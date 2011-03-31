Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 130518D0047
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 09:16:16 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from spt2.w1.samsung.com ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LIX006AHBIYFT50@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 31 Mar 2011 14:16:12 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LIX0034YBIYLP@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 31 Mar 2011 14:16:10 +0100 (BST)
Date: Thu, 31 Mar 2011 15:16:04 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 08/12] mm: MIGRATE_CMA isolation functions added
In-reply-to: <1301577368-16095-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1301577368-16095-9-git-send-email-m.szyprowski@samsung.com>
References: <1301577368-16095-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-samsung-soc@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, Mel Gorman <mel@csn.ul.ie>, Pawel Osciak <pawel@osciak.com>

From: Michal Nazarewicz <m.nazarewicz@samsung.com>

This commit changes various functions that change pages and
pageblocks migrate type between MIGRATE_ISOLATE and
MIGRATE_MOVABLE in such a way as to allow to work with
MIGRATE_CMA migrate type.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
CC: Michal Nazarewicz <mina86@mina86.com>
---
 include/linux/page-isolation.h |   40 +++++++++++++++++++++++++++-------------
 mm/page_alloc.c                |   19 ++++++++++++-------
 mm/page_isolation.c            |   15 ++++++++-------
 3 files changed, 47 insertions(+), 27 deletions(-)

diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index c5d1a7c..177b307 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -3,39 +3,53 @@
 
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
 extern unsigned long alloc_contig_freed_pages(unsigned long start,
 					      unsigned long end, gfp_t flag);
 extern int alloc_contig_range(unsigned long start, unsigned long end,
-			      gfp_t flags);
+			      gfp_t flags, unsigned migratetype);
 extern void free_contig_pages(struct page *page, int nr_pages);
 
 /*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 24f795e..5f4232d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5586,7 +5586,7 @@ out:
 	return ret;
 }
 
-void unset_migratetype_isolate(struct page *page)
+void __unset_migratetype_isolate(struct page *page, unsigned migratetype)
 {
 	struct zone *zone;
 	unsigned long flags;
@@ -5594,8 +5594,8 @@ void unset_migratetype_isolate(struct page *page)
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
@@ -5700,6 +5700,10 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
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
@@ -5711,7 +5715,7 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
  * need to be freed with free_contig_pages().
  */
 int alloc_contig_range(unsigned long start, unsigned long end,
-		       gfp_t flags)
+		       gfp_t flags, unsigned migratetype)
 {
 	unsigned long _start, _end;
 	int ret;
@@ -5739,8 +5743,8 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	 * them.
 	 */
 
-	ret = start_isolate_page_range(pfn_to_maxpage(start),
-				       pfn_to_maxpage_up(end));
+	ret = __start_isolate_page_range(pfn_to_maxpage(start),
+					 pfn_to_maxpage_up(end), migratetype);
 	if (ret)
 		goto done;
 
@@ -5778,7 +5782,8 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 
 	ret = 0;
 done:
-	undo_isolate_page_range(pfn_to_maxpage(start), pfn_to_maxpage_up(end));
+	__undo_isolate_page_range(pfn_to_maxpage(start), pfn_to_maxpage_up(end),
+				  migratetype);
 	return ret;
 }
 
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 8a3122c..d36f082 100644
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
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
