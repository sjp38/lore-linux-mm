From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070409182515.8559.87570.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070409182509.8559.33823.sendpatchset@schroedinger.engr.sgi.com>
References: <20070409182509.8559.33823.sendpatchset@schroedinger.engr.sgi.com>
Subject: [QUICKLIST 2/4] Quicklist support for IA64
Date: Mon,  9 Apr 2007 11:25:15 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, ak@suse.de, linux-kernel@vger.kernel.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Quicklist for IA64

IA64 is the origin of the quicklist implementation. So cut out the pieces
that are now in core code and modify the functions called.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc5-mm4/arch/ia64/mm/init.c
===================================================================
--- linux-2.6.21-rc5-mm4.orig/arch/ia64/mm/init.c	2007-04-07 16:20:16.000000000 -0700
+++ linux-2.6.21-rc5-mm4/arch/ia64/mm/init.c	2007-04-07 18:02:51.000000000 -0700
@@ -39,9 +39,6 @@
 
 DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
 
-DEFINE_PER_CPU(unsigned long *, __pgtable_quicklist);
-DEFINE_PER_CPU(long, __pgtable_quicklist_size);
-
 extern void ia64_tlb_init (void);
 
 unsigned long MAX_DMA_ADDRESS = PAGE_OFFSET + 0x100000000UL;
@@ -56,54 +53,6 @@
 struct page *zero_page_memmap_ptr;	/* map entry for zero page */
 EXPORT_SYMBOL(zero_page_memmap_ptr);
 
