From: "William J. Earl" <wje@cthulhu.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14416.5650.168893.38145@liveoak.engr.sgi.com>
Date: Thu, 9 Dec 1999 12:50:26 -0800 (PST)
Subject: Re: Getting big areas of memory, in 2.3.x?
In-Reply-To: <199912092031.MAA40950@google.engr.sgi.com>
References: <38501014.E5066331@mandrakesoft.com>
	<199912092031.MAA40950@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Jeff Garzik <jgarzik@mandrakesoft.com>, mingo@chiara.csoma.elte.hu, alan@lxorguk.ukuu.org.uk, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Kanoj Sarcar writes:
 > > 
 > > Ingo Molnar wrote:
 > > > hm, does anyone have any conceptual problem with a new
 > > > allocate_largemem(pages) interface in page_alloc.c? It's not terribly hard
 > > > to scan all bitmaps for available RAM and mark the large memory area
 > > > allocated and remove all pages from the freelists. Such areas can only be
 > > > freed via free_largemem(pages). Both calls will be slow, so should be only
 > > > used at driver initialization time and such.
 > > 
 > > Would this interface swap out user pages if necessary?  That sort of
 > > interface would be great, and kill a number of hacks floating around out
 > > there.
 > >
 > 
 > Swapping out user pages is not a sure shot thing unless Linux implements
 > reverse maps, so that we can track which page is being used by which pte. 
 > 
 > Without rmaps, any possible solution will be quite costly, if not an 
 > outright hack, IMO. 

      With rmaps, one can simply move the page, instead of swapping it out.

      Also, even with rmaps, we will also have to have placement control
for "long term" unmoveable allocations.  That is, whenever a page is allocated
for some use where it cannot be moved by the large page assembly routine,
such as certain kernel data structures, it must be placed in an area of
memory devoted to such pages, where that area of memory can grow, by adding
large-page-sized chunks of space ot it, but can be expected to never
shrink.  If a page is converted to such a use, it must be moved to the
"unmoveable" area.  Pages in the "unmoveable" area can be used for "moveable"
purposes, but will sometimes need to be moved to the "moveable" area to make
room for allocations of "unmoveable" pages, to minimize the need to grow
the "unmoveable" area.  Without placement control, memory gradually becomes
fragmented with unmoveable pages, so, after the system has been running
a while, it becomes impossible to allocate any large pages, even with rmaps.

     The SGI O2 implements this model (in IRIX, and successfully
allocates large pages on demand, occupying in total a large percentage
of main memory, even after the system has been running for weeks.

     The main change required to interfaces is a flag to page allocation
specifying "unmoveable allocation" and a pair of "make page unmoveable"
and "make page moveable" functions, to be called when, for example,
an application locks some memory in place, in order to point hardware
control blocks at it.  The "make page unmoveable" routine has to handle
relocating the page, if necessary, including possibly moving some "moveable" 
page out of the way.  The overhead is pretty small, except when memory
is highly congested.  The page cleaner should do a little extra work,
to try to keep some pages in the "unmoveable" area available, to reduce
the likelihood of needing to move pages when allocating an unmoveble
page or when making a moveable page unmoveable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
