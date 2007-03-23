From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070323062853.19502.49020.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070323062843.19502.19827.sendpatchset@schroedinger.engr.sgi.com>
References: <20070323062843.19502.19827.sendpatchset@schroedinger.engr.sgi.com>
Subject: [QUICKLIST 3/5] Quicklist support for i386
Date: Thu, 22 Mar 2007 22:28:51 -0800 (PST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Implement the i386 management of pgd and pmds using quicklists.

The i386 management of page table pages currently uses page sized slabs.
Getting rid of that using quicklists allows full use of the page flags
and the page->lru. So get rid of the improvised linked lists using
page->index and page->private.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc4-mm1/arch/i386/mm/init.c
===================================================================
--- linux-2.6.21-rc4-mm1.orig/arch/i386/mm/init.c	2007-03-15 17:20:01.000000000 -0700
+++ linux-2.6.21-rc4-mm1/arch/i386/mm/init.c	2007-03-20 14:21:52.000000000 -0700
@@ -695,31 +695,6 @@ int remove_memory(u64 start, u64 size)
 EXPORT_SYMBOL_GPL(remove_memory);
 #endif
 
-struct kmem_cache *pgd_cache;
-struct kmem_cache *pmd_cache;
-
-void __init pgtable_cache_init(void)
-{
-	if (PTRS_PER_PMD > 1) {
-		pmd_cache = kmem_cache_create("pmd",
-					PTRS_PER_PMD*sizeof(pmd_t),
-					PTRS_PER_PMD*sizeof(pmd_t),
-					0,
-					pmd_ctor,
-					NULL);
-		if (!pmd_cache)
-			panic("pgtable_cache_init(): cannot create pmd cache");
-	}
-	pgd_cache = kmem_cache_create("pgd",
-				PTRS_PER_PGD*sizeof(pgd_t),
-				PTRS_PER_PGD*sizeof(pgd_t),
-				0,
-				pgd_ctor,
-				PTRS_PER_PMD == 1 ? pgd_dtor : NULL);
-	if (!pgd_cache)
-		panic("pgtable_cache_init(): Cannot create pgd cache");
-}
-
 /*
  * This function cannot be __init, since exceptions don't work in that
  * section.  Put this after the callers, so that it cannot be inlined.
Index: linux-2.6.21-rc4-mm1/arch/i386/mm/pgtable.c
===================================================================
--- linux-2.6.21-rc4-mm1.orig/arch/i386/mm/pgtable.c	2007-03-15 17:20:01.000000000 -0700
+++ linux-2.6.21-rc4-mm1/arch/i386/mm/pgtable.c	2007-03-20 14:55:47.000000000 -0700
@@ -13,6 +13,7 @@
 #include <linux/pagemap.h>
 #include <linux/spinlock.h>
 #include <linux/module.h>
+#include <linux/quicklist.h>
 
 #include <asm/system.h>
 #include <asm/pgtable.h>
@@ -198,11 +199,6 @@ struct page *pte_alloc_one(struct mm_str
 	return pte;
 }
 
-void pmd_ctor(void *pmd, struct kmem_cache *cache, unsigned long flags)
-{
-	memset(pmd, 0, PTRS_PER_PMD*sizeof(pmd_t));
-}
-
 /*
  * List of all pgd's needed for non-PAE so it can invalidate entries
  * in both cached and uncached pgd's; not needed for PAE since the
@@ -211,36 +207,18 @@ void pmd_ctor(void *pmd, struct kmem_cac
  * against pageattr.c; it is the unique case in which a valid change
  * of kernel pagetables can't be lazily synchronized by vmalloc faults.
  * vmalloc faults work because attached pagetables are never freed.
- * The locking scheme was chosen on the basis of manfred's
- * recommendations and having no core impact whatsoever.
  * -- wli
  */
 DEFINE_SPINLOCK(pgd_lock);
-struct page *pgd_list;
-
-static inline void pgd_list_add(pgd_t *pgd)
-{
-	struct page *page = virt_to_page(pgd);
-	page->index = (unsigned long)pgd_list;
-	if (pgd_list)
-		set_page_private(pgd_list, (unsigned long)&page->index);
-	pgd_list = page;
-	set_page_private(page, (unsigned long)&pgd_list);
-}
+LIST_HEAD(pgd_list);
 
-static inline void pgd_list_del(pgd_t *pgd)
-{
-	struct page *next, **pprev, *page = virt_to_page(pgd);
-	next = (struct page *)page->index;
-	pprev = (struct page **)page_private(page);
-	*pprev = next;
-	if (next)
-		set_page_private(next, (unsigned long)pprev);
-}
+#define QUICK_PGD 0
+#define QUICK_PMD 1
 
-void pgd_ctor(void *pgd, struct kmem_cache *cache, unsigned long unused)
+void pgd_ctor(void *pgd)
 {
 	unsigned long flags;
+	struct page *page = virt_to_page(pgd);
 
 	if (PTRS_PER_PMD == 1) {
 		memset(pgd, 0, USER_PTRS_PER_PGD*sizeof(pgd_t));
@@ -259,31 +237,32 @@ void pgd_ctor(void *pgd, struct kmem_cac
 			__pa(swapper_pg_dir) >> PAGE_SHIFT,
 			USER_PTRS_PER_PGD, PTRS_PER_PGD - USER_PTRS_PER_PGD);
 
-	pgd_list_add(pgd);
+	list_add(&page->lru, &pgd_list);
 	spin_unlock_irqrestore(&pgd_lock, flags);
 }
 
 /* never called when PTRS_PER_PMD > 1 */
-void pgd_dtor(void *pgd, struct kmem_cache *cache, unsigned long unused)
+void pgd_dtor(void *pgd)
 {
 	unsigned long flags; /* can be called from interrupt context */
+	struct page *page = virt_to_page(pgd);
 
 	paravirt_release_pd(__pa(pgd) >> PAGE_SHIFT);
 	spin_lock_irqsave(&pgd_lock, flags);
-	pgd_list_del(pgd);
+	list_del(&page->lru);
 	spin_unlock_irqrestore(&pgd_lock, flags);
 }
 
 pgd_t *pgd_alloc(struct mm_struct *mm)
 {
 	int i;
-	pgd_t *pgd = kmem_cache_alloc(pgd_cache, GFP_KERNEL);
+	pgd_t *pgd = quicklist_alloc(QUICK_PGD, GFP_KERNEL, pgd_ctor);
 
 	if (PTRS_PER_PMD == 1 || !pgd)
 		return pgd;
 
 	for (i = 0; i < USER_PTRS_PER_PGD; ++i) {
-		pmd_t *pmd = kmem_cache_alloc(pmd_cache, GFP_KERNEL);
+		pmd_t *pmd = quicklist_alloc(QUICK_PMD, GFP_KERNEL, NULL);
 		if (!pmd)
 			goto out_oom;
 		paravirt_alloc_pd(__pa(pmd) >> PAGE_SHIFT);
@@ -296,9 +275,9 @@ out_oom:
 		pgd_t pgdent = pgd[i];
 		void* pmd = (void *)__va(pgd_val(pgdent)-1);
 		paravirt_release_pd(__pa(pmd) >> PAGE_SHIFT);
-		kmem_cache_free(pmd_cache, pmd);
+		quicklist_free(QUICK_PMD, NULL, pmd);
 	}
-	kmem_cache_free(pgd_cache, pgd);
+	quicklist_free(QUICK_PGD, pgd_dtor, pgd);
 	return NULL;
 }
 
@@ -312,8 +291,14 @@ void pgd_free(pgd_t *pgd)
 			pgd_t pgdent = pgd[i];
 			void* pmd = (void *)__va(pgd_val(pgdent)-1);
 			paravirt_release_pd(__pa(pmd) >> PAGE_SHIFT);
-			kmem_cache_free(pmd_cache, pmd);
+			quicklist_free(QUICK_PMD, NULL, pmd);
 		}
 	/* in the non-PAE case, free_pgtables() clears user pgd entries */
-	kmem_cache_free(pgd_cache, pgd);
+	quicklist_free(QUICK_PGD, pgd_ctor, pgd);
+}
+
+void check_pgt_cache(void)
+{
+	quicklist_trim(QUICK_PGD, pgd_dtor, 25, 16);
+	quicklist_trim(QUICK_PMD, NULL, 25, 16);
 }
