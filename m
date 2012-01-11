Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id E01826B006C
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 02:05:18 -0500 (EST)
From: Milton Miller <miltonm@bga.com>
Subject: Re: [PATCH v6 7/8] mm: only IPI CPUs to drain local pages if they exist
In-Reply-To: <op.v7vcjum63l0zgt@mpn-glaptop>
References: 
 <op.v7vcjum63l0zgt@mpn-glaptop>
 <alpine.DEB.2.00.1201091034390.31395@router.home>
 <1326040026-7285-8-git-send-email-gilad@benyossef.com>
Date: Wed, 11 Jan 2012 01:04:14 -0600
Message-ID: <1326265454_1664@mail4.comsite.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>, Christoph Lameter <cl@linux.com>, Michal Nazarewicz <mina86@mina86.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org
Cc: Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Sasha Levin <levinsasha928@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

On Mon Jan 09 2012 about 11:47:36 EST, Michal Nazarewicz wrote:
> On Mon Jan 09 2012 11:35:37 +0100, Christoph Lameter <cl@linux.com> wrote:
> > On Sun, 8 Jan 2012, Gilad Ben-Yossef wrote:
> > > 
> > > Calculate a cpumask of CPUs with per-cpu pages in any zone
> > > and only send an IPI requesting CPUs to drain these pages
> > > to the buddy allocator if they actually have pages when
> > > asked to flush.
> > > 
> > > This patch saves 90%+ of IPIs asking to drain per-cpu
> > > pages in case of severe memory preassure that leads
> > > to OOM since in these cases multiple, possibly concurrent,
> > > allocation requests end up in the direct reclaim code
> > > path so when the per-cpu pages end up reclaimed on first
> > > allocation failure for most of the proceeding allocation
> > > attempts until the memory pressure is off (possibly via
> > > the OOM killer) there are no per-cpu pages on most CPUs
> > > (and there can easily be hundreds of them).
> > > 
> > > This also has the side effect of shortening the average
> > > latency of direct reclaim by 1 or more order of magnitude
> > > since waiting for all the CPUs to ACK the IPI takes a
> > > long time.
> > > 
> > > Tested by running "hackbench 400" on a 4 CPU x86 otherwise
> > > idle VM and observing the difference between the number
> > > of direct reclaim attempts that end up in drain_all_pages()
> > > and those were more then 1/2 of the online CPU had any
> > > per-cpu page in them, using the vmstat counters introduced
> > > in the next patch in the series and using proc/interrupts.
> > > 
> > > In the test sceanrio, this saved around 500 global IPIs.
> > > After trigerring an OOM:
> > > 
> > > $ cat /proc/vmstat
> > > ...
> > > pcp_global_drain 627
> > > pcp_global_ipi_saved 578
> > > 
> > > I've also seen the number of drains reach 15k calls
> > > with the saved percentage reaching 99% when there
> > > are more tasks running during an OOM kill.
> > > 
> > > Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
> > > Acked-by: Mel Gorman <mel@csn.ul.ie>
> > > Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

> > > ---
> > >  mm/page_alloc.c |   26 +++++++++++++++++++++++++-
> > >  1 files changed, 25 insertions(+), 1 deletions(-)
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index bdc804c..dc97199 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -67,6 +67,14 @@ DEFINE_PER_CPU(int, numa_node);
> > >  EXPORT_PER_CPU_SYMBOL(numa_node);
> > >  #endif
> > >  
> > > +/*
> > > + * A global cpumask of CPUs with per-cpu pages that gets
> > > + * recomputed on each drain. We use a global cpumask
> > > + * here to avoid allocation on direct reclaim code path
> > > + * for CONFIG_CPUMASK_OFFSTACK=y
> > > + */
> > > +static cpumask_var_t cpus_with_pcps;
> > > +
> > Move the static definition into drain_all_pages()? 
>
> This is initialised in setup_per_cpu_pageset() so it needs to be file scoped.

