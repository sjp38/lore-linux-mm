Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3A1268D003D
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 19:46:03 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 2/8] Change alloc_pages_vma to pass down the policy node for local policy
Date: Wed,  2 Mar 2011 16:45:22 -0800
Message-Id: <1299113128-11349-3-git-send-email-andi@firstfloor.org>
In-Reply-To: <1299113128-11349-1-git-send-email-andi@firstfloor.org>
References: <1299113128-11349-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

From: Andi Kleen <ak@linux.intel.com>

Currently alloc_pages_vma always uses the local node as policy node
for the LOCAL policy. Pass this node down as an argument instead.

No behaviour change from this patch, but will be needed for followons.

Acked-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 include/linux/gfp.h |    9 +++++----
 mm/huge_memory.c    |    2 +-
 mm/mempolicy.c      |   11 +++++------
 3 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 0b84c61..782e74a 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -332,16 +332,17 @@ alloc_pages(gfp_t gfp_mask, unsigned int order)
 	return alloc_pages_current(gfp_mask, order);
 }
 extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
-			struct vm_area_struct *vma, unsigned long addr);
+		    	struct vm_area_struct *vma, unsigned long addr,
+			int node);
 #else
 #define alloc_pages(gfp_mask, order) \
 		alloc_pages_node(numa_node_id(), gfp_mask, order)
-#define alloc_pages_vma(gfp_mask, order, vma, addr)	\
+#define alloc_pages_vma(gfp_mask, order, vma, addr, node)	\
 	alloc_pages(gfp_mask, order)
 #endif
 #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
-#define alloc_page_vma(gfp_mask, vma, addr)	\
-	alloc_pages_vma(gfp_mask, 0, vma, addr)
+#define alloc_page_vma(gfp_mask, vma, addr)			\
+	alloc_pages_vma(gfp_mask, 0, vma, addr, numa_node_id())
 
 extern unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order);
 extern unsigned long get_zeroed_page(gfp_t gfp_mask);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 3e29781..c7c2cd9 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -653,7 +653,7 @@ static inline struct page *alloc_hugepage_vma(int defrag,
 					      unsigned long haddr)
 {
 	return alloc_pages_vma(alloc_hugepage_gfpmask(defrag),
-			       HPAGE_PMD_ORDER, vma, haddr);
+			       HPAGE_PMD_ORDER, vma, haddr, numa_node_id());
 }
 
 #ifndef CONFIG_NUMA
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 49355a9..25a5a91 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1524,10 +1524,9 @@ static nodemask_t *policy_nodemask(gfp_t gfp, struct mempolicy *policy)
 }
 
 /* Return a zonelist indicated by gfp for node representing a mempolicy */
-static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *policy)
+static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *policy,
+	int nd)
 {
-	int nd = numa_node_id();
-
 	switch (policy->mode) {
 	case MPOL_PREFERRED:
 		if (!(policy->flags & MPOL_F_LOCAL))
@@ -1679,7 +1678,7 @@ struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr,
 		zl = node_zonelist(interleave_nid(*mpol, vma, addr,
 				huge_page_shift(hstate_vma(vma))), gfp_flags);
 	} else {
-		zl = policy_zonelist(gfp_flags, *mpol);
+		zl = policy_zonelist(gfp_flags, *mpol, numa_node_id());
 		if ((*mpol)->mode == MPOL_BIND)
 			*nodemask = &(*mpol)->v.nodes;
 	}
@@ -1820,7 +1819,7 @@ static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
  */
 struct page *
 alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
-		unsigned long addr)
+		unsigned long addr, int node)
 {
 	struct mempolicy *pol = get_vma_policy(current, vma, addr);
 	struct zonelist *zl;
@@ -1836,7 +1835,7 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 		put_mems_allowed();
 		return page;
 	}
-	zl = policy_zonelist(gfp, pol);
+	zl = policy_zonelist(gfp, pol, node);
 	if (unlikely(mpol_needs_cond_ref(pol))) {
 		/*
 		 * slow path: ref counted shared policy
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
