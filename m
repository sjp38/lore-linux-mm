Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id D638D9003C8
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 10:26:31 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so104442665pdj.3
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 07:26:31 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ah3si36347526pad.55.2015.07.20.07.21.27
        for <linux-mm@kvack.org>;
        Mon, 20 Jul 2015 07:21:27 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9 29/36] thp: implement split_huge_pmd()
Date: Mon, 20 Jul 2015 17:21:02 +0300
Message-Id: <1437402069-105900-30-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Original split_huge_page() combined two operations: splitting PMDs into
tables of PTEs and splitting underlying compound page. This patch
implements split_huge_pmd() which split given PMD without splitting
other PMDs this page mapped with or underlying compound page.

Without tail page refcounting, implementation of split_huge_pmd() is
pretty straight-forward.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/huge_mm.h |  11 ++++-
 mm/huge_memory.c        | 122 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 132 insertions(+), 1 deletion(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 460441349a52..940112755591 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -96,7 +96,16 @@ extern unsigned long transparent_hugepage_flags;
 
 #define split_huge_page_to_list(page, list) BUILD_BUG()
 #define split_huge_page(page) BUILD_BUG()
-#define split_huge_pmd(__vma, __pmd, __address) BUILD_BUG()
+
+void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
+		unsigned long address);
+
+#define split_huge_pmd(__vma, __pmd, __address)				\
+	do {								\
+		pmd_t *____pmd = (__pmd);				\
+		if (pmd_trans_huge(*____pmd))				\
+			__split_huge_pmd(__vma, __pmd, __address);	\
+	}  while (0)
 
 #if HPAGE_PMD_ORDER >= MAX_ORDER
 #error "hugepages can't be allocated by the buddy allocator"
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 52a20e92d51a..1f7a7288ffa3 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2599,6 +2599,128 @@ static int khugepaged(void *none)
 	return 0;
 }
 
+static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
+		unsigned long haddr, pmd_t *pmd)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pgtable_t pgtable;
+	pmd_t _pmd;
+	int i;
+
+	/* leave pmd empty until pte is filled */
+	pmdp_huge_clear_flush_notify(vma, haddr, pmd);
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
+static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
+		unsigned long haddr)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	struct page *page;
+	pgtable_t pgtable;
+	pmd_t _pmd;
+	bool young, write;
+	int i;
+
+	VM_BUG_ON(haddr & ~HPAGE_PMD_MASK);
+	VM_BUG_ON_VMA(vma->vm_start > haddr, vma);
+	VM_BUG_ON_VMA(vma->vm_end < haddr + HPAGE_PMD_SIZE, vma);
+	VM_BUG_ON(!pmd_trans_huge(*pmd));
+
+	count_vm_event(THP_SPLIT_PMD);
+
+	if (vma_is_dax(vma)) {
+		pmdp_huge_clear_flush_notify(vma, haddr, pmd);
+		return;
+	} else if (is_huge_zero_pmd(*pmd)) {
+		return __split_huge_zero_page_pmd(vma, haddr, pmd);
+	}
+
+	page = pmd_page(*pmd);
+	VM_BUG_ON_PAGE(!page_count(page), page);
+	atomic_add(HPAGE_PMD_NR - 1, &page->_count);
+	write = pmd_write(*pmd);
+	young = pmd_young(*pmd);
+
+	/* leave pmd empty until pte is filled */
+	pmdp_huge_clear_flush_notify(vma, haddr, pmd);
+
+	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
+	pmd_populate(mm, &_pmd, pgtable);
+
+	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
+		pte_t entry, *pte;
+		/*
+		 * Note that NUMA hinting access restrictions are not
+		 * transferred to avoid any possibility of altering
+		 * permissions across VMAs.
+		 */
+		entry = mk_pte(page + i, vma->vm_page_prot);
+		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		if (!write)
+			entry = pte_wrprotect(entry);
+		if (!young)
+			entry = pte_mkold(entry);
+		pte = pte_offset_map(&_pmd, haddr);
+		BUG_ON(!pte_none(*pte));
+		set_pte_at(mm, haddr, pte, entry);
+		atomic_inc(&page[i]._mapcount);
+		pte_unmap(pte);
+	}
+
+	/*
+	 * Set PG_double_map before dropping compound_mapcount to avoid
+	 * false-negative page_mapped().
+	 */
+	if (compound_mapcount(page) > 1 && !TestSetPageDoubleMap(page)) {
+		for (i = 0; i < HPAGE_PMD_NR; i++)
+			atomic_inc(&page[i]._mapcount);
+	}
+
+	if (atomic_add_negative(-1, compound_mapcount_ptr(page))) {
+		/* Last compound_mapcount is gone. */
+		__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+		if (TestClearPageDoubleMap(page)) {
+			/* No need in mapcount reference anymore */
+			for (i = 0; i < HPAGE_PMD_NR; i++)
+				atomic_dec(&page[i]._mapcount);
+		}
+	}
+
+	smp_wmb(); /* make pte visible before pmd */
+	pmd_populate(mm, pmd, pgtable);
+}
+
+void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
+		unsigned long address)
+{
+	spinlock_t *ptl;
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned long haddr = address & HPAGE_PMD_MASK;
+
+	mmu_notifier_invalidate_range_start(mm, haddr, haddr + HPAGE_PMD_SIZE);
+	ptl = pmd_lock(mm, pmd);
+	if (likely(pmd_trans_huge(*pmd)))
+		__split_huge_pmd_locked(vma, pmd, haddr);
+	spin_unlock(ptl);
+	mmu_notifier_invalidate_range_end(mm, haddr, haddr + HPAGE_PMD_SIZE);
+}
+
 static void split_huge_pmd_address(struct vm_area_struct *vma,
 				    unsigned long address)
 {
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
