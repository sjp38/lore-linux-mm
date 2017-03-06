Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 63EFC6B0038
	for <linux-mm@kvack.org>; Sun,  5 Mar 2017 20:37:46 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id j5so185588744pfb.3
        for <linux-mm@kvack.org>; Sun, 05 Mar 2017 17:37:46 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id d64si1900322pfc.193.2017.03.05.17.37.44
        for <linux-mm@kvack.org>;
        Sun, 05 Mar 2017 17:37:45 -0800 (PST)
Date: Mon, 6 Mar 2017 10:37:40 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/9] mm: fix 100% CPU kswapd busyloop on unreclaimable
 nodes
Message-ID: <20170306013740.GA8779@bbox>
References: <20170228214007.5621-1-hannes@cmpxchg.org>
 <20170228214007.5621-2-hannes@cmpxchg.org>
 <20170303012609.GA3394@bbox>
 <20170303075954.GA31499@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170303075954.GA31499@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Jia He <hejianet@gmail.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Hi Michal,

On Fri, Mar 03, 2017 at 08:59:54AM +0100, Michal Hocko wrote:
> On Fri 03-03-17 10:26:09, Minchan Kim wrote:
> > Hi Johannes,
> > 
> > On Tue, Feb 28, 2017 at 04:39:59PM -0500, Johannes Weiner wrote:
> > > Jia He reports a problem with kswapd spinning at 100% CPU when
> > > requesting more hugepages than memory available in the system:
> > > 
> > > $ echo 4000 >/proc/sys/vm/nr_hugepages
> > > 
> > > top - 13:42:59 up  3:37,  1 user,  load average: 1.09, 1.03, 1.01
> > > Tasks:   1 total,   1 running,   0 sleeping,   0 stopped,   0 zombie
> > > %Cpu(s):  0.0 us, 12.5 sy,  0.0 ni, 85.5 id,  2.0 wa,  0.0 hi,  0.0 si,  0.0 st
> > > KiB Mem:  31371520 total, 30915136 used,   456384 free,      320 buffers
> > > KiB Swap:  6284224 total,   115712 used,  6168512 free.    48192 cached Mem
> > > 
> > >   PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
> > >    76 root      20   0       0      0      0 R 100.0 0.000 217:17.29 kswapd3
> > > 
> > > At that time, there are no reclaimable pages left in the node, but as
> > > kswapd fails to restore the high watermarks it refuses to go to sleep.
> > > 
> > > Kswapd needs to back away from nodes that fail to balance. Up until
> > > 1d82de618ddd ("mm, vmscan: make kswapd reclaim in terms of nodes")
> > > kswapd had such a mechanism. It considered zones whose theoretically
> > > reclaimable pages it had reclaimed six times over as unreclaimable and
> > > backed away from them. This guard was erroneously removed as the patch
> > > changed the definition of a balanced node.
> > > 
> > > However, simply restoring this code wouldn't help in the case reported
> > > here: there *are* no reclaimable pages that could be scanned until the
> > > threshold is met. Kswapd would stay awake anyway.
> > > 
> > > Introduce a new and much simpler way of backing off. If kswapd runs
> > > through MAX_RECLAIM_RETRIES (16) cycles without reclaiming a single
> > > page, make it back off from the node. This is the same number of shots
> > > direct reclaim takes before declaring OOM. Kswapd will go to sleep on
> > > that node until a direct reclaimer manages to reclaim some pages, thus
> > > proving the node reclaimable again.
> > > 
> > > v2: move MAX_RECLAIM_RETRIES to mm/internal.h (Michal)
> > > 
> > > Reported-by: Jia He <hejianet@gmail.com>
> > > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > > Tested-by: Jia He <hejianet@gmail.com>
> > > Acked-by: Michal Hocko <mhocko@suse.com>
> > > ---
> > >  include/linux/mmzone.h |  2 ++
> > >  mm/internal.h          |  6 ++++++
> > >  mm/page_alloc.c        |  9 ++-------
> > >  mm/vmscan.c            | 27 ++++++++++++++++++++-------
> > >  mm/vmstat.c            |  2 +-
> > >  5 files changed, 31 insertions(+), 15 deletions(-)
> > > 
> > > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > > index 8e02b3750fe0..d2c50ab6ae40 100644
> > > --- a/include/linux/mmzone.h
> > > +++ b/include/linux/mmzone.h
> > > @@ -630,6 +630,8 @@ typedef struct pglist_data {
> > >  	int kswapd_order;
> > >  	enum zone_type kswapd_classzone_idx;
> > >  
> > > +	int kswapd_failures;		/* Number of 'reclaimed == 0' runs */
> > > +
> > >  #ifdef CONFIG_COMPACTION
> > >  	int kcompactd_max_order;
> > >  	enum zone_type kcompactd_classzone_idx;
> > > diff --git a/mm/internal.h b/mm/internal.h
> > > index ccfc2a2969f4..aae93e3fd984 100644
> > > --- a/mm/internal.h
> > > +++ b/mm/internal.h
> > > @@ -81,6 +81,12 @@ static inline void set_page_refcounted(struct page *page)
> > >  extern unsigned long highest_memmap_pfn;
> > >  
> > >  /*
> > > + * Maximum number of reclaim retries without progress before the OOM
> > > + * killer is consider the only way forward.
> > > + */
> > > +#define MAX_RECLAIM_RETRIES 16
> > > +
> > > +/*
> > >   * in mm/vmscan.c:
> > >   */
> > >  extern int isolate_lru_page(struct page *page);
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index 614cd0397ce3..f50e36e7b024 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -3516,12 +3516,6 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
> > >  }
> > >  
> > >  /*
> > > - * Maximum number of reclaim retries without any progress before OOM killer
> > > - * is consider as the only way to move forward.
> > > - */
> > > -#define MAX_RECLAIM_RETRIES 16
> > > -
> > > -/*
> > >   * Checks whether it makes sense to retry the reclaim to make a forward progress
> > >   * for the given allocation request.
> > >   * The reclaim feedback represented by did_some_progress (any progress during
> > > @@ -4527,7 +4521,8 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
> > >  			K(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
> > >  			K(node_page_state(pgdat, NR_UNSTABLE_NFS)),
> > >  			node_page_state(pgdat, NR_PAGES_SCANNED),
> > > -			!pgdat_reclaimable(pgdat) ? "yes" : "no");
> > > +			pgdat->kswapd_failures >= MAX_RECLAIM_RETRIES ?
> > > +				"yes" : "no");
> > >  	}
> > >  
> > >  	for_each_populated_zone(zone) {
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index 26c3b405ef34..407b27831ff7 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -2626,6 +2626,15 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
> > >  	} while (should_continue_reclaim(pgdat, sc->nr_reclaimed - nr_reclaimed,
> > >  					 sc->nr_scanned - nr_scanned, sc));
> > >  
> > > +	/*
> > > +	 * Kswapd gives up on balancing particular nodes after too
> > > +	 * many failures to reclaim anything from them and goes to
> > > +	 * sleep. On reclaim progress, reset the failure counter. A
> > > +	 * successful direct reclaim run will revive a dormant kswapd.
> > > +	 */
> > > +	if (reclaimable)
> > > +		pgdat->kswapd_failures = 0;
> > > +
> > >  	return reclaimable;
> > >  }
> > >  
> > > @@ -2700,10 +2709,6 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
> > >  						 GFP_KERNEL | __GFP_HARDWALL))
> > >  				continue;
> > >  
> > > -			if (sc->priority != DEF_PRIORITY &&
> > > -			    !pgdat_reclaimable(zone->zone_pgdat))
> > > -				continue;	/* Let kswapd poll it */
> > > -
> > >  			/*
> > >  			 * If we already have plenty of memory free for
> > >  			 * compaction in this zone, don't free any more.
> > > @@ -3134,6 +3139,10 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, int classzone_idx)
> > >  	if (waitqueue_active(&pgdat->pfmemalloc_wait))
> > >  		wake_up_all(&pgdat->pfmemalloc_wait);
> > >  
> > > +	/* Hopeless node, leave it to direct reclaim */
> > 
> > I hope to clear what we want by deferring the job to direct reclaim.
> > Direct reclaim is much limited reclaim worker by serveral things(e.g.,
> > avoid writeback for stack overflow, NOIO|NOFS context)
> 
> This is true but if kswapd cannot reclaim anything at all then we do not
> have much choice left
> 
> > so what do we
> > want for direct reclaimer to do even if kswapd can make forward
> > progress? OOM?
> 
> yes resp. back off for costly high order requests and leave the node
> unbalanced.

