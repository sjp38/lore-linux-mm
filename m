Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j4J0blLK513470
	for <linux-mm@kvack.org>; Wed, 18 May 2005 20:37:47 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4J0blrR229994
	for <linux-mm@kvack.org>; Wed, 18 May 2005 18:37:47 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j4J0bkvV005249
	for <linux-mm@kvack.org>; Wed, 18 May 2005 18:37:46 -0600
Date: Wed, 18 May 2005 17:31:33 -0700
From: Chandra Seetharaman <sekharan@us.ibm.com>
Subject: [PATCH 1/6] CKRM: Basic changes to the core kernel
Message-ID: <20050519003133.GA25221@chandralinux.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Patch 1 of 6 patches to support memory controller under CKRM framework.
This patch has the basic changes needed to get the hooks in the appropriate
kernel functions to get control in the controller.
----------------------------------------
Following changes have been made since the last release:
 - disable in NUMA and DISCONTIGMEM.
 - remove the 'in_interrupt()' part in __alloc_pages()
 - Remove the usage of PG_ckrm_account bit in the page flags.
----------------------------------------

 fs/exec.c                       |    2 +
 include/linux/ckrm_mem_inline.h |   67 ++++++++++++++++++++++++++++++++++++++++
 include/linux/mm_inline.h       |    7 ++++
 include/linux/sched.h           |    8 ++++
 init/Kconfig                    |   10 +++++
 kernel/exit.c                   |    2 +
 kernel/fork.c                   |    6 +++
 mm/page_alloc.c                 |    6 +++
 8 files changed, 108 insertions(+)

Content-Disposition: inline; filename=11-01-mem_base_changes

Index: linux-2612-rc3/fs/exec.c
===================================================================
--- linux-2612-rc3.orig/fs/exec.c
+++ linux-2612-rc3/fs/exec.c
@@ -49,6 +49,7 @@
 #include <linux/rmap.h>
 #include <linux/acct.h>
 #include <linux/ckrm_events.h>
+#include <linux/ckrm_mem_inline.h>
 
 #include <asm/uaccess.h>
 #include <asm/mmu_context.h>
