Date: Wed, 16 May 2007 16:32:15 +0100
Subject: Re: [PATCH 1/2] Have kswapd keep a minimum order free other than order-0
Message-ID: <20070516153215.GB10225@skynet.ie>
References: <20070514182456.GA9006@skynet.ie> <1179218576.25205.1.camel@rousalka.dyndns.org> <Pine.LNX.4.64.0705150958150.6896@skynet.skynet.ie> <464AC00E.10704@yahoo.com.au> <Pine.LNX.4.64.0705160958230.7139@skynet.skynet.ie> <464ACA68.2040707@yahoo.com.au> <Pine.LNX.4.64.0705161011400.7139@skynet.skynet.ie> <464AF8DB.9030000@yahoo.com.au> <20070516135039.GA7467@skynet.ie> <464B0F81.2090103@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <464B0F81.2090103@yahoo.com.au>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Nicolas Mailhot <nicolas.mailhot@laposte.net>, Christoph Lameter <clameter@sgi.com>, Andy Whitcroft <apw@shadowen.org>, akpm@linux-foundation.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On (17/05/07 00:04), Nick Piggin didst pronounce:
> Mel Gorman wrote:
> >On (16/05/07 22:28), Nick Piggin didst pronounce:
> >
> >>Mel Gorman wrote:
> >>
> >>>On Wed, 16 May 2007, Nick Piggin wrote:
> >>>
> 
> >>>No, raise_kswapd_order() is used when it is known there are many 
> >>>high-order allocations of a particular value. It becomes the minimum 
> >>>value kswapd reclaims at. SLUB does not *require* high order allocations 
> >>>but can be configured to use them so it makes sense to keep 
> >>>min_free_kbytes at that order to reduce stalls due to direct reclaim.
> >>
> >>The point is you still might not have anything performing those
> >>allocations from those higher order caches. Or you might have things
> >>that are doing higher order allocations, but not via slab.
> >>
> >
> >
> >On the contrary, raise_kswapd_order() is called when you *know* things will
> >be performing those allocations. However, I think what you are saying is
> >that kswapd could end up reclaiming at the highest-order cache even though
> >it might be very rarely used. Christoph identified the same problem and 
> >sent
> >a follow-up patch, this is the leader
> >
> >======
> >
> >On third thought: The trouble with this solution is that we will now set
> >the order to that used by the largest kmalloc cache. Bad... this could be
> >6 on i386 to 13 if CONFIG_LARGE_ALLOCs is set. The large kmalloc caches are
> >rarely used and we are used to OOMing if those are utilized to frequently.
> >
> >I guess we should only set this for non kmalloc caches then. 
> >So move the call into kmem_cache_create? Would make the min order 3 on
> >most of my mm machines.
> >===
> 
> You do not *know* if the slab is going to be allocated from. Or maybe it
> is a few times at bootup, or once every 10 minutes.
> 

So is your primary issue with raise_kswapd_order() being called at the
time a cache is opened for use and instead it should be more selective?

> 
> >The second part of what you say is that there could be a non-slab user of
> >high order allocs. That is true and expected. In that case, the existing
> >mechanism informs kswapd of the higher order as it does today so it can
> >reclaim at the higher order for a bit and enter direct reclaim if 
> >necessary.
> 
> You seem to have broken the existing mechanism though.
> 

How is it broken exactly? What has changed in this patch is that there
may be a minimum order that kswapd reclaims at. The same minimum number
of pages are kept free.

If the watermark was totally ignored with the second patch, I would understand
but they are still obeyed. Even if it is an ALLOC_HIGH or ALLOC_HARDER
allocation, the watermarks are obeyed for order-0 so memory does not get
exhausted as that could cause a host of problems. The difference is if this
is a HIGH or HARDER allocation and the memory can be granted without going
belong the order-0 watermarks, it'll succeed. Would it be better if the
lack of ALLOC_CPUSET was used to determine when only order-0 watermarks
should be obeyed?

> >>Basically this is dumbing down the existing higher order watermarking
> >>already there in favour of a worse special case AFAIKS.
> >>
> >
> >
> >It's not being replaced. That existing watermarking is still used. If it
> >was being replaced, the for loop in zone_watermark_ok() would have been
> >taken out.
> 
> Patch 2 sure doesn't make it any better.
> 

The second patch is simply saying "If you can satisfy the allocation without
going below the watermarks for order-0, then do it". Again, if it used
!(alloc_flags & ALLOC_CPUSET), would you be happier?

> 
> >>kswapd already does reclaim on behalf of non-sleeping higher order
> >>allocations (or at least it does in mainline).
> >>
> >
> >
> >My point is that when it does, a caller is still likely to enter direct
> >reclaim and kswapd can help prevent stalls if it pre-emptively reclaims at
> >an order known to be commonly used when free pages is below watermarks
> 
> So we should increase the watermarks, and keep the existing, working
> code there and it will work for everyone, not just for slab, and it
> will not keep higher orders free if they are not needed.
> 

Raising watermarks is no guarantee that a high-order allocation that can sleep
will occur at the right time to kick kswapd awake and that it'll get back from
whatever it's doing in time to spot the new order and start reclaiming again.

> >>>>>Arguably, e1000 should also be calling raise_kswapd_order() when it 
> >>>>>is using jumbo frames.
> >>>>
> >>>>
> >>>>It should be able to handle higher order page allocation failures
> >>>>gracefully.
> >>>
> >>>
> >>>Has something changed recently that it can handle failures? It might 
> >>>have because it has been hinted that it's possible, just not very fast.
> >>
> >>I don't know, but it is stupid if it can't.
> >
> >
> >Well, if it could, order:3 allocation failure reports wouldn't occur
> >periodically.
> 
> They are reports of failures, not failure to handle the failures.
> 

If the failures were being handled correctly, why would it be logging at
all? They would have set __GFP_NOWARN and recovered silently.

> 
> >>It should not be too hard to keep it fast where it is fast today, and have
> >>it at least work where it would otherwise fail... just by reserving some
> >>memory pages in case none can be allocated.
> >>
> >
> >
> >It already reserves and still occasionally hits the problem.
> 
> e1000 reserves page? It would have to use them in a manner that guaranteed
> timely return to the reserve pool like mempools. If it did that then it
> would not have a problem.
> 

When I last looked, they kept a series of buffers in a ring buffer. My
understanding at the time was that this buffer regularly gets depleted
and refilled.

Ultimately, the allocations are done kmalloc() but with jumbo frames, the
kmalloc() is for 32K. As it happens, this means that if jumbo frames are in
use, then that kmalloc slab is opened and the minimum kswapd order is raised
so that min_free_kbytes is kept contiguous for those atomic allocations.

> >>>>kswapd will be notified of the attempts and go on and try
> >>>>to free up some higher order pages for it for next time. What is wrong
> >>>>with this process?
> >>>
> >>>
> >>>It's reactive, it only occurs when a process has already entered direct 
> >>>reclaim.
> >>
> >>No it should not be. It should be proactive even for higher order 
> >>allocations.
> >
> >
> >I don't see why it would be. kswapd is only told to wake up when the
> >first allocation attempt obeying watermarks fails.
> 
> That first watermark is the the reclaim watermark, not the allocation
> watermark.
> 
> 
> >>All this stuff used to work properly :(
> >>
> >
> >
> >It only came to light recently that there might be issues.
> 
> I mean kswapd asynchronously freeing higher order pages proactively. We
> should get that working again first.
> 

What do you suggest then?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
