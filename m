Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 4E7506B0044
	for <linux-mm@kvack.org>; Fri,  4 May 2012 00:52:57 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 4 May 2012 04:33:48 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q444itlI12910618
	for <linux-mm@kvack.org>; Fri, 4 May 2012 14:44:55 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q444plpc006771
	for <linux-mm@kvack.org>; Fri, 4 May 2012 14:51:48 +1000
Message-ID: <4FA36045.9080504@linux.vnet.ibm.com>
Date: Fri, 04 May 2012 10:21:17 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v1 3/6] workqueue: introduce schedule_on_each_cpu_cond
References: <1336056962-10465-1-git-send-email-gilad@benyossef.com> <1336056962-10465-4-git-send-email-gilad@benyossef.com>
In-Reply-To: <1336056962-10465-4-git-send-email-gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Mike Frysinger <vapier@gentoo.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org

On 05/03/2012 08:25 PM, Gilad Ben-Yossef wrote:

> Introduce the schedule_on_each_cpu_cond() function that schedules
> a work item on each online CPU for which the supplied condition
> function returns true.
> 
> This function should be used instead of schedule_on_each_cpu()
> when only some of the CPUs have actual work to do and a predicate
> function can tell if a certain CPU does or does not have work to do,
> thus saving unneeded wakeups and schedules.
> 
> Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
> ---


> diff --git a/kernel/workqueue.c b/kernel/workqueue.c
> index 1c9782b..3322d30 100644
> --- a/kernel/workqueue.c
> +++ b/kernel/workqueue.c
> @@ -2828,6 +2828,43 @@ int schedule_on_each_cpu_mask(work_func_t func, const struct cpumask *mask)
>  }
> 
>  /**
> + * schedule_on_each_cpu_cond - execute a function synchronously on each
> + * online CPU for which the supplied condition function returns true
> + * @func: the function to run on the selected CPUs
> + * @cond_func: the function to call to select the CPUs
> + *
> + * schedule_on_each_cpu_cond() executes @func on each online CPU for
> + * @cond_func returns true using the system workqueue and blocks until

    ^^^
(for) which

Regards,
Srivatsa S. Bhat

> + * all CPUs have completed.
> + * schedule_on_each_cpu_cond() is very slow.
> + *
> + * RETURNS:
> + * 0 on success, -errno on failure.
> + */
> +int schedule_on_each_cpu_cond(work_func_t func, bool (*cond_func)(int cpu))
> +{
> +	int cpu, ret;
> +	cpumask_var_t mask;
> +
> +	if (unlikely(!zalloc_cpumask_var(&mask, GFP_KERNEL)))
> +		return -ENOMEM;
> +
> +	get_online_cpus();
> +
> +	for_each_online_cpu(cpu)
> +		if (cond_func(cpu))
> +			cpumask_set_cpu(cpu, mask);
> +
> +	ret = schedule_on_each_cpu_mask(func, mask);
> +
> +	put_online_cpus();
> +
> +	free_cpumask_var(mask);
> +
> +	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
