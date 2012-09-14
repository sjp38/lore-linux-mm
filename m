Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id E017D6B019D
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 23:41:24 -0400 (EDT)
Date: Fri, 14 Sep 2012 12:43:36 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 4/5] mm: add accounting for CMA pages and use them for
 watermark calculation
Message-ID: <20120914034336.GI5085@bbox>
References: <1346765185-30977-1-git-send-email-b.zolnierkie@samsung.com>
 <1346765185-30977-5-git-send-email-b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1346765185-30977-5-git-send-email-b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, m.szyprowski@samsung.com, mina86@mina86.com, mgorman@suse.de, hughd@google.com, kyungmin.park@samsung.com

On Tue, Sep 04, 2012 at 03:26:24PM +0200, Bartlomiej Zolnierkiewicz wrote:
> From: Marek Szyprowski <m.szyprowski@samsung.com>
> 
> During watermark check we need to decrease available free pages number
> by free CMA pages number because unmovable allocations cannot use pages
> from CMA areas.

This patch could be fold into 5/5.

> 
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Hugh Dickins <hughd@google.com>
> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
>  mm/page_alloc.c | 10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5bb0cda..2166774 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1628,7 +1628,7 @@ static inline bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
>   * of the allocation.
>   */
>  static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> -		      int classzone_idx, int alloc_flags, long free_pages)
> +		      int classzone_idx, int alloc_flags, long free_pages, long free_cma_pages)
>  {
>  	/* free_pages my go negative - that's OK */
>  	long min = mark;
> @@ -1641,7 +1641,7 @@ static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
>  	if (alloc_flags & ALLOC_HARDER)
>  		min -= min / 4;
>  
> -	if (free_pages <= min + lowmem_reserve)
> +	if (free_pages - free_cma_pages <= min + lowmem_reserve)
>  		return false;
>  	for (o = 0; o < order; o++) {
>  		/* At the next order, this order's pages become unavailable */
> @@ -1674,13 +1674,15 @@ bool zone_watermark_ok(struct zone *z, int order, unsigned long mark,
>  		      int classzone_idx, int alloc_flags)
>  {
>  	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
> -					zone_page_state(z, NR_FREE_PAGES));
> +					zone_page_state(z, NR_FREE_PAGES),
> +					zone_page_state(z, NR_FREE_CMA_PAGES));
>  }
>  
>  bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
>  		      int classzone_idx, int alloc_flags)
>  {
>  	long free_pages = zone_page_state(z, NR_FREE_PAGES);
> +	long free_cma_pages = zone_page_state(z, NR_FREE_CMA_PAGES);
>  
>  	if (z->percpu_drift_mark && free_pages < z->percpu_drift_mark)
>  		free_pages = zone_page_state_snapshot(z, NR_FREE_PAGES);
> @@ -1694,7 +1696,7 @@ bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
>  	 */
>  	free_pages -= nr_zone_isolate_freepages(z);
>  	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
> -								free_pages);
> +					free_pages, free_cma_pages);
>  }
>  
>  #ifdef CONFIG_NUMA
> -- 
> 1.7.11.3
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
