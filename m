Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 10A6290003B
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:28:53 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xb4so2539120pbc.8
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 06:28:53 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 63/63] sched: numa: periodically retry task_numa_migrate
Date: Fri, 27 Sep 2013 14:27:48 +0100
Message-Id: <1380288468-5551-64-git-send-email-mgorman@suse.de>
In-Reply-To: <1380288468-5551-1-git-send-email-mgorman@suse.de>
References: <1380288468-5551-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Rik van Riel <riel@redhat.com>

Short spikes of CPU load can lead to a task being migrated
away from its preferred node for temporary reasons.

It is important that the task is migrated back to where it
belongs, in order to avoid migrating too much memory to its
new location, and generally disturbing a task's NUMA location.

This patch fixes NUMA placement for 4 specjbb instances on
a 4 node system. Without this patch, things take longer to
converge, and processes are not always completely on their
own node.

Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/fair.c | 22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index fced601..8fe5789 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1259,18 +1259,19 @@ static int task_numa_migrate(struct task_struct *p)
 /* Attempt to migrate a task to a CPU on the preferred node. */
 static void numa_migrate_preferred(struct task_struct *p)
 {
-	/* Success if task is already running on preferred CPU */
-	p->numa_migrate_retry = 0;
-	if (cpu_to_node(task_cpu(p)) == p->numa_preferred_nid)
+	/* This task has no NUMA fault statistics yet */
+	if (unlikely(p->numa_preferred_nid == -1 || !p->numa_faults))
 		return;
 
-	/* This task has no NUMA fault statistics yet */
-	if (unlikely(p->numa_preferred_nid == -1))
+	/* Periodically retry migrating the task to the preferred node */
+	p->numa_migrate_retry = jiffies + HZ;
+
+	/* Success if task is already running on preferred CPU */
+	if (cpu_to_node(task_cpu(p)) == p->numa_preferred_nid)
 		return;
 
 	/* Otherwise, try migrate to a CPU on the preferred node */
-	if (task_numa_migrate(p) != 0)
-		p->numa_migrate_retry = jiffies + HZ*5;
+	task_numa_migrate(p);
 }
 
 /*
@@ -1629,8 +1630,11 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
 
 	task_numa_placement(p);
 
-	/* Retry task to preferred node migration if it previously failed */
-	if (p->numa_migrate_retry && time_after(jiffies, p->numa_migrate_retry))
+	/*
+	 * Retry task to preferred node migration periodically, in case it
+	 * case it previously failed, or the scheduler moved us.
+	 */
+	if (time_after(jiffies, p->numa_migrate_retry))
 		numa_migrate_preferred(p);
 
 	if (migrated)
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
