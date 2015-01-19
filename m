Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 57C396B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 01:55:59 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kq14so36878861pab.12
        for <linux-mm@kvack.org>; Sun, 18 Jan 2015 22:55:59 -0800 (PST)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id pa8si14810294pdb.93.2015.01.18.22.55.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 18 Jan 2015 22:55:57 -0800 (PST)
Received: by mail-pa0-f52.google.com with SMTP id kx10so6304506pab.11
        for <linux-mm@kvack.org>; Sun, 18 Jan 2015 22:55:56 -0800 (PST)
Date: Mon, 19 Jan 2015 15:55:44 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] CMA: treat free cma pages as non-free if not ALLOC_CMA
 on watermark checking
Message-ID: <20150119065544.GA18473@blaptop>
References: <1421569979-2596-1-git-send-email-teawater@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421569979-2596-1-git-send-email-teawater@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <teawater@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, isimatu.yasuaki@jp.fujitsu.com, wangnan0@huawei.com, davidlohr@hp.com, cl@linux.com, rientjes@google.com, sasha.levin@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hui Zhu <zhuhui@xiaomi.com>, Weixing Liu <liuweixing@xiaomi.com>

Hello,

On Sun, Jan 18, 2015 at 04:32:59PM +0800, Hui Zhu wrote:
> From: Hui Zhu <zhuhui@xiaomi.com>
> 
> The original of this patch [1] is part of Joonsoo's CMA patch series.
> I made a patch [2] to fix the issue of this patch.  Joonsoo reminded me
> that this issue affect current kernel too.  So made a new one for upstream.

