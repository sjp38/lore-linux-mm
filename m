From: "William J. Earl" <wje@cthulhu.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14416.18132.295161.653334@liveoak.engr.sgi.com>
Date: Thu, 9 Dec 1999 16:18:28 -0800 (PST)
Subject: Re: Getting big areas of memory, in 2.3.x?
In-Reply-To: <Pine.LNX.4.10.9912100139370.12148-100000@chiara.csoma.elte.hu>
References: <Pine.LNX.3.96.991209180518.21542B-100000@kanga.kvack.org>
	<Pine.LNX.4.10.9912100139370.12148-100000@chiara.csoma.elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, Rik van Riel <riel@nl.linux.org>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, Jeff Garzik <jgarzik@mandrakesoft.com>, alan@lxorguk.ukuu.org.uk, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ingo Molnar writes:
 > On Thu, 9 Dec 1999, Benjamin C.R. LaHaise wrote:
 > 
 > > The type of allocation determines what pool memory is allocated from.  
 > > Ie nonpagable kernel allocations come from one zone, atomic
 > > allocations from another and user from yet another.  It's basically
 > > the same thing that the slab does, except for pages.  The key
 > > advantage is that allocations of different types are not mixed, so the
 > > lifetime of allocations in the same zone tends to be similar and
 > > fragmentation tends to be lower.
 > 
 > well, this is perfectly possible with the current zone allocator (check
 > out how build_zonelists() builds dynamic allocation paths). I dont see
 > much point in it though, it might prevent fragmentation to a certain
 > degree, but i dont think it is a fair use of memory resources. (i'm pretty
 > sure the atomic zone would stay unused most of the time) But you might
 > want to try it out - just pass many small zones in free_area_init_core()
 > and modify build_zonelists() to have private and isolated zones for
 > GFP_ATOMIC, etc.
 > 
 > the SLAB is completely different as it has micro-units of a few pages. A
 > zoned allocator must work on a larger scale, and cannot afford wasting
 > memory on the order of those larger units.
...

     For a production implementation of large pages, the zones have to
be more dynamic.  That is, there has to be a way to move a large page
from the "moveable" zone to the "unmoveable" zone (when we run out of
"unmoveable" space and the kernel wants more), and to temporarily
put moveable (small) pages in the "unmoveable" zone, to avoid just
this inefficient use of memory.  (This assumes that an allocation
of an "unmoveable" page will evict a "moveable" page from the "unmoveable"
zone before expanding the "unmoveable" zone, if there are no free
pages left in the "unmoveable" zone.)

    Even this scheme is, of course, not a perfect solution, if there
are multiple large page sizes, and "unmoveable" allocations can
request a page of any size, since one could then wind up with
fragmentation of unmoveable memory.  A reasonable compromise might be
to force "ummoveable" allocations larger than a basic page to some
particular large page size, make that page size the unit of additions
to the "unmoveable" zone, and delete from the "unmoveable" zone any
large pages which hecome entirely free (or composed only of free and
"moveable" pages).  This last is what I did on the SGI O2.  It still
allows for "moveable" large pages of any size, which gains the
efficiency benefits of large pages for applications, at the cost
of limiting driver and other kernel allocations to the specific large
page size.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
