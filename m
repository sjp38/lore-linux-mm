Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 112686B004F
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 04:01:02 -0500 (EST)
Received: from euspt2 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LYE000ODEDO2M@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Thu, 26 Jan 2012 09:01:00 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LYE0019FEDNKG@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 26 Jan 2012 09:00:59 +0000 (GMT)
Date: Thu, 26 Jan 2012 10:00:45 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 03/15] mm: compaction: introduce isolate_migratepages_range().
In-reply-to: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1327568457-27734-4-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

From: Michal Nazarewicz <mina86@mina86.com>

This commit introduces isolate_migratepages_range() function which
extracts functionality from isolate_migratepages() so that it can be
used on arbitrary PFN ranges.

isolate_migratepages() function is implemented as a simple wrapper
around isolate_migratepages_range().

Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
---
 mm/compaction.c |   77 +++++++++++++++++++++++++++++++++++++++---------------
 1 files changed, 55 insertions(+), 22 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 71a58f6..a42bbdd 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -250,31 +250,34 @@ typedef enum {
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
+ * Apart from cc->migratepages and cc->nr_migratetypes this function
+ * does not modify any cc's fields, in particular it does not modify
+ * (or read for that matter) cc->migrate_pfn.
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
@@ -283,12 +286,12 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
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
@@ -313,7 +316,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 		} else if (!locked)
 			spin_lock_irq(&zone->lru_lock);
 
-		if (!pfn_valid_within(low_pfn))
+		if (!pfn_valid(low_pfn))
 			continue;
 		nr_scanned++;
 
@@ -374,10 +377,40 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
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
