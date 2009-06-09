Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id DA2496B004F
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 04:55:32 -0400 (EDT)
Date: Tue, 9 Jun 2009 10:25:54 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/3] Do not unconditionally treat zones that fail
	zone_reclaim() as full
Message-ID: <20090609092554.GJ18380@csn.ul.ie>
References: <1244466090-10711-1-git-send-email-mel@csn.ul.ie> <1244466090-10711-4-git-send-email-mel@csn.ul.ie> <20090609143806.DD67.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090609143806.DD67.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, yanmin.zhang@intel.com, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 09, 2009 at 04:48:02PM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> > On NUMA machines, the administrator can configure zone_reclaim_mode that
> > is a more targetted form of direct reclaim. On machines with large NUMA
> > distances for example, a zone_reclaim_mode defaults to 1 meaning that clean
> > unmapped pages will be reclaimed if the zone watermarks are not being
> > met. The problem is that zone_reclaim() failing at all means the zone
> > gets marked full.
> > 
> > This can cause situations where a zone is usable, but is being skipped
> > because it has been considered full. Take a situation where a large tmpfs
> > mount is occuping a large percentage of memory overall. The pages do not
> > get cleaned or reclaimed by zone_reclaim(), but the zone gets marked full
> > and the zonelist cache considers them not worth trying in the future.
> > 
> > This patch makes zone_reclaim() return more fine-grained information about
> > what occured when zone_reclaim() failued. The zone only gets marked full if
> > it really is unreclaimable. If it's a case that the scan did not occur or
> > if enough pages were not reclaimed with the limited reclaim_mode, then the
> > zone is simply skipped.
> > 
> > There is a side-effect to this patch. Currently, if zone_reclaim()
> > successfully reclaimed SWAP_CLUSTER_MAX, an allocation attempt would
> > go ahead. With this patch applied, zone watermarks are rechecked after
> > zone_reclaim() does some work.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > ---
> >  mm/internal.h   |    4 ++++
> >  mm/page_alloc.c |   26 ++++++++++++++++++++++----
> >  mm/vmscan.c     |   10 +++++-----
> >  3 files changed, 31 insertions(+), 9 deletions(-)
> > 
> > diff --git a/mm/internal.h b/mm/internal.h
> > index 987bb03..090c267 100644
> > --- a/mm/internal.h
> > +++ b/mm/internal.h
> > @@ -284,4 +284,8 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> >  		     unsigned long start, int len, int flags,
> >  		     struct page **pages, struct vm_area_struct **vmas);
> >  
> > +#define ZONE_RECLAIM_NOSCAN	-2
> > +#define ZONE_RECLAIM_FULL	-1
> > +#define ZONE_RECLAIM_SOME	0
> > +#define ZONE_RECLAIM_SUCCESS	1
> >  #endif
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index fe753ec..ce2f684 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1420,20 +1420,38 @@ zonelist_scan:
> >  
> >  		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
> >  			unsigned long mark;
> > +			int ret;
> 
> Please insert one empty line here.
> 

Done.

