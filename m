Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5CEFC6B007D
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 14:16:50 -0500 (EST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 10 of 28] add pmd mangling functions to x86
Message-Id: <a77787d44f25abf69338.1261076413@v2.random>
In-Reply-To: <patchbomb.1261076403@v2.random>
References: <patchbomb.1261076403@v2.random>
Date: Thu, 17 Dec 2009 19:00:13 -0000
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Add needed pmd mangling functions with simmetry with their pte counterparts.
pmdp_freeze_flush is the only exception only present on the pmd side and it's
needed to serialize the VM against split_huge_page, it simply atomically clears
the present bit in the same way pmdp_clear_flush_young atomically clears the
accessed bit (and both need to flush the tlb to make it effective, which is
mandatory to happen synchronously for pmdp_freeze_flush).

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -95,11 +95,21 @@ static inline int pte_young(pte_t pte)
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
 }
 
+static inline int pmd_write(pmd_t pmd)
+{
+	return pmd_flags(pmd) & _PAGE_RW;
+}
+
 static inline int pte_file(pte_t pte)
 {
 	return pte_flags(pte) & _PAGE_FILE;
@@ -150,6 +160,13 @@ static inline pte_t pte_set_flags(pte_t 
 	return native_make_pte(v | set);
 }
 
+static inline pmd_t pmd_set_flags(pmd_t pmd, pmdval_t set)
+{
+	pmdval_t v = native_pmd_val(pmd);
+
+	return native_make_pmd(v | set);
+}
+
 static inline pte_t pte_clear_flags(pte_t pte, pteval_t clear)
 {
 	pteval_t v = native_pte_val(pte);
@@ -157,6 +174,13 @@ static inline pte_t pte_clear_flags(pte_
 	return native_make_pte(v & ~clear);
 }
 
+static inline pmd_t pmd_clear_flags(pmd_t pmd, pmdval_t clear)
+{
+	pmdval_t v = native_pmd_val(pmd);
+
+	return native_make_pmd(v & ~clear);
+}
+
 static inline pte_t pte_mkclean(pte_t pte)
 {
 	return pte_clear_flags(pte, _PAGE_DIRTY);
@@ -167,11 +191,21 @@ static inline pte_t pte_mkold(pte_t pte)
 	return pte_clear_flags(pte, _PAGE_ACCESSED);
 }
 
+static inline pmd_t pmd_mkold(pmd_t pmd)
+{
+	return pmd_clear_flags(pmd, _PAGE_ACCESSED);
+}
+
 static inline pte_t pte_wrprotect(pte_t pte)
 {
 	return pte_clear_flags(pte, _PAGE_RW);
 }
 
+static inline pmd_t pmd_wrprotect(pmd_t pmd)
+{
+	return pmd_clear_flags(pmd, _PAGE_RW);
+}
+
 static inline pte_t pte_mkexec(pte_t pte)
 {
 	return pte_clear_flags(pte, _PAGE_NX);
@@ -182,16 +216,36 @@ static inline pte_t pte_mkdirty(pte_t pt
 	return pte_set_flags(pte, _PAGE_DIRTY);
 }
 
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
 static inline pte_t pte_mkyoung(pte_t pte)
 {
 	return pte_set_flags(pte, _PAGE_ACCESSED);
 }
 
+static inline pmd_t pmd_mkyoung(pmd_t pmd)
+{
+	return pmd_set_flags(pmd, _PAGE_ACCESSED);
+}
+
 static inline pte_t pte_mkwrite(pte_t pte)
 {
 	return pte_set_flags(pte, _PAGE_RW);
 }
 
+static inline pmd_t pmd_mkwrite(pmd_t pmd)
+{
+	return pmd_set_flags(pmd, _PAGE_RW);
+}
+
 static inline pte_t pte_mkhuge(pte_t pte)
 {
 	return pte_set_flags(pte, _PAGE_PSE);
@@ -320,6 +374,11 @@ static inline int pte_same(pte_t a, pte_
 	return a.pte == b.pte;
 }
 
+static inline int pmd_same(pmd_t a, pmd_t b)
+{
+	return a.pmd == b.pmd;
+}
+
 static inline int pte_present(pte_t a)
 {
 	return pte_flags(a) & (_PAGE_PRESENT | _PAGE_PROTNONE);
@@ -351,7 +410,7 @@ static inline unsigned long pmd_page_vad
  * Currently stuck as a macro due to indirect forward reference to
  * linux/mmzone.h's __section_mem_map_addr() definition:
  */
-#define pmd_page(pmd)	pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT)
+#define pmd_page(pmd)	pfn_to_page((pmd_val(pmd) & PTE_PFN_MASK) >> PAGE_SHIFT)
 
 /*
  * the pmd page can be thought of an array like this: pmd_t[PTRS_PER_PMD]
@@ -372,6 +431,7 @@ static inline unsigned long pmd_index(un
  * to linux/mm.h:page_to_nid())
  */
 #define mk_pte(page, pgprot)   pfn_pte(page_to_pfn(page), (pgprot))
+#define mk_pmd(page, pgprot)   pfn_pmd(page_to_pfn(page), (pgprot))
 
 /*
  * the pte page can be thought of an array like this: pte_t[PTRS_PER_PTE]
@@ -568,14 +628,21 @@ struct vm_area_struct;
 extern int ptep_set_access_flags(struct vm_area_struct *vma,
 				 unsigned long address, pte_t *ptep,
 				 pte_t entry, int dirty);
+extern int pmdp_set_access_flags(struct vm_area_struct *vma,
+				 unsigned long address, pmd_t *pmdp,
+				 pmd_t entry, int dirty);
 
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
 extern int ptep_test_and_clear_young(struct vm_area_struct *vma,
 				     unsigned long addr, pte_t *ptep);
+extern int pmdp_test_and_clear_young(struct vm_area_struct *vma,
+				     unsigned long addr, pmd_t *pmdp);
 
 #define __HAVE_ARCH_PTEP_CLEAR_YOUNG_FLUSH
 extern int ptep_clear_flush_young(struct vm_area_struct *vma,
 				  unsigned long address, pte_t *ptep);
+extern int pmdp_clear_flush_young(struct vm_area_struct *vma,
+				  unsigned long address, pmd_t *pmdp);
 
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
 static inline pte_t ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
@@ -586,6 +653,14 @@ static inline pte_t ptep_get_and_clear(s
 	return pte;
 }
 
+static inline pmd_t pmdp_get_and_clear(struct mm_struct *mm, unsigned long addr,
+				       pmd_t *pmdp)
+{
+	pmd_t pmd = native_pmdp_get_and_clear(pmdp);
+	pmd_update(mm, addr, pmdp);
+	return pmd;
+}
+
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR_FULL
 static inline pte_t ptep_get_and_clear_full(struct mm_struct *mm,
 					    unsigned long addr, pte_t *ptep,
@@ -612,6 +687,16 @@ static inline void ptep_set_wrprotect(st
 	pte_update(mm, addr, ptep);
 }
 
+static inline void pmdp_set_wrprotect(struct mm_struct *mm,
+				      unsigned long addr, pmd_t *pmdp)
+{
+	clear_bit(_PAGE_BIT_RW, (unsigned long *)&pmdp->pmd);
+	pmd_update(mm, addr, pmd);
+}
+
+extern void pmdp_splitting_flush(struct vm_area_struct *vma,
+				 unsigned long addr, pmd_t *pmdp);
+
 /*
  * clone_pgd_range(pgd_t *dst, pgd_t *src, int count);
  *
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -71,6 +71,18 @@ static inline pte_t native_ptep_get_and_
 	return ret;
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
 
 static inline void native_set_pmd(pmd_t *pmdp, pmd_t pmd)
 {
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -288,6 +288,23 @@ int ptep_set_access_flags(struct vm_area
 	return changed;
 }
 
+int pmdp_set_access_flags(struct vm_area_struct *vma,
+			  unsigned long address, pmd_t *pmdp,
+			  pmd_t entry, int dirty)
+{
+	int changed = !pmd_same(*pmdp, entry);
+
+	VM_BUG_ON(address & ~HPAGE_MASK);
+
+	if (changed && dirty) {
+		*pmdp = entry;
+		pmd_update_defer(vma->vm_mm, address, pmdp);
+		flush_tlb_range(vma, address, address + HPAGE_SIZE);
+	}
+
+	return changed;
+}
+
 int ptep_test_and_clear_young(struct vm_area_struct *vma,
 			      unsigned long addr, pte_t *ptep)
 {
@@ -303,6 +320,21 @@ int ptep_test_and_clear_young(struct vm_
 	return ret;
 }
 
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
+
 int ptep_clear_flush_young(struct vm_area_struct *vma,
 			   unsigned long address, pte_t *ptep)
 {
@@ -315,6 +347,34 @@ int ptep_clear_flush_young(struct vm_are
 	return young;
 }
 
+int pmdp_clear_flush_young(struct vm_area_struct *vma,
+			   unsigned long address, pmd_t *pmdp)
+{
+	int young;
+
+	VM_BUG_ON(address & ~HPAGE_MASK);
+
+	young = pmdp_test_and_clear_young(vma, address, pmdp);
+	if (young)
+		flush_tlb_range(vma, address, address + HPAGE_SIZE);
+
+	return young;
+}
+
+void pmdp_splitting_flush(struct vm_area_struct *vma,
+			  unsigned long address, pmd_t *pmdp)
+{
+	int set;
+	VM_BUG_ON(address & ~HPAGE_MASK);
+	set = !test_and_set_bit(_PAGE_BIT_SPLITTING,
+				(unsigned long *)&pmdp->pmd);
+	if (set) {
+		pmd_update(vma->vm_mm, address, pmdp);
+		/* need tlb flush only to serialize against gup-fast */
+		flush_tlb_range(vma, address, address + HPAGE_SIZE);
+	}
+}
+
 /**
  * reserve_top_address - reserves a hole in the top of kernel address space
  * @reserve - size of hole to reserve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
