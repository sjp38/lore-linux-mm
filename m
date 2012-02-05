Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id B91F66B002C
	for <linux-mm@kvack.org>; Sun,  5 Feb 2012 10:36:50 -0500 (EST)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Sun, 5 Feb 2012 21:06:47 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q15FaiF14186212
	for <linux-mm@kvack.org>; Sun, 5 Feb 2012 21:06:44 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q15FahK9020617
	for <linux-mm@kvack.org>; Mon, 6 Feb 2012 02:36:44 +1100
Message-ID: <4F2EA206.3000707@linux.vnet.ibm.com>
Date: Sun, 05 Feb 2012 21:06:38 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 4/8] smp: add func to IPI cpus based on parameter func
References: <1328448800-15794-1-git-send-email-gilad@benyossef.com> <1328449722-15959-3-git-send-email-gilad@benyossef.com>
In-Reply-To: <1328449722-15959-3-git-send-email-gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Christoph Lameter <cl@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Milton Miller <miltonm@bga.com>

On 02/05/2012 07:18 PM, Gilad Ben-Yossef wrote:

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
> Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
...
> diff --git a/include/linux/smp.h b/include/linux/smp.h
> index d0adb78..da4d034 100644
> --- a/include/linux/smp.h
> +++ b/include/linux/smp.h
> @@ -109,6 +109,15 @@ void on_each_cpu_mask(const struct cpumask *mask, smp_call_func_t func,
>  		void *info, bool wait);
> 
>  /*
> + * Call a function on each processor for which the supplied function
> + * cond_func returns a positive value. This may include the local
> + * processor.
> + */
> +void on_each_cpu_cond(bool (*cond_func)(int cpu, void *info),
> +		smp_call_func_t func, void *info, bool wait,
> +		gfp_t gfp_flags);
> +
> +/*
>   * Mark the boot cpu "online" so that it can call console drivers in
>   * printk() and can access its per-cpu storage.
>   */
> @@ -153,6 +162,21 @@ static inline int up_smp_call_function(smp_call_func_t func, void *info)
>  			local_irq_enable();		\
>  		}					\
>  	} while (0)
> +/*
> + * Preemption is disabled here to make sure the
> + * cond_func is called under the same condtions in UP
> + * and SMP.
> + */
> +#define on_each_cpu_cond(cond_func, func, info, wait, gfp_flags) \
> +	do {						\
> +		preempt_disable();			\
> +		if (cond_func(0, info)) {		\
> +			local_irq_disable();		\
> +			(func)(info);			\
> +			local_irq_enable();		\
> +		}					\
> +		preempt_enable();			\
> +	} while (0)
> 
>  static inline void smp_send_reschedule(int cpu) { }
>  #define num_booting_cpus()			1
> diff --git a/kernel/smp.c b/kernel/smp.c
> index a081e6c..28cbcc5 100644
> --- a/kernel/smp.c
> +++ b/kernel/smp.c
> @@ -730,3 +730,63 @@ void on_each_cpu_mask(const struct cpumask *mask, smp_call_func_t func,
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
> + * @gfp_flags:	GFP flags to use when allocating the cpumask
> + *		used internally by the function.
> + *
> + * The function might sleep if the GFP flags indicates a non
> + * atomic allocation is allowed.
> + *
> + * Preemption is disabled to protect against a hotplug event.


Well, disabling preemption protects us only against CPU offline right?
(because we use the stop_machine thing during cpu offline).

What about CPU online?

Just to cross-check my understanding of the code with the existing
documentation on CPU hotplug, I looked up Documentation/cpu-hotplug.txt
and this is what I found:

"If you merely need to avoid cpus going away, you could also use 
preempt_disable() and preempt_enable() for those sections....
...The preempt_disable() will work as long as stop_machine_run() is used
to take a cpu down."

So even this only talks about using preempt_disable() to prevent CPU offline,
not CPU online. Or, am I missing something?

> + *
> + * You must not call this function with disabled interrupts or
> + * from a hardware interrupt handler or from a bottom half handler.
> + */
> +void on_each_cpu_cond(bool (*cond_func)(int cpu, void *info),
> +			smp_call_func_t func, void *info, bool wait,
> +			gfp_t gfp_flags)
> +{
> +	cpumask_var_t cpus;
> +	int cpu, ret;
> +
> +	might_sleep_if(gfp_flags & __GFP_WAIT);
> +
> +	if (likely(zalloc_cpumask_var(&cpus, (gfp_flags|__GFP_NOWARN)))) {
> +		preempt_disable();
> +		for_each_online_cpu(cpu)
> +			if (cond_func(cpu, info))
> +				cpumask_set_cpu(cpu, cpus);


IOW, what prevents a new CPU from becoming online at this point?

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



Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
