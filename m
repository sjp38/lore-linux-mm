Date: Thu, 10 May 2007 13:46:45 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC] memory hotremove patch take 2 [01/10] (counter of removable
 page)
In-Reply-To: <20070509120132.B906.Y-GOTO@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0705101326190.1581@skynet.skynet.ie>
References: <20070509115506.B904.Y-GOTO@jp.fujitsu.com>
 <20070509120132.B906.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, 9 May 2007, Yasunori Goto wrote:

> Show #of Movable pages and vmstat.
>
> Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
>
> arch/ia64/mm/init.c    |    2 ++
> drivers/base/node.c    |    4 ++++
> fs/proc/proc_misc.c    |    4 ++++
> include/linux/kernel.h |    2 ++
> include/linux/swap.h   |    1 +
> mm/page_alloc.c        |   22 ++++++++++++++++++++++
> 6 files changed, 35 insertions(+)
>
> Index: current_test/mm/page_alloc.c
> ===================================================================
> --- current_test.orig/mm/page_alloc.c	2007-05-08 15:06:50.000000000 +0900
> +++ current_test/mm/page_alloc.c	2007-05-08 15:08:36.000000000 +0900
> @@ -58,6 +58,7 @@ unsigned long totalram_pages __read_most
> unsigned long totalreserve_pages __read_mostly;
> long nr_swap_pages;
> int percpu_pagelist_fraction;
> +unsigned long total_movable_pages __read_mostly;
>

Is it really necessary to have this as a separate value? It could be 
calculated at the same time as nr_free_movable_pages() seeing as that is 
called for meminfo anyway if the read was protected with 
zone_span_seqbegin()+zone_span_seqretry().

> static void __free_pages_ok(struct page *page, unsigned int order);
>
> @@ -1827,6 +1828,18 @@ static unsigned int nr_free_zone_pages(i
> 	return sum;
> }
>
> +unsigned int nr_free_movable_pages(void)
> +{
> +	unsigned long nr_pages = 0;
> +	struct zone *zone;
> +	int nid;
> +
> +	for_each_online_node(nid) {
> +		zone = &(NODE_DATA(nid)->node_zones[ZONE_MOVABLE]);
> +		nr_pages += zone_page_state(zone, NR_FREE_PAGES);
> +	}
> +	return nr_pages;
> +}
> /*
>  * Amount of free RAM allocatable within ZONE_DMA and ZONE_NORMAL
>  */
> @@ -1889,6 +1902,8 @@ void si_meminfo(struct sysinfo *val)
> 	val->totalhigh = totalhigh_pages;
> 	val->freehigh = nr_free_highpages();
> 	val->mem_unit = PAGE_SIZE;
> +	val->movable = total_movable_pages;
> +	val->free_movable = nr_free_movable_pages();
> }
>
> EXPORT_SYMBOL(si_meminfo);
> @@ -1908,6 +1923,11 @@ void si_meminfo_node(struct sysinfo *val
> 	val->totalhigh = 0;
> 	val->freehigh = 0;
> #endif
> +
> +	val->movable = pgdat->node_zones[ZONE_MOVABLE].present_pages;

I think this has to be protected with zone_span_seqbegin()

> +	val->free_movable = zone_page_state(&pgdat->node_zones[ZONE_MOVABLE],
> +				NR_FREE_PAGES);
> +
> 	val->mem_unit = PAGE_SIZE;
> }
> #endif
> @@ -3216,6 +3236,8 @@ static void __meminit free_area_init_cor
>
> 		zone->spanned_pages = size;
> 		zone->present_pages = realsize;
> +		if (j == ZONE_MOVABLE)
> +			total_movable_pages += realsize;

If total_movable_pages is calculated at the same time as free pages, 
this could go away. Similar for online_page() later

