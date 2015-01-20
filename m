Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id E84426B006E
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 06:35:02 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id et14so45153326pad.3
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 03:35:02 -0800 (PST)
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com. [202.81.31.147])
        by mx.google.com with ESMTPS id zn6si4448743pac.126.2015.01.20.03.34.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 Jan 2015 03:35:01 -0800 (PST)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 20 Jan 2015 21:34:55 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id D2D313578048
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 22:34:51 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t0KBYpkG48955448
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 22:34:51 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t0KBYooq023470
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 22:34:50 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V4] mm/thp: Allocate transparent hugepages on local node
Date: Tue, 20 Jan 2015 17:04:31 +0530
Message-Id: <1421753671-16793-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This make sure that we try to allocate hugepages from local node if
allowed by mempolicy. If we can't, we fallback to small page allocation
based on mempolicy. This is based on the observation that allocating pages
on local node is more beneficial than allocating hugepages on remote
node.

With this patch applied we may find transparent huge page allocation
failures if the current node doesn't have enough freee hugepages.
Before this patch such failures result in us retrying the allocation on
other nodes in the numa node mask.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
Changes from V3:
* Add more comments. Update commit message. 

 include/linux/gfp.h |  4 +++
 mm/huge_memory.c    | 24 +++++++-----------
 mm/mempolicy.c      | 70 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 83 insertions(+), 15 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index b840e3b2770d..60110e06419d 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -335,11 +335,15 @@ alloc_pages(gfp_t gfp_mask, unsigned int order)
 extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
 			struct vm_area_struct *vma, unsigned long addr,
 			int node);
+extern struct page *alloc_hugepage_vma(gfp_t gfp, struct vm_area_struct *vma,
+				       unsigned long addr, int order);
 #else
 #define alloc_pages(gfp_mask, order) \
 		alloc_pages_node(numa_node_id(), gfp_mask, order)
 #define alloc_pages_vma(gfp_mask, order, vma, addr, node)	\
 	alloc_pages(gfp_mask, order)
+#define alloc_hugepage_vma(gfp_mask, vma, addr, order)	\
+	alloc_pages(gfp_mask, order)
 #endif
 #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
 #define alloc_page_vma(gfp_mask, vma, addr)			\
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 817a875f2b8c..031fb1584bbf 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -766,15 +766,6 @@ static inline gfp_t alloc_hugepage_gfpmask(int defrag, gfp_t extra_gfp)
 	return (GFP_TRANSHUGE & ~(defrag ? 0 : __GFP_WAIT)) | extra_gfp;
 }
 
-static inline struct page *alloc_hugepage_vma(int defrag,
-					      struct vm_area_struct *vma,
-					      unsigned long haddr, int nd,
-					      gfp_t extra_gfp)
-{
-	return alloc_pages_vma(alloc_hugepage_gfpmask(defrag, extra_gfp),
-			       HPAGE_PMD_ORDER, vma, haddr, nd);
-}
-
 /* Caller must hold page table lock. */
 static bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
 		struct vm_area_struct *vma, unsigned long haddr, pmd_t *pmd,
@@ -795,6 +786,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			       unsigned long address, pmd_t *pmd,
 			       unsigned int flags)
 {
+	gfp_t gfp;
 	struct page *page;
 	unsigned long haddr = address & HPAGE_PMD_MASK;
 
@@ -829,8 +821,8 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 		return 0;
 	}
-	page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
-			vma, haddr, numa_node_id(), 0);
+	gfp = alloc_hugepage_gfpmask(transparent_hugepage_defrag(vma), 0);
+	page = alloc_hugepage_vma(gfp, vma, haddr, HPAGE_PMD_ORDER);
 	if (unlikely(!page)) {
 		count_vm_event(THP_FAULT_FALLBACK);
 		return VM_FAULT_FALLBACK;
@@ -1118,10 +1110,12 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	spin_unlock(ptl);
 alloc:
 	if (transparent_hugepage_enabled(vma) &&
-	    !transparent_hugepage_debug_cow())
-		new_page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
-					      vma, haddr, numa_node_id(), 0);
-	else
+	    !transparent_hugepage_debug_cow()) {
+		gfp_t gfp;
+
+		gfp = alloc_hugepage_gfpmask(transparent_hugepage_defrag(vma), 0);
+		new_page = alloc_hugepage_vma(gfp, vma, haddr, HPAGE_PMD_ORDER);
+	} else
 		new_page = NULL;
 
 	if (unlikely(!new_page)) {
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 0e0961b8c39c..e99e8352cc04 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2031,6 +2031,76 @@ retry_cpuset:
 }
 
 /**
+ * alloc_hugepage_vma: Allocate a hugepage for a VMA
+ * @gfp:
+ *   %GFP_USER	  user allocation.
+ *   %GFP_KERNEL  kernel allocations,
+ *   %GFP_HIGHMEM highmem/user allocations,
+ *   %GFP_FS	  allocation should not call back into a file system.
+ *   %GFP_ATOMIC  don't sleep.
+ *
+ * @vma:   Pointer to VMA or NULL if not available.
+ * @addr:  Virtual Address of the allocation. Must be inside the VMA.
+ * @order: Order of the hugepage for gfp allocation.
+ *
+ * This functions allocate a huge page from the kernel page pool and applies
+ * a NUMA policy associated with the VMA or the current process.
+ * For policy other than %MPOL_INTERLEAVE, we make sure we allocate hugepage
+ * only from the current node if the current node is part of the node mask.
+ * If we can't allocate a hugepage we fail the allocation and don' try to fallback
+ * to other nodes in the node mask. If the current node is not part of node mask
+ * or if the NUMA policy is MPOL_INTERLEAVE we use the allocator that can
+ * fallback to nodes in the policy node mask.
+ *
+ * When VMA is not NULL caller must hold down_read on the mmap_sem of the
+ * mm_struct of the VMA to prevent it from going away. Should be used for
+ * all allocations for pages that will be mapped into
+ * user space. Returns NULL when no page can be allocated.
+ *
+ * Should be called with the mm_sem of the vma hold.
+ *
+ */
+struct page *alloc_hugepage_vma(gfp_t gfp, struct vm_area_struct *vma,
+				unsigned long addr, int order)
+{
+	struct page *page;
+	nodemask_t *nmask;
+	struct mempolicy *pol;
+	int node = numa_node_id();
+	unsigned int cpuset_mems_cookie;
+
+retry_cpuset:
+	pol = get_vma_policy(vma, addr);
+	cpuset_mems_cookie = read_mems_allowed_begin();
+	/*
+	 * For interleave policy, we don't worry about
+	 * current node. Otherwise if current node is
+	 * in nodemask, try to allocate hugepage from
+	 * the current node. Don't fall back to other nodes
+	 * for THP.
+	 */
+	if (unlikely(pol->mode == MPOL_INTERLEAVE))
+		goto alloc_with_fallback;
+	nmask = policy_nodemask(gfp, pol);
+	if (!nmask || node_isset(node, *nmask)) {
+		mpol_cond_put(pol);
+		page = alloc_pages_exact_node(node, gfp, order);
+		if (unlikely(!page &&
+			     read_mems_allowed_retry(cpuset_mems_cookie)))
+			goto retry_cpuset;
+		return page;
+	}
+alloc_with_fallback:
+	mpol_cond_put(pol);
+	/*
+	 * if current node is not part of node mask, try
+	 * the allocation from any node, and we can do retry
+	 * in that case.
+	 */
+	return alloc_pages_vma(gfp, order, vma, addr, node);
+}
+
+/**
  * 	alloc_pages_current - Allocate pages.
  *
  *	@gfp:
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
