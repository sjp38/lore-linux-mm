Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3BE4B6B0260
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 20:12:34 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g62so204229962pfb.3
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 17:12:34 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ai12si908080pac.139.2016.06.30.17.12.30
        for <linux-mm@kvack.org>;
        Thu, 30 Jun 2016 17:12:30 -0700 (PDT)
Subject: [PATCH 6/6] x86: Fix stray A/D bit setting into non-present PTEs
From: Dave Hansen <dave@sr71.net>
Date: Thu, 30 Jun 2016 17:12:18 -0700
References: <20160701001209.7DA24D1C@viggo.jf.intel.com>
In-Reply-To: <20160701001209.7DA24D1C@viggo.jf.intel.com>
Message-Id: <20160701001218.3D316260@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, bp@alien8.de, ak@linux.intel.com, mhocko@suse.com, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

The Intel(R) Xeon Phi(TM) Processor x200 Family (codename: Knights
Landing) has an erratum where a processor thread setting the Accessed
or Dirty bits may not do so atomically against its checks for the
Present bit.  This may cause a thread (which is about to page fault)
to set A and/or D, even though the Present bit had already been
atomically cleared.

If the PTE is used for storing a swap index or a NUMA migration index,
the A bit could be misinterpreted as part of the swap type.  The stray
bits being set cause a software-cleared PTE to be interpreted as a
swap entry.  In some cases (like when the swap index ends up being
for a non-existent swapfile), the kernel detects the stray value
and WARN()s about it, but there is no guarantee that the kernel can
always detect it.

There are basically three things we have to do to work around this
erratum:

1. Extra TLB flushes when we clear PTEs that might be affected by
   this erratum.
2. Extra pass back over the suspect PTEs after the TLBs have been
   flushed to clear stray bits.
3. Make sure to hold ptl in pte_unmap_same() (underneath
   do_swap_page()) to keep the swap code from observing the bad
   entries between #1 and #2.

Notes:
 * The little pte++ in zap_pte_range() is to ensure that 'pte'
   points _past_ the last PTE that was cleared so that the
   whole range can be cleaned up.
 * We could do more of the new arch_*() helpers inside the
   existing TLB flush callers if we passed the old 'ptent'
   in as an argument.  That would require a more invasive
   rework, though.
 * change_pte_range() does not need to be modified.  It fully
   writes back over the PTE after clearing it.  It also does
   this inside the ptl, so the cleared PTE potentially
   containing stray bits is never visible to anyone.
 * move_ptes() does remote TLB flushes after each PTE clear.
   This is slow, but mremap() is not as important as munmap()
   Leave it simple for now.
 * could apply A/D optimization to huge pages too
 * As far as I can tell, sites that just change PTE permissions
   are OK.  They generally do some variant of:
	ptent = ptep_get_and_clear(...);
	ptent = pte_mksomething(ptent);
	set_pte_at(mm, addr, pte, ptent);
	tlb_flush...();
   This is OK because the cleared PTE (which might contain
   the stray bits) is written over by set_pte_at() and this
   all happens under the pagetable lock.
   Examples of this:
    * madvise_free_pte_range()
    * hugetlb_change_protection()
    * clear_soft_dirty()
    * move_ptes() - new PTE will not fault so will not hit
      erratum
    * change_pte_range()

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/arm/include/asm/tlb.h         |    1 
 b/arch/ia64/include/asm/tlb.h        |    1 
 b/arch/s390/include/asm/tlb.h        |    1 
 b/arch/sh/include/asm/tlb.h          |    1 
 b/arch/um/include/asm/tlb.h          |    2 
 b/arch/x86/include/asm/cpufeatures.h |    1 
 b/arch/x86/include/asm/pgtable.h     |   32 +++++++++
 b/arch/x86/include/asm/tlbflush.h    |   37 +++++++++++
 b/arch/x86/kernel/cpu/intel.c        |  113 +++++++++++++++++++++++++++++++++++
 b/include/asm-generic/tlb.h          |    4 +
 b/include/linux/mm.h                 |   17 +++++
 b/mm/memory.c                        |   12 ++-
 b/mm/mremap.c                        |    9 ++
 b/mm/rmap.c                          |    4 +
 b/mm/vmalloc.c                       |    1 
 15 files changed, 231 insertions(+), 5 deletions(-)

