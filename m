From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Thu, 13 Jul 2006 14:26:50 +1000
Message-Id: <20060713042650.9978.99039.sendpatchset@localhost.localdomain>
In-Reply-To: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
References: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
Subject: [PATCH 2/18] PTI - Page table type
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

This patch does the following:
1) Introduces a page table type in include/linux/pt-type.h.  
2) VM code making reference to pgds is replaced with references 
to the pt_type.
 * pgd is replaced in sched.h with new page table type, pt_type_t.
 * fork.c calls implementation in pt-default.h and no longer 
 directly refers to pgds.
 * pgtable.h & mmu_context.h references to pgd are removed for i386 and ia64.
 * init_task.h reference to pgd removed.

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 fs/proc/task_mmu.c             |   10 +---------
 include/asm-ia64/mmu_context.h |    2 +-
 include/asm-ia64/pgtable.h     |    4 ++--
 include/linux/init_task.h      |    2 +-
 include/linux/mm.h             |    9 +++++++++
 include/linux/pt-type.h        |    9 +++++++++
 include/linux/sched.h          |    3 ++-
 include/linux/swapops.h        |    5 +++++
 kernel/fork.c                  |   24 ++++++------------------
 mm/memory.c                    |   10 +---------
 10 files changed, 37 insertions(+), 41 deletions(-)
Index: linux-2.6.17.2/include/linux/mm.h
===================================================================
--- linux-2.6.17.2.orig/include/linux/mm.h	2006-07-08 23:23:46.298145512 +1000
+++ linux-2.6.17.2/include/linux/mm.h	2006-07-08 23:25:15.198630584 +1000
@@ -789,6 +789,15 @@
 extern struct shrinker *set_shrinker(int, shrinker_t);
 extern void remove_shrinker(struct shrinker *shrinker);
 
+struct mem_size_stats
+{
+	unsigned long resident;
+	unsigned long shared_clean;
+	unsigned long shared_dirty;
+	unsigned long private_clean;
+	unsigned long private_dirty;
+};
+
 extern pte_t *FASTCALL(get_locked_pte(struct mm_struct *mm, unsigned long addr, spinlock_t **ptl));
 
 int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address);
Index: linux-2.6.17.2/mm/memory.c
===================================================================
--- linux-2.6.17.2.orig/mm/memory.c	2006-07-08 23:23:46.299145360 +1000
+++ linux-2.6.17.2/mm/memory.c	2006-07-08 23:25:15.200630280 +1000
@@ -48,8 +48,8 @@
 #include <linux/rmap.h>
 #include <linux/module.h>
 #include <linux/init.h>
+#include <linux/pt.h>
 
-#include <asm/pgalloc.h>
 #include <asm/uaccess.h>
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
@@ -333,14 +333,6 @@
 	return 0;
 }
 
