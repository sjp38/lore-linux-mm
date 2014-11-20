Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8E5336B0085
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 05:20:03 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id bs8so8170591wib.4
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 02:20:03 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b4si3805575wie.0.2014.11.20.02.20.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Nov 2014 02:20:02 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 06/10] mm: Remove remaining references to NUMA hinting bits and helpers
Date: Thu, 20 Nov 2014 10:19:46 +0000
Message-Id: <1416478790-27522-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1416478790-27522-1-git-send-email-mgorman@suse.de>
References: <1416478790-27522-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>

This patch removes the NUMA PTE bits and associated helpers. As a side-effect
it increases the maximum possible swap space on x86-64.

One potential source of problems is races between the marking of PTEs
PROT_NONE, NUMA hinting faults and migration. It must be guaranteed that
a PTE being protected is not faulted in parallel, seen as a pte_none and
corrupting memory. The base case is safe but transhuge has problems in the
past due to an different migration mechanism and a dependance on page lock
to serialise migrations and warrants a closer look.

task_work hinting update			parallel fault
------------------------			--------------
change_pmd_range
  change_huge_pmd
    __pmd_trans_huge_lock
      pmdp_get_and_clear
						__handle_mm_fault
						pmd_none
						  do_huge_pmd_anonymous_page
						  read? pmd_lock blocks until hinting complete, fail !pmd_none test
						  write? __do_huge_pmd_anonymous_page acquires pmd_lock, checks pmd_none
      pmd_modify
      set_pmd_at

task_work hinting update			parallel migration
------------------------			------------------
change_pmd_range
  change_huge_pmd
    __pmd_trans_huge_lock
      pmdp_get_and_clear
						__handle_mm_fault
						  do_huge_pmd_numa_page
						    migrate_misplaced_transhuge_page
						    pmd_lock waits for updates to complete, recheck pmd_same
      pmd_modify
      set_pmd_at

Both of those are safe and the case where a transhuge page is inserted
during a protection update is unchanged. The case where two processes try
migrating at the same time is unchanged by this series so should still be
ok. I could not find a case where we are accidentally depending on the
PTE not being cleared and flushed. If one is missed, it'll manifest as
corruption problems that start triggering shortly after this series is
merged and only happen when NUMA balancing is enabled.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/powerpc/include/asm/pgtable.h    |  54 +-----------
 arch/powerpc/include/asm/pte-common.h |   5 --
 arch/powerpc/include/asm/pte-hash64.h |   6 --
 arch/x86/include/asm/pgtable.h        |  22 +----
 arch/x86/include/asm/pgtable_64.h     |   5 --
 arch/x86/include/asm/pgtable_types.h  |  41 +--------
 include/asm-generic/pgtable.h         | 155 ----------------------------------
 include/linux/swapops.h               |   2 +-
 8 files changed, 7 insertions(+), 283 deletions(-)

diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index 452c3b4..2e074e7 100644
--- a/arch/powerpc/include/asm/pgtable.h
+++ b/arch/powerpc/include/asm/pgtable.h
@@ -49,64 +49,12 @@ static inline int pmd_protnone_numa(pmd_t pmd)
 {
 	return pte_protnone_numa(pmd_pte(pmd));
 }
