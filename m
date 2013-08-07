Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id D7EC06B00B1
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 12:18:42 -0400 (EDT)
Date: Wed, 7 Aug 2013 17:18:37 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 9/9] mm: zone_reclaim: compaction: add compaction to
 zone_reclaim_mode
Message-ID: <20130807161837.GW2296@suse.de>
References: <1375459596-30061-1-git-send-email-aarcange@redhat.com>
 <1375459596-30061-10-git-send-email-aarcange@redhat.com>
 <20130804165526.GG27921@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130804165526.GG27921@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hush Bensen <hush.bensen@gmail.com>

On Sun, Aug 04, 2013 at 06:55:26PM +0200, Andrea Arcangeli wrote:
> On Fri, Aug 02, 2013 at 06:06:36PM +0200, Andrea Arcangeli wrote:
> > +		need_compaction = false;
> 
> This should be changed to "*need_compaction = false". It's actually a
> cleanup because it's a nooperational change at runtime.
> need_compaction was initialized to false by the only caller so it
> couldn't harm. But it's better to fix it to avoid
> confusion. Alternatively the above line can be dropped entirely but I
> thought it was cleaner to have a defined value as result of the
> function.
> 
> Found by Fengguang kbuild robot.
> 
> A new replacement patch 9/9 is appended below:
> 
> ===
> From: Andrea Arcangeli <aarcange@redhat.com>
> Subject: [PATCH] mm: zone_reclaim: compaction: add compaction to
>  zone_reclaim_mode
> 
> This adds compaction to zone_reclaim so THP enabled won't decrease the
> NUMA locality with /proc/sys/vm/zone_reclaim_mode > 0.
> 

That is a light explanation.

> It is important to boot with numa_zonelist_order=n (n means nodes) to
> get more accurate NUMA locality if there are multiple zones per node.
> 

This appears to be an unrelated observation.

> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  include/linux/swap.h |   8 +++-
>  mm/page_alloc.c      |   4 +-
>  mm/vmscan.c          | 111 ++++++++++++++++++++++++++++++++++++++++++---------
>  3 files changed, 102 insertions(+), 21 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f2ada36..fedb246 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
>
> <SNIP>
>
> @@ -3549,27 +3567,35 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  	return sc.nr_reclaimed >= nr_pages;
>  }
>  
> -int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
> +static int zone_reclaim_compact(struct zone *preferred_zone,
> +				struct zone *zone, gfp_t gfp_mask,
> +				unsigned int order,
> +				bool sync_compaction,
> +				bool *need_compaction)
>  {
> -	int node_id;
> -	int ret;
> +	bool contended;
>  
> -	/*
> -	 * Zone reclaim reclaims unmapped file backed pages and
> -	 * slab pages if we are over the defined limits.
> -	 *
> -	 * A small portion of unmapped file backed pages is needed for
> -	 * file I/O otherwise pages read by file I/O will be immediately
> -	 * thrown out if the zone is overallocated. So we do not reclaim
> -	 * if less than a specified percentage of the zone is used by
> -	 * unmapped file backed pages.
> -	 */
> -	if (zone_pagecache_reclaimable(zone) <= zone->min_unmapped_pages &&
> -	    zone_page_state(zone, NR_SLAB_RECLAIMABLE) <= zone->min_slab_pages)
> -		return ZONE_RECLAIM_FULL;
> +	if (compaction_deferred(preferred_zone, order) ||
> +	    !order ||
> +	    (gfp_mask & (__GFP_FS|__GFP_IO)) != (__GFP_FS|__GFP_IO)) {
> +		*need_compaction = false;
> +		return COMPACT_SKIPPED;
> +	}
>  
> -	if (zone->all_unreclaimable)
> -		return ZONE_RECLAIM_FULL;
> +	*need_compaction = true;
> +	return compact_zone_order(zone, order,
> +				  gfp_mask,
> +				  sync_compaction,
> +				  &contended);
> +}
> +
> +int zone_reclaim(struct zone *preferred_zone, struct zone *zone,
> +		 gfp_t gfp_mask, unsigned int order,
> +		 unsigned long mark, int classzone_idx, int alloc_flags)
> +{
> +	int node_id;
> +	int ret, c_ret;
> +	bool sync_compaction = false, need_compaction = false;
>  
>  	/*
>  	 * Do not scan if the allocation should not be delayed.
> @@ -3587,7 +3613,56 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  	if (node_state(node_id, N_CPU) && node_id != numa_node_id())
>  		return ZONE_RECLAIM_NOSCAN;
>  
> +repeat_compaction:
> +	/*
> +	 * If this allocation may be satisfied by memory compaction,
> +	 * run compaction before reclaim.
> +	 */
> +	c_ret = zone_reclaim_compact(preferred_zone,
> +				     zone, gfp_mask, order,
> +				     sync_compaction,
> +				     &need_compaction);
> +	if (need_compaction &&
> +	    c_ret != COMPACT_SKIPPED &&

need_compaction records whether compaction was attempted or not. Why
not just check for COMPACT_SKIPPED and have compact_zone_order return
COMPACT_SKIPPED if !CONFIG_COMPACTION?

> +	    zone_watermark_ok(zone, order, mark,
> +			      classzone_idx,
> +			      alloc_flags)) {
> +#ifdef CONFIG_COMPACTION
> +		zone->compact_considered = 0;
> +		zone->compact_defer_shift = 0;
> +#endif
> +		return ZONE_RECLAIM_SUCCESS;
> +	}
> +
> +	/*
> +	 * reclaim if compaction failed because not enough memory was
> +	 * available or if compaction didn't run (order 0) or didn't
> +	 * succeed.
> +	 */
>  	ret = __zone_reclaim(zone, gfp_mask, order);
> +	if (ret == ZONE_RECLAIM_SUCCESS) {
> +		if (zone_watermark_ok(zone, order, mark,
> +				      classzone_idx,
> +				      alloc_flags))
> +			return ZONE_RECLAIM_SUCCESS;
> +
> +		/*
> +		 * If compaction run but it was skipped and reclaim was
> +		 * successful keep going.
> +		 */
> +		if (need_compaction && c_ret == COMPACT_SKIPPED) {

And I recognise that you use need_compaction to see if it had been possible
to attempt compaction before but the way this is organise it appears that
it is possible to loop until __zone_reclaim fails which could be a lot
of reclaiming. If compaction always makes an attempt but always fails
(pinned/locked pages, fragmentation etc) then potentially we reclaim the
entire zone. I recognise that a single __zone_reclaim pass may not reclaim
enough pages to allow compaction to succeed so a single pass is not the
answer either but I worry that this will create a variation of the bug
where an excessive amount of memory is reclaimed to satisfy a THP
allocation.

> +			/*
> +			 * If it's ok to wait for I/O we can as well run sync
> +			 * compaction
> +			 */
> +			sync_compaction = !!(zone_reclaim_mode &
> +					     (RECLAIM_WRITE|RECLAIM_SWAP));
> +			cond_resched();
> +			goto repeat_compaction;
> +		}
> +	}
> +	if (need_compaction)
> +		defer_compaction(preferred_zone, order);
>  
>  	if (!ret)
>  		count_vm_event(PGSCAN_ZONE_RECLAIM_FAILED);

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
