Date: Wed, 18 Jul 2001 11:18:18 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] Separate global/perzone inactive/free shortage
Message-ID: <20010718111818.D6826@redhat.com>
References: <OF11D0664E.20E72543-ON85256A8B.004B248D@pok.ibm.com> <Pine.LNX.4.33.0107180808470.724-100000@mikeg.weiden.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33.0107180808470.724-100000@mikeg.weiden.de>; from mikeg@wen-online.de on Wed, Jul 18, 2001 at 10:54:52AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <mikeg@wen-online.de>
Cc: Bulent Abali <abali@us.ibm.com>, "Stephen C. Tweedie" <sct@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, Dirk Wetter <dirkw@rentec.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jul 18, 2001 at 10:54:52AM +0200, Mike Galbraith wrote:

> Much worse is the case of Dirk's two 2gig simulations on a dual cpu
> 4gig box.  It will guaranteed allocate all of the dma zone to his two
> tasks vm.  It will also guaranteed unbalance the zone.  Doesn't that
> also guarantee that we will walk pagetables endlessly each and every
> time a ZONE_DMA page is issued?  Try to write out a swapcache page,
> and you might get a dma page, try to do _anything_ and you might get
> a ZONE_DMA page.  With per zone balancing, you will turn these pages
> over much much faster than before, and the aging will be unfair in
> the extreme.. it absolutely has to be.  SCT's suggestion would make
> the total pressure equal, but it would not (could not) correct the
> problem of searching for this handful of pages, the very serious cost
> of owning a ZONE_DMA page, nor the problem of a specific request for
> GFP_DMA pages having a reasonable chance of succeeding.

The round-robin scheme would result in 16MB worth of allocations ever
2GB of requests coming from ZONE_DMA.  That's one in 128.

But the impact of this on memory pressure depends on how we distribute
PAGES_HIGH/PAGES_LOW allocation requests, and at what point we wake up
the reclaim code.  If we have 50 pages between PAGES_HIGH and
PAGES_LOW for DMA zone, and the reclaim target is PAGES_HIGH, then we
won't start the reclaim until (50*128) allocations have been done
since the last one --- that's 25MB of allocations.  Plus, the reclaim
that does kick off won't be scanning the VM for just one DMA page, it
will keep scanning for a bunch of them, so it's just one VM pass for
that whole 25MB of allocation.  At the very least, this helps spread
the load.

But on top of that, we need to make a distinction between directed
reclaim and opportunistic reclaim.  What I mean by that is this: we
need not force the memory reclaim logic to try to balance the DMA
zone unnecessarily; hence we should not force it to scavenge in DMA if
the (free+inactive) count is above pages_low.  However, we *should*
still age DMA pages if we happen to be triggering the aging loop
anyway.  If pressure on the NORMAL zone triggers aging, then sure, we
can top up the DMA zone.  So, for page aging, if the memory pressure
is balanced, the aging should not have to do a specific pass over the
DMA zone at all --- the aging done in response to pressure elsewhere
ought to have a proportionate impact on the DMA zone's inactive queue
too.

> IMHO, it is really really bad, that any fallback allocation can also
> bring the dma zone into critical, and these allocations may end up in
> kernel structures which are invisible to the balancing logic

That is the crux of the problem.  ext3's journaling, XFS with deferred
allocation, and other advanced filesystem activities will just make
this worse, because even normal file data may suddenly become
"pinned".  With transactions, you can't write out dirty data until any
pending syscalls which are still operating on that transaction
complete.  With deferred block allocation, you can't write out dirty
data without first doing extra filesystem operations to assign disk
blocks for them.

It's not really possible to account this stuff 100% right now ---
mlock() is just too hard to deal with in the absense of rmaps (because
when you munlock() a page, it's currently too expensive to check
whether any other tasks still have a lock on the page.)  A separate
lock_count on the page would help here --- that would allow
the filesystem, the VM and any other components of the system to
register temporary or permanent pins on a page for balancing purposes.

*If* you can account for pinned pages, much of the current trouble
disappears --- you can even do 4MB allocations effectively if you have
the ability to restrict permanently pinned pages to certain zones, and
to force temporary pins out of memory when you need to cleanse a
particular 4MB region for a large allocation.

But for now we have absolutely no such accounting, so if you combine
Reiserfs, ext3 and XFS all on one box, all of them doing their own
half-hearted attempts to avoid flooding memory with pinned pages but
none of them communicating with each other, we can most certainly
deadlock the system.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