-
-static inline int pte_present(pte_t pte)
-{
-	return pte_val(pte) & _PAGE_NUMA_MASK;
-}
-
-#define pte_present_nonuma pte_present_nonuma
-static inline int pte_present_nonuma(pte_t pte)
-{
-	return pte_val(pte) & (_PAGE_PRESENT);
-}
-
-#define ptep_set_numa ptep_set_numa
-static inline void ptep_set_numa(struct mm_struct *mm, unsigned long addr,
-				 pte_t *ptep)
-{
-	if ((pte_val(*ptep) & _PAGE_PRESENT) == 0)
-		VM_BUG_ON(1);
-
-	pte_update(mm, addr, ptep, _PAGE_PRESENT, _PAGE_NUMA, 0);
-	return;
-}
-
-#define pmdp_set_numa pmdp_set_numa
-static inline void pmdp_set_numa(struct mm_struct *mm, unsigned long addr,
-				 pmd_t *pmdp)
-{
-	if ((pmd_val(*pmdp) & _PAGE_PRESENT) == 0)
-		VM_BUG_ON(1);
-
-	pmd_hugepage_update(mm, addr, pmdp, _PAGE_PRESENT, _PAGE_NUMA);
-	return;
-}
-
-/*
- * Generic NUMA pte helpers expect pteval_t and pmdval_t types to exist
- * which was inherited from x86. For the purposes of powerpc pte_basic_t and
- * pmd_t are equivalent
- */
-#define pteval_t pte_basic_t
-#define pmdval_t pmd_t
-static inline pteval_t ptenuma_flags(pte_t pte)
-{
-	return pte_val(pte) & _PAGE_NUMA_MASK;
-}
-
-static inline pmdval_t pmdnuma_flags(pmd_t pmd)
-{
-	return pmd_val(pmd) & _PAGE_NUMA_MASK;
-}
-
-# else
+#endif /* CONFIG_NUMA_BALANCING */
 
 static inline int pte_present(pte_t pte)
 {
 	return pte_val(pte) & _PAGE_PRESENT;
 }
-#endif /* CONFIG_NUMA_BALANCING */
 
 /* Conversion functions: convert a page and protection to a page entry,
  * and a page entry and page directory to the page they refer to.
diff --git a/arch/powerpc/include/asm/pte-common.h b/arch/powerpc/include/asm/pte-common.h
index e040c35..8d1569c 100644
--- a/arch/powerpc/include/asm/pte-common.h
+++ b/arch/powerpc/include/asm/pte-common.h
@@ -98,11 +98,6 @@ extern unsigned long bad_call_to_PMD_PAGE_SIZE(void);
 			 _PAGE_USER | _PAGE_ACCESSED | \
 			 _PAGE_RW | _PAGE_HWWRITE | _PAGE_DIRTY | _PAGE_EXEC)
 
-#ifdef CONFIG_NUMA_BALANCING
-/* Mask of bits that distinguish present and numa ptes */
-#define _PAGE_NUMA_MASK (_PAGE_NUMA|_PAGE_PRESENT)
-#endif
-
 /*
  * We define 2 sets of base prot bits, one for basic pages (ie,
  * cacheable kernel and user pages) and one for non cacheable
diff --git a/arch/powerpc/include/asm/pte-hash64.h b/arch/powerpc/include/asm/pte-hash64.h
index 2505d8e..55aea0c 100644
--- a/arch/powerpc/include/asm/pte-hash64.h
+++ b/arch/powerpc/include/asm/pte-hash64.h
@@ -27,12 +27,6 @@
 #define _PAGE_RW		0x0200 /* software: user write access allowed */
 #define _PAGE_BUSY		0x0800 /* software: PTE & hash are busy */
 
-/*
- * Used for tracking numa faults
- */
-#define _PAGE_NUMA	0x00000010 /* Gather numa placement stats */
-
-
 /* No separate kernel read-only */
 #define _PAGE_KERNEL_RW		(_PAGE_RW | _PAGE_DIRTY) /* user access blocked by key */
 #define _PAGE_KERNEL_RO		 _PAGE_KERNEL_RW
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 613cd00..f8799e0 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -299,7 +299,7 @@ static inline pmd_t pmd_mkwrite(pmd_t pmd)
 
 static inline pmd_t pmd_mknotpresent(pmd_t pmd)
 {
-	return pmd_clear_flags(pmd, _PAGE_PRESENT);
+	return pmd_clear_flags(pmd, _PAGE_PRESENT | _PAGE_PROTNONE);
 }
 
 #ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
@@ -457,13 +457,6 @@ static inline int pte_same(pte_t a, pte_t b)
 
 static inline int pte_present(pte_t a)
 {
-	return pte_flags(a) & (_PAGE_PRESENT | _PAGE_PROTNONE |
-			       _PAGE_NUMA);
-}
-
-#define pte_present_nonuma pte_present_nonuma
-static inline int pte_present_nonuma(pte_t a)
-{
 	return pte_flags(a) & (_PAGE_PRESENT | _PAGE_PROTNONE);
 }
 
