Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8FB9C6B01AC
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 17:50:11 -0400 (EDT)
Date: Fri, 2 Jul 2010 14:49:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 10/11] oom: give the dying task a higher priority
Message-Id: <20100702144941.8fa101c3.akpm@linux-foundation.org>
In-Reply-To: <20100630183243.AA65.A69D9226@jp.fujitsu.com>
References: <20100630172430.AA42.A69D9226@jp.fujitsu.com>
	<20100630183243.AA65.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Wed, 30 Jun 2010 18:33:23 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> +static void boost_dying_task_prio(struct task_struct *p,
> +				  struct mem_cgroup *mem)
> +{
> +	struct sched_param param = { .sched_priority = 1 };
> +
> +	if (mem)
> +		return;
> +
> +	if (!rt_task(p))
> +		sched_setscheduler_nocheck(p, SCHED_FIFO, &param);
> +}

We can actually make `param' static here.  That saves a teeny bit of
code and a little bit of stack.  The oom-killer can be called when
we're using a lot of stack.

But if we make that change we really should make the param arg to
sched_setscheduler_nocheck() be const.  I did that (and was able to
convert lots of callers to use a static `param') but to complete the
job we'd need to chase through all the security goop, fixing up
security_task_setscheduler() and callees, and I got bored.


 include/linux/sched.h |    2 +-
 kernel/kthread.c      |    2 +-
 kernel/sched.c        |    4 ++--
 kernel/softirq.c      |    4 +++-
 kernel/stop_machine.c |    2 +-
 kernel/workqueue.c    |    2 +-
 6 files changed, 9 insertions(+), 7 deletions(-)

diff -puN kernel/kthread.c~a kernel/kthread.c
--- a/kernel/kthread.c~a
+++ a/kernel/kthread.c
@@ -131,7 +131,7 @@ struct task_struct *kthread_create(int (
 	wait_for_completion(&create.done);
 
 	if (!IS_ERR(create.result)) {
-		struct sched_param param = { .sched_priority = 0 };
+		static struct sched_param param = { .sched_priority = 0 };
 		va_list args;
 
 		va_start(args, namefmt);
diff -puN kernel/workqueue.c~a kernel/workqueue.c
--- a/kernel/workqueue.c~a
+++ a/kernel/workqueue.c
@@ -962,7 +962,7 @@ init_cpu_workqueue(struct workqueue_stru
 
 static int create_workqueue_thread(struct cpu_workqueue_struct *cwq, int cpu)
 {
-	struct sched_param param = { .sched_priority = MAX_RT_PRIO-1 };
+	static struct sched_param param = { .sched_priority = MAX_RT_PRIO-1 };
 	struct workqueue_struct *wq = cwq->wq;
 	const char *fmt = is_wq_single_threaded(wq) ? "%s" : "%s/%d";
 	struct task_struct *p;
diff -puN kernel/stop_machine.c~a kernel/stop_machine.c
--- a/kernel/stop_machine.c~a
+++ a/kernel/stop_machine.c
@@ -291,7 +291,7 @@ repeat:
 static int __cpuinit cpu_stop_cpu_callback(struct notifier_block *nfb,
 					   unsigned long action, void *hcpu)
 {
-	struct sched_param param = { .sched_priority = MAX_RT_PRIO - 1 };
+	static struct sched_param param = { .sched_priority = MAX_RT_PRIO - 1 };
 	unsigned int cpu = (unsigned long)hcpu;
 	struct cpu_stopper *stopper = &per_cpu(cpu_stopper, cpu);
 	struct task_struct *p;
diff -puN kernel/sched.c~a kernel/sched.c
--- a/kernel/sched.c~a
+++ a/kernel/sched.c
@@ -4570,7 +4570,7 @@ static bool check_same_owner(struct task
 }
 
 static int __sched_setscheduler(struct task_struct *p, int policy,
-				struct sched_param *param, bool user)
+				const struct sched_param *param, bool user)
 {
 	int retval, oldprio, oldpolicy = -1, on_rq, running;
 	unsigned long flags;
@@ -4734,7 +4734,7 @@ EXPORT_SYMBOL_GPL(sched_setscheduler);
  * but our caller might not have that capability.
  */
 int sched_setscheduler_nocheck(struct task_struct *p, int policy,
-			       struct sched_param *param)
+			       const struct sched_param *param)
 {
 	return __sched_setscheduler(p, policy, param, false);
 }
diff -puN kernel/softirq.c~a kernel/softirq.c
--- a/kernel/softirq.c~a
+++ a/kernel/softirq.c
@@ -827,7 +827,9 @@ static int __cpuinit cpu_callback(struct
 			     cpumask_any(cpu_online_mask));
 	case CPU_DEAD:
 	case CPU_DEAD_FROZEN: {
-		struct sched_param param = { .sched_priority = MAX_RT_PRIO-1 };
+		static struct sched_param param = {
+				.sched_priority = MAX_RT_PRIO-1,
+			};
 
 		p = per_cpu(ksoftirqd, hotcpu);
 		per_cpu(ksoftirqd, hotcpu) = NULL;
diff -puN include/linux/sched.h~a include/linux/sched.h
--- a/include/linux/sched.h~a
+++ a/include/linux/sched.h
@@ -1924,7 +1924,7 @@ extern int task_curr(const struct task_s
 extern int idle_cpu(int cpu);
 extern int sched_setscheduler(struct task_struct *, int, struct sched_param *);
 extern int sched_setscheduler_nocheck(struct task_struct *, int,
-				      struct sched_param *);
+				      const struct sched_param *);
 extern struct task_struct *idle_task(int cpu);
 extern struct task_struct *curr_task(int cpu);
 extern void set_curr_task(int cpu, struct task_struct *p);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
