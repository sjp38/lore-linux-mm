Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 5E0F46B0074
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 03:26:00 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [RFC PATCH 1/3 V1] mm, page_alloc: use __rmqueue_smallest when borrow memory from MIGRATE_CMA
Date: Wed, 4 Jul 2012 15:26:16 +0800
Message-Id: <1341386778-8002-2-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1341386778-8002-1-git-send-email-laijs@cn.fujitsu.com>
References: <1341386778-8002-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Chris Metcalf <cmetcalf@tilera.com>, --@kvack.org, Len Brown <lenb@kernel.org>--@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>--@kvack.org, Andi Kleen <andi@firstfloor.org>--@kvack.org, Julia Lawall <julia@diku.dk>--@kvack.org, David Howells <dhowells@redhat.com>--@kvack.org, Lai Jiangshan <laijs@cn.fujitsu.com>--@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>--@kvack.org, Kay Sievers <kay.sievers@vrfy.org>--@kvack.org, Ingo Molnar <mingo@elte.hu>--@kvack.org, Paul Gortmaker <paul.gortmaker@windriver.com>--@kvack.org, Daniel Kiper <dkiper@net-space.pl>--@kvack.org, Andrew Morton <akpm@linux-foundation.org>--@kvack.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>--@kvack.org, Michal Hocko <mhocko@suse.cz>--@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>--@kvack.org, Minchan Kim <minchan@kernel.org>--@kvack.org, Michal Nazarewicz <mina86@mina86.com>--@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>--@kvack.org, Rik van Riel <riel@redhat.com>--@kvack.org, Bjorn Helgaas <bhelgaas@google.com>--@kvack.org, Christoph Lameter <cl@linux.com>--@kvack.org, David Rientjes <rientjes@google.com>--@kvack.org, linux-kernel@vger.kernel.org--, linux-acpi@vger.kernel.org--, linux-mm@kvack.org

The pages of MIGRATE_CMA can't not be changed to the other type,
nor be moved to the other free list. 

==>
So when we use __rmqueue_fallback() to borrow memory from MIGRATE_CMA,
one of the highest order page is borrowed and it is split.
But the free pages resulted by splitting can NOT
be moved to MIGRATE_MOVABLE.

==>
So in the next time of allocation, we NEED to borrow again,
another one of the highest order page is borrowed from CMA and it is split.
and results some other new split free pages.

==>
So when __rmqueue_fallback() borrows (highest order)memory from MIGRATE_CMA,
it introduces fragments at the same time and may waste tlb(only one page is used in
a pageblock).

Conclusion:
We should borrows the smallest order memory from MIGRATE_CMA in such case