-#define MIN_PGT_PAGES			25UL
-#define MAX_PGT_FREES_PER_PASS		16L
-#define PGT_FRACTION_OF_NODE_MEM	16
-
-static inline long
-max_pgt_pages(void)
-{
-	u64 node_free_pages, max_pgt_pages;
-
-#ifndef	CONFIG_NUMA
-	node_free_pages = nr_free_pages();
-#else
-	node_free_pages = node_page_state(numa_node_id(), NR_FREE_PAGES);
-#endif
-	max_pgt_pages = node_free_pages / PGT_FRACTION_OF_NODE_MEM;
-	max_pgt_pages = max(max_pgt_pages, MIN_PGT_PAGES);
-	return max_pgt_pages;
-}
-
-static inline long
-min_pages_to_free(void)
-{
-	long pages_to_free;
-
-	pages_to_free = pgtable_quicklist_size - max_pgt_pages();
-	pages_to_free = min(pages_to_free, MAX_PGT_FREES_PER_PASS);
-	return pages_to_free;
-}
-
-void
-check_pgt_cache(void)
-{
-	long pages_to_free;
-
-	if (unlikely(pgtable_quicklist_size <= MIN_PGT_PAGES))
-		return;
-
-	preempt_disable();
-	while (unlikely((pages_to_free = min_pages_to_free()) > 0)) {
-		while (pages_to_free--) {
-			free_page((unsigned long)pgtable_quicklist_alloc());
-		}
-		preempt_enable();
-		preempt_disable();
-	}
-	preempt_enable();
-}
-
 void
 lazy_mmu_prot_update (pte_t pte)
 {
Index: linux-2.6.21-rc5-mm4/include/asm-ia64/pgalloc.h
===================================================================
--- linux-2.6.21-rc5-mm4.orig/include/asm-ia64/pgalloc.h	2007-03-25 15:56:23.000000000 -0700
+++ linux-2.6.21-rc5-mm4/include/asm-ia64/pgalloc.h	2007-04-07 18:02:51.000000000 -0700
@@ -18,71 +18,18 @@
 #include <linux/mm.h>
 #include <linux/page-flags.h>
 #include <linux/threads.h>
+#include <linux/quicklist.h>
 
 #include <asm/mmu_context.h>
 
-DECLARE_PER_CPU(unsigned long *, __pgtable_quicklist);
-#define pgtable_quicklist __ia64_per_cpu_var(__pgtable_quicklist)
-DECLARE_PER_CPU(long, __pgtable_quicklist_size);
-#define pgtable_quicklist_size __ia64_per_cpu_var(__pgtable_quicklist_size)
-
-static inline long pgtable_quicklist_total_size(void)
-{
-	long ql_size = 0;
-	int cpuid;
-
-	for_each_online_cpu(cpuid) {
-		ql_size += per_cpu(__pgtable_quicklist_size, cpuid);
-	}
-	return ql_size;
-}
-
-static inline void *pgtable_quicklist_alloc(void)
-{
-	unsigned long *ret = NULL;
-
-	preempt_disable();
-
-	ret = pgtable_quicklist;
-	if (likely(ret != NULL)) {
-		pgtable_quicklist = (unsigned long *)(*ret);
-		ret[0] = 0;
-		--pgtable_quicklist_size;
-		preempt_enable();
-	} else {
-		preempt_enable();
-		ret = (unsigned long *)__get_free_page(GFP_KERNEL | __GFP_ZERO);
-	}
-
-	return ret;
-}
-
-static inline void pgtable_quicklist_free(void *pgtable_entry)
-{
-#ifdef CONFIG_NUMA
-	int nid = page_to_nid(virt_to_page(pgtable_entry));
-
-	if (unlikely(nid != numa_node_id())) {
-		free_page((unsigned long)pgtable_entry);
-		return;
-	}
-#endif
-
-	preempt_disable();
-	*(unsigned long *)pgtable_entry = (unsigned long)pgtable_quicklist;
-	pgtable_quicklist = (unsigned long *)pgtable_entry;
-	++pgtable_quicklist_size;
-	preempt_enable();
-}
-
 static inline pgd_t *pgd_alloc(struct mm_struct *mm)
 {
-	return pgtable_quicklist_alloc();
+	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
 static inline void pgd_free(pgd_t * pgd)
 {
-	pgtable_quicklist_free(pgd);
+	quicklist_free(0, NULL, pgd);
 }
 
 #ifdef CONFIG_PGTABLE_4
@@ -94,12 +41,12 @@
 
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return pgtable_quicklist_alloc();
+	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
 static inline void pud_free(pud_t * pud)
 {
-	pgtable_quicklist_free(pud);
+	quicklist_free(0, NULL, pud);
 }
 #define __pud_free_tlb(tlb, pud)	pud_free(pud)
 #endif /* CONFIG_PGTABLE_4 */
@@ -112,12 +59,12 @@
 
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return pgtable_quicklist_alloc();
+	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
 static inline void pmd_free(pmd_t * pmd)
 {
-	pgtable_quicklist_free(pmd);
+	quicklist_free(0, NULL, pmd);
 }
 
 #define __pmd_free_tlb(tlb, pmd)	pmd_free(pmd)
@@ -137,28 +84,31 @@
 static inline struct page *pte_alloc_one(struct mm_struct *mm,
 					 unsigned long addr)
 {
-	void *pg = pgtable_quicklist_alloc();
+	void *pg = quicklist_alloc(0, GFP_KERNEL, NULL);
 	return pg ? virt_to_page(pg) : NULL;
 }
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long addr)
 {
-	return pgtable_quicklist_alloc();
+	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
 
 static inline void pte_free(struct page *pte)
 {
-	pgtable_quicklist_free(page_address(pte));
+	quicklist_free_page(0, NULL, pte);
 }
 
 static inline void pte_free_kernel(pte_t * pte)
 {
-	pgtable_quicklist_free(pte);
+	quicklist_free(0, NULL, pte);
 }
 
-#define __pte_free_tlb(tlb, pte)	pte_free(pte)
+static inline void check_pgt_cache(void)
+{
+	quicklist_trim(0, NULL, 25, 16);
+}
 
-extern void check_pgt_cache(void);
+#define __pte_free_tlb(tlb, pte)	pte_free(pte)
 
 #endif				/* _ASM_IA64_PGALLOC_H */
Index: linux-2.6.21-rc5-mm4/arch/ia64/mm/contig.c
===================================================================
--- linux-2.6.21-rc5-mm4.orig/arch/ia64/mm/contig.c	2007-04-07 16:20:07.000000000 -0700
+++ linux-2.6.21-rc5-mm4/arch/ia64/mm/contig.c	2007-04-07 18:02:51.000000000 -0700
@@ -88,7 +88,7 @@
 	printk(KERN_INFO "%d pages shared\n", total_shared);
 	printk(KERN_INFO "%d pages swap cached\n", total_cached);
 	printk(KERN_INFO "Total of %ld pages in page table cache\n",
-	       pgtable_quicklist_total_size());
+	       quicklist_total_size());
 	printk(KERN_INFO "%d free buffer pages\n", nr_free_buffer_pages());
 }
 
Index: linux-2.6.21-rc5-mm4/arch/ia64/mm/discontig.c
===================================================================
--- linux-2.6.21-rc5-mm4.orig/arch/ia64/mm/discontig.c	2007-04-07 17:59:49.000000000 -0700
+++ linux-2.6.21-rc5-mm4/arch/ia64/mm/discontig.c	2007-04-07 18:02:51.000000000 -0700
@@ -636,7 +636,7 @@
 	printk(KERN_INFO "%d pages shared\n", total_shared);
 	printk(KERN_INFO "%d pages swap cached\n", total_cached);
 	printk(KERN_INFO "Total of %ld pages in page table cache\n",
-	       pgtable_quicklist_total_size());
+	       quicklist_total_size());
 	printk(KERN_INFO "%d free buffer pages\n", nr_free_buffer_pages());
 }
 
Index: linux-2.6.21-rc5-mm4/arch/ia64/Kconfig
===================================================================
--- linux-2.6.21-rc5-mm4.orig/arch/ia64/Kconfig	2007-04-07 17:59:49.000000000 -0700
+++ linux-2.6.21-rc5-mm4/arch/ia64/Kconfig	2007-04-07 18:02:51.000000000 -0700
@@ -30,6 +30,10 @@
 	def_bool y
 	depends on !IA64_SGI_SN2
 
+config QUICKLIST
+	bool
+	default y
+
 config MMU
 	bool
 	default y

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
