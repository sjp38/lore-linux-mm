Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id D96046B0037
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 06:08:02 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 28 Jun 2013 06:08:01 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id DF8D26E803A
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 06:07:54 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5SA7TTR278008
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 06:07:29 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5SA7S6G021679
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 07:07:28 -0300
Date: Fri, 28 Jun 2013 15:37:23 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 5/8] sched: Favour moving tasks towards the preferred node
Message-ID: <20130628100723.GC8362@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20130628090447.GD28407@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> > > +
> > > +
> > >  /*
> > >   * can_migrate_task - may task p from runqueue rq be migrated to this_cpu?
> > >   */
> > > @@ -3945,10 +3977,14 @@ int can_migrate_task(struct task_struct *p, struct lb_env *env)
> > >  
> > >  	/*
> > >  	 * Aggressive migration if:
> > > -	 * 1) task is cache cold, or
> > > -	 * 2) too many balance attempts have failed.
> > > +	 * 1) destination numa is preferred
> > > +	 * 2) task is cache cold, or
> > > +	 * 3) too many balance attempts have failed.
> > >  	 */
> > >  
> > > +	if (migrate_improves_locality(p, env))
> > > +		return 1;
> > 
> > Shouldnt this be under tsk_cache_hot check?
> > 
> > If the task is cache hot, then we would have to update the corresponding  schedstat
> > metrics.
> 
> No; you want migrate_degrades_locality() to be like task_hot(). You want
> to _always_ migrate tasks towards better locality irrespective of local
> cache hotness.
> 

Yes, I understand that numa should have more priority over cache.
But the schedstats will not be updated about whether the task was hot or
cold.

So lets say the task was cache hot but numa wants it to move, then we
should certainly move it but we should update the schedstats to mention that we
moved a cache hot task.

Something akin to this.

	tsk_cache_hot = task_hot(p, env->src_rq->clock_task, env->sd);
	if (tsk_cache_hot) {
		if (migrate_improves_locality(p, env) || 
		 	(env->sd->nr_balance_failed > env->sd->cache_nice_tries)) {
#ifdef CONFIG_SCHEDSTATS
			schedstat_inc(env->sd, lb_hot_gained[env->idle]);
			schedstat_inc(p, se.statistics.nr_forced_migrations);
#endif
			return 1;
		}
		schedstat_inc(p, se.statistics.nr_failed_migrations_hot);
		return 0;
	}
	return 1;

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
