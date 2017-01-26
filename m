Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1DE1B6B0253
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 12:09:58 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 204so319498781pge.5
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 09:09:58 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id q5si26969608pgh.189.2017.01.26.09.09.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 09:09:55 -0800 (PST)
Subject: [PATCH v2 2/3] mm,
 x86: Add support for PUD-sized transparent hugepages
From: Dave Jiang <dave.jiang@intel.com>
Date: Thu, 26 Jan 2017 10:09:53 -0700
Message-ID: <148545059381.17912.8602162635537598445.stgit@djiang5-desk3.ch.intel.com>
In-Reply-To: <148545012634.17912.13951763606410303827.stgit@djiang5-desk3.ch.intel.com>
References: <148545012634.17912.13951763606410303827.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: dave.hansen@linux.intel.com, mawilcox@microsoft.com, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, vbabka@suse.cz, jack@suse.com, dan.j.williams@intel.com, linux-ext4@vger.kernel.org, ross.zwisler@linux.intel.com, kirill.shutemov@linux.intel.com

From: Matthew Wilcox <willy@linux.intel.com>

The current transparent hugepage code only supports PMDs.  This patch
adds support for transparent use of PUDs with DAX.  It does not include
support for anonymous pages. x86 support code also added.

Most of this patch simply parallels the work that was done for huge PMDs.
The only major difference is how the new ->pud_entry method in mm_walk
works.  The ->pmd_entry method replaces the ->pte_entry method, whereas
the ->pud_entry method works along with either ->pmd_entry or ->pte_entry.
The pagewalk code takes care of locking the PUD before calling ->pud_walk,
so handlers do not need to worry whether the PUD is stable.

[DJ: Forward ported to 4.10-rc]

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Signed-off-by: Dave Jiang <dave.jiang@intel.com>
---
 arch/Kconfig                          |    3 
 arch/x86/Kconfig                      |    1 
 arch/x86/include/asm/paravirt.h       |   11 +
 arch/x86/include/asm/paravirt_types.h |    2 
 arch/x86/include/asm/pgtable-2level.h |   17 ++
 arch/x86/include/asm/pgtable-3level.h |   24 +++
 arch/x86/include/asm/pgtable.h        |  140 +++++++++++++++++++
 arch/x86/include/asm/pgtable_64.h     |   15 ++
 arch/x86/kernel/paravirt.c            |    1 
 arch/x86/mm/pgtable.c                 |   31 ++++
 include/asm-generic/pgtable.h         |   80 ++++++++++-
 include/asm-generic/tlb.h             |   14 ++
 include/linux/huge_mm.h               |   83 ++++++++++-
 include/linux/mm.h                    |   30 ++++
 include/linux/mmu_notifier.h          |   14 ++
 include/linux/pfn_t.h                 |   12 ++
 mm/gup.c                              |    7 +
 mm/huge_memory.c                      |  249 +++++++++++++++++++++++++++++++++
 mm/memory.c                           |   88 +++++++++++-
 mm/pagewalk.c                         |   20 +++
 mm/pgtable-generic.c                  |   14 ++
 21 files changed, 838 insertions(+), 18 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 89e0b4f..40ed4e2 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -545,6 +545,9 @@ config HAVE_IRQ_TIME_ACCOUNTING
 config HAVE_ARCH_TRANSPARENT_HUGEPAGE
 	bool
 
+config HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+	bool
+
 config HAVE_ARCH_HUGE_VMAP
 	bool
 
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index e487493..2c4a6ab 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -105,6 +105,7 @@ config X86
 	select HAVE_ARCH_SECCOMP_FILTER
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
+	select HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD if X86_64
 	select HAVE_ARCH_VMAP_STACK		if X86_64
 	select HAVE_ARCH_WITHIN_STACK_FRAMES
 	select HAVE_CC_STACKPROTECTOR
diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
index 1eea6ca..1b5c172 100644
--- a/arch/x86/include/asm/paravirt.h
+++ b/arch/x86/include/asm/paravirt.h
@@ -475,6 +475,17 @@ static inline void set_pmd_at(struct mm_struct *mm, unsigned long addr,
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
index bb2de45..b060f96 100644
--- a/arch/x86/include/asm/paravirt_types.h
+++ b/arch/x86/include/asm/paravirt_types.h
@@ -249,6 +249,8 @@ struct pv_mmu_ops {
 	void (*set_pmd)(pmd_t *pmdp, pmd_t pmdval);
 	void (*set_pmd_at)(struct mm_struct *mm, unsigned long addr,
 			   pmd_t *pmdp, pmd_t pmdval);
+	void (*set_pud_at)(struct mm_struct *mm, unsigned long addr,
+			   pud_t *pudp, pud_t pudval);
 	void (*pte_update)(struct mm_struct *mm, unsigned long addr,
 			   pte_t *ptep);
 
diff --git a/arch/x86/include/asm/pgtable-2level.h b/arch/x86/include/asm/pgtable-2level.h
index fd74a11..a8b96e7 100644
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
@@ -55,6 +63,15 @@ static inline pmd_t native_pmdp_get_and_clear(pmd_t *xp)
 #define native_pmdp_get_and_clear(xp) native_local_pmdp_get_and_clear(xp)
 #endif
 
+#ifdef CONFIG_SMP
+static inline pud_t native_pudp_get_and_clear(pud_t *xp)
+{
+	return __pud(xchg((pudval_t *)xp, 0));
+}
+#else
+#define native_pudp_get_and_clear(xp) native_local_pudp_get_and_clear(xp)
+#endif
+
 /* Bit manipulation helper on pte/pgoff entry */
 static inline unsigned long pte_bitop(unsigned long value, unsigned int rightshift,
 				      unsigned long mask, unsigned int leftshift)
diff --git a/arch/x86/include/asm/pgtable-3level.h b/arch/x86/include/asm/pgtable-3level.h
index cdaa58c..be759ff 100644
--- a/arch/x86/include/asm/pgtable-3level.h
+++ b/arch/x86/include/asm/pgtable-3level.h
@@ -176,6 +176,30 @@ static inline pmd_t native_pmdp_get_and_clear(pmd_t *pmdp)
 #define native_pmdp_get_and_clear(xp) native_local_pmdp_get_and_clear(xp)
 #endif
 
+#ifdef CONFIG_SMP
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
+#else
+#define native_pudp_get_and_clear(xp) native_local_pudp_get_and_clear(xp)
+#endif
+
 /* Encode and de-code a swap entry */
 #define MAX_SWAPFILES_CHECK() BUILD_BUG_ON(MAX_SWAPFILES_SHIFT > 5)
 #define __swp_type(x)			(((x).val) & 0x1f)
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 437feb4..1cfb36b 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -46,6 +46,7 @@ extern struct mm_struct *pgd_page_get_mm(struct page *page);
 #define set_pte(ptep, pte)		native_set_pte(ptep, pte)
 #define set_pte_at(mm, addr, ptep, pte)	native_set_pte_at(mm, addr, ptep, pte)
 #define set_pmd_at(mm, addr, pmdp, pmd)	native_set_pmd_at(mm, addr, pmdp, pmd)
+#define set_pud_at(mm, addr, pudp, pud)	native_set_pud_at(mm, addr, pudp, pud)
 
 #define set_pte_atomic(ptep, pte)					\
 	native_set_pte_atomic(ptep, pte)
@@ -128,6 +129,16 @@ static inline int pmd_young(pmd_t pmd)
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
@@ -181,6 +192,13 @@ static inline int pmd_trans_huge(pmd_t pmd)
 	return (pmd_val(pmd) & (_PAGE_PSE|_PAGE_DEVMAP)) == _PAGE_PSE;
 }
 
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+static inline int pud_trans_huge(pud_t pud)
+{
+	return (pud_val(pud) & (_PAGE_PSE|_PAGE_DEVMAP)) == _PAGE_PSE;
+}
+#endif
+
 #define has_transparent_hugepage has_transparent_hugepage
 static inline int has_transparent_hugepage(void)
 {
@@ -192,6 +210,18 @@ static inline int pmd_devmap(pmd_t pmd)
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
 
@@ -333,6 +363,65 @@ static inline pmd_t pmd_mknotpresent(pmd_t pmd)
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
@@ -344,6 +433,11 @@ static inline int pmd_soft_dirty(pmd_t pmd)
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
@@ -354,6 +448,11 @@ static inline pmd_t pmd_mksoft_dirty(pmd_t pmd)
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
@@ -364,6 +463,11 @@ static inline pmd_t pmd_clear_soft_dirty(pmd_t pmd)
 	return pmd_clear_flags(pmd, _PAGE_SOFT_DIRTY);
 }
 
+static inline pud_t pud_clear_soft_dirty(pud_t pud)
+{
+	return pud_clear_flags(pud, _PAGE_SOFT_DIRTY);
+}
+
 #endif /* CONFIG_HAVE_ARCH_SOFT_DIRTY */
 
 /*
@@ -392,6 +496,12 @@ static inline pmd_t pfn_pmd(unsigned long page_nr, pgprot_t pgprot)
 		     massage_pgprot(pgprot));
 }
 
+static inline pud_t pfn_pud(unsigned long page_nr, pgprot_t pgprot)
+{
+	return __pud(((phys_addr_t)page_nr << PAGE_SHIFT) |
+		     massage_pgprot(pgprot));
+}
+
 static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
 {
 	pteval_t val = pte_val(pte);
@@ -771,6 +881,14 @@ static inline pmd_t native_local_pmdp_get_and_clear(pmd_t *pmdp)
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
 static inline void native_set_pte_at(struct mm_struct *mm, unsigned long addr,
 				     pte_t *ptep , pte_t pte)
 {
@@ -783,6 +901,12 @@ static inline void native_set_pmd_at(struct mm_struct *mm, unsigned long addr,
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
@@ -861,10 +985,15 @@ static inline void ptep_set_wrprotect(struct mm_struct *mm,
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
@@ -884,6 +1013,13 @@ static inline pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm, unsigned long
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
@@ -932,6 +1068,10 @@ static inline void update_mmu_cache_pmd(struct vm_area_struct *vma,
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
index 62b77592..73c7ccc 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -106,6 +106,21 @@ static inline void native_pud_clear(pud_t *pud)
 	native_set_pud(pud, native_make_pud(0));
 }
 
+static inline pud_t native_pudp_get_and_clear(pud_t *xp)
+{
+#ifdef CONFIG_SMP
+	return native_make_pud(xchg(&xp->pud, 0));
+#else
+	/* native_local_pudp_get_and_clear,
+	 * but duplicated because of cyclic dependency
+	 */
+	pud_t ret = *xp;
+
+	native_pud_clear(xp);
+	return ret;
+#endif
+}
+
 static inline void native_set_pgd(pgd_t *pgdp, pgd_t pgd)
 {
 	*pgdp = pgd;
diff --git a/arch/x86/kernel/paravirt.c b/arch/x86/kernel/paravirt.c
index a1bfba0..4797e87 100644
--- a/arch/x86/kernel/paravirt.c
+++ b/arch/x86/kernel/paravirt.c
@@ -425,6 +425,7 @@ struct pv_mmu_ops pv_mmu_ops __ro_after_init = {
 	.pmd_clear = native_pmd_clear,
 #endif
 	.set_pud = native_set_pud,
+	.set_pud_at = native_set_pud_at,
 
 	.pmd_val = PTE_IDENT,
 	.make_pmd = PTE_IDENT,
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 3feec5a..6cbdff2 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -445,6 +445,26 @@ int pmdp_set_access_flags(struct vm_area_struct *vma,
 
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
@@ -474,6 +494,17 @@ int pmdp_test_and_clear_young(struct vm_area_struct *vma,
 
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
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 18af2bc..a0aba0f 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -36,6 +36,9 @@ extern int ptep_set_access_flags(struct vm_area_struct *vma,
 extern int pmdp_set_access_flags(struct vm_area_struct *vma,
 				 unsigned long address, pmd_t *pmdp,
 				 pmd_t entry, int dirty);
+extern int pudp_set_access_flags(struct vm_area_struct *vma,
+				 unsigned long address, pud_t *pudp,
+				 pud_t entry, int dirty);
 #else
 static inline int pmdp_set_access_flags(struct vm_area_struct *vma,
 					unsigned long address, pmd_t *pmdp,
@@ -44,6 +47,13 @@ static inline int pmdp_set_access_flags(struct vm_area_struct *vma,
 	BUILD_BUG();
 	return 0;
 }
+static inline int pudp_set_access_flags(struct vm_area_struct *vma,
+					unsigned long address, pud_t *pudp,
+					pud_t entry, int dirty)
+{
+	BUILD_BUG();
+	return 0;
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
 
@@ -121,8 +131,8 @@ static inline pte_t ptep_get_and_clear(struct mm_struct *mm,
 }
 #endif
 
-#ifndef __HAVE_ARCH_PMDP_HUGE_GET_AND_CLEAR
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#ifndef __HAVE_ARCH_PMDP_HUGE_GET_AND_CLEAR
 static inline pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm,
 					    unsigned long address,
 					    pmd_t *pmdp)
@@ -131,20 +141,40 @@ static inline pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm,
 	pmd_clear(pmdp);
 	return pmd;
 }
+#endif /* __HAVE_ARCH_PMDP_HUGE_GET_AND_CLEAR */
+#ifndef __HAVE_ARCH_PUDP_HUGE_GET_AND_CLEAR
+static inline pud_t pudp_huge_get_and_clear(struct mm_struct *mm,
+					    unsigned long address,
+					    pud_t *pudp)
+{
+	pud_t pud = *pudp;
+
+	pud_clear(pudp);
+	return pud;
+}
+#endif /* __HAVE_ARCH_PUDP_HUGE_GET_AND_CLEAR */
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
-#endif
 
-#ifndef __HAVE_ARCH_PMDP_HUGE_GET_AND_CLEAR_FULL
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#ifndef __HAVE_ARCH_PMDP_HUGE_GET_AND_CLEAR_FULL
 static inline pmd_t pmdp_huge_get_and_clear_full(struct mm_struct *mm,
 					    unsigned long address, pmd_t *pmdp,
 					    int full)
 {
 	return pmdp_huge_get_and_clear(mm, address, pmdp);
 }
-#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
 
+#ifndef __HAVE_ARCH_PUDP_HUGE_GET_AND_CLEAR_FULL
+static inline pud_t pudp_huge_get_and_clear_full(struct mm_struct *mm,
+					    unsigned long address, pud_t *pudp,
+					    int full)
+{
+	return pudp_huge_get_and_clear(mm, address, pudp);
+}
+#endif
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+
 #ifndef __HAVE_ARCH_PTEP_GET_AND_CLEAR_FULL
 static inline pte_t ptep_get_and_clear_full(struct mm_struct *mm,
 					    unsigned long address, pte_t *ptep,
@@ -181,6 +211,9 @@ extern pte_t ptep_clear_flush(struct vm_area_struct *vma,
 extern pmd_t pmdp_huge_clear_flush(struct vm_area_struct *vma,
 			      unsigned long address,
 			      pmd_t *pmdp);
+extern pud_t pudp_huge_clear_flush(struct vm_area_struct *vma,
+			      unsigned long address,
+			      pud_t *pudp);
 #endif
 
 #ifndef __HAVE_ARCH_PTEP_SET_WRPROTECT
@@ -208,6 +241,23 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm,
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
+#ifndef __HAVE_ARCH_PUDP_SET_WRPROTECT
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+static inline void pudp_set_wrprotect(struct mm_struct *mm,
+				      unsigned long address, pud_t *pudp)
+{
+	pud_t old_pud = *pudp;
+
+	set_pud_at(mm, address, pudp, pud_wrprotect(old_pud));
+}
+#else
+static inline void pudp_set_wrprotect(struct mm_struct *mm,
+				      unsigned long address, pud_t *pudp)
+{
+	BUILD_BUG();
+}
+#endif /* CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
+#endif
 
 #ifndef pmdp_collapse_flush
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -273,12 +323,23 @@ static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_b)
 {
 	return pmd_val(pmd_a) == pmd_val(pmd_b);
 }
+
+static inline int pud_same(pud_t pud_a, pud_t pud_b)
+{
+	return pud_val(pud_a) == pud_val(pud_b);
+}
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_b)
 {
 	BUILD_BUG();
 	return 0;
 }
+
+static inline int pud_same(pud_t pud_a, pud_t pud_b)
+{
+	BUILD_BUG();
+	return 0;
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
 
@@ -640,6 +701,15 @@ static inline int pmd_write(pmd_t pmd)
 #endif /* __HAVE_ARCH_PMD_WRITE */
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
+#if !defined(CONFIG_TRANSPARENT_HUGEPAGE) || \
+	(defined(CONFIG_TRANSPARENT_HUGEPAGE) && \
+	 !defined(CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD))
+static inline int pud_trans_huge(pud_t pud)
+{
+	return 0;
+}
+#endif
+
 #ifndef pmd_read_atomic
 static inline pmd_t pmd_read_atomic(pmd_t *pmdp)
 {
@@ -785,8 +855,10 @@ static inline int pmd_clear_huge(pmd_t *pmd)
  * e.g. see arch/arc: flush_pmd_tlb_range
  */
 #define flush_pmd_tlb_range(vma, addr, end)	flush_tlb_range(vma, addr, end)
+#define flush_pud_tlb_range(vma, addr, end)	flush_tlb_range(vma, addr, end)
 #else
 #define flush_pmd_tlb_range(vma, addr, end)	BUILD_BUG()
+#define flush_pud_tlb_range(vma, addr, end)	BUILD_BUG()
 #endif
 #endif
 
diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index 7eed8cf..4329bc6 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -232,6 +232,20 @@ static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
 		__tlb_remove_pmd_tlb_entry(tlb, pmdp, address);		\
 	} while (0)
 
+/**
+ * tlb_remove_pud_tlb_entry - remember a pud mapping for later tlb
+ * invalidation. This is a nop so far, because only x86 needs it.
+ */
+#ifndef __tlb_remove_pud_tlb_entry
+#define __tlb_remove_pud_tlb_entry(tlb, pudp, address) do {} while (0)
+#endif
+
+#define tlb_remove_pud_tlb_entry(tlb, pudp, address)			\
+	do {								\
+		__tlb_adjust_range(tlb, address, HPAGE_PUD_SIZE);	\
+		__tlb_remove_pud_tlb_entry(tlb, pudp, address);		\
+	} while (0)
+
 /*
  * For things like page tables caches (ie caching addresses "inside" the
  * page tables, like x86 does), for legacy reasons, flushing an
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 97e478d..a530742 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -6,6 +6,18 @@ extern int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 			 pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
 			 struct vm_area_struct *vma);
 extern void huge_pmd_set_accessed(struct vm_fault *vmf, pmd_t orig_pmd);
+extern int copy_huge_pud(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+			 pud_t *dst_pud, pud_t *src_pud, unsigned long addr,
+			 struct vm_area_struct *vma);
+
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+extern void huge_pud_set_accessed(struct vm_fault *vmf, pud_t orig_pud);
+#else
+static inline void huge_pud_set_accessed(struct vm_fault *vmf, pud_t orig_pud)
+{
+}
+#endif
+
 extern int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd);
 extern struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 					  unsigned long addr,
@@ -17,6 +29,9 @@ extern bool madvise_free_huge_pmd(struct mmu_gather *tlb,
 extern int zap_huge_pmd(struct mmu_gather *tlb,
 			struct vm_area_struct *vma,
 			pmd_t *pmd, unsigned long addr);
+extern int zap_huge_pud(struct mmu_gather *tlb,
+			struct vm_area_struct *vma,
+			pud_t *pud, unsigned long addr);
 extern int mincore_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			unsigned long addr, unsigned long end,
 			unsigned char *vec);
@@ -26,8 +41,10 @@ extern bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
 extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			unsigned long addr, pgprot_t newprot,
 			int prot_numa);
-int vmf_insert_pfn_pmd(struct vm_area_struct *, unsigned long addr, pmd_t *,
-			pfn_t pfn, bool write);
+int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
+			pmd_t *pmd, pfn_t pfn, bool write);
+int vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
+			pud_t *pud, pfn_t pfn, bool write);
 enum transparent_hugepage_flag {
 	TRANSPARENT_HUGEPAGE_FLAG,
 	TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
@@ -57,13 +74,14 @@ extern struct kobj_attribute shmem_enabled_attr;
 #define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
-		pmd_t *pmd, int flags);
-
 #define HPAGE_PMD_SHIFT PMD_SHIFT
 #define HPAGE_PMD_SIZE	((1UL) << HPAGE_PMD_SHIFT)
 #define HPAGE_PMD_MASK	(~(HPAGE_PMD_SIZE - 1))
 
+#define HPAGE_PUD_SHIFT PUD_SHIFT
+#define HPAGE_PUD_SIZE	((1UL) << HPAGE_PUD_SHIFT)
+#define HPAGE_PUD_MASK	(~(HPAGE_PUD_SIZE - 1))
+
 extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
 
 #define transparent_hugepage_enabled(__vma)				\
@@ -117,6 +135,17 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address,
 		bool freeze, struct page *page);
 
+void __split_huge_pud(struct vm_area_struct *vma, pud_t *pud,
+		unsigned long address);
+
+#define split_huge_pud(__vma, __pud, __address)				\
+	do {								\
+		pud_t *____pud = (__pud);				\
+		if (pud_trans_huge(*____pud)				\
+					|| pud_devmap(*____pud))	\
+			__split_huge_pud(__vma, __pud, __address);	\
+	}  while (0)
+
 extern int hugepage_madvise(struct vm_area_struct *vma,
 			    unsigned long *vm_flags, int advice);
 extern void vma_adjust_trans_huge(struct vm_area_struct *vma,
@@ -125,6 +154,8 @@ extern void vma_adjust_trans_huge(struct vm_area_struct *vma,
 				    long adjust_next);
 extern spinlock_t *__pmd_trans_huge_lock(pmd_t *pmd,
 		struct vm_area_struct *vma);
+extern spinlock_t *__pud_trans_huge_lock(pud_t *pud,
+		struct vm_area_struct *vma);
 /* mmap_sem must be held on entry */
 static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
 		struct vm_area_struct *vma)
@@ -135,6 +166,15 @@ static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
 	else
 		return NULL;
 }
+static inline spinlock_t *pud_trans_huge_lock(pud_t *pud,
+		struct vm_area_struct *vma)
+{
+	VM_BUG_ON_VMA(!rwsem_is_locked(&vma->vm_mm->mmap_sem), vma);
+	if (pud_trans_huge(*pud) || pud_devmap(*pud))
+		return __pud_trans_huge_lock(pud, vma);
+	else
+		return NULL;
+}
 static inline int hpage_nr_pages(struct page *page)
 {
 	if (unlikely(PageTransHuge(page)))
@@ -142,6 +182,11 @@ static inline int hpage_nr_pages(struct page *page)
 	return 1;
 }
 
+struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
+		pmd_t *pmd, int flags);
+struct page *follow_devmap_pud(struct vm_area_struct *vma, unsigned long addr,
+		pud_t *pud, int flags);
+
 extern int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t orig_pmd);
 
 extern struct page *huge_zero_page;
@@ -156,6 +201,11 @@ static inline bool is_huge_zero_pmd(pmd_t pmd)
 	return is_huge_zero_page(pmd_page(pmd));
 }
 
+static inline bool is_huge_zero_pud(pud_t pud)
+{
+	return false;
+}
+
 struct page *mm_get_huge_zero_page(struct mm_struct *mm);
 void mm_put_huge_zero_page(struct mm_struct *mm);
 
@@ -166,6 +216,10 @@ void mm_put_huge_zero_page(struct mm_struct *mm);
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_SIZE ({ BUILD_BUG(); 0; })
 
+#define HPAGE_PUD_SHIFT ({ BUILD_BUG(); 0; })
+#define HPAGE_PUD_MASK ({ BUILD_BUG(); 0; })
+#define HPAGE_PUD_SIZE ({ BUILD_BUG(); 0; })
+
 #define hpage_nr_pages(x) 1
 
 #define transparent_hugepage_enabled(__vma) 0
@@ -194,6 +248,9 @@ static inline void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 static inline void split_huge_pmd_address(struct vm_area_struct *vma,
 		unsigned long address, bool freeze, struct page *page) {}
 
+#define split_huge_pud(__vma, __pmd, __address)	\
+	do { } while (0)
+
 static inline int hugepage_madvise(struct vm_area_struct *vma,
 				   unsigned long *vm_flags, int advice)
 {
@@ -211,6 +268,11 @@ static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
 {
 	return NULL;
 }
+static inline spinlock_t *pud_trans_huge_lock(pud_t *pud,
+		struct vm_area_struct *vma)
+{
+	return NULL;
+}
 
 static inline int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t orig_pmd)
 {
@@ -222,6 +284,11 @@ static inline bool is_huge_zero_page(struct page *page)
 	return false;
 }
 
+static inline bool is_huge_zero_pud(pud_t pud)
+{
+	return false;
+}
+
 static inline void mm_put_huge_zero_page(struct mm_struct *mm)
 {
 	return;
@@ -232,6 +299,12 @@ static inline struct page *follow_devmap_pmd(struct vm_area_struct *vma,
 {
 	return NULL;
 }
+
+static inline struct page *follow_devmap_pud(struct vm_area_struct *vma,
+		unsigned long addr, pud_t *pud, int flags)
+{
+	return NULL;
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #endif /* _LINUX_HUGE_MM_H */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 19d6f71..5282729 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -420,6 +420,10 @@ static inline int pmd_devmap(pmd_t pmd)
 {
 	return 0;
 }
+static inline int pud_devmap(pud_t pud)
+{
+	return 0;
+}
 #endif
 
 /*
@@ -1198,6 +1202,10 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 
 /**
  * mm_walk - callbacks for walk_page_range
+ * @pud_entry: if set, called for each non-empty PUD (2nd-level) entry
+ *	       this handler should only handle pud_trans_huge() puds.
+ *	       the pmd_entry or pte_entry callbacks will be used for
+ *	       regular PUDs.
  * @pmd_entry: if set, called for each non-empty PMD (3rd-level) entry
  *	       this handler is required to be able to handle
  *	       pmd_trans_huge() pmds.  They may simply choose to
@@ -1217,6 +1225,8 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
  * (see the comment on walk_page_range() for more details)
  */
 struct mm_walk {
+	int (*pud_entry)(pud_t *pud, unsigned long addr,
+			 unsigned long next, struct mm_walk *walk);
 	int (*pmd_entry)(pmd_t *pmd, unsigned long addr,
 			 unsigned long next, struct mm_walk *walk);
 	int (*pte_entry)(pte_t *pte, unsigned long addr,
@@ -1800,8 +1810,26 @@ static inline spinlock_t *pmd_lock(struct mm_struct *mm, pmd_t *pmd)
 	return ptl;
 }
 
-extern void __init pagecache_init(void);
+/*
+ * No scalability reason to split PUD locks yet, but follow the same pattern
+ * as the PMD locks to make it easier if we decide to.  The VM should not be
+ * considered ready to switch to split PUD locks yet; there may be places
+ * which need to be converted from page_table_lock.
+ */
+static inline spinlock_t *pud_lockptr(struct mm_struct *mm, pud_t *pud)
+{
+	return &mm->page_table_lock;
+}
+
+static inline spinlock_t *pud_lock(struct mm_struct *mm, pud_t *pud)
+{
+	spinlock_t *ptl = pud_lockptr(mm, pud);
+
+	spin_lock(ptl);
+	return ptl;
+}
 
+extern void __init pagecache_init(void);
 extern void free_area_init(unsigned long * zones_size);
 extern void free_area_init_node(int nid, unsigned long * zones_size,
 		unsigned long zone_start_pfn, unsigned long *zholes_size);
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index a1a210d..51891fb 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -381,6 +381,19 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 	___pmd;								\
 })
 
+#define pudp_huge_clear_flush_notify(__vma, __haddr, __pud)		\
+({									\
+	unsigned long ___haddr = __haddr & HPAGE_PUD_MASK;		\
+	struct mm_struct *___mm = (__vma)->vm_mm;			\
+	pud_t ___pud;							\
+									\
+	___pud = pudp_huge_clear_flush(__vma, __haddr, __pud);		\
+	mmu_notifier_invalidate_range(___mm, ___haddr,			\
+				      ___haddr + HPAGE_PUD_SIZE);	\
+									\
+	___pud;								\
+})
+
 #define pmdp_huge_get_and_clear_notify(__mm, __haddr, __pmd)		\
 ({									\
 	unsigned long ___haddr = __haddr & HPAGE_PMD_MASK;		\
@@ -475,6 +488,7 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 #define pmdp_clear_young_notify pmdp_test_and_clear_young
 #define	ptep_clear_flush_notify ptep_clear_flush
 #define pmdp_huge_clear_flush_notify pmdp_huge_clear_flush
+#define pudp_huge_clear_flush_notify pudp_huge_clear_flush
 #define pmdp_huge_get_and_clear_notify pmdp_huge_get_and_clear
 #define set_pte_at_notify set_pte_at
 
diff --git a/include/linux/pfn_t.h b/include/linux/pfn_t.h
index 033fc7b..a49b325 100644
--- a/include/linux/pfn_t.h
+++ b/include/linux/pfn_t.h
@@ -90,6 +90,13 @@ static inline pmd_t pfn_t_pmd(pfn_t pfn, pgprot_t pgprot)
 {
 	return pfn_pmd(pfn_t_to_pfn(pfn), pgprot);
 }
+
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+static inline pud_t pfn_t_pud(pfn_t pfn, pgprot_t pgprot)
+{
+	return pfn_pud(pfn_t_to_pfn(pfn), pgprot);
+}
+#endif
 #endif
 
 #ifdef __HAVE_ARCH_PTE_DEVMAP
@@ -106,5 +113,10 @@ static inline bool pfn_t_devmap(pfn_t pfn)
 }
 pte_t pte_mkdevmap(pte_t pte);
 pmd_t pmd_mkdevmap(pmd_t pmd);
+#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && \
+	defined(CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD)
+pud_t pud_mkdevmap(pud_t pud);
 #endif
+#endif /* __HAVE_ARCH_PTE_DEVMAP */
+
 #endif /* _LINUX_PFN_T_H_ */
diff --git a/mm/gup.c b/mm/gup.c
index 40abe4c..1e67461 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -253,6 +253,13 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 			return page;
 		return no_page_table(vma, flags);
 	}
+	if (pud_devmap(*pud)) {
+		ptl = pud_lock(mm, pud);
+		page = follow_devmap_pud(vma, address, pud, flags);
+		spin_unlock(ptl);
+		if (page)
+			return page;
+	}
 	if (unlikely(pud_bad(*pud)))
 		return no_page_table(vma, flags);
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5f3ad65c..de9ba1e 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -755,6 +755,60 @@ int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 }
 EXPORT_SYMBOL_GPL(vmf_insert_pfn_pmd);
 
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+static pud_t maybe_pud_mkwrite(pud_t pud, struct vm_area_struct *vma)
+{
+	if (likely(vma->vm_flags & VM_WRITE))
+		pud = pud_mkwrite(pud);
+	return pud;
+}
+
+static void insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
+		pud_t *pud, pfn_t pfn, pgprot_t prot, bool write)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pud_t entry;
+	spinlock_t *ptl;
+
+	ptl = pud_lock(mm, pud);
+	entry = pud_mkhuge(pfn_t_pud(pfn, prot));
+	if (pfn_t_devmap(pfn))
+		entry = pud_mkdevmap(entry);
+	if (write) {
+		entry = pud_mkyoung(pud_mkdirty(entry));
+		entry = maybe_pud_mkwrite(entry, vma);
+	}
+	set_pud_at(mm, addr, pud, entry);
+	update_mmu_cache_pud(vma, addr, pud);
+	spin_unlock(ptl);
+}
+
+int vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
+			pud_t *pud, pfn_t pfn, bool write)
+{
+	pgprot_t pgprot = vma->vm_page_prot;
+	/*
+	 * If we had pud_special, we could avoid all these restrictions,
+	 * but we need to be consistent with PTEs and architectures that
+	 * can't support a 'special' bit.
+	 */
+	BUG_ON(!(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)));
+	BUG_ON((vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)) ==
+						(VM_PFNMAP|VM_MIXEDMAP));
+	BUG_ON((vma->vm_flags & VM_PFNMAP) && is_cow_mapping(vma->vm_flags));
+	BUG_ON(!pfn_t_devmap(pfn));
+
+	if (addr < vma->vm_start || addr >= vma->vm_end)
+		return VM_FAULT_SIGBUS;
+
+	track_pfn_insert(vma, &pgprot, pfn);
+
+	insert_pfn_pud(vma, addr, pud, pfn, pgprot, write);
+	return VM_FAULT_NOPAGE;
+}
+EXPORT_SYMBOL_GPL(vmf_insert_pfn_pud);
+#endif /* CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
+
 static void touch_pmd(struct vm_area_struct *vma, unsigned long addr,
 		pmd_t *pmd)
 {
@@ -885,6 +939,123 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	return ret;
 }
 
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+static void touch_pud(struct vm_area_struct *vma, unsigned long addr,
+		pud_t *pud)
+{
+	pud_t _pud;
+
+	/*
+	 * We should set the dirty bit only for FOLL_WRITE but for now
+	 * the dirty bit in the pud is meaningless.  And if the dirty
+	 * bit will become meaningful and we'll only set it with
+	 * FOLL_WRITE, an atomic set_bit will be required on the pud to
+	 * set the young bit, instead of the current set_pud_at.
+	 */
+	_pud = pud_mkyoung(pud_mkdirty(*pud));
+	if (pudp_set_access_flags(vma, addr & HPAGE_PUD_MASK,
+				pud, _pud,  1))
+		update_mmu_cache_pud(vma, addr, pud);
+}
+
+struct page *follow_devmap_pud(struct vm_area_struct *vma, unsigned long addr,
+		pud_t *pud, int flags)
+{
+	unsigned long pfn = pud_pfn(*pud);
+	struct mm_struct *mm = vma->vm_mm;
+	struct dev_pagemap *pgmap;
+	struct page *page;
+
+	assert_spin_locked(pud_lockptr(mm, pud));
+
+	if (flags & FOLL_WRITE && !pud_write(*pud))
+		return NULL;
+
+	if (pud_present(*pud) && pud_devmap(*pud))
+		/* pass */;
+	else
+		return NULL;
+
+	if (flags & FOLL_TOUCH)
+		touch_pud(vma, addr, pud);
+
+	/*
+	 * device mapped pages can only be returned if the
+	 * caller will manage the page reference count.
+	 */
+	if (!(flags & FOLL_GET))
+		return ERR_PTR(-EEXIST);
+
+	pfn += (addr & ~PUD_MASK) >> PAGE_SHIFT;
+	pgmap = get_dev_pagemap(pfn, NULL);
+	if (!pgmap)
+		return ERR_PTR(-EFAULT);
+	page = pfn_to_page(pfn);
+	get_page(page);
+	put_dev_pagemap(pgmap);
+
+	return page;
+}
+
+int copy_huge_pud(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+		  pud_t *dst_pud, pud_t *src_pud, unsigned long addr,
+		  struct vm_area_struct *vma)
+{
+	spinlock_t *dst_ptl, *src_ptl;
+	pud_t pud;
+	int ret;
+
+	dst_ptl = pud_lock(dst_mm, dst_pud);
+	src_ptl = pud_lockptr(src_mm, src_pud);
+	spin_lock_nested(src_ptl, SINGLE_DEPTH_NESTING);
+
+	ret = -EAGAIN;
+	pud = *src_pud;
+	if (unlikely(!pud_trans_huge(pud) && !pud_devmap(pud)))
+		goto out_unlock;
+
+	/*
+	 * When page table lock is held, the huge zero pud should not be
+	 * under splitting since we don't split the page itself, only pud to
+	 * a page table.
+	 */
+	if (is_huge_zero_pud(pud)) {
+		/* No huge zero pud yet */
+	}
+
+	pudp_set_wrprotect(src_mm, addr, src_pud);
+	pud = pud_mkold(pud_wrprotect(pud));
+	set_pud_at(dst_mm, addr, dst_pud, pud);
+
+	ret = 0;
+out_unlock:
+	spin_unlock(src_ptl);
+	spin_unlock(dst_ptl);
+	return ret;
+}
+
+void huge_pud_set_accessed(struct vm_fault *vmf, pud_t orig_pud)
+{
+	pud_t entry;
+	unsigned long haddr;
+	bool write = vmf->flags & FAULT_FLAG_WRITE;
+
+	vmf->ptl = pud_lock(vmf->vma->vm_mm, vmf->pud);
+	if (unlikely(!pud_same(*vmf->pud, orig_pud)))
+		goto unlock;
+
+	entry = pud_mkyoung(orig_pud);
+	if (write)
+		entry = pud_mkdirty(entry);
+	haddr = vmf->address & HPAGE_PUD_MASK;
+	if (pudp_set_access_flags(vmf->vma, haddr, vmf->pud, entry, write))
+		update_mmu_cache_pud(vmf->vma, vmf->address, vmf->pud);
+
+unlock:
+	spin_unlock(vmf->ptl);
+}
+#endif /* CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
+
 void huge_pmd_set_accessed(struct vm_fault *vmf, pmd_t orig_pmd)
 {
 	pmd_t entry;
@@ -1599,6 +1770,84 @@ spinlock_t *__pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma)
 	return NULL;
 }
 
