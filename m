Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 489238D003D
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 14:08:11 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 5/8] Use correct numa policy node for transparent hugepages
Date: Mon, 21 Feb 2011 11:07:47 -0800
Message-Id: <1298315270-10434-6-git-send-email-andi@firstfloor.org>
In-Reply-To: <1298315270-10434-1-git-send-email-andi@firstfloor.org>
References: <1298315270-10434-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, lwoodman@redhat.com, Andi Kleen <ak@linux.intel.com>

From: Andi Kleen <ak@linux.intel.com>

Pass down the correct node for a transparent hugepage allocation.
Most callers continue to use the current node, however the hugepaged
daemon now uses the previous node of the first to be collapsed page
instead. This ensures that khugepaged does not mess up local memory
for an existing process which uses local policy.

The choice of node is somewhat primitive currently: it just
uses the node of the first page in the pmd range. An alternative
would be to look at multiple pages and use the most popular
node. I used the simplest variant for now which should work
well enough for the case of all pages being on the same node.

Cc: aarcange@redhat.com
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 mm/huge_memory.c |   24 +++++++++++++++++-------
 mm/mempolicy.c   |    3 ++-
 2 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 00a5c39..5a05b35 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -650,10 +650,10 @@ static inline gfp_t alloc_hugepage_gfpmask(int defrag)
 
 static inline struct page *alloc_hugepage_vma(int defrag,
 					      struct vm_area_struct *vma,
-					      unsigned long haddr)
+					      unsigned long haddr, int nd)
 {
 	return alloc_pages_vma(alloc_hugepage_gfpmask(defrag),
-			       HPAGE_PMD_ORDER, vma, haddr, numa_node_id());
+			       HPAGE_PMD_ORDER, vma, haddr, nd);
 }
 
 #ifndef CONFIG_NUMA
@@ -678,7 +678,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		if (unlikely(khugepaged_enter(vma)))
 			return VM_FAULT_OOM;
 		page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
-					  vma, haddr);
+					  vma, haddr, numa_node_id());
 		if (unlikely(!page))
 			goto out;
 		if (unlikely(mem_cgroup_newpage_charge(page, mm, GFP_KERNEL))) {
@@ -902,7 +902,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (transparent_hugepage_enabled(vma) &&
 	    !transparent_hugepage_debug_cow())
 		new_page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
-					      vma, haddr);
+					      vma, haddr, numa_node_id());
 	else
 		new_page = NULL;
 
@@ -1745,7 +1745,8 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
 static void collapse_huge_page(struct mm_struct *mm,
 			       unsigned long address,
 			       struct page **hpage,
-			       struct vm_area_struct *vma)
+			       struct vm_area_struct *vma,
+			       int node)
 {
 	pgd_t *pgd;
 	pud_t *pud;
@@ -1773,7 +1774,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * mmap_sem in read mode is good idea also to allow greater
 	 * scalability.
 	 */
-	new_page = alloc_hugepage_vma(khugepaged_defrag(), vma, address);
+	new_page = alloc_hugepage_vma(khugepaged_defrag(), vma, address,
+				      node);
 	if (unlikely(!new_page)) {
 		up_read(&mm->mmap_sem);
 		*hpage = ERR_PTR(-ENOMEM);
@@ -1917,6 +1919,7 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 	struct page *page;
 	unsigned long _address;
 	spinlock_t *ptl;
+	int node = -1;
 
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 
@@ -1947,6 +1950,13 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 		page = vm_normal_page(vma, _address, pteval);
 		if (unlikely(!page))
 			goto out_unmap;
+		/* 
+		 * Chose the node of the first page. This could 
+		 * be more sophisticated and look at more pages,
+		 * but isn't for now.
+		 */
+		if (node == -1) 
+			node = page_to_nid(page);
 		VM_BUG_ON(PageCompound(page));
 		if (!PageLRU(page) || PageLocked(page) || !PageAnon(page))
 			goto out_unmap;
@@ -1963,7 +1973,7 @@ out_unmap:
 	pte_unmap_unlock(pte, ptl);
 	if (ret)
 		/* collapse_huge_page will return with the mmap_sem released */
-		collapse_huge_page(mm, address, hpage, vma);
+		collapse_huge_page(mm, address, hpage, vma, node);
 out:
 	return ret;
 }
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d3d1e747..0e7515a 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1891,7 +1891,8 @@ struct page *alloc_pages_current(gfp_t gfp, unsigned order)
 		page = alloc_page_interleave(gfp, order, interleave_nodes(pol));
 	else
 		page = __alloc_pages_nodemask(gfp, order,
-			policy_zonelist(gfp, pol), policy_nodemask(gfp, pol));
+	      			policy_zonelist(gfp, pol, numa_node_id()), 
+				policy_nodemask(gfp, pol));
 	put_mems_allowed();
 	return page;
 }
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
