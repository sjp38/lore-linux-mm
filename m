Message-ID: <464C056E.5080500@yahoo.com.au>
Date: Thu, 17 May 2007 17:34:06 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] Only check absolute watermarks for ALLOC_HIGH and
 ALLOC_HARDER allocations
References: <20070514173218.6787.56089.sendpatchset@skynet.skynet.ie> <20070514173259.6787.58533.sendpatchset@skynet.skynet.ie> <464AF589.2000000@yahoo.com.au> <20070516132419.GA18542@skynet.ie> <464B089C.9070805@yahoo.com.au> <20070516140038.GA10225@skynet.ie> <464B110E.2040309@yahoo.com.au> <464B4D43.9020002@shadowen.org>
In-Reply-To: <464B4D43.9020002@shadowen.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: clameter@sgi.com, Mel Gorman <mel@skynet.ie>, nicolas.mailhot@laposte.net, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andy Whitcroft wrote:
> Nick Piggin wrote:

>>Doesn't mean you should break the watermarks. !wait allocations don't
>>always happen from interrupt context either, and it is possible to see
>>code doing
> 
> 
> The problem perhaps here is that we are not able to allocate at all
> despite having large amounts of memory free.  In the original problem
> report we had a failing order-2 allocation when order-7 pages were free,
> and we were over the reserve.

Look, the watermarks for higher order pages are exactly the same as those
for order-0 allocations, simply scaled. And the reasons for subtracting
lower order pages is utterly logical.

Firstly, some background. If you have 100 order-0 pages, 100 order-1 pages,
and 100 order-2 pages in the buddy lists, then you have 700 order-0 pages
available, or 300 order-1, or 100 order-2. Right?

Then if the order-0 watermarks are (in KB):
high 256
low 128
min 64

The order-1 watermarks will be 128, 64, 32.
And order-2 will be 64, 32, 16.

So the higher order watermarks are _less_ aggressive than order-0 watermarks.
I made them like that because previously there were _no_ higher order
watermarks, so I didn't want to start too strongly.

There is no reason why they couldn't be changed (eg. there would be a valid
argument to say at least the top watermark should be the same for all orders).


>>I feel strongly about not breaking these things which are specifically
>>there
>>for a reason and that are being changed seemingly because of the false
>>impression that kswapd doesn't proactively free pages for them.
> 
> 
> The interaction with kswapd is not instantaneous.  When an allocation at
> high order fails to allocate at the low watermarks it will indeed wake
> up kswapd and that will work to release memory at the order specified.
> However, if it is already reclaiming at another order it will not switch
> up until it next completes a pass.  For an allocator who cannot sleep
> this is very likely to be too late.  This is never going to help a
> bursty allocator.

If that is how lumpy reclaim works, then shouldn't that be improved?
But in general (and especially mainline) it is definitely harder to reclaim
higher orders, so there might even be an argument to say the watermarks
should be _higher_ for higher order allocations. (I would argue that we
should convert the allocator to lower order allocations ;)).


>>The watermarks for higher order pages you could say are implicit but
>>still there. They are scaled down from the order-0 watermarks, so they
>>should behave in the same way. I just can't understand why you're
>>bypassing these if you think the order-0 behaviour is OK.
> 
> 
> The problem is the watermarks for the higher orders are actually much
> stricter than for low orders.  This is a by product of the way in which
> the algorithm calculates the current free at each iteration, taking away
> the pages at smaller order.  The effective free pages at each order is
> scaled by the ratio of the free pages at that order to all the sum of
> all higher orders.  The effective min at each order is halved.
> 
> Due to the nature of the reclaim strategy we will always expect to see
> exponentially more order-0 pages than order-1 etc and so on, making it
> hugely more difficult to allocate a page at these higher orders.

I don't think it is valid to say the higher watermarks are more strict. They
are less strict in terms of both numbers of pages of that order, and of
total bytes.


>>Well that's wrong unless you are allocating with GFP_THISNODE, in which
>>case that is specifically the behaviour that is asked for.
> 
> 
> kswapd is kicked when we cannot allocate at the normal low water mark,
> we will then attempt a further allocation at min/2 etc.  However we are
> as likely to fail the second as the effective low water mark for higher
> order pages is significantly higher than for order-0.  So kswapd will be
> woken, but it has a huge job on its hands to get us from order-0 low
> order to order-N low water.  As we cannot sleep we are very likely to fail.

No. The problem is not that the watermarks are too high!! Firstly, as I
explained, they are lower. Secondly, you gain _more_ buffering if they
are higher. You're not looking at the whole picture, you see the watermark
that we eventually hit and say "that's too high, let's just allow some
allocations into it", but actually this just screws the guy below you.

The reality is that kswapd isn't getting kicked early enough, so the
watermarks should be increased.


> Looking at the figures above dispassionately it is hard to fault the
> logic of the allocator denying this allocation.  There are indeed very
> few pages at those orders and some (where possible) are reserved for
> PF_MEM tasks, for reclaim itself.

So if you lower the watermarks, then everybody has proportionately less
buffering for themselves, and everything falls apart more easily.


>  However, the reservation system takes
> no account of higher orders, so we can always end up in a situation
> where there only order-0 pages free; all higher orders have been split.

What do you mean the reservation system takes no account of higher
orders?

The lowmem_reserve thing is *not* the PF_MEMALLOC reserve, it is a
mechanism which makes eg. a tiny ZONE_DMA not be allocated from when
doing GFP_HIGHMEM allocations on a 4GB system.


>  This gives us a constraint on all reclaim processing, it must only
> involve order-0 pages else it could deadlock.  BUT if that is true and
> reclaim only uses order-0 pages then there is in actually no point in
> retaining any PF_MEM reserve at higher order as it would never be used.

There is nothing to say reclaim only uses order-0 pages... but I would
buy the argument that says we don't need the PF_MEMALLOC reserves for
eg. order > X allocations (where X is maybe 3).


 > I think that probabally means that the second of our patches here is not
 > the right approach to this problem long term.

I don't think either of the patches are right. Changes to this code
really have to be based on a solid understanding of how it works firstly,
then what the problem is, then how the change is going to go about fixing
the problem without breaking things.


 > A patch which sets the
 > critical slabs to order-0 is probabally the way forward.

Right. Critical allocations should always be order-very-low.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
