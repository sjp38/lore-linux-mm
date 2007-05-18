Message-ID: <464D0E7C.5050509@yahoo.com.au>
Date: Fri, 18 May 2007 12:25:00 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] Have kswapd keep a minimum order free other than
 order-0
References: <Pine.LNX.4.64.0705150958150.6896@skynet.skynet.ie> <464AC00E.10704@yahoo.com.au> <Pine.LNX.4.64.0705160958230.7139@skynet.skynet.ie> <464ACA68.2040707@yahoo.com.au> <Pine.LNX.4.64.0705161011400.7139@skynet.skynet.ie> <464AF8DB.9030000@yahoo.com.au> <20070516135039.GA7467@skynet.ie> <464B0F81.2090103@yahoo.com.au> <20070516153215.GB10225@skynet.ie> <464B26E8.3060404@yahoo.com.au> <20070516164631.GD10225@skynet.ie> <464BFF9D.809@yahoo.com.au> <464C48F1.3060903@shadowen.org>
In-Reply-To: <464C48F1.3060903@shadowen.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Mel Gorman <mel@skynet.ie>, Nicolas Mailhot <nicolas.mailhot@laposte.net>, Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andy Whitcroft wrote:
> Nick Piggin wrote:

>>>order-0 alloc
>>>watermark hit => wake kswapd
>>>order-0 alloc            kswapd reclaiming order 0
>>>order-0 alloc            kswapd reclaiming order 0
>>>order-3 alloc => kick kswap for order 3
>>>order-0 alloc            kswapd reclaiming order 0
>>>order-3 alloc            kswapd reclaiming order 0
>>>order-3 alloc            kswapd reclaiming order 0
>>>order-3 alloc => highorder mark hit, fail
>>>
>>>kswapd will keep reclaiming at order-0 until it completes a reclaim cycle
>>>and spots the new order and start over again. So there is a potentially
>>>sizable window there where problems can hit. Right?
>>
>>Take a look at the code. wakeup_kswapd and __alloc_pages.
>>
>>First, assume the zone is above high watermarks for order-0 and order-1.
>>order-0 allocs...
>>order-1 low watermark hit => don't care, not allocing order-1
>>order-0 low watermark hit => wake kswapd reclaim order 0
>>order-1 alloc => wakeup_kswapd raises kswapd_max_order to 1
>>order-1 allocs continue to succeed until the min watermark is hit
>>order-1 *atomic* allocs continue until the atomic reserve is hit
>>order-1 memalloc allocs continue until no more order-1 pages left.
> 
> 
> This represents the ideal.  However we never consider the reserves at
> order-1 unless we get an order-1 allocation.  With lots of order-0
> allocations (the norm) we can run the order-1 availability well below
> even the atomic reserve without anyone noticing, while the total reserve
> is above the order-0 low watermark.

Yes, but my reply was addressing the misconception that kswapd never
has its reclaim-order updated while it is reclaiming for a lower order.

It is by design that we don't make order-0 allocations notice order-1
watermarks, so if there is some problem with that, then that is what
should be changed. Not randomly break the watermarking code.


>  Here kswapd has been idle as there
> is only order-0 activity and we have sufficient of those.  THEN an
> order-1 comes in, we are below the order-1 low watermarks, we wake
> kswapd, and retry and discover we are below the atomic threshold and
> _fail_ the allocation.

And that is by design because we don't want to have order-1 pages free
if there are only order-0 allocations.

Anyway, atomic allocations are able to fail gracefully, in which case
kswapd will be kicked for next time. Non-atomic allocations can enter
direct reclaim, so it isn't the end of the world.


>>There really is (or should be) a proper watermarking system in place that
>>provides the right buffering for higher order allocations.
> 
> 
> I think that this is should be, not is.

Well you also said earlier that our problems are due to higher order
watermarks being too aggressive. So I think what is needed is to
actually work out what the real problem is first.


>>>I believe it failed to work due to a combination of kswapd reclaiming at
>>>the wrong order for a while and the fact that the watermarks are pretty
>>>agressive when it comes to higher orders. I'm trying to think of
>>>alternative fixes but keep coming back to the current fix using
>>>!(alloc_flags & ALLOC_CPUSET) to allow !wait allocations to succeed if
>>>the memory is there and above min watermarks at order-0.
>>
>>kswapd reclaiming at the wrong order should be a bug. It should start
>>reclaiming at the right order as soon as an allocation (atomic or not)
>>goes through the "start reclaiming now" watermark.
>>
>>Now this is just looking at mainline code that has the kswapd_max_order,
>>and kswapd doesn't actually reclaim "at" any order -- it just uses the
>>kswapd_max_order to know when the required "stop reclaiming now" marks
>>have been hit. If lumpy reclaim is not reclaiming at the right order,
>>then it means it isn't refreshing from kswapd_max_order enough.
> 
> 
> Yes I believe all of this is working as designed.  The problem is that
> we treat order-0 and order-1 allocations as independant.  We do not take
> into account that we split order-1's to make order-0.  We do not check
> the order-1 reserve for order 0 and so wake kswapd early enough.  It is
> very hard given the interdependant nature if the current calculation to
> detect transitions at _other_ orders when we allocate at any specific order.

Breaking the watermark code then adding a ridiculous hack to pin the
reclaim order to the highest created kmem cache is the wrong way to
go about this.

There are a number of right ways to help with this problem you describe.
One would be to *raise* higher order watermarks. Another would be to
have some decaying check-this-order-watermark-on-alloc counter in the
zone.

All this higher order allocation stuff had better _really_ be worth it...

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
