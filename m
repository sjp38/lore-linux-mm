Subject: [RFC][PATCH 3/5] RSS accounting in the kernel code
Message-Id: <20070205132633.C02391B676@openx4.frec.bull.fr>
Date: Mon, 5 Feb 2007 14:26:33 +0100 (CET)
From: Patrick.Le-Dot@bull.net (Patrick.Le-Dot)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ckrm-tech@lists.sourceforge.net
Cc: balbir@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, menage@google.com
List-ID: <linux-mm.kvack.org>

Insert callbacks in the kernel

Signed-off-by: Patrick Le Dot <Patrick.Le-Dot@bull.net>
---

 include/linux/memctlr.h    |   15 +++++++
 include/linux/rmap.h       |    2 +
 include/linux/sched.h      |   11 +++++
 kernel/fork.c              |    6 +++
 kernel/res_group/memctlr.c |   90 +++++++++++++++++++++++++++++++++++++++++++--
 mm/rmap.c                  |    4 ++
 6 files changed, 125 insertions(+), 3 deletions(-)

diff -puN a/include/linux/sched.h b/include/linux/sched.h
--- a/include/linux/sched.h	2006-12-08 10:03:19.000000000 +0100
+++ b/include/linux/sched.h	2006-12-08 10:00:44.000000000 +0100
@@ -88,6 +88,10 @@ struct sched_param {
 struct exec_domain;
 struct futex_pi_state;
 
+struct memctlr;
+struct container;
+struct mem_counter;
+
 /*
  * List of flags we want to share for kernel threads,
  * if only because they are not used by them anyway.
@@ -355,6 +359,13 @@ struct mm_struct {
 	/* aio bits */
 	rwlock_t		ioctx_list_lock;
 	struct kioctx		*ioctx_list;
+#ifdef CONFIG_RES_GROUPS_MEMORY
+	struct container	*container;
+	/*
+	 * Try and merge anon and file rss accounting
+	 */
+	struct mem_counter	*counter;
+#endif
 };
 
 struct sighand_struct {
diff -puN a/kernel/res_group/memctlr.c b/kernel/res_group/memctlr.c
--- a/kernel/res_group/memctlr.c	2006-12-08 10:23:37.000000000 +0100
+++ b/kernel/res_group/memctlr.c	2006-12-08 10:36:01.000000000 +0100
@@ -70,12 +70,88 @@ static struct memctlr *get_memctlr(struc
 								&memctlr_rg));
 }
 
+static void memctlr_init_mem_counter(struct mem_counter *counter)
+{
+	atomic_long_set(&counter->rss, 0);
+}
+
+int mm_init_mem_counter(struct mm_struct *mm)
+{
+	mm->counter = kmalloc(sizeof(struct mem_counter), GFP_KERNEL);
+	if (!mm->counter)
+		return -ENOMEM;
+	memctlr_init_mem_counter(mm->counter);
+	return 0;
+}
+
+void mm_free_mem_counter(struct mm_struct *mm)
+{
+	kfree(mm->counter);
+}
+
+void mm_assign_container(struct mm_struct *mm, struct task_struct *p)
+{
+	rcu_read_lock();
+	mm->container = task_container(p, &memctlr_rg.subsys);
+	rcu_read_unlock();
+}
+
+static inline struct memctlr *get_task_memctlr(struct task_struct *p)
+{
+	struct memctlr *res;
+
+	/*
+	 * Is the resource groups infrastructure initialized?
+	 */
+	if (!memctlr_root)
+		return NULL;
+
+	rcu_read_lock();
+	res = get_memctlr(task_container(p, &memctlr_rg.subsys));
+	rcu_read_unlock();
+
+	if (!res)
+		return NULL;
+
+	return res;
+}
+
+
+void memctlr_inc_rss(struct page *page)
+{
+	struct memctlr *res;
+
+	res = get_task_memctlr(current);
+	if (!res)
+		return;
+
+	atomic_long_inc(&current->mm->counter->rss);
+	atomic_long_inc(&res->counter.rss);
+}
+
+void memctlr_dec_rss(struct page *page)
+{
+	struct memctlr *res;
+
+	res = get_task_memctlr(current);
+	if (!res)
+		return;
+
+	atomic_long_dec(&res->counter.rss);
+
+	if ((current->flags & PF_EXITING) && !current->mm)
+		return;
+	atomic_long_dec(&current->mm->counter->rss);
+}
+
 static void memctlr_init_new(struct memctlr *res)
 {
 	res->shares.min_shares = SHARE_DONT_CARE;
 	res->shares.max_shares = SHARE_DONT_CARE;
 	res->shares.child_shares_divisor = SHARE_DEFAULT_DIVISOR;
 	res->shares.unused_min_shares = SHARE_DEFAULT_DIVISOR;
+
+	memctlr_init_mem_counter(&res->counter);
 }
 
 static struct res_shares *memctlr_alloc_instance(struct resource_group *rgroup)
