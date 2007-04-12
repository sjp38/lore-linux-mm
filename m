Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [150.166.1.51])
	by netops-testserver-3.corp.sgi.com (Postfix) with ESMTP id 62E6B908F3
	for <linux-mm@kvack.org>; Wed, 11 Apr 2007 18:00:54 -0700 (PDT)
Received: from clameter (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1HbngE-00067E-00
	for <linux-mm@kvack.org>; Wed, 11 Apr 2007 18:00:54 -0700
Date: Wed, 11 Apr 2007 17:58:52 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: [i386] Band-Aid: Minimal patch to enable SLUB
Message-ID: <Pine.LNX.4.64.0704111748280.23433@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.64.0704111800430.23511@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@vger.kernel.org, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

Andrew seems to want to release mm with SLUB as the default. Its bad that
i386 cannot use SLUB because of the handling of the pgds uses the page
struct fields. Some of the uses overlap.

This patch switches the pgd handling to use a quicklist. That way
both are disentangled and SLUB works fine (well it booted and built
a kernel ...)

Tried to be as least invasive as possible to provide some band aid.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc6/arch/i386/mm/init.c
===================================================================
--- linux-2.6.21-rc6.orig/arch/i386/mm/init.c	2007-04-12 00:24:52.000000000 +0000
+++ linux-2.6.21-rc6/arch/i386/mm/init.c	2007-04-12 00:25:10.000000000 +0000
@@ -752,7 +752,6 @@
 EXPORT_SYMBOL_GPL(remove_memory);
 #endif
 
-struct kmem_cache *pgd_cache;
 struct kmem_cache *pmd_cache;
 
 void __init pgtable_cache_init(void)
@@ -779,14 +778,6 @@
 			pgd_size = PAGE_SIZE;
 		}
 	}
-	pgd_cache = kmem_cache_create("pgd",
-				pgd_size,
-				pgd_size,
-				0,
-				pgd_ctor,
-				(!SHARED_KERNEL_PMD) ? pgd_dtor : NULL);
-	if (!pgd_cache)
-		panic("pgtable_cache_init(): Cannot create pgd cache");
 }
 
 /*
Index: linux-2.6.21-rc6/arch/i386/mm/pgtable.c
===================================================================
--- linux-2.6.21-rc6.orig/arch/i386/mm/pgtable.c	2007-04-12 00:24:52.000000000 +0000
+++ linux-2.6.21-rc6/arch/i386/mm/pgtable.c	2007-04-12 00:34:27.000000000 +0000
@@ -13,6 +13,7 @@
 #include <linux/pagemap.h>
 #include <linux/spinlock.h>
 #include <linux/module.h>
+#include <linux/quicklist.h>
 
 #include <asm/system.h>
 #include <asm/pgtable.h>
@@ -205,38 +206,19 @@
  * against pageattr.c; it is the unique case in which a valid change
  * of kernel pagetables can't be lazily synchronized by vmalloc faults.
  * vmalloc faults work because attached pagetables are never freed.
- * The locking scheme was chosen on the basis of manfred's
- * recommendations and having no core impact whatsoever.
  * -- wli
  */
 DEFINE_SPINLOCK(pgd_lock);
-struct page *pgd_list;
+LIST_HEAD(pgd_list);
 
-static inline void pgd_list_add(pgd_t *pgd)
-{
-	struct page *page = virt_to_page(pgd);
-	page->index = (unsigned long)pgd_list;
-	if (pgd_list)
-		set_page_private(pgd_list, (unsigned long)&page->index);
-	pgd_list = page;
-	set_page_private(page, (unsigned long)&pgd_list);
-}
-
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
 
 #if (PTRS_PER_PMD == 1)
 /* Non-PAE pgd constructor */
-void pgd_ctor(void *pgd, struct kmem_cache *cache, unsigned long unused)
+static void pgd_ctor(void *pgd)
 {
 	unsigned long flags;
+	struct page *page = virt_to_page(pgd);
 
 	/* !PAE, no pagetable sharing */
 	memset(pgd, 0, USER_PTRS_PER_PGD*sizeof(pgd_t));
@@ -251,12 +233,12 @@
 				__pa(swapper_pg_dir) >> PAGE_SHIFT,
 				USER_PTRS_PER_PGD,
 				KERNEL_PGD_PTRS);
