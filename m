Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 978D46B0032
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 04:49:08 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id n3so1049529wiv.7
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 01:49:08 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ei5si1113153wjd.110.2014.12.09.01.49.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Dec 2014 01:49:07 -0800 (PST)
Message-ID: <5486C591.7030509@suse.cz>
Date: Tue, 09 Dec 2014 10:49:05 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: page_alloc: remove redundant set_freepage_migratetype()
 calls
References: <000301d01385$45554a60$cfffdf20$%yang@samsung.com>
In-Reply-To: <000301d01385$45554a60$cfffdf20$%yang@samsung.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>, iamjoonsoo.kim@lge.com
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, mgorman@suse.de, 'Rik van Riel' <riel@redhat.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Minchan Kim' <minchan@kernel.org>, 'Weijie Yang' <weijie.yang.kh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 12/09/2014 08:51 AM, Weijie Yang wrote:
> The freepage_migratetype is a temporary cached value which represents
> the free page's pageblock migratetype. Now we use it in two scenarios:
>
> 1. Use it as a cached value in page freeing path. This cached value
> is temporary and non-100% update, which help us decide which pcp
> freelist and buddy freelist the page should go rather than using
> get_pfnblock_migratetype() to save some instructions.
> When there is race between page isolation and free path, we need use
> additional method to get a accurate value to put the free pages to
> the correct freelist and get a precise free pages statistics.
>
> 2. Use it in page alloc path to update NR_FREE_CMA_PAGES statistics.

Maybe add that in this case, the value is only valid between being set 
by __rmqueue_smallest/__rmqueue_fallback and being consumed by 
rmqueue_bulk or buffered_rmqueue for the purposes of statistics.
Oh, except that in rmqueue_bulk, we are placing it on pcplists, so it's 
case 1. Tricky.

Anyway, the comments for get/set_freepage_migratetype() say:

/* It's valid only if the page is free path or free_list */

And that's not really true. So should it instead say something like "The 
value is only valid when the page is on pcp list, for determining on 
which free list the page should go if the pcp list is flushed. It is 
also temporarily valid during allocation from free list."

> This patch aims at the scenario 1 and removes two redundant
> set_freepage_migratetype() calls, which will make sense in the hot path.
>
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
> ---
>   mm/page_alloc.c |    2 --
>   1 file changed, 2 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 616a2c9..99af01a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -775,7 +775,6 @@ static void __free_pages_ok(struct page *page, unsigned int order)
>   	migratetype = get_pfnblock_migratetype(page, pfn);
>   	local_irq_save(flags);
>   	__count_vm_events(PGFREE, 1 << order);
> -	set_freepage_migratetype(page, migratetype);
>   	free_one_page(page_zone(page), page, pfn, order, migratetype);
>   	local_irq_restore(flags);
>   }
> @@ -1024,7 +1023,6 @@ int move_freepages(struct zone *zone,
>   		order = page_order(page);
>   		list_move(&page->lru,
>   			  &zone->free_area[order].free_list[migratetype]);
> -		set_freepage_migratetype(page, migratetype);
>   		page += 1 << order;
>   		pages_moved += 1 << order;
>   	}
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
