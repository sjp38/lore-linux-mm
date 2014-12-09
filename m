Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id DDA326B0032
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 22:16:56 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id p10so2006652pdj.41
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 19:16:56 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id qe7si35659967pac.59.2014.12.08.19.16.54
        for <linux-mm@kvack.org>;
        Mon, 08 Dec 2014 19:16:55 -0800 (PST)
Date: Tue, 9 Dec 2014 12:17:43 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC PATCH 3/3] mm: always steal split buddies in fallback
 allocations
Message-ID: <20141209031743.GE3358@bbox>
References: <1417713178-10256-1-git-send-email-vbabka@suse.cz>
 <1417713178-10256-4-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1417713178-10256-4-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On Thu, Dec 04, 2014 at 06:12:58PM +0100, Vlastimil Babka wrote:
> When allocation falls back to another migratetype, it will steal a page with
> highest available order, and (depending on this order and desired migratetype),
> it might also steal the rest of free pages from the same pageblock.
> 
> Given the preference of highest available order, it is likely that it will be
> higher than the desired order, and result in the stolen buddy page being split.
> The remaining pages after split are currently stolen only when the rest of the
> free pages are stolen. This can however lead to situations where for MOVABLE
> allocations we split e.g. order-4 fallback UNMOVABLE page, but steal only
> order-0 page. Then on the next MOVABLE allocation (which may be batched to
> fill the pcplists) we split another order-3 or higher page, etc. By stealing
> all pages that we have split, we can avoid further stealing.
> 
> This patch therefore adjust the page stealing so that buddy pages created by
> split are always stolen. This has effect only on MOVABLE allocations, as
> RECLAIMABLE and UNMOVABLE allocations already always do that in addition to
> stealing the rest of free pages from the pageblock.
> 
> Note that commit 7118af076f6 ("mm: mmzone: MIGRATE_CMA migration type added")
> has already performed this change (unintentinally), but was reverted by commit
> 0cbef29a7821 ("mm: __rmqueue_fallback() should respect pageblock type").
> Neither included evaluation. My evaluation with stress-highalloc from mmtests
> shows about 2.5x reduction of page stealing events for MOVABLE allocations,
> without affecting the page stealing events for other allocation migratetypes.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Minchan Kim <minchan@kernel.org>

Nit:

>From this patch, try_to_steal_freepages always return start_type excpet CMA
case so we could factor CMA case out in try_to_steal_freepages and put the
check right before calling try_to_steal_freepages.

The benefit are we could make try_to_steal_freepages's return type as void
and we could remove fallback_type argument(ie, make the function simple).
Additionally, we could move set_freepage_migratetype into
try_to_steal_freepages so that we could remove new_type variable
in __rmqueue_fallback.

trace_mm_page_alloc_extfrag could work without new_type using
get_pageblock_migratetype.

Thanks.

> ---
>  mm/page_alloc.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a14249c..82096a6 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1108,11 +1108,9 @@ static int try_to_steal_freepages(struct zone *zone, struct page *page,
>  		if (pages >= (1 << (pageblock_order-1)) ||
>  				page_group_by_mobility_disabled)
>  			set_pageblock_migratetype(page, start_type);
> -
> -		return start_type;
>  	}
>  
> -	return fallback_type;
> +	return start_type;
>  }
>  
>  /* Remove an element from the buddy allocator from the fallback list */
> -- 
> 2.1.2
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
