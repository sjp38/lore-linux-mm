Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id A96F56B0035
	for <linux-mm@kvack.org>; Mon, 12 May 2014 10:15:26 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id d17so4694272eek.16
        for <linux-mm@kvack.org>; Mon, 12 May 2014 07:15:26 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t3si10684185eeg.61.2014.05.12.07.15.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 May 2014 07:15:25 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH] mm, compaction: properly signal and act upon lock and need_sched() contention
Date: Mon, 12 May 2014 16:15:11 +0200
Message-Id: <1399904111-23520-1-git-send-email-vbabka@suse.cz>
In-Reply-To: <20140508051747.GA9161@js1304-P5Q-DELUXE>
References: <20140508051747.GA9161@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

Compaction uses compact_checklock_irqsave() function to periodically check for
lock contention and need_resched() to either abort async compaction, or to
free the lock, schedule and retake the lock. When aborting, cc->contended is
set to signal the contended state to the caller. Two problems have been
identified in this mechanism.

First, compaction also calls directly cond_resched() in both scanners when no
lock is yet taken. This call either does not abort async compaction, or set
cc->contended appropriately. This patch introduces a new
compact_check_resched() function to achieve both.

Second, isolate_freepages() does not check if isolate_freepages_block()
aborted due to contention, and advances to the next pageblock. This violates
the principle of aborting on contention, and might result in pageblocks not
being scanned completely, since the scanning cursor is advanced. This patch
makes isolate_freepages_block() check the cc->contended flag and abort.

Reported-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/compaction.c | 40 +++++++++++++++++++++++++++++++++-------
 1 file changed, 33 insertions(+), 7 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 83ca6f9..b34ab7c 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -222,6 +222,27 @@ static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
 	return true;
 }
 
+/*
+ * Similar to compact_checklock_irqsave() (see its comment) for places where
+ * a zone lock is not concerned.
+ *
+ * Returns false when compaction should abort.
+ */
+static inline bool compact_check_resched(struct compact_control *cc)
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
@@ -491,11 +512,8 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 			return 0;
 	}
 
-	if (cond_resched()) {
-		/* Async terminates prematurely on need_resched() */
-		if (cc->mode == MIGRATE_ASYNC)
-			return 0;
-	}
+	if (!compact_check_resched(cc))
+		return 0;
 
 	/* Time to isolate some pages for migration */
 	for (; low_pfn < end_pfn; low_pfn++) {
@@ -718,9 +736,10 @@ static void isolate_freepages(struct zone *zone,
 		/*
 		 * This can iterate a massively long zone without finding any
 		 * suitable migration targets, so periodically check if we need
-		 * to schedule.
+		 * to schedule, or even abort async compaction.
 		 */
-		cond_resched();
+		if (!compact_check_resched(cc))
+			break;
 
 		if (!pfn_valid(block_start_pfn))
 			continue;
@@ -758,6 +777,13 @@ static void isolate_freepages(struct zone *zone,
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
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
