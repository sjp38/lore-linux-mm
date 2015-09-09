Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8BDDC6B0255
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 13:57:02 -0400 (EDT)
Received: by qkfq186 with SMTP id q186so7957758qkf.1
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 10:57:02 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u71si9259657qku.50.2015.09.09.10.57.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Sep 2015 10:57:01 -0700 (PDT)
Subject: Re: [PATCH/RFC] mm: do not regard CMA pages as free on watermark
 check
References: <BLU436-SMTP171766343879051ED4CED0A2520@phx.gbl>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <55F072EA.4000703@redhat.com>
Date: Wed, 9 Sep 2015 10:56:58 -0700
MIME-Version: 1.0
In-Reply-To: <BLU436-SMTP171766343879051ED4CED0A2520@phx.gbl>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vwool@hotmail.com>, linux-kernel@vger.kernel.org
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

(cc-ing linux-mm)
On 09/09/2015 07:44 AM, Vitaly Wool wrote:
> __zone_watermark_ok() does not corrrectly take high-order
> CMA pageblocks into account: high-order CMA blocks are not
> removed from the watermark check. Moreover, CMA pageblocks
> may suddenly vanish through CMA allocation, so let's not
> regard these pages as free in __zone_watermark_ok().
>
> This patch also adds some primitive testing for the method
> implemented which has proven that it works as it should.
>

The choice to include CMA as part of watermarks was pretty deliberate.
Do you have a description of the problem you are facing with
the watermark code as is? Any performance numbers?

> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
> ---
>   include/linux/mmzone.h |  1 +
>   mm/page_alloc.c        | 56 +++++++++++++++++++++++++++++++++++++++++++++-----
>   mm/page_isolation.c    |  2 +-
>   3 files changed, 53 insertions(+), 6 deletions(-)
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index ac00e20..73268f5 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -92,6 +92,7 @@ static inline int get_pfnblock_migratetype(struct page *page, unsigned long pfn)
>   struct free_area {
>   	struct list_head	free_list[MIGRATE_TYPES];
>   	unsigned long		nr_free;
> +	unsigned long		nr_free_cma;
>   };
>
>   struct pglist_data;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5b5240b..69fbc93 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -672,6 +672,8 @@ static inline void __free_one_page(struct page *page,
>   		} else {
>   			list_del(&buddy->lru);
>   			zone->free_area[order].nr_free--;
> +			if (is_migrate_cma(migratetype))
> +				zone->free_area[order].nr_free_cma--;
>   			rmv_page_order(buddy);
>   		}
>   		combined_idx = buddy_idx & page_idx;
> @@ -705,6 +707,8 @@ static inline void __free_one_page(struct page *page,
>   	list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
>   out:
>   	zone->free_area[order].nr_free++;
> +	if (is_migrate_cma(migratetype))
> +		zone->free_area[order].nr_free_cma++;
>   }
>
>   static inline int free_pages_check(struct page *page)
> @@ -1278,6 +1282,8 @@ static inline void expand(struct zone *zone, struct page *page,
>   		}
>   		list_add(&page[size].lru, &area->free_list[migratetype]);
>   		area->nr_free++;
> +		if (is_migrate_cma(migratetype))
> +			area->nr_free_cma++;
>   		set_page_order(&page[size], high);
>   	}
>   }
> @@ -1379,6 +1385,8 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
>   		list_del(&page->lru);
>   		rmv_page_order(page);
>   		area->nr_free--;
> +		if (is_migrate_cma(migratetype))
> +			area->nr_free_cma--;
>   		expand(zone, page, order, current_order, area, migratetype);
>   		set_freepage_migratetype(page, migratetype);
>   		return page;
> @@ -1428,6 +1436,7 @@ int move_freepages(struct zone *zone,
>   	struct page *page;
>   	unsigned long order;
>   	int pages_moved = 0;
> +	int mt;
>
>   #ifndef CONFIG_HOLES_IN_ZONE
>   	/*
> @@ -1457,7 +1466,12 @@ int move_freepages(struct zone *zone,
>   		order = page_order(page);
>   		list_move(&page->lru,
>   			  &zone->free_area[order].free_list[migratetype]);
> +		mt = get_pageblock_migratetype(page);
> +		if (is_migrate_cma(mt))
> +			zone->free_area[order].nr_free_cma--;
>   		set_freepage_migratetype(page, migratetype);
> +		if (is_migrate_cma(migratetype))
> +			zone->free_area[order].nr_free_cma++;
>   		page += 1 << order;
>   		pages_moved += 1 << order;
>   	}
> @@ -1621,6 +1635,8 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
>
>   		/* Remove the page from the freelists */
>   		area->nr_free--;
> +		if (unlikely(is_migrate_cma(start_migratetype)))
> +			area->nr_free_cma--;
>   		list_del(&page->lru);
>   		rmv_page_order(page);
>
> @@ -2012,6 +2028,8 @@ int __isolate_free_page(struct page *page, unsigned int order)
>   	/* Remove page from free list */
>   	list_del(&page->lru);
>   	zone->free_area[order].nr_free--;
> +	if (is_migrate_cma(mt))
> +		zone->free_area[order].nr_free_cma--;
>   	rmv_page_order(page);
>
>   	set_page_owner(page, order, __GFP_MOVABLE);
> @@ -2220,7 +2238,6 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
>   	/* free_pages may go negative - that's OK */
>   	long min = mark;
>   	int o;
> -	long free_cma = 0;
>
>   	free_pages -= (1 << order) - 1;
>   	if (alloc_flags & ALLOC_HIGH)
> @@ -2228,17 +2245,43 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
>   	if (alloc_flags & ALLOC_HARDER)
>   		min -= min / 4;
>   #ifdef CONFIG_CMA
> -	/* If allocation can't use CMA areas don't use free CMA pages */
> +	/*
> +	 * We don't want to regard the pages on CMA region as free
> +	 * on watermark checking, since they cannot be used for
> +	 * unmovable/reclaimable allocation and they can suddenly
> +	 * vanish through CMA allocation
> +	 */
>   	if (!(alloc_flags & ALLOC_CMA))
> -		free_cma = zone_page_state(z, NR_FREE_CMA_PAGES);
> +		free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
> +#ifdef CONFIG_DEBUG_PAGEALLOC
> +	{
> +		long nr_free_cma;
> +		for (o = 0, nr_free_cma = 0; o < MAX_ORDER; o++)
> +			nr_free_cma += z->free_area[o].nr_free_cma << o;
> +
> +		/* nr_free_cma is a bit more realtime than zone_page_state
> +		 * and may thus differ from it a little, and it's ok
> +		 */
> +		if (abs(nr_free_cma -
> +				zone_page_state(z, NR_FREE_CMA_PAGES)) > 256)
> +			pr_info_ratelimited("%s: nr_free_cma %ld instead of %ld\n",
> +					__func__,
> +					nr_free_cma,
> +					zone_page_state(z, NR_FREE_CMA_PAGES));
> +	}
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