-	pgd_list_add(pgd);
+	list_add(&page->lru, &pgd_list);
 	spin_unlock_irqrestore(&pgd_lock, flags);
 }
 #else  /* PTRS_PER_PMD > 1 */
 /* PAE pgd constructor */
-void pgd_ctor(void *pgd, struct kmem_cache *cache, unsigned long unused)
+static void pgd_ctor(void *pgd)
 {
 	/* PAE, kernel PMD may be shared */
 
@@ -266,24 +248,27 @@
 				KERNEL_PGD_PTRS);
 	} else {
 		unsigned long flags;
+		struct page *page = virt_to_page(pgd);
 
 		memset(pgd, 0, USER_PTRS_PER_PGD*sizeof(pgd_t));
 		spin_lock_irqsave(&pgd_lock, flags);
-		pgd_list_add(pgd);
+		list_add(&page->lru, &pgd_list);
 		spin_unlock_irqrestore(&pgd_lock, flags);
 	}
 }
 #endif	/* PTRS_PER_PMD */
 
-void pgd_dtor(void *pgd, struct kmem_cache *cache, unsigned long unused)
+static void pgd_dtor(void *pgd)
 {
 	unsigned long flags; /* can be called from interrupt context */
+	struct page *page = virt_to_page(pgd);
 
-	BUG_ON(SHARED_KERNEL_PMD);
+	if (SHARED_KERNEL_PMD)
+		return;
 
 	paravirt_release_pd(__pa(pgd) >> PAGE_SHIFT);
 	spin_lock_irqsave(&pgd_lock, flags);
-	pgd_list_del(pgd);
+	list_del(&page->lru);
 	spin_unlock_irqrestore(&pgd_lock, flags);
 }
 
@@ -321,7 +306,7 @@
 pgd_t *pgd_alloc(struct mm_struct *mm)
 {
 	int i;
-	pgd_t *pgd = kmem_cache_alloc(pgd_cache, GFP_KERNEL);
+	pgd_t *pgd = quicklist_alloc(QUICK_PGD, GFP_KERNEL, pgd_ctor);
 
 	if (PTRS_PER_PMD == 1 || !pgd)
 		return pgd;
@@ -344,7 +329,7 @@
 		paravirt_release_pd(__pa(pmd) >> PAGE_SHIFT);
 		pmd_cache_free(pmd, i);
 	}
-	kmem_cache_free(pgd_cache, pgd);
+	quicklist_free(QUICK_PGD, pgd_dtor, pgd);
 	return NULL;
 }
 
@@ -361,5 +346,11 @@
 			pmd_cache_free(pmd, i);
 		}
 	/* in the non-PAE case, free_pgtables() clears user pgd entries */
-	kmem_cache_free(pgd_cache, pgd);
+	quicklist_free(QUICK_PGD, pgd_dtor, pgd);
+}
+
+void check_pgt_cache(void)
+{
+	quicklist_trim(QUICK_PGD, pgd_dtor, 25, 16);
 }
+
Index: linux-2.6.21-rc6/arch/i386/Kconfig
===================================================================
--- linux-2.6.21-rc6.orig/arch/i386/Kconfig	2007-04-12 00:24:52.000000000 +0000
+++ linux-2.6.21-rc6/arch/i386/Kconfig	2007-04-12 00:25:10.000000000 +0000
@@ -55,6 +55,10 @@
 	bool
 	default y
 
+config QUICKLIST
+	bool
+	default y
+
 config SBUS
 	bool
 
@@ -79,10 +83,6 @@
 	bool
 	default y
 
-config ARCH_USES_SLAB_PAGE_STRUCT
-	bool
-	default y
-
 config DMI
 	bool
 	default y
