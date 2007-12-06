From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 06 Dec 2007 16:21:17 -0500
Message-Id: <20071206212117.6279.82703.sendpatchset@localhost>
In-Reply-To: <20071206212047.6279.10881.sendpatchset@localhost>
References: <20071206212047.6279.10881.sendpatchset@localhost>
Subject: [PATCH/RFC 5/8] Mem Policy: Rework mempolicy Reference Counting [yet again]
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, ak@suse.de, mel@skynet.ie, eric.whitney@hp.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

PATCH/RFC 05/08 Mem Policy:  rework mempolicy reference counting [yet again]

Against:  2.6.24-rc2-mm1

N.B., this patch depends on Mel Gorman's "one zonelist" series.  See
discussion of read_swap_cache_async() below.

After further discussion with Christoph Lameter, it has become clear
that my earlier attempts to clean up the mempolicy reference counting
were a bit of overkill in some areas, resulting in superflous ref/unref
in what are usually fast paths.  In other areas, further inspection 
reveals that I botched the unref for interleave policies.  This patch
attempts to clean this up.  Maybe I'll get it right this time.

So, here's what [I think] is happening:

1) system default mempolicy needs no protection by extra reference counts
   as it is never freed.  However, we need to be real sure that we never
   unref the sys default mempolicy.

2) The current task's mempolicy needs no extra references because it can
   only be changed by the task itself.  That can't happen when we're in
   here using the policy for allocation or querying it via get_mempolicy().

3) An other task's mempolicy needs no extra reference [after patch 1 of
   this series] because the caller must hold the target task's mm's
   mmap_sem when accessing the mempolicy.  Currently, this only occurs
   when show_numa_maps() looks up a task's per vma mempolicy and the
   mempolicy falls back to [non-NULL] task policy.  show_numa_maps() is
   called from the /proc/<pid>/numa_maps handler holding the target
   task's mmap_sem for read.

   N.B., this only works if do_set_mempolicy() grabs the mmap_sem for write
   when updating the task mempolicy.  This is covered by patch 1 of this
   series.

4) A task's [non-shared] vma policy needs no extra references because all 
   lookups and usage of vma policy occurs with the mmap_sem held for read--
   e.g., in the fault path or in do_get_mempolicy().

5) A shared policy--i.e., a mempolicy for a range of a shared memory region
   [really a mmap()ed tmpfs file]--managed by the shared policy infrastructure
   in mm/mempoicy.c requires an extra reference when looked up for allocation
   or query.  The shared policy infrastructure has always added this reference.
   Shmem page allocation [shmem_alloc_page() and shmem_swapin()] released
   the ref count, but new_vma_page() [page migration] and show_numa_maps()
   never did, resulting in leaking of mempolicy structures applied to shared
   memory regions allocated by shmget().  We need to release this extra
   reference when finished with the mempolicy.

When are we "finished" with the mempolicy?

For MPOL_PREFERRED policies [including MPOL_DEFAULT == "preferred local"],
we finished as soon as we've obtained the zonelist for the target node.

For MPOL_INTERLEAVE policies, we're finished as soon as we've determined
the target node for the interleave.

For MPOL_BIND policies, because they contain a custom zonelist used for
page allocation, we're only finished after we've converted this zonelist
to a nodemask for get_mempolicy()/show_numa_maps() or after we've allocated
a page [or failed to] based on the nodelist.  [Note:  when Mel Gorman's
onezonelist series gets merged--he says hopefully--this paragraph will
apply to the custom nodemask that replaces the zonelist, as the nodemask
must also be held over the allocation.]

But, again, lookup of mempolicy, based on (vma, address) need only add a
reference for shared policy, and we need only unref the policy when finished
for shared policies.  So, this patch backs all of the unneeded extra 
reference counting added by my previous attempt.  It then unrefs only
shared policies when we're finished with them, using the mpol_cond_free()
[conditional free] helper function introduced by this patch.

Note that shmem_swapin() calls read_swap_cache_async() with a dummy vma
containing just the policy.  read_swap_cache_async() can call
alloc_page_vma() multiple times, so we can't let alloc_page_vma() unref
the shared policy in this case.  To avoid this, we make a copy of any
non-null shared policy and remove the MPOL_SHARED flag from the copy.
I introduced a new static inline function "mpol_cond_assign()" to assign
the shared policy to an on-stack policy and remove the flags that would
require a conditional free.  This depends on Mel Gorman's "one zonelist"
patch series that eliminates the custom zonelist hanging off MPOL_BIND
policies.

