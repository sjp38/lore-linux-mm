Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6702E6B0078
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 12:27:18 -0400 (EDT)
Date: Tue, 7 Jun 2011 17:27:11 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 4/4] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous V2
Message-ID: <20110607162711.GO5247@suse.de>
References: <1307459225-4481-1-git-send-email-mgorman@suse.de>
 <1307459225-4481-5-git-send-email-mgorman@suse.de>
 <20110607155029.GL1686@barrios-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110607155029.GL1686@barrios-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Sattler <tsattler@gmx.de>, Ury Stankevich <urykhy@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Changelog since V1
  o Return COMPACT_PARTIAL when aborting due to too many isolated
    pages. As pointed out by Minchan, this is better for consistency

Asynchronous compaction is used when promoting to huge pages. This is
all very nice but if there are a number of processes in compacting
memory, a large number of pages can be isolated. An "asynchronous"
process can stall for long periods of time as a result with a user
reporting that firefox can stall for 10s of seconds. This patch aborts
asynchronous compaction if too many pages are isolated as it's better to
fail a hugepage promotion than stall a process.

[minchan.kim@gmail.com: Return COMPACT_PARTIAL for abort]
Reported-and-tested-by: Ury Stankevich <urykhy@gmail.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/compaction.c |   29 ++++++++++++++++++++++++-----
 1 files changed, 24 insertions(+), 5 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 5c744ab..e4e0166 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -251,11 +251,18 @@ static bool too_many_isolated(struct zone *zone)
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
  */
-static unsigned long isolate_migratepages(struct zone *zone,
+static isolate_migrate_t isolate_migratepages(struct zone *zone,
 					struct compact_control *cc)
 {
 	unsigned long low_pfn, end_pfn;
@@ -272,7 +279,7 @@ static unsigned long isolate_migratepages(struct zone *zone,
 	/* Do not cross the free scanner or scan within a memory hole */
 	if (end_pfn > cc->free_pfn || !pfn_valid(low_pfn)) {
 		cc->migrate_pfn = end_pfn;
-		return 0;
+		return ISOLATE_NONE;
 	}
 
 	/*
@@ -281,10 +288,14 @@ static unsigned long isolate_migratepages(struct zone *zone,
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
@@ -369,7 +380,7 @@ static unsigned long isolate_migratepages(struct zone *zone,
 
 	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
 
-	return cc->nr_migratepages;
+	return ISOLATE_SUCCESS;
 }
 
 /*
@@ -533,8 +544,15 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		unsigned long nr_migrate, nr_remaining;
 		int err;
 
-		if (!isolate_migratepages(zone, cc))
+		switch (isolate_migratepages(zone, cc)) {
+		case ISOLATE_ABORT:
+			ret = COMPACT_PARTIAL;
+			goto out;
+		case ISOLATE_NONE:
 			continue;
+		case ISOLATE_SUCCESS:
+			;
+		}
 
 		nr_migrate = cc->nr_migratepages;
 		err = migrate_pages(&cc->migratepages, compaction_alloc,
@@ -558,6 +576,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 
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
