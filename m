Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9497A9C0028
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 06:30:30 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so6935505pdj.17
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 03:30:30 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 49/63] sched: numa: use group fault statistics in numa placement
Date: Mon,  7 Oct 2013 11:29:27 +0100
Message-Id: <1381141781-10992-50-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-1-git-send-email-mgorman@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This patch uses the fraction of faults on a particular node for both task
and group, to figure out the best node to place a task.  If the task and
group statistics disagree on what the preferred node should be then a full
rescan will select the node with the best combined weight.

Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/sched.h |   1 +
 kernel/sched/fair.c   | 124 +++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 108 insertions(+), 17 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index d61b531..17eb13f 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1346,6 +1346,7 @@ struct task_struct {
 	 * The values remain static for the duration of a PTE scan
 	 */
 	unsigned long *numa_faults;
+	unsigned long total_numa_faults;
 
 	/*
 	 * numa_faults_buffer records faults per node during the current
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index a9ce454..f9070f2 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -897,6 +897,7 @@ struct numa_group {
 	struct list_head task_list;
 
 	struct rcu_head rcu;
+	atomic_long_t total_faults;
 	atomic_long_t faults[0];
 };
 
@@ -919,6 +920,51 @@ static inline unsigned long task_faults(struct task_struct *p, int nid)
 		p->numa_faults[task_faults_idx(nid, 1)];
 }
 
+static inline unsigned long group_faults(struct task_struct *p, int nid)
+{
+	if (!p->numa_group)
+		return 0;
+
+	return atomic_long_read(&p->numa_group->faults[2*nid]) +
+	       atomic_long_read(&p->numa_group->faults[2*nid+1]);
+}
+
+/*
+ * These return the fraction of accesses done by a particular task, or
+ * task group, on a particular numa node.  The group weight is given a
+ * larger multiplier, in order to group tasks together that are almost
+ * evenly spread out between numa nodes.
+ */
+static inline unsigned long task_weight(struct task_struct *p, int nid)
+{
+	unsigned long total_faults;
+
+	if (!p->numa_faults)
+		return 0;
+
+	total_faults = p->total_numa_faults;
+
+	if (!total_faults)
+		return 0;
+
+	return 1000 * task_faults(p, nid) / total_faults;
+}
+
+static inline unsigned long group_weight(struct task_struct *p, int nid)
+{
+	unsigned long total_faults;
+
+	if (!p->numa_group)
+		return 0;
+
+	total_faults = atomic_long_read(&p->numa_group->total_faults);
+
+	if (!total_faults)
+		return 0;
+
+	return 1200 * group_faults(p, nid) / total_faults;
+}
+
 static unsigned long weighted_cpuload(const int cpu);
 static unsigned long source_load(int cpu, int type);
 static unsigned long target_load(int cpu, int type);
@@ -1018,8 +1064,10 @@ static void task_numa_compare(struct task_numa_env *env, long imp)
 		if (!cpumask_test_cpu(env->src_cpu, tsk_cpus_allowed(cur)))
 			goto unlock;
 
-		imp += task_faults(cur, env->src_nid) -
-		       task_faults(cur, env->dst_nid);
+		imp += task_weight(cur, env->src_nid) +
+		       group_weight(cur, env->src_nid) -
+		       task_weight(cur, env->dst_nid) -
+		       group_weight(cur, env->dst_nid);
 	}
 
 	if (imp < env->best_imp)
@@ -1098,7 +1146,7 @@ static int task_numa_migrate(struct task_struct *p)
 		.best_cpu = -1
 	};
 	struct sched_domain *sd;
-	unsigned long faults;
+	unsigned long weight;
 	int nid, ret;
 	long imp;
 
@@ -1115,10 +1163,10 @@ static int task_numa_migrate(struct task_struct *p)
 	env.imbalance_pct = 100 + (sd->imbalance_pct - 100) / 2;
 	rcu_read_unlock();
 
-	faults = task_faults(p, env.src_nid);
+	weight = task_weight(p, env.src_nid) + group_weight(p, env.src_nid);
 	update_numa_stats(&env.src_stats, env.src_nid);
 	env.dst_nid = p->numa_preferred_nid;
-	imp = task_faults(env.p, env.dst_nid) - faults;
+	imp = task_weight(p, env.dst_nid) + group_weight(p, env.dst_nid) - weight;
 	update_numa_stats(&env.dst_stats, env.dst_nid);
 
 	/* If the preferred nid has capacity, try to use it. */
@@ -1131,8 +1179,8 @@ static int task_numa_migrate(struct task_struct *p)
 			if (nid == env.src_nid || nid == p->numa_preferred_nid)
 				continue;
 
-			/* Only consider nodes that recorded more faults */
-			imp = task_faults(env.p, nid) - faults;
+			/* Only consider nodes where both task and groups benefit */
+			imp = task_weight(p, nid) + group_weight(p, nid) - weight;
 			if (imp < 0)
 				continue;
 
