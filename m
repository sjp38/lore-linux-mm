Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 2C5EA6B008C
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 05:33:12 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 36/50] stop_machine: Introduce stop_two_cpus()
Date: Tue, 10 Sep 2013 10:32:16 +0100
Message-Id: <1378805550-29949-37-git-send-email-mgorman@suse.de>
In-Reply-To: <1378805550-29949-1-git-send-email-mgorman@suse.de>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Peter Zijlstra <peterz@infradead.org>

Introduce stop_two_cpus() in order to allow controlled swapping of two
tasks. It repurposes the stop_machine() state machine but only stops
the two cpus which we can do with on-stack structures and avoid
machine wide synchronization issues.

The ordering of CPUs is important to avoid deadlocks. If unordered then
two cpus calling stop_two_cpus on each other simultaneously would attempt
to queue in the opposite order on each CPU causing an AB-BA style deadlock.
By always having the lowest number CPU doing the queueing of works, we can
guarantee that works are always queued in the same order, and deadlocks
are avoided.

[riel@redhat.com: Deadlock avoidance]
Signed-off-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/stop_machine.h |   1 +
 kernel/stop_machine.c        | 272 +++++++++++++++++++++++++++----------------
 2 files changed, 175 insertions(+), 98 deletions(-)

diff --git a/include/linux/stop_machine.h b/include/linux/stop_machine.h
index 3b5e910..d2abbdb 100644
--- a/include/linux/stop_machine.h
+++ b/include/linux/stop_machine.h
@@ -28,6 +28,7 @@ struct cpu_stop_work {
 };
 
 int stop_one_cpu(unsigned int cpu, cpu_stop_fn_t fn, void *arg);
+int stop_two_cpus(unsigned int cpu1, unsigned int cpu2, cpu_stop_fn_t fn, void *arg);
 void stop_one_cpu_nowait(unsigned int cpu, cpu_stop_fn_t fn, void *arg,
 			 struct cpu_stop_work *work_buf);
 int stop_cpus(const struct cpumask *cpumask, cpu_stop_fn_t fn, void *arg);
diff --git a/kernel/stop_machine.c b/kernel/stop_machine.c
index c09f295..32a6c44 100644
--- a/kernel/stop_machine.c
+++ b/kernel/stop_machine.c
@@ -115,6 +115,166 @@ int stop_one_cpu(unsigned int cpu, cpu_stop_fn_t fn, void *arg)
 	return done.executed ? done.ret : -ENOENT;
 }
 
