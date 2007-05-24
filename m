From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 24 May 2007 13:28:59 -0400
Message-Id: <20070524172859.13933.41069.sendpatchset@localhost>
In-Reply-To: <20070524172821.13933.80093.sendpatchset@localhost>
References: <20070524172821.13933.80093.sendpatchset@localhost>
Subject: [PATCH/RFC 5/8] Mapped File Policy:  Factor alloc_page_pol routine
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, nish.aravamudan@gmail.com, Lee Schermerhorn <lee.schermerhorn@hp.com>, clameter@sgi.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

Mapped File Policy 5/8 - Factor alloc_page_pol routine

Against 2.6.22-rc2-mm1

Implement alloc_page_pol() to allocate a page given a policy and
an offset [for interleaving].  No vma nor addr needed.  This
function will be used to allocate page_cache pages given the
policy at a given page offset in a subsequent patch.

Revise alloc_page_vma() to just call alloc_page_pol() after looking
up the policy, to eliminate duplicate code.  This change rippled
into the interleaving functions.  Was able to eliminate
interleave_nid() by computing the offset at the call sites and
calling [modified] offset_il_node() directly.

	removed vma arg from offset_il_node(), as it wasn't
	used and is not available when called from 
	alloc_page_pol().

Note:  re: alloc_page_vma() -- can be called w/ vma == NULL via
read_swap_cache_async() from swapin_readahead().  Can't compute
a page offset in this case, but not an issue?

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/gfp.h       |    3 +
 include/linux/hugetlb.h   |    9 ++++
 include/linux/mempolicy.h |    2 +
 mm/mempolicy.c            |   89 ++++++++++++++++++++++++++--------------------
 4 files changed, 66 insertions(+), 37 deletions(-)

Index: Linux/include/linux/gfp.h
===================================================================
--- Linux.orig/include/linux/gfp.h	2007-05-23 10:57:07.000000000 -0400
+++ Linux/include/linux/gfp.h	2007-05-23 11:34:46.000000000 -0400
@@ -180,10 +180,13 @@ alloc_pages(gfp_t gfp_mask, unsigned int
 }
 extern struct page *alloc_page_vma(gfp_t gfp_mask,
 			struct vm_area_struct *vma, unsigned long addr);
+struct mempolicy;
+extern struct page *alloc_page_pol(gfp_t, struct mempolicy *, pgoff_t);
 #else
 #define alloc_pages(gfp_mask, order) \
 		alloc_pages_node(numa_node_id(), gfp_mask, order)
 #define alloc_page_vma(gfp_mask, vma, addr) alloc_pages(gfp_mask, 0)
+#define alloc_page_pol(gfp_mask, pol, off)  alloc_pages(gfp_mask, 0)
 #endif
 #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
 
Index: Linux/include/linux/hugetlb.h
===================================================================
--- Linux.orig/include/linux/hugetlb.h	2007-05-23 11:34:36.000000000 -0400
+++ Linux/include/linux/hugetlb.h	2007-05-23 11:34:46.000000000 -0400
@@ -14,6 +14,14 @@ static inline int is_vm_hugetlb_page(str
 	return vma->vm_flags & VM_HUGETLB;
 }
 
+static inline int vma_page_shift(struct vm_area_struct *vma)
+{
+	if (unlikely(is_vm_hugetlb_page(vma)))
+		return HPAGE_SHIFT;
+	else
+		return PAGE_SHIFT;
+}
+
 int hugetlb_sysctl_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
 int hugetlb_treat_movable_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
 int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
@@ -127,6 +135,7 @@ static inline unsigned long hugetlb_tota
 #define HPAGE_MASK	PAGE_MASK		/* Keep the compiler happy */
 #define HPAGE_SIZE	PAGE_SIZE
 #endif
+#define vma_page_shift(VMA)		PAGE_SHIFT
 
 #endif /* !CONFIG_HUGETLB_PAGE */
 
Index: Linux/include/linux/mempolicy.h
===================================================================
--- Linux.orig/include/linux/mempolicy.h	2007-05-23 11:34:29.000000000 -0400
+++ Linux/include/linux/mempolicy.h	2007-05-23 11:34:46.000000000 -0400
@@ -130,6 +130,8 @@ extern void mpol_fix_fork_child_flag(str
 #endif
 
 extern struct mempolicy default_policy;
+extern struct mempolicy *get_file_policy(struct task_struct *,
+		struct address_space *, pgoff_t);
 extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
 		unsigned long addr, gfp_t gfp_flags);
 extern unsigned slab_node(struct mempolicy *policy);
Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-05-23 11:34:40.000000000 -0400
+++ Linux/mm/mempolicy.c	2007-05-23 11:34:46.000000000 -0400
@@ -21,6 +21,7 @@
  *
  * bind           Only allocate memory on a specific set of nodes,
  *                no fallback.
+//TODO:  following still applicable?
  *                FIXME: memory is allocated starting with the first node
  *                to the last. It would be better if bind would truly restrict
  *                the allocation to memory nodes instead
@@ -35,6 +36,7 @@
  *                use the process policy. This is what Linux always did
  *		  in a NUMA aware kernel and still does by, ahem, default.
  *
+//TODO:  following needs paragraph rewording.  haven't figured out what to say.
  * The process policy is applied for most non interrupt memory allocations
  * in that process' context. Interrupts ignore the policies and always
  * try to allocate on the local CPU. The VMA policy is only applied for memory
