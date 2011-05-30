Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A45746B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 09:13:05 -0400 (EDT)
Date: Mon, 30 May 2011 14:13:00 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
Message-ID: <20110530131300.GQ5044@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org

Asynchronous compaction is used when promoting to huge pages. This is
all very nice but if there are a number of processes in compacting
memory, a large number of pages can be isolated. An "asynchronous"
process can stall for long periods of time as a result with a user
reporting that firefox can stall for 10s of seconds. This patch aborts
asynchronous compaction if too many pages are isolated as it's better to
fail a hugepage promotion than stall a process.

If accepted, this should also be considered for 2.6.39-stable. It should
also be considered for 2.6.38-stable but ideally [11bc82d6: mm:
compaction: Use async migration for __GFP_NO_KSWAPD and enforce no
writeback] would be applied to 2.6.38 before consideration.

Reported-and-Tested-by: Ury Stankevich <urykhy@gmail.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/compaction.c |   32 ++++++++++++++++++++++++++------
 1 files changed, 26 insertions(+), 6 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 021a296..331a2ee 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -240,11 +240,20 @@ static bool too_many_isolated(struct zone *zone)
 	return isolated > (inactive + active) / 2;
 }
 
+/* possible outcome of isolate_migratepages */
+typedef enum {
+	ISOLATE_ABORT,		/* Abort compaction now */
+	ISOLATE_NONE,		/* No pages isolated, continue scanning */
+	ISOLATE_SUCCESS,	/* Pages isolated, migrate */
+} isolate_migrate_t;
+
 /*
  * Isolate all pages that can be migrated from the block pointed to by
  * the migrate scanner within compact_control.
+ *
+ * Returns false if compaction should abort at this point due to congestion.
  */
-static unsigned long isolate_migratepages(struct zone *zone,
+static isolate_migrate_t isolate_migratepages(struct zone *zone,
 					struct compact_control *cc)
 {
 	unsigned long low_pfn, end_pfn;
@@ -261,7 +270,7 @@ static unsigned long isolate_migratepages(struct zone *zone,
 	/* Do not cross the free scanner or scan within a memory hole */
 	if (end_pfn > cc->free_pfn || !pfn_valid(low_pfn)) {
 		cc->migrate_pfn = end_pfn;
-		return 0;
+		return ISOLATE_NONE;
 	}
 
 	/*
@@ -270,10 +279,14 @@ static unsigned long isolate_migratepages(struct zone *zone,
 	 * delay for some time until fewer pages are isolated
 	 */
 	while (unlikely(too_many_isolated(zone))) {
+		/* async migration should just abort */
+		if (!cc->sync)
+			return ISOLATE_ABORT;
+
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 		if (fatal_signal_pending(current))
-			return 0;
+			return ISOLATE_ABORT;
 	}
 
 	/* Time to isolate some pages for migration */
@@ -358,7 +371,7 @@ static unsigned long isolate_migratepages(struct zone *zone,
 
 	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
 
-	return cc->nr_migratepages;
+	return ISOLATE_SUCCESS;
 }
 
 /*
@@ -522,9 +535,15 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		unsigned long nr_migrate, nr_remaining;
 		int err;
 
-		if (!isolate_migratepages(zone, cc))
+		switch (isolate_migratepages(zone, cc)) {
+		case ISOLATE_ABORT:
+			goto out;
+		case ISOLATE_NONE:
 			continue;
-
+		case ISOLATE_SUCCESS:
+			;
+		}
+		
 		nr_migrate = cc->nr_migratepages;
 		err = migrate_pages(&cc->migratepages, compaction_alloc,
 				(unsigned long)cc, false,
@@ -547,6 +566,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 
 	}
 
+out:
 	/* Release free pages and check accounting */
 	cc->nr_freepages -= release_freepages(&cc->freepages);
 	VM_BUG_ON(cc->nr_freepages != 0);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
