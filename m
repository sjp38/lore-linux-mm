From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [BUG][PATCH -mm] avoid BUG() in __stop_machine_run()
Date: Thu, 19 Jun 2008 20:12:43 +1000
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org> <485A03E6.2090509@hitachi.com>
In-Reply-To: <485A03E6.2090509@hitachi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200806192012.44459.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, sugita <yumiko.sugita.yf@hitachi.com>, Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Thursday 19 June 2008 16:59:50 Hidehiro Kawai wrote:
> When a process loads a kernel module, __stop_machine_run() is called, and
> it calls sched_setscheduler() to give newly created kernel threads highest
> priority.  However, the process can have no CAP_SYS_NICE which required
> for sched_setscheduler() to increase the priority.  For example, SystemTap
> loads its module with only CAP_SYS_MODULE.  In this case,
> sched_setscheduler() returns -EPERM, then BUG() is called.

Hi Hidehiro,

	Nice catch.  This can happen in the current code, it just doesn't
BUG().

> Failure of sched_setscheduler() wouldn't be a real problem, so this
> patch just ignores it.

	Well, it can mean that the stop_machine blocks indefinitely.  Better
than a BUG(), but we should aim higher.

> Or, should we give the CAP_SYS_NICE capability temporarily?

        I don't think so.  It can be seen from another thread, and in theory
that should not see something random.  Worse, they can change it from
another thread.

How's this?

sched_setscheduler: add a flag to control access checks

Hidehiro Kawai noticed that sched_setscheduler() can fail in
stop_machine: it calls sched_setscheduler() from insmod, which can
have CAP_SYS_MODULE without CAP_SYS_NICE.

This simply introduces a flag to allow us to disable the capability
checks for internal callers (this is simpler than splitting the
sched_setscheduler() function, since it loops checking permissions).

The flag is only "false" (ie. no check) for the following cases, where
it shouldn't matter:
  drivers/input/touchscreen/ucb1400_ts.c:ucb1400_ts_thread()
	- it's a kthread
  drivers/mmc/core/sdio_irq.c:sdio_irq_thread()
	- also a kthread
  kernel/kthread.c:create_kthread()
	- making a kthread (from kthreadd)
  kernel/softlockup.c:watchdog()
	- also a kthread

And these cases could have failed before:
  kernel/softirq.c:cpu_callback()
	- CPU hotplug callback
  kernel/stop_machine.c:__stop_machine_run()
	- Called from various places, including modprobe()

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff -r 509f0724da6b drivers/input/touchscreen/ucb1400_ts.c
--- a/drivers/input/touchscreen/ucb1400_ts.c	Thu Jun 19 17:06:30 2008 +1000
+++ b/drivers/input/touchscreen/ucb1400_ts.c	Thu Jun 19 19:36:40 2008 +1000
@@ -287,7 +287,7 @@ static int ucb1400_ts_thread(void *_ucb)
 	int valid = 0;
 	struct sched_param param = { .sched_priority = 1 };
 
-	sched_setscheduler(tsk, SCHED_FIFO, &param);
+	sched_setscheduler(tsk, SCHED_FIFO, &param, false);
 
 	set_freezable();
 	while (!kthread_should_stop()) {
diff -r 509f0724da6b drivers/mmc/core/sdio_irq.c
--- a/drivers/mmc/core/sdio_irq.c	Thu Jun 19 17:06:30 2008 +1000
+++ b/drivers/mmc/core/sdio_irq.c	Thu Jun 19 19:36:40 2008 +1000
@@ -70,7 +70,7 @@ static int sdio_irq_thread(void *_host)
 	unsigned long period, idle_period;
 	int ret;
 
-	sched_setscheduler(current, SCHED_FIFO, &param);
+	sched_setscheduler(current, SCHED_FIFO, &param, false);
 
 	/*
 	 * We want to allow for SDIO cards to work even on non SDIO
diff -r 509f0724da6b include/linux/sched.h
--- a/include/linux/sched.h	Thu Jun 19 17:06:30 2008 +1000
+++ b/include/linux/sched.h	Thu Jun 19 19:36:40 2008 +1000
@@ -1654,7 +1654,8 @@ extern int can_nice(const struct task_st
 extern int can_nice(const struct task_struct *p, const int nice);
 extern int task_curr(const struct task_struct *p);
 extern int idle_cpu(int cpu);
-extern int sched_setscheduler(struct task_struct *, int, struct sched_param *);
+extern int sched_setscheduler(struct task_struct *, int, struct sched_param *,
+			      bool);
 extern struct task_struct *idle_task(int cpu);
 extern struct task_struct *curr_task(int cpu);
 extern void set_curr_task(int cpu, struct task_struct *p);
diff -r 509f0724da6b kernel/kthread.c
--- a/kernel/kthread.c	Thu Jun 19 17:06:30 2008 +1000
+++ b/kernel/kthread.c	Thu Jun 19 19:36:40 2008 +1000
@@ -104,7 +104,7 @@ static void create_kthread(struct kthrea
 		 * root may have changed our (kthreadd's) priority or CPU mask.
 		 * The kernel thread should not inherit these properties.
 		 */
-		sched_setscheduler(create->result, SCHED_NORMAL, &param);
+		sched_setscheduler(create->result, SCHED_NORMAL, &param, false);
 		set_user_nice(create->result, KTHREAD_NICE_LEVEL);
 		set_cpus_allowed(create->result, CPU_MASK_ALL);
 	}
