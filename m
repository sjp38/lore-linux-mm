Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0B7916B0253
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 11:14:31 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a69so108534734pfa.1
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 08:14:31 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id u29si6417363pfi.150.2016.06.16.08.14.29
        for <linux-mm@kvack.org>;
        Thu, 16 Jun 2016 08:14:29 -0700 (PDT)
From: Lukasz Anaczkowski <lukasz.anaczkowski@intel.com>
Subject: [PATCH v3] Linux VM workaround for Knights Landing A/D leak
Date: Thu, 16 Jun 2016 17:14:02 +0200
Message-Id: <1466090042-30908-1-git-send-email-lukasz.anaczkowski@intel.com>
In-Reply-To: <1465923672-14232-1-git-send-email-lukasz.anaczkowski@intel.com>
References: <1465923672-14232-1-git-send-email-lukasz.anaczkowski@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, mingo@redhat.com, tglx@linutronix.de, dave.hansen@linux.intel.com, ak@linux.intel.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: lukasz.anaczkowski@intel.com, harish.srinivasappa@intel.com, lukasz.odzioba@intel.com, grzegorz.andrejczuk@intel.com, lukasz.daniluk@intel.com

From: Andi Kleen <ak@linux.intel.com>

Knights Landing has an issue that a thread setting A or D bits
may not do so atomically against checking the present bit.
A thread which is going to page fault may still set those
bits, even though the present bit was already atomically cleared.

This implies that when the kernel clears present atomically,
some time later the supposed to be zero entry could be corrupted
with stray A or D bits.

Since the PTE could be already used for storing a swap index,
or a NUMA migration index, this cannot be tolerated. Most
of the time the kernel detects the problem, but in some
rare cases it may not.

This patch enforces that the page unmap path in vmscan/direct reclaim
always flushes other CPUs after clearing each page, and also
clears the PTE again after the flush. A new memory barrier may be
required, but this code is at least consistent with all
the existing uses in the kernel. If we decide that we need a new
barrier, it can added at the same time as the rest of the tree.

For reclaim this brings the performance back to before Mel's
flushing changes, but for unmap it disables batching.

This makes sure any leaked A/D bits are immediately cleared before the entry
is used for something else.

Any parallel faults that check for entry is zero may loop,
but they should eventually recover after the entry is written.

Also other users may spin in the page table lock until we
"fixed" the PTE. This is ensured by always taking the page table lock
even for the swap cache case. Previously this was only done
on architectures with non atomic PTE accesses (such as 32bit PTE),
but now it is also done when this bug workaround is active.

I audited apply_pte_range and other users of arch_enter_lazy...
and they seem to all not clear the present bit.

Right now the extra flush is done in the low level
architecture code, while the higher level code still
does batched TLB flush. This means there is always one extra
unnecessary TLB flush now. As a followon optimization
this could be avoided by telling the callers that
the flush already happenend.

The official erratum will be posted hopefully by the end of July'16.

v3 (Lukasz Anaczkowski):
    () Improved documentation
    () Removed unnecessary declaration and call to fix_pte_leak from hugetlb.h
    () Moved fix_pte_leak() definition from tlb.c to intel.c
    () Replaced boot_cpu_has_bug() with static_cpu_has_bug()
    () pr_info_once instead of pr_info
    () Fix applies only to 64-bit kernels as Knights Landing does not
       support 32-bit kernels

v2 (Lukasz Anaczkowski):
    () added call to smp_mb__after_atomic() to synchornize with
       switch_mm, based on Nadav's comment
    () fixed compilation breakage

Signed-off-by: Andi Kleen <ak@linux.intel.com>
Signed-off-by: Lukasz Anaczkowski <lukasz.anaczkowski@intel.com>
---
 arch/x86/include/asm/cpufeatures.h |  1 +
 arch/x86/include/asm/pgtable.h     | 10 ++++++++++
 arch/x86/include/asm/pgtable_64.h  | 16 +++++++++++++++
 arch/x86/kernel/cpu/intel.c        | 41 ++++++++++++++++++++++++++++++++++++++
 include/linux/mm.h                 |  4 ++++
 mm/memory.c                        |  3 ++-
 6 files changed, 74 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/cpufeatures.h b/arch/x86/include/asm/cpufeatures.h
index 4a41348..2c48011 100644
--- a/arch/x86/include/asm/cpufeatures.h
+++ b/arch/x86/include/asm/cpufeatures.h
@@ -303,6 +303,7 @@
 #define X86_BUG_SYSRET_SS_ATTRS	X86_BUG(8) /* SYSRET doesn't fix up SS attrs */
 #define X86_BUG_NULL_SEG	X86_BUG(9) /* Nulling a selector preserves the base */
 #define X86_BUG_SWAPGS_FENCE	X86_BUG(10) /* SWAPGS without input dep on GS */
