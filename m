Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 60F276B0071
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 05:32:58 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 23/50] sched: Resist moving tasks towards nodes with fewer hinting faults
Date: Tue, 10 Sep 2013 10:32:03 +0100
Message-Id: <1378805550-29949-24-git-send-email-mgorman@suse.de>
In-Reply-To: <1378805550-29949-1-git-send-email-mgorman@suse.de>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Just as "sched: Favour moving tasks towards the preferred node" favours
moving tasks towards nodes with a higher number of recorded NUMA hinting
faults, this patch resists moving tasks towards nodes with lower faults.

[mgorman@suse.de: changelog]
Signed-off-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/fair.c     | 33 +++++++++++++++++++++++++++++++++
 kernel/sched/features.h |  8 ++++++++
 2 files changed, 41 insertions(+)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 216908c..5649280 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -4060,12 +4060,43 @@ static bool migrate_improves_locality(struct task_struct *p, struct lb_env *env)
 
 	return false;
 }
+
+
+static bool migrate_degrades_locality(struct task_struct *p, struct lb_env *env)
+{
+	int src_nid, dst_nid;
+
+	if (!sched_feat(NUMA) || !sched_feat(NUMA_RESIST_LOWER))
+		return false;
+
+	if (!p->numa_faults || !(env->sd->flags & SD_NUMA))
+		return false;
+
+	src_nid = cpu_to_node(env->src_cpu);
+	dst_nid = cpu_to_node(env->dst_cpu);
+
+	if (src_nid == dst_nid ||
+	    p->numa_migrate_seq >= sysctl_numa_balancing_settle_count)
+		return false;
+
+	if (p->numa_faults[dst_nid] < p->numa_faults[src_nid])
+ 		return true;
+ 
+ 	return false;
+}
+
 #else
 static inline bool migrate_improves_locality(struct task_struct *p,
 					     struct lb_env *env)
 {
 	return false;
 }
+
+static inline bool migrate_degrades_locality(struct task_struct *p,
+					     struct lb_env *env)
+{
+	return false;
+}
 #endif
 
 /*
@@ -4130,6 +4161,8 @@ int can_migrate_task(struct task_struct *p, struct lb_env *env)
 	 * 3) too many balance attempts have failed.
 	 */
 	tsk_cache_hot = task_hot(p, rq_clock_task(env->src_rq), env->sd);
+	if (!tsk_cache_hot)
+		tsk_cache_hot = migrate_degrades_locality(p, env);
 
 	if (migrate_improves_locality(p, env)) {
 #ifdef CONFIG_SCHEDSTATS
diff --git a/kernel/sched/features.h b/kernel/sched/features.h
index d9278ce..5716929 100644
--- a/kernel/sched/features.h
+++ b/kernel/sched/features.h
@@ -74,4 +74,12 @@ SCHED_FEAT(NUMA,	false)
  * balancing.
  */
 SCHED_FEAT(NUMA_FAVOUR_HIGHER, true)
+
+/*
+ * NUMA_RESIST_LOWER will resist moving tasks towards nodes where a
+ * lower number of hinting faults have been recorded. As this has
+ * the potential to prevent a task ever migrating to a new node
+ * due to CPU overload it is disabled by default.
+ */
+SCHED_FEAT(NUMA_RESIST_LOWER, false)
 #endif
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
