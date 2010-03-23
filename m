Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id F1D316B01B5
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 10:35:45 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: mincore and transparent huge pages
Date: Tue, 23 Mar 2010 15:34:57 +0100
Message-Id: <1269354902-18975-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


Hi,

I wanted to make mincore() handle huge pmds natively over the weekend
but I chose do beef up the code a bit first (1-4).

Andrew, 1-4 may have merit without transparent huge pages, so they
could go in independently.  They are based on Andrea's patches but the
only thing huge page in them is the split_huge_page_vma() call, so it
would be easy to rebase (I can do that).

Below is also an ugly hack I used to test transparent huge pages on my
32bit netbook.  The VM_ flags, oh, the VM_ flags!

	Hannes

diff --git a/arch/x86/include/asm/pgtable-2level.h b/arch/x86/include/asm/pgtable-2level.h
index 2334982..98391db 100644
--- a/arch/x86/include/asm/pgtable-2level.h
+++ b/arch/x86/include/asm/pgtable-2level.h
@@ -46,6 +46,15 @@ static inline pte_t native_ptep_get_and_clear(pte_t *xp)
 #define native_ptep_get_and_clear(xp) native_local_ptep_get_and_clear(xp)
 #endif
 
+#ifdef CONFIG_SMP
+static inline pmd_t native_pmdp_get_and_clear(pmd_t *xp)
+{
+	return __pmd(xchg((pmdval_t *)xp, 0));
+}
+#else
+#define native_pmdp_get_and_clear(xp) native_local_pmdp_get_and_clear(xp)
+#endif
+
 /*
  * Bits _PAGE_BIT_PRESENT, _PAGE_BIT_FILE and _PAGE_BIT_PROTNONE are taken,
  * split up the 29 bits of offset into this range:
diff --git a/arch/x86/include/asm/pgtable-3level.h b/arch/x86/include/asm/pgtable-3level.h
index 177b016..cc62f48 100644
--- a/arch/x86/include/asm/pgtable-3level.h
+++ b/arch/x86/include/asm/pgtable-3level.h
@@ -104,6 +104,29 @@ static inline pte_t native_ptep_get_and_clear(pte_t *ptep)
 #define native_ptep_get_and_clear(xp) native_local_ptep_get_and_clear(xp)
 #endif
 
+#ifdef CONFIG_SMP
+union split_pmd {
+	struct {
+		u32 pmd_low;
+		u32 pmd_high;
+	};
+	pmd_t pmd;
+};
+static inline pmd_t native_pmdp_get_and_clear(pmd_t *pmdp)
+{
+	union split_pmd res, *orig = (union pmd_parts *)pmdp;
+
+	/* xchg acts as a barrier before setting of the high bits */
+	res.pmd_low = xchg(&orig->pmd_low, 0);
+	res.pmd_high = orig->pmd_high;
+	orig->pmd_high = 0;
+
+	return res.pmd;
+}
+#else
+#define native_pmdp_get_and_clear(xp) native_local_pmdp_get_and_clear(xp)
+#endif
+
 /*
  * Bits 0, 6 and 7 are taken in the low part of the pte,
  * put the 32 bits of offset into the high part.
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index d26f1cf..59c4fdb 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -95,6 +95,11 @@ static inline int pte_young(pte_t pte)
 	return pte_flags(pte) & _PAGE_ACCESSED;
 }
 
+static inline int pmd_young(pmd_t pmd)
+{
+	return pmd_flags(pmd) & _PAGE_ACCESSED;
+}
+
 static inline int pte_write(pte_t pte)
 {
 	return pte_flags(pte) & _PAGE_RW;
@@ -143,6 +148,18 @@ static inline int pmd_large(pmd_t pte)
 		(_PAGE_PSE | _PAGE_PRESENT);
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static inline int pmd_trans_splitting(pmd_t pmd)
+{
+	return pmd_val(pmd) & _PAGE_SPLITTING;
+}
+
+static inline int pmd_trans_huge(pmd_t pmd)
+{
+	return pmd_val(pmd) & _PAGE_PSE;
+}
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+
 static inline pte_t pte_set_flags(pte_t pte, pteval_t set)
 {
 	pteval_t v = native_pte_val(pte);
@@ -217,6 +234,50 @@ static inline pte_t pte_mkspecial(pte_t pte)
 	return pte_set_flags(pte, _PAGE_SPECIAL);
 }
 
+static inline pmd_t pmd_set_flags(pmd_t pmd, pmdval_t set)
+{
+	pmdval_t v = native_pmd_val(pmd);
+
+	return __pmd(v | set);
+}
+
+static inline pmd_t pmd_clear_flags(pmd_t pmd, pmdval_t clear)
+{
+	pmdval_t v = native_pmd_val(pmd);
+
+	return __pmd(v & ~clear);
+}
+
+static inline pmd_t pmd_mkold(pmd_t pmd)
+{
+	return pmd_clear_flags(pmd, _PAGE_ACCESSED);
+}
+
+static inline pmd_t pmd_wrprotect(pmd_t pmd)
+{
+	return pmd_clear_flags(pmd, _PAGE_RW);
+}
+
+static inline pmd_t pmd_mkdirty(pmd_t pmd)
+{
+	return pmd_set_flags(pmd, _PAGE_DIRTY);
+}
+
+static inline pmd_t pmd_mkhuge(pmd_t pmd)
+{
+	return pmd_set_flags(pmd, _PAGE_PSE);
+}
+
+static inline pmd_t pmd_mkyoung(pmd_t pmd)
+{
+	return pmd_set_flags(pmd, _PAGE_ACCESSED);
+}
+
+static inline pmd_t pmd_mkwrite(pmd_t pmd)
+{
+	return pmd_set_flags(pmd, _PAGE_RW);
+}
+
 /*
  * Mask out unsupported bits in a present pgprot.  Non-present pgprots
  * can use those bits for other purposes, so leave them be.
@@ -525,6 +586,14 @@ static inline pte_t native_local_ptep_get_and_clear(pte_t *ptep)
 	return res;
 }
 
+static inline pmd_t native_local_pmdp_get_and_clear(pmd_t *pmdp)
+{
+	pmd_t res = *pmdp;
+
+	native_pmd_clear(pmdp);
+	return res;
+}
+
 static inline void native_set_pte_at(struct mm_struct *mm, unsigned long addr,
 				     pte_t *ptep , pte_t pte)
 {
@@ -612,6 +681,49 @@ static inline void ptep_set_wrprotect(struct mm_struct *mm,
 	pte_update(mm, addr, ptep);
 }
 
+#define mk_pmd(page, pgprot)   pfn_pmd(page_to_pfn(page), (pgprot))
+
+#define  __HAVE_ARCH_PMDP_SET_ACCESS_FLAGS
+extern int pmdp_set_access_flags(struct vm_area_struct *vma,
+				 unsigned long address, pmd_t *pmdp,
+				 pmd_t entry, int dirty);
+
+#define __HAVE_ARCH_PMDP_TEST_AND_CLEAR_YOUNG
+extern int pmdp_test_and_clear_young(struct vm_area_struct *vma,
+				     unsigned long addr, pmd_t *pmdp);
+
+#define __HAVE_ARCH_PMDP_CLEAR_YOUNG_FLUSH
+extern int pmdp_clear_flush_young(struct vm_area_struct *vma,
+				  unsigned long address, pmd_t *pmdp);
+
+
+#define __HAVE_ARCH_PMDP_SPLITTING_FLUSH
+extern void pmdp_splitting_flush(struct vm_area_struct *vma,
+				 unsigned long addr, pmd_t *pmdp);
+
+#define __HAVE_ARCH_PMD_WRITE
+static inline int pmd_write(pmd_t pmd)
+{
+	return pmd_flags(pmd) & _PAGE_RW;
+}
+
+#define __HAVE_ARCH_PMDP_GET_AND_CLEAR
+static inline pmd_t pmdp_get_and_clear(struct mm_struct *mm, unsigned long addr,
+				       pmd_t *pmdp)
+{
+	pmd_t pmd = native_pmdp_get_and_clear(pmdp);
+	pmd_update(mm, addr, pmdp);
+	return pmd;
+}
+
+#define __HAVE_ARCH_PMDP_SET_WRPROTECT
+static inline void pmdp_set_wrprotect(struct mm_struct *mm,
+				      unsigned long addr, pmd_t *pmdp)
+{
+	clear_bit(_PAGE_BIT_RW, (unsigned long *)pmdp);
+	pmd_update(mm, addr, pmdp);
+}
+
 /*
  * clone_pgd_range(pgd_t *dst, pgd_t *src, int count);
  *
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index b8b801d..5962bac 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -182,110 +182,6 @@ extern void cleanup_highmap(void);
 
 #define __HAVE_ARCH_PTE_SAME
 
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-static inline int pmd_trans_splitting(pmd_t pmd)
-{
-	return pmd_val(pmd) & _PAGE_SPLITTING;
-}
-
-static inline int pmd_trans_huge(pmd_t pmd)
-{
-	return pmd_val(pmd) & _PAGE_PSE;
-}
-#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
-
-#define mk_pmd(page, pgprot)   pfn_pmd(page_to_pfn(page), (pgprot))
-
-#define  __HAVE_ARCH_PMDP_SET_ACCESS_FLAGS
-extern int pmdp_set_access_flags(struct vm_area_struct *vma,
-				 unsigned long address, pmd_t *pmdp,
-				 pmd_t entry, int dirty);
-
-#define __HAVE_ARCH_PMDP_TEST_AND_CLEAR_YOUNG
-extern int pmdp_test_and_clear_young(struct vm_area_struct *vma,
-				     unsigned long addr, pmd_t *pmdp);
-
-#define __HAVE_ARCH_PMDP_CLEAR_YOUNG_FLUSH
-extern int pmdp_clear_flush_young(struct vm_area_struct *vma,
-				  unsigned long address, pmd_t *pmdp);
-
-
-#define __HAVE_ARCH_PMDP_SPLITTING_FLUSH
-extern void pmdp_splitting_flush(struct vm_area_struct *vma,
-				 unsigned long addr, pmd_t *pmdp);
-
-#define __HAVE_ARCH_PMD_WRITE
-static inline int pmd_write(pmd_t pmd)
-{
-	return pmd_flags(pmd) & _PAGE_RW;
-}
-
-#define __HAVE_ARCH_PMDP_GET_AND_CLEAR
-static inline pmd_t pmdp_get_and_clear(struct mm_struct *mm, unsigned long addr,
-				       pmd_t *pmdp)
-{
-	pmd_t pmd = native_pmdp_get_and_clear(pmdp);
-	pmd_update(mm, addr, pmdp);
-	return pmd;
-}
-
-#define __HAVE_ARCH_PMDP_SET_WRPROTECT
-static inline void pmdp_set_wrprotect(struct mm_struct *mm,
-				      unsigned long addr, pmd_t *pmdp)
-{
-	clear_bit(_PAGE_BIT_RW, (unsigned long *)&pmdp->pmd);
-	pmd_update(mm, addr, pmdp);
-}
-
-static inline int pmd_young(pmd_t pmd)
-{
-	return pmd_flags(pmd) & _PAGE_ACCESSED;
-}
-
-static inline pmd_t pmd_set_flags(pmd_t pmd, pmdval_t set)
-{
-	pmdval_t v = native_pmd_val(pmd);
-
-	return native_make_pmd(v | set);
-}
-
-static inline pmd_t pmd_clear_flags(pmd_t pmd, pmdval_t clear)
-{
-	pmdval_t v = native_pmd_val(pmd);
-
-	return native_make_pmd(v & ~clear);
-}
-
-static inline pmd_t pmd_mkold(pmd_t pmd)
-{
-	return pmd_clear_flags(pmd, _PAGE_ACCESSED);
-}
-
-static inline pmd_t pmd_wrprotect(pmd_t pmd)
-{
-	return pmd_clear_flags(pmd, _PAGE_RW);
-}
-
-static inline pmd_t pmd_mkdirty(pmd_t pmd)
-{
-	return pmd_set_flags(pmd, _PAGE_DIRTY);
-}
-
-static inline pmd_t pmd_mkhuge(pmd_t pmd)
-{
-	return pmd_set_flags(pmd, _PAGE_PSE);
-}
-
-static inline pmd_t pmd_mkyoung(pmd_t pmd)
-{
-	return pmd_set_flags(pmd, _PAGE_ACCESSED);
-}
-
-static inline pmd_t pmd_mkwrite(pmd_t pmd)
-{
-	return pmd_set_flags(pmd, _PAGE_RW);
-}
-
 #endif /* !__ASSEMBLY__ */
 
 #endif /* _ASM_X86_PGTABLE_64_H */
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index d360616..d4470f6 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -351,7 +351,7 @@ int pmdp_test_and_clear_young(struct vm_area_struct *vma,
 
 	if (pmd_young(*pmdp))
 		ret = test_and_clear_bit(_PAGE_BIT_ACCESSED,
-					 (unsigned long *) &pmdp->pmd);
+					 (unsigned long *)pmdp);
 
 	if (ret)
 		pmd_update(vma->vm_mm, addr, pmdp);
