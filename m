Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3FBD44403E0
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 04:18:51 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id f31so583178lfi.3
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 01:18:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o84sor609055lff.82.2017.11.08.01.18.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Nov 2017 01:18:49 -0800 (PST)
From: Dmitry Monakhov <dmonakhov@openvz.org>
Subject: [PATCH 2/2] mm: memcg control oom logging behavior
Date: Wed,  8 Nov 2017 09:18:43 +0000
Message-Id: <20171108091843.29349-2-dmonakhov@openvz.org>
In-Reply-To: <20171108091843.29349-1-dmonakhov@openvz.org>
References: <20171108091843.29349-1-dmonakhov@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, vdavydov.dev@gmail.com, Dmitry Monakhov <dmonakhov@openvz.org>

OOM is not uncommon in mem cgroup. Especially in case of tightly memory
bounded containers workflow (for example kubernetes jobs). This result
in massive spam in dmesg, which makes whole system less responsive.

Let's allow memcg admin to configure OOM logging behavior

Unfortunately oom_reaper worker has no access to original oom_control
context so we have somehow to pass cgroups's dump behavior to it.
Let's pass it via lower (always empty) bit in oom_reaper_list pointer

#Testcase (continuous OOMs inside container)
#docker run -m 64M lorel/docker-stress-ng stress-ng \
	           --vm 1 --vm-bytes 64M -t 60s

Signed-off-by: Dmitry Monakhov <dmonakhov@openvz.org>
---
 Documentation/cgroup-v1/memory.txt |  1 +
 include/linux/memcontrol.h         | 16 +++++++++++++
 mm/memcontrol.c                    | 27 ++++++++++++++++++++++
 mm/oom_kill.c                      | 47 +++++++++++++++++++++++++++-----------
 4 files changed, 78 insertions(+), 13 deletions(-)

diff --git a/Documentation/cgroup-v1/memory.txt b/Documentation/cgroup-v1/memory.txt
index cefb636..4759de9 100644
--- a/Documentation/cgroup-v1/memory.txt
+++ b/Documentation/cgroup-v1/memory.txt
@@ -76,6 +76,7 @@ Brief summary of control files.
 				 (See sysctl's vm.swappiness)
  memory.move_charge_at_immigrate # set/show controls of moving charges
  memory.oom_control		 # set/show oom controls.
+ memory.oom_dump		 # set/show dump log on oom
  memory.numa_stat		 # show the number of memory usage per numa node
 
  memory.kmem.limit_in_bytes      # set/show hard limit for kernel memory
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 69966c4..20c7a5a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -27,6 +27,7 @@
 #include <linux/vmpressure.h>
 #include <linux/eventfd.h>
 #include <linux/mm.h>
+#include <linux/oom.h>
 #include <linux/vmstat.h>
 #include <linux/writeback.h>
 #include <linux/page-flags.h>
@@ -198,6 +199,7 @@ struct mem_cgroup {
 	int	swappiness;
 	/* OOM-Killer disable */
 	int		oom_kill_disable;
+	int		oom_dump;
 
 	/* handle for "memory.events" */
 	struct cgroup_file events_file;
@@ -1085,6 +1087,15 @@ static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
 	} while ((memcg = parent_mem_cgroup(memcg)));
 	return false;
 }
+static inline int mem_cgroup_oom_dump(struct mem_cgroup *memcg)
+{
+	/* root ? */
+	if (mem_cgroup_disabled() || !memcg->css.parent)
+		return sysctl_oom_dump_log;
+
+	return memcg->oom_dump;
+}
+
 #else
 #define mem_cgroup_sockets_enabled 0
 static inline void mem_cgroup_sk_alloc(struct sock *sk) { };
@@ -1093,6 +1104,11 @@ static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
 {
 	return false;
 }
+static inline int mem_cgroup_oom_dump(struct mem_cgroup *memcg)
+{
+	return sysctl_oom_dump_log;
+}
+
 #endif
 
 struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 661f046..0a9f6d2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3639,6 +3639,27 @@ static int mem_cgroup_oom_control_write(struct cgroup_subsys_state *css,
 	return 0;
 }
 
+static u64 mem_cgroup_oom_dump_read(struct cgroup_subsys_state *css,
+				      struct cftype *cft)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+
+	return mem_cgroup_oom_dump(memcg);
+}
+
+static int mem_cgroup_oom_dump_write(struct cgroup_subsys_state *css,
+				       struct cftype *cft, u64 val)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+
+	if (css->parent)
+		memcg->oom_dump = (bool)val;
+	else
+		sysctl_oom_dump_log = (bool)val;
+
+	return 0;
+}
+
 #ifdef CONFIG_CGROUP_WRITEBACK
 
 struct list_head *mem_cgroup_cgwb_list(struct mem_cgroup *memcg)
@@ -4018,6 +4039,11 @@ static ssize_t memcg_write_event_control(struct kernfs_open_file *of,
 		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
 	},
 	{
+		.name = "oom_dump",
+		.read_u64 = mem_cgroup_oom_dump_read,
+		.write_u64 = mem_cgroup_oom_dump_write,
+	},
+	{
 		.name = "pressure_level",
 	},
 #ifdef CONFIG_NUMA
@@ -4277,6 +4303,7 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	if (parent) {
 		memcg->swappiness = mem_cgroup_swappiness(parent);
 		memcg->oom_kill_disable = parent->oom_kill_disable;
+		memcg->oom_dump = mem_cgroup_oom_dump(parent);
 	}
 	if (parent && parent->use_hierarchy) {
 		memcg->use_hierarchy = true;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 02c8f5d6..3e27777 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -406,6 +406,14 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 	rcu_read_unlock();
 }
 
