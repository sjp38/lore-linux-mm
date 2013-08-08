Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id DBF3D900006
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 10:00:52 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 08/27] Revert "mm: sched: numa: Delay PTE scanning until a task is scheduled on a new node"
Date: Thu,  8 Aug 2013 15:00:20 +0100
Message-Id: <1375970439-5111-9-git-send-email-mgorman@suse.de>
In-Reply-To: <1375970439-5111-1-git-send-email-mgorman@suse.de>
References: <1375970439-5111-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

PTE scanning and NUMA hinting fault handling is expensive so commit
5bca2303 ("mm: sched: numa: Delay PTE scanning until a task is scheduled
on a new node") deferred the PTE scan until a task had been scheduled on
another node. The problem is that in the purely shared memory case that
this may never happen and no NUMA hinting fault information will be
captured. We are not ruling out the possibility that something better
can be done here but for now, this patch needs to be reverted and depend
entirely on the scan_delay to avoid punishing short-lived processes.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mm_types.h | 10 ----------
 kernel/fork.c            |  3 ---
 kernel/sched/fair.c      | 18 ------------------
 kernel/sched/features.h  |  4 +---
 4 files changed, 1 insertion(+), 34 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index fb425aa..86f3a56 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -426,20 +426,10 @@ struct mm_struct {
 
 	/* numa_scan_seq prevents two threads setting pte_numa */
 	int numa_scan_seq;
-
-	/*
-	 * The first node a task was scheduled on. If a task runs on
-	 * a different node than Make PTE Scan Go Now.
-	 */
-	int first_nid;
 #endif
 	struct uprobes_state uprobes_state;
 };
 
-/* first nid will either be a valid NID or one of these values */
-#define NUMA_PTE_SCAN_INIT	-1
-#define NUMA_PTE_SCAN_ACTIVE	-2
-
 static inline void mm_init_cpumask(struct mm_struct *mm)
 {
 #ifdef CONFIG_CPUMASK_OFFSTACK
diff --git a/kernel/fork.c b/kernel/fork.c
index 403d2bb..61e799e 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -820,9 +820,6 @@ struct mm_struct *dup_mm(struct task_struct *tsk)
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	mm->pmd_huge_pte = NULL;
 #endif
-#ifdef CONFIG_NUMA_BALANCING
-	mm->first_nid = NUMA_PTE_SCAN_INIT;
-#endif
 	if (!mm_init(mm, tsk))
 		goto fail_nomem;
 
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index cc2ee69..bb5d978 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -901,24 +901,6 @@ void task_numa_work(struct callback_head *work)
 		return;
 
 	/*
-	 * We do not care about task placement until a task runs on a node
-	 * other than the first one used by the address space. This is
-	 * largely because migrations are driven by what CPU the task
-	 * is running on. If it's never scheduled on another node, it'll
-	 * not migrate so why bother trapping the fault.
-	 */
-	if (mm->first_nid == NUMA_PTE_SCAN_INIT)
-		mm->first_nid = numa_node_id();
-	if (mm->first_nid != NUMA_PTE_SCAN_ACTIVE) {
-		/* Are we running on a new node yet? */
-		if (numa_node_id() == mm->first_nid &&
-		    !sched_feat_numa(NUMA_FORCE))
-			return;
-
-		mm->first_nid = NUMA_PTE_SCAN_ACTIVE;
-	}
-
-	/*
 	 * Reset the scan period if enough time has gone by. Objective is that
 	 * scanning will be reduced if pages are properly placed. As tasks
 	 * can enter different phases this needs to be re-examined. Lacking
diff --git a/kernel/sched/features.h b/kernel/sched/features.h
index 99399f8..cba5c61 100644
--- a/kernel/sched/features.h
+++ b/kernel/sched/features.h
@@ -63,10 +63,8 @@ SCHED_FEAT(LB_MIN, false)
 /*
  * Apply the automatic NUMA scheduling policy. Enabled automatically
  * at runtime if running on a NUMA machine. Can be controlled via
- * numa_balancing=. Allow PTE scanning to be forced on UMA machines
- * for debugging the core machinery.
+ * numa_balancing=
  */
 #ifdef CONFIG_NUMA_BALANCING
 SCHED_FEAT(NUMA,	false)
-SCHED_FEAT(NUMA_FORCE,	false)
 #endif
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
