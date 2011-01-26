Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D134A6B0092
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 08:13:21 -0500 (EST)
Subject: [RFC][PATCH 26/25] mm, arch: Convert ia64, arm, sh to generic tlb
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110125173111.720927511@chello.nl>
References: <20110125173111.720927511@chello.nl>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 26 Jan 2011 14:13:21 +0100
Message-ID: <1296047601.28776.1162.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Russell King <rmk@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>
List-ID: <linux-mm.kvack.org>

I was looking at what makes the various arches use !generic tlb gather
bits and found that for most the reason is the same, so I looked at what
it would take to support those in the generic code as well.

The below is a quick unification, I still need to run through all the
details since they appear to all do the same thing but slightly
different ;-)

I've compile tested it on ia64 and arm (seem to have lost my SH compiler
again).

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/Kconfig                    |    3=20
 arch/arm/Kconfig                |    1=20
 arch/arm/include/asm/tlb.h      |   90 --------------------
 arch/arm/include/asm/tlbflush.h |    5 -
 arch/ia64/Kconfig               |    1=20
 arch/ia64/include/asm/tlb.h     |  178 +----------------------------------=
-----
 arch/sh/Kconfig                 |    1=20
 arch/sh/include/asm/tlb.h       |   99 +---------------------
 include/asm-generic/tlb.h       |   35 +++++++
 9 files changed, 59 insertions(+), 354 deletions(-)

Index: linux-2.6/arch/Kconfig
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/Kconfig
+++ linux-2.6/arch/Kconfig
@@ -181,4 +181,7 @@ config HAVE_ARCH_MUTEX_CPU_RELAX
 config HAVE_RCU_TABLE_FREE
 	bool
=20
+config HAVE_MMU_GATHER_RANGE
+	bool
+
 source "kernel/gcov/Kconfig"
Index: linux-2.6/arch/arm/Kconfig
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/arm/Kconfig
+++ linux-2.6/arch/arm/Kconfig
@@ -28,6 +28,7 @@ config ARM
 	select HAVE_C_RECORDMCOUNT
 	select HAVE_GENERIC_HARDIRQS
 	select HAVE_SPARSE_IRQ
+	select HAVE_MMU_GATHER_RANGE if MMU
 	help
 	  The ARM series is a line of low-power-consumption RISC chip designs
 	  licensed by ARM Ltd and targeted at embedded applications and
Index: linux-2.6/arch/arm/include/asm/tlb.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/arm/include/asm/tlb.h
+++ linux-2.6/arch/arm/include/asm/tlb.h
@@ -23,96 +23,14 @@
 #ifndef CONFIG_MMU
=20
 #include <linux/pagemap.h>
-#include <asm-generic/tlb.h>
=20
 #else /* !CONFIG_MMU */
=20
-#include <asm/pgalloc.h>
-
-/*
- * TLB handling.  This allows us to remove pages from the page
- * tables, and efficiently handle the TLB issues.
- */
-struct mmu_gather {
-	struct mm_struct	*mm;
-	unsigned int		fullmm;
-	unsigned long		range_start;
-	unsigned long		range_end;
-};
-
-static inline void
-tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned int =
full_mm_flush)
-{
-	tlb->mm =3D mm;
-	tlb->fullmm =3D full_mm_flush;
-}
-
-static inline void
-tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long =
end)
-{
-	if (tlb->fullmm)
-		flush_tlb_mm(tlb->mm);
-
-	/* keep the page table cache within bounds */
-	check_pgt_cache();
-}
-
-/*
- * Memorize the range for the TLB flush.
- */
-static inline void
-tlb_remove_tlb_entry(struct mmu_gather *tlb, pte_t *ptep, unsigned long ad=
dr)
-{
-	if (!tlb->fullmm) {
-		if (addr < tlb->range_start)
-			tlb->range_start =3D addr;
-		if (addr + PAGE_SIZE > tlb->range_end)
-			tlb->range_end =3D addr + PAGE_SIZE;
-	}
-}
-
-/*
- * In the case of tlb vma handling, we can optimise these away in the
- * case where we're doing a full MM flush.  When we're doing a munmap,
- * the vmas are adjusted to only cover the region to be torn down.
- */
-static inline void
-tlb_start_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
-{
-	if (!tlb->fullmm) {
-		flush_cache_range(vma, vma->vm_start, vma->vm_end);
-		tlb->range_start =3D TASK_SIZE;
-		tlb->range_end =3D 0;
-	}
-}
-
-static inline void
-tlb_end_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
-{
-	if (!tlb->fullmm && tlb->range_end > 0)
-		flush_tlb_range(vma, tlb->range_start, tlb->range_end);
-}
-
-static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *p=
age)
-{
-	free_page_and_swap_cache(page);
-	return 0;
-}
-
-static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *pa=
ge)
-{
-	might_sleep();
-	__tlb_remove_page(tlb, page);
-}
-
-static inline void tlb_flush_mmu(struct mmu_gather *tlb)
-{
-}
+#define __pte_free_tlb(tlb, ptep, addr)	pte_free((tlb)->mm, ptep)
+#define __pmd_free_tlb(tlb, pmdp, addr)	pmd_free((tlb)->mm, pmdp)
=20
-#define pte_free_tlb(tlb, ptep, addr)	pte_free((tlb)->mm, ptep)
-#define pmd_free_tlb(tlb, pmdp, addr)	pmd_free((tlb)->mm, pmdp)
+#endif /* CONFIG_MMU */
=20
-#define tlb_migrate_finish(mm)		do { } while (0)
+#include <asm-generic/tlb.h>
=20
-#endif /* CONFIG_MMU */
 #endif
