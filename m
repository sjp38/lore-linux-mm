Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id C40A56B0032
	for <linux-mm@kvack.org>; Sun,  4 Jan 2015 21:32:17 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id z10so27339946pdj.0
        for <linux-mm@kvack.org>; Sun, 04 Jan 2015 18:32:17 -0800 (PST)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id ie5si55776884pbc.186.2015.01.04.18.32.14
        for <linux-mm@kvack.org>;
        Sun, 04 Jan 2015 18:32:16 -0800 (PST)
Date: Mon, 5 Jan 2015 11:32:11 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] CMA: Fix CMA's page number is substructed twice in
 __zone_watermark_ok
Message-ID: <20150105023211.GA3534@js1304-P5Q-DELUXE>
References: <1419934645-20106-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1419934645-20106-1-git-send-email-zhuhui@xiaomi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <zhuhui@xiaomi.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com, vbabka@suse.cz, isimatu.yasuaki@jp.fujitsu.com, rientjes@google.com, sasha.levin@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, teawater@gmail.com, Weixing Liu <liuweixing@xiaomi.com>

Hello,

On Tue, Dec 30, 2014 at 06:17:25PM +0800, Hui Zhu wrote:
> The original of this patch [1] is used to fix the issue in Joonsoo's CMA patch
> "CMA: always treat free cma pages as non-free on watermark checking" [2].
> 
> Joonsoo reminded me that this issue affect current kernel too.  So made a new
> one for upstream.
> 
> Function __zone_watermark_ok substruct CMA pages number from free_pages
> if system allocation can't use CMA areas:
> 	/* If allocation can't use CMA areas don't use free CMA pages */
> 	if (!(alloc_flags & ALLOC_CMA))
> 		free_cma = zone_page_state(z, NR_FREE_CMA_PAGES);
> 
> But after this part of code
> 	for (o = 0; o < order; o++) {
> 		/* At the next order, this order's pages become unavailable */
> 		free_pages -= z->free_area[o].nr_free << o;
> CMA memory in each order is part of z->free_area[o].nr_free, then the CMA
> page number of this order is substructed twice.  This bug will make
> __zone_watermark_ok return more false.
> 
> This patch add cma_free_area to struct free_area that just record the number
> of CMA pages.  And add it back in the order loop to handle the substruct
> twice issue.
> 
> [1] https://lkml.org/lkml/2014/12/25/43
> [2] https://lkml.org/lkml/2014/5/28/110
> 
> Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
> Signed-off-by: Weixing Liu <liuweixing@xiaomi.com>
> ---
>  include/linux/mmzone.h |  3 +++
>  mm/page_alloc.c        | 22 ++++++++++++++++++++++
>  2 files changed, 25 insertions(+)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 2f0856d..094476b 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -92,6 +92,9 @@ static inline int get_pfnblock_migratetype(struct page *page, unsigned long pfn)
>  struct free_area {
>  	struct list_head	free_list[MIGRATE_TYPES];
>  	unsigned long		nr_free;
> +#ifdef CONFIG_CMA
> +	unsigned long		cma_nr_free;
> +#endif
>  };
>  
>  struct pglist_data;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 7633c50..026cf27 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -650,6 +650,8 @@ static inline void __free_one_page(struct page *page,
>  		} else {
>  			list_del(&buddy->lru);
>  			zone->free_area[order].nr_free--;
> +			if (is_migrate_cma(migratetype))
> +				zone->free_area[order].cma_nr_free--;

cma_nr_free is defined only if CONFIG_CMA. If !CONFIG_CMA, this would
cause build failure. How about making new function to manipulate
nr_free, cma_nr_free and use it on each sites?

And, if pageblock for CMA is isolated, cma_nr_free would be
miscalculated. Think about following situation.

One freepage (A) in CMA.
zone->free_area[0].nr_free = 1
zone->free_area[0].cma_nr_free = 1
zone->free_area[1].nr_free = 0
zone->free_area[1].cma_nr_free = 0


Isolate the pageblock having (A)
__free_one_page() with buddy page of (A)

Intermediate state of free_area after above logic
zone->free_area[0].nr_free = 0
zone->free_area[0].cma_nr_free = 1
zone->free_area[1].nr_free = 0
zone->free_area[1].cma_nr_free = 0

Final state of free_area after merging
zone->free_area[0].nr_free = 0
zone->free_area[0].cma_nr_free = 1
zone->free_area[1].nr_free = 1
zone->free_area[1].cma_nr_free = 0

>  			rmv_page_order(buddy);
>  		}
>  		combined_idx = buddy_idx & page_idx;
> @@ -683,6 +685,8 @@ static inline void __free_one_page(struct page *page,
>  	list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
>  out:
>  	zone->free_area[order].nr_free++;
> +	if (is_migrate_cma(migratetype))
> +		zone->free_area[order].cma_nr_free++;
>  }
>  
>  static inline int free_pages_check(struct page *page)
> @@ -937,6 +941,8 @@ static inline void expand(struct zone *zone, struct page *page,
>  		}
>  		list_add(&page[size].lru, &area->free_list[migratetype]);
>  		area->nr_free++;
> +		if (is_migrate_cma(migratetype))
> +			area->cma_nr_free++;
>  		set_page_order(&page[size], high);
>  	}
>  }
> @@ -1020,6 +1026,8 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
>  		list_del(&page->lru);
>  		rmv_page_order(page);
>  		area->nr_free--;
> +		if (is_migrate_cma(migratetype))
> +			area->cma_nr_free--;
>  		expand(zone, page, order, current_order, area, migratetype);
>  		set_freepage_migratetype(page, migratetype);
>  		return page;
> @@ -1208,6 +1216,8 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
>  			page = list_entry(area->free_list[migratetype].next,
>  					struct page, lru);
>  			area->nr_free--;
> +			if (is_migrate_cma(migratetype))
> +				area->cma_nr_free--;
>  
>  			new_type = try_to_steal_freepages(zone, page,
>  							  start_migratetype,
> @@ -1597,6 +1607,8 @@ int __isolate_free_page(struct page *page, unsigned int order)
>  	/* Remove page from free list */
>  	list_del(&page->lru);
>  	zone->free_area[order].nr_free--;
> +	if (is_migrate_cma(mt))
> +		zone->free_area[order].cma_nr_free--;
>  	rmv_page_order(page);

When we do cma_alloc(), pageblock migratetype is MIGRATE_ISOLATE and
this would cause miscalculation. Maybe, __offline_isolated_pages() has
same problem.

>  
>  	/* Set the pageblock if the isolated page is at least a pageblock */
> @@ -1827,6 +1839,13 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
>  		/* At the next order, this order's pages become unavailable */
>  		free_pages -= z->free_area[o].nr_free << o;
>  
> +		/* If CMA's page number of this order was substructed as part
> +		   of "zone_page_state(z, NR_FREE_CMA_PAGES)", subtracting
> +		   "z->free_area[o].nr_free << o" substructed CMA's page
> +		   number of this order again.  So add it back.  */
> +		if (IS_ENABLED(CONFIG_CMA) && free_cma)
> +			free_pages += z->free_area[o].cma_nr_free << o;
> +

free_pages isn't subtracted yet.
See following code snippet.

        if (free_pages - free_cma <= min + z->lowmem_reserve[classzone_idx])
                                return false;

So, __zone_watermark_ok() should be changed like as following.

        free_pages -= free_cma;
        if (free_pages <= min + z->lowmem_reserve[classzone_idx])
                return false;

        In the loop
        	if (IS_ENABLED(CONFIG_CMA) && free_cma)
        	        free_pages += z->free_area[o].cma_nr_free << o;

Thanks.

>  		/* Require fewer higher order pages to be free */
>  		min >>= 1;
>  
> @@ -4238,6 +4257,7 @@ static void __meminit zone_init_free_lists(struct zone *zone)
>  	for_each_migratetype_order(order, t) {
>  		INIT_LIST_HEAD(&zone->free_area[order].free_list[t]);
>  		zone->free_area[order].nr_free = 0;
> +		zone->free_area[order].cma_nr_free = 0;
>  	}
>  }
>  
> @@ -6610,6 +6630,8 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
>  		list_del(&page->lru);
>  		rmv_page_order(page);
>  		zone->free_area[order].nr_free--;
> +		if (is_migrate_cma(get_pageblock_migratetype(page)))
> +			zone->free_area[order].cma_nr_free--;
>  		for (i = 0; i < (1 << order); i++)
>  			SetPageReserved((page+i));
>  		pfn += (1 << order);
> -- 
> 1.9.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
