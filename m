Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id BADC86B0069
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 09:08:47 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id n8so4993431wmg.4
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 06:08:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p34si777356edb.501.2017.11.23.06.08.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Nov 2017 06:08:46 -0800 (PST)
Date: Thu, 23 Nov 2017 14:08:43 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm, compaction: direct freepage allocation for async
 direct compaction
Message-ID: <20171123140843.is7cqatrdijkjqql@suse.de>
References: <20171122143321.29501-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20171122143321.29501-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Nov 22, 2017 at 09:33:21AM -0500, Johannes Weiner wrote:
> From: Vlastimil Babka <vbabka@suse.cz>
> 
> The goal of direct compaction is to quickly make a high-order page available
> for the pending allocation. The free page scanner can add significant latency
> when searching for migration targets, although to succeed the compaction, the
> only important limit on the target free pages is that they must not come from
> the same order-aligned block as the migrated pages.
> 
> This patch therefore makes direct async compaction allocate freepages directly
> from freelists. Pages that do come from the same block (which we cannot simply
> exclude from the freelist allocation) are put on separate list and released
> only after migration to allow them to merge.
> 
> In addition to reduced stall, another advantage is that we split larger free
> pages for migration targets only when smaller pages are depleted, while the
> free scanner can split pages up to (order - 1) as it encouters them. However,
> this approach likely sacrifices some of the long-term anti-fragmentation
> features of a thorough compaction, so we limit the direct allocation approach
> to direct async compaction.
> 
> For observational purposes, the patch introduces two new counters to
> /proc/vmstat. compact_free_direct_alloc counts how many pages were allocated
> directly without scanning, and compact_free_direct_miss counts the subset of
> these allocations that were from the wrong range and had to be held on the
> separate list.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
> 
> Hi. I'm resending this because we've been struggling with the cost of
> compaction in our fleet, and this patch helps substantially.
>  

That particular problem only has been gettiing worse as memory sizes get
larger. So broadly speaking I'm happy to see something happen with it but
there were reasons why a linear scanner was settled on originally. They were
not insurmountable problems but not severe enough at the time to justify
the complexity (particularly as THP and high-order were still treated as
"no on cares" problems). Unfortunately, I believe the same problems are
still relevant today;

Lets look closely at the core function that really matters in this
patch, IMO at least.

> diff --git a/mm/compaction.c b/mm/compaction.c
> index 10cd757f1006..ccc9b157f716 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1160,6 +1160,41 @@ static void isolate_freepages(struct compact_control *cc)
>  	cc->free_pfn = isolate_start_pfn;
>  }
>  
> +static void isolate_freepages_direct(struct compact_control *cc)
> +{
> +	unsigned long nr_pages;
> +	unsigned long flags;
> +
> +	nr_pages = cc->nr_migratepages - cc->nr_freepages;
> +
> +	if (!compact_trylock_irqsave(&cc->zone->lock, &flags, cc))
> +		return;
> +
> +	while (nr_pages) {
> +		struct page *page;
> +		unsigned long pfn;
> +
> +		page = alloc_pages_zone(cc->zone, 0, MIGRATE_MOVABLE);
> +		if (!page)
> +			break;
> +		pfn = page_to_pfn(page);
> +
> +		count_compact_event(COMPACTFREE_DIRECT_ALLOC);
> +
> +		/* Is the free page in the block we are migrating from? */
> +		if (pfn >> cc->order ==	(cc->migrate_pfn - 1) >> cc->order) {
> +			list_add(&page->lru, &cc->freepages_held);
> +			count_compact_event(COMPACTFREE_DIRECT_MISS);
> +		} else {
> +			list_add(&page->lru, &cc->freepages);
> +			cc->nr_freepages++;
> +			nr_pages--;
> +		}
> +	}
> +
> +	spin_unlock_irqrestore(&cc->zone->lock, flags);
> +}
> +

1. This indirectly uses __rmqueue to allocate a MIGRATE_MOVABLE page but
   that is allowed to fallback to other pageblocks and potentially even
   steal them. I think it's very bad that an attempt to defragment can
   itself indirectly cause more fragmentation events by altering pageblocks.
   Please consider using __rmqueue_fallback (within alloc_pages_zone of
   course)

2. One of the reasons a linear scanner was used was because I wanted the
   possibility that MIGRATE_UNMOVABLE and MIGRATE_RECLAIMABLE pageblocks
   would also be scanned and we would avoid future fragmentation events.
   This had a lot of overhead and was reduced since but it's still a
   relevant problem.  Granted, this patch is not the correct place to fix
   that issue and potential solutions have been discussed elsewhere. However,
   this patch potentially means that never happens. It doesn't necessarily
   kill the patch but the long-lived behaviour may be that no compaction
   occurs because all the MIGRATE_MOVABLE pageblocks are full and you'll
   either need to reclaim to fix it or we'll need kcompactd to migration
   MIGRATE_MOVABLE pages from UNMOVABLE and RECLAIMABLE pageblocks out
   of band.

   For THP, this point doesn't matter but if you need this patch for
   high-order allocations for network buffers then at some point, you
   really will have to clean out those pageblocks or it'll degrade.

3. Another reason a linear scanner was used was because we wanted to
   clear entire pageblocks we were migrating from and pack the target
   pageblocks as much as possible. This was to reduce the amount of
   migration required overall even though the scanning hurts. This patch
   takes MIGRATE_MOVABLE pages from anywhere that is "not this pageblock".
   Those potentially have to be moved again and again trying to randomly
   fill a MIGRATE_MOVABLE block. Have you considered using the freelists
   as a hint? i.e. take a page from the freelist, then isolate all free
   pages in the same pageblock as migration targets? That would preserve
   the "packing property" of the linear scanner.

   This would increase the amount of scanning but that *might* be offset by
   the number of migrations the workload does overall. Note that migrations
   potentially are minor faults so if we do too many migrations, your
   workload may suffer.

4. One problem the linear scanner avoids is that a migration target is
   subsequently used as a migration source and leads to a ping-pong effect.
   I don't know how bad this is in practice or even if it's a problem at
   all but it was a concern at the time

5. Consider two processes A and B compacting at the same time with A_s
   and A_t being the source pageblock and target pageblock that process
   A is using and B_s/B_t being B's pageblocks. Nothing prevents A_s ==
   B_t and B_s == A_t. Maybe it rarely happens in practice but it was one
   problem the linear scanner was meant to avoid.

I can't shake the feeling I had another concern when I started this
email but then forgot it before I got to the end so it can't be that
important :(.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