Index: linux-2.6/arch/ia64/Kconfig
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/ia64/Kconfig
+++ linux-2.6/arch/ia64/Kconfig
@@ -25,6 +25,7 @@ config IA64
 	select HAVE_GENERIC_HARDIRQS
 	select GENERIC_IRQ_PROBE
 	select GENERIC_PENDING_IRQ if SMP
+	select HAVE_MMU_GATHER_RANGE
 	select IRQ_PER_CPU
 	default y
 	help
Index: linux-2.6/arch/ia64/include/asm/tlb.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/ia64/include/asm/tlb.h
+++ linux-2.6/arch/ia64/include/asm/tlb.h
@@ -46,30 +46,6 @@
 #include <asm/tlbflush.h>
 #include <asm/machvec.h>
=20
-#ifdef CONFIG_SMP
-# define tlb_fast_mode(tlb)	((tlb)->nr =3D=3D ~0U)
-#else
-# define tlb_fast_mode(tlb)	(1)
-#endif
-
-/*
- * If we can't allocate a page to make a big batch of page pointers
- * to work on, then just handle a few from the on-stack structure.
- */
-#define	IA64_GATHER_BUNDLE	8
-
-struct mmu_gather {
-	struct mm_struct	*mm;
-	unsigned int		nr;		/* =3D=3D ~0U =3D> fast mode */
-	unsigned int		max;
-	unsigned char		fullmm;		/* non-zero means full mm flush */
-	unsigned char		need_flush;	/* really unmapped some PTEs? */
-	unsigned long		start_addr;
-	unsigned long		end_addr;
-	struct page		**pages;
-	struct page		*local[IA64_GATHER_BUNDLE];
-};
-
 struct ia64_tr_entry {
 	u64 ifa;
 	u64 itir;
@@ -96,6 +72,12 @@ extern struct ia64_tr_entry *ia64_idtrs[
 #define RR_RID_MASK	0x00000000ffffff00L
 #define RR_TO_RID(val) 	((val >> 8) & 0xffffff)
=20
+static inline void tlb_flush(struct mmu_gather *tlb);
+
+#define tlb_migrate_finish(mm)	platform_tlb_migrate_finish(mm)
+
+#include <asm-generic/tlb.h>
+
 /*
  * Flush the TLB for address range START to END and, if not in fast mode, =
release the
  * freed pages that where gathered up to this point.
@@ -103,12 +85,6 @@ extern struct ia64_tr_entry *ia64_idtrs[
 static inline void
 ia64_tlb_flush_mmu (struct mmu_gather *tlb, unsigned long start, unsigned =
long end)
 {
-	unsigned int nr;
-
-	if (!tlb->need_flush)
-		return;
-	tlb->need_flush =3D 0;
-
 	if (tlb->fullmm) {
 		/*
 		 * Tearing down the entire address space.  This happens both as a result
@@ -138,149 +114,11 @@ ia64_tlb_flush_mmu (struct mmu_gather *t
 		/* now flush the virt. page-table area mapping the address range: */
 		flush_tlb_range(&vma, ia64_thash(start), ia64_thash(end));
 	}
-
-	/* lastly, release the freed pages */
-	nr =3D tlb->nr;
-	if (!tlb_fast_mode(tlb)) {
-		unsigned long i;
-		tlb->nr =3D 0;
-		tlb->start_addr =3D ~0UL;
-		for (i =3D 0; i < nr; ++i)
-			free_page_and_swap_cache(tlb->pages[i]);
-	}
-}
-
-static inline void __tlb_alloc_page(struct mmu_gather *tlb)
-{
-	unsigned long addr =3D __get_free_pages(GFP_NOWAIT | __GFP_NOWARN, 0);
-
-	if (addr) {
-		tlb->pages =3D (void *)addr;
-		tlb->max =3D PAGE_SIZE / sizeof(void *);
-	}
-}
-
-
-static inline void
-tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned int =
full_mm_flush)
-{
-	tlb->mm =3D mm;
-	tlb->max =3D ARRAY_SIZE(tlb->local);
-	tlb->pages =3D tlb->local;
-	/*
-	 * Use fast mode if only 1 CPU is online.
-	 *
-	 * It would be tempting to turn on fast-mode for full_mm_flush as well.  =
But this
-	 * doesn't work because of speculative accesses and software prefetching:=
 the page
-	 * table of "mm" may (and usually is) the currently active page table and=
 even
-	 * though the kernel won't do any user-space accesses during the TLB shoo=
t down, a
-	 * compiler might use speculation or lfetch.fault on what happens to be a=
 valid
-	 * user-space address.  This in turn could trigger a TLB miss fault (or a=
 VHPT
-	 * walk) and re-insert a TLB entry we just removed.  Slow mode avoids suc=
h
-	 * problems.  (We could make fast-mode work by switching the current task=
 to a
-	 * different "mm" during the shootdown.) --davidm 08/02/2002
-	 */
-	tlb->nr =3D (num_online_cpus() =3D=3D 1) ? ~0U : 0;
-	tlb->fullmm =3D full_mm_flush;
-	tlb->start_addr =3D ~0UL;
 }
