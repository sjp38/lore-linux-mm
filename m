Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id D72B1680F7F
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:48:39 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id r129so69569650wmr.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 07:48:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e8si29180144wjx.113.2016.01.25.07.48.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 25 Jan 2016 07:48:38 -0800 (PST)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v4 22/22] thermal/intel_powerclamp: Convert the kthread to kthread worker API
Date: Mon, 25 Jan 2016 16:45:11 +0100
Message-Id: <1453736711-6703-23-git-send-email-pmladek@suse.com>
In-Reply-To: <1453736711-6703-1-git-send-email-pmladek@suse.com>
References: <1453736711-6703-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>, Zhang Rui <rui.zhang@intel.com>, Eduardo Valentin <edubezval@gmail.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-pm@vger.kernel.org

Kthreads are currently implemented as an infinite loop. Each
has its own variant of checks for terminating, freezing,
awakening. In many cases it is unclear to say in which state
it is and sometimes it is done a wrong way.

The plan is to convert kthreads into kthread_worker or workqueues
API. It allows to split the functionality into separate operations.
It helps to make a better structure. Also it defines a clean state
where no locks are taken, IRQs blocked, the kthread might sleep
or even be safely migrated.

The kthread worker API is useful when we want to have a dedicated
single thread for the work. It helps to make sure that it is
available when needed. Also it allows a better control, e.g.
define a scheduling priority.

This patch converts the intel powerclamp kthreads into the kthread
worker because they need to have a good control over the assigned
CPUs.

IMHO, the most natural way is to split one cycle into two works.
First one does some balancing and let the CPU work normal
way for some time. The second work checks what the CPU has done
in the meantime and put it into C-state to reach the required
idle time ratio. The delay between the two works is achieved
by the delayed kthread work.

The two works have to share some data that used to be local
variables of the single kthread function. This is achieved
by the new per-CPU struct kthread_worker_data. It might look
as a complication. On the other hand, the long original kthread
function was not nice either.

The patch tries to avoid extra init and cleanup works. All the
actions might be done outside the thread. They are moved
to the functions that create or destroy the worker. Especially,
I checked that the timers are assigned to the right CPU.

The two works are queuing each other. It makes it a bit tricky to
break it when we want to stop the worker. We use the global and
per-worker "clamping" variables to make sure that the re-queuing
eventually stops. We also cancel the works to make it faster.
Note that the canceling is not reliable because the handling
of the two variables and queuing is not synchronized via a lock.
But it is not a big deal because it is just an optimization.
The job is stopped faster than before in most cases.

Signed-off-by: Petr Mladek <pmladek@suse.com>
CC: Zhang Rui <rui.zhang@intel.com>
CC: Eduardo Valentin <edubezval@gmail.com>
CC: Jacob Pan <jacob.jun.pan@linux.intel.com>
CC: linux-pm@vger.kernel.org
---
 drivers/thermal/intel_powerclamp.c | 287 ++++++++++++++++++++++---------------
 1 file changed, 168 insertions(+), 119 deletions(-)

diff --git a/drivers/thermal/intel_powerclamp.c b/drivers/thermal/intel_powerclamp.c
index cb32c38f9828..58ea1862d412 100644
--- a/drivers/thermal/intel_powerclamp.c
+++ b/drivers/thermal/intel_powerclamp.c
@@ -86,11 +86,27 @@ static unsigned int control_cpu; /* The cpu assigned to collect stat and update
 				  */
 static bool clamping;
 
+static const struct sched_param sparam = {
+	.sched_priority = MAX_USER_RT_PRIO / 2,
+};
+struct powerclamp_worker_data {
+	struct kthread_worker *worker;
+	struct kthread_work balancing_work;
+	struct delayed_kthread_work idle_injection_work;
+	struct timer_list wakeup_timer;
+	unsigned int cpu;
+	unsigned int count;
+	unsigned int guard;
+	unsigned int window_size_now;
+	unsigned int target_ratio;
+	unsigned int duration_jiffies;
+	bool clamping;
+};
 
-static struct task_struct * __percpu *powerclamp_thread;
+static struct powerclamp_worker_data * __percpu worker_data;
 static struct thermal_cooling_device *cooling_dev;
 static unsigned long *cpu_clamping_mask;  /* bit map for tracking per cpu
-					   * clamping thread
+					   * clamping kthread worker
 					   */
 
 static unsigned int duration;
@@ -368,100 +384,102 @@ static bool powerclamp_adjust_controls(unsigned int target_ratio,
 	return set_target_ratio + guard <= current_ratio;
 }
 
