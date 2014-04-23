Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3EDC46B0036
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 09:52:15 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id e53so815388eek.2
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 06:52:14 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z42si3336584eel.2.2014.04.23.06.52.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Apr 2014 06:52:13 -0700 (PDT)
Date: Wed, 23 Apr 2014 14:52:10 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: vmscan: Do not throttle based on pfmemalloc reserves
 if node has no ZONE_NORMAL
Message-ID: <20140423135210.GK23991@suse.de>
References: <20140422083852.GB23991@suse.de>
 <20140422123149.d406e5cbef5c01eb6dc5c89b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140422123149.d406e5cbef5c01eb6dc5c89b@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Apr 22, 2014 at 12:31:49PM -0700, Andrew Morton wrote:
> On Tue, 22 Apr 2014 09:38:52 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > throttle_direct_reclaim() is meant to trigger during swap-over-network
> > during which the min watermark is treated as a pfmemalloc reserve. It
> > throttes on the first node in the zonelist but this is flawed.
> > 
> > On a NUMA machine running a 32-bit kernel (I know) allocation requests
> > freom CPUs on node 1 would detect no pfmemalloc reserves and the process
> > gets throttled. This patch adjusts throttling of direct reclaim to throttle
> > based on the first node in the zonelist that has a usable ZONE_NORMAL or
> > lower zone.
> 
> I'm unable to determine from the above whether we should backport this
> fix.  Please don't forget to describe the end-user visible effects of
> a bug when that isn't obvious.  
> 

The user-visible impact is that a process running on CPU whose local
memory node has no ZONE_NORMAL will stall for prolonged periods of time,
possibly indefintely. This is due to throttle_direct_reclaim thinking the
pfmemalloc reserves are depleted when in fact they don't exist on that node.

Strictly speaking this is stable material. I should have flagged it as
such but hadn't as I was treating 32-bit kernels running on NUMA hardware
as being a poor choice.

> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2507,10 +2507,17 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
> >  
> >  	for (i = 0; i <= ZONE_NORMAL; i++) {
> >  		zone = &pgdat->node_zones[i];
> > +		if (!populated_zone(zone))
> > +			continue;
> 
> What's this?  Performance tweak?  Or does min_wmark_pages() return
> non-zero for an unpopulated zone, which seems odd.
> 

Minor performance tweak. It's a force of habit to skip populated zones
when doing a zone walk like this.

> >  		pfmemalloc_reserve += min_wmark_pages(zone);
> >  		free_pages += zone_page_state(zone, NR_FREE_PAGES);
> >  	}
> >  
> > +	/* If there are no reserves (unexpected config) then do not throttle */
> > +	if (!pfmemalloc_reserve)
> > +		return true;
> > +
> >  	wmark_ok = free_pages > pfmemalloc_reserve / 2;
> >  
> >  	/* kswapd must be awake if processes are being throttled */
> > @@ -2535,9 +2542,9 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
> >  static bool throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
> >  					nodemask_t *nodemask)
> >  {
> > +	struct zoneref *z;
> >  	struct zone *zone;
> > -	int high_zoneidx = gfp_zone(gfp_mask);
> > -	pg_data_t *pgdat;
> > +	pg_data_t *pgdat = NULL;
> >  
> >  	/*
> >  	 * Kernel threads should not be throttled as they may be indirectly
> > @@ -2556,10 +2563,24 @@ static bool throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
> >  	if (fatal_signal_pending(current))
> >  		goto out;
> >  
> > -	/* Check if the pfmemalloc reserves are ok */
> > -	first_zones_zonelist(zonelist, high_zoneidx, NULL, &zone);
> > -	pgdat = zone->zone_pgdat;
> > -	if (pfmemalloc_watermark_ok(pgdat))
> > +	/*
> > +	 * Check if the pfmemalloc reserves are ok by finding the first node
> > +	 * with a usable ZONE_NORMAL or lower zone
> > +	 */
> 
> That comment tells us what the code does but not why it does it.
> 
> - Why do we ignore zones >= ZONE_NORMAL?
> 
> - Why do we throttle when there may be as-yet-unexamined nodes which
>   have reclaimable pages?
> 

/*
 * Check if the pfmemalloc reserves are ok by finding the first node
 * with a usable ZONE_NORMAL or lower zone. The expectation is that
 * GFP_KERNEL will be required for allocating network buffers when
 * swapping over the network so ZONE_HIGHMEM is unusable.
 * 
 * Throttling is based on the first usable node and throttled processes
 * wait on a queue until kswapd makes progress and wakes them. There
 * is an affinity then between processes waking up and where reclaim
 * progress has been made assuming the process wakes on the same node.
 * More importantly, processes running on remote nodes will not compete
 * for remote pfmemalloc reserves and processes on different nodes
 * should make reasonable progress.
 */

?

> 
> > +        for_each_zone_zonelist_nodemask(zone, z, zonelist,
> > +                                        gfp_mask, nodemask) {
> 
> Those two lines have spaces-instead-of-tabs.
> 

Sorry, that was careless.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
