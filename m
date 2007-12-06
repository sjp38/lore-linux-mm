From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 06 Dec 2007 16:21:05 -0500
Message-Id: <20071206212105.6279.68578.sendpatchset@localhost>
In-Reply-To: <20071206212047.6279.10881.sendpatchset@localhost>
References: <20071206212047.6279.10881.sendpatchset@localhost>
Subject: [PATCH/RFC 3/8] Mem Policy:  Mark shared policies for unref
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, ak@suse.de, mel@skynet.ie, clameter@sgi.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

PATCH/RFC 03/08 - Mem Policy:  Mark shared policies for unref

Against:  2.6.24-rc2-mm1

As part of yet another rework of mempolicy reference counting,
we want to be able to identify shared policies efficiently,
because they have an extra ref taken on lookup that needs to
be removed when we're finished using the policy.

  Note:  the extra ref is required because the policies are
  shared between tasks/processes and can be changed/freed
  by one task while another task is using them--e.g., for
  page allocation.

Reusing part of my yet-to-be/maybe-never merged "context-independent"
interleave policy patch, this patch encodes the "shared" state
in an upper bit of the 'mode' member of the mempolicy structure.
Note this member has been renamed from 'policy' to 'mode' to better
match documentation and, more importantly, to catch any direct
references to the member.

The mode member must already be tested to determine the policy mode,
so no extra memory references should be required.  However, for
testing the policy--e.g., in the several switch() and if() statements--
the MPOL_SHARED flag must be masked off using the policy_mode() inline
function.  This allows additional flags to be so encoded, should that
become useful--e.g., for "context-independent" interleave policy,
cpuset-relative node id numbering, or any other future extension to 
mempolicy.

