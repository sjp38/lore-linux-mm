Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 0AC946B0069
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 02:05:20 -0500 (EST)
From: Milton Miller <miltonm@bga.com>
Subject: Re: [PATCH v6 4/8] smp: add func to IPI cpus based on parameter func
In-Reply-To: <1326040026-7285-5-git-send-email-gilad@benyossef.com>
References: <1326040026-7285-5-git-send-email-gilad@benyossef.com>
Date: Wed, 11 Jan 2012 01:04:12 -0600
Message-ID: <1326265452_1661@mail4.comsite.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org
Cc: Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Sasha Levin <levinsasha928@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.org>, Kosaki Motohiro <kosaki.motohiro@gmail.com>


On Sun, 8 Jan 2012 about 11:28:08 EST, Gilad Ben-Yossef wrote:
> Add the on_each_cpu_cond() function that wraps on_each_cpu_mask()
> and calculates the cpumask of cpus to IPI by calling a function supplied
> as a parameter in order to determine whether to IPI each specific cpu.
> 
> The function works around allocation failure of cpumask variable in
> CONFIG_CPUMASK_OFFSTACK=y by itereating over cpus sending an IPI a
> time via smp_call_function_single().
> 
> The function is useful since it allows to seperate the specific
> code that decided in each case whether to IPI a specific cpu for
> a specific request from the common boilerplate code of handling
> creating the mask, handling failures etc.
> 
..
> ---
>  include/linux/smp.h |   16 ++++++++++++++++
>  kernel/smp.c        |   38 ++++++++++++++++++++++++++++++++++++++
>  2 files changed, 54 insertions(+), 0 deletions(-)
> diff --git a/include/linux/smp.h b/include/linux/smp.h
> index a3a14d9..a37f388 100644
> --- a/include/linux/smp.h
> +++ b/include/linux/smp.h
> @@ -109,6 +109,14 @@ void on_each_cpu_mask(const struct cpumask *mask, void (*func)(void *),
>  		void *info, bool wait);
>  
>  /*
> + * Call a function on each processor for which the supplied function
> + * cond_func returns a positive value. This may include the local
> + * processor.
> + */
> +void on_each_cpu_cond(int (*cond_func) (int cpu, void *info),
> +		void (*func)(void *), void *info, bool wait);
> +

func should be smp_call_func_t

The kernel has adopted bool for boolean return values, and cond_func
certianly qualifes.  Therefore cond_func should return bool not int,
and the comment "returns true".

Of course the other patches will need ther condition funcitons
adjusted to return bool.

There should not be a space between cond_func) and it argument list.

> +/*
>   * Mark the boot cpu "online" so that it can call console drivers in
>   * printk() and can access its per-cpu storage.
>   */
> @@ -153,6 +161,14 @@ static inline int up_smp_call_function(smp_call_func_t func, void *info)
>  			local_irq_enable();		\
>  		}					\
>  	} while (0)
> +#define on_each_cpu_cond(cond_func, func, info, wait) \
> +	do {						\
> +		if (cond_func(0, info)) {		\
> +			local_irq_disable();		\
> +			(func)(info);			\
> +			local_irq_enable();		\
> +		}					\
> +	} while (0)
>  
>  static inline void smp_send_reschedule(int cpu) { }
>  #define num_booting_cpus()			1
> diff --git a/kernel/smp.c b/kernel/smp.c
> index 7c0cbd7..bd8f4ad 100644
> --- a/kernel/smp.c
> +++ b/kernel/smp.c
> @@ -721,3 +721,41 @@ void on_each_cpu_mask(const struct cpumask *mask, void (*func)(void *),
>  	put_cpu();
>  }
>  EXPORT_SYMBOL(on_each_cpu_mask);
> +
> +/*
> + * Call a function on each processor for which the supplied function
> + * cond_func returns a positive value. This may include the local

changing to bool would be returns true.

And the existing check was for nonzero not positive.

The comment should become kerneldoc for the function.

> + * processor, optionally waiting for all the required CPUs to finish.

The part after the comma should be part of the previous sentence.
The comment about the including the local processor can come later.

> + * All the limitations specified in smp_call_function_many apply.

Actually, I think we should have this function disable preemption
instead of having it disabled before being called.  This will
insure we see a consistent value of cpu_online_mask.  We could then
pass in the gfp mask to be used for the alloc, but if we do then
we would want might_sleep_if(gfp & __GFP_WAIT).  While adding gfp
might seem to be a bit premature optimization, the cost for waiting on
most cpus could be significant.  Even if wait is 0 we would only
overlap the calls to cond_func before smp_call_function_data will
wait on the previous cpu to free its percpu call_single_data.

> + */
> +void on_each_cpu_cond(int (*cond_func) (int cpu, void *info),
> +			void (*func)(void *), void *info, bool wait)
> +{
> +	cpumask_var_t cpus;
> +	int cpu;
> +
> +	if (likely(zalloc_cpumask_var(&cpus, GFP_ATOMIC))) {
> +		for_each_online_cpu(cpu)
> +			if (cond_func(cpu, info))
> +				cpumask_set_cpu(cpu, cpus);
> +		on_each_cpu_mask(cpus, func, info, wait);
> +		free_cpumask_var(cpus);
> +	} else {
> +		/*
> +		 * No free cpumask, bother. No matter, we'll
> +		 * just have to IPI them one by one.
> +		 */
> +		for_each_online_cpu(cpu)
> +			if (cond_func(cpu, info))
> +				/*
> +				 * This call can fail if we ask it to IPI an
> +				 * offline CPU, but this can be a valid
> +				 * sceanrio here. Also, on_each_cpu_mask
> +				 * ignores offlines CPUs. So, we ignore
> +				 * the return value here.
> +				 */
> +				smp_call_function_single(cpu, func, info, wait);
> +	}
> +}
> +EXPORT_SYMBOL(on_each_cpu_cond);

One of the requirements of smp_call_function_many is that preemption is
disabled so as not to race with cpu_online_set.  While on_each_cpu_mask
will disable preemption that in the first case, it will do so after
we have iterated over the online mask.  I suggest it should disable
preemption after allocating the cpumask var.  Then we can remove
part about it being a valid scenario and instead say it can't happen,
and ignore it or WARN_ON_ONCE if it triggers for some strange reason
added in the future.

If we change the preemption rules then we should also do so in the up
case to have cond_func be called in a consistent environment.

milton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