@@ -574,6 +575,7 @@ static int exec_mmap(struct mm_struct *m
 	activate_mm(active_mm, mm);
 	task_unlock(tsk);
 	arch_pick_mmap_layout(mm);
+	ckrm_task_mm_change(tsk, old_mm, mm);
 	if (old_mm) {
 		up_read(&old_mm->mmap_sem);
 		if (active_mm != old_mm) BUG();
Index: linux-2612-rc3/include/linux/ckrm_mem_inline.h
===================================================================
--- /dev/null
+++ linux-2612-rc3/include/linux/ckrm_mem_inline.h
@@ -0,0 +1,67 @@
+/* include/linux/ckrm_mem_inline.h : memory control for CKRM
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
+#ifndef _LINUX_CKRM_MEM_INLINE_H_
+#define _LINUX_CKRM_MEM_INLINE_H_
+
+#ifdef CONFIG_CKRM_RES_MEM
+
+#error "Memory controller for CKRM is not available."
+
+#else
+
+static inline void
+ckrm_task_mm_init(struct task_struct *tsk)
+{
+}
+
+static inline void
+ckrm_task_mm_set(struct mm_struct * mm, struct task_struct *task)
+{
+}
+
+static inline void
+ckrm_task_mm_change(struct task_struct *tsk,
+		struct mm_struct *oldmm, struct mm_struct *newmm)
+{
+}
+
+static inline void
+ckrm_task_mm_clear(struct task_struct *tsk, struct mm_struct *mm)
+{
+}
+
+static inline void
+ckrm_mm_init(struct mm_struct *mm)
+{
+}
+
+/* using #define instead of static inline as the prototype requires   *
+ * data structures that is available only with the controller enabled */
+#define ckrm_mm_setclass(a, b) do { } while(0)
+#define ckrm_class_limit_ok(a)	(1)
+
+static inline void ckrm_mem_inc_active(struct page *p)		{}
+static inline void ckrm_mem_dec_active(struct page *p)		{}
+static inline void ckrm_mem_inc_inactive(struct page *p)	{}
+static inline void ckrm_mem_dec_inactive(struct page *p)	{}
+static inline void ckrm_page_init(struct page *p)		{}
+static inline void ckrm_clear_page_class(struct page *p)	{}
+
+#endif 
+#endif /* _LINUX_CKRM_MEM_INLINE_H_ */
Index: linux-2612-rc3/include/linux/mm_inline.h
===================================================================
--- linux-2612-rc3.orig/include/linux/mm_inline.h
+++ linux-2612-rc3/include/linux/mm_inline.h
@@ -1,9 +1,11 @@
+#include <linux/ckrm_mem_inline.h>
 
 static inline void
 add_page_to_active_list(struct zone *zone, struct page *page)
 {
 	list_add(&page->lru, &zone->active_list);
 	zone->nr_active++;
+	ckrm_mem_inc_active(page);
 }
 
 static inline void
@@ -11,6 +13,7 @@ add_page_to_inactive_list(struct zone *z
 {
 	list_add(&page->lru, &zone->inactive_list);
 	zone->nr_inactive++;
+	ckrm_mem_inc_inactive(page);
 }
 
 static inline void
@@ -18,6 +21,7 @@ del_page_from_active_list(struct zone *z
 {
 	list_del(&page->lru);
 	zone->nr_active--;
+	ckrm_mem_dec_active(page);
 }
 
 static inline void
@@ -25,6 +29,7 @@ del_page_from_inactive_list(struct zone 
 {
 	list_del(&page->lru);
 	zone->nr_inactive--;
+	ckrm_mem_dec_inactive(page);
 }
 
 static inline void
@@ -34,7 +39,9 @@ del_page_from_lru(struct zone *zone, str
 	if (PageActive(page)) {
 		ClearPageActive(page);
 		zone->nr_active--;
+		ckrm_mem_dec_active(page);
 	} else {
 		zone->nr_inactive--;
+		ckrm_mem_dec_inactive(page);
 	}
 }
Index: linux-2612-rc3/include/linux/sched.h
===================================================================
--- linux-2612-rc3.orig/include/linux/sched.h
+++ linux-2612-rc3/include/linux/sched.h
@@ -268,6 +268,11 @@ struct mm_struct {
 
 	unsigned long hiwater_rss;	/* High-water RSS usage */
 	unsigned long hiwater_vm;	/* High-water virtual memory usage */
+#ifdef CONFIG_CKRM_RES_MEM
+	struct ckrm_mem_res *memclass;
+	struct list_head tasklist;	/* tasks sharing this address space */
+	spinlock_t peertask_lock;	/* protect tasklist above */
+#endif
 };
 
 struct sighand_struct {
@@ -745,6 +750,9 @@ struct task_struct {
 	struct ckrm_task_class *taskclass;
 	struct list_head taskclass_link;
 #endif /* CONFIG_CKRM_TYPE_TASKCLASS */
+#ifdef CONFIG_CKRM_RES_MEM
+	struct list_head mm_peers; /* list of tasks using same mm_struct */
+#endif
 #endif /* CONFIG_CKRM */
 #ifdef CONFIG_DELAY_ACCT
 	struct task_delay_info delays;
Index: linux-2612-rc3/init/Kconfig
===================================================================
--- linux-2612-rc3.orig/init/Kconfig
+++ linux-2612-rc3/init/Kconfig
@@ -182,6 +182,16 @@ config CKRM_TYPE_TASKCLASS
 	
 	  Say Y if unsure
 
+config CKRM_RES_MEM
+	bool "Class based physical memory controller"
+	default y
+	depends on CKRM_TYPE_TASKCLASS
+	depends on !CONFIG_NUMA && !CONFIG_DISCONTIGMEM
+	help
+	  Provide the basic support for collecting physical memory usage
+	  information among classes. Say Y if you want to know the memory
+	  usage of each class.
+
 config CKRM_TYPE_SOCKETCLASS
 	bool "Class Manager for socket groups"
 	depends on CKRM && RCFS_FS
Index: linux-2612-rc3/kernel/exit.c
===================================================================
--- linux-2612-rc3.orig/kernel/exit.c
+++ linux-2612-rc3/kernel/exit.c
@@ -31,6 +31,7 @@
 #include <linux/cpuset.h>
 #include <linux/syscalls.h>
 #include <linux/ckrm_events.h>
+#include <linux/ckrm_mem_inline.h>
 
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
@@ -508,6 +509,7 @@ void exit_mm(struct task_struct * tsk)
 	task_lock(tsk);
 	tsk->mm = NULL;
 	up_read(&mm->mmap_sem);
+	ckrm_task_mm_clear(tsk, mm);
 	enter_lazy_tlb(mm, current);
 	task_unlock(tsk);
 	mmput(mm);
Index: linux-2612-rc3/kernel/fork.c
===================================================================
--- linux-2612-rc3.orig/kernel/fork.c
+++ linux-2612-rc3/kernel/fork.c
@@ -44,6 +44,7 @@
 #include <linux/ckrm_events.h>
 #include <linux/ckrm_tsk.h>
 #include <linux/ckrm_tc.h>
+#include <linux/ckrm_mem_inline.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -178,6 +179,7 @@ static struct task_struct *dup_task_stru
 	ti->task = tsk;
 
 	ckrm_cb_newtask(tsk);
+	ckrm_task_mm_init(tsk);
 	/* One for us, one for whoever does the "release_task()" (usually parent) */
 	atomic_set(&tsk->usage,2);
 	return tsk;
@@ -326,6 +328,7 @@ static struct mm_struct * mm_init(struct
 	mm->ioctx_list = NULL;
 	mm->default_kioctx = (struct kioctx)INIT_KIOCTX(mm->default_kioctx, *mm);
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
+	ckrm_mm_init(mm);
 
 	if (likely(!mm_alloc_pgd(mm))) {
 		mm->def_flags = 0;
@@ -346,6 +349,7 @@ struct mm_struct * mm_alloc(void)
 	if (mm) {
 		memset(mm, 0, sizeof(*mm));
 		mm = mm_init(mm);
+		ckrm_mm_setclass(mm, ckrm_get_mem_class(current));
 	}
 	return mm;
 }
@@ -502,6 +506,8 @@ static int copy_mm(unsigned long clone_f
 good_mm:
 	tsk->mm = mm;
 	tsk->active_mm = mm;
+	ckrm_mm_setclass(mm, oldmm->memclass);
+	ckrm_task_mm_set(mm, tsk);
 	return 0;
 
 free_pt:
Index: linux-2612-rc3/mm/page_alloc.c
===================================================================
--- linux-2612-rc3.orig/mm/page_alloc.c
+++ linux-2612-rc3/mm/page_alloc.c
@@ -34,6 +34,7 @@
 #include <linux/cpuset.h>
 #include <linux/nodemask.h>
 #include <linux/vmalloc.h>
+#include <linux/ckrm_mem_inline.h>
 
 #include <asm/tlbflush.h>
 #include "internal.h"
@@ -355,6 +356,7 @@ free_pages_bulk(struct zone *zone, int c
 		/* have to delete it as __free_pages_bulk list manipulates */
 		list_del(&page->lru);
 		__free_pages_bulk(page, zone, order);
+		ckrm_clear_page_class(page);
 		ret++;
 	}
 	spin_unlock_irqrestore(&zone->lock, flags);
@@ -454,6 +456,7 @@ static void prep_new_page(struct page *p
 			1 << PG_referenced | 1 << PG_arch_1 |
 			1 << PG_checked | 1 << PG_mappedtodisk);
 	page->private = 0;
+	ckrm_page_init(page);
 	set_page_refs(page, order);
 	kernel_map_pages(page, 1 << order, 1);
 }
@@ -749,6 +752,9 @@ __alloc_pages(unsigned int __nocast gfp_
 	 */
 	can_try_harder = (unlikely(rt_task(p)) && !in_interrupt()) || !wait;
 
+	if (!ckrm_class_limit_ok(ckrm_get_mem_class(p)))
+		return NULL;
+
 	zones = zonelist->zones;  /* the list of zones suitable for gfp_mask */
 
 	if (unlikely(zones[0] == NULL)) {
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