I set the MPOL_SHARED flag when the policy is installed in the shared
policy rb-tree.  Don't need/want to clear the flag when removing from the 
tree as the mempolicy is freed  [unref'd] internally to the sp_delete()
function.  However, a task could hold another reference on this mempolicy
from a prior lookup.  We need the MPOL_SHARED flag to stay put so that
any tasks holding a ref will unref, eventually freeing, the mempolicy.

A later patch in this series will introduce a function to conditionally
unref [mpol_free] a policy.  The MPOL_SHARED flag is one reason
[currently the only reason] to unref/free a policy via the conditional
free.

Note:  an alternative to marking shared policies, suggested recently
by Christoph Lameter, is to define an additional argument to
get_vma_policy() that points to a 'needs_unref' variable.  We would
test 'needs_unref' in all functions that lookup policies
to determine if the policy need to be unref'd.  We could then set
the 'needs ref' in get_vma_policy() for non-null mempolicies
returned by a vma get_policy() op.  This means that the shm
get_policy() vm_op would need to add a ref when falling back to
vma policy--e.g., for SHM_HUGETLB segments--to mimic shmem refs.
OR, we could pass the extra args all the way down the vm policy op
call stacks...

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 Documentation/vm/numa_memory_policy.txt |    4 --
 include/linux/mempolicy.h               |   18 ++++++++++++
 mm/mempolicy.c                          |   45 +++++++++++++++++---------------
 3 files changed, 41 insertions(+), 26 deletions(-)

Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-12-05 13:49:07.000000000 -0500
+++ Linux/mm/mempolicy.c	2007-12-06 14:17:40.000000000 -0500
@@ -107,7 +107,7 @@ enum zone_type policy_zone = 0;
 
 struct mempolicy default_policy = {
 	.refcnt = ATOMIC_INIT(1), /* never free it */
-	.policy = MPOL_DEFAULT,
+	.mode   = MPOL_DEFAULT,
 };
 
 static struct mempolicy *get_vma_policy(struct task_struct *task,
@@ -194,7 +194,7 @@ static struct mempolicy *mpol_new(int mo
 		policy->v.nodes = *nodes;
 		break;
 	}
-	policy->policy = mode;
+	policy->mode = mode;
 	policy->cpuset_mems_allowed = cpuset_mems_allowed(current);
 	return policy;
 }
@@ -471,7 +471,7 @@ static long do_set_mempolicy(int mode, n
 	mpol_free(current->mempolicy);
 	current->mempolicy = new;
 	mpol_set_task_struct_flag();
-	if (new && new->policy == MPOL_INTERLEAVE)
+	if (new && policy_mode(new) == MPOL_INTERLEAVE)
 		current->il_next = first_node(new->v.nodes);
 	if (mm)
 		up_write(&mm->mmap_sem);
@@ -483,7 +483,7 @@ static long do_set_mempolicy(int mode, n
 static void get_zonemask(struct mempolicy *p, nodemask_t *nodes)
 {
 	nodes_clear(*nodes);
-	switch (p->policy) {
+	switch (policy_mode(p)) {
 	case MPOL_DEFAULT:
 		break;
 	case MPOL_BIND:
@@ -559,14 +559,14 @@ static long do_get_mempolicy(int *policy
 				goto out;
 			*policy = err;
 		} else if (pol == current->mempolicy &&
-				pol->policy == MPOL_INTERLEAVE) {
+				policy_mode(pol) == MPOL_INTERLEAVE) {
 			*policy = current->il_next;
 		} else {
 			err = -EINVAL;
 			goto out;
 		}
 	} else
-		*policy = pol->policy;
+		*policy = policy_mode(pol);
 
 	if (vma) {
 		up_read(&current->mm->mmap_sem);
@@ -1129,7 +1129,7 @@ static struct mempolicy *get_vma_policy(
 				pol = vpol;
 			shared_pol = 1;	/* if pol non-NULL, add ref below */
 		} else if (vma->vm_policy &&
-				vma->vm_policy->policy != MPOL_DEFAULT)
+				policy_mode(vma->vm_policy) != MPOL_DEFAULT)
 			pol = vma->vm_policy;
 	}
 	if (!pol)
@@ -1143,7 +1143,7 @@ static struct mempolicy *get_vma_policy(
 static nodemask_t *nodemask_policy(gfp_t gfp, struct mempolicy *policy)
 {
 	/* Lower zones don't get a nodemask applied for MPOL_BIND */
-	if (unlikely(policy->policy == MPOL_BIND) &&
+	if (unlikely(policy_mode(policy) == MPOL_BIND) &&
 			gfp_zone(gfp) >= policy_zone &&
 			cpuset_nodemask_valid_mems_allowed(&policy->v.nodes))
 		return &policy->v.nodes;
@@ -1156,7 +1156,7 @@ static struct zonelist *zonelist_policy(
 {
 	int nd;
 
-	switch (policy->policy) {
+	switch (policy_mode(policy)) {
 	case MPOL_PREFERRED:
 		nd = policy->v.preferred_node;
 		if (nd < 0)
@@ -1205,7 +1205,7 @@ static unsigned interleave_nodes(struct 
  */
 unsigned slab_node(struct mempolicy *policy)
 {
-	int pol = policy ? policy->policy : MPOL_DEFAULT;
+	int pol = policy ? policy_mode(policy) : MPOL_DEFAULT;
 
 	switch (pol) {
 	case MPOL_INTERLEAVE:
@@ -1298,7 +1298,7 @@ struct zonelist *huge_zonelist(struct vm
 	struct zonelist *zl;
 
 	*mpol = NULL;		/* probably no unref needed */
-	if (pol->policy == MPOL_INTERLEAVE) {
+	if (policy_mode(pol) == MPOL_INTERLEAVE) {
 		unsigned nid;
 
 		nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);
@@ -1308,7 +1308,7 @@ struct zonelist *huge_zonelist(struct vm
 
 	zl = zonelist_policy(GFP_HIGHUSER, pol);
 	if (unlikely(pol != &default_policy && pol != current->mempolicy)) {
-		if (pol->policy != MPOL_BIND)
+		if (policy_mode(pol) != MPOL_BIND)
 			__mpol_free(pol);	/* finished with pol */
 		else
 			*mpol = pol;	/* unref needed after allocation */
@@ -1362,7 +1362,7 @@ alloc_page_vma(gfp_t gfp, struct vm_area
 
 	cpuset_update_task_memory_state();
 
-	if (unlikely(pol->policy == MPOL_INTERLEAVE)) {
+	if (unlikely(policy_mode(pol) == MPOL_INTERLEAVE)) {
 		unsigned nid;
 
 		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT);
@@ -1411,7 +1411,7 @@ struct page *alloc_pages_current(gfp_t g
 		cpuset_update_task_memory_state();
 	if (!pol || in_interrupt() || (gfp & __GFP_THISNODE))
 		pol = &default_policy;
-	if (pol->policy == MPOL_INTERLEAVE)
+	if (policy_mode(pol) == MPOL_INTERLEAVE)
 		return alloc_page_interleave(gfp, order, interleave_nodes(pol));
 	return __alloc_pages_nodemask(gfp, order,
 			zonelist_policy(gfp, pol), nodemask_policy(gfp, pol));
@@ -1447,9 +1447,11 @@ int __mpol_equal(struct mempolicy *a, st
 {
 	if (!a || !b)
 		return 0;
-	if (a->policy != b->policy)
+
+	if (a->mode != b->mode)
 		return 0;
-	switch (a->policy) {
+
+ 	switch (policy_mode(a)) {
 	case MPOL_DEFAULT:
 		return 1;
 	case MPOL_BIND:
@@ -1469,7 +1471,7 @@ void __mpol_free(struct mempolicy *p)
 {
 	if (!atomic_dec_and_test(&p->refcnt))
 		return;
-	p->policy = MPOL_DEFAULT;
+	p->mode = MPOL_DEFAULT;
 	kmem_cache_free(policy_cache, p);
 }
 
@@ -1535,7 +1537,7 @@ static void sp_insert(struct shared_poli
 	rb_link_node(&new->nd, parent, p);
 	rb_insert_color(&new->nd, &sp->root);
 	pr_debug("inserting %lx-%lx: %d\n", new->start, new->end,
-		 new->policy ? new->policy->policy : 0);
+		 new->policy ? policy_mode(new->policy) : 0);
 }
 
 /* Find shared policy intersecting idx */
@@ -1575,6 +1577,7 @@ static struct sp_node *sp_alloc(unsigned
 	n->start = start;
 	n->end = end;
 	mpol_get(pol);
+	pol->mode |= MPOL_SHARED;	/* for unref */
 	n->policy = pol;
 	return n;
 }
@@ -1660,7 +1663,7 @@ int mpol_set_shared_policy(struct shared
 
 	pr_debug("set_shared_policy %lx sz %lu %d %lx\n",
 		 vma->vm_pgoff,
-		 sz, npol? npol->policy : -1,
+		 sz, npol? policy_mode(npol) : -1,
 		 npol ? nodes_addr(npol->v.nodes)[0] : -1);
 
 	if (npol) {
@@ -1756,7 +1759,7 @@ static void mpol_rebind_policy(struct me
 	if (nodes_equal(*mpolmask, *newmask))
 		return;
 
-	switch (pol->policy) {
+	switch (policy_mode(pol)) {
 	case MPOL_DEFAULT:
 		break;
 	case MPOL_BIND:
@@ -1822,7 +1825,7 @@ static inline int mpol_to_str(char *buff
 	char *p = buffer;
 	int l;
 	nodemask_t nodes;
-	int mode = pol ? pol->policy : MPOL_DEFAULT;
+	int mode = pol ? policy_mode(pol) : MPOL_DEFAULT;
 
 	switch (mode) {
 	case MPOL_DEFAULT:
Index: Linux/include/linux/mempolicy.h
===================================================================
--- Linux.orig/include/linux/mempolicy.h	2007-12-05 11:54:20.000000000 -0500
+++ Linux/include/linux/mempolicy.h	2007-12-06 14:17:40.000000000 -0500
@@ -15,6 +15,13 @@
 #define MPOL_INTERLEAVE	3
 
 #define MPOL_MAX MPOL_INTERLEAVE
+#define MPOL_MODE 0x0ff		/* reserve 8 bits for policy "mode" */
+
+/*
+ * OR'd into struct mempolicy 'policy' member for 'shared policies'
+ * so that we can easily identify them for unref after lookup/use.
+ */
+#define MPOL_SHARED  (1 << 8)
 
 /* Flags for get_mem_policy */
 #define MPOL_F_NODE	(1<<0)	/* return next IL mode instead of node mask */
@@ -62,7 +69,7 @@ struct mm_struct;
  */
 struct mempolicy {
 	atomic_t refcnt;
-	short policy; 	/* See MPOL_* above */
+	short mode; 	/* See MPOL_* above */
 	union {
 		short 		 preferred_node; /* preferred */
 		nodemask_t	 nodes;		/* interleave/bind */
@@ -72,6 +79,15 @@ struct mempolicy {
 };
 
 /*
+ * Return 'policy' [a.k.a. 'mode'] member of mpol, less CONTEXT
+ * or any other modifiers.
+ */
+static inline int policy_mode(struct mempolicy *mpol)
+{
+	return mpol->mode & MPOL_MODE;
+}
+
+/*
  * Support for managing mempolicy data objects (clone, copy, destroy)
  * The default fast path of a NULL MPOL_DEFAULT policy is always inlined.
  */
Index: Linux/Documentation/vm/numa_memory_policy.txt
===================================================================
--- Linux.orig/Documentation/vm/numa_memory_policy.txt	2007-12-06 14:17:40.000000000 -0500
+++ Linux/Documentation/vm/numa_memory_policy.txt	2007-12-06 14:18:27.000000000 -0500
@@ -143,10 +143,6 @@ Components of Memory Policies
    structure, struct mempolicy.  Details of this structure will be discussed
    in context, below, as required to explain the behavior.
 
-	Note:  in some functions AND in the struct mempolicy itself, the mode
-	is called "policy".  However, to avoid confusion with the policy tuple,
-	this document will continue to use the term "mode".
-
    Linux memory policy supports the following 4 behavioral modes:
 
 	Default Mode--MPOL_DEFAULT:  The behavior specified by this mode is

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
