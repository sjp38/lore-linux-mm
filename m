Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 02A156B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 04:59:54 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id l15so15343324wiw.4
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 01:59:53 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id eb1si22333899wic.94.2015.02.02.01.59.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Feb 2015 01:59:52 -0800 (PST)
Message-ID: <54CF4A95.4090504@suse.cz>
Date: Mon, 02 Feb 2015 10:59:49 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 2/3] mm/page_alloc: factor out fallback freepage
 checking
References: <1422861348-5117-1-git-send-email-iamjoonsoo.kim@lge.com> <1422861348-5117-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1422861348-5117-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 02/02/2015 08:15 AM, Joonsoo Kim wrote:
> This is preparation step to use page allocator's anti fragmentation logic
> in compaction. This patch just separates fallback freepage checking part
> from fallback freepage management part. Therefore, there is no functional
> change.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/page_alloc.c | 128 +++++++++++++++++++++++++++++++++-----------------------
>  1 file changed, 76 insertions(+), 52 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index e64b260..6cb18f8 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1142,14 +1142,26 @@ static void change_pageblock_range(struct page *pageblock_page,
>   * as fragmentation caused by those allocations polluting movable pageblocks
>   * is worse than movable allocations stealing from unmovable and reclaimable
>   * pageblocks.
> - *
> - * If we claim more than half of the pageblock, change pageblock's migratetype
> - * as well.
>   */
> -static void try_to_steal_freepages(struct zone *zone, struct page *page,
> -				  int start_type, int fallback_type)
> +static bool can_steal_fallback(unsigned int order, int start_mt)
> +{
> +	if (order >= pageblock_order)
> +		return true;
> +
> +	if (order >= pageblock_order / 2 ||
> +		start_mt == MIGRATE_RECLAIMABLE ||
> +		start_mt == MIGRATE_UNMOVABLE ||
> +		page_group_by_mobility_disabled)
> +		return true;
> +
> +	return false;
> +}
> +
> +static void steal_suitable_fallback(struct zone *zone, struct page *page,
> +							  int start_type)

Some comment about the function please?

>  {
>  	int current_order = page_order(page);
> +	int pages;
>  
>  	/* Take ownership for orders >= pageblock_order */
>  	if (current_order >= pageblock_order) {
> @@ -1157,19 +1169,39 @@ static void try_to_steal_freepages(struct zone *zone, struct page *page,
>  		return;
>  	}
>  
> -	if (current_order >= pageblock_order / 2 ||
> -	    start_type == MIGRATE_RECLAIMABLE ||
> -	    start_type == MIGRATE_UNMOVABLE ||
> -	    page_group_by_mobility_disabled) {
> -		int pages;
> +	pages = move_freepages_block(zone, page, start_type);
>  
> -		pages = move_freepages_block(zone, page, start_type);
> +	/* Claim the whole block if over half of it is free */
> +	if (pages >= (1 << (pageblock_order-1)) ||
> +			page_group_by_mobility_disabled)
> +		set_pageblock_migratetype(page, start_type);
> +}
>  
> -		/* Claim the whole block if over half of it is free */
> -		if (pages >= (1 << (pageblock_order-1)) ||
> -				page_group_by_mobility_disabled)
> -			set_pageblock_migratetype(page, start_type);
> +static int find_suitable_fallback(struct free_area *area, unsigned int order,
> +					int migratetype, bool *can_steal)

Same here.

> +{
> +	int i;
> +	int fallback_mt;
> +
> +	if (area->nr_free == 0)
> +		return -1;
> +
> +	*can_steal = false;
> +	for (i = 0;; i++) {
> +		fallback_mt = fallbacks[migratetype][i];
> +		if (fallback_mt == MIGRATE_RESERVE)
> +			break;
> +
> +		if (list_empty(&area->free_list[fallback_mt]))
> +			continue;
> +
> +		if (can_steal_fallback(order, migratetype))
> +			*can_steal = true;
> +
> +		return i;

You want to return fallback_mt, not 'i', no?

>  	}
> +
> +	return -1;
>  }
>  
>  /* Remove an element from the buddy allocator from the fallback list */
> @@ -1179,53 +1211,45 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
>  	struct free_area *area;
>  	unsigned int current_order;
>  	struct page *page;
> +	int fallback_mt;
> +	bool can_steal;
>  
>  	/* Find the largest possible block of pages in the other list */
>  	for (current_order = MAX_ORDER-1;
>  				current_order >= order && current_order <= MAX_ORDER-1;
>  				--current_order) {
> -		int i;
> -		for (i = 0;; i++) {
> -			int migratetype = fallbacks[start_migratetype][i];
> -			int buddy_type = start_migratetype;
> -
> -			/* MIGRATE_RESERVE handled later if necessary */
> -			if (migratetype == MIGRATE_RESERVE)
> -				break;
> -
> -			area = &(zone->free_area[current_order]);
> -			if (list_empty(&area->free_list[migratetype]))
> -				continue;
> -
> -			page = list_entry(area->free_list[migratetype].next,
> -					struct page, lru);
> -			area->nr_free--;
> +		area = &(zone->free_area[current_order]);
> +		fallback_mt = find_suitable_fallback(area, current_order,
> +				start_migratetype, &can_steal);
> +		if (fallback_mt == -1)
> +			continue;
>  
> -			try_to_steal_freepages(zone, page, start_migratetype,
> -								migratetype);
> +		page = list_entry(area->free_list[fallback_mt].next,
> +						struct page, lru);
> +		if (can_steal)
> +			steal_suitable_fallback(zone, page, start_migratetype);
>  
> -			/* Remove the page from the freelists */
> -			list_del(&page->lru);
> -			rmv_page_order(page);
> -
> -			expand(zone, page, order, current_order, area,
> -					buddy_type);
> +		/* Remove the page from the freelists */
> +		area->nr_free--;
> +		list_del(&page->lru);
> +		rmv_page_order(page);
>  
> -			/*
> -			 * The freepage_migratetype may differ from pageblock's
> -			 * migratetype depending on the decisions in
> -			 * try_to_steal_freepages(). This is OK as long as it
> -			 * does not differ for MIGRATE_CMA pageblocks. For CMA
> -			 * we need to make sure unallocated pages flushed from
> -			 * pcp lists are returned to the correct freelist.
> -			 */
> -			set_freepage_migratetype(page, buddy_type);
> +		expand(zone, page, order, current_order, area,
> +					start_migratetype);
> +		/*
> +		 * The freepage_migratetype may differ from pageblock's
> +		 * migratetype depending on the decisions in
> +		 * try_to_steal_freepages(). This is OK as long as it
> +		 * does not differ for MIGRATE_CMA pageblocks. For CMA
> +		 * we need to make sure unallocated pages flushed from
> +		 * pcp lists are returned to the correct freelist.
> +		 */
> +		set_freepage_migratetype(page, start_migratetype);
>  
> -			trace_mm_page_alloc_extfrag(page, order, current_order,
> -				start_migratetype, migratetype);
> +		trace_mm_page_alloc_extfrag(page, order, current_order,
> +			start_migratetype, fallback_mt);
>  
> -			return page;
> -		}
> +		return page;
>  	}
>  
>  	return NULL;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
