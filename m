Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id EE36D6B0257
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 00:09:12 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so177525535pab.0
        for <linux-mm@kvack.org>; Sun, 29 Nov 2015 21:09:12 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id b10si11156268pas.127.2015.11.29.21.09.12
        for <linux-mm@kvack.org>;
        Sun, 29 Nov 2015 21:09:12 -0800 (PST)
Subject: [RFC PATCH 2/5] mm, dax: dax-pmd vs thp-pmd vs hugetlbfs-pmd
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 29 Nov 2015 21:08:44 -0800
Message-ID: <20151130050844.18366.61858.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151130050833.18366.21963.stgit@dwillia2-desk3.jf.intel.com>
References: <20151130050833.18366.21963.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave@sr71.net>, toshi.kani@hp.com, linux-nvdimm@lists.01.org, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <willy@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
 arch/x86/include/asm/pgtable.h       |    2 +-
 include/linux/huge_mm.h              |    3 ++-
 mm/huge_memory.c                     |   23 +++++++++++++----------
 mm/memory.c                          |    8 ++++----
 6 files changed, 22 insertions(+), 16 deletions(-)

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
index 02096a5dec2a..d5747ada2a76 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -178,7 +178,7 @@ static inline int pmd_trans_splitting(pmd_t pmd)
 
 static inline int pmd_trans_huge(pmd_t pmd)
 {
-	return pmd_val(pmd) & _PAGE_PSE;
+	return (pmd_val(pmd) & (_PAGE_PSE|_PAGE_DEVMAP)) == _PAGE_PSE;
 }
 
 static inline int has_transparent_hugepage(void)
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index d218abedfeb9..9c9c1688889a 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -105,7 +105,8 @@ extern void __split_huge_page_pmd(struct vm_area_struct *vma,
 #define split_huge_page_pmd(__vma, __address, __pmd)			\
 	do {								\
 		pmd_t *____pmd = (__pmd);				\
-		if (unlikely(pmd_trans_huge(*____pmd)))			\
+		if (unlikely(pmd_trans_huge(*____pmd)			\
+					|| pmd_devmap(*____pmd)))	\
 			__split_huge_page_pmd(__vma, __address,		\
 					____pmd);			\
 	}  while (0)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 6b506df659ec..329cedf48b8a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -933,7 +933,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 
 	ret = -EAGAIN;
 	pmd = *src_pmd;
-	if (unlikely(!pmd_trans_huge(pmd))) {
+	if (unlikely(!pmd_trans_huge(pmd) && !pmd_devmap(pmd))) {
 		pte_free(dst_mm, pgtable);
 		goto out_unlock;
 	}
@@ -965,17 +965,20 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		wait_split_huge_page(vma->anon_vma, src_pmd); /* src_vma */
 		goto out;
 	}
-	src_page = pmd_page(pmd);
-	VM_BUG_ON_PAGE(!PageHead(src_page), src_page);
-	get_page(src_page);
-	page_dup_rmap(src_page);
-	add_mm_counter(dst_mm, MM_ANONPAGES, HPAGE_PMD_NR);
+	if (pmd_trans_huge(pmd)) {
+		/* thp accounting separate from pmd_devmap accounting */
+		src_page = pmd_page(pmd);
+		VM_BUG_ON_PAGE(!PageHead(src_page), src_page);
+		get_page(src_page);
+		page_dup_rmap(src_page);
+		add_mm_counter(dst_mm, MM_ANONPAGES, HPAGE_PMD_NR);
+		pgtable_trans_huge_deposit(dst_mm, dst_pmd, pgtable);
+		atomic_long_inc(&dst_mm->nr_ptes);
+	}
 
 	pmdp_set_wrprotect(src_mm, addr, src_pmd);
 	pmd = pmd_mkold(pmd_wrprotect(pmd));
-	pgtable_trans_huge_deposit(dst_mm, dst_pmd, pgtable);
 	set_pmd_at(dst_mm, addr, dst_pmd, pmd);
-	atomic_long_inc(&dst_mm->nr_ptes);
 
 	ret = 0;
 out_unlock:
@@ -1599,7 +1602,7 @@ int __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
 		spinlock_t **ptl)
 {
 	*ptl = pmd_lock(vma->vm_mm, pmd);
-	if (likely(pmd_trans_huge(*pmd))) {
+	if (likely(pmd_trans_huge(*pmd) || pmd_devmap(*pmd))) {
 		if (unlikely(pmd_trans_splitting(*pmd))) {
 			spin_unlock(*ptl);
 			wait_split_huge_page(vma->anon_vma, pmd);
@@ -2975,7 +2978,7 @@ void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long address,
 again:
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 	ptl = pmd_lock(mm, pmd);
-	if (unlikely(!pmd_trans_huge(*pmd)))
+	if (unlikely(!pmd_trans_huge(*pmd) && !pmd_devmap(*pmd)))
 		goto unlock;
 	if (vma_is_dax(vma)) {
 		pmd_t _pmd = pmdp_huge_clear_flush_notify(vma, haddr, pmd);
diff --git a/mm/memory.c b/mm/memory.c
index 6a34be836a3b..5b9c6bab80d1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -961,7 +961,7 @@ static inline int copy_pmd_range(struct mm_struct *dst_mm, struct mm_struct *src
 	src_pmd = pmd_offset(src_pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
-		if (pmd_trans_huge(*src_pmd)) {
+		if (pmd_trans_huge(*src_pmd) || pmd_devmap(*src_pmd)) {
 			int err;
 			VM_BUG_ON(next-addr != HPAGE_PMD_SIZE);
 			err = copy_huge_pmd(dst_mm, src_mm,
@@ -1193,7 +1193,7 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
 	pmd = pmd_offset(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
-		if (pmd_trans_huge(*pmd)) {
+		if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
 			if (next - addr != HPAGE_PMD_SIZE) {
 #ifdef CONFIG_DEBUG_VM
 				if (!rwsem_is_locked(&tlb->mm->mmap_sem)) {
@@ -3366,7 +3366,7 @@ static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		int ret;
 
 		barrier();
-		if (pmd_trans_huge(orig_pmd)) {
+		if (pmd_trans_huge(orig_pmd) || pmd_devmap(orig_pmd)) {
 			unsigned int dirty = flags & FAULT_FLAG_WRITE;
 
 			/*
@@ -3403,7 +3403,7 @@ static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	    unlikely(__pte_alloc(mm, vma, pmd, address)))
 		return VM_FAULT_OOM;
 	/* if an huge pmd materialized from under us just retry later */
-	if (unlikely(pmd_trans_huge(*pmd)))
+	if (unlikely(pmd_trans_huge(*pmd) || pmd_devmap(*pmd)))
 		return 0;
 	/*
 	 * A regular pmd is established and it can't morph into a huge pmd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
