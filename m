Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 2D22E6B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 13:14:49 -0400 (EDT)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 28 Jun 2013 11:14:48 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id E8F3B3E40060
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 11:14:22 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5SHEXwX389192
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 11:14:34 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5SHEWhR015565
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 11:14:32 -0600
Date: Fri, 28 Jun 2013 22:44:27 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 5/8] sched: Favour moving tasks towards the preferred node
Message-ID: <20130628171427.GO8362@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20130628090447.GD28407@twins.programming.kicks-ass.net>
 <20130628100723.GC8362@linux.vnet.ibm.com>
 <20130628135114.GY1875@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20130628135114.GY1875@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> > Yes, I understand that numa should have more priority over cache.
> > But the schedstats will not be updated about whether the task was hot or
> > cold.
> > 
> > So lets say the task was cache hot but numa wants it to move, then we
> > should certainly move it but we should update the schedstats to mention that we
> > moved a cache hot task.
> > 
> > Something akin to this.
> > 
> > 	tsk_cache_hot = task_hot(p, env->src_rq->clock_task, env->sd);
> > 	if (tsk_cache_hot) {
> > 		if (migrate_improves_locality(p, env) || 
> > 		 	(env->sd->nr_balance_failed > env->sd->cache_nice_tries)) {
> > #ifdef CONFIG_SCHEDSTATS
> > 			schedstat_inc(env->sd, lb_hot_gained[env->idle]);
> > 			schedstat_inc(p, se.statistics.nr_forced_migrations);
> > #endif
> > 			return 1;
> > 		}
> > 		schedstat_inc(p, se.statistics.nr_failed_migrations_hot);
> > 		return 0;
> > 	}
> > 	return 1;
> > 
> 
> Thanks. Is this acceptable?
> 
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index b3848e0..c3a153e 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -4088,8 +4088,13 @@ int can_migrate_task(struct task_struct *p, struct lb_env *env)
>  	 * 3) too many balance attempts have failed.
>  	 */
> 
> -	if (migrate_improves_locality(p, env))
> +	if (migrate_improves_locality(p, env)) {
> +#ifdef CONFIG_SCHEDSTATS
> +		schedstat_inc(env->sd, lb_hot_gained[env->idle]);
> +		schedstat_inc(p, se.statistics.nr_forced_migrations);
> +#endif
>  		return 1;
> +	}
> 

In this case, we account even cache cold threads as _cache hot_ in
schedstats.

We need the task_hot() call to determine if task is cache hot or not.
So the migrate_improves_locality(), I think should be called within the
tsk_cache_hot check.

Do you have issues with the above snippet that I posted earlier?

>  	tsk_cache_hot = task_hot(p, env->src_rq->clock_task, env->sd);
>  	if (!tsk_cache_hot)
> 
> -- 
> Mel Gorman
> SUSE Labs
> 

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
