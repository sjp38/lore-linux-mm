Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id B50E76B00FB
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 10:53:12 -0400 (EDT)
Message-Id: <20120316144240.432892200@chello.nl>
Date: Fri, 16 Mar 2012 15:40:33 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 05/26] mm, mpol: Check for misplaced page
References: <20120316144028.036474157@chello.nl>
Content-Disposition: inline; filename=migrate-on-fault-03-mpol_misplaced.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>

This patch provides a new function to test whether a page resides
on a node that is appropriate for the mempolicy for the vma and
address where the page is supposed to be mapped.  This involves
looking up the node where the page belongs.  So, the function
returns that node so that it may be used to allocated the page
without consulting the policy again.  Because interleaved and
non-interleaved allocations are accounted differently, the function
also returns whether or not the new node came from an interleaved
policy, if the page is misplaced.

A subsequent patch will call this function from the fault path for
stable pages with zero page_mapcount().  Because of this, I don't
want to go ahead and allocate the page, e.g., via alloc_page_vma()
only to have to free it if it has the correct policy.  So, I just
mimic the alloc_page_vma() node computation logic--sort of.

Note:  we could use this function to implement a MPOL_MF_STRICT
behavior when migrating pages to match mbind() mempolicy--e.g.,
to ensure that pages in an interleaved range are reinterleaved
rather than left where they are when they reside on any page in
the interleave nodemask.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
[ Added MPOL_F_LAZY to trigger migrate-on-fault;
  simplified code now that we don't have to bother
  with special crap for interleaved ]
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/mempolicy.h |    3 +
 mm/mempolicy.c            |   79 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 82 insertions(+)
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -67,6 +67,7 @@ enum mpol_rebind_step {
 #define MPOL_F_SHARED  (1 << 0)	/* identify shared policies */
 #define MPOL_F_LOCAL   (1 << 1)	/* preferred local allocation */
 #define MPOL_F_REBINDING (1 << 2)	/* identify policies in rebinding */
+#define MPOL_F_MOF	(1 << 3) /* this policy wants migrate on fault */
 
 #ifdef __KERNEL__
 
@@ -261,6 +262,8 @@ static inline int vma_migratable(struct 
 	return 1;
 }
 
+extern int mpol_misplaced(struct page *, struct vm_area_struct *, unsigned long);
+
 #else
 
 struct mempolicy {};
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1117,6 +1117,9 @@ static long do_mbind(unsigned long start
 	if (IS_ERR(new))
 		return PTR_ERR(new);
 
+	if (flags & MPOL_MF_LAZY)
+		new->flags |= MPOL_F_MOF;
+
 	/*
 	 * If we are using the default policy then operation
 	 * on discontinuous address spaces is okay after all
@@ -2072,6 +2075,82 @@ mpol_shared_policy_lookup(struct shared_
 	return pol;
 }
 
+/**
+ * mpol_misplaced - check whether current page node is valid in policy
+ *
+ * @page   - page to be checked
+ * @vma    - vm area where page mapped
+ * @addr   - virtual address where page mapped
+ *
+ * Lookup current policy node id for vma,addr and "compare to" page's
+ * node id.
+ *
+ * Returns:
+ * 	-1	- not misplaced, page is in the right node
+ * 	node	- node id where the page should be
+ *
+ * Policy determination "mimics" alloc_page_vma().
+ * Called from fault path where we know the vma and faulting address.
+ */
+int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long addr)
+{
+	struct mempolicy *pol;
+	struct zone *zone;
+	int curnid = page_to_nid(page);
+	unsigned long pgoff;
+	int polnid = -1;
+	int ret = -1;
+
+	BUG_ON(!vma);
+
+	pol = get_vma_policy(current, vma, addr);
+	if (!(pol->flags & MPOL_F_MOF))
+		goto out;
+
+	switch (pol->mode) {
+	case MPOL_INTERLEAVE:
+		BUG_ON(addr >= vma->vm_end);
+		BUG_ON(addr < vma->vm_start);
+
+		pgoff = vma->vm_pgoff;
+		pgoff += (addr - vma->vm_start) >> PAGE_SHIFT;
+		polnid = offset_il_node(pol, vma, pgoff);
+		break;
+
+	case MPOL_PREFERRED:
+		if (pol->flags & MPOL_F_LOCAL)
+			polnid = numa_node_id();
+		else
+			polnid = pol->v.preferred_node;
+		break;
+
+	case MPOL_BIND:
+		/*
+		 * allows binding to multiple nodes.
+		 * use current page if in policy nodemask,
+		 * else select nearest allowed node, if any.
+		 * If no allowed nodes, use current [!misplaced].
+		 */
+		if (node_isset(curnid, pol->v.nodes))
+			goto out;
+		(void)first_zones_zonelist(
+				node_zonelist(numa_node_id(), GFP_HIGHUSER),
+				gfp_zone(GFP_HIGHUSER),
+				&pol->v.nodes, &zone);
+		polnid = zone->node;
+		break;
+
+	default:
+		BUG();
+	}
+	if (curnid != polnid)
+		ret = polnid;
+out:
+	mpol_cond_put(pol);
+
+	return ret;
+}
+
 static void sp_delete(struct shared_policy *sp, struct sp_node *n)
 {
 	pr_debug("deleting %lx-l%lx\n", n->start, n->end);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
