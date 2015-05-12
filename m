Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 906576B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 03:52:01 -0400 (EDT)
Received: by wgic8 with SMTP id c8so129189594wgi.1
        for <linux-mm@kvack.org>; Tue, 12 May 2015 00:52:01 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i2si1775872wie.61.2015.05.12.00.51.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 12 May 2015 00:51:59 -0700 (PDT)
Message-ID: <5551B11C.4080000@suse.cz>
Date: Tue, 12 May 2015 09:51:56 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm/page_alloc: don't break highest order freepage
 if steal
References: <1430119421-13536-1-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1430119421-13536-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On 04/27/2015 09:23 AM, Joonsoo Kim wrote:
> When we steal whole pageblock, we don't need to break highest order
> freepage. Perhaps, there is small order freepage so we can use it.
>
> This also gives us some code size reduction because expand() which
> is used in __rmqueue_fallback() and inlined into __rmqueue_fallback()
> is removed.
>
>     text    data     bss     dec     hex filename
>    37413    1440     624   39477    9a35 mm/page_alloc.o
>    37249    1440     624   39313    9991 mm/page_alloc.o
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>   mm/page_alloc.c | 40 +++++++++++++++++++++-------------------
>   1 file changed, 21 insertions(+), 19 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ed0f1c6..044f16c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1239,14 +1239,14 @@ int find_suitable_fallback(struct free_area *area, unsigned int order,
>   }
>
>   /* Remove an element from the buddy allocator from the fallback list */

This is no longer accurate description.

> -static inline struct page *
> +static inline bool
>   __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
>   {
>   	struct free_area *area;
>   	unsigned int current_order;
>   	struct page *page;
>   	int fallback_mt;
> -	bool can_steal;
> +	bool can_steal_pageblock;
>
>   	/* Find the largest possible block of pages in the other list */
>   	for (current_order = MAX_ORDER-1;
> @@ -1254,26 +1254,24 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
>   				--current_order) {
>   		area = &(zone->free_area[current_order]);
>   		fallback_mt = find_suitable_fallback(area, current_order,
> -				start_migratetype, false, &can_steal);
> +						start_migratetype, false,
> +						&can_steal_pageblock);
>   		if (fallback_mt == -1)
>   			continue;
>
>   		page = list_entry(area->free_list[fallback_mt].next,
>   						struct page, lru);

> -		if (can_steal)
> +		BUG_ON(!page);

Please no new BUG_ON. VM_BUG_ON maybe for debugging, otherwise just let 
it panic on null pointer exception accessing page->lru later on.

> +
> +		if (can_steal_pageblock)
>   			steal_suitable_fallback(zone, page, start_migratetype);
>
> -		/* Remove the page from the freelists */
> -		area->nr_free--;
> -		list_del(&page->lru);
> -		rmv_page_order(page);
> +		list_move(&page->lru, &area->free_list[start_migratetype]);

This list_move is redundant if we are stealing whole pageblock, right? 
Just put it in an else of the if above, and explain in comment?


> -		expand(zone, page, order, current_order, area,
> -					start_migratetype);
>   		/*
>   		 * The freepage_migratetype may differ from pageblock's
>   		 * migratetype depending on the decisions in
> -		 * try_to_steal_freepages(). This is OK as long as it
> +		 * find_suitable_fallback(). This is OK as long as it
>   		 * does not differ for MIGRATE_CMA pageblocks. For CMA
>   		 * we need to make sure unallocated pages flushed from
>   		 * pcp lists are returned to the correct freelist.

The whole thing with set_freepage_migratetype(page, start_migratetype); 
below this comment is now redundant, as rmqueue_smallest will do it too.
The comment itself became outdated and misplaced too. I guess 
MIGRATE_CMA is now handled just by the fact that is is not set as 
fallback in the fallbacks array?

> @@ -1283,10 +1281,10 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
>   		trace_mm_page_alloc_extfrag(page, order, current_order,
>   			start_migratetype, fallback_mt);
>
> -		return page;
> +		return true;
>   	}
>
> -	return NULL;
> +	return false;
>   }
>
>   /*
> @@ -1297,28 +1295,32 @@ static struct page *__rmqueue(struct zone *zone, unsigned int order,
>   						int migratetype)
>   {
>   	struct page *page;
> +	bool steal_fallback;
>
> -retry_reserve:
> +retry:
>   	page = __rmqueue_smallest(zone, order, migratetype);
>
>   	if (unlikely(!page) && migratetype != MIGRATE_RESERVE) {
>   		if (migratetype == MIGRATE_MOVABLE)
>   			page = __rmqueue_cma_fallback(zone, order);
>
> -		if (!page)
> -			page = __rmqueue_fallback(zone, order, migratetype);
> +		if (page)
> +			goto out;
> +
> +		steal_fallback = __rmqueue_fallback(zone, order, migratetype);
>
>   		/*
>   		 * Use MIGRATE_RESERVE rather than fail an allocation. goto
>   		 * is used because __rmqueue_smallest is an inline function
>   		 * and we want just one call site
>   		 */
> -		if (!page) {
> +		if (!steal_fallback)
>   			migratetype = MIGRATE_RESERVE;
> -			goto retry_reserve;
> -		}
> +
> +		goto retry;
>   	}
>
> +out:
>   	trace_mm_page_alloc_zone_locked(page, order, migratetype);
>   	return page;
>   }
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
