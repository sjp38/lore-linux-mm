Message-ID: <39CA50B0.77A2CD84@norran.net>
Date: Thu, 21 Sep 2000 20:17:20 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: 2.4.0-test9-pre4: __alloc_pages(...) try_again:
References: <Pine.Linu.4.10.10009210655320.761-100000@mikeg.weiden.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <mikeg@weiden.de>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Mike Galbraith wrote:
> 
> On Wed, 20 Sep 2000, Roger Larsson wrote:
> 
> > Hi,
> >
> >
> > Trying to find out why test9-pre4 freezes with mmap002
> > I added a counter for try_again loops.
> >
> > ... __alloc_pages(...)
> >
> >         int direct_reclaim = 0;
> >         unsigned int gfp_mask = zonelist->gfp_mask;
> >         struct page * page = NULL;
> > +       int try_again_loops = 0;
> >
> > - - -
> >
> > +         printk("VM: sync kswapd (direct_reclaim: %d) try_again #
> > %d\n",
> > +                direct_reclaim, ++try_again_loops);
> >                         wakeup_kswapd(1);
> >                         goto try_again;
> >
> >
> > Result was surprising:
> >   direct_reclaim was 1.
> >   try_again_loops did never stop increasing (note: it is not static,
> >   and should restart from zero after each success)
> >
> > Why does this happen?
> > a) kswapd did not succeed in freeing a suitable page?
> > b) __alloc_pages did not succeed in grabbing the page?
> 
> Hi Roger,
> 
> A trace of locked up box shows endless repetitions of kswapd aparantly
> failing to free anything.  What I don't see in the trace snippet below
> is reclaim_page().  I wonder if this test in __alloc_pages_limit()
> should include an || direct_reclaim.

When I have run into this problem I have had no inactive_clean pages =>
reclaim_page() should not work... :-(
That is your situation too...


> 
>                 if (z->free_pages + z->inactive_clean_pages > water_mark) {
>                         struct page *page = NULL;
>                         /* If possible, reclaim a page directly. */
>                         if (direct_reclaim && z->free_pages < z->pages_min + 8)
>                                 page = reclaim_page(z);
>                         /* If that fails, fall back to rmqueue. */
>                         if (!page)
>                                 page = rmqueue(z, order);
>                         if (page)
>                                 return page;
>                 }
> 
> dmesg log after breakout:
> SysRq: Suspending trace
> SysRq: Show Memory
> Mem-info:
> Free pages:        1404kB (     0kB HighMem)
> ( Active: 274, inactive_dirty: 49, inactive_clean: 0, free: 351 (255 510 765) )
> 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB = 512kB)
> 1*4kB 1*8kB 1*16kB 1*32kB 1*64kB 0*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB = 892kB)
> = 0kB)
> Swap cache: add 470291, delete 470291, find 212689/658406
> Free swap:       199024kB
> 32752 pages of RAM
> 0 pages of HIGHMEM
> 4321 reserved pages
> 296 pages shared
> 0 pages swap cached
> 0 pages in page table cache
> Buffer memory:      120kB
> SysRq: Terminate All Tasks
> 


--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
