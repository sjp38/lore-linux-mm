Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1C2296B025F
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 13:05:17 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id c21so1903191wrg.16
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 10:05:17 -0700 (PDT)
Received: from mellanox.co.il (mail-il-dmz.mellanox.com. [193.47.165.129])
        by mx.google.com with ESMTP id a137si2159003wme.11.2017.11.03.10.05.13
        for <linux-mm@kvack.org>;
        Fri, 03 Nov 2017 10:05:14 -0700 (PDT)
From: Chris Metcalf <cmetcalf@mellanox.com>
Subject: [PATCH v16 06/13] task_isolation: userspace hard isolation from kernel
Date: Fri,  3 Nov 2017 13:04:45 -0400
Message-Id: <1509728692-10460-7-git-send-email-cmetcalf@mellanox.com>
In-Reply-To: <1509728692-10460-1-git-send-email-cmetcalf@mellanox.com>
References: <1509728692-10460-1-git-send-email-cmetcalf@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Frederic Weisbecker <fweisbec@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Viresh Kumar <viresh.kumar@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, Jonathan Corbet <corbet@lwn.net>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Chris Metcalf <cmetcalf@mellanox.com>

The existing nohz_full mode is designed as a "soft" isolation mode
that makes tradeoffs to minimize userspace interruptions while
still attempting to avoid overheads in the kernel entry/exit path,
to provide 100% kernel semantics, etc.

However, some applications require a "hard" commitment from the
kernel to avoid interruptions, in particular userspace device driver
style applications, such as high-speed networking code.

This change introduces a framework to allow applications
to elect to have the "hard" semantics as needed, specifying
prctl(PR_TASK_ISOLATION, PR_TASK_ISOLATION_ENABLE) to do so.

The kernel must be built with the new TASK_ISOLATION Kconfig flag
to enable this mode, and the kernel booted with an appropriate
"nohz_full=CPULIST isolcpus=CPULIST" boot argument to enable
nohz_full and isolcpus.  The "task_isolation" state is then indicated
by setting a new task struct field, task_isolation_flag, to the
value passed by prctl(), and also setting a TIF_TASK_ISOLATION
bit in the thread_info flags.  When the kernel is returning to
userspace from the prctl() call and sees TIF_TASK_ISOLATION set,
it calls the new task_isolation_start() routine to arrange for
the task to avoid being interrupted in the future.

With interrupts disabled, task_isolation_start() ensures that kernel
subsystems that might cause a future interrupt are quiesced.  If it
doesn't succeed, it adjusts the syscall return value to indicate that
fact, and userspace can retry as desired.  In addition to stopping
the scheduler tick, the code takes any actions that might avoid
a future interrupt to the core, such as a worker thread being
scheduled that could be quiesced now (e.g. the vmstat worker)
or a future IPI to the core to clean up some state that could be
cleaned up now (e.g. the mm lru per-cpu cache).

Once the task has returned to userspace after issuing the prctl(),
if it enters the kernel again via system call, page fault, or any
other exception or irq, the kernel will kill it with SIGKILL.
In addition to sending a signal, the code supports a kernel
command-line "task_isolation_debug" flag which causes a stack
backtrace to be generated whenever a task loses isolation.

To allow the state to be entered and exited, the syscall checking
test ignores the prctl(PR_TASK_ISOLATION) syscall so that we can
clear the bit again later, and ignores exit/exit_group to allow
exiting the task without a pointless signal being delivered.

The prctl() API allows for specifying a signal number to use instead
of the default SIGKILL, to allow for catching the notification
signal; for example, in a production environment, it might be
helpful to log information to the application logging mechanism
before exiting.  Or, the signal handler might choose to reset the
program counter back to the code segment intended to be run isolated
via prctl() to continue execution.

In a number of cases we can tell on a remote cpu that we are
going to be interrupting the cpu, e.g. via an IPI or a TLB flush.
In that case we generate the diagnostic (and optional stack dump)
on the remote core to be able to deliver better diagnostics.
If the interrupt is not something caught by Linux (e.g. a
hypervisor interrupt) we can also request a reschedule IPI to
be sent to the remote core so it can be sure to generate a
signal to notify the process.

Separate patches that follow provide these changes for x86, tile,
arm, and arm64.

