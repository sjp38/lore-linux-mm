Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DCBF46B0038
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 08:30:10 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f193so8851255wmg.0
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 05:30:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b83si2865069wmh.116.2016.10.07.05.30.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 07 Oct 2016 05:30:09 -0700 (PDT)
Subject: Re: [PATCH 1/4] mm: adjust reserved highatomic count
References: <1475819136-24358-1-git-send-email-minchan@kernel.org>
 <1475819136-24358-2-git-send-email-minchan@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7ac7c0d8-4b7b-e362-08e7-6d62ee20f4c3@suse.cz>
Date: Fri, 7 Oct 2016 14:30:04 +0200
MIME-Version: 1.0
In-Reply-To: <1475819136-24358-2-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>

On 10/07/2016 07:45 AM, Minchan Kim wrote:
> In page freeing path, migratetype is racy so that a highorderatomic
> page could free into non-highorderatomic free list.

Yes. If page from a pageblock went to a pcplist before that pageblock 
was reserved as highatomic, free_pcppages_bulk() will misplace it.

> If that page
> is allocated, VM can change the pageblock from higorderatomic to
> something.

More specifically, steal_suitable_fallback(). Yes.

> In that case, we should adjust nr_reserved_highatomic.
> Otherwise, VM cannot reserve highorderatomic pageblocks any more
> although it doesn't reach 1% limit. It means highorder atomic
> allocation failure would be higher.
>
> So, this patch decreases the account as well as migratetype
> if it was MIGRATE_HIGHATOMIC.
>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Hm wouldn't it be simpler just to prevent the pageblock's migratetype to 
be changed if it's highatomic? Possibly also not do 
move_freepages_block() in that case. Most accurate would be to put such 
misplaced page on the proper freelist and retry the fallback, but that 
might be overkill.

> ---
>  mm/page_alloc.c | 44 ++++++++++++++++++++++++++++++++++++++------
>  1 file changed, 38 insertions(+), 6 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 55ad0229ebf3..e7cbb3cc22fa 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -282,6 +282,9 @@ EXPORT_SYMBOL(nr_node_ids);
>  EXPORT_SYMBOL(nr_online_nodes);
>  #endif
>
> +static void dec_highatomic_pageblock(struct zone *zone, struct page *page,
> +					int migratetype);
> +
>  int page_group_by_mobility_disabled __read_mostly;
>
>  #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
> @@ -1935,7 +1938,14 @@ static void change_pageblock_range(struct page *pageblock_page,
>  	int nr_pageblocks = 1 << (start_order - pageblock_order);
>
>  	while (nr_pageblocks--) {
> -		set_pageblock_migratetype(pageblock_page, migratetype);
> +		if (get_pageblock_migratetype(pageblock_page) !=
> +			MIGRATE_HIGHATOMIC)
> +			set_pageblock_migratetype(pageblock_page,
> +							migratetype);
> +		else
> +			dec_highatomic_pageblock(page_zone(pageblock_page),
> +							pageblock_page,
> +							migratetype);
>  		pageblock_page += pageblock_nr_pages;
>  	}
>  }
> @@ -1996,8 +2006,14 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
>
>  	/* Claim the whole block if over half of it is free */
>  	if (pages >= (1 << (pageblock_order-1)) ||
> -			page_group_by_mobility_disabled)
> -		set_pageblock_migratetype(page, start_type);
> +			page_group_by_mobility_disabled) {
> +		int mt = get_pageblock_migratetype(page);
> +
> +		if (mt != MIGRATE_HIGHATOMIC)
> +			set_pageblock_migratetype(page, start_type);
> +		else
> +			dec_highatomic_pageblock(zone, page, start_type);
> +	}
>  }
>
>  /*
> @@ -2037,6 +2053,17 @@ int find_suitable_fallback(struct free_area *area, unsigned int order,
>  	return -1;
>  }
>
> +static void dec_highatomic_pageblock(struct zone *zone, struct page *page,
> +					int migratetype)
> +{
> +	if (zone->nr_reserved_highatomic <= pageblock_nr_pages)
> +		return;
> +
> +	zone->nr_reserved_highatomic -= min(pageblock_nr_pages,
> +					zone->nr_reserved_highatomic);
> +	set_pageblock_migratetype(page, migratetype);
> +}
> +
>  /*
>   * Reserve a pageblock for exclusive use of high-order atomic allocations if
>   * there are no empty page blocks that contain a page with a suitable order
> @@ -2555,9 +2582,14 @@ int __isolate_free_page(struct page *page, unsigned int order)
>  		struct page *endpage = page + (1 << order) - 1;
>  		for (; page < endpage; page += pageblock_nr_pages) {
>  			int mt = get_pageblock_migratetype(page);
> -			if (!is_migrate_isolate(mt) && !is_migrate_cma(mt))
> -				set_pageblock_migratetype(page,
> -							  MIGRATE_MOVABLE);
> +			if (!is_migrate_isolate(mt) && !is_migrate_cma(mt)) {
> +				if (mt != MIGRATE_HIGHATOMIC)
> +					set_pageblock_migratetype(page,
> +							MIGRATE_MOVABLE);
> +				else
> +					dec_highatomic_pageblock(zone, page,
> +							MIGRATE_MOVABLE);
> +			}
>  		}
>  	}
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
