Message-Id: <200509050926.j859QCKm000496@shell0.pdx.osdl.net>
Subject: x86-ptep-clear-optimization.patch removed from -mm tree
From: akpm@osdl.org
Date: Mon, 05 Sep 2005 02:24:32 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: zach@vmware.com, christoph@lameter.com, linux-mm@kvack.org, mm-commits@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The patch titled

     x86: ptep_clear optimization

has been removed from the -mm tree.  Its filename is

     x86-ptep-clear-optimization.patch

Patches currently in -mm which might be from zach@vmware.com are

i386-transparent-paravirtualization-sub-arch-move-msr-accessors-into-the-sub-arch-layer.patch
i386-transparent-paravirtualization-sub-arch-move-privileged-processor-operations-to-the-subarch-layer.patch
i386-transparent-paravirtualization-sub-arch-move-sensitive-system-definitions-into-the-sub-arch-layer.patch
i386-transparent-paravirtualization-sub-arch-move-tlb-flush-definitions-to-the-sub-architecture-level.patch
i386-transparent-paravirtualization-sub-arch-move-descriptor-table-management-into-the-sub-arch-layer.patch
i386-transparent-paravirtualization-sub-arch-move-sensitive-i-o-instructions-into-the-sub-arch-layer.patch
i386-transparent-paravirtualization-sub-arch-create-accessors-that-allow-the-i386-kernel-to-run-at.patch
i386-transparent-paravirtualization-sub-arch-create-mmu-2-3-level-accessors-in-the-sub-arch-layer.patch
i386--make-write-ldt-return-error-code.patch
i386--remove-ugly-tls-code.patch
i386--remove-unnecessary-tls-init.patch
i386--clean-up-asm-and-volatile-keywords-in-desc.patch
i386--use-early-clobber-to-eliminate-rotate-in-desc.patch
i386--add-some-segment-convenience-functions.patch
i386--add-some-descriptor-convenience-functions.patch
i386--add-a-per-cpu-gdt-accessor.patch
i386--typecheck-and-optimize-base-and-limit-accessors.patch
i386--typecheck-and-optimize-base-and-limit-accessors-fix.patch
i386--typecheck-and-optimize-base-and-limit-accessors-fix-tidy.patch
i386--move-descriptor-accessors-into-desc-h.patch
i386--eliminate-yet-another-redundant-accessor.patch
i386--move-context-switch-inline.patch
i386--introduce-hypervisor-ldt-hooks.patch
i386--introduce-hypervisor-lazy-pinning-hooks.patch
i386-virtualization-fix-uml-build.patch
i386-virtualization-remove-some-dead-debugging-code.patch
i386-virtualization-make-ldt-a-desc-struct.patch
i386-virtualization-ldt-kprobes-bugfix.patch
i386-virtualization-make-generic-set-wrprotect-a-macro.patch
i386-virtualization-attempt-to-clean-up-pgtable-code-motion.patch
i386-fix-desc-empty.patch



From: Zachary Amsden <zach@vmware.com>

Add a new accessor for PTEs, which passes the full hint from the mmu_gather
struct; this allows architectures with hardware pagetables to optimize away
atomic PTE operations when destroying an address space.  Removing the
locked operation should allow better pipelining of memory access in this
loop.  I measured an average savings of 30-35 cycles per zap_pte_range on
the first 500 destructions on Pentium-M, but I believe the optimization
would win more on older processors which still assert the bus lock on xchg
for an exclusive cacheline.

Update: I made some new measurements, and this saves exactly 26 cycles over
ptep_get_and_clear on Pentium M.  On P4, with a PAE kernel, this saves 180
cycles per ptep_get_and_clear, for a whopping 92160 cycles savings for a
full address space destruction.

