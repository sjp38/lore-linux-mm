Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 646FF6B0031
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 09:02:16 -0400 (EDT)
Date: Fri, 28 Jun 2013 14:01:59 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 5/8] sched: Favour moving tasks towards the preferred node
Message-ID: <20130628130159.GW1875@suse.de>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
 <1372257487-9749-6-git-send-email-mgorman@suse.de>
 <20130627160127.GY28407@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130627160127.GY28407@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 27, 2013 at 06:01:27PM +0200, Peter Zijlstra wrote:
> On Wed, Jun 26, 2013 at 03:38:04PM +0100, Mel Gorman wrote:
> > @@ -3897,6 +3907,28 @@ task_hot(struct task_struct *p, u64 now, struct sched_domain *sd)
> >  	return delta < (s64)sysctl_sched_migration_cost;
> >  }
> >  
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
> > +
> 
> This references ->numa_faults, which is declared under NUMA_BALANCING
> but lacks any such conditionality here.

Fixed.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
