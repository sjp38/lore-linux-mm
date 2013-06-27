Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id B83196B0032
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 10:52:54 -0400 (EDT)
Date: Thu, 27 Jun 2013 16:52:45 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 5/8] sched: Favour moving tasks towards the preferred node
Message-ID: <20130627145245.GS28407@twins.programming.kicks-ass.net>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
 <1372257487-9749-6-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1372257487-9749-6-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jun 26, 2013 at 03:38:04PM +0100, Mel Gorman wrote:
> @@ -3897,6 +3907,28 @@ task_hot(struct task_struct *p, u64 now, struct sched_domain *sd)
>  	return delta < (s64)sysctl_sched_migration_cost;
>  }
>  
> +/* Returns true if the destination node has incurred more faults */
> +static bool migrate_improves_locality(struct task_struct *p, struct lb_env *env)
> +{
> +	int src_nid, dst_nid;
> +
> +	if (!p->numa_faults || !(env->sd->flags & SD_NUMA))
> +		return false;
> +
> +	src_nid = cpu_to_node(env->src_cpu);
> +	dst_nid = cpu_to_node(env->dst_cpu);
> +
> +	if (src_nid == dst_nid)
> +		return false;
> +
> +	if (p->numa_migrate_seq < sysctl_numa_balancing_settle_count &&
> +	    p->numa_preferred_nid == dst_nid)
> +		return true;
> +
> +	return false;
> +}
> +
> +
>  /*
>   * can_migrate_task - may task p from runqueue rq be migrated to this_cpu?
>   */
> @@ -3945,10 +3977,14 @@ int can_migrate_task(struct task_struct *p, struct lb_env *env)
>  
>  	/*
>  	 * Aggressive migration if:
> -	 * 1) task is cache cold, or
> -	 * 2) too many balance attempts have failed.
> +	 * 1) destination numa is preferred
> +	 * 2) task is cache cold, or
> +	 * 3) too many balance attempts have failed.
>  	 */
>  
> +	if (migrate_improves_locality(p, env))
> +		return 1;
> +
>  	tsk_cache_hot = task_hot(p, env->src_rq->clock_task, env->sd);
>  	if (!tsk_cache_hot ||
>  		env->sd->nr_balance_failed > env->sd->cache_nice_tries) {

Should we not also do the reverse; make it harder to worsen locality?

Similar to the task_hot() thing; do not allow to migrate a task on low
nr_balance_failed when it makes the locality worse.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
