Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id B3FE06B0068
	for <linux-mm@kvack.org>; Fri,  5 Jul 2013 19:09:18 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 15/15] sched: Favour moving tasks towards nodes that incurred more faults
Date: Sat,  6 Jul 2013 00:09:02 +0100
Message-Id: <1373065742-9753-16-git-send-email-mgorman@suse.de>
In-Reply-To: <1373065742-9753-1-git-send-email-mgorman@suse.de>
References: <1373065742-9753-1-git-send-email-mgorman@suse.de>
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
 kernel/sched/fair.c | 63 ++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 57 insertions(+), 6 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index c303ba6..1a4af96 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -4069,24 +4069,65 @@ task_hot(struct task_struct *p, u64 now, struct sched_domain *sd)
 }
 
 #ifdef CONFIG_NUMA_BALANCING
-/* Returns true if the destination node has incurred more faults */
-static bool migrate_improves_locality(struct task_struct *p, struct lb_env *env)
+
+static bool migrate_locality_prepare(struct task_struct *p, struct lb_env *env,
+			int *src_nid, int *dst_nid,
+			unsigned long *src_faults, unsigned long *dst_faults)
 {
-	int src_nid, dst_nid;
+	int priv;
 
 	if (!p->numa_faults || !(env->sd->flags & SD_NUMA))
 		return false;
 
-	src_nid = cpu_to_node(env->src_cpu);
-	dst_nid = cpu_to_node(env->dst_cpu);
+	*src_nid = cpu_to_node(env->src_cpu);
+	*dst_nid = cpu_to_node(env->dst_cpu);
 
-	if (src_nid == dst_nid ||
+	if (*src_nid == *dst_nid ||
 	    p->numa_migrate_seq >= sysctl_numa_balancing_settle_count)
 		return false;
 
+	/* Calculate private/shared faults on the two nodes */
+	*src_faults = 0;
+	*dst_faults = 0;
+	for (priv = 0; priv < 2; priv++) {
+		*src_faults += p->numa_faults[task_faults_idx(*src_nid, priv)];
+		*dst_faults += p->numa_faults[task_faults_idx(*dst_nid, priv)];
+	}
+
+	return true;
+}
+
+/* Returns true if the destination node has incurred more faults */
+static bool migrate_improves_locality(struct task_struct *p, struct lb_env *env)
+{
+	int src_nid, dst_nid;
+	unsigned long src, dst;
+
+	if (!migrate_locality_prepare(p, env, &src_nid, &dst_nid, &src, &dst))
+		return false;
+
+	/* Move towards node if it is the preferred node */
 	if (p->numa_preferred_nid == dst_nid)
 		return true;
 
+	/* Move towards node if there were more NUMA hinting faults recorded */
+	if (dst > src)
+		return true;
+
+	return false;
+}
+
+static bool migrate_degrades_locality(struct task_struct *p, struct lb_env *env)
+{
+	int src_nid, dst_nid;
+	unsigned long src, dst;
+
+	if (!migrate_locality_prepare(p, env, &src_nid, &dst_nid, &src, &dst))
+		return false;
+
+	if (src > dst)
+		return true;
+
 	return false;
 }
 #else
@@ -4095,6 +4136,14 @@ static inline bool migrate_improves_locality(struct task_struct *p,
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
@@ -4150,6 +4199,8 @@ int can_migrate_task(struct task_struct *p, struct lb_env *env)
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
