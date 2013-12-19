Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id AD9646B0031
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 06:20:56 -0500 (EST)
Received: by mail-ee0-f50.google.com with SMTP id c41so406038eek.9
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 03:20:56 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u49si3853119eep.127.2013.12.19.03.20.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Dec 2013 03:20:55 -0800 (PST)
Date: Thu, 19 Dec 2013 11:20:51 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/6] Configurable fair allocation zone policy v3
Message-ID: <20131219112051.GH11295@suse.de>
References: <1387298904-8824-1-git-send-email-mgorman@suse.de>
 <20131217200210.GG21724@cmpxchg.org>
 <20131218061750.GK21724@cmpxchg.org>
 <20131218150038.GP11295@suse.de>
 <20131218194813.GB20038@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131218194813.GB20038@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 18, 2013 at 02:48:13PM -0500, Johannes Weiner wrote:
> > <SNIP>
> > 
> > Sure about the name?
> > 
> > This is a boolean and "mode" implies it might be a bitmask. That said, I
> > recognise that my own naming also sucked because complaining about yours
> > I can see that mine also sucks.
> 
> Is it because of how we use zone_reclaim_mode? I don't see anything
> wrong with a "mode" toggle that switches between only two modes of
> operation instead of three or more.  But English being a second
> language and all...
> 

It's not just zone_reclaim_mode. Most references to mode in the VM (but
not all because who needs consistentcy) refer to either a mask or multiple
potential values. isolate_mode_t, gfp masks referred to as mode, memory
policies described as mode, migration modes etc.

Intuitively, I expect "mode" to not be a binary value.

> > > @@ -1816,7 +1833,7 @@ static void zlc_clear_zones_full(struct zonelist *zonelist)
> > >  
> > >  static bool zone_local(struct zone *local_zone, struct zone *zone)
> > >  {
> > > -	return node_distance(local_zone->node, zone->node) == LOCAL_DISTANCE;
> > > +	return local_zone->node == zone->node;
> > >  }
> > 
> > Does that not break on !CONFIG_NUMA?
> > 
> > It's why I used zone_to_nid
> 
> There is a separate definition for !CONFIG_NUMA, it fit nicely next to
> the zlc stuff.
> 

Ah, fair enough.

> > >  static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
> > > @@ -1908,22 +1925,25 @@ zonelist_scan:
> > >  		if (unlikely(alloc_flags & ALLOC_NO_WATERMARKS))
> > >  			goto try_this_zone;
> > >  		/*
> > > -		 * Distribute pages in proportion to the individual
> > > -		 * zone size to ensure fair page aging.  The zone a
> > > -		 * page was allocated in should have no effect on the
> > > -		 * time the page has in memory before being reclaimed.
> > > +		 * Distribute pagecache pages in proportion to the
> > > +		 * individual zone size to ensure fair page aging.
> > > +		 * The zone a page was allocated in should have no
> > > +		 * effect on the time the page has in memory before
> > > +		 * being reclaimed.
> > >  		 *
> > > -		 * When zone_reclaim_mode is enabled, try to stay in
> > > -		 * local zones in the fastpath.  If that fails, the
> > > +		 * When pagecache_mempolicy_mode or zone_reclaim_mode
> > > +		 * is enabled, try to allocate from zones within the
> > > +		 * preferred node in the fastpath.  If that fails, the
> > >  		 * slowpath is entered, which will do another pass
> > >  		 * starting with the local zones, but ultimately fall
> > >  		 * back to remote zones that do not partake in the
> > >  		 * fairness round-robin cycle of this zonelist.
> > >  		 */
> > > -		if (alloc_flags & ALLOC_WMARK_LOW) {
> > > +		if ((alloc_flags & ALLOC_WMARK_LOW) &&
> > > +		    (gfp_mask & __GFP_PAGECACHE)) {
> > >  			if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
> > >  				continue;
> > 
> > NR_ALLOC_BATCH is updated regardless of zone_reclaim_mode or
> > pagecache_mempolicy_mode. We only reset batch in the prepare_slowpath in
> > some cases. Looks a bit fishy even though I can't quite put my finger on it.
> > 
> > I also got details wrong here in the v3 of the series. In an unreleased
> > v4 of the series I had corrected the treatment of slab pages in line
> > with your wishes and reused the broken out helper in prepare_slowpath to
> > keep the decision in sync.
> > 
> > It's still in development but even if it gets rejected it'll act as a
> > comparison point to yours.
> > 
> > > -			if (zone_reclaim_mode &&
> > > +			if ((zone_reclaim_mode || pagecache_mempolicy_mode) &&
> > >  			    !zone_local(preferred_zone, zone))
> > >  				continue;
> > >  		}
> > 
> > Documention says "enabling pagecache_mempolicy_mode, in which case page cache
> > allocations will be placed according to the configured memory policy". Should
> > that be !pagecache_mempolicy_mode? I'm getting confused with the double nots.
> 
> Yes, it's a bit weird.
> 
> We want to consider the round-robin batches for local zones but at the
> same time avoid exhausted batches from pushing the allocation off-node
> when either of those modes are enabled.  So in the fastpath we filter
> for both and in the slowpath, once kswapd has been woken at the same
> time that the batches have been reset to launch the new aging cycle,
> we try in order of zonelist preference.
> 
> However, to answer your question above, if the slowpath still has to
> fall back to a remote zone, we don't want to reset its batch because
> we didn't verify it was actually exhausted in the fastpath and we
> could risk cutting short the aging cycle for that particular zone.

Understood, thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
