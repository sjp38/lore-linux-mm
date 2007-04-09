From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070409182520.8559.33529.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070409182509.8559.33823.sendpatchset@schroedinger.engr.sgi.com>
References: <20070409182509.8559.33823.sendpatchset@schroedinger.engr.sgi.com>
Subject: [QUICKLIST 3/4] Quicklist support for x86_64
Date: Mon,  9 Apr 2007 11:25:20 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, ak@suse.de, Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Conver x86_64 to using quicklists

This adds caching of pgds and puds, pmds, pte. That way we can
avoid costly zeroing and initialization of special mappings in the
pgd.

A second quicklist is useful to separate out PGD handling. We can carry
the initialized pgds over to the next process needing them.

Also clean up the pgd_list handling to use regular list macros.
There is no need anymore to avoid the lru field.

Move the add/removal of the pgds to the pgdlist into the
constructor / destructor. That way the implementation is
congruent with i386.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 arch/x86_64/Kconfig          |    4 ++
 arch/x86_64/kernel/process.c |    1 
 arch/x86_64/kernel/smp.c     |    2 -
 arch/x86_64/mm/fault.c       |    5 +-
 include/asm-x86_64/pgalloc.h |   76 +++++++++++++++++++++----------------------
 include/asm-x86_64/pgtable.h |    3 -
 mm/Kconfig                   |    5 ++
 7 files changed, 52 insertions(+), 44 deletions(-)

Index: linux-2.6.21-rc5-mm4/arch/x86_64/Kconfig
===================================================================
--- linux-2.6.21-rc5-mm4.orig/arch/x86_64/Kconfig	2007-04-07 18:09:17.000000000 -0700
+++ linux-2.6.21-rc5-mm4/arch/x86_64/Kconfig	2007-04-07 18:09:30.000000000 -0700
@@ -56,6 +56,14 @@
 	bool
 	default y
 
+config QUICKLIST
+	bool
+	default y
+
+config NR_QUICK
+	int
+	default 2
+
 config ISA
 	bool
 
Index: linux-2.6.21-rc5-mm4/include/asm-x86_64/pgalloc.h
===================================================================
--- linux-2.6.21-rc5-mm4.orig/include/asm-x86_64/pgalloc.h	2007-04-07 18:07:47.000000000 -0700
+++ linux-2.6.21-rc5-mm4/include/asm-x86_64/pgalloc.h	2007-04-07 18:47:03.000000000 -0700
@@ -4,6 +4,10 @@
 #include <asm/pda.h>
 #include <linux/threads.h>
 #include <linux/mm.h>
+#include <linux/quicklist.h>
+
+#define QUICK_PGD 0	/* We preserve special mappings over free */
+#define QUICK_PT 1	/* Other page table pages that are zero on free */
 
 #define pmd_populate_kernel(mm, pmd, pte) \
 		set_pmd(pmd, __pmd(_PAGE_TABLE | __pa(pte)))
@@ -20,23 +24,23 @@
 static inline void pmd_free(pmd_t *pmd)
 {
 	BUG_ON((unsigned long)pmd & (PAGE_SIZE-1));
-	free_page((unsigned long)pmd);
+	quicklist_free(QUICK_PT, NULL, pmd);
 }
 
 static inline pmd_t *pmd_alloc_one (struct mm_struct *mm, unsigned long addr)
 {
-	return (pmd_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+	return (pmd_t *)quicklist_alloc(QUICK_PT, GFP_KERNEL|__GFP_REPEAT, NULL);
 }
 
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return (pud_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+	return (pud_t *)quicklist_alloc(QUICK_PT, GFP_KERNEL|__GFP_REPEAT, NULL);
 }
 
 static inline void pud_free (pud_t *pud)
 {
 	BUG_ON((unsigned long)pud & (PAGE_SIZE-1));
-	free_page((unsigned long)pud);
+	quicklist_free(QUICK_PT, NULL, pud);
 }
 
 static inline void pgd_list_add(pgd_t *pgd)
@@ -57,41 +61,57 @@
 	spin_unlock(&pgd_lock);
 }
 