=20
-/*
- * Called at the end of the shootdown operation to free up any resources t=
hat were
- * collected.
- */
-static inline void
-tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long =
end)
+static inline void tlb_flush(struct mmu_gather *tlb)
 {
-	/*
-	 * Note: tlb->nr may be 0 at this point, so we can't rely on tlb->start_a=
ddr and
-	 * tlb->end_addr.
-	 */
-	ia64_tlb_flush_mmu(tlb, start, end);
-
-	/* keep the page table cache within bounds */
-	check_pgt_cache();
-
-	if (tlb->pages !=3D tlb->local)
-		free_pages((unsigned long)tlb->pages, 0);
+	ia64_tlb_flush_mmu(tlb, tlb->start, tlb->end);
 }
=20
-/*
- * Logically, this routine frees PAGE.  On MP machines, the actual freeing=
 of the page
- * must be delayed until after the TLB has been flushed (see comments at t=
he beginning of
- * this file).
- */
-static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *p=
age)
-{
-	tlb->need_flush =3D 1;
-
-	if (tlb_fast_mode(tlb)) {
-		free_page_and_swap_cache(page);
-		return 0;
-	}
-
-	if (!tlb->nr && tlb->pages =3D=3D tlb->local)
-		__tlb_alloc_page(tlb);
-
-	tlb->pages[tlb->nr++] =3D page;
-	if (tlb->nr >=3D tlb->max)
-		return 1;
-
-	return 0;
-}
-
-static inline void tlb_flush_mmu(struct mmu_gather *tlb)
-{
-	ia64_tlb_flush_mmu(tlb, tlb->start_addr, tlb->end_addr);
-}
-
-static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *pa=
ge)
-{
-	might_sleep();
-
-	if (__tlb_remove_page(tlb, page))
-		tlb_flush_mmu(tlb);
-}
-
-/*
- * Remove TLB entry for PTE mapped at virtual address ADDRESS.  This is ca=
lled for any
- * PTE, not just those pointing to (normal) physical memory.
- */
-static inline void
-__tlb_remove_tlb_entry (struct mmu_gather *tlb, pte_t *ptep, unsigned long=
 address)
