From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Wed, 10 Oct 2007 16:58:49 -0400
Message-Id: <20071010205849.7230.81877.sendpatchset@localhost>
In-Reply-To: <20071010205837.7230.42818.sendpatchset@localhost>
References: <20071010205837.7230.42818.sendpatchset@localhost>
Subject: [PATCH/RFC 2/2] Mem Policy: Fixup Shm and Interleave Policy Reference Counting
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: ak@suse.de, clameter@sgi.com, gregkh@suse.de, linux-mm@kvack.org, mel@skynet.ie, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

PATCH 2/2 Mempolicy:  Fixup Shm and Interleave Policy Reference Counting

Against: 2.6.23-rc8-mm2

* In the memory policy reference counting cleanup patch,  I
  missed one path that needs to unreference the memory policy.
  After computing the target node for interleave policy, we need
  to drop the reference if the policy is not the system default
  nor the current task's policy.

* In huge_zonelist(), I was unconditionally unref'ing the policy
  in the interleave path, even when it was a policy that didn't 
  need it.  Fix this!

  Note:  I investigated moving the check for "policy_needs_unref"
  to the mpol_free() wrapper, but this led to nasty circular header
  dependencies.  If we wanted to make mpol_free() an external 
  function, rather than a static inline, I could do this and 
  remove several checks.  I'd still need to keep an explicit
  check in alloc_page_vma() if we want to use a tail-call for
  the fast path.

* get_vma_policy() assumes that shared policies are referenced by
  the get_policy() vm_op, if any.  This is true for shmem_get_policy()
  but not for shm_get_policy() when the "backing file" does not
  support a get_policy() vm_op.  The latter is the case for SHM_HUGETLB
  segments.  Because get_vma_policy() expects the get_policy() op to
  have added a ref, it doesn't do so itself.  This results in 
  premature freeing of the policy.  Add the mpol_get() to the 
  shm_get_policy() op when the backing file doesn't support shared
  policies.

* Further, shm_get_policy() was falling back to current task's task
  policy if the backing file did not support get_policy() vm_op and
  the vma policy was null.  This is not valid when get_vma_policy() is
  called from show_numa_map() as task != current.  Also, this did
  not match the behavior of the shmem_get_policy() vm_op which did
  NOT fall back to task policy.  So, modify shm_get_policy() NOT to
  fall back to current->mempolicy.

* Now, turns out that get_vma_policy() was not handling fallback to
  task policy correctly when the get_policy() vm_op returns NULL.
  Rather, it was falling back directly to system default policy.
  So, fix get_vma_policy() to use only non-NULL policy returned from
  the vma get_policy op and indicate that this policy does not need
  another ref count.  

* Document mempolicy return value reference semantics assumed by
  the changes discussed above for the set_ and get_policy vm_ops
  in <linux/mm.h>--where the prototypes are defined.

* Add VM_BUG_ON()s to __mpol_free() and mpol_get() to trap attempts
  to ref/unref the system default policy.  Should no longer occur.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/mempolicy.h |    5 ++++-
 include/linux/mm.h        |   14 ++++++++++++++
 ipc/shm.c                 |    6 +++---
 mm/mempolicy.c            |   32 ++++++++++++++++++++++++--------
 4 files changed, 45 insertions(+), 12 deletions(-)

Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-10-10 13:36:44.000000000 -0400
+++ Linux/mm/mempolicy.c	2007-10-10 14:25:52.000000000 -0400
@@ -1112,19 +1112,25 @@ static struct mempolicy * get_vma_policy
 		struct vm_area_struct *vma, unsigned long addr)
 {
 	struct mempolicy *pol = task->mempolicy;
-	int shared_pol = 0;
+	int pol_needs_ref = (task != current);
 
 	if (vma) {
 		if (vma->vm_ops && vma->vm_ops->get_policy) {
-			pol = vma->vm_ops->get_policy(vma, addr);
-			shared_pol = 1;	/* if pol non-NULL, add ref below */
+			struct mempolicy *vpol = vma->vm_ops->get_policy(vma,
+									addr);
+			if (vpol) {
+				pol = vpol;
+				pol_needs_ref = 0; /* get_policy() added ref */
+			}
 		} else if (vma->vm_policy &&
-				vma->vm_policy->policy != MPOL_DEFAULT)
+				vma->vm_policy->policy != MPOL_DEFAULT) {
 			pol = vma->vm_policy;
+			pol_needs_ref++;
+		}
 	}
 	if (!pol)
 		pol = &default_policy;
-	else if (!shared_pol && pol != current->mempolicy)
+	else if (pol_needs_ref)
 		mpol_get(pol);	/* vma or other task's policy */
 	return pol;
 }
@@ -1262,18 +1268,21 @@ struct zonelist *huge_zonelist(struct vm
 {
 	struct mempolicy *pol = get_vma_policy(current, vma, addr);
 	struct zonelist *zl;
+	int policy_needs_unref = (pol != &default_policy && \
+					pol != current->mempolicy);
 
 	*mpol = NULL;		/* probably no unref needed */
 	if (pol->policy == MPOL_INTERLEAVE) {
 		unsigned nid;
 
 		nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);
-		__mpol_free(pol);		/* finished with pol */
+		if (unlikely(policy_needs_unref))
+			__mpol_free(pol);	/* finished with pol */
 		return NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_flags);
 	}
 
 	zl = zonelist_policy(GFP_HIGHUSER, pol);