@@ -1183,8 +1231,8 @@ static void numa_migrate_preferred(struct task_struct *p)
 
 static void task_numa_placement(struct task_struct *p)
 {
-	int seq, nid, max_nid = -1;
-	unsigned long max_faults = 0;
+	int seq, nid, max_nid = -1, max_group_nid = -1;
+	unsigned long max_faults = 0, max_group_faults = 0;
 
 	seq = ACCESS_ONCE(p->mm->numa_scan_seq);
 	if (p->numa_scan_seq == seq)
@@ -1195,7 +1243,7 @@ static void task_numa_placement(struct task_struct *p)
 
 	/* Find the node with the highest number of faults */
 	for_each_online_node(nid) {
-		unsigned long faults = 0;
+		unsigned long faults = 0, group_faults = 0;
 		int priv, i;
 
 		for (priv = 0; priv < 2; priv++) {
@@ -1211,9 +1259,12 @@ static void task_numa_placement(struct task_struct *p)
 
 			faults += p->numa_faults[i];
 			diff += p->numa_faults[i];
+			p->total_numa_faults += diff;
 			if (p->numa_group) {
 				/* safe because we can only change our own group */
 				atomic_long_add(diff, &p->numa_group->faults[i]);
+				atomic_long_add(diff, &p->numa_group->total_faults);
+				group_faults += atomic_long_read(&p->numa_group->faults[i]);
 			}
 		}
 
@@ -1221,6 +1272,27 @@ static void task_numa_placement(struct task_struct *p)
 			max_faults = faults;
 			max_nid = nid;
 		}
+
+		if (group_faults > max_group_faults) {
+			max_group_faults = group_faults;
+			max_group_nid = nid;
+		}
+	}
+
+	/*
+	 * If the preferred task and group nids are different,
+	 * iterate over the nodes again to find the best place.
+	 */
+	if (p->numa_group && max_nid != max_group_nid) {
+		unsigned long weight, max_weight = 0;
+
+		for_each_online_node(nid) {
+			weight = task_weight(p, nid) + group_weight(p, nid);
+			if (weight > max_weight) {
+				max_weight = weight;
+				max_nid = nid;
+			}
+		}
 	}
 
 	/* Preferred node as the node with the most faults */
@@ -1276,6 +1348,8 @@ static void task_numa_group(struct task_struct *p, int cpupid)
 		for (i = 0; i < 2*nr_node_ids; i++)
 			atomic_long_set(&grp->faults[i], p->numa_faults[i]);
 
+		atomic_long_set(&grp->total_faults, p->total_numa_faults);
+
 		list_add(&p->numa_entry, &grp->task_list);
 		grp->nr_tasks++;
 		rcu_assign_pointer(p->numa_group, grp);
@@ -1323,6 +1397,8 @@ unlock:
 		atomic_long_sub(p->numa_faults[i], &my_grp->faults[i]);
 		atomic_long_add(p->numa_faults[i], &grp->faults[i]);
 	}
+	atomic_long_sub(p->total_numa_faults, &my_grp->total_faults);
+	atomic_long_add(p->total_numa_faults, &grp->total_faults);
 
 	double_lock(&my_grp->lock, &grp->lock);
 
@@ -1347,6 +1423,8 @@ void task_numa_free(struct task_struct *p)
 		for (i = 0; i < 2*nr_node_ids; i++)
 			atomic_long_sub(p->numa_faults[i], &grp->faults[i]);
 
+		atomic_long_sub(p->total_numa_faults, &grp->total_faults);
+
 		spin_lock(&grp->lock);
 		list_del(&p->numa_entry);
 		grp->nr_tasks--;
@@ -1385,6 +1463,7 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
 
 		BUG_ON(p->numa_faults_buffer);
 		p->numa_faults_buffer = p->numa_faults + (2 * nr_node_ids);
+		p->total_numa_faults = 0;
 	}
 
 	/*
@@ -4571,12 +4650,17 @@ static bool migrate_improves_locality(struct task_struct *p, struct lb_env *env)
 	src_nid = cpu_to_node(env->src_cpu);
 	dst_nid = cpu_to_node(env->dst_cpu);
 
-	if (src_nid == dst_nid ||
-	    p->numa_migrate_seq >= sysctl_numa_balancing_settle_count)
+	if (src_nid == dst_nid)
 		return false;
 
-	if (dst_nid == p->numa_preferred_nid ||
-	    task_faults(p, dst_nid) > task_faults(p, src_nid))
+	/* Always encourage migration to the preferred node. */
+	if (dst_nid == p->numa_preferred_nid)
+		return true;
+
+	/* After the task has settled, check if the new node is better. */
+	if (p->numa_migrate_seq >= sysctl_numa_balancing_settle_count &&
+			task_weight(p, dst_nid) + group_weight(p, dst_nid) >
+			task_weight(p, src_nid) + group_weight(p, src_nid))
 		return true;
 
 	return false;
@@ -4596,11 +4680,17 @@ static bool migrate_degrades_locality(struct task_struct *p, struct lb_env *env)
 	src_nid = cpu_to_node(env->src_cpu);
 	dst_nid = cpu_to_node(env->dst_cpu);
 
-	if (src_nid == dst_nid ||
-	    p->numa_migrate_seq >= sysctl_numa_balancing_settle_count)
+	if (src_nid == dst_nid)
 		return false;
 
-	if (task_faults(p, dst_nid) < task_faults(p, src_nid))
+	/* Migrating away from the preferred node is always bad. */
+	if (src_nid == p->numa_preferred_nid)
+		return true;
+
+	/* After the task has settled, check if the new node is worse. */
+	if (p->numa_migrate_seq >= sysctl_numa_balancing_settle_count &&
+			task_weight(p, dst_nid) + group_weight(p, dst_nid) <
+			task_weight(p, src_nid) + group_weight(p, src_nid))
 		return true;
 
 	return false;
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
