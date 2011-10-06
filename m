Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 4A3AE6B0289
	for <linux-mm@kvack.org>; Thu,  6 Oct 2011 09:54:59 -0400 (EDT)
Received: from euspt2 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LSN00FWMDBH20@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Thu, 06 Oct 2011 14:54:56 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LSN00KGPDBISK@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 06 Oct 2011 14:54:54 +0100 (BST)
Date: Thu, 06 Oct 2011 15:54:45 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 5/9] mm: MIGRATE_CMA isolation functions added
In-reply-to: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1317909290-29832-6-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

From: Michal Nazarewicz <m.nazarewicz@samsung.com>

This commit changes various functions that change pages and
pageblocks migrate type between MIGRATE_ISOLATE and
MIGRATE_MOVABLE in such a way as to allow to work with
MIGRATE_CMA migrate type.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
[m.nazarewicz: fixed incorrect handling of pages from ISOLATE page blocks]
Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
Acked-by: Arnd Bergmann <arnd@arndb.de>
---
 include/linux/page-isolation.h |   40 +++++++++++++++++++++++++++-------------
 mm/page_alloc.c                |   31 ++++++++++++++++++++++++-------
 mm/page_isolation.c            |   17 +++++++++--------
 3 files changed, 60 insertions(+), 28 deletions(-)

diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index 9b6aa8a..003c52f 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -3,41 +3,55 @@
 
 /*
  * Changes migrate type in [start_pfn, end_pfn) to be MIGRATE_ISOLATE.
- * If specified range includes migrate types other than MOVABLE,
+ * If specified range includes migrate types other than MOVABLE or CMA,
  * this will fail with -EBUSY.
  *
  * For isolating all pages in the range finally, the caller have to
  * free all pages in the range. test_page_isolated() can be used for
  * test it.
  */
-extern int
-start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn);
+int __start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
+			       unsigned migratetype);
+
+static inline int
+start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn)
+{
+	return __start_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
+}
+
+int __undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
+			      unsigned migratetype);
 
 /*
  * Changes MIGRATE_ISOLATE to MIGRATE_MOVABLE.
  * target range is [start_pfn, end_pfn)
  */
-extern int
-undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn);
+static inline int
+undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn)
+{
+	return __undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
+}
 
 /*
- * test all pages in [start_pfn, end_pfn)are isolated or not.
+ * Test all pages in [start_pfn, end_pfn) are isolated or not.
  */
-extern int
-test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn);
+int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn);
 
 /*
- * Internal funcs.Changes pageblock's migrate type.
- * Please use make_pagetype_isolated()/make_pagetype_movable().
+ * Internal functions. Changes pageblock's migrate type.
  */
-extern int set_migratetype_isolate(struct page *page);
-extern void unset_migratetype_isolate(struct page *page);
+int set_migratetype_isolate(struct page *page);
+void __unset_migratetype_isolate(struct page *page, unsigned migratetype);
+static inline void unset_migratetype_isolate(struct page *page)
+{
+	__unset_migratetype_isolate(page, MIGRATE_MOVABLE);
+}
 
 /* The below functions must be run on a range from a single zone. */
 extern unsigned long alloc_contig_freed_pages(unsigned long start,
 					      unsigned long end, gfp_t flag);
 extern int alloc_contig_range(unsigned long start, unsigned long end,
-			      gfp_t flags);
+			      gfp_t flags, unsigned migratetype);
 extern void free_contig_pages(unsigned long pfn, unsigned nr_pages);
 
 /*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6758b9a..6dd6fb5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -641,6 +641,18 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			page = list_entry(list->prev, struct page, lru);
 			/* must delete as __free_one_page list manipulates */
 			list_del(&page->lru);
+
+			/*
+			 * When page is isolated in set_migratetype_isolate()
+			 * function it's page_private is not changed since the
+			 * function has no way of knowing if it can touch it.
+			 * This means that when a page is on PCP list, it's
+			 * page_private no longer matches the desired migrate
+			 * type.
+			 */
+			if (get_pageblock_migratetype(page) == MIGRATE_ISOLATE)
+				set_page_private(page, MIGRATE_ISOLATE);
+
 			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
 			__free_one_page(page, zone, 0, page_private(page));
 			trace_mm_page_pcpu_drain(page, 0, page_private(page));
@@ -5733,7 +5745,7 @@ out:
 	return ret;
 }
 
