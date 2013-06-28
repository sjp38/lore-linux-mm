Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 028A96B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 09:45:40 -0400 (EDT)
Date: Fri, 28 Jun 2013 14:45:35 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 5/8] sched: Favour moving tasks towards the preferred node
Message-ID: <20130628134535.GX1875@suse.de>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
 <1372257487-9749-6-git-send-email-mgorman@suse.de>
 <20130627161127.GZ28407@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130627161127.GZ28407@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 27, 2013 at 06:11:27PM +0200, Peter Zijlstra wrote:
> On Wed, Jun 26, 2013 at 03:38:04PM +0100, Mel Gorman wrote:
> > +/* Returns true if the destination node has incurred more faults */
> > +static bool migrate_improves_locality(struct task_struct *p, struct lb_env *env)
> > +{
> > +	int src_nid, dst_nid;
> > +
> > +	if (!p->numa_faults || !(env->sd->flags & SD_NUMA))
> > +		return false;
> > +
> > +	src_nid = cpu_to_node(env->src_cpu);
> > +	dst_nid = cpu_to_node(env->dst_cpu);
> > +
> > +	if (src_nid == dst_nid)
> > +		return false;
> > +
> > +	if (p->numa_migrate_seq < sysctl_numa_balancing_settle_count &&
> > +	    p->numa_preferred_nid == dst_nid)
> > +		return true;
> > +
> > +	return false;
> > +}
> 
> Also, until I just actually _read_ that function; I assumed it would
> compare p->numa_faults[src_nid] and p->numa_faults[dst_nid]. Because
> even when the dst_nid isn't the preferred nid; it might still have more
> pages than where we currently are.
> 

I tested something like this and also tested it when only taking shared
accesses into account but it performed badly in some cases.  I've included
the last patch I tested below for reference but dropped it until I figured
out why it performed badly. I guessed it was due to increased bouncing
due to shared faults but didn't prove it.

> Idem with the proposed migrate_degrades_locality().
> 
> Something like so I suppose
> 
> ---
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -3969,6 +3969,7 @@ task_hot(struct task_struct *p, u64 now,
>  	return delta < (s64)sysctl_sched_migration_cost;
>  }
>  
> +#ifdef CONFIG_NUMA_BALANCING
>  /* Returns true if the destination node has incurred more faults */
>  static bool migrate_improves_locality(struct task_struct *p, struct lb_env *env)
>  {
> @@ -3983,13 +3984,50 @@ static bool migrate_improves_locality(st
>  	if (src_nid == dst_nid)
>  		return false;
>  
> -	if (p->numa_migrate_seq < sysctl_numa_balancing_settle_count &&
> -	    p->numa_preferred_nid == dst_nid)
> +	if (p->numa_migrate_seq >= sysctl_numa_balancing_settle_count)
> +		return false;
> +
> +	if (p->numa_preferred_nid == dst_nid)
> +		return true;
> +
> +	if (p->numa_faults[src_nid] < p->numa_faults[dst_nid])
> +		return true;
> +
> +	return false;
> +}
> +

I tested something like this.

> +static vool migrate_degrades_locality(struct task_struct *p, struct lb_env *env)
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
> +	if (p->numa_faults[src_nid] > p->numa_faults[dst_nid])
>  		return true;
>  
>  	return false;
>  }

But I had not tried this and it makes sense. I'll test it out and include
it in the next revision if it looks good. Unless you object I'll add
your signed-off because the version of the patch I'm about to test looks
almost identical to this.

>  
> +#else
> +
> +static inline bool migrate_improves_locality(struct task_struct *p, struct lb_env *env)
> +{
> +	return false;
> +}
> +
> +static inline bool migrate_degrades_locality(struct task_struct *p, struct lb_env *env)
> +{
> +	return false;
> +}
> +
> +#endif /* CONFIG_NUMA_BALANCING */
>  
>  /*
>   * can_migrate_task - may task p from runqueue rq be migrated to this_cpu?
> @@ -4055,8 +4093,10 @@ int can_migrate_task(struct task_struct
>  		return 1;
>  
>  	tsk_cache_hot = task_hot(p, rq_clock_task(env->src_rq), env->sd);
> +	if (!tsk_cache_hot)
> +		tsk_cache_hot = migrate_degrades_locality(p, env);
>  	if (!tsk_cache_hot ||
> -		env->sd->nr_balance_failed > env->sd->cache_nice_tries) {
> +	    env->sd->nr_balance_failed > env->sd->cache_nice_tries) {
>  
>  		if (tsk_cache_hot) {
>  			schedstat_inc(env->sd, lb_hot_gained[env->idle]);
> 

This is the last patch similar to this idea I tested.

---8<---
sched: Favour moving tasks towards nodes that incurred more faults

Signed-off-by: Mel Gorman <mgorman@suse.de>

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index e9bbb70..3379ca4 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -3980,9 +3980,18 @@ static bool migrate_improves_locality(struct task_struct *p, struct lb_env *env)
 	if (src_nid == dst_nid)
 		return false;
 
-	if (p->numa_migrate_seq < sysctl_numa_balancing_settle_count &&
-	    p->numa_preferred_nid == dst_nid)
-		return true;
+	if (p->numa_migrate_seq < sysctl_numa_balancing_settle_count) {
+		if (p->numa_preferred_nid == dst_nid)
+			return true;
+
+		/*
+		 * Move towards node if there were a higher number of shared
+		 * NUMA hinting faults
+		 */
+		if (p->numa_faults[task_faults_idx(dst_nid, 0)] >
+		    p->numa_faults[task_faults_idx(src_nid, 0)])
+			return true;
+	}
 
 	return false;
 }


-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
