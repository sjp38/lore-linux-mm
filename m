Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4F6506B0083
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:05 -0500 (EST)
Received: from int-mx08.intmail.prod.int.phx2.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o1QK93sc027994
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:03 -0500
Message-Id: <20100226200901.223389291@redhat.com>
Date: Fri, 26 Feb 2010 21:04:48 +0100
From: aarcange@redhat.com
Subject: [patch 15/35] add pmd mangling functions to x86
References: <20100226200433.516502198@redhat.com>
Content-Disposition: inline; filename=pmd_mangling_x86
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Add needed pmd mangling functions with simmetry with their pte counterparts.
pmdp_freeze_flush is the only exception only present on the pmd side and it's
needed to serialize the VM against split_huge_page, it simply atomically clears
the present bit in the same way pmdp_clear_flush_young atomically clears the
accessed bit (and both need to flush the tlb to make it effective, which is
mandatory to happen synchronously for pmdp_freeze_flush).

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
---
 arch/x86/include/asm/pgtable.h    |    8 +-
 arch/x86/include/asm/pgtable_64.h |  105 ++++++++++++++++++++++++++++++++++++++
 arch/x86/mm/pgtable.c             |   66 +++++++++++++++++++++++
 3 files changed, 175 insertions(+), 4 deletions(-)

--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -300,15 +300,15 @@ pmd_t *populate_extra_pmd(unsigned long 
 pte_t *populate_extra_pte(unsigned long vaddr);
 #endif	/* __ASSEMBLY__ */
 
+#ifndef __ASSEMBLY__
+#include <linux/mm_types.h>
+
 #ifdef CONFIG_X86_32
 # include "pgtable_32.h"
 #else
 # include "pgtable_64.h"
 #endif
 
-#ifndef __ASSEMBLY__
-#include <linux/mm_types.h>
-
 static inline int pte_none(pte_t pte)
 {
 	return !pte.pte;
@@ -351,7 +351,7 @@ static inline unsigned long pmd_page_vad
  * Currently stuck as a macro due to indirect forward reference to
  * linux/mmzone.h's __section_mem_map_addr() definition:
  */
-#define pmd_page(pmd)	pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT)
+#define pmd_page(pmd)	pfn_to_page((pmd_val(pmd) & PTE_PFN_MASK) >> PAGE_SHIFT)
 
 /*
  * the pmd page can be thought of an array like this: pmd_t[PTRS_PER_PMD]
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -72,6 +72,19 @@ static inline pte_t native_ptep_get_and_
 #endif
 }
 
+static inline pmd_t native_pmdp_get_and_clear(pmd_t *xp)
+{
+#ifdef CONFIG_SMP
+	return native_make_pmd(xchg(&xp->pmd, 0));
+#else
+	/* native_local_pmdp_get_and_clear,
+	   but duplicated because of cyclic dependency */
+	pmd_t ret = *xp;
+	native_pmd_clear(NULL, 0, xp);
+	return ret;
+#endif
+}
+
 static inline void native_set_pmd(pmd_t *pmdp, pmd_t pmd)
 {
 	*pmdp = pmd;
@@ -181,6 +194,98 @@ static inline int pmd_trans_huge(pmd_t p
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
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
+	clear_bit(_PAGE_BIT_RW, (unsigned long *)&pmdp->pmd);
+	pmd_update(mm, addr, pmdp);
+}
+
+static inline int pmd_young(pmd_t pmd)
+{
+	return pmd_flags(pmd) & _PAGE_ACCESSED;
+}
+
+static inline pmd_t pmd_set_flags(pmd_t pmd, pmdval_t set)
+{
+	pmdval_t v = native_pmd_val(pmd);
+
+	return native_make_pmd(v | set);
+}
+
+static inline pmd_t pmd_clear_flags(pmd_t pmd, pmdval_t clear)
+{
+	pmdval_t v = native_pmd_val(pmd);
+
+	return native_make_pmd(v & ~clear);
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
 #endif /* !__ASSEMBLY__ */
 
 #endif /* _ASM_X86_PGTABLE_64_H */
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -288,6 +288,25 @@ int ptep_set_access_flags(struct vm_area
 	return changed;
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+int pmdp_set_access_flags(struct vm_area_struct *vma,
+			  unsigned long address, pmd_t *pmdp,
+			  pmd_t entry, int dirty)
+{
+	int changed = !pmd_same(*pmdp, entry);
+
+	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+
+	if (changed && dirty) {
+		*pmdp = entry;
+		pmd_update_defer(vma->vm_mm, address, pmdp);
+		flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
+	}
+
+	return changed;
+}
+#endif
+
 int ptep_test_and_clear_young(struct vm_area_struct *vma,
 			      unsigned long addr, pte_t *ptep)
 {
@@ -303,6 +322,23 @@ int ptep_test_and_clear_young(struct vm_
 	return ret;
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+int pmdp_test_and_clear_young(struct vm_area_struct *vma,
+			      unsigned long addr, pmd_t *pmdp)
+{
+	int ret = 0;
+
+	if (pmd_young(*pmdp))
+		ret = test_and_clear_bit(_PAGE_BIT_ACCESSED,
+					 (unsigned long *) &pmdp->pmd);
+
+	if (ret)
+		pmd_update(vma->vm_mm, addr, pmdp);
+
+	return ret;
+}
+#endif
+
 int ptep_clear_flush_young(struct vm_area_struct *vma,
 			   unsigned long address, pte_t *ptep)
 {
@@ -315,6 +351,36 @@ int ptep_clear_flush_young(struct vm_are
 	return young;
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+int pmdp_clear_flush_young(struct vm_area_struct *vma,
+			   unsigned long address, pmd_t *pmdp)
+{
+	int young;
+
+	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+
+	young = pmdp_test_and_clear_young(vma, address, pmdp);
+	if (young)
+		flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
+
+	return young;
+}
+
+void pmdp_splitting_flush(struct vm_area_struct *vma,
+			  unsigned long address, pmd_t *pmdp)
+{
+	int set;
+	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+	set = !test_and_set_bit(_PAGE_BIT_SPLITTING,
+				(unsigned long *)&pmdp->pmd);
+	if (set) {
+		pmd_update(vma->vm_mm, address, pmdp);
+		/* need tlb flush only to serialize against gup-fast */
+		flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
+	}
+}
+#endif
+
 /**
  * reserve_top_address - reserves a hole in the top of kernel address space
  * @reserve - size of hole to reserve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
