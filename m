Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id E38726B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 11:59:17 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 5so276415234ioy.2
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 08:59:17 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id r85si15775834pfb.223.2016.06.14.08.59.16
        for <linux-mm@kvack.org>;
        Tue, 14 Jun 2016 08:59:16 -0700 (PDT)
From: Lukasz Anaczkowski <lukasz.anaczkowski@intel.com>
Subject: [PATCH] Linux VM workaround for Knights Landing A/D leak
Date: Tue, 14 Jun 2016 17:58:39 +0200
Message-Id: <1465919919-2093-1-git-send-email-lukasz.anaczkowski@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, dave.hansen@linux.intel.com, ak@linux.intel.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, akpm@linux-foundation.org, hpa@zytor.com
Cc: lukasz.anaczkowski@intel.com, harish.srinivasappa@intel.com, lukasz.odzioba@intel.com

From: Andi Kleen <ak@linux.intel.com>

Knights Landing has a issue that a thread setting A or D bits
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
clears the PTE again after the flush.

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

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 arch/x86/include/asm/cpufeatures.h |  1 +
 arch/x86/include/asm/hugetlb.h     |  9 ++++++++-
 arch/x86/include/asm/pgtable.h     |  5 +++++
 arch/x86/include/asm/pgtable_64.h  |  6 ++++++
 arch/x86/kernel/cpu/intel.c        | 10 ++++++++++
 arch/x86/mm/tlb.c                  | 20 ++++++++++++++++++++
 include/linux/mm.h                 |  4 ++++
 mm/memory.c                        |  3 ++-
 8 files changed, 56 insertions(+), 2 deletions(-)

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
diff --git a/arch/x86/include/asm/hugetlb.h b/arch/x86/include/asm/hugetlb.h
index 3a10616..58e1ca9 100644
--- a/arch/x86/include/asm/hugetlb.h
+++ b/arch/x86/include/asm/hugetlb.h
@@ -41,10 +41,17 @@ static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 	set_pte_at(mm, addr, ptep, pte);
 }
 
+extern void fix_pte_leak(struct mm_struct *mm, unsigned long addr,
+			 pte_t *ptep);
+
 static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
 					    unsigned long addr, pte_t *ptep)
 {
-	return ptep_get_and_clear(mm, addr, ptep);
+	pte_t pte = ptep_get_and_clear(mm, addr, ptep);
+
+	if (boot_cpu_has_bug(X86_BUG_PTE_LEAK))
+		fix_pte_leak(mm, addr, ptep);
+	return pte;
 }
 
 static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 1a27396..9769355 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -794,11 +794,16 @@ extern int ptep_test_and_clear_young(struct vm_area_struct *vma,
 extern int ptep_clear_flush_young(struct vm_area_struct *vma,
 				  unsigned long address, pte_t *ptep);
 
+extern void fix_pte_leak(struct mm_struct *mm, unsigned long addr,
+			 pte_t *ptep);
+
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
 static inline pte_t ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
 				       pte_t *ptep)
 {
 	pte_t pte = native_ptep_get_and_clear(ptep);
+	if (boot_cpu_has_bug(X86_BUG_PTE_LEAK))
+		fix_pte_leak(mm, addr, ptep);
 	pte_update(mm, addr, ptep);
 	return pte;
 }
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 2ee7811..6fa4079 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -178,6 +178,12 @@ extern void cleanup_highmap(void);
 extern void init_extra_mapping_uc(unsigned long phys, unsigned long size);
 extern void init_extra_mapping_wb(unsigned long phys, unsigned long size);
 
+#define ARCH_HAS_NEEDS_SWAP_PTL 1
+static inline bool arch_needs_swap_ptl(void)
+{
+       return boot_cpu_has_bug(X86_BUG_PTE_LEAK);
+}
+
 #endif /* !__ASSEMBLY__ */
 
 #endif /* _ASM_X86_PGTABLE_64_H */
diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
index 6e2ffbe..f499513 100644
--- a/arch/x86/kernel/cpu/intel.c
+++ b/arch/x86/kernel/cpu/intel.c
@@ -181,6 +181,16 @@ static void early_init_intel(struct cpuinfo_x86 *c)
 		}
 	}
 
+	if (c->x86_model == 87) {
+		static bool printed;
+
+		if (!printed) {
+			pr_info("Enabling PTE leaking workaround\n");
+			printed = true;
+		}
+		set_cpu_bug(c, X86_BUG_PTE_LEAK);
+	}
+
 	/*
 	 * Intel Quark Core DevMan_001.pdf section 6.4.11
 	 * "The operating system also is required to invalidate (i.e., flush)
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 5643fd0..3d54488 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -468,4 +468,24 @@ static int __init create_tlb_single_page_flush_ceiling(void)
 }
 late_initcall(create_tlb_single_page_flush_ceiling);
 
+/*
+ * Workaround for KNL issue:
+ *
+ * A thread that is going to page fault due to P=0, may still
+ * non atomically set A or D bits, which could corrupt swap entries.
+ * Always flush the other CPUs and clear the PTE again to avoid
+ * this leakage. We are excluded using the pagetable lock.
+ */
+
+void fix_pte_leak(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
+{
+	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids) {
+		trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
+		flush_tlb_others(mm_cpumask(mm), mm, addr,
+				 addr + PAGE_SIZE);
+		mb();
+		set_pte(ptep, __pte(0));
+	}
+}
+
 #endif /* CONFIG_SMP */
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
