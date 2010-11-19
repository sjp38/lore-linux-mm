Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BEC446B0095
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 10:58:33 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from eu_spt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LC500JE631F4A20@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 19 Nov 2010 15:58:27 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LC500IPZ31E0K@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 19 Nov 2010 15:58:27 +0000 (GMT)
Date: Fri, 19 Nov 2010 16:58:09 +0100
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [RFCv6 11/13] mm: MIGRATE_CMA isolation functions added
In-reply-to: <cover.1290172312.git.m.nazarewicz@samsung.com>
Message-id: 
 <af6afb66dfbd7b8943b6b65bf2c0cebd63b2e4ef.1290172312.git.m.nazarewicz@samsung.com>
References: <cover.1290172312.git.m.nazarewicz@samsung.com>
Sender: owner-linux-mm@kvack.org
To: mina86@mina86.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, Bryan Huntsman <bryanh@codeaurora.org>, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Johan Mossberg <johan.xx.mossberg@stericsson.com>, Jonathan Corbet <corbet@lwn.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Marcus LORENTZON <marcus.xm.lorentzon@stericsson.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Mel Gorman <mel@csn.ul.ie>, Pawel Osciak <pawel@osciak.com>, Russell King <linux@arm.linux.org.uk>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, dipankar@in.ibm.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This commit changes various functions that change pages and
pageblocks migrate type between MIGRATE_ISOLATE and
MIGRATE_MOVABLE in such a way as to allow to work with
MIGRATE_CMA migrate type.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 include/linux/page-isolation.h |   39 ++++++++++++++++++++++++++-------------
 mm/page_alloc.c                |    6 +++---
 mm/page_isolation.c            |   15 ++++++++-------
 3 files changed, 37 insertions(+), 23 deletions(-)

diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index f1417ed..56f0e13 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -3,35 +3,49 @@
 
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
 extern void free_contig_pages(struct page *page, int nr_pages);
@@ -39,7 +53,6 @@ extern void free_contig_pages(struct page *page, int nr_pages);
 /*
  * For migration.
  */
-
 int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn);
 unsigned long scan_lru_pages(unsigned long start, unsigned long end);
 int do_migrate_range(unsigned long start_pfn, unsigned long end_pfn);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 91daf22..a24193e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5463,7 +5463,7 @@ out:
 	return ret;
 }
 
-void unset_migratetype_isolate(struct page *page)
+void __unset_migratetype_isolate(struct page *page, unsigned migratetype)
 {
 	struct zone *zone;
 	unsigned long flags;
@@ -5471,8 +5471,8 @@ void unset_migratetype_isolate(struct page *page)
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
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 077cf19..ea9781e 100644
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
1.7.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
