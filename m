Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j324KxYF016128
	for <linux-mm@kvack.org>; Fri, 1 Apr 2005 23:20:59 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j324Kxk4248846
	for <linux-mm@kvack.org>; Fri, 1 Apr 2005 23:20:59 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j324KwBn018208
	for <linux-mm@kvack.org>; Fri, 1 Apr 2005 23:20:59 -0500
Date: Fri, 1 Apr 2005 19:12:49 -0800
From: Chandra Seetharaman <sekharan@us.ibm.com>
Subject: [PATCH 2/6] CKRM: Core framework support
Message-ID: <20050402031249.GC23284@chandralinux.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="i0/AhcQY5QxfSsSZ"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--i0/AhcQY5QxfSsSZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


-- 

----------------------------------------------------------------------
    Chandra Seetharaman               | Be careful what you choose....
              - sekharan@us.ibm.com   |      .......you may get it.
----------------------------------------------------------------------

--i0/AhcQY5QxfSsSZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=11-02-mem_base-core

Patch 2 of 6 patches to support memory controller under CKRM framework.
This patch gets the controller into the CKRM framework. Basically, it
provides all the necessary function points needed by the CKRM framework,
and also provides the filesystem interface.
No support for guarantee/limit is available in this patch.

 include/linux/ckrm_mem.h        |   68 +++++++
 include/linux/ckrm_mem_inline.h |  192 ++++++++++++++++++++
 include/linux/mm.h              |    4 
 kernel/ckrm/Makefile            |    1 
 kernel/ckrm/ckrm_memcore.c      |  376 ++++++++++++++++++++++++++++++++++++++++
 kernel/ckrm/ckrm_memctlr.c      |  205 +++++++++++++++++++++
 6 files changed, 845 insertions(+), 1 deletion(-)

Index: linux-2.6.12-rc1/include/linux/ckrm_mem.h
===================================================================
--- /dev/null
+++ linux-2.6.12-rc1/include/linux/ckrm_mem.h
@@ -0,0 +1,68 @@
+/* include/linux/ckrm_mem.h : memory control for CKRM
+ *
+ * Copyright (C) Jiantao Kong, IBM Corp. 2003
+ *           (C) Shailabh Nagar, IBM Corp. 2003
+ *           (C) Chandra Seetharaman, IBM Corp. 2004
+ *
+ *
+ * Memory control functions of the CKRM kernel API
+ *
+ * Latest version, more details at http://ckrm.sf.net
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ */
+
+#ifndef _LINUX_CKRM_MEM_H
+#define _LINUX_CKRM_MEM_H
+
+#ifdef CONFIG_CKRM_RES_MEM
+
+#include <linux/list.h>
+#include <linux/kref.h>
+#include <linux/mmzone.h>
+#include <linux/ckrm_rc.h>
+
+struct ckrm_mem_res {
+	unsigned long flags;
+	struct ckrm_core_class *core;	/* the core i am part of... */
+	struct ckrm_core_class *parent;	/* parent of the core i am part of */
+	struct ckrm_shares shares;	
+	struct list_head mcls_list;	/* list of all 1-level classes */
+	struct kref nr_users;		/* ref count */
+	int pg_total[MAX_NR_ZONES];	/* # of pages used by this class */
+	int pg_guar;			/* absolute # of guarantee */
+	int pg_limit;			/* absolute # of limit */
+	int pg_borrowed[MAX_NR_ZONES];	/* # of pages borrowed from parent */
+	int pg_lent[MAX_NR_ZONES];	/* # of pages lent to children */
+	int pg_unused;			/* # of pages left to this class
+					 * (after giving the guarantees to
+					 * children. need to borrow from
+					 * parent if more than this is needed.
+					 */
+	int hier;			/* hiearchy level, root = 0 */
+};
+
+extern atomic_t ckrm_mem_real_count;
+extern struct ckrm_res_ctlr mem_rcbs;
+extern struct ckrm_mem_res *ckrm_mem_root_class;
+
+extern void ckrm_mem_migrate_mm(struct mm_struct *, struct ckrm_mem_res *);
+extern void ckrm_mem_migrate_all_pages(struct ckrm_mem_res *,
+						struct ckrm_mem_res *);
+extern void memclass_release(struct kref *);
+extern void incr_use_count(struct ckrm_mem_res *, int, int);
+extern void decr_use_count(struct ckrm_mem_res *, int, int);
+extern int ckrm_class_limit_ok(struct ckrm_mem_res *);
+
+#else
+
+#define ckrm_mem_migrate_mm(a, b)			do {} while (0)
+#define ckrm_mem_migrate_all_pages(a, b)		do {} while (0)
+
+#endif /* CONFIG_CKRM_RES_MEM */
+
+#endif /* _LINUX_CKRM_MEM_H */
Index: linux-2.6.12-rc1/include/linux/ckrm_mem_inline.h
===================================================================
--- linux-2.6.12-rc1.orig/include/linux/ckrm_mem_inline.h
+++ linux-2.6.12-rc1/include/linux/ckrm_mem_inline.h
@@ -19,9 +19,188 @@
 #ifndef _LINUX_CKRM_MEM_INLINE_H_
 #define _LINUX_CKRM_MEM_INLINE_H_
 
