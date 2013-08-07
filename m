Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 35F996B0074
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 11:38:03 -0400 (EDT)
Date: Wed, 7 Aug 2013 11:37:43 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch v2 3/3] mm: page_alloc: fair zone allocator policy
Message-ID: <20130807153743.GH715@cmpxchg.org>
References: <1375457846-21521-1-git-send-email-hannes@cmpxchg.org>
 <1375457846-21521-4-git-send-email-hannes@cmpxchg.org>
 <20130807145828.GQ2296@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130807145828.GQ2296@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@surriel.com>, Andrea Arcangeli <aarcange@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 07, 2013 at 03:58:28PM +0100, Mel Gorman wrote:
> On Fri, Aug 02, 2013 at 11:37:26AM -0400, Johannes Weiner wrote:
> > Each zone that holds userspace pages of one workload must be aged at a
> > speed proportional to the zone size.  Otherwise, the time an
> > individual page gets to stay in memory depends on the zone it happened
> > to be allocated in.  Asymmetry in the zone aging creates rather
> > unpredictable aging behavior and results in the wrong pages being
> > reclaimed, activated etc.
> > 
> > But exactly this happens right now because of the way the page
> > allocator and kswapd interact.  The page allocator uses per-node lists
> > of all zones in the system, ordered by preference, when allocating a
> > new page.  When the first iteration does not yield any results, kswapd
> > is woken up and the allocator retries.  Due to the way kswapd reclaims
> > zones below the high watermark while a zone can be allocated from when
> > it is above the low watermark, the allocator may keep kswapd running
> > while kswapd reclaim ensures that the page allocator can keep
> > allocating from the first zone in the zonelist for extended periods of
> > time.  Meanwhile the other zones rarely see new allocations and thus
> > get aged much slower in comparison.
> > 
> > The result is that the occasional page placed in lower zones gets
> > relatively more time in memory, even gets promoted to the active list
> > after its peers have long been evicted.  Meanwhile, the bulk of the
> > working set may be thrashing on the preferred zone even though there
> > may be significant amounts of memory available in the lower zones.
> > 
> > Even the most basic test -- repeatedly reading a file slightly bigger
> > than memory -- shows how broken the zone aging is.  In this scenario,
> > no single page should be able stay in memory long enough to get
> > referenced twice and activated, but activation happens in spades:
> > 
> >   $ grep active_file /proc/zoneinfo
> >       nr_inactive_file 0
> >       nr_active_file 0
> >       nr_inactive_file 0
> >       nr_active_file 8
> >       nr_inactive_file 1582
> >       nr_active_file 11994
> >   $ cat data data data data >/dev/null
> >   $ grep active_file /proc/zoneinfo
> >       nr_inactive_file 0
> >       nr_active_file 70
> >       nr_inactive_file 258753
> >       nr_active_file 443214
> >       nr_inactive_file 149793
> >       nr_active_file 12021
> > 
> > Fix this with a very simple round robin allocator.  Each zone is
> > allowed a batch of allocations that is proportional to the zone's
> > size, after which it is treated as full.  The batch counters are reset
> > when all zones have been tried and the allocator enters the slowpath
> > and kicks off kswapd reclaim.  Allocation and reclaim is now fairly
> > spread out to all available/allowable zones:
> > 
> >   $ grep active_file /proc/zoneinfo
> >       nr_inactive_file 0
> >       nr_active_file 0
> >       nr_inactive_file 174
> >       nr_active_file 4865
> >       nr_inactive_file 53
> >       nr_active_file 860
> >   $ cat data data data data >/dev/null
> >   $ grep active_file /proc/zoneinfo
> >       nr_inactive_file 0
> >       nr_active_file 0
> >       nr_inactive_file 666622
> >       nr_active_file 4988
> >       nr_inactive_file 190969
> >       nr_active_file 937
> > 
> > When zone_reclaim_mode is enabled, allocations will now spread out to
> > all zones on the local node, not just the first preferred zone (which
> > on a 4G node might be a tiny Normal zone).
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > Tested-by: Zlatko Calusic <zcalusic@bitsync.net>
> > ---
> >  include/linux/mmzone.h |  1 +
> >  mm/page_alloc.c        | 69 ++++++++++++++++++++++++++++++++++++++++++--------
> >  2 files changed, 60 insertions(+), 10 deletions(-)
> > 
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index af4a3b7..dcad2ab 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -352,6 +352,7 @@ struct zone {
> >  	 * free areas of different sizes
> >  	 */
> >  	spinlock_t		lock;
> > +	int			alloc_batch;
> >  	int                     all_unreclaimable; /* All pages pinned */
> >  #if defined CONFIG_COMPACTION || defined CONFIG_CMA
> >  	/* Set to true when the PG_migrate_skip bits should be cleared */
> 
> This adds a dirty cache line that is updated on every allocation even if
> it's from the per-cpu allocator. I am concerned that this will introduce
> noticable overhead in the allocator paths on large machines running
> allocator intensive workloads.
> 
> Would it be possible to move it into the per-cpu pageset? I understand
> that hte round-robin nature will then depend on what CPU is running and
> the performance characterisics will be different. There might even be an
> adverse workload that uses all the batches from all available CPUs until
> it is essentially the same problem but that would be a very worst case.
> I would hope that in general it would work without adding a big source of
> dirty cache line bouncing in the middle of the allocator.

Rik made the same suggestion.  The per-cpu error is one thing, the
problem is if the allocating task and kswapd run on the same CPU and
bypass the round-robin allocator completely, at which point we are
back to square one.  We'd have to reduce the per-cpu lists from a pool
to strict batching of frees and allocs without reuse in between.  That
might be doable, I'll give this another look.

> > @@ -2006,7 +2036,8 @@ this_zone_full:
> >  		goto zonelist_scan;
> >  	}
> >  
> > -	if (page)
> > +	if (page) {
> > +		zone->alloc_batch -= 1U << order;
> 
> This line is where I think there will be noticable increases in cache
> misses when running parallel tests. PFT from mmtests on a large machine
> might be able to show the problem.

I tested this back then with the original atomic ops on a two socket
machine:

pft
                              BASE               RRALLOC            WORKINGSET
User       1       0.0235 (  0.00%)       0.0275 (-17.02%)       0.0270 (-14.89%)
User       2       0.0275 (  0.00%)       0.0275 ( -0.00%)       0.0285 ( -3.64%)
User       3       0.0330 (  0.00%)       0.0365 (-10.61%)       0.0335 ( -1.52%)
User       4       0.0390 (  0.00%)       0.0390 (  0.00%)       0.0380 (  2.56%)
System     1       0.2645 (  0.00%)       0.2620 (  0.95%)       0.2625 (  0.76%)
System     2       0.3215 (  0.00%)       0.3310 ( -2.95%)       0.3285 ( -2.18%)
System     3       0.3935 (  0.00%)       0.4080 ( -3.68%)       0.4130 ( -4.96%)
System     4       0.4920 (  0.00%)       0.5030 ( -2.24%)       0.5045 ( -2.54%)
Elapsed    1       0.2905 (  0.00%)       0.2905 (  0.00%)       0.2905 (  0.00%)
Elapsed    2       0.1800 (  0.00%)       0.1800 (  0.00%)       0.1800 (  0.00%)
Elapsed    3       0.1500 (  0.00%)       0.1600 ( -6.67%)       0.1600 ( -6.67%)
Elapsed    4       0.1305 (  0.00%)       0.1420 ( -8.81%)       0.1415 ( -8.43%)
Faults/cpu 1  667251.7997 (  0.00%)  666296.4749 ( -0.14%)  667880.8099 (  0.09%)
Faults/cpu 2  551464.0345 (  0.00%)  536113.4630 ( -2.78%)  538286.2087 ( -2.39%)
Faults/cpu 3  452403.4425 (  0.00%)  433856.5320 ( -4.10%)  432193.9888 ( -4.47%)
Faults/cpu 4  362691.4491 (  0.00%)  356514.8821 ( -1.70%)  356436.5711 ( -1.72%)
Faults/sec 1  663612.5980 (  0.00%)  662501.4959 ( -0.17%)  664037.3123 (  0.06%)
Faults/sec 2 1096166.5317 (  0.00%) 1064679.7154 ( -2.87%) 1068906.1040 ( -2.49%)
Faults/sec 3 1272925.4995 (  0.00%) 1209241.9167 ( -5.00%) 1202868.9190 ( -5.50%)
Faults/sec 4 1437691.1054 (  0.00%) 1362549.9877 ( -5.23%) 1381633.9889 ( -3.90%)

so a 2-5% regression in fault throughput on this machine.  I would
love to avoid it, but I don't think it's a show stopper if it buys
500% improvements in tests like parallelio on the same machine.

> > @@ -2346,16 +2378,28 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
> >  	return page;
> >  }
> >  
> > -static inline
> > -void wake_all_kswapd(unsigned int order, struct zonelist *zonelist,
> > -						enum zone_type high_zoneidx,
> > -						enum zone_type classzone_idx)
> > +static void prepare_slowpath(gfp_t gfp_mask, unsigned int order,
> > +			     struct zonelist *zonelist,
> > +			     enum zone_type high_zoneidx,
> > +			     struct zone *preferred_zone)
> >  {
> >  	struct zoneref *z;
> >  	struct zone *zone;
> >  
> > -	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
> > -		wakeup_kswapd(zone, order, classzone_idx);
> > +	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
> > +		if (!(gfp_mask & __GFP_NO_KSWAPD))
> > +			wakeup_kswapd(zone, order, zone_idx(preferred_zone));
> > +		/*
> > +		 * Only reset the batches of zones that were actually
> > +		 * considered in the fast path, we don't want to
> > +		 * thrash fairness information for zones that are not
> > +		 * actually part of this zonelist's round-robin cycle.
> > +		 */
> > +		if (zone_reclaim_mode && !zone_local(preferred_zone, zone))
> > +			continue;
> > +		zone->alloc_batch = high_wmark_pages(zone) -
> > +			low_wmark_pages(zone);
> > +	}
> 
> We now call wakeup_kswapd() when the batches for the round-robin are
> expired. In some circumstances this can be expensive in its own right if
> it calls zone_watermark_ok_safe() from zone_balanced().
> 
> If we are entering the slowpath because the batches are expired should
> the fast path reset the alloc_batches once and retry the fast path before
> wakeup_kswapd?

The batches are set up so that their expiration coincides with the
watermarks being hit.  I haven't actually double checked it, but I'm
going to run some tests to see if the wakeups increased significantly.

Thanks for the input, Mel!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
