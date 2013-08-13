Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 126886B0032
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 21:35:57 -0400 (EDT)
Date: Tue, 13 Aug 2013 10:35:59 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] mm: vmscan: decrease cma pages from nr_reclaimed
Message-ID: <20130813013559.GB3101@bbox>
References: <52092FB5.3060300@intel.com>
 <1376356062-25200-1-git-send-email-haojian.zhuang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1376356062-25200-1-git-send-email-haojian.zhuang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Haojian Zhuang <haojian.zhuang@gmail.com>
Cc: dave.hansen@intel.com, m.szyprowski@samsung.com, akpm@linux-foundation.org, mgorman@suse.de, linux-mm@kvack.org

Hello,

On Tue, Aug 13, 2013 at 09:07:42AM +0800, Haojian Zhuang wrote:
> shrink_page_list() reclaims the pages. But the statistical data may
> be inaccurate since some pages are CMA pages. If kernel needs to
> reclaim unmovable memory (GFP_KERNEL flag), free CMA pages should not
> be counted in nr_reclaimed pages.

Please write description as following as.

1. What's the problem?
2. So what's the user effect?
3. How to fix it?

I will try.

Now, VM reclaims CMA pages although memory pressure happens by kernel
memory request(ex, GFP_KERNEL). The problem is that VM can't allocate
new page from just freed CMA area for kernel memory request so that
reclaiming CMA pages when kernel memory space is short is pointless and
it would reclaim too excessive CMA pages without any progress.

This patch fixes ....

> 
> v2:
> * Remove #ifdef CONFIG_CMA. Use IS_ENABLED() & is_migrate_cma() instead.

But I don't like your approach.

IMHO, better fix is we should filter out it from the beginnig.
Look at isolate_lru_pages with isolate_mode. When we select victim pages,
we shouldn't select CMA pages if memory pressure happens by GFP_KERNEL.
It would avoid unnecessary CPU overhead and reclaiming.

Thanks.

> 
> Signed-off-by: Haojian Zhuang <haojian.zhuang@gmail.com>
> ---
>  mm/vmscan.c | 14 ++++++++++++++
>  1 file changed, 14 insertions(+)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 2cff0d4..414f74f 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -720,6 +720,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  	unsigned long nr_reclaimed = 0;
>  	unsigned long nr_writeback = 0;
>  	unsigned long nr_immediate = 0;
> +	/* Number of pages freed with MIGRATE_CMA type */
> +	unsigned long nr_reclaimed_cma = 0;
> +	int mt = 0;
>  
>  	cond_resched();
>  
> @@ -987,6 +990,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  					 * leave it off the LRU).
>  					 */
>  					nr_reclaimed++;
> +					mt = get_pageblock_migratetype(page);
> +					if (is_migrate_cma(mt))
> +						nr_reclaimed_cma++;
>  					continue;
>  				}
>  			}
> @@ -1005,6 +1011,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		__clear_page_locked(page);
>  free_it:
>  		nr_reclaimed++;
> +		mt = get_pageblock_migratetype(page);
> +		if (is_migrate_cma(mt))
> +			nr_reclaimed_cma++;
>  
>  		/*
>  		 * Is there need to periodically free_page_list? It would
> @@ -1044,6 +1053,11 @@ keep:
>  	*ret_nr_unqueued_dirty += nr_unqueued_dirty;
>  	*ret_nr_writeback += nr_writeback;
>  	*ret_nr_immediate += nr_immediate;
> +	if (IS_ENABLED(CONFIG_CMA)) {
> +		mt = allocflags_to_migratetype(sc->gfp_mask);
> +		if (mt == MIGRATE_UNMOVABLE)
> +			nr_reclaimed -= nr_reclaimed_cma;
> +	}
>  	return nr_reclaimed;
>  }
>  
> -- 
> 1.8.1.2
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
