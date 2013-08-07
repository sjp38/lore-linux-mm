Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id B65726B0092
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 11:46:26 -0400 (EDT)
Date: Wed, 7 Aug 2013 15:18:50 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 6/9] mm: zone_reclaim: compaction: increase the high
 order pages in the watermarks
Message-ID: <20130807131850.GA4661@redhat.com>
References: <1375459596-30061-1-git-send-email-aarcange@redhat.com>
 <1375459596-30061-7-git-send-email-aarcange@redhat.com>
 <20130806160838.GI1845@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130806160838.GI1845@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hush Bensen <hush.bensen@gmail.com>

On Tue, Aug 06, 2013 at 12:08:38PM -0400, Johannes Weiner wrote:
> Okay, bear with me here:
> 
> After an allocation, the watermark has to be met, all available pages
> considered.  That is reasonable because we don't want to deadlock and
> order-0 pages can be served from any page block.
> 
> Now say we have an order-2 allocation: in addition to the order-0 view
> on the watermark, after the allocation a quarter of the watermark has
> to be met with order-2 pages and up.  Okay, maybe we always want a few
> < PAGE_ALLOC_COSTLY_ORDER pages at our disposal, who knows.
> 
> Then it kind of sizzles out towards higher order pages but it always
> requires the remainder to be positive, i.e. at least one page at the
> checked order available.  Only the actually requested order is not
> checked, so for an order-9 we only make sure that we could serve at
> least one order-8 page, maybe more depending on the zone size.
> 
> You're proposing to check at least for
> 
>   (watermark - min_watermark) >> (pageblock_order >> 2)
> 
> worth of order-8 pages instead.

worth of order 9 plus all higher order than 9, pages.

> 
> How does any of this make any sense?

The loop removes from the total number of free pages, all free pages
in the too-low buddy allocator orders to be relevant for an order 9
allocation (order from 0 to 8 range), so the check is against order 9
pages or higher order of free memory.

But it's still good to review this in detail, as this is one tricky
bit of math.

The loop independently of the above (to correcting the free_pages to
only account order 9 or higher), scales down the watermark that we'll
check the corrected free_pages level against. With this change now we
stop the scaling down after we reach o >= 2. (pageblock_order >> 2 ==
2).

So we remain identical and we still scale down (shift right) once for
order 1, and we scale down twice for order 2 like before. But for all
higher orders we scale down the maximum twice and not more:

	(mark - min) >> 2

And we set to 0 the wmark of high order pages required for the
ALLOC_WMARK_MIN. That means the MIN wmark will succeed and stop
compaction if there's 1 page of the right order, not more than
that. (free_pages <= min will not succeed the allocation, which means
free_pages <= 0 because min is 0, and if instead it's > 0 it means at
least 1 order 9 page has been generated which is what we need at the
MIN level)

About the ALLOC_WMARK_LOW, my current normal zone has min 11191 and
low 13988. So the amount of free memory in order9 or higher zone
required for the ALLOC_WMARK_LOW to succeed in compaction now becomes
((13988-11191)>>2)*4096 = 2.7MB. That means "free_pages > 2.7MB" will
succeed with order 9 or higher, only with at least 2 pages generated
in compaction, to have at least a bit more of margin than for min
wmark and for concurrent allocations that could split or allocate the
order 9 page generated. 2 pages better than one, and it seems to make
a measurable difference in the allocation success rate here with all
threads allocating from all CPUs at the same time.

Before ALLOC_WMARK_LOW check for order 9 or higher was set at (13988
>> 9)*4096 = 110KB (same as zero, requiring only one order 9 page),
and ALLOC_WMARK_MIN was set at (11191 >> 9)*4096 = 86KB (again same as
zero, requiring just 1 page).

In short this should allow at least 2 pages free at LOW for order 9
allocations, and still 1 for MIN like before. But it should be mostly
beneficial in reducing compaction overhead for the lower orders than
9, where previously we would stop compaction much later for the MIN
and for the LOW, despite nobody (except a bit atomic allocations)
could access to the pages below the MIN. We were working for nothing.
And potentially we did more work but we had fewer pages usable than we
do now in between LOW and MIN that we could really allocate as high
order pages.

I could have used PAGE_ALLOC_COSTLY_ORDER instead of "pageblock_order
>> 2" but I seen no obvious connection between this value and the fact
the allocation is more costly. Keeping it in function of the
pageblock_order I thought was better because if the pageblock order is
bigger than 9 (signaling a very big hugepage), we keep scaling down a
little more to avoid generating too many of very huge ones. It's not
black and white stuff anyway but it felt better than
PAGE_ALLOC_COSTLY_ORDER.

To be sure, I would suggest to write a script that prints the low and
min wmarks to check against the high order free_pages, given the
standard low/min wmarks, for all orders of allocations from 0 to
MAX_ORDER, with new and old code. And to run it with different min/low
wmarks as generated by default on very different zone sizes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