Instead of allocating and initialising a cpumask_var_t at runtime for
the life of the kernel we could create a cpumask_t in bss.  It would
trade the permanent kmalloc for some BSS (but we haven't merged the
nr_cpu_ids cpumask_size yet, so we aren't saving any memory).

> > >  #ifdef CONFIG_HAVE_MEMORYLESS_NODES
> > >  /*
> > >   * N.B., Do NOT reference the '_numa_mem_' per cpu variable directly.
> > > @@ -1097,7 +1105,19 @@ void drain_local_pages(void *arg)
> > >   */
> > >  void drain_all_pages(void)
> > >  {
> > > -	on_each_cpu(drain_local_pages, NULL, 1);
> > > +	int cpu;
> > > +	struct per_cpu_pageset *pcp;
> > > +	struct zone *zone;
> > > +
> > > +	for_each_online_cpu(cpu)
> > > +		for_each_populated_zone(zone) {
> > > +			pcp = per_cpu_ptr(zone->pageset, cpu);
> > > +			if (pcp->pcp.count)
> > > +				cpumask_set_cpu(cpu, cpus_with_pcps);
> > > +			else
> > > +				cpumask_clear_cpu(cpu, cpus_with_pcps);
> > > +		}
> > > +	on_each_cpu_mask(cpus_with_pcps, drain_local_pages, NULL, 1);
> > 

This will only select cpus that have pcp pages in the last zone,
not pages in any populated zone.

Call cpu_mask_clear before the for_each_online_cpu loop, and only
set cpus in the loop.

Hmm, that means we actually need a lock for using the static mask.

-- what would happen without any lock? 
[The last to store would likely see all the cpus and send them IPIs
but the earlier, racing callers would miss some cpus (It will test
our smp_call_function_many locking!), and would retry before all the
pages were drained from pcp pools].  The locking should be better
than racing -- one cpu will peek and pull all per-cpu data to itself,
then copy the mask to its smp_call_function_many element, then wait
for all the cpus it found cpus to process their list pulling their
pcp data back to the owners.   Not much sense in the racing cpus
figighting to bring the per-cpu data to themselves to write to the
now contended static mask while pulling the zone pcp data from the
owning cpus that are trying to push to the buddy lists.

The benefit numbers in the changelog need to be measured again
after this correction.


At first I was thinking raw_spinlock_t but then I realized we have
filtered !__GFP_WAIT and have called cond_sched several times so we
can sleep.  But I am not sure we really want to use a mutex, we could
end up scheduling every task trying to lock this mask in the middle
of the memory allocation slowpath?  What happens if we decide to oom
kill a random task waiting at this mutex, will we become unfair?
If we use interruptable and are signalled do we just skip waiting
for the per cpu buckets to drain? what if we are trying to allocate
memory to delive the signal?  Of course, a mutex might lead us to
find a task that can make progress with the memory it already has.
Definitely could use some exploration.

I think we should start with a normal spinlock (not irq, must respond
to an ipi here!) or a try_spin_lock / cond_resched / cpu_relax loop.



An alternative to clearing the mask at the beginning is to loop over
the zones, calculating the summary for each cpu, then make the set or
clear decision.   Or letting the cpus take themselves out of the mask,
but I think both of those are worse.  While it might hide the lock
I think it would only lead to cache contention on the mask and pcp.


Disabling preemption around online loop and the call will prevent
races with cpus going offline, but we do not that we care as the
offline notification will cause the notified cpu to drain that pool.
on_each_cpu_mask disables preemption as part of its processing.

If we document the o-e-c-m behaviour then we should consider putting a
comment here, or at least put the previous paragraph in the change log.


> > >  }
> > >  
> > >  #ifdef CONFIG_HIBERNATION
> > > @@ -3601,6 +3621,10 @@ static void setup_zone_pageset(struct zone *zone)
> > >  void __init setup_per_cpu_pageset(void)
> > >  {
> > >  	struct zone *zone;
> > > +	int ret;
> > > +
> > > +	ret = zalloc_cpumask_var(&cpus_with_pcps, GFP_KERNEL);
> > > +	BUG_ON(!ret);
> > >  

Switching to cpumask_t will eliminate this hunk.   Even if we decide
to keep it a cpumask_var_t we don't need to pre-zero it as we set
the entire mask so alloc_cpumask_var would be sufficient.

milton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
