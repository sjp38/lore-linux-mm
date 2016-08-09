Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B1BA96B025F
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 16:30:17 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 1so34650818wmz.2
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 13:30:17 -0700 (PDT)
Received: from mellanox.co.il (mail-il-dmz.mellanox.com. [193.47.165.129])
        by mx.google.com with ESMTP id jf5si6177966wjb.108.2016.08.09.13.30.12
        for <linux-mm@kvack.org>;
        Tue, 09 Aug 2016 13:30:13 -0700 (PDT)
From: Chris Metcalf <cmetcalf@mellanox.com>
Subject: [PATCH v14 04/14] task_isolation: add initial support
Date: Tue,  9 Aug 2016 16:29:46 -0400
Message-Id: <1470774596-17341-5-git-send-email-cmetcalf@mellanox.com>
In-Reply-To: <1470774596-17341-1-git-send-email-cmetcalf@mellanox.com>
References: <1470774596-17341-1-git-send-email-cmetcalf@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben Yossef <giladb@mellanox.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Frederic Weisbecker <fweisbec@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Viresh Kumar <viresh.kumar@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org
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
prctl(PR_SET_TASK_ISOLATION, PR_TASK_ISOLATION_ENABLE) to do so.
Subsequent commits will add additional flags and additional
semantics.

The kernel must be built with the new TASK_ISOLATION Kconfig flag
to enable this mode, and the kernel booted with an appropriate
task_isolation=CPULIST boot argument, which enables nohz_full and
isolcpus as well.  The "task_isolation" state is then indicated by
setting a new task struct field, task_isolation_flag, to the value
passed by prctl(), and also setting a TIF_TASK_ISOLATION bit in
thread_info flags.  When task isolation is enabled for a task, and it
is returning to userspace on a task isolation core, it calls the
new task_isolation_ready() / task_isolation_enter() routines to
take additional actions to help the task avoid being interrupted
in the future.

The task_isolation_ready() call is invoked when TIF_TASK_ISOLATION is
set in prepare_exit_to_usermode() or its architectural equivalent,
and forces the loop to retry if the system is not ready.  It is
called with interrupts disabled and inspects the kernel state
to determine if it is safe to return into an isolated state.
In particular, if it sees that the scheduler tick is still enabled,
it reports that it is not yet safe.

Each time through the loop of TIF work to do, if TIF_TASK_ISOLATION
is set, we call the new task_isolation_enter() routine.  This
takes any actions that might avoid a future interrupt to the core,
such as a worker thread being scheduled that could be quiesced now
(e.g. the vmstat worker) or a future IPI to the core to clean up some
state that could be cleaned up now (e.g. the mm lru per-cpu cache).
In addition, it reqeusts rescheduling if the scheduler dyntick is
still running.

Once the task has returned to userspace after issuing the prctl(),
if it enters the kernel again via system call, page fault, or any
of a number of other synchronous traps, the kernel will kill it
with SIGKILL.  For system calls, this test is performed immediately
before the SECCOMP test and causes the syscall to return immediately
with ENOSYS.

To allow the state to be entered and exited, the syscall checking
test ignores the prctl() syscall so that we can clear the bit again
later, and ignores exit/exit_group to allow exiting the task without
a pointless signal killing you as you try to do so.

A new /sys/devices/system/cpu/task_isolation pseudo-file is added,
parallel to the comparable nohz_full file.

Separate patches that follow provide these changes for x86, tile,
and arm64.

Signed-off-by: Chris Metcalf <cmetcalf@mellanox.com>
---
 Documentation/kernel-parameters.txt |   8 ++
 drivers/base/cpu.c                  |  18 +++
 include/linux/isolation.h           |  60 ++++++++++
 include/linux/sched.h               |   3 +
 include/linux/tick.h                |   2 +
 include/uapi/linux/prctl.h          |   5 +
 init/Kconfig                        |  27 +++++
 kernel/Makefile                     |   1 +
 kernel/fork.c                       |   3 +
 kernel/isolation.c                  | 217 ++++++++++++++++++++++++++++++++++++
 kernel/signal.c                     |   8 ++
 kernel/sys.c                        |   9 ++
 kernel/time/tick-sched.c            |  36 +++---
 13 files changed, 384 insertions(+), 13 deletions(-)
 create mode 100644 include/linux/isolation.h
 create mode 100644 kernel/isolation.c

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 46c030a49186..7f1336b50dcc 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -3943,6 +3943,14 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			neutralize any effect of /proc/sys/kernel/sysrq.
 			Useful for debugging.
 
