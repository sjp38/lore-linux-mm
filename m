Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 658BF6B0036
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 13:45:26 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 28 Jun 2013 13:45:25 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 5C5066E8044
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 13:45:16 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5SHioDl313864
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 13:44:50 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5SHinOm021995
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 14:44:50 -0300
Date: Fri, 28 Jun 2013 23:14:45 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 5/8] sched: Favour moving tasks towards the preferred node
Message-ID: <20130628174445.GP8362@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20130628090447.GD28407@twins.programming.kicks-ass.net>
 <20130628100723.GC8362@linux.vnet.ibm.com>
 <20130628135114.GY1875@suse.de>
 <20130628171427.GO8362@linux.vnet.ibm.com>
 <20130628173407.GC1875@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20130628173407.GC1875@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> > > 
> > > -	if (migrate_improves_locality(p, env))
> > > +	if (migrate_improves_locality(p, env)) {
> > > +#ifdef CONFIG_SCHEDSTATS
> > > +		schedstat_inc(env->sd, lb_hot_gained[env->idle]);
> > > +		schedstat_inc(p, se.statistics.nr_forced_migrations);
> > > +#endif
> > >  		return 1;
> > > +	}
> > > 
> > 
> > In this case, we account even cache cold threads as _cache hot_ in
> > schedstats.
> > 
> > We need the task_hot() call to determine if task is cache hot or not.
> > So the migrate_improves_locality(), I think should be called within the
> > tsk_cache_hot check.
> > 
> > Do you have issues with the above snippet that I posted earlier?
> > 
> 
> The migrate_improves_locality call had already happened so it cannot be
> true after the tsk_cache_hot check is made so I was confused. If the call is
> moved within task cache hot then it changes the intent of the patch because

Yes,  I was suggesting moving it inside.

> cache hotness then trumps memory locality which is not intended. Memory
> locality is expected to trump cache hotness.
> 

But whether the memory locality trumps or the cache hotness, the result
would still be the same but a little concise code.

> How about this?
> 
>         tsk_cache_hot = task_hot(p, env->src_rq->clock_task, env->sd);
> 
>         if (migrate_improves_locality(p, env)) {
> #ifdef CONFIG_SCHEDSTATS
>                 if (tsk_cache_hot) {
>                         schedstat_inc(env->sd, lb_hot_gained[env->idle]);
>                         schedstat_inc(p, se.statistics.nr_forced_migrations);
>                 }
> #endif
>                 return 1;
>         }
> 
>         if (!tsk_cache_hot ||
>                 env->sd->nr_balance_failed > env->sd->cache_nice_tries) {
> #ifdef CONFIG_SCHEDSTATS
>                 if (tsk_cache_hot) {
>                         schedstat_inc(env->sd, lb_hot_gained[env->idle]);
>                         schedstat_inc(p, se.statistics.nr_forced_migrations);
>                 }
> #endif
>                 return 1;
>         }

Yes, this looks fine to me.
> 

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