@@ -50,15 +52,18 @@
  * Same with GFP_DMA allocations.
  *
  * For shmfs/tmpfs/hugetlbfs shared memory the policy is shared between
- * all users and remembered even when nobody has memory mapped.
+ * all users and remembered even when nobody has memory mapped. Shared
+ * policies handle sub-ranges of the object using a red/black tree.
+ *
+ * For mmap()ed files, the policy is shared between all 'SHARED mappers
+ * and is remembered as long as the inode exists.  Private mappings
+ * still use vma policy for COWed pages, but use the shared policy
+ * [default, if none] for initial and read-only faults.
  */
 
 /* Notebook:
-   fix mmap readahead to honour policy and enable policy for any page cache
-   object
    statistics for bigpages
-   global policy for page cache? currently it uses process policy. Requires
-   first item above.
+   global policy for page cache?
    handle mremap for shared memory (currently ignored for the policy)
    grows down?
    make bind policy root only? It can trigger oom much faster and the
@@ -1124,6 +1129,22 @@ static struct mempolicy * get_vma_policy
 	return pol;
 }
 
+/*
+ * Return effective policy for file [address_space] at pgoff
+ */
+struct mempolicy *get_file_policy(struct task_struct *task,
+		struct address_space *x, pgoff_t pgoff)
+{
+	struct shared_policy *sp = x->spolicy;
+	struct mempolicy *pol = task->mempolicy;
+
+	if (sp)
+		pol = mpol_shared_policy_lookup(sp, pgoff);
+	if (!pol)
+		pol = &default_policy;
+	return pol;
+}
+
 /* Return a zonelist representing a mempolicy */
 static struct zonelist *zonelist_policy(gfp_t gfp, struct mempolicy *policy)
 {
@@ -1196,9 +1217,8 @@ unsigned slab_node(struct mempolicy *pol
 	}
 }
 
-/* Do static interleaving for a VMA with known offset. */
-static unsigned offset_il_node(struct mempolicy *pol,
-		struct vm_area_struct *vma, unsigned long off)
+/* Do static interleaving for a policy with known offset. */
+static unsigned offset_il_node(struct mempolicy *pol, pgoff_t off)
 {
 	unsigned nnodes = nodes_weight(pol->v.nodes);
 	unsigned target = (unsigned)off % nnodes;
@@ -1213,28 +1233,6 @@ static unsigned offset_il_node(struct me
 	return nid;
 }
 
-/* Determine a node number for interleave */
-static inline unsigned interleave_nid(struct mempolicy *pol,
-		 struct vm_area_struct *vma, unsigned long addr, int shift)
-{
-	if (vma) {
-		unsigned long off;
-
-		/*
-		 * for small pages, there is no difference between
-		 * shift and PAGE_SHIFT, so the bit-shift is safe.
-		 * for huge pages, since vm_pgoff is in units of small
-		 * pages, we need to shift off the always 0 bits to get
-		 * a useful offset.
-		 */
-		BUG_ON(shift < PAGE_SHIFT);
-		off = vma->vm_pgoff >> (shift - PAGE_SHIFT);
-		off += (addr - vma->vm_start) >> shift;
-		return offset_il_node(pol, vma, off);
-	} else
-		return interleave_nodes(pol);
-}
-
 #ifdef CONFIG_HUGETLBFS
 /* Return a zonelist suitable for a huge page allocation. */
 struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr,
@@ -1245,7 +1243,8 @@ struct zonelist *huge_zonelist(struct vm
 	if (pol->policy == MPOL_INTERLEAVE) {
 		unsigned nid;
 
-		nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);
+		nid = offset_il_node(pol,
+				vma_addr_to_pgoff(vma, addr, HPAGE_SHIFT));
 		return NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_flags);
 	}
 	return zonelist_policy(GFP_HIGHUSER, pol);
@@ -1267,6 +1266,23 @@ static struct page *alloc_page_interleav
 	return page;
 }
 
+/*
+ * alloc_page_pol() -- allocate a page based on policy,offset.
+ * Used for mmap()ed file policy allocations where policy is based
+ * on file offset rather than a vma,addr pair
+ */
+struct page *alloc_page_pol(gfp_t gfp, struct mempolicy *pol, pgoff_t pgoff)
+{
+	if (unlikely(pol->policy == MPOL_INTERLEAVE)) {
+		unsigned nid;
+
+		nid = offset_il_node(pol, pgoff);
+		return alloc_page_interleave(gfp, 0, nid);
+	}
+	return __alloc_pages(gfp, 0, zonelist_policy(gfp, pol));
+}
+EXPORT_SYMBOL(alloc_page_pol);
+
 /**
  * 	alloc_page_vma	- Allocate a page for a VMA.
  *
@@ -1293,16 +1309,15 @@ struct page *
 alloc_page_vma(gfp_t gfp, struct vm_area_struct *vma, unsigned long addr)
 {
 	struct mempolicy *pol = get_vma_policy(current, vma, addr);
+	pgoff_t pgoff = 0;
 
 	cpuset_update_task_memory_state();
 
-	if (unlikely(pol->policy == MPOL_INTERLEAVE)) {
-		unsigned nid;
-
-		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT);
-		return alloc_page_interleave(gfp, 0, nid);
+	if (likely(vma)) {
+		int shift = vma_page_shift(vma);
+		pgoff = vma_addr_to_pgoff(vma, addr, shift);
 	}
-	return __alloc_pages(gfp, 0, zonelist_policy(gfp, pol));
+	return alloc_page_pol(gfp, pol, pgoff);
 }
 
 /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