+#include <linux/rmap.h>
+#include <linux/mmzone.h>
+#include <linux/ckrm_mem.h>
+
+
 #ifdef CONFIG_CKRM_RES_MEM
 
-#error "Memory controller for CKRM is not available."
+static inline struct ckrm_mem_res *
+ckrm_get_mem_class(struct task_struct *tsk)
+{
+	return ckrm_get_res_class(tsk->taskclass, mem_rcbs.resid,
+		struct ckrm_mem_res);
+}
+
+static inline void
+ckrm_set_page_class(struct page *page, struct ckrm_mem_res *cls)
+{
+	if (!cls) {
+		if (!ckrm_mem_root_class)
+			return;
+		cls = ckrm_mem_root_class;
+	}
+	if (page->ckrm_class)
+		kref_put(&page->ckrm_class->nr_users, memclass_release);
+	page->ckrm_class = cls;
+	kref_get(&cls->nr_users);
+	incr_use_count(cls, 0, page_zonenum(page));
+	SetPageCkrmAccount(page);
+}
+
+static inline void
+ckrm_change_page_class(struct page *page, struct ckrm_mem_res *newcls)
+{
+	struct ckrm_mem_res *oldcls = page->ckrm_class;
+	int zindex = page_zonenum(page);
+
+	if  (!newcls) {
+		if (!ckrm_mem_root_class)
+			return;
+		newcls = ckrm_mem_root_class;
+	}
+
+	if (oldcls == newcls)
+		return;
+
+	if (oldcls) {
+		kref_put(&oldcls->nr_users, memclass_release);
+		decr_use_count(oldcls, 0, zindex);
+	}
+
+	page->ckrm_class = newcls;
+	kref_get(&newcls->nr_users);
+	incr_use_count(newcls, 0, zindex);
+}
+
+static inline void
+ckrm_clear_page_class(struct page *page)
+{
+	struct ckrm_mem_res *cls = page->ckrm_class;
+	if (cls && PageCkrmAccount(page)) {
+		decr_use_count(cls, 0, page_zonenum(page));
+		ClearPageCkrmAccount(page);
+		kref_put(&cls->nr_users, memclass_release);
+	}
+}
+
+static inline void
+ckrm_mem_inc_active(struct page *page)
+{
+	struct ckrm_mem_res *cls = ckrm_get_mem_class(current)
+						?: ckrm_mem_root_class;
+
+	if (!cls)
+		return;
+	ckrm_set_page_class(page, cls);
+}
+
+static inline void
+ckrm_mem_dec_active(struct page *page)
+{
+	if (page->ckrm_class == NULL)
+		return;
+	ckrm_clear_page_class(page);
+}
+
+static inline void
+ckrm_mem_inc_inactive(struct page *page)
+{
+	struct ckrm_mem_res *cls = ckrm_get_mem_class(current)
+					?: ckrm_mem_root_class;
+
+	if (!cls)
+		return;
+	ckrm_set_page_class(page, cls);
+}
+
+static inline void
+ckrm_mem_dec_inactive(struct page *page)
+{
+	if (!page->ckrm_class)
+		return;
+	ckrm_clear_page_class(page);
+}
+
+static inline void
+ckrm_page_init(struct page *page)
+{
+	page->flags &= ~(1 << PG_ckrm_account);
+	page->ckrm_class = NULL;
+}
+
+
+/* task/mm initializations/cleanup */
+
+static inline void
+ckrm_task_mm_init(struct task_struct *tsk)
+{
+	INIT_LIST_HEAD(&tsk->mm_peers);
+}
+
+static inline void
+ckrm_task_mm_set(struct mm_struct * mm, struct task_struct *task)
+{
+	spin_lock(&mm->peertask_lock);
+	if (!list_empty(&task->mm_peers)) {
+		printk(KERN_ERR "MEM_RC: Task list NOT empty!! emptying...\n");
+		list_del_init(&task->mm_peers);
+	}
+	list_add_tail(&task->mm_peers, &mm->tasklist);
+	spin_unlock(&mm->peertask_lock);
+	if (mm->memclass != ckrm_get_mem_class(task))
+		ckrm_mem_migrate_mm(mm, NULL);
+	return;
+}
+
+static inline void
+ckrm_task_mm_change(struct task_struct *tsk,
+		struct mm_struct *oldmm, struct mm_struct *newmm)
+{
+	if (oldmm) {
+		spin_lock(&oldmm->peertask_lock);
+		list_del(&tsk->mm_peers);
+		ckrm_mem_migrate_mm(oldmm, NULL);
+		spin_unlock(&oldmm->peertask_lock);
+	}
+	spin_lock(&newmm->peertask_lock);
+	list_add_tail(&tsk->mm_peers, &newmm->tasklist);
+	ckrm_mem_migrate_mm(newmm, NULL);
+	spin_unlock(&newmm->peertask_lock);
+}
+
+static inline void
+ckrm_task_mm_clear(struct task_struct *tsk, struct mm_struct *mm)
+{
+	spin_lock(&mm->peertask_lock);
+	list_del_init(&tsk->mm_peers);
+	ckrm_mem_migrate_mm(mm, NULL);
+	spin_unlock(&mm->peertask_lock);
+}
+
+static inline void
+ckrm_mm_init(struct mm_struct *mm)
+{
+	INIT_LIST_HEAD(&mm->tasklist);
+	mm->peertask_lock = SPIN_LOCK_UNLOCKED;
+}
+
+static inline void
+ckrm_mm_setclass(struct mm_struct *mm, struct ckrm_mem_res *cls)
+{
+	mm->memclass = cls;
+	kref_get(&cls->nr_users);
+}
+
+static inline void
+ckrm_mm_clearclass(struct mm_struct *mm)
+{
+	if (mm->memclass) {
+		kref_put(&mm->memclass->nr_users, memclass_release);
+		mm->memclass = NULL;
+	}
+}
 
 #else
 
