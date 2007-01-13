From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:46:06 +1100
Message-Id: <20070113024606.29682.18276.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 5/29] Start calling simple PTI functions
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH 05
 * Creates /include/linux/pt-type.h for holding different page table types.
  * Gives the default page table a type, and adjusts include/linux/sched.h 
  to point to the generic page table type (as opposed to the pgd).
 * Removes implementation dependent calls from fork.c and replaces them
 with calls from the interface in pt.h. (create_page_table etc are called
 instead).

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 include/linux/init_task.h |    2 +-
 include/linux/pt-type.h   |    8 ++++++++
 include/linux/sched.h     |    4 +++-
 kernel/fork.c             |   25 +++++++------------------
 4 files changed, 19 insertions(+), 20 deletions(-)
Index: linux-2.6.20-rc1/kernel/fork.c
===================================================================
--- linux-2.6.20-rc1.orig/kernel/fork.c	2006-12-23 14:54:16.573929000 +1100
+++ linux-2.6.20-rc1/kernel/fork.c	2006-12-23 14:55:07.173929000 +1100
@@ -49,6 +49,7 @@
 #include <linux/delayacct.h>
 #include <linux/taskstats_kern.h>
 #include <linux/random.h>
+#include <linux/pt.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -300,22 +301,10 @@
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
@@ -340,11 +329,11 @@
 	mm->ioctx_list = NULL;
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	mm->cached_hole_size = ~0UL;
-
-	if (likely(!mm_alloc_pgd(mm))) {
+	if (likely(!create_user_page_table(mm))) {
 		mm->def_flags = 0;
 		return mm;
 	}
+
 	free_mm(mm);
 	return NULL;
 }
@@ -372,7 +361,7 @@
 void fastcall __mmdrop(struct mm_struct *mm)
 {
 	BUG_ON(mm == &init_mm);
-	mm_free_pgd(mm);
+	destroy_user_page_table(mm);
 	destroy_context(mm);
 	free_mm(mm);
 }
@@ -519,7 +508,7 @@
 	 * If init_new_context() failed, we cannot use mmput() to free the mm
 	 * because it calls destroy_context()
 	 */
-	mm_free_pgd(mm);
+	destroy_user_page_table(mm);
 	free_mm(mm);
 	return NULL;
 }
Index: linux-2.6.20-rc1/include/linux/pt-type.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.20-rc1/include/linux/pt-type.h	2006-12-23 14:55:39.021929000 +1100
@@ -0,0 +1,8 @@
+#ifndef _LINUX_PT_TYPE_H
+#define _LINUX_PT_TYPE_H
+
+#ifdef CONFIG_PT_DEFAULT
+typedef struct { pgd_t *pgd; } pt_t;
+#endif
+
+#endif
Index: linux-2.6.20-rc1/include/linux/sched.h
===================================================================
--- linux-2.6.20-rc1.orig/include/linux/sched.h	2006-12-23 14:54:16.581929000 +1100
+++ linux-2.6.20-rc1/include/linux/sched.h	2006-12-23 14:55:07.173929000 +1100
@@ -83,6 +83,7 @@
 #include <linux/timer.h>
 #include <linux/hrtimer.h>
 #include <linux/task_io_accounting.h>
+#include <linux/pt-type.h>
 
 #include <asm/processor.h>
 
@@ -308,6 +309,7 @@
 } while (0)
 
 struct mm_struct {
+	pt_t page_table;					/* Page table */
 	struct vm_area_struct * mmap;		/* list of VMAs */
 	struct rb_root mm_rb;
 	struct vm_area_struct * mmap_cache;	/* last find_vma result */
@@ -319,7 +321,7 @@
 	unsigned long task_size;		/* size of task vm space */
 	unsigned long cached_hole_size;         /* if non-zero, the largest hole below free_area_cache */
 	unsigned long free_area_cache;		/* first hole of size cached_hole_size or larger */
-	pgd_t * pgd;
+		/*pgd_t * pgd;*/
 	atomic_t mm_users;			/* How many users with user space? */
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
 	int map_count;				/* number of VMAs */
Index: linux-2.6.20-rc1/include/linux/init_task.h
===================================================================
--- linux-2.6.20-rc1.orig/include/linux/init_task.h	2006-12-23 14:54:16.581929000 +1100
+++ linux-2.6.20-rc1/include/linux/init_task.h	2006-12-23 14:55:07.177929000 +1100
@@ -47,7 +47,7 @@
 #define INIT_MM(name) \
 {			 					\
 	.mm_rb		= RB_ROOT,				\
-	.pgd		= swapper_pg_dir, 			\
+	INIT_PT 			\
 	.mm_users	= ATOMIC_INIT(2), 			\
 	.mm_count	= ATOMIC_INIT(1), 			\
 	.mmap_sem	= __RWSEM_INITIALIZER(name.mmap_sem),	\

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