-void unset_migratetype_isolate(struct page *page)
+void __unset_migratetype_isolate(struct page *page, unsigned migratetype)
 {
 	struct zone *zone;
 	unsigned long flags;
@@ -5741,8 +5753,8 @@ void unset_migratetype_isolate(struct page *page)
 	spin_lock_irqsave(&zone->lock, flags);
 	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
 		goto out;
-	set_pageblock_migratetype(page, MIGRATE_MOVABLE);
-	move_freepages_block(zone, page, MIGRATE_MOVABLE);
+	set_pageblock_migratetype(page, migratetype);
+	move_freepages_block(zone, page, migratetype);
 out:
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
@@ -5880,6 +5892,10 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
  * @start:	start PFN to allocate
  * @end:	one-past-the-last PFN to allocate
  * @flags:	flags passed to alloc_contig_freed_pages().
+ * @migratetype:	migratetype of the underlaying pageblocks (either
+ *			#MIGRATE_MOVABLE or #MIGRATE_CMA).  All pageblocks
+ *			in range must have the same migratetype and it must
+ *			be either of the two.
  *
  * The PFN range does not have to be pageblock or MAX_ORDER_NR_PAGES
  * aligned, hovewer it's callers responsibility to guarantee that we
@@ -5891,7 +5907,7 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
  * need to be freed with free_contig_pages().
  */
 int alloc_contig_range(unsigned long start, unsigned long end,
-		       gfp_t flags)
+		       gfp_t flags, unsigned migratetype)
 {
 	unsigned long outer_start, outer_end;
 	int ret;
@@ -5919,8 +5935,8 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	 * them.
 	 */
 
-	ret = start_isolate_page_range(pfn_to_maxpage(start),
-				       pfn_to_maxpage_up(end));
+	ret = __start_isolate_page_range(pfn_to_maxpage(start),
+					 pfn_to_maxpage_up(end), migratetype);
 	if (ret)
 		goto done;
 
@@ -5958,7 +5974,8 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 
 	ret = 0;
 done:
-	undo_isolate_page_range(pfn_to_maxpage(start), pfn_to_maxpage_up(end));
+	__undo_isolate_page_range(pfn_to_maxpage(start), pfn_to_maxpage_up(end),
+				  migratetype);
 	return ret;
 }
 
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 270a026..bcbed1d 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -23,10 +23,11 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
 }
 
 /*
- * start_isolate_page_range() -- make page-allocation-type of range of pages
+ * __start_isolate_page_range() -- make page-allocation-type of range of pages
  * to be MIGRATE_ISOLATE.
  * @start_pfn: The lower PFN of the range to be isolated.
  * @end_pfn: The upper PFN of the range to be isolated.
+ * @migratetype: migrate type to set in error recovery.
  *
  * Making page-allocation-type to be MIGRATE_ISOLATE means free pages in
  * the range will never be allocated. Any free pages and pages freed in the
@@ -35,8 +36,8 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
  * start_pfn/end_pfn must be aligned to pageblock_order.
  * Returns 0 on success and -EBUSY if any part of range cannot be isolated.
  */
-int
-start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn)
+int __start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
+			       unsigned migratetype)
 {
 	unsigned long pfn;
 	unsigned long undo_pfn;
@@ -59,7 +60,7 @@ undo:
 	for (pfn = start_pfn;
 	     pfn < undo_pfn;
 	     pfn += pageblock_nr_pages)
-		unset_migratetype_isolate(pfn_to_page(pfn));
+		__unset_migratetype_isolate(pfn_to_page(pfn), migratetype);
 
 	return -EBUSY;
 }
@@ -67,8 +68,8 @@ undo:
 /*
  * Make isolated pages available again.
  */
-int
-undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn)
+int __undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
+			      unsigned migratetype)
 {
 	unsigned long pfn;
 	struct page *page;
@@ -80,7 +81,7 @@ undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn)
 		page = __first_valid_page(pfn, pageblock_nr_pages);
 		if (!page || get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
 			continue;
-		unset_migratetype_isolate(page);
+		__unset_migratetype_isolate(page, migratetype);
 	}
 	return 0;
 }
@@ -89,7 +90,7 @@ undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn)
  * all pages in [start_pfn...end_pfn) must be in the same zone.
  * zone->lock must be held before call this.
  *
- * Returns 1 if all pages in the range is isolated.
+ * Returns 1 if all pages in the range are isolated.
  */
 static int
 __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn)
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
