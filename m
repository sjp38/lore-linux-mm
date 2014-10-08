Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 5C883900014
	for <linux-mm@kvack.org>; Wed,  8 Oct 2014 09:25:52 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so9134348pab.32
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 06:25:52 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id rp11si69660pab.22.2014.10.08.06.25.48
        for <linux-mm@kvack.org>;
        Wed, 08 Oct 2014 06:25:49 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v1 2/7] mm: Prepare for DAX huge pages
Date: Wed,  8 Oct 2014 09:25:24 -0400
Message-Id: <1412774729-23956-3-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1412774729-23956-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1412774729-23956-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.krenel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <willy@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

DAX wants to use the 'special' bit to mark PMD entries that are not backed
by struct page, just as for PTEs.  Add pmd_special() and pmd_mkspecial
for x86 (nb: also need to be added for other architectures).  Prepare
do_huge_pmd_wp_page(), zap_huge_pmd() and __split_huge_page_pmd() to
handle pmd_special entries.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 arch/x86/include/asm/pgtable.h | 10 +++++++++
 mm/huge_memory.c               | 51 ++++++++++++++++++++++++++----------------
 2 files changed, 42 insertions(+), 19 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index aa97a07..f4f42f2 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -302,6 +302,11 @@ static inline pmd_t pmd_mknotpresent(pmd_t pmd)
 	return pmd_clear_flags(pmd, _PAGE_PRESENT);
 }
 
+static inline pmd_t pmd_mkspecial(pmd_t pmd)
+{
+	return pmd_set_flags(pmd, _PAGE_SPECIAL);
+}
+
 #ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
 static inline int pte_soft_dirty(pte_t pte)
 {
@@ -504,6 +509,11 @@ static inline int pmd_none(pmd_t pmd)
 	return (unsigned long)native_pmd_val(pmd) == 0;
 }
 
+static inline int pmd_special(pmd_t pmd)
+{
+	return (pmd_flags(pmd) & _PAGE_SPECIAL) && pmd_present(pmd);
+}
+
 static inline unsigned long pmd_page_vaddr(pmd_t pmd)
 {
 	return (unsigned long)__va(pmd_val(pmd) & PTE_PFN_MASK);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 2a56ddd..ad09fc1 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1096,7 +1096,6 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long mmun_end;		/* For mmu_notifiers */
 
 	ptl = pmd_lockptr(mm, pmd);
-	VM_BUG_ON(!vma->anon_vma);
 	haddr = address & HPAGE_PMD_MASK;
 	if (is_huge_zero_pmd(orig_pmd))
 		goto alloc;
@@ -1104,9 +1103,20 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (unlikely(!pmd_same(*pmd, orig_pmd)))
 		goto out_unlock;
 
-	page = pmd_page(orig_pmd);
-	VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
-	if (page_mapcount(page) == 1) {
+	if (pmd_special(orig_pmd)) {
+		/* VM_MIXEDMAP !pfn_valid() case */
+		if ((vma->vm_flags & (VM_WRITE|VM_SHARED)) !=
+				     (VM_WRITE|VM_SHARED)) {
+			pmdp_clear_flush(vma, haddr, pmd);
+			ret = VM_FAULT_FALLBACK;
+			goto out_unlock;
+		}
+	} else {
+		VM_BUG_ON(!vma->anon_vma);
+		page = pmd_page(orig_pmd);
+		VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
+	}
+	if (!page || page_mapcount(page) == 1) {
 		pmd_t entry;
 		entry = pmd_mkyoung(orig_pmd);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
@@ -1391,7 +1401,6 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	int ret = 0;
 
 	if (__pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
-		struct page *page;
 		pgtable_t pgtable;
 		pmd_t orig_pmd;
 		/*
@@ -1402,13 +1411,17 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		 */
 		orig_pmd = pmdp_get_and_clear(tlb->mm, addr, pmd);
 		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
+		if (pmd_special(orig_pmd)) {
+			spin_unlock(ptl);
+			return 1;
+		}
 		pgtable = pgtable_trans_huge_withdraw(tlb->mm, pmd);
 		if (is_huge_zero_pmd(orig_pmd)) {
 			atomic_long_dec(&tlb->mm->nr_ptes);
 			spin_unlock(ptl);
 			put_huge_zero_page();
 		} else {
-			page = pmd_page(orig_pmd);
+			struct page *page = pmd_page(orig_pmd);
 			page_remove_rmap(page);
 			VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
 			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
@@ -2860,7 +2873,7 @@ void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long address,
 		pmd_t *pmd)
 {
 	spinlock_t *ptl;
-	struct page *page;
+	struct page *page = NULL;
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long haddr = address & HPAGE_PMD_MASK;
 	unsigned long mmun_start;	/* For mmu_notifiers */
@@ -2873,25 +2886,25 @@ void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long address,
 again:
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 	ptl = pmd_lock(mm, pmd);
-	if (unlikely(!pmd_trans_huge(*pmd))) {
-		spin_unlock(ptl);
-		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
-		return;
-	}
+	if (unlikely(!pmd_trans_huge(*pmd)))
+		goto unlock;
 	if (is_huge_zero_pmd(*pmd)) {
 		__split_huge_zero_page_pmd(vma, haddr, pmd);
-		spin_unlock(ptl);
-		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
-		return;
+	} else if (pmd_special(*pmd)) {
+		pmdp_clear_flush(vma, haddr, pmd);
+	} else {
+		page = pmd_page(*pmd);
+		VM_BUG_ON_PAGE(!page_count(page), page);
+		get_page(page);
 	}
-	page = pmd_page(*pmd);
-	VM_BUG_ON_PAGE(!page_count(page), page);
-	get_page(page);
+ unlock:
 	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 
-	split_huge_page(page);
+	if (!page)
+		return;
 
+	split_huge_page(page);
 	put_page(page);
 
 	/*
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