-static int clamp_thread(void *arg)
+static void clamp_balancing_func(struct kthread_work *work)
 {
-	int cpunr = (unsigned long)arg;
-	DEFINE_TIMER(wakeup_timer, noop_timer, 0, 0);
-	static const struct sched_param param = {
-		.sched_priority = MAX_USER_RT_PRIO/2,
-	};
-	unsigned int count = 0;
-	unsigned int target_ratio;
+	struct powerclamp_worker_data *w_data;
+	int sleeptime;
+	unsigned long target_jiffies;
+	unsigned int compensation;
+	int interval; /* jiffies to sleep for each attempt */
 
-	set_bit(cpunr, cpu_clamping_mask);
-	set_freezable();
-	init_timer_on_stack(&wakeup_timer);
-	sched_setscheduler(current, SCHED_FIFO, &param);
-
-	while (true == clamping && !kthread_should_stop() &&
-		cpu_online(cpunr)) {
-		int sleeptime;
-		unsigned long target_jiffies;
-		unsigned int guard;
-		unsigned int compensation = 0;
-		int interval; /* jiffies to sleep for each attempt */
-		unsigned int duration_jiffies = msecs_to_jiffies(duration);
-		unsigned int window_size_now;
-
-		try_to_freeze();
-		/*
-		 * make sure user selected ratio does not take effect until
-		 * the next round. adjust target_ratio if user has changed
-		 * target such that we can converge quickly.
-		 */
-		target_ratio = set_target_ratio;
-		guard = 1 + target_ratio/20;
-		window_size_now = window_size;
-		count++;
+	w_data = container_of(work, struct powerclamp_worker_data,
+			      balancing_work);
 
-		/*
-		 * systems may have different ability to enter package level
-		 * c-states, thus we need to compensate the injected idle ratio
-		 * to achieve the actual target reported by the HW.
-		 */
-		compensation = get_compensation(target_ratio);
-		interval = duration_jiffies*100/(target_ratio+compensation);
-
-		/* align idle time */
-		target_jiffies = roundup(jiffies, interval);
-		sleeptime = target_jiffies - jiffies;
-		if (sleeptime <= 0)
-			sleeptime = 1;
-		schedule_timeout_interruptible(sleeptime);
-		/*
-		 * only elected controlling cpu can collect stats and update
-		 * control parameters.
-		 */
-		if (cpunr == control_cpu && !(count%window_size_now)) {
-			should_skip =
-				powerclamp_adjust_controls(target_ratio,
-							guard, window_size_now);
-			smp_mb();
-		}
+	/*
+	 * make sure user selected ratio does not take effect until
+	 * the next round. adjust target_ratio if user has changed
+	 * target such that we can converge quickly.
+	 */
+	w_data->target_ratio = READ_ONCE(set_target_ratio);
+	w_data->guard = 1 + w_data->target_ratio / 20;
+	w_data->window_size_now = window_size;
+	w_data->duration_jiffies = msecs_to_jiffies(duration);
+	w_data->count++;
+
+	/*
+	 * systems may have different ability to enter package level
+	 * c-states, thus we need to compensate the injected idle ratio
+	 * to achieve the actual target reported by the HW.
+	 */
+	compensation = get_compensation(w_data->target_ratio);
+	interval = w_data->duration_jiffies * 100 /
+		(w_data->target_ratio + compensation);
+
+	/* align idle time */
+	target_jiffies = roundup(jiffies, interval);
+	sleeptime = target_jiffies - jiffies;
+	if (sleeptime <= 0)
+		sleeptime = 1;
+
+	if (clamping && w_data->clamping && cpu_online(w_data->cpu))
+		queue_delayed_kthread_work(w_data->worker,
+					   &w_data->idle_injection_work,
+					   sleeptime);
+}
+
+static void clamp_idle_injection_func(struct kthread_work *work)
+{
+	struct powerclamp_worker_data *w_data;
+	unsigned long target_jiffies;
+
+	w_data = container_of(work, struct powerclamp_worker_data,
+			      idle_injection_work.work);
+
+	/*
+	 * only elected controlling cpu can collect stats and update
+	 * control parameters.
+	 */
+	if (w_data->cpu == control_cpu &&
+	    !(w_data->count % w_data->window_size_now)) {
+		should_skip =
+			powerclamp_adjust_controls(w_data->target_ratio,
+						   w_data->guard,
+						   w_data->window_size_now);
+		smp_mb();
+	}
 
-		if (should_skip)
-			continue;
+	if (should_skip)
+		goto balance;
+
+	target_jiffies = jiffies + w_data->duration_jiffies;
+	mod_timer(&w_data->wakeup_timer, target_jiffies);
+	if (unlikely(local_softirq_pending()))
+		goto balance;
+	/*
+	 * stop tick sched during idle time, interrupts are still
+	 * allowed. thus jiffies are updated properly.
+	 */
+	preempt_disable();
+	/* mwait until target jiffies is reached */
+	while (time_before(jiffies, target_jiffies)) {
+		unsigned long ecx = 1;
+		unsigned long eax = target_mwait;
 
-		target_jiffies = jiffies + duration_jiffies;
-		mod_timer(&wakeup_timer, target_jiffies);
-		if (unlikely(local_softirq_pending()))
-			continue;
 		/*
-		 * stop tick sched during idle time, interrupts are still
-		 * allowed. thus jiffies are updated properly.
+		 * REVISIT: may call enter_idle() to notify drivers who
+		 * can save power during cpu idle. same for exit_idle()
 		 */
-		preempt_disable();
-		/* mwait until target jiffies is reached */
-		while (time_before(jiffies, target_jiffies)) {
-			unsigned long ecx = 1;
-			unsigned long eax = target_mwait;
-
-			/*
-			 * REVISIT: may call enter_idle() to notify drivers who
-			 * can save power during cpu idle. same for exit_idle()
-			 */
-			local_touch_nmi();
-			stop_critical_timings();
-			mwait_idle_with_hints(eax, ecx);
-			start_critical_timings();
-			atomic_inc(&idle_wakeup_counter);
-		}
-		preempt_enable();
+		local_touch_nmi();
+		stop_critical_timings();
+		mwait_idle_with_hints(eax, ecx);
+		start_critical_timings();
+		atomic_inc(&idle_wakeup_counter);
 	}
-	del_timer_sync(&wakeup_timer);
-	clear_bit(cpunr, cpu_clamping_mask);
+	preempt_enable();
 
-	return 0;
+balance:
+	if (clamping && w_data->clamping && cpu_online(w_data->cpu))
+		queue_kthread_work(w_data->worker, &w_data->balancing_work);
 }
 
 /*
@@ -505,22 +523,58 @@ static void poll_pkg_cstate(struct work_struct *dummy)
 		schedule_delayed_work(&poll_pkg_cstate_work, HZ);
 }
 
-static void start_power_clamp_thread(unsigned long cpu)
+static void start_power_clamp_worker(unsigned long cpu)
 {
-	struct task_struct **p = per_cpu_ptr(powerclamp_thread, cpu);
-	struct task_struct *thread;
-
-	thread = kthread_create_on_node(clamp_thread,
-					(void *) cpu,
-					cpu_to_node(cpu),
-					"kidle_inject/%ld", cpu);
-	if (IS_ERR(thread))
+	struct powerclamp_worker_data *w_data = per_cpu_ptr(worker_data, cpu);
+	struct kthread_worker *worker;
+
+	worker = create_kthread_worker_on_cpu(KTW_FREEZABLE, cpu,
+					      "kidle_inject/%ld");
+	if (IS_ERR(worker))
 		return;
 
-	/* bind to cpu here */
-	kthread_bind(thread, cpu);
-	wake_up_process(thread);
-	*p = thread;
+	w_data->worker = worker;
+	w_data->count = 0;
+	w_data->cpu = cpu;
+	w_data->clamping = true;
+	set_bit(cpu, cpu_clamping_mask);
+	setup_timer(&w_data->wakeup_timer, noop_timer, 0);
+	sched_setscheduler(worker->task, SCHED_FIFO, &sparam);
+	init_kthread_work(&w_data->balancing_work, clamp_balancing_func);
+	init_delayed_kthread_work(&w_data->idle_injection_work,
+				  clamp_idle_injection_func);
+	queue_kthread_work(w_data->worker, &w_data->balancing_work);
+}
+
+static void stop_power_clamp_worker(unsigned long cpu)
+{
+	struct powerclamp_worker_data *w_data = per_cpu_ptr(worker_data, cpu);
+
+	if (!w_data->worker)
+		return;
+
+	w_data->clamping = false;
+	/*
+	 * Make sure that all works that get queued after this point see
+	 * the clamping disabled. The counter part is not needed because
+	 * there is an implicit memory barrier when the queued work
+	 * is proceed.
+	 */
+	smp_wmb();
+	cancel_kthread_work_sync(&w_data->balancing_work);
+	cancel_delayed_kthread_work_sync(&w_data->idle_injection_work);
+	/*
+	 * The balancing work still might be queued here because
+	 * the handling of the "clapming" variable, cancel, and queue
+	 * operations are not synchronized via a lock. But it is not
+	 * a big deal. The balancing work is fast and destroy kthread
+	 * will wait for it.
+	 */
+	del_timer_sync(&w_data->wakeup_timer);
+	clear_bit(w_data->cpu, cpu_clamping_mask);
+	destroy_kthread_worker(w_data->worker);
+
+	w_data->worker = NULL;
 }
 
 static int start_power_clamp(void)