-	if (unlikely(pol != &default_policy && pol != current->mempolicy)) {
+	if (unlikely(policy_needs_unref)) {
 		if (pol->policy != MPOL_BIND)
 			__mpol_free(pol);	/* finished with pol */
 		else
@@ -1325,6 +1334,9 @@ alloc_page_vma(gfp_t gfp, struct vm_area
 {
 	struct mempolicy *pol = get_vma_policy(current, vma, addr);
 	struct zonelist *zl;
+	int policy_needs_unref = (pol != &default_policy && \
+				pol != current->mempolicy);
+
 
 	cpuset_update_task_memory_state();
 
@@ -1332,10 +1344,12 @@ alloc_page_vma(gfp_t gfp, struct vm_area
 		unsigned nid;
 
 		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT);
+		if (unlikely(policy_needs_unref))
+			__mpol_free(pol);
 		return alloc_page_interleave(gfp, 0, nid);
 	}
 	zl = zonelist_policy(gfp, pol);
-	if (pol != &default_policy && pol != current->mempolicy) {
+	if (unlikely(policy_needs_unref)) {
 		/*
 		 * slow path: ref counted policy -- shared or vma
 		 */
@@ -1444,6 +1458,8 @@ int __mpol_equal(struct mempolicy *a, st
 /* Slow path of a mpol destructor. */
 void __mpol_free(struct mempolicy *p)
 {
+	VM_BUG_ON(p == &default_policy);
+
 	if (!atomic_dec_and_test(&p->refcnt))
 		return;
 	if (p->policy == MPOL_BIND)
Index: Linux/ipc/shm.c
===================================================================
--- Linux.orig/ipc/shm.c	2007-10-10 13:36:44.000000000 -0400
+++ Linux/ipc/shm.c	2007-10-10 14:21:59.000000000 -0400
@@ -263,10 +263,10 @@ static struct mempolicy *shm_get_policy(
 
 	if (sfd->vm_ops->get_policy)
 		pol = sfd->vm_ops->get_policy(vma, addr);
-	else if (vma->vm_policy)
+	else if (vma->vm_policy) {
 		pol = vma->vm_policy;
-	else
-		pol = current->mempolicy;
+		mpol_get(pol);		/* get_vma_policy() assumes this */
+	}
 	return pol;
 }
 #endif
Index: Linux/include/linux/mempolicy.h
===================================================================
--- Linux.orig/include/linux/mempolicy.h	2007-10-10 13:36:44.000000000 -0400
+++ Linux/include/linux/mempolicy.h	2007-10-10 14:20:28.000000000 -0400
@@ -2,6 +2,7 @@
 #define _LINUX_MEMPOLICY_H 1
 
 #include <linux/errno.h>
+#include <linux/mm.h>
 
 /*
  * NUMA memory policies for Linux.
@@ -72,6 +73,8 @@ struct mempolicy {
 	nodemask_t cpuset_mems_allowed;	/* mempolicy relative to these nodes */
 };
 
+extern struct mempolicy default_policy;
+
 /*
  * Support for managing mempolicy data objects (clone, copy, destroy)
  * The default fast path of a NULL MPOL_DEFAULT policy is always inlined.
@@ -97,6 +100,7 @@ static inline struct mempolicy *mpol_cop
 
 static inline void mpol_get(struct mempolicy *pol)
 {
+	VM_BUG_ON(pol == &default_policy);
 	if (pol)
 		atomic_inc(&pol->refcnt);
 }
@@ -149,7 +153,6 @@ extern void mpol_rebind_task(struct task
 extern void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new);
 extern void mpol_fix_fork_child_flag(struct task_struct *p);
 
-extern struct mempolicy default_policy;
 extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
 		unsigned long addr, gfp_t gfp_flags, struct mempolicy **mpol);
 extern unsigned slab_node(struct mempolicy *policy);
Index: Linux/include/linux/mm.h
===================================================================
--- Linux.orig/include/linux/mm.h	2007-10-10 13:36:44.000000000 -0400
+++ Linux/include/linux/mm.h	2007-10-10 14:20:28.000000000 -0400
@@ -173,7 +173,21 @@ struct vm_operations_struct {
 	 * writable, if an error is returned it will cause a SIGBUS */
 	int (*page_mkwrite)(struct vm_area_struct *vma, struct page *page);
 #ifdef CONFIG_NUMA
+	/*
+	 * set_policy() op must add a reference to any non-NULL @new mempolicy
+	 * to hold the policy upon return.  Caller should pass NULL @new to
+	 * remove a policy and fall back to surrounding context--i.e. do not
+	 * install a MPOL_DEFAULT policy, nor the task or system default
+	 * mempolicy.
+	 */
 	int (*set_policy)(struct vm_area_struct *vma, struct mempolicy *new);
+
+	/*
+	 * get_policy() op must add reference [mpol_get()] to any mempolicy
+	 * at (vma,addr).  If no [shared/vma] mempolicy exists at that addr,
+	 * get_policy() op must return NULL--i.e., do not "fallback" to task
+	 * or system default policy.
+	 */
 	struct mempolicy *(*get_policy)(struct vm_area_struct *vma,
 					unsigned long addr);
 	int (*migrate)(struct vm_area_struct *vma, const nodemask_t *from,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
