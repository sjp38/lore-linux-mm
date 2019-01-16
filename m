Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 85D068E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 08:15:15 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id f31so2332133edf.17
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 05:15:15 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v9-v6si4216274eje.240.2019.01.16.05.15.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 05:15:13 -0800 (PST)
Subject: Re: [PATCH 11/25] mm, compaction: Use free lists to quickly locate a
 migration source
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190104125011.16071-12-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f1e0e977-d901-776d-9a6a-799735ebd3bf@suse.cz>
Date: Wed, 16 Jan 2019 14:15:10 +0100
MIME-Version: 1.0
In-Reply-To: <20190104125011.16071-12-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On 1/4/19 1:49 PM, Mel Gorman wrote:
> The migration scanner is a linear scan of a zone with a potentiall large
> search space.  Furthermore, many pageblocks are unusable such as those
> filled with reserved pages or partially filled with pages that cannot
> migrate. These still get scanned in the common case of allocating a THP
> and the cost accumulates.
> 
> The patch uses a partial search of the free lists to locate a migration
> source candidate that is marked as MOVABLE when allocating a THP. It
> prefers picking a block with a larger number of free pages already on
> the basis that there are fewer pages to migrate to free the entire block.
> The lowest PFN found during searches is tracked as the basis of the start
> for the linear search after the first search of the free list fails.
> After the search, the free list is shuffled so that the next search will
> not encounter the same page. If the search fails then the subsequent
> searches will be shorter and the linear scanner is used.
> 
> If this search fails, or if the request is for a small or
> unmovable/reclaimable allocation then the linear scanner is still used. It
> is somewhat pointless to use the list search in those cases. Small free
> pages must be used for the search and there is no guarantee that movable
> pages are located within that block that are contiguous.
> 
>                                         4.20.0                 4.20.0
>                                 failfast-v2r15          findmig-v2r15
> Amean     fault-both-1         0.00 (   0.00%)        0.00 *   0.00%*
> Amean     fault-both-3      3833.72 (   0.00%)     3505.69 (   8.56%)
> Amean     fault-both-5      4967.15 (   0.00%)     5794.13 * -16.65%*
> Amean     fault-both-7      7139.19 (   0.00%)     7663.09 (  -7.34%)
> Amean     fault-both-12    11326.30 (   0.00%)    10983.36 (   3.03%)
> Amean     fault-both-18    16270.70 (   0.00%)    13602.71 *  16.40%*
> Amean     fault-both-24    19839.65 (   0.00%)    16145.77 *  18.62%*
> Amean     fault-both-30    21707.05 (   0.00%)    19753.82 (   9.00%)
> Amean     fault-both-32    21968.16 (   0.00%)    20616.16 (   6.15%)
> 
>                                    4.20.0                 4.20.0
>                            failfast-v2r15          findmig-v2r15
> Percentage huge-1         0.00 (   0.00%)        0.00 (   0.00%)
> Percentage huge-3        84.62 (   0.00%)       90.58 (   7.05%)
> Percentage huge-5        88.43 (   0.00%)       91.34 (   3.29%)
> Percentage huge-7        88.33 (   0.00%)       92.21 (   4.39%)
> Percentage huge-12       88.74 (   0.00%)       92.48 (   4.21%)
> Percentage huge-18       86.52 (   0.00%)       91.65 (   5.93%)
> Percentage huge-24       86.42 (   0.00%)       90.23 (   4.41%)
> Percentage huge-30       86.67 (   0.00%)       90.17 (   4.04%)
> Percentage huge-32       86.00 (   0.00%)       89.72 (   4.32%)
> 
> This shows an improvement in allocation latencies and a slight increase
> in allocation success rates. While not presented, there was a 13% reduction
> in migration scanning and a 10% reduction on system CPU usage. A 2-socket
> machine showed similar benefits.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  mm/compaction.c | 179 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  mm/internal.h   |   2 +
>  2 files changed, 179 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 8f0ce44dba41..137e32e8a2f5 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1050,6 +1050,12 @@ static bool suitable_migration_target(struct compact_control *cc,
>  	return false;
>  }
>  
> +static inline unsigned int
> +freelist_scan_limit(struct compact_control *cc)
> +{
> +	return (COMPACT_CLUSTER_MAX >> cc->fast_search_fail) + 1;
> +}
> +
>  /*
>   * Test whether the free scanner has reached the same or lower pageblock than
>   * the migration scanner, and compaction should thus terminate.
> @@ -1060,6 +1066,19 @@ static inline bool compact_scanners_met(struct compact_control *cc)
>  		<= (cc->migrate_pfn >> pageblock_order);
>  }
>  
> +/* Reorder the free list to reduce repeated future searches */
> +static void
> +move_freelist_tail(struct list_head *freelist, struct page *freepage)
> +{
> +	LIST_HEAD(sublist);
> +
> +	if (!list_is_last(freelist, &freepage->lru)) {
> +		list_cut_position(&sublist, freelist, &freepage->lru);
> +		if (!list_empty(&sublist))
> +			list_splice_tail(&sublist, freelist);
> +	}
> +}
> +
>  /*
>   * Based on information in the current compact_control, find blocks
>   * suitable for isolating free pages from and then isolate them.
> @@ -1217,6 +1236,160 @@ typedef enum {
>   */
>  int sysctl_compact_unevictable_allowed __read_mostly = 1;
>  
> +static inline void
> +update_fast_start_pfn(struct compact_control *cc, unsigned long pfn)
> +{
> +	if (cc->fast_start_pfn == ULONG_MAX)
> +		return;
> +
> +	if (!cc->fast_start_pfn)
> +		cc->fast_start_pfn = pfn;
> +
> +	cc->fast_start_pfn = min(cc->fast_start_pfn, pfn);
> +}
> +
> +static inline void
> +reinit_migrate_pfn(struct compact_control *cc)
> +{
> +	if (!cc->fast_start_pfn || cc->fast_start_pfn == ULONG_MAX)
> +		return;
> +
> +	cc->migrate_pfn = cc->fast_start_pfn;
> +	cc->fast_start_pfn = ULONG_MAX;
> +}
> +
> +/*
> + * Briefly search the free lists for a migration source that already has
> + * some free pages to reduce the number of pages that need migration
> + * before a pageblock is free.
> + */
> +static unsigned long fast_find_migrateblock(struct compact_control *cc)
> +{
> +	unsigned int limit = freelist_scan_limit(cc);
> +	unsigned int nr_scanned = 0;
> +	unsigned long distance;
> +	unsigned long pfn = cc->migrate_pfn;
> +	unsigned long high_pfn;
> +	int order;
> +
> +	/* Skip hints are relied on to avoid repeats on the fast search */
> +	if (cc->ignore_skip_hint)
> +		return pfn;
> +
> +	/*
> +	 * If the migrate_pfn is not at the start of a zone or the start
> +	 * of a pageblock then assume this is a continuation of a previous
> +	 * scan restarted due to COMPACT_CLUSTER_MAX.
> +	 */
> +	if (pfn != cc->zone->zone_start_pfn && pfn != pageblock_start_pfn(pfn))
> +		return pfn;
> +
> +	/*
> +	 * For smaller orders, just linearly scan as the number of pages
> +	 * to migrate should be relatively small and does not necessarily
> +	 * justify freeing up a large block for a small allocation.
> +	 */
> +	if (cc->order <= PAGE_ALLOC_COSTLY_ORDER)
> +		return pfn;
> +
> +	/*
> +	 * Only allow kcompactd and direct requests for movable pages to
> +	 * quickly clear out a MOVABLE pageblock for allocation. This
> +	 * reduces the risk that a large movable pageblock is freed for
> +	 * an unmovable/reclaimable small allocation.
> +	 */
> +	if (cc->direct_compaction && cc->migratetype != MIGRATE_MOVABLE)
> +		return pfn;
> +
> +	/*
> +	 * When starting the migration scanner, pick any pageblock within the
> +	 * first half of the search space. Otherwise try and pick a pageblock
> +	 * within the first eighth to reduce the chances that a migration
> +	 * target later becomes a source.
> +	 */
> +	distance = (cc->free_pfn - cc->migrate_pfn) >> 1;
> +	if (cc->migrate_pfn != cc->zone->zone_start_pfn)
> +		distance >>= 2;
> +	high_pfn = pageblock_start_pfn(cc->migrate_pfn + distance);
> +
> +	for (order = cc->order - 1;
> +	     order >= PAGE_ALLOC_COSTLY_ORDER && pfn == cc->migrate_pfn && nr_scanned < limit;
> +	     order--) {
> +		struct free_area *area = &cc->zone->free_area[order];
> +		struct list_head *freelist;
> +		unsigned long nr_skipped = 0;
> +		unsigned long flags;
> +		struct page *freepage;
> +
> +		if (!area->nr_free)
> +			continue;
> +
> +		spin_lock_irqsave(&cc->zone->lock, flags);
> +		freelist = &area->free_list[MIGRATE_MOVABLE];
> +		list_for_each_entry(freepage, freelist, lru) {
> +			unsigned long free_pfn;
> +
> +			nr_scanned++;
> +			free_pfn = page_to_pfn(freepage);
> +			if (free_pfn < high_pfn) {
> +				update_fast_start_pfn(cc, free_pfn);
> +
> +				/*
> +				 * Avoid if skipped recently. Move to the tail
> +				 * of the list so it will not be found again
> +				 * soon
> +				 */
> +				if (get_pageblock_skip(freepage)) {
> +
> +					if (list_is_last(freelist, &freepage->lru))
> +						break;
> +
> +					nr_skipped++;
> +					list_del(&freepage->lru);
> +					list_add_tail(&freepage->lru, freelist);

Use list_move_tail() instead of del+add ? Also is this even safe inside
list_for_each_entry() and not list_for_each_entry_safe()? I guess
without the extra safe iterator, we moved freepage, which is our
iterator, to the tail, so the for cycle will immediately end?
Also is this moving of one page needed when you also have
move_freelist_tail() to move everything we scanned at once?


> +					if (nr_skipped > 2)
> +						break;

Counting number of skips per order seems weird. What's the intention, is
it not to encounter again a page that we already moved to tail? That
could be solved differently, e.g. using only move_freelist_tail()?

> +					continue;
> +				}
> +
> +				/* Reorder to so a future search skips recent pages */
> +				move_freelist_tail(freelist, freepage);
> +
> +				pfn = pageblock_start_pfn(free_pfn);
> +				cc->fast_search_fail = 0;
> +				set_pageblock_skip(freepage);

Hmm with pageblock skip bit set, we return to isolate_migratepages(),
and there's isolation_suitable() check which tests the skip bit, so
AFAICS in the end we skip the pageblock we found here?

> +				break;
> +			}
> +
> +			/*
> +			 * If low PFNs are being found and discarded then
> +			 * limit the scan as fast searching is finding
> +			 * poor candidates.
> +			 */

I wonder about the "low PFNs are being found and discarded" part. Maybe
I'm missing it, but I don't see them being discarded above, this seems
to be the first check against cc->migrate_pfn. With the min() part in
update_fast_start_pfn(), does it mean we can actually go back and rescan
(or skip thanks to skip bits, anyway) again pageblocks that we already
scanned?

> +			if (free_pfn < cc->migrate_pfn)
> +				limit >>= 1;
> +
> +			if (nr_scanned >= limit) {
> +				cc->fast_search_fail++;
> +				move_freelist_tail(freelist, freepage);
> +				break;
> +			}
> +		}
> +		spin_unlock_irqrestore(&cc->zone->lock, flags);
> +	}
> +
> +	cc->total_migrate_scanned += nr_scanned;
> +
> +	/*
> +	 * If fast scanning failed then use a cached entry for a page block
> +	 * that had free pages as the basis for starting a linear scan.
> +	 */
> +	if (pfn == cc->migrate_pfn)
> +		reinit_migrate_pfn(cc);
> +
> +	return pfn;
> +}
> +
>  /*
>   * Isolate all pages that can be migrated from the first suitable block,
>   * starting at the block pointed to by the migrate scanner pfn within
> @@ -1235,9 +1408,10 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  
>  	/*
>  	 * Start at where we last stopped, or beginning of the zone as
> -	 * initialized by compact_zone()
> +	 * initialized by compact_zone(). The first failure will use
> +	 * the lowest PFN as the starting point for linear scanning.
>  	 */
> -	low_pfn = cc->migrate_pfn;
> +	low_pfn = fast_find_migrateblock(cc);
>  	block_start_pfn = pageblock_start_pfn(low_pfn);
>  	if (block_start_pfn < zone->zone_start_pfn)
>  		block_start_pfn = zone->zone_start_pfn;
> @@ -1560,6 +1734,7 @@ static enum compact_result compact_zone(struct compact_control *cc)
>  	 * want to compact the whole zone), but check that it is initialised
>  	 * by ensuring the values are within zone boundaries.
>  	 */
> +	cc->fast_start_pfn = 0;
>  	if (cc->whole_zone) {
>  		cc->migrate_pfn = start_pfn;
>  		cc->free_pfn = pageblock_start_pfn(end_pfn - 1);
> diff --git a/mm/internal.h b/mm/internal.h
> index edb4029f64c8..b25b33c5dd80 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -187,9 +187,11 @@ struct compact_control {
>  	unsigned int nr_migratepages;	/* Number of pages to migrate */
>  	unsigned long free_pfn;		/* isolate_freepages search base */
>  	unsigned long migrate_pfn;	/* isolate_migratepages search base */
> +	unsigned long fast_start_pfn;	/* a pfn to start linear scan from */
>  	struct zone *zone;
>  	unsigned long total_migrate_scanned;
>  	unsigned long total_free_scanned;
> +	unsigned int fast_search_fail;	/* failures to use free list searches */
>  	const gfp_t gfp_mask;		/* gfp mask of a direct compactor */
>  	int order;			/* order a direct compactor needs */
>  	int migratetype;		/* migratetype of direct compactor */
> 