> >  			if (alloc_flags & ALLOC_WMARK_MIN)
> >  				mark = zone->pages_min;
> >  			else if (alloc_flags & ALLOC_WMARK_LOW)
> >  				mark = zone->pages_low;
> >  			else
> >  				mark = zone->pages_high;
> > -			if (!zone_watermark_ok(zone, order, mark,
> > -				    classzone_idx, alloc_flags)) {
> > -				if (!zone_reclaim_mode ||
> > -				    !zone_reclaim(zone, gfp_mask, order))
> > +			if (zone_watermark_ok(zone, order, mark,
> > +				    classzone_idx, alloc_flags))
> > +				goto try_this_zone;
> > +
> > +			if (zone_reclaim_mode == 0)
> > +				goto this_zone_full;
> > +
> > +			ret = zone_reclaim(zone, gfp_mask, order);
> > +			switch (ret) {
> > +				case ZONE_RECLAIM_NOSCAN:
> > +					/* did not scan */
> > +					goto try_next_zone;
> > +				case ZONE_RECLAIM_FULL:
> > +					/* scanned but unreclaimable */
> >  					goto this_zone_full;
> > +				default:
> > +					/* did we reclaim enough */
> > +					if (!zone_watermark_ok(zone, order,
> > +							mark, classzone_idx,
> > +							alloc_flags))
> > +						goto try_next_zone;
> 
> hmmm
> I haven't catch your mention yet. sorry.
> Could you please explain more?
> 
> My confuseness are:
> 
> 1.
> ----
> I think your patch almost revert Paul's 9276b1bc96a132f4068fdee00983c532f43d3a26 essence.
> after your patch applied, zlc_mark_zone_full() is called only when zone_is_all_unreclaimable()==1
> or memory stealed after zone_watermark_ok() rechecking.
> 

It's true that the zone is only being marked full when it's .... full due
to all pages being unreclaimable. Maybe this is too aggressive.

> but zone_is_all_unreclaimable() is very rare on large NUMA machine. Thus
> your patch makes zlc_zone_worth_trying() check to worthless.
> So, I like simple reverting 9276b1bc rather than introduce more messy if necessary.
> 
> but necessary? why?
> 

Allegedly the ZLC cache reduces on large NUMA machines but I have no figures
proving or disproving that so I'm wary of a full revert.

The danger as I see it is that zones get skipped when there was no need
simply because the previous caller failed to scan with the case of the GFP
flags causing the zone to be marked full of particular concern.

I was also concerned that once it was marked full, the zone was unconditionally
skipped even though the next caller might be using a different watermark
level like ALLOC_WMARK_LOW or ALLOC_NO_WATERMARKS.

How about the following.

o If the zone is fully unreclaimable - mark full
o If the zone_reclaim() avoids the scan because of the number of pages
  and the current setting of reclaim_mode - mark full
o If the scan occurs but enough pages were not reclaimed to meet the
  watermarks - mark full

This is the important part

o Push down the zlc_zone_worth_trying() further down to take place after
  the watermark check has failed but before reclaim_zone() is considered

The last part in particular is important because it might mean the
zone_reclaim_interval can be later dropped because the zlc does the necessary
scan avoidance for a period of time. It also means that a check of a bitmap
is happening outside of a fast path.

> 
> 2.
> -----
> Why simple following switch-case is wrong?
> 
> 	case ZONE_RECLAIM_NOSCAN:
> 		goto try_next_zone;
> 	case ZONE_RECLAIM_FULL:
> 	case ZONE_RECLAIM_SOME:
> 		goto this_zone_full;
> 	case ZONE_RECLAIM_SUCCESS
> 		; /* do nothing */
> 
> I mean, 
>  (1) ZONE_RECLAIM_SOME and zone_watermark_ok()==1
> are rare.

How rare? In the event the zone is under pressure, we could be just on the
watermark. If we're within 32 pages of that watermark, then reclaiming some
pages might just be enough to meet the watermark so why consider it full?

> Is rechecking really worth?

If we don't recheck and we reclaimed just 1 page, we allow a caller
to go below watermarks. This could have an impact on GFP_ATOMIC
allocations.

> In my experience, zone_watermark_ok() is not so fast function.
> 

It's not, but watermarks can't be ignored just because the function is not
fast. For what it's worth, we are already in a horrible slow path by the
time we're reclaiming pages and the cost of zone_watermark_ok() is less
of a concern?

> And,
> 
>  (2) ZONE_RECLAIM_SUCCESS and zone_watermark_ok()==0
> 
> is also rare.

Again, how rare? I don't actually know myself.

> What do you afraid bad thing?
> 

Because watermarks are important.

> I guess, high-order allocation and ZONE_RECLAIM_SUCCESS and 
> zone_watermark_ok()==0 case, right?
> 
> if so, Why your system makes high order allocation so freqently?
> 

This is not about high-order allocations.

> 3.
> ------
> your patch do:
> 
> 1. call zone_reclaim() and return ZONE_RECLAIM_SUCCESS
> 2. another thread steal memory
> 3. call zone_watermark_ok() and return 0
> 
> but
> 
> 1. call zone_reclaim() and return ZONE_RECLAIM_SUCCESS
> 2. call zone_watermark_ok() and return 1
> 3. another thread steal memory
> 4. call buffered_rmqueue() and return NULL
> 
> Then, it call zlc_mark_zone_full().
> 
> it seems a bit inconsistency.
> 

There is a relatively harmless race in there when memory is extremely
tight and there are multiple threads contending. Potentially, we go one
page below the watermark per thread contending on the one zone because
we are not locking in this path and the allocation could be satisified
from the per-cpu allocator.

However, I do not see this issue as being serious enough to warrent
fixing because it would require a lock just to very strictly adhere to
the watermarks. It's different to the case above where if we did not check
watermarks, a thread can go below the watermark without any other thread
contending.

> 
> 
> 
> >  			}
> >  		}
> >  
> > +try_this_zone:
> >  		page = buffered_rmqueue(preferred_zone, zone, order, gfp_mask);
> >  		if (page)
> >  			break;
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index ffe2f32..84cdae2 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2409,7 +2409,7 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
> >  	if (pagecache_reclaimable <= zone->min_unmapped_pages
> >  	    && zone_page_state(zone, NR_SLAB_RECLAIMABLE)
> >  			<= zone->min_slab_pages)
> > -		return 0;
> > +		return ZONE_RECLAIM_NOSCAN;
> >  
> >  	/* Do not attempt a scan if scanning failed recently */
> >  	if (time_before(jiffies,
> > @@ -2417,13 +2417,13 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
> >  		return 0;
> >  
> >  	if (zone_is_all_unreclaimable(zone))
> > -		return 0;
> > +		return ZONE_RECLAIM_FULL;
> >  
> >  	/*
> >  	 * Do not scan if the allocation should not be delayed.
> >  	 */
> >  	if (!(gfp_mask & __GFP_WAIT) || (current->flags & PF_MEMALLOC))
> > -			return 0;
> > +			return ZONE_RECLAIM_NOSCAN;
> >  
> >  	/*
> >  	 * Only run zone reclaim on the local zone or on zones that do not
> > @@ -2433,10 +2433,10 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
> >  	 */
> >  	node_id = zone_to_nid(zone);
> >  	if (node_state(node_id, N_CPU) && node_id != numa_node_id())
> > -		return 0;
> > +		return ZONE_RECLAIM_NOSCAN;
> >  
> >  	if (zone_test_and_set_flag(zone, ZONE_RECLAIM_LOCKED))
> > -		return 0;
> > +		return ZONE_RECLAIM_NOSCAN;
> >  	ret = __zone_reclaim(zone, gfp_mask, order);
> >  	zone_clear_flag(zone, ZONE_RECLAIM_LOCKED);
> >  
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
