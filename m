Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 226426B0032
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 10:32:43 -0400 (EDT)
Date: Tue, 17 Sep 2013 16:32:35 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 37/50] sched: Introduce migrate_swap()
Message-ID: <20130917143235.GB29354@twins.programming.kicks-ass.net>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
 <1378805550-29949-38-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1378805550-29949-38-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Sep 10, 2013 at 10:32:17AM +0100, Mel Gorman wrote:
> TODO: I'm fairly sure we can get rid of the wake_cpu != -1 test by keeping
> wake_cpu to the actual task cpu; just couldn't be bothered to think through
> all the cases.

> + * XXX worry about hotplug

Combined with the {get,put}_online_cpus() optimization patch, the below
should address the two outstanding issues.

Completely untested for now.. will try and get it some runtime later.

Not-yet-signed-off-by: Peter Zijlstra <peterz@infradead.org>
---
 kernel/sched/core.c  |   37 ++++++++++++++++++++-----------------
 kernel/sched/sched.h |    1 +
 2 files changed, 21 insertions(+), 17 deletions(-)

--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1035,7 +1035,7 @@ static void __migrate_swap_task(struct t
 		/*
 		 * Task isn't running anymore; make it appear like we migrated
 		 * it before it went to sleep. This means on wakeup we make the
-		 * previous cpu or targer instead of where it really is.
+		 * previous cpu our target instead of where it really is.
 		 */
 		p->wake_cpu = cpu;
 	}
@@ -1080,11 +1080,16 @@ static int migrate_swap_stop(void *data)
 }
 
 /*
- * XXX worry about hotplug
+ * Cross migrate two tasks
  */
 int migrate_swap(struct task_struct *cur, struct task_struct *p)
 {
-	struct migration_swap_arg arg = {
+	struct migration_swap_arg arg;
+	int ret = -EINVAL;
+
+	get_online_cpus();
+
+       	arg = (struct migration_swap_arg){
 		.src_task = cur,
 		.src_cpu = task_cpu(cur),
 		.dst_task = p,
@@ -1092,15 +1097,22 @@ int migrate_swap(struct task_struct *cur
 	};
 
 	if (arg.src_cpu == arg.dst_cpu)
-		return -EINVAL;
+		goto out;
+
+	if (!cpu_active(arg.src_cpu) || !cpu_active(arg.dst_cpu))
+		goto out;
 
 	if (!cpumask_test_cpu(arg.dst_cpu, tsk_cpus_allowed(arg.src_task)))
-		return -EINVAL;
+		goto out;
 
 	if (!cpumask_test_cpu(arg.src_cpu, tsk_cpus_allowed(arg.dst_task)))
-		return -EINVAL;
+		goto out;
+
+	ret = stop_two_cpus(arg.dst_cpu, arg.src_cpu, migrate_swap_stop, &arg);
 
-	return stop_two_cpus(arg.dst_cpu, arg.src_cpu, migrate_swap_stop, &arg);
+out:
+	put_online_cpus();
+	return ret;
 }
 
 struct migration_arg {
@@ -1608,12 +1620,7 @@ try_to_wake_up(struct task_struct *p, un
 	if (p->sched_class->task_waking)
 		p->sched_class->task_waking(p);
 
-	if (p->wake_cpu != -1) {	/* XXX make this condition go away */
-		cpu = p->wake_cpu;
-		p->wake_cpu = -1;
-	}
-
-	cpu = select_task_rq(p, cpu, SD_BALANCE_WAKE, wake_flags);
+	cpu = select_task_rq(p, p->wake_cpu, SD_BALANCE_WAKE, wake_flags);
 	if (task_cpu(p) != cpu) {
 		wake_flags |= WF_MIGRATED;
 		set_task_cpu(p, cpu);
@@ -1699,10 +1706,6 @@ static void __sched_fork(struct task_str
 {
 	p->on_rq			= 0;
 
-#ifdef CONFIG_SMP
-	p->wake_cpu			= -1;
-#endif
-
 	p->se.on_rq			= 0;
 	p->se.exec_start		= 0;
 	p->se.sum_exec_runtime		= 0;
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -737,6 +737,7 @@ static inline void __set_task_cpu(struct
 	 */
 	smp_wmb();
 	task_thread_info(p)->cpu = cpu;
+	p->wake_cpu = cpu;
 #endif
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
