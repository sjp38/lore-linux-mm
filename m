Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 239036B026E
	for <linux-mm@kvack.org>; Tue,  4 May 2010 06:53:08 -0400 (EDT)
Message-ID: <4BDFFCC8.4040205@cn.fujitsu.com>
Date: Tue, 04 May 2010 18:54:00 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: [PATCH 1/2] mempolicy: restructure rebinding-mempolicy functions
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@suse.de>, Paul Menage <menage@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

In order to fix no node to alloc memory, when we want to update mempolicy and
mems_allowed, we expand the set of nodes first (set all the newly nodes) and
shrink the set of nodes lazily(clean disallowed nodes), But the mempolicy's
rebind functions may breaks the expanding.

So we restructure the mempolicy's rebind functions and split the rebind work to
two steps, just like the update of cpuset's mems:
The 1st step: expand the set of the mempolicy's nodes.
The 2nd step: shrink the set of the mempolicy's nodes.
It is used when there is no real lock to protect the mempolicy in the read-side.
Otherwise we can do rebind work at once.

In order to implement it, we defined
	enum mpol_rebind_step {
		MPOL_REBIND_ONCE,
		MPOL_REBIND_STEP1,
		MPOL_REBIND_STEP2,
		MPOL_REBIND_NSTEP,
	};
If the mempolicy needn't be updated by two steps, we can pass MPOL_REBIND_ONCE
to the rebind functions. Or we can pass MPOL_REBIND_STEP1 to do the first step
of the rebind work and pass MPOL_REBIND_STEP2 to do the second step work.

Besides that, it maybe long time between these two step and we have to release
the lock that protects mempolicy and mems_allowed. If we hold the lock once
again, we must check whether the current mempolicy is under the rebinding (the
first step has been done) or not, because the task may alloc a new mempolicy
when we don't hold the lock. So we defined the following flag to identify it.
	#define MPOL_F_REBINDING (1 << 2)

The new functions will be used in the next patch.

Signed-off-by: Miao Xie <miaox@cn.fujitsu.com>
---
 include/linux/mempolicy.h |   15 ++++-
 kernel/cpuset.c           |    4 +-
 mm/mempolicy.c            |  124 ++++++++++++++++++++++++++++++++++++++-------
 3 files changed, 119 insertions(+), 24 deletions(-)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 1cc966c..7b9ef6b 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -23,6 +23,13 @@ enum {
 	MPOL_MAX,	/* always last member of enum */
 };
 
+enum mpol_rebind_step {
+	MPOL_REBIND_ONCE,	/* do rebind work at once(not by two step) */
+	MPOL_REBIND_STEP1,	/* first step(set all the newly nodes) */
+	MPOL_REBIND_STEP2,	/* second step(clean all the disallowed nodes)*/
+	MPOL_REBIND_NSTEP,
+};
+
 /* Flags for set_mempolicy */
 #define MPOL_F_STATIC_NODES	(1 << 15)
 #define MPOL_F_RELATIVE_NODES	(1 << 14)
@@ -51,6 +58,7 @@ enum {
  */
 #define MPOL_F_SHARED  (1 << 0)	/* identify shared policies */
 #define MPOL_F_LOCAL   (1 << 1)	/* preferred local allocation */
+#define MPOL_F_REBINDING (1 << 2)	/* identify policies in rebinding */
 
 #ifdef __KERNEL__
 
@@ -193,8 +201,8 @@ struct mempolicy *mpol_shared_policy_lookup(struct shared_policy *sp,
 
 extern void numa_default_policy(void);
 extern void numa_policy_init(void);
-extern void mpol_rebind_task(struct task_struct *tsk,
-					const nodemask_t *new);
+extern void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new,
+				enum mpol_rebind_step step);
 extern void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new);
 extern void mpol_fix_fork_child_flag(struct task_struct *p);
 
