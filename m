From: "William J. Earl" <wje@cthulhu.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14416.18872.811910.38578@liveoak.engr.sgi.com>
Date: Thu, 9 Dec 1999 16:30:48 -0800 (PST)
Subject: Re: Getting big areas of memory, in 2.3.x?
In-Reply-To: <E11wDK1-0002nT-00@the-village.bc.nu>
References: <14416.15954.354222.915088@liveoak.engr.sgi.com>
	<E11wDK1-0002nT-00@the-village.bc.nu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: mingo@chiara.csoma.elte.hu, jgarzik@mandrakesoft.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alan Cox writes:
...
 > > for higher-bandwidth targets, such as a graphics controller or a 
 > > HDTV camera.
 > 
 > I don't know of any capture cards that don't do scatter gather. Most of them
 > do scatter gather with skipping and byte alignment so you can DMA around
 > other windows.
 > 
 > This is the main point. There are so so few devices that actually _have_ to
 > have lots of linear memory it is questionable that it is worth paying the
 > price to allow modules to allocate that way

    If the only issue were devices which cannot do scatter-gather, I
would certainly agree.  However, except for the SGI O2 (which only
cares about 64 KB pages in hardware, anyway), all of the SGI hardware
has been happy to do scatter-gather.  What we found with (high
resolution) digital media and other applications which do a lot of
large DMAs was that the overhead of doing the equivalent of
map_kiobuf()/unmap_kiobuf() for large buffers composed of many small
pages was substantial, compared to doing it for large buffers composed
of large pages.  Admittedly, the IRIX equivalent is less efficient
than map_kiobuf(), but map_kiobuf() does still have to touch a lot of
cache lines when visiting all of the small pages in a large buffer.

    Then too, there is the matter of TLB misses for applications which
visit a lot of data, especially on processors with reasonably large
caches.  With 4 KB pages and 64 TLB entries, the TLB cannot map all of
a cache larger than 256 KB.  If the cache is, say, 2 MB and the
application cycles through many of the pages in the cache in a loop,
you can wind up with a TLB miss for almost every load (other than those from
the stack).  With 1 MB pages, there are almost no TLB misses.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