diff -puN arch/arm/include/asm/tlb.h~knl-leak-60-actual-fix arch/arm/include/asm/tlb.h
--- a/arch/arm/include/asm/tlb.h~knl-leak-60-actual-fix	2016-06-30 17:10:43.455287496 -0700
+++ b/arch/arm/include/asm/tlb.h	2016-06-30 17:10:43.483288766 -0700
@@ -264,6 +264,7 @@ tlb_remove_pmd_tlb_entry(struct mmu_gath
 #define pud_free_tlb(tlb, pudp, addr)	pud_free((tlb)->mm, pudp)
 
 #define tlb_migrate_finish(mm)		do { } while (0)
+#define __tlb_cleanup_pte_range(tlb, start_ptep, end_ptep) do {} while (0)
 
 #endif /* CONFIG_MMU */
 #endif
diff -puN arch/ia64/include/asm/tlb.h~knl-leak-60-actual-fix arch/ia64/include/asm/tlb.h
--- a/arch/ia64/include/asm/tlb.h~knl-leak-60-actual-fix	2016-06-30 17:10:43.457287587 -0700
+++ b/arch/ia64/include/asm/tlb.h	2016-06-30 17:10:43.484288812 -0700
@@ -254,6 +254,7 @@ __tlb_remove_tlb_entry (struct mmu_gathe
 }
 
 #define tlb_migrate_finish(mm)	platform_tlb_migrate_finish(mm)
+#define __tlb_cleanup_pte_range(tlb, start_ptep, end_ptep) do {} while (0)
 
 #define tlb_start_vma(tlb, vma)			do { } while (0)
 #define tlb_end_vma(tlb, vma)			do { } while (0)
diff -puN arch/s390/include/asm/tlb.h~knl-leak-60-actual-fix arch/s390/include/asm/tlb.h
--- a/arch/s390/include/asm/tlb.h~knl-leak-60-actual-fix	2016-06-30 17:10:43.460287723 -0700
+++ b/arch/s390/include/asm/tlb.h	2016-06-30 17:10:43.484288812 -0700
@@ -146,5 +146,6 @@ static inline void pud_free_tlb(struct m
 #define tlb_remove_tlb_entry(tlb, ptep, addr)	do { } while (0)
 #define tlb_remove_pmd_tlb_entry(tlb, pmdp, addr)	do { } while (0)
 #define tlb_migrate_finish(mm)			do { } while (0)
+#define __tlb_cleanup_pte_range(tlb, start_ptep, end_ptep) do {} while (0)
 
 #endif /* _S390_TLB_H */
diff -puN arch/sh/include/asm/tlb.h~knl-leak-60-actual-fix arch/sh/include/asm/tlb.h
--- a/arch/sh/include/asm/tlb.h~knl-leak-60-actual-fix	2016-06-30 17:10:43.461287768 -0700
+++ b/arch/sh/include/asm/tlb.h	2016-06-30 17:10:43.484288812 -0700
@@ -116,6 +116,7 @@ static inline void tlb_remove_page(struc
 #define pud_free_tlb(tlb, pudp, addr)	pud_free((tlb)->mm, pudp)
 
 #define tlb_migrate_finish(mm)		do { } while (0)
+#define __tlb_cleanup_pte_range(tlb, start_ptep, end_ptep) do {} while (0)
 
 #if defined(CONFIG_CPU_SH4) || defined(CONFIG_SUPERH64)
 extern void tlb_wire_entry(struct vm_area_struct *, unsigned long, pte_t);
diff -puN arch/um/include/asm/tlb.h~knl-leak-60-actual-fix arch/um/include/asm/tlb.h
--- a/arch/um/include/asm/tlb.h~knl-leak-60-actual-fix	2016-06-30 17:10:43.463287859 -0700
+++ b/arch/um/include/asm/tlb.h	2016-06-30 17:10:43.485288857 -0700
@@ -133,4 +133,6 @@ static inline void tlb_remove_page(struc
 
 #define tlb_migrate_finish(mm) do {} while (0)
 
+#define __tlb_cleanup_pte_range(tlb, start_ptep, end_ptep) do {} while (0)
+
 #endif
diff -puN arch/x86/include/asm/cpufeatures.h~knl-leak-60-actual-fix arch/x86/include/asm/cpufeatures.h
--- a/arch/x86/include/asm/cpufeatures.h~knl-leak-60-actual-fix	2016-06-30 17:10:43.464287904 -0700
+++ b/arch/x86/include/asm/cpufeatures.h	2016-06-30 17:10:43.485288857 -0700
@@ -310,5 +310,6 @@
 #endif
 #define X86_BUG_NULL_SEG	X86_BUG(10) /* Nulling a selector preserves the base */
 #define X86_BUG_SWAPGS_FENCE	X86_BUG(11) /* SWAPGS without input dep on GS */
+#define X86_BUG_PTE_LEAK	X86_BUG(12) /* PTE may leak A/D bits after clear */
 
 #endif /* _ASM_X86_CPUFEATURES_H */
diff -puN arch/x86/include/asm/pgtable.h~knl-leak-60-actual-fix arch/x86/include/asm/pgtable.h
--- a/arch/x86/include/asm/pgtable.h~knl-leak-60-actual-fix	2016-06-30 17:10:43.466287995 -0700
+++ b/arch/x86/include/asm/pgtable.h	2016-06-30 17:10:43.486288902 -0700
@@ -794,6 +794,12 @@ extern int ptep_test_and_clear_young(str
 extern int ptep_clear_flush_young(struct vm_area_struct *vma,
 				  unsigned long address, pte_t *ptep);
 
+#ifdef CONFIG_CPU_SUP_INTEL
+#define __HAVE_ARCH_PTEP_CLEAR_FLUSH
+extern pte_t ptep_clear_flush(struct vm_area_struct *vma,
+			      unsigned long address, pte_t *ptep);
+#endif
+
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
 static inline pte_t ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
 				       pte_t *ptep)
@@ -956,6 +962,32 @@ static inline u16 pte_flags_pkey(unsigne
 #endif
 }
 
+#ifdef CONFIG_CPU_SUP_INTEL
+/*
+ * These are all specific to working around an Intel-specific
+ * bug and the out-of-line code is all defined in intel.c.
+ */
+extern void fix_pte_leak(struct mm_struct *mm, unsigned long addr,
+			 pte_t *ptep);
+#define ARCH_HAS_FIX_PTE_LEAK 1
+static inline void arch_fix_pte_leak(struct mm_struct *mm, unsigned long addr,
+				     pte_t *ptep)
+{
+	if (static_cpu_has_bug(X86_BUG_PTE_LEAK))
+		fix_pte_leak(mm, addr, ptep);
+}
+#define ARCH_HAS_NEEDS_SWAP_PTL 1
+static inline bool arch_needs_swap_ptl(void)
+{
+	return static_cpu_has_bug(X86_BUG_PTE_LEAK);
+}
+#define ARCH_DISABLE_DEFERRED_FLUSH 1
+static inline bool arch_disable_deferred_flush(void)
+{
+	return static_cpu_has_bug(X86_BUG_PTE_LEAK);
+}
+#endif /* CONFIG_CPU_SUP_INTEL */
+
 #include <asm-generic/pgtable.h>
 #endif	/* __ASSEMBLY__ */
 
diff -puN arch/x86/include/asm/tlbflush.h~knl-leak-60-actual-fix arch/x86/include/asm/tlbflush.h
--- a/arch/x86/include/asm/tlbflush.h~knl-leak-60-actual-fix	2016-06-30 17:10:43.468288086 -0700
+++ b/arch/x86/include/asm/tlbflush.h	2016-06-30 17:10:43.486288902 -0700
@@ -324,4 +324,41 @@ static inline void reset_lazy_tlbstate(v
 	native_flush_tlb_others(mask, mm, start, end)
 #endif
 
+static inline bool intel_detect_leaked_pte(pte_t ptent)
+{
+	/*
+	 * Hardware sets the dirty bit only on writable ptes and
+	 * only on ptes where dirty is unset.
+	 */
+	if (pte_write(ptent) && !pte_dirty(ptent))
+		return true;
+	/*
+	 * The leak occurs when the hardware sees a unset A/D bit
+	 * and tries to set it.  If the PTE has both A/D bits
+	 * set, then the hardware will not be going to try to set
+	 * it and we have no chance for a leak.
+	 */
+	if (!pte_young(ptent))
+		return true;
+
+	return false;
+}
+
+#ifdef CONFIG_CPU_SUP_INTEL
+void intel_cleanup_pte_range(struct mmu_gather *tlb, pte_t *start_ptep,
+		pte_t *end_ptep);
+#define __tlb_cleanup_pte_range(tlb, start_ptep, end_ptep) do {		\
+	if (static_cpu_has_bug(X86_BUG_PTE_LEAK))			\
+		intel_cleanup_pte_range(tlb, start_ptep, end_ptep);	\
+} while (0)
+#define ARCH_FLUSH_CLEARED_PTE 1
+#define arch_flush_cleared_pte(tlb, ptent) do {				\
+	if (static_cpu_has_bug(X86_BUG_PTE_LEAK) &&			\
+	    intel_detect_leaked_pte(ptent)) {				\
+		tlb->saw_unset_a_or_d = 1;				\
+		tlb->force_batch_flush = 1;				\
+	}								\
+} while (0)
+#endif /* CONFIG_CPU_SUP_INTEL */
+
 #endif /* _ASM_X86_TLBFLUSH_H */
diff -puN arch/x86/kernel/cpu/intel.c~knl-leak-60-actual-fix arch/x86/kernel/cpu/intel.c
--- a/arch/x86/kernel/cpu/intel.c~knl-leak-60-actual-fix	2016-06-30 17:10:43.469288131 -0700
+++ b/arch/x86/kernel/cpu/intel.c	2016-06-30 17:10:43.487288948 -0700
@@ -9,10 +9,14 @@
 #include <linux/uaccess.h>
 
 #include <asm/cpufeature.h>
+#include <asm/intel-family.h>
 #include <asm/pgtable.h>
 #include <asm/msr.h>
 #include <asm/bugs.h>
 #include <asm/cpu.h>
+#include <asm/tlb.h>
+
+#include <trace/events/tlb.h>
 
 #ifdef CONFIG_X86_64
 #include <linux/topology.h>
@@ -181,6 +185,11 @@ static void early_init_intel(struct cpui
 		}
 	}
 
+	if (c->x86_model == INTEL_FAM6_XEON_PHI_KNL) {
+		pr_info_once("x86/intel: Enabling PTE leaking workaround\n");
+		set_cpu_bug(c, X86_BUG_PTE_LEAK);
+	}
+
 	/*
 	 * Intel Quark Core DevMan_001.pdf section 6.4.11
 	 * "The operating system also is required to invalidate (i.e., flush)
@@ -820,3 +829,107 @@ static const struct cpu_dev intel_cpu_de
 
 cpu_dev_register(intel_cpu_dev);
 
+/*
+ * Workaround for KNL issue:
+ *
+ * A thread that is going to page fault due to P=0, may still
+ * non atomically set A or D bits, which could corrupt swap entries.
+ * Always flush the other CPUs and clear the PTE again to avoid
+ * this leakage. We are excluded using the pagetable lock.
+ *
+ * This only needs to be called on processors that might "leak"
+ * A or D bits and have X86_BUG_PTE_LEAK set.
+ */
+void fix_pte_leak(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
+{
+	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids) {
+		flush_tlb_others(mm_cpumask(mm), mm, addr,
+				 addr + PAGE_SIZE);
+		set_pte(ptep, __pte(0));
+	}
+}
+
+/*
+ * We batched a bunch of PTE clears up.  After the TLB has been
+ * flushed for the whole batch, we might have had some leaked
+ * A or D bits and need to clear them here.
+ *
+ * This should be called with the page table lock still held.
+ *
+ * This only needs to be called on processors that might "leak"
+ * A or D bits and have X86_BUG_PTE_LEAK set.
+ */
+void intel_cleanup_pte_range(struct mmu_gather *tlb, pte_t *start_ptep,
+		pte_t *end_ptep)
+{
+	pte_t *pte;
+
+	/*
+	 * fullmm means nobody will care that we have leaked bits
+	 * laying around.  We also skip TLB flushes when doing
+	 * fullmm teardown, so the additional pte clearing would
+	 * not help the issue.
+	 */
+	if (tlb->fullmm)
+		return;
+
+	/*
+	 * If none of the PTEs hit inside intel_detect_leaked_pte(),
+	 * then we have nothing that might have been leaked and
+	 * nothing to clear.
+	 */
+	if (!tlb->saw_unset_a_or_d)
+		return;
+
+	/*
+	 * Contexts calling us with NULL ptep's do not have any
+	 * PTEs for us to go clear because they did not do any
+	 * actual TLB invalidation.
+	 */
+	if (!start_ptep || !end_ptep)
+		return;
+
+	/*
+	 * Mark that the workaround is no longer needed for
+	 * this batch.
+	 */
+	tlb->saw_unset_a_or_d = 0;
+
+	/*
+	 * Ensure that the compiler orders our set_pte()
+	 * after the preceding TLB flush no matter what.
+	 */
+	barrier();
+
+	/*
+	 * Re-clear out all the PTEs into which the hardware
+	 * may have leaked Accessed or Dirty bits.
+	 */
+	for (pte = start_ptep; pte < end_ptep; pte++)
+		set_pte(pte, __pte(0));
+}
+
+/*
+ * Kinda weird to define this in here, but we only use it for
+ * an Intel-specific issue.  This will get used on all
+ * processors (even non-Intel) if CONFIG_CPU_SUP_INTEL=y.
+ */
+pte_t ptep_clear_flush(struct vm_area_struct *vma, unsigned long address,
+		       pte_t *ptep)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pte_t pte;
+
+	pte = ptep_get_and_clear(mm, address, ptep);
+	if (pte_accessible(mm, pte)) {
+		flush_tlb_page(vma, address);
+		/*
+		 * Ensure that the compiler orders our set_pte()
+		 * after the flush_tlb_page() no matter what.
+		 */
+		barrier();
+		if (static_cpu_has_bug(X86_BUG_PTE_LEAK))
+			set_pte(ptep, __pte(0));
+	}
+	return pte;
+}
diff -puN include/asm-generic/tlb.h~knl-leak-60-actual-fix include/asm-generic/tlb.h
--- a/include/asm-generic/tlb.h~knl-leak-60-actual-fix	2016-06-30 17:10:43.471288222 -0700
+++ b/include/asm-generic/tlb.h	2016-06-30 17:10:43.489289039 -0700
@@ -226,4 +226,8 @@ static inline void __tlb_reset_range(str
 
 #define tlb_migrate_finish(mm) do {} while (0)
 
+#ifndef __tlb_cleanup_pte_range
+#define __tlb_cleanup_pte_range(tlb, start_ptep, end_ptep) do {} while (0)
+#endif
+
 #endif /* _ASM_GENERIC__TLB_H */
diff -puN include/linux/mm.h~knl-leak-60-actual-fix include/linux/mm.h
--- a/include/linux/mm.h~knl-leak-60-actual-fix	2016-06-30 17:10:43.472288267 -0700
+++ b/include/linux/mm.h	2016-06-30 17:10:43.492289175 -0700
@@ -2404,6 +2404,23 @@ static inline bool debug_guardpage_enabl
 static inline bool page_is_guard(struct page *page) { return false; }
 #endif /* CONFIG_DEBUG_PAGEALLOC */
 
+#ifndef ARCH_HAS_NEEDS_SWAP_PTL
+static inline bool arch_needs_swap_ptl(void) { return false; }
+#endif
+
+#ifndef ARCH_HAS_FIX_PTE_LEAK
+static inline void arch_fix_pte_leak(struct mm_struct *mm, unsigned long addr,
+				     pte_t *ptep) {}
+#endif
+
+#ifndef ARCH_DISABLE_DEFERRED_FLUSH
+static inline bool arch_disable_deferred_flush(void) { return false; }
+#endif
+
+#ifndef ARCH_FLUSH_CLEARED_PTE
+static inline void arch_flush_cleared_pte(struct mmu_gather *tlb, pte_t ptent) {}
+#endif
+
 #if MAX_NUMNODES > 1
 void __init setup_nr_node_ids(void);
 #else
diff -puN mm/memory.c~knl-leak-60-actual-fix mm/memory.c
--- a/mm/memory.c~knl-leak-60-actual-fix	2016-06-30 17:10:43.474288358 -0700
+++ b/mm/memory.c	2016-06-30 17:10:43.496289356 -0700
@@ -1141,6 +1141,7 @@ again:
 			ptent = ptep_get_and_clear_full(mm, addr, pte,
 							tlb->fullmm);
 			tlb_remove_tlb_entry(tlb, pte, addr);
+			arch_flush_cleared_pte(tlb, ptent);
 			if (unlikely(!page))
 				continue;
 
@@ -1166,6 +1167,7 @@ again:
 			if (unlikely(!__tlb_remove_page(tlb, page))) {
 				tlb->force_batch_flush = 1;
 				addr += PAGE_SIZE;
+				pte++;
 				break;
 			}
 			continue;
@@ -1192,8 +1194,11 @@ again:
 	arch_leave_lazy_mmu_mode();
 
 	/* Do the actual TLB flush before dropping ptl */
-	if (tlb->force_batch_flush)
-		tlb_flush_mmu_tlbonly(tlb);
+	if (tlb->force_batch_flush) {
+		bool did_flush = tlb_flush_mmu_tlbonly(tlb);
+		if (did_flush)
+			__tlb_cleanup_pte_range(tlb, start_pte, pte);
+	}
 	pte_unmap_unlock(start_pte, ptl);
 
 	/*
@@ -1965,7 +1970,8 @@ static inline int pte_unmap_same(struct
 {
 	int same = 1;
 #if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
-	if (sizeof(pte_t) > sizeof(unsigned long)) {
+	if (unlikely(arch_needs_swap_ptl() ||
+	    sizeof(pte_t) > sizeof(unsigned long))) {
 		spinlock_t *ptl = pte_lockptr(mm, pmd);
 		spin_lock(ptl);
 		same = pte_same(*page_table, orig_pte);
diff -puN mm/mremap.c~knl-leak-60-actual-fix mm/mremap.c
--- a/mm/mremap.c~knl-leak-60-actual-fix	2016-06-30 17:10:43.476288449 -0700
+++ b/mm/mremap.c	2016-06-30 17:10:43.497289401 -0700
@@ -24,6 +24,7 @@
 #include <linux/mm-arch-hooks.h>
 
 #include <asm/cacheflush.h>
+#include <asm/tlb.h>
 #include <asm/tlbflush.h>
 
 #include "internal.h"
@@ -144,10 +145,14 @@ static void move_ptes(struct vm_area_str
 
 	for (; old_addr < old_end; old_pte++, old_addr += PAGE_SIZE,
 				   new_pte++, new_addr += PAGE_SIZE) {
+		pte_t old_ptent;
+
 		if (pte_none(*old_pte))
 			continue;
-		pte = ptep_get_and_clear(mm, old_addr, old_pte);
-		pte = move_pte(pte, new_vma->vm_page_prot, old_addr, new_addr);
+		old_ptent = ptep_get_and_clear(mm, old_addr, old_pte);
+		pte = move_pte(old_ptent, new_vma->vm_page_prot,
+				old_addr, new_addr);
+		arch_fix_pte_leak(mm, old_addr, old_pte);
 		pte = move_soft_dirty_pte(pte);
 		set_pte_at(mm, new_addr, new_pte, pte);
 	}
diff -puN mm/rmap.c~knl-leak-60-actual-fix mm/rmap.c
--- a/mm/rmap.c~knl-leak-60-actual-fix	2016-06-30 17:10:43.478288539 -0700
+++ b/mm/rmap.c	2016-06-30 17:10:43.498289447 -0700
@@ -633,6 +633,10 @@ static bool should_defer_flush(struct mm
 {
 	bool should_defer = false;
 
+	/* x86 may need an immediate flush after a pte clear */
+	if (arch_disable_deferred_flush())
+		return false;
+
 	if (!(flags & TTU_BATCH_FLUSH))
 		return false;
 
diff -puN mm/vmalloc.c~knl-leak-60-actual-fix mm/vmalloc.c
--- a/mm/vmalloc.c~knl-leak-60-actual-fix	2016-06-30 17:10:43.479288585 -0700
+++ b/mm/vmalloc.c	2016-06-30 17:10:43.500289538 -0700
@@ -66,6 +66,7 @@ static void vunmap_pte_range(pmd_t *pmd,
 	pte = pte_offset_kernel(pmd, addr);
 	do {
 		pte_t ptent = ptep_get_and_clear(&init_mm, addr, pte);
+		arch_fix_pte_leak(&init_mm, addr, pte);
 		WARN_ON(!pte_none(ptent) && !pte_present(ptent));
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 }
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
