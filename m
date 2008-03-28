Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2S8T28s006125
	for <linux-mm@kvack.org>; Fri, 28 Mar 2008 04:29:02 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2S8QxVZ1089864
	for <linux-mm@kvack.org>; Fri, 28 Mar 2008 04:26:59 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2S8QwZl016359
	for <linux-mm@kvack.org>; Fri, 28 Mar 2008 04:26:59 -0400
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Fri, 28 Mar 2008 13:53:16 +0530
Message-Id: <20080328082316.6961.29044.sendpatchset@localhost.localdomain>
Subject: [-mm] Add an owner to the mm_struct (v2)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>
Cc: Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


This patch removes the mem_cgroup member from mm_struct and instead adds
an owner. This approach was suggested by Paul Menage. The advantage of
this approach is that, once the mm->owner is known, using the subsystem
id, the cgroup can be determined. It also allows several control groups
that are virtually grouped by mm_struct, to exist independent of the memory
controller i.e., without adding mem_cgroup's for each controller,
to mm_struct.

The code initially assigns mm->owner to the task and then after the
thread group leader is identified. The mm->owner is changed to the thread
group leader of the task later at the end of copy_process.

A new config option CONFIG_MM_OWNER is added and the memory resource
controller now depends on this config option.

NOTE: This patch was developed on top of 2.6.25-rc5-mm1 and is applied on top
of the memory-controller-move-to-own-slab patch (which is already present
in the Andrew's patchset).

These patches have been tested on a powerpc 64 bit box and on x86_64 box with
several microbenchmarks and some simple memory controller testing.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 include/linux/memcontrol.h |   14 ++++++++-
 include/linux/mm_types.h   |    6 ++--
 include/linux/sched.h      |   19 ++++++++++++
 init/Kconfig               |   13 ++++++++
 kernel/exit.c              |   66 +++++++++++++++++++++++++++++++++++++++++++++
 kernel/fork.c              |   26 +++++++++++++++++
 mm/memcontrol.c            |   19 +++++++-----
 7 files changed, 151 insertions(+), 12 deletions(-)

diff -puN include/linux/mm_types.h~memory-controller-add-mm-owner include/linux/mm_types.h
--- linux-2.6.25-rc5/include/linux/mm_types.h~memory-controller-add-mm-owner	2008-03-28 09:30:47.000000000 +0530
+++ linux-2.6.25-rc5-balbir/include/linux/mm_types.h	2008-03-28 12:26:59.000000000 +0530
@@ -227,8 +227,10 @@ struct mm_struct {
 	/* aio bits */
 	rwlock_t		ioctx_list_lock;
 	struct kioctx		*ioctx_list;
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR
-	struct mem_cgroup *mem_cgroup;
+#ifdef CONFIG_MM_OWNER
+	spinlock_t owner_lock;
+	struct task_struct *owner;	/* The thread group leader that */
+					/* owns the mm_struct.		*/
 #endif
 
 #ifdef CONFIG_PROC_FS
diff -puN kernel/fork.c~memory-controller-add-mm-owner kernel/fork.c
--- linux-2.6.25-rc5/kernel/fork.c~memory-controller-add-mm-owner	2008-03-28 09:30:47.000000000 +0530
+++ linux-2.6.25-rc5-balbir/kernel/fork.c	2008-03-28 12:33:12.000000000 +0530
@@ -359,6 +359,7 @@ static struct mm_struct * mm_init(struct
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	mm->cached_hole_size = ~0UL;
 	mm_init_cgroup(mm, p);
+	mm_init_owner(mm, p);
 
 	if (likely(!mm_alloc_pgd(mm))) {
 		mm->def_flags = 0;
@@ -995,6 +996,27 @@ static void rt_mutex_init_task(struct ta
 #endif
 }
 
+#ifdef CONFIG_MM_OWNER
+void mm_init_owner(struct mm_struct *mm, struct task_struct *p)
+{
+	spin_lock_init(&mm->owner_lock);
+	mm->owner = p;
+}
+
+void mm_fork_init_owner(struct task_struct *p)
+{
+	struct mm_struct *mm = get_task_mm(p);
+	if (!mm)
+		return;
+
+	spin_lock(&mm->owner);
+	if (mm->owner != p)
+		rcu_assign_pointer(mm->owner, p->group_leader);
+	spin_unlock(&mm->owner);
+	mmput(mm);
+}
+#endif /* CONFIG_MM_OWNER */
+
 /*
  * This creates a new process as a copy of the old one,
  * but does not actually start it yet.
@@ -1357,6 +1379,10 @@ static struct task_struct *copy_process(
 	write_unlock_irq(&tasklist_lock);
 	proc_fork_connector(p);
 	cgroup_post_fork(p);
+
+	if (!(clone_flags & CLONE_VM) && (p != p->group_leader))
+		mm_fork_init_owner(p);
+
 	return p;
 
 bad_fork_free_pid:
diff -puN include/linux/memcontrol.h~memory-controller-add-mm-owner include/linux/memcontrol.h
--- linux-2.6.25-rc5/include/linux/memcontrol.h~memory-controller-add-mm-owner	2008-03-28 09:30:47.000000000 +0530
+++ linux-2.6.25-rc5-balbir/include/linux/memcontrol.h	2008-03-28 09:30:47.000000000 +0530
@@ -29,6 +29,7 @@ struct mm_struct;
 
 extern void mm_init_cgroup(struct mm_struct *mm, struct task_struct *p);
 extern void mm_free_cgroup(struct mm_struct *mm);
+extern void mem_cgroup_fork_init(struct task_struct *p);
 
 #define page_reset_bad_cgroup(page)	((page)->page_cgroup = 0)
 
@@ -49,7 +50,7 @@ extern void mem_cgroup_out_of_memory(str
 int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
 
 #define mm_match_cgroup(mm, cgroup)	\
-	((cgroup) == rcu_dereference((mm)->mem_cgroup))
+	((cgroup) == mem_cgroup_from_task((mm)->owner))
 
 extern int mem_cgroup_prepare_migration(struct page *page);
 extern void mem_cgroup_end_migration(struct page *page);
@@ -72,6 +73,8 @@ extern long mem_cgroup_calc_reclaim_acti
 extern long mem_cgroup_calc_reclaim_inactive(struct mem_cgroup *mem,
 				struct zone *zone, int priority);
 
+extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
+
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 static inline void mm_init_cgroup(struct mm_struct *mm,
 					struct task_struct *p)
@@ -82,6 +85,10 @@ static inline void mm_free_cgroup(struct
 {
 }
 
+static inline void mem_cgroup_fork_init(struct task_struct *p)
+{
+}
+
 static inline void page_reset_bad_cgroup(struct page *page)
 {
 }
@@ -172,6 +179,11 @@ static inline long mem_cgroup_calc_recla
 {
 	return 0;
 }
+
+static void mm_free_fork_cgroup(struct task_struct *p)
+{
+}
+
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */
diff -puN mm/memcontrol.c~memory-controller-add-mm-owner mm/memcontrol.c
--- linux-2.6.25-rc5/mm/memcontrol.c~memory-controller-add-mm-owner	2008-03-28 09:30:47.000000000 +0530
+++ linux-2.6.25-rc5-balbir/mm/memcontrol.c	2008-03-28 10:15:32.000000000 +0530
@@ -238,7 +238,7 @@ static struct mem_cgroup *mem_cgroup_fro
 				css);
 }
 
-static struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
+struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
 {
 	return container_of(task_subsys_state(p, mem_cgroup_subsys_id),
 				struct mem_cgroup, css);
@@ -250,12 +250,17 @@ void mm_init_cgroup(struct mm_struct *mm
 
 	mem = mem_cgroup_from_task(p);
 	css_get(&mem->css);
-	mm->mem_cgroup = mem;
 }
 
 void mm_free_cgroup(struct mm_struct *mm)
 {
-	css_put(&mm->mem_cgroup->css);
+	struct mem_cgroup *mem;
+
+	/*
+	 * TODO: Should we assign mm->owner to NULL here?
+	 */
+	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
+	css_put(&mem->css);
 }
 
 static inline int page_cgroup_locked(struct page *page)
@@ -478,6 +483,7 @@ unsigned long mem_cgroup_isolate_pages(u
 	int zid = zone_idx(z);
 	struct mem_cgroup_per_zone *mz;
 
+	BUG_ON(!mem_cont);
 	mz = mem_cgroup_zoneinfo(mem_cont, nid, zid);
 	if (active)
 		src = &mz->active_list;
@@ -575,13 +581,11 @@ retry:
 	if (!mm)
 		mm = &init_mm;
 
-	rcu_read_lock();
-	mem = rcu_dereference(mm->mem_cgroup);
+	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
 	/*
 	 * For every charge from the cgroup, increment reference count
 	 */
 	css_get(&mem->css);
-	rcu_read_unlock();
 
 	while (res_counter_charge(&mem->res, PAGE_SIZE)) {
 		if (!(gfp_mask & __GFP_WAIT))
@@ -990,8 +994,8 @@ mem_cgroup_create(struct cgroup_subsys *
 
 	if (unlikely((cont->parent) == NULL)) {
 		mem = &init_mem_cgroup;
-		init_mm.mem_cgroup = mem;
 		page_cgroup_cache = KMEM_CACHE(page_cgroup, SLAB_PANIC);
+		init_mm.owner = &init_task;
 	} else
 		mem = kzalloc(sizeof(struct mem_cgroup), GFP_KERNEL);
 
@@ -1072,7 +1076,6 @@ static void mem_cgroup_move_task(struct 
 		goto out;
 
 	css_get(&mem->css);
-	rcu_assign_pointer(mm->mem_cgroup, mem);
 	css_put(&old_mem->css);
 
 out:
diff -puN include/linux/sched.h~memory-controller-add-mm-owner include/linux/sched.h
--- linux-2.6.25-rc5/include/linux/sched.h~memory-controller-add-mm-owner	2008-03-28 09:30:47.000000000 +0530
+++ linux-2.6.25-rc5-balbir/include/linux/sched.h	2008-03-28 10:50:14.000000000 +0530
@@ -2130,6 +2130,25 @@ static inline void migration_init(void)
 
 #define TASK_STATE_TO_CHAR_STR "RSDTtZX"
 
+#ifdef CONFIG_MM_OWNER
+extern void mm_update_next_owner(struct mm_struct *mm, struct task_struct *p);
+extern void mm_fork_init_owner(struct task_struct *p);
+extern void mm_init_owner(struct mm_struct *mm, struct task_struct *p);
+#else
+static inline void
+mm_update_next_owner(struct mm_struct *mm, struct task_struct *p)
+{
+}
+
+static inline void mm_fork_init_owner(struct task_struct *p)
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
+++ linux-2.6.25-rc5-balbir/kernel/exit.c	2008-03-28 12:35:39.000000000 +0530
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
+	rcu_read_lock();
+	ret = (mm && (rcu_dereference(mm->owner) == p) &&
+		(atomic_read(&mm->mm_users) > 1));
+	rcu_read_unlock();
+	return ret;
+}
+
+void mm_update_next_owner(struct mm_struct *mm, struct task_struct *p)
+{
+	struct task_struct *c, *g;
+
+	/*
+	 * This should not be called for init_task
+	 */
+	BUG_ON(p == p->parent);
+
+	if (!mm_need_new_owner(mm, p))
+		return;
+
+	/*
+	 * Search in the children
+	 */
+	list_for_each_entry(c, &p->children, sibling) {
+		if (c->mm == p->mm)
+			goto assign_new_owner;
+	}
+
+	/*
+	 * Search in the siblings
+	 */
+	list_for_each_entry(c, &p->parent->children, sibling) {
+		if (c->mm == p->mm)
+			goto assign_new_owner;
+	}
+
+	/*
+	 * Search through everything else. We should not get
+	 * here often
+	 */
+	for_each_process(c) {
+		g = c;
+		do {
+			if (c->mm && (c->mm == p->mm))
+					goto assign_new_owner;
+		} while ((c = next_thread(c)) != g);
+	}
+
+	BUG();
+
+assign_new_owner:
+	spin_lock(&mm->owner_lock);
+	rcu_assign_pointer(mm->owner, c);
+	spin_unlock(&mm->owner_lock);
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
+	mm_update_next_owner(mm, current);
 	mmput(mm);
 }
 
diff -puN init/Kconfig~memory-controller-add-mm-owner init/Kconfig
--- linux-2.6.25-rc5/init/Kconfig~memory-controller-add-mm-owner	2008-03-28 09:30:47.000000000 +0530
+++ linux-2.6.25-rc5-balbir/init/Kconfig	2008-03-28 10:08:07.000000000 +0530
@@ -364,9 +364,20 @@ config RESOURCE_COUNTERS
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
-	depends on CGROUPS && RESOURCE_COUNTERS
+	depends on CGROUPS && RESOURCE_COUNTERS && MM_OWNER
 	help
 	  Provides a memory resource controller that manages both page cache and
 	  RSS memory.
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
