Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id l63CADuX176964
	for <linux-mm@kvack.org>; Tue, 3 Jul 2007 12:10:13 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l63CADjT934132
	for <linux-mm@kvack.org>; Tue, 3 Jul 2007 14:10:13 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l63CAD5h019581
	for <linux-mm@kvack.org>; Tue, 3 Jul 2007 14:10:13 +0200
Message-Id: <20070703121228.707597951@de.ibm.com>
References: <20070703111822.418649776@de.ibm.com>
Date: Tue, 03 Jul 2007 13:18:25 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 3/5] remove ptep_test_and_clear_dirty and ptep_clear_flush_dirty.
Content-Disposition: inline; filename=003-ptep-clear-dirty.diff
Sender: owner-linux-mm@kvack.org
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, hugh@veritas.com, peterz@infradead.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

Nobody is using ptep_test_and_clear_dirty and ptep_clear_flush_dirty.
Remove the functions from all architectures.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 include/asm-frv/pgtable.h           |    8 --------
 include/asm-generic/pgtable.h       |   25 -------------------------
 include/asm-i386/pgtable.h          |   21 ---------------------
 include/asm-ia64/pgtable.h          |   17 -----------------
 include/asm-m32r/pgtable.h          |    6 ------
 include/asm-parisc/pgtable.h        |   16 ----------------
 include/asm-powerpc/pgtable-ppc32.h |    7 -------
 include/asm-powerpc/pgtable-ppc64.h |   31 -------------------------------
 include/asm-ppc/pgtable.h           |    7 -------
 include/asm-s390/pgtable.h          |   15 ---------------
 include/asm-x86_64/pgtable.h        |    8 --------
 include/asm-xtensa/pgtable.h        |   12 ------------
 12 files changed, 173 deletions(-)

diff -urpN linux-2.6/include/asm-frv/pgtable.h linux-2.6-patched/include/asm-frv/pgtable.h
--- linux-2.6/include/asm-frv/pgtable.h	2007-07-02 08:45:46.000000000 +0200
+++ linux-2.6-patched/include/asm-frv/pgtable.h	2007-07-03 12:56:49.000000000 +0200
@@ -394,13 +394,6 @@ static inline pte_t pte_mkdirty(pte_t pt
 static inline pte_t pte_mkyoung(pte_t pte)	{ (pte).pte |= _PAGE_ACCESSED; return pte; }
 static inline pte_t pte_mkwrite(pte_t pte)	{ (pte).pte &= ~_PAGE_WP; return pte; }
 
-static inline int ptep_test_and_clear_dirty(struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
-{
-	int i = test_and_clear_bit(_PAGE_BIT_DIRTY, ptep);
-	asm volatile("dcf %M0" :: "U"(*ptep));
-	return i;
-}
-
 static inline int ptep_test_and_clear_young(struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
 {
 	int i = test_and_clear_bit(_PAGE_BIT_ACCESSED, ptep);
@@ -510,7 +503,6 @@ static inline int pte_file(pte_t pte)
 		remap_pfn_range(vma, vaddr, pfn, size, prot)
 
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
-#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
 #define __HAVE_ARCH_PTEP_SET_WRPROTECT
 #define __HAVE_ARCH_PTE_SAME
diff -urpN linux-2.6/include/asm-generic/pgtable.h linux-2.6-patched/include/asm-generic/pgtable.h
--- linux-2.6/include/asm-generic/pgtable.h	2007-07-03 12:56:49.000000000 +0200
+++ linux-2.6-patched/include/asm-generic/pgtable.h	2007-07-03 12:56:49.000000000 +0200
@@ -49,31 +49,6 @@
 })
 #endif
 
-#ifndef __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
-#define ptep_test_and_clear_dirty(__vma, __address, __ptep)		\
-({									\
-	pte_t __pte = *__ptep;						\
-	int r = 1;							\
-	if (!pte_dirty(__pte))						\
-		r = 0;							\
-	else								\
-		set_pte_at((__vma)->vm_mm, (__address), (__ptep),	\
-			   pte_mkclean(__pte));				\
-	r;								\
-})
-#endif
-
-#ifndef __HAVE_ARCH_PTEP_CLEAR_DIRTY_FLUSH
-#define ptep_clear_flush_dirty(__vma, __address, __ptep)		\
-({									\
-	int __dirty;							\
-	__dirty = ptep_test_and_clear_dirty(__vma, __address, __ptep);	\
-	if (__dirty)							\
-		flush_tlb_page(__vma, __address);			\
-	__dirty;							\
-})
-#endif
-
 #ifndef __HAVE_ARCH_PTEP_GET_AND_CLEAR
 #define ptep_get_and_clear(__mm, __address, __ptep)			\
 ({									\
diff -urpN linux-2.6/include/asm-i386/pgtable.h linux-2.6-patched/include/asm-i386/pgtable.h
--- linux-2.6/include/asm-i386/pgtable.h	2007-07-03 12:56:49.000000000 +0200
+++ linux-2.6-patched/include/asm-i386/pgtable.h	2007-07-03 12:56:49.000000000 +0200
@@ -295,17 +295,6 @@ static inline pte_t native_local_ptep_ge
 	__changed;							\
 })
 
-#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
-#define ptep_test_and_clear_dirty(vma, addr, ptep) ({			\
-	int __ret = 0;							\
-	if (pte_dirty(*(ptep)))						\
-		__ret = test_and_clear_bit(_PAGE_BIT_DIRTY,		\
-						&(ptep)->pte_low);	\
-	if (__ret)							\
-		pte_update((vma)->vm_mm, addr, ptep);			\
-	__ret;								\
-})
-
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
 #define ptep_test_and_clear_young(vma, addr, ptep) ({			\
 	int __ret = 0;							\
