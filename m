Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D0A186B0275
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 00:16:46 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id s18so11723076pge.19
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 21:16:46 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l9sor3902629plt.108.2017.11.20.21.16.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Nov 2017 21:16:45 -0800 (PST)
From: Shawn Landden <slandden@gmail.com>
Subject: [RFC v4] It is common for services to be stateless around their main event loop. If a process sets PR_SET_IDLE to PR_IDLE_MODE_KILLME then it signals to the kernel that epoll_wait() and friends may not complete, and the kernel may send SIGKILL if resources get tight.
Date: Mon, 20 Nov 2017 21:16:39 -0800
Message-Id: <20171121051639.1228-1-slandden@gmail.com>
In-Reply-To: <20171121044947.18479-1-slandden@gmail.com>
References: <20171121044947.18479-1-slandden@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, mhocko@kernel.org, willy@infradead.org, Shawn Landden <slandden@gmail.com>

See my systemd patch: https://github.com/shawnl/systemd/tree/prctl

Android uses this memory model for all programs, and having it in the
kernel will enable integration with the page cache (not in this
series).

v2
switch to prctl, memcg support

v3
use <linux/wait.h>
put OOM after constraint checking

v4
ignore memcg OOMs as should have been all along (sry for the noise)
---
 fs/eventpoll.c             |  9 +++++++++
 fs/proc/array.c            |  7 +++++++
 include/linux/memcontrol.h |  1 +
 include/linux/oom.h        |  4 ++++
 include/linux/sched.h      |  1 +
 include/uapi/linux/prctl.h |  4 ++++
 kernel/exit.c              |  1 +
 kernel/sys.c               |  9 +++++++++
 mm/oom_kill.c              | 43 +++++++++++++++++++++++++++++++++++++++++++
 9 files changed, 79 insertions(+)

diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index 2fabd19cdeea..5b3f084b22d5 100644
--- a/fs/eventpoll.c
+++ b/fs/eventpoll.c
@@ -43,6 +43,8 @@
 #include <linux/compat.h>
 #include <linux/rculist.h>
 #include <net/busy_poll.h>
+#include <linux/memcontrol.h>
+#include <linux/oom.h>
 
 /*
  * LOCKING:
@@ -1761,6 +1763,10 @@ static int ep_poll(struct eventpoll *ep, struct epoll_event __user *events,
 	u64 slack = 0;
 	wait_queue_entry_t wait;
 	ktime_t expires, *to = NULL;
+	DEFINE_WAIT_FUNC(oom_target_wait, oom_target_callback);
+
+	if (current->oom_target)
+		add_wait_queue(oom_target_get_wait(), &oom_target_wait);
 
 	if (timeout > 0) {
 		struct timespec64 end_time = ep_set_mstimeout(timeout);
@@ -1850,6 +1856,9 @@ static int ep_poll(struct eventpoll *ep, struct epoll_event __user *events,
 	    !(res = ep_send_events(ep, events, maxevents)) && !timed_out)
 		goto fetch_events;
 
+	if (current->oom_target)
+		remove_wait_queue(oom_target_get_wait(), &oom_target_wait);
+
 	return res;
 }
 
diff --git a/fs/proc/array.c b/fs/proc/array.c
index 9390032a11e1..1954ae87cb88 100644
--- a/fs/proc/array.c
+++ b/fs/proc/array.c
@@ -350,6 +350,12 @@ static inline void task_seccomp(struct seq_file *m, struct task_struct *p)
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
@@ -381,6 +387,7 @@ int proc_pid_status(struct seq_file *m, struct pid_namespace *ns,
 	task_sig(m, task);
 	task_cap(m, task);
 	task_seccomp(m, task);
+	task_idle(m, task);
 	task_cpus_allowed(m, task);
 	cpuset_task_status_allowed(m, task);
 	task_context_switch_counts(m, task);
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 69966c461d1c..471d1d52ae72 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -30,6 +30,7 @@
 #include <linux/vmstat.h>
 #include <linux/writeback.h>
 #include <linux/page-flags.h>
+#include <linux/wait.h>
 
 struct mem_cgroup;
 struct page;
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 01c91d874a57..88acea9e0a59 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -102,6 +102,10 @@ extern void oom_killer_enable(void);
 
 extern struct task_struct *find_lock_task_mm(struct task_struct *p);
 
+extern void exit_oom_target(void);
+struct wait_queue_head *oom_target_get_wait(void);
+int oom_target_callback(wait_queue_entry_t *wait, unsigned mode, int sync, void *key);
+
 /* sysctls */
 extern int sysctl_oom_dump_tasks;
 extern int sysctl_oom_kill_allocating_task;
