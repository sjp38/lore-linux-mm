Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2AD796B003B
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 02:04:38 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id rr13so2645418pbb.37
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 23:04:37 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id sj5si2938579pab.342.2014.01.08.23.04.34
        for <linux-mm@kvack.org>;
        Wed, 08 Jan 2014 23:04:36 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 5/7] mm/page_alloc: separate interface to set/get migratetype of freepage
Date: Thu,  9 Jan 2014 16:04:45 +0900
Message-Id: <1389251087-10224-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1389251087-10224-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1389251087-10224-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jiang Liu <jiang.liu@huawei.com>, Mel Gorman <mgorman@suse.de>, Cody P Schafer <cody@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Andi Kleen <ak@linux.intel.com>, Wei Yongjun <yongjun_wei@trendmicro.com.cn>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Currently, we use (set/get)_freepage_migratetype in two use cases.
One is to know the buddy list where this page will be linked and
the other is to know the buddy list where this page is linked now.

But, we should deal these two use cases differently, because information
isn't sufficient for the second use case and properly setting this
information needs some overhead. Whenever the page is merged or split
in buddy, this information isn't properly re-assigned and it may not
have enough information for the second use case.

This patch just separates interface, so there is no functional change.
Following patch will do further steps about this issue.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3552717..2733e0b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -257,14 +257,31 @@ struct inode;
 #define page_private(page)		((page)->private)
 #define set_page_private(page, v)	((page)->private = (v))
 
-/* It's valid only if the page is free path or free_list */
-static inline void set_freepage_migratetype(struct page *page, int migratetype)
+/*
+ * It's valid only if the page is on buddy. It represents
+ * which freelist the page is linked.
+ */
+static inline void set_buddy_migratetype(struct page *page, int migratetype)
+{
+	page->index = migratetype;
+}
+
+static inline int get_buddy_migratetype(struct page *page)
+{
+	return page->index;
+}
+
+/*
+ * It's valid only if the page is on pcp list. It represents
+ * which freelist the page should go on buddy.
+ */
+static inline void set_pcp_migratetype(struct page *page, int migratetype)
 {
 	page->index = migratetype;
 }
 
-/* It's valid only if the page is free path or free_list */
-static inline int get_freepage_migratetype(struct page *page)
+/* It's valid only if the page is on pcp list */
+static inline int get_pcp_migratetype(struct page *page)
 {
 	return page->index;
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4913829..c9e6622 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -681,7 +681,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			page = list_entry(list->prev, struct page, lru);
 			/* must delete as __free_one_page list manipulates */
 			list_del(&page->lru);
-			mt = get_freepage_migratetype(page);
+			mt = get_pcp_migratetype(page);
 			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
 			__free_one_page(page, zone, 0, mt);
 			trace_mm_page_pcpu_drain(page, 0, mt);
@@ -745,7 +745,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	local_irq_save(flags);
 	__count_vm_events(PGFREE, 1 << order);
 	migratetype = get_pageblock_migratetype(page);
-	set_freepage_migratetype(page, migratetype);
+	set_buddy_migratetype(page, migratetype);
 	free_one_page(page_zone(page), page, order, migratetype);
 	local_irq_restore(flags);
 }
@@ -903,7 +903,7 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 		rmv_page_order(page);
 		area->nr_free--;
 		expand(zone, page, order, current_order, area, migratetype);
-		set_freepage_migratetype(page, migratetype);
+		set_pcp_migratetype(page, migratetype);
 		return page;
 	}
 
@@ -971,7 +971,7 @@ int move_freepages(struct zone *zone,
 		order = page_order(page);
 		list_move(&page->lru,
 			  &zone->free_area[order].free_list[migratetype]);
-		set_freepage_migratetype(page, migratetype);
+		set_buddy_migratetype(page, migratetype);
 		page += 1 << order;
 		pages_moved += 1 << order;
 	}
@@ -1094,12 +1094,11 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 
 			/* CMA pages cannot be stolen */
 			if (is_migrate_cma(migratetype)) {
-				set_freepage_migratetype(page, migratetype);
+				set_pcp_migratetype(page, migratetype);
 				__mod_zone_page_state(zone,
 					NR_FREE_CMA_PAGES, -(1 << order));
 			} else {
-				set_freepage_migratetype(page,
-							start_migratetype);
+				set_pcp_migratetype(page, start_migratetype);
 			}
 
 			/* Remove the page from the freelists */
@@ -1346,7 +1345,7 @@ void free_hot_cold_page(struct page *page, int cold)
 		return;
 
 	migratetype = get_pageblock_migratetype(page);
-	set_freepage_migratetype(page, migratetype);
+	set_pcp_migratetype(page, migratetype);
 	local_irq_save(flags);
 	__count_vm_event(PGFREE);
 
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 534fb3a..c341413 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -190,7 +190,7 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
 			 * is MIGRATE_ISOLATE. Catch it and move the page into
 			 * MIGRATE_ISOLATE list.
 			 */
-			if (get_freepage_migratetype(page) != MIGRATE_ISOLATE) {
+			if (get_buddy_migratetype(page) != MIGRATE_ISOLATE) {
 				struct page *end_page;
 
 				end_page = page + (1 << page_order(page)) - 1;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
