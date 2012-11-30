Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 682306B00E4
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 14:59:16 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so427555eaa.14
        for <linux-mm@kvack.org>; Fri, 30 Nov 2012 11:59:15 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 10/10] sched: Refine the 'shared tasks' memory interleaving logic
Date: Fri, 30 Nov 2012 20:58:41 +0100
Message-Id: <1354305521-11583-11-git-send-email-mingo@kernel.org>
In-Reply-To: <1354305521-11583-1-git-send-email-mingo@kernel.org>
References: <1354305521-11583-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

Change the adaptive memory policy code to take a majority of buddies
on a node into account. Previously, since this commit:

  "sched: Track shared task's node groups and interleave their memory allocations"

We'd include any node that has run a buddy in the past, which was too
aggressive and spread the allocations of 'mostly converged' workloads
too much, and prevented their further convergence.

Add a few other variants for testing:

  NUMA_POLICY_ADAPTIVE:		use memory on every node that runs a buddy of this task

  NUMA_POLICY_SYSWIDE:		use a simple, static, system-wide mask

  NUMA_POLICY_MAXNODE:		use memory on this task's 'maximum node'

  NUMA_POLICY_MAXBUDDIES:	use memory on the node with the most buddies

  NUMA_POLICY_MANYBUDDIES:	this is the default, a quorum of buddies
				determines the allocation mask

The 'many buddies' quorum logic appears to work best in practice,
but the 'maxnode' and 'syswide' ones are good, robust policies too.

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 kernel/sched/core.c     |  2 +-
 kernel/sched/fair.c     | 43 +++++++++++++++++++++++++++++++++++++------
 kernel/sched/features.h |  6 ++++++
 kernel/sched/sched.h    |  4 ++--
 4 files changed, 46 insertions(+), 9 deletions(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 47b14d1..9fef0d3 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -134,7 +134,7 @@ void update_rq_clock(struct rq *rq)
 #define SCHED_FEAT(name, enabled)	\
 	(1UL << __SCHED_FEAT_##name) * enabled |
 
-const_debug unsigned int sysctl_sched_features =
+const_debug u64 sysctl_sched_features =
 #include "features.h"
 	0;
 
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 9262692..18d732f 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1611,6 +1611,9 @@ static int sched_update_ideal_cpu_shared(struct task_struct *p, int *flip_tasks)
 	min_node_load = LONG_MAX;
 	min_node = -1;
 
+	if (sched_feat(NUMA_POLICY_MANYBUDDIES))
+		nodes_clear(p->numa_policy.v.nodes);
+
 	/*
 	 * Map out our maximum buddies layout:
 	 */
@@ -1677,16 +1680,28 @@ static int sched_update_ideal_cpu_shared(struct task_struct *p, int *flip_tasks)
 			min_node = node;
 		}
 
-		if (buddies)
-			node_set(node, p->numa_policy.v.nodes);
-		else
-			node_clear(node, p->numa_policy.v.nodes);
+		if (sched_feat(NUMA_POLICY_ADAPTIVE)) {
+			if (buddies)
+				node_set(node, p->numa_policy.v.nodes);
+			else
+				node_clear(node, p->numa_policy.v.nodes);
+		}
+
+		if (!buddies) {
+			if (sched_feat(NUMA_POLICY_MANYBUDDIES))
+				node_clear(node, p->numa_policy.v.nodes);
+			continue;
+		}
+
+		/* A majority of buddies attracts memory: */
+		if (sched_feat(NUMA_POLICY_MANYBUDDIES)) {
+			if (buddies >= 3)
+				node_set(node, p->numa_policy.v.nodes);
+		}
 
 		/* Don't go to a node that is near its capacity limit: */
 		if (node_load + SCHED_LOAD_SCALE > node_capacity)
 			continue;
-		if (!buddies)
-			continue;
 
 		if (buddies > max_buddies && target_cpu != -1) {
 			max_buddies = buddies;
@@ -1696,6 +1711,13 @@ static int sched_update_ideal_cpu_shared(struct task_struct *p, int *flip_tasks)
 		}
 	}
 
+	/* Cluster memory around the buddies maximum: */
+	if (sched_feat(NUMA_POLICY_MAXBUDDIES)) {
+		if (ideal_node != -1) {
+			nodes_clear(p->numa_policy.v.nodes);
+			node_set(ideal_node, p->numa_policy.v.nodes);
+		}
+	}
 	if (WARN_ON_ONCE(ideal_node == -1 && ideal_cpu != -1))
 		return this_cpu;
 	if (WARN_ON_ONCE(ideal_node != -1 && ideal_cpu == -1))
@@ -2079,6 +2101,15 @@ static void task_numa_placement_tick(struct task_struct *p)
 			p->numa_faults[idx_oldnode] = 0;
 		}
 		sched_setnuma(p, ideal_node, shared);
+
+		/* Allocate only the maximum node: */
+		if (sched_feat(NUMA_POLICY_MAXNODE)) {
+			nodes_clear(p->numa_policy.v.nodes);
+			node_set(ideal_node, p->numa_policy.v.nodes);
+		}
+		/* Allocate system-wide: */
+		if (sched_feat(NUMA_POLICY_SYSWIDE))
+			p->numa_policy.v.nodes = node_online_map;
 		/*
 		 * We changed a node, start scanning more frequently again
 		 * to map out the working set:
diff --git a/kernel/sched/features.h b/kernel/sched/features.h
index 9075faf..1775b80 100644
--- a/kernel/sched/features.h
+++ b/kernel/sched/features.h
@@ -81,5 +81,11 @@ SCHED_FEAT(NUMA_LB,			false)
 SCHED_FEAT(NUMA_GROUP_LB_COMPRESS,	true)
 SCHED_FEAT(NUMA_GROUP_LB_SPREAD,	true)
 SCHED_FEAT(MIGRATE_FAULT_STATS,		false)
+SCHED_FEAT(NUMA_POLICY_ADAPTIVE,	false)
+SCHED_FEAT(NUMA_POLICY_SYSWIDE,		false)
+SCHED_FEAT(NUMA_POLICY_MAXNODE,		false)
+SCHED_FEAT(NUMA_POLICY_MAXBUDDIES,	false)
+SCHED_FEAT(NUMA_POLICY_MANYBUDDIES,	true)
+
 SCHED_FEAT(NUMA_CONVERGE_MIGRATIONS,	true)
 #endif
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index ca92adf..ace1159 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -648,7 +648,7 @@ static inline void __set_task_cpu(struct task_struct *p, unsigned int cpu)
 # define const_debug const
 #endif
 
-extern const_debug unsigned int sysctl_sched_features;
+extern const_debug u64 sysctl_sched_features;
 
 #define SCHED_FEAT(name, enabled)	\
 	__SCHED_FEAT_##name ,
@@ -684,7 +684,7 @@ static __always_inline bool static_branch_##name(struct static_key *key) \
 extern struct static_key sched_feat_keys[__SCHED_FEAT_NR];
 #define sched_feat(x) (static_branch_##x(&sched_feat_keys[__SCHED_FEAT_##x]))
 #else /* !(SCHED_DEBUG && HAVE_JUMP_LABEL) */
-#define sched_feat(x) (sysctl_sched_features & (1UL << __SCHED_FEAT_##x))
+#define sched_feat(x) (sysctl_sched_features & (1ULL << __SCHED_FEAT_##x))
 #endif /* SCHED_DEBUG && HAVE_JUMP_LABEL */
 
 #ifdef CONFIG_NUMA_BALANCING
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
