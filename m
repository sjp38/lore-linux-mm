Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id D1DF36B000E
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 13:30:36 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id 78so226827818pfw.2
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 10:30:36 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id z9si64834888par.42.2016.01.05.10.30.35
        for <linux-mm@kvack.org>;
        Tue, 05 Jan 2016 10:30:35 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v2 6/8] x86: Add support for PUD-sized transparent hugepages
Date: Tue,  5 Jan 2016 13:30:08 -0500
Message-Id: <1452018610-26090-7-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1452018610-26090-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1452018610-26090-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

From: Matthew Wilcox <willy@linux.intel.com>

The x86-specific code needed to support the PUD uses in the transparent
hugepages code.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 arch/x86/Kconfig                      |  1 +
 arch/x86/include/asm/paravirt.h       | 11 ++++
 arch/x86/include/asm/paravirt_types.h |  2 +
 arch/x86/include/asm/pgtable.h        | 95 +++++++++++++++++++++++++++++++++++
 arch/x86/include/asm/pgtable_64.h     | 13 +++++
 arch/x86/kernel/paravirt.c            |  1 +
 arch/x86/mm/pgtable.c                 | 31 ++++++++++++
 7 files changed, 154 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index fd0c8ea..df99d21 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -89,6 +89,7 @@ config X86
 	select HAVE_ARCH_SOFT_DIRTY		if X86_64
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
+	select HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD if X86_64
 	select HAVE_BPF_JIT			if X86_64
 	select HAVE_CC_STACKPROTECTOR
 	select HAVE_CMPXCHG_DOUBLE
diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
index c261402..db4f274 100644
--- a/arch/x86/include/asm/paravirt.h
+++ b/arch/x86/include/asm/paravirt.h
@@ -479,6 +479,17 @@ static inline void set_pmd_at(struct mm_struct *mm, unsigned long addr,
 			    native_pmd_val(pmd));
 }
 
