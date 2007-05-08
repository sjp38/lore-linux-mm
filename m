Date: Mon, 7 May 2007 20:41:05 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Get FRV to be able to run SLUB
Message-ID: <Pine.LNX.4.64.0705072037030.4661@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Is FRV still alive? I see myself there as one of the last people who 
changes something. FRV seems to be not able to run SLUB because it 
modifies the page struct of page sized SLABS that it allocates. Its the 
last architecture that has trouble with SLUB I guess.

I fixed up the i386 patch for FRV. Could you or someone familiar with FRV 
give this a spin?


Subject: [FRV] Band-Aid: Minimal patch to enable SLUB

This patch switches the pgd handling to use a quicklist. That way
both are disentangled and SLUB works.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-mm1/arch/frv/Kconfig
===================================================================
--- linux-2.6.21-mm1.orig/arch/frv/Kconfig	2007-05-07 20:22:50.000000000 -0700
+++ linux-2.6.21-mm1/arch/frv/Kconfig	2007-05-07 20:29:02.000000000 -0700
@@ -45,15 +45,15 @@ config TIME_LOW_RES
 	bool
 	default y
 
-config ARCH_HAS_ILOG2_U32
+config QUICKLIST
 	bool
 	default y
 
-config ARCH_HAS_ILOG2_U64
+config ARCH_HAS_ILOG2_U32
 	bool
 	default y
 
-config ARCH_USES_SLAB_PAGE_STRUCT
+config ARCH_HAS_ILOG2_U64
 	bool
 	default y
 
Index: linux-2.6.21-mm1/arch/frv/kernel/process.c
===================================================================
--- linux-2.6.21-mm1.orig/arch/frv/kernel/process.c	2007-05-07 20:22:50.000000000 -0700
+++ linux-2.6.21-mm1/arch/frv/kernel/process.c	2007-05-07 20:29:34.000000000 -0700
@@ -88,6 +88,8 @@ void cpu_idle(void)
 		while (!need_resched()) {
 			irq_stat[cpu].idle_timestamp = jiffies;
 
+			check_pgt_cache();
+
 			if (!frv_dma_inprogress && idle)
 				idle();
 		}
Index: linux-2.6.21-mm1/arch/frv/mm/pgalloc.c
===================================================================
--- linux-2.6.21-mm1.orig/arch/frv/mm/pgalloc.c	2007-05-07 20:24:47.000000000 -0700
+++ linux-2.6.21-mm1/arch/frv/mm/pgalloc.c	2007-05-07 20:34:58.000000000 -0700
@@ -18,7 +18,6 @@
 #include <asm/cacheflush.h>
 
 pgd_t swapper_pg_dir[PTRS_PER_PGD] __attribute__((aligned(PAGE_SIZE)));
-struct kmem_cache *pgd_cache;
 
 pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
@@ -100,7 +99,7 @@ static inline void pgd_list_del(pgd_t *p
 		set_page_private(next, (unsigned long) pprev);
 }
 
-void pgd_ctor(void *pgd, struct kmem_cache *cache, unsigned long unused)
+void pgd_ctor(void *pgd)
 {
 	unsigned long flags;
 
@@ -120,7 +119,7 @@ void pgd_ctor(void *pgd, struct kmem_cac
 }
 
 /* never called when PTRS_PER_PMD > 1 */
-void pgd_dtor(void *pgd, struct kmem_cache *cache, unsigned long unused)
+void pgd_dtor(void *pgd)
 {
 	unsigned long flags; /* can be called from interrupt context */
 
@@ -133,7 +132,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 {
 	pgd_t *pgd;
 
-	pgd = kmem_cache_alloc(pgd_cache, GFP_KERNEL);
+	pgd = quicklist_alloc(0, GFP_KERNEL, pgd_ctor);
 	if (!pgd)
 		return pgd;
 
@@ -143,15 +142,14 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 void pgd_free(pgd_t *pgd)
 {
 	/* in the non-PAE case, clear_page_tables() clears user pgd entries */
-	kmem_cache_free(pgd_cache, pgd);
+	pgd = quicklist_free(0, NULL, pgd_dtor);
 }
 
 void __init pgtable_cache_init(void)
 {
-	pgd_cache = kmem_cache_create("pgd",
-				      PTRS_PER_PGD * sizeof(pgd_t),
-				      PTRS_PER_PGD * sizeof(pgd_t),
-				      SLAB_PANIC,
-				      pgd_ctor,
-				      pgd_dtor);
+}
+
+void check_pgt_cache(void)
+{
+	quicklist_trim(0, pgd_dtor, 25, 16);
 }
Index: linux-2.6.21-mm1/include/asm-frv/tlb.h
===================================================================
--- linux-2.6.21-mm1.orig/include/asm-frv/tlb.h	2007-05-07 20:30:26.000000000 -0700
+++ linux-2.6.21-mm1/include/asm-frv/tlb.h	2007-05-07 20:30:48.000000000 -0700
@@ -3,7 +3,7 @@
 
 #include <asm/tlbflush.h>
 
-#define check_pgt_cache() do {} while(0)
+extern void check_pgt_cache();
 
 /*
  * we don't need any special per-pte or per-vma handling...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
