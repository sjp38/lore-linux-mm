Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B1D356B005C
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 03:50:07 -0400 (EDT)
Date: Tue, 9 Jun 2009 09:18:21 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/3] Reintroduce zone_reclaim_interval for when
	zone_reclaim() scans and fails to avoid CPU spinning at 100% on NUMA
Message-ID: <20090609081821.GE18380@csn.ul.ie>
References: <1244466090-10711-1-git-send-email-mel@csn.ul.ie> <1244466090-10711-2-git-send-email-mel@csn.ul.ie> <20090609143211.DD64.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090609143211.DD64.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, yanmin.zhang@intel.com, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 09, 2009 at 04:48:28PM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> > On NUMA machines, the administrator can configure zone_reclaim_mode that is a
> > more targetted form of direct reclaim. On machines with large NUMA distances,
> > zone_reclaim_mode defaults to 1 meaning that clean unmapped pages will be
> > reclaimed if the zone watermarks are not being met. The problem is that
> > zone_reclaim() can be in a situation where it scans excessively without
> > making progress.
> > 
> > One such situation is where a large tmpfs mount is occupying a large
> > percentage of memory overall. The pages do not get cleaned or reclaimed by
> > zone_reclaim(), but the lists are uselessly scanned frequencly making the
> > CPU spin at 100%. The scanning occurs because zone_reclaim() cannot tell
> > in advance the scan is pointless because the counters do not distinguish
> > between pagecache pages backed by disk and by RAM.  The observation in
> > the field is that malloc() stalls for a long time (minutes in some cases)
> > when this situation occurs.
> > 
> > Accounting for ram-backed file pages was considered but not implemented on
> > the grounds it would be introducing new branches and expensive checks into
> > the page cache add/remove patches and increase the number of statistics
> > needed in the zone. As zone_reclaim() failing is currently considered a
> > corner case, this seemed like overkill. Note, if there are a large number
> > of reports about CPU spinning at 100% on NUMA that is fixed by disabling
> > zone_reclaim, then this assumption is false and zone_reclaim() scanning
> > and failing is not a corner case but a common occurance
> > 
> > This patch reintroduces zone_reclaim_interval which was removed by commit
> > 34aa1330f9b3c5783d269851d467326525207422 [zoned vm counters: zone_reclaim:
> > remove /proc/sys/vm/zone_reclaim_interval] because the zone counters were
> > considered sufficient to determine in advance if the scan would succeed.
> > As unsuccessful scans can still occur, zone_reclaim_interval is still
> > required.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie
> > ---
> >  Documentation/sysctl/vm.txt |   13 +++++++++++++
> >  include/linux/mmzone.h      |    9 +++++++++
> >  include/linux/swap.h        |    1 +
> >  kernel/sysctl.c             |    9 +++++++++
> >  mm/vmscan.c                 |   22 ++++++++++++++++++++++
> >  5 files changed, 54 insertions(+), 0 deletions(-)
> > 
> > diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> > index c302ddf..f9b8db5 100644
> > --- a/Documentation/sysctl/vm.txt
> > +++ b/Documentation/sysctl/vm.txt
> > @@ -52,6 +52,7 @@ Currently, these files are in /proc/sys/vm:
> >  - swappiness
> >  - vfs_cache_pressure
> >  - zone_reclaim_mode
> > +- zone_reclaim_interval
> >  
> >  
> >  ==============================================================
> > @@ -620,4 +621,16 @@ Allowing regular swap effectively restricts allocations to the local
> >  node unless explicitly overridden by memory policies or cpuset
> >  configurations.
> >  
> > +================================================================
> > +
> > +zone_reclaim_interval:
> > +
> > +The time allowed for off node allocations after zone reclaim
> > +has failed to reclaim enough pages to allow a local allocation.
> > +
> > +Time is set in seconds and set by default to 30 seconds.
> > +
> > +Reduce the interval if undesired off node allocations occur. However, too
> > +frequent scans will have a negative impact on off-node allocation performance.
> > +
> >  ============ End of Document =================================
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index a47c879..f1f0fb2 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -337,6 +337,15 @@ struct zone {
> >  	atomic_long_t		vm_stat[NR_VM_ZONE_STAT_ITEMS];
> >  
> >  	/*
> > +	 * timestamp (in jiffies) of the last zone_reclaim that scanned
> > +	 * but failed to free enough pages. This is used to avoid repeated
> > +	 * scans when zone_reclaim() is unable to detect in advance that
> > +	 * the scanning is useless. This can happen for example if a zone
> > +	 * has large numbers of clean unmapped file pages on tmpfs
> > +	 */
> > +	unsigned long		zone_reclaim_failure;
> > +
> > +	/*
> >  	 * prev_priority holds the scanning priority for this zone.  It is
> >  	 * defined as the scanning priority at which we achieved our reclaim
> >  	 * target at the previous try_to_free_pages() or balance_pgdat()
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index d476aad..6a71368 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -224,6 +224,7 @@ extern long vm_total_pages;
> >  
> >  #ifdef CONFIG_NUMA
> >  extern int zone_reclaim_mode;
> > +extern int zone_reclaim_interval;
> >  extern int sysctl_min_unmapped_ratio;
> >  extern int sysctl_min_slab_ratio;
> >  extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
> > diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> > index b2970d5..cc0623c 100644
> > --- a/kernel/sysctl.c
> > +++ b/kernel/sysctl.c
> > @@ -1192,6 +1192,15 @@ static struct ctl_table vm_table[] = {
> >  		.extra1		= &zero,
> >  	},
> >  	{
> > +		.ctl_name       = CTL_UNNUMBERED,
> > +		.procname       = "zone_reclaim_interval",
> > +		.data           = &zone_reclaim_interval,
> > +		.maxlen         = sizeof(zone_reclaim_interval),
> > +		.mode           = 0644,
> > +		.proc_handler   = &proc_dointvec_jiffies,
> > +		.strategy       = &sysctl_jiffies,
> > +	},
> 
> hmmm, I think nobody can know proper interval settings on his own systems.
> I agree with Wu. It can be hidden.
> 

For the few users that case, I expect the majority of those will choose
either 0 or the default value of 30. They might want to alter this while
setting zone_reclaim_mode if they don't understand the different values
it can have for example.

My preference would be that this not exist at all but the
scan-avoidance-heuristic has to be perfect to allow that.

> 
> > +	{
> >  		.ctl_name	= VM_MIN_UNMAPPED,
> >  		.procname	= "min_unmapped_ratio",
> >  		.data		= &sysctl_min_unmapped_ratio,
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index d254306..ba211c1 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2272,6 +2272,13 @@ int zone_reclaim_mode __read_mostly;
> >  #define RECLAIM_SWAP (1<<2)	/* Swap pages out during reclaim */
> >  
> >  /*
> > + * Minimum time between zone_reclaim() scans that failed. Ordinarily, a
> > + * scan will not fail because it will be determined in advance if it can
> > + * succeeed but this does not always work. See mmzone.h
> > + */
> > +int zone_reclaim_interval __read_mostly = 30*HZ;
> > +
> > +/*
> >   * Priority for ZONE_RECLAIM. This determines the fraction of pages
> >   * of a node considered for each zone_reclaim. 4 scans 1/16th of
> >   * a zone.
> > @@ -2390,6 +2397,11 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
> >  			<= zone->min_slab_pages)
> >  		return 0;
> >  
> > +	/* Do not attempt a scan if scanning failed recently */
> > +	if (time_before(jiffies,
> > +			zone->zone_reclaim_failure + zone_reclaim_interval))
> > +		return 0;
> > +
> >  	if (zone_is_all_unreclaimable(zone))
> >  		return 0;
> >  
> > @@ -2414,6 +2426,16 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
> >  	ret = __zone_reclaim(zone, gfp_mask, order);
> >  	zone_clear_flag(zone, ZONE_RECLAIM_LOCKED);
> >  
> > +	if (!ret) {
> > +		/*
> > +		 * We were unable to reclaim enough pages to stay on node and
> > +		 * unable to detect in advance that the scan would fail. Allow
> > +		 * off node accesses for zone_reclaim_inteval jiffies before
> > +		 * trying zone_reclaim() again
> > +		 */
> > +		zone->zone_reclaim_failure = jiffies;
> 
> Oops, this simple assignment don't care jiffies round-trip.
> 

Here it is just recording the jiffies value. The real smarts with the counter
use time_before() which I assumed could handle jiffie wrap-arounds. Even
if it doesn't, the consequence is that one scan will occur that could have
been avoided around the time of the jiffie wraparound. The value will then
be reset and it will be fine.

> 
> > +	}
> > +
> >  	return ret;
> >  }
> >  #endif

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
