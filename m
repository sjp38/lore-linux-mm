Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3BE486B007B
	for <linux-mm@kvack.org>; Fri,  5 Feb 2010 05:24:07 -0500 (EST)
Date: Fri, 5 Feb 2010 10:23:50 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/7] Export unusable free space index via
	/proc/pagetypeinfo
Message-ID: <20100205102349.GB20412@csn.ul.ie>
References: <1262795169-9095-1-git-send-email-mel@csn.ul.ie> <1262795169-9095-3-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1001281411290.30252@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1001281411290.30252@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 28, 2010 at 02:27:39PM -0800, David Rientjes wrote:
> On Wed, 6 Jan 2010, Mel Gorman wrote:
> 
> > Unusuable free space index is a measure of external fragmentation that
> > takes the allocation size into account. For the most part, the huge page
> > size will be the size of interest but not necessarily so it is exported
> > on a per-order and per-zone basis via /proc/pagetypeinfo.
> > 
> > The index is normally calculated as a value between 0 and 1 which is
> > obviously unsuitable within the kernel. Instead, the first three decimal
> > places are used as a value between 0 and 1000 for an integer approximation.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > ---
> >  mm/vmstat.c |   99 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  1 files changed, 99 insertions(+), 0 deletions(-)
> > 
> > diff --git a/mm/vmstat.c b/mm/vmstat.c
> > index 6051fba..e1ea2d5 100644
> > --- a/mm/vmstat.c
> > +++ b/mm/vmstat.c
> > @@ -451,6 +451,104 @@ static int frag_show(struct seq_file *m, void *arg)
> >  	return 0;
> >  }
> >  
> > +
> > +struct config_page_info {
> > +	unsigned long free_pages;
> > +	unsigned long free_blocks_total;
> > +	unsigned long free_blocks_suitable;
> > +};
> > +
> > +/*
> > + * Calculate the number of free pages in a zone, how many contiguous
> > + * pages are free and how many are large enough to satisfy an allocation of
> > + * the target size. Note that this function makes to attempt to estimate
> > + * how many suitable free blocks there *might* be if MOVABLE pages were
> > + * migrated. Calculating that is possible, but expensive and can be
> > + * figured out from userspace
> > + */
> > +static void fill_contig_page_info(struct zone *zone,
> > +				unsigned int suitable_order,
> > +				struct config_page_info *info)
> 
> There's a descrepency between the name of the function and the name of the 
> struct, I think they were probably both meant to be contig_page_info.
> 

Fixed

> > +{
> > +	unsigned int order;
> > +
> > +	info->free_pages = 0;
> > +	info->free_blocks_total = 0;
> > +	info->free_blocks_suitable = 0;
> > +
> > +	for (order = 0; order < MAX_ORDER; order++) {
> > +		unsigned long blocks;
> > +
> > +		/* Count number of free blocks */
> > +		blocks = zone->free_area[order].nr_free;
> > +		info->free_blocks_total += blocks;
> > +
> > +		/* Count free base pages */
> > +		info->free_pages += blocks << order;
> > +
> > +		/* Count the suitable free blocks */
> > +		if (order >= suitable_order)
> > +			info->free_blocks_suitable += blocks <<
> > +						(order - suitable_order);
> > +	}
> > +}
> > +
> > +/*
> > + * Return an index indicating how much of the available free memory is
> > + * unusable for an allocation of the requested size.
> > + */
> > +int unusable_free_index(struct zone *zone,
> > +				unsigned int order,
> > +				struct config_page_info *info)
> 
> Should be static?
> 

Fixed

> > +{
> > +	/* No free memory is interpreted as all free memory is unusable */
> > +	if (info->free_pages == 0)
> > +		return 100;
> > +
> > +	/*
> > +	 * Index should be a value between 0 and 1. Return a value to 3
> > +	 * decimal places.
> > +	 *
> > +	 * 0 => no fragmentation
> > +	 * 1 => high fragmentation
> > +	 */
> > +	return ((info->free_pages - (info->free_blocks_suitable << order)) * 1000) / info->free_pages;
> > +
> 
> This value is only for userspace consumption via /proc/pagetypeinfo, so 
> I'm wondering why it needs to be exported as an index.  Other than a loss 
> of precision, wouldn't this be easier to understand (especially when 
> coupled with the free page counts already exported) if it were multipled 
> by 100 rather than 1000 and shown as a percent of _usable_ free memory at 
> each order? 

I find it easier to understand either way, but that's hardly a surprise.
The 1000 is because of the loss of precision. I can make it a 100 but I
don't think it makes much of a difference.

> Otherwise, we're left doing this "free - unusuable" 
> calculation while the number of unusuable pages at an order isn't 
> necessarily of great interest as a vanilla value.
> 
> > +}
> > +
> > +static void pagetypeinfo_showunusable_print(struct seq_file *m,
> > +					pg_data_t *pgdat, struct zone *zone)
> > +{
> > +	unsigned int order;
> > +
> > +	/* Alloc on stack as interrupts are disabled for zone walk */
> > +	struct config_page_info info;
> > +
> > +	seq_printf(m, "Node %4d, zone %8s %19s",
> > +				pgdat->node_id,
> > +				zone->name, " ");
> > +	for (order = 0; order < MAX_ORDER; ++order) {
> > +		fill_contig_page_info(zone, order, &info);
> 
> It's a shame we can't keep this data for the fragmentation index exported 
> subsequently in patch 3.
> 

It could. When I did first, it made things messier and the patches less
clear-cut so I kept it simple as it wasn't performance-critical.

> > +		seq_printf(m, "%6d ", unusable_free_index(zone, order, &info));
> > +	}
> > +
> > +	seq_putc(m, '\n');
> > +}
> > +
> > +/*
> > + * Display unusable free space index
> > + * XXX: Could be a lot more efficient, but it's not a critical path
> > + */
> > +static int pagetypeinfo_showunusable(struct seq_file *m, void *arg)
> > +{
> > +	pg_data_t *pgdat = (pg_data_t *)arg;
> > +
> > +	seq_printf(m, "\nUnusable free space index at order\n");
> > +	walk_zones_in_node(m, pgdat, pagetypeinfo_showunusable_print);
> > +
> > +	return 0;
> > +}
> > +
> >  static void pagetypeinfo_showfree_print(struct seq_file *m,
> >  					pg_data_t *pgdat, struct zone *zone)
> >  {
> > @@ -558,6 +656,7 @@ static int pagetypeinfo_show(struct seq_file *m, void *arg)
> >  	seq_printf(m, "Pages per block:  %lu\n", pageblock_nr_pages);
> >  	seq_putc(m, '\n');
> >  	pagetypeinfo_showfree(m, pgdat);
> > +	pagetypeinfo_showunusable(m, pgdat);
> >  	pagetypeinfo_showblockcount(m, pgdat);
> >  
> >  	return 0;
> 
> /proc/pagetypeinfo isn't documented, but that's been fine until now 
> because all of the fields dealing with "free pages" and "number of blocks" 
> are easily understood.  That changes now because there is no clear 
> understanding of "fragmentation index" in userspace, so we'll probably 
> need some kind of memory compaction documentation eventually.
> 

Agreed.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
