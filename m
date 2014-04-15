Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id D4D9E6B0037
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 10:41:25 -0400 (EDT)
Received: by mail-ee0-f53.google.com with SMTP id b57so7856005eek.12
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 07:41:24 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y41si25812143eel.260.2014.04.15.07.41.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 07:41:24 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/3] x86: Define _PAGE_NUMA by reusing software bits on the PMD and PTE levels
Date: Tue, 15 Apr 2014 15:41:16 +0100
Message-Id: <1397572876-1610-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1397572876-1610-1-git-send-email-mgorman@suse.de>
References: <1397572876-1610-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Mel Gorman <mgorman@suse.de>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

_PAGE_NUMA is currently an alias of _PROT_PROTNONE to trap NUMA hinting
faults on x86. Care is taken such that _PAGE_NUMA is used only in situations
where the VMA flags distinguish between NUMA hinting faults and prot_none
faults. This decision was x86-specific and conceptually it is difficult
requiring special casing to distinguish between PROTNONE and NUMA ptes
based on context.

Fundamentally, we only need the _PAGE_NUMA bit to tell the difference between
an entry that is really unmapped and a page that is protected for NUMA
hinting faults as if the PTE is not present then a fault will be trapped.

Swap PTEs on x86-64 use the bits after _PAGE_GLOBAL for the offset. This
patch shrinks the maximum possible swap size and uses the bit to uniquely
distinguish between NUMA hinting ptes and swap ptes.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/powerpc/include/asm/pgtable.h   |  5 +++
 arch/x86/include/asm/pgtable.h       | 14 +++++---
 arch/x86/include/asm/pgtable_64.h    |  8 +++++
 arch/x86/include/asm/pgtable_types.h | 66 +++++++++++++++++++-----------------
 arch/x86/mm/pageattr-test.c          |  2 +-
 include/asm-generic/pgtable.h        |  4 +--
 include/linux/swapops.h              |  2 +-
 mm/memory.c                          | 17 ++++------
 8 files changed, 69 insertions(+), 49 deletions(-)

diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index 3ebb188..cdf6679 100644
--- a/arch/powerpc/include/asm/pgtable.h
+++ b/arch/powerpc/include/asm/pgtable.h
@@ -44,6 +44,11 @@ static inline int pte_present(pte_t pte)
 	return pte_val(pte) & (_PAGE_PRESENT | _PAGE_NUMA);
 }
 
+static inline int pte_present_nonuma(pte_t pte)
+{
+	return pte_val(pte) & (_PAGE_PRESENT);
+}
+
 #define pte_numa pte_numa
 static inline int pte_numa(pte_t pte)
 {
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index bbc8b12..611dd32 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -130,7 +130,8 @@ static inline int pte_exec(pte_t pte)
 
 static inline int pte_special(pte_t pte)
 {
-	return pte_flags(pte) & _PAGE_SPECIAL;
+	return (pte_flags(pte) & (_PAGE_PRESENT|_PAGE_SPECIAL)) ==
+				 (_PAGE_PRESENT|_PAGE_SPECIAL);
 }
 
 static inline unsigned long pte_pfn(pte_t pte)
@@ -451,6 +452,11 @@ static inline int pte_present(pte_t a)
 			       _PAGE_NUMA);
 }
 