Index: linux-2.6.21-rc4-mm1/arch/i386/Kconfig
===================================================================
--- linux-2.6.21-rc4-mm1.orig/arch/i386/Kconfig	2007-03-20 14:20:27.000000000 -0700
+++ linux-2.6.21-rc4-mm1/arch/i386/Kconfig	2007-03-20 14:21:52.000000000 -0700
@@ -55,6 +55,14 @@ config ZONE_DMA
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
 config SBUS
 	bool
 
Index: linux-2.6.21-rc4-mm1/include/asm-i386/pgtable.h
===================================================================
--- linux-2.6.21-rc4-mm1.orig/include/asm-i386/pgtable.h	2007-03-15 17:20:01.000000000 -0700
+++ linux-2.6.21-rc4-mm1/include/asm-i386/pgtable.h	2007-03-20 14:21:52.000000000 -0700
@@ -35,15 +35,12 @@ struct vm_area_struct;
 #define ZERO_PAGE(vaddr) (virt_to_page(empty_zero_page))
 extern unsigned long empty_zero_page[1024];
 extern pgd_t swapper_pg_dir[1024];
-extern struct kmem_cache *pgd_cache;
-extern struct kmem_cache *pmd_cache;
-extern spinlock_t pgd_lock;
-extern struct page *pgd_list;
 
