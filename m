Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1C8C46B0071
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 06:21:39 -0400 (EDT)
Date: Thu, 25 Mar 2010 10:21:17 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 10/11] Direct compact when a high-order allocation fails
Message-ID: <20100325102117.GO2024@csn.ul.ie>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie> <1269347146-7461-11-git-send-email-mel@csn.ul.ie> <20100324134816.529778bd.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100324134816.529778bd.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 24, 2010 at 01:48:16PM -0700, Andrew Morton wrote:
> On Tue, 23 Mar 2010 12:25:45 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > Ordinarily when a high-order allocation fails, direct reclaim is entered to
> > free pages to satisfy the allocation.  With this patch, it is determined if
> > an allocation failed due to external fragmentation instead of low memory
> > and if so, the calling process will compact until a suitable page is
> > freed. Compaction by moving pages in memory is considerably cheaper than
> > paging out to disk and works where there are locked pages or no swap. If
> > compaction fails to free a page of a suitable size, then reclaim will
> > still occur.
> > 
> > Direct compaction returns as soon as possible. As each block is compacted,
> > it is checked if a suitable page has been freed and if so, it returns.
> > 
> >
> > ...
> >
> > +static inline unsigned long compact_zone_order(struct zone *zone,
> > +						int order, gfp_t gfp_mask)
> 
> Suggest that you re-review all the manual inlining in the patchset. 
> It's rarely needed and often incorrect.
> 

I dropped both inlines. Both have only one caller and should be
automatically inlined.

> > +{
> > +	struct compact_control cc = {
> > +		.nr_freepages = 0,
> > +		.nr_migratepages = 0,
> > +		.order = order,
> > +		.migratetype = allocflags_to_migratetype(gfp_mask),
> > +		.zone = zone,
> > +	};
> > +	INIT_LIST_HEAD(&cc.freepages);
> > +	INIT_LIST_HEAD(&cc.migratepages);
> > +
> > +	return compact_zone(zone, &cc);
> > +}
> > +
> > +/**
> > + * try_to_compact_pages - Direct compact to satisfy a high-order allocation
> > + * @zonelist: The zonelist used for the current allocation
> > + * @order: The order of the current allocation
> > + * @gfp_mask: The GFP mask of the current allocation
> > + * @nodemask: The allowed nodes to allocate from
> > + *
> > + * This is the main entry point for direct page compaction.
> > + */
> > +unsigned long try_to_compact_pages(struct zonelist *zonelist,
> > +			int order, gfp_t gfp_mask, nodemask_t *nodemask)
> > +{
> > +	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
> > +	int may_enter_fs = gfp_mask & __GFP_FS;
> > +	int may_perform_io = gfp_mask & __GFP_IO;
> > +	unsigned long watermark;
> > +	struct zoneref *z;
> > +	struct zone *zone;
> > +	int rc = COMPACT_INCOMPLETE;
> > +
> > +	/* Check whether it is worth even starting compaction */
> > +	if (order == 0 || !may_enter_fs || !may_perform_io)
> > +		return rc;
> 
> hm, that was sad.  All those darn wireless drivers doing their
> high-order GFP_ATOMIC allocations cannot be saved?
> 

Not at this time. I'd need to go through migration and make it atomic-safe
first. It's doing things like taking the page table lock which is not
interrupt-safe. It's possible that migration can distinguish between atomic
and non-atomic migrations in the future.

> > +	/*
> > +	 * We will not stall if the necessary conditions are not met for
> > +	 * migration but direct reclaim seems to account stalls similarly
> > +	 */
> > +	count_vm_event(COMPACTSTALL);
> > +
> > +	/* Compact each zone in the list */
> > +	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
> > +								nodemask) {
> 
> Will all of this code play nicely with memory hotplug?
> 

I assume you mean memory hot-remove as I cannot see any problems with
memory hot-add.

Kamezawa mostly covers this but I did miss one
possibility. suitable_migration_target() will return true if a block if
MIGRATE_ISOLATE and it had a large free page at the start. I'll fix it to
explicitly avoid MIGRATE_ISOLATE.

> > +		int fragindex;
> > +		int status;
> > +
> > +		/*
> > +		 * Watermarks for order-0 must be met for compaction. Note
> > +		 * the 2UL. This is because during migration, copies of
> > +		 * pages need to be allocated and for a short time, the
> > +		 * footprint is higher
> > +		 */
> > +		watermark = low_wmark_pages(zone) + (2UL << order);
> > +		if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
> > +			continue;
> > +
> > +		/*
> > +		 * fragmentation index determines if allocation failures are
> > +		 * due to low memory or external fragmentation
> > +		 *
> > +		 * index of -1 implies allocations might succeed depending
> > +		 * 	on watermarks
> > +		 * index < 500 implies alloc failure is due to lack of memory
> > +		 *
> > +		 * XXX: The choice of 500 is arbitrary. Reinvestigate
> > +		 *      appropriately to determine a sensible default.
> > +		 *      and what it means when watermarks are also taken
> > +		 *      into account. Consider making it a sysctl
> > +		 */
> 
> Yes, best to make it a sysctl IMO.   It'll make optimisation far easier.
> /proc/sys/vm/fragmentation_index_dont_you_dare_use_this_it_will_disappear_soon
> 

Will do. This is why I leave such nice notes for myself :)

Is there also scope for a feature that allows the following?

if (!mel || !mel_told_you_to_do_this)
	slap_user();

> > +		fragindex = fragmentation_index(zone, order);
> > +		if (fragindex >= 0 && fragindex <= 500)
> > +			continue;
> > +
> > +		if (fragindex == -1 && zone_watermark_ok(zone, order, watermark, 0, 0)) {
> > +			rc = COMPACT_PARTIAL;
> > +			break;
> > +		}
> > +
> > +		status = compact_zone_order(zone, order, gfp_mask);
> > +		rc = max(status, rc);
> > +
> > +		if (zone_watermark_ok(zone, order, watermark, 0, 0))
> > +			break;
> > +	}
> > +
> > +	return rc;
> > +}
> >
> > ...
> >
> > @@ -1765,6 +1766,31 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
> >  
> >  	cond_resched();
> >  
> > +	/* Try memory compaction for high-order allocations before reclaim */
> > +	if (order) {
> > +		*did_some_progress = try_to_compact_pages(zonelist,
> > +						order, gfp_mask, nodemask);
> > +		if (*did_some_progress != COMPACT_INCOMPLETE) {
> > +			page = get_page_from_freelist(gfp_mask, nodemask,
> > +					order, zonelist, high_zoneidx,
> > +					alloc_flags, preferred_zone,
> > +					migratetype);
> > +			if (page) {
> > +				__count_vm_event(COMPACTSUCCESS);
> > +				return page;
> > +			}
> > +
> > +			/*
> > +			 * It's bad if compaction run occurs and fails.
> > +			 * The most likely reason is that pages exist,
> > +			 * but not enough to satisfy watermarks.
> > +			 */
> > +			count_vm_event(COMPACTFAIL);
> 
> This counter will get incremented if !__GFP_FS or !__GFP_IO.  Seems
> wrong.
> 

Yep, it is wrong. I'll fix it. Thanks

> > +			cond_resched();
> > +		}
> > +	}
> > +
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
