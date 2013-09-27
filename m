Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id B6188900026
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:28:44 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so2585843pdj.40
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 06:28:44 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 53/63] sched: numa: Decide whether to favour task or group weights based on swap candidate relationships
Date: Fri, 27 Sep 2013 14:27:38 +0100
Message-Id: <1380288468-5551-54-git-send-email-mgorman@suse.de>
In-Reply-To: <1380288468-5551-1-git-send-email-mgorman@suse.de>
References: <1380288468-5551-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Rik van Riel <riel@redhat.com>

This patch separately considers task and group affinities when searching
for swap candidates during task NUMA placement. If tasks are not part of
a group or the same group then the task weights are considered.
Otherwise the group weights are compared.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 kernel/sched/fair.c | 59 ++++++++++++++++++++++++++++++++---------------------
 1 file changed, 36 insertions(+), 23 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index cd1b862..60ca698 100644
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
+		if (!cur->numa_group || !env->p->numa_group ||
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
 
@@ -1146,9 +1158,9 @@ static int task_numa_migrate(struct task_struct *p)
 		.best_cpu = -1
 	};
 	struct sched_domain *sd;
-	unsigned long weight;
+	unsigned long taskweight, groupweight;
 	int nid, ret;
-	long imp;
+	long taskimp, groupimp;
 
 	/*
 	 * Pick the lowest SD_NUMA domain, as that would have the smallest
@@ -1163,15 +1175,17 @@ static int task_numa_migrate(struct task_struct *p)
 	env.imbalance_pct = 100 + (sd->imbalance_pct - 100) / 2;
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
 
 	/* If the preferred nid has capacity, try to use it. */
 	if (env.dst_stats.has_capacity)
-		task_numa_find_cpu(&env, imp);
+		task_numa_find_cpu(&env, taskimp, groupimp);
 
 	/* No space available on the preferred nid. Look elsewhere. */
 	if (env.best_cpu == -1) {
@@ -1180,13 +1194,14 @@ static int task_numa_migrate(struct task_struct *p)
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
 
@@ -4632,10 +4647,9 @@ static bool migrate_improves_locality(struct task_struct *p, struct lb_env *env)
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
@@ -4662,10 +4676,9 @@ static bool migrate_degrades_locality(struct task_struct *p, struct lb_env *env)
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
