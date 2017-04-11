Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E1B286B03A2
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 10:06:18 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v6so7220792wrc.21
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 07:06:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x62si3181947wma.157.2017.04.11.07.06.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Apr 2017 07:06:16 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 4/6] mm, mempolicy: simplify rebinding mempolicies when updating cpusets
Date: Tue, 11 Apr 2017 16:06:07 +0200
Message-Id: <20170411140609.3787-5-vbabka@suse.cz>
In-Reply-To: <20170411140609.3787-1-vbabka@suse.cz>
References: <20170411140609.3787-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

Commit c0ff7453bb5c ("cpuset,mm: fix no node to alloc memory when changing
cpuset's mems") has introduced a two-step protocol when rebinding task's
mempolicy due to cpuset update, in order to avoid a parallel allocation seeing
an empty effective nodemask and failing. Later, commit cc9a6c877661 ("cpuset:
mm: reduce large amounts of memory barrier related damage v3") introduced
a seqlock protection and removed the synchronization point between the two
update steps. At that point (or perhaps later), the two-step rebinding became
unnecessary. Currently it only makes sure that the update first adds new nodes
in step 1 and then removes nodes in step 2. Without memory barriers the effects
are questionable, and even then this cannot prevent a parallel zonelist
iteration checking the nodemask at each step to observe all nodes as unusable
for allocation. We now fully rely on the seqlock to prevent premature OOMs and
allocation failures.

We can thus remove the two-step update parts and simplify the code.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/mempolicy.h      |   6 +--
 include/uapi/linux/mempolicy.h |   8 ----
 kernel/cgroup/cpuset.c         |   4 +-
 mm/mempolicy.c                 | 102 ++++++++---------------------------------
 4 files changed, 21 insertions(+), 99 deletions(-)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index ecb6cbeede5a..3a58b4be1b0c 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -142,8 +142,7 @@ bool vma_policy_mof(struct vm_area_struct *vma);
 
 extern void numa_default_policy(void);
 extern void numa_policy_init(void);
-extern void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new,
-				enum mpol_rebind_step step);
+extern void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new);
 extern void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new);
 
 extern int huge_node(struct vm_area_struct *vma,
@@ -260,8 +259,7 @@ static inline void numa_default_policy(void)
 }
 
 static inline void mpol_rebind_task(struct task_struct *tsk,
-				const nodemask_t *new,
-				enum mpol_rebind_step step)
+				const nodemask_t *new)
 {
 }
 
diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
index 9cd8b21dddbe..2a4d89508fec 100644
--- a/include/uapi/linux/mempolicy.h
+++ b/include/uapi/linux/mempolicy.h
@@ -24,13 +24,6 @@ enum {
 	MPOL_MAX,	/* always last member of enum */
 };
 
-enum mpol_rebind_step {
-	MPOL_REBIND_ONCE,	/* do rebind work at once(not by two step) */
-	MPOL_REBIND_STEP1,	/* first step(set all the newly nodes) */
-	MPOL_REBIND_STEP2,	/* second step(clean all the disallowed nodes)*/
-	MPOL_REBIND_NSTEP,
-};
-
 /* Flags for set_mempolicy */
 #define MPOL_F_STATIC_NODES	(1 << 15)
 #define MPOL_F_RELATIVE_NODES	(1 << 14)