pte_clear_full is not yet used, but is provided for future optimizations
(in particular, when running inside of a hypervisor that queues page table
updates, the full hint allows us to avoid queueing unnecessary page table
update for an address space in the process of being destroyed.

This is not a huge win, but it does help a bit, and sets the stage for
further hypervisor optimization of the mm layer on all architectures.

Signed-off-by: Zachary Amsden <zach@vmware.com>
Cc: Christoph Lameter <christoph@lameter.com>
Cc: <linux-mm@kvack.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 include/asm-generic/pgtable.h |   16 ++++++++++++++++
 include/asm-i386/pgtable.h    |   13 +++++++++++++
 mm/memory.c                   |    5 +++--
 3 files changed, 32 insertions(+), 2 deletions(-)

diff -puN include/asm-generic/pgtable.h~x86-ptep-clear-optimization include/asm-generic/pgtable.h
--- devel/include/asm-generic/pgtable.h~x86-ptep-clear-optimization	2005-09-03 15:46:15.000000000 -0700
+++ devel-akpm/include/asm-generic/pgtable.h	2005-09-03 15:46:15.000000000 -0700
@@ -101,6 +101,22 @@ do {				  					  \
 })
 #endif
 
+#ifndef __HAVE_ARCH_PTEP_GET_AND_CLEAR_FULL
+#define ptep_get_and_clear_full(__mm, __address, __ptep, __full)	\
+({									\
+	pte_t __pte;							\
+	__pte = ptep_get_and_clear((__mm), (__address), (__ptep));	\
+	__pte;								\
+})
+#endif
+
+#ifndef __HAVE_ARCH_PTE_CLEAR_FULL
+#define pte_clear_full(__mm, __address, __ptep, __full)			\
+do {									\
+	pte_clear((__mm), (__address), (__ptep));			\
+} while (0)
+#endif
+
 #ifndef __HAVE_ARCH_PTEP_CLEAR_FLUSH
 #define ptep_clear_flush(__vma, __address, __ptep)			\
 ({									\
diff -puN include/asm-i386/pgtable.h~x86-ptep-clear-optimization include/asm-i386/pgtable.h
--- devel/include/asm-i386/pgtable.h~x86-ptep-clear-optimization	2005-09-03 15:46:15.000000000 -0700
+++ devel-akpm/include/asm-i386/pgtable.h	2005-09-03 15:52:11.000000000 -0700
@@ -260,6 +260,18 @@ static inline int ptep_test_and_clear_yo
 	return test_and_clear_bit(_PAGE_BIT_ACCESSED, &ptep->pte_low);
 }
 
+static inline pte_t ptep_get_and_clear_full(struct mm_struct *mm, unsigned long addr, pte_t *ptep, int full)
+{
+	pte_t pte;
+	if (full) {
+		pte = *ptep;
+		*ptep = __pte(0);
+	} else {
+		pte = ptep_get_and_clear(mm, addr, ptep);
+	}
+	return pte;
+}
+
 static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
 {
 	clear_bit(_PAGE_BIT_RW, &ptep->pte_low);
@@ -417,6 +429,7 @@ extern void noexec_setup(const char *str
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
+#define __HAVE_ARCH_PTEP_GET_AND_CLEAR_FULL
 #define __HAVE_ARCH_PTEP_SET_WRPROTECT
 #define __HAVE_ARCH_PTE_SAME
 #include <asm-generic/pgtable.h>
diff -puN mm/memory.c~x86-ptep-clear-optimization mm/memory.c
--- devel/mm/memory.c~x86-ptep-clear-optimization	2005-09-03 15:46:15.000000000 -0700
+++ devel-akpm/mm/memory.c	2005-09-03 15:46:15.000000000 -0700
@@ -562,7 +562,8 @@ static void zap_pte_range(struct mmu_gat
 				     page->index > details->last_index))
 					continue;
 			}
-			ptent = ptep_get_and_clear(tlb->mm, addr, pte);
+			ptent = ptep_get_and_clear_full(tlb->mm, addr, pte,
+							tlb->fullmm);
 			tlb_remove_tlb_entry(tlb, pte, addr);
 			if (unlikely(!page))
 				continue;
@@ -590,7 +591,7 @@ static void zap_pte_range(struct mmu_gat
 			continue;
 		if (!pte_file(ptent))
 			free_swap_and_cache(pte_to_swp_entry(ptent));
-		pte_clear(tlb->mm, addr, pte);
+		pte_clear_full(tlb->mm, addr, pte, tlb->fullmm);
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	pte_unmap(pte - 1);
 }
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