@@ -393,7 +393,7 @@ void pmdp_splitting_flush(struct vm_area_struct *vma,
 	int set;
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 	set = !test_and_set_bit(_PAGE_BIT_SPLITTING,
-				(unsigned long *)&pmdp->pmd);
+				(unsigned long *)pmdp);
 	if (set) {
 		pmd_update(vma->vm_mm, address, pmdp);
 		/* need tlb flush only to serialize against gup-fast */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 85fa92a..b6aec57 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -106,10 +106,11 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_MIXEDMAP	0x10000000	/* Can contain "struct page" and pure PFN pages */
 #define VM_SAO		0x20000000	/* Strong Access Ordering (powerpc) */
 #define VM_PFN_AT_MMAP	0x40000000	/* PFNMAP vma that is fully mapped at mmap time */
+#ifdef CONFIG_KSM
+#error no more VM_ flags
 #define VM_MERGEABLE	0x80000000	/* KSM may merge identical pages */
-#if BITS_PER_LONG > 32
-#define VM_HUGEPAGE	0x100000000UL	/* MADV_HUGEPAGE marked this vma */
 #endif
+#define VM_HUGEPAGE	0x80000000	/* MADV_HUGEPAGE marked this vma */
 
 #ifndef VM_STACK_DEFAULT_FLAGS		/* arch can override this */
 #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS
diff --git a/mm/Kconfig b/mm/Kconfig
index 2a771ef..89a7fe9 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -290,7 +290,7 @@ config NOMMU_INITIAL_TRIM_EXCESS
 
 config TRANSPARENT_HUGEPAGE
 	bool "Transparent Hugepage support" if EMBEDDED
-	depends on X86_64
+	depends on X86
 	default y
 	help
 	  Transparent Hugepages allows the kernel to use huge pages and

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