+static int oom_dump_enabled(struct oom_control *oc)
+{
+	if (is_memcg_oom(oc) && sysctl_oom_dump_log)
+		return mem_cgroup_oom_dump(oc->memcg);
+	else
+		return sysctl_oom_dump_log;
+}
+
 static void dump_header(struct oom_control *oc, struct task_struct *p)
 {
 	pr_warn("%s invoked oom-killer: gfp_mask=%#x(%pGg), nodemask=",
@@ -467,8 +475,10 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
 static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
 static struct task_struct *oom_reaper_list;
 static DEFINE_SPINLOCK(oom_reaper_lock);
+#define OOM_REAPER_DUMP_MASK 1UL
 
-static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
+static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm,
+	bool dump_log)
 {
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
@@ -553,7 +563,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 					 NULL);
 	}
 	tlb_finish_mmu(&tlb, 0, -1);
-	if (sysctl_oom_dump_log)
+	if (dump_log)
 		pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
 			task_pid_nr(tsk), tsk->comm,
 			K(get_mm_counter(mm, MM_ANONPAGES)),
@@ -568,19 +578,20 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 }
 
 #define MAX_OOM_REAP_RETRIES 10
-static void oom_reap_task(struct task_struct *tsk)
+static void oom_reap_task(struct task_struct *tsk, bool dump_log)
 {
 	int attempts = 0;
 	struct mm_struct *mm = tsk->signal->oom_mm;
 
 	/* Retry the down_read_trylock(mmap_sem) a few times */
-	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task_mm(tsk, mm))
+	while (attempts++ < MAX_OOM_REAP_RETRIES &&
+	       !__oom_reap_task_mm(tsk, mm, dump_log))
 		schedule_timeout_idle(HZ/10);
 
 	if (attempts <= MAX_OOM_REAP_RETRIES)
 		goto done;
 
-	if (sysctl_oom_dump_log) {
+	if (dump_log) {
 		pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
 			task_pid_nr(tsk), tsk->comm);
 		debug_show_all_locks();
@@ -602,23 +613,29 @@ static int oom_reaper(void *unused)
 {
 	while (true) {
 		struct task_struct *tsk = NULL;
+		bool dump_log = 1;
 
 		wait_event_freezable(oom_reaper_wait, oom_reaper_list != NULL);
 		spin_lock(&oom_reaper_lock);
 		if (oom_reaper_list != NULL) {
-			tsk = oom_reaper_list;
+			tsk = (struct task_struct *)
+				((unsigned long) oom_reaper_list
+				 & ~OOM_REAPER_DUMP_MASK);
+			dump_log = (unsigned long)oom_reaper_list
+				& OOM_REAPER_DUMP_MASK;
+
 			oom_reaper_list = tsk->oom_reaper_list;
 		}
 		spin_unlock(&oom_reaper_lock);
 
 		if (tsk)
-			oom_reap_task(tsk);
+			oom_reap_task(tsk, dump_log);
 	}
 
 	return 0;
 }
 
-static void wake_oom_reaper(struct task_struct *tsk)
+static void wake_oom_reaper(struct task_struct *tsk, bool dump_log)
 {
 	if (!oom_reaper_th)
 		return;
@@ -632,6 +649,9 @@ static void wake_oom_reaper(struct task_struct *tsk)
 	spin_lock(&oom_reaper_lock);
 	tsk->oom_reaper_list = oom_reaper_list;
 	oom_reaper_list = tsk;
+	if (dump_log)
+		oom_reaper_list = (struct task_struct *)
+			((unsigned long)oom_reaper_list | OOM_REAPER_DUMP_MASK);
 	spin_unlock(&oom_reaper_lock);
 	trace_wake_reaper(tsk->pid);
 	wake_up(&oom_reaper_wait);
@@ -834,7 +854,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
 	bool can_oom_reap = true;
-
+	bool dump_log = oom_dump_enabled(oc);
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
 	 * its children or threads, just give it access to memory reserves
@@ -843,13 +863,13 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	task_lock(p);
 	if (task_will_free_mem(p)) {
 		mark_oom_victim(p);
-		wake_oom_reaper(p);
+		wake_oom_reaper(p, dump_log);
 		task_unlock(p);
 		put_task_struct(p);
 		return;
 	}
 	task_unlock(p);
-	if (sysctl_oom_dump_log) {
+	if (dump_log) {
 		if (__ratelimit(&oom_rs))
 			dump_header(oc, p);
 
@@ -952,7 +972,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	rcu_read_unlock();
 
 	if (can_oom_reap)
-		wake_oom_reaper(victim);
+		wake_oom_reaper(victim, dump_log);
 
 	mmdrop(mm);
 	put_task_struct(victim);
@@ -1011,6 +1031,7 @@ bool out_of_memory(struct oom_control *oc)
 {
 	unsigned long freed = 0;
 	enum oom_constraint constraint = CONSTRAINT_NONE;
+	bool dump_log = oom_dump_enabled(oc);
 
 	if (oom_killer_disabled)
 		return false;
@@ -1029,7 +1050,7 @@ bool out_of_memory(struct oom_control *oc)
 	 */
 	if (task_will_free_mem(current)) {
 		mark_oom_victim(current);
-		wake_oom_reaper(current);
+		wake_oom_reaper(current, dump_log);
 		return true;
 	}
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