+static inline void set_pud_at(struct mm_struct *mm, unsigned long addr,
+			      pud_t *pudp, pud_t pud)
+{
+	if (sizeof(pudval_t) > sizeof(long))
+		/* 5 arg words */
+		pv_mmu_ops.set_pud_at(mm, addr, pudp, pud);
+	else
+		PVOP_VCALL4(pv_mmu_ops.set_pud_at, mm, addr, pudp,
+			    native_pud_val(pud));
+}
+
 static inline void set_pmd(pmd_t *pmdp, pmd_t pmd)
 {
 	pmdval_t val = native_pmd_val(pmd);
diff --git a/arch/x86/include/asm/paravirt_types.h b/arch/x86/include/asm/paravirt_types.h
index 2489d6a..261c203 100644
--- a/arch/x86/include/asm/paravirt_types.h
+++ b/arch/x86/include/asm/paravirt_types.h
@@ -247,6 +247,8 @@ struct pv_mmu_ops {
 	void (*set_pmd)(pmd_t *pmdp, pmd_t pmdval);
 	void (*set_pmd_at)(struct mm_struct *mm, unsigned long addr,
 			   pmd_t *pmdp, pmd_t pmdval);
+	void (*set_pud_at)(struct mm_struct *mm, unsigned long addr,
+			   pud_t *pudp, pud_t pudval);
 	void (*pte_update)(struct mm_struct *mm, unsigned long addr,
 			   pte_t *ptep);
 
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index c69f385..246bc5f 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -46,6 +46,7 @@ extern struct mm_struct *pgd_page_get_mm(struct page *page);
 #define set_pte(ptep, pte)		native_set_pte(ptep, pte)
 #define set_pte_at(mm, addr, ptep, pte)	native_set_pte_at(mm, addr, ptep, pte)
 #define set_pmd_at(mm, addr, pmdp, pmd)	native_set_pmd_at(mm, addr, pmdp, pmd)
+#define set_pud_at(mm, addr, pudp, pud)	native_set_pud_at(mm, addr, pudp, pud)
 
 #define set_pte_atomic(ptep, pte)					\
 	native_set_pte_atomic(ptep, pte)
@@ -114,6 +115,16 @@ static inline int pmd_young(pmd_t pmd)
 	return pmd_flags(pmd) & _PAGE_ACCESSED;
 }
 
+static inline int pud_dirty(pud_t pud)
+{
+	return pud_flags(pud) & _PAGE_DIRTY;
+}
+
+static inline int pud_young(pud_t pud)
+{
+	return pud_flags(pud) & _PAGE_ACCESSED;
+}
+
 static inline int pte_write(pte_t pte)
 {
 	return pte_flags(pte) & _PAGE_RW;
@@ -167,12 +178,23 @@ static inline int pmd_trans_huge(pmd_t pmd)
 	return (pmd_val(pmd) & (_PAGE_PSE|_PAGE_DEVMAP)) == _PAGE_PSE;
 }
 
+static inline int pud_trans_huge(pud_t pud)
+{
+	return (pud_val(pud) & (_PAGE_PSE|_PAGE_DEVMAP)) == _PAGE_PSE;
+}
+
 #define pmd_devmap pmd_devmap
 static inline int pmd_devmap(pmd_t pmd)
 {
 	return !!(pmd_val(pmd) & _PAGE_DEVMAP);
 }
 
+#define pud_devmap pud_devmap
+static inline int pud_devmap(pud_t pud)
+{
+	return !!(pud_val(pud) & _PAGE_DEVMAP);
+}
+
 static inline int has_transparent_hugepage(void)
 {
 	return cpu_has_pse;
@@ -317,6 +339,45 @@ static inline pmd_t pmd_mknotpresent(pmd_t pmd)
 	return pmd_clear_flags(pmd, _PAGE_PRESENT | _PAGE_PROTNONE);
 }
 
+static inline pud_t pud_set_flags(pud_t pud, pudval_t set)
+{
+	pudval_t v = native_pud_val(pud);
+
+	return __pud(v | set);
+}
+
+static inline pud_t pud_clear_flags(pud_t pud, pudval_t clear)
+{
+	pudval_t v = native_pud_val(pud);
+
+	return __pud(v & ~clear);
+}
+
+static inline pud_t pud_mkdevmap(pud_t pud)
+{
+	return pud_set_flags(pud, _PAGE_DEVMAP);
+}
+
+static inline pud_t pud_mkhuge(pud_t pud)
+{
+	return pud_set_flags(pud, _PAGE_PSE);
+}
+
+static inline pud_t pud_mkdirty(pud_t pud)
+{
+	return pud_set_flags(pud, _PAGE_DIRTY | _PAGE_SOFT_DIRTY);
+}
+
+static inline pud_t pud_mkyoung(pud_t pud)
+{
+	return pud_set_flags(pud, _PAGE_ACCESSED);
+}
+
+static inline pud_t pud_mkwrite(pud_t pud)
+{
+	return pud_set_flags(pud, _PAGE_RW);
+}
+
 #ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
 static inline int pte_soft_dirty(pte_t pte)
 {
@@ -328,6 +389,11 @@ static inline int pmd_soft_dirty(pmd_t pmd)
 	return pmd_flags(pmd) & _PAGE_SOFT_DIRTY;
 }
 
+static inline int pud_soft_dirty(pud_t pud)
+{
+	return pud_flags(pud) & _PAGE_SOFT_DIRTY;
+}
+
 static inline pte_t pte_mksoft_dirty(pte_t pte)
 {
 	return pte_set_flags(pte, _PAGE_SOFT_DIRTY);
@@ -378,6 +444,13 @@ static inline pmd_t pfn_pmd(unsigned long page_nr, pgprot_t pgprot)
 		     massage_pgprot(pgprot));
 }
 
