Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0A6CF6B0032
	for <linux-mm@kvack.org>; Thu, 25 Dec 2014 04:55:21 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so11617373pab.2
        for <linux-mm@kvack.org>; Thu, 25 Dec 2014 01:55:20 -0800 (PST)
Received: from mx1.mxmail.xiaomi.com ([58.68.235.87])
        by mx.google.com with ESMTP id ja5si193063pbc.237.2014.12.25.01.55.18
        for <linux-mm@kvack.org>;
        Thu, 25 Dec 2014 01:55:19 -0800 (PST)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [PATCH 1/3] CMA: Fix the bug that CMA's page number is substructed twice
Date: Thu, 25 Dec 2014 17:43:26 +0800
Message-ID: <1419500608-11656-2-git-send-email-zhuhui@xiaomi.com>
In-Reply-To: <1419500608-11656-1-git-send-email-zhuhui@xiaomi.com>
References: <1419500608-11656-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: m.szyprowski@samsung.com, mina86@mina86.com, akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, aneesh.kumar@linux.vnet.ibm.com, pintu.k@samsung.com, weijie.yang@samsung.com, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com, vbabka@suse.cz, laurent.pinchart+renesas@ideasonboard.com, rientjes@google.com, sasha.levin@oracle.com, liuweixing@xiaomi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: teawater@gmail.com, Hui Zhu <zhuhui@xiaomi.com>

In Joonsoo's CMA patch "CMA: always treat free cma pages as non-free on
watermark checking" [1], it changes __zone_watermark_ok to substruct CMA
pages number from free_pages if system use CMA:
	if (IS_ENABLED(CONFIG_CMA) && z->managed_cma_pages)
		free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);

But after this part of code
	for (o = 0; o < order; o++) {
		/* At the next order, this order's pages become unavailable */
		free_pages -= z->free_area[o].nr_free << o;
CMA memory in each order is part of z->free_area[o].nr_free, then the CMA
page number of this order is substructed twice.  This bug will make
__zone_watermark_ok return more false.

This patch add cma_free_area to struct free_area that just record the number
of CMA pages.  And add it back in the order loop to handle the substruct
twice issue.

[1] https://lkml.org/lkml/2014/5/28/110

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
Signed-off-by: Weixing Liu <liuweixing@xiaomi.com>
---
 include/linux/mmzone.h |  3 +++
 mm/page_alloc.c        | 29 ++++++++++++++++++++++++++++-
 2 files changed, 31 insertions(+), 1 deletion(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index ee1ce1f..7ccad93 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -92,6 +92,9 @@ static inline int get_pfnblock_migratetype(struct page *page, unsigned long pfn)
 struct free_area {
 	struct list_head	free_list[MIGRATE_TYPES];
 	unsigned long		nr_free;
+#ifdef CONFIG_CMA
+	unsigned long		cma_nr_free;
+#endif
 };
 
 struct pglist_data;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1b6c82c..a8d9f03 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -650,6 +650,8 @@ static inline void __free_one_page(struct page *page,
 		} else {
 			list_del(&buddy->lru);
 			zone->free_area[order].nr_free--;
+			if (is_migrate_cma(migratetype))
+				zone->free_area[order].cma_nr_free--;
 			rmv_page_order(buddy);
 		}
 		combined_idx = buddy_idx & page_idx;
@@ -683,6 +685,8 @@ static inline void __free_one_page(struct page *page,
 	list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
 out:
 	zone->free_area[order].nr_free++;
+	if (is_migrate_cma(migratetype))
+		zone->free_area[order].cma_nr_free++;
 }
 
 static inline int free_pages_check(struct page *page)
@@ -987,6 +991,8 @@ static inline void expand(struct zone *zone, struct page *page,
 		}
 		list_add(&page[size].lru, &area->free_list[migratetype]);
 		area->nr_free++;
+		if (is_migrate_cma(migratetype))
+			area->cma_nr_free++;
 		set_page_order(&page[size], high);
 	}
 }
@@ -1070,6 +1076,8 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 		list_del(&page->lru);
 		rmv_page_order(page);
 		area->nr_free--;
+		if (is_migrate_cma(migratetype))
+			area->cma_nr_free--;
 		expand(zone, page, order, current_order, area, migratetype);
 		set_freepage_migratetype(page, migratetype);
 		return page;
@@ -1258,6 +1266,8 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 			page = list_entry(area->free_list[migratetype].next,
 					struct page, lru);
 			area->nr_free--;
+			if (is_migrate_cma(migratetype))
+				area->cma_nr_free--;
 
 			new_type = try_to_steal_freepages(zone, page,
 							  start_migratetype,
@@ -1682,6 +1692,8 @@ int __isolate_free_page(struct page *page, unsigned int order)
 	/* Remove page from free list */
 	list_del(&page->lru);
 	zone->free_area[order].nr_free--;
+	if (is_migrate_cma(mt))
+		zone->free_area[order].cma_nr_free--;
 	rmv_page_order(page);
 
 	/* Set the pageblock if the isolated page is at least a pageblock */
@@ -1893,6 +1905,9 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
 	/* free_pages may go negative - that's OK */
 	long min = mark;
 	int o;
+#ifdef CONFIG_CMA
+	bool cma_is_subbed = false;
+#endif
 
 	free_pages -= (1 << order) - 1;
 	if (alloc_flags & ALLOC_HIGH)
@@ -1905,8 +1920,10 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
 	 * unmovable/reclaimable allocation and they can suddenly
 	 * vanish through CMA allocation
 	 */
-	if (IS_ENABLED(CONFIG_CMA) && z->managed_cma_pages)
+	if (IS_ENABLED(CONFIG_CMA) && z->managed_cma_pages) {
 		free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
+		cma_is_subbed = true;
+	}
 
 	if (free_pages <= min + z->lowmem_reserve[classzone_idx])
 		return false;
@@ -1914,6 +1931,13 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
 		/* At the next order, this order's pages become unavailable */
 		free_pages -= z->free_area[o].nr_free << o;
 
+		/* If CMA's page number of this order was substructed as part
+		   of "zone_page_state(z, NR_FREE_CMA_PAGES)", subtracting
+		   "z->free_area[o].nr_free << o" substructed CMA's page
+		   number of this order again.  So add it back.  */
+		if (IS_ENABLED(CONFIG_CMA) && cma_is_subbed)
+			free_pages += z->free_area[o].cma_nr_free << o;
+
 		/* Require fewer higher order pages to be free */
 		min >>= 1;
 
@@ -4318,6 +4342,7 @@ static void __meminit zone_init_free_lists(struct zone *zone)
 	for_each_migratetype_order(order, t) {
 		INIT_LIST_HEAD(&zone->free_area[order].free_list[t]);
 		zone->free_area[order].nr_free = 0;
+		zone->free_area[order].cma_nr_free = 0;
 	}
 }
 
@@ -6691,6 +6716,8 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 		list_del(&page->lru);
 		rmv_page_order(page);
 		zone->free_area[order].nr_free--;
+		if (is_migrate_cma(get_pageblock_migratetype(page)))
+			zone->free_area[order].cma_nr_free--;
 		for (i = 0; i < (1 << order); i++)
 			SetPageReserved((page+i));
 		pfn += (1 << order);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
