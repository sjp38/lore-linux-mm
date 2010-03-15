Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 71FB36B01B7
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 05:48:43 -0400 (EDT)
Date: Mon, 15 Mar 2010 09:48:22 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 05/11] Export unusable free space index via
	/proc/unusable_index
Message-ID: <20100315094822.GH18274@csn.ul.ie>
References: <1268412087-13536-1-git-send-email-mel@csn.ul.ie> <1268412087-13536-6-git-send-email-mel@csn.ul.ie> <20100315144124.ba503bfe.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100315144124.ba503bfe.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 15, 2010 at 02:41:24PM +0900, KAMEZAWA Hiroyuki wrote:
> On Fri, 12 Mar 2010 16:41:21 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > Unusable free space index is a measure of external fragmentation that
> > takes the allocation size into account. For the most part, the huge page
> > size will be the size of interest but not necessarily so it is exported
> > on a per-order and per-zone basis via /proc/unusable_index.
> > 
> > The index is a value between 0 and 1. It can be expressed as a
> > percentage by multiplying by 100 as documented in
> > Documentation/filesystems/proc.txt.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> > Acked-by: Rik van Riel <riel@redhat.com>
> > ---
> >  Documentation/filesystems/proc.txt |   13 ++++-
> >  mm/vmstat.c                        |  120 ++++++++++++++++++++++++++++++++++++
> >  2 files changed, 132 insertions(+), 1 deletions(-)
> > 
> > diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> > index 5e132b5..5c4b0fb 100644
> > --- a/Documentation/filesystems/proc.txt
> > +++ b/Documentation/filesystems/proc.txt
> > @@ -452,6 +452,7 @@ Table 1-5: Kernel info in /proc
> >   sys         See chapter 2                                     
> >   sysvipc     Info of SysVIPC Resources (msg, sem, shm)		(2.4)
> >   tty	     Info of tty drivers
> > + unusable_index Additional page allocator information (see text)(2.5)
> >   uptime      System uptime                                     
> >   version     Kernel version                                    
> >   video	     bttv info of video resources			(2.4)
> > @@ -609,7 +610,7 @@ ZONE_DMA, 4 chunks of 2^1*PAGE_SIZE in ZONE_DMA, 101 chunks of 2^4*PAGE_SIZE
> >  available in ZONE_NORMAL, etc... 
> >  
> >  More information relevant to external fragmentation can be found in
> > -pagetypeinfo.
> > +pagetypeinfo and unusable_index
> >  
> >  > cat /proc/pagetypeinfo
> >  Page block order: 9
> > @@ -650,6 +651,16 @@ unless memory has been mlock()'d. Some of the Reclaimable blocks should
> >  also be allocatable although a lot of filesystem metadata may have to be
> >  reclaimed to achieve this.
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
> > +
> 
> I'm sorry but how this information is different from buddyinfo ?
> 

This information can be calculated from buddyinfo by hand or by scripts if
necessary. The difference is in how the information is presented.  It's far
easier to see at a glance the potential fragmentation at each order with this
file than with buddyinfo. I use this information in fragmentation-tests to
graph the index over time but I also have the necessary scripts to parse
buddyinfo so it's not a big deal for me.

I can drop this patch if necessary because none of the core code uses
it. It was for the convenience of a user.

> Thanks,
> -Kame
> 
> 
> 
> >  ..............................................................................
> >  
> >  meminfo:
> > diff --git a/mm/vmstat.c b/mm/vmstat.c
> > index 7f760cb..ca42e10 100644
> > --- a/mm/vmstat.c
> > +++ b/mm/vmstat.c
> > @@ -453,6 +453,106 @@ static int frag_show(struct seq_file *m, void *arg)
> >  	return 0;
> >  }
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
> > + * the target size. Note that this function makes to attempt to estimate
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
> > +	return ((info->free_pages - (info->free_blocks_suitable << order)) * 1000) / info->free_pages;
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
> > -- 
> > 1.6.5
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> > 
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
