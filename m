Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 95AF66B009D
	for <linux-mm@kvack.org>; Tue, 14 May 2013 07:25:17 -0400 (EDT)
Date: Tue, 14 May 2013 13:25:14 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 6/9] mm: vmscan: Have kswapd writeback pages based on
 dirty pages encountered, not priority
Message-ID: <20130514112514.GO5198@dhcp22.suse.cz>
References: <1368432760-21573-1-git-send-email-mgorman@suse.de>
 <1368432760-21573-7-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1368432760-21573-7-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 13-05-13 09:12:37, Mel Gorman wrote:
> Currently kswapd queues dirty pages for writeback if scanning at an elevated
> priority but the priority kswapd scans at is not related to the number
> of unqueued dirty encountered.  Since commit "mm: vmscan: Flatten kswapd
> priority loop", the priority is related to the size of the LRU and the
> zone watermark which is no indication as to whether kswapd should write
> pages or not.
> 
> This patch tracks if an excessive number of unqueued dirty pages are being
> encountered at the end of the LRU.  If so, it indicates that dirty pages
> are being recycled before flusher threads can clean them and flags the
> zone so that kswapd will start writing pages until the zone is balanced.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

I do not see the direct reclaim clearing the flag. Although direct
reclaim ignores the flag it still sets it without clearing it. This
means that you rely on parallel kswapd to clear it.
We do the same thing with ZONE_CONGESTED but I think this should be at
least documented somewhere.

Other than that
Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/mmzone.h |  9 +++++++++
>  mm/vmscan.c            | 31 +++++++++++++++++++++++++------
>  2 files changed, 34 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 5c76737..2aaf72f 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -495,6 +495,10 @@ typedef enum {
>  	ZONE_CONGESTED,			/* zone has many dirty pages backed by
>  					 * a congested BDI
>  					 */
> +	ZONE_TAIL_LRU_DIRTY,		/* reclaim scanning has recently found
> +					 * many dirty file pages at the tail
> +					 * of the LRU.
> +					 */
>  } zone_flags_t;
>  
>  static inline void zone_set_flag(struct zone *zone, zone_flags_t flag)
> @@ -517,6 +521,11 @@ static inline int zone_is_reclaim_congested(const struct zone *zone)
>  	return test_bit(ZONE_CONGESTED, &zone->flags);
>  }
>  
> +static inline int zone_is_reclaim_dirty(const struct zone *zone)
> +{
> +	return test_bit(ZONE_TAIL_LRU_DIRTY, &zone->flags);
> +}
> +
>  static inline int zone_is_reclaim_locked(const struct zone *zone)
>  {
>  	return test_bit(ZONE_RECLAIM_LOCKED, &zone->flags);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 1505c57..d6c916d 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -676,13 +676,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  				      struct zone *zone,
>  				      struct scan_control *sc,
>  				      enum ttu_flags ttu_flags,
> -				      unsigned long *ret_nr_dirty,
> +				      unsigned long *ret_nr_unqueued_dirty,
>  				      unsigned long *ret_nr_writeback,
>  				      bool force_reclaim)
>  {
>  	LIST_HEAD(ret_pages);
>  	LIST_HEAD(free_pages);
>  	int pgactivate = 0;
> +	unsigned long nr_unqueued_dirty = 0;
>  	unsigned long nr_dirty = 0;
>  	unsigned long nr_congested = 0;
>  	unsigned long nr_reclaimed = 0;
> @@ -808,14 +809,17 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		if (PageDirty(page)) {
>  			nr_dirty++;
>  
> +			if (!PageWriteback(page))
> +				nr_unqueued_dirty++;
> +
>  			/*
>  			 * Only kswapd can writeback filesystem pages to
> -			 * avoid risk of stack overflow but do not writeback
> -			 * unless under significant pressure.
> +			 * avoid risk of stack overflow but only writeback
> +			 * if many dirty pages have been encountered.
>  			 */
>  			if (page_is_file_cache(page) &&
>  					(!current_is_kswapd() ||
> -					 sc->priority >= DEF_PRIORITY - 2)) {
> +					 !zone_is_reclaim_dirty(zone))) {
>  				/*
>  				 * Immediately reclaim when written back.
>  				 * Similar in principal to deactivate_page()
> @@ -960,7 +964,7 @@ keep:
>  	list_splice(&ret_pages, page_list);
>  	count_vm_events(PGACTIVATE, pgactivate);
>  	mem_cgroup_uncharge_end();
> -	*ret_nr_dirty += nr_dirty;
> +	*ret_nr_unqueued_dirty += nr_unqueued_dirty;
>  	*ret_nr_writeback += nr_writeback;
>  	return nr_reclaimed;
>  }
> @@ -1373,6 +1377,15 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  			(nr_taken >> (DEF_PRIORITY - sc->priority)))
>  		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
>  
> +	/*
> +	 * Similarly, if many dirty pages are encountered that are not
> +	 * currently being written then flag that kswapd should start
> +	 * writing back pages.
> +	 */
> +	if (global_reclaim(sc) && nr_dirty &&
> +			nr_dirty >= (nr_taken >> (DEF_PRIORITY - sc->priority)))
> +		zone_set_flag(zone, ZONE_TAIL_LRU_DIRTY);
> +
>  	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
>  		zone_idx(zone),
>  		nr_scanned, nr_reclaimed,
> @@ -2769,8 +2782,12 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>  				end_zone = i;
>  				break;
>  			} else {
> -				/* If balanced, clear the congested flag */
> +				/*
> +				 * If balanced, clear the dirty and congested
> +				 * flags
> +				 */
>  				zone_clear_flag(zone, ZONE_CONGESTED);
> +				zone_clear_flag(zone, ZONE_TAIL_LRU_DIRTY);
>  			}
>  		}
>  
> @@ -2888,8 +2905,10 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>  				 * possible there are dirty pages backed by
>  				 * congested BDIs but as pressure is relieved,
>  				 * speculatively avoid congestion waits
> +				 * or writing pages from kswapd context.
>  				 */
>  				zone_clear_flag(zone, ZONE_CONGESTED);
> +				zone_clear_flag(zone, ZONE_TAIL_LRU_DIRTY);
>  		}
>  
>  		/*
> -- 
> 1.8.1.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