+static inline int pte_present_nonuma(pte_t a)
+{
+	return pte_flags(a) & (_PAGE_PRESENT | _PAGE_PROTNONE);
+}
+
 #define pte_accessible pte_accessible
 static inline bool pte_accessible(struct mm_struct *mm, pte_t a)
 {
@@ -859,19 +865,19 @@ static inline void update_mmu_cache_pmd(struct vm_area_struct *vma,
 
 static inline pte_t pte_swp_mksoft_dirty(pte_t pte)
 {
-	VM_BUG_ON(pte_present(pte));
+	VM_BUG_ON(pte_present_nonuma(pte));
 	return pte_set_flags(pte, _PAGE_SWP_SOFT_DIRTY);
 }
 
 static inline int pte_swp_soft_dirty(pte_t pte)
 {
-	VM_BUG_ON(pte_present(pte));
+	VM_BUG_ON(pte_present_nonuma(pte));
 	return pte_flags(pte) & _PAGE_SWP_SOFT_DIRTY;
 }
 
 static inline pte_t pte_swp_clear_soft_dirty(pte_t pte)
 {
-	VM_BUG_ON(pte_present(pte));
+	VM_BUG_ON(pte_present_nonuma(pte));
 	return pte_clear_flags(pte, _PAGE_SWP_SOFT_DIRTY);
 }
 
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index e22c1db..6d6ecd0 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -145,8 +145,16 @@ static inline int pgd_large(pgd_t pgd) { return 0; }
 /* Encode and de-code a swap entry */
 #if _PAGE_BIT_FILE < _PAGE_BIT_PROTNONE
 #define SWP_TYPE_BITS (_PAGE_BIT_FILE - _PAGE_BIT_PRESENT - 1)
+#ifdef CONFIG_NUMA_BALANCING
+/* Automatic NUMA balancing needs to be distinguishable from swap entries */
+#define SWP_OFFSET_SHIFT (_PAGE_BIT_PROTNONE + 2)
+#else
 #define SWP_OFFSET_SHIFT (_PAGE_BIT_PROTNONE + 1)
+#endif
 #else
+#ifdef CONFIG_NUMA_BALANCING
+#error Incompatible format for automatic NUMA balancing
+#endif
 #define SWP_TYPE_BITS (_PAGE_BIT_PROTNONE - _PAGE_BIT_PRESENT - 1)
 #define SWP_OFFSET_SHIFT (_PAGE_BIT_FILE + 1)
 #endif
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 1aa9ccd..f95ee23 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -16,15 +16,26 @@
 #define _PAGE_BIT_PSE		7	/* 4 MB (or 2MB) page */
 #define _PAGE_BIT_PAT		7	/* on 4KB pages */
 #define _PAGE_BIT_GLOBAL	8	/* Global TLB entry PPro+ */
-#define _PAGE_BIT_UNUSED1	9	/* available for programmer */
-#define _PAGE_BIT_IOMAP		10	/* flag used to indicate IO mapping */
-#define _PAGE_BIT_HIDDEN	11	/* hidden by kmemcheck */
+#define _PAGE_BIT_SOFTW1	9	/* available for programmer */
+#define _PAGE_BIT_SOFTW2	10	/* " */
+#define _PAGE_BIT_SOFTW3	11	/* " */
 #define _PAGE_BIT_PAT_LARGE	12	/* On 2MB or 1GB pages */
-#define _PAGE_BIT_SPECIAL	_PAGE_BIT_UNUSED1
-#define _PAGE_BIT_CPA_TEST	_PAGE_BIT_UNUSED1
-#define _PAGE_BIT_SPLITTING	_PAGE_BIT_UNUSED1 /* only valid on a PSE pmd */
+#define _PAGE_BIT_SPECIAL	_PAGE_BIT_SOFTW1
+#define _PAGE_BIT_CPA_TEST	_PAGE_BIT_SOFTW1
+#define _PAGE_BIT_SPLITTING	_PAGE_BIT_SOFTW2 /* only valid on a PSE pmd */
+#define _PAGE_BIT_IOMAP		_PAGE_BIT_SOFTW2 /* flag used to indicate IO mapping */
+#define _PAGE_BIT_HIDDEN	_PAGE_BIT_SOFTW3 /* hidden by kmemcheck */
+#define _PAGE_BIT_SOFT_DIRTY	_PAGE_BIT_SOFTW3 /* software dirty tracking */
 #define _PAGE_BIT_NX           63       /* No execute: only valid after cpuid check */
 
+/*
+ * Swap offsets on configurations that allow automatic NUMA balancing use the
+ * bits after _PAGE_BIT_GLOBAL. To uniquely distinguish NUMA hinting PTEs from
+ * swap entries, we use the first bit after _PAGE_BIT_GLOBAL and shrink the
+ * maximum possible swap space from 16TB to 8TB.
+ */
+#define _PAGE_BIT_NUMA		(_PAGE_BIT_GLOBAL+1)
+
 /* If _PAGE_BIT_PRESENT is clear, we use these: */
 /* - if the user mapped it with PROT_NONE; pte_present gives true */
 #define _PAGE_BIT_PROTNONE	_PAGE_BIT_GLOBAL
@@ -40,7 +51,7 @@
 #define _PAGE_DIRTY	(_AT(pteval_t, 1) << _PAGE_BIT_DIRTY)
 #define _PAGE_PSE	(_AT(pteval_t, 1) << _PAGE_BIT_PSE)
 #define _PAGE_GLOBAL	(_AT(pteval_t, 1) << _PAGE_BIT_GLOBAL)
-#define _PAGE_UNUSED1	(_AT(pteval_t, 1) << _PAGE_BIT_UNUSED1)
+#define _PAGE_SOFTW1	(_AT(pteval_t, 1) << _PAGE_BIT_SOFTW1)
 #define _PAGE_IOMAP	(_AT(pteval_t, 1) << _PAGE_BIT_IOMAP)
 #define _PAGE_PAT	(_AT(pteval_t, 1) << _PAGE_BIT_PAT)
 #define _PAGE_PAT_LARGE (_AT(pteval_t, 1) << _PAGE_BIT_PAT_LARGE)
@@ -61,8 +72,6 @@
  * they do not conflict with each other.
  */
 
-#define _PAGE_BIT_SOFT_DIRTY	_PAGE_BIT_HIDDEN
-
 #ifdef CONFIG_MEM_SOFT_DIRTY
 #define _PAGE_SOFT_DIRTY	(_AT(pteval_t, 1) << _PAGE_BIT_SOFT_DIRTY)
 #else
@@ -70,6 +79,21 @@
 #endif
 
 /*
+ * _PAGE_NUMA distinguishes between a numa hinting minor fault and a page
+ * that is not present. The hinting fault gathers numa placement statistics
+ * (see pte_numa()). The bit is always zero when the PTE is not present.
+ *
+ * The bit picked must be always zero when the pmd is present and not
+ * present, so that we don't lose information when we set it while
+ * atomically clearing the present bit.
+ */
+#ifdef CONFIG_NUMA_BALANCING
+#define _PAGE_NUMA	(_AT(pteval_t, 1) << _PAGE_BIT_NUMA)
+#else
+#define _PAGE_NUMA	(_AT(pteval_t, 0))
+#endif
+
+/*
  * Tracking soft dirty bit when a page goes to a swap is tricky.
  * We need a bit which can be stored in pte _and_ not conflict
  * with swap entry format. On x86 bits 6 and 7 are *not* involved
@@ -94,26 +118,6 @@
 #define _PAGE_FILE	(_AT(pteval_t, 1) << _PAGE_BIT_FILE)
 #define _PAGE_PROTNONE	(_AT(pteval_t, 1) << _PAGE_BIT_PROTNONE)
 
-/*
- * _PAGE_NUMA indicates that this page will trigger a numa hinting
- * minor page fault to gather numa placement statistics (see
- * pte_numa()). The bit picked (8) is within the range between
- * _PAGE_FILE (6) and _PAGE_PROTNONE (8) bits. Therefore, it doesn't
- * require changes to the swp entry format because that bit is always
- * zero when the pte is not present.
- *
- * The bit picked must be always zero when the pmd is present and not
- * present, so that we don't lose information when we set it while
- * atomically clearing the present bit.
- *
- * Because we shared the same bit (8) with _PAGE_PROTNONE this can be
- * interpreted as _PAGE_NUMA only in places that _PAGE_PROTNONE
- * couldn't reach, like handle_mm_fault() (see access_error in
- * arch/x86/mm/fault.c, the vma protection must not be PROT_NONE for
- * handle_mm_fault() to be invoked).
- */
-#define _PAGE_NUMA	_PAGE_PROTNONE
-
 #define _PAGE_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_USER |	\
 			 _PAGE_ACCESSED | _PAGE_DIRTY)
 #define _KERNPG_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_ACCESSED |	\
@@ -122,8 +126,8 @@
 /* Set of bits not changed in pte_modify */
 #define _PAGE_CHG_MASK	(PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT |		\
 			 _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY |	\
-			 _PAGE_SOFT_DIRTY)
-#define _HPAGE_CHG_MASK (_PAGE_CHG_MASK | _PAGE_PSE)
+			 _PAGE_SOFT_DIRTY | _PAGE_NUMA)
+#define _HPAGE_CHG_MASK (_PAGE_CHG_MASK | _PAGE_PSE | _PAGE_NUMA)
 
 #define _PAGE_CACHE_MASK	(_PAGE_PCD | _PAGE_PWT)
 #define _PAGE_CACHE_WB		(0)
