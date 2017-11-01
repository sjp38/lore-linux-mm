Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 877CC6B0268
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 01:32:49 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id d28so1294191pfe.1
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 22:32:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e2sor855499pgn.126.2017.10.31.22.32.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Oct 2017 22:32:48 -0700 (PDT)
From: Shawn Landden <slandden@gmail.com>
Subject: [RFC] EPOLL_KILLME: New flag to epoll_wait() that subscribes process to death row (new syscall)
Date: Tue, 31 Oct 2017 22:32:44 -0700
Message-Id: <20171101053244.5218-1-slandden@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Shawn Landden <slandden@gmail.com>

It is common for services to be stateless around their main event loop.
If a process passes the EPOLL_KILLME flag to epoll_wait5() then it
signals to the kernel that epoll_wait5() may not complete, and the kernel
may send SIGKILL if resources get tight.

See my systemd patch: https://github.com/shawnl/systemd/tree/killme

Android uses this memory model for all programs, and having it in the
kernel will enable integration with the page cache (not in this
series).
---
 arch/x86/entry/syscalls/syscall_32.tbl |  1 +
 arch/x86/entry/syscalls/syscall_64.tbl |  1 +
 fs/eventpoll.c                         | 74 +++++++++++++++++++++++++++++++++-
 include/linux/eventpoll.h              |  2 +
 include/linux/sched.h                  |  3 ++
 include/uapi/asm-generic/unistd.h      |  5 ++-
 include/uapi/linux/eventpoll.h         |  3 ++
 kernel/exit.c                          |  2 +
 mm/oom_kill.c                          | 17 ++++++++
 9 files changed, 105 insertions(+), 3 deletions(-)

diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
index 448ac2161112..040e5d02bdcc 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -391,3 +391,4 @@
 382	i386	pkey_free		sys_pkey_free
 383	i386	statx			sys_statx
 384	i386	arch_prctl		sys_arch_prctl			compat_sys_arch_prctl
+385	i386	epoll_wait5		sys_epoll_wait5
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index 5aef183e2f85..c72802e8cf65 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -339,6 +339,7 @@
 330	common	pkey_alloc		sys_pkey_alloc
 331	common	pkey_free		sys_pkey_free
 332	common	statx			sys_statx
+333	common	epoll_wait5		sys_epoll_wait5
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index 2fabd19cdeea..76d1c91d940b 100644
--- a/fs/eventpoll.c
+++ b/fs/eventpoll.c
@@ -297,6 +297,14 @@ static LIST_HEAD(visited_list);
  */
 static LIST_HEAD(tfile_check_list);
 
+static LIST_HEAD(deathrow_q);
+static long deathrow_len __read_mostly;
+
+/* TODO: Can this lock be removed by using atomic instructions to update
+ * queue?
+ */
+static DEFINE_MUTEX(deathrow_mutex);
+
 #ifdef CONFIG_SYSCTL
 
 #include <linux/sysctl.h>
@@ -314,6 +322,15 @@ struct ctl_table epoll_table[] = {
 		.extra1		= &zero,
 		.extra2		= &long_max,
 	},
+	{
+		.procname	= "deathrow_size",
+		.data		= &deathrow_len,
+		.maxlen		= sizeof(deathrow_len),
+		.mode		= 0444,
+		.proc_handler	= proc_doulongvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &long_max,
+	},
 	{ }
 };
 #endif /* CONFIG_SYSCTL */
