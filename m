Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 4B0436B0031
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 19:57:35 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc8so9451549pbc.18
        for <linux-mm@kvack.org>; Fri, 12 Jul 2013 16:57:34 -0700 (PDT)
Message-ID: <51E097E5.7060308@gmail.com>
Date: Fri, 12 Jul 2013 18:57:25 -0500
From: Hush Bensen <hush.bensen@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/7] mm: compaction: add compaction to zone_reclaim_mode
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com> <1370445037-24144-8-git-send-email-aarcange@redhat.com>
In-Reply-To: <1370445037-24144-8-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

Hi Andrea,
OU 2013/6/5 10:10, Andrea Arcangeli D'uA:
> This fixes zone_reclaim_mode by using the min watermark so it won't
> fail in presence of concurrent allocations. This greatly increases the
> reliability of zone_reclaim_mode > 0 also with cache shrinking and THP
> disabled.
>
> This also adds compaction to zone_reclaim so THP enabled won't
> decrease the NUMA locality with /proc/sys/vm/zone_reclaim_mode > 0.
>
> Some checks for __GFP_WAIT and numa_node_id() are moved from the
> zone_reclaim() to the caller so they also apply to the compaction
> logic.
>
> It is important to boot with numa_zonelist_order=n (n means nodes) to
> get more accurate NUMA locality if there are multiple zones per node.
>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  mm/internal.h   |  1 -
>  mm/page_alloc.c | 99 +++++++++++++++++++++++++++++++++++++++++++--------------
>  mm/vmscan.c     | 17 ----------
>  3 files changed, 75 insertions(+), 42 deletions(-)
>
> diff --git a/mm/internal.h b/mm/internal.h
> index 8562de0..560a1ec 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -339,7 +339,6 @@ static inline void mminit_validate_memmodel_limits(unsigned long *start_pfn,
>  }
>  #endif /* CONFIG_SPARSEMEM */
>  
> -#define ZONE_RECLAIM_NOSCAN	-2
>  #define ZONE_RECLAIM_FULL	-1
>  #define ZONE_RECLAIM_SOME	0
>  #define ZONE_RECLAIM_SUCCESS	1
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c13e062..3ca905a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1902,7 +1902,9 @@ zonelist_scan:
>  		BUILD_BUG_ON(ALLOC_NO_WATERMARKS < NR_WMARK);
>  		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
>  			unsigned long mark;
> -			int ret;
> +			int ret, node_id, c_ret;
> +			bool repeated_compaction, need_compaction;
> +			bool contended = false;
>  
>  			mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
>  			if (zone_watermark_ok(zone, order, mark,
> @@ -1933,35 +1935,84 @@ zonelist_scan:
>  				!zlc_zone_worth_trying(zonelist, z, allowednodes))
>  				continue;
>  
> -			ret = zone_reclaim(zone, gfp_mask, order);
> -			switch (ret) {
> -			case ZONE_RECLAIM_NOSCAN:
> -				/* did not scan */
> +			if (!(gfp_mask & __GFP_WAIT) ||
> +			    (current->flags & PF_MEMALLOC))
>  				continue;
> -			case ZONE_RECLAIM_FULL:
> -				/* scanned but unreclaimable */
> +
> +			/*
> +			 * Only reclaim the local zone or on zones
> +			 * that do not have associated
> +			 * processors. This will favor the local
> +			 * processor over remote processors and spread
> +			 * off node memory allocations as wide as
> +			 * possible.
> +			 */
> +			node_id = zone_to_nid(zone);
> +			if (node_state(node_id, N_CPU) &&
> +			    node_id != numa_node_id())
>  				continue;
> -			default:
> -				/* did we reclaim enough */
> +
> +			/*
> +			 * We're going to do reclaim so allow
> +			 * allocations up to the MIN watermark, so less
> +			 * concurrent allocation will fail.
> +			 */
> +			mark = min_wmark_pages(zone);

Target reclaim will be done once under low wmark in vanilla kernel,
however, your patch change it to min wmark, why this behavior change?

> +
> +			/* initialize to avoid warnings */
> +			c_ret = COMPACT_SKIPPED;
> +			ret = ZONE_RECLAIM_FULL;
> +
> +			repeated_compaction = false;
> +			need_compaction = false;
> +			if (!compaction_deferred(preferred_zone, order))
> +				need_compaction = order &&
> +					(gfp_mask & GFP_KERNEL) == GFP_KERNEL;
> +			if (need_compaction) {
> +			repeat_compaction:
> +				c_ret = compact_zone_order(zone, order,
> +							   gfp_mask,
> +							   repeated_compaction,
> +							   &contended);
> +				if (c_ret != COMPACT_SKIPPED &&
> +				    zone_watermark_ok(zone, order, mark,
> +						      classzone_idx,
> +						      alloc_flags)) {
> +#ifdef CONFIG_COMPACTION
> +					preferred_zone->compact_considered = 0;
> +					preferred_zone->compact_defer_shift = 0;
> +#endif
> +					goto try_this_zone;
> +				}
> +			}
> +			/*
> +			 * reclaim if compaction failed because not
> +			 * enough memory was available or if
> +			 * compaction didn't run (order 0) or didn't
> +			 * succeed.
> +			 */
> +			if (!repeated_compaction || c_ret == COMPACT_SKIPPED) {
> +				ret = zone_reclaim(zone, gfp_mask, order);
>  				if (zone_watermark_ok(zone, order, mark,
> -						classzone_idx, alloc_flags))
> +						      classzone_idx,
> +						      alloc_flags))
>  					goto try_this_zone;
> +			}
> +			if (need_compaction &&
> +			    (!repeated_compaction ||
> +			     (c_ret == COMPACT_SKIPPED &&
> +			      ret == ZONE_RECLAIM_SUCCESS))) {
> +				repeated_compaction = true;
> +				cond_resched();
> +				goto repeat_compaction;
> +			}
> +			if (need_compaction)
> +				defer_compaction(preferred_zone, order);
>  
> -				/*
> -				 * Failed to reclaim enough to meet watermark.
> -				 * Only mark the zone full if checking the min
> -				 * watermark or if we failed to reclaim just
> -				 * 1<<order pages or else the page allocator
> -				 * fastpath will prematurely mark zones full
> -				 * when the watermark is between the low and
> -				 * min watermarks.
> -				 */
> -				if (((alloc_flags & ALLOC_WMARK_MASK) == ALLOC_WMARK_MIN) ||
> -				    ret == ZONE_RECLAIM_SOME)
> -					goto this_zone_full;
> -
> +			if (!order)
> +				goto this_zone_full;
> +			else

You do the works should be done in slow path, is it worth?

>  				continue;
> -			}
>  		}
>  
>  try_this_zone:
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 825c631..6a65107 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3380,7 +3380,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  
>  int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  {
> -	int node_id;
>  	int ret;
>  
>  	/*
> @@ -3400,22 +3399,6 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  	if (zone->all_unreclaimable)
>  		return ZONE_RECLAIM_FULL;
>  
> -	/*
> -	 * Do not scan if the allocation should not be delayed.
> -	 */
> -	if (!(gfp_mask & __GFP_WAIT) || (current->flags & PF_MEMALLOC))
> -		return ZONE_RECLAIM_NOSCAN;
> -
> -	/*
> -	 * Only run zone reclaim on the local zone or on zones that do not
> -	 * have associated processors. This will favor the local processor
> -	 * over remote processors and spread off node memory allocations
> -	 * as wide as possible.
> -	 */
> -	node_id = zone_to_nid(zone);
> -	if (node_state(node_id, N_CPU) && node_id != numa_node_id())
> -		return ZONE_RECLAIM_NOSCAN;
> -
>  	ret = __zone_reclaim(zone, gfp_mask, order);
>  
>  	if (!ret)
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
