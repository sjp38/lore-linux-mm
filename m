Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A798C8E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 12:54:01 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id o21so5274435edq.4
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 09:54:01 -0800 (PST)
Received: from outbound-smtp25.blacknight.com (outbound-smtp25.blacknight.com. [81.17.249.193])
        by mx.google.com with ESMTPS id 25si2894796edv.63.2019.01.18.09.53.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 09:53:59 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp25.blacknight.com (Postfix) with ESMTPS id 49873B87ED
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 17:53:59 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 13/22] mm, compaction: Finish pageblock scanning on contention
Date: Fri, 18 Jan 2019 17:51:27 +0000
Message-Id: <20190118175136.31341-14-mgorman@techsingularity.net>
In-Reply-To: <20190118175136.31341-1-mgorman@techsingularity.net>
References: <20190118175136.31341-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

Async migration aborts on spinlock contention but contention can be high
when there are multiple compaction attempts and kswapd is active. The
consequence is that the migration scanners move forward uselessly while
still contending on locks for longer while leaving suitable migration
sources behind.

This patch will acquire the lock but track when contention occurs. When
it does, the current pageblock will finish as compaction may succeed for
that block and then abort. This will have a variable impact on latency as
in some cases useless scanning is avoided (reduces latency) but a lock
will be contended (increase latency) or a single contended pageblock is
scanned that would otherwise have been skipped (increase latency).

                                     5.0.0-rc1              5.0.0-rc1
                                norescan-v3r16    finishcontend-v3r16
Amean     fault-both-1         0.00 (   0.00%)        0.00 *   0.00%*
Amean     fault-both-3      3002.07 (   0.00%)     3153.17 (  -5.03%)
Amean     fault-both-5      4684.47 (   0.00%)     4280.52 (   8.62%)
Amean     fault-both-7      6815.54 (   0.00%)     5811.50 *  14.73%*
Amean     fault-both-12    10864.02 (   0.00%)     9276.85 (  14.61%)
Amean     fault-both-18    12247.52 (   0.00%)    11032.67 (   9.92%)
Amean     fault-both-24    15683.99 (   0.00%)    14285.70 (   8.92%)
Amean     fault-both-30    18620.02 (   0.00%)    16293.76 *  12.49%*
Amean     fault-both-32    19250.28 (   0.00%)    16721.02 *  13.14%*

                                5.0.0-rc1              5.0.0-rc1
                           norescan-v3r16    finishcontend-v3r16
Percentage huge-1         0.00 (   0.00%)        0.00 (   0.00%)
Percentage huge-3        95.00 (   0.00%)       96.82 (   1.92%)
Percentage huge-5        94.22 (   0.00%)       95.40 (   1.26%)
Percentage huge-7        92.35 (   0.00%)       95.92 (   3.86%)
Percentage huge-12       91.90 (   0.00%)       96.73 (   5.25%)
Percentage huge-18       89.58 (   0.00%)       96.77 (   8.03%)
Percentage huge-24       90.03 (   0.00%)       96.05 (   6.69%)
Percentage huge-30       89.14 (   0.00%)       96.81 (   8.60%)
Percentage huge-32       90.58 (   0.00%)       97.41 (   7.54%)

There is a variable impact that is mostly good on latency while allocation
success rates are slightly higher. System CPU usage is reduced by about
10% but scan rate impact is mixed

Compaction migrate scanned    27997659.00    20148867
Compaction free scanned      120782791.00   118324914

Migration scan rates are reduced 28% which is expected as a pageblock
is used by the async scanner instead of skipped. The impact on the free
scanner is known to be variable.  Overall the primary justification for
this patch is that completing scanning of a pageblock is very important
for later patches.

