Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1E3338D0002
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 11:30:14 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 18 of 66] add pmd mangling functions to x86
Message-Id: <c681aaa016f2bd9ce393.1288798073@v2.random>
In-Reply-To: <patchbomb.1288798055@v2.random>
References: <patchbomb.1288798055@v2.random>
Date: Wed, 03 Nov 2010 16:27:53 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
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

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -302,15 +302,15 @@ pmd_t *populate_extra_pmd(unsigned long 
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
@@ -353,7 +353,7 @@ static inline unsigned long pmd_page_vad
  * Currently stuck as a macro due to indirect forward reference to
  * linux/mmzone.h's __section_mem_map_addr() definition:
  */
-#define pmd_page(pmd)	pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT)
+#define pmd_page(pmd)	pfn_to_page((pmd_val(pmd) & PTE_PFN_MASK) >> PAGE_SHIFT)
 
 /*
  * the pmd page can be thought of an array like this: pmd_t[PTRS_PER_PMD]
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -59,6 +59,16 @@ static inline void native_set_pte_atomic
 	native_set_pte(ptep, pte);
 }
 
+static inline void native_set_pmd(pmd_t *pmdp, pmd_t pmd)
+{
+	*pmdp = pmd;
+}
+
+static inline void native_pmd_clear(pmd_t *pmd)
+{
+	native_set_pmd(pmd, native_make_pmd(0));
+}
+
 static inline pte_t native_ptep_get_and_clear(pte_t *xp)
 {
 #ifdef CONFIG_SMP
@@ -72,14 +82,17 @@ static inline pte_t native_ptep_get_and_
 #endif
 }
 
-static inline void native_set_pmd(pmd_t *pmdp, pmd_t pmd)
+static inline pmd_t native_pmdp_get_and_clear(pmd_t *xp)
 {
-	*pmdp = pmd;
-}
-
-static inline void native_pmd_clear(pmd_t *pmd)
-{
-	native_set_pmd(pmd, native_make_pmd(0));
+#ifdef CONFIG_SMP
+	return native_make_pmd(xchg(&xp->pmd, 0));
+#else
+	/* native_local_pmdp_get_and_clear,
+	   but duplicated because of cyclic dependency */
+	pmd_t ret = *xp;
+	native_pmd_clear(xp);
+	return ret;
+#endif
 }
 
 static inline void native_set_pud(pud_t *pudp, pud_t pud)
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
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -320,6 +320,25 @@ int ptep_set_access_flags(struct vm_area
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
@@ -335,6 +354,23 @@ int ptep_test_and_clear_young(struct vm_
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
@@ -347,6 +383,36 @@ int ptep_clear_flush_young(struct vm_are
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
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
