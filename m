Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id D07E86B00EC
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 11:49:08 -0500 (EST)
Received: from euspt2 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LZT00JT501P7G@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 22 Feb 2012 16:49:02 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LZT001G601OXV@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 22 Feb 2012 16:49:01 +0000 (GMT)
Date: Wed, 22 Feb 2012 17:48:45 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv23 04/16] mm: compaction: introduce isolate_freepages_range()
In-reply-to: <1329929337-16648-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1329929337-16648-5-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1329929337-16648-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, Rob Clark <rob.clark@linaro.org>, Ohad Ben-Cohen <ohad@wizery.com>

From: Michal Nazarewicz <mina86@mina86.com>

This commit introduces isolate_freepages_range() function which
generalises isolate_freepages_block() so that it can be used on
arbitrary PFN ranges.

isolate_freepages_block() is left with only minor changes.

Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Tested-by: Rob Clark <rob.clark@linaro.org>
Tested-by: Ohad Ben-Cohen <ohad@wizery.com>
Tested-by: Benjamin Gaignard <benjamin.gaignard@linaro.org>
Tested-by: Robert Nelson <robertcnelson@gmail.com>
---
 mm/compaction.c |  111 ++++++++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 93 insertions(+), 18 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index d9d7b35..06b198f 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -54,24 +54,20 @@ static unsigned long release_freepages(struct list_head *freelist)
 	return count;
 }
 
-/* Isolate free pages onto a private freelist. Must hold zone->lock */
-static unsigned long isolate_freepages_block(struct zone *zone,
-				unsigned long blockpfn,
-				struct list_head *freelist)
+/*
+ * Isolate free pages onto a private freelist. Caller must hold zone->lock.
+ * If @strict is true, will abort returning 0 on any invalid PFNs or non-free
+ * pages inside of the pageblock (even though it may still end up isolating
+ * some pages).
+ */
+static unsigned long isolate_freepages_block(unsigned long blockpfn,
+				unsigned long end_pfn,
+				struct list_head *freelist,
+				bool strict)
 {
-	unsigned long zone_end_pfn, end_pfn;
 	int nr_scanned = 0, total_isolated = 0;
 	struct page *cursor;
 
-	/* Get the last PFN we should scan for free pages at */
-	zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
-	end_pfn = min(blockpfn + pageblock_nr_pages, zone_end_pfn);
-
-	/* Find the first usable PFN in the block to initialse page cursor */
-	for (; blockpfn < end_pfn; blockpfn++) {
-		if (pfn_valid_within(blockpfn))
-			break;
-	}
 	cursor = pfn_to_page(blockpfn);
 
 	/* Isolate free pages. This assumes the block is valid */
@@ -79,15 +75,23 @@ static unsigned long isolate_freepages_block(struct zone *zone,
 		int isolated, i;
 		struct page *page = cursor;
 
-		if (!pfn_valid_within(blockpfn))
+		if (!pfn_valid_within(blockpfn)) {
+			if (strict)
+				return 0;
 			continue;
+		}
 		nr_scanned++;
 
-		if (!PageBuddy(page))
+		if (!PageBuddy(page)) {
+			if (strict)
+				return 0;
 			continue;
+		}
 
 		/* Found a free page, break it into order-0 pages */
 		isolated = split_free_page(page);
+		if (!isolated && strict)
+			return 0;
 		total_isolated += isolated;
 		for (i = 0; i < isolated; i++) {
 			list_add(&page->lru, freelist);
@@ -105,6 +109,73 @@ static unsigned long isolate_freepages_block(struct zone *zone,
 	return total_isolated;
 }
 
+/**
+ * isolate_freepages_range() - isolate free pages.
+ * @start_pfn: The first PFN to start isolating.
+ * @end_pfn:   The one-past-last PFN.
+ *
+ * Non-free pages, invalid PFNs, or zone boundaries within the
+ * [start_pfn, end_pfn) range are considered errors, cause function to
+ * undo its actions and return zero.
+ *
+ * Otherwise, function returns one-past-the-last PFN of isolated page
+ * (which may be greater then end_pfn if end fell in a middle of
+ * a free page).
+ */
+static unsigned long
+isolate_freepages_range(unsigned long start_pfn, unsigned long end_pfn)
+{
+	unsigned long isolated, pfn, block_end_pfn, flags;
+	struct zone *zone = NULL;
+	LIST_HEAD(freelist);
+
+	if (pfn_valid(start_pfn))
+		zone = page_zone(pfn_to_page(start_pfn));
+
+	for (pfn = start_pfn; pfn < end_pfn; pfn += isolated) {
+		if (!pfn_valid(pfn) || zone != page_zone(pfn_to_page(pfn)))
+			break;
+
+		/*
+		 * On subsequent iterations ALIGN() is actually not needed,
+		 * but we keep it that we not to complicate the code.
+		 */
+		block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
+		block_end_pfn = min(block_end_pfn, end_pfn);
+
+		spin_lock_irqsave(&zone->lock, flags);
+		isolated = isolate_freepages_block(pfn, block_end_pfn,
+						   &freelist, true);
+		spin_unlock_irqrestore(&zone->lock, flags);
+
+		/*
+		 * In strict mode, isolate_freepages_block() returns 0 if
+		 * there are any holes in the block (ie. invalid PFNs or
+		 * non-free pages).
+		 */
+		if (!isolated)
+			break;
+
+		/*
+		 * If we managed to isolate pages, it is always (1 << n) *
+		 * pageblock_nr_pages for some non-negative n.  (Max order
+		 * page may span two pageblocks).
+		 */
+	}
+
+	/* split_free_page does not map the pages */
+	map_pages(&freelist);
+
+	if (pfn < end_pfn) {
+		/* Loop terminated early, cleanup. */
+		release_freepages(&freelist);
+		return 0;
+	}
+
+	/* We don't use freelists for anything. */
+	return pfn;
+}
+
 /* Returns true if the page is within a block suitable for migration to */
 static bool suitable_migration_target(struct page *page)
 {
@@ -145,7 +216,7 @@ static void isolate_freepages(struct zone *zone,
 				struct compact_control *cc)
 {
 	struct page *page;
-	unsigned long high_pfn, low_pfn, pfn;
+	unsigned long high_pfn, low_pfn, pfn, zone_end_pfn, end_pfn;
 	unsigned long flags;
 	int nr_freepages = cc->nr_freepages;
 	struct list_head *freelist = &cc->freepages;
@@ -165,6 +236,8 @@ static void isolate_freepages(struct zone *zone,
 	 */
 	high_pfn = min(low_pfn, pfn);
 
+	zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
+
 	/*
 	 * Isolate free pages until enough are available to migrate the
 	 * pages on cc->migratepages. We stop searching if the migrate
@@ -201,7 +274,9 @@ static void isolate_freepages(struct zone *zone,
 		isolated = 0;
 		spin_lock_irqsave(&zone->lock, flags);
 		if (suitable_migration_target(page)) {
-			isolated = isolate_freepages_block(zone, pfn, freelist);
+			end_pfn = min(pfn + pageblock_nr_pages, zone_end_pfn);
+			isolated = isolate_freepages_block(pfn, end_pfn,
+							   freelist, false);
 			nr_freepages += isolated;
 		}
 		spin_unlock_irqrestore(&zone->lock, flags);
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
