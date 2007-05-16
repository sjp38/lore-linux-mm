Message-ID: <464B110E.2040309@yahoo.com.au>
Date: Thu, 17 May 2007 00:11:26 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] Only check absolute watermarks for ALLOC_HIGH and
 ALLOC_HARDER allocations
References: <20070514173218.6787.56089.sendpatchset@skynet.skynet.ie> <20070514173259.6787.58533.sendpatchset@skynet.skynet.ie> <464AF589.2000000@yahoo.com.au> <20070516132419.GA18542@skynet.ie> <464B089C.9070805@yahoo.com.au> <20070516140038.GA10225@skynet.ie>
In-Reply-To: <20070516140038.GA10225@skynet.ie>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: nicolas.mailhot@laposte.net, clameter@sgi.com, apw@shadowen.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> On (16/05/07 23:35), Nick Piggin didst pronounce:
> 
>>Mel Gorman wrote:

>>>In page_alloc.c
>>>
>>>       if ((unlikely(rt_task(p)) && !in_interrupt()) || !wait)
>>>               alloc_flags |= ALLOC_HARDER;
>>>
>>>See the !wait part.
>>
>>And the || part.
>>
> 
> 
> I doubt a rt_task is thrilled to be entering direct reclaim.

Doesn't mean you should break the watermarks. !wait allocations don't
always happen from interrupt context either, and it is possible to see
code doing

if (!alloc(GFP_KERNEL&~__GFP_WAIT)) {
     spin_unlock()
     alloc(GFP_KERNEL)
     spin_lock()
}


>>>The ALLOC_HIGH applies to __GFP_HIGH allocations which are allowed to
>>>dip into emergency pools and go below the reserve.
>>
>>And some of them can sleep too.
>>
> 
> 
> If you feel very strongly about it, I can back out the ALLOC_HIGH part for
> __GFP_HIGH allocations but it looks like at a glance that users of __GFP_HIGH
> are not too keen on sleeping;

I feel strongly about not breaking these things which are specifically there
for a reason and that are being changed seemingly because of the false
impression that kswapd doesn't proactively free pages for them.


>>>ALLOC_HARDER is an urgent allocation class.
>>
>>And HIGH is even more, and MEMALLOC even more again.
>>
> 
> 
> HIGH => ALLOC_HIGH => obey watermarks at order-0
> 
> Somewhat counter-intuitively, with the current code if the allocation is
> a really high priority but can sleep, it can actually allocate without any
> watermarks at all

I didn't understand what you meant?


>>>What actually happens is that high-order allocations fail even though
>>>the watermarks are met because they cannot enter direct reclaim.
>>
>>Yeah, they fail leaving some spare for more urgent allocations. Like
>>how the order-0 allocations work.
> 
> 
> order-0 watermarks are still in place. After the patch, it is still not
> possible for the allocations to break the watermarks there.

The watermarks for higher order pages you could say are implicit but
still there. They are scaled down from the order-0 watermarks, so they
should behave in the same way. I just can't understand why you're
bypassing these if you think the order-0 behaviour is OK.


>>They should also kick kswapd to start freeing pages _before_ they start
>>failing too.
>>
> 
> 
> Should prehaps, but from what I read kswapd is only kicked into action
> when the first allocation attempt has already failed.

Well that's wrong unless you are allocating with GFP_THISNODE, in which
case that is specifically the behaviour that is asked for.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