@@ -317,16 +306,6 @@ static inline pte_t native_local_ptep_ge
 	__ret;								\
 })
 
-#define __HAVE_ARCH_PTEP_CLEAR_DIRTY_FLUSH
-#define ptep_clear_flush_dirty(vma, address, ptep)			\
-({									\
-	int __dirty;							\
-	__dirty = ptep_test_and_clear_dirty((vma), (address), (ptep));	\
-	if (__dirty)							\
-		flush_tlb_page(vma, address);				\
-	__dirty;							\
-})
-
 #define __HAVE_ARCH_PTEP_CLEAR_YOUNG_FLUSH
 #define ptep_clear_flush_young(vma, address, ptep)			\
 ({									\
diff -urpN linux-2.6/include/asm-ia64/pgtable.h linux-2.6-patched/include/asm-ia64/pgtable.h
--- linux-2.6/include/asm-ia64/pgtable.h	2007-07-03 12:56:49.000000000 +0200
+++ linux-2.6-patched/include/asm-ia64/pgtable.h	2007-07-03 12:56:49.000000000 +0200
@@ -398,22 +398,6 @@ ptep_test_and_clear_young (struct vm_are
 #endif
 }
 
-static inline int
-ptep_test_and_clear_dirty (struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
-{
-#ifdef CONFIG_SMP
-	if (!pte_dirty(*ptep))
-		return 0;
-	return test_and_clear_bit(_PAGE_D_BIT, ptep);
-#else
-	pte_t pte = *ptep;
-	if (!pte_dirty(pte))
-		return 0;
-	set_pte_at(vma->vm_mm, addr, ptep, pte_mkclean(pte));
-	return 1;
-#endif
-}
-
 static inline pte_t
 ptep_get_and_clear(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
 {
@@ -593,7 +577,6 @@ extern void lazy_mmu_prot_update (pte_t 
 #endif
 
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
-#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
 #define __HAVE_ARCH_PTEP_SET_WRPROTECT
 #define __HAVE_ARCH_PTE_SAME
diff -urpN linux-2.6/include/asm-m32r/pgtable.h linux-2.6-patched/include/asm-m32r/pgtable.h
--- linux-2.6/include/asm-m32r/pgtable.h	2007-05-12 20:16:10.000000000 +0200
+++ linux-2.6-patched/include/asm-m32r/pgtable.h	2007-07-03 12:56:49.000000000 +0200
@@ -284,11 +284,6 @@ static inline pte_t pte_mkwrite(pte_t pt
 	return pte;
 }
 
-static inline  int ptep_test_and_clear_dirty(struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
-{
-	return test_and_clear_bit(_PAGE_BIT_DIRTY, ptep);
-}
-
 static inline  int ptep_test_and_clear_young(struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
 {
 	return test_and_clear_bit(_PAGE_BIT_ACCESSED, ptep);
@@ -382,7 +377,6 @@ static inline void pmd_set(pmd_t * pmdp,
 		remap_pfn_range(vma, vaddr, pfn, size, prot)
 
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
-#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
 #define __HAVE_ARCH_PTEP_SET_WRPROTECT
 #define __HAVE_ARCH_PTE_SAME
diff -urpN linux-2.6/include/asm-parisc/pgtable.h linux-2.6-patched/include/asm-parisc/pgtable.h
--- linux-2.6/include/asm-parisc/pgtable.h	2007-05-09 09:58:15.000000000 +0200
+++ linux-2.6-patched/include/asm-parisc/pgtable.h	2007-07-03 12:56:49.000000000 +0200
@@ -451,21 +451,6 @@ static inline int ptep_test_and_clear_yo
 #endif
 }
 
-static inline int ptep_test_and_clear_dirty(struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
-{
-#ifdef CONFIG_SMP
-	if (!pte_dirty(*ptep))
-		return 0;
-	return test_and_clear_bit(xlate_pabit(_PAGE_DIRTY_BIT), &pte_val(*ptep));
-#else
-	pte_t pte = *ptep;
-	if (!pte_dirty(pte))
-		return 0;
-	set_pte_at(vma->vm_mm, addr, ptep, pte_mkclean(pte));
-	return 1;
-#endif
-}
-
 extern spinlock_t pa_dbit_lock;
 
 struct mm_struct;
@@ -533,7 +518,6 @@ static inline void ptep_set_wrprotect(st
 #define HAVE_ARCH_UNMAPPED_AREA
 
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
-#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
 #define __HAVE_ARCH_PTEP_SET_WRPROTECT
 #define __HAVE_ARCH_PTE_SAME
diff -urpN linux-2.6/include/asm-powerpc/pgtable-ppc32.h linux-2.6-patched/include/asm-powerpc/pgtable-ppc32.h
--- linux-2.6/include/asm-powerpc/pgtable-ppc32.h	2007-06-18 09:43:22.000000000 +0200
+++ linux-2.6-patched/include/asm-powerpc/pgtable-ppc32.h	2007-07-03 12:56:49.000000000 +0200
@@ -643,13 +643,6 @@ static inline int __ptep_test_and_clear_
 #define ptep_test_and_clear_young(__vma, __addr, __ptep) \
 	__ptep_test_and_clear_young((__vma)->vm_mm->context.id, __addr, __ptep)
 
-#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
-static inline int ptep_test_and_clear_dirty(struct vm_area_struct *vma,
-					    unsigned long addr, pte_t *ptep)
-{
-	return (pte_update(ptep, (_PAGE_DIRTY | _PAGE_HWWRITE), 0) & _PAGE_DIRTY) != 0;
-}
-
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
 static inline pte_t ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
 				       pte_t *ptep)
diff -urpN linux-2.6/include/asm-powerpc/pgtable-ppc64.h linux-2.6-patched/include/asm-powerpc/pgtable-ppc64.h
--- linux-2.6/include/asm-powerpc/pgtable-ppc64.h	2007-06-18 09:43:22.000000000 +0200
+++ linux-2.6-patched/include/asm-powerpc/pgtable-ppc64.h	2007-07-03 12:56:49.000000000 +0200
@@ -307,29 +307,6 @@ static inline int __ptep_test_and_clear_
 	__r;								   \
 })
 
-/*
- * On RW/DIRTY bit transitions we can avoid flushing the hpte. For the
- * moment we always flush but we need to fix hpte_update and test if the
- * optimisation is worth it.
- */
-static inline int __ptep_test_and_clear_dirty(struct mm_struct *mm,
-					      unsigned long addr, pte_t *ptep)
-{
-	unsigned long old;
-
-       	if ((pte_val(*ptep) & _PAGE_DIRTY) == 0)
-		return 0;
-	old = pte_update(mm, addr, ptep, _PAGE_DIRTY, 0);
-	return (old & _PAGE_DIRTY) != 0;
-}
-#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
-#define ptep_test_and_clear_dirty(__vma, __addr, __ptep)		   \
-({									   \
-	int __r;							   \
-	__r = __ptep_test_and_clear_dirty((__vma)->vm_mm, __addr, __ptep); \
-	__r;								   \
-})
-
 #define __HAVE_ARCH_PTEP_SET_WRPROTECT
 static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr,
 				      pte_t *ptep)
@@ -357,14 +334,6 @@ static inline void ptep_set_wrprotect(st
 	__young;							\
 })
 
-#define __HAVE_ARCH_PTEP_CLEAR_DIRTY_FLUSH
-#define ptep_clear_flush_dirty(__vma, __address, __ptep)		\
-({									\
-	int __dirty = __ptep_test_and_clear_dirty((__vma)->vm_mm, __address, \
-						  __ptep); 		\
-	__dirty;							\
-})
-
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
 static inline pte_t ptep_get_and_clear(struct mm_struct *mm,
 				       unsigned long addr, pte_t *ptep)
diff -urpN linux-2.6/include/asm-ppc/pgtable.h linux-2.6-patched/include/asm-ppc/pgtable.h
--- linux-2.6/include/asm-ppc/pgtable.h	2007-06-18 09:43:22.000000000 +0200
+++ linux-2.6-patched/include/asm-ppc/pgtable.h	2007-07-03 12:56:49.000000000 +0200
@@ -664,13 +664,6 @@ static inline int __ptep_test_and_clear_
 #define ptep_test_and_clear_young(__vma, __addr, __ptep) \
 	__ptep_test_and_clear_young((__vma)->vm_mm->context.id, __addr, __ptep)
 
-#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
-static inline int ptep_test_and_clear_dirty(struct vm_area_struct *vma,
-					    unsigned long addr, pte_t *ptep)
-{
-	return (pte_update(ptep, (_PAGE_DIRTY | _PAGE_HWWRITE), 0) & _PAGE_DIRTY) != 0;
-}
-
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
 static inline pte_t ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
 				       pte_t *ptep)
diff -urpN linux-2.6/include/asm-s390/pgtable.h linux-2.6-patched/include/asm-s390/pgtable.h
--- linux-2.6/include/asm-s390/pgtable.h	2007-07-03 12:56:49.000000000 +0200
+++ linux-2.6-patched/include/asm-s390/pgtable.h	2007-07-03 12:56:49.000000000 +0200
@@ -677,19 +677,6 @@ ptep_clear_flush_young(struct vm_area_st
 	return ptep_test_and_clear_young(vma, address, ptep);
 }
 
-static inline int ptep_test_and_clear_dirty(struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
-{
-	return 0;
-}
-
-static inline int
-ptep_clear_flush_dirty(struct vm_area_struct *vma,
-			unsigned long address, pte_t *ptep)
-{
-	/* No need to flush TLB; bits are in storage key */
-	return ptep_test_and_clear_dirty(vma, address, ptep);
-}
-
 static inline pte_t ptep_get_and_clear(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
 {
 	pte_t pte = *ptep;
@@ -947,8 +934,6 @@ extern void memmap_init(unsigned long, i
 #define __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
 #define __HAVE_ARCH_PTEP_CLEAR_YOUNG_FLUSH
-#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
-#define __HAVE_ARCH_PTEP_CLEAR_DIRTY_FLUSH
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
 #define __HAVE_ARCH_PTEP_CLEAR_FLUSH
 #define __HAVE_ARCH_PTEP_SET_WRPROTECT
diff -urpN linux-2.6/include/asm-x86_64/pgtable.h linux-2.6-patched/include/asm-x86_64/pgtable.h
--- linux-2.6/include/asm-x86_64/pgtable.h	2007-06-18 09:43:22.000000000 +0200
+++ linux-2.6-patched/include/asm-x86_64/pgtable.h	2007-07-03 12:56:49.000000000 +0200
@@ -290,13 +290,6 @@ static inline pte_t pte_clrhuge(pte_t pt
 
 struct vm_area_struct;
 
-static inline int ptep_test_and_clear_dirty(struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
-{
-	if (!pte_dirty(*ptep))
-		return 0;
-	return test_and_clear_bit(_PAGE_BIT_DIRTY, &ptep->pte);
-}
-
 static inline int ptep_test_and_clear_young(struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
 {
 	if (!pte_young(*ptep))
@@ -433,7 +426,6 @@ extern int kern_addr_valid(unsigned long
    (((o) & (1UL << (__VIRTUAL_MASK_SHIFT-1))) ? ((o) | (~__VIRTUAL_MASK)) : (o))
 
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
-#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR_FULL
 #define __HAVE_ARCH_PTEP_SET_WRPROTECT
diff -urpN linux-2.6/include/asm-xtensa/pgtable.h linux-2.6-patched/include/asm-xtensa/pgtable.h
--- linux-2.6/include/asm-xtensa/pgtable.h	2006-12-11 10:25:32.000000000 +0100
+++ linux-2.6-patched/include/asm-xtensa/pgtable.h	2007-07-03 12:56:49.000000000 +0200
@@ -270,17 +270,6 @@ ptep_test_and_clear_young(struct vm_area
 	return 1;
 }
 
-static inline int
-ptep_test_and_clear_dirty(struct vm_area_struct *vma, unsigned long addr,
-   			  pte_t *ptep)
-{
-	pte_t pte = *ptep;
-	if (!pte_dirty(pte))
-		return 0;
-	update_pte(ptep, pte_mkclean(pte));
-	return 1;
-}
-
 static inline pte_t
 ptep_get_and_clear(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
 {
@@ -421,7 +410,6 @@ typedef pte_t *pte_addr_t;
 #endif /* !defined (__ASSEMBLY__) */
 
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
-#define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
 #define __HAVE_ARCH_PTEP_SET_WRPROTECT
 #define __HAVE_ARCH_PTEP_MKDIRTY

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
