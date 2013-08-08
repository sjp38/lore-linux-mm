Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 55A97900017
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 10:01:14 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 27/27] sched: Retry migration of tasks to CPU on a preferred node
Date: Thu,  8 Aug 2013 15:00:39 +0100
Message-Id: <1375970439-5111-28-git-send-email-mgorman@suse.de>
In-Reply-To: <1375970439-5111-1-git-send-email-mgorman@suse.de>
References: <1375970439-5111-1-git-send-email-mgorman@suse.de>
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
 kernel/sched/fair.c   | 40 +++++++++++++++++++++++-----------------
 2 files changed, 24 insertions(+), 17 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index bbafa60..cd67c95 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1333,6 +1333,7 @@ struct task_struct {
 	int numa_migrate_seq;
 	unsigned int numa_scan_period;
 	unsigned int numa_scan_period_max;
+	unsigned long numa_migrate_retry;
 	u64 node_stamp;			/* migration stamp  */
 	struct callback_head numa_work;
 
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 9ea4d5c..7cffbf5 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -989,6 +989,22 @@ static int task_numa_find_cpu(struct task_struct *p, int nid)
 	return dst_cpu;
 }
 
+/* Attempt to migrate a task to a CPU on the preferred node. */
+static void numa_migrate_preferred(struct task_struct *p)
+{
+	int preferred_cpu = task_cpu(p);
+
+	/* Success if task is already running on preferred CPU */
+	p->numa_migrate_retry = 0;
+	if (cpu_to_node(preferred_cpu) == p->numa_preferred_nid)
+		return;
+
+	/* Otherwise, try migrate to a CPU on the preferred node */
+	preferred_cpu = task_numa_find_cpu(p, p->numa_preferred_nid);
+	if (migrate_task_to(p, preferred_cpu) != 0)
+		p->numa_migrate_retry = jiffies + HZ*5;
+}
+
 static void task_numa_placement(struct task_struct *p)
 {
 	int seq, nid, max_nid = -1;
@@ -1023,27 +1039,13 @@ static void task_numa_placement(struct task_struct *p)
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
-		int preferred_cpu;
-
-		/*
-		 * If the task is not on the preferred node then find
-		 * a suitable CPU to migrate to.
-		 */
-		preferred_cpu = task_cpu(p);
-		if (cpu_to_node(preferred_cpu) != max_nid)
-			preferred_cpu = task_numa_find_cpu(p, max_nid);
 
-		/* Update the preferred nid and migrate task if possible */
+		/* Queue task on preferred node if possible */
 		p->numa_preferred_nid = max_nid;
 		p->numa_migrate_seq = 0;
-		migrate_task_to(p, preferred_cpu);
+		numa_migrate_preferred(p);
 	}
 }
 
@@ -1099,6 +1101,10 @@ void task_numa_fault(int last_nidpid, int node, int pages, bool migrated)
 
 	task_numa_placement(p);
 
+	/* Retry task to preferred node migration if it previously failed */
+	if (p->numa_migrate_retry && time_after(jiffies, p->numa_migrate_retry))
+		numa_migrate_preferred(p);
+
 	p->numa_faults_buffer[task_faults_idx(node, priv)] += pages;
 }
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
