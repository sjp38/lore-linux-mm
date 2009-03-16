Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 714F86B0099
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 05:44:41 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 33/35] Do not merge buddies until they are needed by a high-order allocation or anti-fragmentation
Date: Mon, 16 Mar 2009 09:46:28 +0000
Message-Id: <1237196790-7268-34-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1237196790-7268-1-git-send-email-mel@csn.ul.ie>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

Freeing and allocating pages from the buddy lists can incur a number of
cache misses as the struct pages are written to. This patch only merges
buddies up to PAGE_ALLOC_COSTLY_ORDER. High-order allocations are then
required to do the actual merging. This punishes high-order allocations
somewhat but they are expected to be relatively rare and should be
avoided in general.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/mmzone.h |    7 ++++
 mm/page_alloc.c        |   91 +++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 86 insertions(+), 12 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 9057bc1..8027163 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -35,6 +35,13 @@
  */
 #define PAGE_ALLOC_COSTLY_ORDER 3
 
+/*
+ * PAGE_ALLOC_MERGE_ORDER is the order at which pages get merged together
+ * but not merged further unless explicitly needed by a high-order allocation.
+ * The value is to merge to larger than the PCP batch refill size
+ */
+#define PAGE_ALLOC_MERGE_ORDER 5
+
 #define MIGRATE_UNMOVABLE     0
 #define MIGRATE_RECLAIMABLE   1
 #define MIGRATE_MOVABLE       2
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 33f39cf..f1741a3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -456,25 +456,18 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
  * -- wli
  */
 
-static inline void __free_one_page(struct page *page,
-		struct zone *zone, unsigned int order,
-		int migratetype)
+static inline struct page *__merge_one_page(struct page *page,
+		struct zone *zone, unsigned int order, unsigned int maxorder)
 {
 	unsigned long page_idx;
 
-	if (unlikely(PageCompound(page)))
-		if (unlikely(destroy_compound_page(page, order)))
-			return;
-
-	VM_BUG_ON(migratetype == -1);
-
 	page_idx = page_to_pfn(page) & ((1 << MAX_ORDER) - 1);
 	page->index = 0;
 
 	VM_BUG_ON(page_idx & ((1 << order) - 1));
 	VM_BUG_ON(bad_range(zone, page));
 
-	while (order < MAX_ORDER-1) {
+	while (order < maxorder) {
 		unsigned long combined_idx;
 		struct page *buddy;
 
@@ -491,10 +484,77 @@ static inline void __free_one_page(struct page *page,
 		page_idx = combined_idx;
 		order++;
 	}
+
 	set_page_order(page, order);
+	return page;
+}
+
+/* Merge free pages up to MAX_ORDER-1 */
+static noinline void __merge_highorder_pages(struct zone *zone)
+{
+	struct page *page, *buddy;
+	struct free_area *area;
+	int migratetype;
+	unsigned int order;
+
+	for_each_migratetype_order(order, migratetype) {
+		struct list_head *list;
+		unsigned long page_idx;
+
+		if (order == MAX_ORDER-1)
+			break;
+
+		area = &(zone->free_area[order]);
+		list = &area->free_list[migratetype];
+
+pagemerged:
+		if (list_empty(list))
+			continue;
+		/*
+		 * Each time we merge, we jump back here as even the _safe
+		 * variants of list_for_each() cannot cope with the cursor
+		 * page disappearing
+		 */
+		list_for_each_entry(page, list, lru) {
+
+			page_idx = page_to_pfn(page) & ((1 << MAX_ORDER) - 1);
+			buddy = __page_find_buddy(page, page_idx, order);
+			if (!page_is_buddy(page, buddy, order))
+				continue;
+
+			/* Ok, remove the page, merge and re-add */
+			list_del(&page->lru);
+			rmv_page_order(page);
+			area->nr_free--;
+			page = __merge_one_page(page, zone,
+							order, MAX_ORDER-1);
+			list_add(&page->lru,
+				&zone->free_area[page_order(page)].free_list[migratetype]);
+			zone->free_area[page_order(page)].nr_free++;
+			goto pagemerged;
+		}
+	}
+}
+
+static inline void __free_one_page(struct page *page,
+		struct zone *zone, unsigned int order,
+		int migratetype)
+{
+	if (unlikely(PageCompound(page)))
+		if (unlikely(destroy_compound_page(page, order)))
+			return;
+
+	VM_BUG_ON(migratetype == -1);
+
+	/*
+	 * We only lazily merge up to PAGE_ALLOC_MERGE_ORDER to avoid
+	 * cache line bounces merging buddies. High order allocations
+	 * take the hit of merging the buddies further
+	 */
+	page = __merge_one_page(page, zone, order, PAGE_ALLOC_MERGE_ORDER);
 	list_add(&page->lru,
-		&zone->free_area[order].free_list[migratetype]);
-	zone->free_area[order].nr_free++;
+		&zone->free_area[page_order(page)].free_list[migratetype]);
+	zone->free_area[page_order(page)].nr_free++;
 }
 
 static inline int free_pages_check(struct page *page)
@@ -849,6 +909,9 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 	struct page *page;
 	int migratetype, i;
 
+	/* Merge the buddies before stealing */
+	__merge_highorder_pages(zone);
+
 	/* Find the largest possible block of pages in the other list */
 	for (current_order = MAX_ORDER-1; current_order >= order;
 						--current_order) {
@@ -1608,6 +1671,10 @@ zonelist_scan:
 			}
 		}
 
+		/* Lazy merge buddies for high orders */
+		if (order > PAGE_ALLOC_MERGE_ORDER)
+			__merge_highorder_pages(zone);
+
 		page = buffered_rmqueue(preferred_zone, zone, order,
 						gfp_mask, migratetype, cold);
 		if (page)
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
