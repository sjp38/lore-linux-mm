Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id A75CC6B0033
	for <linux-mm@kvack.org>; Thu,  4 Jul 2013 09:54:23 -0400 (EDT)
Date: Thu, 4 Jul 2013 14:54:15 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 13/13] sched: Account for the number of preferred tasks
 running on a node when selecting a preferred node
Message-ID: <20130704135415.GR1875@suse.de>
References: <1372861300-9973-1-git-send-email-mgorman@suse.de>
 <1372861300-9973-14-git-send-email-mgorman@suse.de>
 <20130703183243.GB18898@dyad.programming.kicks-ass.net>
 <20130704093716.GO1875@suse.de>
 <20130704130719.GC29916@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130704130719.GC29916@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 04, 2013 at 06:37:19PM +0530, Srikar Dronamraju wrote:
> >  static void task_numa_placement(struct task_struct *p)
> >  {
> >  	int seq, nid, max_nid = 0;
> > @@ -897,7 +924,7 @@ static void task_numa_placement(struct task_struct *p)
> > 
> >  		/* Find maximum private faults */
> >  		faults = p->numa_faults[task_faults_idx(nid, 1)];
> > -		if (faults > max_faults) {
> > +		if (faults > max_faults && !sched_numa_overloaded(nid)) {
> 
> Should we take the other approach of setting the preferred nid but not 
> moving the task to the node?
> 

Why would that be better?

> So if some task moves out of the preferred node, then we should still be
> able to move this task there. 
> 

I think if we were to do that then I'd revisit the "task swap" logic from
autonuma (numacore had something similar) and search for pairs of tasks
that both benefit from a swap. I prototyped something basic alont this
lines but it was premature. It's a more directed approach but one that
should be done only when the private/shared and load logic is solidified.

> However your current approach has an advantage that it atleast runs on
> second preferred choice if not the first.
> 

That was the intention.

> Also should sched_numa_overloaded() also consider pinned tasks?
> 

I don't think sched_numa_overloaded() needs to as such, least I don't see how
it would do it sensibly right now. However, you still make an important point
in that find_idlest_cpu_node should take it into account. How about this?

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 9247345..387f28d 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -863,9 +863,13 @@ find_idlest_cpu_node(int this_cpu, int nid)
 		load = weighted_cpuload(i);
 
 		if (load < min_load) {
-			/* Do not preempt a task running on a preferred node */
+			/*
+			 * Do not preempt a task running on a preferred node or
+			 * tasks are are pinned to their current CPU
+			 */
 			struct task_struct *p = cpu_rq(i)->curr;
-			if (p->numa_preferred_nid != nid) {
+			if (p->numa_preferred_nid != nid &&
+			    cpumask_weight(tsk_cpus_allowed(p)) > 1) {
 				min_load = load;
 				idlest_cpu = i;
 			}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
