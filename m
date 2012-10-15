Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 4B1566B0068
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 02:00:35 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH v4 07/10] thp: implement splitting pmd for huge zero page
Date: Mon, 15 Oct 2012 09:00:56 +0300
Message-Id: <1350280859-18801-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1350280859-18801-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1350280859-18801-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org
Cc: Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We can't split huge zero page itself (and it's bug if we try), but we
can split the pmd which points to it.

On splitting the pmd we create a table with all ptes set to normal zero
page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c |   47 ++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 44 insertions(+), 3 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 87359f1..b267b12 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1610,6 +1610,7 @@ int split_huge_page(struct page *page)
 	struct anon_vma *anon_vma;
 	int ret = 1;
 
+	BUG_ON(is_huge_zero_pfn(page_to_pfn(page)));
 	BUG_ON(!PageAnon(page));
 	anon_vma = page_lock_anon_vma(page);
 	if (!anon_vma)
@@ -2508,23 +2509,63 @@ static int khugepaged(void *none)
 	return 0;
 }
 
+static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
+		unsigned long haddr, pmd_t *pmd)
+{
+	pgtable_t pgtable;
+	pmd_t _pmd;
+	int i;
+
+	pmdp_clear_flush(vma, haddr, pmd);
+	/* leave pmd empty until pte is filled */
+
+	pgtable = get_pmd_huge_pte(vma->vm_mm);
+	pmd_populate(vma->vm_mm, &_pmd, pgtable);
+
+	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
+		pte_t *pte, entry;
+		entry = pfn_pte(my_zero_pfn(haddr), vma->vm_page_prot);
+		entry = pte_mkspecial(entry);
+		pte = pte_offset_map(&_pmd, haddr);
+		VM_BUG_ON(!pte_none(*pte));
+		set_pte_at(vma->vm_mm, haddr, pte, entry);
+		pte_unmap(pte);
+	}
+	smp_wmb(); /* make pte visible before pmd */
+	pmd_populate(vma->vm_mm, pmd, pgtable);
+}
+
 void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long address,
 		pmd_t *pmd)
 {
 	struct page *page;
+	struct mm_struct *mm = vma->vm_mm;
 	unsigned long haddr = address & HPAGE_PMD_MASK;
+	unsigned long mmun_start;	/* For mmu_notifiers */
+	unsigned long mmun_end;		/* For mmu_notifiers */
 
 	BUG_ON(vma->vm_start > haddr || vma->vm_end < haddr + HPAGE_PMD_SIZE);
 
-	spin_lock(&vma->vm_mm->page_table_lock);
+	mmun_start = haddr;
+	mmun_end   = address + HPAGE_PMD_SIZE;
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_trans_huge(*pmd))) {
-		spin_unlock(&vma->vm_mm->page_table_lock);
+		spin_unlock(&mm->page_table_lock);
+		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+		return;
+	}
+	if (is_huge_zero_pmd(*pmd)) {
+		__split_huge_zero_page_pmd(vma, haddr, pmd);
+		spin_unlock(&mm->page_table_lock);
+		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 		return;
 	}
 	page = pmd_page(*pmd);
 	VM_BUG_ON(!page_count(page));
 	get_page(page);
-	spin_unlock(&vma->vm_mm->page_table_lock);
+	spin_unlock(&mm->page_table_lock);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 
 	split_huge_page(page);
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
