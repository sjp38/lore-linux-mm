Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8617E6B0069
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 00:47:04 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id y13so10186387pdi.17
        for <linux-mm@kvack.org>; Sun, 30 Nov 2014 21:47:04 -0800 (PST)
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com. [122.248.162.2])
        by mx.google.com with ESMTPS id zv1si27041252pbb.220.2014.11.30.21.47.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 30 Nov 2014 21:47:03 -0800 (PST)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 1 Dec 2014 11:16:55 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 32AD3E0053
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 11:17:19 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sB15lQeP63307996
	for <linux-mm@kvack.org>; Mon, 1 Dec 2014 11:17:27 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sB15koFU011579
	for <linux-mm@kvack.org>; Mon, 1 Dec 2014 11:16:50 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2] mm/thp: Allocate transparent hugepages on local node
Date: Mon,  1 Dec 2014 11:16:43 +0530
Message-Id: <1417412803-27234-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This make sure that we try to allocate hugepages from local node if
allowed by mempolicy. If we can't, we fallback to small page allocation
based on mempolicy. This is based on the observation that allocating pages
on local node is more beneficial that allocating hugepages on remote node.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/gfp.h |  4 ++++
 mm/huge_memory.c    | 24 +++++++++---------------
 mm/mempolicy.c      | 40 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 53 insertions(+), 15 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 41b30fd4d041..fcbd017b4fb4 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -338,11 +338,15 @@ alloc_pages(gfp_t gfp_mask, unsigned int order)
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
index de984159cf0b..7903eb995b7f 100644
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
@@ -796,6 +787,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			       unsigned long address, pmd_t *pmd,
 			       unsigned int flags)
 {
+	gfp_t gfp;
 	struct page *page;
 	unsigned long haddr = address & HPAGE_PMD_MASK;
 
@@ -830,8 +822,8 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
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
@@ -1119,10 +1111,12 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
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
index e58725aff7e9..fa96af5b31f7 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2041,6 +2041,46 @@ retry_cpuset:
 	return page;
 }
 
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
+
+	if (pol->mode != MPOL_INTERLEAVE) {
+		/*
+		 * For interleave policy, we don't worry about
+		 * current node. Otherwise if current node is
+		 * in nodemask, try to allocate hugepage from
+		 * current node. Don't fall back to other nodes
+		 * for THP.
+		 */
+		nmask = policy_nodemask(gfp, pol);
+		if (!nmask || node_isset(node, *nmask)) {
+			mpol_cond_put(pol);
+			page = alloc_pages_exact_node(node, gfp, order);
+			if (unlikely(!page &&
+				     read_mems_allowed_retry(cpuset_mems_cookie)))
+				goto retry_cpuset;
+			return page;
+		}
+	}
+	mpol_cond_put(pol);
+	/*
+	 * if current node is not part of node mask, try
+	 * the allocation from any node, and we can do retry
+	 * in that case.
+	 */
+	return alloc_pages_vma(gfp, order, vma, addr, node);
+}
+
 /**
  * 	alloc_pages_current - Allocate pages.
  *
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
