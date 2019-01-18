Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 04E898E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 12:54:42 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id l45so5281158edb.1
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 09:54:41 -0800 (PST)
Received: from outbound-smtp25.blacknight.com (outbound-smtp25.blacknight.com. [81.17.249.193])
        by mx.google.com with ESMTPS id p33si9098726eda.412.2019.01.18.09.54.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 09:54:40 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp25.blacknight.com (Postfix) with ESMTPS id EE285B879A
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 17:54:39 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 17/22] mm, compaction: Do not consider a need to reschedule as contention
Date: Fri, 18 Jan 2019 17:51:31 +0000
Message-Id: <20190118175136.31341-18-mgorman@techsingularity.net>
In-Reply-To: <20190118175136.31341-1-mgorman@techsingularity.net>
References: <20190118175136.31341-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

Scanning on large machines can take a considerable length of time and
eventually need to be rescheduled. This is treated as an abort event but
that's not appropriate as the attempt is likely to be retried after making
numerous checks and taking another cycle through the page allocator.
This patch will check the need to reschedule if necessary but continue
the scanning.

The main benefit is reduced scanning when compaction is taking a long time
or the machine is over-saturated. It also avoids an unnecessary exit of
compaction that ends up being retried by the page allocator in the outer
loop.

                                     5.0.0-rc1              5.0.0-rc1
                              synccached-v3r16        noresched-v3r17
Amean     fault-both-1         0.00 (   0.00%)        0.00 *   0.00%*
Amean     fault-both-3      2958.27 (   0.00%)     2965.68 (  -0.25%)
Amean     fault-both-5      4091.90 (   0.00%)     3995.90 (   2.35%)
Amean     fault-both-7      5803.05 (   0.00%)     5842.12 (  -0.67%)
Amean     fault-both-12     9481.06 (   0.00%)     9550.87 (  -0.74%)
Amean     fault-both-18    14141.51 (   0.00%)    13304.72 (   5.92%)
Amean     fault-both-24    16438.00 (   0.00%)    14618.59 (  11.07%)
Amean     fault-both-30    17531.72 (   0.00%)    16650.96 (   5.02%)
Amean     fault-both-32    17101.96 (   0.00%)    17145.15 (  -0.25%)

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 23 ++++-------------------
 1 file changed, 4 insertions(+), 19 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 9aa71945255d..293d9a9e6f00 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -404,21 +404,6 @@ static bool compact_lock_irqsave(spinlock_t *lock, unsigned long *flags,
 	return true;
 }
 
-/*
- * Aside from avoiding lock contention, compaction also periodically checks
- * need_resched() and records async compaction as contended if necessary.
- */
-static inline void compact_check_resched(struct compact_control *cc)
-{
-	/* async compaction aborts if contended */
-	if (need_resched()) {
-		if (cc->mode == MIGRATE_ASYNC)
-			cc->contended = true;
-
-		cond_resched();
-	}
-}
-
 /*
  * Compaction requires the taking of some coarse locks that are potentially
  * very heavily contended. The lock should be periodically unlocked to avoid
@@ -447,7 +432,7 @@ static bool compact_unlock_should_abort(spinlock_t *lock,
 		return true;
 	}
 
-	compact_check_resched(cc);
+	cond_resched();
 
 	return false;
 }
@@ -736,7 +721,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			return 0;
 	}
 
-	compact_check_resched(cc);
+	cond_resched();
 
 	if (cc->direct_compaction && (cc->mode == MIGRATE_ASYNC)) {
 		skip_on_failure = true;
@@ -1370,7 +1355,7 @@ static void isolate_freepages(struct compact_control *cc)
 		 * suitable migration targets, so periodically check resched.
 		 */
 		if (!(block_start_pfn % (SWAP_CLUSTER_MAX * pageblock_nr_pages)))
-			compact_check_resched(cc);
+			cond_resched();
 
 		page = pageblock_pfn_to_page(block_start_pfn, block_end_pfn,
 									zone);
@@ -1664,7 +1649,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 		 * need to schedule.
 		 */
 		if (!(low_pfn % (SWAP_CLUSTER_MAX * pageblock_nr_pages)))
-			compact_check_resched(cc);
+			cond_resched();
 
 		page = pageblock_pfn_to_page(block_start_pfn, block_end_pfn,
 									zone);
-- 
2.16.4