-void pmd_ctor(void *, struct kmem_cache *, unsigned long);
-void pgd_ctor(void *, struct kmem_cache *, unsigned long);
-void pgd_dtor(void *, struct kmem_cache *, unsigned long);
-void pgtable_cache_init(void);
+void check_pgt_cache(void);
+
+extern spinlock_t pgd_lock;
+extern struct list_head pgd_list;
+static inline void pgtable_cache_init(void) {};
 void paging_init(void);
 
 /*
Index: linux-2.6.21-rc4-mm1/arch/i386/kernel/smp.c
===================================================================
--- linux-2.6.21-rc4-mm1.orig/arch/i386/kernel/smp.c	2007-03-20 14:20:28.000000000 -0700
+++ linux-2.6.21-rc4-mm1/arch/i386/kernel/smp.c	2007-03-20 14:21:52.000000000 -0700
@@ -437,7 +437,7 @@ void flush_tlb_mm (struct mm_struct * mm
 	}
 	if (!cpus_empty(cpu_mask))
 		flush_tlb_others(cpu_mask, mm, FLUSH_ALL);
-
+	check_pgt_cache();
 	preempt_enable();
 }
 
Index: linux-2.6.21-rc4-mm1/arch/i386/kernel/process.c
===================================================================
--- linux-2.6.21-rc4-mm1.orig/arch/i386/kernel/process.c	2007-03-20 14:20:28.000000000 -0700
+++ linux-2.6.21-rc4-mm1/arch/i386/kernel/process.c	2007-03-20 14:21:52.000000000 -0700
@@ -181,6 +181,7 @@ void cpu_idle(void)
 			if (__get_cpu_var(cpu_idle_state))
 				__get_cpu_var(cpu_idle_state) = 0;
 
+			check_pgt_cache();
 			rmb();
 			idle = pm_idle;
 
Index: linux-2.6.21-rc4-mm1/include/asm-i386/pgalloc.h
===================================================================
--- linux-2.6.21-rc4-mm1.orig/include/asm-i386/pgalloc.h	2007-03-20 14:21:00.000000000 -0700
+++ linux-2.6.21-rc4-mm1/include/asm-i386/pgalloc.h	2007-03-20 14:21:52.000000000 -0700
@@ -65,6 +65,6 @@ do {									\
 #define pud_populate(mm, pmd, pte)	BUG()
 #endif
 
-#define check_pgt_cache()	do { } while (0)
+extern void check_pgt_cache(void);
 
 #endif /* _I386_PGALLOC_H */
Index: linux-2.6.21-rc4-mm1/arch/i386/mm/fault.c
===================================================================
--- linux-2.6.21-rc4-mm1.orig/arch/i386/mm/fault.c	2007-03-20 14:20:28.000000000 -0700
+++ linux-2.6.21-rc4-mm1/arch/i386/mm/fault.c	2007-03-20 14:21:52.000000000 -0700
@@ -623,11 +623,10 @@ void vmalloc_sync_all(void)
 			struct page *page;
 
 			spin_lock_irqsave(&pgd_lock, flags);
-			for (page = pgd_list; page; page =
-					(struct page *)page->index)
+			list_for_each_entry(page, &pgd_list, lru)
 				if (!vmalloc_sync_one(page_address(page),
 								address)) {
-					BUG_ON(page != pgd_list);
+					BUG();
 					break;
 				}
 			spin_unlock_irqrestore(&pgd_lock, flags);
Index: linux-2.6.21-rc4-mm1/arch/i386/mm/pageattr.c
===================================================================
--- linux-2.6.21-rc4-mm1.orig/arch/i386/mm/pageattr.c	2007-03-15 17:20:01.000000000 -0700
+++ linux-2.6.21-rc4-mm1/arch/i386/mm/pageattr.c	2007-03-20 14:21:52.000000000 -0700
@@ -95,7 +95,7 @@ static void set_pmd_pte(pte_t *kpte, uns
 		return;
 
 	spin_lock_irqsave(&pgd_lock, flags);
-	for (page = pgd_list; page; page = (struct page *)page->index) {
+	list_for_each_entry(page, &pgd_list, lru) {
 		pgd_t *pgd;
 		pud_t *pud;
 		pmd_t *pmd;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
