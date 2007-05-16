Date: Wed, 16 May 2007 14:50:39 +0100
Subject: Re: [PATCH 1/2] Have kswapd keep a minimum order free other than order-0
Message-ID: <20070516135039.GA7467@skynet.ie>
References: <Pine.LNX.4.64.0705141058590.11319@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0705141111400.11411@schroedinger.engr.sgi.com> <20070514182456.GA9006@skynet.ie> <1179218576.25205.1.camel@rousalka.dyndns.org> <Pine.LNX.4.64.0705150958150.6896@skynet.skynet.ie> <464AC00E.10704@yahoo.com.au> <Pine.LNX.4.64.0705160958230.7139@skynet.skynet.ie> <464ACA68.2040707@yahoo.com.au> <Pine.LNX.4.64.0705161011400.7139@skynet.skynet.ie> <464AF8DB.9030000@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <464AF8DB.9030000@yahoo.com.au>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Nicolas Mailhot <nicolas.mailhot@laposte.net>, Christoph Lameter <clameter@sgi.com>, Andy Whitcroft <apw@shadowen.org>, akpm@linux-foundation.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On (16/05/07 22:28), Nick Piggin didst pronounce:
> Mel Gorman wrote:
> >On Wed, 16 May 2007, Nick Piggin wrote:
> >
> >>Mel Gorman wrote:
> >>
> >>>On Wed, 16 May 2007, Nick Piggin wrote:
> >>
> >>
> >>>>Hmm, so we require higher order pages be kept free even if nothing is
> >>>>using them? That's not very nice :(
> >>>>
> >>>
> >>>Not quite. We are already required to keep a minimum number of pages 
> >>>free even though nothing is using them. The difference is that if it 
> >>>is known high-order allocations are frequently required, the freed 
> >>>pages will be contiguous. If no one calls raise_kswapd_order(), 
> >>>kswapd will continue reclaiming at order-0.
> >>
> >>
> >>And after they are stopped being used, it falls back to order-0?
> >
> >
> >No, raise_kswapd_order() is used when it is known there are many 
> >high-order allocations of a particular value. It becomes the minimum 
> >value kswapd reclaims at. SLUB does not *require* high order allocations 
> >but can be configured to use them so it makes sense to keep 
> >min_free_kbytes at that order to reduce stalls due to direct reclaim.
> 
> The point is you still might not have anything performing those
> allocations from those higher order caches. Or you might have things
> that are doing higher order allocations, but not via slab.
> 

On the contrary, raise_kswapd_order() is called when you *know* things will
be performing those allocations. However, I think what you are saying is
that kswapd could end up reclaiming at the highest-order cache even though
it might be very rarely used. Christoph identified the same problem and sent
a follow-up patch, this is the leader

======

On third thought: The trouble with this solution is that we will now set
the order to that used by the largest kmalloc cache. Bad... this could be
6 on i386 to 13 if CONFIG_LARGE_ALLOCs is set. The large kmalloc caches are
rarely used and we are used to OOMing if those are utilized to frequently.

I guess we should only set this for non kmalloc caches then. 
So move the call into kmem_cache_create? Would make the min order 3 on
most of my mm machines.
===

The second part of what you say is that there could be a non-slab user of
high order allocs. That is true and expected. In that case, the existing
mechanism informs kswapd of the higher order as it does today so it can
reclaim at the higher order for a bit and enter direct reclaim if necessary.

> Basically this is dumbing down the existing higher order watermarking
> already there in favour of a worse special case AFAIKS.
> 

It's not being replaced. That existing watermarking is still used. If it
was being replaced, the for loop in zone_watermark_ok() would have been
taken out.

> 
> >>Why
> >>can't this use the infrastructure that is already in place for that?
> >>
> >
> >The infrastructure there currently deals nicely with the situation where 
> >there are rarely allocations of a high order. This change is for when it 
> >is known there are frequent high-order (e.g. orders 1-4) allocations. 
> >While the callers often can direct reclaim, kswapd should help them 
> >avoid stalls because reducing stalls is one of it's functions. With this 
> >patch, kswapd still reclaims the same number of pages, just tries to 
> >reclaim contiguous ones.
> 
> kswapd already does reclaim on behalf of non-sleeping higher order
> allocations (or at least it does in mainline).
> 

My point is that when it does, a caller is still likely to enter direct
reclaim and kswapd can help prevent stalls if it pre-emptively reclaims at
an order known to be commonly used when free pages is below watermarks

> 
> >>>Arguably, e1000 should also be calling raise_kswapd_order() when it 
> >>>is using jumbo frames.
> >>
> >>
> >>It should be able to handle higher order page allocation failures
> >>gracefully.
> >
> >
> >Has something changed recently that it can handle failures? It might 
> >have because it has been hinted that it's possible, just not very fast.
> 
> I don't know, but it is stupid if it can't.

Well, if it could, order:3 allocation failure reports wouldn't occur
periodically.

> It should not be too hard to keep it fast where it is fast today, and have
> it at least work where it would otherwise fail... just by reserving some
> memory pages in case none can be allocated.
> 

It already reserves and still occasionally hits the problem.

> 
> >>kswapd will be notified of the attempts and go on and try
> >>to free up some higher order pages for it for next time. What is wrong
> >>with this process?
> >
> >
> >It's reactive, it only occurs when a process has already entered direct 
> >reclaim.
> 
> No it should not be. It should be proactive even for higher order 
> allocations.

I don't see why it would be. kswapd is only told to wake up when the
first allocation attempt obeying watermarks fails.

> All this stuff used to work properly :(
> 

It only came to light recently that there might be issues.

> 
> >>Are the higher order watermarks insufficient?
> >>
> >
> >The high-order watermarks are still used to make a process that can 
> >sleep enter direct reclaim when the higher order watermarks are not 
> >being met.
> >
> >>(I would also add that non-arguably, e1000 should also be able to do
> >>scatter gather with jumbo frames too.)
> >>
> >
> >That's another football that has done the laps.
> 
> I think the hardware can do it.
> 

e1000 cards come in such a variety of capabilitys that it's difficult to
tell

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
