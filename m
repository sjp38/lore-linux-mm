From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070409182525.8559.53694.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070409182509.8559.33823.sendpatchset@schroedinger.engr.sgi.com>
References: <20070409182509.8559.33823.sendpatchset@schroedinger.engr.sgi.com>
Subject: [QUICKLIST 4/4] Quicklist support for sparc64
Date: Mon,  9 Apr 2007 11:25:25 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
From: David Miller <davem@davemloft.net>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, ak@suse.de, linux-kernel@vger.kernel.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

[QUICKLIST]: Add sparc64 quicklist support.

I ported this to sparc64 as per the patch below, tested on
UP SunBlade1500 and 24 cpu Niagara T1000.

Signed-off-by: David S. Miller <davem@davemloft.net>

Index: linux-2.6.21-rc5-mm4/arch/sparc64/Kconfig
===================================================================
--- linux-2.6.21-rc5-mm4.orig/arch/sparc64/Kconfig	2007-04-07 16:20:07.000000000 -0700
+++ linux-2.6.21-rc5-mm4/arch/sparc64/Kconfig	2007-04-07 18:03:06.000000000 -0700
@@ -26,6 +26,10 @@
 	bool
 	default y
 
+config QUICKLIST
+	bool
+	default y
+
 config STACKTRACE_SUPPORT
 	bool
 	default y
Index: linux-2.6.21-rc5-mm4/arch/sparc64/mm/init.c
===================================================================
--- linux-2.6.21-rc5-mm4.orig/arch/sparc64/mm/init.c	2007-03-25 15:56:23.000000000 -0700
+++ linux-2.6.21-rc5-mm4/arch/sparc64/mm/init.c	2007-04-07 18:03:06.000000000 -0700
@@ -178,30 +178,6 @@
 
 int bigkernel = 0;
 
-struct kmem_cache *pgtable_cache __read_mostly;
-
-static void zero_ctor(void *addr, struct kmem_cache *cache, unsigned long flags)
-{
-	clear_page(addr);
-}
-
-extern void tsb_cache_init(void);
-
-void pgtable_cache_init(void)
-{
-	pgtable_cache = kmem_cache_create("pgtable_cache",
-					  PAGE_SIZE, PAGE_SIZE,
-					  SLAB_HWCACHE_ALIGN |
-					  SLAB_MUST_HWCACHE_ALIGN,
-					  zero_ctor,
-					  NULL);
-	if (!pgtable_cache) {
-		prom_printf("Could not create pgtable_cache\n");
-		prom_halt();
-	}
-	tsb_cache_init();
-}
-
 #ifdef CONFIG_DEBUG_DCFLUSH
 atomic_t dcpage_flushes = ATOMIC_INIT(0);
 #ifdef CONFIG_SMP
Index: linux-2.6.21-rc5-mm4/arch/sparc64/mm/tsb.c
===================================================================
--- linux-2.6.21-rc5-mm4.orig/arch/sparc64/mm/tsb.c	2007-03-25 15:56:23.000000000 -0700
+++ linux-2.6.21-rc5-mm4/arch/sparc64/mm/tsb.c	2007-04-07 18:03:06.000000000 -0700
@@ -252,7 +252,7 @@
 	"tsb_1MB",
 };
 
-void __init tsb_cache_init(void)
+void __init pgtable_cache_init(void)
 {
 	unsigned long i;
 
Index: linux-2.6.21-rc5-mm4/include/asm-sparc64/pgalloc.h
===================================================================
--- linux-2.6.21-rc5-mm4.orig/include/asm-sparc64/pgalloc.h	2007-03-25 15:56:23.000000000 -0700
+++ linux-2.6.21-rc5-mm4/include/asm-sparc64/pgalloc.h	2007-04-07 18:03:07.000000000 -0700
@@ -6,6 +6,7 @@
 #include <linux/sched.h>
 #include <linux/mm.h>
 #include <linux/slab.h>
+#include <linux/quicklist.h>
 
 #include <asm/spitfire.h>
 #include <asm/cpudata.h>
@@ -13,52 +14,50 @@
 #include <asm/page.h>
 
 /* Page table allocation/freeing. */
-extern struct kmem_cache *pgtable_cache;
 
 static inline pgd_t *pgd_alloc(struct mm_struct *mm)
 {
-	return kmem_cache_alloc(pgtable_cache, GFP_KERNEL);
+	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
 static inline void pgd_free(pgd_t *pgd)
 {
-	kmem_cache_free(pgtable_cache, pgd);
+	quicklist_free(0, NULL, pgd);
 }
 
 #define pud_populate(MM, PUD, PMD)	pud_set(PUD, PMD)
 
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return kmem_cache_alloc(pgtable_cache,
-				GFP_KERNEL|__GFP_REPEAT);
+	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
 static inline void pmd_free(pmd_t *pmd)
 {
-	kmem_cache_free(pgtable_cache, pmd);
+	quicklist_free(0, NULL, pmd);
 }
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
 {
-	return kmem_cache_alloc(pgtable_cache,
-				GFP_KERNEL|__GFP_REPEAT);
+	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
 static inline struct page *pte_alloc_one(struct mm_struct *mm,
 					 unsigned long address)
 {
-	return virt_to_page(pte_alloc_one_kernel(mm, address));
+	void *pg = quicklist_alloc(0, GFP_KERNEL, NULL);
+	return pg ? virt_to_page(pg) : NULL;
 }
 		
 static inline void pte_free_kernel(pte_t *pte)
 {
-	kmem_cache_free(pgtable_cache, pte);
+	quicklist_free(0, NULL, pte);
 }
 
 static inline void pte_free(struct page *ptepage)
 {
-	pte_free_kernel(page_address(ptepage));
+	quicklist_free_page(0, NULL, ptepage);
 }
 
 
@@ -66,6 +65,9 @@
 #define pmd_populate(MM,PMD,PTE_PAGE)		\
 	pmd_populate_kernel(MM,PMD,page_address(PTE_PAGE))
 
-#define check_pgt_cache()	do { } while (0)
+static inline void check_pgt_cache(void)
+{
+	quicklist_trim(0, NULL, 25, 16);
+}
 
 #endif /* _SPARC64_PGALLOC_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
