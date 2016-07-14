Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 86CE66B025F
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 09:40:16 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id o80so56569634wme.1
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 06:40:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k8si2158665lfd.5.2016.07.14.06.40.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Jul 2016 06:40:14 -0700 (PDT)
Subject: Re: [PATCH 34/34] mm, vmstat: remove zone and node double accounting
 by approximating retries
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-35-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <bd515668-2d1f-e70e-f419-7a55189757f7@suse.cz>
Date: Thu, 14 Jul 2016 15:40:11 +0200
MIME-Version: 1.0
In-Reply-To: <1467970510-21195-35-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On 07/08/2016 11:35 AM, Mel Gorman wrote:
> The number of LRU pages, dirty pages and writeback pages must be accounted
> for on both zones and nodes because of the reclaim retry logic, compaction
> retry logic and highmem calculations all depending on per-zone stats.
>
> Many lowmem allocations are immune from OOM kill due to a check in
> __alloc_pages_may_oom for (ac->high_zoneidx < ZONE_NORMAL) since commit
> 03668b3ceb0c ("oom: avoid oom killer for lowmem allocations"). The exception
> is costly high-order allocations or allocations that cannot fail. If the
> __alloc_pages_may_oom avoids OOM-kill for low-order lowmem allocations
> then it would fall through to __alloc_pages_direct_compact.
>
> This patch will blindly retry reclaim for zone-constrained allocations
> in should_reclaim_retry up to MAX_RECLAIM_RETRIES. This is not ideal but
> without per-zone stats there are not many alternatives. The impact it that
> zone-constrained allocations may delay before considering the OOM killer.
>
> As there is no guarantee enough memory can ever be freed to satisfy
> compaction, this patch avoids retrying compaction for zone-contrained
> allocations.
>
> In combination, that means that the per-node stats can be used when deciding
> whether to continue reclaim using a rough approximation.  While it is
> possible this will make the wrong decision on occasion, it will not infinite
> loop as the number of reclaim attempts is capped by MAX_RECLAIM_RETRIES.
>
> The final step is calculating the number of dirtyable highmem pages. As
> those calculations only care about the global count of file pages in
> highmem. This patch uses a global counter used instead of per-zone stats
> as it is sufficient.
>
> In combination, this allows the per-zone LRU and dirty state counters to
> be removed.
>
> Suggested by: Michal Hocko <mhocko@kernel.org>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

The resulting should_reclaim_retry() makes my head spin, I hope Michal 
can make more sense of it :) So just some comments below.

> @@ -4,6 +4,26 @@
>  #include <linux/huge_mm.h>
>  #include <linux/swap.h>
>
> +#ifdef CONFIG_HIGHMEM
> +extern atomic_t highmem_file_pages;
> +
> +static inline void acct_highmem_file_pages(int zid, enum lru_list lru,
> +							int nr_pages)
> +{
> +	if (is_highmem_idx(zid) && is_file_lru(lru)) {
> +		if (nr_pages > 0)

This seems like a unnecessary branch, atomic_add should handle negative 
nr_pages just fine?

> +			atomic_add(nr_pages, &highmem_file_pages);
> +		else
> +			atomic_sub(nr_pages, &highmem_file_pages);
> +	}
> +}

[...]

