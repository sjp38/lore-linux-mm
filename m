Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 30D916B0031
	for <linux-mm@kvack.org>; Sat, 28 Sep 2013 10:47:41 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc17so3733154pbc.32
        for <linux-mm@kvack.org>; Sat, 28 Sep 2013 07:47:40 -0700 (PDT)
Date: Sat, 28 Sep 2013 16:47:20 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130928144720.GL15690@laptop.programming.kicks-ass.net>
References: <20130925174307.GA3220@laptop.programming.kicks-ass.net>
 <20130925175055.GA25914@redhat.com>
 <20130925184015.GC3657@laptop.programming.kicks-ass.net>
 <20130925212200.GA7959@linux.vnet.ibm.com>
 <20130926111042.GS3081@twins.programming.kicks-ass.net>
 <20130926165840.GA863@redhat.com>
 <20130926175016.GI3657@laptop.programming.kicks-ass.net>
 <20130927181532.GA8401@redhat.com>
 <20130927204116.GJ15690@laptop.programming.kicks-ass.net>
 <20130928124859.GA13425@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130928124859.GA13425@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

On Sat, Sep 28, 2013 at 02:48:59PM +0200, Oleg Nesterov wrote:
> > > >  void cpu_hotplug_done(void)
> > > >  {
> ...
> > > > +	/*
> > > > +	 * Wait for any pending readers to be running. This ensures readers
> > > > +	 * after writer and avoids writers starving readers.
> > > > +	 */
> > > > +	wait_event(cpuhp_writer, !atomic_read(&cpuhp_waitcount));
> > > >  }
> > >
> > > OK, to some degree I can understand "avoids writers starving readers"
> > > part (although the next writer should do synchronize_sched() first),
> > > but could you explain "ensures readers after writer" ?
> >
> > Suppose reader A sees state == BLOCK and goes to sleep; our writer B
> > does cpu_hotplug_done() and wakes all pending readers. If for some
> > reason A doesn't schedule to inc ref until B again executes
> > cpu_hotplug_begin() and state is once again BLOCK, A will not have made
> > any progress.
> 
> Yes, yes, thanks, this is clear. But this explains "writers starving readers".
> And let me repeat, if B again executes cpu_hotplug_begin() it will do
> another synchronize_sched() before it sets BLOCK, so I am not sure we
> need this "in practice".
> 
> I was confused by "ensures readers after writer", I thought this means
> we need the additional synchronization with the readers which are going
> to increment cpuhp_waitcount, say, some sort of barries.

Ah no; I just wanted to guarantee that any pending readers did get a
chance to run. And yes due to the two sync_sched() calls it seems
somewhat unlikely in practise.

> Please note that this wait_event() adds a problem... it doesn't allow
> to "offload" the final synchronize_sched(). Suppose a 4k cpu machine
> does disable_nonboot_cpus(), we do not want 2 * 4k * synchronize_sched's
> in this case. We can solve this, but this wait_event() complicates
> the problem.

That seems like a particularly easy fix; something like so?

---
 include/linux/cpu.h |    1 
 kernel/cpu.c        |   84 ++++++++++++++++++++++++++++++++++------------------
 2 files changed, 56 insertions(+), 29 deletions(-)

