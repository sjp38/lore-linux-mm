Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id A88AF6B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 07:57:24 -0400 (EDT)
Date: Wed, 31 Jul 2013 12:57:19 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/18] Basic scheduler support for automatic NUMA
 balancing V5
Message-ID: <20130731115719.GT2296@suse.de>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <20130725103620.GM27075@twins.programming.kicks-ass.net>
 <20130731103052.GR2296@suse.de>
 <20130731104814.GA3008@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130731104814.GA3008@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 31, 2013 at 12:48:14PM +0200, Peter Zijlstra wrote:
> On Wed, Jul 31, 2013 at 11:30:52AM +0100, Mel Gorman wrote:
> > I'm not sure I understand your point. The scan rate is decreased again if
> > the page is found to be properly placed in the future. It's in the next
> > hunk you modify although the periodically reset comment is now out of date.
> 
> Yeah its because of the next hunk. I figured that if we don't lower it,
> we shouldn't raise it either.
> 

hmm, I'm going to punt that to a TODO item and think about it some more
with a fresh head.

> > > @@ -1167,10 +1171,20 @@ void task_numa_fault(int last_nidpid, in
> > >  	/*
> > >  	 * If pages are properly placed (did not migrate) then scan slower.
> > >  	 * This is reset periodically in case of phase changes
> > > -	 */
> > > -        if (!migrated)
> > > +	 *
> > > +	 * APZ: it seems to me that one can get a ton of !migrated faults;
> > > +	 * consider the scenario where two threads fight over a shared memory
> > > +	 * segment. We'll win half the faults, half of that will be local, half
> > > +	 * of that will be remote. This means we'll see 1/4-th of the total
> > > +	 * memory being !migrated. Using a fixed increment will completely
> > > +	 * flatten the scan speed for a sufficiently large workload. Another
> > > +	 * scenario is due to that migration rate limit.
> > > +	 *
> > > +        if (!migrated) {
> > >  		p->numa_scan_period = min(p->numa_scan_period_max,
> > >  			p->numa_scan_period + jiffies_to_msecs(10));
> > > +	}
> > > +	 */
> > 
> > FWIW, I'm also not happy with how the scan rate is reduced but did not
> > come up with a better alternative that was not fragile or depended on
> > gathering too much state. Granted, I also have not been treating it as a
> > high priority problem.
> 
> Right, so what Ingo did is have the scan rate depend on the convergence.
> What exactly did you dislike about that?
> 

It depended entirely on properly detecting if we are converged or not. As
things like false share detection within THP is still not there I was
worried that it was too easy to make the wrong decision here and keep it
pinned at the maximum scan rate.

> We could define the convergence as all the faults inside the interleave
> mask vs the total faults, and then run at: min + (1 - c)*(max-min).
> 

And when we have such things properly in place then I think we can kick
away the current crutch.

> > > +#if 0
> > >  	/*
> > >  	 * We do not care about task placement until a task runs on a node
> > >  	 * other than the first one used by the address space. This is
> > >  	 * largely because migrations are driven by what CPU the task
> > >  	 * is running on. If it's never scheduled on another node, it'll
> > >  	 * not migrate so why bother trapping the fault.
> > > +	 *
> > > +	 * APZ: seems like a bad idea for pure shared memory workloads.
> > >  	 */
> > >  	if (mm->first_nid == NUMA_PTE_SCAN_INIT)
> > >  		mm->first_nid = numa_node_id();
> > 
> > At some point in the past scan starts were based on waiting a fixed interval
> > but that seemed like a hack designed to get around hurting kernel compile
> > benchmarks. I'll give it more thought and see can I think of a better
> > alternative that is based on an event but not this event.
> 
> Ah, well the reasoning on that was that all this NUMA business is
> 'expensive' so we'd better only bother with tasks that persist long
> enough for it to pay off.
> 

Which is fair enough but tasks that lasted *just* longer than the interval
still got punished. Processes running with a slightly slower CPU gets
hurts meaning that it would be a difficult bug report to digest.

> In that regard it makes perfect sense to wait a fixed amount of runtime
> before we start scanning.
> 
> So it was not a pure hack to make kbuild work again.. that is did was
> good though.
> 

Maybe we should reintroduce the delay then but I really would prefer that
it was triggered on some sort of event.

> > > @@ -1254,9 +1272,14 @@ void task_numa_work(struct callback_head
> > >  	 * Do not set pte_numa if the current running node is rate-limited.
> > >  	 * This loses statistics on the fault but if we are unwilling to
> > >  	 * migrate to this node, it is less likely we can do useful work
> > > -	 */
> > > +	 *
> > > +	 * APZ: seems like a bad idea; even if this node can't migrate anymore
> > > +	 * other nodes might and we want up-to-date information to do balance
> > > +	 * decisions.
> > > +	 *
> > >  	if (migrate_ratelimited(numa_node_id()))
> > >  		return;
> > > +	 */
> > >  
> > 
> > Ingo also disliked this but I wanted to avoid a situation where the
> > workload suffered because of a corner case where the interconnect was
> > filled with migration traffic.
> 
> Right, but you already rate limit the actual migrations, this should
> leave enough bandwidth to allow the non-migrating scanning.
> 
> I think its important we keep up-to-date information if we're going to
> do placement based on it.
> 

Ok, you convinced me. I slapped a changelog on it that is a cut&paste job
and moved it earlier in the series.

> On that rate-limit, this looks to be a hard-coded number unrelated to
> the actual hardware.

Guesstimate.

> I think we should at the very least make it a
> configurable number and preferably scale the number with the SLIT info.
> Or alternatively actually measure the node to node bandwidth.
> 

Ideally we should just kick it away because scan rate limiting works
properly. Lets not make it a tunable just yet so we can avoid having to
deprecate it later.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
