Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 456F56B0082
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 16:13:09 -0400 (EDT)
Date: Wed, 15 Jun 2011 22:12:16 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: [GIT PULL] Re: REGRESSION: Performance regressions from switching
 anon_vma->lock to mutex
Message-ID: <20110615201216.GA4762@elte.hu>
References: <1308097798.17300.142.camel@schen9-DESK>
 <1308134200.15315.32.camel@twins>
 <1308135495.15315.38.camel@twins>
 <BANLkTikt88KnxTy8TuGGVrBVnXvsnL7nMQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTikt88KnxTy8TuGGVrBVnXvsnL7nMQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, ak@linux.intel.com, shaohua.li@intel.com, alex.shi@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Wed, Jun 15, 2011 at 3:58 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> >
> > The first thing that stood out when running it was:
> >
> > 31694 root      20   0 26660 1460 1212 S 17.5  0.0   0:01.97 exim
> >    7 root      -2  19     0    0    0 S 12.7  0.0   0:06.14 rcuc0
> ...
> >
> > Which is an impressive amount of RCU usage..
> 
> Gaah. Can we just revert that crazy "use threads for RCU" thing already?

I have this fix queued up currently:

  09223371deac: rcu: Use softirq to address performance regression

and that's ready for pulling and should fix this regression:

   git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip.git core-urgent-for-linus

The revert itself looks quite hairy, i just attempted it: it affects 
half a dozen other followup commits. We might be better off using the 
(tested) commit above and then shutting down all kthread based 
processing and always use a softirq ... or something like that.

if you think that's risky and we should do the revert then i'll 
rebase the core/urgent branch and we'll do the revert.

Paul, Peter, what do you think?

 Thanks,

	Ingo

------------------>
Paul E. McKenney (1):
      rcu: Simplify curing of load woes

Shaohua Li (1):
      rcu: Use softirq to address performance regression


 Documentation/filesystems/proc.txt  |    1 +
 include/linux/interrupt.h           |    1 +
 include/trace/events/irq.h          |    3 +-
 kernel/rcutree.c                    |   88 ++++++++++++++++-------------------
 kernel/rcutree.h                    |    1 +
 kernel/rcutree_plugin.h             |   20 ++++----
 kernel/softirq.c                    |    2 +-
 tools/perf/util/trace-event-parse.c |    1 +
 8 files changed, 57 insertions(+), 60 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index f481780..db3b1ab 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -843,6 +843,7 @@ Provides counts of softirq handlers serviced since boot time, for each cpu.
  TASKLET:          0          0          0        290
    SCHED:      27035      26983      26971      26746
  HRTIMER:          0          0          0          0
+     RCU:       1678       1769       2178       2250
 
 
 1.3 IDE devices in /proc/ide
diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index 6c12989..f6efed0 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -414,6 +414,7 @@ enum
 	TASKLET_SOFTIRQ,
 	SCHED_SOFTIRQ,
 	HRTIMER_SOFTIRQ,
+	RCU_SOFTIRQ,    /* Preferable RCU should always be the last softirq */
 
 	NR_SOFTIRQS
 };
diff --git a/include/trace/events/irq.h b/include/trace/events/irq.h
index ae045ca..1c09820 100644
--- a/include/trace/events/irq.h
+++ b/include/trace/events/irq.h
@@ -20,7 +20,8 @@ struct softirq_action;
 			 softirq_name(BLOCK_IOPOLL),	\
 			 softirq_name(TASKLET),		\
 			 softirq_name(SCHED),		\
-			 softirq_name(HRTIMER))
+			 softirq_name(HRTIMER),		\
+			 softirq_name(RCU))
 
 /**
  * irq_handler_entry - called immediately before the irq action handler
diff --git a/kernel/rcutree.c b/kernel/rcutree.c
index 89419ff..ae5c9ea 100644
--- a/kernel/rcutree.c
+++ b/kernel/rcutree.c
@@ -100,6 +100,7 @@ static char rcu_kthreads_spawnable;
 
 static void rcu_node_kthread_setaffinity(struct rcu_node *rnp, int outgoingcpu);
 static void invoke_rcu_cpu_kthread(void);
+static void __invoke_rcu_cpu_kthread(void);
 
 #define RCU_KTHREAD_PRIO 1	/* RT priority for per-CPU kthreads. */
 
