Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 05E3B6B0087
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 11:43:31 -0500 (EST)
Received: from euspt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LUV00LJ97S904@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 18 Nov 2011 16:43:21 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LUV00DUB7S8SU@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 18 Nov 2011 16:43:21 +0000 (GMT)
Date: Fri, 18 Nov 2011 17:43:09 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 02/11] mm: compaction: introduce
 isolate_{free,migrate}pages_range().
In-reply-to: <1321634598-16859-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1321634598-16859-3-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1321634598-16859-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

From: Michal Nazarewicz <mina86@mina86.com>

This commit introduces isolate_freepages_range() and
isolate_migratepages_range() functions.  The first one replaces
isolate_freepages_block() and the second one extracts functionality
from isolate_migratepages().

They are more generic and instead of operating on pageblocks operate
on PFN ranges.

Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
---
 mm/compaction.c |  170 ++++++++++++++++++++++++++++++++++++-------------------
 1 files changed, 111 insertions(+), 59 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 899d956..6afae0e 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -54,51 +54,64 @@ static unsigned long release_freepages(struct list_head *freelist)
 	return count;
 }
 
-/* Isolate free pages onto a private freelist. Must hold zone->lock */
-static unsigned long isolate_freepages_block(struct zone *zone,
-				unsigned long blockpfn,
-				struct list_head *freelist)
+/**
+ * isolate_freepages_range() - isolate free pages, must hold zone->lock.
+ * @zone:	Zone pages are in.
+ * @start:	The first PFN to start isolating.
+ * @end:	The one-past-last PFN.
+ * @freelist:	A list to save isolated pages to.
+ *
+ * If @freelist is not provided, holes in range (either non-free pages
+ * or invalid PFNs) are considered an error and function undos its
+ * actions and returns zero.
+ *
+ * If @freelist is provided, function will simply skip non-free and
+ * missing pages and put only the ones isolated on the list.
+ *
+ * Returns number of isolated pages.  This may be more then end-start
+ * if end fell in a middle of a free page.
+ */
+static unsigned long
+isolate_freepages_range(struct zone *zone,
+			unsigned long start, unsigned long end,
+			struct list_head *freelist)
 {
-	unsigned long zone_end_pfn, end_pfn;
-	int nr_scanned = 0, total_isolated = 0;
-	struct page *cursor;
-
-	/* Get the last PFN we should scan for free pages at */
-	zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
-	end_pfn = min(blockpfn + pageblock_nr_pages, zone_end_pfn);
+	unsigned long nr_scanned = 0, total_isolated = 0;
+	unsigned long pfn = start;
+	struct page *page;
 
-	/* Find the first usable PFN in the block to initialse page cursor */
-	for (; blockpfn < end_pfn; blockpfn++) {
-		if (pfn_valid_within(blockpfn))
-			break;
-	}
-	cursor = pfn_to_page(blockpfn);
+	VM_BUG_ON(!pfn_valid(pfn));
+	page = pfn_to_page(pfn);
 
 	/* Isolate free pages. This assumes the block is valid */
-	for (; blockpfn < end_pfn; blockpfn++, cursor++) {
-		int isolated, i;
-		struct page *page = cursor;
-
-		if (!pfn_valid_within(blockpfn))
-			continue;
-		nr_scanned++;
-
-		if (!PageBuddy(page))
-			continue;
+	while (pfn < end) {
+		unsigned isolated = 1, i;
+
+		if (!pfn_valid_within(pfn))
+			goto skip;
+		++nr_scanned;
+
+		if (!PageBuddy(page)) {
+skip:
+			if (freelist)
+				goto next;
+			for (; start < pfn; ++start)
+				__free_page(pfn_to_page(pfn));
+			return 0;
+		}
 
 		/* Found a free page, break it into order-0 pages */
 		isolated = split_free_page(page);
 		total_isolated += isolated;
-		for (i = 0; i < isolated; i++) {
-			list_add(&page->lru, freelist);
-			page++;
+		if (freelist) {
+			struct page *p = page;
+			for (i = isolated; i; --i, ++p)
+				list_add(&p->lru, freelist);
 		}
 
-		/* If a page was split, advance to the end of it */
-		if (isolated) {
-			blockpfn += isolated - 1;
-			cursor += isolated - 1;
-		}
+next:
+		pfn += isolated;
+		page += isolated;
 	}
 
 	trace_mm_compaction_isolate_freepages(nr_scanned, total_isolated);
@@ -135,7 +148,7 @@ static void isolate_freepages(struct zone *zone,
 				struct compact_control *cc)
 {
 	struct page *page;
-	unsigned long high_pfn, low_pfn, pfn;
+	unsigned long high_pfn, low_pfn, pfn, zone_end_pfn, end_pfn;
 	unsigned long flags;
 	int nr_freepages = cc->nr_freepages;
 	struct list_head *freelist = &cc->freepages;
@@ -155,6 +168,8 @@ static void isolate_freepages(struct zone *zone,
 	 */
 	high_pfn = min(low_pfn, pfn);
 
+	zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
+
 	/*
 	 * Isolate free pages until enough are available to migrate the
 	 * pages on cc->migratepages. We stop searching if the migrate
@@ -191,7 +206,9 @@ static void isolate_freepages(struct zone *zone,
 		isolated = 0;
 		spin_lock_irqsave(&zone->lock, flags);
 		if (suitable_migration_target(page)) {
-			isolated = isolate_freepages_block(zone, pfn, freelist);
+			end_pfn = min(pfn + pageblock_nr_pages, zone_end_pfn);
+			isolated = isolate_freepages_range(zone, pfn,
+					end_pfn, freelist);
 			nr_freepages += isolated;
 		}
 		spin_unlock_irqrestore(&zone->lock, flags);
@@ -250,31 +267,34 @@ typedef enum {
 	ISOLATE_SUCCESS,	/* Pages isolated, migrate */
 } isolate_migrate_t;
 
-/*
- * Isolate all pages that can be migrated from the block pointed to by
- * the migrate scanner within compact_control.
+/**
+ * isolate_migratepages_range() - isolate all migrate-able pages in range.
+ * @zone:	Zone pages are in.
+ * @cc:		Compaction control structure.
+ * @low_pfn:	The first PFN of the range.
+ * @end_pfn:	The one-past-the-last PFN of the range.
+ *
+ * Isolate all pages that can be migrated from the range specified by
+ * [low_pfn, end_pfn).  Returns zero if there is a fatal signal
+ * pending), otherwise PFN of the first page that was not scanned
+ * (which may be both less, equal to or more then end_pfn).
+ *
+ * Assumes that cc->migratepages is empty and cc->nr_migratepages is
+ * zero.
+ *
+ * Other then cc->migratepages and cc->nr_migratetypes this function
+ * does not modify any cc's fields, ie. it does not modify (or read
+ * for that matter) cc->migrate_pfn.
  */
-static isolate_migrate_t isolate_migratepages(struct zone *zone,
-					struct compact_control *cc)
+static unsigned long
+isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
+			   unsigned long low_pfn, unsigned long end_pfn)
 {
-	unsigned long low_pfn, end_pfn;
 	unsigned long last_pageblock_nr = 0, pageblock_nr;
 	unsigned long nr_scanned = 0, nr_isolated = 0;
 	struct list_head *migratelist = &cc->migratepages;
 	isolate_mode_t mode = ISOLATE_ACTIVE|ISOLATE_INACTIVE;
 
-	/* Do not scan outside zone boundaries */
-	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
-
-	/* Only scan within a pageblock boundary */
-	end_pfn = ALIGN(low_pfn + pageblock_nr_pages, pageblock_nr_pages);
-
-	/* Do not cross the free scanner or scan within a memory hole */
-	if (end_pfn > cc->free_pfn || !pfn_valid(low_pfn)) {
-		cc->migrate_pfn = end_pfn;
-		return ISOLATE_NONE;
-	}
-
 	/*
 	 * Ensure that there are not too many pages isolated from the LRU
 	 * list by either parallel reclaimers or compaction. If there are,
@@ -283,12 +303,12 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	while (unlikely(too_many_isolated(zone))) {
 		/* async migration should just abort */
 		if (!cc->sync)
-			return ISOLATE_ABORT;
+			return 0;
 
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 		if (fatal_signal_pending(current))
-			return ISOLATE_ABORT;
+			return 0;
 	}
 
 	/* Time to isolate some pages for migration */
@@ -365,17 +385,49 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 		nr_isolated++;
 
 		/* Avoid isolating too much */
-		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX)
+		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX) {
+			++low_pfn;
 			break;
+		}
 	}
 
 	acct_isolated(zone, cc);
 
 	spin_unlock_irq(&zone->lru_lock);
-	cc->migrate_pfn = low_pfn;
 
 	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
 
+	return low_pfn;
+}
+
+/*
+ * Isolate all pages that can be migrated from the block pointed to by
+ * the migrate scanner within compact_control.
+ */
+static isolate_migrate_t isolate_migratepages(struct zone *zone,
+					struct compact_control *cc)
+{
+	unsigned long low_pfn, end_pfn;
+
+	/* Do not scan outside zone boundaries */
+	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
+
+	/* Only scan within a pageblock boundary */
+	end_pfn = ALIGN(low_pfn + pageblock_nr_pages, pageblock_nr_pages);
+
+	/* Do not cross the free scanner or scan within a memory hole */
+	if (end_pfn > cc->free_pfn || !pfn_valid(low_pfn)) {
+		cc->migrate_pfn = end_pfn;
+		return ISOLATE_NONE;
+	}
+
+	/* Perform the isolation */
+	low_pfn = isolate_migratepages_range(zone, cc, low_pfn, end_pfn);
+	if (!low_pfn)
+		return ISOLATE_ABORT;
+
+	cc->migrate_pfn = low_pfn;
+
 	return ISOLATE_SUCCESS;
 }
 
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
