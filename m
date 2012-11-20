Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 7F2AE6B006C
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 19:01:35 -0500 (EST)
Date: Tue, 20 Nov 2012 09:01:37 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: cma: allocate pages from CMA if NR_FREE_PAGES
 approaches low water mark
Message-ID: <20121120000137.GC447@bbox>
References: <1352710782-25425-1-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1352710782-25425-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

Hi Marek,

On Mon, Nov 12, 2012 at 09:59:42AM +0100, Marek Szyprowski wrote:
> It has been observed that system tends to keep a lot of CMA free pages
> even in very high memory pressure use cases. The CMA fallback for movable

CMA free pages are just fallback for movable pages so if user requires many
user pages, it ends up consuming cma free pages after out of movable pages.
What do you mean that system tend to keep free pages even in very
high memory pressure?

> pages is used very rarely, only when system is completely pruned from
> MOVABLE pages, what usually means that the out-of-memory even will be
> triggered very soon. To avoid such situation and make better use of CMA

Why does OOM is triggered very soon if movable pages are burned out while
there are many cma pages?

It seems I can't understand your point quitely.
Please make your problem clear for silly me to understand clearly.

Thanks.

> pages, a heuristics is introduced which turns on CMA fallback for movable
> pages when the real number of free pages (excluding CMA free pages)
> approaches low water mark.
> 
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Reviewed-by: Kyungmin Park <kyungmin.park@samsung.com>
> CC: Michal Nazarewicz <mina86@mina86.com>
> ---
>  mm/page_alloc.c |    9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index fcb9719..90b51f3 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1076,6 +1076,15 @@ static struct page *__rmqueue(struct zone *zone, unsigned int order,
>  {
>  	struct page *page;
>  
> +#ifdef CONFIG_CMA
> +	unsigned long nr_free = zone_page_state(zone, NR_FREE_PAGES);
> +	unsigned long nr_cma_free = zone_page_state(zone, NR_FREE_CMA_PAGES);
> +
> +	if (migratetype == MIGRATE_MOVABLE && nr_cma_free &&
> +	    nr_free - nr_cma_free < 2 * low_wmark_pages(zone))
> +		migratetype = MIGRATE_CMA;
> +#endif /* CONFIG_CMA */
> +
>  retry_reserve:
>  	page = __rmqueue_smallest(zone, order, migratetype);
>  
> -- 
> 1.7.9.5
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
