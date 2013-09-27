Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id DA3BA90000A
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:28:08 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so2543464pbb.5
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 06:28:08 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 14/63] sched: numa: Continue PTE scanning even if migrate rate limited
Date: Fri, 27 Sep 2013 14:26:59 +0100
Message-Id: <1380288468-5551-15-git-send-email-mgorman@suse.de>
In-Reply-To: <1380288468-5551-1-git-send-email-mgorman@suse.de>
References: <1380288468-5551-1-git-send-email-mgorman@suse.de>
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
index db83eb1..f2580ce 100644
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
