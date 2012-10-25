Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 353B96B0089
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 09:09:32 -0400 (EDT)
Message-Id: <20121025124833.478567618@chello.nl>
Date: Thu, 25 Oct 2012 14:16:30 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 13/31] mm/mpol: Check for misplaced page
References: <20121025121617.617683848@chello.nl>
Content-Disposition: inline; filename=0013-mm-mpol-Check-for-misplaced-page.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>

From: Lee Schermerhorn <lee.schermerhorn@hp.com>

This patch provides a new function to test whether a page resides
on a node that is appropriate for the mempolicy for the vma and
address where the page is supposed to be mapped.  This involves
looking up the node where the page belongs.  So, the function
returns that node so that it may be used to allocated the page
without consulting the policy again.  

A subsequent patch will call this function from the fault path.
Because of this, I don't want to go ahead and allocate the page, e.g.,
via alloc_page_vma() only to have to free it if it has the correct
policy.  So, I just mimic the alloc_page_vma() node computation
logic--sort of.

Note:  we could use this function to implement a MPOL_MF_STRICT
behavior when migrating pages to match mbind() mempolicy--e.g.,
to ensure that pages in an interleaved range are reinterleaved
rather than left where they are when they reside on any page in
the interleave nodemask.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
[ Added MPOL_F_LAZY to trigger migrate-on-fault;
  simplified code now that we don't have to bother
  with special crap for interleaved ]
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/mempolicy.h      |    8 ++++
 include/uapi/linux/mempolicy.h |    1 
 mm/mempolicy.c                 |   76 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 85 insertions(+)

Index: tip/include/linux/mempolicy.h
===================================================================
--- tip.orig/include/linux/mempolicy.h
+++ tip/include/linux/mempolicy.h
@@ -198,6 +198,8 @@ static inline int vma_migratable(struct
 	return 1;
 }
 
+extern int mpol_misplaced(struct page *, struct vm_area_struct *, unsigned long);
+
 #else
 
 struct mempolicy {};
@@ -323,5 +325,11 @@ static inline int mpol_to_str(char *buff
 	return 0;
 }
 
+static inline int mpol_misplaced(struct page *page, struct vm_area_struct *vma,
+				 unsigned long address)
+{
+	return -1; /* no node preference */
+}
+
 #endif /* CONFIG_NUMA */
 #endif
Index: tip/include/uapi/linux/mempolicy.h
===================================================================
--- tip.orig/include/uapi/linux/mempolicy.h
+++ tip/include/uapi/linux/mempolicy.h
@@ -61,6 +61,7 @@ enum mpol_rebind_step {
 #define MPOL_F_SHARED  (1 << 0)	/* identify shared policies */
 #define MPOL_F_LOCAL   (1 << 1)	/* preferred local allocation */
 #define MPOL_F_REBINDING (1 << 2)	/* identify policies in rebinding */
+#define MPOL_F_MOF	(1 << 3) /* this policy wants migrate on fault */
 
 
 #endif /* _UAPI_LINUX_MEMPOLICY_H */
Index: tip/mm/mempolicy.c
===================================================================
--- tip.orig/mm/mempolicy.c
+++ tip/mm/mempolicy.c
@@ -2153,6 +2153,82 @@ static void sp_free(struct sp_node *n)
 	kmem_cache_free(sn_cache, n);
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
+ *	-1	- not misplaced, page is in the right node
+ *	node	- node id where the page should be
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