Index: linux-2.6.21-rc6/include/asm-i386/pgtable.h
===================================================================
--- linux-2.6.21-rc6.orig/include/asm-i386/pgtable.h	2007-04-12 00:24:52.000000000 +0000
+++ linux-2.6.21-rc6/include/asm-i386/pgtable.h	2007-04-12 00:25:10.000000000 +0000
@@ -35,14 +35,13 @@
 #define ZERO_PAGE(vaddr) (virt_to_page(empty_zero_page))
 extern unsigned long empty_zero_page[1024];
 extern pgd_t swapper_pg_dir[1024];
-extern struct kmem_cache *pgd_cache;
-extern struct kmem_cache *pmd_cache;
-extern spinlock_t pgd_lock;
-extern struct page *pgd_list;
 
+void check_pgt_cache(void);
+
+extern spinlock_t pgd_lock;
+extern struct list_head pgd_list;
+extern struct kmem_cache *pmd_cache;
 void pmd_ctor(void *, struct kmem_cache *, unsigned long);
-void pgd_ctor(void *, struct kmem_cache *, unsigned long);
-void pgd_dtor(void *, struct kmem_cache *, unsigned long);
 void pgtable_cache_init(void);
 void paging_init(void);
 
Index: linux-2.6.21-rc6/arch/i386/kernel/process.c
===================================================================
--- linux-2.6.21-rc6.orig/arch/i386/kernel/process.c	2007-04-12 00:24:52.000000000 +0000
+++ linux-2.6.21-rc6/arch/i386/kernel/process.c	2007-04-12 00:25:10.000000000 +0000
@@ -181,6 +181,7 @@
 			if (__get_cpu_var(cpu_idle_state))
 				__get_cpu_var(cpu_idle_state) = 0;
 
+			check_pgt_cache();
 			rmb();
 			idle = pm_idle;
 
Index: linux-2.6.21-rc6/include/asm-i386/pgalloc.h
===================================================================
--- linux-2.6.21-rc6.orig/include/asm-i386/pgalloc.h	2007-04-12 00:24:52.000000000 +0000
+++ linux-2.6.21-rc6/include/asm-i386/pgalloc.h	2007-04-12 00:25:10.000000000 +0000
@@ -65,6 +65,6 @@
 #define pud_populate(mm, pmd, pte)	BUG()
 #endif
 
-#define check_pgt_cache()	do { } while (0)
+extern void check_pgt_cache(void);
 
 #endif /* _I386_PGALLOC_H */
Index: linux-2.6.21-rc6/arch/i386/mm/fault.c
===================================================================
--- linux-2.6.21-rc6.orig/arch/i386/mm/fault.c	2007-04-12 00:24:52.000000000 +0000
+++ linux-2.6.21-rc6/arch/i386/mm/fault.c	2007-04-12 00:25:10.000000000 +0000
@@ -625,11 +625,10 @@
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
Index: linux-2.6.21-rc6/arch/i386/mm/pageattr.c
===================================================================
--- linux-2.6.21-rc6.orig/arch/i386/mm/pageattr.c	2007-04-12 00:24:52.000000000 +0000
+++ linux-2.6.21-rc6/arch/i386/mm/pageattr.c	2007-04-12 00:25:10.000000000 +0000
@@ -95,7 +95,7 @@
 		return;
 
 	spin_lock_irqsave(&pgd_lock, flags);
-	for (page = pgd_list; page; page = (struct page *)page->index) {
+	list_for_each_entry(page, &pgd_list, lru) {
 		pgd_t *pgd;
 		pud_t *pud;
 		pmd_t *pmd;
Index: linux-2.6.21-rc6/arch/i386/kernel/smp.c
===================================================================
--- linux-2.6.21-rc6.orig/arch/i386/kernel/smp.c	2007-04-12 00:24:52.000000000 +0000
+++ linux-2.6.21-rc6/arch/i386/kernel/smp.c	2007-04-12 00:25:10.000000000 +0000
@@ -430,7 +430,7 @@
 	}
 	if (!cpus_empty(cpu_mask))
 		flush_tlb_others(cpu_mask, mm, TLB_FLUSH_ALL);
-
+	check_pgt_cache();
 	preempt_enable();
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
