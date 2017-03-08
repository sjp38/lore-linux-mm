Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id B18396B038A
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 21:17:29 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id k133so24509213oia.6
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 18:17:29 -0800 (PST)
Received: from dggrg03-dlp.huawei.com ([45.249.212.189])
        by mx.google.com with ESMTPS id g98si2344757iod.6.2017.03.07.18.17.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Mar 2017 18:17:28 -0800 (PST)
Subject: Re: [RFC v2 10/10] mm, page_alloc: introduce MIGRATE_MIXED
 migratetype
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170210172343.30283-11-vbabka@suse.cz>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <2743b3d4-743a-33db-fdbd-fa95edd35611@huawei.com>
Date: Wed, 8 Mar 2017 10:16:44 +0800
MIME-Version: 1.0
In-Reply-To: <20170210172343.30283-11-vbabka@suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, kernel-team@fb.com, Hanjun Guo <guohanjun@huawei.com>

Hi Vlastimil ,

On 2017/2/11 1:23, Vlastimil Babka wrote:
> @@ -1977,7 +1978,7 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
>  	unsigned int current_order = page_order(page);
>  	struct free_area *area;
>  	int free_pages, good_pages;
> -	int old_block_type;
> +	int old_block_type, new_block_type;
>  
>  	/* Take ownership for orders >= pageblock_order */
>  	if (current_order >= pageblock_order) {
> @@ -1991,11 +1992,27 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
>  	if (!whole_block) {
>  		area = &zone->free_area[current_order];
>  		list_move(&page->lru, &area->free_list[start_type]);
> -		return;
> +		free_pages = 1 << current_order;
> +		/* TODO: We didn't scan the block, so be pessimistic */
> +		good_pages = 0;
> +	} else {
> +		free_pages = move_freepages_block(zone, page, start_type,
> +							&good_pages);
> +		/*
> +		 * good_pages is now the number of movable pages, but if we
> +		 * want UNMOVABLE or RECLAIMABLE, we consider all non-movable
> +		 * as good (but we can't fully distinguish them)
> +		 */
> +		if (start_type != MIGRATE_MOVABLE)
> +			good_pages = pageblock_nr_pages - free_pages -
> +								good_pages;
>  	}
>  
>  	free_pages = move_freepages_block(zone, page, start_type,
>  						&good_pages);
It seems this move_freepages_block() should be removed, if we can steal whole block
then just  do it. If not we can check whether we can set it as mixed mt, right?
Please let me know if I miss something..

Thanks
Yisheng Xie

> +
> +	new_block_type = old_block_type = get_pageblock_migratetype(page);
> +
>  	/*
>  	 * good_pages is now the number of movable pages, but if we
>  	 * want UNMOVABLE or RECLAIMABLE allocation, it's more tricky
> @@ -2007,7 +2024,6 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
>  		 * falling back to RECLAIMABLE or vice versa, be conservative
>  		 * as we can't distinguish the exact migratetype.
>  		 */
> -		old_block_type = get_pageblock_migratetype(page);
>  		if (old_block_type == MIGRATE_MOVABLE)
>  			good_pages = pageblock_nr_pages
>  						- free_pages - good_pages;
> @@ -2015,10 +2031,34 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
>  			good_pages = 0;
>  	}
>  
> -	/* Claim the whole block if over half of it is free or good type */
> -	if (free_pages + good_pages >= (1 << (pageblock_order-1)) ||
> -			page_group_by_mobility_disabled)
> -		set_pageblock_migratetype(page, start_type);
> +	if (page_group_by_mobility_disabled) {
> +		new_block_type = start_type;
> +	} else if (free_pages + good_pages >= (1 << (pageblock_order-1))) {
> +		/*
> +		 * Claim the whole block if over half of it is free or good
> +		 * type. The exception is the transition to MIGRATE_MOVABLE
> +		 * where we require it to be fully free so that MIGRATE_MOVABLE
> +		 * pageblocks consist of purely movable pages. So if we steal
> +		 * less than whole pageblock, mark it as MIGRATE_MIXED.
> +		 */
> +		if ((start_type == MIGRATE_MOVABLE) &&
> +				free_pages + good_pages < pageblock_nr_pages)
> +			new_block_type = MIGRATE_MIXED;
> +		else
> +			new_block_type = start_type;
> +	} else {
> +		/*
> +		 * We didn't steal enough to change the block's migratetype.
> +		 * But if we are stealing from a MOVABLE block for a
> +		 * non-MOVABLE allocation, mark the block as MIXED.
> +		 */
> +		if (old_block_type == MIGRATE_MOVABLE
> +					&& start_type != MIGRATE_MOVABLE)
> +			new_block_type = MIGRATE_MIXED;
> +	}
> +
> +	if (new_block_type != old_block_type)
> +		set_pageblock_migratetype(page, new_block_type);
>  }
>  
>  /*
> @@ -2560,16 +2600,18 @@ int __isolate_free_page(struct page *page, unsigned int order)
>  	rmv_page_order(page);
>  
>  	/*
> -	 * Set the pageblock if the isolated page is at least half of a
> -	 * pageblock
> +	 * Set the pageblock's migratetype to MIXED if the isolated page is
> +	 * at least half of a pageblock, MOVABLE if at least whole pageblock
>  	 */
>  	if (order >= pageblock_order - 1) {
>  		struct page *endpage = page + (1 << order) - 1;
> +		int new_mt = (order >= pageblock_order) ?
> +					MIGRATE_MOVABLE : MIGRATE_MIXED;
>  		for (; page < endpage; page += pageblock_nr_pages) {
>  			int mt = get_pageblock_migratetype(page);
> -			if (!is_migrate_isolate(mt) && !is_migrate_cma(mt))
> -				set_pageblock_migratetype(page,
> -							  MIGRATE_MOVABLE);
> +
> +			if (!is_migrate_isolate(mt) && !is_migrate_movable(mt))
> +				set_pageblock_migratetype(page, new_mt);
>  		}
>  	}
>  
> @@ -4252,6 +4294,7 @@ static void show_migration_types(unsigned char type)
>  		[MIGRATE_MOVABLE]	= 'M',
>  		[MIGRATE_RECLAIMABLE]	= 'E',
>  		[MIGRATE_HIGHATOMIC]	= 'H',
> +		[MIGRATE_MIXED]		= 'M',
>  #ifdef CONFIG_CMA
>  		[MIGRATE_CMA]		= 'C',
>  #endif
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