+/*
+ * Returns true if a given pud maps a thp, false otherwise.
+ *
+ * Note that if it returns true, this routine returns without unlocking page
+ * table lock. So callers must unlock it.
+ */
+spinlock_t *__pud_trans_huge_lock(pud_t *pud, struct vm_area_struct *vma)
+{
+	spinlock_t *ptl;
+
+	ptl = pud_lock(vma->vm_mm, pud);
+	if (likely(pud_trans_huge(*pud) || pud_devmap(*pud)))
+		return ptl;
+	spin_unlock(ptl);
+	return NULL;
+}
+
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+int zap_huge_pud(struct mmu_gather *tlb, struct vm_area_struct *vma,
+		 pud_t *pud, unsigned long addr)
+{
+	pud_t orig_pud;
+	spinlock_t *ptl;
+
+	ptl = __pud_trans_huge_lock(pud, vma);
+	if (!ptl)
+		return 0;
+	/*
+	 * For architectures like ppc64 we look at deposited pgtable
+	 * when calling pudp_huge_get_and_clear. So do the
+	 * pgtable_trans_huge_withdraw after finishing pudp related
+	 * operations.
+	 */
+	orig_pud = pudp_huge_get_and_clear_full(tlb->mm, addr, pud,
+			tlb->fullmm);
+	tlb_remove_pud_tlb_entry(tlb, pud, addr);
+	if (vma_is_dax(vma)) {
+		spin_unlock(ptl);
+		/* No zero page support yet */
+	} else {
+		/* No support for anonymous PUD pages yet */
+		BUG();
+	}
+	return 1;
+}
+
+static void __split_huge_pud_locked(struct vm_area_struct *vma, pud_t *pud,
+		unsigned long haddr)
+{
+	VM_BUG_ON(haddr & ~HPAGE_PUD_MASK);
+	VM_BUG_ON_VMA(vma->vm_start > haddr, vma);
+	VM_BUG_ON_VMA(vma->vm_end < haddr + HPAGE_PUD_SIZE, vma);
+	VM_BUG_ON(!pud_trans_huge(*pud) && !pud_devmap(*pud));
+
+	count_vm_event(THP_SPLIT_PMD);
+
+	pudp_huge_clear_flush_notify(vma, haddr, pud);
+}
+
+void __split_huge_pud(struct vm_area_struct *vma, pud_t *pud,
+		unsigned long address)
+{
+	spinlock_t *ptl;
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned long haddr = address & HPAGE_PUD_MASK;
+
+	mmu_notifier_invalidate_range_start(mm, haddr, haddr + HPAGE_PUD_SIZE);
+	ptl = pud_lock(mm, pud);
+	if (unlikely(!pud_trans_huge(*pud) && !pud_devmap(*pud)))
+		goto out;
+	__split_huge_pud_locked(vma, pud, haddr);
+
+out:
+	spin_unlock(ptl);
+	mmu_notifier_invalidate_range_end(mm, haddr, haddr + HPAGE_PUD_SIZE);
+}
+#endif /* CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
+
 static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
 		unsigned long haddr, pmd_t *pmd)
 {
diff --git a/mm/memory.c b/mm/memory.c
index a2acf9e..c55b799 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1001,7 +1001,7 @@ static inline int copy_pmd_range(struct mm_struct *dst_mm, struct mm_struct *src
 		next = pmd_addr_end(addr, end);
 		if (pmd_trans_huge(*src_pmd) || pmd_devmap(*src_pmd)) {
 			int err;
-			VM_BUG_ON(next-addr != HPAGE_PMD_SIZE);
+			VM_BUG_ON_VMA(next-addr != HPAGE_PMD_SIZE, vma);
 			err = copy_huge_pmd(dst_mm, src_mm,
 					    dst_pmd, src_pmd, addr, vma);
 			if (err == -ENOMEM)
@@ -1032,6 +1032,18 @@ static inline int copy_pud_range(struct mm_struct *dst_mm, struct mm_struct *src
 	src_pud = pud_offset(src_pgd, addr);
 	do {
 		next = pud_addr_end(addr, end);
+		if (pud_trans_huge(*src_pud) || pud_devmap(*src_pud)) {
+			int err;
+
+			VM_BUG_ON_VMA(next-addr != HPAGE_PUD_SIZE, vma);
+			err = copy_huge_pud(dst_mm, src_mm,
+					    dst_pud, src_pud, addr, vma);
+			if (err == -ENOMEM)
+				return -ENOMEM;
+			if (!err)
+				continue;
+			/* fall through */
+		}
 		if (pud_none_or_clear_bad(src_pud))
 			continue;
 		if (copy_pmd_range(dst_mm, src_mm, dst_pud, src_pud,
@@ -1269,9 +1281,19 @@ static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
 	pud = pud_offset(pgd, addr);
 	do {
 		next = pud_addr_end(addr, end);
+		if (pud_trans_huge(*pud) || pud_devmap(*pud)) {
+			if (next - addr != HPAGE_PUD_SIZE) {
+				VM_BUG_ON_VMA(!rwsem_is_locked(&tlb->mm->mmap_sem), vma);
+				split_huge_pud(vma, pud, addr);
+			} else if (zap_huge_pud(tlb, vma, pud, addr))
+				goto next;
+			/* fall through */
+		}
 		if (pud_none_or_clear_bad(pud))
 			continue;
 		next = zap_pmd_range(tlb, vma, pud, addr, next, details);
+next:
+		cond_resched();
 	} while (pud++, addr = next, addr != end);
 
 	return addr;
@@ -3497,6 +3519,30 @@ static inline bool vma_is_accessible(struct vm_area_struct *vma)
 	return vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE);
 }
 
+static int create_huge_pud(struct vm_fault *vmf)
+{
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	/* No support for anonymous transparent PUD pages yet */
+	if (vma_is_anonymous(vmf->vma))
+		return VM_FAULT_FALLBACK;
+	if (vmf->vma->vm_ops->huge_fault)
+		return vmf->vma->vm_ops->huge_fault(vmf);
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+	return VM_FAULT_FALLBACK;
+}
+
+static int wp_huge_pud(struct vm_fault *vmf, pud_t orig_pud)
+{
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	/* No support for anonymous transparent PUD pages yet */
+	if (vma_is_anonymous(vmf->vma))
+		return VM_FAULT_FALLBACK;
+	if (vmf->vma->vm_ops->huge_fault)
+		return vmf->vma->vm_ops->huge_fault(vmf);
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+	return VM_FAULT_FALLBACK;
+}
+
 /*
  * These routines also need to handle stuff like marking pages dirty
  * and/or accessed for architectures that don't do it in hardware (most
@@ -3612,14 +3658,41 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	};
 	struct mm_struct *mm = vma->vm_mm;
 	pgd_t *pgd;
-	pud_t *pud;
 	int ret;
 
 	pgd = pgd_offset(mm, address);
-	pud = pud_alloc(mm, pgd, address);
-	if (!pud)
+
+	vmf.pud = pud_alloc(mm, pgd, address);
+	if (!vmf.pud)
 		return VM_FAULT_OOM;
-	vmf.pmd = pmd_alloc(mm, pud, address);
+	if (pud_none(*vmf.pud) && transparent_hugepage_enabled(vma)) {
+		vmf.flags |= FAULT_FLAG_SIZE_PUD;
+		ret = create_huge_pud(&vmf);
+		if (!(ret & VM_FAULT_FALLBACK))
+			return ret;
+	} else {
+		pud_t orig_pud = *vmf.pud;
+
+		barrier();
+		if (pud_trans_huge(orig_pud) || pud_devmap(orig_pud)) {
+			unsigned int dirty = flags & FAULT_FLAG_WRITE;
+
+			vmf.flags |= FAULT_FLAG_SIZE_PUD;
+
+			/* NUMA case for anonymous PUDs would go here */
+
+			if (dirty && !pud_write(orig_pud)) {
+				ret = wp_huge_pud(&vmf, orig_pud);
+				if (!(ret & VM_FAULT_FALLBACK))
+					return ret;
+			} else {
+				huge_pud_set_accessed(&vmf, orig_pud);
+				return 0;
+			}
+		}
+	}
+
+	vmf.pmd = pmd_alloc(mm, vmf.pud, address);
 	if (!vmf.pmd)
 		return VM_FAULT_OOM;
 	if (pmd_none(*vmf.pmd) && transparent_hugepage_enabled(vma)) {
@@ -3746,13 +3819,14 @@ int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
  */
 int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
 {
+	spinlock_t *ptl;
 	pmd_t *new = pmd_alloc_one(mm, address);
 	if (!new)
 		return -ENOMEM;
 
 	smp_wmb(); /* See comment in __pte_alloc */
 
-	spin_lock(&mm->page_table_lock);
+	ptl = pud_lock(mm, pud);
 #ifndef __ARCH_HAS_4LEVEL_HACK
 	if (!pud_present(*pud)) {
 		mm_inc_nr_pmds(mm);
@@ -3766,7 +3840,7 @@ int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
 	} else /* Another has populated it */
 		pmd_free(mm, new);
 #endif /* __ARCH_HAS_4LEVEL_HACK */
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 	return 0;
 }
 #endif /* __PAGETABLE_PMD_FOLDED */
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 2072444..0376157 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -78,14 +78,32 @@ static int walk_pud_range(pgd_t *pgd, unsigned long addr, unsigned long end,
 
 	pud = pud_offset(pgd, addr);
 	do {
+ again:
 		next = pud_addr_end(addr, end);
-		if (pud_none_or_clear_bad(pud)) {
+		if (pud_none(*pud) || !walk->vma) {
 			if (walk->pte_hole)
 				err = walk->pte_hole(addr, next, walk);
 			if (err)
 				break;
 			continue;
 		}
+
+		if (walk->pud_entry) {
+			spinlock_t *ptl = pud_trans_huge_lock(pud, walk->vma);
+
+			if (ptl) {
+				err = walk->pud_entry(pud, addr, next, walk);
+				spin_unlock(ptl);
+				if (err)
+					break;
+				continue;
+			}
+		}
+
+		split_huge_pud(walk->vma, pud, addr);
+		if (pud_none(*pud))
+			goto again;
+
 		if (walk->pmd_entry || walk->pte_entry)
 			err = walk_pmd_range(pud, addr, next, walk);
 		if (err)
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index 71c5f91..4ed5908 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -123,6 +123,20 @@ pmd_t pmdp_huge_clear_flush(struct vm_area_struct *vma, unsigned long address,
 	flush_pmd_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
 	return pmd;
 }
+
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+pud_t pudp_huge_clear_flush(struct vm_area_struct *vma, unsigned long address,
+			    pud_t *pudp)
+{
+	pud_t pud;
+
+	VM_BUG_ON(address & ~HPAGE_PUD_MASK);
+	VM_BUG_ON(!pud_trans_huge(*pudp) && !pud_devmap(*pudp));
+	pud = pudp_huge_get_and_clear(vma->vm_mm, address, pudp);
+	flush_pud_tlb_range(vma, address, address + HPAGE_PUD_SIZE);
+	return pud;
+}
+#endif
 #endif
 
 #ifndef __HAVE_ARCH_PGTABLE_DEPOSIT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
