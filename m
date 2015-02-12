Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2923F6B006C
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 11:20:11 -0500 (EST)
Received: by pdjy10 with SMTP id y10so12889098pdj.6
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 08:20:10 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id dh1si1708434pbc.142.2015.02.12.08.20.08
        for <linux-mm@kvack.org>;
        Thu, 12 Feb 2015 08:20:08 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 01/24] thp: cluster split_huge_page* code together
Date: Thu, 12 Feb 2015 18:18:15 +0200
Message-Id: <1423757918-197669-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Rearrange code in mm/huge_memory.c to make future changes somewhat
easier.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 224 +++++++++++++++++++++++++++----------------------------
 1 file changed, 112 insertions(+), 112 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e08e37ad050e..5f4c97e1a6da 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1622,6 +1622,118 @@ int pmd_freeable(pmd_t pmd)
 	return !pmd_dirty(pmd);
 }
 
+static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
+		unsigned long haddr, pmd_t *pmd)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pgtable_t pgtable;
+	pmd_t _pmd;
+	int i;
+
+	pmdp_clear_flush_notify(vma, haddr, pmd);
+	/* leave pmd empty until pte is filled */
+
+	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
+	pmd_populate(mm, &_pmd, pgtable);
+
+	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
+		pte_t *pte, entry;
+		entry = pfn_pte(my_zero_pfn(haddr), vma->vm_page_prot);
+		entry = pte_mkspecial(entry);
+		pte = pte_offset_map(&_pmd, haddr);
+		VM_BUG_ON(!pte_none(*pte));
+		set_pte_at(mm, haddr, pte, entry);
+		pte_unmap(pte);
+	}
+	smp_wmb(); /* make pte visible before pmd */
+	pmd_populate(mm, pmd, pgtable);
+	put_huge_zero_page();
+}
+
+void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long address,
+		pmd_t *pmd)
+{
+	spinlock_t *ptl;
+	struct page *page;
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned long haddr = address & HPAGE_PMD_MASK;
+	unsigned long mmun_start;	/* For mmu_notifiers */
+	unsigned long mmun_end;		/* For mmu_notifiers */
+
+	BUG_ON(vma->vm_start > haddr || vma->vm_end < haddr + HPAGE_PMD_SIZE);
+
+	mmun_start = haddr;
+	mmun_end   = haddr + HPAGE_PMD_SIZE;
+again:
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	ptl = pmd_lock(mm, pmd);
+	if (unlikely(!pmd_trans_huge(*pmd))) {
+		spin_unlock(ptl);
+		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+		return;
+	}
+	if (is_huge_zero_pmd(*pmd)) {
+		__split_huge_zero_page_pmd(vma, haddr, pmd);
+		spin_unlock(ptl);
+		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+		return;
+	}
+	page = pmd_page(*pmd);
+	VM_BUG_ON_PAGE(!page_count(page), page);
+	get_page(page);
+	spin_unlock(ptl);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+
+	split_huge_page(page);
+
+	put_page(page);
+
+	/*
+	 * We don't always have down_write of mmap_sem here: a racing
+	 * do_huge_pmd_wp_page() might have copied-on-write to another
+	 * huge page before our split_huge_page() got the anon_vma lock.
+	 */
+	if (unlikely(pmd_trans_huge(*pmd)))
+		goto again;
+}
+
+void split_huge_page_pmd_mm(struct mm_struct *mm, unsigned long address,
+		pmd_t *pmd)
+{
+	struct vm_area_struct *vma;
+
+	vma = find_vma(mm, address);
+	BUG_ON(vma == NULL);
+	split_huge_page_pmd(vma, address, pmd);
+}
+
+static void split_huge_page_address(struct mm_struct *mm,
+				    unsigned long address)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+
+	VM_BUG_ON(!(address & ~HPAGE_PMD_MASK));
+
+	pgd = pgd_offset(mm, address);
+	if (!pgd_present(*pgd))
+		return;
+
+	pud = pud_offset(pgd, address);
+	if (!pud_present(*pud))
+		return;
+
+	pmd = pmd_offset(pud, address);
+	if (!pmd_present(*pmd))
+		return;
+	/*
+	 * Caller holds the mmap_sem write mode, so a huge pmd cannot
+	 * materialize from under us.
+	 */
+	split_huge_page_pmd_mm(mm, address, pmd);
+}
+
 static int __split_huge_page_splitting(struct page *page,
 				       struct vm_area_struct *vma,
 				       unsigned long address)
