Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0D2C06B0032
	for <linux-mm@kvack.org>; Wed, 18 Sep 2013 18:07:04 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id ma3so7572972pbc.35
        for <linux-mm@kvack.org>; Wed, 18 Sep 2013 15:07:04 -0700 (PDT)
Date: Wed, 18 Sep 2013 15:06:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: RFC vmstat: On demand vmstat threads
Message-Id: <20130918150659.5091a2c3ca94b99304427ec5@linux-foundation.org>
In-Reply-To: <0000014109b8e5db-4b0f577e-c3b4-47fe-b7f2-0e5febbcc948-000000@email.amazonses.com>
References: <00000140e9dfd6bd-40db3d4f-c1be-434f-8132-7820f81bb586-000000@email.amazonses.com>
	<CAOtvUMdfqyg80_9J8AnOaAdahuRYGC-bpemdo_oucDBPguXbVA@mail.gmail.com>
	<0000014109b8e5db-4b0f577e-c3b4-47fe-b7f2-0e5febbcc948-000000@email.amazonses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>

On Tue, 10 Sep 2013 21:13:34 +0000 Christoph Lameter <cl@linux.com> wrote:

> Subject: vmstat: On demand vmstat workers V2

grumbles.

> vmstat threads are used for folding counter differentials into the
> zone, per node and global counters at certain time intervals.

These are not "threads".  Let's please use accurate terminology
("keventd works" is close enough) and not inappropriately repurpose
well-understood terms.

> They currently run at defined intervals on all processors which will
> cause some holdoff for processors that need minimal intrusion by the
> OS.
> 
> This patch creates a vmstat shepherd task that monitors the

No, it does not call kthread_run() hence it does not create a task.  Or
a thread.

> per cpu differentials on all processors. If there are differentials
> on a processor then a vmstat worker thread local to the processors
> with the differentials is created. That worker will then start
> folding the diffs in regular intervals. Should the worker
> find that there is no work to be done then it will
> terminate itself and make the shepherd task monitor the differentials
> again.
> 
> With this patch it is possible then to have periods longer than
> 2 seconds without any OS event on a "cpu" (hardware thread).

It would be useful (actually essential) to have a description of why
anyone cares about this.  A good and detailed description, please.

> The tick_do_timer_cpu is chosen to run the shepherd workers.
> So there must be at least one cpu that will keep running vmstat
> updates.
> 
> ...
>
> --- linux.orig/mm/vmstat.c	2013-09-09 13:58:25.526562233 -0500
> +++ linux/mm/vmstat.c	2013-09-09 16:09:14.266402841 -0500
> @@ -14,6 +14,7 @@
>  #include <linux/module.h>
>  #include <linux/slab.h>
>  #include <linux/cpu.h>
> +#include <linux/cpumask.h>
>  #include <linux/vmstat.h>
>  #include <linux/sched.h>
>  #include <linux/math64.h>
> @@ -414,13 +415,18 @@ void dec_zone_page_state(struct page *pa
>  EXPORT_SYMBOL(dec_zone_page_state);
>  #endif
> 
> -static inline void fold_diff(int *diff)
> +
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
> 
>  /*
> @@ -437,11 +443,12 @@ static inline void fold_diff(int *diff)
>   * with the global counters. These could cause remote node cache line
>   * bouncing and will have to be only done when necessary.

Document the newly-added return value?  Especially as it's a scalar
which is used as a boolean when it isn't just ignored.

>   */
> -static void refresh_cpu_vm_stats(void)
> +static int refresh_cpu_vm_stats(void)
>  {
>  	struct zone *zone;
>  	int i;
>  	int global_diff[NR_VM_ZONE_STAT_ITEMS] = { 0, };
> +	int changes = 0;
> 
>  	for_each_populated_zone(zone) {
>  		struct per_cpu_pageset __percpu *p = zone->pageset;
> @@ -485,11 +492,14 @@ static void refresh_cpu_vm_stats(void)
>  		if (__this_cpu_dec_return(p->expire))
>  			continue;
> 
> -		if (__this_cpu_read(p->pcp.count))
> +		if (__this_cpu_read(p->pcp.count)) {
>  			drain_zone_pages(zone, __this_cpu_ptr(&p->pcp));
> +			changes++;
> +		}
>  #endif
>  	}
> -	fold_diff(global_diff);
> +	changes += fold_diff(global_diff);
> +	return changes;
>  }
> 
>  /*
> @@ -1203,12 +1213,15 @@ static const struct file_operations proc
>  #ifdef CONFIG_SMP
>  static DEFINE_PER_CPU(struct delayed_work, vmstat_work);
>  int sysctl_stat_interval __read_mostly = HZ;
> +static struct cpumask *monitored_cpus;
> 
>  static void vmstat_update(struct work_struct *w)
>  {
> -	refresh_cpu_vm_stats();
> -	schedule_delayed_work(this_cpu_ptr(&vmstat_work),
> -		round_jiffies_relative(sysctl_stat_interval));
> +	if (refresh_cpu_vm_stats())
> +		schedule_delayed_work(this_cpu_ptr(&vmstat_work),
> +			round_jiffies_relative(sysctl_stat_interval));
> +	else
> +		cpumask_set_cpu(smp_processor_id(), monitored_cpus);
>  }
> 
>  static void start_cpu_timer(int cpu)
> @@ -1216,7 +1229,63 @@ static void start_cpu_timer(int cpu)
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
> +static int need_update(int cpu)
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
> +		if (memchr_inv(p->vm_stat_diff, 0, NR_VM_ZONE_STAT_ITEMS))
> +			return 1;
> +	}
> +	return 0;
> +}
> +
> +static struct delayed_work shepherd_work;
> +extern int tick_do_timer_cpu;

This should be in a header file so we can keep definition and users in
sync.

> +static void vmstat_shepherd(struct work_struct *w)
> +{
> +	int cpu;
> +
> +	refresh_cpu_vm_stats();
> +	for_each_cpu(cpu, monitored_cpus)
> +		if (need_update(cpu)) {
> +			cpumask_clear_cpu(cpu, monitored_cpus);
> +			start_cpu_timer(cpu);
> +		}
> +
> +	schedule_delayed_work_on(tick_do_timer_cpu,
> +		&shepherd_work,
> +		__round_jiffies_relative(sysctl_stat_interval,
> +			tick_do_timer_cpu));
> +}

Some documentation would be nice.  The unobvious things.  ie: design
concepts.

> +static void start_shepherd_timer(void)

Should be __init

> +{
> +	INIT_DEFERRABLE_WORK(&shepherd_work, vmstat_shepherd);

It should be possible to do this at compile time.  Might need addition
of core infrastructure.

> +	monitored_cpus = kmalloc(BITS_TO_LONGS(nr_cpu_ids) * sizeof(long),
> +			__GFP_NOFAIL);

Please don't add new uses of __GFP_NOFAIL.

Using __GFP_NOFAIL without __GFP_WAIT, __GFP_FS etc is irrational and
I'm not sure what the page allocator will do.  It might just go into a
non-reclaiming tight loop, as that's precisely what this usage asked it
to do.

Let's just use GFP_KERNEL and handle any failure (which shouldn't
happen at boot time anyway).

> +	cpumask_copy(monitored_cpus, cpu_online_mask);
> +	cpumask_clear_cpu(tick_do_timer_cpu, monitored_cpus);

What on earth are we using tick_do_timer_cpu for anyway? 
tick_do_timer_cpu is cheerfully undocumented, as is this code's use of
it.

> ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
