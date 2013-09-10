Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 158126B009E
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 05:33:24 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 48/50] sched: numa: Decide whether to favour task or group weights based on swap candidate relationships
Date: Tue, 10 Sep 2013 10:32:28 +0100
Message-Id: <1378805550-29949-49-git-send-email-mgorman@suse.de>
In-Reply-To: <1378805550-29949-1-git-send-email-mgorman@suse.de>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Rik van Riel <riel@redhat.com>

This patch separately considers task and group affinities when searching
for swap candidates during task NUMA placement. If tasks are not part of
a group or the same group then the task weights are considered.
Otherwise the group weights are compared.

Not-signed-off-by: Rik van Riel
---
 kernel/sched/fair.c | 59 ++++++++++++++++++++++++++++++++---------------------
 1 file changed, 36 insertions(+), 23 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 80906fa..fdb7923 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1039,13 +1039,15 @@ static void task_numa_assign(struct task_numa_env *env,
  * into account that it might be best if task running on the dst_cpu should
  * be exchanged with the source task
  */
-static void task_numa_compare(struct task_numa_env *env, long imp)
+static void task_numa_compare(struct task_numa_env *env,
+			      long taskimp, long groupimp)
 {
 	struct rq *src_rq = cpu_rq(env->src_cpu);
 	struct rq *dst_rq = cpu_rq(env->dst_cpu);
 	struct task_struct *cur;
 	long dst_load, src_load;
 	long load;
+	long imp = (groupimp > 0) ? groupimp : taskimp;
 
 	rcu_read_lock();
 	cur = ACCESS_ONCE(dst_rq->curr);
@@ -1064,10 +1066,19 @@ static void task_numa_compare(struct task_numa_env *env, long imp)
 		if (!cpumask_test_cpu(env->src_cpu, tsk_cpus_allowed(cur)))
 			goto unlock;
 
-		imp += task_weight(cur, env->src_nid) +
-		       group_weight(cur, env->src_nid) -
-		       task_weight(cur, env->dst_nid) -
-		       group_weight(cur, env->dst_nid);
+		/*
+		 * If dst and source tasks are in the same NUMA group, or not
+		 * in any group then look only at task weights otherwise give
+		 * priority to the group weights.
+		 */
+		if (!cur->numa_group || ! env->p->numa_group ||
+		    cur->numa_group == env->p->numa_group) {
+			imp = taskimp + task_weight(cur, env->src_nid) -
+			      task_weight(cur, env->dst_nid);
+		} else {
+			imp = groupimp + group_weight(cur, env->src_nid) -
+			       group_weight(cur, env->dst_nid);
+		}
 	}
 
 	if (imp < env->best_imp)
@@ -1117,7 +1128,8 @@ unlock:
 	rcu_read_unlock();
 }
 
-static void task_numa_find_cpu(struct task_numa_env *env, long imp)
+static void task_numa_find_cpu(struct task_numa_env *env,
+				long taskimp, long groupimp)
 {
 	int cpu;
 
@@ -1127,7 +1139,7 @@ static void task_numa_find_cpu(struct task_numa_env *env, long imp)
 			continue;
 
 		env->dst_cpu = cpu;
-		task_numa_compare(env, imp);
+		task_numa_compare(env, taskimp, groupimp);
 	}
 }
 
@@ -1147,9 +1159,9 @@ static int task_numa_migrate(struct task_struct *p)
 		.best_cpu = -1
 	};
  	struct sched_domain *sd;
-	unsigned long weight;
+	unsigned long taskweight, groupweight;
 	int nid, ret;
-	long imp;
+	long taskimp, groupimp;
 
 	/*
 	 * Find the lowest common scheduling domain covering the nodes of both
@@ -1164,10 +1176,12 @@ static int task_numa_migrate(struct task_struct *p)
 	}
 	rcu_read_unlock();
 
-	weight = task_weight(p, env.src_nid) + group_weight(p, env.src_nid);
+	taskweight = task_weight(p, env.src_nid);
+	groupweight = group_weight(p, env.src_nid);
 	update_numa_stats(&env.src_stats, env.src_nid);
 	env.dst_nid = p->numa_preferred_nid;
-	imp = task_weight(p, env.dst_nid) + group_weight(p, env.dst_nid) - weight;
+	taskimp = task_weight(p, env.dst_nid) - taskweight;
+	groupimp = group_weight(p, env.dst_nid) - groupweight;
 	update_numa_stats(&env.dst_stats, env.dst_nid);
 
 	/*
@@ -1175,20 +1189,21 @@ static int task_numa_migrate(struct task_struct *p)
 	 * alternative node with relatively better statistics.
 	 */
 	if (env.dst_stats.has_capacity) {
-		task_numa_find_cpu(&env, imp);
+		task_numa_find_cpu(&env, taskimp, groupimp);
 	} else {
 		for_each_online_node(nid) {
 			if (nid == env.src_nid || nid == p->numa_preferred_nid)
 				continue;
 
 			/* Only consider nodes where both task and groups benefit */
-			imp = task_weight(p, nid) + group_weight(p, nid) - weight;
-			if (imp < 0)
+			taskimp = task_weight(p, nid) - taskweight;
+			groupimp = group_weight(p, nid) - groupweight;
+			if (taskimp < 0 && groupimp < 0)
 				continue;
 
 			env.dst_nid = nid;
 			update_numa_stats(&env.dst_stats, env.dst_nid);
-			task_numa_find_cpu(&env, imp);
+			task_numa_find_cpu(&env, taskimp, groupimp);
 		}
 	}
 
@@ -4627,10 +4642,9 @@ static bool migrate_improves_locality(struct task_struct *p, struct lb_env *env)
 	if (dst_nid == p->numa_preferred_nid)
 		return true;
 
-	/* After the task has settled, check if the new node is better. */
-	if (p->numa_migrate_seq >= sysctl_numa_balancing_settle_count &&
-			task_weight(p, dst_nid) + group_weight(p, dst_nid) >
-			task_weight(p, src_nid) + group_weight(p, src_nid))
+	/* If both task and group weight improve, this move is a winner. */
+	if (task_weight(p, dst_nid) > task_weight(p, src_nid) &&
+	    group_weight(p, dst_nid) > group_weight(p, src_nid))
 		return true;
 
 	return false;
@@ -4657,10 +4671,9 @@ static bool migrate_degrades_locality(struct task_struct *p, struct lb_env *env)
 	if (src_nid == p->numa_preferred_nid)
 		return true;
 
-	/* After the task has settled, check if the new node is worse. */
-	if (p->numa_migrate_seq >= sysctl_numa_balancing_settle_count &&
-			task_weight(p, dst_nid) + group_weight(p, dst_nid) <
-			task_weight(p, src_nid) + group_weight(p, src_nid))
+	/* If either task or group weight get worse, don't do it. */
+	if (task_weight(p, dst_nid) < task_weight(p, src_nid) ||
+	    group_weight(p, dst_nid) < group_weight(p, src_nid))
 		return true;
 
 	return false;
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
