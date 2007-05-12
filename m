Date: Sat, 12 May 2007 22:12:54 +0400
From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: [PATCH 1/2] scalable rw_mutex
Message-ID: <20070512181254.GA331@tv-sign.ru>
References: <20070511131541.992688403@chello.nl> <20070511132321.895740140@chello.nl> <20070511093108.495feb70.akpm@linux-foundation.org> <Pine.LNX.4.64.0705111006470.32716@schroedinger.engr.sgi.com> <20070511110522.ed459635.akpm@linux-foundation.org> <p73odkpeusf.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <p73odkpeusf.fsf@bingen.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On 05/12, Andi Kleen wrote:
> 
> --- linux-2.6.21-git2-net.orig/kernel/cpu.c
> +++ linux-2.6.21-git2-net/kernel/cpu.c
> @@ -26,6 +26,10 @@ static __cpuinitdata RAW_NOTIFIER_HEAD(c
>   */
>  static int cpu_hotplug_disabled;
>  
> +/* Contains any CPUs that were ever online at some point.
> +   No guarantee they were fully initialized though */
> +cpumask_t cpu_everonline_map;
> +
>  #ifdef CONFIG_HOTPLUG_CPU
>  
>  /* Crappy recursive lock-takers in cpufreq! Complain loudly about idiots */
> @@ -212,6 +216,8 @@ static int __cpuinit _cpu_up(unsigned in
>  	if (cpu_online(cpu) || !cpu_present(cpu))
>  		return -EINVAL;
>  
> +	cpu_set(cpu, cpu_everonline_map);
> +

This also allows us to de-uglify workqueue.c a little bit, it uses
a home-grown cpu_populated_map.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
