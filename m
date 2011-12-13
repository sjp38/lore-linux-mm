Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 02AE16B024A
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 04:13:35 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E83DC3EE0AE
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 18:13:33 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CE54E45DE61
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 18:13:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B67B145DE4E
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 18:13:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A82851DB803E
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 18:13:33 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 56DFD1DB8038
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 18:13:33 +0900 (JST)
Date: Tue, 13 Dec 2011 18:12:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH v4] oom: add trace points for debugging.
Message-Id: <20111213181225.673e19db.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, rientjes@google.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

Changelog:
 - devided into oom tracepoint and task tracepoint.
 - task tracepoint traces fork/rename
 - oom tracepoint traces modification to oom_score_adj.

dropped acks because of total design changes.

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] tracepoint: add tracepoints for debugging oom_score_adj.

oom_score_adj is used for guarding processes from OOM-Killer. One of problem
is that it's inherited at fork(). When a daemon set oom_score_adj and
make children, it's hard to know where the value is set.

This patch adds some tracepoints useful for debugging. This patch adds
3 trace points.
  - creating new task
  - renaming a task (exec)
  - set oom_score_adj

To debug, users need to enable some trace pointer. Maybe filtering is useful as

# EVENT=/sys/kernel/debug/tracing/events/task/
# echo "oom_score_adj != 0" > $EVENT/task_newtask/filter
# echo "oom_score_adj != 0" > $EVENT/task_rename/filter
# echo 1 > $EVENT/enable
# EVENT=/sys/kernel/debug/tracing/events/oom/
# echo 1 > $EVENT/enable

output will be like this.
# grep oom /sys/kernel/debug/tracing/trace
bash-7699  [007] d..3  5140.744510: oom_score_adj_update: pid=7699 comm=bash oom_score_adj=-1000
bash-7699  [007] ...1  5151.818022: task_newtask: pid=7729 comm=bash clone_flags=1200011 oom_score_adj=-1000
ls-7729  [003] ...2  5151.818504: task_rename: pid=7729 oldcomm=bash newcomm=ls oom_score_adj=-1000
bash-7699  [002] ...1  5175.701468: task_newtask: pid=7730 comm=bash clone_flags=1200011 oom_score_adj=-1000
grep-7730  [007] ...2  5175.701993: task_rename: pid=7730 oldcomm=bash newcomm=grep oom_score_adj=-1000

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 fs/exec.c                   |    4 +++
 fs/proc/base.c              |    3 ++
 include/trace/events/oom.h  |   35 ++++++++++++++++++++++++
 include/trace/events/task.h |   63 +++++++++++++++++++++++++++++++++++++++++++
 kernel/fork.c               |    6 ++++
 mm/oom_kill.c               |    6 ++++
 6 files changed, 117 insertions(+), 0 deletions(-)
 create mode 100644 include/trace/events/oom.h
 create mode 100644 include/trace/events/task.h

diff --git a/fs/exec.c b/fs/exec.c
index ca141db..fd0bfbd 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -59,6 +59,8 @@
 #include <asm/uaccess.h>
 #include <asm/mmu_context.h>
 #include <asm/tlb.h>
+
+#include <trace/events/task.h>
 #include "internal.h"
 
 int core_uses_pid;
