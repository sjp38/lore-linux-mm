Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id DA2146B0294
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 20:35:00 -0500 (EST)
Received: by pfu207 with SMTP id 207so3096952pfu.2
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 17:35:00 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id 85si1281614pfl.178.2015.12.07.17.34.59
        for <linux-mm@kvack.org>;
        Mon, 07 Dec 2015 17:35:00 -0800 (PST)
Subject: [PATCH -mm 22/25] mm, dax: dax-pmd vs thp-pmd vs hugetlbfs-pmd
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 07 Dec 2015 17:34:32 -0800
Message-ID: <20151208013432.25030.18831.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151208013236.25030.68781.stgit@dwillia2-desk3.jf.intel.com>
References: <20151208013236.25030.68781.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave@sr71.net>, linux-nvdimm@lists.01.org, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

A dax-huge-page mapping while it uses some thp helpers is ultimately not a
transparent huge page.  The distinction is especially important in the
get_user_pages() path.  pmd_devmap() is used to distinguish dax-pmds from
pmd_huge() and pmd_trans_huge() which have slightly different semantics.

Explicitly mark the pmd_trans_huge() helpers that dax needs by adding
pmd_devmap() checks.

Also, before we introduce usages of pmd_pfn() in common code, include a
definition for archs that have not needed it to date.

Cc: Dave Hansen <dave@sr71.net>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Matthew Wilcox <willy@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/ia64/include/asm/pgtable.h      |    1 +
 arch/sh/include/asm/pgtable-3level.h |    1 +
 arch/x86/include/asm/pgtable.h       |    8 +++++++-
 include/asm-generic/pgtable.h        |    4 ++++
 include/linux/huge_mm.h              |    3 ++-
 include/linux/mm.h                   |    4 ++++
 mm/huge_memory.c                     |   33 +++++++++++++++++++--------------
 mm/memory.c                          |    8 ++++----
 mm/mprotect.c                        |    5 +++--
 mm/pgtable-generic.c                 |    2 +-
 10 files changed, 46 insertions(+), 23 deletions(-)

diff --git a/arch/ia64/include/asm/pgtable.h b/arch/ia64/include/asm/pgtable.h
index 9f3ed9ee8f13..81d2af23958f 100644
--- a/arch/ia64/include/asm/pgtable.h
+++ b/arch/ia64/include/asm/pgtable.h
@@ -273,6 +273,7 @@ extern unsigned long VMALLOC_END;
 #define pmd_clear(pmdp)			(pmd_val(*(pmdp)) = 0UL)
 #define pmd_page_vaddr(pmd)		((unsigned long) __va(pmd_val(pmd) & _PFN_MASK))
 #define pmd_page(pmd)			virt_to_page((pmd_val(pmd) + PAGE_OFFSET))
+#define pmd_pfn(pmd)			(pmd_val(pmd) >> PAGE_SHIFT)
 
 #define pud_none(pud)			(!pud_val(pud))
 #define pud_bad(pud)			(!ia64_phys_addr_valid(pud_val(pud)))
diff --git a/arch/sh/include/asm/pgtable-3level.h b/arch/sh/include/asm/pgtable-3level.h
index 249a985d9648..bb29a80fb40e 100644
--- a/arch/sh/include/asm/pgtable-3level.h
+++ b/arch/sh/include/asm/pgtable-3level.h
@@ -29,6 +29,7 @@
 
 typedef struct { unsigned long long pmd; } pmd_t;
 #define pmd_val(x)	((x).pmd)
+#define pmd_pfn(x)	((pmd_val(x) & PMD_MASK) >> PAGE_SHIFT)
 #define __pmd(x)	((pmd_t) { (x) } )
 
 static inline unsigned long pud_page_vaddr(pud_t pud)
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 5209ca1161d2..d377f950fb9f 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -164,7 +164,13 @@ static inline int pmd_large(pmd_t pte)
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 static inline int pmd_trans_huge(pmd_t pmd)
 {
-	return pmd_val(pmd) & _PAGE_PSE;
+	return (pmd_val(pmd) & (_PAGE_PSE|_PAGE_DEVMAP)) == _PAGE_PSE;
+}
+
+#define pmd_devmap pmd_devmap
+static inline int pmd_devmap(pmd_t pmd)
+{
+	return !!(pmd_val(pmd) & _PAGE_DEVMAP);
 }
 
 static inline int has_transparent_hugepage(void)
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index bdff35e90889..5459a66a8529 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -616,6 +616,10 @@ static inline int pmd_trans_huge(pmd_t pmd)
 {
 	return 0;
 }
