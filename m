Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1EDC36B007E
	for <linux-mm@kvack.org>; Wed, 16 Mar 2016 12:49:26 -0400 (EDT)
Received: by mail-wm0-f43.google.com with SMTP id p65so81285165wmp.0
        for <linux-mm@kvack.org>; Wed, 16 Mar 2016 09:49:26 -0700 (PDT)
Received: from metis.ext.pengutronix.de (metis.ext.pengutronix.de. [2001:67c:670:201:290:27ff:fe1d:cc33])
        by mx.google.com with ESMTPS id wl1si5044961wjc.217.2016.03.16.09.49.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 16 Mar 2016 09:49:24 -0700 (PDT)
From: Lucas Stach <l.stach@pengutronix.de>
Subject: [PATCH] mm/page_isolation: let caller take the zone lock for test_pages_isolated
Date: Wed, 16 Mar 2016 17:49:22 +0100
Message-Id: <1458146962-15401-1-git-send-email-l.stach@pengutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, kernel@pengutronix.de, patchwork-lst@pengutronix.de

This fixes an annoying race in the CMA code leading to lots of "PFNs busy"
messages when CMA is used concurrently. This is harmless normally as CMA
will just retry the allocation at a different place, but it might lead to
increased fragmentation of the CMA area as well as failing allocations
when CMA is under memory pressure.

The issue is that test_pages_isolated checks if the range is free by
checking that all pages in the range are buddy pages. For this to work
the start pfn needs to be aligned to the higher order buddy page
including the start pfn if there is any.

This is not a problem for the memory hotplug code, as it always offlines
whole pageblocks, but CMA may want to isolate a smaller range. So for
the check to work correctly it down-aligns the start pfn to the higher
order buddy page. As the zone is not yet locked at that point a
concurrent page free might coalesce the pages to be checked into an
even bigger buddy page, causing the check to fail, while all pages are
in fact buddy pages.

By moving the zone locking to the caller of the test function, it's
possible to do it before CMA tries to find the proper start page and stop
any concurrent page coalescing to happen until the check is finished.

Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
---
 mm/memory_hotplug.c |  2 ++
 mm/page_alloc.c     | 11 +++++++----
 mm/page_isolation.c | 13 ++++++++-----
 3 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 4af58a3a8ffa..05de25bd228e 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1828,7 +1828,9 @@ repeat:
 	 */
 	dissolve_free_huge_pages(start_pfn, end_pfn);
 	/* check again */
+	spin_lock_irqsave(&zone->lock, flags);
 	offlined_pages = check_pages_isolated(start_pfn, end_pfn);
+	spin_unlock_irqrestore(&zone->lock, flags);
 	if (offlined_pages < 0) {
 		ret = -EBUSY;
 		goto failed_removal;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 838ca8bb64f7..50b3b8f9594f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6702,14 +6702,15 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
 int alloc_contig_range(unsigned long start, unsigned long end,
 		       unsigned migratetype)
 {
-	unsigned long outer_start, outer_end;
+	struct zone *zone = page_zone(pfn_to_page(start));
+	unsigned long outer_start, outer_end, flags;
 	unsigned int order;
 	int ret = 0;
 
 	struct compact_control cc = {
 		.nr_migratepages = 0,
 		.order = -1,
-		.zone = page_zone(pfn_to_page(start)),
+		.zone = zone,
 		.mode = MIGRATE_SYNC,
 		.ignore_skip_hint = true,
 	};
@@ -6775,6 +6776,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 
 	order = 0;
 	outer_start = start;
+	spin_lock_irqsave(&zone->lock, flags);
 	while (!PageBuddy(pfn_to_page(outer_start))) {
 		if (++order >= MAX_ORDER) {
 			outer_start = start;
@@ -6797,10 +6799,11 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	}
 
 	/* Make sure the range is really isolated. */
-	if (test_pages_isolated(outer_start, end, false)) {
+	ret = test_pages_isolated(outer_start, end, false);
+	spin_unlock_irqrestore(&zone->lock, flags);
+	if (ret) {
 		pr_info("%s: [%lx, %lx) PFNs busy\n",
 			__func__, outer_start, end);
-		ret = -EBUSY;
 		goto done;
 	}
 
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 92c4c36501e7..357c8e39a08e 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -246,12 +246,18 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
 	return pfn;
 }
 
+/*
+ * Test all pages in the range are isolated.
+ * All pages in [start_pfn...end_pfn) must be in the same zone.
+ * zone->lock must be held before call this.
+ *
+ * Returns 0 if all pages in the range are isolated.
+ */
 int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 			bool skip_hwpoisoned_pages)
 {
-	unsigned long pfn, flags;
+	unsigned long pfn;
 	struct page *page;
-	struct zone *zone;
 
 	/*
 	 * Note: pageblock_nr_pages != MAX_ORDER. Then, chunks of free pages
@@ -267,11 +273,8 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 	if ((pfn < end_pfn) || !page)
 		return -EBUSY;
 	/* Check all pages are free or marked as ISOLATED */
-	zone = page_zone(page);
-	spin_lock_irqsave(&zone->lock, flags);
 	pfn = __test_page_isolated_in_pageblock(start_pfn, end_pfn,
 						skip_hwpoisoned_pages);
-	spin_unlock_irqrestore(&zone->lock, flags);
 
 	trace_test_pages_isolated(start_pfn, end_pfn, pfn);
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
