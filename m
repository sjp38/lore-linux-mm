Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id ADEDD8D004B
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 12:10:55 -0500 (EST)
Message-Id: <20110217163234.965977975@chello.nl>
Date: Thu, 17 Feb 2011 17:23:31 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 04/17] sparc: mmu_gather rework
References: <20110217162327.434629380@chello.nl>
Content-Disposition: inline; filename=peter_zijlstra-sparc-preemptible_mmu_gather.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>

Rework the sparc mmu_gather usage to conform to the new world order :-)

Sparc mmu_gather does two things:
 - tracks vaddrs to unhash
 - tracks pages to free

Split these two things like powerpc has done and keep the vaddrs
in per-cpu data structures and flush them on context switch.

The remaining bits can then use the generic mmu_gather.

Acked-by: David Miller <davem@davemloft.net>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/sparc/include/asm/pgalloc_64.h  |    3 +
 arch/sparc/include/asm/pgtable_64.h  |   15 ++++-
 arch/sparc/include/asm/tlb_64.h      |   91 ++---------------------------------
 arch/sparc/include/asm/tlbflush_64.h |   12 +++-
 arch/sparc/mm/tlb.c                  |   43 +++++++++-------
 arch/sparc/mm/tsb.c                  |   15 +++--
 6 files changed, 63 insertions(+), 116 deletions(-)

Index: linux-2.6/arch/sparc/include/asm/pgalloc_64.h
===================================================================
--- linux-2.6.orig/arch/sparc/include/asm/pgalloc_64.h
+++ linux-2.6/arch/sparc/include/asm/pgalloc_64.h
@@ -78,4 +78,7 @@ static inline void check_pgt_cache(void)
 	quicklist_trim(0, NULL, 25, 16);
 }
 
+#define __pte_free_tlb(tlb, pte, addr)	pte_free((tlb)->mm, pte)
+#define __pmd_free_tlb(tlb, pmd, addr)	pmd_free((tlb)->mm, pmd)
+
 #endif /* _SPARC64_PGALLOC_H */
Index: linux-2.6/arch/sparc/include/asm/tlb_64.h
===================================================================
--- linux-2.6.orig/arch/sparc/include/asm/tlb_64.h
+++ linux-2.6/arch/sparc/include/asm/tlb_64.h
@@ -7,66 +7,11 @@
 #include <asm/tlbflush.h>
 #include <asm/mmu_context.h>
 
-#define TLB_BATCH_NR	192
-
-/*
- * For UP we don't need to worry about TLB flush
- * and page free order so much..
- */
-#ifdef CONFIG_SMP
-  #define FREE_PTE_NR	506
-  #define tlb_fast_mode(bp) ((bp)->pages_nr == ~0U)
-#else
-  #define FREE_PTE_NR	1
-  #define tlb_fast_mode(bp) 1
-#endif
-
-struct mmu_gather {
-	struct mm_struct *mm;
-	unsigned int pages_nr;
-	unsigned int need_flush;
-	unsigned int fullmm;
-	unsigned int tlb_nr;
-	unsigned long vaddrs[TLB_BATCH_NR];
-	struct page *pages[FREE_PTE_NR];
-};
-
-DECLARE_PER_CPU(struct mmu_gather, mmu_gathers);
-
 #ifdef CONFIG_SMP
 extern void smp_flush_tlb_pending(struct mm_struct *,
 				  unsigned long, unsigned long *);
 #endif
 
