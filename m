Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 814868E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 07:52:57 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id f31so34824976edf.17
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 04:52:57 -0800 (PST)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id r18-v6si2062593ejf.218.2019.01.04.04.52.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 04:52:55 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 221F01C1C4F
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 12:52:55 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 15/25] mm, compaction: Finish pageblock scanning on contention
Date: Fri,  4 Jan 2019 12:50:01 +0000
Message-Id: <20190104125011.16071-16-mgorman@techsingularity.net>
In-Reply-To: <20190104125011.16071-1-mgorman@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

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

                                        4.20.0                 4.20.0
                                norescan-v2r15    finishcontend-v2r15
Amean     fault-both-1         0.00 (   0.00%)        0.00 *   0.00%*
Amean     fault-both-3      2872.13 (   0.00%)     2973.08 (  -3.51%)
Amean     fault-both-5      4330.56 (   0.00%)     3870.19 (  10.63%)
Amean     fault-both-7      6496.63 (   0.00%)     6580.50 (  -1.29%)
Amean     fault-both-12    10280.59 (   0.00%)     9527.40 (   7.33%)
Amean     fault-both-18    11079.19 (   0.00%)    13395.86 * -20.91%*
Amean     fault-both-24    17207.80 (   0.00%)    14936.94 *  13.20%*
Amean     fault-both-30    17736.13 (   0.00%)    16748.46 (   5.57%)
Amean     fault-both-32    18509.41 (   0.00%)    18521.30 (  -0.06%)

                                   4.20.0                 4.20.0
                           norescan-v2r15    finishcontend-v2r15
Percentage huge-1         0.00 (   0.00%)        0.00 (   0.00%)
Percentage huge-3        96.87 (   0.00%)       97.57 (   0.72%)
Percentage huge-5        94.63 (   0.00%)       96.88 (   2.39%)
Percentage huge-7        93.83 (   0.00%)       95.47 (   1.74%)
Percentage huge-12       92.65 (   0.00%)       98.64 (   6.47%)
Percentage huge-18       93.66 (   0.00%)       98.33 (   4.98%)
Percentage huge-24       93.15 (   0.00%)       98.88 (   6.15%)
Percentage huge-30       93.16 (   0.00%)       97.09 (   4.21%)
Percentage huge-32       92.58 (   0.00%)       96.20 (   3.92%)

As expected, a variable impact on latency while allocation success
rates are slightly higher. System CPU usage is reduced by about 10%
but scan rate impact is mixed

Compaction migrate scanned    31772603    19980216
Compaction free scanned       63267928   120381828

Migration scan rates are reduced 37% which is expected as a pageblock
is used by the async scanner instead of skipped but the free scanning is
increased. This can be partially accounted for by the increased success
rate but also by the fact that the scanners do not meet for longer when
pageblocks are actually used. Overall this is justified and completing
a pageblock scan is very important for later patches.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/compaction.c | 95 +++++++++++++++++++++++----------------------------------
 1 file changed, 39 insertions(+), 56 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 9c2cc7955446..608d274f9880 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -376,24 +376,25 @@ static bool test_and_set_skip(struct compact_control *cc, struct page *page,
 
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
 
@@ -426,10 +427,8 @@ static bool compact_unlock_should_abort(spinlock_t *lock,
 	}
 
 	if (need_resched()) {
-		if (cc->mode == MIGRATE_ASYNC) {
+		if (cc->mode == MIGRATE_ASYNC)
 			cc->contended = true;
-			return true;
-		}
 		cond_resched();
 	}
 
@@ -449,10 +448,8 @@ static inline bool compact_should_abort(struct compact_control *cc)
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
@@ -538,18 +535,8 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
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
@@ -910,15 +897,9 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
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
@@ -961,9 +942,12 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
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
@@ -1411,12 +1395,8 @@ static void isolate_freepages(struct compact_control *cc)
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
@@ -1458,13 +1438,8 @@ static struct page *compaction_alloc(struct page *migratepage,
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
@@ -1729,7 +1704,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 		low_pfn = isolate_migratepages_block(cc, low_pfn,
 						block_end_pfn, isolate_mode);
 
-		if (!low_pfn || cc->contended)
+		if (!low_pfn)
 			return ISOLATE_ABORT;
 
 		/*
@@ -1759,9 +1734,7 @@ static enum compact_result __compact_finished(struct compact_control *cc)
 {
 	unsigned int order;
 	const int migratetype = cc->migratetype;
-
-	if (cc->contended || fatal_signal_pending(current))
-		return COMPACT_CONTENDED;
+	int ret;
 
 	/* Compaction run completes if the migrate and free scanner meet */
 	if (compact_scanners_met(cc)) {
@@ -1796,6 +1769,7 @@ static enum compact_result __compact_finished(struct compact_control *cc)
 		return COMPACT_CONTINUE;
 
 	/* Direct compactor: Is a suitable page free? */
+	ret = COMPACT_NO_SUITABLE_PAGE;
 	for (order = cc->order; order < MAX_ORDER; order++) {
 		struct free_area *area = &cc->zone->free_area[order];
 		bool can_steal;
@@ -1835,11 +1809,15 @@ static enum compact_result __compact_finished(struct compact_control *cc)
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
@@ -1981,6 +1959,7 @@ static enum compact_result compact_zone(struct compact_control *cc)
 	unsigned long end_pfn = zone_end_pfn(cc->zone);
 	unsigned long last_migrated_pfn;
 	const bool sync = cc->mode != MIGRATE_ASYNC;
+	unsigned long a, b, c;
 
 	cc->migratetype = gfpflags_to_migratetype(cc->gfp_mask);
 	ret = compaction_suitable(cc->zone, cc->order, cc->alloc_flags,
@@ -2026,6 +2005,10 @@ static enum compact_result compact_zone(struct compact_control *cc)
 			cc->whole_zone = true;
 	}
 
+	a = cc->migrate_pfn;
+	b = cc->free_pfn;
+	c = (cc->free_pfn - cc->migrate_pfn) / pageblock_nr_pages;
+
 	last_migrated_pfn = 0;
 
 	trace_mm_compaction_begin(start_pfn, cc->migrate_pfn,
-- 
2.16.4