diff -r 509f0724da6b kernel/rtmutex-tester.c
--- a/kernel/rtmutex-tester.c	Thu Jun 19 17:06:30 2008 +1000
+++ b/kernel/rtmutex-tester.c	Thu Jun 19 19:36:40 2008 +1000
@@ -327,7 +327,8 @@ static ssize_t sysfs_test_command(struct
 	switch (op) {
 	case RTTEST_SCHEDOT:
 		schedpar.sched_priority = 0;
-		ret = sched_setscheduler(threads[tid], SCHED_NORMAL, &schedpar);
+		ret = sched_setscheduler(threads[tid], SCHED_NORMAL, &schedpar,
+					 true);
 		if (ret)
 			return ret;
 		set_user_nice(current, 0);
@@ -335,7 +336,8 @@ static ssize_t sysfs_test_command(struct
 
 	case RTTEST_SCHEDRT:
 		schedpar.sched_priority = dat;
-		ret = sched_setscheduler(threads[tid], SCHED_FIFO, &schedpar);
+		ret = sched_setscheduler(threads[tid], SCHED_FIFO, &schedpar,
+					 true);
 		if (ret)
 			return ret;
 		break;
diff -r 509f0724da6b kernel/sched.c
--- a/kernel/sched.c	Thu Jun 19 17:06:30 2008 +1000
+++ b/kernel/sched.c	Thu Jun 19 19:36:40 2008 +1000
@@ -4749,11 +4749,12 @@ __setscheduler(struct rq *rq, struct tas
  * @p: the task in question.
  * @policy: new policy.
  * @param: structure containing the new RT priority.
+ * @user: do checks to ensure this thread has permission
  *
  * NOTE that the task may be already dead.
  */
 int sched_setscheduler(struct task_struct *p, int policy,
-		       struct sched_param *param)
+		       struct sched_param *param, bool user)
 {
 	int retval, oldprio, oldpolicy = -1, on_rq, running;
 	unsigned long flags;
@@ -4785,7 +4786,7 @@ recheck:
 	/*
 	 * Allow unprivileged RT tasks to decrease priority:
 	 */
-	if (!capable(CAP_SYS_NICE)) {
+	if (user && !capable(CAP_SYS_NICE)) {
 		if (rt_policy(policy)) {
 			unsigned long rlim_rtprio;
 
@@ -4821,7 +4822,8 @@ recheck:
 	 * Do not allow realtime tasks into groups that have no runtime
 	 * assigned.
 	 */
-	if (rt_policy(policy) && task_group(p)->rt_bandwidth.rt_runtime == 0)
+	if (user
+	    && rt_policy(policy) && task_group(p)->rt_bandwidth.rt_runtime == 0)
 		return -EPERM;
 #endif
 
@@ -4888,7 +4890,7 @@ do_sched_setscheduler(pid_t pid, int pol
 	retval = -ESRCH;
 	p = find_process_by_pid(pid);
 	if (p != NULL)
-		retval = sched_setscheduler(p, policy, &lparam);
+		retval = sched_setscheduler(p, policy, &lparam, true);
 	rcu_read_unlock();
 
 	return retval;
diff -r 509f0724da6b kernel/softirq.c
--- a/kernel/softirq.c	Thu Jun 19 17:06:30 2008 +1000
+++ b/kernel/softirq.c	Thu Jun 19 19:36:40 2008 +1000
@@ -645,7 +645,7 @@ static int __cpuinit cpu_callback(struct
 
 		p = per_cpu(ksoftirqd, hotcpu);
 		per_cpu(ksoftirqd, hotcpu) = NULL;
-		sched_setscheduler(p, SCHED_FIFO, &param);
+		sched_setscheduler(p, SCHED_FIFO, &param, false);
 		kthread_stop(p);
 		takeover_tasklets(hotcpu);
 		break;
diff -r 509f0724da6b kernel/softlockup.c
--- a/kernel/softlockup.c	Thu Jun 19 17:06:30 2008 +1000
+++ b/kernel/softlockup.c	Thu Jun 19 19:36:40 2008 +1000
@@ -211,7 +211,7 @@ static int watchdog(void *__bind_cpu)
 	struct sched_param param = { .sched_priority = MAX_RT_PRIO-1 };
 	int this_cpu = (long)__bind_cpu;
 
-	sched_setscheduler(current, SCHED_FIFO, &param);
+	sched_setscheduler(current, SCHED_FIFO, &param, false);
 
 	/* initialize timestamp */
 	touch_softlockup_watchdog();
diff -r 509f0724da6b kernel/stop_machine.c
--- a/kernel/stop_machine.c	Thu Jun 19 17:06:30 2008 +1000
+++ b/kernel/stop_machine.c	Thu Jun 19 19:36:40 2008 +1000
@@ -187,7 +187,7 @@ struct task_struct *__stop_machine_run(i
 		struct sched_param param = { .sched_priority = MAX_RT_PRIO-1 };
 
 		/* One high-prio thread per cpu.  We'll do this one. */
-		sched_setscheduler(p, SCHED_FIFO, &param);
+		sched_setscheduler(p, SCHED_FIFO, &param, false);
 		kthread_bind(p, cpu);
 		wake_up_process(p);
 		wait_for_completion(&smdata.done);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