@@ -1442,13 +1443,21 @@ __rcu_process_callbacks(struct rcu_state *rsp, struct rcu_data *rdp)
 	}
 
 	/* If there are callbacks ready, invoke them. */
-	rcu_do_batch(rsp, rdp);
+	if (cpu_has_callbacks_ready_to_invoke(rdp))
+		__invoke_rcu_cpu_kthread();
+}
+
+static void rcu_kthread_do_work(void)
+{
+	rcu_do_batch(&rcu_sched_state, &__get_cpu_var(rcu_sched_data));
+	rcu_do_batch(&rcu_bh_state, &__get_cpu_var(rcu_bh_data));
+	rcu_preempt_do_callbacks();
 }
 
 /*
  * Do softirq processing for the current CPU.
  */
-static void rcu_process_callbacks(void)
+static void rcu_process_callbacks(struct softirq_action *unused)
 {
 	__rcu_process_callbacks(&rcu_sched_state,
 				&__get_cpu_var(rcu_sched_data));
@@ -1465,7 +1474,7 @@ static void rcu_process_callbacks(void)
  * the current CPU with interrupts disabled, the rcu_cpu_kthread_task
  * cannot disappear out from under us.
  */
-static void invoke_rcu_cpu_kthread(void)
+static void __invoke_rcu_cpu_kthread(void)
 {
 	unsigned long flags;
 
@@ -1479,6 +1488,11 @@ static void invoke_rcu_cpu_kthread(void)
 	local_irq_restore(flags);
 }
 
+static void invoke_rcu_cpu_kthread(void)
+{
+	raise_softirq(RCU_SOFTIRQ);
+}
+
 /*
  * Wake up the specified per-rcu_node-structure kthread.
  * Because the per-rcu_node kthreads are immortal, we don't need
@@ -1613,7 +1627,7 @@ static int rcu_cpu_kthread(void *arg)
 		*workp = 0;
 		local_irq_restore(flags);
 		if (work)
-			rcu_process_callbacks();
+			rcu_kthread_do_work();
 		local_bh_enable();
 		if (*workp != 0)
 			spincnt++;
@@ -1635,6 +1649,20 @@ static int rcu_cpu_kthread(void *arg)
  * to manipulate rcu_cpu_kthread_task.  There might be another CPU
  * attempting to access it during boot, but the locking in kthread_bind()
  * will enforce sufficient ordering.
+ *
+ * Please note that we cannot simply refuse to wake up the per-CPU
+ * kthread because kthreads are created in TASK_UNINTERRUPTIBLE state,
+ * which can result in softlockup complaints if the task ends up being
+ * idle for more than a couple of minutes.
+ *
+ * However, please note also that we cannot bind the per-CPU kthread to its
+ * CPU until that CPU is fully online.  We also cannot wait until the
+ * CPU is fully online before we create its per-CPU kthread, as this would
+ * deadlock the system when CPU notifiers tried waiting for grace
+ * periods.  So we bind the per-CPU kthread to its CPU only if the CPU
+ * is online.  If its CPU is not yet fully online, then the code in
+ * rcu_cpu_kthread() will wait until it is fully online, and then do
+ * the binding.
  */
 static int __cpuinit rcu_spawn_one_cpu_kthread(int cpu)
 {
@@ -1647,12 +1675,14 @@ static int __cpuinit rcu_spawn_one_cpu_kthread(int cpu)
 	t = kthread_create(rcu_cpu_kthread, (void *)(long)cpu, "rcuc%d", cpu);
 	if (IS_ERR(t))
 		return PTR_ERR(t);
-	kthread_bind(t, cpu);
+	if (cpu_online(cpu))
+		kthread_bind(t, cpu);
 	per_cpu(rcu_cpu_kthread_cpu, cpu) = cpu;
 	WARN_ON_ONCE(per_cpu(rcu_cpu_kthread_task, cpu) != NULL);
-	per_cpu(rcu_cpu_kthread_task, cpu) = t;
 	sp.sched_priority = RCU_KTHREAD_PRIO;
 	sched_setscheduler_nocheck(t, SCHED_FIFO, &sp);
+	per_cpu(rcu_cpu_kthread_task, cpu) = t;
+	wake_up_process(t); /* Get to TASK_INTERRUPTIBLE quickly. */
 	return 0;
 }
 
@@ -1759,12 +1789,11 @@ static int __cpuinit rcu_spawn_one_node_kthread(struct rcu_state *rsp,
 		raw_spin_unlock_irqrestore(&rnp->lock, flags);
 		sp.sched_priority = 99;
 		sched_setscheduler_nocheck(t, SCHED_FIFO, &sp);
+		wake_up_process(t); /* get to TASK_INTERRUPTIBLE quickly. */
 	}
 	return rcu_spawn_one_boost_kthread(rsp, rnp, rnp_index);
 }
 
