Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 80E236B003B
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 19:48:11 -0400 (EDT)
Date: Thu, 8 Aug 2013 01:48:00 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 9/9] mm: zone_reclaim: compaction: add compaction to
 zone_reclaim_mode
Message-ID: <20130807234800.GG4661@redhat.com>
References: <1375459596-30061-1-git-send-email-aarcange@redhat.com>
 <1375459596-30061-10-git-send-email-aarcange@redhat.com>
 <20130804165526.GG27921@redhat.com>
 <20130807161837.GW2296@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130807161837.GW2296@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hush Bensen <hush.bensen@gmail.com>

On Wed, Aug 07, 2013 at 05:18:37PM +0100, Mel Gorman wrote:
> > It is important to boot with numa_zonelist_order=n (n means nodes) to
> > get more accurate NUMA locality if there are multiple zones per node.
> > 
> 
> This appears to be an unrelated observation.

But things still don't work ok without it. After alloc_batch changes
it matters only in the slowpath but it still related.

> 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > ---
> >  include/linux/swap.h |   8 +++-
> >  mm/page_alloc.c      |   4 +-
> >  mm/vmscan.c          | 111 ++++++++++++++++++++++++++++++++++++++++++---------
> >  3 files changed, 102 insertions(+), 21 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index f2ada36..fedb246 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> >
> > <SNIP>
> >
> > @@ -3549,27 +3567,35 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
> >  	return sc.nr_reclaimed >= nr_pages;
> >  }
> >  
> > -int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
> > +static int zone_reclaim_compact(struct zone *preferred_zone,
> > +				struct zone *zone, gfp_t gfp_mask,
> > +				unsigned int order,
> > +				bool sync_compaction,
> > +				bool *need_compaction)
> >  {
> > -	int node_id;
> > -	int ret;
> > +	bool contended;
> >  
> > -	/*
> > -	 * Zone reclaim reclaims unmapped file backed pages and
> > -	 * slab pages if we are over the defined limits.
> > -	 *
> > -	 * A small portion of unmapped file backed pages is needed for
> > -	 * file I/O otherwise pages read by file I/O will be immediately
> > -	 * thrown out if the zone is overallocated. So we do not reclaim
> > -	 * if less than a specified percentage of the zone is used by
> > -	 * unmapped file backed pages.
> > -	 */
> > -	if (zone_pagecache_reclaimable(zone) <= zone->min_unmapped_pages &&
> > -	    zone_page_state(zone, NR_SLAB_RECLAIMABLE) <= zone->min_slab_pages)
> > -		return ZONE_RECLAIM_FULL;
> > +	if (compaction_deferred(preferred_zone, order) ||
> > +	    !order ||
> > +	    (gfp_mask & (__GFP_FS|__GFP_IO)) != (__GFP_FS|__GFP_IO)) {
> > +		*need_compaction = false;
> > +		return COMPACT_SKIPPED;
> > +	}
> >  
> > -	if (zone->all_unreclaimable)
> > -		return ZONE_RECLAIM_FULL;
> > +	*need_compaction = true;
> > +	return compact_zone_order(zone, order,
> > +				  gfp_mask,
> > +				  sync_compaction,
> > +				  &contended);
> > +}
> > +
> > +int zone_reclaim(struct zone *preferred_zone, struct zone *zone,
> > +		 gfp_t gfp_mask, unsigned int order,
> > +		 unsigned long mark, int classzone_idx, int alloc_flags)
> > +{
> > +	int node_id;
> > +	int ret, c_ret;
> > +	bool sync_compaction = false, need_compaction = false;
> >  
> >  	/*
> >  	 * Do not scan if the allocation should not be delayed.
> > @@ -3587,7 +3613,56 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
> >  	if (node_state(node_id, N_CPU) && node_id != numa_node_id())
> >  		return ZONE_RECLAIM_NOSCAN;
> >  
> > +repeat_compaction:
> > +	/*
> > +	 * If this allocation may be satisfied by memory compaction,
> > +	 * run compaction before reclaim.
> > +	 */
> > +	c_ret = zone_reclaim_compact(preferred_zone,
> > +				     zone, gfp_mask, order,
> > +				     sync_compaction,
> > +				     &need_compaction);
> > +	if (need_compaction &&
> > +	    c_ret != COMPACT_SKIPPED &&
> 
> need_compaction records whether compaction was attempted or not. Why
> not just check for COMPACT_SKIPPED and have compact_zone_order return
> COMPACT_SKIPPED if !CONFIG_COMPACTION?

How can it be ok that try_to_compact_pages returns COMPACT_CONTINUE
but compact_zone order returns the opposite? I mean either we change
both or none.

static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
			int order, gfp_t gfp_mask, nodemask_t *nodemask,
			bool sync, bool *contended)
{
	return COMPACT_CONTINUE;
}

static inline unsigned long compact_zone_order(struct zone *zone,
					       int order, gfp_t gfp_mask,
					       bool sync, bool *contended)
{
	return COMPACT_CONTINUE;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