@@ -545,9 +599,9 @@ static int start_power_clamp(void)
 	clamping = true;
 	schedule_delayed_work(&poll_pkg_cstate_work, 0);
 
-	/* start one thread per online cpu */
+	/* start one kthread worker per online cpu */
 	for_each_online_cpu(cpu) {
-		start_power_clamp_thread(cpu);
+		start_power_clamp_worker(cpu);
 	}
 	put_online_cpus();
 
@@ -557,20 +611,17 @@ static int start_power_clamp(void)
 static void end_power_clamp(void)
 {
 	int i;
-	struct task_struct *thread;
 
-	clamping = false;
 	/*
-	 * make clamping visible to other cpus and give per cpu clamping threads
-	 * sometime to exit, or gets killed later.
+	 * Block requeuing in all the kthread workers. They will drain and
+	 * stop faster.
 	 */
-	smp_mb();
-	msleep(20);
+	clamping = false;
 	if (bitmap_weight(cpu_clamping_mask, num_possible_cpus())) {
 		for_each_set_bit(i, cpu_clamping_mask, num_possible_cpus()) {
-			pr_debug("clamping thread for cpu %d alive, kill\n", i);
-			thread = *per_cpu_ptr(powerclamp_thread, i);
-			kthread_stop(thread);
+			pr_debug("clamping worker for cpu %d alive, destroy\n",
+				 i);
+			stop_power_clamp_worker(i);
 		}
 	}
 }
