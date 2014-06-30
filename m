Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id D03566B0037
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 10:41:48 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id n15so6202233wiw.16
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 07:41:48 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id da1si10565896wib.71.2014.06.30.07.41.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 30 Jun 2014 07:41:47 -0700 (PDT)
Date: Mon, 30 Jun 2014 10:41:42 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 4/5] mm: page_alloc: Reduce cost of the fair zone
 allocation policy
Message-ID: <20140630144142.GA1369@cmpxchg.org>
References: <1403856880-12597-1-git-send-email-mgorman@suse.de>
 <1403856880-12597-5-git-send-email-mgorman@suse.de>
 <20140627185700.GV7331@cmpxchg.org>
 <20140627192537.GM10819@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140627192537.GM10819@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Fri, Jun 27, 2014 at 08:25:37PM +0100, Mel Gorman wrote:
> On Fri, Jun 27, 2014 at 02:57:00PM -0400, Johannes Weiner wrote:
> > On Fri, Jun 27, 2014 at 09:14:39AM +0100, Mel Gorman wrote:
> > > And the number of pages allocated from each zone is comparable
> > > 
> > >                             3.16.0-rc2  3.16.0-rc2
> > >                               checklow    fairzone
> > > DMA allocs                           0           0
> > > DMA32 allocs                   7374217     7920241
> > > Normal allocs                999277551   996568115
> > 
> > Wow, the DMA32 zone gets less than 1% of the allocations.  What are
> > the zone sizes in this machine?
> > 
> 
>         managed  3976
>         managed  755409
>         managed  1281601

Something seems way off with this.  On my system here, the DMA32 zone
makes up for 20% of managed pages and it gets roughly 20% of the page
allocations, as I would expect.

Your DMA32 zone makes up for 37% of the managed pages and receives
merely 0.7% of the page allocations.  Unless a large portion of that
zone is somehow unreclaimable, fairness seems completely obliberated
in both kernels.

Is that checklow's doing?

> > > @@ -3287,10 +3287,18 @@ void show_free_areas(unsigned int filter)
> > >  	show_swap_cache_info();
> > >  }
> > >  
> > > -static void zoneref_set_zone(struct zone *zone, struct zoneref *zoneref)
> > > +static int zoneref_set_zone(pg_data_t *pgdat, struct zone *zone,
> > > +			struct zoneref *zoneref, struct zone *preferred_zone)
> > >  {
> > > +	int zone_type = zone_idx(zone);
> > > +	bool fair_enabled = zone_local(zone, preferred_zone);
> > > +	if (zone_type == 0 &&
> > > +			zone->managed_pages < (pgdat->node_present_pages >> 4))
> > > +		fair_enabled = false;
> > 
> > This needs a comment.
> > 
> 
>         /*
>          * Do not count the lowest zone as of relevance to the fair zone
>          * allocation policy if it's a small percentage of the node
>          */
> 
> However, as I write this I'll look at getting rid of this entirely. It
> made some sense when fair_eligible was tracked on a per-zone basis but
> it's more complex than necessary.
>
> > >  	zoneref->zone = zone;
> > > -	zoneref->zone_idx = zone_idx(zone);
> > > +	zoneref->zone_idx = zone_type;
> > > +	return fair_enabled;
> > >  }
> > >  
> > >  /*
> > > @@ -3303,17 +3311,26 @@ static int build_zonelists_node(pg_data_t *pgdat, struct zonelist *zonelist,
> > >  {
> > >  	struct zone *zone;
> > >  	enum zone_type zone_type = MAX_NR_ZONES;
> > > +	struct zone *preferred_zone = NULL;
> > > +	int nr_fair = 0;
> > >  
> > >  	do {
> > >  		zone_type--;
> > >  		zone = pgdat->node_zones + zone_type;
> > >  		if (populated_zone(zone)) {
> > > -			zoneref_set_zone(zone,
> > > -				&zonelist->_zonerefs[nr_zones++]);
> > > +			if (!preferred_zone)
> > > +				preferred_zone = zone;
> > > +
> > > +			nr_fair += zoneref_set_zone(pgdat, zone,
> > > +				&zonelist->_zonerefs[nr_zones++],
> > > +				preferred_zone);
> > 
> > Passing preferred_zone to determine locality seems pointless when you
> > walk the zones of a single node.
> > 
> 
> True.
> 
> > And the return value of zoneref_set_zone() is fairly unexpected.
> > 
> 
> How so?

Given the name zoneref_set_zone(), I wouldn't expect any return value,
or a success/failure type return value at best - certainly not whether
the passed zone is eligible for the fairness policy.

> > It's probably better to determine fair_enabled in the callsite, that
> > would fix both problems, and write a separate helper that tests if a
> > zone is eligible for fair treatment (type && managed_pages test).
> > 
> 
> Are you thinking of putting that into the page allocator fast path? I'm
> trying to take stuff out of there :/.

Not at all, I was just suggesting to restructure the code for building
the zonelists, and move the fairness stuff out of zoneref_set_zone().

If you remove the small-zone exclusion as per above, this only leaves
the locality check when building the zonelist in zone order and that
can easily be checked inline in build_zonelists_in_zone_order().

build_zonelists_node() can just count every populated zone in nr_fair.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
