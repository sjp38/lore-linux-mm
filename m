From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070323062903.19502.94804.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070323062843.19502.19827.sendpatchset@schroedinger.engr.sgi.com>
References: <20070323062843.19502.19827.sendpatchset@schroedinger.engr.sgi.com>
Subject: [QUICKLIST 5/5] Quicklist support for sparc64
Date: Thu, 22 Mar 2007 22:29:02 -0800 (PST)
Sender: owner-linux-mm@kvack.org
From: David Miller <davem@davemloft.net>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

[QUICKLIST]: Add sparc64 quicklist support.

I ported this to sparc64 as per the patch below, tested on
UP SunBlade1500 and 24 cpu Niagara T1000.

Signed-off-by: David S. Miller <davem@davemloft.net>

Index: linux-2.6.21-rc4-mm1/arch/sparc64/Kconfig
===================================================================
--- linux-2.6.21-rc4-mm1.orig/arch/sparc64/Kconfig	2007-03-20 14:20:33.000000000 -0700
+++ linux-2.6.21-rc4-mm1/arch/sparc64/Kconfig	2007-03-20 14:22:03.000000000 -0700
@@ -26,6 +26,10 @@ config MMU
 	bool
 	default y
 
+config QUICKLIST
+	bool
+	default y
+
 config STACKTRACE_SUPPORT
 	bool
 	default y
Index: linux-2.6.21-rc4-mm1/arch/sparc64/mm/init.c
===================================================================
--- linux-2.6.21-rc4-mm1.orig/arch/sparc64/mm/init.c	2007-03-20 14:20:33.000000000 -0700
+++ linux-2.6.21-rc4-mm1/arch/sparc64/mm/init.c	2007-03-20 14:22:03.000000000 -0700
@@ -178,30 +178,6 @@ unsigned long sparc64_kern_sec_context _
 
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
Index: linux-2.6.21-rc4-mm1/arch/sparc64/mm/tsb.c
===================================================================
--- linux-2.6.21-rc4-mm1.orig/arch/sparc64/mm/tsb.c	2007-03-15 17:20:01.000000000 -0700
+++ linux-2.6.21-rc4-mm1/arch/sparc64/mm/tsb.c	2007-03-20 14:22:03.000000000 -0700
@@ -252,7 +252,7 @@ static const char *tsb_cache_names[8] = 
 	"tsb_1MB",
 };
 
-void __init tsb_cache_init(void)
+void __init pgtable_cache_init(void)
 {
 	unsigned long i;
 
Index: linux-2.6.21-rc4-mm1/include/asm-sparc64/pgalloc.h
===================================================================
--- linux-2.6.21-rc4-mm1.orig/include/asm-sparc64/pgalloc.h	2007-03-15 17:20:01.000000000 -0700
+++ linux-2.6.21-rc4-mm1/include/asm-sparc64/pgalloc.h	2007-03-20 14:55:47.000000000 -0700
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
+	quicklist_free(0, NULL, page_address(ptepage));
 }
 
 
@@ -66,6 +65,9 @@ static inline void pte_free(struct page 
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