-extern void __flush_tlb_pending(unsigned long, unsigned long, unsigned long *);
-extern void flush_tlb_pending(void);
-
-static inline struct mmu_gather *tlb_gather_mmu(struct mm_struct *mm, unsigned int full_mm_flush)
-{
-	struct mmu_gather *mp = &get_cpu_var(mmu_gathers);
-
-	BUG_ON(mp->tlb_nr);
-
-	mp->mm = mm;
-	mp->pages_nr = num_online_cpus() > 1 ? 0U : ~0U;
-	mp->fullmm = full_mm_flush;
-
-	return mp;
-}
-
-
-static inline void tlb_flush_mmu(struct mmu_gather *mp)
-{
-	if (!mp->fullmm)
-		flush_tlb_pending();
-	if (mp->need_flush) {
-		free_pages_and_swap_cache(mp->pages, mp->pages_nr);
-		mp->pages_nr = 0;
-		mp->need_flush = 0;
-	}
-
-}
-
 #ifdef CONFIG_SMP
 extern void smp_flush_tlb_mm(struct mm_struct *mm);
 #define do_flush_tlb_mm(mm) smp_flush_tlb_mm(mm)
@@ -74,38 +19,14 @@ extern void smp_flush_tlb_mm(struct mm_s
 #define do_flush_tlb_mm(mm) __flush_tlb_mm(CTX_HWBITS(mm->context), SECONDARY_CONTEXT)
 #endif
 
-static inline void tlb_finish_mmu(struct mmu_gather *mp, unsigned long start, unsigned long end)
-{
-	tlb_flush_mmu(mp);
-
-	if (mp->fullmm)
-		mp->fullmm = 0;
-
-	/* keep the page table cache within bounds */
-	check_pgt_cache();
-
-	put_cpu_var(mmu_gathers);
-}
-
-static inline void tlb_remove_page(struct mmu_gather *mp, struct page *page)
-{
-	if (tlb_fast_mode(mp)) {
-		free_page_and_swap_cache(page);
-		return;
-	}
-	mp->need_flush = 1;
-	mp->pages[mp->pages_nr++] = page;
-	if (mp->pages_nr >= FREE_PTE_NR)
-		tlb_flush_mmu(mp);
-}
-
-#define tlb_remove_tlb_entry(mp,ptep,addr) do { } while (0)
-#define pte_free_tlb(mp, ptepage, addr) pte_free((mp)->mm, ptepage)
-#define pmd_free_tlb(mp, pmdp, addr) pmd_free((mp)->mm, pmdp)
-#define pud_free_tlb(tlb,pudp, addr) __pud_free_tlb(tlb,pudp,addr)
+extern void __flush_tlb_pending(unsigned long, unsigned long, unsigned long *);
+extern void flush_tlb_pending(void);
 
-#define tlb_migrate_finish(mm)	do { } while (0)
 #define tlb_start_vma(tlb, vma) do { } while (0)
 #define tlb_end_vma(tlb, vma)	do { } while (0)
+#define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
+#define tlb_flush(tlb)	flush_tlb_pending()
+
+#include <asm-generic/tlb.h>
 
 #endif /* _SPARC64_TLB_H */
Index: linux-2.6/arch/sparc/include/asm/tlbflush_64.h
===================================================================
--- linux-2.6.orig/arch/sparc/include/asm/tlbflush_64.h
+++ linux-2.6/arch/sparc/include/asm/tlbflush_64.h
@@ -5,9 +5,17 @@
 #include <asm/mmu_context.h>
 
 /* TSB flush operations. */
-struct mmu_gather;
+
+#define TLB_BATCH_NR	192
+
+struct tlb_batch {
+	struct mm_struct *mm;
+	unsigned long tlb_nr;
+	unsigned long vaddrs[TLB_BATCH_NR];
+};
+
 extern void flush_tsb_kernel_range(unsigned long start, unsigned long end);
-extern void flush_tsb_user(struct mmu_gather *mp);
+extern void flush_tsb_user(struct tlb_batch *tb);
 
 /* TLB flush operations. */
 
Index: linux-2.6/arch/sparc/mm/tlb.c
===================================================================
--- linux-2.6.orig/arch/sparc/mm/tlb.c
+++ linux-2.6/arch/sparc/mm/tlb.c
@@ -19,33 +19,34 @@
 
 /* Heavily inspired by the ppc64 code.  */
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
+static DEFINE_PER_CPU(struct tlb_batch, tlb_batch);
 
 void flush_tlb_pending(void)
 {
-	struct mmu_gather *mp = &get_cpu_var(mmu_gathers);
+	struct tlb_batch *tb = &get_cpu_var(tlb_batch);
 
-	if (mp->tlb_nr) {
-		flush_tsb_user(mp);
+	if (tb->tlb_nr) {
+		flush_tsb_user(tb);
 
-		if (CTX_VALID(mp->mm->context)) {
+		if (CTX_VALID(tb->mm->context)) {
 #ifdef CONFIG_SMP
-			smp_flush_tlb_pending(mp->mm, mp->tlb_nr,
-					      &mp->vaddrs[0]);
+			smp_flush_tlb_pending(tb->mm, tb->tlb_nr,
+					      &tb->vaddrs[0]);
 #else
-			__flush_tlb_pending(CTX_HWBITS(mp->mm->context),
-					    mp->tlb_nr, &mp->vaddrs[0]);
+			__flush_tlb_pending(CTX_HWBITS(tb->mm->context),
+					    tb->tlb_nr, &tb->vaddrs[0]);
 #endif
 		}
-		mp->tlb_nr = 0;
+		tb->tlb_nr = 0;
 	}
 
-	put_cpu_var(mmu_gathers);
+	put_cpu_var(tlb_batch);
 }
 
-void tlb_batch_add(struct mm_struct *mm, unsigned long vaddr, pte_t *ptep, pte_t orig)
+void tlb_batch_add(struct mm_struct *mm, unsigned long vaddr,
+		   pte_t *ptep, pte_t orig, int fullmm)
 {
-	struct mmu_gather *mp = &__get_cpu_var(mmu_gathers);
+	struct tlb_batch *tb = &get_cpu_var(tlb_batch);
 	unsigned long nr;
 
 	vaddr &= PAGE_MASK;
@@ -77,21 +78,25 @@ void tlb_batch_add(struct mm_struct *mm,
 
 no_cache_flush:
 
-	if (mp->fullmm)
+	if (fullmm) {
+		put_cpu_var(tlb_batch);
 		return;
+	}
 
-	nr = mp->tlb_nr;
+	nr = tb->tlb_nr;
 
-	if (unlikely(nr != 0 && mm != mp->mm)) {
+	if (unlikely(nr != 0 && mm != tb->mm)) {
 		flush_tlb_pending();
 		nr = 0;
 	}
 
 	if (nr == 0)
-		mp->mm = mm;
+		tb->mm = mm;
 
-	mp->vaddrs[nr] = vaddr;
-	mp->tlb_nr = ++nr;
+	tb->vaddrs[nr] = vaddr;
+	tb->tlb_nr = ++nr;
 	if (nr >= TLB_BATCH_NR)
 		flush_tlb_pending();
+
+	put_cpu_var(tlb_batch);
 }
Index: linux-2.6/arch/sparc/mm/tsb.c
===================================================================
--- linux-2.6.orig/arch/sparc/mm/tsb.c
+++ linux-2.6/arch/sparc/mm/tsb.c
@@ -47,12 +47,13 @@ void flush_tsb_kernel_range(unsigned lon
 	}
 }
 
-static void __flush_tsb_one(struct mmu_gather *mp, unsigned long hash_shift, unsigned long tsb, unsigned long nentries)
+static void __flush_tsb_one(struct tlb_batch *tb, unsigned long hash_shift,
+			    unsigned long tsb, unsigned long nentries)
 {
 	unsigned long i;
 
-	for (i = 0; i < mp->tlb_nr; i++) {
-		unsigned long v = mp->vaddrs[i];
+	for (i = 0; i < tb->tlb_nr; i++) {
+		unsigned long v = tb->vaddrs[i];
 		unsigned long tag, ent, hash;
 
 		v &= ~0x1UL;
@@ -65,9 +66,9 @@ static void __flush_tsb_one(struct mmu_g
 	}
 }
 
-void flush_tsb_user(struct mmu_gather *mp)
+void flush_tsb_user(struct tlb_batch *tb)
 {
-	struct mm_struct *mm = mp->mm;
+	struct mm_struct *mm = tb->mm;
 	unsigned long nentries, base, flags;
 
 	spin_lock_irqsave(&mm->context.lock, flags);
@@ -76,7 +77,7 @@ void flush_tsb_user(struct mmu_gather *m
 	nentries = mm->context.tsb_block[MM_TSB_BASE].tsb_nentries;
 	if (tlb_type == cheetah_plus || tlb_type == hypervisor)
 		base = __pa(base);
-	__flush_tsb_one(mp, PAGE_SHIFT, base, nentries);
+	__flush_tsb_one(tb, PAGE_SHIFT, base, nentries);
 
 #ifdef CONFIG_HUGETLB_PAGE
 	if (mm->context.tsb_block[MM_TSB_HUGE].tsb) {
@@ -84,7 +85,7 @@ void flush_tsb_user(struct mmu_gather *m
 		nentries = mm->context.tsb_block[MM_TSB_HUGE].tsb_nentries;
 		if (tlb_type == cheetah_plus || tlb_type == hypervisor)
 			base = __pa(base);
-		__flush_tsb_one(mp, HPAGE_SHIFT, base, nentries);
+		__flush_tsb_one(tb, HPAGE_SHIFT, base, nentries);
 	}
 #endif
 	spin_unlock_irqrestore(&mm->context.lock, flags);
Index: linux-2.6/arch/sparc/include/asm/pgtable_64.h
===================================================================
--- linux-2.6.orig/arch/sparc/include/asm/pgtable_64.h
+++ linux-2.6/arch/sparc/include/asm/pgtable_64.h
@@ -655,9 +655,11 @@ static inline int pte_special(pte_t pte)
 #define pte_unmap(pte)			do { } while (0)
 
 /* Actual page table PTE updates.  */
-extern void tlb_batch_add(struct mm_struct *mm, unsigned long vaddr, pte_t *ptep, pte_t orig);
+extern void tlb_batch_add(struct mm_struct *mm, unsigned long vaddr,
+			  pte_t *ptep, pte_t orig, int fullmm);
 
-static inline void set_pte_at(struct mm_struct *mm, unsigned long addr, pte_t *ptep, pte_t pte)
+static inline void __set_pte_at(struct mm_struct *mm, unsigned long addr,
+			     pte_t *ptep, pte_t pte, int fullmm)
 {
 	pte_t orig = *ptep;
 
@@ -670,12 +672,19 @@ static inline void set_pte_at(struct mm_
 	 *             and SUN4V pte layout, so this inline test is fine.
 	 */
 	if (likely(mm != &init_mm) && (pte_val(orig) & _PAGE_VALID))
-		tlb_batch_add(mm, addr, ptep, orig);
+		tlb_batch_add(mm, addr, ptep, orig, fullmm);
 }
 
+#define set_pte_at(mm,addr,ptep,pte)	\
+	__set_pte_at((mm), (addr), (ptep), (pte), 0)
+
 #define pte_clear(mm,addr,ptep)		\
 	set_pte_at((mm), (addr), (ptep), __pte(0UL))
 
+#define __HAVE_ARCH_PTE_CLEAR_NOT_PRESENT_FULL
+#define pte_clear_not_present_full(mm,addr,ptep,fullmm)	\
+	__set_pte_at((mm), (addr), (ptep), __pte(0UL), (fullmm))
+
 #ifdef DCACHE_ALIASING_POSSIBLE
 #define __HAVE_ARCH_MOVE_PTE
 #define move_pte(pte, prot, old_addr, new_addr)				\


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
