Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2C8FC60023A
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 04:55:41 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [10.3.21.13])
	by smtp-out.google.com with ESMTP id o2H8tabd011890
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 09:55:36 +0100
Received: from pwj7 (pwj7.prod.google.com [10.241.219.71])
	by hpaq13.eem.corp.google.com with ESMTP id o2H8tYP3020368
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 09:55:35 +0100
Received: by pwj7 with SMTP id 7so543686pwj.38
        for <linux-mm@kvack.org>; Wed, 17 Mar 2010 01:55:34 -0700 (PDT)
Date: Wed, 17 Mar 2010 01:55:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 03/11 -mm v4] oom: select task from tasklist for mempolicy
 ooms
In-Reply-To: <alpine.DEB.2.00.1003170151540.31796@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1003170153010.31796@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1003170151540.31796@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The oom killer presently kills current whenever there is no more memory
free or reclaimable on its mempolicy's nodes.  There is no guarantee that
current is a memory-hogging task or that killing it will free any
substantial amount of memory, however.

In such situations, it is better to scan the tasklist for nodes that are
allowed to allocate on current's set of nodes and kill the task with the
highest badness() score.  This ensures that the most memory-hogging task,
or the one configured by the user with /proc/pid/oom_adj, is always
selected in such scenarios.

It is necessary to synchronize the detachment of task->mempolicy with
task_lock(task) to ensure it is not prematurely destroyed while a user is
operating on it.

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/mempolicy.h |   13 +++++++-
 kernel/exit.c             |    8 ++--
 mm/mempolicy.c            |   44 +++++++++++++++++++++++++
 mm/oom_kill.c             |   77 +++++++++++++++++++++++++++-----------------
 4 files changed, 107 insertions(+), 35 deletions(-)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -202,6 +202,8 @@ extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
 				unsigned long addr, gfp_t gfp_flags,
 				struct mempolicy **mpol, nodemask_t **nodemask);
 extern bool init_nodemask_of_mempolicy(nodemask_t *mask);
+extern bool mempolicy_nodemask_intersects(struct task_struct *tsk,
+				const nodemask_t *mask);
 extern unsigned slab_node(struct mempolicy *policy);
 
 extern enum zone_type policy_zone;
@@ -329,7 +331,16 @@ static inline struct zonelist *huge_zonelist(struct vm_area_struct *vma,
 	return node_zonelist(0, gfp_flags);
 }
 
-static inline bool init_nodemask_of_mempolicy(nodemask_t *m) { return false; }
+static inline bool init_nodemask_of_mempolicy(nodemask_t *m)
+{
+	return false;
+}
+
+static inline bool mempolicy_nodemask_intersects(struct task_struct *tsk,
+			const nodemask_t *mask)
+{
+	return false;
+}
 
 static inline int do_migrate_pages(struct mm_struct *mm,
 			const nodemask_t *from_nodes,
diff --git a/kernel/exit.c b/kernel/exit.c
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -697,6 +697,10 @@ static void exit_mm(struct task_struct * tsk)
 	enter_lazy_tlb(mm, current);
 	/* We don't want this task to be frozen prematurely */
 	clear_freeze_flag(tsk);
+#ifdef CONFIG_NUMA
+	mpol_put(tsk->mempolicy);
+	tsk->mempolicy = NULL;
+#endif
 	task_unlock(tsk);
 	mm_update_next_owner(mm);
 	mmput(mm);
@@ -1001,10 +1005,6 @@ NORET_TYPE void do_exit(long code)
 	perf_event_exit_task(tsk);
 
 	exit_notify(tsk, group_dead);
-#ifdef CONFIG_NUMA
-	mpol_put(tsk->mempolicy);
-	tsk->mempolicy = NULL;
-#endif
 #ifdef CONFIG_FUTEX
 	if (unlikely(current->pi_state_cache))
 		kfree(current->pi_state_cache);
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1638,6 +1638,50 @@ bool init_nodemask_of_mempolicy(nodemask_t *mask)
 }
 #endif
 
+/*
+ * mempolicy_nodemask_intersects
+ *
+ * If tsk's mempolicy is "default" [NULL], return 'true' to indicate default
+ * policy.  Otherwise, check for intersection between mask and the policy
+ * nodemask for 'bind' or 'interleave' policy.  For 'perferred' or 'local'
+ * policy, always return true since it may allocate elsewhere on fallback.
+ *
+ * Takes task_lock(tsk) to prevent freeing of its mempolicy.
+ */
+bool mempolicy_nodemask_intersects(struct task_struct *tsk,
+					const nodemask_t *mask)
+{
+	struct mempolicy *mempolicy;
+	bool ret = true;
+
+	if (!mask)
+		return ret;
+	task_lock(tsk);
+	mempolicy = tsk->mempolicy;
+	if (!mempolicy)
+		goto out;
+
+	switch (mempolicy->mode) {
+	case MPOL_PREFERRED:
+		/*
+		 * MPOL_PREFERRED and MPOL_F_LOCAL are only preferred nodes to
+		 * allocate from, they may fallback to other nodes when oom.
+		 * Thus, it's possible for tsk to have allocated memory from
+		 * nodes in mask.
+		 */
+		break;
+	case MPOL_BIND:
+	case MPOL_INTERLEAVE:
+		ret = nodes_intersects(mempolicy->v.nodes, *mask);
+		break;
+	default:
+		BUG();
+	}
+out:
+	task_unlock(tsk);
+	return ret;
+}
+
 /* Allocate a page in interleaved policy.
    Own path because it needs to do special accounting. */
 static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -26,6 +26,7 @@
 #include <linux/module.h>
 #include <linux/notifier.h>
 #include <linux/memcontrol.h>