@@ -473,7 +466,7 @@ static inline bool pte_accessible(struct mm_struct *mm, pte_t a)
 	if (pte_flags(a) & _PAGE_PRESENT)
 		return true;
 
-	if ((pte_flags(a) & (_PAGE_PROTNONE | _PAGE_NUMA)) &&
+	if ((pte_flags(a) & _PAGE_PROTNONE) &&
 			mm_tlb_flush_pending(mm))
 		return true;
 
@@ -493,8 +486,7 @@ static inline int pmd_present(pmd_t pmd)
 	 * the _PAGE_PSE flag will remain set at all times while the
 	 * _PAGE_PRESENT bit is clear).
 	 */
-	return pmd_flags(pmd) & (_PAGE_PRESENT | _PAGE_PROTNONE | _PAGE_PSE |
-				 _PAGE_NUMA);
+	return pmd_flags(pmd) & (_PAGE_PRESENT | _PAGE_PROTNONE | _PAGE_PSE);
 }
 
 #ifdef CONFIG_NUMA_BALANCING
@@ -569,11 +561,6 @@ static inline pte_t *pte_offset_kernel(pmd_t *pmd, unsigned long address)
 
 static inline int pmd_bad(pmd_t pmd)
 {
-#ifdef CONFIG_NUMA_BALANCING
-	/* pmd_numa check */
-	if ((pmd_flags(pmd) & (_PAGE_NUMA|_PAGE_PRESENT)) == _PAGE_NUMA)
-		return 0;
-#endif
 	return (pmd_flags(pmd) & ~_PAGE_USER) != _KERNPG_TABLE;
 }
 
@@ -892,19 +879,16 @@ static inline void update_mmu_cache_pmd(struct vm_area_struct *vma,
 #ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
 static inline pte_t pte_swp_mksoft_dirty(pte_t pte)
 {
-	VM_BUG_ON(pte_present_nonuma(pte));
 	return pte_set_flags(pte, _PAGE_SWP_SOFT_DIRTY);
 }
 
 static inline int pte_swp_soft_dirty(pte_t pte)
 {
-	VM_BUG_ON(pte_present_nonuma(pte));
 	return pte_flags(pte) & _PAGE_SWP_SOFT_DIRTY;
 }
 
 static inline pte_t pte_swp_clear_soft_dirty(pte_t pte)
 {
-	VM_BUG_ON(pte_present_nonuma(pte));
 	return pte_clear_flags(pte, _PAGE_SWP_SOFT_DIRTY);
 }
 #endif
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 4572b2f..06ffca8 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -146,12 +146,7 @@ static inline int pgd_large(pgd_t pgd) { return 0; }
 
 /* Encode and de-code a swap entry */
 #define SWP_TYPE_BITS (_PAGE_BIT_FILE - _PAGE_BIT_PRESENT - 1)
-#ifdef CONFIG_NUMA_BALANCING
-/* Automatic NUMA balancing needs to be distinguishable from swap entries */
-#define SWP_OFFSET_SHIFT (_PAGE_BIT_PROTNONE + 2)
-#else
 #define SWP_OFFSET_SHIFT (_PAGE_BIT_PROTNONE + 1)
-#endif
 
 #define MAX_SWAPFILES_CHECK() BUILD_BUG_ON(MAX_SWAPFILES_SHIFT > SWP_TYPE_BITS)
 
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 0778964..d299cdd 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -27,14 +27,6 @@
 #define _PAGE_BIT_SOFT_DIRTY	_PAGE_BIT_SOFTW3 /* software dirty tracking */
 #define _PAGE_BIT_NX           63       /* No execute: only valid after cpuid check */
 
-/*
- * Swap offsets on configurations that allow automatic NUMA balancing use the
- * bits after _PAGE_BIT_GLOBAL. To uniquely distinguish NUMA hinting PTEs from
- * swap entries, we use the first bit after _PAGE_BIT_GLOBAL and shrink the
- * maximum possible swap space from 16TB to 8TB.
- */
-#define _PAGE_BIT_NUMA		(_PAGE_BIT_GLOBAL+1)
-
 /* If _PAGE_BIT_PRESENT is clear, we use these: */
 /* - if the user mapped it with PROT_NONE; pte_present gives true */
 #define _PAGE_BIT_PROTNONE	_PAGE_BIT_GLOBAL
@@ -78,21 +70,6 @@
 #endif
 
 /*
- * _PAGE_NUMA distinguishes between a numa hinting minor fault and a page
- * that is not present. The hinting fault gathers numa placement statistics
- * (see pte_numa()). The bit is always zero when the PTE is not present.
- *
- * The bit picked must be always zero when the pmd is present and not
- * present, so that we don't lose information when we set it while
- * atomically clearing the present bit.
- */
-#ifdef CONFIG_NUMA_BALANCING
-#define _PAGE_NUMA	(_AT(pteval_t, 1) << _PAGE_BIT_NUMA)
-#else
-#define _PAGE_NUMA	(_AT(pteval_t, 0))
-#endif
-
-/*
  * Tracking soft dirty bit when a page goes to a swap is tricky.
  * We need a bit which can be stored in pte _and_ not conflict
  * with swap entry format. On x86 bits 6 and 7 are *not* involved
@@ -125,8 +102,8 @@
 /* Set of bits not changed in pte_modify */
 #define _PAGE_CHG_MASK	(PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT |		\
 			 _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY |	\
-			 _PAGE_SOFT_DIRTY | _PAGE_NUMA)
-#define _HPAGE_CHG_MASK (_PAGE_CHG_MASK | _PAGE_PSE | _PAGE_NUMA)
+			 _PAGE_SOFT_DIRTY)
+#define _HPAGE_CHG_MASK (_PAGE_CHG_MASK | _PAGE_PSE)
 
 #define _PAGE_CACHE_MASK	(_PAGE_PCD | _PAGE_PWT)
 #define _PAGE_CACHE_WB		(0)
