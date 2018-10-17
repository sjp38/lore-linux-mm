Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C97326B026A
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 06:44:30 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i16-v6so16121016ede.11
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 03:44:30 -0700 (PDT)
Received: from outbound-smtp27.blacknight.com (outbound-smtp27.blacknight.com. [81.17.249.195])
        by mx.google.com with ESMTPS id 62-v6si12887468edy.200.2018.10.17.03.44.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Oct 2018 03:44:29 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp27.blacknight.com (Postfix) with ESMTPS id C8B39B89CD
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 11:44:26 +0100 (IST)
Date: Wed, 17 Oct 2018 11:44:27 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC v4 PATCH 2/5] mm/__free_one_page: skip merge for order-0
 page unless compaction failed
Message-ID: <20181017104427.GJ5819@techsingularity.net>
References: <20181017063330.15384-1-aaron.lu@intel.com>
 <20181017063330.15384-3-aaron.lu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181017063330.15384-3-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, Oct 17, 2018 at 02:33:27PM +0800, Aaron Lu wrote:
> Running will-it-scale/page_fault1 process mode workload on a 2 sockets
> Intel Skylake server showed severe lock contention of zone->lock, as
> high as about 80%(42% on allocation path and 35% on free path) CPU
> cycles are burnt spinning. With perf, the most time consuming part inside
> that lock on free path is cache missing on page structures, mostly on
> the to-be-freed page's buddy due to merging.
> 

This confuses me slightly. The commit log for d8a759b57035 ("mm,
page_alloc: double zone's batchsize") indicates that the contention for
will-it-scale moved from the zone lock to the LRU lock. This appears to
contradict that although the exact test case is different (page_fault_1
vs page_fault2). Can you clarify why commit d8a759b57035 is
insufficient?

I'm wondering is this really about reducing the number of dirtied cache
lines due to struct page updates and less about the actual zone lock.

> One way to avoid this overhead is not do any merging at all for order-0
> pages. With this approach, the lock contention for zone->lock on free
> path dropped to 1.1% but allocation side still has as high as 42% lock
> contention. In the meantime, the dropped lock contention on free side
> doesn't translate to performance increase, instead, it's consumed by
> increased lock contention of the per node lru_lock(rose from 5% to 37%)
> and the final performance slightly dropped about 1%.
> 

Although this implies it's really about contention.

> Though performance dropped a little, it almost eliminated zone lock
> contention on free path and it is the foundation for the next patch
> that eliminates zone lock contention for allocation path.
> 

Can you clarify whether THP was enabled or not? As this is order-0 focused,
it would imply the series should have minimal impact due to limited merging.

> Suggested-by: Dave Hansen <dave.hansen@intel.com>
> Signed-off-by: Aaron Lu <aaron.lu@intel.com>
> ---
>  include/linux/mm_types.h |  9 +++-
>  mm/compaction.c          | 13 +++++-
>  mm/internal.h            | 27 ++++++++++++
>  mm/page_alloc.c          | 88 ++++++++++++++++++++++++++++++++++------
>  4 files changed, 121 insertions(+), 16 deletions(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 5ed8f6292a53..aed93053ef6e 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -179,8 +179,13 @@ struct page {
>  		int units;			/* SLOB */
>  	};
>  
> -	/* Usage count. *DO NOT USE DIRECTLY*. See page_ref.h */
> -	atomic_t _refcount;
> +	union {
> +		/* Usage count. *DO NOT USE DIRECTLY*. See page_ref.h */
> +		atomic_t _refcount;
> +
> +		/* For pages in Buddy: if skipped merging when added to Buddy */
> +		bool buddy_merge_skipped;
> +	};
>  

In some instances, bools within structrs are frowned upon because of
differences in sizes across architectures. Because this is part of a
union, I don't think it's problematic but bear in mind in case someone
else spots it.

>  #ifdef CONFIG_MEMCG
>  	struct mem_cgroup *mem_cgroup;
> diff --git a/mm/compaction.c b/mm/compaction.c
> index faca45ebe62d..0c9c7a30dde3 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -777,8 +777,19 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>  		 * potential isolation targets.
>  		 */
>  		if (PageBuddy(page)) {
> -			unsigned long freepage_order = page_order_unsafe(page);
> +			unsigned long freepage_order;
>  
> +			/*
> +			 * If this is a merge_skipped page, do merge now
> +			 * since high-order pages are needed. zone lock
> +			 * isn't taken for the merge_skipped check so the
> +			 * check could be wrong but the worst case is we
> +			 * lose a merge opportunity.
> +			 */
> +			if (page_merge_was_skipped(page))
> +				try_to_merge_page(page);
> +
> +			freepage_order = page_order_unsafe(page);
>  			/*
>  			 * Without lock, we cannot be sure that what we got is
>  			 * a valid page order. Consider only values in the
> diff --git a/mm/internal.h b/mm/internal.h
> index 87256ae1bef8..c166735a559e 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -527,4 +527,31 @@ static inline bool is_migrate_highatomic_page(struct page *page)
>  
>  void setup_zone_pageset(struct zone *zone);
>  extern struct page *alloc_new_node_page(struct page *page, unsigned long node);
> +
> +static inline bool page_merge_was_skipped(struct page *page)
> +{
> +	return page->buddy_merge_skipped;
> +}
> +
> +void try_to_merge_page(struct page *page);
> +
> +#ifdef CONFIG_COMPACTION
> +static inline bool can_skip_merge(struct zone *zone, int order)
> +{
> +	/* Compaction has failed in this zone, we shouldn't skip merging */
> +	if (zone->compact_considered)
> +		return false;
> +
> +	/* Only consider no_merge for order 0 pages */
> +	if (order)
> +		return false;
> +
> +	return true;
> +}
> +#else /* CONFIG_COMPACTION */
> +static inline bool can_skip_merge(struct zone *zone, int order)
> +{
> +	return false;
> +}
> +#endif  /* CONFIG_COMPACTION */
>  #endif	/* __MM_INTERNAL_H */

Strictly speaking, lazy buddy merging does not need to be linked to
compaction. Lazy merging doesn't say anything about the mobility of
buddy pages that are still allocated.

When lazy buddy merging was last examined years ago, a consequence was
that high-order allocation success rates were reduced. I see you do the
merging when compaction has been recently considered but I don't see how
that is sufficient. If a high-order allocation fails, there is no
guarantee that compaction will find those unmerged buddies. There is
also no guarantee that a page free will find them. So, in the event of a
high-order allocation failure, what finds all those unmerged buddies and
puts them together to see if the allocation would succeed without
reclaim/compaction/etc.

-- 
Mel Gorman
SUSE Labs
