Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6AA4E8D003C
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 13:11:20 -0500 (EST)
Message-Id: <20110302180258.956518392@chello.nl>
Date: Wed, 02 Mar 2011 18:59:30 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 2/6] mm: Change flush_tlb_range() to take an mm_struct
References: <20110302175928.022902359@chello.nl>
Content-Disposition: inline; filename=fixup-flush_tlb_range.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

In order to be able to properly support architecture that want/need to
support TLB range invalidation, we need to change the
flush_tlb_range() argument from a vm_area_struct to an mm_struct
because the range might very well extend past one VMA, or not have a
VMA at all.

There are two mmu_gather cases to consider:

  unmap_region()
    tlb_gather_mmu()
    unmap_vmas()
      for (; vma; vma = vma->vm_next)
        unmao_page_range()
          tlb_start_vma() -> flush cache range
          zap_*_range()
            ptep_get_and_clear_full() -> batch/track external tlbs
            tlb_remove_tlb_entry() -> batch/track external tlbs
            tlb_remove_page() -> track range/batch page
          tlb_end_vma()
    free_pgtables()
      while (vma)
        unlink_*_vma()
        free_*_range()
          *_free_tlb() -> track tlb range
    tlb_finish_mmu() -> flush everything
  free vmas

and:

  shift_arg_pages()
    tlb_gather_mmu()
    free_*_range()
      *_free_tlb() -> track tlb range
    tlb_finish_mmu() -> flush things

There are various reasons that we need to flush TLBs _after_ freeing
the page-tables themselves. For some architectures (x86 among others)
this serializes against (both hardware and software) page table
walkers like gup_fast().

For others (ARM) this is (also) needed to evict stale page-table
caches - ARM LPAE mode apparently caches page tables and concurrent
hardware walkers could re-populate these caches if the final tlb flush
were to be from tlb_end_vma() since an concurrent walk could still be
in progress.

Therefore we need to track the range over all VMAs and the freeing of
the page-tables themselves. This means we cannot use a VMA argument to
the flush the TLB range.

Mostly architectures only used the ->vm_mm argument anyway, and
conversion is straight forward and removes numerous fake vma
instrances created just to pass an mm pointer.

The exceptions are ARM and TILE, both of which also look at
->vm_flags, ARM uses this to optimize TBL flushes for Harvard style
MMUs that have independent I-TLB ops. The taken conversion is rather
ugly (because I can't write ARM asm) and creates a fake VMA with
VM_EXEC set so that it effectively always flushes the I-TLBs and thus
looses the optimization.

TILE uses vm_flags to check for VM_EXEC in order to flush I-cache, but
also checks VM_HUGETLB. Arguably it shouldn't flush I-cache here and
we can use things like update_mmu_cache() to solve this. As for the
HUGETLB case, we can simply flush both at a small penalty. The current
conversion does all three, I-cache, TLB and HUGETLB.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 Documentation/cachetlb.txt             |    9 +++------
 arch/alpha/include/asm/tlbflush.h      |    8 +++-----
 arch/alpha/kernel/smp.c                |    4 ++--
 arch/arm/include/asm/tlb.h             |    2 +-
 arch/arm/include/asm/tlbflush.h        |    5 +++--
 arch/arm/kernel/ecard.c                |    8 ++------
 arch/arm/kernel/smp_tlb.c              |   29 +++++++++++++++++++++--------
 arch/avr32/include/asm/tlb.h           |    2 +-
 arch/avr32/include/asm/tlbflush.h      |    4 ++--
 arch/avr32/mm/tlb.c                    |    4 +---
 arch/cris/include/asm/tlbflush.h       |    4 ++--
 arch/frv/include/asm/tlbflush.h        |    4 ++--
 arch/ia64/include/asm/tlb.h            |   11 ++---------
 arch/ia64/include/asm/tlbflush.h       |    4 ++--
 arch/ia64/mm/tlb.c                     |    3 +--
 arch/m32r/include/asm/tlbflush.h       |   14 +++++++-------
 arch/m32r/kernel/smp.c                 |    6 +++---
 arch/m32r/mm/fault-nommu.c             |    2 +-
 arch/m32r/mm/fault.c                   |    5 +----
 arch/m68k/include/asm/tlbflush.h       |    7 +++----
 arch/microblaze/include/asm/tlbflush.h |    2 +-
 arch/mips/include/asm/tlbflush.h       |    8 ++++----
 arch/mips/kernel/smp.c                 |   12 +++++-------
 arch/mips/mm/tlb-r3k.c                 |    3 +--
 arch/mips/mm/tlb-r4k.c                 |    3 +--
 arch/mips/mm/tlb-r8k.c                 |    3 +--
 arch/mn10300/include/asm/tlbflush.h    |    6 +++---
 arch/parisc/include/asm/tlb.h          |    2 +-
 arch/parisc/include/asm/tlbflush.h     |    2 +-
 arch/powerpc/include/asm/tlbflush.h    |    8 ++++----
 arch/powerpc/mm/tlb_hash32.c           |    6 +++---
 arch/powerpc/mm/tlb_nohash.c           |    4 ++--
 arch/s390/include/asm/tlbflush.h       |    6 +++---
 arch/score/include/asm/tlbflush.h      |    6 +++---
 arch/score/mm/tlb-score.c              |    3 +--
 arch/sh/include/asm/tlb.h              |    2 +-
 arch/sh/include/asm/tlbflush.h         |   10 +++++-----
 arch/sh/kernel/smp.c                   |   12 +++++-------
 arch/sh/mm/nommu.c                     |    2 +-
 arch/sh/mm/tlbflush_32.c               |    3 +--
 arch/sh/mm/tlbflush_64.c               |    4 +---
 arch/sparc/include/asm/tlb_32.h        |    2 +-
 arch/sparc/include/asm/tlbflush_32.h   |   12 ++++++------
 arch/sparc/include/asm/tlbflush_64.h   |    2 +-
 arch/sparc/kernel/smp_32.c             |    8 +++-----
 arch/sparc/mm/generic_32.c             |    2 +-
 arch/sparc/mm/generic_64.c             |    2 +-
 arch/sparc/mm/hypersparc.S             |    1 -
 arch/sparc/mm/srmmu.c                  |   17 ++++++++---------
 arch/sparc/mm/sun4c.c                  |    3 +--
 arch/sparc/mm/swift.S                  |    1 -
 arch/sparc/mm/tsunami.S                |    1 -
 arch/sparc/mm/viking.S                 |    2 --
 arch/tile/include/asm/tlbflush.h       |    4 ++--
 arch/tile/kernel/tlb.c                 |   11 +++++------
 arch/um/include/asm/tlbflush.h         |    4 ++--
 arch/um/kernel/tlb.c                   |    6 +++---
 arch/unicore32/include/asm/tlb.h       |    2 +-
 arch/unicore32/include/asm/tlbflush.h  |    2 +-
 arch/x86/include/asm/tlbflush.h        |   10 +++++-----
 arch/x86/mm/pgtable.c                  |    6 +++---
 arch/xtensa/include/asm/tlb.h          |    2 +-
 arch/xtensa/include/asm/tlbflush.h     |    2 +-
 arch/xtensa/mm/tlb.c                   |    3 +--
 mm/huge_memory.c                       |    6 +++---
 mm/hugetlb.c                           |    4 ++--
 mm/mprotect.c                          |    2 +-
 mm/pgtable-generic.c                   |    8 ++++----
 68 files changed, 168 insertions(+), 199 deletions(-)

Index: linux-2.6/Documentation/cachetlb.txt
===================================================================
--- linux-2.6.orig/Documentation/cachetlb.txt
+++ linux-2.6/Documentation/cachetlb.txt
@@ -49,20 +49,17 @@ invoke one of the following flush method
 	page table operations such as what happens during
 	fork, and exec.
 
-3) void flush_tlb_range(struct vm_area_struct *vma,
+3) void flush_tlb_range(struct mm_struct *mm,
 			unsigned long start, unsigned long end)
 
 	Here we are flushing a specific range of (user) virtual
 	address translations from the TLB.  After running, this
 	interface must make sure that any previous page table
-	modifications for the address space 'vma->vm_mm' in the range
+	modifications for the address space 'mm' in the range
 	'start' to 'end-1' will be visible to the cpu.  That is, after
 	running, here will be no entries in the TLB for 'mm' for
 	virtual addresses in the range 'start' to 'end-1'.
 
-	The "vma" is the backing store being used for the region.
-	Primarily, this is used for munmap() type operations.
-
 	The interface is provided in hopes that the port can find
 	a suitably efficient method for removing multiple page
 	sized translations from the TLB, instead of having the kernel
@@ -120,7 +117,7 @@ is changing an existing virtual-->physic
 
 	2) flush_cache_range(vma, start, end);
 	   change_range_of_page_tables(mm, start, end);
-	   flush_tlb_range(vma, start, end);
+	   flush_tlb_range(vma->vm_mm, start, end);
 
 	3) flush_cache_page(vma, addr, pfn);
 	   set_pte(pte_pointer, new_pte_val);