--- a/include/linux/cpu.h
+++ b/include/linux/cpu.h
@@ -109,6 +109,7 @@ enum {
 #define CPU_DOWN_FAILED_FROZEN	(CPU_DOWN_FAILED | CPU_TASKS_FROZEN)
 #define CPU_DEAD_FROZEN		(CPU_DEAD | CPU_TASKS_FROZEN)
 #define CPU_DYING_FROZEN	(CPU_DYING | CPU_TASKS_FROZEN)
+#define CPU_POST_DEAD_FROZEN	(CPU_POST_DEAD | CPU_TASKS_FROZEN)
 #define CPU_STARTING_FROZEN	(CPU_STARTING | CPU_TASKS_FROZEN)
 
 
--- a/kernel/cpu.c
+++ b/kernel/cpu.c
@@ -364,8 +364,7 @@ static int __ref take_cpu_down(void *_pa
 	return 0;
 }
 
-/* Requires cpu_add_remove_lock to be held */
-static int __ref _cpu_down(unsigned int cpu, int tasks_frozen)
+static int __ref __cpu_down(unsigned int cpu, int tasks_frozen)
 {
 	int err, nr_calls = 0;
 	void *hcpu = (void *)(long)cpu;
@@ -375,21 +374,13 @@ static int __ref _cpu_down(unsigned int
 		.hcpu = hcpu,
 	};
 
-	if (num_online_cpus() == 1)
-		return -EBUSY;
-
-	if (!cpu_online(cpu))
-		return -EINVAL;
-
-	cpu_hotplug_begin();
-
 	err = __cpu_notify(CPU_DOWN_PREPARE | mod, hcpu, -1, &nr_calls);
 	if (err) {
 		nr_calls--;
 		__cpu_notify(CPU_DOWN_FAILED | mod, hcpu, nr_calls, NULL);
 		printk("%s: attempt to take down CPU %u failed\n",
 				__func__, cpu);
-		goto out_release;
+		return err;
 	}
 	smpboot_park_threads(cpu);
 
@@ -398,7 +389,7 @@ static int __ref _cpu_down(unsigned int
 		/* CPU didn't die: tell everyone.  Can't complain. */
 		smpboot_unpark_threads(cpu);
 		cpu_notify_nofail(CPU_DOWN_FAILED | mod, hcpu);
-		goto out_release;
+		return err;
 	}
 	BUG_ON(cpu_online(cpu));
 
@@ -420,10 +411,27 @@ static int __ref _cpu_down(unsigned int
 
 	check_for_tasks(cpu);
 
-out_release:
+	return err;
+}
+
+/* Requires cpu_add_remove_lock to be held */
+static int __ref _cpu_down(unsigned int cpu, int tasks_frozen)
+{
+	unsigned long mod = tasks_frozen ? CPU_TASKS_FROZEN : 0;
+	int err;
+
+	if (num_online_cpus() == 1)
+		return -EBUSY;
+
+	if (!cpu_online(cpu))
+		return -EINVAL;
+
+	cpu_hotplug_begin();
+	err = __cpu_down(cpu, tasks_frozen);
 	cpu_hotplug_done();
+
 	if (!err)
-		cpu_notify_nofail(CPU_POST_DEAD | mod, hcpu);
+		cpu_notify_nofail(CPU_POST_DEAD | mod, (void *)(long)cpu);
 	return err;
 }
 
@@ -447,30 +455,22 @@ int __ref cpu_down(unsigned int cpu)
 EXPORT_SYMBOL(cpu_down);
 #endif /*CONFIG_HOTPLUG_CPU*/
 
-/* Requires cpu_add_remove_lock to be held */
-static int _cpu_up(unsigned int cpu, int tasks_frozen)
+static int ___cpu_up(unsigned int cpu, int tasks_frozen)
 {
 	int ret, nr_calls = 0;
 	void *hcpu = (void *)(long)cpu;
 	unsigned long mod = tasks_frozen ? CPU_TASKS_FROZEN : 0;
 	struct task_struct *idle;
 
-	cpu_hotplug_begin();
-
-	if (cpu_online(cpu) || !cpu_present(cpu)) {
-		ret = -EINVAL;
-		goto out;
-	}
-
 	idle = idle_thread_get(cpu);
 	if (IS_ERR(idle)) {
 		ret = PTR_ERR(idle);
-		goto out;
+		return ret;
 	}
 
 	ret = smpboot_create_threads(cpu);
 	if (ret)
-		goto out;
+		return ret;
 
 	ret = __cpu_notify(CPU_UP_PREPARE | mod, hcpu, -1, &nr_calls);
 	if (ret) {
@@ -492,9 +492,24 @@ static int _cpu_up(unsigned int cpu, int
 	/* Now call notifier in preparation. */
 	cpu_notify(CPU_ONLINE | mod, hcpu);
 
+	return 0;
+
 out_notify:
-	if (ret != 0)
-		__cpu_notify(CPU_UP_CANCELED | mod, hcpu, nr_calls, NULL);
+	__cpu_notify(CPU_UP_CANCELED | mod, hcpu, nr_calls, NULL);
+	return ret;
+}
+
+/* Requires cpu_add_remove_lock to be held */
+static int _cpu_up(unsigned int cpu, int tasks_frozen)
+{
+	cpu_hotplug_begin();
+
+	if (cpu_online(cpu) || !cpu_present(cpu)) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	ret = ___cpu_up(cpu, tasks_frozen);
 out:
 	cpu_hotplug_done();
 
@@ -572,11 +587,13 @@ int disable_nonboot_cpus(void)
 	 */
 	cpumask_clear(frozen_cpus);
 
+	cpu_hotplug_begin();
+
 	printk("Disabling non-boot CPUs ...\n");
 	for_each_online_cpu(cpu) {
 		if (cpu == first_cpu)
 			continue;
-		error = _cpu_down(cpu, 1);
+		error = __cpu_down(cpu, 1);
 		if (!error)
 			cpumask_set_cpu(cpu, frozen_cpus);
 		else {
@@ -586,6 +603,11 @@ int disable_nonboot_cpus(void)
 		}
 	}
 
+	cpu_hotplug_done();
+
+	for_each_cpu(cpu, frozen_cpus)
+		cpu_notify_nofail(CPU_POST_DEAD_FROZEN, (void*)(long)cpu);
+
 	if (!error) {
 		BUG_ON(num_online_cpus() > 1);
 		/* Make sure the CPUs won't be enabled by someone else */
@@ -619,8 +641,10 @@ void __ref enable_nonboot_cpus(void)
 
 	arch_enable_nonboot_cpus_begin();
 
+	cpu_hotplug_begin();
+
 	for_each_cpu(cpu, frozen_cpus) {
-		error = _cpu_up(cpu, 1);
+		error = ___cpu_up(cpu, 1);
 		if (!error) {
 			printk(KERN_INFO "CPU%d is up\n", cpu);
 			continue;
@@ -628,6 +652,8 @@ void __ref enable_nonboot_cpus(void)
 		printk(KERN_WARNING "Error taking CPU%d up: %d\n", cpu, error);
 	}
 
+	cpu_hotplug_done();
+
 	arch_enable_nonboot_cpus_end();
 
 	cpumask_clear(frozen_cpus);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
