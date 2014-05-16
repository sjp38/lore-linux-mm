Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id A3A2D6B004D
	for <linux-mm@kvack.org>; Fri, 16 May 2014 05:48:18 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id e51so1393524eek.9
        for <linux-mm@kvack.org>; Fri, 16 May 2014 02:48:17 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 49si6281617een.275.2014.05.16.02.48.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 16 May 2014 02:48:16 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2] mm, compaction: properly signal and act upon lock and need_sched() contention
Date: Fri, 16 May 2014 11:47:53 +0200
Message-Id: <1400233673-11477-1-git-send-email-vbabka@suse.cz>
In-Reply-To: <1399904111-23520-1-git-send-email-vbabka@suse.cz>
References: <1399904111-23520-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

Compaction uses compact_checklock_irqsave() function to periodically check for
lock contention and need_resched() to either abort async compaction, or to
free the lock, schedule and retake the lock. When aborting, cc->contended is
set to signal the contended state to the caller. Two problems have been
identified in this mechanism.

First, compaction also calls directly cond_resched() in both scanners when no
lock is yet taken. This call either does not abort async compaction, or set
cc->contended appropriately. This patch introduces a new compact_should_abort()
function to achieve both. In isolate_freepages(), the check frequency is
reduced to once by SWAP_CLUSTER_MAX pageblocks to match what the migration
scanner does in the preliminary page checks. In case a pageblock is found
suitable for calling isolate_freepages_block(), the checks within there are
done on higher frequency.

Second, isolate_freepages() does not check if isolate_freepages_block()
aborted due to contention, and advances to the next pageblock. This violates
the principle of aborting on contention, and might result in pageblocks not
being scanned completely, since the scanning cursor is advanced. This patch
makes isolate_freepages_block() check the cc->contended flag and abort.

In case isolate_freepages() has already isolated some pages before aborting
due to contention, page migration will proceed, which is OK since we do not
want to waste the work that has been done, and page migration has own checks
for contention. However, we do not want another isolation attempt by either
of the scanners, so cc->contended flag check is added also to
compaction_alloc() and compact_finished() to make sure compaction is aborted
right after the migration.

Reported-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
---
v2: update struct compact_control comment (per Naoya Horiguchi)
    rename to compact_should_abort() and add comments (per David Rientjes)
    add cc->contended checks in compaction_alloc() and compact_finished()
    (per Joonsoo Kim)
    reduce frequency of checks in isolate_freepages() 

 mm/compaction.c | 54 ++++++++++++++++++++++++++++++++++++++++++++----------
 mm/internal.h   |  5 ++++-
 2 files changed, 48 insertions(+), 11 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 83ca6f9..6fc9f18 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -222,6 +222,30 @@ static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
 	return true;
 }
 
+/*
+ * Aside from avoiding lock contention, compaction also periodically checks
+ * need_resched() and either schedules in sync compaction, or aborts async
+ * compaction. This is similar to compact_checklock_irqsave() does, but used
+ * where no lock is concerned.
+ *
+ * Returns false when no scheduling was needed, or sync compaction scheduled.
+ * Returns true when async compaction should abort.
+ */
+static inline bool compact_should_abort(struct compact_control *cc)
+{
+	/* async compaction aborts if contended */
+	if (need_resched()) {
+		if (cc->mode == MIGRATE_ASYNC) {
+			cc->contended = true;
+			return false;
+		}
+
+		cond_resched();
+	}
+
+	return true;
+}
+
 /* Returns true if the page is within a block suitable for migration to */
 static bool suitable_migration_target(struct page *page)
 {
@@ -491,11 +515,8 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 			return 0;
 	}
 
-	if (cond_resched()) {
-		/* Async terminates prematurely on need_resched() */
-		if (cc->mode == MIGRATE_ASYNC)
-			return 0;
-	}
+	if (compact_should_abort(cc))
+		return 0;
 
 	/* Time to isolate some pages for migration */
 	for (; low_pfn < end_pfn; low_pfn++) {
@@ -718,9 +739,11 @@ static void isolate_freepages(struct zone *zone,
 		/*
 		 * This can iterate a massively long zone without finding any
 		 * suitable migration targets, so periodically check if we need
-		 * to schedule.
+		 * to schedule, or even abort async compaction.
 		 */
-		cond_resched();
+		if (!(block_start_pfn % (SWAP_CLUSTER_MAX * pageblock_nr_pages))
+						&& compact_should_abort(cc))
+			break;
 
 		if (!pfn_valid(block_start_pfn))
 			continue;
@@ -758,6 +781,13 @@ static void isolate_freepages(struct zone *zone,
 		 */
 		if (isolated)
 			cc->finished_update_free = true;
+
+		/*
+		 * isolate_freepages_block() might have aborted due to async
+		 * compaction being contended
+		 */
+		if (cc->contended)
+			break;
 	}
 
 	/* split_free_page does not map the pages */
@@ -785,9 +815,13 @@ static struct page *compaction_alloc(struct page *migratepage,
 	struct compact_control *cc = (struct compact_control *)data;
 	struct page *freepage;
 
-	/* Isolate free pages if necessary */
+	/*
+	 * Isolate free pages if necessary, and if we are not aborting due to
+	 * contention.
+	 */
 	if (list_empty(&cc->freepages)) {
-		isolate_freepages(cc->zone, cc);
+		if (!cc->contended)
+			isolate_freepages(cc->zone, cc);
 
 		if (list_empty(&cc->freepages))
 			return NULL;
@@ -857,7 +891,7 @@ static int compact_finished(struct zone *zone,
 	unsigned int order;
 	unsigned long watermark;
 
-	if (fatal_signal_pending(current))
+	if (cc->contended || fatal_signal_pending(current))
 		return COMPACT_PARTIAL;
 
 	/* Compaction run completes if the migrate and free scanner meet */
diff --git a/mm/internal.h b/mm/internal.h
index a25424a..ad844ab 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -144,7 +144,10 @@ struct compact_control {
 	int order;			/* order a direct compactor needs */
 	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
 	struct zone *zone;
-	bool contended;			/* True if a lock was contended */
+	bool contended;			/* True if a lock was contended, or
+					 * need_resched() true during async
+					 * compaction
+					 */
 };
 
 unsigned long
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
