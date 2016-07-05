Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D406B6B0005
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 04:07:30 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 143so435567299pfx.0
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 01:07:30 -0700 (PDT)
Received: from out4133-98.mail.aliyun.com (out4133-98.mail.aliyun.com. [42.120.133.98])
        by mx.google.com with ESMTP id wd9si1178432pab.236.2016.07.05.01.07.26
        for <linux-mm@kvack.org>;
        Tue, 05 Jul 2016 01:07:27 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <00f601d1d691$d790ad40$86b207c0$@alibaba-inc.com>
In-Reply-To: <00f601d1d691$d790ad40$86b207c0$@alibaba-inc.com>
Subject: Re: [PATCH 31/31] mm, vmstat: Remove zone and node double accounting by approximating retries
Date: Tue, 05 Jul 2016 16:07:23 +0800
Message-ID: <00fa01d1d694$42f6a7e0$c8e3f7a0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

> 
> The number of LRU pages, dirty pages and writeback pages must be accounted
> for on both zones and nodes because of the reclaim retry logic, compaction
> retry logic and highmem calculations all depending on per-zone stats.
> 
> The retry logic is only critical for allocations that can use any zones.
> Hence this patch will not retry reclaim or compaction for such allocations.
> This should not be a problem for reclaim as zone-constrained allocations
> are immune from OOM kill. For retries, a very rough approximation is made
> whether to retry or not. While it is possible this will make the wrong
> decision on occasion, it will not infinite loop as the number of reclaim
> attempts is capped by MAX_RECLAIM_RETRIES.
> 
> The highmem calculations only care about the global count of file pages
> in highmem. Hence, a global counter is used instead of per-zone stats.
> With this, the per-zone double accounting disappears.
> 
> Suggested by: Michal Hocko <mhocko@kernel.org>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  include/linux/mm_inline.h | 20 +++++++++++--
>  include/linux/mmzone.h    |  4 ---
>  include/linux/swap.h      |  1 -
>  mm/compaction.c           | 22 ++++++++++++++-
>  mm/migrate.c              |  2 --
>  mm/page-writeback.c       | 13 ++++-----
>  mm/page_alloc.c           | 71 ++++++++++++++++++++++++++++++++---------------
>  mm/vmscan.c               | 16 -----------
>  mm/vmstat.c               |  3 --
>  9 files changed, 92 insertions(+), 60 deletions(-)
> 
[...]
> @@ -3445,6 +3445,7 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
>  {
>  	struct zone *zone;
>  	struct zoneref *z;
> +	pg_data_t *current_pgdat = NULL;
> 
>  	/*
>  	 * Make sure we converge to OOM if we cannot make any progress
> @@ -3454,6 +3455,14 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
>  		return false;
> 
>  	/*
> +	 * Blindly retry allocation requests that cannot use all zones. We do
> +	 * not have a reliable and fast means of calculating reclaimable, dirty
> +	 * and writeback pages in eligible zones.
> +	 */
> +	if (IS_ENABLED(CONFIG_HIGHMEM) && !is_highmem_idx(gfp_zone(gfp_mask)))
> +		goto out;
> +
> +	/*
>  	 * Keep reclaiming pages while there is a chance this will lead somewhere.
>  	 * If none of the target zones can satisfy our allocation request even
>  	 * if all reclaimable pages are considered then we are screwed and have
> @@ -3463,36 +3472,54 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
>  					ac->nodemask) {
>  		unsigned long available;
>  		unsigned long reclaimable;
> +		unsigned long write_pending = 0;
> +		int zid;
> +
> +		if (current_pgdat == zone->zone_pgdat)
> +			continue;
> 
> -		available = reclaimable = zone_reclaimable_pages(zone);
> +		current_pgdat = zone->zone_pgdat;
> +		available = reclaimable = pgdat_reclaimable_pages(current_pgdat);
>  		available -= DIV_ROUND_UP(no_progress_loops * available,
>  					MAX_RECLAIM_RETRIES);
> -		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
> +		write_pending = node_page_state(current_pgdat, NR_WRITEBACK) +
> +					node_page_state(current_pgdat, NR_FILE_DIRTY);
> 
> -		/*
> -		 * Would the allocation succeed if we reclaimed the whole
> -		 * available?
> -		 */
> -		if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
> -				ac_classzone_idx(ac), alloc_flags, available)) {
> -			/*
> -			 * If we didn't make any progress and have a lot of
> -			 * dirty + writeback pages then we should wait for
> -			 * an IO to complete to slow down the reclaim and
> -			 * prevent from pre mature OOM
> -			 */
> -			if (!did_some_progress) {
> -				unsigned long write_pending;
> +		/* Account for all free pages on eligible zones */
> +		for (zid = 0; zid <= zone_idx(zone); zid++) {
> +			struct zone *acct_zone = &current_pgdat->node_zones[zid];
> 
> -				write_pending = zone_page_state_snapshot(zone,
> -							NR_ZONE_WRITE_PENDING);
> +			available += zone_page_state_snapshot(acct_zone, NR_FREE_PAGES);
> +		}
> 
> -				if (2 * write_pending > reclaimable) {
> -					congestion_wait(BLK_RW_ASYNC, HZ/10);
> -					return true;
> -				}
> +		/*
> +		 * If we didn't make any progress and have a lot of
> +		 * dirty + writeback pages then we should wait for an IO to
> +		 * complete to slow down the reclaim and prevent from premature
> +		 * OOM.
> +		 */
> +		if (!did_some_progress) {
> +			if (2 * write_pending > reclaimable) {
> +				congestion_wait(BLK_RW_ASYNC, HZ/10);
> +				return true;
>  			}
> +		}
> 
> +		/*
> +		 * Would the allocation succeed if we reclaimed the whole
> +		 * available? This is approximate because there is no
> +		 * accurate count of reclaimable pages per zone.
> +		 */
> +		for (zid = 0; zid <= zone_idx(zone); zid++) {
> +			struct zone *check_zone = &current_pgdat->node_zones[zid];
> +			unsigned long estimate;
> +
> +			estimate = min(check_zone->managed_pages, available);
> +			if (__zone_watermark_ok(check_zone, order,
> +					min_wmark_pages(check_zone), ac_classzone_idx(ac),
> +					alloc_flags, available)) {
> +			}
Stray indent?

> +out:
>  			/*
>  			 * Memory allocation/reclaim might be called from a WQ
>  			 * context and the current implementation of the WQ
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 151c30dd27e2..c538a8cab43b 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
