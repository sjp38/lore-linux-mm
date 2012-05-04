Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 958F66B0044
	for <linux-mm@kvack.org>; Fri,  4 May 2012 00:45:34 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 4 May 2012 10:15:31 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q444jTYZ3867092
	for <linux-mm@kvack.org>; Fri, 4 May 2012 10:15:30 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q44AG0Ix003725
	for <linux-mm@kvack.org>; Fri, 4 May 2012 20:16:06 +1000
Message-ID: <4FA35EC8.5090804@linux.vnet.ibm.com>
Date: Fri, 04 May 2012 10:14:56 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v1 2/6] workqueue: introduce schedule_on_each_cpu_mask
References: <1336056962-10465-1-git-send-email-gilad@benyossef.com> <1336056962-10465-3-git-send-email-gilad@benyossef.com>
In-Reply-To: <1336056962-10465-3-git-send-email-gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Mike Frysinger <vapier@gentoo.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org

On 05/03/2012 08:25 PM, Gilad Ben-Yossef wrote:

> Introduce schedule_on_each_cpu_mask function to schedule a work
> item on each online CPU which is included in the mask provided.
> 
> Then re-implement schedule_on_each_cpu on top of the new function.
> 
> This function should be prefered to schedule_on_each_cpu in
> any case where some of the CPUs, especially on a big multi-core
> system, might not have actual work to perform in order to save
> needless wakeups and schedules.
> 
> Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>


>  /**
> - * schedule_on_each_cpu - execute a function synchronously on each online CPU
> + * schedule_on_each_cpu_mask - execute a function synchronously on each
> + * online CPU which is specified in the supplied cpumask
>   * @func: the function to call
> + * @mask: the cpu mask
>   *
> - * schedule_on_each_cpu() executes @func on each online CPU using the
> - * system workqueue and blocks until all CPUs have completed.
> - * schedule_on_each_cpu() is very slow.
> + * schedule_on_each_cpu_mask() executes @func on each online CPU which
> + * is part of the @mask using the * system workqueue and blocks until

                                    ^^^
stray character?

> + * all CPUs have completed
> + * schedule_on_each_cpu_mask() is very slow.
>   *
>   * RETURNS:
>   * 0 on success, -errno on failure.
>   */
> -int schedule_on_each_cpu(work_func_t func)
> +int schedule_on_each_cpu_mask(work_func_t func, const struct cpumask *mask)
>  {
>  	int cpu;
>  	struct work_struct __percpu *works;
> 
>  	works = alloc_percpu(struct work_struct);
> -	if (!works)
> +	if (unlikely(!works))
>  		return -ENOMEM;
> 
>  	get_online_cpus();
> 
> -	for_each_online_cpu(cpu) {
> +	for_each_cpu_and(cpu, mask, cpu_online_mask) {
>  		struct work_struct *work = per_cpu_ptr(works, cpu);
> 
>  		INIT_WORK(work, func);
>  		schedule_work_on(cpu, work);
>  	}
> 
> -	for_each_online_cpu(cpu)
> +	for_each_cpu_and(cpu, mask, cpu_online_mask)
>  		flush_work(per_cpu_ptr(works, cpu));
> 


Given that cpu hotplug is not a frequent operation, I think mask will be
a subset of cpu_online_mask most of the time (also, one example is from
schedule_on_each_cpu_cond() introduced in 3/6, which is already under
get/put_online_cpus(). So can we optimize something (the 'and' operations
perhaps) based on that?

May be something by using:
	if (likely(cpumask_subset(mask, cpu_online_mask))

>  	put_online_cpus();

>  	free_percpu(works);
> +
>  	return 0;
>  }
> 


Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