diff --git a/arch/x86/mm/pageattr-test.c b/arch/x86/mm/pageattr-test.c
index 461bc82..6629f39 100644
--- a/arch/x86/mm/pageattr-test.c
+++ b/arch/x86/mm/pageattr-test.c
@@ -35,7 +35,7 @@ enum {
 
 static int pte_testbit(pte_t pte)
 {
-	return pte_flags(pte) & _PAGE_UNUSED1;
+	return pte_flags(pte) & _PAGE_SOFTW1;
 }
 
 struct split_state {
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 38a7437..d2b92be 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -657,7 +657,7 @@ static inline int pmd_trans_unstable(pmd_t *pmd)
 static inline int pte_numa(pte_t pte)
 {
 	return (pte_flags(pte) &
-		(_PAGE_NUMA|_PAGE_PRESENT)) == _PAGE_NUMA;
+		(_PAGE_NUMA|_PAGE_PROTNONE|_PAGE_PRESENT)) == _PAGE_NUMA;
 }
 #endif
 
@@ -665,7 +665,7 @@ static inline int pte_numa(pte_t pte)
 static inline int pmd_numa(pmd_t pmd)
 {
 	return (pmd_flags(pmd) &
-		(_PAGE_NUMA|_PAGE_PRESENT)) == _PAGE_NUMA;
+		(_PAGE_NUMA|_PAGE_PROTNONE|_PAGE_PRESENT)) == _PAGE_NUMA;
 }
 #endif
 
diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index c0f7526..6adfb7b 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -54,7 +54,7 @@ static inline pgoff_t swp_offset(swp_entry_t entry)
 /* check whether a pte points to a swap entry */
 static inline int is_swap_pte(pte_t pte)
 {
-	return !pte_none(pte) && !pte_present(pte) && !pte_file(pte);
+	return !pte_none(pte) && !pte_present_nonuma(pte) && !pte_file(pte);
 }
 #endif
 
diff --git a/mm/memory.c b/mm/memory.c
index 22dfa61..f1639a2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -746,7 +746,7 @@ struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 	unsigned long pfn = pte_pfn(pte);
 
 	if (HAVE_PTE_SPECIAL) {
-		if (likely(!pte_special(pte)))
+		if (likely(!pte_special(pte) || pte_numa(pte)))
 			goto check_pfn;
 		if (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP))
 			return NULL;
@@ -772,14 +772,15 @@ struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 		}
 	}
 
-	if (is_zero_pfn(pfn))
-		return NULL;
 check_pfn:
 	if (unlikely(pfn > highest_memmap_pfn)) {
 		print_bad_pte(vma, addr, pte, NULL);
 		return NULL;
 	}
 
+	if (is_zero_pfn(pfn))
+		return NULL;
+
 	/*
 	 * NOTE! We still have PageReserved() pages in the page tables.
 	 * eg. VDSO mappings can cause them to exist.
@@ -1715,13 +1716,9 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			(VM_MAYREAD | VM_MAYWRITE) : (VM_READ | VM_WRITE);
 
 	/*
-	 * If FOLL_FORCE and FOLL_NUMA are both set, handle_mm_fault
-	 * would be called on PROT_NONE ranges. We must never invoke
-	 * handle_mm_fault on PROT_NONE ranges or the NUMA hinting
-	 * page faults would unprotect the PROT_NONE ranges if
-	 * _PAGE_NUMA and _PAGE_PROTNONE are sharing the same pte/pmd
-	 * bitflag. So to avoid that, don't set FOLL_NUMA if
-	 * FOLL_FORCE is set.
+	 * If FOLL_FORCE is set then do not force a full fault as the hinting
+	 * fault information is unrelated to the reference behaviour of a task
+	 * using the address space
 	 */
 	if (!(gup_flags & FOLL_FORCE))
 		gup_flags |= FOLL_NUMA;
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