Signed-off-by: Chris Metcalf <cmetcalf@mellanox.com>
---
 Documentation/admin-guide/kernel-parameters.txt |   6 +
 include/linux/isolation.h                       | 175 +++++++++++
 include/linux/sched.h                           |   4 +
 include/uapi/linux/prctl.h                      |   6 +
 init/Kconfig                                    |  28 ++
 kernel/Makefile                                 |   1 +
 kernel/context_tracking.c                       |   2 +
 kernel/isolation.c                              | 402 ++++++++++++++++++++++++
 kernel/signal.c                                 |   2 +
 kernel/sys.c                                    |   6 +
 10 files changed, 631 insertions(+)
 create mode 100644 include/linux/isolation.h
 create mode 100644 kernel/isolation.c

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 05496622b4ef..aaf278f2cfc3 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -4025,6 +4025,12 @@
 			neutralize any effect of /proc/sys/kernel/sysrq.
 			Useful for debugging.
 
+	task_isolation_debug	[KNL]
+			In kernels built with CONFIG_TASK_ISOLATION, this
+			setting will generate console backtraces to
+			accompany the diagnostics generated about
+			interrupting tasks running with task isolation.
+
 	tcpmhash_entries= [KNL,NET]
 			Set the number of tcp_metrics_hash slots.
 			Default value is 8192 or 16384 depending on total