@@ -579,15 +630,13 @@ static int powerclamp_cpu_callback(struct notifier_block *nfb,
 				unsigned long action, void *hcpu)
 {
 	unsigned long cpu = (unsigned long)hcpu;
-	struct task_struct **percpu_thread =
-		per_cpu_ptr(powerclamp_thread, cpu);
 
 	if (false == clamping)
 		goto exit_ok;
 
 	switch (action) {
 	case CPU_ONLINE:
-		start_power_clamp_thread(cpu);
+		start_power_clamp_worker(cpu);
 		/* prefer BSP as controlling CPU */
 		if (cpu == 0) {
 			control_cpu = 0;
@@ -598,7 +647,7 @@ static int powerclamp_cpu_callback(struct notifier_block *nfb,
 		if (test_bit(cpu, cpu_clamping_mask)) {
 			pr_err("cpu %lu dead but powerclamping thread is not\n",
 				cpu);
-			kthread_stop(*percpu_thread);
+			stop_power_clamp_worker(cpu);
 		}
 		if (cpu == control_cpu) {
 			control_cpu = smp_processor_id();
@@ -785,8 +834,8 @@ static int __init powerclamp_init(void)
 	window_size = 2;
 	register_hotcpu_notifier(&powerclamp_cpu_notifier);
 
-	powerclamp_thread = alloc_percpu(struct task_struct *);
-	if (!powerclamp_thread) {
+	worker_data = alloc_percpu(struct powerclamp_worker_data);
+	if (!worker_data) {
 		retval = -ENOMEM;
 		goto exit_unregister;
 	}
@@ -806,7 +855,7 @@ static int __init powerclamp_init(void)
 	return 0;
 
 exit_free_thread:
-	free_percpu(powerclamp_thread);
+	free_percpu(worker_data);
 exit_unregister:
 	unregister_hotcpu_notifier(&powerclamp_cpu_notifier);
 exit_free:
@@ -819,7 +868,7 @@ static void __exit powerclamp_exit(void)
 {
 	unregister_hotcpu_notifier(&powerclamp_cpu_notifier);
 	end_power_clamp();
-	free_percpu(powerclamp_thread);
+	free_percpu(worker_data);
 	thermal_cooling_device_unregister(cooling_dev);
 	kfree(cpu_clamping_mask);
 
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
