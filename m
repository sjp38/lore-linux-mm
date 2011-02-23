Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 96DEC8D003E
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 20:52:38 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 7/8] Use GFP_OTHER_NODE for transparent huge pages
Date: Tue, 22 Feb 2011 17:52:01 -0800
Message-Id: <1298425922-23630-8-git-send-email-andi@firstfloor.org>
In-Reply-To: <1298425922-23630-1-git-send-email-andi@firstfloor.org>
References: <1298425922-23630-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, aarcange@redhat.com

From: Andi Kleen <ak@linux.intel.com>

Pass GFP_OTHER_NODE for transparent hugepages NUMA allocations
done by the hugepages daemon. This way the low level accounting
for local versus remote pages works correctly.

Cc: aarcange@redhat.com
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 mm/huge_memory.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5a05b35..877756e 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -643,16 +643,17 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 	return ret;
 }
 
-static inline gfp_t alloc_hugepage_gfpmask(int defrag)
+static inline gfp_t alloc_hugepage_gfpmask(int defrag, gfp_t extra_gfp)
 {
-	return GFP_TRANSHUGE & ~(defrag ? 0 : __GFP_WAIT);
+	return (GFP_TRANSHUGE & ~(defrag ? 0 : __GFP_WAIT)) | extra_gfp;
 }
 
 static inline struct page *alloc_hugepage_vma(int defrag,
 					      struct vm_area_struct *vma,
-					      unsigned long haddr, int nd)
+					      unsigned long haddr, int nd,
+					      gfp_t extra_gfp)
 {
-	return alloc_pages_vma(alloc_hugepage_gfpmask(defrag),
+	return alloc_pages_vma(alloc_hugepage_gfpmask(defrag, extra_gfp),
 			       HPAGE_PMD_ORDER, vma, haddr, nd);
 }
 
@@ -678,7 +679,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		if (unlikely(khugepaged_enter(vma)))
 			return VM_FAULT_OOM;
 		page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
-					  vma, haddr, numa_node_id());
+					  vma, haddr, numa_node_id(), 0);
 		if (unlikely(!page))
 			goto out;
 		if (unlikely(mem_cgroup_newpage_charge(page, mm, GFP_KERNEL))) {
@@ -799,7 +800,8 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 	}
 
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
-		pages[i] = alloc_page_vma_node(GFP_HIGHUSER_MOVABLE,
+		pages[i] = alloc_page_vma_node(GFP_HIGHUSER_MOVABLE | 
+					       __GFP_OTHER_NODE,
 					       vma, address, page_to_nid(page));
 		if (unlikely(!pages[i] ||
 			     mem_cgroup_newpage_charge(pages[i], mm,
@@ -902,7 +904,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (transparent_hugepage_enabled(vma) &&
 	    !transparent_hugepage_debug_cow())
 		new_page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
-					      vma, haddr, numa_node_id());
+					      vma, haddr, numa_node_id(), 0);
 	else
 		new_page = NULL;
 
@@ -1775,7 +1777,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * scalability.
 	 */
 	new_page = alloc_hugepage_vma(khugepaged_defrag(), vma, address,
-				      node);
+				      node, __GFP_OTHER_NODE);
 	if (unlikely(!new_page)) {
 		up_read(&mm->mmap_sem);
 		*hpage = ERR_PTR(-ENOMEM);
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
