Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id A46426B0035
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 02:35:50 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id fp1so5284099pdb.16
        for <linux-mm@kvack.org>; Sun, 22 Jun 2014 23:35:50 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id lc8si20462354pab.180.2014.06.22.23.35.48
        for <linux-mm@kvack.org>;
        Sun, 22 Jun 2014 23:35:49 -0700 (PDT)
Date: Mon, 23 Jun 2014 15:36:37 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch 2/4] mm: vmscan: rework compaction-ready signaling in
 direct reclaim
Message-ID: <20140623063637.GB15594@bbox>
References: <1403282030-29915-1-git-send-email-hannes@cmpxchg.org>
 <1403282030-29915-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1403282030-29915-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 20, 2014 at 12:33:48PM -0400, Johannes Weiner wrote:
> Page reclaim for a higher-order page runs until compaction is ready,
> then aborts and signals this situation through the return value of
> shrink_zones().  This is an oddly specific signal to encode in the
> return value of shrink_zones(), though, and can be quite confusing.
> 
> Introduce sc->compaction_ready and signal the compactability of the
> zones out-of-band to free up the return value of shrink_zones() for
> actual zone reclaimability.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Minchan Kim <minchan@kernel.org>

Below just one nitpick.

> ---
>  mm/vmscan.c | 67 ++++++++++++++++++++++++++++---------------------------------
>  1 file changed, 31 insertions(+), 36 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 19b5b8016209..ed1efb84c542 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -65,6 +65,9 @@ struct scan_control {
>  	/* Number of pages freed so far during a call to shrink_zones() */
>  	unsigned long nr_reclaimed;
>  
> +	/* One of the zones is ready for compaction */
> +	int compaction_ready;
> +
>  	/* How many pages shrink_list() should reclaim */
>  	unsigned long nr_to_reclaim;
>  
> @@ -2292,15 +2295,11 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
>  }
>  
>  /* Returns true if compaction should go ahead for a high-order request */
> -static inline bool compaction_ready(struct zone *zone, struct scan_control *sc)
> +static inline bool compaction_ready(struct zone *zone, int order)
>  {
>  	unsigned long balance_gap, watermark;
>  	bool watermark_ok;
>  
> -	/* Do not consider compaction for orders reclaim is meant to satisfy */
> -	if (sc->order <= PAGE_ALLOC_COSTLY_ORDER)
> -		return false;
> -
>  	/*
>  	 * Compaction takes time to run and there are potentially other
>  	 * callers using the pages just freed. Continue reclaiming until
> @@ -2309,18 +2308,18 @@ static inline bool compaction_ready(struct zone *zone, struct scan_control *sc)
>  	 */
>  	balance_gap = min(low_wmark_pages(zone), DIV_ROUND_UP(
>  			zone->managed_pages, KSWAPD_ZONE_BALANCE_GAP_RATIO));
> -	watermark = high_wmark_pages(zone) + balance_gap + (2UL << sc->order);
> +	watermark = high_wmark_pages(zone) + balance_gap + (2UL << order);
>  	watermark_ok = zone_watermark_ok_safe(zone, 0, watermark, 0, 0);
>  
>  	/*
>  	 * If compaction is deferred, reclaim up to a point where
>  	 * compaction will have a chance of success when re-enabled
>  	 */
> -	if (compaction_deferred(zone, sc->order))
> +	if (compaction_deferred(zone, order))
>  		return watermark_ok;
>  
>  	/* If compaction is not ready to start, keep reclaiming */
> -	if (!compaction_suitable(zone, sc->order))
> +	if (!compaction_suitable(zone, order))
>  		return false;
>  
>  	return watermark_ok;
> @@ -2341,20 +2340,14 @@ static inline bool compaction_ready(struct zone *zone, struct scan_control *sc)
>   *
>   * If a zone is deemed to be full of pinned pages then just give it a light
>   * scan then give up on it.
> - *
> - * This function returns true if a zone is being reclaimed for a costly
> - * high-order allocation and compaction is ready to begin. This indicates to
> - * the caller that it should consider retrying the allocation instead of
> - * further reclaim.
>   */
> -static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
> +static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  {
>  	struct zoneref *z;
>  	struct zone *zone;
>  	unsigned long nr_soft_reclaimed;
>  	unsigned long nr_soft_scanned;
>  	unsigned long lru_pages = 0;
> -	bool aborted_reclaim = false;

>  	struct reclaim_state *reclaim_state = current->reclaim_state;
>  	gfp_t orig_mask;
>  	struct shrink_control shrink = {
> @@ -2391,22 +2384,24 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  			if (sc->priority != DEF_PRIORITY &&
>  			    !zone_reclaimable(zone))
>  				continue;	/* Let kswapd poll it */
> -			if (IS_ENABLED(CONFIG_COMPACTION)) {
> -				/*
> -				 * If we already have plenty of memory free for
> -				 * compaction in this zone, don't free any more.
> -				 * Even though compaction is invoked for any
> -				 * non-zero order, only frequent costly order
> -				 * reclamation is disruptive enough to become a
> -				 * noticeable problem, like transparent huge
> -				 * page allocations.
> -				 */
> -				if ((zonelist_zone_idx(z) <= requested_highidx)
> -				    && compaction_ready(zone, sc)) {
> -					aborted_reclaim = true;
> -					continue;
> -				}
> +
> +			/*
> +			 * If we already have plenty of memory free
> +			 * for compaction in this zone, don't free any
> +			 * more.  Even though compaction is invoked
> +			 * for any non-zero order, only frequent
> +			 * costly order reclamation is disruptive
> +			 * enough to become a noticeable problem, like
> +			 * transparent huge page allocations.
> +			 */
> +			if (IS_ENABLED(CONFIG_COMPACTION) &&
> +			    sc->order > PAGE_ALLOC_COSTLY_ORDER &&

You are deleting comment sc->order <= PAGE_ALLOC_COSTLY_ORDER which was
in compaction_ready. At least, that comment was useful for me to guess
the intention. So if you have strong reason to remove that, I'd like to
remain it.


> +			    zonelist_zone_idx(z) <= requested_highidx &&
> +			    compaction_ready(zone, sc->order)) {
> +				sc->compaction_ready = true;
> +				continue;
>  			}
> +
>  			/*
>  			 * This steals pages from memory cgroups over softlimit
>  			 * and returns the number of reclaimed pages and
> @@ -2444,8 +2439,6 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  	 * promoted it to __GFP_HIGHMEM.
>  	 */
>  	sc->gfp_mask = orig_mask;
> -
> -	return aborted_reclaim;
>  }
>  
>  /* All zones in zonelist are unreclaimable? */
> @@ -2489,7 +2482,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  {
>  	unsigned long total_scanned = 0;
>  	unsigned long writeback_threshold;
> -	bool aborted_reclaim;
>  
>  	delayacct_freepages_start();
>  
> @@ -2500,12 +2492,15 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  		vmpressure_prio(sc->gfp_mask, sc->target_mem_cgroup,
>  				sc->priority);
>  		sc->nr_scanned = 0;
> -		aborted_reclaim = shrink_zones(zonelist, sc);
> +		shrink_zones(zonelist, sc);
>  
>  		total_scanned += sc->nr_scanned;
>  		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
>  			goto out;
>  
> +		if (sc->compaction_ready)
> +			goto out;
> +
>  		/*
>  		 * If we're getting trouble reclaiming, start doing
>  		 * writepage even in laptop mode.
> @@ -2526,7 +2521,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  						WB_REASON_TRY_TO_FREE_PAGES);
>  			sc->may_writepage = 1;
>  		}
> -	} while (--sc->priority >= 0 && !aborted_reclaim);
> +	} while (--sc->priority >= 0);
>  
>  out:
>  	delayacct_freepages_end();
> @@ -2535,7 +2530,7 @@ out:
>  		return sc->nr_reclaimed;
>  
>  	/* Aborted reclaim to try compaction? don't OOM, then */
> -	if (aborted_reclaim)
> +	if (sc->compaction_ready)
>  		return 1;
>  
>  	/* top priority shrink_zones still had more to do? don't OOM, then */
> -- 
> 2.0.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
