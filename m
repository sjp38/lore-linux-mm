Date: Tue, 8 May 2007 13:28:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Get FRV to be able to run SLUB 
In-Reply-To: <28059.1178653974@redhat.com>
Message-ID: <Pine.LNX.4.64.0705081320120.13626@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705081105570.9941@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0705080905020.8722@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0705072037030.4661@schroedinger.engr.sgi.com>
 <7950.1178620309@redhat.com> <11856.1178647354@redhat.com>
 <28059.1178653974@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

I fixed up the patch to work against 2.6.21-mm1. I added your signoff.

Ok to apply to Andrew's tree? Or will this patch go through the arch 
maintainer?


FRV: Replace pgd management via slabs through quicklists

This is done in order to be able to run SLUB which expects no
modifications to its page structs.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: David Howells <dhowells@redhat.com>

Index: linux-2.6.21-mm1/arch/frv/Kconfig
===================================================================
--- linux-2.6.21-mm1.orig/arch/frv/Kconfig	2007-05-08 13:14:44.000000000 -0700
+++ linux-2.6.21-mm1/arch/frv/Kconfig	2007-05-08 13:15:52.000000000 -0700
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
--- linux-2.6.21-mm1.orig/arch/frv/kernel/process.c	2007-05-08 13:14:44.000000000 -0700
+++ linux-2.6.21-mm1/arch/frv/kernel/process.c	2007-05-08 13:15:52.000000000 -0700
@@ -25,12 +25,14 @@
 #include <linux/elf.h>
 #include <linux/reboot.h>
 #include <linux/interrupt.h>
+#include <linux/pagemap.h>
 
 #include <asm/asm-offsets.h>
 #include <asm/uaccess.h>
 #include <asm/system.h>
 #include <asm/setup.h>
 #include <asm/pgtable.h>
+#include <asm/tlb.h>
 #include <asm/gdb-stub.h>
 #include <asm/mb-regs.h>
 
@@ -88,6 +90,8 @@ void cpu_idle(void)
 		while (!need_resched()) {
 			irq_stat[cpu].idle_timestamp = jiffies;
 
+			check_pgt_cache();
+
 			if (!frv_dma_inprogress && idle)
 				idle();
 		}
Index: linux-2.6.21-mm1/arch/frv/mm/pgalloc.c
===================================================================
--- linux-2.6.21-mm1.orig/arch/frv/mm/pgalloc.c	2007-05-08 13:14:44.000000000 -0700
+++ linux-2.6.21-mm1/arch/frv/mm/pgalloc.c	2007-05-08 13:17:42.000000000 -0700
@@ -13,12 +13,12 @@
 #include <linux/slab.h>
 #include <linux/mm.h>
 #include <linux/highmem.h>
+#include <linux/quicklist.h>
 #include <asm/pgalloc.h>
 #include <asm/page.h>
 #include <asm/cacheflush.h>
 
 pgd_t swapper_pg_dir[PTRS_PER_PGD] __attribute__((aligned(PAGE_SIZE)));
-struct kmem_cache *pgd_cache;
 
 pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
@@ -100,7 +100,7 @@ static inline void pgd_list_del(pgd_t *p
 		set_page_private(next, (unsigned long) pprev);
 }
 
-void pgd_ctor(void *pgd, struct kmem_cache *cache, unsigned long unused)
+void pgd_ctor(void *pgd)
 {
 	unsigned long flags;
 
@@ -120,7 +120,7 @@ void pgd_ctor(void *pgd, struct kmem_cac
 }
 
 /* never called when PTRS_PER_PMD > 1 */
-void pgd_dtor(void *pgd, struct kmem_cache *cache, unsigned long unused)
+void pgd_dtor(void *pgd)
 {
 	unsigned long flags; /* can be called from interrupt context */
 
@@ -133,7 +133,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 {
 	pgd_t *pgd;
 
-	pgd = kmem_cache_alloc(pgd_cache, GFP_KERNEL);
+	pgd = quicklist_alloc(0, GFP_KERNEL, pgd_ctor);
 	if (!pgd)
 		return pgd;
 
@@ -143,15 +143,15 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 void pgd_free(pgd_t *pgd)
 {
 	/* in the non-PAE case, clear_page_tables() clears user pgd entries */
-	kmem_cache_free(pgd_cache, pgd);
+ 	quicklist_free(0, pgd_dtor, pgd);
 }
 
 void __init pgtable_cache_init(void)
 {
-	pgd_cache = kmem_cache_create("pgd",
-				      PTRS_PER_PGD * sizeof(pgd_t),
-				      PTRS_PER_PGD * sizeof(pgd_t),
-				      SLAB_PANIC,
-				      pgd_ctor,
-				      pgd_dtor);
 }
+
+void check_pgt_cache(void)
+{
+	quicklist_trim(0, pgd_dtor, 25, 16);
+}
+
Index: linux-2.6.21-mm1/include/asm-frv/tlb.h
===================================================================
--- linux-2.6.21-mm1.orig/include/asm-frv/tlb.h	2007-05-08 13:14:44.000000000 -0700
+++ linux-2.6.21-mm1/include/asm-frv/tlb.h	2007-05-08 13:15:52.000000000 -0700
@@ -3,7 +3,11 @@
 
 #include <asm/tlbflush.h>
 
+#ifdef CONFIG_MMU
+extern void check_pgt_cache(void);
+#else
 #define check_pgt_cache() do {} while(0)
+#endif
 
 /*
  * we don't need any special per-pte or per-vma handling...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