Recently, we found many problems of CMA and Joonsoo tried to add more
hooks into MM like agressive allocation but I suggested adding new zone
would be more desirable than more hooks in mm fast path in various aspect.
(ie, remove lots of hooks in hot path of MM, don't need reclaim hooks
 for special CMA pages, don't need custom fair allocation for CMA).

Joonsoo is investigating the direction so please wait.
If it turns out we have lots of hurdle to go that way,
this direction(ie, putting more hooks) should be second plan.

Thanks.

> 
> Current code treat free cma pages as non-free if not ALLOC_CMA in the first
> check:
> if (free_pages - free_cma <= min + z->lowmem_reserve[classzone_idx])
> 	return false;
> But in the loop after that, it treat free cma pages as free memory even
> if not ALLOC_CMA.
> So this one substruct free_cma from free_pages before the loop if not
> ALLOC_CMA to treat free cma pages as non-free in the loop.
> 
> But there still have a issue is that CMA memory in each order is part
> of z->free_area[o].nr_free, then the CMA page number of this order is
> substructed twice.  This bug will make __zone_watermark_ok return more false.
> This patch add cma_nr_free to struct free_area that just record the number
> of CMA pages.  And add it back in the order loop to handle the substruct
> twice issue.
> 
> The last issue of this patch should handle is pointed by Joonsoo in [3].
> If pageblock for CMA is isolated, cma_nr_free would be miscalculated.
> This patch add two functions nr_free_inc and nr_free_dec to change the
> values of nr_free and cma_nr_free.  If the migratetype is MIGRATE_ISOLATE,
> they will not change the value of nr_free.
> Change __mod_zone_freepage_state to doesn't record isolated page to
> NR_FREE_PAGES.
> And add code to move_freepages to record the page number that isolated:
> 		if (is_migrate_isolate(migratetype))
> 			nr_free_dec(&zone->free_area[order],
> 				    get_freepage_migratetype(page));
> 		else
> 			nr_free_inc(&zone->free_area[order], migratetype);
> Then the isolate issue is handled.
> 
> This patchset is based on fc7f0dd381720ea5ee5818645f7d0e9dece41cb0.
> 
> [1] https://lkml.org/lkml/2014/5/28/110
> [2] https://lkml.org/lkml/2014/12/25/43
> [3] https://lkml.org/lkml/2015/1/4/220
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
> Signed-off-by: Weixing Liu <liuweixing@xiaomi.com>
> ---
>  include/linux/mmzone.h |  3 +++
>  include/linux/vmstat.h |  4 +++-
>  mm/page_alloc.c        | 59 +++++++++++++++++++++++++++++++++++++++++---------
>  3 files changed, 55 insertions(+), 11 deletions(-)
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
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index 82e7db7..f18ef00 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -6,6 +6,7 @@
>  #include <linux/mm.h>
>  #include <linux/mmzone.h>
>  #include <linux/vm_event_item.h>
> +#include <linux/page-isolation.h>
>  #include <linux/atomic.h>
>  
>  extern int sysctl_stat_interval;
> @@ -280,7 +281,8 @@ static inline void drain_zonestat(struct zone *zone,
>  static inline void __mod_zone_freepage_state(struct zone *zone, int nr_pages,
>  					     int migratetype)
>  {
> -	__mod_zone_page_state(zone, NR_FREE_PAGES, nr_pages);
> +	if (!is_migrate_isolate(migratetype))
> +		__mod_zone_page_state(zone, NR_FREE_PAGES, nr_pages);
>  	if (is_migrate_cma(migratetype))
>  		__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, nr_pages);
>  }
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 7633c50..9a2b6da 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -576,6 +576,28 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
>  	return 0;
>  }
>  
> +static inline void nr_free_inc(struct free_area *area, int migratetype)
> +{
> +	if (!is_migrate_isolate(migratetype))
> +		area->nr_free++;
> +
> +#ifdef CONFIG_CMA
> +	if (is_migrate_cma(migratetype))
> +		area->cma_nr_free++;
> +#endif
> +}
> +
> +static inline void nr_free_dec(struct free_area *area, int migratetype)
> +{
> +	if (!is_migrate_isolate(migratetype))
> +		area->nr_free--;
> +
> +#ifdef CONFIG_CMA
> +	if (is_migrate_cma(migratetype))
> +		area->cma_nr_free--;
> +#endif
> +}
> +
>  /*
>   * Freeing function for a buddy system allocator.
>   *
> @@ -649,7 +671,7 @@ static inline void __free_one_page(struct page *page,
>  			clear_page_guard(zone, buddy, order, migratetype);
>  		} else {
>  			list_del(&buddy->lru);
> -			zone->free_area[order].nr_free--;
> +			nr_free_dec(&zone->free_area[order], migratetype);
>  			rmv_page_order(buddy);
>  		}
>  		combined_idx = buddy_idx & page_idx;
> @@ -682,7 +704,7 @@ static inline void __free_one_page(struct page *page,
>  
>  	list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
>  out:
> -	zone->free_area[order].nr_free++;
> +	nr_free_inc(&zone->free_area[order], migratetype);
>  }
>  
>  static inline int free_pages_check(struct page *page)
> @@ -936,7 +958,7 @@ static inline void expand(struct zone *zone, struct page *page,
>  			continue;
>  		}
>  		list_add(&page[size].lru, &area->free_list[migratetype]);
> -		area->nr_free++;
> +		nr_free_inc(area, migratetype);
>  		set_page_order(&page[size], high);
>  	}
>  }
> @@ -1019,7 +1041,7 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
>  							struct page, lru);
>  		list_del(&page->lru);
>  		rmv_page_order(page);
> -		area->nr_free--;
> +		nr_free_dec(area, migratetype);
>  		expand(zone, page, order, current_order, area, migratetype);
>  		set_freepage_migratetype(page, migratetype);
>  		return page;
> @@ -1089,6 +1111,11 @@ int move_freepages(struct zone *zone,
>  		order = page_order(page);
>  		list_move(&page->lru,
>  			  &zone->free_area[order].free_list[migratetype]);
> +		if (is_migrate_isolate(migratetype))
> +			nr_free_dec(&zone->free_area[order],
> +				    get_freepage_migratetype(page));
> +		else
> +			nr_free_inc(&zone->free_area[order], migratetype);
>  		set_freepage_migratetype(page, migratetype);
>  		page += 1 << order;
>  		pages_moved += 1 << order;
> @@ -1207,7 +1234,7 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
>  
>  			page = list_entry(area->free_list[migratetype].next,
>  					struct page, lru);
> -			area->nr_free--;
> +			nr_free_dec(area, migratetype);
>  
>  			new_type = try_to_steal_freepages(zone, page,
>  							  start_migratetype,
> @@ -1596,7 +1623,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
>  
>  	/* Remove page from free list */
>  	list_del(&page->lru);
> -	zone->free_area[order].nr_free--;
> +	nr_free_dec(&zone->free_area[order], mt);
>  	rmv_page_order(page);
>  
>  	/* Set the pageblock if the isolated page is at least a pageblock */
> @@ -1808,7 +1835,6 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
>  	/* free_pages may go negative - that's OK */
>  	long min = mark;
>  	int o;
> -	long free_cma = 0;
>  
>  	free_pages -= (1 << order) - 1;
>  	if (alloc_flags & ALLOC_HIGH)
> @@ -1818,15 +1844,24 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
>  #ifdef CONFIG_CMA
>  	/* If allocation can't use CMA areas don't use free CMA pages */
>  	if (!(alloc_flags & ALLOC_CMA))
> -		free_cma = zone_page_state(z, NR_FREE_CMA_PAGES);
> +		free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
>  #endif
>  
> -	if (free_pages - free_cma <= min + z->lowmem_reserve[classzone_idx])
> +	if (free_pages <= min + z->lowmem_reserve[classzone_idx])
>  		return false;
>  	for (o = 0; o < order; o++) {
>  		/* At the next order, this order's pages become unavailable */
>  		free_pages -= z->free_area[o].nr_free << o;
>  
> +#ifdef CONFIG_CMA
> +		/* If CMA's page number of this order was substructed as part
> +		   of "zone_page_state(z, NR_FREE_CMA_PAGES)", subtracting
> +		   "z->free_area[o].nr_free << o" substructed CMA's page
> +		   number of this order again.  So add it back.  */
> +		if (!(alloc_flags & ALLOC_CMA)) {
> +			free_pages += z->free_area[o].cma_nr_free << o;
> +#endif
> +
>  		/* Require fewer higher order pages to be free */
>  		min >>= 1;
>  
> @@ -4238,6 +4273,9 @@ static void __meminit zone_init_free_lists(struct zone *zone)
>  	for_each_migratetype_order(order, t) {
>  		INIT_LIST_HEAD(&zone->free_area[order].free_list[t]);
>  		zone->free_area[order].nr_free = 0;
> +#ifdef CONFIG_CMA
> +		zone->free_area[order].cma_nr_free = 0;
> +#endif
>  	}
>  }
>  
> @@ -6609,7 +6647,8 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
>  #endif
>  		list_del(&page->lru);
>  		rmv_page_order(page);
> -		zone->free_area[order].nr_free--;
> +		nr_free_dec(&zone->free_area[order],
> +			    get_pageblock_migratetype(page));
>  		for (i = 0; i < (1 << order); i++)
>  			SetPageReserved((page+i));
>  		pfn += (1 << order);
> -- 
> 1.9.3
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
