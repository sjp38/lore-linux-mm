Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2OE4gdE015322
	for <linux-mm@kvack.org>; Mon, 24 Mar 2008 10:04:42 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2OE4XdL187234
	for <linux-mm@kvack.org>; Mon, 24 Mar 2008 08:04:33 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2OE4W1N014237
	for <linux-mm@kvack.org>; Mon, 24 Mar 2008 08:04:33 -0600
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Mon, 24 Mar 2008 19:31:42 +0530
Message-Id: <20080324140142.28786.97267.sendpatchset@localhost.localdomain>
Subject: [RFC][-mm] Memory controller add mm->owner
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
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

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 include/linux/memcontrol.h |   14 +++++++++++++-
 include/linux/mm_types.h   |    5 ++++-
 kernel/fork.c              |    4 ++++
 mm/memcontrol.c            |   42 ++++++++++++++++++++++++++++++++++--------
 4 files changed, 55 insertions(+), 10 deletions(-)

diff -puN include/linux/mm_types.h~memory-controller-add-mm-owner include/linux/mm_types.h
--- linux-2.6.25-rc5/include/linux/mm_types.h~memory-controller-add-mm-owner	2008-03-20 13:35:09.000000000 +0530
+++ linux-2.6.25-rc5-balbir/include/linux/mm_types.h	2008-03-20 15:11:05.000000000 +0530
@@ -228,7 +228,10 @@ struct mm_struct {
 	rwlock_t		ioctx_list_lock;
 	struct kioctx		*ioctx_list;
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
-	struct mem_cgroup *mem_cgroup;
+	struct task_struct *owner;	/* The thread group leader that */
+					/* owns the mm_struct. This     */
+					/* might be useful even outside */
+					/* of the config option         */
 #endif
 
 #ifdef CONFIG_PROC_FS
diff -puN kernel/fork.c~memory-controller-add-mm-owner kernel/fork.c
--- linux-2.6.25-rc5/kernel/fork.c~memory-controller-add-mm-owner	2008-03-20 13:35:09.000000000 +0530
+++ linux-2.6.25-rc5-balbir/kernel/fork.c	2008-03-24 18:49:29.000000000 +0530
@@ -1357,6 +1357,10 @@ static struct task_struct *copy_process(
 	write_unlock_irq(&tasklist_lock);
 	proc_fork_connector(p);
 	cgroup_post_fork(p);
+
+	if (!(clone_flags & CLONE_VM))
+		mem_cgroup_fork_init(p);
+
 	return p;
 
 bad_fork_free_pid:
diff -puN include/linux/memcontrol.h~memory-controller-add-mm-owner include/linux/memcontrol.h
--- linux-2.6.25-rc5/include/linux/memcontrol.h~memory-controller-add-mm-owner	2008-03-20 13:35:09.000000000 +0530
+++ linux-2.6.25-rc5-balbir/include/linux/memcontrol.h	2008-03-24 18:49:52.000000000 +0530
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
--- linux-2.6.25-rc5/mm/memcontrol.c~memory-controller-add-mm-owner	2008-03-20 13:35:09.000000000 +0530
+++ linux-2.6.25-rc5-balbir/mm/memcontrol.c	2008-03-24 19:04:32.000000000 +0530
@@ -236,7 +236,7 @@ static struct mem_cgroup *mem_cgroup_fro
 				css);
 }
 
-static struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
+struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
 {
 	return container_of(task_subsys_state(p, mem_cgroup_subsys_id),
 				struct mem_cgroup, css);
@@ -248,12 +248,40 @@ void mm_init_cgroup(struct mm_struct *mm
 
 	mem = mem_cgroup_from_task(p);
 	css_get(&mem->css);
-	mm->mem_cgroup = mem;
+	mm->owner = p;
+}
+
+void mem_cgroup_fork_init(struct task_struct *p)
+{
+	struct mm_struct *mm = get_task_mm(p);
+	struct mem_cgroup *mem, *oldmem;
+	if (!mm)
+		return;
+
+	/*
+	 * Initial owner at mm_init_cgroup() time is the task itself.
+	 * The thread group leader had not been setup then
+	 */
+	oldmem = mem_cgroup_from_task(mm->owner);
+	/*
+	 * Override the mm->owner after we know the thread group later
+	 */
+	mm->owner = p->group_leader;
+	mem = mem_cgroup_from_task(mm->owner);
+	css_get(&mem->css);
+	css_put(&oldmem->css);
+	mmput(mm);
 }
 
 void mm_free_cgroup(struct mm_struct *mm)
 {
-	css_put(&mm->mem_cgroup->css);
+	struct mem_cgroup *mem;
+
+	/*
+	 * TODO: Should we assign mm->owner to NULL here?
+	 */
+	mem = mem_cgroup_from_task(mm->owner);
+	css_put(&mem->css);
 }
 
 static inline int page_cgroup_locked(struct page *page)
@@ -476,6 +504,7 @@ unsigned long mem_cgroup_isolate_pages(u
 	int zid = zone_idx(z);
 	struct mem_cgroup_per_zone *mz;
 
+	BUG_ON(!mem_cont);
 	mz = mem_cgroup_zoneinfo(mem_cont, nid, zid);
 	if (active)
 		src = &mz->active_list;
@@ -573,13 +602,11 @@ retry:
 	if (!mm)
 		mm = &init_mm;
 
-	rcu_read_lock();
-	mem = rcu_dereference(mm->mem_cgroup);
+	mem = mem_cgroup_from_task(mm->owner);
 	/*
 	 * For every charge from the cgroup, increment reference count
 	 */
 	css_get(&mem->css);
-	rcu_read_unlock();
 
 	while (res_counter_charge(&mem->res, PAGE_SIZE)) {
 		if (!(gfp_mask & __GFP_WAIT))
@@ -988,7 +1015,7 @@ mem_cgroup_create(struct cgroup_subsys *
 
 	if (unlikely((cont->parent) == NULL)) {
 		mem = &init_mem_cgroup;
-		init_mm.mem_cgroup = mem;
+		init_mm.owner = &init_task;
 	} else
 		mem = kzalloc(sizeof(struct mem_cgroup), GFP_KERNEL);
 
@@ -1069,7 +1096,6 @@ static void mem_cgroup_move_task(struct 
 		goto out;
 
 	css_get(&mem->css);
-	rcu_assign_pointer(mm->mem_cgroup, mem);
 	css_put(&old_mem->css);
 
 out:
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
