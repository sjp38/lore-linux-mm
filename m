Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3C7666B011A
	for <linux-mm@kvack.org>; Thu,  8 May 2014 17:29:07 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id g10so2764119pdj.24
        for <linux-mm@kvack.org>; Thu, 08 May 2014 14:29:06 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id td10si1106554pac.17.2014.05.08.14.29.05
        for <linux-mm@kvack.org>;
        Thu, 08 May 2014 14:29:06 -0700 (PDT)
Date: Thu, 8 May 2014 14:29:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: vmstat: On demand vmstat workers V4
Message-Id: <20140508142903.c2ef166c95d2b8acd0d7ea7d@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.10.1405081033090.23786@gentwo.org>
References: <alpine.DEB.2.10.1405081033090.23786@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org

(tglx poke)

On Thu, 8 May 2014 10:35:15 -0500 (CDT) Christoph Lameter <cl@linux.com> wrote:

> There were numerous requests for an update of this patch.
> 
> 
> V3->V4:
> - Make the shepherd task not deferrable. It runs on the tick cpu
>   anyways. Deferral could get deltas too far out of sync if
>   vmstat operations are disabled for a certain processor.
> 
> V2->V3:
> - Introduce a new tick_get_housekeeping_cpu() function. Not sure
>   if that is exactly what we want but it is a start. Thomas?
> - Migrate the shepherd task if the output of
>   tick_get_housekeeping_cpu() changes.
> - Fixes recommended by Andrew.
> 
> V1->V2:
> - Optimize the need_update check by using memchr_inv.
> - Clean up.
> 
> vmstat workers are used for folding counter differentials into the
> zone, per node and global counters at certain time intervals.
> They currently run at defined intervals on all processors which will
> cause some holdoff for processors that need minimal intrusion by the
> OS.
> 
> The current vmstat_update mechanism depends on a deferrable timer
> firing every other second by default which registers a work queue item
> that runs on the local CPU, with the result that we have 1 interrupt
> and one additional schedulable task on each CPU every 2 seconds
> If a workload indeed causes VM activity or multiple tasks are running
> on a CPU, then there are probably bigger issues to deal with.
> 
> However, some workloads dedicate a CPU for a single CPU bound task.
> This is done in high performance computing, in high frequency
> financial applications, in networking (Intel DPDK, EZchip NPS) and with
> the advent of systems with more and more CPUs over time, this may become
> more and more common to do since when one has enough CPUs
> one cares less about efficiently sharing a CPU with other tasks and
> more about efficiently monopolizing a CPU per task.
> 
> The difference of having this timer firing and workqueue kernel thread
> scheduled per second can be enormous. An artificial test measuring the
> worst case time to do a simple "i++" in an endless loop on a bare metal
> system and under Linux on an isolated CPU with dynticks and with and
> without this patch, have Linux match the bare metal performance
> (~700 cycles) with this patch and loose by couple of orders of magnitude
> (~200k cycles) without it[*].  The loss occurs for something that just
> calculates statistics. For networking applications, for example, this
> could be the difference between dropping packets or sustaining line rate.
> 
> Statistics are important and useful, but it would be great if there
> would be a way to not cause statistics gathering produce a huge
> performance difference. This patche does just that.
> 
> This patch creates a vmstat shepherd worker that monitors the
> per cpu differentials on all processors. If there are differentials
> on a processor then a vmstat worker local to the processors
> with the differentials is created. That worker will then start
> folding the diffs in regular intervals. Should the worker
> find that there is no work to be done then it will make the shepherd
> worker monitor the differentials again.
> 
> With this patch it is possible then to have periods longer than
> 2 seconds without any OS event on a "cpu" (hardware thread).

Some explanation of the changes to kernel/time/tick-common.c would be
appropriate.

>
> ...
>
> +
> +/*
> + * Fold a differential into the global counters.
> + * Returns the number of counters updated.
> + */
> +static inline int fold_diff(int *diff)
>  {
>  	int i;
> +	int changes = 0;
> 
>  	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
> -		if (diff[i])
> +		if (diff[i]) {
>  			atomic_long_add(diff[i], &vm_stat[i]);
> +			changes++;
> +	}
> +	return changes;
>  }

This is too large to be inlined.  It has a single callsite so the
compiler will presumably choose to inline it regardless of whether we
put "inline" in the definition.

>  /*
>
> ...
>
> @@ -1222,12 +1239,15 @@
>  #ifdef CONFIG_SMP
>  static DEFINE_PER_CPU(struct delayed_work, vmstat_work);
>  int sysctl_stat_interval __read_mostly = HZ;
> +static struct cpumask *monitored_cpus;
> 
>  static void vmstat_update(struct work_struct *w)
>  {
> -	refresh_cpu_vm_stats();
> -	schedule_delayed_work(&__get_cpu_var(vmstat_work),
> -		round_jiffies_relative(sysctl_stat_interval));
> +	if (refresh_cpu_vm_stats())
> +		schedule_delayed_work(this_cpu_ptr(&vmstat_work),
> +			round_jiffies_relative(sysctl_stat_interval));
> +	else
> +		cpumask_set_cpu(smp_processor_id(), monitored_cpus);
>  }

This function is the core of this design and would be a good place to
document it all.  Where we decide to call schedule_delayed_work(), add
a comment explaining why.  Where we decide to call cpumask_set_cpu(),
add a comment explaining why.


>  static void start_cpu_timer(int cpu)
> @@ -1235,7 +1255,69 @@
>  	struct delayed_work *work = &per_cpu(vmstat_work, cpu);
> 
>  	INIT_DEFERRABLE_WORK(work, vmstat_update);
> -	schedule_delayed_work_on(cpu, work, __round_jiffies_relative(HZ, cpu));
> +	schedule_delayed_work_on(cpu, work,
> +		__round_jiffies_relative(sysctl_stat_interval, cpu));
> +}
> +
> +/*
> + * Check if the diffs for a certain cpu indicate that
> + * an update is needed.
> + */
> +static bool need_update(int cpu)
> +{
> +	struct zone *zone;
> +
> +	for_each_populated_zone(zone) {
> +		struct per_cpu_pageset *p = per_cpu_ptr(zone->pageset, cpu);
> +
> +		/*
> +		 * The fast way of checking if there are any vmstat diffs.
> +		 * This works because the diffs are byte sized items.
> +		 */

yikes.

I guess

		BUILD_BUG_ON(sizeof(p->vm_stat_diff[0]) != 1);

will help address the obvious maintainability concern.

> +		if (memchr_inv(p->vm_stat_diff, 0, NR_VM_ZONE_STAT_ITEMS))
> +			return true;
> +	}
> +	return false;
> +}
> +
> +static void vmstat_shepherd(struct work_struct *w)