+static inline int pmd_devmap(pmd_t pmd)
+{
+	return 0;
+}
 #ifndef __HAVE_ARCH_PMD_WRITE
 static inline int pmd_write(pmd_t pmd)
 {
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 0af95c1a2666..7deeaa7cc960 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -101,7 +101,8 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 #define split_huge_pmd(__vma, __pmd, __address)				\
 	do {								\
 		pmd_t *____pmd = (__pmd);				\
-		if (pmd_trans_huge(*____pmd))				\
+		if (pmd_trans_huge(*____pmd)				\
+					|| pmd_devmap(*____pmd))	\
 			__split_huge_pmd(__vma, __pmd, __address);	\
 	}  while (0)
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 4166977f51eb..5cad85044e50 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1931,6 +1931,10 @@ static inline void pgtable_pmd_page_dtor(struct page *page) {}
 #define pte_devmap(x) (0)
 #endif
 
+#ifndef pmd_devmap
+#define pmd_devmap(x) (0)
+#endif
+
 static inline spinlock_t *pmd_lock(struct mm_struct *mm, pmd_t *pmd)
 {
 	spinlock_t *ptl = pmd_lockptr(mm, pmd);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index c1491ce1d8ac..1864de3addd1 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1023,7 +1023,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 
 	ret = -EAGAIN;
 	pmd = *src_pmd;
-	if (unlikely(!pmd_trans_huge(pmd))) {
+	if (unlikely(!pmd_trans_huge(pmd) && !pmd_devmap(pmd))) {
 		pte_free(dst_mm, pgtable);
 		goto out_unlock;
 	}
@@ -1046,17 +1046,20 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		goto out_unlock;
 	}
 
-	src_page = pmd_page(pmd);
-	VM_BUG_ON_PAGE(!PageHead(src_page), src_page);
-	get_page(src_page);
-	page_dup_rmap(src_page, true);
-	add_mm_counter(dst_mm, MM_ANONPAGES, HPAGE_PMD_NR);
+	if (pmd_trans_huge(pmd)) {
+		/* thp accounting separate from pmd_devmap accounting */
+		src_page = pmd_page(pmd);
+		VM_BUG_ON_PAGE(!PageHead(src_page), src_page);
+		get_page(src_page);
+		page_dup_rmap(src_page, true);
+		add_mm_counter(dst_mm, MM_ANONPAGES, HPAGE_PMD_NR);
+		atomic_long_inc(&dst_mm->nr_ptes);
+		pgtable_trans_huge_deposit(dst_mm, dst_pmd, pgtable);
+	}
 
 	pmdp_set_wrprotect(src_mm, addr, src_pmd);
 	pmd = pmd_mkold(pmd_wrprotect(pmd));
-	pgtable_trans_huge_deposit(dst_mm, dst_pmd, pgtable);
 	set_pmd_at(dst_mm, addr, dst_pmd, pmd);
-	atomic_long_inc(&dst_mm->nr_ptes);
 
 	ret = 0;
 out_unlock:
@@ -1673,7 +1676,7 @@ bool __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
 		spinlock_t **ptl)
 {
 	*ptl = pmd_lock(vma->vm_mm, pmd);
-	if (likely(pmd_trans_huge(*pmd)))
+	if (likely(pmd_trans_huge(*pmd) || pmd_devmap(*pmd)))
 		return true;
 	spin_unlock(*ptl);
 	return false;
@@ -2790,7 +2793,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	VM_BUG_ON(haddr & ~HPAGE_PMD_MASK);
 	VM_BUG_ON_VMA(vma->vm_start > haddr, vma);
 	VM_BUG_ON_VMA(vma->vm_end < haddr + HPAGE_PMD_SIZE, vma);
-	VM_BUG_ON(!pmd_trans_huge(*pmd));
+	VM_BUG_ON(!pmd_trans_huge(*pmd) && !pmd_devmap(*pmd));
 
 	count_vm_event(THP_SPLIT_PMD);
 
@@ -2900,11 +2903,13 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 
 	mmu_notifier_invalidate_range_start(mm, haddr, haddr + HPAGE_PMD_SIZE);
 	ptl = pmd_lock(mm, pmd);
-	if (unlikely(!pmd_trans_huge(*pmd)))
+	if (unlikely(!pmd_trans_huge(*pmd) && !pmd_devmap(*pmd)))
 		goto out;
-	page = pmd_page(*pmd);
 	__split_huge_pmd_locked(vma, pmd, haddr, false);
-	if (PageMlocked(page))
+
+	if (pmd_trans_huge(*pmd))
+		page = pmd_page(*pmd);
+	if (page && PageMlocked(page))
 		get_page(page);
 	else
 		page = NULL;
@@ -2937,7 +2942,7 @@ static void split_huge_pmd_address(struct vm_area_struct *vma,
 		return;
 
 	pmd = pmd_offset(pud, address);
-	if (!pmd_present(*pmd) || !pmd_trans_huge(*pmd))
+	if (!pmd_present(*pmd) || (!pmd_trans_huge(*pmd) && !pmd_devmap(*pmd)))
 		return;
 	/*
 	 * Caller holds the mmap_sem write mode, so a huge pmd cannot
diff --git a/mm/memory.c b/mm/memory.c
index 42a812d3c3af..0b8a42e15610 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -949,7 +949,7 @@ static inline int copy_pmd_range(struct mm_struct *dst_mm, struct mm_struct *src
 	src_pmd = pmd_offset(src_pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
-		if (pmd_trans_huge(*src_pmd)) {
+		if (pmd_trans_huge(*src_pmd) || pmd_devmap(*src_pmd)) {
 			int err;
 			VM_BUG_ON(next-addr != HPAGE_PMD_SIZE);
 			err = copy_huge_pmd(dst_mm, src_mm,
@@ -1176,7 +1176,7 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
 	pmd = pmd_offset(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
-		if (pmd_trans_huge(*pmd)) {
+		if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
 			if (next - addr != HPAGE_PMD_SIZE) {
 #ifdef CONFIG_DEBUG_VM
 				if (!rwsem_is_locked(&tlb->mm->mmap_sem)) {
@@ -3357,7 +3357,7 @@ static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		int ret;
 
 		barrier();
-		if (pmd_trans_huge(orig_pmd)) {
+		if (pmd_trans_huge(orig_pmd) || pmd_devmap(orig_pmd)) {
 			unsigned int dirty = flags & FAULT_FLAG_WRITE;
 
 			if (pmd_protnone(orig_pmd))
@@ -3386,7 +3386,7 @@ static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	    unlikely(__pte_alloc(mm, vma, pmd, address)))
 		return VM_FAULT_OOM;
 	/* if an huge pmd materialized from under us just retry later */
-	if (unlikely(pmd_trans_huge(*pmd)))
+	if (unlikely(pmd_trans_huge(*pmd) || pmd_devmap(*pmd)))
 		return 0;
 	/*
 	 * A regular pmd is established and it can't morph into a huge pmd
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 9c1445dc8a4c..732e07baf76c 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -149,7 +149,8 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		unsigned long this_pages;
 
 		next = pmd_addr_end(addr, end);
-		if (!pmd_trans_huge(*pmd) && pmd_none_or_clear_bad(pmd))
+		if (!pmd_trans_huge(*pmd) && !pmd_devmap(*pmd)
+				&& pmd_none_or_clear_bad(pmd))
 			continue;
 
 		/* invoke the mmu notifier if the pmd is populated */
@@ -158,7 +159,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 			mmu_notifier_invalidate_range_start(mm, mni_start, end);
 		}
 
-		if (pmd_trans_huge(*pmd)) {
+		if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
 			if (next - addr != HPAGE_PMD_SIZE)
 				split_huge_pmd(vma, pmd, addr);
 			else {
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index c311a2ec6fea..9d4767698a1c 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -132,7 +132,7 @@ pmd_t pmdp_huge_clear_flush(struct vm_area_struct *vma, unsigned long address,
 {
 	pmd_t pmd;
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
-	VM_BUG_ON(!pmd_trans_huge(*pmdp));
+	VM_BUG_ON(!pmd_trans_huge(*pmdp) && !pmd_devmap(*pmdp));
 	pmd = pmdp_huge_get_and_clear(vma->vm_mm, address, pmdp);
 	flush_pmd_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
 	return pmd;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
