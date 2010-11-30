From: Christoph Lameter <cl@linux.com>
Subject: [thisops uV3 12/18] Core: Replace __get_cpu_var with __this_cpu_read if not used for an address.
Date: Tue, 30 Nov 2010 13:07:19 -0600
Message-ID: <20101130190848.114108527@linux.com>
References: <20101130190707.457099608@linux.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PNVZz-0000hN-62
	for glkm-linux-mm-2@m.gmane.org; Tue, 30 Nov 2010 20:09:31 +0100
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id D3B986B009B
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 14:08:56 -0500 (EST)
Content-Disposition: inline; filename=this_cpu_core
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

__get_cpu_var() can be replaced with this_cpu_read and will then use a single
read instruction with implied address calculation to access the correct per cpu
instance.

However, the address of a per cpu variable passed to __this_cpu_read() cannot be
determed (since its an implied address conversion through segment prefixes).
Therefore apply this only to uses of __get_cpu_var where the addres of the
variable is not used.

Cc: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Hugh Dickins <hughd@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/asm-generic/irq_regs.h |    8 +++----
 include/linux/elevator.h       |   12 ++---------
 include/linux/kernel_stat.h    |    2 -
 kernel/exit.c                  |    2 -
 kernel/fork.c                  |    2 -
 kernel/hrtimer.c               |    2 -
 kernel/printk.c                |    4 +--
 kernel/rcutree.c               |    4 +--
 kernel/softirq.c               |   44 ++++++++++++++++++++---------------------
 kernel/time/tick-common.c      |    2 -
 kernel/time/tick-oneshot.c     |    4 +--
 kernel/watchdog.c              |   36 ++++++++++++++++-----------------
 mm/slab.c                      |    6 ++---
 13 files changed, 61 insertions(+), 67 deletions(-)

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2010-11-30 12:40:22.000000000 -0600
+++ linux-2.6/mm/slab.c	2010-11-30 12:41:14.000000000 -0600
@@ -829,12 +829,12 @@ static void init_reap_node(int cpu)
 
 static void next_reap_node(void)
 {
-	int node = __get_cpu_var(slab_reap_node);
+	int node = __this_cpu_read(slab_reap_node);
 
 	node = next_node(node, node_online_map);
 	if (unlikely(node >= MAX_NUMNODES))
 		node = first_node(node_online_map);
-	__get_cpu_var(slab_reap_node) = node;
+	__this_cpu_write(slab_reap_node, node);
 }
 
 #else