diff --git a/include/linux/sched.h b/include/linux/sched.h
index fdf74f27acf1..51b0e5987e8c 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -652,6 +652,7 @@ struct task_struct {
 	/* disallow userland-initiated cgroup migration */
 	unsigned			no_cgroup_migration:1;
 #endif
+	unsigned			oom_target:1;
 
 	unsigned long			atomic_flags; /* Flags requiring atomic access. */
 
diff --git a/include/uapi/linux/prctl.h b/include/uapi/linux/prctl.h
index b640071421f7..94868317c6f2 100644
--- a/include/uapi/linux/prctl.h
+++ b/include/uapi/linux/prctl.h
@@ -198,4 +198,8 @@ struct prctl_mm_map {
 # define PR_CAP_AMBIENT_LOWER		3
 # define PR_CAP_AMBIENT_CLEAR_ALL	4
 
+#define PR_SET_IDLE		48
+#define PR_GET_IDLE		49
+# define PR_IDLE_MODE_KILLME	1
+
 #endif /* _LINUX_PRCTL_H */
diff --git a/kernel/exit.c b/kernel/exit.c
index f6cad39f35df..2788fbdae267 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -62,6 +62,7 @@
 #include <linux/random.h>
 #include <linux/rcuwait.h>
 #include <linux/compat.h>
+#include <linux/eventpoll.h>
 
 #include <linux/uaccess.h>
 #include <asm/unistd.h>
diff --git a/kernel/sys.c b/kernel/sys.c
index 524a4cb9bbe2..e1eb049a85e6 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -2386,6 +2386,15 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
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
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index dee0f75c3013..73ad7ee47c8e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -41,6 +41,8 @@
 #include <linux/kthread.h>
 #include <linux/init.h>
 #include <linux/mmu_notifier.h>
+#include <linux/eventpoll.h>
+#include <linux/wait.h>
 
 #include <asm/tlb.h>
 #include "internal.h"
@@ -54,6 +56,23 @@ int sysctl_oom_dump_tasks = 1;
 
 DEFINE_MUTEX(oom_lock);
 
+static DECLARE_WAIT_QUEUE_HEAD(oom_target);
+
+/* Clean up after a EPOLL_KILLME process quits.
+ * Called by kernel/exit.c.
+ */
+void exit_oom_target(void)
+{
+	DECLARE_WAITQUEUE(wait, current);
+
+	remove_wait_queue(&oom_target, &wait);
+}
+
+inline struct wait_queue_head *oom_target_get_wait()
+{
+	return &oom_target;
+}
+
 #ifdef CONFIG_NUMA
 /**
  * has_intersects_mems_allowed() - check task eligiblity for kill
@@ -994,6 +1013,18 @@ int unregister_oom_notifier(struct notifier_block *nb)
 }
 EXPORT_SYMBOL_GPL(unregister_oom_notifier);
 
+int oom_target_callback(wait_queue_entry_t *wait, unsigned mode, int sync, void *key)
+{
+	struct task_struct *ts = wait->private;
+
+	/* We use SIGKILL instead of the oom killer
+	 * so as to cleanly interrupt ep_poll()
+	 */
+	pr_debug("Killing pid %u from prctl(PR_SET_IDLE) death row.\n", ts->pid);
+	send_sig(SIGKILL, ts, 1);
+	return 0;
+}
+
 /**
  * out_of_memory - kill the "best" process when we run out of memory
  * @oc: pointer to struct oom_control
@@ -1007,6 +1038,7 @@ bool out_of_memory(struct oom_control *oc)
 {
 	unsigned long freed = 0;
 	enum oom_constraint constraint = CONSTRAINT_NONE;
+	wait_queue_head_t *w;
 
 	if (oom_killer_disabled)
 		return false;
@@ -1056,6 +1088,17 @@ bool out_of_memory(struct oom_control *oc)
 		return true;
 	}
 
+	/*
+	 * Check death row for current memcg or global.
+	 */
+	if (!is_memcg_oom(oc)) {
+		w = oom_target_get_wait();
+		if (waitqueue_active(w)) {
+			wake_up(w);
+			return true;
+		}
+	}
+
 	select_bad_process(oc);
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