+	task_isolation=	[KNL]
+			In kernels built with CONFIG_TASK_ISOLATION=y, set
+			the specified list of CPUs where cpus will be able
+			to use prctl(PR_SET_TASK_ISOLATION) to set up task
+			isolation mode.  Setting this boot flag implicitly
+			also sets up nohz_full and isolcpus mode for the
+			listed set of cpus.
+
 	tcpmhash_entries= [KNL,NET]
 			Set the number of tcp_metrics_hash slots.
 			Default value is 8192 or 16384 depending on total
diff --git a/drivers/base/cpu.c b/drivers/base/cpu.c
index 691eeea2f19a..eaf40f4264ee 100644
--- a/drivers/base/cpu.c
+++ b/drivers/base/cpu.c
@@ -17,6 +17,7 @@
 #include <linux/of.h>
 #include <linux/cpufeature.h>
 #include <linux/tick.h>
+#include <linux/isolation.h>
 
 #include "base.h"
 
@@ -290,6 +291,20 @@ static ssize_t print_cpus_nohz_full(struct device *dev,
 static DEVICE_ATTR(nohz_full, 0444, print_cpus_nohz_full, NULL);
 #endif
 
+#ifdef CONFIG_TASK_ISOLATION
+static ssize_t print_cpus_task_isolation(struct device *dev,
+					 struct device_attribute *attr,
+					 char *buf)
+{
+	int n = 0, len = PAGE_SIZE-2;
+
+	n = scnprintf(buf, len, "%*pbl\n", cpumask_pr_args(task_isolation_map));
+
+	return n;
+}
+static DEVICE_ATTR(task_isolation, 0444, print_cpus_task_isolation, NULL);
+#endif
+
 static void cpu_device_release(struct device *dev)
 {
 	/*
@@ -460,6 +475,9 @@ static struct attribute *cpu_root_attrs[] = {
 #ifdef CONFIG_NO_HZ_FULL
 	&dev_attr_nohz_full.attr,
 #endif
+#ifdef CONFIG_TASK_ISOLATION
+	&dev_attr_task_isolation.attr,
+#endif
 #ifdef CONFIG_GENERIC_CPU_AUTOPROBE
 	&dev_attr_modalias.attr,
 #endif
diff --git a/include/linux/isolation.h b/include/linux/isolation.h
new file mode 100644
index 000000000000..d9288b85b41f
--- /dev/null
+++ b/include/linux/isolation.h
@@ -0,0 +1,60 @@
+/*
+ * Task isolation related global functions
+ */
+#ifndef _LINUX_ISOLATION_H
+#define _LINUX_ISOLATION_H
+
+#include <linux/tick.h>
+#include <linux/prctl.h>
+
+#ifdef CONFIG_TASK_ISOLATION
+
+/* cpus that are configured to support task isolation */
+extern cpumask_var_t task_isolation_map;
+
+extern int task_isolation_init(void);
+
+static inline bool task_isolation_possible(int cpu)
+{
+	return task_isolation_map != NULL &&
+		cpumask_test_cpu(cpu, task_isolation_map);
+}
+
+extern int task_isolation_set(unsigned int flags);
+
+extern bool task_isolation_ready(void);
+extern void task_isolation_enter(void);
+
+static inline void task_isolation_set_flags(struct task_struct *p,
+					    unsigned int flags)
+{
+	p->task_isolation_flags = flags;
+
+	if (flags & PR_TASK_ISOLATION_ENABLE)
+		set_tsk_thread_flag(p, TIF_TASK_ISOLATION);
+	else
+		clear_tsk_thread_flag(p, TIF_TASK_ISOLATION);
+}
+
+extern int task_isolation_syscall(int nr);
+
+/* Report on exceptions that don't cause a signal for the user process. */
+extern void _task_isolation_quiet_exception(const char *fmt, ...);
+#define task_isolation_quiet_exception(fmt, ...)			\
+	do {								\
+		if (current_thread_info()->flags & _TIF_TASK_ISOLATION) \
+			_task_isolation_quiet_exception(fmt, ## __VA_ARGS__); \
+	} while (0)
+
+#else
+static inline void task_isolation_init(void) { }
+static inline bool task_isolation_possible(int cpu) { return false; }
+static inline bool task_isolation_ready(void) { return true; }
+static inline void task_isolation_enter(void) { }
+extern inline void task_isolation_set_flags(struct task_struct *p,
+					    unsigned int flags) { }
+static inline int task_isolation_syscall(int nr) { return 0; }
+static inline void task_isolation_quiet_exception(const char *fmt, ...) { }
+#endif
+
+#endif
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 62c68e513e39..77dc12cd4fe8 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1923,6 +1923,9 @@ struct task_struct {
 #ifdef CONFIG_MMU
 	struct task_struct *oom_reaper_list;
 #endif
+#ifdef CONFIG_TASK_ISOLATION
+	unsigned int	task_isolation_flags;
+#endif
 /* CPU-specific state of this task */
 	struct thread_struct thread;
 /*
diff --git a/include/linux/tick.h b/include/linux/tick.h
index 62be0786d6d0..fbd81e322860 100644
--- a/include/linux/tick.h
+++ b/include/linux/tick.h
@@ -235,6 +235,8 @@ static inline void tick_dep_clear_signal(struct signal_struct *signal,
 
 extern void tick_nohz_full_kick_cpu(int cpu);
 extern void __tick_nohz_task_switch(void);
+extern void tick_nohz_full_add_cpus(const struct cpumask *mask);
+extern bool can_stop_my_full_tick(void);
 #else
 static inline int housekeeping_any_cpu(void)
 {
diff --git a/include/uapi/linux/prctl.h b/include/uapi/linux/prctl.h
index a8d0759a9e40..2a49d0d2940a 100644
--- a/include/uapi/linux/prctl.h
+++ b/include/uapi/linux/prctl.h
@@ -197,4 +197,9 @@ struct prctl_mm_map {
 # define PR_CAP_AMBIENT_LOWER		3
 # define PR_CAP_AMBIENT_CLEAR_ALL	4
 
+/* Enable/disable or query task_isolation mode for TASK_ISOLATION kernels. */
+#define PR_SET_TASK_ISOLATION		48
+#define PR_GET_TASK_ISOLATION		49
+# define PR_TASK_ISOLATION_ENABLE	(1 << 0)
+
 #endif /* _LINUX_PRCTL_H */
diff --git a/init/Kconfig b/init/Kconfig
index 69886493ff1e..85a4b6dd26f2 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -786,6 +786,33 @@ config RCU_EXPEDITE_BOOT
 
 endmenu # "RCU Subsystem"
 
+config HAVE_ARCH_TASK_ISOLATION
+	bool
+
+config TASK_ISOLATION
+	bool "Provide hard CPU isolation from the kernel on demand"
+	depends on NO_HZ_FULL && HAVE_ARCH_TASK_ISOLATION
+	help
+	 Allow userspace processes to place themselves on task_isolation
+	 cores and run prctl(PR_SET_TASK_ISOLATION) to "isolate"
+	 themselves from the kernel.  Prior to returning to userspace,
+	 isolated tasks will arrange that no future kernel
+	 activity will interrupt the task while the task is running
+	 in userspace.  By default, attempting to re-enter the kernel
+	 while in this mode will cause the task to be terminated
+	 with a signal; you must explicitly use prctl() to disable
+	 task isolation before resuming normal use of the kernel.
+
+	 This "hard" isolation from the kernel is required for
+	 userspace tasks that are running hard real-time tasks in
+	 userspace, such as a 10 Gbit network driver in userspace.
+	 Without this option, but with NO_HZ_FULL enabled, the kernel
+	 will make a best-faith, "soft" effort to shield a single userspace
+	 process from interrupts, but makes no guarantees.
+
+	 You should say "N" unless you are intending to run a
+	 high-performance userspace driver or similar task.
+
 config BUILD_BIN2C
 	bool
 	default n
diff --git a/kernel/Makefile b/kernel/Makefile
index e2ec54e2b952..91ff1615f4d6 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -112,6 +112,7 @@ obj-$(CONFIG_TORTURE_TEST) += torture.o
 obj-$(CONFIG_MEMBARRIER) += membarrier.o
 
 obj-$(CONFIG_HAS_IOMEM) += memremap.o
+obj-$(CONFIG_TASK_ISOLATION) += isolation.o
 
 $(obj)/configs.o: $(obj)/config_data.h
 
diff --git a/kernel/fork.c b/kernel/fork.c
index 52e725d4a866..54542266d7a8 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -76,6 +76,7 @@
 #include <linux/compiler.h>
 #include <linux/sysctl.h>
 #include <linux/kcov.h>
+#include <linux/isolation.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -1533,6 +1534,8 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 #endif
 	clear_all_latency_tracing(p);
 
+	task_isolation_set_flags(p, 0);
+
 	/* ok, now we should be set up.. */
 	p->pid = pid_nr(pid);
 	if (clone_flags & CLONE_THREAD) {
diff --git a/kernel/isolation.c b/kernel/isolation.c
new file mode 100644
index 000000000000..bf3ebb0a727c
--- /dev/null
+++ b/kernel/isolation.c
@@ -0,0 +1,217 @@
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
+#include <asm/unistd.h>
+#include <asm/syscall.h>
+#include "time/tick-sched.h"
+
+cpumask_var_t task_isolation_map;
+static bool saw_boot_arg;
+
+/*
+ * Isolation requires both nohz and isolcpus support from the scheduler.
+ * We provide a boot flag that enables both for now, and which we can
+ * add other functionality to over time if needed.  Note that just
+ * specifying "nohz_full=... isolcpus=..." does not enable task isolation.
+ */
+static int __init task_isolation_setup(char *str)
+{
+	saw_boot_arg = true;
+
+	alloc_bootmem_cpumask_var(&task_isolation_map);
+	if (cpulist_parse(str, task_isolation_map) < 0) {
+		pr_warn("task_isolation: Incorrect cpumask '%s'\n", str);
+		return 1;
+	}
+
+	return 1;
+}
+__setup("task_isolation=", task_isolation_setup);
+
+int __init task_isolation_init(void)
+{
+	/* For offstack cpumask, ensure we allocate an empty cpumask early. */
+	if (!saw_boot_arg) {
+		zalloc_cpumask_var(&task_isolation_map, GFP_KERNEL);
+		return 0;
+	}
+
+	/*
+	 * Add our task_isolation cpus to nohz_full and isolcpus.  Note
+	 * that we are called relatively early in boot, from tick_init();
+	 * at this point neither nohz_full nor isolcpus has been used
+	 * to configure the system, but isolcpus has been allocated
+	 * already in sched_init().
+	 */
+	tick_nohz_full_add_cpus(task_isolation_map);
+	cpumask_or(cpu_isolated_map, cpu_isolated_map, task_isolation_map);
+
+	return 0;
+}
+
+/*
+ * Get a snapshot of whether, at this moment, it would be possible to
+ * stop the tick.  This test normally requires interrupts disabled since
+ * the condition can change if an interrupt is delivered.  However, in
+ * this case we are using it in an advisory capacity to see if there
+ * is anything obviously indicating that the task isolation
+ * preconditions have not been met, so it's OK that in principle it
+ * might not still be true later in the prctl() syscall path.
+ */
+static bool can_stop_my_full_tick_now(void)
+{
+	bool ret;
+
+	local_irq_disable();
+	ret = can_stop_my_full_tick();
+	local_irq_enable();
+	return ret;
+}
+
+/*
+ * This routine controls whether we can enable task-isolation mode.
+ * The task must be affinitized to a single task_isolation core, or
+ * else we return EINVAL.  And, it must be at least statically able to
+ * stop the nohz_full tick (e.g., no other schedulable tasks currently
+ * running, no POSIX cpu timers currently set up, etc.); if not, we
+ * return EAGAIN.
+ */
+int task_isolation_set(unsigned int flags)
+{
+	if (flags != 0) {
+		if (cpumask_weight(tsk_cpus_allowed(current)) != 1 ||
+		    !task_isolation_possible(raw_smp_processor_id())) {
+			/* Invalid task affinity setting. */
+			return -EINVAL;
+		}
+		if (!can_stop_my_full_tick_now()) {
+			/* System not yet ready for task isolation. */
+			return -EAGAIN;
+		}
+	}
+
+	task_isolation_set_flags(current, flags);
+	return 0;
+}
+
+/*
+ * In task isolation mode we try to return to userspace only after
+ * attempting to make sure we won't be interrupted again.  This test
+ * is run with interrupts disabled to test that everything we need
+ * to be true is true before we can return to userspace.
+ */
+bool task_isolation_ready(void)
+{
+	WARN_ON_ONCE(!irqs_disabled());
+
+	return (!lru_add_drain_needed(smp_processor_id()) &&
+		vmstat_idle() &&
+		tick_nohz_tick_stopped());
+}
+
+/*
+ * Each time we try to prepare for return to userspace in a process
+ * with task isolation enabled, we run this code to quiesce whatever
+ * subsystems we can readily quiesce to avoid later interrupts.
+ */
+void task_isolation_enter(void)
+{
+	WARN_ON_ONCE(irqs_disabled());
+
+	/* Drain the pagevecs to avoid unnecessary IPI flushes later. */
+	lru_add_drain();
+
+	/* Quieten the vmstat worker so it won't interrupt us. */
+	quiet_vmstat_sync();
+
+	/*
+	 * Request rescheduling unless we are in full dynticks mode.
+	 * We would eventually get pre-empted without this, and if
+	 * there's another task waiting, it would run; but by
+	 * explicitly requesting the reschedule, we may reduce the
+	 * latency.  We could directly call schedule() here as well,
+	 * but since our caller is the standard place where schedule()
+	 * is called, we defer to the caller.
+	 *
+	 * A more substantive approach here would be to use a struct
+	 * completion here explicitly, and complete it when we shut
+	 * down dynticks, but since we presumably have nothing better
+	 * to do on this core anyway, just spinning seems plausible.
+	 */
+	if (!tick_nohz_tick_stopped())
+		set_tsk_need_resched(current);
+}
+
+static void task_isolation_deliver_signal(struct task_struct *task,
+					  const char *buf)
+{
+	siginfo_t info = {};
+
+	info.si_signo = SIGKILL;
+
+	/*
+	 * Report on the fact that isolation was violated for the task.
+	 * It may not be the task's fault (e.g. a TLB flush from another
+	 * core) but we are not blaming it, just reporting that it lost
+	 * its isolation status.
+	 */
+	pr_warn("%s/%d: task_isolation mode lost due to %s\n",
+		task->comm, task->pid, buf);
+
+	/* Turn off task isolation mode to avoid further isolation callbacks. */
+	task_isolation_set_flags(task, 0);
+
+	send_sig_info(info.si_signo, &info, task);
+}
+
+/*
+ * This routine is called from any userspace exception that doesn't
+ * otherwise trigger a signal to the user process (e.g. simple page fault).
+ */
+void _task_isolation_quiet_exception(const char *fmt, ...)
+{
+	struct task_struct *task = current;
+	va_list args;
+	char buf[100];
+
+	/* RCU should have been enabled prior to this point. */
+	RCU_LOCKDEP_WARN(!rcu_is_watching(), "kernel entry without RCU");
+
+	va_start(args, fmt);
+	vsnprintf(buf, sizeof(buf), fmt, args);
+	va_end(args);
+
+	task_isolation_deliver_signal(task, buf);
+}
+
+/*
+ * This routine is called from syscall entry (with the syscall number
+ * passed in), and prevents most syscalls from executing and raises a
+ * signal to notify the process.
+ */
+int task_isolation_syscall(int syscall)
+{
+	char buf[20];
+
+	if (syscall == __NR_prctl ||
+	    syscall == __NR_exit ||
+	    syscall == __NR_exit_group)
+		return 0;
+
+	snprintf(buf, sizeof(buf), "syscall %d", syscall);
+	task_isolation_deliver_signal(current, buf);
+
+	syscall_set_return_value(current, current_pt_regs(),
+					 -ERESTARTNOINTR, -1);
+	return -1;
+}
diff --git a/kernel/signal.c b/kernel/signal.c
index af21afc00d08..895f547ff66f 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -34,6 +34,7 @@
 #include <linux/compat.h>
 #include <linux/cn_proc.h>
 #include <linux/compiler.h>
+#include <linux/isolation.h>
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/signal.h>
@@ -2213,6 +2214,13 @@ relock:
 		/* Trace actually delivered signals. */
 		trace_signal_deliver(signr, &ksig->info, ka);
 
+		/*
+		 * Disable task isolation when delivering a signal.
+		 * The isolation model requires users to reset task
+		 * isolation from the signal handler if desired.
+		 */
+		task_isolation_set_flags(current, 0);
+
 		if (ka->sa.sa_handler == SIG_IGN) /* Do nothing.  */
 			continue;
 		if (ka->sa.sa_handler != SIG_DFL) {
diff --git a/kernel/sys.c b/kernel/sys.c
index 89d5be418157..4df84af425e3 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -41,6 +41,7 @@
 #include <linux/syscore_ops.h>
 #include <linux/version.h>
 #include <linux/ctype.h>
+#include <linux/isolation.h>
 
 #include <linux/compat.h>
 #include <linux/syscalls.h>
@@ -2270,6 +2271,14 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 	case PR_GET_FP_MODE:
 		error = GET_FP_MODE(me);
 		break;
+#ifdef CONFIG_TASK_ISOLATION
+	case PR_SET_TASK_ISOLATION:
+		error = task_isolation_set(arg2);
+		break;
+	case PR_GET_TASK_ISOLATION:
+		error = me->task_isolation_flags;
+		break;
+#endif
 	default:
 		error = -EINVAL;
 		break;
diff --git a/kernel/time/tick-sched.c b/kernel/time/tick-sched.c
index 204fdc86863d..a6e29527743e 100644
--- a/kernel/time/tick-sched.c
+++ b/kernel/time/tick-sched.c
@@ -23,6 +23,7 @@
 #include <linux/irq_work.h>
 #include <linux/posix-timers.h>
 #include <linux/context_tracking.h>
+#include <linux/isolation.h>
 
 #include <asm/irq_regs.h>
 
@@ -205,6 +206,11 @@ static bool can_stop_full_tick(struct tick_sched *ts)
 	return true;
 }
 
+bool can_stop_my_full_tick(void)
+{
+	return can_stop_full_tick(this_cpu_ptr(&tick_cpu_sched));
+}
+
 static void nohz_full_kick_func(struct irq_work *work)
 {
 	/* Empty, the tick restart happens on tick_nohz_irq_exit() */
@@ -407,30 +413,34 @@ static int tick_nohz_cpu_down_callback(struct notifier_block *nfb,
 	return NOTIFY_OK;
 }
 
-static int tick_nohz_init_all(void)
+void tick_nohz_full_add_cpus(const struct cpumask *mask)
 {
-	int err = -1;
+	if (!cpumask_weight(mask))
+		return;
 
-#ifdef CONFIG_NO_HZ_FULL_ALL
-	if (!alloc_cpumask_var(&tick_nohz_full_mask, GFP_KERNEL)) {
+	if (tick_nohz_full_mask == NULL &&
+	    !zalloc_cpumask_var(&tick_nohz_full_mask, GFP_KERNEL)) {
 		WARN(1, "NO_HZ: Can't allocate full dynticks cpumask\n");
-		return err;
+		return;
 	}
-	err = 0;
-	cpumask_setall(tick_nohz_full_mask);
+
+	cpumask_or(tick_nohz_full_mask, tick_nohz_full_mask, mask);
 	tick_nohz_full_running = true;
-#endif
-	return err;
 }
 
 void __init tick_nohz_init(void)
 {
 	int cpu;
 
-	if (!tick_nohz_full_running) {
-		if (tick_nohz_init_all() < 0)
-			return;
-	}
+	task_isolation_init();
+
+#ifdef CONFIG_NO_HZ_FULL_ALL
+	if (!tick_nohz_full_running)
+		tick_nohz_full_add_cpus(cpu_possible_mask);
+#endif
+
+	if (!tick_nohz_full_running)
+		return;
 
 	if (!alloc_cpumask_var(&housekeeping_mask, GFP_KERNEL)) {
 		WARN(1, "NO_HZ: Can't allocate not-full dynticks cpumask\n");
-- 
2.7.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
