Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DA11B8D0030
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 06:12:28 -0400 (EDT)
Date: Fri, 29 Oct 2010 11:12:11 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] mm: page allocator: Adjust the per-cpu counter
	threshold when memory is low
Message-ID: <20101029101210.GG4896@csn.ul.ie>
References: <1288278816-32667-1-git-send-email-mel@csn.ul.ie> <1288278816-32667-2-git-send-email-mel@csn.ul.ie> <20101028150433.fe4f2d77.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101028150433.fe4f2d77.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 28, 2010 at 03:04:33PM -0700, Andrew Morton wrote:
> On Thu, 28 Oct 2010 16:13:35 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > Commit [aa45484: calculate a better estimate of NR_FREE_PAGES when
> > memory is low] noted that watermarks were based on the vmstat
> > NR_FREE_PAGES. To avoid synchronization overhead, these counters are
> > maintained on a per-cpu basis and drained both periodically and when a
> > threshold is above a threshold. On large CPU systems, the difference
> > between the estimate and real value of NR_FREE_PAGES can be very high.
> > The system can get into a case where pages are allocated far below the
> > min watermark potentially causing livelock issues. The commit solved the
> > problem by taking a better reading of NR_FREE_PAGES when memory was low.
> > 
> > Unfortately, as reported by Shaohua Li this accurate reading can consume
> > a large amount of CPU time on systems with many sockets due to cache
> > line bouncing. This patch takes a different approach. For large machines
> > where counter drift might be unsafe and while kswapd is awake, the per-cpu
> > thresholds for the target pgdat are reduced to limit the level of drift
> > to what should be a safe level. This incurs a performance penalty in heavy
> > memory pressure by a factor that depends on the workload and the machine but
> > the machine should function correctly without accidentally exhausting all
> > memory on a node. There is an additional cost when kswapd wakes and sleeps
> > but the event is not expected to be frequent - in Shaohua's test case,
> > there was one recorded sleep and wake event at least.
> > 
> > To ensure that kswapd wakes up, a safe version of zone_watermark_ok()
> > is introduced that takes a more accurate reading of NR_FREE_PAGES when
> > called from wakeup_kswapd, when deciding whether it is really safe to go
> > back to sleep in sleeping_prematurely() and when deciding if a zone is
> > really balanced or not in balance_pgdat(). We are still using an expensive
> > function but limiting how often it is called.
> 
> Here I go again.  I have a feeling that I already said this, but I
> can't find versions 2 or 3 in the archives..
> 
> Did you evaluate using plain on percpu_counters for this?  They won't
> solve the performance problem as they're basically the same thing as
> these open-coded counters.  But they'd reduce the amount of noise and
> custom-coded boilerplate in mm/.
> 

You did bring this up before. Here is the reference to the answer you got
from Christoph at the time http://lkml.org/lkml/2010/9/3/453 . It seemed
like a reasonable answer.

> > When the test case is reproduced, the time spent in the watermark functions
> > is reduced. The following report is on the percentage of time spent
> > cumulatively spent in the functions zone_nr_free_pages(), zone_watermark_ok(),
> > __zone_watermark_ok(), zone_watermark_ok_safe(), zone_page_state_snapshot(),
> > zone_page_state().
> 
> So how did you decide which callsites needed to use the
> fast-but-inaccurate zone_watermark_ok() and which needed to use the
> slow-but-more-accurate zone_watermark_ok_safe()?  (Those functions need
> comments explaining the difference btw)
> 

Selection was based on kswapd being woken up and staying awake

1. When deciding if kswapd should wake (wakeup_kswapd()), we have failed
   the initial allocation attempt and we should be sure of the
   watermarks to decide if kswapd really should wake or not
2. Once kswapd is awake, it shouldn't go to sleep prematurely

While kswapd is awake, drift is less of a problem because thresholds are
reduced.