-{
-	if (tlb->start_addr =3D=3D ~0UL)
-		tlb->start_addr =3D address;
-	tlb->end_addr =3D address + PAGE_SIZE;
-}
-
-#define tlb_migrate_finish(mm)	platform_tlb_migrate_finish(mm)
-
-#define tlb_start_vma(tlb, vma)			do { } while (0)
-#define tlb_end_vma(tlb, vma)			do { } while (0)
-
-#define tlb_remove_tlb_entry(tlb, ptep, addr)		\
-do {							\
-	tlb->need_flush =3D 1;				\
-	__tlb_remove_tlb_entry(tlb, ptep, addr);	\
-} while (0)
-
-#define pte_free_tlb(tlb, ptep, address)		\
-do {							\
-	tlb->need_flush =3D 1;				\
-	__pte_free_tlb(tlb, ptep, address);		\
-} while (0)
-
-#define pmd_free_tlb(tlb, ptep, address)		\
-do {							\
-	tlb->need_flush =3D 1;				\
-	__pmd_free_tlb(tlb, ptep, address);		\
-} while (0)
-
-#define pud_free_tlb(tlb, pudp, address)		\
-do {							\
-	tlb->need_flush =3D 1;				\
-	__pud_free_tlb(tlb, pudp, address);		\
-} while (0)
-
 #endif /* _ASM_IA64_TLB_H */
Index: linux-2.6/arch/sh/Kconfig
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/sh/Kconfig
+++ linux-2.6/arch/sh/Kconfig
@@ -22,6 +22,7 @@ config SUPERH
 	select HAVE_SPARSE_IRQ
 	select RTC_LIB
 	select GENERIC_ATOMIC64
+	select HAVE_MMU_GATHER_RANGE if MMU
 	# Support the deprecated APIs until MFD and GPIOLIB catch up.
 	select GENERIC_HARDIRQS_NO_DEPRECATED if !MFD_SUPPORT && !GPIOLIB
 	help
Index: linux-2.6/arch/sh/include/asm/tlb.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/sh/include/asm/tlb.h
+++ linux-2.6/arch/sh/include/asm/tlb.h
@@ -9,101 +9,11 @@
 #include <linux/pagemap.h>
=20
 #ifdef CONFIG_MMU
-#include <asm/pgalloc.h>
-#include <asm/tlbflush.h>
 #include <asm/mmu_context.h>
=20
-/*
- * TLB handling.  This allows us to remove pages from the page
- * tables, and efficiently handle the TLB issues.
- */
-struct mmu_gather {
-	struct mm_struct	*mm;
-	unsigned int		fullmm;
-	unsigned long		start, end;
-};
-
-static inline void init_tlb_gather(struct mmu_gather *tlb)
-{
-	tlb->start =3D TASK_SIZE;
-	tlb->end =3D 0;
-
-	if (tlb->fullmm) {
-		tlb->start =3D 0;
-		tlb->end =3D TASK_SIZE;
-	}
-}
-
-static inline void
-tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned int =
full_mm_flush)
-{
-	tlb->mm =3D mm;
-	tlb->fullmm =3D full_mm_flush;
-
-	init_tlb_gather(tlb);
-}
-
-static inline void
-tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long =
end)
-{
-	if (tlb->fullmm)
-		flush_tlb_mm(tlb->mm);
-
-	/* keep the page table cache within bounds */
-	check_pgt_cache();
-}
-
-static inline void
-tlb_remove_tlb_entry(struct mmu_gather *tlb, pte_t *ptep, unsigned long ad=
dress)
-{
-	if (tlb->start > address)
-		tlb->start =3D address;
-	if (tlb->end < address + PAGE_SIZE)
-		tlb->end =3D address + PAGE_SIZE;
-}
-
-/*
- * In the case of tlb vma handling, we can optimise these away in the
- * case where we're doing a full MM flush.  When we're doing a munmap,
- * the vmas are adjusted to only cover the region to be torn down.
- */
-static inline void
-tlb_start_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
-{
-	if (!tlb->fullmm)
-		flush_cache_range(vma, vma->vm_start, vma->vm_end);
-}
-
-static inline void
-tlb_end_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
-{
-	if (!tlb->fullmm && tlb->end) {
-		flush_tlb_range(vma, tlb->start, tlb->end);
-		init_tlb_gather(tlb);
-	}
-}
-
-static inline void tlb_flush_mmu(struct mmu_gather *tlb)
-{
-}
-
-static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *p=
age)
-{
-	free_page_and_swap_cache(page);
-	return 0;
-}
-
-static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *pa=
ge)
-{
-	might_sleep();
-	__tlb_remove_page(tlb, page);
-}
-
-#define pte_free_tlb(tlb, ptep, addr)	pte_free((tlb)->mm, ptep)
-#define pmd_free_tlb(tlb, pmdp, addr)	pmd_free((tlb)->mm, pmdp)
-#define pud_free_tlb(tlb, pudp, addr)	pud_free((tlb)->mm, pudp)
-
-#define tlb_migrate_finish(mm)		do { } while (0)
+#define __pte_free_tlb(tlb, ptep, addr)	pte_free((tlb)->mm, ptep)
+#define __pmd_free_tlb(tlb, pmdp, addr)	pmd_free((tlb)->mm, pmdp)
+#define __pud_free_tlb(tlb, pudp, addr)	pud_free((tlb)->mm, pudp)
=20
 #if defined(CONFIG_CPU_SH4) || defined(CONFIG_SUPERH64)
 extern void tlb_wire_entry(struct vm_area_struct *, unsigned long, pte_t);
