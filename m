Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 7FF1A6B005C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 09:19:25 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (mailout3.samsung.com [203.254.224.33])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M5L0099DZNZB830@mailout3.samsung.com> for
 linux-mm@kvack.org; Thu, 14 Jun 2012 22:19:23 +0900 (KST)
Received: from AMDC159 ([106.116.37.153])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M5L00GVIZO2PT20@mmp2.samsung.com> for linux-mm@kvack.org;
 Thu, 14 Jun 2012 22:19:23 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
References: <201205230922.00530.b.zolnierkie@samsung.com>
In-reply-to: <201205230922.00530.b.zolnierkie@samsung.com>
Subject: RE: [PATCH] cma: cached pageblock type fixup
Date: Thu, 14 Jun 2012 15:19:13 +0200
Message-id: <001d01cd4a30$4d2505d0$e76f1170$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7bit
Content-language: pl
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, linux-mm@kvack.org
Cc: 'Michal Nazarewicz' <mina86@mina86.com>, 'Mel Gorman' <mgorman@suse.de>

Hello,

On Wednesday, May 23, 2012 9:22 AM Bartlomiej Zolnierkiewicz wrote:

> CMA pages added to per-cpu pages lists in free_hot_cold_page()
> have private field set to MIGRATE_CMA pageblock type .  If this
> happes just before start_isolate_page_range() in alloc_contig_range()
> changes pageblock type of the page to MIGRATE_ISOLATE it may result
> in the cached pageblock type being stale in free_pcppages_bulk()
> (which may be triggered by drain_all_pages() in alloc_contig_range()),
> page being added to MIGRATE_CMA free list instead of MIGRATE_ISOLATE
> one in __free_one_page() and (if the page is reused just before
> test_pages_isolated() check) causing alloc_contig_range() failure.
> 
> Fix such situation by checking whether pageblock type of the page
> changed to MIGRATE_ISOLATE for MIGRATE_CMA type pages in
> free_pcppages_bulk() and if so fixup the pageblock type to
> MIGRATE_ISOLATE (so the page will be added to MIGRATE_ISOLATE free
> list in __free_one_page() and won't be used).
> 
> Similar situation can happen if rmqueue_bulk() sets cached pageblock
> of the page to MIGRATE_CMA and start_isolate_page_range() is called
> before buffered_rmqueue() completes (so the page may used by
> get_page_from_freelist() and cause test_pages_isolated() check
> failure in alloc_contig_range()).  Fix it in buffered_rmqueue() by
> changing the pageblock type of the affected page if needed, freeing
> page back to buddy allocator and retrying the allocation.
> 
> Please note that even with this patch applied some page allocation
> vs alloc_contig_range() races are still possible and may result in
> rare test_pages_isolated() failures.
> 
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>

Mel, do you have any suggestions or comments how can we deal with this 
issue?

> ---
>  mm/page_alloc.c |   38 ++++++++++++++++++++++++++++++++++++--
>  1 file changed, 36 insertions(+), 2 deletions(-)
> 
> Index: b/mm/page_alloc.c
> ===================================================================
> --- a/mm/page_alloc.c	2012-05-14 16:19:10.052973990 +0200
> +++ b/mm/page_alloc.c	2012-05-15 12:40:54.199127705 +0200
> @@ -664,12 +664,24 @@
>  			batch_free = to_free;
> 
>  		do {
> +			int mt;
> +
>  			page = list_entry(list->prev, struct page, lru);
>  			/* must delete as __free_one_page list manipulates */
>  			list_del(&page->lru);
> +
> +			mt = page_private(page);
> +			/*
> +			 * cached MIGRATE_CMA pageblock type may have changed
> +			 * during isolation
> +			 */
> +			if (is_migrate_cma(mt) &&
> +			    get_pageblock_migratetype(page) == MIGRATE_ISOLATE)
> +				mt = MIGRATE_ISOLATE;
> +
>  			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
> -			__free_one_page(page, zone, 0, page_private(page));
> -			trace_mm_page_pcpu_drain(page, 0, page_private(page));
> +			__free_one_page(page, zone, 0, mt);
> +			trace_mm_page_pcpu_drain(page, 0, mt);
>  		} while (--to_free && --batch_free && !list_empty(list));
>  	}
>  	__mod_zone_page_state(zone, NR_FREE_PAGES, count);
> @@ -1440,6 +1452,7 @@
>  	if (likely(order == 0)) {
>  		struct per_cpu_pages *pcp;
>  		struct list_head *list;
> +		int mt;
> 
>  		local_irq_save(flags);
>  		pcp = &this_cpu_ptr(zone->pageset)->pcp;
> @@ -1459,6 +1472,27 @@
> 
>  		list_del(&page->lru);
>  		pcp->count--;
> +
> +		spin_lock(&zone->lock);
> +		mt = page_private(page);
> +		/*
> +		 * cached MIGRATE_CMA pageblock type may have changed
> +		 * during isolation
> +		 */
> +		if ((is_migrate_cma(mt) &&
> +		     get_pageblock_migratetype(page) == MIGRATE_ISOLATE) ||
> +		    mt == MIGRATE_ISOLATE) {
> +			mt = MIGRATE_ISOLATE;
> +
> +			zone->all_unreclaimable = 0;
> +			zone->pages_scanned = 0;
> +
> +			__free_one_page(page, zone, 0, mt);
> +			__mod_zone_page_state(zone, NR_FREE_PAGES, 1);
> +			spin_unlock(&zone->lock);
> +			goto again;
> +		} else
> +			spin_unlock(&zone->lock);
>  	} else {
>  		if (unlikely(gfp_flags & __GFP_NOFAIL)) {
>  			/*

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
