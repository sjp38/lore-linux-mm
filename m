Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m31CltFr023977
	for <linux-mm@kvack.org>; Tue, 1 Apr 2008 08:47:55 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m31CltIJ178196
	for <linux-mm@kvack.org>; Tue, 1 Apr 2008 06:47:55 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m31ClsGe020843
	for <linux-mm@kvack.org>; Tue, 1 Apr 2008 06:47:55 -0600
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Tue, 01 Apr 2008 18:13:12 +0530
Message-Id: <20080401124312.23664.64616.sendpatchset@localhost.localdomain>
Subject: [RFC][-mm] Add an owner to the mm_struct (v4)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>
Cc: Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


Changelog v3
------------

1. Add mm->owner change callbacks using cgroups

This patch removes the mem_cgroup member from mm_struct and instead adds
an owner. This approach was suggested by Paul Menage. The advantage of
this approach is that, once the mm->owner is known, using the subsystem
id, the cgroup can be determined. It also allows several control groups
that are virtually grouped by mm_struct, to exist independent of the memory
controller i.e., without adding mem_cgroup's for each controller,
to mm_struct.

A new config option CONFIG_MM_OWNER is added and the memory resource
controller selects this config option.

NOTE: This patch was developed on top of 2.6.25-rc5-mm1 and is applied on top
of the memory-controller-move-to-own-slab patch (which is already present
in the Andrew's patchset).

This patch also adds cgroup callbacks to notify subsystems when mm->owner
changes. The mm_cgroup_changed callback is called with the task_lock()
of the new task held and is called just prior to changing the mm->owner.

I am indebted to Paul Menage for the several reviews of this patchset
and helping me make it lighter and simpler.

This patch was tested on a powerpc box.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 fs/exec.c                  |    1 
 include/linux/cgroup.h     |   15 ++++++++++
 include/linux/init_task.h  |    2 -
 include/linux/memcontrol.h |   17 ++---------
 include/linux/mm_types.h   |    5 ++-
 include/linux/sched.h      |   14 +++++++++
 init/Kconfig               |   15 ++++++++++
 kernel/cgroup.c            |   24 ++++++++++++++++
 kernel/exit.c              |   66 +++++++++++++++++++++++++++++++++++++++++++++
 kernel/fork.c              |   11 +++++--
 mm/memcontrol.c            |   21 ++------------
 11 files changed, 154 insertions(+), 37 deletions(-)

diff -puN include/linux/mm_types.h~memory-controller-add-mm-owner include/linux/mm_types.h
--- linux-2.6.25-rc5/include/linux/mm_types.h~memory-controller-add-mm-owner	2008-03-28 09:30:47.000000000 +0530
+++ linux-2.6.25-rc5-balbir/include/linux/mm_types.h	2008-03-31 14:53:04.000000000 +0530
@@ -227,8 +227,9 @@ struct mm_struct {
 	/* aio bits */
 	rwlock_t		ioctx_list_lock;
 	struct kioctx		*ioctx_list;
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR
-	struct mem_cgroup *mem_cgroup;
+#ifdef CONFIG_MM_OWNER
+	struct task_struct *owner;	/* The thread group leader that */
+					/* owns the mm_struct.		*/
 #endif
 
 #ifdef CONFIG_PROC_FS
diff -puN kernel/fork.c~memory-controller-add-mm-owner kernel/fork.c
--- linux-2.6.25-rc5/kernel/fork.c~memory-controller-add-mm-owner	2008-03-28 09:30:47.000000000 +0530
+++ linux-2.6.25-rc5-balbir/kernel/fork.c	2008-04-01 10:26:42.000000000 +0530
@@ -358,14 +358,13 @@ static struct mm_struct * mm_init(struct
 	mm->ioctx_list = NULL;
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	mm->cached_hole_size = ~0UL;
-	mm_init_cgroup(mm, p);
+	mm_init_owner(mm, p);
 
 	if (likely(!mm_alloc_pgd(mm))) {
 		mm->def_flags = 0;
 		return mm;
 	}
 
-	mm_free_cgroup(mm);
 	free_mm(mm);
 	return NULL;
 }
@@ -394,7 +393,6 @@ void __mmdrop(struct mm_struct *mm)
 {
 	BUG_ON(mm == &init_mm);
 	mm_free_pgd(mm);
-	mm_free_cgroup(mm);
 	destroy_context(mm);
 	free_mm(mm);
 }
@@ -995,6 +993,13 @@ static void rt_mutex_init_task(struct ta
 #endif
 }
 
+#ifdef CONFIG_MM_OWNER
+void mm_init_owner(struct mm_struct *mm, struct task_struct *p)
+{
+	mm->owner = p;
+}
+#endif /* CONFIG_MM_OWNER */
+
 /*
  * This creates a new process as a copy of the old one,
  * but does not actually start it yet.
diff -puN include/linux/memcontrol.h~memory-controller-add-mm-owner include/linux/memcontrol.h
--- linux-2.6.25-rc5/include/linux/memcontrol.h~memory-controller-add-mm-owner	2008-03-28 09:30:47.000000000 +0530
+++ linux-2.6.25-rc5-balbir/include/linux/memcontrol.h	2008-04-01 10:27:02.000000000 +0530
@@ -27,9 +27,6 @@ struct mm_struct;
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 
-extern void mm_init_cgroup(struct mm_struct *mm, struct task_struct *p);
-extern void mm_free_cgroup(struct mm_struct *mm);
-
 #define page_reset_bad_cgroup(page)	((page)->page_cgroup = 0)
 
 extern struct page_cgroup *page_get_page_cgroup(struct page *page);
@@ -48,8 +45,10 @@ extern unsigned long mem_cgroup_isolate_
 extern void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask);
 int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
 
+extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
+
 #define mm_match_cgroup(mm, cgroup)	\
-	((cgroup) == rcu_dereference((mm)->mem_cgroup))
+	((cgroup) == mem_cgroup_from_task((mm)->owner))
 
 extern int mem_cgroup_prepare_migration(struct page *page);
 extern void mem_cgroup_end_migration(struct page *page);
@@ -73,15 +72,6 @@ extern long mem_cgroup_calc_reclaim_inac
 				struct zone *zone, int priority);
 
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
-static inline void mm_init_cgroup(struct mm_struct *mm,
-					struct task_struct *p)
-{
-}
-
-static inline void mm_free_cgroup(struct mm_struct *mm)
-{
-}
-
 static inline void page_reset_bad_cgroup(struct page *page)
 {
 }
@@ -172,6 +162,7 @@ static inline long mem_cgroup_calc_recla
 {
 	return 0;
 }
+
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */
diff -puN mm/memcontrol.c~memory-controller-add-mm-owner mm/memcontrol.c
--- linux-2.6.25-rc5/mm/memcontrol.c~memory-controller-add-mm-owner	2008-03-28 09:30:47.000000000 +0530
+++ linux-2.6.25-rc5-balbir/mm/memcontrol.c	2008-03-28 18:55:33.000000000 +0530
@@ -238,26 +238,12 @@ static struct mem_cgroup *mem_cgroup_fro
 				css);
 }
 