@@ -2858,118 +2970,6 @@ static int khugepaged(void *none)
 	return 0;
 }
 
-static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
-		unsigned long haddr, pmd_t *pmd)
-{
-	struct mm_struct *mm = vma->vm_mm;
-	pgtable_t pgtable;
-	pmd_t _pmd;
-	int i;
-
-	pmdp_clear_flush_notify(vma, haddr, pmd);
-	/* leave pmd empty until pte is filled */
-
-	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
-	pmd_populate(mm, &_pmd, pgtable);
-
-	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
-		pte_t *pte, entry;
-		entry = pfn_pte(my_zero_pfn(haddr), vma->vm_page_prot);
-		entry = pte_mkspecial(entry);
-		pte = pte_offset_map(&_pmd, haddr);
-		VM_BUG_ON(!pte_none(*pte));
-		set_pte_at(mm, haddr, pte, entry);
-		pte_unmap(pte);
-	}
-	smp_wmb(); /* make pte visible before pmd */
-	pmd_populate(mm, pmd, pgtable);
-	put_huge_zero_page();
-}
-
-void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long address,
-		pmd_t *pmd)
-{
-	spinlock_t *ptl;
-	struct page *page;
-	struct mm_struct *mm = vma->vm_mm;
-	unsigned long haddr = address & HPAGE_PMD_MASK;
-	unsigned long mmun_start;	/* For mmu_notifiers */
-	unsigned long mmun_end;		/* For mmu_notifiers */
-
-	BUG_ON(vma->vm_start > haddr || vma->vm_end < haddr + HPAGE_PMD_SIZE);
-
-	mmun_start = haddr;
-	mmun_end   = haddr + HPAGE_PMD_SIZE;
-again:
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
-	ptl = pmd_lock(mm, pmd);
-	if (unlikely(!pmd_trans_huge(*pmd))) {
-		spin_unlock(ptl);
-		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
-		return;
-	}
-	if (is_huge_zero_pmd(*pmd)) {
-		__split_huge_zero_page_pmd(vma, haddr, pmd);
-		spin_unlock(ptl);
-		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
-		return;
-	}
-	page = pmd_page(*pmd);
-	VM_BUG_ON_PAGE(!page_count(page), page);
-	get_page(page);
-	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
-
-	split_huge_page(page);
-
-	put_page(page);
-
-	/*
-	 * We don't always have down_write of mmap_sem here: a racing
-	 * do_huge_pmd_wp_page() might have copied-on-write to another
-	 * huge page before our split_huge_page() got the anon_vma lock.
-	 */
-	if (unlikely(pmd_trans_huge(*pmd)))
-		goto again;
-}
-
-void split_huge_page_pmd_mm(struct mm_struct *mm, unsigned long address,
-		pmd_t *pmd)
-{
-	struct vm_area_struct *vma;
-
-	vma = find_vma(mm, address);
-	BUG_ON(vma == NULL);
-	split_huge_page_pmd(vma, address, pmd);
-}
-
-static void split_huge_page_address(struct mm_struct *mm,
-				    unsigned long address)
-{
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
-
-	VM_BUG_ON(!(address & ~HPAGE_PMD_MASK));
-
-	pgd = pgd_offset(mm, address);
-	if (!pgd_present(*pgd))
-		return;
-
-	pud = pud_offset(pgd, address);
-	if (!pud_present(*pud))
-		return;
-
-	pmd = pmd_offset(pud, address);
-	if (!pmd_present(*pmd))
-		return;
-	/*
-	 * Caller holds the mmap_sem write mode, so a huge pmd cannot
-	 * materialize from under us.
-	 */
-	split_huge_page_pmd_mm(mm, address, pmd);
-}
-
 void __vma_adjust_trans_huge(struct vm_area_struct *vma,
 			     unsigned long start,
 			     unsigned long end,
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