-static inline void add_mm_rss(struct mm_struct *mm, int file_rss, int anon_rss)
-{
-	if (file_rss)
-		add_mm_counter(mm, file_rss, file_rss);
-	if (anon_rss)
-		add_mm_counter(mm, anon_rss, anon_rss);
-}
-
 /*
  * This function is called to print an error when a bad pte
  * is found. For example, we might have a PFN-mapped pte in
Index: linux-2.6.17.2/fs/proc/task_mmu.c
===================================================================
--- linux-2.6.17.2.orig/fs/proc/task_mmu.c	2006-07-08 23:23:46.299145360 +1000
+++ linux-2.6.17.2/fs/proc/task_mmu.c	2006-07-08 23:25:15.201630128 +1000
@@ -5,6 +5,7 @@
 #include <linux/highmem.h>
 #include <linux/pagemap.h>
 #include <linux/mempolicy.h>
+#include <linux/pt.h>
 
 #include <asm/elf.h>
 #include <asm/uaccess.h>
@@ -109,15 +110,6 @@
 	seq_printf(m, "%*c", len, ' ');
 }
 
-struct mem_size_stats
-{
-	unsigned long resident;
-	unsigned long shared_clean;
-	unsigned long shared_dirty;
-	unsigned long private_clean;
-	unsigned long private_dirty;
-};
-
 static int show_map_internal(struct seq_file *m, void *v, struct mem_size_stats *mss)
 {
 	struct task_struct *task = m->private;
Index: linux-2.6.17.2/include/linux/swapops.h
===================================================================
--- linux-2.6.17.2.orig/include/linux/swapops.h	2006-07-08 23:23:46.298145512 +1000
+++ linux-2.6.17.2/include/linux/swapops.h	2006-07-08 23:25:15.201630128 +1000
@@ -1,3 +1,6 @@
+#ifndef _LINUX_SWAPOPS_H
+#define _LINUX_SWAPOPS_H 1
+
 /*
  * swapcache pages are stored in the swapper_space radix tree.  We want to
  * get good packing density in that tree, so the index should be dense in
@@ -67,3 +70,5 @@
 	BUG_ON(pte_file(__swp_entry_to_pte(arch_entry)));
 	return __swp_entry_to_pte(arch_entry);
 }
+
+#endif
Index: linux-2.6.17.2/include/linux/pt-type.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.17.2/include/linux/pt-type.h	2006-07-08 23:25:15.202629976 +1000
@@ -0,0 +1,9 @@
+#ifndef _LINUX_PT_TYPE_H
+#define _LINUX_PT_TYPE_H
+
+typedef struct struct_pt_type { pgd_t *pgd; } pt_type_t;
+
+#define get_root_pt(mm) (mm->pt.pgd)
+#define set_root_pt .pt.pgd = swapper_pg_dir
+
+#endif
Index: linux-2.6.17.2/include/linux/sched.h
===================================================================
--- linux-2.6.17.2.orig/include/linux/sched.h	2006-07-08 23:23:46.298145512 +1000
+++ linux-2.6.17.2/include/linux/sched.h	2006-07-08 23:25:15.203629824 +1000
@@ -23,6 +23,7 @@
 #include <asm/mmu.h>
 #include <asm/cputime.h>
 
+#include <linux/pt-type.h>
 #include <linux/smp.h>
 #include <linux/sem.h>
 #include <linux/signal.h>
@@ -304,7 +305,7 @@
 	unsigned long task_size;		/* size of task vm space */
 	unsigned long cached_hole_size;         /* if non-zero, the largest hole below free_area_cache */
 	unsigned long free_area_cache;		/* first hole of size cached_hole_size or larger */
-	pgd_t * pgd;
+	pt_type_t pt;				/* Page table */
 	atomic_t mm_users;			/* How many users with user space? */
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
 	int map_count;				/* number of VMAs */
Index: linux-2.6.17.2/include/asm-ia64/pgtable.h
===================================================================
--- linux-2.6.17.2.orig/include/asm-ia64/pgtable.h	2006-07-08 23:23:46.298145512 +1000
+++ linux-2.6.17.2/include/asm-ia64/pgtable.h	2006-07-08 23:25:15.203629824 +1000
@@ -347,13 +347,13 @@
 static inline pgd_t*
 pgd_offset (struct mm_struct *mm, unsigned long address)
 {
-	return mm->pgd + pgd_index(address);
+	return mm->pt.pgd + pgd_index(address);
 }
 
 /* In the kernel's mapped region we completely ignore the region number
    (since we know it's in region number 5). */
 #define pgd_offset_k(addr) \