-static inline pgd_t *pgd_alloc(struct mm_struct *mm)
+static inline void pgd_ctor(void *x)
 {
 	unsigned boundary;
-	pgd_t *pgd = (pgd_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
-	if (!pgd)
-		return NULL;
-	pgd_list_add(pgd);
+	pgd_t *pgd = x;
+	struct page *page = virt_to_page(pgd);
+
 	/*
 	 * Copy kernel pointers in from init.
-	 * Could keep a freelist or slab cache of those because the kernel
-	 * part never changes.
 	 */
 	boundary = pgd_index(__PAGE_OFFSET);
-	memset(pgd, 0, boundary * sizeof(pgd_t));
 	memcpy(pgd + boundary,
-	       init_level4_pgt + boundary,
-	       (PTRS_PER_PGD - boundary) * sizeof(pgd_t));
+		init_level4_pgt + boundary,
+		(PTRS_PER_PGD - boundary) * sizeof(pgd_t));
+
+	spin_lock(&pgd_lock);
+	list_add(&page->lru, &pgd_list);
+	spin_unlock(&pgd_lock);
+}
+
+static inline void pgd_dtor(void *x)
+{
+	pgd_t *pgd = x;
+	struct page *page = virt_to_page(pgd);
+
+        spin_lock(&pgd_lock);
+	list_del(&page->lru);
+	spin_unlock(&pgd_lock);
+}
+
+static inline pgd_t *pgd_alloc(struct mm_struct *mm)
+{
+	pgd_t *pgd = (pgd_t *)quicklist_alloc(QUICK_PGD,
+		GFP_KERNEL|__GFP_REPEAT, pgd_ctor);
 	return pgd;
 }
 
 static inline void pgd_free(pgd_t *pgd)
 {
 	BUG_ON((unsigned long)pgd & (PAGE_SIZE-1));
-	pgd_list_del(pgd);
-	free_page((unsigned long)pgd);
+	quicklist_free(QUICK_PGD, pgd_dtor, pgd);
 }
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
-	return (pte_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+	return (pte_t *)quicklist_alloc(QUICK_PT, GFP_KERNEL|__GFP_REPEAT, NULL);
 }
 
 static inline struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
-	void *p = (void *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+	void *p = (void *)quicklist_alloc(QUICK_PT, GFP_KERNEL|__GFP_REPEAT, NULL);
+
 	if (!p)
 		return NULL;
 	return virt_to_page(p);
@@ -103,17 +123,22 @@
 static inline void pte_free_kernel(pte_t *pte)
 {
 	BUG_ON((unsigned long)pte & (PAGE_SIZE-1));
-	free_page((unsigned long)pte); 
+	quicklist_free(QUICK_PT, NULL, pte);
 }
 
 static inline void pte_free(struct page *pte)
 {
-	__free_page(pte);
-} 
+	quicklist_free_page(QUICK_PT, NULL, pte);
+}
 
-#define __pte_free_tlb(tlb,pte) tlb_remove_page((tlb),(pte))
+#define __pte_free_tlb(tlb,pte) quicklist_free_page(QUICK_PT, NULL,(pte))
 
-#define __pmd_free_tlb(tlb,x)   tlb_remove_page((tlb),virt_to_page(x))
-#define __pud_free_tlb(tlb,x)   tlb_remove_page((tlb),virt_to_page(x))
+#define __pmd_free_tlb(tlb,x)   quicklist_free(QUICK_PT, NULL, (x))
+#define __pud_free_tlb(tlb,x)   quicklist_free(QUICK_PT, NULL, (x))
 
+static inline void check_pgt_cache(void)
+{
+	quicklist_trim(QUICK_PGD, pgd_dtor, 25, 16);
+	quicklist_trim(QUICK_PT, NULL, 25, 16);
+}
 #endif /* _X86_64_PGALLOC_H */
Index: linux-2.6.21-rc5-mm4/arch/x86_64/kernel/process.c
===================================================================
--- linux-2.6.21-rc5-mm4.orig/arch/x86_64/kernel/process.c	2007-04-07 18:07:47.000000000 -0700
+++ linux-2.6.21-rc5-mm4/arch/x86_64/kernel/process.c	2007-04-07 18:09:30.000000000 -0700
@@ -207,6 +207,7 @@
 			if (__get_cpu_var(cpu_idle_state))
 				__get_cpu_var(cpu_idle_state) = 0;
 
+			check_pgt_cache();
 			rmb();
 			idle = pm_idle;
 			if (!idle)
Index: linux-2.6.21-rc5-mm4/arch/x86_64/kernel/smp.c
===================================================================
--- linux-2.6.21-rc5-mm4.orig/arch/x86_64/kernel/smp.c	2007-04-07 18:07:47.000000000 -0700
+++ linux-2.6.21-rc5-mm4/arch/x86_64/kernel/smp.c	2007-04-07 18:09:30.000000000 -0700
@@ -241,7 +241,7 @@
 	}
 	if (!cpus_empty(cpu_mask))
 		flush_tlb_others(cpu_mask, mm, FLUSH_ALL);
-
+	check_pgt_cache();
 	preempt_enable();
 }
 EXPORT_SYMBOL(flush_tlb_mm);
Index: linux-2.6.21-rc5-mm4/include/asm-x86_64/pgtable.h
===================================================================
--- linux-2.6.21-rc5-mm4.orig/include/asm-x86_64/pgtable.h	2007-04-07 18:07:47.000000000 -0700
+++ linux-2.6.21-rc5-mm4/include/asm-x86_64/pgtable.h	2007-04-07 18:09:30.000000000 -0700
@@ -424,7 +424,6 @@
 #define HAVE_ARCH_UNMAPPED_AREA
 
 #define pgtable_cache_init()   do { } while (0)
-#define check_pgt_cache()      do { } while (0)
 
 #define PAGE_AGP    PAGE_KERNEL_NOCACHE
 #define HAVE_PAGE_AGP 1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
