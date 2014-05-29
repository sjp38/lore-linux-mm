Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id E15D26B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 19:55:38 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id u57so1211242wes.32
        for <linux-mm@kvack.org>; Thu, 29 May 2014 16:55:38 -0700 (PDT)
Received: from mail-we0-x236.google.com (mail-we0-x236.google.com [2a00:1450:400c:c03::236])
        by mx.google.com with ESMTPS id y16si4614969wju.93.2014.05.29.16.55.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 May 2014 16:55:37 -0700 (PDT)
Received: by mail-we0-f182.google.com with SMTP id t60so1206455wes.27
        for <linux-mm@kvack.org>; Thu, 29 May 2014 16:55:36 -0700 (PDT)
Date: Fri, 30 May 2014 01:55:33 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH] vmstat: on demand updates from differentials V7
Message-ID: <20140529235530.GA25555@localhost.localdomain>
References: <alpine.DEB.2.10.1405291453260.2899@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1405291453260.2899@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>

On Thu, May 29, 2014 at 02:56:15PM -0500, Christoph Lameter wrote:
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

Now you're open coding alloc_cpumask_var() ?

> +	cpumask_copy(cpu_stat_off, cpu_online_mask);
> 
> -	INIT_DEFERRABLE_WORK(work, vmstat_update);
> -	schedule_delayed_work_on(cpu, work, __round_jiffies_relative(HZ, cpu));
> +	schedule_delayed_work(&shepherd,
> +		round_jiffies_relative(sysctl_stat_interval));
>  }
> 
>  static void vmstat_cpu_dead(int node)
> @@ -1266,17 +1367,17 @@
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
>  		break;
>  	case CPU_DOWN_FAILED:
>  	case CPU_DOWN_FAILED_FROZEN:
> -		start_cpu_timer(cpu);
> +		cpumask_set_cpu(cpu, cpu_stat_off);
>  		break;
>  	case CPU_DEAD:
>  	case CPU_DEAD_FROZEN:
> @@ -1296,15 +1397,10 @@
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
