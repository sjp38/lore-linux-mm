Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 51BC26B0279
	for <linux-mm@kvack.org>; Tue, 30 May 2017 14:03:48 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k30so6262621wrc.9
        for <linux-mm@kvack.org>; Tue, 30 May 2017 11:03:48 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id t25si13494767edt.160.2017.05.30.11.03.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 30 May 2017 11:03:46 -0700 (PDT)
Date: Tue, 30 May 2017 14:03:36 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: make kswapd try harder to keep active pages in cache
Message-ID: <20170530180336.GA25329@cmpxchg.org>
References: <1495549403-3719-1-git-send-email-jbacik@fb.com>
 <20170524174610.GB22174@cmpxchg.org>
 <20170524185040.GA14869@destiny>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170524185040.GA14869@destiny>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: akpm@linux-foundation.org, kernel-team@fb.com, riel@redhat.com, linux-mm@kvack.org

On Wed, May 24, 2017 at 02:50:42PM -0400, Josef Bacik wrote:
> On Wed, May 24, 2017 at 01:46:10PM -0400, Johannes Weiner wrote:
> > > @@ -2292,6 +2310,15 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
> > >  				scan = 0;
> > >  			}
> > >  			break;
> > > +		case SCAN_INACTIVE:
> > > +			if (file && !is_active_lru(lru)) {
> > > +				if (scan && size > sc->nr_to_reclaim)
> > > +					scan = sc->nr_to_reclaim;
> > 
> > Why is the scan target different than with regular cache reclaim? I'd
> > expect that we only need to zero the active list sizes here, not that
> > we'd also need any further updates to 'scan'.
> 
> Huh I actually screwed this up slightly from what I wanted.  Since
> 
> scan = size >> sc->priority
> 
> we'd sometimes end up with scan < nr_to_reclaim, but since we're only scanning
> inactive we really want to try as hard as possible to reclaim what we need from
> inactive.  What I should have done is something like
> 
> scan = max(sc->nr_to_reclaim, scan);
> 
> instead, I'll fix that.

I see what you're saying.

But why not leave it to the priority level going up until some groups'
inactive lists make the cut? If this one node or cgroup doesn't have
size >> priority number of inactive pages, the next one might. And we
should reclaim the bigger group's inactive pages first rather than
putting disproportionately high pressure on the smaller ones.

> > > @@ -2509,8 +2536,62 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
> > >  {
> > >  	struct reclaim_state *reclaim_state = current->reclaim_state;
> > >  	unsigned long nr_reclaimed, nr_scanned;
> > > +	unsigned long nr_reclaim, nr_slab, total_high_wmark = 0, nr_inactive;
> > > +	int z;
> > >  	bool reclaimable = false;
> > > +	bool skip_slab = false;
> > > +
> > > +	nr_slab = sum_zone_node_page_state(pgdat->node_id,
> > > +					   NR_SLAB_RECLAIMABLE);
> > > +	nr_inactive = node_page_state(pgdat, NR_INACTIVE_FILE);
> > > +	nr_reclaim = pgdat_reclaimable_pages(pgdat);
> > > +
> > > +	for (z = 0; z < MAX_NR_ZONES; z++) {
> > > +		struct zone *zone = &pgdat->node_zones[z];
> > > +		if (!managed_zone(zone))
> > > +			continue;
> > > +		total_high_wmark += high_wmark_pages(zone);
> > > +	}
> > 
> > This function is used for memcg target reclaim, in which case you're
> > only looking at a subset of the pgdats and zones. Any pgdat or zone
> > state read here would be scoped incorrectly; and the ratios on the
> > node level are independent from ratios on the cgroup level and can
> > diverge heavily from each other.
> > 
> > These size inquiries to drive the balancing will have to be made
> > inside the memcg iteration loop further down with per-cgroup numbers.
> > 
> 
> Ok so I suppose I need to look at the actual lru list sizes instead for these
> numbers for !global_reclaim(sc)?

Yeah, you have to work against the lruvecs. That is the right scope
for both global reclaim and cgroup limit reclaim.

> > > +	/*
> > > +	 * We don't have historical information, we can't make good decisions
> > > +	 * about ratio's and where we should put pressure, so just apply
> > > +	 * pressure based on overall consumption ratios.
> > > +	 */
> > > +	if (!sc->slab_diff && !sc->inactive_diff)
> > > +		sc->inactive_only = 0;
> > 
> > This one I'm not sure about. If we have enough slabs and and inactive
> > pages why shouldn't we go for them first anyway - regardless of
> > whether they have grown since the last reclaim invocation?
> > 
> 
> Because we use them for the ratio of where to put pressure, but I suppose I
> could just drop this and do
> 
> foo = max(sc->slab_diff, 1);
> bar = max(sc->inactive_diff, 1);
> 
> so if we have no historical information we just equally scan both.  I'll do that
> instead.

Okay, makes sense.

> > > @@ -2543,10 +2626,27 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
> > >  			shrink_node_memcg(pgdat, memcg, sc, &lru_pages);
> > >  			node_lru_pages += lru_pages;
> > >  
> > > -			if (memcg)
> > > -				shrink_slab(sc->gfp_mask, pgdat->node_id,
> > > -					    memcg, sc->nr_scanned - scanned,
> > > -					    lru_pages);
> > > +			/*
> > > +			 * We don't want to put a lot of pressure on all of the
> > > +			 * slabs if a memcg is mostly full, so use the ratio of
> > > +			 * the lru size to the total reclaimable space on the
> > > +			 * system.  If we have sc->inactive_only set then we
> > > +			 * want to use the ratio of the difference between the
> > > +			 * two since the last kswapd run so we apply pressure to
> > > +			 * the consumer appropriately.
> > > +			 */
> > > +			if (memcg && !skip_slab) {
> > > +				unsigned long numerator = lru_pages;
> > > +				unsigned long denominator = nr_reclaim;
> > 
> > I don't quite follow this.
> > 
> > It calculates the share of this memcg's pages on the node, which is
> > the ratio we should apply to the global slab pool to have equivalent
> > pressure. However, it's being applied to the *memcg's* share of slab
> > pages. This means that the smaller the memcg relative to the node, the
> > less of its tiny share of slab objects we reclaim.
> > 
> > We're not translating from fraction to total, we're translating from
> > fraction to fraction. Shouldn't the ratio be always 1:1?
> > 
> > For example, if there is only one cgroup on the node, the ratio would
> > be 1 share of LRU pages and 1 share of slab pages. But if there are
> > two cgroups, we still scan one share of each cgroup's LRU pages but
> > only half a share of each cgroup's slab pages. That doesn't add up.
> > 
> > Am I missing something?
> > 
> 
> We hashed this out offline, but basically we concluded to add a memcg specific
> slab reclaimable counter so we can make these ratios be consistent with the
> global ratios.

Yes, that should make things a lot easier. I'm going to send out
patches for this after this email. They'll add lruvec_page_state() and
a NR_SLAB_RECLAIMABLE counter which allows you to directly compare the
slab cache and the page cache for any given lruvec you're reclaiming.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
