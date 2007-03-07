Date: Wed, 7 Mar 2007 10:55:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC} memory unplug patchset prep [8/16] counter for
 ZONE_MOVABLE
Message-Id: <20070307105528.541e134e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0703060029510.21900@chino.kir.corp.google.com>
References: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
	<20070306135058.5ce2ab9d.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0703060029510.21900@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, mel@skynet.ie, clameter@engr.sgi.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Mar 2007 08:11:22 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 6 Mar 2007, KAMEZAWA Hiroyuki wrote:
> 
> > Index: devel-tree-2.6.20-mm2/mm/page_alloc.c
> > ===================================================================
> > --- devel-tree-2.6.20-mm2.orig/mm/page_alloc.c
> > +++ devel-tree-2.6.20-mm2/mm/page_alloc.c
> > @@ -58,6 +58,7 @@ unsigned long totalram_pages __read_most
> >  unsigned long totalreserve_pages __read_mostly;
> >  long nr_swap_pages;
> >  int percpu_pagelist_fraction;
> > +unsigned long total_movable_pages __read_mostly;
> >  
> >  static void __free_pages_ok(struct page *page, unsigned int order);
> >  
> > @@ -1571,6 +1572,20 @@ static unsigned int nr_free_zone_pages(i
> >  	return sum;
> >  }
> >  
> > +unsigned int nr_free_movable_pages(void)
> > +{
> > +	unsigned long nr_pages = 0;
> > +	struct zone *zone;
> > +	int nid;
> > +	if (is_configured_zone(ZONE_MOVABLE)) {
> > +		/* we want to count *only* pages in movable zone */
> > +		for_each_online_node(nid) {
> > +			zone = &(NODE_DATA(nid)->node_zones[ZONE_MOVABLE]);
> > +			nr_pages += zone_page_state(zone, NR_FREE_PAGES);
> > +		}
> > +	}
> > +	return nr_pages;
> > +}
> >  /*
> >   * Amount of free RAM allocatable within ZONE_DMA and ZONE_NORMAL
> >   */
> 
> On each online node, zone should be
> 
> 	zone = NODE_DATA(nid)->node_sizes + ZONE_MOVABLE;
> 
> Also, you should probably only declare this function on #ifdef 
> CONFIG_ZONE_MOVABLE and #define it to "do {} while(0)" otherwise.
> 
is_configure_zone() does enough work. (But I'll move to the latest -mm.)



> > @@ -1584,7 +1599,7 @@ unsigned int nr_free_buffer_pages(void)
> >   */
> >  unsigned int nr_free_pagecache_pages(void)
> >  {
> > -	return nr_free_zone_pages(gfp_zone(GFP_HIGHUSER));
> > +	return nr_free_zone_pages(gfp_zone(GFP_HIGH_MOVABLE));
> >  }
> >  
> >  /*
> > @@ -1633,6 +1648,8 @@ void si_meminfo(struct sysinfo *val)
> >  	val->totalhigh = totalhigh_pages;
> >  	val->freehigh = nr_free_highpages();
> >  	val->mem_unit = PAGE_SIZE;
> > +	val->movable = total_movable_pages;
> > +	val->free_movable = nr_free_movable_pages();
> >  }
> >  
> >  EXPORT_SYMBOL(si_meminfo);
> > @@ -1654,6 +1671,13 @@ void si_meminfo_node(struct sysinfo *val
> >  		val->totalhigh = 0;
> >  		val->freehigh = 0;
> >  	}
> > +	if (is_configured_zone(ZONE_MOVABLE)) {
> > +		val->movable +=
> > +			pgdat->node_zones[ZONE_MOVABLE].present_pages;
> > +		val->free_movable +=
> > +			zone_page_state(&pgdat->node_zones[ZONE_MOVABLE],
> > +				NR_FREE_PAGES);
> > +	}
> >  	val->mem_unit = PAGE_SIZE;
> >  }
> >  #endif
> 
> Don't you want assignments here instead of accumulations?  val->movable 
> and val->free_movable probably shouldn't be the only members in 
> si_meminfo_node() that accumulate.
> 
> Your first patch in this patchset actually sets val->totalhigh and 
> val->freehigh both to 0 in the !is_configured_zone(ZONE_HIGHMEM) case.  Do 
> these need the same assignments for movable and free_movable in the 
> !is_configured_zone(ZONE_MOVABLE) case?
> 
> > Index: devel-tree-2.6.20-mm2/include/linux/kernel.h
> > ===================================================================
> > --- devel-tree-2.6.20-mm2.orig/include/linux/kernel.h
> > +++ devel-tree-2.6.20-mm2/include/linux/kernel.h
> > @@ -329,6 +329,8 @@ struct sysinfo {
> >  	unsigned short pad;		/* explicit padding for m68k */
> >  	unsigned long totalhigh;	/* Total high memory size */
> >  	unsigned long freehigh;		/* Available high memory size */
> > +	unsigned long movable;		/* pages used only for data */
> > +	unsigned long free_movable;	/* Avaiable pages in movable */
> >  	unsigned int mem_unit;		/* Memory unit size in bytes */
> >  	char _f[20-2*sizeof(long)-sizeof(int)];	/* Padding: libc5 uses this.. */
> >  };
> 
> Please add #ifdef's to CONFIG_ZONE_MOVABLE around these members in struct 
> sysinfo so we incur no penalty if we choose not to enable this option.
> 
I just do this becasue highmem is not covered by CONFIG_HIGHMEM.

> > Index: devel-tree-2.6.20-mm2/mm/vmstat.c
> > ===================================================================
> > --- devel-tree-2.6.20-mm2.orig/mm/vmstat.c
> > +++ devel-tree-2.6.20-mm2/mm/vmstat.c
> > @@ -426,8 +426,14 @@ const struct seq_operations fragmentatio
> >  #define TEXT_FOR_HIGHMEM(xx)
> >  #endif
> >  
> > +#ifdef CONFIG_ZONE_MOVABLE
> > +#define TEXT_FOR_MOVABLE(xx) xx "_movable",
> > +#else
> > +#define TXT_FOR_MOVABLE(xx)
> > +#endif
> > +
> >  #define TEXTS_FOR_ZONES(xx) TEXT_FOR_DMA(xx) TEXT_FOR_DMA32(xx) xx "_normal", \
> > -					TEXT_FOR_HIGHMEM(xx)
> > +					TEXT_FOR_HIGHMEM(xx) TEXT_FOR_MOVABLE(xx)
> >  
> >  static const char * const vmstat_text[] = {
> >  	/* Zoned VM counters */
> > 
> 
> This broke my build because TEXT_FOR_MOVABLE() is misspelled on 
> !CONFIG_ZONE_MOVABLE.
> 
Ah.. sigh. ok. I'll do better test in the next time.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