> #ifdef CONFIG_NUMA
> 		zone->node = nid;
> 		zone->min_unmapped_pages = (realsize*sysctl_min_unmapped_ratio)
> Index: current_test/include/linux/kernel.h
> ===================================================================
> --- current_test.orig/include/linux/kernel.h	2007-05-08 15:06:49.000000000 +0900
> +++ current_test/include/linux/kernel.h	2007-05-08 15:07:20.000000000 +0900
> @@ -352,6 +352,8 @@ struct sysinfo {
> 	unsigned short pad;		/* explicit padding for m68k */
> 	unsigned long totalhigh;	/* Total high memory size */
> 	unsigned long freehigh;		/* Available high memory size */
> +	unsigned long movable;		/* pages used only for data */
> +	unsigned long free_movable;	/* Avaiable pages in movable */
> 	unsigned int mem_unit;		/* Memory unit size in bytes */
> 	char _f[20-2*sizeof(long)-sizeof(int)];	/* Padding: libc5 uses this.. */
> };
> Index: current_test/fs/proc/proc_misc.c
> ===================================================================
> --- current_test.orig/fs/proc/proc_misc.c	2007-05-08 15:06:48.000000000 +0900
> +++ current_test/fs/proc/proc_misc.c	2007-05-08 15:07:20.000000000 +0900
> @@ -161,6 +161,8 @@ static int meminfo_read_proc(char *page,
> 		"LowTotal:     %8lu kB\n"
> 		"LowFree:      %8lu kB\n"
> #endif
> +		"MovableTotal: %8lu kB\n"
> +		"MovableFree:  %8lu kB\n"
> 		"SwapTotal:    %8lu kB\n"
> 		"SwapFree:     %8lu kB\n"
> 		"Dirty:        %8lu kB\n"
> @@ -191,6 +193,8 @@ static int meminfo_read_proc(char *page,
> 		K(i.totalram-i.totalhigh),
> 		K(i.freeram-i.freehigh),
> #endif
> +		K(i.movable),
> +		K(i.free_movable),
> 		K(i.totalswap),
> 		K(i.freeswap),
> 		K(global_page_state(NR_FILE_DIRTY)),
> Index: current_test/drivers/base/node.c
> ===================================================================
> --- current_test.orig/drivers/base/node.c	2007-05-08 15:06:10.000000000 +0900
> +++ current_test/drivers/base/node.c	2007-05-08 15:07:20.000000000 +0900
> @@ -55,6 +55,8 @@ static ssize_t node_read_meminfo(struct
> 		       "Node %d LowTotal:     %8lu kB\n"
> 		       "Node %d LowFree:      %8lu kB\n"
> #endif
> +		       "Node %d MovableTotal: %8lu kB\n"
> +		       "Node %d MovableFree:  %8lu kB\n"
> 		       "Node %d Dirty:        %8lu kB\n"
> 		       "Node %d Writeback:    %8lu kB\n"
> 		       "Node %d FilePages:    %8lu kB\n"
> @@ -77,6 +79,8 @@ static ssize_t node_read_meminfo(struct
> 		       nid, K(i.totalram - i.totalhigh),
> 		       nid, K(i.freeram - i.freehigh),
> #endif
> +		       nid, K(i.movable),
> +		       nid, K(i.free_movable),
> 		       nid, K(node_page_state(nid, NR_FILE_DIRTY)),
> 		       nid, K(node_page_state(nid, NR_WRITEBACK)),
> 		       nid, K(node_page_state(nid, NR_FILE_PAGES)),
> Index: current_test/arch/ia64/mm/init.c
> ===================================================================
> --- current_test.orig/arch/ia64/mm/init.c	2007-05-08 15:06:38.000000000 +0900
> +++ current_test/arch/ia64/mm/init.c	2007-05-08 15:08:29.000000000 +0900
> @@ -700,6 +700,8 @@ void online_page(struct page *page)
> 	__free_page(page);
> 	totalram_pages++;
> 	num_physpages++;
> +	if (page_zonenum(page) == ZONE_MOVABLE)
> +		total_movable_pages++;
> }
>
> int arch_add_memory(int nid, u64 start, u64 size)
> Index: current_test/include/linux/swap.h
> ===================================================================
> --- current_test.orig/include/linux/swap.h	2007-05-08 15:06:49.000000000 +0900
> +++ current_test/include/linux/swap.h	2007-05-08 15:07:20.000000000 +0900
> @@ -169,6 +169,7 @@ extern void swapin_readahead(swp_entry_t
> /* linux/mm/page_alloc.c */
> extern unsigned long totalram_pages;
> extern unsigned long totalreserve_pages;
> +extern unsigned long total_movable_pages;

If total_movable_pages was calculated on the fly, this extern could also 
go away because online_page() would not need it any more.

> extern long nr_swap_pages;
> extern unsigned int nr_free_buffer_pages(void);
> extern unsigned int nr_free_pagecache_pages(void);
>
> -- 
> Yasunori Goto
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