-static void rcu_wake_one_boost_kthread(struct rcu_node *rnp);
-
 /*
  * Spawn all kthreads -- called as soon as the scheduler is running.
  */
@@ -1772,30 +1801,18 @@ static int __init rcu_spawn_kthreads(void)
 {
 	int cpu;
 	struct rcu_node *rnp;
-	struct task_struct *t;
 
 	rcu_kthreads_spawnable = 1;
 	for_each_possible_cpu(cpu) {
 		per_cpu(rcu_cpu_has_work, cpu) = 0;
-		if (cpu_online(cpu)) {
+		if (cpu_online(cpu))
 			(void)rcu_spawn_one_cpu_kthread(cpu);
-			t = per_cpu(rcu_cpu_kthread_task, cpu);
-			if (t)
-				wake_up_process(t);
-		}
 	}
 	rnp = rcu_get_root(rcu_state);
 	(void)rcu_spawn_one_node_kthread(rcu_state, rnp);
-	if (rnp->node_kthread_task)
-		wake_up_process(rnp->node_kthread_task);
 	if (NUM_RCU_NODES > 1) {
-		rcu_for_each_leaf_node(rcu_state, rnp) {
+		rcu_for_each_leaf_node(rcu_state, rnp)
 			(void)rcu_spawn_one_node_kthread(rcu_state, rnp);
-			t = rnp->node_kthread_task;
-			if (t)
-				wake_up_process(t);
-			rcu_wake_one_boost_kthread(rnp);
-		}
 	}
 	return 0;
 }
@@ -2221,31 +2238,6 @@ static void __cpuinit rcu_prepare_kthreads(int cpu)
 }
 
 /*
- * kthread_create() creates threads in TASK_UNINTERRUPTIBLE state,
- * but the RCU threads are woken on demand, and if demand is low this
- * could be a while triggering the hung task watchdog.
- *
- * In order to avoid this, poke all tasks once the CPU is fully
- * up and running.
- */
-static void __cpuinit rcu_online_kthreads(int cpu)
-{
-	struct rcu_data *rdp = per_cpu_ptr(rcu_state->rda, cpu);
-	struct rcu_node *rnp = rdp->mynode;
-	struct task_struct *t;
-
-	t = per_cpu(rcu_cpu_kthread_task, cpu);
-	if (t)
-		wake_up_process(t);
-
-	t = rnp->node_kthread_task;
-	if (t)
-		wake_up_process(t);
-
-	rcu_wake_one_boost_kthread(rnp);
-}
-
-/*
  * Handle CPU online/offline notification events.
  */
 static int __cpuinit rcu_cpu_notify(struct notifier_block *self,
@@ -2262,7 +2254,6 @@ static int __cpuinit rcu_cpu_notify(struct notifier_block *self,
 		rcu_prepare_kthreads(cpu);
 		break;
 	case CPU_ONLINE:
-		rcu_online_kthreads(cpu);
 	case CPU_DOWN_FAILED:
 		rcu_node_kthread_setaffinity(rnp, -1);
 		rcu_cpu_kthread_setrt(cpu, 1);
@@ -2410,6 +2401,7 @@ void __init rcu_init(void)
 	rcu_init_one(&rcu_sched_state, &rcu_sched_data);
 	rcu_init_one(&rcu_bh_state, &rcu_bh_data);
 	__rcu_init_preempt();
+	 open_softirq(RCU_SOFTIRQ, rcu_process_callbacks);
 
 	/*
 	 * We don't need protection against CPU-hotplug here because
diff --git a/kernel/rcutree.h b/kernel/rcutree.h
index 7b9a08b..0fed6b9 100644
--- a/kernel/rcutree.h
+++ b/kernel/rcutree.h
@@ -439,6 +439,7 @@ static void rcu_preempt_offline_cpu(int cpu);
 #endif /* #ifdef CONFIG_HOTPLUG_CPU */
 static void rcu_preempt_check_callbacks(int cpu);
 static void rcu_preempt_process_callbacks(void);
+static void rcu_preempt_do_callbacks(void);
 void call_rcu(struct rcu_head *head, void (*func)(struct rcu_head *rcu));
 #if defined(CONFIG_HOTPLUG_CPU) || defined(CONFIG_TREE_PREEMPT_RCU)
 static void rcu_report_exp_rnp(struct rcu_state *rsp, struct rcu_node *rnp);
diff --git a/kernel/rcutree_plugin.h b/kernel/rcutree_plugin.h
index c8bff30..38d09c5 100644
--- a/kernel/rcutree_plugin.h
+++ b/kernel/rcutree_plugin.h
@@ -602,6 +602,11 @@ static void rcu_preempt_process_callbacks(void)
 				&__get_cpu_var(rcu_preempt_data));
 }
 
