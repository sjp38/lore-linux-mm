Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 62C3C828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 01:52:28 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id cx13so222618448pac.2
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 22:52:28 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id p128si2354642pfb.108.2016.07.05.22.52.26
        for <linux-mm@kvack.org>;
        Tue, 05 Jul 2016 22:52:27 -0700 (PDT)
Date: Wed, 6 Jul 2016 14:55:50 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 17/17] mm, vmscan: make compaction_ready() more
 accurate and readable
Message-ID: <20160706055550.GG23627@js1304-P5Q-DELUXE>
References: <20160624095437.16385-1-vbabka@suse.cz>
 <20160624095437.16385-18-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160624095437.16385-18-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On Fri, Jun 24, 2016 at 11:54:37AM +0200, Vlastimil Babka wrote:
> The compaction_ready() is used during direct reclaim for costly order
> allocations to skip reclaim for zones where compaction should be attempted
> instead. It's combining the standard compaction_suitable() check with its own
> watermark check based on high watermark with extra gap, and the result is
> confusing at best.
> 
> This patch attempts to better structure and document the checks involved.
> First, compaction_suitable() can determine that the allocation should either
> succeed already, or that compaction doesn't have enough free pages to proceed.
> The third possibility is that compaction has enough free pages, but we still
> decide to reclaim first - unless we are already above the high watermark with
> gap.  This does not mean that the reclaim will actually reach this watermark
> during single attempt, this is rather an over-reclaim protection. So document
> the code as such. The check for compaction_deferred() is removed completely, as
> it in fact had no proper role here.
> 
> The result after this patch is mainly a less confusing code. We also skip some
> over-reclaim in cases where the allocation should already succed.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/vmscan.c | 43 ++++++++++++++++++++-----------------------
>  1 file changed, 20 insertions(+), 23 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 484ff05d5a8f..724131661f0c 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2462,40 +2462,37 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  }
>  
>  /*
> - * Returns true if compaction should go ahead for a high-order request, or
> - * the high-order allocation would succeed without compaction.
> + * Returns true if compaction should go ahead for a costly-order request, or
> + * the allocation would already succeed without compaction. Return false if we
> + * should reclaim first.
>   */
>  static inline bool compaction_ready(struct zone *zone, int order, int classzone_idx)
>  {
>  	unsigned long balance_gap, watermark;
> -	bool watermark_ok;
> +	enum compact_result suitable;
> +
> +	suitable = compaction_suitable(zone, order, 0, classzone_idx);
> +	if (suitable == COMPACT_PARTIAL)
> +		/* Allocation should succeed already. Don't reclaim. */
> +		return true;
> +	if (suitable == COMPACT_SKIPPED)
> +		/* Compaction cannot yet proceed. Do reclaim. */
> +		return false;
>  
>  	/*
> -	 * Compaction takes time to run and there are potentially other
> -	 * callers using the pages just freed. Continue reclaiming until
> -	 * there is a buffer of free pages available to give compaction
> -	 * a reasonable chance of completing and allocating the page
> +	 * Compaction is already possible, but it takes time to run and there
> +	 * are potentially other callers using the pages just freed. So proceed
> +	 * with reclaim to make a buffer of free pages available to give
> +	 * compaction a reasonable chance of completing and allocating the page.
> +	 * Note that we won't actually reclaim the whole buffer in one attempt
> +	 * as the target watermark in should_continue_reclaim() is lower. But if
> +	 * we are already above the high+gap watermark, don't reclaim at all.
>  	 */
>  	balance_gap = min(low_wmark_pages(zone), DIV_ROUND_UP(
>  			zone->managed_pages, KSWAPD_ZONE_BALANCE_GAP_RATIO));
>  	watermark = high_wmark_pages(zone) + balance_gap + compact_gap(order);
> -	watermark_ok = zone_watermark_ok_safe(zone, 0, watermark, classzone_idx);

Hmm... it doesn't explain why both high_wmark_pages and balance_gap
are needed. If we want to make a buffer, one of them would work.

Thanks.

> -
> -	/*
> -	 * If compaction is deferred, reclaim up to a point where
> -	 * compaction will have a chance of success when re-enabled
> -	 */
> -	if (compaction_deferred(zone, order))
> -		return watermark_ok;
> -
> -	/*
> -	 * If compaction is not ready to start and allocation is not likely
> -	 * to succeed without it, then keep reclaiming.
> -	 */
> -	if (compaction_suitable(zone, order, 0, classzone_idx) == COMPACT_SKIPPED)
> -		return false;
>  
> -	return watermark_ok;
> +	return zone_watermark_ok_safe(zone, 0, watermark, classzone_idx);
>  }
>  
>  /*
> -- 
> 2.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
