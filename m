Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 07E476B01AD
	for <linux-mm@kvack.org>; Mon,  5 Jul 2010 20:52:02 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o660pcI2028952
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 6 Jul 2010 09:51:38 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3136845DE4F
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 09:51:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1009D45DE4E
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 09:51:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EA7E61DB8038
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 09:51:37 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A383C1DB8037
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 09:51:34 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/2] sched: make sched_param arugment static variables in some sched_setscheduler() caller
In-Reply-To: <20100706091607.CCCC.A69D9226@jp.fujitsu.com>
References: <20100702144941.8fa101c3.akpm@linux-foundation.org> <20100706091607.CCCC.A69D9226@jp.fujitsu.com>
Message-Id: <20100706095013.CCD9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  6 Jul 2010 09:51:33 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, James Morris <jmorris@namei.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton pointed out almost sched_setscheduler() caller are
using fixed parameter and it can be converted static. it reduce
runtume memory waste a bit.

Reported-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/sched.h         |    5 +++--
 kernel/irq/manage.c           |    4 +++-
 kernel/kthread.c              |    2 +-
 kernel/sched.c                |    6 +++---
 kernel/softirq.c              |    4 +++-
 kernel/stop_machine.c         |    2 +-
 kernel/trace/trace_selftest.c |    2 +-
 kernel/watchdog.c             |    2 +-
 kernel/workqueue.c            |    2 +-
 9 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index cfcd13e..97b7fe3 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1917,9 +1917,10 @@ extern int task_nice(const struct task_struct *p);
 extern int can_nice(const struct task_struct *p, const int nice);
 extern int task_curr(const struct task_struct *p);
 extern int idle_cpu(int cpu);
-extern int sched_setscheduler(struct task_struct *, int, struct sched_param *);
+extern int sched_setscheduler(struct task_struct *, int,
+			      const struct sched_param *);
 extern int sched_setscheduler_nocheck(struct task_struct *, int,
-				      struct sched_param *);
+				      const struct sched_param *);
 extern struct task_struct *idle_task(int cpu);
 extern struct task_struct *curr_task(int cpu);
 extern void set_curr_task(int cpu, struct task_struct *p);
diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index 3164ba7..ce1dbb8 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -569,7 +569,9 @@ irq_thread_check_affinity(struct irq_desc *desc, struct irqaction *action) { }
  */
 static int irq_thread(void *data)
 {
-	struct sched_param param = { .sched_priority = MAX_USER_RT_PRIO/2, };
+	static struct sched_param param = {
+		.sched_priority = MAX_USER_RT_PRIO/2,
+	};
 	struct irqaction *action = data;
 	struct irq_desc *desc = irq_to_desc(action->irq);
 	int wake, oneshot = desc->status & IRQ_ONESHOT;
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 83911c7..3b55a26 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -131,7 +131,7 @@ struct task_struct *kthread_create(int (*threadfn)(void *data),
 	wait_for_completion(&create.done);
 
 	if (!IS_ERR(create.result)) {
-		struct sched_param param = { .sched_priority = 0 };
+		static struct sched_param param = { .sched_priority = 0 };
 		va_list args;
 
 		va_start(args, namefmt);
diff --git a/kernel/sched.c b/kernel/sched.c
index 18faf4d..8f2f4b4 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -4396,7 +4396,7 @@ static bool check_same_owner(struct task_struct *p)
 }
 
 static int __sched_setscheduler(struct task_struct *p, int policy,
-				struct sched_param *param, bool user)
+				const struct sched_param *param, bool user)
 {
 	int retval, oldprio, oldpolicy = -1, on_rq, running;
 	unsigned long flags;
@@ -4540,7 +4540,7 @@ recheck:
  * NOTE that the task may be already dead.
  */
 int sched_setscheduler(struct task_struct *p, int policy,
-		       struct sched_param *param)
+		       const struct sched_param *param)
 {
 	return __sched_setscheduler(p, policy, param, true);
 }
@@ -4558,7 +4558,7 @@ EXPORT_SYMBOL_GPL(sched_setscheduler);
  * but our caller might not have that capability.
  */
 int sched_setscheduler_nocheck(struct task_struct *p, int policy,
-			       struct sched_param *param)
+			       const struct sched_param *param)
 {
 	return __sched_setscheduler(p, policy, param, false);
 }
