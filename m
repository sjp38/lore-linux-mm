Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 353196B00A1
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 17:58:50 -0500 (EST)
Date: Wed, 14 Nov 2012 14:58:48 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: cma: allocate pages from CMA if NR_FREE_PAGES
 approaches low water mark
Message-Id: <20121114145848.8224e8b0.akpm@linux-foundation.org>
In-Reply-To: <1352710782-25425-1-git-send-email-m.szyprowski@samsung.com>
References: <1352710782-25425-1-git-send-email-m.szyprowski@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

On Mon, 12 Nov 2012 09:59:42 +0100
Marek Szyprowski <m.szyprowski@samsung.com> wrote:

> It has been observed that system tends to keep a lot of CMA free pages
> even in very high memory pressure use cases. The CMA fallback for movable
> pages is used very rarely, only when system is completely pruned from
> MOVABLE pages, what usually means that the out-of-memory even will be
> triggered very soon. To avoid such situation and make better use of CMA
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

erk, this is right on the page allocator hotpath.  Bad.

At the very least, we could code it so it is not quite so dreadfully
inefficient:

	if (migratetype == MIGRATE_MOVABLE) {
		unsigned long nr_cma_free;

		nr_cma_free = zone_page_state(zone, NR_FREE_CMA_PAGES);
		if (nr_cma_free) {
			unsigned long nr_free;

			nr_free = zone_page_state(zone, NR_FREE_PAGES);

			if (nr_free - nr_cma_free < 2 * low_wmark_pages(zone))
				migratetype = MIGRATE_CMA;
		}
	}

but it still looks pretty bad.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
