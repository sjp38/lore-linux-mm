Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 529496B004F
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 18:57:27 -0500 (EST)
Date: Fri, 27 Jan 2012 15:57:25 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [v7 4/8] smp: add func to IPI cpus based on parameter func
Message-Id: <20120127155725.86654035.akpm@linux-foundation.org>
In-Reply-To: <1327572121-13673-5-git-send-email-gilad@benyossef.com>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
	<1327572121-13673-5-git-send-email-gilad@benyossef.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Christoph Lameter <cl@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Thu, 26 Jan 2012 12:01:57 +0200
Gilad Ben-Yossef <gilad@benyossef.com> wrote:

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
> ...
>
> @@ -153,6 +162,16 @@ static inline int up_smp_call_function(smp_call_func_t func, void *info)
>  			local_irq_enable();		\
>  		}					\
>  	} while (0)
> +#define on_each_cpu_cond(cond_func, func, info, wait, gfpflags) \
> +	do {						\
> +		preempt_disable();			\
> +		if (cond_func(0, info)) {		\
> +			local_irq_disable();		\
> +			(func)(info);			\
> +			local_irq_enable();		\

Ordinarily, local_irq_enable() in such a low-level thing is dangerous,
because it can cause horrid bugs when called from local_irq_disable()d
code.

However I think we're OK here because it is a bug to call on_each_cpu()
and friends with local irqs disabled, yes?

Do we have any warnings printks if someone calls the ipi-sending
functions with local interrupts disabled?  I didn't see any, but didn't
look very hard.

If my above claims are correct then why does on_each_cpu() use
local_irq_save()?  hrm.

> +		}					\
> +		preempt_enable();			\
> +	} while (0)
>  
>  static inline void smp_send_reschedule(int cpu) { }
>  #define num_booting_cpus()			1
> diff --git a/kernel/smp.c b/kernel/smp.c
> index a081e6c..fa0912a 100644
> --- a/kernel/smp.c
> +++ b/kernel/smp.c
> @@ -730,3 +730,61 @@ void on_each_cpu_mask(const struct cpumask *mask, smp_call_func_t func,
>  	put_cpu();
>  }
>  EXPORT_SYMBOL(on_each_cpu_mask);
> +
> +/*
> + * on_each_cpu_cond(): Call a function on each processor for which
> + * the supplied function cond_func returns true, optionally waiting
> + * for all the required CPUs to finish. This may include the local
> + * processor.
> + * @cond_func:	A callback function that is passed a cpu id and
> + *		the the info parameter. The function is called
> + *		with preemption disabled. The function should
> + *		return a blooean value indicating whether to IPI
> + *		the specified CPU.
> + * @func:	The function to run on all applicable CPUs.
> + *		This must be fast and non-blocking.
> + * @info:	An arbitrary pointer to pass to both functions.
> + * @wait:	If true, wait (atomically) until function has
> + *		completed on other CPUs.
> + * @gfpflags:	GFP flags to use when allocating the cpumask
> + *		used internally by the function.
> + *
> + * The function might sleep if the GFP flags indicates a non
> + * atomic allocation is allowed.
> + *
> + * You must not call this function with disabled interrupts or
> + * from a hardware interrupt handler or from a bottom half handler.
> + */
> +void on_each_cpu_cond(bool (*cond_func)(int cpu, void *info),
> +			smp_call_func_t func, void *info, bool wait,
> +			gfp_t gfpflags)

bah.

z:/usr/src/linux-3.3-rc1> grep -r gfpflags . | wc -l
78
z:/usr/src/linux-3.3-rc1> grep -r gfp_flags . | wc -l 
548

> +{
> +	cpumask_var_t cpus;
> +	int cpu, ret;
> +
> +	might_sleep_if(gfpflags & __GFP_WAIT);

For the zalloc_cpumask_var(), it seems.  I expect there are
might_sleep() elsewhere in the memory allocation paths, but putting one
here will detect bugs even if CONFIG_CPUMASK_OFFSTACK=n.

> +	if (likely(zalloc_cpumask_var(&cpus, (gfpflags|__GFP_NOWARN)))) {
> +		preempt_disable();
> +		for_each_online_cpu(cpu)
> +			if (cond_func(cpu, info))
> +				cpumask_set_cpu(cpu, cpus);
> +		on_each_cpu_mask(cpus, func, info, wait);
> +		preempt_enable();
> +		free_cpumask_var(cpus);
> +	} else {
> +		/*
> +		 * No free cpumask, bother. No matter, we'll
> +		 * just have to IPI them one by one.
> +		 */
> +		preempt_disable();
> +		for_each_online_cpu(cpu)
> +			if (cond_func(cpu, info)) {
> +				ret = smp_call_function_single(cpu, func,
> +								info, wait);
> +				WARN_ON_ONCE(!ret);
> +			}
> +		preempt_enable();
> +	}
> +}
> +EXPORT_SYMBOL(on_each_cpu_cond);

I assume the preempt_disable()s here are to suspend CPU hotplug?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