@@ -308,7 +316,8 @@ static inline void numa_default_policy(void)
 }
 
 static inline void mpol_rebind_task(struct task_struct *tsk,
-					const nodemask_t *new)
+				const nodemask_t *new,
+				enum mpol_rebind_step step)
 {
 }
 
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index d109467..a4d7cfb 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -953,8 +953,8 @@ static void cpuset_change_task_nodemask(struct task_struct *tsk,
 					nodemask_t *newmems)
 {
 	nodes_or(tsk->mems_allowed, tsk->mems_allowed, *newmems);
-	mpol_rebind_task(tsk, &tsk->mems_allowed);
-	mpol_rebind_task(tsk, newmems);
+	mpol_rebind_task(tsk, &tsk->mems_allowed, MPOL_REBIND_ONCE);
+	mpol_rebind_task(tsk, newmems, MPOL_REBIND_ONCE);
 	tsk->mems_allowed = *newmems;
 }
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 08f40a2..acfacf6 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -119,7 +119,22 @@ struct mempolicy default_policy = {
 
 static const struct mempolicy_operations {
 	int (*create)(struct mempolicy *pol, const nodemask_t *nodes);
-	void (*rebind)(struct mempolicy *pol, const nodemask_t *nodes);
+	/*
+	 * If read-side task has no lock to protect task->mempolicy, write-side
+	 * task will rebind the task->mempolicy by two step. The first step is 
+	 * setting all the newly nodes, and the second step is cleaning all the
+	 * disallowed nodes. In this way, we can avoid finding no node to alloc
+	 * page.
+	 * If we have a lock to protect task->mempolicy in read-side, we do
+	 * rebind directly.
+	 *
+	 * step:
+	 * 	MPOL_REBIND_ONCE - do rebind work at once
+	 * 	MPOL_REBIND_STEP1 - set all the newly nodes
+	 * 	MPOL_REBIND_STEP2 - clean all the disallowed nodes
+	 */
+	void (*rebind)(struct mempolicy *pol, const nodemask_t *nodes,
+			enum mpol_rebind_step step);
 } mpol_ops[MPOL_MAX];
 
 /* Check that the nodemask contains at least one populated zone */
@@ -277,12 +292,19 @@ void __mpol_put(struct mempolicy *p)
 	kmem_cache_free(policy_cache, p);
 }
 
-static void mpol_rebind_default(struct mempolicy *pol, const nodemask_t *nodes)
+static void mpol_rebind_default(struct mempolicy *pol, const nodemask_t *nodes,
+				enum mpol_rebind_step step)
 {
 }
 