-static struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
+struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
 {
 	return container_of(task_subsys_state(p, mem_cgroup_subsys_id),
 				struct mem_cgroup, css);
 }
 
-void mm_init_cgroup(struct mm_struct *mm, struct task_struct *p)
-{
-	struct mem_cgroup *mem;
-
-	mem = mem_cgroup_from_task(p);
-	css_get(&mem->css);
-	mm->mem_cgroup = mem;
-}
-
-void mm_free_cgroup(struct mm_struct *mm)
-{
-	css_put(&mm->mem_cgroup->css);
-}
-
 static inline int page_cgroup_locked(struct page *page)
 {
 	return bit_spin_is_locked(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
@@ -478,6 +464,7 @@ unsigned long mem_cgroup_isolate_pages(u
 	int zid = zone_idx(z);
 	struct mem_cgroup_per_zone *mz;
 
+	BUG_ON(!mem_cont);
 	mz = mem_cgroup_zoneinfo(mem_cont, nid, zid);
 	if (active)
 		src = &mz->active_list;
@@ -576,7 +563,7 @@ retry:
 		mm = &init_mm;
 
 	rcu_read_lock();
-	mem = rcu_dereference(mm->mem_cgroup);
+	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
 	/*
 	 * For every charge from the cgroup, increment reference count
 	 */
@@ -990,7 +977,6 @@ mem_cgroup_create(struct cgroup_subsys *
 
 	if (unlikely((cont->parent) == NULL)) {
 		mem = &init_mem_cgroup;
-		init_mm.mem_cgroup = mem;
 		page_cgroup_cache = KMEM_CACHE(page_cgroup, SLAB_PANIC);
 	} else
 		mem = kzalloc(sizeof(struct mem_cgroup), GFP_KERNEL);
@@ -1072,7 +1058,6 @@ static void mem_cgroup_move_task(struct 
 		goto out;
 
 	css_get(&mem->css);
-	rcu_assign_pointer(mm->mem_cgroup, mem);
 	css_put(&old_mem->css);
 
 out:
diff -puN include/linux/sched.h~memory-controller-add-mm-owner include/linux/sched.h
--- linux-2.6.25-rc5/include/linux/sched.h~memory-controller-add-mm-owner	2008-03-28 09:30:47.000000000 +0530
+++ linux-2.6.25-rc5-balbir/include/linux/sched.h	2008-04-01 12:58:24.000000000 +0530
@@ -2130,6 +2130,20 @@ static inline void migration_init(void)
 
 #define TASK_STATE_TO_CHAR_STR "RSDTtZX"
 
+#ifdef CONFIG_MM_OWNER
+extern void mm_update_next_owner(struct mm_struct *mm);
+extern void mm_init_owner(struct mm_struct *mm, struct task_struct *p);
+#else
+static inline void
+mm_update_next_owner(struct mm_struct *mm, struct task_struct *p)
+{
+}
+
+static inline void mm_init_owner(struct mm_struct *mm, struct task_struct *p)
+{
+}
+#endif /* CONFIG_MM_OWNER */
+
 #endif /* __KERNEL__ */
 
 #endif
diff -puN kernel/exit.c~memory-controller-add-mm-owner kernel/exit.c
--- linux-2.6.25-rc5/kernel/exit.c~memory-controller-add-mm-owner	2008-03-28 09:30:47.000000000 +0530
+++ linux-2.6.25-rc5-balbir/kernel/exit.c	2008-04-01 18:05:02.000000000 +0530
@@ -579,6 +579,71 @@ void exit_fs(struct task_struct *tsk)
 
 EXPORT_SYMBOL_GPL(exit_fs);
 
+#ifdef CONFIG_MM_OWNER
+/*
+ * Task p is exiting and it owned p, so lets find a new owner for it
+ */
+static inline int
+mm_need_new_owner(struct mm_struct *mm, struct task_struct *p)
+{
+	int ret;
+
+	ret = (mm && (atomic_read(&mm->mm_users) > 1) && (mm->owner == p) &&
+		!delay_group_leader(p));
+	return ret;
+}
+
+void mm_update_next_owner(struct mm_struct *mm)
+{
+	struct task_struct *c, *g, *p = current;
+
+retry:
+	if (!mm_need_new_owner(mm, p))
+		return;
+
+	rcu_read_lock();
+	/*
+	 * Search in the children
+	 */
+	list_for_each_entry(c, &p->children, sibling) {
+		if (c->mm == mm)
+			goto assign_new_owner;
+	}
+
+	/*
+	 * Search in the siblings
+	 */
+	list_for_each_entry(c, &p->parent->children, sibling) {
+		if (c->mm == mm)
+			goto assign_new_owner;
+	}
+
+	/*
+	 * Search through everything else. We should not get
+	 * here often
+	 */
+	do_each_thread(g, c) {
+		if (c->mm == mm)
+			goto assign_new_owner;
+	} while_each_thread(g, c);
+
+	rcu_read_unlock();
+	return;
+
+assign_new_owner:
+	rcu_read_unlock();
+	BUG_ON(c == p);
+	task_lock(c);
+	if (c->mm != mm) {
+		task_unlock(c);
+		goto retry;
+	}
+	cgroup_mm_owner_callbacks(mm->owner, c);
+	mm->owner = c;
+	task_unlock(c);
+}
+#endif /* CONFIG_MM_OWNER */
+
 /*
  * Turn us into a lazy TLB process if we
  * aren't already..
@@ -618,6 +683,7 @@ static void exit_mm(struct task_struct *
 	/* We don't want this task to be frozen prematurely */
 	clear_freeze_flag(tsk);
 	task_unlock(tsk);
+	mm_update_next_owner(mm);
 	mmput(mm);
 }
 
diff -puN init/Kconfig~memory-controller-add-mm-owner init/Kconfig
--- linux-2.6.25-rc5/init/Kconfig~memory-controller-add-mm-owner	2008-03-28 09:30:47.000000000 +0530
+++ linux-2.6.25-rc5-balbir/init/Kconfig	2008-04-01 08:58:57.000000000 +0530
@@ -364,9 +364,21 @@ config RESOURCE_COUNTERS
           infrastructure that works with cgroups
 	depends on CGROUPS
 
+config MM_OWNER
+	bool "Enable ownership of mm structure"
+	help
+	  This option enables mm_struct's to have an owner. The advantage
+	  of this approach is that it allows for several independent memory
+	  based cgorup controllers to co-exist independently without too
+	  much space overhead
+
+	  This feature adds fork/exit overhead. So enable this only if
+	  you need resource controllers
+
 config CGROUP_MEM_RES_CTLR
 	bool "Memory Resource Controller for Control Groups"
 	depends on CGROUPS && RESOURCE_COUNTERS
+	select MM_OWNER
 	help
 	  Provides a memory resource controller that manages both page cache and
 	  RSS memory.
@@ -379,6 +391,9 @@ config CGROUP_MEM_RES_CTLR
 	  Only enable when you're ok with these trade offs and really
 	  sure you need the memory resource controller.
 
+	  This config option also selects MM_OWNER config option, which
+	  could in turn add some fork/exit overhead.
+
 config SYSFS_DEPRECATED
 	bool
 
diff -puN include/linux/init_task.h~memory-controller-add-mm-owner include/linux/init_task.h
--- linux-2.6.25-rc5/include/linux/init_task.h~memory-controller-add-mm-owner	2008-03-28 18:14:36.000000000 +0530
+++ linux-2.6.25-rc5-balbir/include/linux/init_task.h	2008-03-31 23:29:33.000000000 +0530
@@ -57,6 +57,7 @@
 	.page_table_lock =  __SPIN_LOCK_UNLOCKED(name.page_table_lock),	\
 	.mmlist		= LIST_HEAD_INIT(name.mmlist),		\
 	.cpu_vm_mask	= CPU_MASK_ALL,				\
+	.owner		= &init_task,				\
 }
 
 #define INIT_SIGNALS(sig) {						\
@@ -199,7 +200,6 @@ extern struct group_info init_groups;
 	INIT_LOCKDEP							\
 }
 
-
 #define INIT_CPU_TIMERS(cpu_timers)					\
 {									\
 	LIST_HEAD_INIT(cpu_timers[0]),					\
diff -puN fs/exec.c~memory-controller-add-mm-owner fs/exec.c
--- linux-2.6.25-rc5/fs/exec.c~memory-controller-add-mm-owner	2008-03-28 20:38:20.000000000 +0530
+++ linux-2.6.25-rc5-balbir/fs/exec.c	2008-03-29 11:34:02.000000000 +0530
@@ -735,6 +735,7 @@ static int exec_mmap(struct mm_struct *m
 	tsk->active_mm = mm;
 	activate_mm(active_mm, mm);
 	task_unlock(tsk);
+	mm_update_next_owner(mm);
 	arch_pick_mmap_layout(mm);
 	if (old_mm) {
 		up_read(&old_mm->mmap_sem);
diff -puN kernel/cgroup.c~memory-controller-add-mm-owner kernel/cgroup.c
--- linux-2.6.25-rc5/kernel/cgroup.c~memory-controller-add-mm-owner	2008-04-01 13:08:41.000000000 +0530
+++ linux-2.6.25-rc5-balbir/kernel/cgroup.c	2008-04-01 15:51:05.000000000 +0530
@@ -118,6 +118,7 @@ static int root_count;
  * be called.
  */
 static int need_forkexit_callback;
+static int need_mm_owner_callback;
 
 /* convenient tests for these bits */
 inline int cgroup_is_removed(const struct cgroup *cgrp)
@@ -2481,6 +2482,7 @@ static void __init cgroup_init_subsys(st
 	}
 
 	need_forkexit_callback |= ss->fork || ss->exit;
+	need_mm_owner_callback |= !!ss->mm_owner_changed;
 
 	ss->active = 1;
 }
@@ -2717,6 +2719,28 @@ void cgroup_fork_callbacks(struct task_s
 	}
 }
 
+#ifdef CONFIG_MM_OWNER
+/**
+ * cgroup_mm_owner_callbacks - run callbacks when the mm->owner changes
+ * @p: the new owner
+ *
+ * Called on every change to mm->owner. mm_init_owner() does not
+ * invoke this routine, since it assigns the mm->owner the first time
+ * and does not change it.
+ */
+void cgroup_mm_owner_callbacks(struct task_struct *old, struct task_struct *new)
+{
+	if (need_mm_owner_callback) {
+		int i;
+		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
+			struct cgroup_subsys *ss = subsys[i];
+			if (ss->mm_owner_changed)
+				ss->mm_owner_changed(ss, old, new);
+		}
+	}
+}
+#endif /* CONFIG_MM_OWNER */
+
 /**
  * cgroup_post_fork - called on a new task after adding it to the task list
  * @child: the task in question
diff -puN include/linux/cgroup.h~memory-controller-add-mm-owner include/linux/cgroup.h
--- linux-2.6.25-rc5/include/linux/cgroup.h~memory-controller-add-mm-owner	2008-04-01 13:08:45.000000000 +0530
+++ linux-2.6.25-rc5-balbir/include/linux/cgroup.h	2008-04-01 15:40:17.000000000 +0530
@@ -292,6 +292,12 @@ struct cgroup_subsys {
 			struct cgroup *cgrp);
 	void (*post_clone)(struct cgroup_subsys *ss, struct cgroup *cgrp);
 	void (*bind)(struct cgroup_subsys *ss, struct cgroup *root);
+	/*
+	 * This routine is called with the task_lock of mm->owner held
+	 */
+	void (*mm_owner_changed)(struct cgroup_subsys *ss,
+					struct task_struct *old,
+					struct task_struct *new);
 	int subsys_id;
 	int active;
 	int disabled;
@@ -377,4 +383,13 @@ static inline int cgroupstats_build(stru
 
 #endif /* !CONFIG_CGROUPS */
 
+#ifdef CONFIG_MM_OWNER
+extern void
+cgroup_mm_owner_callbacks(struct task_struct *old, struct task_struct *new);
+#else /* !CONFIG_MM_OWNER */
+static inline void
+cgroup_mm_owner_callbacks(struct task_struct *old, struct task_struct *new)
+{
+}
+#endif /* CONFIG_MM_OWNER */
 #endif /* _LINUX_CGROUP_H */
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
