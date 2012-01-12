Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 5AE396B004D
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 10:46:21 -0500 (EST)
Date: Thu, 12 Jan 2012 15:46:17 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH -mm 1/2] mm: kswapd test order 0 watermarks when
 compaction is enabled
Message-ID: <20120112154617.GH3910@csn.ul.ie>
References: <20120109213156.0ff47ee5@annuminas.surriel.com>
 <20120109213313.22841ef5@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120109213313.22841ef5@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, aarcange@redhat.com

On Mon, Jan 09, 2012 at 09:33:13PM -0500, Rik van Riel wrote:
> When built with CONFIG_COMPACTION, kswapd does not try to free
> contiguous pages.  Because it is not trying, it should also not
> test whether it succeeded, because that can result in continuous
> page reclaim, until a large fraction of memory is free and large
> fractions of the working set have been evicted.
> 

hmm, I'm missing something about your explanation.

1. wakeup_kswapd passes requested order to kswapd_max_order. Bear in
   mind that this does *not* happen for THP.
2. kswapd reads this and passes it to balance_pgdat
3. balance_pgdat puts that in scan_control
4. shrink_zone gets that scan_control and so on

kswapd does try to free contiguous pages.

What is the source of the contiguous allocations of concern? The
mm_vmscan_wakeup_kswapd tracepoint should be able to get you a stack
trace to identify the source of high-order allocations.

To confirm I was not on crazy pills I fired up a systemtap script
that did a burst of order-8 allocations (ok, some crazy pills) and
observed this with tracepoints

          <idle>-0     [002] 236009.284803: mm_vmscan_wakeup_kswapd: nid=0 zid=2 order=8
         kswapd0-53    [002] 236009.285028: mm_vmscan_kswapd_wake: nid=0 order=8
         kswapd0-53    [002] 236009.285034: mm_vmscan_lru_isolate: isolate_mode=1 order=8 nr_requested=9 nr_scanned=0 nr_taken=0 contig_taken=0 contig_dirty=0 contig_failed=0
         kswapd0-53    [002] 236009.285035: mm_vmscan_lru_isolate: isolate_mode=1 order=8 nr_requested=22 nr_scanned=0 nr_taken=0 contig_taken=0 contig_dirty=0 contig_failed=0
         kswapd0-53    [002] 236009.285038: mm_vmscan_lru_isolate: isolate_mode=1 order=8 nr_requested=1 nr_scanned=1 nr_taken=1 contig_taken=0 contig_dirty=0 contig_failed=1
         kswapd0-53    [002] 236009.285049: mm_vmscan_lru_isolate: isolate_mode=1 order=8 nr_requested=32 nr_scanned=32 nr_taken=32 contig_taken=12 contig_dirty=0 contig_failed=20
         kswapd0-53    [002] 236009.285080: mm_vmscan_lru_isolate: isolate_mode=2 order=8 nr_requested=32 nr_scanned=38 nr_taken=38 contig_taken=24 contig_dirty=0 contig_failed=14
         kswapd0-53    [002] 236009.285090: mm_vmscan_lru_isolate: isolate_mode=1 order=8 nr_requested=23 nr_scanned=24 nr_taken=24 contig_taken=4 contig_dirty=0 contig_failed=20

This is with CONFIG_COMPACTION.

You're still in the right area though. kswapd does contiguous-aware
reclaim it does not do any compaction and so potentially it is doing
excessive reclaim while depending on another process to do the
compaction for it. That is a problem.

> Also remove a line of code that increments balanced right before
> exiting the function.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
>  mm/vmscan.c |   22 +++++++++++++++++-----
>  1 files changed, 17 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f54a05b..c3eec6b 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2608,7 +2608,7 @@ loop_again:
>  		 */
>  		for (i = 0; i <= end_zone; i++) {
>  			struct zone *zone = pgdat->node_zones + i;
> -			int nr_slab;
> +			int nr_slab, testorder;
>  			unsigned long balance_gap;
>  
>  			if (!populated_zone(zone))
> @@ -2637,11 +2637,25 @@ loop_again:
>  			 * gap is either the low watermark or 1%
>  			 * of the zone, whichever is smaller.
>  			 */
> +			testorder = order;
>  			balance_gap = min(low_wmark_pages(zone),
>  				(zone->present_pages +
>  					KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
>  				KSWAPD_ZONE_BALANCE_GAP_RATIO);
> -			if (!zone_watermark_ok_safe(zone, order,
> +			/*
> +			 * Kswapd reclaims only single pages when
> +			 * COMPACTION_BUILD. Trying too hard to get
> +			 * contiguous free pages can result in excessive
> +			 * amounts of free memory, and useful things
> +			 * getting kicked out of memory.
> +			 * Limit the amount of reclaim to something sane,
> +			 * plus space for compaction to do its thing.
> +			 */
> +			if (COMPACTION_BUILD) {
> +				testorder = 0;
> +				balance_gap += 2<<order;
> +			}
> +			if (!zone_watermark_ok_safe(zone, testorder,
>  					high_wmark_pages(zone) + balance_gap,
>  					end_zone, 0)) {

kswapd does reclaim high-order pages so this comment is misleading.
However I see the type of problem you are talking about.

Direct reclaim in shrink_zones() does a check for compaction_suitable()
when deciding whether to abort reclaim or not. How about doing the same
for kswapd and if compaction can go ahead, goto out?

>  				shrink_zone(priority, zone, &sc);
> @@ -2670,7 +2684,7 @@ loop_again:
>  				continue;
>  			}
>  
> -			if (!zone_watermark_ok_safe(zone, order,
> +			if (!zone_watermark_ok_safe(zone, testorder,
>  					high_wmark_pages(zone), end_zone, 0)) {
>  				all_zones_ok = 0;
>  				/*
> @@ -2776,8 +2790,6 @@ out:
>  
>  			/* If balanced, clear the congested flag */
>  			zone_clear_flag(zone, ZONE_CONGESTED);
> -			if (i <= *classzone_idx)
> -				balanced += zone->present_pages;
>  		}
>  	}
>  
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