+/* This controls the threads on each CPU. */
+enum multi_stop_state {
+	/* Dummy starting state for thread. */
+	MULTI_STOP_NONE,
+	/* Awaiting everyone to be scheduled. */
+	MULTI_STOP_PREPARE,
+	/* Disable interrupts. */
+	MULTI_STOP_DISABLE_IRQ,
+	/* Run the function */
+	MULTI_STOP_RUN,
+	/* Exit */
+	MULTI_STOP_EXIT,
+};
+
+struct multi_stop_data {
+	int			(*fn)(void *);
+	void			*data;
+	/* Like num_online_cpus(), but hotplug cpu uses us, so we need this. */
+	unsigned int		num_threads;
+	const struct cpumask	*active_cpus;
+
+	enum multi_stop_state	state;
+	atomic_t		thread_ack;
+};
+
+static void set_state(struct multi_stop_data *msdata,
+		      enum multi_stop_state newstate)
+{
+	/* Reset ack counter. */
+	atomic_set(&msdata->thread_ack, msdata->num_threads);
+	smp_wmb();
+	msdata->state = newstate;
+}
+
+/* Last one to ack a state moves to the next state. */
+static void ack_state(struct multi_stop_data *msdata)
+{
+	if (atomic_dec_and_test(&msdata->thread_ack))
+		set_state(msdata, msdata->state + 1);
+}
+
+/* This is the cpu_stop function which stops the CPU. */
+static int multi_cpu_stop(void *data)
+{
+	struct multi_stop_data *msdata = data;
+	enum multi_stop_state curstate = MULTI_STOP_NONE;
+	int cpu = smp_processor_id(), err = 0;
+	unsigned long flags;
+	bool is_active;
+
+	/*
+	 * When called from stop_machine_from_inactive_cpu(), irq might
+	 * already be disabled.  Save the state and restore it on exit.
+	 */
+	local_save_flags(flags);
+
+	if (!msdata->active_cpus)
+		is_active = cpu == cpumask_first(cpu_online_mask);
+	else
+		is_active = cpumask_test_cpu(cpu, msdata->active_cpus);
+
+	/* Simple state machine */
+	do {
+		/* Chill out and ensure we re-read multi_stop_state. */
+		cpu_relax();
+		if (msdata->state != curstate) {
+			curstate = msdata->state;
+			switch (curstate) {
+			case MULTI_STOP_DISABLE_IRQ:
+				local_irq_disable();
+				hard_irq_disable();
+				break;
+			case MULTI_STOP_RUN:
+				if (is_active)
+					err = msdata->fn(msdata->data);
+				break;
+			default:
+				break;
+			}
+			ack_state(msdata);
+		}
+	} while (curstate != MULTI_STOP_EXIT);
+
+	local_irq_restore(flags);
+	return err;
+}
+
+struct irq_cpu_stop_queue_work_info {
+	int cpu1;
+	int cpu2;
+	struct cpu_stop_work *work1;
+	struct cpu_stop_work *work2;
+};
+
+/*
+ * This function is always run with irqs and preemption disabled.
+ * This guarantees that both work1 and work2 get queued, before
+ * our local migrate thread gets the chance to preempt us.
+ */
+static void irq_cpu_stop_queue_work(void *arg)
+{
+	struct irq_cpu_stop_queue_work_info *info = arg;
+	cpu_stop_queue_work(info->cpu1, info->work1);
+	cpu_stop_queue_work(info->cpu2, info->work2);
+}
+
+/**
+ * stop_two_cpus - stops two cpus
+ * @cpu1: the cpu to stop
+ * @cpu2: the other cpu to stop
+ * @fn: function to execute
+ * @arg: argument to @fn
+ *
+ * Stops both the current and specified CPU and runs @fn on one of them.
+ *
+ * returns when both are completed.
+ */
+int stop_two_cpus(unsigned int cpu1, unsigned int cpu2, cpu_stop_fn_t fn, void *arg)
+{
+	int call_cpu;
+	struct cpu_stop_done done;
+	struct cpu_stop_work work1, work2;
+	struct irq_cpu_stop_queue_work_info call_args;
+	struct multi_stop_data msdata = {
+		.fn = fn,
+		.data = arg,
+		.num_threads = 2,
+		.active_cpus = cpumask_of(cpu1),
+	};
+
+	work1 = work2 = (struct cpu_stop_work){
+		.fn = multi_cpu_stop,
+		.arg = &msdata,
+		.done = &done
+	};
+
+	call_args = (struct irq_cpu_stop_queue_work_info){
+		.cpu1 = cpu1,
+		.cpu2 = cpu2,
+		.work1 = &work1,
+		.work2 = &work2,
+	};
+
+	cpu_stop_init_done(&done, 2);
+	set_state(&msdata, MULTI_STOP_PREPARE);
+
+	/*
+	 * Queuing needs to be done by the lowest numbered CPU, to ensure
+	 * that works are always queued in the same order on every CPU.
+	 * This prevents deadlocks.
+	 */
+	call_cpu = min(cpu1, cpu2);
+
+	smp_call_function_single(call_cpu, &irq_cpu_stop_queue_work,
+				 &call_args, 0);
+
+	wait_for_completion(&done.completion);
+	return done.executed ? done.ret : -ENOENT;
+}
+
 /**
  * stop_one_cpu_nowait - stop a cpu but don't wait for completion
  * @cpu: cpu to stop
@@ -359,98 +519,14 @@ early_initcall(cpu_stop_init);
 
 #ifdef CONFIG_STOP_MACHINE
 
-/* This controls the threads on each CPU. */
-enum stopmachine_state {
-	/* Dummy starting state for thread. */
-	STOPMACHINE_NONE,
-	/* Awaiting everyone to be scheduled. */
-	STOPMACHINE_PREPARE,
-	/* Disable interrupts. */
-	STOPMACHINE_DISABLE_IRQ,
-	/* Run the function */
-	STOPMACHINE_RUN,
-	/* Exit */
-	STOPMACHINE_EXIT,
-};
-
-struct stop_machine_data {
-	int			(*fn)(void *);
-	void			*data;
-	/* Like num_online_cpus(), but hotplug cpu uses us, so we need this. */
-	unsigned int		num_threads;
-	const struct cpumask	*active_cpus;
-
-	enum stopmachine_state	state;
-	atomic_t		thread_ack;
-};
-
-static void set_state(struct stop_machine_data *smdata,
-		      enum stopmachine_state newstate)
-{
-	/* Reset ack counter. */
-	atomic_set(&smdata->thread_ack, smdata->num_threads);
-	smp_wmb();
-	smdata->state = newstate;
-}
-
-/* Last one to ack a state moves to the next state. */
-static void ack_state(struct stop_machine_data *smdata)
-{
-	if (atomic_dec_and_test(&smdata->thread_ack))
-		set_state(smdata, smdata->state + 1);
-}
-
-/* This is the cpu_stop function which stops the CPU. */
-static int stop_machine_cpu_stop(void *data)
-{
-	struct stop_machine_data *smdata = data;
-	enum stopmachine_state curstate = STOPMACHINE_NONE;
-	int cpu = smp_processor_id(), err = 0;
-	unsigned long flags;
-	bool is_active;
-
-	/*
-	 * When called from stop_machine_from_inactive_cpu(), irq might
-	 * already be disabled.  Save the state and restore it on exit.
-	 */
-	local_save_flags(flags);
-
-	if (!smdata->active_cpus)
-		is_active = cpu == cpumask_first(cpu_online_mask);
-	else
-		is_active = cpumask_test_cpu(cpu, smdata->active_cpus);
-
-	/* Simple state machine */
-	do {
-		/* Chill out and ensure we re-read stopmachine_state. */
-		cpu_relax();
-		if (smdata->state != curstate) {
-			curstate = smdata->state;
-			switch (curstate) {
-			case STOPMACHINE_DISABLE_IRQ:
-				local_irq_disable();
-				hard_irq_disable();
-				break;
-			case STOPMACHINE_RUN:
-				if (is_active)
-					err = smdata->fn(smdata->data);
-				break;
-			default:
-				break;
-			}
-			ack_state(smdata);
-		}
-	} while (curstate != STOPMACHINE_EXIT);
-
-	local_irq_restore(flags);
-	return err;
-}
-
 int __stop_machine(int (*fn)(void *), void *data, const struct cpumask *cpus)
 {
-	struct stop_machine_data smdata = { .fn = fn, .data = data,
-					    .num_threads = num_online_cpus(),
-					    .active_cpus = cpus };
+	struct multi_stop_data msdata = {
+		.fn = fn,
+		.data = data,
+		.num_threads = num_online_cpus(),
+		.active_cpus = cpus,
+	};
 
 	if (!stop_machine_initialized) {
 		/*
@@ -461,7 +537,7 @@ int __stop_machine(int (*fn)(void *), void *data, const struct cpumask *cpus)
 		unsigned long flags;
 		int ret;
 
-		WARN_ON_ONCE(smdata.num_threads != 1);
+		WARN_ON_ONCE(msdata.num_threads != 1);
 
 		local_irq_save(flags);
 		hard_irq_disable();
@@ -472,8 +548,8 @@ int __stop_machine(int (*fn)(void *), void *data, const struct cpumask *cpus)
 	}
 
 	/* Set the initial state and stop all online cpus. */
-	set_state(&smdata, STOPMACHINE_PREPARE);
-	return stop_cpus(cpu_online_mask, stop_machine_cpu_stop, &smdata);
+	set_state(&msdata, MULTI_STOP_PREPARE);
+	return stop_cpus(cpu_online_mask, multi_cpu_stop, &msdata);
 }
 
 int stop_machine(int (*fn)(void *), void *data, const struct cpumask *cpus)
@@ -513,25 +589,25 @@ EXPORT_SYMBOL_GPL(stop_machine);
 int stop_machine_from_inactive_cpu(int (*fn)(void *), void *data,
 				  const struct cpumask *cpus)
 {
-	struct stop_machine_data smdata = { .fn = fn, .data = data,
+	struct multi_stop_data msdata = { .fn = fn, .data = data,
 					    .active_cpus = cpus };
 	struct cpu_stop_done done;
 	int ret;
 
 	/* Local CPU must be inactive and CPU hotplug in progress. */
 	BUG_ON(cpu_active(raw_smp_processor_id()));
-	smdata.num_threads = num_active_cpus() + 1;	/* +1 for local */
+	msdata.num_threads = num_active_cpus() + 1;	/* +1 for local */
 
 	/* No proper task established and can't sleep - busy wait for lock. */
 	while (!mutex_trylock(&stop_cpus_mutex))
 		cpu_relax();
 
 	/* Schedule work on other CPUs and execute directly for local CPU */
-	set_state(&smdata, STOPMACHINE_PREPARE);
+	set_state(&msdata, MULTI_STOP_PREPARE);
 	cpu_stop_init_done(&done, num_active_cpus());
-	queue_stop_cpus_work(cpu_active_mask, stop_machine_cpu_stop, &smdata,
+	queue_stop_cpus_work(cpu_active_mask, multi_cpu_stop, &msdata,
 			     &done);
-	ret = stop_machine_cpu_stop(&smdata);
+	ret = multi_cpu_stop(&msdata);
 
 	/* Busy wait for completion. */
 	while (!completion_done(&done.completion))
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