@@ -324,20 +301,6 @@ static inline pteval_t pte_flags(pte_t pte)
 	return native_pte_val(pte) & PTE_FLAGS_MASK;
 }
 
-#ifdef CONFIG_NUMA_BALANCING
-/* Set of bits that distinguishes present, prot_none and numa ptes */
-#define _PAGE_NUMA_MASK (_PAGE_NUMA|_PAGE_PROTNONE|_PAGE_PRESENT)
-static inline pteval_t ptenuma_flags(pte_t pte)
-{
-	return pte_flags(pte) & _PAGE_NUMA_MASK;
-}
-
-static inline pmdval_t pmdnuma_flags(pmd_t pmd)
-{
-	return pmd_flags(pmd) & _PAGE_NUMA_MASK;
-}
-#endif /* CONFIG_NUMA_BALANCING */
-
 #define pgprot_val(x)	((x).pgprot)
 #define __pgprot(x)	((pgprot_t) { (x) } )
 
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 7e74122..323e914 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -233,10 +233,6 @@ static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_b)
 # define pte_accessible(mm, pte)	((void)(pte), 1)
 #endif
 
-#ifndef pte_present_nonuma
-#define pte_present_nonuma(pte) pte_present(pte)
-#endif
-
 #ifndef flush_tlb_fix_spurious_fault
 #define flush_tlb_fix_spurious_fault(vma, address) flush_tlb_page(vma, address)
 #endif
@@ -696,157 +692,6 @@ static inline int pmd_protnone_numa(pmd_t pmd)
 }
 #endif /* CONFIG_NUMA_BALANCING */
 
