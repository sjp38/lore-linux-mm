Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A28578E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 07:53:27 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o21so35178681edq.4
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 04:53:27 -0800 (PST)
Received: from outbound-smtp26.blacknight.com (outbound-smtp26.blacknight.com. [81.17.249.194])
        by mx.google.com with ESMTPS id g14si7194628edy.160.2019.01.04.04.53.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 04:53:25 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp26.blacknight.com (Postfix) with ESMTPS id A9632B87AC
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 12:53:25 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 18/25] mm, compaction: Rework compact_should_abort as compact_check_resched
Date: Fri,  4 Jan 2019 12:50:04 +0000
Message-Id: <20190104125011.16071-19-mgorman@techsingularity.net>
In-Reply-To: <20190104125011.16071-1-mgorman@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

With incremental changes, compact_should_abort no longer makes
any documented sense. Rename to compact_check_resched and update the
associated comments.  There is no benefit other than reducing redundant
code and making the intent slightly clearer. It could potentially be
merged with earlier patches but it just makes the review slightly
harder.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/compaction.c | 61 ++++++++++++++++++++++-----------------------------------
 1 file changed, 23 insertions(+), 38 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index be27e4fa1b40..1a41a2dbff24 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -398,6 +398,21 @@ static bool compact_lock_irqsave(spinlock_t *lock, unsigned long *flags,
 	return true;
 }
 
+/*
+ * Aside from avoiding lock contention, compaction also periodically checks
+ * need_resched() and records async compaction as contended if necessary.
+ */
+static inline void compact_check_resched(struct compact_control *cc)
+{
+	/* async compaction aborts if contended */
+	if (need_resched()) {
+		if (cc->mode == MIGRATE_ASYNC)
+			cc->contended = true;
+
+		cond_resched();
+	}
+}
+
 /*
  * Compaction requires the taking of some coarse locks that are potentially
  * very heavily contended. The lock should be periodically unlocked to avoid
@@ -426,33 +441,7 @@ static bool compact_unlock_should_abort(spinlock_t *lock,
 		return true;
 	}
 
-	if (need_resched()) {
-		if (cc->mode == MIGRATE_ASYNC)
-			cc->contended = true;
-		cond_resched();
-	}
-
-	return false;
-}
-
-/*
- * Aside from avoiding lock contention, compaction also periodically checks
- * need_resched() and either schedules in sync compaction or aborts async
- * compaction. This is similar to what compact_unlock_should_abort() does, but
- * is used where no lock is concerned.
- *
- * Returns false when no scheduling was needed, or sync compaction scheduled.
- * Returns true when async compaction should abort.
- */
-static inline bool compact_should_abort(struct compact_control *cc)
-{
-	/* async compaction aborts if contended */
-	if (need_resched()) {
-		if (cc->mode == MIGRATE_ASYNC)
-			cc->contended = true;
-
-		cond_resched();
-	}
+	compact_check_resched(cc);
 
 	return false;
 }
@@ -750,8 +739,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			return 0;
 	}
 
-	if (compact_should_abort(cc))
-		return 0;
+	compact_check_resched(cc);
 
 	if (cc->direct_compaction && (cc->mode == MIGRATE_ASYNC)) {
 		skip_on_failure = true;
@@ -1374,12 +1362,10 @@ static void isolate_freepages(struct compact_control *cc)
 				isolate_start_pfn = block_start_pfn) {
 		/*
 		 * This can iterate a massively long zone without finding any
-		 * suitable migration targets, so periodically check if we need
-		 * to schedule, or even abort async compaction.
+		 * suitable migration targets, so periodically check resched.
 		 */
-		if (!(block_start_pfn % (SWAP_CLUSTER_MAX * pageblock_nr_pages))
-						&& compact_should_abort(cc))
-			break;
+		if (!(block_start_pfn % (SWAP_CLUSTER_MAX * pageblock_nr_pages)))
+			compact_check_resched(cc);
 
 		page = pageblock_pfn_to_page(block_start_pfn, block_end_pfn,
 									zone);
@@ -1673,11 +1659,10 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 		/*
 		 * This can potentially iterate a massively long zone with
 		 * many pageblocks unsuitable, so periodically check if we
-		 * need to schedule, or even abort async compaction.
+		 * need to schedule.
 		 */
-		if (!(low_pfn % (SWAP_CLUSTER_MAX * pageblock_nr_pages))
-						&& compact_should_abort(cc))
-			break;
+		if (!(low_pfn % (SWAP_CLUSTER_MAX * pageblock_nr_pages)))
+			compact_check_resched(cc);
 
 		page = pageblock_pfn_to_page(block_start_pfn, block_end_pfn,
 									zone);
-- 
2.16.4