diff --git a/kernel/softirq.c b/kernel/softirq.c
index 07b4f1b..be3ec11 100644
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -827,7 +827,9 @@ static int __cpuinit cpu_callback(struct notifier_block *nfb,
 			     cpumask_any(cpu_online_mask));
 	case CPU_DEAD:
 	case CPU_DEAD_FROZEN: {
-		struct sched_param param = { .sched_priority = MAX_RT_PRIO-1 };
+		static struct sched_param param = {
+			.sched_priority = MAX_RT_PRIO-1
+		};
 
 		p = per_cpu(ksoftirqd, hotcpu);
 		per_cpu(ksoftirqd, hotcpu) = NULL;
diff --git a/kernel/stop_machine.c b/kernel/stop_machine.c
index 70f8d90..da9bb42 100644
--- a/kernel/stop_machine.c
+++ b/kernel/stop_machine.c
@@ -291,7 +291,7 @@ repeat:
 static int __cpuinit cpu_stop_cpu_callback(struct notifier_block *nfb,
 					   unsigned long action, void *hcpu)
 {
-	struct sched_param param = { .sched_priority = MAX_RT_PRIO - 1 };
+	static struct sched_param param = { .sched_priority = MAX_RT_PRIO - 1 };
 	unsigned int cpu = (unsigned long)hcpu;
 	struct cpu_stopper *stopper = &per_cpu(cpu_stopper, cpu);
 	struct task_struct *p;
diff --git a/kernel/trace/trace_selftest.c b/kernel/trace/trace_selftest.c
index 250e7f9..d2ebe6e 100644
--- a/kernel/trace/trace_selftest.c
+++ b/kernel/trace/trace_selftest.c
@@ -560,7 +560,7 @@ trace_selftest_startup_nop(struct tracer *trace, struct trace_array *tr)
 static int trace_wakeup_test_thread(void *data)
 {
 	/* Make this a RT thread, doesn't need to be too high */
-	struct sched_param param = { .sched_priority = 5 };
+	static struct sched_param param = { .sched_priority = 5 };
 	struct completion *x = data;
 
 	sched_setscheduler(current, SCHED_FIFO, &param);
diff --git a/kernel/watchdog.c b/kernel/watchdog.c
index 91b0b26..95d8463 100644
--- a/kernel/watchdog.c
+++ b/kernel/watchdog.c
@@ -310,7 +310,7 @@ static enum hrtimer_restart watchdog_timer_fn(struct hrtimer *hrtimer)
  */
 static int watchdog(void *unused)
 {
-	struct sched_param param = { .sched_priority = MAX_RT_PRIO-1 };
+	static struct sched_param param = { .sched_priority = MAX_RT_PRIO-1 };
 	struct hrtimer *hrtimer = &__raw_get_cpu_var(watchdog_hrtimer);
 
 	sched_setscheduler(current, SCHED_FIFO, &param);
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 327d2de..036939a 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -947,7 +947,7 @@ init_cpu_workqueue(struct workqueue_struct *wq, int cpu)
 
 static int create_workqueue_thread(struct cpu_workqueue_struct *cwq, int cpu)
 {
-	struct sched_param param = { .sched_priority = MAX_RT_PRIO-1 };
+	static struct sched_param param = { .sched_priority = MAX_RT_PRIO-1 };
 	struct workqueue_struct *wq = cwq->wq;
 	const char *fmt = is_wq_single_threaded(wq) ? "%s" : "%s/%d";
 	struct task_struct *p;
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