Let's document the design here also.  What does it do, why does it do
it, how does it do it.  We know how to do this.

> +{
> +	int cpu;
> +	int s = tick_get_housekeeping_cpu();
> +	struct delayed_work *d = per_cpu_ptr(&vmstat_work, s);
> +
> +	refresh_cpu_vm_stats();
> +	for_each_cpu(cpu, monitored_cpus)
> +		if (need_update(cpu)) {
> +			cpumask_clear_cpu(cpu, monitored_cpus);

Obvious race is obvious.  Let's either fix the race or tell readers
what the consequences are and why it's OK.

> +			start_cpu_timer(cpu);
> +		}
> +
> +	if (s != smp_processor_id()) {
> +		/* Timekeeping was moved. Move the shepherd worker */

You mean "move the shepherd worker to follow the timekeeping CPU.  We
do this because ..."

> +		cancel_delayed_work_sync(d);
> +		cpumask_set_cpu(smp_processor_id(), monitored_cpus);
> +		cpumask_clear_cpu(s, monitored_cpus);
> +		INIT_DELAYED_WORK(d, vmstat_shepherd);

INIT_DELAYED_WORK() seems inappropriate here.  It's generally used for
once-off initialisation of a freshly allocated work item.  Look at all
the stuff it does - do we really want to run debug_object_init()
against an active object?

> +	}
> +
> +	schedule_delayed_work_on(s, d,
> +		__round_jiffies_relative(sysctl_stat_interval, s));
> +
> +}
> +
> +static void __init start_shepherd_timer(void)
> +{
> +	int cpu = tick_get_housekeeping_cpu();
> +	struct delayed_work *d = per_cpu_ptr(&vmstat_work, cpu);
> +
> +	INIT_DELAYED_WORK(d, vmstat_shepherd);
> +	monitored_cpus = kmalloc(BITS_TO_LONGS(nr_cpu_ids) * sizeof(long),
> +			GFP_KERNEL);
> +	cpumask_copy(monitored_cpus, cpu_online_mask);
> +	cpumask_clear_cpu(cpu, monitored_cpus);
> +	schedule_delayed_work_on(cpu, d,
> +		__round_jiffies_relative(sysctl_stat_interval, cpu));
>  }
> 
>  static void vmstat_cpu_dead(int node)
> @@ -1266,17 +1348,19 @@
>  	case CPU_ONLINE:
>  	case CPU_ONLINE_FROZEN:
>  		refresh_zone_stat_thresholds();
> -		start_cpu_timer(cpu);
>  		node_set_state(cpu_to_node(cpu), N_CPU);
> +		cpumask_set_cpu(cpu, monitored_cpus);
>  		break;
>  	case CPU_DOWN_PREPARE:
>  	case CPU_DOWN_PREPARE_FROZEN:
> -		cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
> +		if (!cpumask_test_cpu(cpu, monitored_cpus))

This test is inverted isn't it?

> +			cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
> +		cpumask_clear_cpu(cpu, monitored_cpus);
>  		per_cpu(vmstat_work, cpu).work.func = NULL;
>  		break;
>  	case CPU_DOWN_FAILED:
>  	case CPU_DOWN_FAILED_FROZEN:
> -		start_cpu_timer(cpu);
> +		cpumask_set_cpu(cpu, monitored_cpus);
>  		break;
>  	case CPU_DEAD:
>  	case CPU_DEAD_FROZEN:
>
> ...
>
> --- linux.orig/kernel/time/tick-common.c	2014-05-06 10:51:19.711239813 -0500
> +++ linux/kernel/time/tick-common.c	2014-05-06 10:51:19.711239813 -0500
> @@ -222,6 +222,24 @@
>  		tick_setup_oneshot(newdev, handler, next_event);
>  }
> 
> +/*
> + * Return a cpu number that may be used to run housekeeping
> + * tasks. This is usually the timekeeping cpu unless that
> + * is not available. Then we simply fall back to the current
> + * cpu.
> + */

This comment is unusably vague.  What the heck is a "housekeeping
task"?  Why would anyone call this and what is special about the CPU
number it returns?


> +int tick_get_housekeeping_cpu(void)
> +{
> +	int cpu;
> +
> +	if (system_state < SYSTEM_RUNNING || tick_do_timer_cpu < 0)
> +		cpu = raw_smp_processor_id();
> +	else
> +		cpu = tick_do_timer_cpu;
> +
> +	return cpu;
> +}
> +
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
