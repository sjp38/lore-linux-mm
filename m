Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id CB9A26B0038
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 08:30:41 -0400 (EDT)
Received: by wijp15 with SMTP id p15so14759614wij.0
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 05:30:41 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com. [209.85.212.178])
        by mx.google.com with ESMTPS id t9si8877157wiz.2.2015.08.20.05.30.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Aug 2015 05:30:40 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so34902002wic.1
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 05:30:39 -0700 (PDT)
Date: Thu, 20 Aug 2015 14:30:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 02/10] mm, page_alloc: Remove unnecessary parameter from
 zone_watermark_ok_safe
Message-ID: <20150820123037.GD20110@dhcp22.suse.cz>
References: <1439376335-17895-1-git-send-email-mgorman@techsingularity.net>
 <1439376335-17895-3-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1439376335-17895-3-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 12-08-15 11:45:27, Mel Gorman wrote:
> No user of zone_watermark_ok_safe() specifies alloc_flags. This patch
> removes the unnecessary parameter.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: David Rientjes <rientjes@google.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/mmzone.h | 2 +-
>  mm/page_alloc.c        | 5 +++--
>  mm/vmscan.c            | 4 ++--
>  3 files changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index decc99a007f5..8b86ec5df968 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -731,7 +731,7 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx);
>  bool zone_watermark_ok(struct zone *z, unsigned int order,
>  		unsigned long mark, int classzone_idx, int alloc_flags);
>  bool zone_watermark_ok_safe(struct zone *z, unsigned int order,
> -		unsigned long mark, int classzone_idx, int alloc_flags);
> +		unsigned long mark, int classzone_idx);
>  enum memmap_context {
>  	MEMMAP_EARLY,
>  	MEMMAP_HOTPLUG,
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 41c0799b9049..5e1f6f4370bc 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2209,6 +2209,7 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
>  		min -= min / 2;
>  	if (alloc_flags & ALLOC_HARDER)
>  		min -= min / 4;
> +
>  #ifdef CONFIG_CMA
>  	/* If allocation can't use CMA areas don't use free CMA pages */
>  	if (!(alloc_flags & ALLOC_CMA))
> @@ -2238,14 +2239,14 @@ bool zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
>  }
>  
>  bool zone_watermark_ok_safe(struct zone *z, unsigned int order,
> -			unsigned long mark, int classzone_idx, int alloc_flags)
> +			unsigned long mark, int classzone_idx)
>  {
>  	long free_pages = zone_page_state(z, NR_FREE_PAGES);
>  
>  	if (z->percpu_drift_mark && free_pages < z->percpu_drift_mark)
>  		free_pages = zone_page_state_snapshot(z, NR_FREE_PAGES);
>  
> -	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
> +	return __zone_watermark_ok(z, order, mark, classzone_idx, 0,
>  								free_pages);
>  }
>  
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index e61445dce04e..f1d8eae285f2 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2454,7 +2454,7 @@ static inline bool compaction_ready(struct zone *zone, int order)
>  	balance_gap = min(low_wmark_pages(zone), DIV_ROUND_UP(
>  			zone->managed_pages, KSWAPD_ZONE_BALANCE_GAP_RATIO));
>  	watermark = high_wmark_pages(zone) + balance_gap + (2UL << order);
> -	watermark_ok = zone_watermark_ok_safe(zone, 0, watermark, 0, 0);
> +	watermark_ok = zone_watermark_ok_safe(zone, 0, watermark, 0);
>  
>  	/*
>  	 * If compaction is deferred, reclaim up to a point where
> @@ -2937,7 +2937,7 @@ static bool zone_balanced(struct zone *zone, int order,
>  			  unsigned long balance_gap, int classzone_idx)
>  {
>  	if (!zone_watermark_ok_safe(zone, order, high_wmark_pages(zone) +
> -				    balance_gap, classzone_idx, 0))
> +				    balance_gap, classzone_idx))
>  		return false;
>  
>  	if (IS_ENABLED(CONFIG_COMPACTION) && order && compaction_suitable(zone,
> -- 
> 2.4.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
