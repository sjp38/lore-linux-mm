Message-ID: <464C48F1.3060903@shadowen.org>
Date: Thu, 17 May 2007 13:22:09 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] Have kswapd keep a minimum order free other than
 order-0
References: <Pine.LNX.4.64.0705150958150.6896@skynet.skynet.ie> <464AC00E.10704@yahoo.com.au> <Pine.LNX.4.64.0705160958230.7139@skynet.skynet.ie> <464ACA68.2040707@yahoo.com.au> <Pine.LNX.4.64.0705161011400.7139@skynet.skynet.ie> <464AF8DB.9030000@yahoo.com.au> <20070516135039.GA7467@skynet.ie> <464B0F81.2090103@yahoo.com.au> <20070516153215.GB10225@skynet.ie> <464B26E8.3060404@yahoo.com.au> <20070516164631.GD10225@skynet.ie> <464BFF9D.809@yahoo.com.au>
In-Reply-To: <464BFF9D.809@yahoo.com.au>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Mel Gorman <mel@skynet.ie>, Nicolas Mailhot <nicolas.mailhot@laposte.net>, Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Mel Gorman wrote:
>> On (17/05/07 01:44), Nick Piggin didst pronounce:
> 
>>>> If the watermark was totally ignored with the second patch, I would
>>>> understand
>>>> but they are still obeyed. Even if it is an ALLOC_HIGH or ALLOC_HARDER
>>>> allocation, the watermarks are obeyed for order-0 so memory does not
>>>> get
>>>> exhausted as that could cause a host of problems. The difference is
>>>> if this
>>>> is a HIGH or HARDER allocation and the memory can be granted without
>>>> going
>>>> belong the order-0 watermarks, it'll succeed. Would it be better if the
>>>> lack of ALLOC_CPUSET was used to determine when only order-0 watermarks
>>>> should be obeyed?
>>>
>>> But I don't know why you want to disobey higher order watermarks in the
>>> first place.
>>
>>
>> Because the original problem was bio_alloc() allocations failing and
>> the OOM
>> log showed that the higher-order pages were available. Patch 2
>> addressed it
>> by succeeding these allocations if the min watermark was not breached
>> with the
>> knowledge that kswapd was awake and reclaiming at the relevant order.
>> I think
>> it may even have solved it without the kswapd change but the kswapd
>> change
>> seemed sensible.
> 
> But that just breaks the watermarks.
> 
> It could be that the actual values of the watermarks as they are now are
> not very good ones, which is where the problem is coming from.
> 
> 
>>> *Those* are exactly the things that are going to be helpful
>>> to fix this problem of atomic higher order allocations failing or non
>>> atomic ones going into direct reclaim.
>>>
>>
>>
>> And the intention was that non-atomic ones would go into direct reclaim
>> after kicking kswapd but the atomic allocations would at least
>> succeeed if
>> the memory was there as long as they don't totally mess up watermarks.
> 
> But we have 3 levels of watermarks, so you can keep a reserve for atomic
> allocations _and_ a buffer between the reclaim watermark and the direct
> reclaim watermark.
> 
> 
>>>> Raising watermarks is no guarantee that a high-order allocation that
>>>> can sleep
>>>> will occur at the right time to kick kswapd awake and that it'll get
>>>> back from
>>>> whatever it's doing in time to spot the new order and start
>>>> reclaiming again.
>>>
>>> You don't *need* a higher order allocation that can sleep in order
>>> to kick kswapd. Crikey, I keep saying this.
>>>
>>
>>
>> Indeed, we seem to have got stuck in a loop of sorts.
>>
>> I understand that kswapd gets kicked awake either way but there must be a
>> timing issue. Lets say we had a situations like
>>
>> order-0 alloc
>> watermark hit => wake kswapd
>> order-0 alloc            kswapd reclaiming order 0
>> order-0 alloc            kswapd reclaiming order 0
>> order-3 alloc => kick kswap for order 3
>> order-0 alloc            kswapd reclaiming order 0
>> order-3 alloc            kswapd reclaiming order 0
>> order-3 alloc            kswapd reclaiming order 0
>> order-3 alloc => highorder mark hit, fail
>>
>> kswapd will keep reclaiming at order-0 until it completes a reclaim cycle
>> and spots the new order and start over again. So there is a potentially
>> sizable window there where problems can hit. Right?
> 
> Take a look at the code. wakeup_kswapd and __alloc_pages.
> 
> First, assume the zone is above high watermarks for order-0 and order-1.
> order-0 allocs...
> order-1 low watermark hit => don't care, not allocing order-1
> order-0 low watermark hit => wake kswapd reclaim order 0
> order-1 alloc => wakeup_kswapd raises kswapd_max_order to 1
> order-1 allocs continue to succeed until the min watermark is hit
> order-1 *atomic* allocs continue until the atomic reserve is hit
> order-1 memalloc allocs continue until no more order-1 pages left.

This represents the ideal.  However we never consider the reserves at
order-1 unless we get an order-1 allocation.  With lots of order-0
allocations (the norm) we can run the order-1 availability well below
even the atomic reserve without anyone noticing, while the total reserve
is above the order-0 low watermark.  Here kswapd has been idle as there
is only order-0 activity and we have sufficient of those.  THEN an
order-1 comes in, we are below the order-1 low watermarks, we wake
kswapd, and retry and discover we are below the atomic threshold and
_fail_ the allocation.

> 
> There really is (or should be) a proper watermarking system in place that
> provides the right buffering for higher order allocations.

I think that this is should be, not is.

>>> Working out why it apparently isn't working, first. Then maybe look at
>>> raising watermarks (they get reduced fairly rapidly as the order
>>> increases,
>>> so it might just be that there is not enough at order-3).
>>>
>>
>>
>> I believe it failed to work due to a combination of kswapd reclaiming at
>> the wrong order for a while and the fact that the watermarks are pretty
>> agressive when it comes to higher orders. I'm trying to think of
>> alternative fixes but keep coming back to the current fix using
>> !(alloc_flags & ALLOC_CPUSET) to allow !wait allocations to succeed if
>> the memory is there and above min watermarks at order-0.
> 
> kswapd reclaiming at the wrong order should be a bug. It should start
> reclaiming at the right order as soon as an allocation (atomic or not)
> goes through the "start reclaiming now" watermark.
> 
> Now this is just looking at mainline code that has the kswapd_max_order,
> and kswapd doesn't actually reclaim "at" any order -- it just uses the
> kswapd_max_order to know when the required "stop reclaiming now" marks
> have been hit. If lumpy reclaim is not reclaiming at the right order,
> then it means it isn't refreshing from kswapd_max_order enough.

Yes I believe all of this is working as designed.  The problem is that
we treat order-0 and order-1 allocations as independant.  We do not take
into account that we split order-1's to make order-0.  We do not check
the order-1 reserve for order 0 and so wake kswapd early enough.  It is
very hard given the interdependant nature if the current calculation to
detect transitions at _other_ orders when we allocate at any specific order.

Hmmmmmm.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
