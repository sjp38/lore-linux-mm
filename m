Date: Wed, 16 May 2007 17:46:32 +0100
Subject: Re: [PATCH 1/2] Have kswapd keep a minimum order free other than order-0
Message-ID: <20070516164631.GD10225@skynet.ie>
References: <Pine.LNX.4.64.0705150958150.6896@skynet.skynet.ie> <464AC00E.10704@yahoo.com.au> <Pine.LNX.4.64.0705160958230.7139@skynet.skynet.ie> <464ACA68.2040707@yahoo.com.au> <Pine.LNX.4.64.0705161011400.7139@skynet.skynet.ie> <464AF8DB.9030000@yahoo.com.au> <20070516135039.GA7467@skynet.ie> <464B0F81.2090103@yahoo.com.au> <20070516153215.GB10225@skynet.ie> <464B26E8.3060404@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <464B26E8.3060404@yahoo.com.au>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Nicolas Mailhot <nicolas.mailhot@laposte.net>, Christoph Lameter <clameter@sgi.com>, Andy Whitcroft <apw@shadowen.org>, akpm@linux-foundation.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On (17/05/07 01:44), Nick Piggin didst pronounce:
> Mel Gorman wrote:
> >On (17/05/07 00:04), Nick Piggin didst pronounce:
> >
> >>Mel Gorman wrote:
> 
> >>>I guess we should only set this for non kmalloc caches then. 
> >>>So move the call into kmem_cache_create? Would make the min order 3 on
> >>>most of my mm machines.
> >>>===
> >>
> >>You do not *know* if the slab is going to be allocated from. Or maybe it
> >>is a few times at bootup, or once every 10 minutes.
> >>
> >
> >
> >So is your primary issue with raise_kswapd_order() being called at the
> >time a cache is opened for use and instead it should be more selective?
> >
> >
> >>>The second part of what you say is that there could be a non-slab user of
> >>>high order allocs. That is true and expected. In that case, the existing
> >>>mechanism informs kswapd of the higher order as it does today so it can
> >>>reclaim at the higher order for a bit and enter direct reclaim if 
> >>>necessary.
> >>
> >>You seem to have broken the existing mechanism though.
> >>
> >
> >
> >How is it broken exactly? What has changed in this patch is that there
> >may be a minimum order that kswapd reclaims at. The same minimum number
> >of pages are kept free.
> 
> I mean with patch 2.
> 

Ok.

> 
> >If the watermark was totally ignored with the second patch, I would 
> >understand
> >but they are still obeyed. Even if it is an ALLOC_HIGH or ALLOC_HARDER
> >allocation, the watermarks are obeyed for order-0 so memory does not get
> >exhausted as that could cause a host of problems. The difference is if this
> >is a HIGH or HARDER allocation and the memory can be granted without going
> >belong the order-0 watermarks, it'll succeed. Would it be better if the
> >lack of ALLOC_CPUSET was used to determine when only order-0 watermarks
> >should be obeyed?
> 
> But I don't know why you want to disobey higher order watermarks in the
> first place.

Because the original problem was bio_alloc() allocations failing and the OOM
log showed that the higher-order pages were available. Patch 2 addressed it
by succeeding these allocations if the min watermark was not breached with the
knowledge that kswapd was awake and reclaiming at the relevant order. I think
it may even have solved it without the kswapd change but the kswapd change
seemed sensible.

> *Those* are exactly the things that are going to be helpful
> to fix this problem of atomic higher order allocations failing or non
> atomic ones going into direct reclaim.
> 

And the intention was that non-atomic ones would go into direct reclaim
after kicking kswapd but the atomic allocations would at least succeeed if
the memory was there as long as they don't totally mess up watermarks.

> 
> >>>It's not being replaced. That existing watermarking is still used. If it
> >>>was being replaced, the for loop in zone_watermark_ok() would have been
> >>>taken out.
> >>
> >>Patch 2 sure doesn't make it any better.
> >>
> >
> >
> >The second patch is simply saying "If you can satisfy the allocation 
> >without
> >going below the watermarks for order-0, then do it". Again, if it used
> >!(alloc_flags & ALLOC_CPUSET), would you be happier?
> 
> No ;)
> 