-#ifdef CONFIG_NUMA_BALANCING
-/*
- * _PAGE_NUMA distinguishes between an unmapped page table entry, an entry that
- * is protected for PROT_NONE and a NUMA hinting fault entry. If the
- * architecture defines __PAGE_PROTNONE then it should take that into account
- * but those that do not can rely on the fact that the NUMA hinting scanner
- * skips inaccessible VMAs.
- *
- * pte/pmd_present() returns true if pte/pmd_numa returns true. Page
- * fault triggers on those regions if pte/pmd_numa returns true
- * (because _PAGE_PRESENT is not set).
- */
-#ifndef pte_numa
-static inline int pte_numa(pte_t pte)
-{
-	return ptenuma_flags(pte) == _PAGE_NUMA;
-}
-#endif
-
-#ifndef pmd_numa
-static inline int pmd_numa(pmd_t pmd)
-{
-	return pmdnuma_flags(pmd) == _PAGE_NUMA;
-}
-#endif
-
-/*
- * pte/pmd_mknuma sets the _PAGE_ACCESSED bitflag automatically
- * because they're called by the NUMA hinting minor page fault. If we
- * wouldn't set the _PAGE_ACCESSED bitflag here, the TLB miss handler
- * would be forced to set it later while filling the TLB after we
- * return to userland. That would trigger a second write to memory
- * that we optimize away by setting _PAGE_ACCESSED here.
- */
-#ifndef pte_mknonnuma
-static inline pte_t pte_mknonnuma(pte_t pte)
-{
-	pteval_t val = pte_val(pte);
-
-	val &= ~_PAGE_NUMA;
-	val |= (_PAGE_PRESENT|_PAGE_ACCESSED);
-	return __pte(val);
-}
-#endif
-
-#ifndef pmd_mknonnuma
-static inline pmd_t pmd_mknonnuma(pmd_t pmd)
-{
-	pmdval_t val = pmd_val(pmd);
-
-	val &= ~_PAGE_NUMA;
-	val |= (_PAGE_PRESENT|_PAGE_ACCESSED);
-
-	return __pmd(val);
-}
-#endif
-
-#ifndef pte_mknuma
-static inline pte_t pte_mknuma(pte_t pte)
-{
-	pteval_t val = pte_val(pte);
-
-	VM_BUG_ON(!(val & _PAGE_PRESENT));
-
-	val &= ~_PAGE_PRESENT;
-	val |= _PAGE_NUMA;
-
-	return __pte(val);
-}
-#endif
-
-#ifndef ptep_set_numa
-static inline void ptep_set_numa(struct mm_struct *mm, unsigned long addr,
-				 pte_t *ptep)
-{
-	pte_t ptent = *ptep;
-
-	ptent = pte_mknuma(ptent);
-	set_pte_at(mm, addr, ptep, ptent);
-	return;
-}
-#endif
-
-#ifndef pmd_mknuma
-static inline pmd_t pmd_mknuma(pmd_t pmd)
-{
-	pmdval_t val = pmd_val(pmd);
-
-	val &= ~_PAGE_PRESENT;
-	val |= _PAGE_NUMA;
-
-	return __pmd(val);
-}
-#endif
-
-#ifndef pmdp_set_numa
-static inline void pmdp_set_numa(struct mm_struct *mm, unsigned long addr,
-				 pmd_t *pmdp)
-{
-	pmd_t pmd = *pmdp;
-
-	pmd = pmd_mknuma(pmd);
-	set_pmd_at(mm, addr, pmdp, pmd);
-	return;
-}
-#endif
-#else
-static inline int pmd_numa(pmd_t pmd)
-{
-	return 0;
-}
-
-static inline int pte_numa(pte_t pte)
-{
-	return 0;
-}
-
-static inline pte_t pte_mknonnuma(pte_t pte)
-{
-	return pte;
-}
-
-static inline pmd_t pmd_mknonnuma(pmd_t pmd)
-{
-	return pmd;
-}
-
-static inline pte_t pte_mknuma(pte_t pte)
-{
-	return pte;
-}
-
-static inline void ptep_set_numa(struct mm_struct *mm, unsigned long addr,
-				 pte_t *ptep)
-{
-	return;
-}
-
-
-static inline pmd_t pmd_mknuma(pmd_t pmd)
-{
-	return pmd;
-}
-
-static inline void pmdp_set_numa(struct mm_struct *mm, unsigned long addr,
-				 pmd_t *pmdp)
-{
-	return ;
-}
-#endif /* CONFIG_NUMA_BALANCING */
-
 #endif /* CONFIG_MMU */
 
 #endif /* !__ASSEMBLY__ */
diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index 6adfb7b..2b1fa56 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -54,7 +54,7 @@ static inline pgoff_t swp_offset(swp_entry_t entry)
 /* check whether a pte points to a swap entry */
 static inline int is_swap_pte(pte_t pte)
 {
-	return !pte_none(pte) && !pte_present_nonuma(pte) && !pte_file(pte);
+	return !pte_none(pte) && !pte_file(pte);
 }
 #endif
 
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
