Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 705F96B0038
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 02:36:00 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 191so2315634pgd.0
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 23:36:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d92sor1813440pld.1.2017.11.02.23.35.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Nov 2017 23:35:58 -0700 (PDT)
From: Shawn Landden <slandden@gmail.com>
Subject: [RFC v2] prctl: prctl(PR_SET_IDLE, PR_IDLE_MODE_KILLME), for stateless idle loops
Date: Thu,  2 Nov 2017 23:35:44 -0700
Message-Id: <20171103063544.13383-1-slandden@gmail.com>
In-Reply-To: <20171101053244.5218-1-slandden@gmail.com>
References: <20171101053244.5218-1-slandden@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Shawn Landden <slandden@gmail.com>

It is common for services to be stateless around their main event loop.
If a process sets PR_SET_IDLE to PR_IDLE_MODE_KILLME then it
signals to the kernel that epoll_wait() and friends may not complete,
and the kernel may send SIGKILL if resources get tight.

See my systemd patch: https://github.com/shawnl/systemd/tree/prctl

Android uses this memory model for all programs, and having it in the
kernel will enable integration with the page cache (not in this
series).

16 bytes per process is kinda spendy, but I want to keep
lru behavior, which mem_score_adj does not allow. When a supervisor,
like Android's user input is keeping track this can be done in user-space.
It could be pulled out of task_struct if an cross-indexing additional
red-black tree is added to support pid-based lookup.

v2
switch to prctl, memcg support
---
 fs/eventpoll.c             | 17 +++++++++++++
 fs/proc/array.c            |  7 ++++++
 include/linux/memcontrol.h |  3 +++
 include/linux/oom.h        |  4 ++++
 include/linux/sched.h      |  4 ++++
 include/uapi/linux/prctl.h |  4 ++++
 kernel/cgroup/cgroup.c     | 12 ++++++++++
 kernel/exit.c              |  2 ++
 kernel/sys.c               |  9 +++++++
 mm/memcontrol.c            |  4 ++++
 mm/oom_kill.c              | 60 ++++++++++++++++++++++++++++++++++++++++++++++
 11 files changed, 126 insertions(+)

diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index 2fabd19cdeea..04011fca038b 100644
--- a/fs/eventpoll.c
+++ b/fs/eventpoll.c
@@ -43,6 +43,7 @@
 #include <linux/compat.h>
 #include <linux/rculist.h>
 #include <net/busy_poll.h>
+#include <linux/oom.h>
 
 /*
  * LOCKING:
@@ -1762,6 +1763,14 @@ static int ep_poll(struct eventpoll *ep, struct epoll_event __user *events,
 	wait_queue_entry_t wait;
 	ktime_t expires, *to = NULL;
 
+	if (current->oom_target) {
+		spin_lock(oom_target_get_spinlock(current));
+		list_add(&current->se.oom_target_queue,
+			 oom_target_get_queue(current));
+		current->se.oom_target_on_queue = 1;
+		spin_unlock(oom_target_get_spinlock(current));
+	}
+
 	if (timeout > 0) {
 		struct timespec64 end_time = ep_set_mstimeout(timeout);
 
@@ -1783,6 +1792,7 @@ static int ep_poll(struct eventpoll *ep, struct epoll_event __user *events,
 	if (!ep_events_available(ep))
 		ep_busy_loop(ep, timed_out);
 
+
 	spin_lock_irqsave(&ep->lock, flags);
 
 	if (!ep_events_available(ep)) {
@@ -1850,6 +1860,13 @@ static int ep_poll(struct eventpoll *ep, struct epoll_event __user *events,
 	    !(res = ep_send_events(ep, events, maxevents)) && !timed_out)
 		goto fetch_events;
 
+	if (current->oom_target) {
+		spin_lock(oom_target_get_spinlock(current));
+		list_del(&current->se.oom_target_queue);
+		current->se.oom_target_on_queue = 0;
+		spin_unlock(oom_target_get_spinlock(current));
+	}
+
 	return res;
 }
 
diff --git a/fs/proc/array.c b/fs/proc/array.c
index 77a8eacbe032..cab009727a7f 100644
--- a/fs/proc/array.c
+++ b/fs/proc/array.c
@@ -349,6 +349,12 @@ static inline void task_seccomp(struct seq_file *m, struct task_struct *p)
 	seq_putc(m, '\n');
 }
 
+static inline void task_idle(struct seq_file *m, struct task_struct *p)
+{
+	seq_put_decimal_ull(m, "Idle:\t", p->oom_target);
+	seq_putc(m, '\n');
+}
+
 static inline void task_context_switch_counts(struct seq_file *m,
 						struct task_struct *p)
 {
@@ -380,6 +386,7 @@ int proc_pid_status(struct seq_file *m, struct pid_namespace *ns,
 	task_sig(m, task);
 	task_cap(m, task);
 	task_seccomp(m, task);
+	task_idle(m, task);
 	task_cpus_allowed(m, task);
 	cpuset_task_status_allowed(m, task);
 	task_context_switch_counts(m, task);
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 69966c461d1c..40a2db8ae522 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -261,6 +261,9 @@ struct mem_cgroup {
 	struct list_head event_list;
 	spinlock_t event_list_lock;
 
+	struct list_head	oom_target_queue;
+	spinlock_t		oom_target_spinlock;
+
 	struct mem_cgroup_per_node *nodeinfo[0];
 	/* WARNING: nodeinfo must be the last member here */
 };
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 76aac4ce39bc..a5d16eb05297 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -101,6 +101,10 @@ extern void oom_killer_enable(void);
 
 extern struct task_struct *find_lock_task_mm(struct task_struct *p);
 