+#define pfn_pud pfn_pud
+static inline pud_t pfn_pud(unsigned long page_nr, pgprot_t pgprot)
+{
+	return __pud(((phys_addr_t)page_nr << PAGE_SHIFT) |
+		     massage_pgprot(pgprot));
+}
+
 static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
 {
 	pteval_t val = pte_val(pte);
@@ -744,6 +817,12 @@ static inline void native_set_pmd_at(struct mm_struct *mm, unsigned long addr,
 	native_set_pmd(pmdp, pmd);
 }
 
+static inline void native_set_pud_at(struct mm_struct *mm, unsigned long addr,
+				     pud_t *pudp , pud_t pud)
+{
+	native_set_pud(pudp, pud);
+}
+
 #ifndef CONFIG_PARAVIRT
 /*
  * Rules for using pte_update - it must be called after any PTE update which
@@ -822,10 +901,15 @@ static inline void ptep_set_wrprotect(struct mm_struct *mm,
 extern int pmdp_set_access_flags(struct vm_area_struct *vma,
 				 unsigned long address, pmd_t *pmdp,
 				 pmd_t entry, int dirty);
+extern int pudp_set_access_flags(struct vm_area_struct *vma,
+				 unsigned long address, pud_t *pudp,
+				 pud_t entry, int dirty);
 
 #define __HAVE_ARCH_PMDP_TEST_AND_CLEAR_YOUNG
 extern int pmdp_test_and_clear_young(struct vm_area_struct *vma,
 				     unsigned long addr, pmd_t *pmdp);
+extern int pudp_test_and_clear_young(struct vm_area_struct *vma,
+				     unsigned long addr, pud_t *pudp);
 
 #define __HAVE_ARCH_PMDP_CLEAR_YOUNG_FLUSH
 extern int pmdp_clear_flush_young(struct vm_area_struct *vma,
@@ -845,6 +929,13 @@ static inline pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm, unsigned long
 	return native_pmdp_get_and_clear(pmdp);
 }
 
+#define __HAVE_ARCH_PUDP_HUGE_GET_AND_CLEAR
+static inline pud_t pudp_huge_get_and_clear(struct mm_struct *mm, unsigned long addr,
+				       pud_t *pudp)
+{
+	return native_pudp_get_and_clear(pudp);
+}
+
 #define __HAVE_ARCH_PMDP_SET_WRPROTECT
 static inline void pmdp_set_wrprotect(struct mm_struct *mm,
 				      unsigned long addr, pmd_t *pmdp)
@@ -893,6 +984,10 @@ static inline void update_mmu_cache_pmd(struct vm_area_struct *vma,
 		unsigned long addr, pmd_t *pmd)
 {
 }
+static inline void update_mmu_cache_pud(struct vm_area_struct *vma,
+		unsigned long addr, pud_t *pud)
+{
+}
 
 #ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
 static inline pte_t pte_swp_mksoft_dirty(pte_t pte)
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 2ee7811..a3aa6b7 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -106,6 +106,19 @@ static inline void native_pud_clear(pud_t *pud)
 	native_set_pud(pud, native_make_pud(0));
 }
 
+static inline pud_t native_pudp_get_and_clear(pud_t *pudp)
+{
+#ifdef CONFIG_SMP
+	return native_make_pud(xchg(&pudp->pud, 0));
+#else
+	/* native_local_pudp_get_and_clear,
+	   but duplicated because of cyclic dependency */
+	pud_t ret = *pudp;
+	native_pud_clear(pudp);
+	return ret;
+#endif
+}
+
 static inline void native_set_pgd(pgd_t *pgdp, pgd_t pgd)
 {
 	*pgdp = pgd;
diff --git a/arch/x86/kernel/paravirt.c b/arch/x86/kernel/paravirt.c
index f08ac28..24d61f2 100644
--- a/arch/x86/kernel/paravirt.c
+++ b/arch/x86/kernel/paravirt.c
@@ -425,6 +425,7 @@ struct pv_mmu_ops pv_mmu_ops = {
 	.pmd_clear = native_pmd_clear,
 #endif
 	.set_pud = native_set_pud,
+	.set_pud_at = native_set_pud_at,
 
 	.pmd_val = PTE_IDENT,
 	.make_pmd = PTE_IDENT,
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 4eb287e..b7c8df6 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -441,6 +441,26 @@ int pmdp_set_access_flags(struct vm_area_struct *vma,
 
 	return changed;
 }
+
+int pudp_set_access_flags(struct vm_area_struct *vma, unsigned long address,
+			  pud_t *pudp, pud_t entry, int dirty)
+{
+	int changed = !pud_same(*pudp, entry);
+
+	VM_BUG_ON(address & ~HPAGE_PUD_MASK);
+
+	if (changed && dirty) {
+		*pudp = entry;
+		/*
+		 * We had a write-protection fault here and changed the pud
+		 * to to more permissive. No need to flush the TLB for that,
+		 * #PF is architecturally guaranteed to do that and in the
+		 * worst-case we'll generate a spurious fault.
+		 */
+	}
+
+	return changed;
+}
 #endif
 
 int ptep_test_and_clear_young(struct vm_area_struct *vma,
@@ -470,6 +490,17 @@ int pmdp_test_and_clear_young(struct vm_area_struct *vma,
 
 	return ret;
 }
+int pudp_test_and_clear_young(struct vm_area_struct *vma,
+			      unsigned long addr, pud_t *pudp)
+{
+	int ret = 0;
+
+	if (pud_young(*pudp))
+		ret = test_and_clear_bit(_PAGE_BIT_ACCESSED,
+					 (unsigned long *)pudp);
+
+	return ret;
+}
 #endif
 
 int ptep_clear_flush_young(struct vm_area_struct *vma,
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
