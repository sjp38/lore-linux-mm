Date: Sun, 10 Oct 1999 18:34:00 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <Pine.LNX.4.10.9910102350240.1556-100000@alpha.random>
Message-ID: <Pine.GSO.4.10.9910101759340.17820-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Manfred Spraul <manfreds@colorfullife.com>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sun, 10 Oct 1999, Andrea Arcangeli wrote:

> On Sun, 10 Oct 1999, Alexander Viro wrote:
> 
> >I still think that just keeping a cyclic list of pages, grabbing from that
> >list before taking mmap_sem _if_ we have a chance for blocking
> >__get_free_page(), refilling if the list is empty (prior to down()) and
> >returning the page into the list if we didn't use it may be the simplest
> >way.
> 
> I can't understand very well your plan.
> 
> We just have a security pool. We just block only when the pool become low.
> To refill our just existing pool we have to walk the vmas. That's the
> problem in first place.

I missed the fact that page-in can suck additional pages. Sorry. Original
idea was to do that _before_ we are getting the mmap_sem - that would
allow to grab it in swap_out_mm. 

We can't do _anything_ with vmas while swap_out_mm is running over their
mm - no list modifications, no vma removal, etc. We could introduce a new
semaphore (spinlocks are not going to work - ->swapout gets vma as
argument and it can sleep. The question being: where can we trigger
__get_free_pages() with __GFP_WAIT if the mmap_sem is held? And another
one - where do we modify ->mmap? If they can be easily separated -
fine. Then we need to protect the thing with semaphore - no contention in
normal case (we already have mmap_sem), enough protection in the swapper.
Probably it make sense to choose the protected area as wide as possible -
there will be no contention in normal case and we can cut the overhead
down.

I'll try to look through the thing tonight (while the truncate stuff will
eat the fs on the testbox ;-), but I'ld be really grateful if some of VM
people would check the results.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
