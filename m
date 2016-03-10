Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id F2ED2828E1
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 18:56:03 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id 129so80449526pfw.1
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 15:56:03 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id x10si9293239pas.64.2016.03.10.15.55.40
        for <linux-mm@kvack.org>;
        Thu, 10 Mar 2016 15:55:41 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v5 09/14] x86: Add support for PUD-sized transparent hugepages
Date: Thu, 10 Mar 2016 18:55:26 -0500
Message-Id: <1457654131-4562-10-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1457654131-4562-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1457654131-4562-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

From: Matthew Wilcox <willy@linux.intel.com>

The x86-specific code needed to support the PUD uses in the transparent
hugepages code.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 arch/x86/Kconfig                      |   1 +
 arch/x86/include/asm/paravirt.h       |  11 +++
 arch/x86/include/asm/paravirt_types.h |   2 +
 arch/x86/include/asm/pgtable-2level.h |  13 +++
 arch/x86/include/asm/pgtable-3level.h |  20 +++++
 arch/x86/include/asm/pgtable.h        | 147 ++++++++++++++++++++++++++++++++++
 arch/x86/include/asm/pgtable_64.h     |   5 ++
 arch/x86/kernel/paravirt.c            |   1 +
 arch/x86/mm/pgtable.c                 |  31 +++++++
 9 files changed, 231 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 3b8290c..d28cc92 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -91,6 +91,7 @@ config X86
 	select HAVE_ARCH_SOFT_DIRTY		if X86_64
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
+	select HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD if X86_64
 	select HAVE_BPF_JIT			if X86_64
 	select HAVE_CC_STACKPROTECTOR
 	select HAVE_CMPXCHG_DOUBLE
diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
index 601f1b8..8fd5e50 100644
--- a/arch/x86/include/asm/paravirt.h
+++ b/arch/x86/include/asm/paravirt.h
@@ -486,6 +486,17 @@ static inline void set_pmd_at(struct mm_struct *mm, unsigned long addr,
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
index e8c2326..38f416e 100644
--- a/arch/x86/include/asm/paravirt_types.h
+++ b/arch/x86/include/asm/paravirt_types.h
@@ -252,6 +252,8 @@ struct pv_mmu_ops {
 	void (*set_pmd)(pmd_t *pmdp, pmd_t pmdval);
 	void (*set_pmd_at)(struct mm_struct *mm, unsigned long addr,
 			   pmd_t *pmdp, pmd_t pmdval);
+	void (*set_pud_at)(struct mm_struct *mm, unsigned long addr,
+			   pud_t *pudp, pud_t pudval);
 	void (*pte_update)(struct mm_struct *mm, unsigned long addr,
 			   pte_t *ptep);
 
diff --git a/arch/x86/include/asm/pgtable-2level.h b/arch/x86/include/asm/pgtable-2level.h
index 2f558ba..38f55ed 100644
--- a/arch/x86/include/asm/pgtable-2level.h
+++ b/arch/x86/include/asm/pgtable-2level.h
@@ -21,6 +21,10 @@ static inline void native_set_pmd(pmd_t *pmdp, pmd_t pmd)
 	*pmdp = pmd;
 }
 
+static inline void native_set_pud(pud_t *pudp, pud_t pud)
+{
+}
+
 static inline void native_set_pte_atomic(pte_t *ptep, pte_t pte)
 {
 	native_set_pte(ptep, pte);
@@ -31,6 +35,10 @@ static inline void native_pmd_clear(pmd_t *pmdp)
 	native_set_pmd(pmdp, __pmd(0));
 }
 
+static inline void native_pud_clear(pud_t *pudp)
+{
+}
+
 static inline void native_pte_clear(struct mm_struct *mm,
 				    unsigned long addr, pte_t *xp)
 {
@@ -47,6 +55,11 @@ static inline pmd_t native_pmdp_get_and_clear(pmd_t *xp)
 {
 	return __pmd(xchg((pmdval_t *)xp, 0));
 }
+
+static inline pud_t native_pudp_get_and_clear(pud_t *xp)
+{
+	return __pud(xchg((pudval_t *)xp, 0));
+}
 #endif
 
 /* Bit manipulation helper on pte/pgoff entry */
diff --git a/arch/x86/include/asm/pgtable-3level.h b/arch/x86/include/asm/pgtable-3level.h
index b1b6412..fbf6ebc 100644
--- a/arch/x86/include/asm/pgtable-3level.h
+++ b/arch/x86/include/asm/pgtable-3level.h
@@ -169,6 +169,26 @@ static inline pmd_t native_pmdp_get_and_clear(pmd_t *pmdp)
 
 	return res.pmd;
 }
+
+union split_pud {
+	struct {
+		u32 pud_low;
+		u32 pud_high;
+	};
+	pud_t pud;
+};
+
+static inline pud_t native_pudp_get_and_clear(pud_t *pudp)
+{
+	union split_pud res, *orig = (union split_pud *)pudp;
+
+	/* xchg acts as a barrier before setting of the high bits */
+	res.pud_low = xchg(&orig->pud_low, 0);
+	res.pud_high = orig->pud_high;
+	orig->pud_high = 0;
+
+	return res.pud;
+}
 #endif
 
 /* Encode and de-code a swap entry */
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 4cbc459..0343699 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -46,6 +46,7 @@ extern struct mm_struct *pgd_page_get_mm(struct page *page);
 #define set_pte(ptep, pte)		native_set_pte(ptep, pte)
 #define set_pte_at(mm, addr, ptep, pte)	native_set_pte_at(mm, addr, ptep, pte)
 #define set_pmd_at(mm, addr, pmdp, pmd)	native_set_pmd_at(mm, addr, pmdp, pmd)
+#define set_pud_at(mm, addr, pudp, pud)	native_set_pud_at(mm, addr, pudp, pud)
 
 #define set_pte_atomic(ptep, pte)					\
 	native_set_pte_atomic(ptep, pte)
@@ -122,6 +123,16 @@ static inline int pmd_young(pmd_t pmd)
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
@@ -175,6 +186,18 @@ static inline int pmd_trans_huge(pmd_t pmd)
 	return (pmd_val(pmd) & (_PAGE_PSE|_PAGE_DEVMAP)) == _PAGE_PSE;
 }
 
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+static inline int pud_trans_huge(pud_t pud)
+{
+	return (pud_val(pud) & (_PAGE_PSE|_PAGE_DEVMAP)) == _PAGE_PSE;
+}
+#else
+static inline int pud_trans_huge(pud_t pud)
+{
+	return 0;
+}
+#endif
+
 static inline int has_transparent_hugepage(void)
 {
 	return cpu_has_pse;
@@ -185,6 +208,18 @@ static inline int pmd_devmap(pmd_t pmd)
 {
 	return !!(pmd_val(pmd) & _PAGE_DEVMAP);
 }
+
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+static inline int pud_devmap(pud_t pud)
+{
+	return !!(pud_val(pud) & _PAGE_DEVMAP);
+}
+#else
+static inline int pud_devmap(pud_t pud)
+{
+	return 0;
+}
+#endif
 #endif
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
@@ -326,6 +361,65 @@ static inline pmd_t pmd_mknotpresent(pmd_t pmd)
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
+static inline pud_t pud_mkold(pud_t pud)
+{
+	return pud_clear_flags(pud, _PAGE_ACCESSED);
+}
+
+static inline pud_t pud_mkclean(pud_t pud)
+{
+	return pud_clear_flags(pud, _PAGE_DIRTY);
+}
+
+static inline pud_t pud_wrprotect(pud_t pud)
+{
+	return pud_clear_flags(pud, _PAGE_RW);
+}
+
+static inline pud_t pud_mkdirty(pud_t pud)
+{
+	return pud_set_flags(pud, _PAGE_DIRTY | _PAGE_SOFT_DIRTY);
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
+static inline pud_t pud_mknotpresent(pud_t pud)
+{
+	return pud_clear_flags(pud, _PAGE_PRESENT | _PAGE_PROTNONE);
+}
+
 #ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
 static inline int pte_soft_dirty(pte_t pte)
 {
@@ -337,6 +431,11 @@ static inline int pmd_soft_dirty(pmd_t pmd)
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
@@ -347,6 +446,11 @@ static inline pmd_t pmd_mksoft_dirty(pmd_t pmd)
 	return pmd_set_flags(pmd, _PAGE_SOFT_DIRTY);
 }
 
+static inline pud_t pud_mksoft_dirty(pud_t pud)
+{
+	return pud_set_flags(pud, _PAGE_SOFT_DIRTY);
+}
+
 static inline pte_t pte_clear_soft_dirty(pte_t pte)
 {
 	return pte_clear_flags(pte, _PAGE_SOFT_DIRTY);
@@ -357,6 +461,11 @@ static inline pmd_t pmd_clear_soft_dirty(pmd_t pmd)
 	return pmd_clear_flags(pmd, _PAGE_SOFT_DIRTY);
 }
 
+static inline pud_t pud_clear_soft_dirty(pud_t pud)
+{
+	return pud_clear_flags(pud, _PAGE_SOFT_DIRTY);
+}
+
 #endif /* CONFIG_HAVE_ARCH_SOFT_DIRTY */
 
 /*
@@ -385,6 +494,13 @@ static inline pmd_t pfn_pmd(unsigned long page_nr, pgprot_t pgprot)
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
@@ -740,9 +856,18 @@ static inline pmd_t native_local_pmdp_get_and_clear(pmd_t *pmdp)
 	return res;
 }
 
+static inline pud_t native_local_pudp_get_and_clear(pud_t *pudp)
+{
+	pud_t res = *pudp;
+
+	native_pud_clear(pudp);
+	return res;
+}
+
 #ifndef CONFIG_SMP
 #define native_ptep_get_and_clear(p)	native_local_ptep_get_and_clear(p)
 #define native_pmdp_get_and_clear(p)	native_local_pmdp_get_and_clear(p)
+#define native_pudp_get_and_clear(p)	native_local_pudp_get_and_clear(p)
 #endif
 
 static inline void native_set_pte_at(struct mm_struct *mm, unsigned long addr,
@@ -757,6 +882,12 @@ static inline void native_set_pmd_at(struct mm_struct *mm, unsigned long addr,
 	native_set_pmd(pmdp, pmd);
 }
 
+static inline void native_set_pud_at(struct mm_struct *mm, unsigned long addr,
+				     pud_t *pudp, pud_t pud)
+{
+	native_set_pud(pudp, pud);
+}
+
 #ifndef CONFIG_PARAVIRT
 /*
  * Rules for using pte_update - it must be called after any PTE update which
@@ -835,10 +966,15 @@ static inline void ptep_set_wrprotect(struct mm_struct *mm,
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
@@ -858,6 +994,13 @@ static inline pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm,
 	return native_pmdp_get_and_clear(pmdp);
 }
 
+#define __HAVE_ARCH_PUDP_HUGE_GET_AND_CLEAR
+static inline pud_t pudp_huge_get_and_clear(struct mm_struct *mm,
+					unsigned long addr, pud_t *pudp)
+{
+	return native_pudp_get_and_clear(pudp);
+}
+
 #define __HAVE_ARCH_PMDP_SET_WRPROTECT
 static inline void pmdp_set_wrprotect(struct mm_struct *mm,
 				      unsigned long addr, pmd_t *pmdp)
@@ -906,6 +1049,10 @@ static inline void update_mmu_cache_pmd(struct vm_area_struct *vma,
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
index a0c0219..d264589 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -80,6 +80,11 @@ static inline pmd_t native_pmdp_get_and_clear(pmd_t *xp)
 {
 	return native_make_pmd(xchg(&xp->pmd, 0));
 }
+
+static inline pud_t native_pudp_get_and_clear(pud_t *pudp)
+{
+	return native_make_pud(xchg(&pudp->pud, 0));
+}
 #endif
 
 static inline void native_set_pud(pud_t *pudp, pud_t pud)
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
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
