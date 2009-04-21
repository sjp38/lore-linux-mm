Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 034CA6B0047
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 04:35:00 -0400 (EDT)
Date: Tue, 21 Apr 2009 09:35:13 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 09/25] Calculate the migratetype for allocation only
	once
Message-ID: <20090421083513.GC12713@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-10-git-send-email-mel@csn.ul.ie> <20090421160729.F136.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090421160729.F136.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 21, 2009 at 04:37:28PM +0900, KOSAKI Motohiro wrote:
> > GFP mask is converted into a migratetype when deciding which pagelist to
> > take a page from. However, it is happening multiple times per
> > allocation, at least once per zone traversed. Calculate it once.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > ---
> >  mm/page_alloc.c |   43 ++++++++++++++++++++++++++-----------------
> >  1 files changed, 26 insertions(+), 17 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index b27bcde..f960cf5 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1065,13 +1065,13 @@ void split_page(struct page *page, unsigned int order)
> >   * or two.
> >   */
> >  static struct page *buffered_rmqueue(struct zone *preferred_zone,
> > -			struct zone *zone, int order, gfp_t gfp_flags)
> > +			struct zone *zone, int order, gfp_t gfp_flags,
> > +			int migratetype)
> >  {
> >  	unsigned long flags;
> >  	struct page *page;
> >  	int cold = !!(gfp_flags & __GFP_COLD);
> >  	int cpu;
> > -	int migratetype = allocflags_to_migratetype(gfp_flags);
> 
> hmmm....
> 
> allocflags_to_migratetype() is very cheap function and buffered_rmqueue()
> and other non-inline static function isn't guranteed inlined.
> 

A later patch makes them inlined due to the fact there is only one call
site.

> I don't think this patch improve performance on x86.
> and, I have one comment to allocflags_to_migratetype.
> 
> -------------------------------------------------------------------
> /* Convert GFP flags to their corresponding migrate type */
> static inline int allocflags_to_migratetype(gfp_t gfp_flags)
> {
>         WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
> 
>         if (unlikely(page_group_by_mobility_disabled))
>                 return MIGRATE_UNMOVABLE;
> 
>         /* Group based on mobility */
>         return (((gfp_flags & __GFP_MOVABLE) != 0) << 1) |
>                 ((gfp_flags & __GFP_RECLAIMABLE) != 0);
> }
> -------------------------------------------------------------------
> 
> s/WARN_ON/VM_BUG_ON/ is better?
> 

I wanted to catch out-of-tree drivers but it's been a while so maybe VM_BUG_ON
wouldn't hurt. I can add a patch that does that a pass 2 of improving the
allocator or would you prefer to see it now?

> GFP_MOVABLE_MASK makes 3. 3 mean MIGRATE_RESERVE. it seems obviously bug.
> 

Short answer;
No, GFP flags that result in MIGRATE_RESERVE is a bug. The caller should
never want to be allocating from there.

Longer answer;
The size of the MIGRATE_RESERVE depends on the number of free pages that
must be kept in the zone. Because GFP flags never result in here, the
area is only used when the alternative is to fail the allocation and the
watermarks are still met. The intention is that high-order atomic
allocations that were short lived may be allocated from here. This was
to preserve a behaviour in the allocator before MIGRATE_RESERVE was
introduced. It makes no sense for a caller to allocate directly out of
here and in fact the fallback list for MIGRATE_RESERVE are useless


> >  
> >  again:
> >  	cpu  = get_cpu();
> > @@ -1397,7 +1397,7 @@ static void zlc_mark_zone_full(struct zonelist *zonelist, struct zoneref *z)
> >  static struct page *
> >  get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
> >  		struct zonelist *zonelist, int high_zoneidx, int alloc_flags,
> > -		struct zone *preferred_zone)
> > +		struct zone *preferred_zone, int migratetype)
> >  {
> >  	struct zoneref *z;
> >  	struct page *page = NULL;
> > @@ -1449,7 +1449,8 @@ zonelist_scan:
> >  			}
> >  		}
> >  
> > -		page = buffered_rmqueue(preferred_zone, zone, order, gfp_mask);
> > +		page = buffered_rmqueue(preferred_zone, zone, order,
> > +						gfp_mask, migratetype);
> >  		if (page)
> >  			break;
> >  this_zone_full:
> > @@ -1513,7 +1514,8 @@ should_alloc_retry(gfp_t gfp_mask, unsigned int order,
> >  static inline struct page *
> >  __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
> >  	struct zonelist *zonelist, enum zone_type high_zoneidx,
> > -	nodemask_t *nodemask, struct zone *preferred_zone)
> > +	nodemask_t *nodemask, struct zone *preferred_zone,
> > +	int migratetype)
> >  {
> >  	struct page *page;
> >  
> > @@ -1531,7 +1533,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
> >  	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask,
> >  		order, zonelist, high_zoneidx,
> >  		ALLOC_WMARK_HIGH|ALLOC_CPUSET,
> > -		preferred_zone);
> > +		preferred_zone, migratetype);
> >  	if (page)
> >  		goto out;
> >  
> > @@ -1552,7 +1554,7 @@ static inline struct page *
> >  __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
> >  	struct zonelist *zonelist, enum zone_type high_zoneidx,
> >  	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
> > -	unsigned long *did_some_progress)
> > +	int migratetype, unsigned long *did_some_progress)
> >  {
> >  	struct page *page = NULL;
> >  	struct reclaim_state reclaim_state;
> > @@ -1585,7 +1587,8 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
> >  	if (likely(*did_some_progress))
> >  		page = get_page_from_freelist(gfp_mask, nodemask, order,
> >  					zonelist, high_zoneidx,
> > -					alloc_flags, preferred_zone);
> > +					alloc_flags, preferred_zone,
> > +					migratetype);
> >  	return page;
> >  }
> >  
> > @@ -1606,14 +1609,15 @@ is_allocation_high_priority(struct task_struct *p, gfp_t gfp_mask)
> >  static inline struct page *
> >  __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
> >  	struct zonelist *zonelist, enum zone_type high_zoneidx,
> > -	nodemask_t *nodemask, struct zone *preferred_zone)
> > +	nodemask_t *nodemask, struct zone *preferred_zone,
> > +	int migratetype)
> >  {
> >  	struct page *page;
> >  
> >  	do {
> >  		page = get_page_from_freelist(gfp_mask, nodemask, order,
> >  			zonelist, high_zoneidx, ALLOC_NO_WATERMARKS,
> > -			preferred_zone);
> > +			preferred_zone, migratetype);
> >  
> >  		if (!page && gfp_mask & __GFP_NOFAIL)
> >  			congestion_wait(WRITE, HZ/50);
> > @@ -1636,7 +1640,8 @@ void wake_all_kswapd(unsigned int order, struct zonelist *zonelist,
> >  static inline struct page *
> >  __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  	struct zonelist *zonelist, enum zone_type high_zoneidx,
> > -	nodemask_t *nodemask, struct zone *preferred_zone)
> > +	nodemask_t *nodemask, struct zone *preferred_zone,
> > +	int migratetype)
> >  {
> >  	const gfp_t wait = gfp_mask & __GFP_WAIT;
> >  	struct page *page = NULL;
> > @@ -1687,14 +1692,16 @@ restart:
> >  	 */
> >  	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
> >  						high_zoneidx, alloc_flags,
> > -						preferred_zone);
> > +						preferred_zone,
> > +						migratetype);
> >  	if (page)
> >  		goto got_pg;
> >  
> >  	/* Allocate without watermarks if the context allows */
> >  	if (is_allocation_high_priority(p, gfp_mask))
> >  		page = __alloc_pages_high_priority(gfp_mask, order,
> > -			zonelist, high_zoneidx, nodemask, preferred_zone);
> > +			zonelist, high_zoneidx, nodemask, preferred_zone,
> > +			migratetype);
> >  	if (page)
> >  		goto got_pg;
> >  
> > @@ -1707,7 +1714,7 @@ restart:
> >  					zonelist, high_zoneidx,
> >  					nodemask,
> >  					alloc_flags, preferred_zone,
> > -					&did_some_progress);
> > +					migratetype, &did_some_progress);
> >  	if (page)
> >  		goto got_pg;
> >  
> > @@ -1719,7 +1726,8 @@ restart:
> >  		if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
> >  			page = __alloc_pages_may_oom(gfp_mask, order,
> >  					zonelist, high_zoneidx,
> > -					nodemask, preferred_zone);
> > +					nodemask, preferred_zone,
> > +					migratetype);
> >  			if (page)
> >  				goto got_pg;
> >  
> > @@ -1758,6 +1766,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
> >  	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
> >  	struct zone *preferred_zone;
> >  	struct page *page;
> > +	int migratetype = allocflags_to_migratetype(gfp_mask);
> >  
> >  	lockdep_trace_alloc(gfp_mask);
> >  
> > @@ -1783,11 +1792,11 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
> >  	/* First allocation attempt */
> >  	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
> >  			zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET,
> > -			preferred_zone);
> > +			preferred_zone, migratetype);
> >  	if (unlikely(!page))
> >  		page = __alloc_pages_slowpath(gfp_mask, order,
> >  				zonelist, high_zoneidx, nodemask,
> > -				preferred_zone);
> > +				preferred_zone, migratetype);
> >  
> >  	return page;
> >  }
> > -- 
> > 1.5.6.5
> > 
> 
> 
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
