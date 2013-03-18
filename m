Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 274996B0002
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 07:37:51 -0400 (EDT)
Received: by mail-ve0-f174.google.com with SMTP id pb11so4167647veb.19
        for <linux-mm@kvack.org>; Mon, 18 Mar 2013 04:37:50 -0700 (PDT)
Message-ID: <5146FC86.2080107@gmail.com>
Date: Mon, 18 Mar 2013 19:37:42 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 07/10] mm: vmscan: Block kswapd if it is encountering
 pages under writeback
References: <1363525456-10448-1-git-send-email-mgorman@suse.de> <1363525456-10448-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1363525456-10448-8-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On 03/17/2013 09:04 PM, Mel Gorman wrote:
> Historically, kswapd used to congestion_wait() at higher priorities if it
> was not making forward progress. This made no sense as the failure to make
> progress could be completely independent of IO. It was later replaced by
> wait_iff_congested() and removed entirely by commit 258401a6 (mm: don't
> wait on congested zones in balance_pgdat()) as it was duplicating logic
> in shrink_inactive_list().
>
> This is problematic. If kswapd encounters many pages under writeback and
> it continues to scan until it reaches the high watermark then it will
> quickly skip over the pages under writeback and reclaim clean young
> pages or push applications out to swap.
>
> The use of wait_iff_congested() is not suited to kswapd as it will only
> stall if the underlying BDI is really congested or a direct reclaimer was
> unable to write to the underlying BDI. kswapd bypasses the BDI congestion
> as it sets PF_SWAPWRITE but even if this was taken into account then it

Where will check this flag?

> would cause direct reclaimers to stall on writeback which is not desirable.
>
> This patch sets a ZONE_WRITEBACK flag if direct reclaim or kswapd is
> encountering too many pages under writeback. If this flag is set and
> kswapd encounters a PageReclaim page under writeback then it'll assume
> that the LRU lists are being recycled too quickly before IO can complete
> and block waiting for some IO to complete.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>   include/linux/mmzone.h |  8 ++++++++
>   mm/vmscan.c            | 29 ++++++++++++++++++++++++-----
>   2 files changed, 32 insertions(+), 5 deletions(-)
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index edd6b98..c758fb7 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -498,6 +498,9 @@ typedef enum {
>   	ZONE_DIRTY,			/* reclaim scanning has recently found
>   					 * many dirty file pages
>   					 */
> +	ZONE_WRITEBACK,			/* reclaim scanning has recently found
> +					 * many pages under writeback
> +					 */
>   } zone_flags_t;
>   
>   static inline void zone_set_flag(struct zone *zone, zone_flags_t flag)
> @@ -525,6 +528,11 @@ static inline int zone_is_reclaim_dirty(const struct zone *zone)
>   	return test_bit(ZONE_DIRTY, &zone->flags);
>   }
>   
> +static inline int zone_is_reclaim_writeback(const struct zone *zone)
> +{
> +	return test_bit(ZONE_WRITEBACK, &zone->flags);
> +}
> +
>   static inline int zone_is_reclaim_locked(const struct zone *zone)
>   {
>   	return test_bit(ZONE_RECLAIM_LOCKED, &zone->flags);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 493728b..7d5a932 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -725,6 +725,19 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>   
>   		if (PageWriteback(page)) {
>   			/*
> +			 * If reclaim is encountering an excessive number of
> +			 * pages under writeback and this page is both under
> +			 * writeback and PageReclaim then it indicates that
> +			 * pages are being queued for IO but are being
> +			 * recycled through the LRU before the IO can complete.
> +			 * is useless CPU work so wait on the IO to complete.
> +			 */
> +			if (current_is_kswapd() &&
> +			    zone_is_reclaim_writeback(zone)) {
> +				wait_on_page_writeback(page);
> +				zone_clear_flag(zone, ZONE_WRITEBACK);
> +
> +			/*
>   			 * memcg doesn't have any dirty pages throttling so we
>   			 * could easily OOM just because too many pages are in
>   			 * writeback and there is nothing else to reclaim.
> @@ -741,7 +754,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>   			 * grab_cache_page_write_begin(,,AOP_FLAG_NOFS), so
>   			 * testing may_enter_fs here is liable to OOM on them.
>   			 */
> -			if (global_reclaim(sc) ||
> +			} else if (global_reclaim(sc) ||
>   			    !PageReclaim(page) || !(sc->gfp_mask & __GFP_IO)) {
>   				/*
>   				 * This is slightly racy - end_page_writeback()
> @@ -756,9 +769,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>   				 */
>   				SetPageReclaim(page);
>   				nr_writeback++;
> +
>   				goto keep_locked;
> +			} else {
> +				wait_on_page_writeback(page);
>   			}
> -			wait_on_page_writeback(page);
>   		}
>   
>   		if (!force_reclaim)
> @@ -1373,8 +1388,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>   	 *                     isolated page is PageWriteback
>   	 */
>   	if (nr_writeback && nr_writeback >=
> -			(nr_taken >> (DEF_PRIORITY - sc->priority)))
> +			(nr_taken >> (DEF_PRIORITY - sc->priority))) {
>   		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
> +		zone_set_flag(zone, ZONE_WRITEBACK);
> +	}
>   
>   	/*
>   	 * Similarly, if many dirty pages are encountered that are not
> @@ -2639,8 +2656,8 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
>    * kswapd shrinks the zone by the number of pages required to reach
>    * the high watermark.
>    *
> - * Returns true if kswapd scanned at least the requested number of
> - * pages to reclaim.
> + * Returns true if kswapd scanned at least the requested number of pages to
> + * reclaim or if the lack of process was due to pages under writeback.
>    */
>   static bool kswapd_shrink_zone(struct zone *zone,
>   			       struct scan_control *sc,
> @@ -2663,6 +2680,8 @@ static bool kswapd_shrink_zone(struct zone *zone,
>   	if (nr_slab == 0 && !zone_reclaimable(zone))
>   		zone->all_unreclaimable = 1;
>   
> +	zone_clear_flag(zone, ZONE_WRITEBACK);
> +
>   	return sc->nr_scanned >= sc->nr_to_reclaim;
>   }
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