Index: linux-2.6/arch/alpha/include/asm/tlbflush.h
===================================================================
--- linux-2.6.orig/arch/alpha/include/asm/tlbflush.h
+++ linux-2.6/arch/alpha/include/asm/tlbflush.h
@@ -127,10 +127,9 @@ flush_tlb_page(struct vm_area_struct *vm
 /* Flush a specified range of user mapping.  On the Alpha we flush
    the whole user tlb.  */
 static inline void
-flush_tlb_range(struct vm_area_struct *vma, unsigned long start,
-		unsigned long end)
+flush_tlb_range(struct mm_struct *mm, unsigned long start, unsigned long end)
 {
-	flush_tlb_mm(vma->vm_mm);
+	flush_tlb_mm(mm);
 }
 
 #else /* CONFIG_SMP */
@@ -138,8 +137,7 @@ flush_tlb_range(struct vm_area_struct *v
 extern void flush_tlb_all(void);
 extern void flush_tlb_mm(struct mm_struct *);
 extern void flush_tlb_page(struct vm_area_struct *, unsigned long);
-extern void flush_tlb_range(struct vm_area_struct *, unsigned long,
-			    unsigned long);
+extern void flush_tlb_range(struct mm_struct *, unsigned long, unsigned long);
 
 #endif /* CONFIG_SMP */
 
Index: linux-2.6/arch/alpha/kernel/smp.c
===================================================================
--- linux-2.6.orig/arch/alpha/kernel/smp.c
+++ linux-2.6/arch/alpha/kernel/smp.c
@@ -773,10 +773,10 @@ flush_tlb_page(struct vm_area_struct *vm
 EXPORT_SYMBOL(flush_tlb_page);
 
 void
-flush_tlb_range(struct vm_area_struct *vma, unsigned long start, unsigned long end)
+flush_tlb_range(struct mm_struct *mm, unsigned long start, unsigned long end)
 {
 	/* On the Alpha we always flush the whole user tlb.  */
-	flush_tlb_mm(vma->vm_mm);
+	flush_tlb_mm(mm);
 }
 EXPORT_SYMBOL(flush_tlb_range);
 
Index: linux-2.6/arch/arm/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/arm/include/asm/tlb.h
+++ linux-2.6/arch/arm/include/asm/tlb.h
@@ -83,7 +83,7 @@ static inline void tlb_flush(struct mmu_
 	if (tlb->fullmm || !tlb->vma)
 		flush_tlb_mm(tlb->mm);
 	else if (tlb->range_end > 0) {
-		flush_tlb_range(tlb->vma, tlb->range_start, tlb->range_end);
+		flush_tlb_range(tlb->mm, tlb->range_start, tlb->range_end);
 		tlb->range_start = TASK_SIZE;
 		tlb->range_end = 0;
 	}
Index: linux-2.6/arch/arm/include/asm/tlbflush.h
===================================================================
--- linux-2.6.orig/arch/arm/include/asm/tlbflush.h
+++ linux-2.6/arch/arm/include/asm/tlbflush.h
@@ -545,7 +545,8 @@ static inline void clean_pmd_entry(pmd_t
 /*
  * Convert calls to our calling convention.
  */
-#define local_flush_tlb_range(vma,start,end)	__cpu_flush_user_tlb_range(start,end,vma)
+extern void local_flush_tlb_range(struct mm_struct *mm, unsigned long start, unsigned long end);
+
 #define local_flush_tlb_kernel_range(s,e)	__cpu_flush_kern_tlb_range(s,e)
 
 #ifndef CONFIG_SMP
@@ -560,7 +561,7 @@ extern void flush_tlb_all(void);
 extern void flush_tlb_mm(struct mm_struct *mm);
 extern void flush_tlb_page(struct vm_area_struct *vma, unsigned long uaddr);
 extern void flush_tlb_kernel_page(unsigned long kaddr);
-extern void flush_tlb_range(struct vm_area_struct *vma, unsigned long start, unsigned long end);
+extern void flush_tlb_range(struct mm_struct *mm, unsigned long start, unsigned long end);
 extern void flush_tlb_kernel_range(unsigned long start, unsigned long end);
 #endif
 
Index: linux-2.6/arch/arm/kernel/ecard.c
===================================================================
--- linux-2.6.orig/arch/arm/kernel/ecard.c
+++ linux-2.6/arch/arm/kernel/ecard.c
@@ -217,8 +217,6 @@ static DEFINE_MUTEX(ecard_mutex);
  */
 static void ecard_init_pgtables(struct mm_struct *mm)
 {
-	struct vm_area_struct vma;
-
 	/* We want to set up the page tables for the following mapping:
 	 *  Virtual	Physical
 	 *  0x03000000	0x03000000
@@ -242,10 +240,8 @@ static void ecard_init_pgtables(struct m
 
 	memcpy(dst_pgd, src_pgd, sizeof(pgd_t) * (EASI_SIZE / PGDIR_SIZE));
 
-	vma.vm_mm = mm;
-
-	flush_tlb_range(&vma, IO_START, IO_START + IO_SIZE);
-	flush_tlb_range(&vma, EASI_START, EASI_START + EASI_SIZE);
+	flush_tlb_range(mm, IO_START, IO_START + IO_SIZE);
+	flush_tlb_range(mm, EASI_START, EASI_START + EASI_SIZE);
 }
 
 static int ecard_init_mm(void)
Index: linux-2.6/arch/arm/kernel/smp_tlb.c
===================================================================
--- linux-2.6.orig/arch/arm/kernel/smp_tlb.c
+++ linux-2.6/arch/arm/kernel/smp_tlb.c
@@ -9,6 +9,7 @@
  */
 #include <linux/preempt.h>
 #include <linux/smp.h>
+#include <linux/mm.h>
 
 #include <asm/smp_plat.h>
 #include <asm/tlbflush.h>
@@ -31,7 +32,7 @@ static void on_each_cpu_mask(void (*func
  * TLB operations
  */
 struct tlb_args {
-	struct vm_area_struct *ta_vma;
+	struct mm_struct *ta_mm;
 	unsigned long ta_start;
 	unsigned long ta_end;
 };
@@ -51,8 +52,11 @@ static inline void ipi_flush_tlb_mm(void
 static inline void ipi_flush_tlb_page(void *arg)
 {
 	struct tlb_args *ta = (struct tlb_args *)arg;
+	struct vm_area_struct vma = {
+		.vm_mm = ta->ta_mm,
+	};
 
-	local_flush_tlb_page(ta->ta_vma, ta->ta_start);
+	local_flush_tlb_page(&vma, ta->ta_start);
 }
 
 static inline void ipi_flush_tlb_kernel_page(void *arg)
@@ -66,7 +70,7 @@ static inline void ipi_flush_tlb_range(v
 {
 	struct tlb_args *ta = (struct tlb_args *)arg;
 
-	local_flush_tlb_range(ta->ta_vma, ta->ta_start, ta->ta_end);
+	local_flush_tlb_range(ta->ta_mm, ta->ta_start, ta->ta_end);
 }
 
 static inline void ipi_flush_tlb_kernel_range(void *arg)
@@ -96,7 +100,7 @@ void flush_tlb_page(struct vm_area_struc
 {
 	if (tlb_ops_need_broadcast()) {
 		struct tlb_args ta;
-		ta.ta_vma = vma;
+		ta.ta_mm = vma->vm_mm;
 		ta.ta_start = uaddr;
 		on_each_cpu_mask(ipi_flush_tlb_page, &ta, 1, mm_cpumask(vma->vm_mm));
 	} else
@@ -113,17 +117,17 @@ void flush_tlb_kernel_page(unsigned long
 		local_flush_tlb_kernel_page(kaddr);
 }
 
-void flush_tlb_range(struct vm_area_struct *vma,
+void flush_tlb_range(struct mm_struct *mm,
                      unsigned long start, unsigned long end)
 {
 	if (tlb_ops_need_broadcast()) {
 		struct tlb_args ta;
-		ta.ta_vma = vma;
+		ta.ta_mm = mm;
 		ta.ta_start = start;
 		ta.ta_end = end;
-		on_each_cpu_mask(ipi_flush_tlb_range, &ta, 1, mm_cpumask(vma->vm_mm));
+		on_each_cpu_mask(ipi_flush_tlb_range, &ta, 1, mm_cpumask(mm));
 	} else
-		local_flush_tlb_range(vma, start, end);
+		local_flush_tlb_range(mm, start, end);
 }
 
 void flush_tlb_kernel_range(unsigned long start, unsigned long end)
@@ -137,3 +141,12 @@ void flush_tlb_kernel_range(unsigned lon
 		local_flush_tlb_kernel_range(start, end);
 }
 
+void local_flush_tlb_range(struct mm_struct *mm, unsigned long start, unsigned long end)
+{
+	struct vm_area_struct vma = {
+		.vm_mm = mm,
+		.vm_flags = VM_EXEC,
+	};
+
+	__cpu_flush_user_tlb_range(start, end, &vma);
+}
Index: linux-2.6/arch/avr32/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/avr32/include/asm/tlb.h
+++ linux-2.6/arch/avr32/include/asm/tlb.h
@@ -12,7 +12,7 @@
 	flush_cache_range(vma, vma->vm_start, vma->vm_end)
 
 #define tlb_end_vma(tlb, vma) \
-	flush_tlb_range(vma, vma->vm_start, vma->vm_end)
+	flush_tlb_range(vma->vm_mm, vma->vm_start, vma->vm_end)
 
 #define __tlb_remove_tlb_entry(tlb, pte, address) do { } while(0)
 
Index: linux-2.6/arch/avr32/include/asm/tlbflush.h
===================================================================
--- linux-2.6.orig/arch/avr32/include/asm/tlbflush.h
+++ linux-2.6/arch/avr32/include/asm/tlbflush.h
@@ -17,13 +17,13 @@
  *  - flush_tlb_all() flushes all processes' TLB entries
  *  - flush_tlb_mm(mm) flushes the specified mm context TLBs
  *  - flush_tlb_page(vma, vmaddr) flushes one page
- *  - flush_tlb_range(vma, start, end) flushes a range of pages
+ *  - flush_tlb_range(mm, start, end) flushes a range of pages
  *  - flush_tlb_kernel_range(start, end) flushes a range of kernel pages
  */
 extern void flush_tlb(void);
 extern void flush_tlb_all(void);
 extern void flush_tlb_mm(struct mm_struct *mm);
-extern void flush_tlb_range(struct vm_area_struct *vma, unsigned long start,
+extern void flush_tlb_range(struct mm_struct *mm, unsigned long start,
 			    unsigned long end);
 extern void flush_tlb_page(struct vm_area_struct *vma, unsigned long page);
 
Index: linux-2.6/arch/avr32/mm/tlb.c
===================================================================
--- linux-2.6.orig/arch/avr32/mm/tlb.c
+++ linux-2.6/arch/avr32/mm/tlb.c
@@ -170,11 +170,9 @@ void flush_tlb_page(struct vm_area_struc
 	}
 }
 
-void flush_tlb_range(struct vm_area_struct *vma, unsigned long start,
+void flush_tlb_range(struct mm_struct *mm, unsigned long start,
 		     unsigned long end)
 {
-	struct mm_struct *mm = vma->vm_mm;
-
 	if (mm->context != NO_CONTEXT) {
 		unsigned long flags;
 		int size;
Index: linux-2.6/arch/cris/include/asm/tlbflush.h
===================================================================
--- linux-2.6.orig/arch/cris/include/asm/tlbflush.h
+++ linux-2.6/arch/cris/include/asm/tlbflush.h
@@ -33,9 +33,9 @@ extern void flush_tlb_page(struct vm_are
 #define flush_tlb_page __flush_tlb_page
 #endif
 
-static inline void flush_tlb_range(struct vm_area_struct * vma, unsigned long start, unsigned long end)
+static inline void flush_tlb_range(struct mm_struct *mm, unsigned long start, unsigned long end)
 {
-	flush_tlb_mm(vma->vm_mm);
+	flush_tlb_mm(mm);
 }
 
 static inline void flush_tlb(void)
Index: linux-2.6/arch/frv/include/asm/tlbflush.h
===================================================================
--- linux-2.6.orig/arch/frv/include/asm/tlbflush.h
+++ linux-2.6/arch/frv/include/asm/tlbflush.h
@@ -39,10 +39,10 @@ do {						\
 	preempt_enable();			\
 } while(0)
 
-#define flush_tlb_range(vma,start,end)					\
+#define flush_tlb_range(mm,start,end)					\
 do {									\
 	preempt_disable();						\
-	__flush_tlb_range((vma)->vm_mm->context.id, start, end);	\
+	__flush_tlb_range((mm)->context.id, start, end);		\
 	preempt_enable();						\
 } while(0)
 
Index: linux-2.6/arch/ia64/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/ia64/include/asm/tlb.h
+++ linux-2.6/arch/ia64/include/asm/tlb.h
@@ -126,17 +126,10 @@ ia64_tlb_flush_mmu (struct mmu_gather *t
 		 */
 		flush_tlb_all();
 	} else {
-		/*
-		 * XXX fix me: flush_tlb_range() should take an mm pointer instead of a
-		 * vma pointer.
-		 */
-		struct vm_area_struct vma;
-
-		vma.vm_mm = tlb->mm;
 		/* flush the address range from the tlb: */
-		flush_tlb_range(&vma, start, end);
+		flush_tlb_range(tlb->mm, start, end);
 		/* now flush the virt. page-table area mapping the address range: */
-		flush_tlb_range(&vma, ia64_thash(start), ia64_thash(end));
+		flush_tlb_range(tlb->mm, ia64_thash(start), ia64_thash(end));
 	}
 
 	/* lastly, release the freed pages */
Index: linux-2.6/arch/ia64/include/asm/tlbflush.h
===================================================================
--- linux-2.6.orig/arch/ia64/include/asm/tlbflush.h
+++ linux-2.6/arch/ia64/include/asm/tlbflush.h
@@ -66,7 +66,7 @@ flush_tlb_mm (struct mm_struct *mm)
 #endif
 }
 
-extern void flush_tlb_range (struct vm_area_struct *vma, unsigned long start, unsigned long end);
+extern void flush_tlb_range (struct mm_struct *mm, unsigned long start, unsigned long end);
 
 /*
  * Page-granular tlb flush.
@@ -75,7 +75,7 @@ static inline void
 flush_tlb_page (struct vm_area_struct *vma, unsigned long addr)
 {
 #ifdef CONFIG_SMP
-	flush_tlb_range(vma, (addr & PAGE_MASK), (addr & PAGE_MASK) + PAGE_SIZE);
+	flush_tlb_range(vma->vm_mm, (addr & PAGE_MASK), (addr & PAGE_MASK) + PAGE_SIZE);
 #else
 	if (vma->vm_mm == current->active_mm)
 		ia64_ptcl(addr, (PAGE_SHIFT << 2));
Index: linux-2.6/arch/ia64/mm/tlb.c
===================================================================
--- linux-2.6.orig/arch/ia64/mm/tlb.c
+++ linux-2.6/arch/ia64/mm/tlb.c
@@ -298,10 +298,9 @@ local_flush_tlb_all (void)
 }
 
 void
-flush_tlb_range (struct vm_area_struct *vma, unsigned long start,
+flush_tlb_range (struct mm_struct *mm, unsigned long start,
 		 unsigned long end)
 {
-	struct mm_struct *mm = vma->vm_mm;
 	unsigned long size = end - start;
 	unsigned long nbits;
 
Index: linux-2.6/arch/m32r/include/asm/tlbflush.h
===================================================================
--- linux-2.6.orig/arch/m32r/include/asm/tlbflush.h
+++ linux-2.6/arch/m32r/include/asm/tlbflush.h
@@ -17,7 +17,7 @@
 extern void local_flush_tlb_all(void);
 extern void local_flush_tlb_mm(struct mm_struct *);
 extern void local_flush_tlb_page(struct vm_area_struct *, unsigned long);
-extern void local_flush_tlb_range(struct vm_area_struct *, unsigned long,
+extern void local_flush_tlb_range(struct mm_struct *, unsigned long,
 	unsigned long);
 
 #ifndef CONFIG_SMP
@@ -25,27 +25,27 @@ extern void local_flush_tlb_range(struct
 #define flush_tlb_all()			local_flush_tlb_all()
 #define flush_tlb_mm(mm)		local_flush_tlb_mm(mm)
 #define flush_tlb_page(vma, page)	local_flush_tlb_page(vma, page)
-#define flush_tlb_range(vma, start, end)	\
-	local_flush_tlb_range(vma, start, end)
+#define flush_tlb_range(mm, start, end)	\
+	local_flush_tlb_range(mm, start, end)
 #define flush_tlb_kernel_range(start, end)	local_flush_tlb_all()
 #else	/* CONFIG_MMU */
 #define flush_tlb_all()			do { } while (0)
 #define flush_tlb_mm(mm)		do { } while (0)
 #define flush_tlb_page(vma, vmaddr)	do { } while (0)
-#define flush_tlb_range(vma, start, end)	do { } while (0)
+#define flush_tlb_range(mm, start, end)	do { } while (0)
 #endif	/* CONFIG_MMU */
 #else	/* CONFIG_SMP */
 extern void smp_flush_tlb_all(void);
 extern void smp_flush_tlb_mm(struct mm_struct *);
 extern void smp_flush_tlb_page(struct vm_area_struct *, unsigned long);
-extern void smp_flush_tlb_range(struct vm_area_struct *, unsigned long,
+extern void smp_flush_tlb_range(struct mm_struct *, unsigned long,
 	unsigned long);
 
 #define flush_tlb_all()			smp_flush_tlb_all()
 #define flush_tlb_mm(mm)		smp_flush_tlb_mm(mm)
 #define flush_tlb_page(vma, page)	smp_flush_tlb_page(vma, page)
-#define flush_tlb_range(vma, start, end)	\
-	smp_flush_tlb_range(vma, start, end)
+#define flush_tlb_range(mm, start, end)	\
+	smp_flush_tlb_range(mm, start, end)
 #define flush_tlb_kernel_range(start, end)	smp_flush_tlb_all()
 #endif	/* CONFIG_SMP */
 
Index: linux-2.6/arch/m32r/kernel/smp.c
===================================================================
--- linux-2.6.orig/arch/m32r/kernel/smp.c
+++ linux-2.6/arch/m32r/kernel/smp.c
@@ -71,7 +71,7 @@ void smp_flush_tlb_all(void);
 static void flush_tlb_all_ipi(void *);
 
 void smp_flush_tlb_mm(struct mm_struct *);
-void smp_flush_tlb_range(struct vm_area_struct *, unsigned long, \
+void smp_flush_tlb_range(struct mm_struct *, unsigned long, \
 	unsigned long);
 void smp_flush_tlb_page(struct vm_area_struct *, unsigned long);
 static void flush_tlb_others(cpumask_t, struct mm_struct *,
@@ -299,10 +299,10 @@ void smp_flush_tlb_mm(struct mm_struct *
  * ---------- --- --------------------------------------------------------
  *
  *==========================================================================*/
-void smp_flush_tlb_range(struct vm_area_struct *vma, unsigned long start,
+void smp_flush_tlb_range(struct mm_struct *mm, unsigned long start,
 	unsigned long end)
 {
-	smp_flush_tlb_mm(vma->vm_mm);
+	smp_flush_tlb_mm(mm);
 }
 
 /*==========================================================================*
Index: linux-2.6/arch/m32r/mm/fault-nommu.c
===================================================================
--- linux-2.6.orig/arch/m32r/mm/fault-nommu.c
+++ linux-2.6/arch/m32r/mm/fault-nommu.c
@@ -111,7 +111,7 @@ void local_flush_tlb_page(struct vm_area
 /*======================================================================*
  * flush_tlb_range() : flushes a range of pages
  *======================================================================*/
-void local_flush_tlb_range(struct vm_area_struct *vma, unsigned long start,
+void local_flush_tlb_range(struct mm_struct *mm, unsigned long start,
 	unsigned long end)
 {
 	BUG();
Index: linux-2.6/arch/m32r/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/m32r/mm/fault.c
+++ linux-2.6/arch/m32r/mm/fault.c
@@ -468,12 +468,9 @@ void local_flush_tlb_page(struct vm_area
 /*======================================================================*
  * flush_tlb_range() : flushes a range of pages
  *======================================================================*/
-void local_flush_tlb_range(struct vm_area_struct *vma, unsigned long start,
+void local_flush_tlb_range(struct mm_struct *mm, unsigned long start,
 	unsigned long end)
 {
-	struct mm_struct *mm;
-
-	mm = vma->vm_mm;
 	if (mm_context(mm) != NO_CONTEXT) {
 		unsigned long flags;
 		int size;
Index: linux-2.6/arch/m68k/include/asm/tlbflush.h
===================================================================
--- linux-2.6.orig/arch/m68k/include/asm/tlbflush.h
+++ linux-2.6/arch/m68k/include/asm/tlbflush.h
@@ -80,10 +80,10 @@ static inline void flush_tlb_page(struct
 	}
 }
 
-static inline void flush_tlb_range(struct vm_area_struct *vma,
+static inline void flush_tlb_range(struct mm_struct *mm,
 				   unsigned long start, unsigned long end)
 {
-	if (vma->vm_mm == current->active_mm)
+	if (mm == current->active_mm)
 		__flush_tlb();
 }
 
@@ -177,10 +177,9 @@ static inline void flush_tlb_page (struc
 }
 /* Flush a range of pages from TLB. */
 
-static inline void flush_tlb_range (struct vm_area_struct *vma,
+static inline void flush_tlb_range (struct mm_struct *mm,
 		      unsigned long start, unsigned long end)
 {
-	struct mm_struct *mm = vma->vm_mm;
 	unsigned char seg, oldctx;
 
 	start &= ~SUN3_PMEG_MASK;
Index: linux-2.6/arch/microblaze/include/asm/tlbflush.h
===================================================================
--- linux-2.6.orig/arch/microblaze/include/asm/tlbflush.h
+++ linux-2.6/arch/microblaze/include/asm/tlbflush.h
@@ -33,7 +33,7 @@ static inline void local_flush_tlb_mm(st
 static inline void local_flush_tlb_page(struct vm_area_struct *vma,
 				unsigned long vmaddr)
 	{ __tlbie(vmaddr); }
-static inline void local_flush_tlb_range(struct vm_area_struct *vma,
+static inline void local_flush_tlb_range(struct mm_struct *mm,
 		unsigned long start, unsigned long end)
 	{ __tlbia(); }
 
Index: linux-2.6/arch/mips/include/asm/tlbflush.h
===================================================================
--- linux-2.6.orig/arch/mips/include/asm/tlbflush.h
+++ linux-2.6/arch/mips/include/asm/tlbflush.h
@@ -9,12 +9,12 @@
  *  - flush_tlb_all() flushes all processes TLB entries
  *  - flush_tlb_mm(mm) flushes the specified mm context TLB entries
  *  - flush_tlb_page(vma, vmaddr) flushes one page
- *  - flush_tlb_range(vma, start, end) flushes a range of pages
+ *  - flush_tlb_range(mm, start, end) flushes a range of pages
  *  - flush_tlb_kernel_range(start, end) flushes a range of kernel pages
  */
 extern void local_flush_tlb_all(void);
 extern void local_flush_tlb_mm(struct mm_struct *mm);
-extern void local_flush_tlb_range(struct vm_area_struct *vma,
+extern void local_flush_tlb_range(struct mm_struct *mm,
 	unsigned long start, unsigned long end);
 extern void local_flush_tlb_kernel_range(unsigned long start,
 	unsigned long end);
@@ -26,7 +26,7 @@ extern void local_flush_tlb_one(unsigned
 
 extern void flush_tlb_all(void);
 extern void flush_tlb_mm(struct mm_struct *);
-extern void flush_tlb_range(struct vm_area_struct *vma, unsigned long,
+extern void flush_tlb_range(struct mm_struct *mm, unsigned long,
 	unsigned long);
 extern void flush_tlb_kernel_range(unsigned long, unsigned long);
 extern void flush_tlb_page(struct vm_area_struct *, unsigned long);
@@ -36,7 +36,7 @@ extern void flush_tlb_one(unsigned long 
 
 #define flush_tlb_all()			local_flush_tlb_all()
 #define flush_tlb_mm(mm)		local_flush_tlb_mm(mm)
-#define flush_tlb_range(vma, vmaddr, end)	local_flush_tlb_range(vma, vmaddr, end)
+#define flush_tlb_range(mm, vmaddr, end)	local_flush_tlb_range(mm, vmaddr, end)
 #define flush_tlb_kernel_range(vmaddr,end) \
 	local_flush_tlb_kernel_range(vmaddr, end)
 #define flush_tlb_page(vma, page)	local_flush_tlb_page(vma, page)
Index: linux-2.6/arch/mips/kernel/smp.c
===================================================================
--- linux-2.6.orig/arch/mips/kernel/smp.c
+++ linux-2.6/arch/mips/kernel/smp.c
@@ -307,7 +307,7 @@ void flush_tlb_mm(struct mm_struct *mm)
 }
 
 struct flush_tlb_data {
-	struct vm_area_struct *vma;
+	struct mm_struct *mm;
 	unsigned long addr1;
 	unsigned long addr2;
 };
@@ -316,17 +316,15 @@ static void flush_tlb_range_ipi(void *in
 {
 	struct flush_tlb_data *fd = info;
 
-	local_flush_tlb_range(fd->vma, fd->addr1, fd->addr2);
+	local_flush_tlb_range(fd->mm, fd->addr1, fd->addr2);
 }
 
-void flush_tlb_range(struct vm_area_struct *vma, unsigned long start, unsigned long end)
+void flush_tlb_range(struct mm_struct *mm, unsigned long start, unsigned long end)
 {
-	struct mm_struct *mm = vma->vm_mm;
-
 	preempt_disable();
 	if ((atomic_read(&mm->mm_users) != 1) || (current->mm != mm)) {
 		struct flush_tlb_data fd = {
-			.vma = vma,
+			.mm = mm,
 			.addr1 = start,
 			.addr2 = end,
 		};
@@ -341,7 +339,7 @@ void flush_tlb_range(struct vm_area_stru
 			if (cpu_context(cpu, mm))
 				cpu_context(cpu, mm) = 0;
 	}
-	local_flush_tlb_range(vma, start, end);
+	local_flush_tlb_range(mm, start, end);
 	preempt_enable();
 }
 
Index: linux-2.6/arch/mips/mm/tlb-r3k.c
===================================================================
--- linux-2.6.orig/arch/mips/mm/tlb-r3k.c
+++ linux-2.6/arch/mips/mm/tlb-r3k.c
@@ -76,10 +76,9 @@ void local_flush_tlb_mm(struct mm_struct
 	}
 }
 
-void local_flush_tlb_range(struct vm_area_struct *vma, unsigned long start,
+void local_flush_tlb_range(struct mm_struct *mm, unsigned long start,
 			   unsigned long end)
 {
-	struct mm_struct *mm = vma->vm_mm;
 	int cpu = smp_processor_id();
 
 	if (cpu_context(cpu, mm) != 0) {
Index: linux-2.6/arch/mips/mm/tlb-r4k.c
===================================================================
--- linux-2.6.orig/arch/mips/mm/tlb-r4k.c
+++ linux-2.6/arch/mips/mm/tlb-r4k.c
@@ -112,10 +112,9 @@ void local_flush_tlb_mm(struct mm_struct
 	preempt_enable();
 }
 
-void local_flush_tlb_range(struct vm_area_struct *vma, unsigned long start,
+void local_flush_tlb_range(struct mm_struct *mm, unsigned long start,
 	unsigned long end)
 {
-	struct mm_struct *mm = vma->vm_mm;
 	int cpu = smp_processor_id();
 
 	if (cpu_context(cpu, mm) != 0) {
Index: linux-2.6/arch/mips/mm/tlb-r8k.c
===================================================================
--- linux-2.6.orig/arch/mips/mm/tlb-r8k.c
+++ linux-2.6/arch/mips/mm/tlb-r8k.c
@@ -60,10 +60,9 @@ void local_flush_tlb_mm(struct mm_struct
 		drop_mmu_context(mm, cpu);
 }
 
-void local_flush_tlb_range(struct vm_area_struct *vma, unsigned long start,
+void local_flush_tlb_range(struct mm_struct *mm, unsigned long start,
 	unsigned long end)
 {
-	struct mm_struct *mm = vma->vm_mm;
 	int cpu = smp_processor_id();
 	unsigned long flags;
 	int oldpid, newpid, size;
Index: linux-2.6/arch/mn10300/include/asm/tlbflush.h
===================================================================
--- linux-2.6.orig/arch/mn10300/include/asm/tlbflush.h
+++ linux-2.6/arch/mn10300/include/asm/tlbflush.h
@@ -105,10 +105,10 @@ extern void flush_tlb_page(struct vm_are
 
 #define flush_tlb()		flush_tlb_current_task()
 
-static inline void flush_tlb_range(struct vm_area_struct *vma,
+static inline void flush_tlb_range(struct mm_struct *mm,
 				   unsigned long start, unsigned long end)
 {
-	flush_tlb_mm(vma->vm_mm);
+	flush_tlb_mm(mm);
 }
 
 #else   /* CONFIG_SMP */
@@ -127,7 +127,7 @@ static inline void flush_tlb_mm(struct m
 	preempt_enable();
 }
 
-static inline void flush_tlb_range(struct vm_area_struct *vma,
+static inline void flush_tlb_range(struct mm_struct *mm,
 				   unsigned long start, unsigned long end)
 {
 	preempt_disable();
Index: linux-2.6/arch/parisc/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/parisc/include/asm/tlb.h
+++ linux-2.6/arch/parisc/include/asm/tlb.h
@@ -13,7 +13,7 @@ do {	if (!(tlb)->fullmm)	\
 
 #define tlb_end_vma(tlb, vma)	\
 do {	if (!(tlb)->fullmm)	\
-		flush_tlb_range(vma, vma->vm_start, vma->vm_end); \
+		flush_tlb_range(vma->vm_mm, vma->vm_start, vma->vm_end); \
 } while (0)
 
 #define __tlb_remove_tlb_entry(tlb, pte, address) \
Index: linux-2.6/arch/parisc/include/asm/tlbflush.h
===================================================================
--- linux-2.6.orig/arch/parisc/include/asm/tlbflush.h
+++ linux-2.6/arch/parisc/include/asm/tlbflush.h
@@ -76,7 +76,7 @@ static inline void flush_tlb_page(struct
 void __flush_tlb_range(unsigned long sid,
 	unsigned long start, unsigned long end);
 
-#define flush_tlb_range(vma,start,end) __flush_tlb_range((vma)->vm_mm->context,start,end)
+#define flush_tlb_range(mm,start,end) __flush_tlb_range((mm)->context,start,end)
 
 #define flush_tlb_kernel_range(start, end) __flush_tlb_range(0,start,end)
 
Index: linux-2.6/arch/powerpc/include/asm/tlbflush.h
===================================================================
--- linux-2.6.orig/arch/powerpc/include/asm/tlbflush.h
+++ linux-2.6/arch/powerpc/include/asm/tlbflush.h
@@ -10,7 +10,7 @@
  *                           the local processor
  *  - local_flush_tlb_page(vma, vmaddr) flushes one page on the local processor
  *  - flush_tlb_page_nohash(vma, vmaddr) flushes one page if SW loaded TLB
- *  - flush_tlb_range(vma, start, end) flushes a range of pages
+ *  - flush_tlb_range(mm, start, end) flushes a range of pages
  *  - flush_tlb_kernel_range(start, end) flushes a range of kernel pages
  *
  *  This program is free software; you can redistribute it and/or
@@ -34,7 +34,7 @@ struct mm_struct;
 
 #define MMU_NO_CONTEXT      	((unsigned int)-1)
 
-extern void flush_tlb_range(struct vm_area_struct *vma, unsigned long start,
+extern void flush_tlb_range(struct mm_struct *mm, unsigned long start,
 			    unsigned long end);
 extern void flush_tlb_kernel_range(unsigned long start, unsigned long end);
 
@@ -64,7 +64,7 @@ extern void __flush_tlb_page(struct mm_s
 extern void flush_tlb_mm(struct mm_struct *mm);
 extern void flush_tlb_page(struct vm_area_struct *vma, unsigned long vmaddr);
 extern void flush_tlb_page_nohash(struct vm_area_struct *vma, unsigned long addr);
-extern void flush_tlb_range(struct vm_area_struct *vma, unsigned long start,
+extern void flush_tlb_range(struct mm_struct *mm, unsigned long start,
 			    unsigned long end);
 extern void flush_tlb_kernel_range(unsigned long start, unsigned long end);
 static inline void local_flush_tlb_page(struct vm_area_struct *vma,
@@ -153,7 +153,7 @@ static inline void flush_tlb_page_nohash
 {
 }
 
-static inline void flush_tlb_range(struct vm_area_struct *vma,
+static inline void flush_tlb_range(struct mm_struct *mm,
 				   unsigned long start, unsigned long end)
 {
 }
Index: linux-2.6/arch/powerpc/mm/tlb_hash32.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/tlb_hash32.c
+++ linux-2.6/arch/powerpc/mm/tlb_hash32.c
@@ -78,7 +78,7 @@ void tlb_flush(struct mmu_gather *tlb)
  *
  *  - flush_tlb_mm(mm) flushes the specified mm context TLB's
  *  - flush_tlb_page(vma, vmaddr) flushes one page
- *  - flush_tlb_range(vma, start, end) flushes a range of pages
+ *  - flush_tlb_range(mm, start, end) flushes a range of pages
  *  - flush_tlb_kernel_range(start, end) flushes kernel pages
  *
  * since the hardware hash table functions as an extension of the
@@ -171,9 +171,9 @@ EXPORT_SYMBOL(flush_tlb_page);
  * and check _PAGE_HASHPTE bit; if it is set, find and destroy
  * the corresponding HPTE.
  */
-void flush_tlb_range(struct vm_area_struct *vma, unsigned long start,
+void flush_tlb_range(struct mm_struct *mm, unsigned long start,
 		     unsigned long end)
 {
-	flush_range(vma->vm_mm, start, end);
+	flush_range(mm, start, end);
 }
 EXPORT_SYMBOL(flush_tlb_range);
Index: linux-2.6/arch/powerpc/mm/tlb_nohash.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/tlb_nohash.c
+++ linux-2.6/arch/powerpc/mm/tlb_nohash.c
@@ -107,7 +107,7 @@ unsigned long linear_map_top;	/* Top of 
  *
  *  - flush_tlb_mm(mm) flushes the specified mm context TLB's
  *  - flush_tlb_page(vma, vmaddr) flushes one page
- *  - flush_tlb_range(vma, start, end) flushes a range of pages
+ *  - flush_tlb_range(mm, start, end) flushes a range of pages
  *  - flush_tlb_kernel_range(start, end) flushes kernel pages
  *
  *  - local_* variants of page and mm only apply to the current
@@ -288,7 +288,7 @@ EXPORT_SYMBOL(flush_tlb_kernel_range);
  * some implementation can stack multiple tlbivax before a tlbsync but
  * for now, we keep it that way
  */
-void flush_tlb_range(struct vm_area_struct *vma, unsigned long start,
+void flush_tlb_range(struct mm_struct *mm, unsigned long start,
 		     unsigned long end)
 
 {
Index: linux-2.6/arch/s390/include/asm/tlbflush.h
===================================================================
--- linux-2.6.orig/arch/s390/include/asm/tlbflush.h
+++ linux-2.6/arch/s390/include/asm/tlbflush.h
@@ -108,7 +108,7 @@ static inline void __tlb_flush_mm_cond(s
  *  flush_tlb_all() - flushes all processes TLBs
  *  flush_tlb_mm(mm) - flushes the specified mm context TLB's
  *  flush_tlb_page(vma, vmaddr) - flushes one page
- *  flush_tlb_range(vma, start, end) - flushes a range of pages
+ *  flush_tlb_range(mm, start, end) - flushes a range of pages
  *  flush_tlb_kernel_range(start, end) - flushes a range of kernel pages
  */
 
@@ -129,10 +129,10 @@ static inline void flush_tlb_mm(struct m
 	__tlb_flush_mm_cond(mm);
 }
 
-static inline void flush_tlb_range(struct vm_area_struct *vma,
+static inline void flush_tlb_range(struct mm_struct *mm,
 				   unsigned long start, unsigned long end)
 {
-	__tlb_flush_mm_cond(vma->vm_mm);
+	__tlb_flush_mm_cond(mm);
 }
 
 static inline void flush_tlb_kernel_range(unsigned long start,
Index: linux-2.6/arch/score/include/asm/tlbflush.h
===================================================================
--- linux-2.6.orig/arch/score/include/asm/tlbflush.h
+++ linux-2.6/arch/score/include/asm/tlbflush.h
@@ -14,7 +14,7 @@
  */
 extern void local_flush_tlb_all(void);
 extern void local_flush_tlb_mm(struct mm_struct *mm);
-extern void local_flush_tlb_range(struct vm_area_struct *vma,
+extern void local_flush_tlb_range(struct mm_struct *mm,
 	unsigned long start, unsigned long end);
 extern void local_flush_tlb_kernel_range(unsigned long start,
 	unsigned long end);
@@ -24,8 +24,8 @@ extern void local_flush_tlb_one(unsigned
 
 #define flush_tlb_all()			local_flush_tlb_all()
 #define flush_tlb_mm(mm)		local_flush_tlb_mm(mm)
-#define flush_tlb_range(vma, vmaddr, end) \
-	local_flush_tlb_range(vma, vmaddr, end)
+#define flush_tlb_range(mm, vmaddr, end) \
+	local_flush_tlb_range(mm, vmaddr, end)
 #define flush_tlb_kernel_range(vmaddr, end) \
 	local_flush_tlb_kernel_range(vmaddr, end)
 #define flush_tlb_page(vma, page)	local_flush_tlb_page(vma, page)
Index: linux-2.6/arch/score/mm/tlb-score.c
===================================================================
--- linux-2.6.orig/arch/score/mm/tlb-score.c
+++ linux-2.6/arch/score/mm/tlb-score.c
@@ -77,10 +77,9 @@ void local_flush_tlb_mm(struct mm_struct
 		drop_mmu_context(mm);
 }
 
-void local_flush_tlb_range(struct vm_area_struct *vma, unsigned long start,
+void local_flush_tlb_range(struct mm_struct *mm, unsigned long start,
 	unsigned long end)
 {
-	struct mm_struct *mm = vma->vm_mm;
 	unsigned long vma_mm_context = mm->context;
 	if (mm->context != 0) {
 		unsigned long flags;
Index: linux-2.6/arch/sh/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/sh/include/asm/tlb.h
+++ linux-2.6/arch/sh/include/asm/tlb.h
@@ -78,7 +78,7 @@ static inline void
 tlb_end_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
 {
 	if (!tlb->fullmm && tlb->end) {
-		flush_tlb_range(vma, tlb->start, tlb->end);
+		flush_tlb_range(vma->vm_mm, tlb->start, tlb->end);
 		init_tlb_gather(tlb);
 	}
 }
Index: linux-2.6/arch/sh/include/asm/tlbflush.h
===================================================================
--- linux-2.6.orig/arch/sh/include/asm/tlbflush.h
+++ linux-2.6/arch/sh/include/asm/tlbflush.h
@@ -7,12 +7,12 @@
  *  - flush_tlb_all() flushes all processes TLBs
  *  - flush_tlb_mm(mm) flushes the specified mm context TLB's
  *  - flush_tlb_page(vma, vmaddr) flushes one page
- *  - flush_tlb_range(vma, start, end) flushes a range of pages
+ *  - flush_tlb_range(mm, start, end) flushes a range of pages
  *  - flush_tlb_kernel_range(start, end) flushes a range of kernel pages
  */
 extern void local_flush_tlb_all(void);
 extern void local_flush_tlb_mm(struct mm_struct *mm);
-extern void local_flush_tlb_range(struct vm_area_struct *vma,
+extern void local_flush_tlb_range(struct mm_struct *mm,
 				  unsigned long start,
 				  unsigned long end);
 extern void local_flush_tlb_page(struct vm_area_struct *vma,
@@ -27,7 +27,7 @@ extern void __flush_tlb_global(void);
 
 extern void flush_tlb_all(void);
 extern void flush_tlb_mm(struct mm_struct *mm);
-extern void flush_tlb_range(struct vm_area_struct *vma, unsigned long start,
+extern void flush_tlb_range(struct mm_struct *mm, unsigned long start,
 			    unsigned long end);
 extern void flush_tlb_page(struct vm_area_struct *vma, unsigned long page);
 extern void flush_tlb_kernel_range(unsigned long start, unsigned long end);
@@ -40,8 +40,8 @@ extern void flush_tlb_one(unsigned long 
 #define flush_tlb_page(vma, page)	local_flush_tlb_page(vma, page)
 #define flush_tlb_one(asid, page)	local_flush_tlb_one(asid, page)
 
-#define flush_tlb_range(vma, start, end)	\
-	local_flush_tlb_range(vma, start, end)
+#define flush_tlb_range(mm, start, end)	\
+	local_flush_tlb_range(mm, start, end)
 
 #define flush_tlb_kernel_range(start, end)	\
 	local_flush_tlb_kernel_range(start, end)
Index: linux-2.6/arch/sh/kernel/smp.c
===================================================================
--- linux-2.6.orig/arch/sh/kernel/smp.c
+++ linux-2.6/arch/sh/kernel/smp.c
@@ -390,7 +390,7 @@ void flush_tlb_mm(struct mm_struct *mm)
 }
 
 struct flush_tlb_data {
-	struct vm_area_struct *vma;
+	struct mm_struct *mm;
 	unsigned long addr1;
 	unsigned long addr2;
 };
@@ -399,19 +399,17 @@ static void flush_tlb_range_ipi(void *in
 {
 	struct flush_tlb_data *fd = (struct flush_tlb_data *)info;
 
-	local_flush_tlb_range(fd->vma, fd->addr1, fd->addr2);
+	local_flush_tlb_range(fd->mm, fd->addr1, fd->addr2);
 }
 
-void flush_tlb_range(struct vm_area_struct *vma,
+void flush_tlb_range(struct mm_struct *mm,
 		     unsigned long start, unsigned long end)
 {
-	struct mm_struct *mm = vma->vm_mm;
-
 	preempt_disable();
 	if ((atomic_read(&mm->mm_users) != 1) || (current->mm != mm)) {
 		struct flush_tlb_data fd;
 
-		fd.vma = vma;
+		fd.mm = mm;
 		fd.addr1 = start;
 		fd.addr2 = end;
 		smp_call_function(flush_tlb_range_ipi, (void *)&fd, 1);
@@ -421,7 +419,7 @@ void flush_tlb_range(struct vm_area_stru
 			if (smp_processor_id() != i)
 				cpu_context(i, mm) = 0;
 	}
-	local_flush_tlb_range(vma, start, end);
+	local_flush_tlb_range(mm, start, end);
 	preempt_enable();
 }
 
Index: linux-2.6/arch/sh/mm/nommu.c
===================================================================
--- linux-2.6.orig/arch/sh/mm/nommu.c
+++ linux-2.6/arch/sh/mm/nommu.c
@@ -46,7 +46,7 @@ void local_flush_tlb_mm(struct mm_struct
 	BUG();
 }
 
-void local_flush_tlb_range(struct vm_area_struct *vma, unsigned long start,
+void local_flush_tlb_range(struct mm_struct *mm, unsigned long start,
 			    unsigned long end)
 {
 	BUG();
Index: linux-2.6/arch/sh/mm/tlbflush_32.c
===================================================================
--- linux-2.6.orig/arch/sh/mm/tlbflush_32.c
+++ linux-2.6/arch/sh/mm/tlbflush_32.c
@@ -36,10 +36,9 @@ void local_flush_tlb_page(struct vm_area
 	}
 }
 
-void local_flush_tlb_range(struct vm_area_struct *vma, unsigned long start,
+void local_flush_tlb_range(struct mm_struct *mm, unsigned long start,
 			   unsigned long end)
 {
-	struct mm_struct *mm = vma->vm_mm;
 	unsigned int cpu = smp_processor_id();
 
 	if (cpu_context(cpu, mm) != NO_CONTEXT) {
Index: linux-2.6/arch/sh/mm/tlbflush_64.c
===================================================================
--- linux-2.6.orig/arch/sh/mm/tlbflush_64.c
+++ linux-2.6/arch/sh/mm/tlbflush_64.c
@@ -365,16 +365,14 @@ void local_flush_tlb_page(struct vm_area
 	}
 }
 
-void local_flush_tlb_range(struct vm_area_struct *vma, unsigned long start,
+void local_flush_tlb_range(struct mm_struct *mm, unsigned long start,
 			   unsigned long end)
 {
 	unsigned long flags;
 	unsigned long long match, pteh=0, pteh_epn, pteh_low;
 	unsigned long tlb;
 	unsigned int cpu = smp_processor_id();
-	struct mm_struct *mm;
 
-	mm = vma->vm_mm;
 	if (cpu_context(cpu, mm) == NO_CONTEXT)
 		return;
 
Index: linux-2.6/arch/sparc/include/asm/tlb_32.h
===================================================================
--- linux-2.6.orig/arch/sparc/include/asm/tlb_32.h
+++ linux-2.6/arch/sparc/include/asm/tlb_32.h
@@ -8,7 +8,7 @@ do {								\
 
 #define tlb_end_vma(tlb, vma) \
 do {								\
-	flush_tlb_range(vma, vma->vm_start, vma->vm_end);	\
+	flush_tlb_range(vma->vm_mm, vma->vm_start, vma->vm_end);\
 } while (0)
 
 #define __tlb_remove_tlb_entry(tlb, pte, address) \
Index: linux-2.6/arch/sparc/include/asm/tlbflush_32.h
===================================================================
--- linux-2.6.orig/arch/sparc/include/asm/tlbflush_32.h
+++ linux-2.6/arch/sparc/include/asm/tlbflush_32.h
@@ -11,7 +11,7 @@
  *  - flush_tlb_all() flushes all processes TLBs
  *  - flush_tlb_mm(mm) flushes the specified mm context TLB's
  *  - flush_tlb_page(vma, vmaddr) flushes one page
- *  - flush_tlb_range(vma, start, end) flushes a range of pages
+ *  - flush_tlb_range(mm, start, end) flushes a range of pages
  *  - flush_tlb_kernel_range(start, end) flushes a range of kernel pages
  */
 
@@ -19,17 +19,17 @@
 
 BTFIXUPDEF_CALL(void, local_flush_tlb_all, void)
 BTFIXUPDEF_CALL(void, local_flush_tlb_mm, struct mm_struct *)
-BTFIXUPDEF_CALL(void, local_flush_tlb_range, struct vm_area_struct *, unsigned long, unsigned long)
+BTFIXUPDEF_CALL(void, local_flush_tlb_range, struct mm_struct *, unsigned long, unsigned long)
 BTFIXUPDEF_CALL(void, local_flush_tlb_page, struct vm_area_struct *, unsigned long)
 
 #define local_flush_tlb_all() BTFIXUP_CALL(local_flush_tlb_all)()
 #define local_flush_tlb_mm(mm) BTFIXUP_CALL(local_flush_tlb_mm)(mm)
-#define local_flush_tlb_range(vma,start,end) BTFIXUP_CALL(local_flush_tlb_range)(vma,start,end)
+#define local_flush_tlb_range(mm,start,end) BTFIXUP_CALL(local_flush_tlb_range)(mm,start,end)
 #define local_flush_tlb_page(vma,addr) BTFIXUP_CALL(local_flush_tlb_page)(vma,addr)
 
 extern void smp_flush_tlb_all(void);
 extern void smp_flush_tlb_mm(struct mm_struct *mm);
-extern void smp_flush_tlb_range(struct vm_area_struct *vma,
+extern void smp_flush_tlb_range(struct mm_struct *mm,
 				  unsigned long start,
 				  unsigned long end);
 extern void smp_flush_tlb_page(struct vm_area_struct *mm, unsigned long page);
@@ -38,12 +38,12 @@ extern void smp_flush_tlb_page(struct vm
 
 BTFIXUPDEF_CALL(void, flush_tlb_all, void)
 BTFIXUPDEF_CALL(void, flush_tlb_mm, struct mm_struct *)
-BTFIXUPDEF_CALL(void, flush_tlb_range, struct vm_area_struct *, unsigned long, unsigned long)
+BTFIXUPDEF_CALL(void, flush_tlb_range, struct mm_struct *, unsigned long, unsigned long)
 BTFIXUPDEF_CALL(void, flush_tlb_page, struct vm_area_struct *, unsigned long)
 
 #define flush_tlb_all() BTFIXUP_CALL(flush_tlb_all)()
 #define flush_tlb_mm(mm) BTFIXUP_CALL(flush_tlb_mm)(mm)
-#define flush_tlb_range(vma,start,end) BTFIXUP_CALL(flush_tlb_range)(vma,start,end)
+#define flush_tlb_range(mm,start,end) BTFIXUP_CALL(flush_tlb_range)(mm,start,end)
 #define flush_tlb_page(vma,addr) BTFIXUP_CALL(flush_tlb_page)(vma,addr)
 
 // #define flush_tlb() flush_tlb_mm(current->active_mm)	/* XXX Sure? */
Index: linux-2.6/arch/sparc/include/asm/tlbflush_64.h
===================================================================
--- linux-2.6.orig/arch/sparc/include/asm/tlbflush_64.h
+++ linux-2.6/arch/sparc/include/asm/tlbflush_64.h
@@ -21,7 +21,7 @@ extern void flush_tsb_user(struct tlb_ba
 
 extern void flush_tlb_pending(void);
 
-#define flush_tlb_range(vma,start,end)	\
+#define flush_tlb_range(mm,start,end)	\
 	do { (void)(start); flush_tlb_pending(); } while (0)
 #define flush_tlb_page(vma,addr)	flush_tlb_pending()
 #define flush_tlb_mm(mm)		flush_tlb_pending()
Index: linux-2.6/arch/sparc/kernel/smp_32.c
===================================================================
--- linux-2.6.orig/arch/sparc/kernel/smp_32.c
+++ linux-2.6/arch/sparc/kernel/smp_32.c
@@ -184,17 +184,15 @@ void smp_flush_cache_range(struct vm_are
 	}
 }
 
-void smp_flush_tlb_range(struct vm_area_struct *vma, unsigned long start,
+void smp_flush_tlb_range(struct mm_struct *mm, unsigned long start,
 			 unsigned long end)
 {
-	struct mm_struct *mm = vma->vm_mm;
-
 	if (mm->context != NO_CONTEXT) {
 		cpumask_t cpu_mask = *mm_cpumask(mm);
 		cpu_clear(smp_processor_id(), cpu_mask);
 		if (!cpus_empty(cpu_mask))
-			xc3((smpfunc_t) BTFIXUP_CALL(local_flush_tlb_range), (unsigned long) vma, start, end);
-		local_flush_tlb_range(vma, start, end);
+			xc3((smpfunc_t) BTFIXUP_CALL(local_flush_tlb_range), (unsigned long) mm, start, end);
+		local_flush_tlb_range(mm, start, end);
 	}
 }
 
Index: linux-2.6/arch/sparc/mm/generic_32.c
===================================================================
--- linux-2.6.orig/arch/sparc/mm/generic_32.c
+++ linux-2.6/arch/sparc/mm/generic_32.c
@@ -92,7 +92,7 @@ int io_remap_pfn_range(struct vm_area_st
 		dir++;
 	}
 
-	flush_tlb_range(vma, beg, end);
+	flush_tlb_range(vma->vm_mm, beg, end);
 	return error;
 }
 EXPORT_SYMBOL(io_remap_pfn_range);
Index: linux-2.6/arch/sparc/mm/generic_64.c
===================================================================
--- linux-2.6.orig/arch/sparc/mm/generic_64.c
+++ linux-2.6/arch/sparc/mm/generic_64.c
@@ -158,7 +158,7 @@ int io_remap_pfn_range(struct vm_area_st
 		dir++;
 	}
 
-	flush_tlb_range(vma, beg, end);
+	flush_tlb_range(vma->vm_mm, beg, end);
 	return error;
 }
 EXPORT_SYMBOL(io_remap_pfn_range);
Index: linux-2.6/arch/sparc/mm/hypersparc.S
===================================================================
--- linux-2.6.orig/arch/sparc/mm/hypersparc.S
+++ linux-2.6/arch/sparc/mm/hypersparc.S
@@ -284,7 +284,6 @@
 	 sta	%g5, [%g1] ASI_M_MMUREGS
 
 hypersparc_flush_tlb_range:
-	ld	[%o0 + 0x00], %o0	/* XXX vma->vm_mm GROSS XXX */
 	mov	SRMMU_CTX_REG, %g1
 	ld	[%o0 + AOFF_mm_context], %o3
 	lda	[%g1] ASI_M_MMUREGS, %g5
Index: linux-2.6/arch/sparc/mm/srmmu.c
===================================================================
--- linux-2.6.orig/arch/sparc/mm/srmmu.c
+++ linux-2.6/arch/sparc/mm/srmmu.c
@@ -679,7 +679,7 @@ extern void tsunami_flush_page_for_dma(u
 extern void tsunami_flush_sig_insns(struct mm_struct *mm, unsigned long insn_addr);
 extern void tsunami_flush_tlb_all(void);
 extern void tsunami_flush_tlb_mm(struct mm_struct *mm);
-extern void tsunami_flush_tlb_range(struct vm_area_struct *vma, unsigned long start, unsigned long end);
+extern void tsunami_flush_tlb_range(struct mm_struct *mm, unsigned long start, unsigned long end);
 extern void tsunami_flush_tlb_page(struct vm_area_struct *vma, unsigned long page);
 extern void tsunami_setup_blockops(void);
 
@@ -726,7 +726,7 @@ extern void swift_flush_page_for_dma(uns
 extern void swift_flush_sig_insns(struct mm_struct *mm, unsigned long insn_addr);
 extern void swift_flush_tlb_all(void);
 extern void swift_flush_tlb_mm(struct mm_struct *mm);
-extern void swift_flush_tlb_range(struct vm_area_struct *vma,
+extern void swift_flush_tlb_range(struct mm_struct *mm,
 				  unsigned long start, unsigned long end);
 extern void swift_flush_tlb_page(struct vm_area_struct *vma, unsigned long page);
 
@@ -964,9 +964,8 @@ static void cypress_flush_tlb_mm(struct 
 	FLUSH_END
 }
 
-static void cypress_flush_tlb_range(struct vm_area_struct *vma, unsigned long start, unsigned long end)
+static void cypress_flush_tlb_range(struct mm_struct *mm, unsigned long start, unsigned long end)
 {
-	struct mm_struct *mm = vma->vm_mm;
 	unsigned long size;
 
 	FLUSH_BEGIN(mm)
@@ -1018,13 +1017,13 @@ extern void viking_flush_page(unsigned l
 extern void viking_mxcc_flush_page(unsigned long page);
 extern void viking_flush_tlb_all(void);
 extern void viking_flush_tlb_mm(struct mm_struct *mm);
-extern void viking_flush_tlb_range(struct vm_area_struct *vma, unsigned long start,
+extern void viking_flush_tlb_range(struct mm_struct *mm, unsigned long start,
 				   unsigned long end);
 extern void viking_flush_tlb_page(struct vm_area_struct *vma,
 				  unsigned long page);
 extern void sun4dsmp_flush_tlb_all(void);
 extern void sun4dsmp_flush_tlb_mm(struct mm_struct *mm);
-extern void sun4dsmp_flush_tlb_range(struct vm_area_struct *vma, unsigned long start,
+extern void sun4dsmp_flush_tlb_range(struct mm_struct *mm, unsigned long start,
 				   unsigned long end);
 extern void sun4dsmp_flush_tlb_page(struct vm_area_struct *vma,
 				  unsigned long page);
@@ -1039,7 +1038,7 @@ extern void hypersparc_flush_page_for_dm
 extern void hypersparc_flush_sig_insns(struct mm_struct *mm, unsigned long insn_addr);
 extern void hypersparc_flush_tlb_all(void);
 extern void hypersparc_flush_tlb_mm(struct mm_struct *mm);
-extern void hypersparc_flush_tlb_range(struct vm_area_struct *vma, unsigned long start, unsigned long end);
+extern void hypersparc_flush_tlb_range(struct mm_struct *mm, unsigned long start, unsigned long end);
 extern void hypersparc_flush_tlb_page(struct vm_area_struct *vma, unsigned long page);
 extern void hypersparc_setup_blockops(void);
 
@@ -1761,9 +1760,9 @@ static void turbosparc_flush_tlb_mm(stru
 	FLUSH_END
 }
 
-static void turbosparc_flush_tlb_range(struct vm_area_struct *vma, unsigned long start, unsigned long end)
+static void turbosparc_flush_tlb_range(struct mm_struct *mm, unsigned long start, unsigned long end)
 {
-	FLUSH_BEGIN(vma->vm_mm)
+	FLUSH_BEGIN(mm)
 	srmmu_flush_whole_tlb();
 	FLUSH_END
 }
Index: linux-2.6/arch/sparc/mm/sun4c.c
===================================================================
--- linux-2.6.orig/arch/sparc/mm/sun4c.c
+++ linux-2.6/arch/sparc/mm/sun4c.c
@@ -1419,9 +1419,8 @@ static void sun4c_flush_tlb_mm(struct mm
 	}
 }
 
-static void sun4c_flush_tlb_range(struct vm_area_struct *vma, unsigned long start, unsigned long end)
+static void sun4c_flush_tlb_range(struct mm_struct *mm, unsigned long start, unsigned long end)
 {
-	struct mm_struct *mm = vma->vm_mm;
 	int new_ctx = mm->context;
 
 	if (new_ctx != NO_CONTEXT) {
Index: linux-2.6/arch/sparc/mm/swift.S
===================================================================
--- linux-2.6.orig/arch/sparc/mm/swift.S
+++ linux-2.6/arch/sparc/mm/swift.S
@@ -219,7 +219,6 @@
 	.globl	swift_flush_tlb_range
 	.globl	swift_flush_tlb_all
 swift_flush_tlb_range:
-	ld	[%o0 + 0x00], %o0	/* XXX vma->vm_mm GROSS XXX */
 swift_flush_tlb_mm:
 	ld	[%o0 + AOFF_mm_context], %g2
 	cmp	%g2, -1
Index: linux-2.6/arch/sparc/mm/tsunami.S
===================================================================
--- linux-2.6.orig/arch/sparc/mm/tsunami.S
+++ linux-2.6/arch/sparc/mm/tsunami.S
@@ -46,7 +46,6 @@
 
 	/* More slick stuff... */
 tsunami_flush_tlb_range:
-	ld	[%o0 + 0x00], %o0	/* XXX vma->vm_mm GROSS XXX */
 tsunami_flush_tlb_mm:
 	ld	[%o0 + AOFF_mm_context], %g2
 	cmp	%g2, -1
Index: linux-2.6/arch/sparc/mm/viking.S
===================================================================
--- linux-2.6.orig/arch/sparc/mm/viking.S
+++ linux-2.6/arch/sparc/mm/viking.S
@@ -149,7 +149,6 @@
 #endif
 
 viking_flush_tlb_range:
-	ld	[%o0 + 0x00], %o0	/* XXX vma->vm_mm GROSS XXX */
 	mov	SRMMU_CTX_REG, %g1
 	ld	[%o0 + AOFF_mm_context], %o3
 	lda	[%g1] ASI_M_MMUREGS, %g5
@@ -240,7 +239,6 @@
 	tst	%g5
 	bne	3f
 	 mov	SRMMU_CTX_REG, %g1
-	ld	[%o0 + 0x00], %o0	/* XXX vma->vm_mm GROSS XXX */
 	ld	[%o0 + AOFF_mm_context], %o3
 	lda	[%g1] ASI_M_MMUREGS, %g5
 	sethi	%hi(~((1 << SRMMU_PGDIR_SHIFT) - 1)), %o4
Index: linux-2.6/arch/tile/include/asm/tlbflush.h
===================================================================
--- linux-2.6.orig/arch/tile/include/asm/tlbflush.h
+++ linux-2.6/arch/tile/include/asm/tlbflush.h
@@ -105,7 +105,7 @@ static inline void local_flush_tlb_all(v
  *  - flush_tlb_all() flushes all processes TLBs
  *  - flush_tlb_mm(mm) flushes the specified mm context TLB's
  *  - flush_tlb_page(vma, vmaddr) flushes one page
- *  - flush_tlb_range(vma, start, end) flushes a range of pages
+ *  - flush_tlb_range(mm, start, end) flushes a range of pages
  *  - flush_tlb_kernel_range(start, end) flushes a range of kernel pages
  *  - flush_tlb_others(cpumask, mm, va) flushes TLBs on other cpus
  *
@@ -120,7 +120,7 @@ extern void flush_tlb_mm(struct mm_struc
 extern void flush_tlb_page(const struct vm_area_struct *, unsigned long);
 extern void flush_tlb_page_mm(const struct vm_area_struct *,
 			      struct mm_struct *, unsigned long);
-extern void flush_tlb_range(const struct vm_area_struct *,
+extern void flush_tlb_range(const struct mm_struct *,
 			    unsigned long start, unsigned long end);
 
 #define flush_tlb()     flush_tlb_current_task()
Index: linux-2.6/arch/tile/kernel/tlb.c
===================================================================
--- linux-2.6.orig/arch/tile/kernel/tlb.c
+++ linux-2.6/arch/tile/kernel/tlb.c
@@ -64,14 +64,13 @@ void flush_tlb_page(const struct vm_area
 }
 EXPORT_SYMBOL(flush_tlb_page);
 
-void flush_tlb_range(const struct vm_area_struct *vma,
+void flush_tlb_range(const struct mm_struct *mm,
 		     unsigned long start, unsigned long end)
 {
-	unsigned long size = hv_page_size(vma);
-	struct mm_struct *mm = vma->vm_mm;
-	int cache = (vma->vm_flags & VM_EXEC) ? HV_FLUSH_EVICT_L1I : 0;
-	flush_remote(0, cache, &mm->cpu_vm_mask, start, end - start, size,
-		     &mm->cpu_vm_mask, NULL, 0);
+	flush_remote(0, HV_FLUSH_EVICT_L1I, &mm->cpu_vm_mask,
+		     start, end - start, PAGE_SIZE, &mm->cpu_vm_mask, NULL, 0);
+	flush_remote(0, 0, &mm->cpu_vm_mask,
+		     start, end - start, HPAGE_SIZE, &mm->cpu_vm_mask, NULL, 0);
 }
 
 void flush_tlb_all(void)
Index: linux-2.6/arch/um/include/asm/tlbflush.h
===================================================================
--- linux-2.6.orig/arch/um/include/asm/tlbflush.h
+++ linux-2.6/arch/um/include/asm/tlbflush.h
@@ -16,12 +16,12 @@
  *  - flush_tlb_mm(mm) flushes the specified mm context TLB's
  *  - flush_tlb_page(vma, vmaddr) flushes one page
  *  - flush_tlb_kernel_vm() flushes the kernel vm area
- *  - flush_tlb_range(vma, start, end) flushes a range of pages
+ *  - flush_tlb_range(mm, start, end) flushes a range of pages
  */
 
 extern void flush_tlb_all(void);
 extern void flush_tlb_mm(struct mm_struct *mm);
-extern void flush_tlb_range(struct vm_area_struct *vma, unsigned long start, 
+extern void flush_tlb_range(struct mm_struct *mm, unsigned long start,
 			    unsigned long end);
 extern void flush_tlb_page(struct vm_area_struct *vma, unsigned long address);
 extern void flush_tlb_kernel_vm(void);
Index: linux-2.6/arch/um/kernel/tlb.c
===================================================================
--- linux-2.6.orig/arch/um/kernel/tlb.c
+++ linux-2.6/arch/um/kernel/tlb.c
@@ -492,12 +492,12 @@ static void fix_range(struct mm_struct *
 	fix_range_common(mm, start_addr, end_addr, force);
 }
 
-void flush_tlb_range(struct vm_area_struct *vma, unsigned long start,
+void flush_tlb_range(struct mm_struct *mm, unsigned long start,
 		     unsigned long end)
 {
-	if (vma->vm_mm == NULL)
+	if (mm == NULL)
 		flush_tlb_kernel_range_common(start, end);
-	else fix_range(vma->vm_mm, start, end, 0);
+	else fix_range(mm, start, end, 0);
 }
 
 void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
Index: linux-2.6/arch/unicore32/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/unicore32/include/asm/tlb.h
+++ linux-2.6/arch/unicore32/include/asm/tlb.h
@@ -77,7 +77,7 @@ static inline void
 tlb_end_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
 {
 	if (!tlb->fullmm && tlb->range_end > 0)
-		flush_tlb_range(vma, tlb->range_start, tlb->range_end);
+		flush_tlb_range(vma->vm_mm, tlb->range_start, tlb->range_end);
 }
 
 static inline void tlb_flush_mmu(struct mmu_gather *tlb)
Index: linux-2.6/arch/unicore32/include/asm/tlbflush.h
===================================================================
--- linux-2.6.orig/arch/unicore32/include/asm/tlbflush.h
+++ linux-2.6/arch/unicore32/include/asm/tlbflush.h
@@ -167,7 +167,7 @@ static inline void clean_pmd_entry(pmd_t
 /*
  * Convert calls to our calling convention.
  */
-#define local_flush_tlb_range(vma, start, end)	\
+#define local_flush_tlb_range(mm, start, end)	\
 	__cpu_flush_user_tlb_range(start, end, vma)
 #define local_flush_tlb_kernel_range(s, e)	\
 	__cpu_flush_kern_tlb_range(s, e)
Index: linux-2.6/arch/x86/include/asm/tlbflush.h
===================================================================
--- linux-2.6.orig/arch/x86/include/asm/tlbflush.h
+++ linux-2.6/arch/x86/include/asm/tlbflush.h
@@ -75,7 +75,7 @@ static inline void __flush_tlb_one(unsig
  *  - flush_tlb_all() flushes all processes TLBs
  *  - flush_tlb_mm(mm) flushes the specified mm context TLB's
  *  - flush_tlb_page(vma, vmaddr) flushes one page
- *  - flush_tlb_range(vma, start, end) flushes a range of pages
+ *  - flush_tlb_range(mm, start, end) flushes a range of pages
  *  - flush_tlb_kernel_range(start, end) flushes a range of kernel pages
  *  - flush_tlb_others(cpumask, mm, va) flushes TLBs on other cpus
  *
@@ -106,10 +106,10 @@ static inline void flush_tlb_page(struct
 		__flush_tlb_one(addr);
 }
 
-static inline void flush_tlb_range(struct vm_area_struct *vma,
+static inline void flush_tlb_range(struct mm_struct *mm,
 				   unsigned long start, unsigned long end)
 {
-	if (vma->vm_mm == current->active_mm)
+	if (mm == current->active_mm)
 		__flush_tlb();
 }
 
@@ -136,10 +136,10 @@ extern void flush_tlb_page(struct vm_are
 
 #define flush_tlb()	flush_tlb_current_task()
 
-static inline void flush_tlb_range(struct vm_area_struct *vma,
+static inline void flush_tlb_range(struct mm_struct *mm,
 				   unsigned long start, unsigned long end)
 {
-	flush_tlb_mm(vma->vm_mm);
+	flush_tlb_mm(mm);
 }
 
 void native_flush_tlb_others(const struct cpumask *cpumask,
Index: linux-2.6/arch/x86/mm/pgtable.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/pgtable.c
+++ linux-2.6/arch/x86/mm/pgtable.c
@@ -332,7 +332,7 @@ int pmdp_set_access_flags(struct vm_area
 	if (changed && dirty) {
 		*pmdp = entry;
 		pmd_update_defer(vma->vm_mm, address, pmdp);
-		flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
+		flush_tlb_range(vma->vm_mm, address, address + HPAGE_PMD_SIZE);
 	}
 
 	return changed;
@@ -393,7 +393,7 @@ int pmdp_clear_flush_young(struct vm_are
 
 	young = pmdp_test_and_clear_young(vma, address, pmdp);
 	if (young)
-		flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
+		flush_tlb_range(vma->vm_mm, address, address + HPAGE_PMD_SIZE);
 
 	return young;
 }
@@ -408,7 +408,7 @@ void pmdp_splitting_flush(struct vm_area
 	if (set) {
 		pmd_update(vma->vm_mm, address, pmdp);
 		/* need tlb flush only to serialize against gup-fast */
-		flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
+		flush_tlb_range(vma->vm_mm, address, address + HPAGE_PMD_SIZE);
 	}
 }
 #endif
Index: linux-2.6/arch/xtensa/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/xtensa/include/asm/tlb.h
+++ linux-2.6/arch/xtensa/include/asm/tlb.h
@@ -32,7 +32,7 @@
 # define tlb_end_vma(tlb, vma)						      \
 	do {								      \
 		if (!tlb->fullmm)					      \
-			flush_tlb_range(vma, vma->vm_start, vma->vm_end);     \
+			flush_tlb_range(vma->vm_mm, vma->vm_start, vma->vm_end);     \
 	} while(0)
 
 #endif
Index: linux-2.6/arch/xtensa/include/asm/tlbflush.h
===================================================================
--- linux-2.6.orig/arch/xtensa/include/asm/tlbflush.h
+++ linux-2.6/arch/xtensa/include/asm/tlbflush.h
@@ -37,7 +37,7 @@
 extern void flush_tlb_all(void);
 extern void flush_tlb_mm(struct mm_struct*);
 extern void flush_tlb_page(struct vm_area_struct*,unsigned long);
-extern void flush_tlb_range(struct vm_area_struct*,unsigned long,unsigned long);
+extern void flush_tlb_range(struct mm_struct*,unsigned long,unsigned long);
 
 #define flush_tlb_kernel_range(start,end) flush_tlb_all()
 
Index: linux-2.6/arch/xtensa/mm/tlb.c
===================================================================
--- linux-2.6.orig/arch/xtensa/mm/tlb.c
+++ linux-2.6/arch/xtensa/mm/tlb.c
@@ -82,10 +82,9 @@ void flush_tlb_mm(struct mm_struct *mm)
 # define _TLB_ENTRIES _DTLB_ENTRIES
 #endif
 
-void flush_tlb_range (struct vm_area_struct *vma,
+void flush_tlb_range (struct mm_struct *mm,
     		      unsigned long start, unsigned long end)
 {
-	struct mm_struct *mm = vma->vm_mm;
 	unsigned long flags;
 
 	if (mm->context == NO_CONTEXT)
Index: linux-2.6/mm/huge_memory.c
===================================================================
--- linux-2.6.orig/mm/huge_memory.c
+++ linux-2.6/mm/huge_memory.c
@@ -1058,8 +1058,8 @@ int change_huge_pmd(struct vm_area_struc
 			entry = pmdp_get_and_clear(mm, addr, pmd);
 			entry = pmd_modify(entry, newprot);
 			set_pmd_at(mm, addr, pmd, entry);
-			spin_unlock(&vma->vm_mm->page_table_lock);
-			flush_tlb_range(vma, addr, addr + HPAGE_PMD_SIZE);
+			spin_unlock(&mm->page_table_lock);
+			flush_tlb_range(mm, addr, addr + HPAGE_PMD_SIZE);
 			ret = 1;
 		}
 	} else
@@ -1313,7 +1313,7 @@ static int __split_huge_page_map(struct 
 		 * of the pmd entry with pmd_populate.
 		 */
 		set_pmd_at(mm, address, pmd, pmd_mknotpresent(*pmd));
-		flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
+		flush_tlb_range(mm, address, address + HPAGE_PMD_SIZE);
 		pmd_populate(mm, pmd, pgtable);
 		ret = 1;
 	}
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -2264,7 +2264,7 @@ void __unmap_hugepage_range(struct vm_ar
 		list_add(&page->lru, &page_list);
 	}
 	spin_unlock(&mm->page_table_lock);
-	flush_tlb_range(vma, start, end);
+	flush_tlb_range(mm, start, end);
 	mmu_notifier_invalidate_range_end(mm, start, end);
 	list_for_each_entry_safe(page, tmp, &page_list, lru) {
 		page_remove_rmap(page);
@@ -2829,7 +2829,7 @@ void hugetlb_change_protection(struct vm
 	spin_unlock(&mm->page_table_lock);
 	mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
 
-	flush_tlb_range(vma, start, end);
+	flush_tlb_range(mm, start, end);
 }
 
 int hugetlb_reserve_pages(struct inode *inode,
Index: linux-2.6/mm/mprotect.c
===================================================================
--- linux-2.6.orig/mm/mprotect.c
+++ linux-2.6/mm/mprotect.c
@@ -138,7 +138,7 @@ static void change_protection(struct vm_
 		change_pud_range(vma, pgd, addr, next, newprot,
 				 dirty_accountable);
 	} while (pgd++, addr = next, addr != end);
-	flush_tlb_range(vma, start, end);
+	flush_tlb_range(mm, start, end);
 }
 
 int
Index: linux-2.6/mm/pgtable-generic.c
===================================================================
--- linux-2.6.orig/mm/pgtable-generic.c
+++ linux-2.6/mm/pgtable-generic.c
@@ -43,7 +43,7 @@ int pmdp_set_access_flags(struct vm_area
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 	if (changed) {
 		set_pmd_at(vma->vm_mm, address, pmdp, entry);
-		flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
+		flush_tlb_range(vma->vm_mm, address, address + HPAGE_PMD_SIZE);
 	}
 	return changed;
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
@@ -76,7 +76,7 @@ int pmdp_clear_flush_young(struct vm_are
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 	young = pmdp_test_and_clear_young(vma, address, pmdp);
 	if (young)
-		flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
+		flush_tlb_range(vma->vm_mm, address, address + HPAGE_PMD_SIZE);
 	return young;
 }
 #endif
@@ -100,7 +100,7 @@ pmd_t pmdp_clear_flush(struct vm_area_st
 	pmd_t pmd;
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 	pmd = pmdp_get_and_clear(vma->vm_mm, address, pmdp);
-	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
+	flush_tlb_range(vma->vm_mm, address, address + HPAGE_PMD_SIZE);
 	return pmd;
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
@@ -115,7 +115,7 @@ pmd_t pmdp_splitting_flush(struct vm_are
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 	set_pmd_at(vma->vm_mm, address, pmdp, pmd);
 	/* tlb flush only to serialize against gup-fast */
-	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
+	flush_tlb_range(vma->vm_mm, address, address + HPAGE_PMD_SIZE);
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
