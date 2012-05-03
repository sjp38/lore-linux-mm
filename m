Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id C95446B0083
	for <linux-mm@kvack.org>; Thu,  3 May 2012 11:39:47 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so3326833pbb.14
        for <linux-mm@kvack.org>; Thu, 03 May 2012 08:39:46 -0700 (PDT)
Date: Thu, 3 May 2012 08:39:41 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v1 3/6] workqueue: introduce schedule_on_each_cpu_cond
Message-ID: <20120503153941.GA5528@google.com>
References: <1336056962-10465-1-git-send-email-gilad@benyossef.com>
 <1336056962-10465-4-git-send-email-gilad@benyossef.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1336056962-10465-4-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, John Stultz <johnstul@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Mike Frysinger <vapier@gentoo.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org

Hello,

On Thu, May 03, 2012 at 05:55:59PM +0300, Gilad Ben-Yossef wrote:
> Introduce the schedule_on_each_cpu_cond() function that schedules
> a work item on each online CPU for which the supplied condition
> function returns true.
> 
> This function should be used instead of schedule_on_each_cpu()
> when only some of the CPUs have actual work to do and a predicate
> function can tell if a certain CPU does or does not have work to do,
> thus saving unneeded wakeups and schedules.
>
>  /**
> + * schedule_on_each_cpu_cond - execute a function synchronously on each
> + * online CPU for which the supplied condition function returns true
> + * @func: the function to run on the selected CPUs
> + * @cond_func: the function to call to select the CPUs
> + *
> + * schedule_on_each_cpu_cond() executes @func on each online CPU for
> + * @cond_func returns true using the system workqueue and blocks until
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
> +}

I'm usually not a big fan of callback based interface.  They tend to
be quite clunky to use.  e.g. in this case, wouldn't it be better to
have helper functions which allocate cpumask and disables cpu hotplug
and undo that afterwards?  That is, if such convenience helpers are
necessary at all.  Also, callback which doesn't have a private data
argument tends to be PITA.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
