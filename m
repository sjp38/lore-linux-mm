Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5C20B6B0032
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 10:08:34 -0400 (EDT)
Received: by wifj2 with SMTP id j2so44525359wif.1
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 07:08:33 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ev20si18125451wjc.79.2015.03.16.07.08.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Mar 2015 07:08:32 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] mm, memcg: sync allocation and memcg charge gfp flags for THP
Date: Mon, 16 Mar 2015 15:08:12 +0100
Message-Id: <1426514892-7063-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

memcg currently uses hardcoded GFP_TRANSHUGE gfp flags for all THP
charges. THP allocations, however, might be using different flags
depending on /sys/kernel/mm/transparent_hugepage/{,khugepaged/}defrag
and the current allocation context.

The primary difference is that defrag configured to "madvise" value will
clear __GFP_WAIT flag from the core gfp mask to make the allocation
lighter for all mappings which are not backed by VM_HUGEPAGE vmas.
If memcg charge path ignores this fact we will get light allocation but
the a potential memcg reclaim would kill the whole point of the
configuration.

Fix the mismatch by providing the same gfp mask used for the
allocation to the charge functions. This is quite easy for all
paths except for hugepaged kernel thread with !CONFIG_NUMA which is
doing a pre-allocation long before the allocated page is used in
collapse_huge_page via khugepaged_alloc_page. To prevent from cluttering
the whole code path from khugepaged_do_scan we simply return the current
flags as per khugepaged_defrag() value which might have changed since
the preallocation. If somebody changed the value of the knob we would
charge differently but this shouldn't happen often and it is definitely
not critical because it would only lead to a reduced success rate of
one-off THP promotion.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/huge_memory.c | 36 ++++++++++++++++++++----------------
 1 file changed, 20 insertions(+), 16 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 625eb556b509..91898b010406 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -708,7 +708,7 @@ static inline pmd_t mk_huge_pmd(struct page *page, pgprot_t prot)
 static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 					struct vm_area_struct *vma,
 					unsigned long haddr, pmd_t *pmd,
-					struct page *page)
+					struct page *page, gfp_t gfp)
 {
 	struct mem_cgroup *memcg;
 	pgtable_t pgtable;
@@ -716,7 +716,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 
 	VM_BUG_ON_PAGE(!PageCompound(page), page);
 
-	if (mem_cgroup_try_charge(page, mm, GFP_TRANSHUGE, &memcg))
+	if (mem_cgroup_try_charge(page, mm, gfp, &memcg))
 		return VM_FAULT_OOM;
 
 	pgtable = pte_alloc_one(mm, haddr);
@@ -822,7 +822,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		count_vm_event(THP_FAULT_FALLBACK);
 		return VM_FAULT_FALLBACK;
 	}
-	if (unlikely(__do_huge_pmd_anonymous_page(mm, vma, haddr, pmd, page))) {
+	if (unlikely(__do_huge_pmd_anonymous_page(mm, vma, haddr, pmd, page, gfp))) {
 		put_page(page);
 		count_vm_event(THP_FAULT_FALLBACK);
 		return VM_FAULT_FALLBACK;
@@ -1080,6 +1080,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long haddr;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
+	gfp_t huge_gfp = GFP_TRANSHUGE;	/* for allocation and charge */
 
 	ptl = pmd_lockptr(mm, pmd);
 	VM_BUG_ON_VMA(!vma->anon_vma, vma);
@@ -1106,10 +1107,8 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 alloc:
 	if (transparent_hugepage_enabled(vma) &&
 	    !transparent_hugepage_debug_cow()) {
-		gfp_t gfp;
-
-		gfp = alloc_hugepage_gfpmask(transparent_hugepage_defrag(vma), 0);
-		new_page = alloc_hugepage_vma(gfp, vma, haddr, HPAGE_PMD_ORDER);
+		huge_gfp = alloc_hugepage_gfpmask(transparent_hugepage_defrag(vma), 0);
+		new_page = alloc_hugepage_vma(huge_gfp, vma, haddr, HPAGE_PMD_ORDER);
 	} else
 		new_page = NULL;
 
@@ -1131,7 +1130,7 @@ alloc:
 	}
 
 	if (unlikely(mem_cgroup_try_charge(new_page, mm,
-					   GFP_TRANSHUGE, &memcg))) {
+					   huge_gfp, &memcg))) {
 		put_page(new_page);
 		if (page) {
 			split_huge_page(page);
@@ -2354,16 +2353,14 @@ static bool khugepaged_prealloc_page(struct page **hpage, bool *wait)
 }
 
 static struct page
-*khugepaged_alloc_page(struct page **hpage, struct mm_struct *mm,
+*khugepaged_alloc_page(struct page **hpage, gfp_t *gfp, struct mm_struct *mm,
 		       struct vm_area_struct *vma, unsigned long address,
 		       int node)
 {
-	gfp_t flags;
-
 	VM_BUG_ON_PAGE(*hpage, *hpage);
 
 	/* Only allocate from the target node */
-	flags = alloc_hugepage_gfpmask(khugepaged_defrag(), __GFP_OTHER_NODE) |
+	*gfp = alloc_hugepage_gfpmask(khugepaged_defrag(), __GFP_OTHER_NODE) |
 	        __GFP_THISNODE;
 
 	/*
@@ -2374,7 +2371,7 @@ static struct page
 	 */
 	up_read(&mm->mmap_sem);
 
-	*hpage = alloc_pages_exact_node(node, flags, HPAGE_PMD_ORDER);
+	*hpage = alloc_pages_exact_node(node, *gfp, HPAGE_PMD_ORDER);
 	if (unlikely(!*hpage)) {
 		count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
 		*hpage = ERR_PTR(-ENOMEM);
@@ -2428,12 +2425,18 @@ static bool khugepaged_prealloc_page(struct page **hpage, bool *wait)
 }
 
 static struct page
-*khugepaged_alloc_page(struct page **hpage, struct mm_struct *mm,
+*khugepaged_alloc_page(struct page **hpage, gfp_t *gfp, struct mm_struct *mm,
 		       struct vm_area_struct *vma, unsigned long address,
 		       int node)
 {
 	up_read(&mm->mmap_sem);
 	VM_BUG_ON(!*hpage);
+
+	/*
+	 * khugepaged_alloc_hugepage is doing the preallocation, use the same
+	 * gfp flags here.
+	 */
+	*gfp = alloc_hugepage_gfpmask(khugepaged_defrag(), 0);
 	return  *hpage;
 }
 #endif
@@ -2468,16 +2471,17 @@ static void collapse_huge_page(struct mm_struct *mm,
 	struct mem_cgroup *memcg;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
+	gfp_t gfp;
 
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 
 	/* release the mmap_sem read lock. */
-	new_page = khugepaged_alloc_page(hpage, mm, vma, address, node);
+	new_page = khugepaged_alloc_page(hpage, &gfp, mm, vma, address, node);
 	if (!new_page)
 		return;
 
 	if (unlikely(mem_cgroup_try_charge(new_page, mm,
-					   GFP_TRANSHUGE, &memcg)))
+					   gfp, &memcg)))
 		return;
 
 	/*
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