+extern void exit_oom_target(void);
+struct list_head *oom_target_get_queue(struct task_struct *ts);
+spinlock_t *oom_target_get_spinlock(struct task_struct *ts);
+
 /* sysctls */
 extern int sysctl_oom_dump_tasks;
 extern int sysctl_oom_kill_allocating_task;
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 26a7df4e558c..2b110c4d7357 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -380,6 +380,9 @@ struct sched_entity {
 	struct list_head		group_node;
 	unsigned int			on_rq;
 
+	unsigned			oom_target_on_queue:1;
+	struct list_head		oom_target_queue;
+
 	u64				exec_start;
 	u64				sum_exec_runtime;
 	u64				vruntime;
@@ -651,6 +654,7 @@ struct task_struct {
 	/* disallow userland-initiated cgroup migration */
 	unsigned			no_cgroup_migration:1;
 #endif
+	unsigned			oom_target:1;
 
 	unsigned long			atomic_flags; /* Flags requiring atomic access. */
 
diff --git a/include/uapi/linux/prctl.h b/include/uapi/linux/prctl.h
index a8d0759a9e40..eba3c3c8375b 100644
--- a/include/uapi/linux/prctl.h
+++ b/include/uapi/linux/prctl.h
@@ -197,4 +197,8 @@ struct prctl_mm_map {
 # define PR_CAP_AMBIENT_LOWER		3
 # define PR_CAP_AMBIENT_CLEAR_ALL	4
 
+#define PR_SET_IDLE		48
+#define PR_GET_IDLE		49
+# define PR_IDLE_MODE_KILLME	1
+
 #endif /* _LINUX_PRCTL_H */
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index 44857278eb8a..bd48b84d9565 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -55,6 +55,7 @@
 #include <linux/nsproxy.h>
 #include <linux/file.h>
 #include <net/sock.h>
+#include <linux/oom.h>
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/cgroup.h>
@@ -779,6 +780,11 @@ static void css_set_move_task(struct task_struct *task,
 				css_task_iter_advance(it);
 
 		list_del_init(&task->cg_list);
+		if (task->se.oom_target_on_queue) {
+			spin_lock(oom_target_get_spinlock(task));
+			list_del_init(&task->se.oom_target_queue);
+			spin_unlock(oom_target_get_spinlock(task));
+		}
 		if (!css_set_populated(from_cset))
 			css_set_update_populated(from_cset, false);
 	} else {
@@ -797,6 +803,12 @@ static void css_set_move_task(struct task_struct *task,
 		rcu_assign_pointer(task->cgroups, to_cset);
 		list_add_tail(&task->cg_list, use_mg_tasks ? &to_cset->mg_tasks :
 							     &to_cset->tasks);
+		if (task->se.oom_target_on_queue) {
+			spin_lock(oom_target_get_spinlock(task));
+			list_add_tail(&task->se.oom_target_queue,
+					oom_target_get_queue(task));
+			spin_unlock(oom_target_get_spinlock(task));
+		}
 	}
 }
 
diff --git a/kernel/exit.c b/kernel/exit.c
index f6cad39f35df..bb13a359b5e7 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -62,6 +62,7 @@
 #include <linux/random.h>
 #include <linux/rcuwait.h>
 #include <linux/compat.h>
+#include <linux/eventpoll.h>
 
 #include <linux/uaccess.h>
 #include <asm/unistd.h>
@@ -917,6 +918,7 @@ void __noreturn do_exit(long code)
 		__this_cpu_add(dirty_throttle_leaks, tsk->nr_dirtied);
 	exit_rcu();
 	exit_tasks_rcu_finish();
+	exit_oom_target();
 
 	lockdep_free_task(tsk);
 	do_task_dead();
diff --git a/kernel/sys.c b/kernel/sys.c
index 9aebc2935013..f949b193f126 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -2385,6 +2385,15 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 	case PR_GET_FP_MODE:
 		error = GET_FP_MODE(me);
 		break;
+	case PR_SET_IDLE:
+		if (!((arg2 == 0) || (arg2 == PR_IDLE_MODE_KILLME)))
+			return -EINVAL;
+		me->oom_target = arg2;
+		error = 0;
+		break;
+	case PR_GET_IDLE:
+		error = me->oom_target;
+		break;
 	default:
 		error = -EINVAL;
 		break;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 661f046ad318..f6ea5adac586 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4300,6 +4300,10 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 			memory_cgrp_subsys.broken_hierarchy = true;
 	}
 
+	INIT_LIST_HEAD(&memcg->oom_target_queue);
+	memcg->oom_target_spinlock = __SPIN_LOCK_UNLOCKED(
+					&memcg->oom_target_spinlock);
+
 	/* The following stuff does not apply to the root */
 	if (!parent) {
 		root_mem_cgroup = memcg;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index dee0f75c3013..05394f0bd6ab 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -41,6 +41,7 @@
 #include <linux/kthread.h>
 #include <linux/init.h>
 #include <linux/mmu_notifier.h>
+#include <linux/eventpoll.h>
 
 #include <asm/tlb.h>
 #include "internal.h"
@@ -54,6 +55,46 @@ int sysctl_oom_dump_tasks = 1;
 
 DEFINE_MUTEX(oom_lock);
 
+static DEFINE_SPINLOCK(oom_target_spinlock);
+static LIST_HEAD(oom_target_global_queue);
+
+/* Clean up after a EPOLL_KILLME process quits.
+ * Called by kernel/exit.c.
+ */
+void exit_oom_target(void)
+{
+	if (current->se.oom_target_on_queue) {
+		spin_lock(&oom_target_spinlock);
+		current->se.oom_target_on_queue = 0;
+		list_del(&current->se.oom_target_queue);
+		spin_unlock(&oom_target_spinlock);
+	}
+}
+
+inline struct list_head *oom_target_get_queue(struct task_struct *ts)
+{
+#ifdef CONFIG_MEMCG
+	struct mem_cgroup *mcg;
+
+	mcg = mem_cgroup_from_task(ts);
+	if (mcg)
+		return &mcg->oom_target_queue;
+#endif
+	return &oom_target_global_queue;
+}
+
+inline spinlock_t *oom_target_get_spinlock(struct task_struct *ts)
+{
+#ifdef CONFIG_MEMCG
+	struct mem_cgroup *mcg;
+
+	mcg = mem_cgroup_from_task(ts);
+	if (mcg)
+		return &mcg->oom_target_spinlock;
+#endif
+	return &oom_target_spinlock;
+}
+
 #ifdef CONFIG_NUMA
 /**
  * has_intersects_mems_allowed() - check task eligiblity for kill
@@ -1007,6 +1048,7 @@ bool out_of_memory(struct oom_control *oc)
 {
 	unsigned long freed = 0;
 	enum oom_constraint constraint = CONSTRAINT_NONE;
+	struct list_head *l;
 
 	if (oom_killer_disabled)
 		return false;
@@ -1018,6 +1060,24 @@ bool out_of_memory(struct oom_control *oc)
 			return true;
 	}
 
+	/*
+	 * Check death row for current memcg or global.
+	 */
+	l = oom_target_get_queue(current);
+	if (!list_empty(l)) {
+		struct task_struct *ts = list_first_entry(l,
+				struct task_struct, se.oom_target_queue);
+
+		pr_debug("Killing pid %u from EPOLL_KILLME death row.",
+			 ts->pid);
+
+		/* We use SIGKILL instead of the oom killer
+		 * so as to cleanly interrupt ep_poll()
+		 */
+		send_sig(SIGKILL, ts, 1);
+		return true;
+	}
+
 	/*
 	 * If current has a pending SIGKILL or is exiting, then automatically
 	 * select it.  The goal is to allow it to allocate so that it may
-- 
2.15.0.rc2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