[yuehaibing@huawei.com: Fix unused variable warning]
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 90 ++++++++++++++++++++++-----------------------------------
 1 file changed, 34 insertions(+), 56 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index a31fea7b3f96..b261c0bfac24 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -382,24 +382,25 @@ static bool test_and_set_skip(struct compact_control *cc, struct page *page,
 
 /*
  * Compaction requires the taking of some coarse locks that are potentially
- * very heavily contended. For async compaction, back out if the lock cannot
- * be taken immediately. For sync compaction, spin on the lock if needed.
+ * very heavily contended. For async compaction, trylock and record if the
+ * lock is contended. The lock will still be acquired but compaction will
+ * abort when the current block is finished regardless of success rate.
+ * Sync compaction acquires the lock.
  *
- * Returns true if the lock is held
- * Returns false if the lock is not held and compaction should abort
+ * Always returns true which makes it easier to track lock state in callers.
  */
-static bool compact_trylock_irqsave(spinlock_t *lock, unsigned long *flags,
+static bool compact_lock_irqsave(spinlock_t *lock, unsigned long *flags,
 						struct compact_control *cc)
 {
-	if (cc->mode == MIGRATE_ASYNC) {
-		if (!spin_trylock_irqsave(lock, *flags)) {
-			cc->contended = true;
-			return false;
-		}
-	} else {
-		spin_lock_irqsave(lock, *flags);
+	/* Track if the lock is contended in async mode */
+	if (cc->mode == MIGRATE_ASYNC && !cc->contended) {
+		if (spin_trylock_irqsave(lock, *flags))
+			return true;
+
+		cc->contended = true;
 	}
 
+	spin_lock_irqsave(lock, *flags);
 	return true;
 }
 
@@ -432,10 +433,8 @@ static bool compact_unlock_should_abort(spinlock_t *lock,
 	}
 
 	if (need_resched()) {
-		if (cc->mode == MIGRATE_ASYNC) {
+		if (cc->mode == MIGRATE_ASYNC)
 			cc->contended = true;
-			return true;
-		}
 		cond_resched();
 	}
 
@@ -455,10 +454,8 @@ static inline bool compact_should_abort(struct compact_control *cc)
 {
 	/* async compaction aborts if contended */
 	if (need_resched()) {
-		if (cc->mode == MIGRATE_ASYNC) {
+		if (cc->mode == MIGRATE_ASYNC)
 			cc->contended = true;
-			return true;
-		}
 
 		cond_resched();
 	}
@@ -535,18 +532,8 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 		 * recheck as well.
 		 */
 		if (!locked) {
-			/*
-			 * The zone lock must be held to isolate freepages.
-			 * Unfortunately this is a very coarse lock and can be
-			 * heavily contended if there are parallel allocations
-			 * or parallel compactions. For async compaction do not
-			 * spin on the lock and we acquire the lock as late as
-			 * possible.
-			 */
-			locked = compact_trylock_irqsave(&cc->zone->lock,
+			locked = compact_lock_irqsave(&cc->zone->lock,
 								&flags, cc);
-			if (!locked)
-				break;
 
 			/* Recheck this is a buddy page under lock */
 			if (!PageBuddy(page))
@@ -900,15 +887,9 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 		/* If we already hold the lock, we can skip some rechecking */
 		if (!locked) {
-			locked = compact_trylock_irqsave(zone_lru_lock(zone),
+			locked = compact_lock_irqsave(zone_lru_lock(zone),
 								&flags, cc);
 
-			/* Allow future scanning if the lock is contended */
-			if (!locked) {
-				clear_pageblock_skip(page);
-				break;
-			}
-
 			/* Try get exclusive access under lock */
 			if (!skip_updated) {
 				skip_updated = true;
@@ -951,9 +932,12 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 		/*
 		 * Avoid isolating too much unless this block is being
-		 * rescanned (e.g. dirty/writeback pages, parallel allocation).
+		 * rescanned (e.g. dirty/writeback pages, parallel allocation)
+		 * or a lock is contended. For contention, isolate quickly to
+		 * potentially remove one source of contention.
 		 */
-		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX && !cc->rescan) {
+		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX &&
+		    !cc->rescan && !cc->contended) {
 			++low_pfn;
 			break;
 		}
@@ -1416,12 +1400,8 @@ static void isolate_freepages(struct compact_control *cc)
 		isolate_freepages_block(cc, &isolate_start_pfn, block_end_pfn,
 					freelist, false);
 
-		/*
-		 * If we isolated enough freepages, or aborted due to lock
-		 * contention, terminate.
-		 */
-		if ((cc->nr_freepages >= cc->nr_migratepages)
-							|| cc->contended) {
+		/* Are enough freepages isolated? */
+		if (cc->nr_freepages >= cc->nr_migratepages) {
 			if (isolate_start_pfn >= block_end_pfn) {
 				/*
 				 * Restart at previous pageblock if more
@@ -1463,13 +1443,8 @@ static struct page *compaction_alloc(struct page *migratepage,
 	struct compact_control *cc = (struct compact_control *)data;
 	struct page *freepage;
 
-	/*
-	 * Isolate free pages if necessary, and if we are not aborting due to
-	 * contention.
-	 */
 	if (list_empty(&cc->freepages)) {
-		if (!cc->contended)
-			isolate_freepages(cc);
+		isolate_freepages(cc);
 
 		if (list_empty(&cc->freepages))
 			return NULL;
@@ -1731,7 +1706,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 		low_pfn = isolate_migratepages_block(cc, low_pfn,
 						block_end_pfn, isolate_mode);
 
-		if (!low_pfn || cc->contended)
+		if (!low_pfn)
 			return ISOLATE_ABORT;
 
 		/*
@@ -1761,9 +1736,7 @@ static enum compact_result __compact_finished(struct compact_control *cc)
 {
 	unsigned int order;
 	const int migratetype = cc->migratetype;
-
-	if (cc->contended || fatal_signal_pending(current))
-		return COMPACT_CONTENDED;
+	int ret;
 
 	/* Compaction run completes if the migrate and free scanner meet */
 	if (compact_scanners_met(cc)) {
@@ -1798,6 +1771,7 @@ static enum compact_result __compact_finished(struct compact_control *cc)
 		return COMPACT_CONTINUE;
 
 	/* Direct compactor: Is a suitable page free? */
+	ret = COMPACT_NO_SUITABLE_PAGE;
 	for (order = cc->order; order < MAX_ORDER; order++) {
 		struct free_area *area = &cc->zone->free_area[order];
 		bool can_steal;
@@ -1837,11 +1811,15 @@ static enum compact_result __compact_finished(struct compact_control *cc)
 				return COMPACT_SUCCESS;
 			}
 
-			return COMPACT_CONTINUE;
+			ret = COMPACT_CONTINUE;
+			break;
 		}
 	}
 
-	return COMPACT_NO_SUITABLE_PAGE;
+	if (cc->contended || fatal_signal_pending(current))
+		ret = COMPACT_CONTENDED;
+
+	return ret;
 }
 
 static enum compact_result compact_finished(struct compact_control *cc)
-- 
2.16.4