@@ -46,6 +225,12 @@ ckrm_task_mm_clear(struct task_struct *t
 {
 }
 
+static inline void *
+ckrm_get_memclass(struct task_struct *tsk)
+{
+	return NULL;
+}
+
 static inline void
 ckrm_mm_init(struct mm_struct *mm)
 {
@@ -56,6 +241,11 @@ ckrm_mm_init(struct mm_struct *mm)
 #define ckrm_mm_setclass(a, b) do { } while(0)
 #define ckrm_class_limit_ok(a)	(1)
 
+static inline void
+ckrm_mm_clearclass(struct mm_struct *mm)
+{
+}
+
 static inline void ckrm_mem_inc_active(struct page *p)		{}
 static inline void ckrm_mem_dec_active(struct page *p)		{}
 static inline void ckrm_mem_inc_inactive(struct page *p)	{}
Index: linux-2.6.12-rc1/include/linux/mm.h
===================================================================
--- linux-2.6.12-rc1.orig/include/linux/mm.h
+++ linux-2.6.12-rc1/include/linux/mm.h
@@ -13,6 +13,7 @@
 #include <linux/rbtree.h>
 #include <linux/prio_tree.h>
 #include <linux/fs.h>
+#include <linux/ckrm_mem.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -260,6 +261,9 @@ struct page {
 	void *virtual;			/* Kernel virtual address (NULL if
 					   not kmapped, ie. highmem) */
 #endif /* WANT_PAGE_VIRTUAL */
+#ifdef CONFIG_CKRM_RES_MEM
+	struct ckrm_mem_res *ckrm_class;
+#endif
 };
 
 /*
Index: linux-2.6.12-rc1/kernel/ckrm/Makefile
===================================================================
--- linux-2.6.12-rc1.orig/kernel/ckrm/Makefile
+++ linux-2.6.12-rc1/kernel/ckrm/Makefile
@@ -6,3 +6,4 @@ obj-y += ckrm_events.o ckrm.o ckrmutils.
 obj-$(CONFIG_CKRM_TYPE_TASKCLASS) += ckrm_tc.o ckrm_numtasks_stub.o
 obj-$(CONFIG_CKRM_TYPE_SOCKETCLASS) += ckrm_sockc.o
 obj-$(CONFIG_CKRM_RES_NUMTASKS) += ckrm_numtasks.o
+obj-$(CONFIG_CKRM_RES_MEM) += ckrm_memcore.o ckrm_memctlr.o
Index: linux-2.6.12-rc1/kernel/ckrm/ckrm_memcore.c
===================================================================
--- /dev/null
+++ linux-2.6.12-rc1/kernel/ckrm/ckrm_memcore.c
@@ -0,0 +1,376 @@
+/* ckrm_memcore.c - Memory Resource Manager for CKRM
+ *
+ * Copyright (C) Jiantao Kong, IBM Corp. 2003
+ *           (C) Chandra Seetharaman, IBM Corp. 2004
+ *           (C) Valerie Clement <Valerie.Clement@bull.net> 2004
+ *
+ * Provides a Memory Resource controller for CKRM
+ *
+ * Latest version, more details at http://ckrm.sf.net
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/slab.h>
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <linux/pagemap.h>
+#include <linux/swap.h>
+#include <linux/swapops.h>
+#include <linux/cache.h>
+#include <linux/percpu.h>
+#include <linux/pagevec.h>
+#include <linux/parser.h>
+#include <linux/ckrm_mem_inline.h>
+
+#include <asm/uaccess.h>
+#include <asm/pgtable.h>
+#include <asm/errno.h>
+
+#define MEM_RES_NAME "mem"
+
+#define CKRM_MEM_MAX_HIERARCHY 2 /* allows only upto 2 levels - 0, 1 & 2 */
+
+/* all 1-level memory_share_class are chained together */
+static LIST_HEAD(ckrm_memclass_list);
+static spinlock_t ckrm_mem_lock; /* protects list above */
+static unsigned int ckrm_tot_lru_pages; /* # of pages in the system */
+
+static int ckrm_nr_mem_classes = 0;
+
+struct ckrm_mem_res *ckrm_mem_root_class;
+atomic_t ckrm_mem_real_count = ATOMIC_INIT(0);
+EXPORT_SYMBOL_GPL(ckrm_mem_root_class);
+EXPORT_SYMBOL_GPL(ckrm_mem_real_count);
+
+void
+memclass_release(struct kref *kref)
+{
+	struct ckrm_mem_res *cls = container_of(kref, 
+				struct ckrm_mem_res, nr_users);
+	kfree(cls);
+}
+EXPORT_SYMBOL_GPL(memclass_release);
+
+static void
+set_ckrm_tot_pages(void)
+{
+	struct zone *zone;
+	int tot_lru_pages = 0;
+
+	for_each_zone(zone) {
+		tot_lru_pages += zone->nr_active;
+		tot_lru_pages += zone->nr_inactive;
+		tot_lru_pages += zone->free_pages;
+	}
+	ckrm_tot_lru_pages = tot_lru_pages;
+}
+
+/* Initialize rescls values
+ * May be called on each rcfs unmount or as part of error recovery
+ * to make share values sane.
+ * Does not traverse hierarchy reinitializing children.
+ */
+static void
+mem_res_initcls_one(struct ckrm_mem_res *res)
+{
+	memset(res, 0, sizeof(struct ckrm_mem_res));
+
+	res->shares.my_guarantee     = CKRM_SHARE_DONTCARE;
+	res->shares.my_limit         = CKRM_SHARE_DONTCARE;
+	res->shares.total_guarantee  = CKRM_SHARE_DFLT_TOTAL_GUARANTEE;
+	res->shares.max_limit        = CKRM_SHARE_DFLT_MAX_LIMIT;
+	res->shares.unused_guarantee = CKRM_SHARE_DFLT_TOTAL_GUARANTEE;
+	res->shares.cur_max_limit    = 0;
+
+	res->pg_guar = CKRM_SHARE_DONTCARE;
+	res->pg_limit = CKRM_SHARE_DONTCARE;
+
+	INIT_LIST_HEAD(&res->mcls_list);
+
+	res->pg_unused = 0;
+	kref_init(&res->nr_users);
+}
+
+static void *
+mem_res_alloc(struct ckrm_core_class *core, struct ckrm_core_class *parent)
+{
+	struct ckrm_mem_res *res, *pres;
+
+	BUG_ON(mem_rcbs.resid == -1);
+
+	pres = ckrm_get_res_class(parent, mem_rcbs.resid, struct ckrm_mem_res);
+	if (pres && (pres->hier == CKRM_MEM_MAX_HIERARCHY)) {
+		printk(KERN_ERR "MEM_RC: only allows hieararchy of %d\n",
+						CKRM_MEM_MAX_HIERARCHY);
+		return NULL;
+	}
+
+	if ((parent == NULL) && (ckrm_mem_root_class != NULL)) {
+		printk(KERN_ERR "MEM_RC: Only one root class is allowed\n");
+		return NULL;
+	}
+
+	if ((parent != NULL) && (ckrm_mem_root_class == NULL)) {
+		printk(KERN_ERR "MEM_RC: child class with no root class!!");
+		return NULL;
+	}
+
+	res = kmalloc(sizeof(struct ckrm_mem_res), GFP_ATOMIC);
+
+	if (res) {
+		mem_res_initcls_one(res);
+		res->core = core;
+		res->parent = parent;
+		spin_lock_irq(&ckrm_mem_lock);
+		list_add(&res->mcls_list, &ckrm_memclass_list);
+		spin_unlock_irq(&ckrm_mem_lock);
+		if (parent == NULL) {
+			/* I am the root class. So, set the max to *
+			 * number of pages available in the system */
+			res->pg_guar = ckrm_tot_lru_pages;
+			res->pg_unused = ckrm_tot_lru_pages;
+			res->pg_limit = ckrm_tot_lru_pages;
+			res->hier = 0;
+			ckrm_mem_root_class = res;
+		} else
+			res->hier = pres->hier + 1;
+		ckrm_nr_mem_classes++;
+	} else
+		printk(KERN_ERR "MEM_RC: alloc: GFP_ATOMIC failed\n");
+	return res;
+}
+
+static void
+mem_res_free(void *my_res)
+{
+	struct ckrm_mem_res *res = my_res;
+	struct ckrm_mem_res *pres;
+
+	if (!res)
+		return;
+
+	ckrm_mem_migrate_all_pages(res, ckrm_mem_root_class);
+
+	pres = ckrm_get_res_class(res->parent, mem_rcbs.resid,
+			struct ckrm_mem_res);
+
+	/*
+	 * Making it all zero as freeing of data structure could 
+	 * happen later.
+	 */
+	res->shares.my_guarantee = 0;
+	res->shares.my_limit = 0;
+	res->pg_guar = 0;
+	res->pg_limit = 0;
+	res->pg_unused = 0;
+
+	spin_lock_irq(&ckrm_mem_lock);
+	list_del_init(&res->mcls_list);
+	spin_unlock_irq(&ckrm_mem_lock);
+
+	res->core = NULL;
+	res->parent = NULL;
+	kref_put(&res->nr_users, memclass_release);
+	ckrm_nr_mem_classes--;
+	return;
+}
+
+static int
+mem_set_share_values(void *my_res, struct ckrm_shares *shares)
+{
+	struct ckrm_mem_res *res = my_res;
+
+	if (!res)
+		return -EINVAL;
+
+	printk(KERN_INFO "set_share called for %s resource of class %s\n",
+			MEM_RES_NAME, res->core->name);
+	return 0;
+}
+
+static int
+mem_get_share_values(void *my_res, struct ckrm_shares *shares)
+{
+	struct ckrm_mem_res *res = my_res;
+
+	if (!res)
+		return -EINVAL;
+	printk(KERN_INFO "get_share called for %s resource of class %s\n",
+			MEM_RES_NAME, res->core->name);
+	*shares = res->shares;
+	return 0;
+}
+
+static int
+mem_get_stats(void *my_res, struct seq_file *sfile)
+{
+	struct ckrm_mem_res *res = my_res;
+	struct zone *zone;
+	int active = 0, inactive = 0, fr = 0;
+	int pg_total = 0, pg_lent = 0, pg_borrowed = 0, i;
+
+	if (!res)
+		return -EINVAL;
+
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+		pg_lent += res->pg_lent[i];
+		pg_total += res->pg_total[i];
+		pg_borrowed += res->pg_borrowed[i];
+	}
+	seq_printf(sfile, "--------- Memory Resource stats start ---------\n");
+	if (res == ckrm_mem_root_class) {
+		i = 0;
+		for_each_zone(zone) {
+			active += zone->nr_active;
+			inactive += zone->nr_inactive;
+			fr += zone->free_pages;
+			i++;
+		}
+		seq_printf(sfile,"System: tot_pages=%d,active=%d,inactive=%d"
+				",free=%d\n", ckrm_tot_lru_pages,
+				active, inactive, fr);
+	}
+	seq_printf(sfile, "Number of pages used(including pages lent to"
+			" children): %d\n", pg_total);
+	seq_printf(sfile, "Number of pages guaranteed: %d\n",
+			res->pg_guar);
+	seq_printf(sfile, "Maximum limit of pages: %d\n",
+			res->pg_limit);
+	seq_printf(sfile, "Total number of pages available"
+			"(after serving guarantees to children): %d\n",
+			res->pg_unused);
+	seq_printf(sfile, "Number of pages lent to children: %d\n", pg_lent);
+	seq_printf(sfile, "Number of pages borrowed from the parent: %d\n",
+			pg_borrowed);
+	seq_printf(sfile, "---------- Memory Resource stats end ----------\n");
+
+	return 0;
+}
+
+static void
+mem_change_resclass(void *tsk, void *old, void *new)
+{
+	struct mm_struct *mm;
+	struct task_struct *task = tsk, *t1;
+	struct ckrm_mem_res *prev_mmcls;
+
+	if (!task->mm || (new == old) || (old == (void *) -1))
+		return;
+
+	mm = task->active_mm;
+	spin_lock(&mm->peertask_lock);
+	prev_mmcls = mm->memclass;
+
+	if (new == NULL)
+		list_del_init(&task->mm_peers);
+	else {
+		int found = 0;
+		list_for_each_entry(t1, &mm->tasklist, mm_peers) {
+			if (t1 == task) {
+				found++;
+				break;
+			}
+		}
+		if (!found) {
+			list_del_init(&task->mm_peers);
+			list_add_tail(&task->mm_peers, &mm->tasklist);
+		}
+	}
+
+	spin_unlock(&mm->peertask_lock);
+	ckrm_mem_migrate_mm(mm, (struct ckrm_mem_res *) new);
+	return;
+}
+
+static int
+mem_show_config(void *my_res, struct seq_file *sfile)
+{
+	struct ckrm_mem_res *res = my_res;
+
+	if (!res)
+		return -EINVAL;
+	printk(KERN_INFO "show_config called for %s resource of class %s\n",
+			MEM_RES_NAME, res->core->name);
+
+	seq_printf(sfile, "res=%s", MEM_RES_NAME);
+
+	return 0;
+}
+
+static int
+mem_set_config(void *my_res, const char *cfgstr)
+{
+	struct ckrm_mem_res *res = my_res;
+
+	if (!res)
+		return -EINVAL;
+	printk(KERN_INFO "set_config called for %s resource of class %s\n",
+			MEM_RES_NAME, res->core->name);
+	return 0;
+}
+
+static int
+mem_reset_stats(void *my_res)
+{
+	struct ckrm_mem_res *res = my_res;
+	printk(KERN_INFO "MEM_RC: reset stats called for class %s\n",
+				res->core->name);
+	return 0;
+}
+
+struct ckrm_res_ctlr mem_rcbs = {
+	.res_name          = MEM_RES_NAME,
+	.res_hdepth        = CKRM_MEM_MAX_HIERARCHY,
+	.resid             = -1,
+	.res_alloc         = mem_res_alloc,
+	.res_free          = mem_res_free,
+	.set_share_values  = mem_set_share_values,
+	.get_share_values  = mem_get_share_values,
+	.get_stats         = mem_get_stats,
+	.change_resclass   = mem_change_resclass,
+	.show_config       = mem_show_config,
+	.set_config        = mem_set_config,
+	.reset_stats       = mem_reset_stats,
+};
+
+EXPORT_SYMBOL_GPL(mem_rcbs);
+
+int __init
+init_ckrm_mem_res(void)
+{
+	struct ckrm_classtype *clstype;
+	int resid = mem_rcbs.resid;
+
+	set_ckrm_tot_pages();
+	spin_lock_init(&ckrm_mem_lock);
+	clstype = ckrm_find_classtype_by_name("taskclass");
+	if (clstype == NULL) {
+		printk(KERN_INFO " Unknown ckrm classtype<taskclass>");
+		return -ENOENT;
+	}
+
+	if (resid == -1) {
+		resid = ckrm_register_res_ctlr(clstype, &mem_rcbs);
+		if (resid != -1)
+			mem_rcbs.classtype = clstype;
+	}
+	return ((resid < 0) ? resid : 0);
+}
+
+void __exit
+exit_ckrm_mem_res(void)
+{
+	ckrm_unregister_res_ctlr(&mem_rcbs);
+	mem_rcbs.resid = -1;
+}
+
+module_init(init_ckrm_mem_res)
+module_exit(exit_ckrm_mem_res)
+MODULE_LICENSE("GPL");
Index: linux-2.6.12-rc1/kernel/ckrm/ckrm_memctlr.c
===================================================================
--- /dev/null
+++ linux-2.6.12-rc1/kernel/ckrm/ckrm_memctlr.c
@@ -0,0 +1,203 @@
+/* ckrm_memctlr.c - Basic routines for the CKRM memory controller
+ *
+ * Copyright (C) Jiantao Kong, IBM Corp. 2003
+ *           (C) Chandra Seetharaman, IBM Corp. 2004
+ *
+ * Provides a Memory Resource controller for CKRM
+ *
+ * Latest version, more details at http://ckrm.sf.net
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ */
+
+#include <linux/ckrm_mem_inline.h>
+
+void
+incr_use_count(struct ckrm_mem_res *cls, int borrow, int zindex)
+{
+	int i, pg_total = 0;
+	struct ckrm_mem_res *parcls = ckrm_get_res_class(cls->parent,
+				mem_rcbs.resid, struct ckrm_mem_res);
+
+	if (!cls)
+		return;
+
+	cls->pg_total[zindex]++;
+	for (i = 0; i < MAX_NR_ZONES; i++)
+		pg_total += cls->pg_total[i];
+	if (borrow)
+		cls->pg_lent[zindex]++;
+
+	parcls = ckrm_get_res_class(cls->parent,
+				mem_rcbs.resid, struct ckrm_mem_res);
+	if (parcls && ((cls->pg_guar == CKRM_SHARE_DONTCARE) ||
+			(pg_total > cls->pg_unused))) {
+		incr_use_count(parcls, 1, zindex);
+		cls->pg_borrowed[zindex]++;
+	} else
+		atomic_inc(&ckrm_mem_real_count);
+	return;
+}
+
+void
+decr_use_count(struct ckrm_mem_res *cls, int borrowed, int zindex)
+{
+	if (!cls)
+		return;
+	cls->pg_total[zindex]--;
+	if (borrowed)
+		cls->pg_lent[zindex]--;
+	if (cls->pg_borrowed > 0) {
+		struct ckrm_mem_res *parcls = ckrm_get_res_class(cls->parent,
+				mem_rcbs.resid, struct ckrm_mem_res);
+		if (parcls) {
+			decr_use_count(parcls, 1, zindex);
+			cls->pg_borrowed[zindex]--;
+			return;
+		}
+	}
+	atomic_dec(&ckrm_mem_real_count);
+}
+
+int
+ckrm_class_limit_ok(struct ckrm_mem_res *cls)
+{
+	return 1; /* stub for now */
+}
+
+static void migrate_list(struct list_head *list,
+	struct ckrm_mem_res* from, struct ckrm_mem_res* to)
+{
+	struct page *page;
+	struct list_head *pos, *next;
+
+	pos = list->next;
+	while (pos != list) {
+		next = pos->next;
+		page = list_entry(pos, struct page, lru);
+		if (page->ckrm_class == from) 
+			ckrm_change_page_class(page, to);
+		pos = next;
+	}
+}
+
+void
+ckrm_mem_migrate_all_pages(struct ckrm_mem_res* from, struct ckrm_mem_res* to)
+{
+	struct zone *zone;
+
+	for_each_zone(zone) {
+		spin_lock_irq(&zone->lru_lock);
+		migrate_list(&zone->inactive_list, from, to);
+		migrate_list(&zone->active_list, from, to);
+		spin_unlock_irq(&zone->lru_lock);
+	}
+	return;
+}
+
+static inline int
+class_migrate_pmd(struct mm_struct* mm, struct vm_area_struct* vma,
+		pmd_t* pmdir, unsigned long address, unsigned long end)
+{
+	pte_t *pte;
+	unsigned long pmd_end;
+
+	if (pmd_none(*pmdir))
+		return 0;
+	BUG_ON(pmd_bad(*pmdir));
+
+	pmd_end = (address+ PMD_SIZE) & PMD_MASK;
+	if (end > pmd_end)
+		end = pmd_end;
+
+	do {
+		pte = pte_offset_map(pmdir, address);
+		if (pte_present(*pte)) {
+			struct page *page = pte_page(*pte);
+			if (page->mapping)
+				ckrm_change_page_class(page, mm->memclass);
+		}
+		address += PAGE_SIZE;
+		pte_unmap(pte);
+		pte++;
+	} while(address && (address < end));
+	return 0;
+}
+
+static inline int
+class_migrate_pgd(struct mm_struct* mm, struct vm_area_struct* vma,
+		pgd_t* pgdir, unsigned long address, unsigned long end)
+{
+	pmd_t* pmd;
+	pud_t* pud;
+	unsigned long pgd_end;
+
+	if (pgd_none(*pgdir))
+		return 0;
+	BUG_ON(pgd_bad(*pgdir));
+
+	pud = pud_offset(pgdir, address);
+	pmd = pmd_offset(pud, address);
+	pgd_end = (address + PGDIR_SIZE) & PGDIR_MASK;
+
+	if (pgd_end && (end > pgd_end))
+		end = pgd_end;
+
+	do {
+		class_migrate_pmd(mm, vma, pmd, address, end);
+		address = (address + PMD_SIZE) & PMD_MASK;
+		pmd++;
+	} while (address && (address < end));
+	return 0;
+}
+
+static inline int
+class_migrate_vma(struct mm_struct* mm, struct vm_area_struct* vma)
+{
+	pgd_t* pgdir;
+	unsigned long address, end;
+
+	address = vma->vm_start;
+	end = vma->vm_end;
+
+	pgdir = pgd_offset(vma->vm_mm, address);
+	do {
+		class_migrate_pgd(mm, vma, pgdir, address, end);
+		address = (address + PGDIR_SIZE) & PGDIR_MASK;
+		pgdir++;
+	} while(address && (address < end));
+	return 0;
+}
+
+/* this function is called with mm->peertask_lock hold */
+void
+ckrm_mem_migrate_mm(struct mm_struct* mm, struct ckrm_mem_res *def)
+{
+	struct vm_area_struct *vma;
+
+	/* We leave the mm->memclass untouched since we believe that one
+	 * mm with no task associated will be deleted soon or attach
+	 * with another task later.
+	 */
+	if (list_empty(&mm->tasklist))
+		return;
+
+	if (mm->memclass)
+		kref_put(&mm->memclass->nr_users, memclass_release);
+	mm->memclass = def ?: ckrm_mem_root_class;
+	kref_get(&mm->memclass->nr_users);
+
+	/* Go through all VMA to migrate pages */
+	down_read(&mm->mmap_sem);
+	vma = mm->mmap;
+	while(vma) {
+		class_migrate_vma(mm, vma);
+		vma = vma->vm_next;
+	}
+	up_read(&mm->mmap_sem);
+	return;
+}

--i0/AhcQY5QxfSsSZ--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
