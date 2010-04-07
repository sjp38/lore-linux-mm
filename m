Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 27BAC6B01EE
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 06:35:29 -0400 (EDT)
Date: Wed, 7 Apr 2010 11:35:07 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 05/14] Export unusable free space index via
	/proc/unusable_index
Message-ID: <20100407103506.GO17882@csn.ul.ie>
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie> <1270224168-14775-6-git-send-email-mel@csn.ul.ie> <20100406170537.c84f54b7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100406170537.c84f54b7.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 06, 2010 at 05:05:37PM -0700, Andrew Morton wrote:
> On Fri,  2 Apr 2010 17:02:39 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > Unusable free space index is a measure of external fragmentation that
> > takes the allocation size into account. For the most part, the huge page
> > size will be the size of interest but not necessarily so it is exported
> > on a per-order and per-zone basis via /proc/unusable_index.
> 
> I'd suggest /proc/sys/vm/unusable_index.  I don't know how pagetypeinfo
> found its way into the top-level dir.
> 

For the same reason buddyinfo did - no one complained. It keeps the
fragmentation-related information in the same place but I can move it.

> > The index is a value between 0 and 1. It can be expressed as a
> > percentage by multiplying by 100 as documented in
> > Documentation/filesystems/proc.txt.
> > 
> > ...
> > 
> > +> cat /proc/unusable_index
> > +Node 0, zone      DMA 0.000 0.000 0.000 0.001 0.005 0.013 0.021 0.037 0.037 0.101 0.230
> > +Node 0, zone   Normal 0.000 0.000 0.000 0.001 0.002 0.002 0.005 0.015 0.028 0.028 0.054
> > +
> > +The unusable free space index measures how much of the available free
> > +memory cannot be used to satisfy an allocation of a given size and is a
> > +value between 0 and 1. The higher the value, the more of free memory is
> > +unusable and by implication, the worse the external fragmentation is. This
> > +can be expressed as a percentage by multiplying by 100.
> 
> That's going to hurt my brain.  Why didn't it report usable free blocks?
> 

Lets say you are graphing the index on a given order over time. If there
are a large number of frees, there can be a large change in that value
but it does nto necessarily tell you how much better or worse the system
is overall.

> Also, the index is scaled by the actual amount of free memory in the
> zones, yes?  So to work out how many order-N pages are available you
> first need to know how many free pages there are?
> 

It depends on what your question is. As I'm interest in fragmentation,
this value gives me information on that. Your question is about how many
pages of a given order can be allocated right now and that can be worked
out from buddyinfo.

> Seems complicated.
> 
> >  
> > +
> > +struct contig_page_info {
> > +	unsigned long free_pages;
> > +	unsigned long free_blocks_total;
> > +	unsigned long free_blocks_suitable;
> > +};
> > +
> > +/*
> > + * Calculate the number of free pages in a zone, how many contiguous
> > + * pages are free and how many are large enough to satisfy an allocation of
> > + * the target size. Note that this function makes no attempt to estimate
> > + * how many suitable free blocks there *might* be if MOVABLE pages were
> > + * migrated. Calculating that is possible, but expensive and can be
> > + * figured out from userspace
> > + */
> > +static void fill_contig_page_info(struct zone *zone,
> > +				unsigned int suitable_order,
> > +				struct contig_page_info *info)
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
> > +static int unusable_free_index(unsigned int order,
> > +				struct contig_page_info *info)
> > +{
> > +	/* No free memory is interpreted as all free memory is unusable */
> > +	if (info->free_pages == 0)
> > +		return 1000;
> > +
> > +	/*
> > +	 * Index should be a value between 0 and 1. Return a value to 3
> > +	 * decimal places.
> > +	 *
> > +	 * 0 => no fragmentation
> > +	 * 1 => high fragmentation
> > +	 */
> > +	return div_u64((info->free_pages - (info->free_blocks_suitable << order)) * 1000ULL, info->free_pages);
> > +
> > +}
> > +
> > +static void unusable_show_print(struct seq_file *m,
> > +					pg_data_t *pgdat, struct zone *zone)
> > +{
> > +	unsigned int order;
> > +	int index;
> > +	struct contig_page_info info;
> > +
> > +	seq_printf(m, "Node %d, zone %8s ",
> > +				pgdat->node_id,
> > +				zone->name);
> > +	for (order = 0; order < MAX_ORDER; ++order) {
> > +		fill_contig_page_info(zone, order, &info);
> > +		index = unusable_free_index(order, &info);
> > +		seq_printf(m, "%d.%03d ", index / 1000, index % 1000);
> > +	}
> > +
> > +	seq_putc(m, '\n');
> > +}
> > +
> > +/*
> > + * Display unusable free space index
> > + * XXX: Could be a lot more efficient, but it's not a critical path
> > + */
> > +static int unusable_show(struct seq_file *m, void *arg)
> > +{
> > +	pg_data_t *pgdat = (pg_data_t *)arg;
> > +
> > +	/* check memoryless node */
> > +	if (!node_state(pgdat->node_id, N_HIGH_MEMORY))
> > +		return 0;
> > +
> > +	walk_zones_in_node(m, pgdat, unusable_show_print);
> > +
> > +	return 0;
> > +}
> > +
> >  static void pagetypeinfo_showfree_print(struct seq_file *m,
> >  					pg_data_t *pgdat, struct zone *zone)
> >  {
> > @@ -603,6 +703,25 @@ static const struct file_operations pagetypeinfo_file_ops = {
> >  	.release	= seq_release,
> >  };
> >  
> > +static const struct seq_operations unusable_op = {
> > +	.start	= frag_start,
> > +	.next	= frag_next,
> > +	.stop	= frag_stop,
> > +	.show	= unusable_show,
> > +};
> > +
> > +static int unusable_open(struct inode *inode, struct file *file)
> > +{
> > +	return seq_open(file, &unusable_op);
> > +}
> > +
> > +static const struct file_operations unusable_file_ops = {
> > +	.open		= unusable_open,
> > +	.read		= seq_read,
> > +	.llseek		= seq_lseek,
> > +	.release	= seq_release,
> > +};
> > +
> >  #ifdef CONFIG_ZONE_DMA
> >  #define TEXT_FOR_DMA(xx) xx "_dma",
> >  #else
> > @@ -947,6 +1066,7 @@ static int __init setup_vmstat(void)
> >  #ifdef CONFIG_PROC_FS
> >  	proc_create("buddyinfo", S_IRUGO, NULL, &fragmentation_file_operations);
> >  	proc_create("pagetypeinfo", S_IRUGO, NULL, &pagetypeinfo_file_ops);
> > +	proc_create("unusable_index", S_IRUGO, NULL, &unusable_file_ops);
> >  	proc_create("vmstat", S_IRUGO, NULL, &proc_vmstat_file_operations);
> >  	proc_create("zoneinfo", S_IRUGO, NULL, &proc_zoneinfo_file_operations);
> >  #endif
> 
> All this code will be bloat for most people, I suspect.  Can we find a
> suitable #ifdef wrapper to keep my cellphone happy?
> 

It could. However, this information can also be created from buddyinfo and
I have a perl script that can be adapted to duplicate the output of this
proc file. As there isn't an in-kernel user of this information, it can
also be dropped.

Will I roll a patch that moves the proc entry and makes it a CONFIG option
or will I just remove the file altogether? If I remove it, I can adapt
the perl script and add to the other hugepage-related utilities in
libhugetlbfs.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