@@ -2164,9 +2181,12 @@ SYSCALL_DEFINE4(epoll_ctl, int, epfd, int, op, int, fd,
 /*
  * Implement the event wait interface for the eventpoll file. It is the kernel
  * part of the user space epoll_wait(2).
+ *
+ * A flags argument cannot be added to epoll_pwait cause it already has
+ * the maximum number of arguments (6). Can this be fixed?
  */
-SYSCALL_DEFINE4(epoll_wait, int, epfd, struct epoll_event __user *, events,
-		int, maxevents, int, timeout)
+SYSCALL_DEFINE5(epoll_wait5, int, epfd, struct epoll_event __user *, events,
+		int, maxevents, int, timeout, int, flags)
 {
 	int error;
 	struct fd f;
@@ -2199,14 +2219,44 @@ SYSCALL_DEFINE4(epoll_wait, int, epfd, struct epoll_event __user *, events,
 	 */
 	ep = f.file->private_data;
 
+	/* Check the EPOLL_* constants for conflicts.  */
+	BUILD_BUG_ON(EPOLL_KILLME == EPOLL_CLOEXEC);
+
+	if (flags & ~EPOLL_KILLME)
+		return -EINVAL;
+
+	if (flags & EPOLL_KILLME) {
+		/* Put process on death row. */
+		mutex_lock(&deathrow_mutex);
+		deathrow_len++;
+		list_add(&current->se.deathrow, &deathrow_q);
+		current->se.on_deathrow = 1;
+		mutex_unlock(&deathrow_mutex);
+	}
+
 	/* Time to fish for events ... */
 	error = ep_poll(ep, events, maxevents, timeout);
 
+	if (flags & EPOLL_KILLME) {
+		/* Remove process from death row. */
+		mutex_lock(&deathrow_mutex);
+		current->se.on_deathrow = 0;
+		list_del(&current->se.deathrow);
+		deathrow_len--;
+		mutex_unlock(&deathrow_mutex);
+	}
+
 error_fput:
 	fdput(f);
 	return error;
 }
 
+SYSCALL_DEFINE4(epoll_wait, int, epfd, struct epoll_event __user *, events,
+		int, maxevents, int, timeout)
+{
+	return sys_epoll_wait5(epfd, events, maxevents, timeout, 0);
+}
+
 /*
  * Implement the event wait interface for the eventpoll file. It is the kernel
  * part of the user space epoll_pwait(2).
@@ -2297,6 +2347,26 @@ COMPAT_SYSCALL_DEFINE6(epoll_pwait, int, epfd,
 }
 #endif
 
+/* Clean up after a EPOLL_KILLME process quits.
+ * Called by kernel/exit.c.
+ */
+int exit_killme(void)
+{
+	if (current->se.on_deathrow) {
+		mutex_lock(&deathrow_mutex);
+		current->se.on_deathrow = 0;
+		list_del(&current->se.deathrow);
+		mutex_unlock(&deathrow_mutex);
+	}
+
+	return 0;
+}
+
+struct list_head *eventpoll_deathrow_list(void)
+{
+	return &deathrow_q;
+}
+
 static int __init eventpoll_init(void)
 {
 	struct sysinfo si;
diff --git a/include/linux/eventpoll.h b/include/linux/eventpoll.h
index 2f14ac73d01d..f1e28d468de5 100644
--- a/include/linux/eventpoll.h
+++ b/include/linux/eventpoll.h
@@ -20,6 +20,8 @@
 /* Forward declarations to avoid compiler errors */
 struct file;
 
+int exit_killme(void);
+struct list_head *eventpoll_deathrow_list(void);
 
 #ifdef CONFIG_EPOLL
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 26a7df4e558c..66462bf27a29 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -380,6 +380,9 @@ struct sched_entity {
 	struct list_head		group_node;
 	unsigned int			on_rq;
 
+	unsigned			on_deathrow:1;
+	struct list_head		deathrow;
+
 	u64				exec_start;
 	u64				sum_exec_runtime;
 	u64				vruntime;
diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
index 061185a5eb51..843553a39388 100644
--- a/include/uapi/asm-generic/unistd.h
+++ b/include/uapi/asm-generic/unistd.h
@@ -893,8 +893,11 @@ __SYSCALL(__NR_fork, sys_fork)
 __SYSCALL(__NR_fork, sys_ni_syscall)
 #endif /* CONFIG_MMU */
 
+#define __NR_epoll_wait5 1080
+__SYSCALL(__NR_epoll_wait5, sys_epoll_wait5)
+
 #undef __NR_syscalls
-#define __NR_syscalls (__NR_fork+1)
+#define __NR_syscalls (__NR_fork+2)
 
 #endif /* __ARCH_WANT_SYSCALL_DEPRECATED */
 
diff --git a/include/uapi/linux/eventpoll.h b/include/uapi/linux/eventpoll.h
index f4d5c998cc2b..ce150a3e7248 100644
--- a/include/uapi/linux/eventpoll.h
+++ b/include/uapi/linux/eventpoll.h
@@ -21,6 +21,9 @@
 /* Flags for epoll_create1.  */
 #define EPOLL_CLOEXEC O_CLOEXEC
 
+/* Flags for epoll_wait5.  */
+#define EPOLL_KILLME 0x00000001
+
 /* Valid opcodes to issue to sys_epoll_ctl() */
 #define EPOLL_CTL_ADD 1
 #define EPOLL_CTL_DEL 2
diff --git a/kernel/exit.c b/kernel/exit.c
index f6cad39f35df..cd089bdc5b17 100644
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
+	exit_killme();
 
 	lockdep_free_task(tsk);
 	do_task_dead();
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index dee0f75c3013..d6252772d593 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -41,6 +41,7 @@
 #include <linux/kthread.h>
 #include <linux/init.h>
 #include <linux/mmu_notifier.h>
+#include <linux/eventpoll.h>
 
 #include <asm/tlb.h>
 #include "internal.h"
@@ -1029,6 +1030,22 @@ bool out_of_memory(struct oom_control *oc)
 		return true;
 	}
 
+	/*
+	 * Check death row.
+	 */
+	if (!list_empty(eventpoll_deathrow_list())) {
+		struct list_head *l = eventpoll_deathrow_list();
+		struct task_struct *ts = list_first_entry(l,
+					 struct task_struct, se.deathrow);
+
+		pr_debug("Killing pid %u from EPOLL_KILLME death row.",
+			ts->pid);
+
+		/* We use SIGKILL so as to cleanly interrupt ep_poll() */
+		kill_pid(task_pid(ts), SIGKILL, 1);
+		return true;
+	}
+
 	/*
 	 * The OOM killer does not compensate for IO-less reclaim.
 	 * pagefault_out_of_memory lost its gfp context so we have to
-- 
2.15.0.rc2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
