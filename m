Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 89A486B027B
	for <linux-mm@kvack.org>; Fri, 21 Mar 2014 10:16:35 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id d1so547223wiv.9
        for <linux-mm@kvack.org>; Fri, 21 Mar 2014 07:16:34 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lb4si3766561wjc.73.2014.03.21.07.16.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 21 Mar 2014 07:16:33 -0700 (PDT)
Message-ID: <532C49BF.8090001@suse.cz>
Date: Fri, 21 Mar 2014 15:16:31 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v3] mm/page_alloc: fix freeing of MIGRATE_RESERVE migratetype
 pages
References: <3269714.29dGMiCR2L@amdc1032>
In-Reply-To: <3269714.29dGMiCR2L@amdc1032>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Yong-Taek Lee <ytk.lee@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/06/2014 06:35 PM, Bartlomiej Zolnierkiewicz wrote:
> Pages allocated from MIGRATE_RESERVE migratetype pageblocks
> are not freed back to MIGRATE_RESERVE migratetype free
> lists in free_pcppages_bulk()->__free_one_page() if we got
> to free_pcppages_bulk() through drain_[zone_]pages().
> The freeing through free_hot_cold_page() is okay because
> freepage migratetype is set to pageblock migratetype before
> calling free_pcppages_bulk().

I think this is somewhat misleading and got me confused for a while. 
It's not about the call path of free_pcppages_bulk(), but about the
fact that rmqueue_bulk() has been called at some point to fill up the 
pcp lists, and had to resort to __rmqueue_fallback(). So, going through 
free_hot_cold_page() might give you correct migratetype for the last 
page freed, but the pcp lists may still contain misplaced pages from 
earlier rmqueue_bulk().

> If pages of MIGRATE_RESERVE
> migratetype end up on the free lists of other migratetype
> whole Reserved pageblock may be later changed to the other
> migratetype in __rmqueue_fallback() and it will be never
> changed back to be a Reserved pageblock.  Fix the issue by
> moving freepage migratetype setting from rmqueue_bulk() to
> __rmqueue[_fallback]() and preserving freepage migratetype
> as an original pageblock migratetype for MIGRATE_RESERVE
> migratetype pages.

Actually wouldn't the easiest solution to this particular problem to 
check current pageblock migratetype in try_to_steal_freepages() and 
disallow changing it. However I agree that preventing the misplaced page 
in the first place would be even better.

> The problem was introduced in v2.6.31 by commit ed0ae21
> ("page allocator: do not call get_pageblock_migratetype()
> more than necessary").
>
> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Reported-by: Yong-Taek Lee <ytk.lee@samsung.com>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Hugh Dickins <hughd@google.com>
> ---
> v2:
> - updated patch description, there is no __zone_pcp_update()
>    in newer kernels
> v3:
> - set freepage migratetype in __rmqueue[_fallback]()
>    instead of rmqueue_bulk() (per Mel's request)
>
>   mm/page_alloc.c |   27 ++++++++++++++++++---------
>   1 file changed, 18 insertions(+), 9 deletions(-)
>
> Index: b/mm/page_alloc.c
> ===================================================================
> --- a/mm/page_alloc.c	2014-03-06 18:10:21.884422983 +0100
> +++ b/mm/page_alloc.c	2014-03-06 18:10:27.016422895 +0100
> @@ -1094,7 +1094,7 @@ __rmqueue_fallback(struct zone *zone, in
>   	struct free_area *area;
>   	int current_order;
>   	struct page *page;
> -	int migratetype, new_type, i;
> +	int migratetype, new_type, mt = start_migratetype, i;

A better naming would help, "mt" and "migratetype" are the same thing 
and it gets too confusing.

>
>   	/* Find the largest possible block of pages in the other list */
>   	for (current_order = MAX_ORDER-1; current_order >= order;
> @@ -1125,6 +1125,14 @@ __rmqueue_fallback(struct zone *zone, in
>   			expand(zone, page, order, current_order, area,
>   			       new_type);
>
> +			if (IS_ENABLED(CONFIG_CMA)) {
> +				mt = get_pageblock_migratetype(page);
> +				if (!is_migrate_cma(mt) &&
> +				    !is_migrate_isolate(mt))
> +					mt = start_migratetype;
> +			}
> +			set_freepage_migratetype(page, mt);
> +
>   			trace_mm_page_alloc_extfrag(page, order, current_order,
>   				start_migratetype, migratetype, new_type);
>
> @@ -1147,7 +1155,9 @@ static struct page *__rmqueue(struct zon
>   retry_reserve:
>   	page = __rmqueue_smallest(zone, order, migratetype);
>
> -	if (unlikely(!page) && migratetype != MIGRATE_RESERVE) {
> +	if (likely(page)) {
> +		set_freepage_migratetype(page, migratetype);

Are you sure that here the checking of of CMA and ISOLATE is not needed? 
Did the original rmqueue_bulk() have this checking only for the 
__rmqueue_fallback() case? Why wouldn't the check already be only in 
__rmqueue_fallback() then?

> +	} else if (migratetype != MIGRATE_RESERVE) {
>   		page = __rmqueue_fallback(zone, order, migratetype);
>
>   		/*
> @@ -1174,7 +1184,7 @@ static int rmqueue_bulk(struct zone *zon
>   			unsigned long count, struct list_head *list,
>   			int migratetype, int cold)
>   {
> -	int mt = migratetype, i;
> +	int i;
>
>   	spin_lock(&zone->lock);
>   	for (i = 0; i < count; ++i) {
> @@ -1195,16 +1205,15 @@ static int rmqueue_bulk(struct zone *zon
>   			list_add(&page->lru, list);
>   		else
>   			list_add_tail(&page->lru, list);
> +		list = &page->lru;
>   		if (IS_ENABLED(CONFIG_CMA)) {
> -			mt = get_pageblock_migratetype(page);
> +			int mt = get_pageblock_migratetype(page);
>   			if (!is_migrate_cma(mt) && !is_migrate_isolate(mt))
>   				mt = migratetype;
> +			if (is_migrate_cma(mt))
> +				__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
> +						      -(1 << order));
>   		}
> -		set_freepage_migratetype(page, mt);
> -		list = &page->lru;
> -		if (is_migrate_cma(mt))
> -			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
> -					      -(1 << order));
>   	}
>   	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
>   	spin_unlock(&zone->lock);
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