Okay, I just wanted to clear it out because we have kept logic to
prevent CPU burn out of direct reclaim in case of being full with
unreclaiamble pages of zones. And this patch removes it in
shrink_zones. It might be optimized to cut off direct reclaim
if kswapd failure is higher than threshold so we reach OOM fast
without pointless retrial to reclaim in direct reclaim path but
I guess it would be rare case so no worth to optimize.

commit 36fb7f8
Author: Andrew Morton <akpm@digeo.com>
Date:   Thu Nov 21 19:32:34 2002 -0800

    [PATCH] handle zones which are full of unreclaimable pages

> 
> > > +	if (pgdat->kswapd_failures >= MAX_RECLAIM_RETRIES)
> > > +		return true;
> > > +
> > >  	for (i = 0; i <= classzone_idx; i++) {
> > >  		struct zone *zone = pgdat->node_zones + i;
> > >  
> > > @@ -3316,6 +3325,9 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
> > >  			sc.priority--;
> > >  	} while (sc.priority >= 1);
> > >  
> > > +	if (!sc.nr_reclaimed)
> > > +		pgdat->kswapd_failures++;
> > 
> > sc.nr_reclaimed is reset to zero in above big loop's beginning so most of time,
> > it pgdat->kswapd_failures is increased.
> 
> But then we increase the counter in kswapd_shrink_node or do I miss your
> point? Are you suggesting to use the aggregate nr_reclaimed over all
> priorities because the last round might have made no progress?

Yes.

Let's assume there is severe memory pressure so there would be less
LRU pages than sum += highwatermark of eligible zones(As well,
user can configure watermark big in a specific zone). In that case,
kswapd will increase prioirity by kswapd_shrink_node's return check
although it reclaims a few of pages.

Also, process can consume pages kswapd reclaimed in parallel without
entering slow path because it uses *low* watermark. So there would be
no chance to reset kswapd_failure to zero until it goes slow path.

Also, although it goes direct reclaim's slow path, it cannot wakeup
kswapd until it can make forward progress which is condition to
reset kswapd_failure and consider direct reclaimer's context is
easily limited with NO_[FS|IO] so sometime, it would be hard to make
forward progress.

We can rule out that situation easily via aggregating nr_reclaimed
in balance_pgdat, simply. Why not?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