@@ -1012,7 +1012,7 @@ static void __drain_alien_cache(struct k
  */
 static void reap_alien(struct kmem_cache *cachep, struct kmem_list3 *l3)
 {
-	int node = __get_cpu_var(slab_reap_node);
+	int node = __this_cpu_read(slab_reap_node);
 
 	if (l3->alien) {
 		struct array_cache *ac = l3->alien[node];
Index: linux-2.6/kernel/rcutree.c
===================================================================
--- linux-2.6.orig/kernel/rcutree.c	2010-11-30 12:40:22.000000000 -0600
+++ linux-2.6/kernel/rcutree.c	2010-11-30 12:41:14.000000000 -0600
@@ -367,8 +367,8 @@ void rcu_irq_exit(void)
 	WARN_ON_ONCE(rdtp->dynticks & 0x1);
 
 	/* If the interrupt queued a callback, get out of dyntick mode. */
-	if (__get_cpu_var(rcu_sched_data).nxtlist ||
-	    __get_cpu_var(rcu_bh_data).nxtlist)
+	if (__this_cpu_read(rcu_sched_data.nxtlist) ||
+	    __this_cpu_read(rcu_bh_data.nxtlist))
 		set_need_resched();
 }
 
Index: linux-2.6/kernel/softirq.c
===================================================================
--- linux-2.6.orig/kernel/softirq.c	2010-11-30 12:40:22.000000000 -0600
+++ linux-2.6/kernel/softirq.c	2010-11-30 12:41:14.000000000 -0600
@@ -70,7 +70,7 @@ char *softirq_to_name[NR_SOFTIRQS] = {
 static void wakeup_softirqd(void)
 {
 	/* Interrupts are disabled: no need to stop preemption */
-	struct task_struct *tsk = __get_cpu_var(ksoftirqd);
+	struct task_struct *tsk = __this_cpu_read(ksoftirqd);
 
 	if (tsk && tsk->state != TASK_RUNNING)
 		wake_up_process(tsk);
@@ -388,8 +388,8 @@ void __tasklet_schedule(struct tasklet_s
 
 	local_irq_save(flags);
 	t->next = NULL;
-	*__get_cpu_var(tasklet_vec).tail = t;
-	__get_cpu_var(tasklet_vec).tail = &(t->next);
+	*__this_cpu_read(tasklet_vec.tail) = t;
+	__this_cpu_write(tasklet_vec.tail, &(t->next));
 	raise_softirq_irqoff(TASKLET_SOFTIRQ);
 	local_irq_restore(flags);
 }
@@ -402,8 +402,8 @@ void __tasklet_hi_schedule(struct taskle
 
 	local_irq_save(flags);
 	t->next = NULL;
-	*__get_cpu_var(tasklet_hi_vec).tail = t;
-	__get_cpu_var(tasklet_hi_vec).tail = &(t->next);
+	*__this_cpu_read(tasklet_hi_vec.tail) = t;
+	__this_cpu_write(tasklet_hi_vec.tail,  &(t->next));
 	raise_softirq_irqoff(HI_SOFTIRQ);
 	local_irq_restore(flags);
 }
@@ -414,8 +414,8 @@ void __tasklet_hi_schedule_first(struct
 {
 	BUG_ON(!irqs_disabled());
 
-	t->next = __get_cpu_var(tasklet_hi_vec).head;
-	__get_cpu_var(tasklet_hi_vec).head = t;
+	t->next = __this_cpu_read(tasklet_hi_vec.head);
+	__this_cpu_write(tasklet_hi_vec.head, t);
 	__raise_softirq_irqoff(HI_SOFTIRQ);
 }
 
@@ -426,9 +426,9 @@ static void tasklet_action(struct softir
 	struct tasklet_struct *list;
 
 	local_irq_disable();
-	list = __get_cpu_var(tasklet_vec).head;
-	__get_cpu_var(tasklet_vec).head = NULL;
-	__get_cpu_var(tasklet_vec).tail = &__get_cpu_var(tasklet_vec).head;
+	list = __this_cpu_read(tasklet_vec.head);
+	__this_cpu_write(tasklet_vec.head, NULL);
+	__this_cpu_write(tasklet_vec.tail, &__get_cpu_var(tasklet_vec).head);
 	local_irq_enable();
 
 	while (list) {
@@ -449,8 +449,8 @@ static void tasklet_action(struct softir
 
 		local_irq_disable();
 		t->next = NULL;
-		*__get_cpu_var(tasklet_vec).tail = t;
-		__get_cpu_var(tasklet_vec).tail = &(t->next);
+		*__this_cpu_read(tasklet_vec.tail) = t;
+		__this_cpu_write(tasklet_vec.tail, &(t->next));
 		__raise_softirq_irqoff(TASKLET_SOFTIRQ);
 		local_irq_enable();
 	}
@@ -461,9 +461,9 @@ static void tasklet_hi_action(struct sof
 	struct tasklet_struct *list;
 
 	local_irq_disable();
-	list = __get_cpu_var(tasklet_hi_vec).head;
-	__get_cpu_var(tasklet_hi_vec).head = NULL;
-	__get_cpu_var(tasklet_hi_vec).tail = &__get_cpu_var(tasklet_hi_vec).head;
+	list = __this_cpu_read(tasklet_hi_vec.head);
+	__this_cpu_write(tasklet_hi_vec.head, NULL);
+	__this_cpu_write(tasklet_hi_vec.tail, &__get_cpu_var(tasklet_hi_vec).head);
 	local_irq_enable();
 
 	while (list) {
@@ -484,8 +484,8 @@ static void tasklet_hi_action(struct sof
 
 		local_irq_disable();
 		t->next = NULL;
-		*__get_cpu_var(tasklet_hi_vec).tail = t;
-		__get_cpu_var(tasklet_hi_vec).tail = &(t->next);
+		*__this_cpu_read(tasklet_hi_vec.tail) = t;
+		__this_cpu_write(tasklet_hi_vec.tail, &(t->next));
 		__raise_softirq_irqoff(HI_SOFTIRQ);
 		local_irq_enable();
 	}
@@ -802,18 +802,18 @@ static void takeover_tasklets(unsigned i
 
 	/* Find end, append list for that CPU. */
 	if (&per_cpu(tasklet_vec, cpu).head != per_cpu(tasklet_vec, cpu).tail) {
-		*(__get_cpu_var(tasklet_vec).tail) = per_cpu(tasklet_vec, cpu).head;
-		__get_cpu_var(tasklet_vec).tail = per_cpu(tasklet_vec, cpu).tail;
+		*__this_cpu_read(tasklet_vec.tail) = per_cpu(tasklet_vec, cpu).head;
+		this_cpu_write(tasklet_vec.tail, per_cpu(tasklet_vec, cpu).tail);
 		per_cpu(tasklet_vec, cpu).head = NULL;
 		per_cpu(tasklet_vec, cpu).tail = &per_cpu(tasklet_vec, cpu).head;
 	}
 	raise_softirq_irqoff(TASKLET_SOFTIRQ);
 
 	if (&per_cpu(tasklet_hi_vec, cpu).head != per_cpu(tasklet_hi_vec, cpu).tail) {
-		*__get_cpu_var(tasklet_hi_vec).tail = per_cpu(tasklet_hi_vec, cpu).head;
-		__get_cpu_var(tasklet_hi_vec).tail = per_cpu(tasklet_hi_vec, cpu).tail;
+		*__this_cpuo_read(tasklet_hi_vec.tail) = per_cpu(tasklet_hi_vec, cpu).head;
+		__this_cpu_write(tasklet_hi_vec.tail, per_cpu(tasklet_hi_vec, cpu).tail;
 		per_cpu(tasklet_hi_vec, cpu).head = NULL;
-		per_cpu(tasklet_hi_vec, cpu).tail = &per_cpu(tasklet_hi_vec, cpu).head;
+		per_cpu(tasklet_hi_vec, cpu).tail = &per_cpu(tasklet_hi_vec, cpu).head);
 	}
 	raise_softirq_irqoff(HI_SOFTIRQ);
 
Index: linux-2.6/kernel/time/tick-common.c
===================================================================
--- linux-2.6.orig/kernel/time/tick-common.c	2010-11-30 12:40:22.000000000 -0600
+++ linux-2.6/kernel/time/tick-common.c	2010-11-30 12:41:14.000000000 -0600
@@ -49,7 +49,7 @@ struct tick_device *tick_get_device(int
  */
 int tick_is_oneshot_available(void)
 {
-	struct clock_event_device *dev = __get_cpu_var(tick_cpu_device).evtdev;
+	struct clock_event_device *dev = __this_cpu_read(tick_cpu_device.evtdev);
 
 	return dev && (dev->features & CLOCK_EVT_FEAT_ONESHOT);
 }
Index: linux-2.6/kernel/time/tick-oneshot.c
===================================================================
--- linux-2.6.orig/kernel/time/tick-oneshot.c	2010-11-30 12:40:22.000000000 -0600
+++ linux-2.6/kernel/time/tick-oneshot.c	2010-11-30 12:41:14.000000000 -0600
@@ -95,7 +95,7 @@ int tick_dev_program_event(struct clock_
  */
 int tick_program_event(ktime_t expires, int force)
 {
-	struct clock_event_device *dev = __get_cpu_var(tick_cpu_device).evtdev;
+	struct clock_event_device *dev = __this_cpu_read(tick_cpu_device.evtdev);
 
 	return tick_dev_program_event(dev, expires, force);
 }
@@ -167,7 +167,7 @@ int tick_oneshot_mode_active(void)
 	int ret;
 
 	local_irq_save(flags);
-	ret = __get_cpu_var(tick_cpu_device).mode == TICKDEV_MODE_ONESHOT;
+	ret = __this_cpu_read(tick_cpu_device.mode) == TICKDEV_MODE_ONESHOT;
 	local_irq_restore(flags);
 
 	return ret;
Index: linux-2.6/kernel/watchdog.c
===================================================================
--- linux-2.6.orig/kernel/watchdog.c	2010-11-30 12:40:22.000000000 -0600
+++ linux-2.6/kernel/watchdog.c	2010-11-30 12:41:14.000000000 -0600
@@ -116,12 +116,12 @@ static void __touch_watchdog(void)
 {
 	int this_cpu = smp_processor_id();
 
-	__get_cpu_var(watchdog_touch_ts) = get_timestamp(this_cpu);
+	__this_cpu_write(watchdog_touch_ts, get_timestamp(this_cpu));
 }
 
 void touch_softlockup_watchdog(void)
 {
-	__raw_get_cpu_var(watchdog_touch_ts) = 0;
+	__this_cpu_write(watchdog_touch_ts, 0);
 }
 EXPORT_SYMBOL(touch_softlockup_watchdog);
 
@@ -165,12 +165,12 @@ void touch_softlockup_watchdog_sync(void
 /* watchdog detector functions */
 static int is_hardlockup(void)
 {
-	unsigned long hrint = __get_cpu_var(hrtimer_interrupts);
+	unsigned long hrint = __this_cpu_read(hrtimer_interrupts);
 
-	if (__get_cpu_var(hrtimer_interrupts_saved) == hrint)
+	if (__this_cpu_read(hrtimer_interrupts_saved) == hrint)
 		return 1;
 
-	__get_cpu_var(hrtimer_interrupts_saved) = hrint;
+	__this_cpu_write(hrtimer_interrupts_saved, hrint);
 	return 0;
 }
 #endif
@@ -203,8 +203,8 @@ static void watchdog_overflow_callback(s
 	/* Ensure the watchdog never gets throttled */
 	event->hw.interrupts = 0;
 
-	if (__get_cpu_var(watchdog_nmi_touch) == true) {
-		__get_cpu_var(watchdog_nmi_touch) = false;
+	if (__this_cpu_read(watchdog_nmi_touch) == true) {
+		__this_cpu_write(watchdog_nmi_touch, false);
 		return;
 	}
 
@@ -218,7 +218,7 @@ static void watchdog_overflow_callback(s
 		int this_cpu = smp_processor_id();
 
 		/* only print hardlockups once */
-		if (__get_cpu_var(hard_watchdog_warn) == true)
+		if (__this_cpu_read(hard_watchdog_warn) == true)
 			return;
 
 		if (hardlockup_panic)
@@ -226,16 +226,16 @@ static void watchdog_overflow_callback(s
 		else
 			WARN(1, "Watchdog detected hard LOCKUP on cpu %d", this_cpu);
 
-		__get_cpu_var(hard_watchdog_warn) = true;
+		__this_cpu_write(hard_watchdog_warn, true);
 		return;
 	}
 
-	__get_cpu_var(hard_watchdog_warn) = false;
+	__this_cpu_write(hard_watchdog_warn, false);
 	return;
 }
 static void watchdog_interrupt_count(void)
 {
-	__get_cpu_var(hrtimer_interrupts)++;
+	__this_cpu_inc(hrtimer_interrupts);
 }
 #else
 static inline void watchdog_interrupt_count(void) { return; }
@@ -244,7 +244,7 @@ static inline void watchdog_interrupt_co
 /* watchdog kicker functions */
 static enum hrtimer_restart watchdog_timer_fn(struct hrtimer *hrtimer)
 {
-	unsigned long touch_ts = __get_cpu_var(watchdog_touch_ts);
+	unsigned long touch_ts = __this_cpu_read(watchdog_touch_ts);
 	struct pt_regs *regs = get_irq_regs();
 	int duration;
 
@@ -252,18 +252,18 @@ static enum hrtimer_restart watchdog_tim
 	watchdog_interrupt_count();
 
 	/* kick the softlockup detector */
-	wake_up_process(__get_cpu_var(softlockup_watchdog));
+	wake_up_process(__this_cpu_read(softlockup_watchdog));
 
 	/* .. and repeat */
 	hrtimer_forward_now(hrtimer, ns_to_ktime(get_sample_period()));
 
 	if (touch_ts == 0) {
-		if (unlikely(__get_cpu_var(softlockup_touch_sync))) {
+		if (unlikely(__this_cpu_read(softlockup_touch_sync))) {
 			/*
 			 * If the time stamp was touched atomically
 			 * make sure the scheduler tick is up to date.
 			 */
-			__get_cpu_var(softlockup_touch_sync) = false;
+			__this_cpu_write(softlockup_touch_sync, false);
 			sched_clock_tick();
 		}
 		__touch_watchdog();
@@ -279,7 +279,7 @@ static enum hrtimer_restart watchdog_tim
 	duration = is_softlockup(touch_ts);
 	if (unlikely(duration)) {
 		/* only warn once */
-		if (__get_cpu_var(soft_watchdog_warn) == true)
+		if (__this_cpu_read(soft_watchdog_warn) == true)
 			return HRTIMER_RESTART;
 
 		printk(KERN_ERR "BUG: soft lockup - CPU#%d stuck for %us! [%s:%d]\n",
@@ -294,9 +294,9 @@ static enum hrtimer_restart watchdog_tim
 
 		if (softlockup_panic)
 			panic("softlockup: hung tasks");
-		__get_cpu_var(soft_watchdog_warn) = true;
+		__this_cpu_write(soft_watchdog_warn, true);
 	} else
-		__get_cpu_var(soft_watchdog_warn) = false;
+		__this_cpu_write(soft_watchdog_warn, false);
 
 	return HRTIMER_RESTART;
 }
Index: linux-2.6/kernel/printk.c
===================================================================
--- linux-2.6.orig/kernel/printk.c	2010-11-30 12:40:22.000000000 -0600
+++ linux-2.6/kernel/printk.c	2010-11-30 12:41:14.000000000 -0600
@@ -1074,8 +1074,8 @@ static DEFINE_PER_CPU(int, printk_pendin
 
 void printk_tick(void)
 {
-	if (__get_cpu_var(printk_pending)) {
-		__get_cpu_var(printk_pending) = 0;
+	if (__this_cpu_read(printk_pending)) {
+		__this_cpu_write(printk_pending, 0);
 		wake_up_interruptible(&log_wait);
 	}
 }
Index: linux-2.6/include/asm-generic/irq_regs.h
===================================================================
--- linux-2.6.orig/include/asm-generic/irq_regs.h	2010-11-30 12:40:22.000000000 -0600
+++ linux-2.6/include/asm-generic/irq_regs.h	2010-11-30 12:41:14.000000000 -0600
@@ -22,15 +22,15 @@ DECLARE_PER_CPU(struct pt_regs *, __irq_
 
 static inline struct pt_regs *get_irq_regs(void)
 {
-	return __get_cpu_var(__irq_regs);
+	return __this_cpu_read(__irq_regs);
 }
 
 static inline struct pt_regs *set_irq_regs(struct pt_regs *new_regs)
 {
-	struct pt_regs *old_regs, **pp_regs = &__get_cpu_var(__irq_regs);
+	struct pt_regs *old_regs;
 
-	old_regs = *pp_regs;
-	*pp_regs = new_regs;
+	old_regs = __this_cpu_read(__irq_regs);
+	__this_cpu_write(__irq_regs, new_regs);
 	return old_regs;
 }
 
Index: linux-2.6/include/linux/elevator.h
===================================================================
--- linux-2.6.orig/include/linux/elevator.h	2010-11-30 12:40:22.000000000 -0600
+++ linux-2.6/include/linux/elevator.h	2010-11-30 12:41:14.000000000 -0600
@@ -195,15 +195,9 @@ enum {
 /*
  * io context count accounting
  */
-#define elv_ioc_count_mod(name, __val)				\
-	do {							\
-		preempt_disable();				\
-		__get_cpu_var(name) += (__val);			\
-		preempt_enable();				\
-	} while (0)
-
-#define elv_ioc_count_inc(name)	elv_ioc_count_mod(name, 1)
-#define elv_ioc_count_dec(name)	elv_ioc_count_mod(name, -1)
+#define elv_ioc_count_mod(name, __val) this_cpu_add(name, __val)
+#define elv_ioc_count_inc(name)	this_cpu_inc(name)
+#define elv_ioc_count_dec(name)	this_cpu_dec(name)
 
 #define elv_ioc_count_read(name)				\
 ({								\
Index: linux-2.6/include/linux/kernel_stat.h
===================================================================
--- linux-2.6.orig/include/linux/kernel_stat.h	2010-11-30 12:40:22.000000000 -0600
+++ linux-2.6/include/linux/kernel_stat.h	2010-11-30 12:41:14.000000000 -0600
@@ -47,7 +47,7 @@ extern unsigned long long nr_context_swi
 
 #ifndef CONFIG_GENERIC_HARDIRQS
 #define kstat_irqs_this_cpu(irq) \
-	(kstat_this_cpu.irqs[irq])
+	(this_cpu_read(kstat.irqs[irq])
 
 struct irq_desc;
 
Index: linux-2.6/kernel/exit.c
===================================================================
--- linux-2.6.orig/kernel/exit.c	2010-11-30 12:40:22.000000000 -0600
+++ linux-2.6/kernel/exit.c	2010-11-30 12:41:14.000000000 -0600
@@ -69,7 +69,7 @@ static void __unhash_process(struct task
 
 		list_del_rcu(&p->tasks);
 		list_del_init(&p->sibling);
-		__get_cpu_var(process_counts)--;
+		__this_cpu_dec(process_counts);
 	}
 	list_del_rcu(&p->thread_group);
 }
Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c	2010-11-30 12:40:22.000000000 -0600
+++ linux-2.6/kernel/fork.c	2010-11-30 12:41:14.000000000 -0600
@@ -1282,7 +1282,7 @@ static struct task_struct *copy_process(
 			attach_pid(p, PIDTYPE_SID, task_session(current));
 			list_add_tail(&p->sibling, &p->real_parent->children);
 			list_add_tail_rcu(&p->tasks, &init_task.tasks);
-			__get_cpu_var(process_counts)++;
+			__this_cpu_inc(process_counts);
 		}
 		attach_pid(p, PIDTYPE_PID, pid);
 		nr_threads++;
Index: linux-2.6/kernel/hrtimer.c
===================================================================
--- linux-2.6.orig/kernel/hrtimer.c	2010-11-30 12:40:22.000000000 -0600
+++ linux-2.6/kernel/hrtimer.c	2010-11-30 12:41:14.000000000 -0600
@@ -497,7 +497,7 @@ static inline int hrtimer_is_hres_enable
  */
 static inline int hrtimer_hres_active(void)
 {
-	return __get_cpu_var(hrtimer_bases).hres_active;
+	return __this_cpu_read(hrtimer_bases.hres_active);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