+#define X86_BUG_PTE_LEAK        X86_BUG(11) /* PTE may leak A/D bits after clear */
 
 
 #ifdef CONFIG_X86_32
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 1a27396..14abcb3 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -794,11 +794,21 @@ extern int ptep_test_and_clear_young(struct vm_area_struct *vma,
 extern int ptep_clear_flush_young(struct vm_area_struct *vma,
 				  unsigned long address, pte_t *ptep);
 
+#if defined(CONFIG_X86_64) && defined(CONFIG_CPU_SUP_INTEL)
+extern void fix_pte_leak(struct mm_struct *mm, unsigned long addr,
+			 pte_t *ptep);
+#else
+static inline void fix_pte_leak(struct mm_struct *mm, unsigned long addr,
+				pte_t *ptep) {}
+#endif
+
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
 static inline pte_t ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
 				       pte_t *ptep)
 {
 	pte_t pte = native_ptep_get_and_clear(ptep);
+	if (static_cpu_has_bug(X86_BUG_PTE_LEAK))
+		fix_pte_leak(mm, addr, ptep);
 	pte_update(mm, addr, ptep);
 	return pte;
 }
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 2ee7811..be7d63c 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -178,6 +178,22 @@ extern void cleanup_highmap(void);
 extern void init_extra_mapping_uc(unsigned long phys, unsigned long size);
 extern void init_extra_mapping_wb(unsigned long phys, unsigned long size);
 
+/*
+ * Intel Xeon Phi x200 codenamed Knights Landing has an issue that a thread
+ * setting A or D bits may not do so atomically against checking the present
+ * bit. A thread which is going to page fault may still set those
+ * bits, even though the present bit was already atomically cleared.
+ *
+ * This implies that when the kernel clears present atomically,
+ * some time later the supposed to be zero entry could be corrupted
+ * with stray A or D bits.
+ */
+#define ARCH_HAS_NEEDS_SWAP_PTL 1
+static inline bool arch_needs_swap_ptl(void)
+{
+       return static_cpu_has_bug(X86_BUG_PTE_LEAK);
+}
+
 #endif /* !__ASSEMBLY__ */
 
 #endif /* _ASM_X86_PGTABLE_64_H */
diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
index 6e2ffbe..b5f5bab 100644
--- a/arch/x86/kernel/cpu/intel.c
+++ b/arch/x86/kernel/cpu/intel.c
@@ -7,12 +7,17 @@
 #include <linux/thread_info.h>
 #include <linux/module.h>
 #include <linux/uaccess.h>
+#include <linux/mm_types.h>
 
 #include <asm/cpufeature.h>
 #include <asm/pgtable.h>
 #include <asm/msr.h>
 #include <asm/bugs.h>
 #include <asm/cpu.h>
+#include <asm/intel-family.h>
+#include <asm/tlbflush.h>
+
+#include <trace/events/tlb.h>
 
 #ifdef CONFIG_X86_64
 #include <linux/topology.h>
@@ -60,6 +65,35 @@ void check_mpx_erratum(struct cpuinfo_x86 *c)
 	}
 }
 
+#ifdef CONFIG_X86_64
+/*
+ * Knights Landing has an issue that a thread setting A or D bits
+ * may not do so atomically against checking the present bit.
+ * A thread which is going to page fault may still set those
+ * bits, even though the present bit was already atomically cleared.
+ *
+ * Entering here, the current CPU just cleared the PTE.  But,
+ * another thread may have raced and set the A or D bits, or be
+ * _about_ to set the bits.  Shooting their TLB entry down will
+ * ensure they see the cleared PTE and will not set A or D and
+ * won't corrupt swap entries.
+ */
+void fix_pte_leak(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
+{
+	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids) {
+		trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
+		flush_tlb_others(mm_cpumask(mm), mm, addr,
+				 addr + PAGE_SIZE);
+		mb();
+		/*
+		 * Clear the PTE one more time, in case the other thread set A/D
+		 * before we sent the TLB flush.
+		 */
+		set_pte(ptep, __pte(0));
+	}
+}
+#endif
+
 static void early_init_intel(struct cpuinfo_x86 *c)
 {
 	u64 misc_enable;
@@ -181,6 +215,13 @@ static void early_init_intel(struct cpuinfo_x86 *c)
 		}
 	}
 
+#ifdef CONFIG_X86_64
+	if (c->x86_model == INTEL_FAM6_XEON_PHI_KNL) {
+		pr_info_once("x86/intel: Enabling PTE leaking workaround\n");
+		set_cpu_bug(c, X86_BUG_PTE_LEAK);
+	}
+#endif
+
 	/*
 	 * Intel Quark Core DevMan_001.pdf section 6.4.11
 	 * "The operating system also is required to invalidate (i.e., flush)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5df5feb..5c80fe09 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2404,6 +2404,10 @@ static inline bool debug_guardpage_enabled(void) { return false; }
 static inline bool page_is_guard(struct page *page) { return false; }
 #endif /* CONFIG_DEBUG_PAGEALLOC */
 
+#ifndef ARCH_HAS_NEEDS_SWAP_PTL
+static inline bool arch_needs_swap_ptl(void) { return false; }
+#endif
+
 #if MAX_NUMNODES > 1
 void __init setup_nr_node_ids(void);
 #else
diff --git a/mm/memory.c b/mm/memory.c
index 15322b7..0d6ef39 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1960,7 +1960,8 @@ static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
 {
 	int same = 1;
 #if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
-	if (sizeof(pte_t) > sizeof(unsigned long)) {
+	if (arch_needs_swap_ptl() ||
+	    sizeof(pte_t) > sizeof(unsigned long)) {
 		spinlock_t *ptl = pte_lockptr(mm, pmd);
 		spin_lock(ptl);
 		same = pte_same(*page_table, orig_pte);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