> 
> I have a feeling this problem will bite us again perhaps due to those
> other callsites, but we haven't found the workload yet.
> 
> I don't undestand why restore/reduce_pgdat_percpu_threshold() were
> called around that particular sleep in kswapd and nowhere else.
> 
> > vanilla                      11.6615%
> > disable-threshold            0.2584%
> 
> Wow.  That's 12% of all CPUs?  How many CPUs and what workload?
> 

112 threads CPUs 14 sockets. Workload initialisation creates NR_CPU sparse
files that are 10*TOTAL_MEMORY/NR_CPU in size. Workload itself is NR_CPU
processes just reading their own file.

The critical thing is the number of sockets. For single-socket-8-thread
for example, vanilla was just 0.66% of time (although the patches did
bring it down to 0.11%).

> >
> > ...
> >
> >  				if (!sleeping_prematurely(pgdat, order, remaining)) {
> >  					trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
> > +					restore_pgdat_percpu_threshold(pgdat);
> >  					schedule();
> > +					reduce_pgdat_percpu_threshold(pgdat);
> 
> We could do with some code comments here explaining what's going on.
> 

Follow-on patch?

> >  				} else {
> >  					if (remaining)
> >  						count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
> >
> > ...
> >
> > +static int calculate_pressure_threshold(struct zone *zone)
> > +{
> > +	int threshold;
> > +	int watermark_distance;
> > +
> > +	/*
> > +	 * As vmstats are not up to date, there is drift between the estimated
> > +	 * and real values. For high thresholds and a high number of CPUs, it
> > +	 * is possible for the min watermark to be breached while the estimated
> > +	 * value looks fine. The pressure threshold is a reduced value such
> > +	 * that even the maximum amount of drift will not accidentally breach
> > +	 * the min watermark
> > +	 */
> > +	watermark_distance = low_wmark_pages(zone) - min_wmark_pages(zone);
> > +	threshold = max(1, (int)(watermark_distance / num_online_cpus()));
> > +
> > +	/*
> > +	 * Maximum threshold is 125
> 
> Reasoning?
> 

To match the existing maximum which I assume is due to the deltas being
stored in a s8.

> > +	 */
> > +	threshold = min(125, threshold);
> > +
> > +	return threshold;
> > +}
> > +
> >  static int calculate_threshold(struct zone *zone)
> >  {
> >  	int threshold;
> >
> > ...
> >
> > +void reduce_pgdat_percpu_threshold(pg_data_t *pgdat)
> > +{
> > +	struct zone *zone;
> > +	int cpu;
> > +	int threshold;
> > +	int i;
> > +
> > +	get_online_cpus();
> > +	for (i = 0; i < pgdat->nr_zones; i++) {
> > +		zone = &pgdat->node_zones[i];
> > +		if (!zone->percpu_drift_mark)
> > +			continue;
> > +
> > +		threshold = calculate_pressure_threshold(zone);
> > +		for_each_online_cpu(cpu)
> > +			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
> > +							= threshold;
> > +	}
> > +	put_online_cpus();
> > +}
> > +
> > +void restore_pgdat_percpu_threshold(pg_data_t *pgdat)
> > +{
> > +	struct zone *zone;
> > +	int cpu;
> > +	int threshold;
> > +	int i;
> > +
> > +	get_online_cpus();
> > +	for (i = 0; i < pgdat->nr_zones; i++) {
> > +		zone = &pgdat->node_zones[i];
> > +		if (!zone->percpu_drift_mark)
> > +			continue;
> > +
> > +		threshold = calculate_threshold(zone);
> > +		for_each_online_cpu(cpu)
> > +			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
> > +							= threshold;
> > +	}
> > +	put_online_cpus();
> > +}
> 
> Given that ->stat_threshold is the same for each CPU, why store it for
> each CPU at all?  Why not put it in the zone and eliminate the inner
> loop?
> 

I asked why we couldn't move the threshold to struct zone and Christoph
responded;

"If you move it then the cache footprint of the vm stat functions (which
need to access the threshold for each access!) will increase and the
performance sink dramatically. I tried to avoid placing the threshold
there when I developed that approach but it always caused a dramatic
regression under heavy load."

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