diff --git a/include/linux/isolation.h b/include/linux/isolation.h
new file mode 100644
index 000000000000..8189a772affd
--- /dev/null
+++ b/include/linux/isolation.h
@@ -0,0 +1,175 @@
+/*
+ * Task isolation related global functions
+ */
+#ifndef _LINUX_ISOLATION_H
+#define _LINUX_ISOLATION_H
+
+#include <stdarg.h>
+#include <linux/errno.h>
+#include <linux/cpumask.h>
+#include <linux/prctl.h>
+#include <linux/types.h>
+
+struct task_struct;
+
+#ifdef CONFIG_TASK_ISOLATION
+
+/**
+ * task_isolation_request() - prctl hook to request task isolation
+ * @flags:	Flags from <linux/prctl.h> PR_TASK_ISOLATION_xxx.
+ *
+ * This is called from the generic prctl() code for PR_TASK_ISOLATION.
+
+ * Return: Returns 0 when task isolation enabled, otherwise a negative
+ * errno.
+ */
+extern int task_isolation_request(unsigned int flags);
+
+/**
+ * task_isolation_start() - attempt to actually start task isolation
+ *
+ * This function should be invoked as the last thing prior to returning to
+ * user space if TIF_TASK_ISOLATION is set in the thread_info flags.  It
+ * will attempt to quiesce the core and enter task-isolation mode.  If it
+ * fails, it will reset the system call return value to an error code that
+ * indicates the failure mode.
+ */
+extern void task_isolation_start(void);
+
+/**
+ * task_isolation_syscall() - report a syscall from an isolated task
+ * @nr:		The syscall number.
+ *
+ * This routine should be invoked at syscall entry if TIF_TASK_ISOLATION is
+ * set in the thread_info flags.  It checks for valid syscalls,
+ * specifically prctl() with PR_TASK_ISOLATION, exit(), and exit_group().
+ * For any other syscall it will raise a signal and return failure.
+ *
+ * Return: 0 for acceptable syscalls, -1 for all others.
+ */
+extern int task_isolation_syscall(int nr);
+
+/**
+ * _task_isolation_interrupt() - report an interrupt of an isolated task
+ * @fmt:	A format string describing the interrupt
+ * @...:	Format arguments, if any.
+ *
+ * This routine should be invoked at any exception or IRQ if
+ * TIF_TASK_ISOLATION is set in the thread_info flags.  It is not necessary
+ * to invoke it if the exception will generate a signal anyway (e.g. a bad
+ * page fault), and in that case it is preferable not to invoke it but just
+ * rely on the standard Linux signal.  The macro task_isolation_syscall()
+ * wraps the TIF_TASK_ISOLATION flag test to simplify the caller code.
+ */
+extern void _task_isolation_interrupt(const char *fmt, ...);
+#define task_isolation_interrupt(fmt, ...)				\
+	do {								\
+		if (current_thread_info()->flags & _TIF_TASK_ISOLATION) \
+			_task_isolation_interrupt(fmt, ## __VA_ARGS__); \
+	} while (0)
+
+/**
+ * _task_isolation_remote() - report a remote interrupt of an isolated task
+ * @cpu:	The remote cpu that is about to be interrupted.
+ * @do_interrupt: Whether we should generate an extra interrupt.
+ * @fmt:	A format string describing the interrupt
+ * @...:	Format arguments, if any.
+ *
+ * This routine should be invoked any time a remote IPI or other type of
+ * interrupt is being delivered to another cpu.  The function will check to
+ * see if the target core is running a task-isolation task, and generate a
+ * diagnostic on the console if so; in addition, we tag the task so it
+ * doesn't generate another diagnostic when the interrupt actually arrives.
+ * Generating a diagnostic remotely yields a clearer indication of what
+ * happened then just reporting only when the remote core is interrupted.
+ *
+ * The @do_interrupt flag, if true, causes the routine to not just print
+ * the diagnostic, but also to generate a reschedule interrupt to the
+ * remote core that is being interrupted.  This is necessary if the remote
+ * interrupt being diagnosed will not otherwise be visible to the remote
+ * core (e.g. a hypervisor service is being invoked on the remote core).
+ * Sending a reschedule will force the core to trigger the isolation signal
+ * and exit isolation mode.
+ *
+ * The task_isolation_remote() macro passes @do_interrupt as false, and the
+ * task_isolation_remote_interrupt() passes the flag as true.
+ */
+extern void _task_isolation_remote(int cpu, bool do_interrupt,
+				   const char *fmt, ...);
+#define task_isolation_remote(cpu, fmt, ...) \
+	_task_isolation_remote(cpu, false, fmt, ## __VA_ARGS__)
+#define task_isolation_remote_interrupt(cpu, fmt, ...) \
+	_task_isolation_remote(cpu, true, fmt, ## __VA_ARGS__)
+
+/**
+ * _task_isolation_remote_cpumask() - report interruption of multiple cpus
+ * @mask:	The set of remotes cpus that are about to be interrupted.
+ * @do_interrupt: Whether we should generate an extra interrupt.
+ * @fmt:	A format string describing the interrupt
+ * @...:	Format arguments, if any.
+ *
+ * This is the cpumask variant of _task_isolation_remote().  We
+ * generate a single-line diagnostic message even if multiple remote
+ * task-isolation cpus are being interrupted.
+ */
+extern void _task_isolation_remote_cpumask(const struct cpumask *mask,
+					   bool do_interrupt,
+					   const char *fmt, ...);
+#define task_isolation_remote_cpumask(cpumask, fmt, ...) \
+	_task_isolation_remote_cpumask(cpumask, false, fmt, ## __VA_ARGS__)
+#define task_isolation_remote_cpumask_interrupt(cpumask, fmt, ...) \
+	_task_isolation_remote_cpumask(cpumask, true, fmt, ## __VA_ARGS__)
+
+/**
+ * _task_isolation_signal() - disable task isolation when signal is pending
+ * @task:	The task for which to disable isolation.
+ *
+ * This function generates a diagnostic and disables task isolation; it
+ * should be called if TIF_TASK_ISOLATION is set when notifying a task of a
+ * pending signal.  The task_isolation_interrupt() function normally
+ * generates a diagnostic for events that just interrupt a task without
+ * generating a signal; here we need to hook the paths that correspond to
+ * interrupts that do generate a signal.  The macro task_isolation_signal()
+ * wraps the TIF_TASK_ISOLATION flag test to simplify the caller code.
+ */
+extern void _task_isolation_signal(struct task_struct *task);
+#define task_isolation_signal(task) do {				\
+		if (task_thread_info(task)->flags & _TIF_TASK_ISOLATION) \
+			_task_isolation_signal(task);			\
+	} while (0)
+
+/**
+ * task_isolation_user_exit() - debug all user_exit calls
+ *
+ * By default, we don't generate an exception in the low-level user_exit()
+ * code, because programs lose the ability to disable task isolation: the
+ * user_exit() hook will cause a signal prior to task_isolation_syscall()
+ * disabling task isolation.  In addition, it means that we lose all the
+ * diagnostic info otherwise available from task_isolation_interrupt() hooks
+ * later in the interrupt-handling process.  But you may enable it here for
+ * a special kernel build if you are having undiagnosed userspace jitter.
+ */
+static inline void task_isolation_user_exit(void)
+{
+#ifdef DEBUG_TASK_ISOLATION
+	task_isolation_interrupt("user_exit");
+#endif
+}
+
+#else /* !CONFIG_TASK_ISOLATION */
+static inline int task_isolation_request(unsigned int flags) { return -EINVAL; }
+static inline void task_isolation_start(void) { }
+static inline int task_isolation_syscall(int nr) { return 0; }
+static inline void task_isolation_interrupt(const char *fmt, ...) { }
+static inline void task_isolation_remote(int cpu, const char *fmt, ...) { }
+static inline void task_isolation_remote_interrupt(int cpu,
+						   const char *fmt, ...) { }
+static inline void task_isolation_remote_cpumask(const struct cpumask *mask,
+						 const char *fmt, ...) { }
+static inline void task_isolation_remote_cpumask_interrupt(
+	const struct cpumask *mask, const char *fmt, ...) { }
+static inline void task_isolation_signal(struct task_struct *task) { }
+static inline void task_isolation_user_exit(void) { }
+#endif
+
+#endif /* _LINUX_ISOLATION_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 26a7df4e558c..739d81a44e13 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1096,6 +1096,10 @@ struct task_struct {
 	/* Used by LSM modules for access restriction: */
 	void				*security;
 #endif
+#ifdef CONFIG_TASK_ISOLATION
+	unsigned short			task_isolation_flags;  /* prctl */
+	unsigned short			task_isolation_state;
+#endif
 
 	/*
 	 * New fields for task_struct should be added above here, so that
diff --git a/include/uapi/linux/prctl.h b/include/uapi/linux/prctl.h
index a8d0759a9e40..5a954302fdea 100644
--- a/include/uapi/linux/prctl.h
+++ b/include/uapi/linux/prctl.h
@@ -197,4 +197,10 @@ struct prctl_mm_map {
 # define PR_CAP_AMBIENT_LOWER		3
 # define PR_CAP_AMBIENT_CLEAR_ALL	4
 
+/* Enable task_isolation mode for TASK_ISOLATION kernels. */
+#define PR_TASK_ISOLATION		48
+# define PR_TASK_ISOLATION_ENABLE	(1 << 0)
+# define PR_TASK_ISOLATION_SET_SIG(sig)	(((sig) & 0x7f) << 8)
+# define PR_TASK_ISOLATION_GET_SIG(bits) (((bits) >> 8) & 0x7f)
+
 #endif /* _LINUX_PRCTL_H */
diff --git a/init/Kconfig b/init/Kconfig
index 78cb2461012e..500c2aeb49b7 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -474,6 +474,34 @@ endmenu # "CPU/Task time and stats accounting"
 
 source "kernel/rcu/Kconfig"
 
+config HAVE_ARCH_TASK_ISOLATION
+	bool
+
+config TASK_ISOLATION
+	bool "Provide hard CPU isolation from the kernel on demand"
+	depends on NO_HZ_FULL && HAVE_ARCH_TASK_ISOLATION
+	help
+
+	 Allow userspace processes that place themselves on cores with
+	 nohz_full and isolcpus enabled, and run prctl(PR_TASK_ISOLATION),
+	 to "isolate" themselves from the kernel.  Prior to returning to
+	 userspace, isolated tasks will arrange that no future kernel
+	 activity will interrupt the task while the task is running in
+	 userspace.  Attempting to re-enter the kernel while in this mode
+	 will cause the task to be terminated with a signal; you must
+	 explicitly use prctl() to disable task isolation before resuming
+	 normal use of the kernel.
+
+	 This "hard" isolation from the kernel is required for userspace
+	 tasks that are running hard real-time tasks in userspace, such as
+	 a high-speed network driver in userspace.  Without this option, but
+	 with NO_HZ_FULL enabled, the kernel will make a best-faith, "soft"
+	 effort to shield a single userspace process from interrupts, but
+	 makes no guarantees.
+
+	 You should say "N" unless you are intending to run a
+	 high-performance userspace driver or similar task.
+
 config BUILD_BIN2C
 	bool
 	default n
diff --git a/kernel/Makefile b/kernel/Makefile
index ed470aac53da..21c908c3083c 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -111,6 +111,7 @@ obj-$(CONFIG_CONTEXT_TRACKING) += context_tracking.o
 obj-$(CONFIG_TORTURE_TEST) += torture.o
 
 obj-$(CONFIG_HAS_IOMEM) += memremap.o
+obj-$(CONFIG_TASK_ISOLATION) += isolation.o
 
 $(obj)/configs.o: $(obj)/config_data.h
 
diff --git a/kernel/context_tracking.c b/kernel/context_tracking.c
index 9ad37b9e44a7..df0c7a07c11f 100644
--- a/kernel/context_tracking.c
+++ b/kernel/context_tracking.c
@@ -20,6 +20,7 @@
 #include <linux/hardirq.h>
 #include <linux/export.h>
 #include <linux/kprobes.h>
+#include <linux/isolation.h>
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/context_tracking.h>
@@ -156,6 +157,7 @@ void __context_tracking_exit(enum ctx_state state)
 			if (state == CONTEXT_USER) {
 				vtime_user_exit(current);
 				trace_user_exit(0);
+				task_isolation_user_exit();
 			}
 		}
 		__this_cpu_write(context_tracking.state, CONTEXT_KERNEL);
diff --git a/kernel/isolation.c b/kernel/isolation.c
new file mode 100644
index 000000000000..e2baa21af03a
--- /dev/null
+++ b/kernel/isolation.c
@@ -0,0 +1,402 @@
+/*
+ *  linux/kernel/isolation.c
+ *
+ *  Implementation for task isolation.
+ *
+ *  Distributed under GPLv2.
+ */
+
+#include <linux/mm.h>
+#include <linux/swap.h>
+#include <linux/vmstat.h>
+#include <linux/isolation.h>
+#include <linux/syscalls.h>
+#include <linux/smp.h>
+#include <linux/tick.h>
+#include <asm/unistd.h>
+#include <asm/syscall.h>
+#include "time/tick-sched.h"
+
+/*
+ * These values are stored in task_isolation_state.
+ * Note that STATE_NORMAL + TIF_TASK_ISOLATION means we are still
+ * returning from sys_prctl() to userspace.
+ */
+enum {
+	STATE_NORMAL = 0,	/* Not isolated */
+	STATE_ISOLATED = 1,	/* In userspace, isolated */
+	STATE_WARNED = 2	/* Like ISOLATED but console warning issued */
+};
+
+cpumask_var_t task_isolation_map;
+
+/* We can run on cpus that are isolated from the scheduler and are nohz_full. */
+static int __init task_isolation_init(void)
+{
+	if (alloc_cpumask_var(&task_isolation_map, GFP_KERNEL))
+		cpumask_and(task_isolation_map, cpu_isolated_map,
+			    tick_nohz_full_mask);
+
+	return 0;
+}
+core_initcall(task_isolation_init)
+
+static inline bool is_isolation_cpu(int cpu)
+{
+	return task_isolation_map != NULL &&
+		cpumask_test_cpu(cpu, task_isolation_map);
+}
+
+/* Enable stack backtraces of any interrupts of task_isolation cores. */
+static bool task_isolation_debug;
+static int __init task_isolation_debug_func(char *str)
+{
+	task_isolation_debug = true;
+	return 1;
+}
+__setup("task_isolation_debug", task_isolation_debug_func);
+
+/*
+ * Dump stack if need be. This can be helpful even from the final exit
+ * to usermode code since stack traces sometimes carry information about
+ * what put you into the kernel, e.g. an interrupt number encoded in
+ * the initial entry stack frame that is still visible at exit time.
+ */
+static void debug_dump_stack(void)
+{
+	if (task_isolation_debug)
+		dump_stack();
+}
+
+/*
+ * Set the flags word but don't try to actually start task isolation yet.
+ * We will start it when entering user space in task_isolation_start().
+ */
+int task_isolation_request(unsigned int flags)
+{
+	struct task_struct *task = current;
+
+	/*
+	 * The task isolation flags should always be cleared just by
+	 * virtue of having entered the kernel.
+	 */
+	WARN_ON_ONCE(test_tsk_thread_flag(task, TIF_TASK_ISOLATION));
+	WARN_ON_ONCE(task->task_isolation_flags != 0);
+	WARN_ON_ONCE(task->task_isolation_state != STATE_NORMAL);
+
+	task->task_isolation_flags = flags;
+	if (!(task->task_isolation_flags & PR_TASK_ISOLATION_ENABLE))
+		return 0;
+
+	/* We are trying to enable task isolation. */
+	set_tsk_thread_flag(task, TIF_TASK_ISOLATION);
+
+	/*
+	 * Shut down the vmstat worker so we're not interrupted later.
+	 * We have to try to do this here (with interrupts enabled) since
+	 * we are canceling delayed work and will call flush_work()
+	 * (which enables interrupts) and possibly schedule().
+	 */
+	quiet_vmstat_sync();
+
+	/* We return 0 here but we may change that in task_isolation_start(). */
+	return 0;
+}
+
+/* Disable task isolation in the specified task. */
+static void stop_isolation(struct task_struct *p)
+{
+	p->task_isolation_flags = 0;
+	p->task_isolation_state = STATE_NORMAL;
+	clear_tsk_thread_flag(p, TIF_TASK_ISOLATION);
+}
+
+/*
+ * This code runs with interrupts disabled just before the return to
+ * userspace, after a prctl() has requested enabling task isolation.
+ * We take whatever steps are needed to avoid being interrupted later:
+ * drain the lru pages, stop the scheduler tick, etc.  More
+ * functionality may be added here later to avoid other types of
+ * interrupts from other kernel subsystems.
+ *
+ * If we can't enable task isolation, we update the syscall return
+ * value with an appropriate error.
+ */
+void task_isolation_start(void)
+{
+	int error;
+
+	/*
+	 * We should only be called in STATE_NORMAL (isolation disabled),
+	 * on our way out of the kernel from the prctl() that turned it on.
+	 * If we are exiting from the kernel in another state, it means we
+	 * made it back into the kernel without disabling task isolation,
+	 * and we should investigate how (and in any case disable task
+	 * isolation at this point).  We are clearly not on the path back
+	 * from the prctl() so we don't touch the syscall return value.
+	 */
+	if (WARN_ON_ONCE(current->task_isolation_state != STATE_NORMAL)) {
+		stop_isolation(current);
+		return;
+	}
+
+	/*
+	 * Must be affinitized to a single core with task isolation possible.
+	 * In principle this could be remotely modified between the prctl()
+	 * and the return to userspace, so we have to check it here.
+	 */
+	if (cpumask_weight(&current->cpus_allowed) != 1 ||
+	    !is_isolation_cpu(smp_processor_id())) {
+		error = -EINVAL;
+		goto error;
+	}
+
+	/* If the vmstat delayed work is not canceled, we have to try again. */
+	if (!vmstat_idle()) {
+		error = -EAGAIN;
+		goto error;
+	}
+
+	/* Try to stop the dynamic tick. */
+	error = try_stop_full_tick();
+	if (error)
+		goto error;
+
+	/* Drain the pagevecs to avoid unnecessary IPI flushes later. */
+	lru_add_drain();
+
+	current->task_isolation_state = STATE_ISOLATED;
+	return;
+
+error:
+	stop_isolation(current);
+	syscall_set_return_value(current, current_pt_regs(), error, 0);
+}
+
+/* Stop task isolation on the remote task and send it a signal. */
+static void send_isolation_signal(struct task_struct *task)
+{
+	int flags = task->task_isolation_flags;
+	siginfo_t info = {
+		.si_signo = PR_TASK_ISOLATION_GET_SIG(flags) ?: SIGKILL,
+	};
+
+	stop_isolation(task);
+	send_sig_info(info.si_signo, &info, task);
+}
+
+/* Only a few syscalls are valid once we are in task isolation mode. */
+static bool is_acceptable_syscall(int syscall)
+{
+	/* No need to incur an isolation signal if we are just exiting. */
+	if (syscall == __NR_exit || syscall == __NR_exit_group)
+		return true;
+
+	/* Check to see if it's the prctl for isolation. */
+	if (syscall == __NR_prctl) {
+		unsigned long arg;
+
+		syscall_get_arguments(current, current_pt_regs(), 0, 1, &arg);
+		if (arg == PR_TASK_ISOLATION)
+			return true;
+	}
+
+	return false;
+}
+
+/*
+ * This routine is called from syscall entry, prevents most syscalls
+ * from executing, and if needed raises a signal to notify the process.
+ *
+ * Note that we have to stop isolation before we even print a message
+ * here, since otherwise we might end up reporting an interrupt due to
+ * kicking the printk handling code, rather than reporting the true
+ * cause of interrupt here.
+ */
+int task_isolation_syscall(int syscall)
+{
+	struct task_struct *task = current;
+
+	if (is_acceptable_syscall(syscall)) {
+		stop_isolation(task);
+		return 0;
+	}
+
+	send_isolation_signal(task);
+
+	pr_warn("%s/%d (cpu %d): task_isolation lost due to syscall %d\n",
+		task->comm, task->pid, smp_processor_id(), syscall);
+	debug_dump_stack();
+
+	syscall_set_return_value(task, current_pt_regs(), -ERESTARTNOINTR, -1);
+	return -1;
+}
+
+/*
+ * This routine is called from any exception or irq that doesn't
+ * otherwise trigger a signal to the user process (e.g. page fault).
+ * We don't warn if we are in STATE_WARNED in case a remote cpu already
+ * reported that it was going to interrupt us, so we don't generate
+ * a lot of confusingly similar messages about the same event.
+ */
+void _task_isolation_interrupt(const char *fmt, ...)
+{
+	struct task_struct *task = current;
+	va_list args;
+	char buf[100];
+	bool do_warn;
+
+	/* RCU should have been enabled prior to this point. */
+	RCU_LOCKDEP_WARN(!rcu_is_watching(), "kernel entry without RCU");
+
+	/*
+	 * Avoid reporting interrupts that happen after we have prctl'ed
+	 * to enable isolation, but before we have returned to userspace.
+	 */
+	if (task->task_isolation_state == STATE_NORMAL)
+		return;
+
+	do_warn = (task->task_isolation_state == STATE_ISOLATED);
+
+	va_start(args, fmt);
+	vsnprintf(buf, sizeof(buf), fmt, args);
+	va_end(args);
+
+	/* Handle NMIs minimally, since we can't send a signal. */
+	if (in_nmi()) {
+		pr_err("%s/%d (cpu %d): in NMI; not delivering signal\n",
+			task->comm, task->pid, smp_processor_id());
+	} else {
+		send_isolation_signal(task);
+	}
+
+	if (do_warn) {
+		pr_warn("%s/%d (cpu %d): task_isolation lost due to %s\n",
+			task->comm, task->pid, smp_processor_id(), buf);
+		debug_dump_stack();
+	}
+}
+
+/*
+ * Called before we wake up a task that has a signal to process.
+ * Needs to be done to handle interrupts that trigger signals, which
+ * we don't catch with task_isolation_interrupt() hooks.
+ */
+void _task_isolation_signal(struct task_struct *task)
+{
+	bool do_warn = (task->task_isolation_state == STATE_ISOLATED);
+
+	stop_isolation(task);
+	if (do_warn) {
+		pr_warn("%s/%d (cpu %d): task_isolation lost due to signal\n",
+			task->comm, task->pid, task_cpu(task));
+		debug_dump_stack();
+	}
+}
+
+/*
+ * Return a task_struct pointer (with ref count bumped up) for the
+ * specified cpu if the task running on that cpu at this moment is in
+ * isolation mode and hasn't yet been warned, otherwise NULL.
+ * In addition, toggle the task state to WARNED in anticipation of
+ * doing a printk, and send a reschedule IPI if needed.
+ */
+static struct task_struct *isolation_task(int cpu, int do_interrupt)
+{
+	struct task_struct *p = try_get_task_struct_on_cpu(cpu);
+
+	if (p == NULL)
+		return NULL;
+
+	if (p->task_isolation_state != STATE_ISOLATED)
+		goto bad_task;
+
+	/*
+	 * If we are claiming to be delivering a remote interrupt to our
+	 * own task, this has to be a bug, since here we are already in the
+	 * kernel, and somehow we didn't reset to STATE_NORMAL.
+	 */
+	if (WARN_ON_ONCE(p == current)) {
+		stop_isolation(p);
+		goto bad_task;
+	}
+
+	p->task_isolation_state = STATE_WARNED;
+	if (do_interrupt)
+		smp_send_reschedule(cpu);
+
+	return p;
+
+bad_task:
+	put_task_struct(p);
+	return NULL;
+}
+
+/*
+ * Generate a stack backtrace if we are going to interrupt another task
+ * isolation process.
+ */
+void _task_isolation_remote(int cpu, bool do_interrupt, const char *fmt, ...)
+{
+	struct task_struct *p;
+	va_list args;
+	char buf[200];
+
+	if (!is_isolation_cpu(cpu))
+		return;
+
+	p = isolation_task(cpu, do_interrupt);
+	if (p == NULL)
+		return;
+
+	va_start(args, fmt);
+	vsnprintf(buf, sizeof(buf), fmt, args);
+	va_end(args);
+	pr_warn("%s/%d (cpu %d): task_isolation lost due to %s by %s/%d on cpu %d\n",
+		p->comm, p->pid, cpu, buf,
+		current->comm, current->pid, smp_processor_id());
+	put_task_struct(p);
+	debug_dump_stack();
+}
+
+/*
+ * Generate a stack backtrace if any of the cpus in "mask" are running
+ * task isolation processes.
+ */
+void _task_isolation_remote_cpumask(const struct cpumask *mask,
+				    bool do_interrupt, const char *fmt, ...)
+{
+	struct task_struct *p = NULL;
+	cpumask_var_t warn_mask;
+	va_list args;
+	char buf[200];
+	int cpu;
+
+	if (task_isolation_map == NULL ||
+	    !zalloc_cpumask_var(&warn_mask, GFP_KERNEL))
+		return;
+
+	for_each_cpu_and(cpu, mask, task_isolation_map) {
+		if (p)
+			put_task_struct(p);
+		p = isolation_task(cpu, do_interrupt);
+		if (p)
+			cpumask_set_cpu(cpu, warn_mask);
+	}
+	if (p == NULL)
+		goto done;
+
+	va_start(args, fmt);
+	vsnprintf(buf, sizeof(buf), fmt, args);
+	va_end(args);
+	pr_warn("%s/%d %s %*pbl): task_isolation lost due to %s by %s/%d on cpu %d\n",
+		p->comm, p->pid,
+		cpumask_weight(warn_mask) == 1 ? "(cpu" : "etc (cpus",
+		cpumask_pr_args(warn_mask), buf,
+		current->comm, current->pid, smp_processor_id());
+	put_task_struct(p);
+	debug_dump_stack();
+
+done:
+	free_cpumask_var(warn_mask);
+}
diff --git a/kernel/signal.c b/kernel/signal.c
index 800a18f77732..fa4786050431 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -40,6 +40,7 @@
 #include <linux/cn_proc.h>
 #include <linux/compiler.h>
 #include <linux/posix-timers.h>
+#include <linux/isolation.h>
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/signal.h>
@@ -658,6 +659,7 @@ int dequeue_signal(struct task_struct *tsk, sigset_t *mask, siginfo_t *info)
  */
 void signal_wake_up_state(struct task_struct *t, unsigned int state)
 {
+	task_isolation_signal(t);
 	set_tsk_thread_flag(t, TIF_SIGPENDING);
 	/*
 	 * TASK_WAKEKILL also means wake it up in the stopped/traced/killable
diff --git a/kernel/sys.c b/kernel/sys.c
index 9aebc2935013..91ed79605768 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -41,6 +41,7 @@
 #include <linux/syscore_ops.h>
 #include <linux/version.h>
 #include <linux/ctype.h>
+#include <linux/isolation.h>
 
 #include <linux/compat.h>
 #include <linux/syscalls.h>
@@ -2385,6 +2386,11 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 	case PR_GET_FP_MODE:
 		error = GET_FP_MODE(me);
 		break;
+	case PR_TASK_ISOLATION:
+		if (arg3 || arg4 || arg5)
+			return -EINVAL;
+		error = task_isolation_request(arg2);
+		break;
 	default:
 		error = -EINVAL;
 		break;
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
