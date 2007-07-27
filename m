Subject: [PATCH/RFC] split sparc64 tlb batch from mmu_gather
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Type: text/plain
Date: Fri, 27 Jul 2007 18:43:37 +1000
Message-Id: <1185525818.5495.205.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

This patch is another pre-requisite to the mmu_gather changes. sparc64
does it's own implementation which also tracks vaddrs. This splits it to
a separate structure that is kept per-cpu and make it use the generic
mmu_gather.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

Index: linux-work/arch/sparc64/mm/tlb.c
===================================================================
--- linux-work.orig/arch/sparc64/mm/tlb.c	2007-07-27 18:06:08.000000000 +1000
+++ linux-work/arch/sparc64/mm/tlb.c	2007-07-27 18:06:44.000000000 +1000
@@ -19,35 +19,38 @@
 
 /* Heavily inspired by the ppc64 code.  */
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers) = { 0, };
+DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
+DEFINE_PER_CPU(struct tlb_batch, tlb_batch);
 
-void flush_tlb_pending(void)
+void __flush_tlb_pending(struct tlb_batch *mp)
 {
-	struct mmu_gather *mp = &__get_cpu_var(mmu_gathers);
-
-	preempt_disable();
-
-	if (mp->tlb_nr) {
+	if (mp->nr) {
 		flush_tsb_user(mp);
 
 		if (CTX_VALID(mp->mm->context)) {
 #ifdef CONFIG_SMP
-			smp_flush_tlb_pending(mp->mm, mp->tlb_nr,
+			smp_flush_tlb_pending(mp->mm, mp->nr,
 					      &mp->vaddrs[0]);
 #else
-			__flush_tlb_pending(CTX_HWBITS(mp->mm->context),
-					    mp->tlb_nr, &mp->vaddrs[0]);
+			local_flush_tlb_pending(CTX_HWBITS(mp->mm->context),
+						mp->nr, &mp->vaddrs[0]);
 #endif
 		}
-		mp->tlb_nr = 0;
+		mp->nr = 0;
 	}
+}
+
+void flush_tlb_pending(void)
+{
+	struct tlb_batch *mp = &get_cpu_var(tlb_batch);
 
-	preempt_enable();
+	__flush_tlb_pending(mp);
+	put_cpu_var(tlb_batch);
 }
 
 void tlb_batch_add(struct mm_struct *mm, unsigned long vaddr, pte_t *ptep, pte_t orig)
 {
-	struct mmu_gather *mp = &__get_cpu_var(mmu_gathers);
+	struct tlb_batch *mp;
 	unsigned long nr;
 
 	vaddr &= PAGE_MASK;
@@ -79,13 +82,17 @@ void tlb_batch_add(struct mm_struct *mm,
 
 no_cache_flush:
 
-	if (mp->fullmm)
+	if (test_bit(MMF_DEAD, &mm->flags))
 		return;
 
-	nr = mp->tlb_nr;
+	/* we are called with enough spinlocks held to make
+	 * preempt disable useless here
+	 */
+	mp = &__get_cpu_var(tlb_batch);
+	nr = mp->nr;
 
 	if (unlikely(nr != 0 && mm != mp->mm)) {
-		flush_tlb_pending();
+		__flush_tlb_pending(mp);
 		nr = 0;
 	}
 
@@ -93,7 +100,7 @@ no_cache_flush:
 		mp->mm = mm;
 
 	mp->vaddrs[nr] = vaddr;
-	mp->tlb_nr = ++nr;
+	mp->nr = ++nr;
 	if (nr >= TLB_BATCH_NR)
-		flush_tlb_pending();
+		__flush_tlb_pending(mp);
 }
Index: linux-work/arch/sparc64/mm/tsb.c
===================================================================
--- linux-work.orig/arch/sparc64/mm/tsb.c	2007-07-27 18:06:08.000000000 +1000
+++ linux-work/arch/sparc64/mm/tsb.c	2007-07-27 18:06:44.000000000 +1000
@@ -47,11 +47,11 @@ void flush_tsb_kernel_range(unsigned lon
 	}
 }
 
-static void __flush_tsb_one(struct mmu_gather *mp, unsigned long hash_shift, unsigned long tsb, unsigned long nentries)
+static void __flush_tsb_one(struct tlb_batch *mp, unsigned long hash_shift, unsigned long tsb, unsigned long nentries)
 {
 	unsigned long i;
 
-	for (i = 0; i < mp->tlb_nr; i++) {
+	for (i = 0; i < mp->nr; i++) {
 		unsigned long v = mp->vaddrs[i];
 		unsigned long tag, ent, hash;
 
@@ -65,7 +65,7 @@ static void __flush_tsb_one(struct mmu_g
 	}
 }
 
-void flush_tsb_user(struct mmu_gather *mp)
+void flush_tsb_user(struct tlb_batch *mp)
 {
 	struct mm_struct *mm = mp->mm;
 	unsigned long nentries, base, flags;
Index: linux-work/arch/sparc64/mm/ultra.S
===================================================================
--- linux-work.orig/arch/sparc64/mm/ultra.S	2007-07-27 18:06:08.000000000 +1000
+++ linux-work/arch/sparc64/mm/ultra.S	2007-07-27 18:06:44.000000000 +1000
@@ -52,8 +52,8 @@ __flush_tlb_mm:		/* 18 insns */
 	nop
 
 	.align		32
-	.globl		__flush_tlb_pending
-__flush_tlb_pending:	/* 26 insns */
+	.globl		local_flush_tlb_pending
+local_flush_tlb_pending:	/* 26 insns */
 	/* %o0 = context, %o1 = nr, %o2 = vaddrs[] */
 	rdpr		%pstate, %g7
 	sllx		%o1, 3, %o1
@@ -346,8 +346,8 @@ cheetah_patch_cachetlbops:
 	call		tlb_patch_one
 	 mov		19, %o2
 
-	sethi		%hi(__flush_tlb_pending), %o0
-	or		%o0, %lo(__flush_tlb_pending), %o0
+	sethi		%hi(local_flush_tlb_pending), %o0
+	or		%o0, %lo(local_flush_tlb_pending), %o0
 	sethi		%hi(__cheetah_flush_tlb_pending), %o1
 	or		%o1, %lo(__cheetah_flush_tlb_pending), %o1
 	call		tlb_patch_one
@@ -699,8 +699,8 @@ hypervisor_patch_cachetlbops:
 	call		tlb_patch_one
 	 mov		10, %o2
 
-	sethi		%hi(__flush_tlb_pending), %o0
-	or		%o0, %lo(__flush_tlb_pending), %o0
+	sethi		%hi(local_flush_tlb_pending), %o0
+	or		%o0, %lo(local_flush_tlb_pending), %o0
 	sethi		%hi(__hypervisor_flush_tlb_pending), %o1
 	or		%o1, %lo(__hypervisor_flush_tlb_pending), %o1
 	call		tlb_patch_one
Index: linux-work/include/asm-sparc64/tlb.h
===================================================================
--- linux-work.orig/include/asm-sparc64/tlb.h	2007-07-27 18:06:08.000000000 +1000
+++ linux-work/include/asm-sparc64/tlb.h	2007-07-27 18:06:44.000000000 +1000
@@ -7,62 +7,38 @@
 #include <asm/tlbflush.h>
 #include <asm/mmu_context.h>
 
-#define TLB_BATCH_NR	192
+#define tlb_flush(mp)					\
+do {							\
+	if (!test_bit(MMF_DEAD, &mp->mm->flags))	\
+		flush_tlb_pending();			\
+} while(0)
 
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
+#include <asm-generic/tlb.h>
+
+#define TLB_BATCH_NR	192
 
-struct mmu_gather {
+struct tlb_batch {
 	struct mm_struct *mm;
-	unsigned int pages_nr;
-	unsigned int need_flush;
-	unsigned int fullmm;
-	unsigned int tlb_nr;
 	unsigned long vaddrs[TLB_BATCH_NR];
-	struct page *pages[FREE_PTE_NR];
+	unsigned int nr;
 };
-
-DECLARE_PER_CPU(struct mmu_gather, mmu_gathers);
+DECLARE_PER_CPU(struct tlb_batch, tlb_batch);
 
 #ifdef CONFIG_SMP
 extern void smp_flush_tlb_pending(struct mm_struct *,
 				  unsigned long, unsigned long *);
 #endif
 
-extern void __flush_tlb_pending(unsigned long, unsigned long, unsigned long *);
+extern void local_flush_tlb_pending(unsigned long, unsigned long, unsigned long *);
+extern void __flush_tlb_pending(struct tlb_batch *mp);
 extern void flush_tlb_pending(void);
 
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
+/* for use by _switch() */
+static inline void check_flush_tlb_pending(void)
 {
-	if (mp->need_flush) {
-		free_pages_and_swap_cache(mp->pages, mp->pages_nr);
-		mp->pages_nr = 0;
-		mp->need_flush = 0;
-	}
-
+	struct tlb_batch *mp = &__get_cpu_var(tlb_batch);
+	if (mp->nr)
+		__flush_tlb_pending(mp);
 }
 
 #ifdef CONFIG_SMP
@@ -72,39 +48,10 @@ extern void smp_flush_tlb_mm(struct mm_s
 #define do_flush_tlb_mm(mm) __flush_tlb_mm(CTX_HWBITS(mm->context), SECONDARY_CONTEXT)
 #endif
 
-static inline void tlb_finish_mmu(struct mmu_gather *mp, unsigned long start, unsigned long end)
-{
-	tlb_flush_mmu(mp);
-
-	if (mp->fullmm)
-		mp->fullmm = 0;
-	else
-		flush_tlb_pending();
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
-#define pte_free_tlb(mp,ptepage) pte_free(ptepage)
-#define pmd_free_tlb(mp,pmdp) pmd_free(pmdp)
-#define pud_free_tlb(tlb,pudp) __pud_free_tlb(tlb,pudp)
+#define __tlb_remove_tlb_entry(mp,ptep,addr) do { } while (0)
+#define __pte_free_tlb(mp,ptepage) pte_free(ptepage)
+#define __pmd_free_tlb(mp,pmdp) pmd_free(pmdp)
 
-#define tlb_migrate_finish(mm)	do { } while (0)
 #define tlb_start_vma(tlb, vma) do { } while (0)
 #define tlb_end_vma(tlb, vma)	do { } while (0)
 
Index: linux-work/include/asm-sparc64/tlbflush.h
===================================================================
--- linux-work.orig/include/asm-sparc64/tlbflush.h	2007-07-27 18:06:08.000000000 +1000
+++ linux-work/include/asm-sparc64/tlbflush.h	2007-07-27 18:06:44.000000000 +1000
@@ -5,9 +5,9 @@
 #include <asm/mmu_context.h>
 
 /* TSB flush operations. */
-struct mmu_gather;
+struct tlb_batch;
 extern void flush_tsb_kernel_range(unsigned long start, unsigned long end);
-extern void flush_tsb_user(struct mmu_gather *mp);
+extern void flush_tsb_user(struct tlb_batch *mp);
 
 /* TLB flush operations. */
 
Index: linux-work/arch/sparc64/kernel/smp.c
===================================================================
--- linux-work.orig/arch/sparc64/kernel/smp.c	2007-07-27 18:06:08.000000000 +1000
+++ linux-work/arch/sparc64/kernel/smp.c	2007-07-27 18:06:44.000000000 +1000
@@ -1142,7 +1142,7 @@ void smp_flush_tlb_pending(struct mm_str
 				      ctx, nr, (unsigned long) vaddrs,
 				      mm->cpu_vm_mask);
 
-	__flush_tlb_pending(ctx, nr, vaddrs);
+	local_flush_tlb_pending(ctx, nr, vaddrs);
 
 	put_cpu();
 }
Index: linux-work/include/asm-sparc64/system.h
===================================================================
--- linux-work.orig/include/asm-sparc64/system.h	2007-07-27 18:06:08.000000000 +1000
+++ linux-work/include/asm-sparc64/system.h	2007-07-27 18:06:44.000000000 +1000
@@ -151,7 +151,7 @@ do {	if (test_thread_flag(TIF_PERFCTR)) 
 		current_thread_info()->kernel_cntd0 += (unsigned int)(__tmp);\
 		current_thread_info()->kernel_cntd1 += ((__tmp) >> 32);	\
 	}								\
-	flush_tlb_pending();						\
+	check_flush_tlb_pending();					\
 	save_and_clear_fpu();						\
 	/* If you are tempted to conditionalize the following */	\
 	/* so that ASI is only written if it changes, think again. */	\


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
