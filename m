Date: Wed, 7 Mar 2007 10:51:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC} memory unplug patchset prep [4/16] ZONE_MOVABLE
Message-Id: <20070307105116.19e9e230.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0703060024440.21900@chino.kir.corp.google.com>
References: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
	<20070306134549.174cc160.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0703060024440.21900@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, mel@skynet.ie, clameter@engr.sgi.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Mar 2007 08:06:33 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> > +static inline int is_movable_dix(enum zone_type idx)
> > +{
> > +	return (idx == ZONE_MOVABLE);
> > +}
> > +
> 
> Should be is_movable_idx() maybe?  I assume this function is here for 
> completeness since it's never referenced in the patchset.
> 
yes.. this is never called. I may drop this function.

> > Index: devel-tree-2.6.20-mm2/mm/page_alloc.c
> > ===================================================================
> > --- devel-tree-2.6.20-mm2.orig/mm/page_alloc.c
> > +++ devel-tree-2.6.20-mm2/mm/page_alloc.c
> > @@ -82,6 +82,7 @@ static char name_dma[] = "DMA";
> >  static char name_dma32[] = "DMA32";
> >  static char name_normal[] = "Normal";
> >  static char name_highmem[] = "Highmem";
> > +static char name_movable[] = "Movable";
> >  
> >  static inline void __meminit zone_variables_init(void)
> >  {
> > @@ -91,6 +92,7 @@ static inline void __meminit zone_variab
> >  	zone_names[ZONE_DMA32] = name_dma32;
> >  	zone_names[ZONE_NORMAL] = name_normal;
> >  	zone_names[ZONE_HIGHMEM] = name_highmem;
> > +	zone_names[ZONE_MOVABLE] = name_movable;
> >  
> >  	/* ZONE below NORAML has ratio 256 */
> >  	if (is_configured_zone(ZONE_DMA))
> > @@ -99,6 +101,8 @@ static inline void __meminit zone_variab
> >  		sysctl_lowmem_reserve_ratio[ZONE_DMA32] = 256;
> >  	if (is_configured_zone(ZONE_HIGHMEM))
> >  		sysctl_lowmem_reserve_ratio[ZONE_HIGHMEM] = 32;
> > +	if (is_configured_zone(ZONE_MOVABLE))
> > +		sysctl_lowmem_reserve_ratio[ZONE_MOVABLE] = 32;
> >  }
> >  
> >  int min_free_kbytes = 1024;
> > @@ -3065,11 +3069,17 @@ void __init free_area_init_nodes(unsigne
> >  	arch_zone_lowest_possible_pfn[0] = find_min_pfn_with_active_regions();
> >  	arch_zone_highest_possible_pfn[0] = max_zone_pfn[0];
> >  	for (i = 1; i < MAX_NR_ZONES; i++) {
> > +		if (i == ZONE_MOVABLE)
> > +			continue;
> >  		arch_zone_lowest_possible_pfn[i] =
> >  			arch_zone_highest_possible_pfn[i-1];
> >  		arch_zone_highest_possible_pfn[i] =
> >  			max(max_zone_pfn[i], arch_zone_lowest_possible_pfn[i]);
> >  	}
> > +	if (is_configured_zone(ZONE_MOVABLE)) {
> > +		arch_zone_lowest_possible_pfn[ZONE_MOVABLE] = 0;
> > +		arch_zone_highest_possible_pfn[ZONE_MOVABLE] = 0;
> > +	}
> >  
> >  	/* Print out the page size for debugging meminit problems */
> >  	printk(KERN_DEBUG "sizeof(struct page) = %zd\n", sizeof(struct page));
> 
> Aren't the arch_zone_{lowest|highest}_possible_pfn's for ZONE_MOVABLE 
> already at 0?  If not, it should definitely be memset early on to avoid 
> any possible assignment mistakes amongst all these conditionals.
> 
ok.


> > Index: devel-tree-2.6.20-mm2/mm/Kconfig
> > ===================================================================
> > --- devel-tree-2.6.20-mm2.orig/mm/Kconfig
> > +++ devel-tree-2.6.20-mm2/mm/Kconfig
> > @@ -163,6 +163,10 @@ config ZONE_DMA_FLAG
> >  	default "0" if !ZONE_DMA
> >  	default "1"
> >  
> > +config ZONE_MOVABLE
> > +	bool "Create zones for MOVABLE pages"
> > +	depends on ARCH_POPULATES_NODE_MAP
> > +	depends on MIGRATION
> >  #
> >  # Adaptive file readahead
> >  #
> > 
> 
> This patchset is heavily dependent on Mel Gorman's work with ZONE_MOVABLE 
> so perhaps it would be better to base it off of the latest -mm with his 
> patchset applied?  And if CONFIG_ZONE_MOVABLE wasn't documented in Kconfig 
> prior to this, it might be a good opportunity to do so if you're going to 
> get community adoption.
> 
I'm very glad to see the latest -mm including Mel's.
And yes. I'll use his patch set. 

-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
