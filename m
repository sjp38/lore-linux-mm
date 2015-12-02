Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 98B5A6B0255
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 11:28:33 -0500 (EST)
Received: by wmww144 with SMTP id w144so222244354wmw.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 08:28:33 -0800 (PST)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id x9si5285318wjf.139.2015.12.02.08.28.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 08:28:32 -0800 (PST)
Received: by wmvv187 with SMTP id v187so263332149wmv.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 08:28:31 -0800 (PST)
Date: Wed, 2 Dec 2015 17:28:29 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm/page_alloc.c: use list_{first,last}_entry instead
 of list_entry
Message-ID: <20151202162829.GK25284@dhcp22.suse.cz>
References: <db1a792ecffc24a080e130725a82f190804fdf78.1449068845.git.geliangtang@163.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <db1a792ecffc24a080e130725a82f190804fdf78.1449068845.git.geliangtang@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@163.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Alexander Duyck <alexander.h.duyck@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 02-12-15 23:12:40, Geliang Tang wrote:
> To make the intention clearer, use list_{first,last}_entry instead
> of list_entry.

I like list_{first,last}_entry that indeed helps readability, the
_or_null is less clear from the name, though. Previous check for an
empty list was easier to read, at least for me. But it seems like
this is a general pattern...

> Signed-off-by: Geliang Tang <geliangtang@163.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_alloc.c | 23 +++++++++++------------
>  1 file changed, 11 insertions(+), 12 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d6d7c97..0d38185 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -830,7 +830,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>  		do {
>  			int mt;	/* migratetype of the to-be-freed page */
>  
> -			page = list_entry(list->prev, struct page, lru);
> +			page = list_last_entry(list, struct page, lru);
>  			/* must delete as __free_one_page list manipulates */
>  			list_del(&page->lru);
>  
> @@ -1457,11 +1457,10 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
>  	/* Find a page of the appropriate size in the preferred list */
>  	for (current_order = order; current_order < MAX_ORDER; ++current_order) {
>  		area = &(zone->free_area[current_order]);
> -		if (list_empty(&area->free_list[migratetype]))
> -			continue;
> -
> -		page = list_entry(area->free_list[migratetype].next,
> +		page = list_first_entry_or_null(&area->free_list[migratetype],
>  							struct page, lru);
> +		if (!page)
> +			continue;
>  		list_del(&page->lru);
>  		rmv_page_order(page);
>  		area->nr_free--;
> @@ -1740,12 +1739,12 @@ static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
>  		for (order = 0; order < MAX_ORDER; order++) {
>  			struct free_area *area = &(zone->free_area[order]);
>  
> -			if (list_empty(&area->free_list[MIGRATE_HIGHATOMIC]))
> +			page = list_first_entry_or_null(
> +					&area->free_list[MIGRATE_HIGHATOMIC],
> +					struct page, lru);
> +			if (!page)
>  				continue;
>  
> -			page = list_entry(area->free_list[MIGRATE_HIGHATOMIC].next,
> -						struct page, lru);
> -
>  			/*
>  			 * It should never happen but changes to locking could
>  			 * inadvertently allow a per-cpu drain to add pages
> @@ -1793,7 +1792,7 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
>  		if (fallback_mt == -1)
>  			continue;
>  
> -		page = list_entry(area->free_list[fallback_mt].next,
> +		page = list_first_entry(&area->free_list[fallback_mt],
>  						struct page, lru);
>  		if (can_steal)
>  			steal_suitable_fallback(zone, page, start_migratetype);
> @@ -2252,9 +2251,9 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
>  		}
>  
>  		if (cold)
> -			page = list_entry(list->prev, struct page, lru);
> +			page = list_last_entry(list, struct page, lru);
>  		else
> -			page = list_entry(list->next, struct page, lru);
> +			page = list_first_entry(list, struct page, lru);
>  
>  		list_del(&page->lru);
>  		pcp->count--;
> -- 
> 2.5.0
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