@@ -65,7 +58,6 @@ enum mpol_rebind_step {
  */
 #define MPOL_F_SHARED  (1 << 0)	/* identify shared policies */
 #define MPOL_F_LOCAL   (1 << 1)	/* preferred local allocation */
-#define MPOL_F_REBINDING (1 << 2)	/* identify policies in rebinding */
 #define MPOL_F_MOF	(1 << 3) /* this policy wants migrate on fault */
 #define MPOL_F_MORON	(1 << 4) /* Migrate On protnone Reference On Node */
 
diff --git a/kernel/cgroup/cpuset.c b/kernel/cgroup/cpuset.c
index f6501f4f6040..b0159f8f8c89 100644
--- a/kernel/cgroup/cpuset.c
+++ b/kernel/cgroup/cpuset.c
@@ -1063,9 +1063,7 @@ static void cpuset_change_task_nodemask(struct task_struct *tsk,
 	}
 
 	nodes_or(tsk->mems_allowed, tsk->mems_allowed, *newmems);
-	mpol_rebind_task(tsk, newmems, MPOL_REBIND_STEP1);
-
-	mpol_rebind_task(tsk, newmems, MPOL_REBIND_STEP2);
+	mpol_rebind_task(tsk, newmems);
 	tsk->mems_allowed = *newmems;
 
 	if (need_loop) {
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 895d7a775f27..72e5aeb1feeb 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -146,22 +146,7 @@ struct mempolicy *get_task_policy(struct task_struct *p)
 
 static const struct mempolicy_operations {
 	int (*create)(struct mempolicy *pol, const nodemask_t *nodes);
-	/*
-	 * If read-side task has no lock to protect task->mempolicy, write-side
-	 * task will rebind the task->mempolicy by two step. The first step is
-	 * setting all the newly nodes, and the second step is cleaning all the
-	 * disallowed nodes. In this way, we can avoid finding no node to alloc
-	 * page.
-	 * If we have a lock to protect task->mempolicy in read-side, we do
-	 * rebind directly.
-	 *
-	 * step:
-	 * 	MPOL_REBIND_ONCE - do rebind work at once
-	 * 	MPOL_REBIND_STEP1 - set all the newly nodes
-	 * 	MPOL_REBIND_STEP2 - clean all the disallowed nodes
-	 */
-	void (*rebind)(struct mempolicy *pol, const nodemask_t *nodes,
-			enum mpol_rebind_step step);
+	void (*rebind)(struct mempolicy *pol, const nodemask_t *nodes);
 } mpol_ops[MPOL_MAX];
 
 static inline int mpol_store_user_nodemask(const struct mempolicy *pol)
@@ -304,19 +289,11 @@ void __mpol_put(struct mempolicy *p)
 	kmem_cache_free(policy_cache, p);
 }
 
-static void mpol_rebind_default(struct mempolicy *pol, const nodemask_t *nodes,
-				enum mpol_rebind_step step)
+static void mpol_rebind_default(struct mempolicy *pol, const nodemask_t *nodes)
 {
 }
 
-/*
- * step:
- * 	MPOL_REBIND_ONCE  - do rebind work at once
- * 	MPOL_REBIND_STEP1 - set all the newly nodes
- * 	MPOL_REBIND_STEP2 - clean all the disallowed nodes
- */
-static void mpol_rebind_nodemask(struct mempolicy *pol, const nodemask_t *nodes,
-				 enum mpol_rebind_step step)
+static void mpol_rebind_nodemask(struct mempolicy *pol, const nodemask_t *nodes)
 {
 	nodemask_t tmp;
 
@@ -325,35 +302,19 @@ static void mpol_rebind_nodemask(struct mempolicy *pol, const nodemask_t *nodes,
 	else if (pol->flags & MPOL_F_RELATIVE_NODES)
 		mpol_relative_nodemask(&tmp, &pol->w.user_nodemask, nodes);
 	else {
-		/*
-		 * if step == 1, we use ->w.cpuset_mems_allowed to cache the
-		 * result
-		 */
-		if (step == MPOL_REBIND_ONCE || step == MPOL_REBIND_STEP1) {
-			nodes_remap(tmp, pol->v.nodes,
-					pol->w.cpuset_mems_allowed, *nodes);
-			pol->w.cpuset_mems_allowed = step ? tmp : *nodes;
-		} else if (step == MPOL_REBIND_STEP2) {
-			tmp = pol->w.cpuset_mems_allowed;
-			pol->w.cpuset_mems_allowed = *nodes;
-		} else
-			BUG();
+		nodes_remap(tmp, pol->v.nodes,pol->w.cpuset_mems_allowed,
+								*nodes);
+		pol->w.cpuset_mems_allowed = tmp;
 	}
 
 	if (nodes_empty(tmp))
 		tmp = *nodes;
 
-	if (step == MPOL_REBIND_STEP1)
-		nodes_or(pol->v.nodes, pol->v.nodes, tmp);
-	else if (step == MPOL_REBIND_ONCE || step == MPOL_REBIND_STEP2)
-		pol->v.nodes = tmp;
-	else
-		BUG();
+	pol->v.nodes = tmp;
 }
 
 static void mpol_rebind_preferred(struct mempolicy *pol,
-				  const nodemask_t *nodes,
-				  enum mpol_rebind_step step)
+						const nodemask_t *nodes)
 {
 	nodemask_t tmp;
 
@@ -379,42 +340,19 @@ static void mpol_rebind_preferred(struct mempolicy *pol,
 /*
  * mpol_rebind_policy - Migrate a policy to a different set of nodes
  *
- * If read-side task has no lock to protect task->mempolicy, write-side
- * task will rebind the task->mempolicy by two step. The first step is
- * setting all the newly nodes, and the second step is cleaning all the
- * disallowed nodes. In this way, we can avoid finding no node to alloc
- * page.
- * If we have a lock to protect task->mempolicy in read-side, we do
- * rebind directly.
- *
- * step:
- * 	MPOL_REBIND_ONCE  - do rebind work at once
- * 	MPOL_REBIND_STEP1 - set all the newly nodes
- * 	MPOL_REBIND_STEP2 - clean all the disallowed nodes
+ * Per-vma policies are protected by mmap_sem. Allocations using per-task
+ * policies are protected by task->mems_allowed_seq to prevent a premature
+ * OOM/allocation failure due to parallel nodemask modification.
  */
-static void mpol_rebind_policy(struct mempolicy *pol, const nodemask_t *newmask,
-				enum mpol_rebind_step step)
+static void mpol_rebind_policy(struct mempolicy *pol, const nodemask_t *newmask)
 {
 	if (!pol)
 		return;
-	if (!mpol_store_user_nodemask(pol) && step == MPOL_REBIND_ONCE &&
+	if (!mpol_store_user_nodemask(pol) &&
 	    nodes_equal(pol->w.cpuset_mems_allowed, *newmask))
 		return;
 
-	if (step == MPOL_REBIND_STEP1 && (pol->flags & MPOL_F_REBINDING))
-		return;
-
-	if (step == MPOL_REBIND_STEP2 && !(pol->flags & MPOL_F_REBINDING))
-		BUG();
-
-	if (step == MPOL_REBIND_STEP1)
-		pol->flags |= MPOL_F_REBINDING;
-	else if (step == MPOL_REBIND_STEP2)
-		pol->flags &= ~MPOL_F_REBINDING;
-	else if (step >= MPOL_REBIND_NSTEP)
-		BUG();
-
-	mpol_ops[pol->mode].rebind(pol, newmask, step);
+	mpol_ops[pol->mode].rebind(pol, newmask);
 }
 
 /*
@@ -424,10 +362,9 @@ static void mpol_rebind_policy(struct mempolicy *pol, const nodemask_t *newmask,
  * Called with task's alloc_lock held.
  */
 
-void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new,
-			enum mpol_rebind_step step)
+void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new)
 {
-	mpol_rebind_policy(tsk->mempolicy, new, step);
+	mpol_rebind_policy(tsk->mempolicy, new);
 }
 
 /*
@@ -442,7 +379,7 @@ void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new)
 
 	down_write(&mm->mmap_sem);
 	for (vma = mm->mmap; vma; vma = vma->vm_next)
-		mpol_rebind_policy(vma->vm_policy, new, MPOL_REBIND_ONCE);
+		mpol_rebind_policy(vma->vm_policy, new);
 	up_write(&mm->mmap_sem);
 }
 
@@ -2103,10 +2040,7 @@ struct mempolicy *__mpol_dup(struct mempolicy *old)
 
 	if (current_cpuset_is_being_rebound()) {
 		nodemask_t mems = cpuset_mems_allowed(current);
-		if (new->flags & MPOL_F_REBINDING)
-			mpol_rebind_policy(new, &mems, MPOL_REBIND_STEP2);
-		else
-			mpol_rebind_policy(new, &mems, MPOL_REBIND_ONCE);
+		mpol_rebind_policy(new, &mems);
 	}
 	atomic_set(&new->refcnt, 1);
 	return new;
-- 
2.12.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