This patch updates the numa_memory_policy.txt document to explain the
reference counting semantics, as discussed above.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 Documentation/vm/numa_memory_policy.txt |   69 ++++++++++++++++++++++++++++++++
 include/linux/mempolicy.h               |   42 +++++++++++++++++++
 mm/hugetlb.c                            |    2 
 mm/mempolicy.c                          |   46 +++++++++------------
 mm/shmem.c                              |   16 ++++---
 5 files changed, 142 insertions(+), 33 deletions(-)

Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-12-06 14:17:40.000000000 -0500
+++ Linux/mm/mempolicy.c	2007-12-06 14:18:34.000000000 -0500
@@ -578,6 +578,7 @@ static long do_get_mempolicy(int *policy
 		get_zonemask(pol, nmask);
 
  out:
+	mpol_cond_free(pol);
 	if (vma)
 		up_read(&current->mm->mmap_sem);
 	return err;
@@ -1110,16 +1111,18 @@ asmlinkage long compat_sys_mbind(compat_
  *
  * Returns effective policy for a VMA at specified address.
  * Falls back to @task or system default policy, as necessary.
- * Returned policy has extra reference count if shared, vma,
- * or some other task's policy [show_numa_maps() can pass
- * @task != current].  It is the caller's responsibility to
- * free the reference in these cases.
+ * Current or other task's task mempolicy and non-shared vma policies
+ * are protected by the task's mmap_sem, which must be held for read by
+ * the caller.
+ * Shared policies [those marked as MPOL_SHARED] require an extra reference
+ * count--added by the get_policy() vm_op, as appropriate--to protect against
+ * freeing by another task.  It is the caller's responsibility to free the
+ * extra reference for shared policies.
  */
 static struct mempolicy *get_vma_policy(struct task_struct *task,
 		struct vm_area_struct *vma, unsigned long addr)
 {
 	struct mempolicy *pol = task->mempolicy;
-	int shared_pol = 0;
 
 	if (vma) {
 		if (vma->vm_ops && vma->vm_ops->get_policy) {
@@ -1127,15 +1130,12 @@ static struct mempolicy *get_vma_policy(
 									addr);
 			if (vpol)
 				pol = vpol;
-			shared_pol = 1;	/* if pol non-NULL, add ref below */
 		} else if (vma->vm_policy &&
 				policy_mode(vma->vm_policy) != MPOL_DEFAULT)
 			pol = vma->vm_policy;
 	}
 	if (!pol)
 		pol = &default_policy;
-	else if (!shared_pol && pol != current->mempolicy)
-		mpol_get(pol);	/* vma or other task's policy */
 	return pol;
 }
 
@@ -1202,6 +1202,10 @@ static unsigned interleave_nodes(struct 
 /*
  * Depending on the memory policy provide a node from which to allocate the
  * next slab entry.
+ * @policy must be protected by freeing by the caller.  If @policy is
+ * the current task's mempolicy, this protection is implicit, as only the
+ * task can change it's policy.  The system default policy requires no
+ * such protection.
  */
 unsigned slab_node(struct mempolicy *policy)
 {
@@ -1295,25 +1299,18 @@ struct zonelist *huge_zonelist(struct vm
 				gfp_t gfp_flags, struct mempolicy **mpol)
 {
 	struct mempolicy *pol = get_vma_policy(current, vma, addr);
-	struct zonelist *zl;
 
-	*mpol = NULL;		/* probably no unref needed */
 	if (policy_mode(pol) == MPOL_INTERLEAVE) {
 		unsigned nid;
 
 		nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);
-		__mpol_free(pol);		/* finished with pol */
+		mpol_cond_free(pol);	/* finished with pol */
+		*mpol = NULL;
 		return node_zonelist(nid, gfp_flags);
 	}
 
-	zl = zonelist_policy(GFP_HIGHUSER, pol);
-	if (unlikely(pol != &default_policy && pol != current->mempolicy)) {
-		if (policy_mode(pol) != MPOL_BIND)
-			__mpol_free(pol);	/* finished with pol */
-		else
-			*mpol = pol;	/* unref needed after allocation */
-	}
-	return zl;
+	*mpol = pol;	/* unref needed after allocation */
+	return zonelist_policy(GFP_HIGHUSER, pol);
 }
 #endif
 
@@ -1366,12 +1363,13 @@ alloc_page_vma(gfp_t gfp, struct vm_area
 		unsigned nid;
 
 		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT);
+		mpol_cond_free(pol);
 		return alloc_page_interleave(gfp, 0, nid);
 	}
 	zl = zonelist_policy(gfp, pol);
-	if (pol != &default_policy && pol != current->mempolicy) {
+ 	if (unlikely(mpol_needs_cond_ref(pol))) {
 		/*
-		 * slow path: ref counted policy -- shared or vma
+		 * slow path: ref counted shared policy
 		 */
 		struct page *page =  __alloc_pages_nodemask(gfp, 0,
 						zl, nodemask_policy(gfp, pol));
@@ -1956,11 +1954,7 @@ int show_numa_map(struct seq_file *m, vo
 
 	pol = get_vma_policy(priv->task, vma, vma->vm_start);
 	mpol_to_str(buffer, sizeof(buffer), pol);
-	/*
-	 * unref shared or other task's mempolicy
-	 */
-	if (pol != &default_policy && pol != current->mempolicy)
-		__mpol_free(pol);
+	mpol_cond_free(pol);
 
 	seq_printf(m, "%08lx %s", vma->vm_start, buffer);
 
Index: Linux/mm/shmem.c
===================================================================
--- Linux.orig/mm/shmem.c	2007-12-06 14:17:40.000000000 -0500
+++ Linux/mm/shmem.c	2007-12-06 14:18:34.000000000 -0500
@@ -1048,16 +1048,19 @@ out:
 static struct page *shmem_swapin(swp_entry_t entry, gfp_t gfp,
 			struct shmem_inode_info *info, unsigned long idx)
 {
+	struct mempolicy mpol, *spol;
 	struct vm_area_struct pvma;
 	struct page *page;
 
+	spol = mpol_cond_assign(&mpol,
+				 mpol_shared_policy_lookup(&info->policy, idx));
+
 	/* Create a pseudo vma that just contains the policy */
 	pvma.vm_start = 0;
 	pvma.vm_pgoff = idx;
 	pvma.vm_ops = NULL;
-	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, idx);
+	pvma.vm_policy = spol;
 	page = swapin_readahead(entry, gfp, &pvma, 0);
-	mpol_free(pvma.vm_policy);
 	return page;
 }
 
@@ -1065,16 +1068,17 @@ static struct page *shmem_alloc_page(gfp
 			struct shmem_inode_info *info, unsigned long idx)
 {
 	struct vm_area_struct pvma;
-	struct page *page;
 
 	/* Create a pseudo vma that just contains the policy */
 	pvma.vm_start = 0;
 	pvma.vm_pgoff = idx;
 	pvma.vm_ops = NULL;
 	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, idx);
-	page = alloc_page_vma(gfp, &pvma, 0);
-	mpol_free(pvma.vm_policy);
-	return page;
+
+	/*
+	 * alloc_page_vma() will drop the shared policy reference
+	 */
+	return alloc_page_vma(gfp, &pvma, 0);
 }
 #else
 static inline int shmem_parse_mpol(char *value, int *policy,
Index: Linux/include/linux/mempolicy.h
===================================================================
--- Linux.orig/include/linux/mempolicy.h	2007-12-06 14:17:40.000000000 -0500
+++ Linux/include/linux/mempolicy.h	2007-12-06 14:18:34.000000000 -0500
@@ -99,6 +99,38 @@ static inline void mpol_free(struct memp
 		__mpol_free(pol);
 }
 
+/*
+ * does policy need explicit unref after use?
+ * currently only needed for shared policies.
+ */
+static inline int mpol_needs_cond_ref(struct mempolicy *pol)
+{
+	return (pol && (pol->mode & MPOL_SHARED));
+}
+
+static inline void mpol_cond_free(struct mempolicy *pol)
+{
+	if (mpol_needs_cond_ref(pol))
+		__mpol_free(pol);
+}
+
+/*
+ * Assign *@frompol to *@topol if conditional ref needed, eliminate the
+ * MPOL_* flags that require conditional ref and drop the extra ref.
+ * Use @tompol for, e.g., multiple allocations with a single policy lookup.
+ */
+static inline struct mempolicy *mpol_cond_assign(struct mempolicy *tompol,
+						struct mempolicy *frompol)
+{
+	if (!mpol_needs_cond_ref(frompol))
+		return frompol;
+
+	*tompol = *frompol;
+	tompol->mode &= ~MPOL_SHARED;
+	__mpol_free(frompol);
+	return tompol;
+}
+
 extern struct mempolicy *__mpol_copy(struct mempolicy *pol);
 static inline struct mempolicy *mpol_copy(struct mempolicy *pol)
 {
@@ -196,6 +228,16 @@ static inline void mpol_free(struct memp
 {
 }
 
+static inline void mpol_cond_free(struct mempolicy *pol)
+{
+}
+
+static inline struct mempolicy *mpol_cond_assign(struct mempolicy *to,
+						struct mempolicy *from)
+{
+	return from;
+}
+
 static inline void mpol_get(struct mempolicy *pol)
 {
 }
Index: Linux/mm/hugetlb.c
===================================================================
--- Linux.orig/mm/hugetlb.c	2007-12-06 14:17:40.000000000 -0500
+++ Linux/mm/hugetlb.c	2007-12-06 14:18:34.000000000 -0500
@@ -95,7 +95,7 @@ static struct page *dequeue_huge_page(st
 			break;
 		}
 	}
-	mpol_free(mpol);	/* unref if mpol !NULL */
+	mpol_cond_free(mpol);
 	return page;
 }
 
Index: Linux/Documentation/vm/numa_memory_policy.txt
===================================================================
--- Linux.orig/Documentation/vm/numa_memory_policy.txt	2007-12-06 14:18:27.000000000 -0500
+++ Linux/Documentation/vm/numa_memory_policy.txt	2007-12-06 14:18:34.000000000 -0500
@@ -227,6 +227,75 @@ Components of Memory Policies
 	    the temporary interleaved system default policy works in this
 	    mode.
 
+MEMORY POLICY REFERENCE COUNTING
+
+To resolve use/free races, struct mempolicy contains an atomic reference
+count field.  Internal interfaces, mpol_get()/mpol_free() increment and
+decrement this reference count, respectively.  mpol_free() will only free
+the structure back to the mempolicy kmem cache when the reference count
+goes to zero.
+
+When a new memory policy is allocated, it's reference count is initialized
+to '1', representing the reference held by the task that is installing the
+new policy.  When a pointer to a memory policy structure is stored in another
+structure, another reference is added, as the task's reference will be dropped
+on completion of the policy installation.
+
+During run-time "usage" of the policy, we attempt to minimize atomic operations
+on the reference count, as this can lead to cache lines bouncing between cpus
+and NUMA nodes.  "Usage" here means one of the following:
+
+1) querying of the policy, either by the task itself [using the get_mempolicy()
+   API discussed below] or by another task using the /proc/<pid>/numa_maps
+   interface.
+
+2) examination of the policy to determine the policy mode and associated node
+   or node lists, if any, for page allocation.  This is considered a "hot
+   path".  Note that for MPOL_BIND, the "usage" extends across the entire
+   allocation process, which may sleep during page reclaimation, because the
+   BIND policy has a custom node list containing the nodes specified by the
+   policy.
+
+We can avoid taking an extra reference during the usages listed above as
+follows:
+
+1) we never need to get/free the system default policy as this is never
+   changed nor freed, once the system is up and running.
+
+2) for querying the policy, we do not need to take an extra reference on the
+   target task's task policy nor vma policies because we always acquire the
+   task's mm's mmap_sem for read during the query.  The set_mempolicy() and
+   mbind() APIs [see below] always acquire the mmap_sem for write when
+   installing or replacing task or vma policies.  Thus, there is no possibility
+   of a task or thread freeing a policy while another task or thread is
+   querying it.
+
+3) Page allocation usage of task or vma policy occurs in the fault path where
+   we hold them mmap_sem for read.  Again, because replacing the task or vma
+   policy requires that the mmap_sem be held for write, the policy can't be
+   freed out from under us while we're using it for page allocation.
+
+4) Shared policies require special consideration.  One task can replace a
+   shared memory policy while another task, with a distinct mmap_sem, is
+   querying or allocating a page based on the policy.  To resolve this
+   potential race, the shared policy infrastructure adds an extra reference
+   to the shared policy during lookup while holding a spin lock on the shared
+   policy management structure.  This requires that we drop this extra
+   reference when we're finished "using" the policy.  We must drop the
+   extra reference on shared policies in the same query/allocation paths
+   used for non-shared policies.  For this reason, shared policies are marked
+   as such, and the extra reference is dropped "conditionally"--i.e., only
+   for shared policies.
+
+   Because of this extra reference counting, and because we must lookup
+   shared policies in a tree structure under spinlock, shared policies are
+   more expensive to use in the page allocation path.  This is expecially
+   true for shared policies on shared memory regions shared by tasks running
+   on different NUMA nodes.  This extra overhead can be avoided by always
+   falling back to task or system default policy for shared memory regions,
+   or by prefaulting the entire shared memory region into memory and locking
+   it down.  However, this might not be appropriate for all applications.
+
 MEMORY POLICY APIs
 
 Linux supports 3 system calls for controlling memory policy.  These APIS

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
