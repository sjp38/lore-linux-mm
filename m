Message-Id: <20070427042909.653208285@sgi.com>
References: <20070427042655.019305162@sgi.com>
Date: Thu, 26 Apr 2007 21:27:05 -0700
From: clameter@sgi.com
Subject: [patch 10/10] SLUB: i386 support
Content-Disposition: inline; filename=slub_i386_pgd_slab
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

SLUB cannot run on i386 at this point because i386 uses the page->private and
page->index field of slab pages for the pgd cache.

Make SLUB run on i386 by replacing the pgd slab cache with a quicklist.
Limit the changes as much as possible. Leave the improvised linked list in place
etc etc. This has been working here for a couple of weeks now.

Cc: William Lee Irwin III <wli@holomorphy.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc7-mm2/arch/i386/Kconfig
===================================================================
--- linux-2.6.21-rc7-mm2.orig/arch/i386/Kconfig	2007-04-26 15:18:04.000000000 -0700
+++ linux-2.6.21-rc7-mm2/arch/i386/Kconfig	2007-04-26 15:23:08.000000000 -0700
@@ -55,6 +55,10 @@ config ZONE_DMA
 	bool
 	default y
 
+config QUICKLIST
+	bool
+	default y
+
 config SBUS
 	bool
 
@@ -79,10 +83,6 @@ config ARCH_MAY_HAVE_PC_FDC
 	bool
 	default y
 
-config ARCH_USES_SLAB_PAGE_STRUCT
-	bool
-	default y
-
 config DMI
 	bool
 	default y
Index: linux-2.6.21-rc7-mm2/arch/i386/kernel/process.c
===================================================================
--- linux-2.6.21-rc7-mm2.orig/arch/i386/kernel/process.c	2007-04-26 15:18:04.000000000 -0700
+++ linux-2.6.21-rc7-mm2/arch/i386/kernel/process.c	2007-04-26 15:23:08.000000000 -0700
@@ -186,6 +186,7 @@ void cpu_idle(void)
 			if (__get_cpu_var(cpu_idle_state))
 				__get_cpu_var(cpu_idle_state) = 0;
 
+			check_pgt_cache();
 			rmb();
 			idle = pm_idle;
 
Index: linux-2.6.21-rc7-mm2/arch/i386/kernel/smp.c
===================================================================
--- linux-2.6.21-rc7-mm2.orig/arch/i386/kernel/smp.c	2007-04-26 15:18:04.000000000 -0700
+++ linux-2.6.21-rc7-mm2/arch/i386/kernel/smp.c	2007-04-26 15:23:08.000000000 -0700
@@ -429,7 +429,7 @@ void flush_tlb_mm (struct mm_struct * mm
 	}
 	if (!cpus_empty(cpu_mask))
 		flush_tlb_others(cpu_mask, mm, TLB_FLUSH_ALL);
-
+	check_pgt_cache();
 	preempt_enable();
 }
 
Index: linux-2.6.21-rc7-mm2/arch/i386/mm/init.c
===================================================================
--- linux-2.6.21-rc7-mm2.orig/arch/i386/mm/init.c	2007-04-26 15:18:04.000000000 -0700
+++ linux-2.6.21-rc7-mm2/arch/i386/mm/init.c	2007-04-26 15:23:08.000000000 -0700
@@ -752,7 +752,6 @@ int remove_memory(u64 start, u64 size)
 EXPORT_SYMBOL_GPL(remove_memory);
 #endif
 
-struct kmem_cache *pgd_cache;
 struct kmem_cache *pmd_cache;
 
 void __init pgtable_cache_init(void)
@@ -776,12 +775,6 @@ void __init pgtable_cache_init(void)
 			pgd_size = PAGE_SIZE;
 		}
 	}
-	pgd_cache = kmem_cache_create("pgd",
-				pgd_size,
-				pgd_size,
-				SLAB_PANIC,
-				pgd_ctor,
-				(!SHARED_KERNEL_PMD) ? pgd_dtor : NULL);
 }
 
 /*
Index: linux-2.6.21-rc7-mm2/arch/i386/mm/pgtable.c
===================================================================
--- linux-2.6.21-rc7-mm2.orig/arch/i386/mm/pgtable.c	2007-04-26 15:18:04.000000000 -0700
+++ linux-2.6.21-rc7-mm2/arch/i386/mm/pgtable.c	2007-04-26 15:37:29.000000000 -0700
@@ -13,6 +13,7 @@
 #include <linux/pagemap.h>
 #include <linux/spinlock.h>
 #include <linux/module.h>
+#include <linux/quicklist.h>
 
 #include <asm/system.h>
 #include <asm/pgtable.h>
@@ -205,8 +206,6 @@ void pmd_ctor(void *pmd, struct kmem_cac
  * against pageattr.c; it is the unique case in which a valid change
  * of kernel pagetables can't be lazily synchronized by vmalloc faults.
  * vmalloc faults work because attached pagetables are never freed.
- * The locking scheme was chosen on the basis of manfred's
- * recommendations and having no core impact whatsoever.
  * -- wli
  */
 DEFINE_SPINLOCK(pgd_lock);
