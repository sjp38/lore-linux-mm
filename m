Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id ADBCF6B00AB
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 18:34:32 -0500 (EST)
Date: Tue, 5 Feb 2013 08:34:30 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: cma: fix accounting of CMA pages placed in high
 memory
Message-ID: <20130204233430.GA2610@blaptop>
References: <1359973626-3900-1-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1359973626-3900-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, kyungmin.park@samsung.com

On Mon, Feb 04, 2013 at 11:27:05AM +0100, Marek Szyprowski wrote:
> The total number of low memory pages is determined as
> totalram_pages - totalhigh_pages, so without this patch all CMA
> pageblocks placed in highmem were accounted to low memory.

So what's the end user effect? With the effect, we have to decide
routing it on stable.

> 
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> ---
>  mm/page_alloc.c |    4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f5bab0a..6415d93 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -773,6 +773,10 @@ void __init init_cma_reserved_pageblock(struct page *page)
>  	set_pageblock_migratetype(page, MIGRATE_CMA);
>  	__free_pages(page, pageblock_order);
>  	totalram_pages += pageblock_nr_pages;
> +#ifdef CONFIG_HIGHMEM

We don't need #ifdef/#endif.

> +	if (PageHighMem(page))
> +		totalhigh_pages += pageblock_nr_pages;
> +#endif
>  }
>  #endif
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
