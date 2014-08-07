Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 04A126B0035
	for <linux-mm@kvack.org>; Thu,  7 Aug 2014 10:34:46 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id w62so4337882wes.36
        for <linux-mm@kvack.org>; Thu, 07 Aug 2014 07:34:46 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lj18si8645603wic.98.2014.08.07.07.34.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 07 Aug 2014 07:34:45 -0700 (PDT)
Message-ID: <53E38E81.3030301@suse.cz>
Date: Thu, 07 Aug 2014 16:34:41 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2 4/8] mm/isolation: close the two race problems related
 to pageblock isolation
References: <1407309517-3270-1-git-send-email-iamjoonsoo.kim@lge.com> <1407309517-3270-8-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1407309517-3270-8-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/06/2014 09:18 AM, Joonsoo Kim wrote:
> We got migratetype of the freeing page without holding the zone lock so
> it could be racy. There are two cases of this race.
>
> 1. pages are added to isolate buddy list after restoring original
> migratetype.
> 2. pages are added to normal buddy list while pageblock is isolated.
>
> If case 1 happens, we can't allocate freepages on isolate buddy list
> until next pageblock isolation occurs.
> In case of 2, pages could be merged with pages on isolate buddy list and
> located on normal buddy list. This makes freepage counting incorrect
> and break the property of pageblock isolation.
>
> One solution to this problem is checking pageblock migratetype with
> holding zone lock in __free_one_page() and I posted it before, but,
> it didn't get welcome since it needs the hook in zone lock critical
> section on freepath.
>
> This is another solution to this problem and impose most overhead on
> pageblock isolation logic. Following is how this solution works.
>
> 1. Extends irq disabled period on freepath to call
> get_pfnblock_migratetype() with irq disabled. With this, we can be
> sure that future freed pages will see modified pageblock migratetype
> after certain synchronization point so we don't need to hold the zone
> lock to get correct pageblock migratetype. Although it extends irq
> disabled period on freepath, I guess it is marginal and better than
> adding the hook in zone lock critical section.
>
> 2. #1 requires IPI for synchronization and we can't hold the zone lock

It would be better to explain here that the synchronization point is 
pcplists draining.

> during processing IPI. In this time, some pages could be moved from buddy
> list to pcp list on page allocation path and later it could be moved again
> from pcp list to buddy list. In this time, this page would be on isolate

It is difficult to understand the problem just by reading this. I guess 
the timelines you included while explaining the problem to me, would 
help here :)

> pageblock, so, the hook is required on free_pcppages_bulk() to prevent

More clearly, a recheck for pageblock's migratetype would be needed in 
free_pcppages_bulk(), which would again impose overhead outside isolation.

> misplacement. To remove this possibility, disabling and draining pcp
> list is needed during isolation. It guaratees that there is no page on pcp
> list on all cpus while isolation, so misplacement problem can't happen.
>
> Note that this doesn't fix freepage counting problem. To fix it,
> we need more logic. Following patches will do it.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>   mm/internal.h       |    2 ++
>   mm/page_alloc.c     |   27 ++++++++++++++++++++-------
>   mm/page_isolation.c |   45 +++++++++++++++++++++++++++++++++------------
>   3 files changed, 55 insertions(+), 19 deletions(-)
>
> diff --git a/mm/internal.h b/mm/internal.h
> index a1b651b..81b8884 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -108,6 +108,8 @@ extern pmd_t *mm_find_pmd(struct mm_struct *mm, unsigned long address);
>   /*
>    * in mm/page_alloc.c
>    */
> +extern void zone_pcp_disable(struct zone *zone);
> +extern void zone_pcp_enable(struct zone *zone);
>   extern void __free_pages_bootmem(struct page *page, unsigned int order);
>   extern void prep_compound_page(struct page *page, unsigned long order);
>   #ifdef CONFIG_MEMORY_FAILURE
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 3e1e344..4517b1d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -726,11 +726,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>   			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
>   			__free_one_page(page, page_to_pfn(page), zone, 0, mt);
>   			trace_mm_page_pcpu_drain(page, 0, mt);
> -			if (likely(!is_migrate_isolate_page(page))) {
> -				__mod_zone_page_state(zone, NR_FREE_PAGES, 1);
> -				if (is_migrate_cma(mt))
> -					__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, 1);
> -			}
> +			__mod_zone_freepage_state(zone, 1, mt);

Could be worth mentioning that this can now be removed as it was an 
incomplete attempt to fix freepage counting, but didn't address the 
misplacement.

>   		} while (--to_free && --batch_free && !list_empty(list));
>   	}
>   	spin_unlock(&zone->lock);
> @@ -789,8 +785,8 @@ static void __free_pages_ok(struct page *page, unsigned int order)
>   	if (!free_pages_prepare(page, order))
>   		return;
>
> -	migratetype = get_pfnblock_migratetype(page, pfn);
>   	local_irq_save(flags);
> +	migratetype = get_pfnblock_migratetype(page, pfn);
>   	__count_vm_events(PGFREE, 1 << order);
>   	set_freepage_migratetype(page, migratetype);
>   	free_one_page(page_zone(page), page, pfn, order, migratetype);
> @@ -1410,9 +1406,9 @@ void free_hot_cold_page(struct page *page, bool cold)
>   	if (!free_pages_prepare(page, 0))
>   		return;
>
> +	local_irq_save(flags);
>   	migratetype = get_pfnblock_migratetype(page, pfn);
>   	set_freepage_migratetype(page, migratetype);
> -	local_irq_save(flags);
>   	__count_vm_event(PGFREE);

Maybe add comments to these two to make it clear that this cannot be 
moved outside of the irq disabled part, in case anyone considers it 
(again) in the future?

> @@ -55,20 +56,32 @@ int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_pages)
>   	 */
>
>   out:
> -	if (!ret) {
> -		unsigned long nr_pages;
> -		int migratetype = get_pageblock_migratetype(page);
> +	if (ret) {
> +		spin_unlock_irqrestore(&zone->lock, flags);
> +		return ret;
> +	}
>   on pcplists
> -		set_pageblock_migratetype(page, MIGRATE_ISOLATE);
> -		nr_pages = move_freepages_block(zone, page, MIGRATE_ISOLATE);
> +	migratetype = get_pageblock_migratetype(page);
> +	set_pageblock_migratetype(page, MIGRATE_ISOLATE);
> +	spin_unlock_irqrestore(&zone->lock, flags);
>
> -		__mod_zone_freepage_state(zone, -nr_pages, migratetype);
> -	}
> +	zone_pcp_disable(zone);
> +
> +	/*
> +	 * After this point, freed pages will see MIGRATE_ISOLATE as
> +	 * their pageblock migratetype on all cpus. And pcp list has
> +	 * no free page.
> +	 */
> +	on_each_cpu(drain_local_pages, NULL, 1);

Is there any difference between drain_all_pages() and this, or why 
didn't you use drain_all_pages()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
