class Libosmium < Formula
  desc "Fast and flexible C++ library for working with OpenStreetMap data."
  homepage "http://osmcode.org/libosmium/"
  url "https://github.com/osmcode/libosmium/archive/v2.12.0.tar.gz"
  sha256 "6fd6812939c80bf1ab58d160e20202f400b26a36941f1e5c939a0a8f3a03af92"

  bottle do
    cellar :any_skip_relocation
    sha256 "0f4f607bb1dd85d5f3745e25576db4a033661ece86fbf09f54b9bd901de013ff" => :sierra
    sha256 "0f4f607bb1dd85d5f3745e25576db4a033661ece86fbf09f54b9bd901de013ff" => :el_capitan
    sha256 "0f4f607bb1dd85d5f3745e25576db4a033661ece86fbf09f54b9bd901de013ff" => :yosemite
  end

  depends_on "cmake" => :build
  depends_on "boost" => :build
  depends_on "google-sparsehash" => :optional
  depends_on "expat" => :optional
  depends_on "gdal" => :optional
  depends_on "proj" => :optional
  depends_on "doxygen" => :optional

  def install
    mkdir "build" do
      system "cmake", *std_cmake_args, "-DINSTALL_GDALCPP=ON", "-DINSTALL_PROTOZERO=ON", "-DINSTALL_UTFCPP=ON", ".."
      system "make", "install"
    end
  end

  test do
    (testpath/"test.osm").write <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <osm version="0.6" generator="handwritten">
      <node id="1" lat="0.001" lon="0.001" user="Dummy User" uid="1" version="1" changeset="1" timestamp="2015-11-01T19:00:00Z"></node>
      <node id="2" lat="0.002" lon="0.002" user="Dummy User" uid="1" version="1" changeset="1" timestamp="2015-11-01T19:00:00Z"></node>
      <way id="1" user="Dummy User" uid="1" version="1" changeset="1" timestamp="2015-11-01T19:00:00Z">
        <nd ref="1"/>
        <nd ref="2"/>
        <tag k="name" v="line"/>
      </way>
      <relation id="1" user="Dummy User" uid="1" version="1" changeset="1" timestamp="2015-11-01T19:00:00Z">
        <member type="node" ref="1" role=""/>
        <member type="way" ref="1" role=""/>
      </relation>
    </osm>
    EOS

    (testpath/"test.cpp").write <<-EOS.undent
    #include <cstdlib>
    #include <iostream>
    #include <osmium/io/xml_input.hpp>

    int main(int argc, char* argv[]) {
      osmium::io::File input_file{argv[1]};
      osmium::io::Reader reader{input_file};
      while (osmium::memory::Buffer buffer = reader.read()) {}
      reader.close();
    }
    EOS

    system ENV.cxx, "-std=c++11", "-stdlib=libc++", "-lexpat", "-o", "libosmium_read", "test.cpp"
    system "./libosmium_read", "test.osm"
  end
end
