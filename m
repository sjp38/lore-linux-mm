Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8F5C36B0260
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 10:02:45 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f75so12383413wmf.2
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 07:02:45 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id h128si43549473wmf.84.2016.06.01.07.02.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 07:02:44 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id e3so7100501wme.2
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 07:02:44 -0700 (PDT)
Date: Wed, 1 Jun 2016 16:02:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 14/18] mm, compaction: create compact_gap wrapper
Message-ID: <20160601140242.GU26601@dhcp22.suse.cz>
References: <20160531130818.28724-1-vbabka@suse.cz>
 <20160531130818.28724-15-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160531130818.28724-15-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On Tue 31-05-16 15:08:14, Vlastimil Babka wrote:
> Compaction uses a watermark gap of (2UL << order) pages at various places and
> it's not immediately obvious why. Abstract it through a compact_gap() wrapper
> to create a single place with a thorough explanation.

Yes the comment is helpful.
 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/compaction.h | 16 ++++++++++++++++
>  mm/compaction.c            |  7 +++----
>  mm/vmscan.c                |  4 ++--
>  3 files changed, 21 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index 4bef69a83f8f..654cb74418c4 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -58,6 +58,22 @@ enum compact_result {
>  
>  struct alloc_context; /* in mm/internal.h */
>  
> +/*
> + * Number of free order-0 pages that should be available above given watermark
> + * to make sure compaction has reasonable chance of not running out of free
> + * pages that it needs to isolate as migration target during its work.
> + */
> +static inline unsigned long compact_gap(unsigned int order)
> +{
> +	/*
> +	 * Although all the isolations for migration are temporary, compaction
> +	 * may have up to 1 << order pages on its list and then try to split
> +	 * an (order - 1) free page. At that point, a gap of 1 << order might
> +	 * not be enough, so it's safer to require twice that amount.
> +	 */
> +	return 2UL << order;
> +}
> +
>  #ifdef CONFIG_COMPACTION
>  extern int sysctl_compact_memory;
>  extern int sysctl_compaction_handler(struct ctl_table *table, int write,
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 4b21a26694a2..bcab680ccb8a 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1337,11 +1337,10 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
>  		return COMPACT_PARTIAL;
>  
>  	/*
> -	 * Watermarks for order-0 must be met for compaction. Note the 2UL.
> -	 * This is because during migration, copies of pages need to be
> -	 * allocated and for a short time, the footprint is higher
> +	 * Watermarks for order-0 must be met for compaction to be able to
> +	 * isolate free pages for migration targets.
>  	 */
> -	watermark = low_wmark_pages(zone) + (2UL << order);
> +	watermark = low_wmark_pages(zone) + compact_gap(order);
>  	if (!__zone_watermark_ok(zone, 0, watermark, classzone_idx,
>  				 alloc_flags, wmark_target))
>  		return COMPACT_SKIPPED;
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c4a2f4512fca..00034ec9229b 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2345,7 +2345,7 @@ static inline bool should_continue_reclaim(struct zone *zone,
>  	 * If we have not reclaimed enough pages for compaction and the
>  	 * inactive lists are large enough, continue reclaiming
>  	 */
> -	pages_for_compaction = (2UL << sc->order);
> +	pages_for_compaction = compact_gap(sc->order);
>  	inactive_lru_pages = zone_page_state(zone, NR_INACTIVE_FILE);
>  	if (get_nr_swap_pages() > 0)
>  		inactive_lru_pages += zone_page_state(zone, NR_INACTIVE_ANON);
> @@ -2472,7 +2472,7 @@ static inline bool compaction_ready(struct zone *zone, int order, int classzone_
>  	 */
>  	balance_gap = min(low_wmark_pages(zone), DIV_ROUND_UP(
>  			zone->managed_pages, KSWAPD_ZONE_BALANCE_GAP_RATIO));
> -	watermark = high_wmark_pages(zone) + balance_gap + (2UL << order);
> +	watermark = high_wmark_pages(zone) + balance_gap + compact_gap(order);
>  	watermark_ok = zone_watermark_ok_safe(zone, 0, watermark, classzone_idx);
>  
>  	/*
> -- 
> 2.8.3

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