-	(init_mm.pgd + (((addr) >> PGDIR_SHIFT) & (PTRS_PER_PGD - 1)))
+	(init_mm.pt.pgd + (((addr) >> PGDIR_SHIFT) & (PTRS_PER_PGD - 1)))
 
 /* Look up a pgd entry in the gate area.  On IA-64, the gate-area
    resides in the kernel-mapped segment, hence we use pgd_offset_k()
Index: linux-2.6.17.2/include/asm-ia64/mmu_context.h
===================================================================
--- linux-2.6.17.2.orig/include/asm-ia64/mmu_context.h	2006-07-08 23:23:46.299145360 +1000
+++ linux-2.6.17.2/include/asm-ia64/mmu_context.h	2006-07-08 23:25:15.204629672 +1000
@@ -191,7 +191,7 @@
 	 * We may get interrupts here, but that's OK because interrupt
 	 * handlers cannot touch user-space.
 	 */
-	ia64_set_kr(IA64_KR_PT_BASE, __pa(next->pgd));
+	ia64_set_kr(IA64_KR_PT_BASE, __pa(get_root_pt(next)));
 	activate_context(next);
 }
 
Index: linux-2.6.17.2/kernel/fork.c
===================================================================
--- linux-2.6.17.2.orig/kernel/fork.c	2006-07-08 23:23:46.299145360 +1000
+++ linux-2.6.17.2/kernel/fork.c	2006-07-08 23:25:51.298142624 +1000
@@ -44,9 +44,9 @@
 #include <linux/rmap.h>
 #include <linux/acct.h>
 #include <linux/cn_proc.h>
+#include <linux/pt.h>
 
 #include <asm/pgtable.h>
-#include <asm/pgalloc.h>
 #include <asm/uaccess.h>
 #include <asm/mmu_context.h>
 #include <asm/cacheflush.h>
@@ -286,22 +286,10 @@
 	goto out;
 }
 
-static inline int mm_alloc_pgd(struct mm_struct * mm)
-{
-	mm->pgd = pgd_alloc(mm);
-	if (unlikely(!mm->pgd))
-		return -ENOMEM;
-	return 0;
-}
-
-static inline void mm_free_pgd(struct mm_struct * mm)
-{
-	pgd_free(mm->pgd);
-}
 #else
 #define dup_mmap(mm, oldmm)	(0)
-#define mm_alloc_pgd(mm)	(0)
-#define mm_free_pgd(mm)
+#define create_user_page_table(mm)	(0)
+#define destroy_user_page_table(mm)
 #endif /* CONFIG_MMU */
 
  __cacheline_aligned_in_smp DEFINE_SPINLOCK(mmlist_lock);
@@ -327,7 +315,7 @@
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	mm->cached_hole_size = ~0UL;
 
-	if (likely(!mm_alloc_pgd(mm))) {
+	if (likely(!create_user_page_table(mm))) {
 		mm->def_flags = 0;
 		return mm;
 	}
@@ -358,7 +346,7 @@
 void fastcall __mmdrop(struct mm_struct *mm)
 {
 	BUG_ON(mm == &init_mm);
-	mm_free_pgd(mm);
+	destroy_user_page_table(mm);
 	destroy_context(mm);
 	free_mm(mm);
 }
@@ -490,7 +478,7 @@
 	 * If init_new_context() failed, we cannot use mmput() to free the mm
 	 * because it calls destroy_context()
 	 */
-	mm_free_pgd(mm);
+	destroy_user_page_table(mm);
 	free_mm(mm);
 	return NULL;
 }
Index: linux-2.6.17.2/include/linux/init_task.h
===================================================================
--- linux-2.6.17.2.orig/include/linux/init_task.h	2006-07-08 23:23:46.298145512 +1000
+++ linux-2.6.17.2/include/linux/init_task.h	2006-07-08 23:25:15.205629520 +1000
@@ -44,7 +44,7 @@
 #define INIT_MM(name) \
 {			 					\
 	.mm_rb		= RB_ROOT,				\
-	.pgd		= swapper_pg_dir, 			\
+	set_root_pt, 			\
 	.mm_users	= ATOMIC_INIT(2), 			\
 	.mm_count	= ATOMIC_INIT(1), 			\
 	.mmap_sem	= __RWSEM_INITIALIZER(name.mmap_sem),	\

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