@@ -111,12 +187,19 @@ static void memctlr_free_instance(struct
 static ssize_t memctlr_show_stats(struct res_shares *shares, char *buf,
 					size_t len)
 {
-	int i = 0;
+	int i = 0, j = 0;
+	struct memctlr *res;
+
+	res = get_memctlr_from_shares(shares);
+	BUG_ON(!res);
 
-	i += snprintf(buf, len, "Accounting will be added soon\n");
+	i = snprintf(buf, len, "RSS Pages %ld\n",
+			atomic_long_read(&res->counter.rss));
 	buf += i;
 	len -= i;
-	return i;
+	j += i;
+
+	return j;
 }
 
 struct res_controller memctlr_rg = {
@@ -145,5 +228,6 @@ void __exit memctlr_exit(void)
 	BUG_ON(rc != 0);
 }
 
+
 module_init(memctlr_init);
 module_exit(memctlr_exit);
diff -puN a/include/linux/memctlr.h b/include/linux/memctlr.h
--- a/include/linux/memctlr.h	2006-12-08 10:03:19.000000000 +0100
+++ b/include/linux/memctlr.h	2006-12-08 10:02:30.000000000 +0100
@@ -28,6 +28,21 @@
 
 #ifdef CONFIG_RES_GROUPS_MEMORY
 #include <linux/res_group_rc.h>
+
+extern int mm_init_mem_counter(struct mm_struct *mm);
+extern void mm_assign_container(struct mm_struct *mm, struct task_struct *p);
+extern void memctlr_inc_rss(struct page *page);
+extern void memctlr_dec_rss(struct page *page);
+extern void mm_free_mem_counter(struct mm_struct *mm);
+
+#else /* CONFIG_RES_GROUPS_MEMORY */
+
+#define mm_init_mem_counter(mm)		(0)
+#define memctlr_inc_rss(page)		do { ; } while (0)
+#define memctlr_dec_rss(page)		do { ; } while (0)
+#define mm_assign_container(mm, task)	do { ; } while (0)
+#define mm_free_mem_counter(mm)		do { ; } while (0)
+
 #endif /* CONFIG_RES_GROUPS_MEMORY */
 
 #endif /* _LINUX_MEMCTRL_H */
diff -puN a/kernel/fork.c b/kernel/fork.c
--- a/kernel/fork.c	2006-12-08 10:03:19.000000000 +0100
+++ b/kernel/fork.c	2006-12-08 10:02:44.000000000 +0100
@@ -49,6 +49,7 @@
 #include <linux/taskstats_kern.h>
 #include <linux/random.h>
 #include <linux/numtasks.h>
+#include <linux/memctlr.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -340,11 +341,14 @@ static struct mm_struct * mm_init(struct
 	mm->ioctx_list = NULL;
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	mm->cached_hole_size = ~0UL;
+	if (mm_init_mem_counter(mm) < 0)
+		goto mem_fail;
 
 	if (likely(!mm_alloc_pgd(mm))) {
 		mm->def_flags = 0;
 		return mm;
 	}
+mem_fail:
 	free_mm(mm);
 	return NULL;
 }
@@ -372,6 +376,7 @@ struct mm_struct * mm_alloc(void)
 void fastcall __mmdrop(struct mm_struct *mm)
 {
 	BUG_ON(mm == &init_mm);
+	mm_free_mem_counter(mm);
 	mm_free_pgd(mm);
 	destroy_context(mm);
 	free_mm(mm);
@@ -544,6 +549,7 @@ static int copy_mm(unsigned long clone_f
 
 good_mm:
 	tsk->mm = mm;
+	mm_assign_container(mm, tsk);
 	tsk->active_mm = mm;
 	return 0;
 
diff -puN a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c	2006-12-08 10:03:19.000000000 +0100
+++ b/mm/rmap.c	2006-12-08 10:46:40.000000000 +0100
@@ -531,6 +531,7 @@ void page_add_anon_rmap(struct page *pag
 	if (atomic_inc_and_test(&page->_mapcount))
 		__page_set_anon_rmap(page, vma, address);
 	/* else checking page index and mapping is racy */
+	memctlr_inc_rss(page);
 }
 
 /*
@@ -547,6 +548,7 @@ void page_add_new_anon_rmap(struct page 
 {
 	atomic_set(&page->_mapcount, 0); /* elevate count by 1 (starts at -1) */
 	__page_set_anon_rmap(page, vma, address);
+	memctlr_inc_rss(page);
 }
 
 /**
@@ -559,6 +561,7 @@ void page_add_file_rmap(struct page *pag
 {
 	if (atomic_inc_and_test(&page->_mapcount))
 		__inc_zone_page_state(page, NR_FILE_MAPPED);
+	memctlr_inc_rss(page);
 }
 
 /**
@@ -592,6 +595,7 @@ void page_remove_rmap(struct page *page)
 		__dec_zone_page_state(page,
 				PageAnon(page) ? NR_ANON_PAGES : NR_FILE_MAPPED);
 	}
+	memctlr_dec_rss(page);
 }
 
 /*
diff -puN a/include/linux/rmap.h b/include/linux/rmap.h
--- a/include/linux/rmap.h	2006-12-08 10:03:19.000000000 +0100
+++ b/include/linux/rmap.h	2006-12-08 10:03:01.000000000 +0100
@@ -8,6 +8,7 @@
 #include <linux/slab.h>
 #include <linux/mm.h>
 #include <linux/spinlock.h>
+#include <linux/memctlr.h>
 
 /*
  * The anon_vma heads a list of private "related" vmas, to scan if
@@ -84,6 +85,7 @@ void page_remove_rmap(struct page *);
 static inline void page_dup_rmap(struct page *page)
 {
 	atomic_inc(&page->_mapcount);
+	memctlr_inc_rss(page);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
