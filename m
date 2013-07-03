Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 0356A6B003C
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 10:22:23 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 09/13] sched: Favour moving tasks towards nodes that incurred more faults
Date: Wed,  3 Jul 2013 15:21:36 +0100
Message-Id: <1372861300-9973-10-git-send-email-mgorman@suse.de>
In-Reply-To: <1372861300-9973-1-git-send-email-mgorman@suse.de>
References: <1372861300-9973-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The scheduler already favours moving tasks towards its preferred node but
does nothing special if the destination node is anything else. This patch
favours moving tasks towards a destination node if more NUMA hinting faults
were recorded on it. Similarly if migrating to a destination node would
degrade locality based on NUMA hinting faults then it will be resisted.

Signed-off-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/fair.c | 54 +++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 48 insertions(+), 6 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index e8d9b3e..e451859 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -3967,22 +3967,54 @@ task_hot(struct task_struct *p, u64 now, struct sched_domain *sd)
 }
 
 #ifdef CONFIG_NUMA_BALANCING
+
+static bool migrate_locality_prepare(struct task_struct *p, struct lb_env *env,
+				int *src_nid, int *dst_nid)
+{
+	if (!p->numa_faults || !(env->sd->flags & SD_NUMA))
+		return false;
+
+	*src_nid = cpu_to_node(env->src_cpu);
+	*dst_nid = cpu_to_node(env->dst_cpu);
+
+	if (*src_nid == *dst_nid ||
+	    p->numa_migrate_seq >= sysctl_numa_balancing_settle_count)
+		return false;
+
+	return true;
+}
+
 /* Returns true if the destination node has incurred more faults */
 static bool migrate_improves_locality(struct task_struct *p, struct lb_env *env)
 {
 	int src_nid, dst_nid;
 
-	if (!p->numa_faults || !(env->sd->flags & SD_NUMA))
+	if (!migrate_locality_prepare(p, env, &src_nid, &dst_nid))
 		return false;
 
-	src_nid = cpu_to_node(env->src_cpu);
-	dst_nid = cpu_to_node(env->dst_cpu);
+	/* Move towards node if it is the preferred node */
+	if (p->numa_preferred_nid == dst_nid)
+		return true;
 
-	if (src_nid == dst_nid ||
-	    p->numa_migrate_seq >= sysctl_numa_balancing_settle_count)
+	/*
+	 * Move towards node if there were a higher number of private
+	 * NUMA hinting faults recorded on it
+	 */
+	if (p->numa_faults[task_faults_idx(dst_nid, 1)] >
+	    p->numa_faults[task_faults_idx(src_nid, 1)])
+		return true;
+
+	return false;
+}
+
+static bool migrate_degrades_locality(struct task_struct *p, struct lb_env *env)
+{
+	int src_nid, dst_nid;
+
+	if (!migrate_locality_prepare(p, env, &src_nid, &dst_nid))
 		return false;
 
-	if (p->numa_preferred_nid == dst_nid)
+	if (p->numa_faults[src_nid] > p->numa_faults[dst_nid])
 		return true;
 
 	return false;
@@ -3993,6 +4025,14 @@ static inline bool migrate_improves_locality(struct task_struct *p,
 {
 	return false;
 }
+
+
+static inline bool migrate_degrades_locality(struct task_struct *p,
+					     struct lb_env *env)
+{
+	return false;
+}
+
 #endif
 
 /*
@@ -4048,6 +4088,8 @@ int can_migrate_task(struct task_struct *p, struct lb_env *env)
 	 * 3) too many balance attempts have failed.
 	 */
 	tsk_cache_hot = task_hot(p, env->src_rq->clock_task, env->sd);
+	if (!tsk_cache_hot)
+		tsk_cache_hot = migrate_degrades_locality(p, env);
 
 	if (migrate_improves_locality(p, env)) {
 #ifdef CONFIG_SCHEDSTATS
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
