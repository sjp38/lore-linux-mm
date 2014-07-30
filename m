Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 61EDC6B0036
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 22:56:20 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id y10so663938pdj.7
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 19:56:20 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id nx7si781516pab.167.2014.07.29.19.56.17
        for <linux-mm@kvack.org>;
        Tue, 29 Jul 2014 19:56:19 -0700 (PDT)
Message-ID: <53D85F20.7020206@cn.fujitsu.com>
Date: Wed, 30 Jul 2014 10:57:36 +0800
From: Lai Jiangshan <laijs@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: vmstat: On demand vmstat workers V8
References: <alpine.DEB.2.11.1407100903130.12483@gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1407100903130.12483@gentwo.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: akpm@linux-foundation.org, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org

If I understand the semantics of the cpu_stat_off correctly, please read.

cpu_stat_off = a set of such CPU: the cpu is online && vmstat_work is off
I consider some code forget to guarantee each cpu in cpu_stat_off is online.

Thanks,
Lai

On 07/10/2014 10:04 PM, Christoph Lameter wrote:

> +
> +/*
> + * Shepherd worker thread that checks the
> + * differentials of processors that have their worker
> + * threads for vm statistics updates disabled because of
> + * inactivity.
> + */
> +static void vmstat_shepherd(struct work_struct *w);
> +
> +static DECLARE_DELAYED_WORK(shepherd, vmstat_shepherd);
> +
> +static void vmstat_shepherd(struct work_struct *w)
> +{
> +	int cpu;
> +
> +	/* Check processors whose vmstat worker threads have been disabled */

I think the bug is here, it re-queues the per_cpu(vmstat_work, cpu) which is offline
(after vmstat_cpuup_callback(CPU_DOWN_PREPARE).  And cpu_stat_off is accessed without
proper lock.

I suggest to use get_cpu_online() or a new cpu_stat_off_mutex to protect it.


	get_cpu_online(); /* mutex_lock(&cpu_stat_off_mutex); */
	for_each_cpu(cpu, cpu_stat_off)
		if (need_update(cpu) &&
			cpumask_test_and_clear_cpu(cpu, cpu_stat_off))

			schedule_delayed_work_on(cpu, &per_cpu(vmstat_work, cpu),
				__round_jiffies_relative(sysctl_stat_interval, cpu));
	put_cpu_online(); /* mutex_unlock(&cpu_stat_off_mutex); */



> +
> +
> +	schedule_delayed_work(&shepherd,
>  		round_jiffies_relative(sysctl_stat_interval));
> +
>  }
> 
> -static void start_cpu_timer(int cpu)
> +static void __init start_shepherd_timer(void)
>  {
> -	struct delayed_work *work = &per_cpu(vmstat_work, cpu);
> +	int cpu;
> +
> +	for_each_possible_cpu(cpu)
> +		INIT_DEFERRABLE_WORK(per_cpu_ptr(&vmstat_work, cpu),
> +			vmstat_update);
> +
> +	cpu_stat_off = kmalloc(cpumask_size(), GFP_KERNEL);
> +	cpumask_copy(cpu_stat_off, cpu_online_mask);
> 
> -	INIT_DEFERRABLE_WORK(work, vmstat_update);
> -	schedule_delayed_work_on(cpu, work, __round_jiffies_relative(HZ, cpu));
> +	schedule_delayed_work(&shepherd,
> +		round_jiffies_relative(sysctl_stat_interval));
>  }
> 
>  static void vmstat_cpu_dead(int node)
> @@ -1272,17 +1373,17 @@ static int vmstat_cpuup_callback(struct
>  	case CPU_ONLINE:
>  	case CPU_ONLINE_FROZEN:
>  		refresh_zone_stat_thresholds();
> -		start_cpu_timer(cpu);
>  		node_set_state(cpu_to_node(cpu), N_CPU);
> +		cpumask_set_cpu(cpu, cpu_stat_off);
>  		break;
>  	case CPU_DOWN_PREPARE:
>  	case CPU_DOWN_PREPARE_FROZEN:
> -		cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
> -		per_cpu(vmstat_work, cpu).work.func = NULL;
> +		if (!cpumask_test_and_set_cpu(cpu, cpu_stat_off))
> +			cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));

It is suggest that cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu)) should
be called unconditionally.  And the cpu should be cleared from cpu_stat_off.
(you set it, it is BUG according to vmstat_shepherd() and the semantics of the
cpu_stat_off).

	/* mutex_lock(&cpu_stat_off_mutex); */
		/*if you use cpu_stat_off_mutex instead of get_cpu_online() */
	cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
	cpumask_clear_cpu(cpu, cpu_stat_off);
	/* mutex_unlock(&cpu_stat_off_mutex); */

	/* don't forget to use cpu_stat_off_mutex on other place for
	   accessing to cpu_stat_off except the one in vmstat_update() which
	   is protected by cancel_delayed_work_sync() + other stuffs
	   please also update that comments and keep that VM_BUG_ON() */


>  		break;
>  	case CPU_DOWN_FAILED:
>  	case CPU_DOWN_FAILED_FROZEN:
> -		start_cpu_timer(cpu);
> +		cpumask_set_cpu(cpu, cpu_stat_off);
>  		break;
>  	case CPU_DEAD:
>  	case CPU_DEAD_FROZEN:
> @@ -1302,15 +1403,10 @@ static struct notifier_block vmstat_noti
>  static int __init setup_vmstat(void)
>  {
>  #ifdef CONFIG_SMP
> -	int cpu;
> -
>  	cpu_notifier_register_begin();
>  	__register_cpu_notifier(&vmstat_notifier);
> 
> -	for_each_online_cpu(cpu) {
> -		start_cpu_timer(cpu);
> -		node_set_state(cpu_to_node(cpu), N_CPU);
> -	}
> +	start_shepherd_timer();
>  	cpu_notifier_register_done();
>  #endif
>  #ifdef CONFIG_PROC_FS
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