@@ -128,8 +38,9 @@ static inline void tlb_unwire_entry(void
 #define __tlb_remove_tlb_entry(tlb, pte, address)	do { } while (0)
 #define tlb_flush(tlb)					do { } while (0)
=20
+#endif /* CONFIG_MMU */
+
 #include <asm-generic/tlb.h>
=20
-#endif /* CONFIG_MMU */
 #endif /* __ASSEMBLY__ */
 #endif /* __ASM_SH_TLB_H */
Index: linux-2.6/include/asm-generic/tlb.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/include/asm-generic/tlb.h
+++ linux-2.6/include/asm-generic/tlb.h
@@ -79,6 +79,10 @@ struct mmu_gather {
 				fast_mode  : 1; /* No batching   */
 	unsigned int		fullmm;		/* Flush full mm */
=20
+#ifdef CONFIG_HAVE_MMU_GATHER_RANGE
+	unsigned long		start, end;
+#endif
+
 	struct mmu_gather_batch *active;
 	struct mmu_gather_batch	local;
 	struct page		*__pages[8];
@@ -222,6 +226,35 @@ static inline void tlb_remove_page(struc
 		tlb_flush_mmu(tlb);
 }
=20
+#ifdef CONFIG_HAVE_MMU_GATHER_RANGE
+static inline void
+__tlb_remove_tlb_entry(struct mmu_gather *tlb, pte_t *ptep, unsigned long =
address)
+{
+	if (!tlb->fullmm) {
+		tlb->start =3D min(tlb->start, address);
+		address +=3D PAGE_SIZE;
+		tlb->end =3D max(tlb->end, address);
+	}
+}
+
+static inline void
+tlb_start_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
+{
+	if (!tlb->fullmm) {
+		flush_cache_range(vma, vma->vm_start, vma->vm_end);
+		tlb->start =3D TASK_SIZE;
+		tlb->end =3D 0;
+	}
+}
+
+static inline void
+tlb_end_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
+{
+	if (!tlb->fullmm && tlb->end)
+		flush_tlb_range(vma, tlb->start, tlb->end);
+}
+#endif
+
 /**
  * tlb_remove_tlb_entry - remember a pte unmapping for later tlb invalidat=
ion.
  *
@@ -255,6 +288,8 @@ static inline void tlb_remove_page(struc
 		__pmd_free_tlb(tlb, pmdp, address);		\
 	} while (0)
=20
+#ifndef tlb_migrate_finish
 #define tlb_migrate_finish(mm) do {} while (0)
+#endif
=20
 #endif /* _ASM_GENERIC__TLB_H */
Index: linux-2.6/arch/arm/include/asm/tlbflush.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/arm/include/asm/tlbflush.h
+++ linux-2.6/arch/arm/include/asm/tlbflush.h
@@ -10,12 +10,9 @@
 #ifndef _ASMARM_TLBFLUSH_H
 #define _ASMARM_TLBFLUSH_H
=20
-
-#ifndef CONFIG_MMU
-
 #define tlb_flush(tlb)	((void) tlb)
=20
-#else /* CONFIG_MMU */
+#ifdef CONFIG_MMU
=20
 #include <asm/glue.h>
=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
