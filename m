Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id E009F6B005C
	for <linux-mm@kvack.org>; Fri,  4 Jul 2014 03:53:03 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id z10so1589287pdj.29
        for <linux-mm@kvack.org>; Fri, 04 Jul 2014 00:53:03 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id pk9si34674254pac.234.2014.07.04.00.52.58
        for <linux-mm@kvack.org>;
        Fri, 04 Jul 2014 00:53:02 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 06/10] mm/page_alloc: separate freepage migratetype interface
Date: Fri,  4 Jul 2014 16:57:51 +0900
Message-Id: <1404460675-24456-7-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Currently, we use (set/get)_freepage_migratetype in two use cases.
One usecase is to know migratetype of buddy list where page will be
linked later. The other one is to know migratetype of buddy list where
page is linked now.

Although there is incompleteness for later case, there is no serious
problem, because it is only used by limited context, such as memory
isolation. But, now I'm preparing to fix many freepage counting bugs, and
accurate information about the migratetype of buddy list where page is
linked now is really needed. So this incompleteness would be problem.

Before fixing this incompleteness, separation of interface is needed,
because it is only used if CONFIG_MEMORY_ISOLATION is enabled and it has
some overhead.

So this patch just do separation of interface. There is no functional
change and following patch will describe what we are missing and fix it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/mm.h  |   24 ++++++++++++++++++++----
 mm/page_alloc.c     |   18 +++++++++---------
 mm/page_isolation.c |    4 ++--
 3 files changed, 31 insertions(+), 15 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index e03dd29..278ecfd 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -281,14 +281,30 @@ struct inode;
 #define page_private(page)		((page)->private)
 #define set_page_private(page, v)	((page)->private = (v))
 
-/* It's valid only if the page is free path or free_list */
-static inline void set_freepage_migratetype(struct page *page, int migratetype)
+static inline void set_onbuddy_migratetype(struct page *page, int migratetype)
 {
 	page->index = migratetype;
 }
 
-/* It's valid only if the page is free path or free_list */
-static inline int get_freepage_migratetype(struct page *page)
+/*
+ * It's valid only if the page is on buddy list. It represents
+ * migratetype of the buddy list where page is linked now.
+ */
+static inline int get_onbuddy_migratetype(struct page *page)
+{
+	return page->index;
+}
+
+static inline void set_onpcp_migratetype(struct page *page, int migratetype)
+{
+	page->index = migratetype;
+}
+
+/*
+ * It's valid only if the page is on pcp. It represents migratetype of
+ * the buddy list where page will be linked later when going buddy.
+ */
+static inline int get_onpcp_migratetype(struct page *page)
 {
 	return page->index;
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dcc2f08..9d8ba2d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -737,7 +737,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			page = list_entry(list->prev, struct page, lru);
 			/* must delete as __free_one_page list manipulates */
 			list_del(&page->lru);
-			mt = get_freepage_migratetype(page);
+			mt = get_onpcp_migratetype(page);
 
 			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
 			__free_one_page(page, page_to_pfn(page), zone, 0, mt);
@@ -797,7 +797,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	migratetype = get_pfnblock_migratetype(page, pfn);
 	local_irq_save(flags);
 	__count_vm_events(PGFREE, 1 << order);
-	set_freepage_migratetype(page, migratetype);
+	set_onbuddy_migratetype(page, migratetype);
 	free_one_page(page_zone(page), page, pfn, order, migratetype);
 	local_irq_restore(flags);
 }
@@ -1023,7 +1023,7 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 		rmv_page_order(page);
 		area->nr_free--;
 		expand(zone, page, order, current_order, area, migratetype);
-		set_freepage_migratetype(page, migratetype);
+		set_onpcp_migratetype(page, migratetype);
 		return page;
 	}
 
@@ -1091,7 +1091,7 @@ int move_freepages(struct zone *zone,
 		order = page_order(page);
 		list_move(&page->lru,
 			  &zone->free_area[order].free_list[migratetype]);
-		set_freepage_migratetype(page, migratetype);
+		set_onbuddy_migratetype(page, migratetype);
 		page += 1 << order;
 		pages_moved += 1 << order;
 	}
@@ -1221,12 +1221,12 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 
 			expand(zone, page, order, current_order, area,
 			       new_type);
-			/* The freepage_migratetype may differ from pageblock's
+			/* The onpcp_migratetype may differ from pageblock's
 			 * migratetype depending on the decisions in
 			 * try_to_steal_freepages. This is OK as long as it does
 			 * not differ for MIGRATE_CMA type.
 			 */
-			set_freepage_migratetype(page, new_type);
+			set_onpcp_migratetype(page, new_type);
 
 			trace_mm_page_alloc_extfrag(page, order, current_order,
 				start_migratetype, migratetype, new_type);
@@ -1344,7 +1344,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 		else
 			list_add_tail(&page->lru, list);
 		list = &page->lru;
-		if (is_migrate_cma(get_freepage_migratetype(page)))
+		if (is_migrate_cma(get_onpcp_migratetype(page)))
 			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
 					      -(1 << order));
 	}
@@ -1510,7 +1510,7 @@ void free_hot_cold_page(struct page *page, bool cold)
 		return;
 
 	migratetype = get_pfnblock_migratetype(page, pfn);
-	set_freepage_migratetype(page, migratetype);
+	set_onpcp_migratetype(page, migratetype);
 	local_irq_save(flags);
 	__count_vm_event(PGFREE);
 
@@ -1710,7 +1710,7 @@ again:
 		if (!page)
 			goto failed;
 		__mod_zone_freepage_state(zone, -(1 << order),
-					  get_freepage_migratetype(page));
+					  get_onpcp_migratetype(page));
 	}
 
 	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 1fa4a4d..6e4e86b 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -192,7 +192,7 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
 			 * is MIGRATE_ISOLATE. Catch it and move the page into
 			 * MIGRATE_ISOLATE list.
 			 */
-			if (get_freepage_migratetype(page) != MIGRATE_ISOLATE) {
+			if (get_onbuddy_migratetype(page) != MIGRATE_ISOLATE) {
 				struct page *end_page;
 
 				end_page = page + (1 << page_order(page)) - 1;
@@ -202,7 +202,7 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
 			pfn += 1 << page_order(page);
 		}
 		else if (page_count(page) == 0 &&
-			get_freepage_migratetype(page) == MIGRATE_ISOLATE)
+			get_onpcp_migratetype(page) == MIGRATE_ISOLATE)
 			pfn += 1;
 		else if (skip_hwpoisoned_pages && PageHWPoison(page)) {
 			/*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