@@ -232,9 +231,11 @@ static inline void pgd_list_del(pgd_t *p
 		set_page_private(next, (unsigned long)pprev);
 }
 
+
+
 #if (PTRS_PER_PMD == 1)
 /* Non-PAE pgd constructor */
-void pgd_ctor(void *pgd, struct kmem_cache *cache, unsigned long unused)
+void pgd_ctor(void *pgd)
 {
 	unsigned long flags;
 
@@ -256,7 +257,7 @@ void pgd_ctor(void *pgd, struct kmem_cac
 }
 #else  /* PTRS_PER_PMD > 1 */
 /* PAE pgd constructor */
-void pgd_ctor(void *pgd, struct kmem_cache *cache, unsigned long unused)
+void pgd_ctor(void *pgd)
 {
 	/* PAE, kernel PMD may be shared */
 
@@ -275,11 +276,12 @@ void pgd_ctor(void *pgd, struct kmem_cac
 }
 #endif	/* PTRS_PER_PMD */
 
-void pgd_dtor(void *pgd, struct kmem_cache *cache, unsigned long unused)
+void pgd_dtor(void *pgd)
 {
 	unsigned long flags; /* can be called from interrupt context */
 
-	BUG_ON(SHARED_KERNEL_PMD);
+	if (SHARED_KERNEL_PMD)
+		return;
 
 	paravirt_release_pd(__pa(pgd) >> PAGE_SHIFT);
 	spin_lock_irqsave(&pgd_lock, flags);
@@ -321,7 +323,7 @@ static void pmd_cache_free(pmd_t *pmd, i
 pgd_t *pgd_alloc(struct mm_struct *mm)
 {
 	int i;
-	pgd_t *pgd = kmem_cache_alloc(pgd_cache, GFP_KERNEL);
+	pgd_t *pgd = quicklist_alloc(0, GFP_KERNEL, pgd_ctor);
 
 	if (PTRS_PER_PMD == 1 || !pgd)
 		return pgd;
@@ -344,7 +346,7 @@ out_oom:
 		paravirt_release_pd(__pa(pmd) >> PAGE_SHIFT);
 		pmd_cache_free(pmd, i);
 	}
-	kmem_cache_free(pgd_cache, pgd);
+	quicklist_free(0, pgd_dtor, pgd);
 	return NULL;
 }
 
@@ -361,5 +363,11 @@ void pgd_free(pgd_t *pgd)
 			pmd_cache_free(pmd, i);
 		}
 	/* in the non-PAE case, free_pgtables() clears user pgd entries */
-	kmem_cache_free(pgd_cache, pgd);
+	quicklist_free(0, pgd_dtor, pgd);
 }
+
+void check_pgt_cache(void)
+{
+	quicklist_trim(0, pgd_dtor, 25, 16);
+}
+
Index: linux-2.6.21-rc7-mm2/include/asm-i386/pgalloc.h
===================================================================
--- linux-2.6.21-rc7-mm2.orig/include/asm-i386/pgalloc.h	2007-04-26 15:18:04.000000000 -0700
+++ linux-2.6.21-rc7-mm2/include/asm-i386/pgalloc.h	2007-04-26 15:23:08.000000000 -0700
@@ -65,6 +65,4 @@ do {									\
 #define pud_populate(mm, pmd, pte)	BUG()
 #endif
 
-#define check_pgt_cache()	do { } while (0)
-
 #endif /* _I386_PGALLOC_H */
Index: linux-2.6.21-rc7-mm2/include/asm-i386/pgtable.h
===================================================================
--- linux-2.6.21-rc7-mm2.orig/include/asm-i386/pgtable.h	2007-04-26 15:18:04.000000000 -0700
+++ linux-2.6.21-rc7-mm2/include/asm-i386/pgtable.h	2007-04-26 15:23:08.000000000 -0700
@@ -35,17 +35,16 @@ struct vm_area_struct;
 #define ZERO_PAGE(vaddr) (virt_to_page(empty_zero_page))
 extern unsigned long empty_zero_page[1024];
 extern pgd_t swapper_pg_dir[1024];
-extern struct kmem_cache *pgd_cache;
 extern struct kmem_cache *pmd_cache;
 extern spinlock_t pgd_lock;
 extern struct page *pgd_list;
+void check_pgt_cache(void);
 
 void pmd_ctor(void *, struct kmem_cache *, unsigned long);
-void pgd_ctor(void *, struct kmem_cache *, unsigned long);
-void pgd_dtor(void *, struct kmem_cache *, unsigned long);
 void pgtable_cache_init(void);
 void paging_init(void);
 
+
 /*
  * The Linux x86 paging architecture is 'compile-time dual-mode', it
  * implements both the traditional 2-level x86 page tables and the

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
