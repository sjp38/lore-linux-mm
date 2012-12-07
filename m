Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 102446B00C9
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:25:12 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 43/49] mm: sched: numa: Delay PTE scanning until a task is scheduled on a new node
Date: Fri,  7 Dec 2012 10:23:46 +0000
Message-Id: <1354875832-9700-44-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Due to the fact that migrations are driven by the CPU a task is running
on there is no point tracking NUMA faults until one task runs on a new
node. This patch tracks the first node used by an address space. Until
it changes, PTE scanning is disabled and no NUMA hinting faults are
trapped. This should help workloads that are short-lived, do not care
about NUMA placement or have bound themselves to a single node.

This takes advantage of the logic in "mm: sched: numa: Implement slow
start for working set sampling" to delay when the checks are made. This
will take advantage of processes that set their CPU and node bindings
early in their lifetime. It will also potentially allow any initial load
balancing to take place.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mm_types.h |   10 ++++++++++
 kernel/fork.c            |    3 +++
 kernel/sched/fair.c      |   18 ++++++++++++++++++
 kernel/sched/features.h  |    4 +++-
 4 files changed, 34 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 62d18a9..e4551c1 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -418,10 +418,20 @@ struct mm_struct {
 
 	/* numa_scan_seq prevents two threads setting pte_numa */
 	int numa_scan_seq;
+
+	/*
+	 * The first node a task was scheduled on. If a task runs on
+	 * a different node than Make PTE Scan Go Now.
+	 */
+	int first_nid;
 #endif
 	struct uprobes_state uprobes_state;
 };
 
+/* first nid will either be a valid NID or one of these values */
+#define NUMA_PTE_SCAN_INIT	-1
+#define NUMA_PTE_SCAN_ACTIVE	-2
+
 static inline void mm_init_cpumask(struct mm_struct *mm)
 {
 #ifdef CONFIG_CPUMASK_OFFSTACK
diff --git a/kernel/fork.c b/kernel/fork.c
index 8b20ab7..e39111a 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -821,6 +821,9 @@ struct mm_struct *dup_mm(struct task_struct *tsk)
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	mm->pmd_huge_pte = NULL;
 #endif
+#ifdef CONFIG_BALANCE_NUMA
+	mm->first_nid = NUMA_PTE_SCAN_INIT;
+#endif
 	if (!mm_init(mm, tsk))
 		goto fail_nomem;
 
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index b4bc459..fd9c78c 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -861,6 +861,24 @@ void task_numa_work(struct callback_head *work)
 		return;
 
 	/*
+	 * We do not care about task placement until a task runs on a node
+	 * other than the first one used by the address space. This is
+	 * largely because migrations are driven by what CPU the task
+	 * is running on. If it's never scheduled on another node, it'll
+	 * not migrate so why bother trapping the fault.
+	 */
+	if (mm->first_nid == NUMA_PTE_SCAN_INIT)
+		mm->first_nid = numa_node_id();
+	if (mm->first_nid != NUMA_PTE_SCAN_ACTIVE) {
+		/* Are we running on a new node yet? */
+		if (numa_node_id() == mm->first_nid &&
+		    !sched_feat_numa(NUMA_FORCE))
+			return;
+
+		mm->first_nid = NUMA_PTE_SCAN_ACTIVE;
+	}
+
+	/*
 	 * Reset the scan period if enough time has gone by. Objective is that
 	 * scanning will be reduced if pages are properly placed. As tasks
 	 * can enter different phases this needs to be re-examined. Lacking
diff --git a/kernel/sched/features.h b/kernel/sched/features.h
index d402368..c3c86fd 100644
--- a/kernel/sched/features.h
+++ b/kernel/sched/features.h
@@ -65,8 +65,10 @@ SCHED_FEAT(LB_MIN, false)
 /*
  * Apply the automatic NUMA scheduling policy. Enabled automatically
  * at runtime if running on a NUMA machine. Can be controlled via
- * balancenuma=
+ * balancenuma=. Allow PTE scanning to be forced on UMA machines
+ * for debugging the core machinery.
  */
 #ifdef CONFIG_BALANCE_NUMA
 SCHED_FEAT(NUMA,	false)
+SCHED_FEAT(NUMA_FORCE,	false)
 #endif
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
