Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 5BE9B9C001E
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 06:30:22 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so7086143pad.5
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 03:30:22 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 40/63] sched: numa: Favor placing a task on the preferred node
Date: Mon,  7 Oct 2013 11:29:18 +0100
Message-Id: <1381141781-10992-41-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-1-git-send-email-mgorman@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

A tasks preferred node is selected based on the number of faults
recorded for a node but the actual task_numa_migate() conducts a global
search regardless of the preferred nid. This patch checks if the
preferred nid has capacity and if so, searches for a CPU within that
node. This avoids a global search when the preferred node is not
overloaded.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/fair.c | 54 ++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 35 insertions(+), 19 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 59abe50..722baab 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1052,6 +1052,20 @@ unlock:
 	rcu_read_unlock();
 }
 
+static void task_numa_find_cpu(struct task_numa_env *env, long imp)
+{
+	int cpu;
+
+	for_each_cpu(cpu, cpumask_of_node(env->dst_nid)) {
+		/* Skip this CPU if the source task cannot migrate */
+		if (!cpumask_test_cpu(cpu, tsk_cpus_allowed(env->p)))
+			continue;
+
+		env->dst_cpu = cpu;
+		task_numa_compare(env, imp);
+	}
+}
+
 static int task_numa_migrate(struct task_struct *p)
 {
 	struct task_numa_env env = {
@@ -1068,7 +1082,8 @@ static int task_numa_migrate(struct task_struct *p)
 	};
 	struct sched_domain *sd;
 	unsigned long faults;
-	int nid, cpu, ret;
+	int nid, ret;
+	long imp;
 
 	/*
 	 * Pick the lowest SD_NUMA domain, as that would have the smallest
@@ -1085,28 +1100,29 @@ static int task_numa_migrate(struct task_struct *p)
 
 	faults = task_faults(p, env.src_nid);
 	update_numa_stats(&env.src_stats, env.src_nid);
+	env.dst_nid = p->numa_preferred_nid;
+	imp = task_faults(env.p, env.dst_nid) - faults;
+	update_numa_stats(&env.dst_stats, env.dst_nid);
 
-	/* Find an alternative node with relatively better statistics */
-	for_each_online_node(nid) {
-		long imp;
-
-		if (nid == env.src_nid)
-			continue;
-
-		/* Only consider nodes that recorded more faults */
-		imp = task_faults(p, nid) - faults;
-		if (imp < 0)
-			continue;
+	/*
+	 * If the preferred nid has capacity then use it. Otherwise find an
+	 * alternative node with relatively better statistics.
+	 */
+	if (env.dst_stats.has_capacity) {
+		task_numa_find_cpu(&env, imp);
+	} else {
+		for_each_online_node(nid) {
+			if (nid == env.src_nid || nid == p->numa_preferred_nid)
+				continue;
 
-		env.dst_nid = nid;
-		update_numa_stats(&env.dst_stats, env.dst_nid);
-		for_each_cpu(cpu, cpumask_of_node(nid)) {
-			/* Skip this CPU if the source task cannot migrate */
-			if (!cpumask_test_cpu(cpu, tsk_cpus_allowed(p)))
+			/* Only consider nodes that recorded more faults */
+			imp = task_faults(env.p, nid) - faults;
+			if (imp < 0)
 				continue;
 
-			env.dst_cpu = cpu;
-			task_numa_compare(&env, imp);
+			env.dst_nid = nid;
+			update_numa_stats(&env.dst_stats, env.dst_nid);
+			task_numa_find_cpu(&env, imp);
 		}
 	}
 
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
