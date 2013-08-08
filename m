Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id B00CA900003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 10:00:51 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 07/27] sched, numa: Continue PTE scanning even if migrate rate limited
Date: Thu,  8 Aug 2013 15:00:19 +0100
Message-Id: <1375970439-5111-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1375970439-5111-1-git-send-email-mgorman@suse.de>
References: <1375970439-5111-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Peter Zijlstra <peterz@infradead.org>

Avoiding marking PTEs pte_numa because a particular NUMA node is migrate rate
limited sees like a bad idea. Even if this node can't migrate anymore other
nodes might and we want up-to-date information to do balance decisions.
We already rate limit the actual migrations, this should leave enough
bandwidth to allow the non-migrating scanning. I think its important we
keep up-to-date information if we're going to do placement based on it.

Signed-off-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/fair.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 2a08727..cc2ee69 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -951,14 +951,6 @@ void task_numa_work(struct callback_head *work)
 	 */
 	p->node_stamp += 2 * TICK_NSEC;
 
-	/*
-	 * Do not set pte_numa if the current running node is rate-limited.
-	 * This loses statistics on the fault but if we are unwilling to
-	 * migrate to this node, it is less likely we can do useful work
-	 */
-	if (migrate_ratelimited(numa_node_id()))
-		return;
-
 	start = mm->numa_scan_offset;
 	pages = sysctl_numa_balancing_scan_size;
 	pages <<= 20 - PAGE_SHIFT; /* MB in pages */
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