+static void rcu_preempt_do_callbacks(void)
+{
+	rcu_do_batch(&rcu_preempt_state, &__get_cpu_var(rcu_preempt_data));
+}
+
 /*
  * Queue a preemptible-RCU callback for invocation after a grace period.
  */
@@ -997,6 +1002,10 @@ static void rcu_preempt_process_callbacks(void)
 {
 }
 
+static void rcu_preempt_do_callbacks(void)
+{
+}
+
 /*
  * Wait for an rcu-preempt grace period, but make it happen quickly.
  * But because preemptible RCU does not exist, map to rcu-sched.
@@ -1299,15 +1308,10 @@ static int __cpuinit rcu_spawn_one_boost_kthread(struct rcu_state *rsp,
 	raw_spin_unlock_irqrestore(&rnp->lock, flags);
 	sp.sched_priority = RCU_KTHREAD_PRIO;
 	sched_setscheduler_nocheck(t, SCHED_FIFO, &sp);
+	wake_up_process(t); /* get to TASK_INTERRUPTIBLE quickly. */
 	return 0;
 }
 
-static void __cpuinit rcu_wake_one_boost_kthread(struct rcu_node *rnp)
-{
-	if (rnp->boost_kthread_task)
-		wake_up_process(rnp->boost_kthread_task);
-}
-
 #else /* #ifdef CONFIG_RCU_BOOST */
 
 static void rcu_initiate_boost(struct rcu_node *rnp, unsigned long flags)
@@ -1331,10 +1335,6 @@ static int __cpuinit rcu_spawn_one_boost_kthread(struct rcu_state *rsp,
 	return 0;
 }
 
-static void __cpuinit rcu_wake_one_boost_kthread(struct rcu_node *rnp)
-{
-}
-
 #endif /* #else #ifdef CONFIG_RCU_BOOST */
 
 #ifndef CONFIG_SMP
diff --git a/kernel/softirq.c b/kernel/softirq.c
index 1396017..40cf63d 100644
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -58,7 +58,7 @@ DEFINE_PER_CPU(struct task_struct *, ksoftirqd);
 
 char *softirq_to_name[NR_SOFTIRQS] = {
 	"HI", "TIMER", "NET_TX", "NET_RX", "BLOCK", "BLOCK_IOPOLL",
-	"TASKLET", "SCHED", "HRTIMER"
+	"TASKLET", "SCHED", "HRTIMER", "RCU"
 };
 
 /*
diff --git a/tools/perf/util/trace-event-parse.c b/tools/perf/util/trace-event-parse.c
index 1e88485..0a7ed5b 100644
--- a/tools/perf/util/trace-event-parse.c
+++ b/tools/perf/util/trace-event-parse.c
@@ -2187,6 +2187,7 @@ static const struct flag flags[] = {
 	{ "TASKLET_SOFTIRQ", 6 },
 	{ "SCHED_SOFTIRQ", 7 },
 	{ "HRTIMER_SOFTIRQ", 8 },
+	{ "RCU_SOFTIRQ", 9 },
 
 	{ "HRTIMER_NORESTART", 0 },
 	{ "HRTIMER_RESTART", 1 },

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
