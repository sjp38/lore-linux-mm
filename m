Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id CD3169C0017
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 06:30:15 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so6877336pbb.5
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 03:30:15 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 33/63] sched: Retry migration of tasks to CPU on a preferred node
Date: Mon,  7 Oct 2013 11:29:11 +0100
Message-Id: <1381141781-10992-34-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-1-git-send-email-mgorman@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

When a preferred node is selected for a tasks there is an attempt to migrate
the task to a CPU there. This may fail in which case the task will only
migrate if the active load balancer takes action. This may never happen if
the conditions are not right. This patch will check at NUMA hinting fault
time if another attempt should be made to migrate the task. It will only
make an attempt once every five seconds.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Peter Zijlstra <peterz@infradead.org>
---
 include/linux/sched.h |  1 +
 kernel/sched/fair.c   | 30 +++++++++++++++++++++++-------
 2 files changed, 24 insertions(+), 7 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 8a3aa9e..4dd0c94 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1331,6 +1331,7 @@ struct task_struct {
 	int numa_migrate_seq;
 	unsigned int numa_scan_period;
 	unsigned int numa_scan_period_max;
+	unsigned long numa_migrate_retry;
 	u64 node_stamp;			/* migration stamp  */
 	struct callback_head numa_work;
 
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index fd6e9e1..559175b 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1011,6 +1011,23 @@ migrate:
 	return migrate_task_to(p, env.best_cpu);
 }
 
+/* Attempt to migrate a task to a CPU on the preferred node. */
+static void numa_migrate_preferred(struct task_struct *p)
+{
+	/* Success if task is already running on preferred CPU */
+	p->numa_migrate_retry = 0;
+	if (cpu_to_node(task_cpu(p)) == p->numa_preferred_nid)
+		return;
+
+	/* This task has no NUMA fault statistics yet */
+	if (unlikely(p->numa_preferred_nid == -1))
+		return;
+
+	/* Otherwise, try migrate to a CPU on the preferred node */
+	if (task_numa_migrate(p) != 0)
+		p->numa_migrate_retry = jiffies + HZ*5;
+}
+
 static void task_numa_placement(struct task_struct *p)
 {
 	int seq, nid, max_nid = -1;
@@ -1045,17 +1062,12 @@ static void task_numa_placement(struct task_struct *p)
 		}
 	}
 
-	/*
-	 * Record the preferred node as the node with the most faults,
-	 * requeue the task to be running on the idlest CPU on the
-	 * preferred node and reset the scanning rate to recheck
-	 * the working set placement.
-	 */
+	/* Preferred node as the node with the most faults */
 	if (max_faults && max_nid != p->numa_preferred_nid) {
 		/* Update the preferred nid and migrate task if possible */
 		p->numa_preferred_nid = max_nid;
 		p->numa_migrate_seq = 1;
-		task_numa_migrate(p);
+		numa_migrate_preferred(p);
 	}
 }
 
@@ -1111,6 +1123,10 @@ void task_numa_fault(int last_nidpid, int node, int pages, bool migrated)
 
 	task_numa_placement(p);
 
+	/* Retry task to preferred node migration if it previously failed */
+	if (p->numa_migrate_retry && time_after(jiffies, p->numa_migrate_retry))
+		numa_migrate_preferred(p);
+
 	p->numa_faults_buffer[task_faults_idx(node, priv)] += pages;
 }
 
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