+#include <linux/mempolicy.h>
 #include <linux/security.h>
 
 int sysctl_panic_on_oom;
@@ -36,19 +37,35 @@ static DEFINE_SPINLOCK(zone_scan_lock);
 
 /*
  * Do all threads of the target process overlap our allowed nodes?
+ * @tsk: task struct of which task to consider
+ * @mask: nodemask passed to page allocator for mempolicy ooms
  */
-static int has_intersects_mems_allowed(struct task_struct *tsk)
+static bool has_intersects_mems_allowed(struct task_struct *tsk,
+						const nodemask_t *mask)
 {
-	struct task_struct *t;
+	struct task_struct *start = tsk;
 
-	t = tsk;
 	do {
-		if (cpuset_mems_allowed_intersects(current, t))
-			return 1;
-		t = next_thread(t);
-	} while (t != tsk);
-
-	return 0;
+		if (mask) {
+			/*
+			 * If this is a mempolicy constrained oom, tsk's
+			 * cpuset is irrelevant.  Only return true if its
+			 * mempolicy intersects current, otherwise it may be
+			 * needlessly killed.
+			 */
+			if (mempolicy_nodemask_intersects(tsk, mask))
+				return true;
+		} else {
+			/*
+			 * This is not a mempolicy constrained oom, so only
+			 * check the mems of tsk's cpuset.
+			 */
+			if (cpuset_mems_allowed_intersects(current, tsk))
+				return true;
+		}
+		tsk = next_thread(tsk);
+	} while (tsk != start);
+	return false;
 }
 
 /**
@@ -236,7 +253,8 @@ static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
  * (not docbooked, we don't want this one cluttering up the manual)
  */
 static struct task_struct *select_bad_process(unsigned long *ppoints,
-						struct mem_cgroup *mem)
+		struct mem_cgroup *mem, enum oom_constraint constraint,
+		const nodemask_t *mask)
 {
 	struct task_struct *p;
 	struct task_struct *chosen = NULL;
@@ -258,7 +276,9 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 			continue;
 		if (mem && !task_in_mem_cgroup(p, mem))
 			continue;
-		if (!has_intersects_mems_allowed(p))
+		if (!has_intersects_mems_allowed(p,
+				constraint == CONSTRAINT_MEMORY_POLICY ? mask :
+									 NULL))
 			continue;
 
 		/*
@@ -482,7 +502,7 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
 		panic("out of memory(memcg). panic_on_oom is selected.\n");
 	read_lock(&tasklist_lock);
 retry:
-	p = select_bad_process(&points, mem);
+	p = select_bad_process(&points, mem, CONSTRAINT_NONE, NULL);
 	if (PTR_ERR(p) == -1UL)
 		goto out;
 
@@ -564,7 +584,8 @@ void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_mask)
 /*
  * Must be called with tasklist_lock held for read.
  */
-static void __out_of_memory(gfp_t gfp_mask, int order)
+static void __out_of_memory(gfp_t gfp_mask, int order,
+			enum oom_constraint constraint, const nodemask_t *mask)
 {
 	struct task_struct *p;
 	unsigned long points;
@@ -578,7 +599,7 @@ retry:
 	 * Rambo mode: Shoot down a process and hope it solves whatever
 	 * issues we may have.
 	 */
-	p = select_bad_process(&points, NULL);
+	p = select_bad_process(&points, NULL, constraint, mask);
 
 	if (PTR_ERR(p) == -1UL)
 		return;
@@ -612,7 +633,8 @@ void pagefault_out_of_memory(void)
 		panic("out of memory from page fault. panic_on_oom is selected.\n");
 
 	read_lock(&tasklist_lock);
-	__out_of_memory(0, 0); /* unknown gfp_mask and order */
+	/* unknown gfp_mask and order */
+	__out_of_memory(0, 0, CONSTRAINT_NONE, NULL);
 	read_unlock(&tasklist_lock);
 
 	/*
@@ -628,6 +650,7 @@ void pagefault_out_of_memory(void)
  * @zonelist: zonelist pointer
  * @gfp_mask: memory allocation flags
  * @order: amount of memory being requested as a power of 2
+ * @nodemask: nodemask passed to page allocator
  *
  * If we run out of memory, we have the choice between either
  * killing a random task (bad), letting the system crash (worse)
@@ -656,24 +679,18 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	 */
 	constraint = constrained_alloc(zonelist, gfp_mask, nodemask);
 	read_lock(&tasklist_lock);
-
-	switch (constraint) {
-	case CONSTRAINT_MEMORY_POLICY:
-		oom_kill_process(current, gfp_mask, order, 0, NULL,
-				"No available memory (MPOL_BIND)");
-		break;
-
-	case CONSTRAINT_NONE:
-		if (sysctl_panic_on_oom) {
+	if (unlikely(sysctl_panic_on_oom)) {
+		/*
+		 * panic_on_oom only affects CONSTRAINT_NONE, the kernel
+		 * should not panic for cpuset or mempolicy induced memory
+		 * failures.
+		 */
+		if (constraint == CONSTRAINT_NONE) {
 			dump_header(NULL, gfp_mask, order, NULL);
-			panic("out of memory. panic_on_oom is selected\n");
+			panic("Out of memory: panic_on_oom is enabled\n");
 		}
-		/* Fall-through */
-	case CONSTRAINT_CPUSET:
-		__out_of_memory(gfp_mask, order);
-		break;
 	}
-
+	__out_of_memory(gfp_mask, order, constraint, nodemask);
 	read_unlock(&tasklist_lock);
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