-static void mpol_rebind_nodemask(struct mempolicy *pol,
-				 const nodemask_t *nodes)
+/*
+ * step:
+ * 	MPOL_REBIND_ONCE  - do rebind work at once
+ * 	MPOL_REBIND_STEP1 - set all the newly nodes
+ * 	MPOL_REBIND_STEP2 - clean all the disallowed nodes
+ */
+static void mpol_rebind_nodemask(struct mempolicy *pol, const nodemask_t *nodes,
+				 enum mpol_rebind_step step)
 {
 	nodemask_t tmp;
 
@@ -291,12 +313,31 @@ static void mpol_rebind_nodemask(struct mempolicy *pol,
 	else if (pol->flags & MPOL_F_RELATIVE_NODES)
 		mpol_relative_nodemask(&tmp, &pol->w.user_nodemask, nodes);
 	else {
-		nodes_remap(tmp, pol->v.nodes, pol->w.cpuset_mems_allowed,
-			    *nodes);
-		pol->w.cpuset_mems_allowed = *nodes;
+		/*
+		 * if step == 1, we use ->w.cpuset_mems_allowed to cache the
+		 * result
+		 */
+		if (step == MPOL_REBIND_ONCE || step == MPOL_REBIND_STEP1) {
+			nodes_remap(tmp, pol->v.nodes,
+					pol->w.cpuset_mems_allowed, *nodes);
+			pol->w.cpuset_mems_allowed = step ? tmp : *nodes;
+		} else if (step == MPOL_REBIND_STEP2) {
+			tmp = pol->w.cpuset_mems_allowed;
+			pol->w.cpuset_mems_allowed = *nodes;
+		} else
+			BUG();
 	}
 
-	pol->v.nodes = tmp;
+	if (nodes_empty(tmp))
+		tmp = *nodes;
+
+	if (step == MPOL_REBIND_STEP1)
+		nodes_or(pol->v.nodes, pol->v.nodes, tmp);
+	else if (step == MPOL_REBIND_ONCE || step == MPOL_REBIND_STEP2)
+		pol->v.nodes = tmp;
+	else
+		BUG();
+
 	if (!node_isset(current->il_next, tmp)) {
 		current->il_next = next_node(current->il_next, tmp);
 		if (current->il_next >= MAX_NUMNODES)
@@ -307,7 +348,8 @@ static void mpol_rebind_nodemask(struct mempolicy *pol,
 }
 
 static void mpol_rebind_preferred(struct mempolicy *pol,
-				  const nodemask_t *nodes)
+				  const nodemask_t *nodes,
+				  enum mpol_rebind_step step)
 {
 	nodemask_t tmp;
 
@@ -330,16 +372,45 @@ static void mpol_rebind_preferred(struct mempolicy *pol,
 	}
 }
 
-/* Migrate a policy to a different set of nodes */
-static void mpol_rebind_policy(struct mempolicy *pol,
-			       const nodemask_t *newmask)
+/*
+ * mpol_rebind_policy - Migrate a policy to a different set of nodes
+ *
+ * If read-side task has no lock to protect task->mempolicy, write-side
+ * task will rebind the task->mempolicy by two step. The first step is 
+ * setting all the newly nodes, and the second step is cleaning all the
+ * disallowed nodes. In this way, we can avoid finding no node to alloc
+ * page.
+ * If we have a lock to protect task->mempolicy in read-side, we do
+ * rebind directly.
+ *
+ * step:
+ * 	MPOL_REBIND_ONCE  - do rebind work at once
+ * 	MPOL_REBIND_STEP1 - set all the newly nodes
+ * 	MPOL_REBIND_STEP2 - clean all the disallowed nodes
+ */
+static void mpol_rebind_policy(struct mempolicy *pol, const nodemask_t *newmask,
+				enum mpol_rebind_step step)
 {
 	if (!pol)
 		return;
-	if (!mpol_store_user_nodemask(pol) &&
+	if (!mpol_store_user_nodemask(pol) && step == 0 &&
 	    nodes_equal(pol->w.cpuset_mems_allowed, *newmask))
 		return;
-	mpol_ops[pol->mode].rebind(pol, newmask);
+
+	if (step == MPOL_REBIND_STEP1 && (pol->flags & MPOL_F_REBINDING))
+		return;
+
+	if (step == MPOL_REBIND_STEP2 && !(pol->flags & MPOL_F_REBINDING))
+		BUG();
+
+	if (step == MPOL_REBIND_STEP1)
+		pol->flags |= MPOL_F_REBINDING;
+	else if (step == MPOL_REBIND_STEP2)
+		pol->flags &= ~MPOL_F_REBINDING;
+	else if (step >= MPOL_REBIND_NSTEP)
+		BUG();
+
+	mpol_ops[pol->mode].rebind(pol, newmask, step);
 }
 
 /*
@@ -349,9 +420,10 @@ static void mpol_rebind_policy(struct mempolicy *pol,
  * Called with task's alloc_lock held.
  */
 
-void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new)
+void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new,
+			enum mpol_rebind_step step)
 {
-	mpol_rebind_policy(tsk->mempolicy, new);
+	mpol_rebind_policy(tsk->mempolicy, new, step);
 }
 
 /*
@@ -366,7 +438,7 @@ void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new)
 
 	down_write(&mm->mmap_sem);
 	for (vma = mm->mmap; vma; vma = vma->vm_next)
-		mpol_rebind_policy(vma->vm_policy, new);
+		mpol_rebind_policy(vma->vm_policy, new, MPOL_REBIND_ONCE);
 	up_write(&mm->mmap_sem);
 }
 
@@ -1750,6 +1822,9 @@ EXPORT_SYMBOL(alloc_pages_current);
  * with the mems_allowed returned by cpuset_mems_allowed().  This
  * keeps mempolicies cpuset relative after its cpuset moves.  See
  * further kernel/cpuset.c update_nodemask().
+ *
+ * current's mempolicy may be rebinded by the other task(the task that changes
+ * cpuset's mems), so we needn't do rebind work for current task.
  */
 
 /* Slow path of a mempolicy duplicate */
@@ -1759,13 +1834,24 @@ struct mempolicy *__mpol_dup(struct mempolicy *old)
 
 	if (!new)
 		return ERR_PTR(-ENOMEM);
+
+	/* task's mempolicy is protected by alloc_lock */
+	if (old == current->mempolicy) {
+		task_lock(current);
+		*new = *old;
+		task_unlock(current);
+	} else
+		*new = *old;
+
 	rcu_read_lock();
 	if (current_cpuset_is_being_rebound()) {
 		nodemask_t mems = cpuset_mems_allowed(current);
-		mpol_rebind_policy(old, &mems);
+		if (new->flags & MPOL_F_REBINDING)
+			mpol_rebind_policy(new, &mems, MPOL_REBIND_STEP2);
+		else
+			mpol_rebind_policy(new, &mems, MPOL_REBIND_ONCE);
 	}
 	rcu_read_unlock();
-	*new = *old;
 	atomic_set(&new->refcnt, 1);
 	return new;
 }
-- 
1.6.5.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