Result(good):
1) use __rmqueue_smallest when borrow memory from MIGRATE_CMA
2) __rmqueue_fallback() don't handle CMA, it becomes much simpler
Result(bad):
__rmqueue_smallest() can't not be inlined to avoid function call overhead.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 include/linux/mmzone.h |    1 +
 mm/page_alloc.c        |   63 ++++++++++++++++--------------------------------
 2 files changed, 22 insertions(+), 42 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index bf3404e..979c333 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -40,6 +40,7 @@ enum {
 	MIGRATE_RECLAIMABLE,
 	MIGRATE_MOVABLE,
 	MIGRATE_PCPTYPES,	/* the number of types on the pcp lists */
+	MIGRATE_PRIME_TYPES = MIGRATE_PCPTYPES,
 	MIGRATE_RESERVE = MIGRATE_PCPTYPES,
 #ifdef CONFIG_CMA
 	/*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 476ae3e..efc327f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -893,17 +893,10 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
  * This array describes the order lists are fallen back to when
  * the free lists for the desirable migrate type are depleted
  */
-static int fallbacks[MIGRATE_TYPES][4] = {
-	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,     MIGRATE_RESERVE },
-	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,     MIGRATE_RESERVE },
-#ifdef CONFIG_CMA
-	[MIGRATE_MOVABLE]     = { MIGRATE_CMA,         MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE },
-	[MIGRATE_CMA]         = { MIGRATE_RESERVE }, /* Never used */
-#else
-	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE,   MIGRATE_RESERVE },
-#endif
-	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE }, /* Never used */
-	[MIGRATE_ISOLATE]     = { MIGRATE_RESERVE }, /* Never used */
+static int fallbacks[MIGRATE_PRIME_TYPES][2] = {
+	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE   },
+	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE   },
+	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE },
 };
 
 /*
@@ -995,16 +988,15 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 	struct page *page;
 	int migratetype, i;
 
+	if (WARN_ON_ONCE(start_migratetype >= MIGRATE_PRIME_TYPES))
+		start_migratetype = MIGRATE_UNMOVABLE;
+
 	/* Find the largest possible block of pages in the other list */
 	for (current_order = MAX_ORDER-1; current_order >= order;
 						--current_order) {
-		for (i = 0;; i++) {
+		for (i = 0; i < ARRAY_SIZE(fallbacks[0]); i++) {
 			migratetype = fallbacks[start_migratetype][i];
 
-			/* MIGRATE_RESERVE handled later if necessary */
-			if (migratetype == MIGRATE_RESERVE)
-				break;
-
 			area = &(zone->free_area[current_order]);
 			if (list_empty(&area->free_list[migratetype]))
 				continue;
@@ -1018,17 +1010,10 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 			 * pages to the preferred allocation list. If falling
 			 * back for a reclaimable kernel allocation, be more
 			 * aggressive about taking ownership of free pages
-			 *
-			 * On the other hand, never change migration
-			 * type of MIGRATE_CMA pageblocks nor move CMA
-			 * pages on different free lists. We don't
-			 * want unmovable pages to be allocated from
-			 * MIGRATE_CMA areas.
 			 */
-			if (!is_migrate_cma(migratetype) &&
-			    (unlikely(current_order >= pageblock_order / 2) ||
-			     start_migratetype == MIGRATE_RECLAIMABLE ||
-			     page_group_by_mobility_disabled)) {
+			if (unlikely(current_order >= pageblock_order / 2) ||
+			    start_migratetype == MIGRATE_RECLAIMABLE ||
+			    page_group_by_mobility_disabled) {
 				int pages;
 				pages = move_freepages_block(zone, page,
 								start_migratetype);
@@ -1047,14 +1032,12 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 			rmv_page_order(page);
 
 			/* Take ownership for orders >= pageblock_order */
-			if (current_order >= pageblock_order &&
-			    !is_migrate_cma(migratetype))
+			if (current_order >= pageblock_order)
 				change_pageblock_range(page, current_order,
 							start_migratetype);
 
 			expand(zone, page, order, current_order, area,
-			       is_migrate_cma(migratetype)
-			     ? migratetype : start_migratetype);
+			       start_migratetype);
 
 			trace_mm_page_alloc_extfrag(page, order, current_order,
 				start_migratetype, migratetype);
@@ -1075,22 +1058,18 @@ static struct page *__rmqueue(struct zone *zone, unsigned int order,
 {
 	struct page *page;
 
-retry_reserve:
 	page = __rmqueue_smallest(zone, order, migratetype);
 
-	if (unlikely(!page) && migratetype != MIGRATE_RESERVE) {
+#ifdef CONFIG_CMA
+	if (unlikely(!page) && migratetype == MIGRATE_MOVABLE)
+		page = __rmqueue_smallest(zone, order, MIGRATE_CMA);
+#endif
+
+	if (unlikely(!page))
 		page = __rmqueue_fallback(zone, order, migratetype);
 
-		/*
-		 * Use MIGRATE_RESERVE rather than fail an allocation. goto
-		 * is used because __rmqueue_smallest is an inline function
-		 * and we want just one call site
-		 */
-		if (!page) {
-			migratetype = MIGRATE_RESERVE;
-			goto retry_reserve;
-		}
-	}
+	if (unlikely(!page))
+		page = __rmqueue_smallest(zone, order, MIGRATE_RESERVE);
 
 	trace_mm_page_alloc_zone_locked(page, order, migratetype);
 	return page;
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
