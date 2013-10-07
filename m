Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 361AD9C001D
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 06:30:22 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so7146916pab.15
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 03:30:22 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 41/63] sched: numa: fix placement of workloads spread across multiple nodes
Date: Mon,  7 Oct 2013 11:29:19 +0100
Message-Id: <1381141781-10992-42-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-1-git-send-email-mgorman@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Rik van Riel <riel@redhat.com>

The load balancer will spread workloads across multiple NUMA nodes,
in order to balance the load on the system. This means that sometimes
a task's preferred node has available capacity, but moving the task
there will not succeed, because that would create too large an imbalance.

In that case, other NUMA nodes need to be considered.

Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/fair.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 722baab..9dd35cb 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1104,13 +1104,12 @@ static int task_numa_migrate(struct task_struct *p)
 	imp = task_faults(env.p, env.dst_nid) - faults;
 	update_numa_stats(&env.dst_stats, env.dst_nid);
 
-	/*
-	 * If the preferred nid has capacity then use it. Otherwise find an
-	 * alternative node with relatively better statistics.
-	 */
-	if (env.dst_stats.has_capacity) {
+	/* If the preferred nid has capacity, try to use it. */
+	if (env.dst_stats.has_capacity)
 		task_numa_find_cpu(&env, imp);
-	} else {
+
+	/* No space available on the preferred nid. Look elsewhere. */
+	if (env.best_cpu == -1) {
 		for_each_online_node(nid) {
 			if (nid == env.src_nid || nid == p->numa_preferred_nid)
 				continue;
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