> @@ -1446,6 +1446,11 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
>  {
>  	struct zone *zone;
>  	struct zoneref *z;
> +	pg_data_t *last_pgdat = NULL;
> +
> +	/* Do not retry compaction for zone-constrained allocations */
> +	if (ac->high_zoneidx < ZONE_NORMAL)
> +		return false;
>
>  	/*
>  	 * Make sure at least one zone would pass __compaction_suitable if we continue
> @@ -1456,14 +1461,27 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
>  		unsigned long available;
>  		enum compact_result compact_result;
>
> +		if (last_pgdat == zone->zone_pgdat)
> +			continue;
> +
> +		/*
> +		 * This over-estimates the number of pages available for
> +		 * reclaim/compaction but walking the LRU would take too
> +		 * long. The consequences are that compaction may retry
> +		 * longer than it should for a zone-constrained allocation
> +		 * request.

The comment above says that we don't retry zone-constrained at all. Is 
this an obsolete comment, or does it refer to the ZONE_NORMAL 
constraint? (as opposed to HIGHMEM, MOVABLE etc?).

[...]

> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3445,6 +3445,7 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
>  {
>  	struct zone *zone;
>  	struct zoneref *z;
> +	pg_data_t *current_pgdat = NULL;
>
>  	/*
>  	 * Make sure we converge to OOM if we cannot make any progress
> @@ -3454,6 +3455,15 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
>  		return false;
>
>  	/*
> +	 * Blindly retry lowmem allocation requests that are often ignored by
> +	 * the OOM killer up to MAX_RECLAIM_RETRIES as we not have a reliable
> +	 * and fast means of calculating reclaimable, dirty and writeback pages
> +	 * in eligible zones.
> +	 */
> +	if (ac->high_zoneidx < ZONE_NORMAL)
> +		goto out;

A goto inside two nested for cycles? Is there no hope for sanity? :(

> +
> +	/*
>  	 * Keep reclaiming pages while there is a chance this will lead somewhere.
>  	 * If none of the target zones can satisfy our allocation request even
>  	 * if all reclaimable pages are considered then we are screwed and have
> @@ -3463,18 +3473,38 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
>  					ac->nodemask) {
>  		unsigned long available;
>  		unsigned long reclaimable;
> +		int zid;
>
> -		available = reclaimable = zone_reclaimable_pages(zone);
> +		if (current_pgdat == zone->zone_pgdat)
> +			continue;
> +
> +		current_pgdat = zone->zone_pgdat;
> +		available = reclaimable = pgdat_reclaimable_pages(current_pgdat);
>  		available -= DIV_ROUND_UP(no_progress_loops * available,
>  					  MAX_RECLAIM_RETRIES);
> -		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
> +
> +		/* Account for all free pages on eligible zones */
> +		for (zid = 0; zid <= zone_idx(zone); zid++) {
> +			struct zone *acct_zone = &current_pgdat->node_zones[zid];
> +
> +			available += zone_page_state_snapshot(acct_zone, NR_FREE_PAGES);
> +		}
>
>  		/*
>  		 * Would the allocation succeed if we reclaimed the whole
> -		 * available?
> +		 * available? This is approximate because there is no
> +		 * accurate count of reclaimable pages per zone.
>  		 */
> -		if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
> -				ac_classzone_idx(ac), alloc_flags, available)) {
> +		for (zid = 0; zid <= zone_idx(zone); zid++) {
> +			struct zone *check_zone = &current_pgdat->node_zones[zid];
> +			unsigned long estimate;
> +
> +			estimate = min(check_zone->managed_pages, available);
> +			if (!__zone_watermark_ok(check_zone, order,
> +					min_wmark_pages(check_zone), ac_classzone_idx(ac),
> +					alloc_flags, estimate))
> +				continue;
> +
>  			/*
>  			 * If we didn't make any progress and have a lot of
>  			 * dirty + writeback pages then we should wait for
> @@ -3484,15 +3514,16 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
>  			if (!did_some_progress) {
>  				unsigned long write_pending;
>
> -				write_pending = zone_page_state_snapshot(zone,
> -							NR_ZONE_WRITE_PENDING);
> +				write_pending =
> +					node_page_state(current_pgdat, NR_WRITEBACK) +
> +					node_page_state(current_pgdat, NR_FILE_DIRTY);
>
>  				if (2 * write_pending > reclaimable) {
>  					congestion_wait(BLK_RW_ASYNC, HZ/10);
>  					return true;
>  				}
>  			}
> -
> +out:
>  			/*
>  			 * Memory allocation/reclaim might be called from a WQ
>  			 * context and the current implementation of the WQ

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
