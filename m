Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 69CAE6B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 08:53:39 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so24981649wib.1
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 05:53:38 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id ja14si26949770wic.18.2015.07.29.05.53.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Wed, 29 Jul 2015 05:53:37 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id C4BE098C2C
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 12:53:36 +0000 (UTC)
Date: Wed, 29 Jul 2015 13:53:34 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 09/10] mm, page_alloc: Reserve pageblocks for high-order
 atomic allocations on demand
Message-ID: <20150729125334.GC19352@techsingularity.net>
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
 <1437379219-9160-10-git-send-email-mgorman@suse.com>
 <55B8BA75.9090903@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <55B8BA75.9090903@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@suse.com>, Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 29, 2015 at 01:35:17PM +0200, Vlastimil Babka wrote:
> On 07/20/2015 10:00 AM, Mel Gorman wrote:
> > From: Mel Gorman <mgorman@suse.de>
> > 
> > High-order watermark checking exists for two reasons --  kswapd high-order
> > awareness and protection for high-order atomic requests. Historically we
> > depended on MIGRATE_RESERVE to preserve min_free_kbytes as high-order free
> > pages for as long as possible. This patch introduces MIGRATE_HIGHATOMIC
> > that reserves pageblocks for high-order atomic allocations. This is expected
> > to be more reliable than MIGRATE_RESERVE was.
> > 
> > A MIGRATE_HIGHORDER pageblock is created when an allocation request steals
> > a pageblock but limits the total number to 10% of the zone.
> 
> This looked weird, until I read the implementation and realized that "an
> allocation request" is limited to high-order atomic allocation requests.
> 

Which is an important detail for understanding the patch, thanks.

> > The pageblocks are unreserved if an allocation fails after a direct
> > reclaim attempt.
> > 
> > The watermark checks account for the reserved pageblocks when the allocation
> > request is not a high-order atomic allocation.
> > 
> > The stutter benchmark was used to evaluate this but while it was running
> > there was a systemtap script that randomly allocated between 1 and 1G worth
> > of order-3 pages using GFP_ATOMIC. In kernel 4.2-rc1 running this workload
> > on a single-node machine there were 339574 allocation failures. With this
> > patch applied there were 28798 failures -- a 92% reduction. On a 4-node
> > machine, allocation failures went from 76917 to 0 failures.
> > 
> > There are minor theoritical side-effects. If the system is intensively
> > making large numbers of long-lived high-order atomic allocations then
> > there will be a lot of reserved pageblocks. This may push some workloads
> > into reclaim until the number of reserved pageblocks is reduced again. This
> > problem was not observed in reclaim intensive workloads but such workloads
> > are also not atomic high-order intensive.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> [...]
> 
> > +/*
> > + * Used when an allocation is about to fail under memory pressure. This
> > + * potentially hurts the reliability of high-order allocations when under
> > + * intense memory pressure but failed atomic allocations should be easier
> > + * to recover from than an OOM.
> > + */
> > +static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
> > +{
> > +	struct zonelist *zonelist = ac->zonelist;
> > +	unsigned long flags;
> > +	struct zoneref *z;
> > +	struct zone *zone;
> > +	struct page *page;
> > +	int order;
> > +
> > +	for_each_zone_zonelist_nodemask(zone, z, zonelist, ac->high_zoneidx,
> > +								ac->nodemask) {
> 
> This fixed order might bias some zones over others wrt unreserving. Is it OK?

I could not think of a situation where it mattered. It'll always be
preferring highest zone over lower zones. Allocation requests that can
use any zone that do not care. Allocation requests that are limited to
lower zones are protected as long as possible.

> 
> > +		/* Preserve at least one pageblock */
> > +		if (zone->nr_reserved_highatomic <= pageblock_nr_pages)
> > +			continue;
> > +
> > +		spin_lock_irqsave(&zone->lock, flags);
> > +		for (order = 0; order < MAX_ORDER; order++) {
> 
> Would it make more sense to look in descending order for a higher chance of
> unreserving a pageblock that's mostly free? Like the traditional page stealing does?
> 

I don't think it's worth the search cost. Traditional page stealing is
searching because it's trying to minimise events that cause external
fragmentation. Here we'd gain very little. We are under some memory
pressure here, if enough pages are not free then another one will get
freed shortly. Either way, I doubt the difference is measurable.

> > +			struct free_area *area = &(zone->free_area[order]);
> > +
> > +			if (list_empty(&area->free_list[MIGRATE_HIGHATOMIC]))
> > +				continue;
> > +
> > +			page = list_entry(area->free_list[MIGRATE_HIGHATOMIC].next,
> > +						struct page, lru);
> > +
> > +			zone->nr_reserved_highatomic -= pageblock_nr_pages;
> > +			set_pageblock_migratetype(page, ac->migratetype);
> 
> Would it make more sense to assume MIGRATE_UNMOVABLE, as high-order allocations
> present in the pageblock typically would be, and apply the traditional page
> stealing heuristics to decide if it should be changed to ac->migratetype (if
> that differs)?
> 

Superb spot, I had to think about this for a while and initially I was
thinking your suggestion was a no-brainer and obviously the right thing
to do.

On the pro side, it preserves the fragmentation logic because it'll force
the normal page stealing logic to be applied.

On the con side, we may reassign the pageblock twice -- once to
MIGRATE_UNMOVABLE and once to ac->migratetype. That one does not matter
but the second con is that we inadvertly increase the number of unmovable
blocks in some cases.

Lets say we default to MIGRATE_UNMOVABLE, ac->migratetype is MIGRATE_MOVABLE
and there are enough free pages to satisfy the allocation but not steal
the whole pageblock. The end result is that we have a new unmovable
pageblock that may not be necessary. The next unmovable allocation
potentially is forever. They key observation is that previously the
pageblock could have been short-lived high-order allocations that could
be completely free soon if it was assigned MIGRATE_MOVABLE. This may not
apply when SLUB is using high-order allocations but the point still
holds.

Grouping pages by mobility really needs to strive to keep the number of
unmovable blocks as low as possible. If ac->migratetype is
MIGRATE_UNMOVABLE then we lose nothing. If it's any other type then the
current code keeps the number of unmovable blocks as low as possible.

On that basis I think the current code is fine but it needs a comment to
record why it's like this.

> > @@ -2175,15 +2257,23 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
> >  			unsigned long mark, int classzone_idx, int alloc_flags,
> >  			long free_pages)
> >  {
> > -	/* free_pages may go negative - that's OK */
> >  	long min = mark;
> >  	int o;
> >  	long free_cma = 0;
> >  
> > +	/* free_pages may go negative - that's OK */
> >  	free_pages -= (1 << order) - 1;
> > +
> >  	if (alloc_flags & ALLOC_HIGH)
> >  		min -= min / 2;
> > -	if (alloc_flags & ALLOC_HARDER)
> > +
> > +	/*
> > +	 * If the caller is not atomic then discount the reserves. This will
> > +	 * over-estimate how the atomic reserve but it avoids a search
> > +	 */
> > +	if (likely(!(alloc_flags & ALLOC_HARDER)))
> > +		free_pages -= z->nr_reserved_highatomic;
> 
> Hm, so in the case the maximum of 10% reserved blocks is already full, we deny
> the allocation access to another 10% of the memory and push it to reclaim. This
> seems rather excessive.

It's necessary. If normal callers can use it then the reserve fills with
normal pages, the memory gets fragmented and high-order atomic allocations
fail due to fragmentation. Similarly, the number of MIGRATE_HIGHORDER
pageblocks cannot be unbound or everything else will be continually pushed
into reclaim even if there is plenty of memory free.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