@@ -1054,6 +1056,8 @@ void set_task_comm(struct task_struct *tsk, char *buf)
 {
 	task_lock(tsk);
 
+	trace_task_rename(tsk, buf);
+
 	/*
 	 * Threads may access current->comm without holding
 	 * the task lock, so write the string carefully.
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 1050b1c..f201e64 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -87,6 +87,7 @@
 #ifdef CONFIG_HARDWALL
 #include <asm/hardwall.h>
 #endif
+#include <trace/events/oom.h>
 #include "internal.h"
 
 /* NOTE:
@@ -1166,6 +1167,7 @@ static ssize_t oom_adjust_write(struct file *file, const char __user *buf,
 	else
 		task->signal->oom_score_adj = (oom_adjust * OOM_SCORE_ADJ_MAX) /
 								-OOM_DISABLE;
+	trace_oom_score_adj_update(task);
 err_sighand:
 	unlock_task_sighand(task, &flags);
 err_task_lock:
@@ -1253,6 +1255,7 @@ static ssize_t oom_score_adj_write(struct file *file, const char __user *buf,
 	task->signal->oom_score_adj = oom_score_adj;
 	if (has_capability_noaudit(current, CAP_SYS_RESOURCE))
 		task->signal->oom_score_adj_min = oom_score_adj;
+	trace_oom_score_adj_update(task);
 	/*
 	 * Scale /proc/pid/oom_adj appropriately ensuring that OOM_DISABLE is
 	 * always attainable.
diff --git a/include/trace/events/oom.h b/include/trace/events/oom.h
new file mode 100644
index 0000000..bb75e5c
--- /dev/null
+++ b/include/trace/events/oom.h
@@ -0,0 +1,35 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM oom
+
+#if !defined(_TRACE_OOM_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_OOM_H
+#include <linux/tracepoint.h>
+
+TRACE_EVENT(oom_score_adj_update,
+
+	TP_PROTO(struct task_struct *task),
+
+	TP_ARGS(task),
+
+	TP_STRUCT__entry(
+		__field(	pid_t,	pid)
+		__array(	char,	comm,	TASK_COMM_LEN )
+		__field(	 int,	oom_score_adj)
+	),
+
+	TP_fast_assign(
+		__entry->pid = task->pid;
+		memcpy(__entry->comm, task->comm, TASK_COMM_LEN);
+		__entry->oom_score_adj = task->signal->oom_score_adj;
+	),
+
+	TP_printk("pid=%d comm=%s oom_score_adj=%d",
+		__entry->pid, __entry->comm, __entry->oom_score_adj)
+);
+
+#endif
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
+
+
diff --git a/include/trace/events/task.h b/include/trace/events/task.h
new file mode 100644
index 0000000..2ac7484
--- /dev/null
+++ b/include/trace/events/task.h
@@ -0,0 +1,63 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM task
+
+#if !defined(_TRACE_TASK_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_TASK_H
+#include <linux/tracepoint.h>
+
+TRACE_EVENT(task_newtask,
+
+	TP_PROTO(struct task_struct *task, unsigned long clone_flags),
+
+	TP_ARGS(task, clone_flags),
+
+	TP_STRUCT__entry(
+		__field(	pid_t,	pid)
+		__array(	char,	comm, TASK_COMM_LEN)
+		__field( unsigned long, clone_flags)
+		__field(	int,    oom_score_adj)
+	),
+
+	TP_fast_assign(
+		__entry->pid = task->pid;
+		memcpy(__entry->comm, task->comm, TASK_COMM_LEN);
+		__entry->clone_flags = clone_flags;
+		__entry->oom_score_adj = task->signal->oom_score_adj;
+	),
+
+	TP_printk("pid=%d comm=%s clone_flags=%lx oom_score_adj=%d",
+		__entry->pid, __entry->comm,
+		__entry->clone_flags, __entry->oom_score_adj)
+);
+
+TRACE_EVENT(task_rename,
+
+	TP_PROTO(struct task_struct *task, char *comm),
+
+	TP_ARGS(task, comm),
+
+	TP_STRUCT__entry(
+		__field(	pid_t,	pid)
+		__array(	char, oldcomm,  TASK_COMM_LEN)
+		__array(	char, newcomm,  TASK_COMM_LEN)
+		__field(	int, oom_score_adj)
+	),
+
+	TP_fast_assign(
+		__entry->pid = task->pid;
+		memcpy(entry->oldcomm, task->comm, TASK_COMM_LEN);
+		memcpy(entry->newcomm, comm, TASK_COMM_LEN);
+		__entry->oom_score_adj = task->signal->oom_score_adj;
+	),
+
+	TP_printk("pid=%d oldcomm=%s newcomm=%s oom_score_adj=%d",
+		__entry->pid, __entry->oldcomm,
+		__entry->newcomm, __entry->oom_score_adj)
+);
+
+#endif
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
+
+
diff --git a/kernel/fork.c b/kernel/fork.c
index e20518d..d93ef13 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -77,6 +77,9 @@
 
 #include <trace/events/sched.h>
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/task.h>
+
 /*
  * Protected counters by write_lock_irq(&tasklist_lock)
  */
@@ -1390,6 +1393,9 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	if (clone_flags & CLONE_THREAD)
 		threadgroup_fork_read_unlock(current);
 	perf_event_fork(p);
+
+	trace_task_newtask(p, clone_flags);
+
 	return p;
 
 bad_fork_free_pid:
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index e2e1402..46b6d0a 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -33,6 +33,10 @@
 #include <linux/security.h>
 #include <linux/ptrace.h>
 #include <linux/freezer.h>
+#include <linux/ftrace.h>
+
+#define CREATE_TRACE_POINTS
+#include <trace/events/oom.h>
 
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
@@ -55,6 +59,7 @@ void compare_swap_oom_score_adj(int old_val, int new_val)
 	spin_lock_irq(&sighand->siglock);
 	if (current->signal->oom_score_adj == old_val)
 		current->signal->oom_score_adj = new_val;
+	trace_oom_score_adj_update(current);
 	spin_unlock_irq(&sighand->siglock);
 }
 
@@ -74,6 +79,7 @@ int test_set_oom_score_adj(int new_val)
 	spin_lock_irq(&sighand->siglock);
 	old_val = current->signal->oom_score_adj;
 	current->signal->oom_score_adj = new_val;
+	trace_oom_score_adj_update(current);
 	spin_unlock_irq(&sighand->siglock);
 
 	return old_val;
-- 
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