heh.

> 
> >>>My point is that when it does, a caller is still likely to enter direct
> >>>reclaim and kswapd can help prevent stalls if it pre-emptively reclaims 
> >>>at
> >>>an order known to be commonly used when free pages is below watermarks
> >>
> >>So we should increase the watermarks, and keep the existing, working
> >>code there and it will work for everyone, not just for slab, and it
> >>will not keep higher orders free if they are not needed.
> >>
> >
> >
> >Raising watermarks is no guarantee that a high-order allocation that can 
> >sleep
> >will occur at the right time to kick kswapd awake and that it'll get back 
> >from
> >whatever it's doing in time to spot the new order and start reclaiming 
> >again.
> 
> You don't *need* a higher order allocation that can sleep in order
> to kick kswapd. Crikey, I keep saying this.
> 

Indeed, we seem to have got stuck in a loop of sorts.

I understand that kswapd gets kicked awake either way but there must be a
timing issue. Lets say we had a situations like

order-0 alloc
watermark hit => wake kswapd
order-0 alloc			kswapd reclaiming order 0
order-0 alloc			kswapd reclaiming order 0
order-3 alloc => kick kswap for order 3
order-0 alloc			kswapd reclaiming order 0
order-3 alloc			kswapd reclaiming order 0
order-3 alloc			kswapd reclaiming order 0
order-3 alloc => highorder mark hit, fail

kswapd will keep reclaiming at order-0 until it completes a reclaim cycle
and spots the new order and start over again. So there is a potentially
sizable window there where problems can hit. Right?

> >>>Well, if it could, order:3 allocation failure reports wouldn't occur
> >>>periodically.
> >>
> >>They are reports of failures, not failure to handle the failures.
> >>
> >
> >
> >If the failures were being handled correctly, why would it be logging at
> >all? They would have set __GFP_NOWARN and recovered silently.
> 
> Lots of places don't set __GFP_NOWARN but handle failures. Generally
> you want to keep the warning even for atomic allocations if it is
> a reasonably small order (0 or 1 or even 2).
> 

Fair enough

> The failures I have seen are not "networking stops working". They are
> "e1000 gives page allocation failures", and the replies have always
> been "that's not unexpected". Have you seen *any* of the former type?
> 

Admittadly, I don't recall complaints that networking totally failed. The
result should be that packets drop until such time that the allocations
start succeeding again.

> >>>It already reserves and still occasionally hits the problem.
> >>
> >>e1000 reserves page? It would have to use them in a manner that guaranteed
> >>timely return to the reserve pool like mempools. If it did that then it
> >>would not have a problem.
> >>
> >
> >
> >When I last looked, they kept a series of buffers in a ring buffer. My
> >understanding at the time was that this buffer regularly gets depleted
> >and refilled.
> 
> But refilled via the allocator, right? One which does not revert to a
> private stash if it cannot get a page.
> 

True.

> 
> >>>>All this stuff used to work properly :(
> >>>>
> >>>
> >>>
> >>>It only came to light recently that there might be issues.
> >>
> >>I mean kswapd asynchronously freeing higher order pages proactively. We
> >>should get that working again first.
> >>
> >
> >
> >What do you suggest then?
> 
> Working out why it apparently isn't working, first. Then maybe look at
> raising watermarks (they get reduced fairly rapidly as the order increases,
> so it might just be that there is not enough at order-3).
> 

I believe it failed to work due to a combination of kswapd reclaiming at
the wrong order for a while and the fact that the watermarks are pretty
agressive when it comes to higher orders. I'm trying to think of
alternative fixes but keep coming back to the current fix using 
!(alloc_flags & ALLOC_CPUSET) to allow !wait allocations to succeed if
the memory is there and above min watermarks at order-0.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
