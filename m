Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 1422B6B00B9
	for <linux-mm@kvack.org>; Sat, 30 Jun 2012 21:15:46 -0400 (EDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sat, 30 Jun 2012 19:15:44 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q611Ff1P071712
	for <linux-mm@kvack.org>; Sat, 30 Jun 2012 19:15:41 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q611Fedp007276
	for <linux-mm@kvack.org>; Sat, 30 Jun 2012 19:15:41 -0600
Date: Sat, 30 Jun 2012 18:15:38 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: mm,numad,rcu: hang on OOM
Message-ID: <20120701011538.GD2907@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1340988281.2936.58.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340988281.2936.58.camel@lappy>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Jun 29, 2012 at 06:44:41PM +0200, Sasha Levin wrote:
> Hi all,
> 
> While fuzzing using trinity on a KVM tools guest with todays linux-next, I've hit the following lockup:
> 
> [  362.261729] INFO: task numad/2:27 blocked for more than 120 seconds.
> [  362.263974] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [  362.271684] numad/2         D 0000000000000001  5672    27      2 0x00000000
> [  362.280052]  ffff8800294c7c58 0000000000000046 ffff8800294c7c08 ffffffff81163dba
> [  362.294477]  ffff8800294c6000 ffff8800294c6010 ffff8800294c7fd8 ffff8800294c6000
> [  362.306631]  ffff8800294c6010 ffff8800294c7fd8 ffff88000d5c3000 ffff8800294c8000
> [  362.315395] Call Trace:
> [  362.318556]  [<ffffffff81163dba>] ? __lock_release+0x1ba/0x1d0
> [  362.325411]  [<ffffffff8372ab75>] schedule+0x55/0x60
> [  362.328844]  [<ffffffff8372b965>] rwsem_down_failed_common+0xf5/0x130
> [  362.332501]  [<ffffffff8115d38e>] ? put_lock_stats+0xe/0x40
> [  362.334496]  [<ffffffff81160135>] ? __lock_contended+0x1f5/0x230
> [  362.336723]  [<ffffffff8372b9d5>] rwsem_down_read_failed+0x15/0x17
> [  362.339297]  [<ffffffff81985e34>] call_rwsem_down_read_failed+0x14/0x30
> [  362.341768]  [<ffffffff83729a29>] ? down_read+0x79/0xa0
> [  362.343669]  [<ffffffff8122d262>] ? lazy_migrate_process+0x22/0x60
> [  362.345616]  [<ffffffff8122d262>] lazy_migrate_process+0x22/0x60
> [  362.347464]  [<ffffffff811453c0>] process_mem_migrate+0x10/0x20
> [  362.349340]  [<ffffffff81145090>] move_processes+0x190/0x230
> [  362.351398]  [<ffffffff81145b7a>] numad_thread+0x7a/0x120
> [  362.353245]  [<ffffffff81145b00>] ? find_busiest_node+0x310/0x310
> [  362.355396]  [<ffffffff81119e82>] kthread+0xb2/0xc0
> [  362.356996]  [<ffffffff8372ea34>] kernel_thread_helper+0x4/0x10
> [  362.359253]  [<ffffffff8372ccb4>] ? retint_restore_args+0x13/0x13
> [  362.361168]  [<ffffffff81119dd0>] ? __init_kthread_worker+0x70/0x70
> [  362.363277]  [<ffffffff8372ea30>] ? gs_change+0x13/0x13
> 
> I've hit sysrq-t to see what might be the cause, and it appears that an OOM was in progress, and was stuck on RCU:
> 
> [  578.086230] trinity-child69 D ffff8800277a54c8  3968  6658   6580 0x00000000
> [  578.086230]  ffff880022c5f518 0000000000000046 ffff880022c5f4c8 ffff88001b9d6e00
> [  578.086230]  ffff880022c5e000 ffff880022c5e010 ffff880022c5ffd8 ffff880022c5e000
> [  578.086230]  ffff880022c5e010 ffff880022c5ffd8 ffff880023c08000 ffff880022c33000
> [  578.086230] Call Trace:
> [  578.086230]  [<ffffffff8372ab75>] schedule+0x55/0x60
> [  578.086230]  [<ffffffff837285c8>] schedule_timeout+0x38/0x2c0
> [  578.086230]  [<ffffffff81161d16>] ? mark_held_locks+0xf6/0x120
> [  578.086230]  [<ffffffff81163dba>] ? __lock_release+0x1ba/0x1d0
> [  578.086230]  [<ffffffff8372c67b>] ? _raw_spin_unlock_irq+0x2b/0x80
> [  578.086230]  [<ffffffff8372a06f>] wait_for_common+0xff/0x170
> [  578.086230]  [<ffffffff81132c10>] ? try_to_wake_up+0x290/0x290
> [  578.086230]  [<ffffffff8372a188>] wait_for_completion+0x18/0x20
> [  578.086230]  [<ffffffff811a5de7>] _rcu_barrier+0x4a7/0x4e0

Hmmm...  Perhaps a blocking operation is not appropriate here.  I have
substituted a nonblocking approach, which is at -rcu (thus soon -next)
at 1ee4c09d (Provide OOM handler to motivate lazy RCU callbacks).
Patch below.

							Thanx, Paul

------------------------------------------------------------------------

rcu: Provide OOM handler to motivate lazy RCU callbacks

In kernels built with CONFIG_RCU_FAST_NO_HZ=y, CPUs can accumulate a
large number of lazy callbacks, which as the name implies will be slow
to be invoked.  This can be a problem on small-memory systems, where the
default 6-second sleep for CPUs having only lazy RCU callbacks could well
be fatal.  This commit therefore installs an OOM hander that ensures that
every CPU with non-lazy callbacks has at least one non-lazy callback,
in turn ensuring timely advancement for these callbacks.

Signed-off-by: Paul E. McKenney <paul.mckenney@linaro.org>
Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

diff --git a/kernel/rcutree.h b/kernel/rcutree.h
index 4b47fbe..dab279f 100644
--- a/kernel/rcutree.h
+++ b/kernel/rcutree.h
@@ -314,8 +314,11 @@ struct rcu_data {
 	unsigned long n_rp_need_fqs;
 	unsigned long n_rp_need_nothing;
 
-	/* 6) _rcu_barrier() callback. */
+	/* 6) _rcu_barrier() and OOM callbacks. */
 	struct rcu_head barrier_head;
+#ifdef CONFIG_RCU_FAST_NO_HZ
+	struct rcu_head oom_head;
+#endif /* #ifdef CONFIG_RCU_FAST_NO_HZ */
 
 	int cpu;
 	struct rcu_state *rsp;
diff --git a/kernel/rcutree_plugin.h b/kernel/rcutree_plugin.h
index 81e53eb..1908847 100644
--- a/kernel/rcutree_plugin.h
+++ b/kernel/rcutree_plugin.h
@@ -25,6 +25,7 @@
  */
 
 #include <linux/delay.h>
+#include <linux/oom.h>
 
 #define RCU_KTHREAD_PRIO 1
 
@@ -2128,6 +2129,90 @@ static void rcu_idle_count_callbacks_posted(void)
 	__this_cpu_add(rcu_dynticks.nonlazy_posted, 1);
 }
 
+/*
+ * Data for flushing lazy RCU callbacks at OOM time.
+ */
+static atomic_t oom_callback_count;
+static DECLARE_WAIT_QUEUE_HEAD(oom_callback_wq);
+
+/*
+ * RCU OOM callback -- decrement the outstanding count and deliver the
+ * wake-up if we are the last one.
+ */
+static void rcu_oom_callback(struct rcu_head *rhp)
+{
+	if (atomic_dec_and_test(&oom_callback_count))
+		wake_up(&oom_callback_wq);
+}
+
+/*
+ * Post an rcu_oom_notify callback on the current CPU if it has at
+ * least one lazy callback.  This will unnecessarily post callbacks
+ * to CPUs that already have a non-lazy callback at the end of their
+ * callback list, but this is an infrequent operation, so accept some
+ * extra overhead to keep things simple.
+ */
+static void rcu_oom_notify_cpu(void *flavor)
+{
+	struct rcu_state *rsp = flavor;
+	struct rcu_data *rdp = __this_cpu_ptr(rsp->rda);
+
+	if (rdp->qlen_lazy != 0) {
+		atomic_inc(&oom_callback_count);
+		rsp->call(&rdp->oom_head, rcu_oom_callback);
+	}
+}
+
+/*
+ * If low on memory, ensure that each CPU has a non-lazy callback.
+ * This will wake up CPUs that have only lazy callbacks, in turn
+ * ensuring that they free up the corresponding memory in a timely manner.
+ */
+static int rcu_oom_notify(struct notifier_block *self,
+                          unsigned long notused, void *nfreed)
+{
+	int cpu;
+
+	/* Wait for callbacks from earlier instance to complete. */
+	wait_event(oom_callback_wq, atomic_read(&oom_callback_count) == 0);
+
+	/*
+	 * Prevent premature wakeup: ensure that all increments happen
+	 * before there is a chance of the counter reaching zero.
+	 */
+	atomic_set(&oom_callback_count, 1);
+
+	get_online_cpus();
+	for_each_online_cpu(cpu) {
+#ifdef CONFIG_PREEMPT_RCU
+		smp_call_function_single(cpu, rcu_oom_notify_cpu,
+					 &rcu_preempt_state, 1);
+#endif /* #ifdef CONFIG_PREEMPT_RCU */
+		smp_call_function_single(cpu, rcu_oom_notify_cpu,
+					 &rcu_bh_state, 1);
+		smp_call_function_single(cpu, rcu_oom_notify_cpu,
+					 &rcu_sched_state, 1);
+	}
+	put_online_cpus();
+
+	/* Unconditionally decrement: no need to wake ourselves up. */
+	atomic_dec(&oom_callback_count);
+
+	*(unsigned long *)nfreed = 1;
+	return NOTIFY_OK;
+}
+
+static struct notifier_block rcu_oom_nb = {
+	.notifier_call = rcu_oom_notify
+};
+
+static int __init rcu_register_oom_notifier(void)
+{
+	register_oom_notifier(&rcu_oom_nb);
+	return 0;
+}
+early_initcall(rcu_register_oom_notifier);
+
 #endif /* #else #if !defined(CONFIG_RCU_FAST_NO_HZ) */
 
 #ifdef CONFIG_RCU_CPU_STALL_INFO

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
