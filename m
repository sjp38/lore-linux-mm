Date: Wed, 7 Mar 2007 10:21:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC} memory unplug patchset prep [1/16] zone ids cleanup
Message-Id: <20070307102146.d22b524d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0703052320140.21484@chino.kir.corp.google.com>
References: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
	<20070306134232.bb024956.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0703052320140.21484@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, mel@skynet.ie, clameter@engr.sgi.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Mar 2007 07:36:30 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> >  static inline int is_highmem_idx(enum zone_type idx)
> >  {
> > -#ifdef CONFIG_HIGHMEM
> >  	return (idx == ZONE_HIGHMEM);
> > -#else
> > -	return 0;
> > -#endif
> >  }
> >  
> 
> Doesn't this need a check for is_configured_zone(idx) as well since this 
> will return 1 if we pass in idx == ZONE_HIGHMEM even though it's above 
> MAX_NR_ZONES?
Hmm, I'll add
==
BUG_ON(idx >= MAX_NR_ZONES)
==
here.

> 
> >  static inline int is_normal_idx(enum zone_type idx)
> > @@ -520,11 +531,7 @@ static inline int is_normal_idx(enum zon
> >   */
> >  static inline int is_highmem(struct zone *zone)
> >  {
> > -#ifdef CONFIG_HIGHMEM
> >  	return zone == zone->zone_pgdat->node_zones + ZONE_HIGHMEM;
> > -#else
> > -	return 0;
> > -#endif
> >  }
> >  
> 
> The only call site for this after your patchset is applied is in i386 code 
> which you can probably remove with the identity idx.
Ok, look into.


> 
> >  static inline int is_normal(struct zone *zone)
> > @@ -534,20 +541,12 @@ static inline int is_normal(struct zone 
> >  
> >  static inline int is_dma32(struct zone *zone)
> >  {
> > -#ifdef CONFIG_ZONE_DMA32
> >  	return zone == zone->zone_pgdat->node_zones + ZONE_DMA32;
> > -#else
> > -	return 0;
> > -#endif
> >  }
> >  
> >  static inline int is_dma(struct zone *zone)
> >  {
> > -#ifdef CONFIG_ZONE_DMA
> >  	return zone == zone->zone_pgdat->node_zones + ZONE_DMA;
> > -#else
> > -	return 0;
> > -#endif
> >  }
> >  
> 
> Neither is_dma32() nor is_dma() are even used anymore.

I see. maybe removing entire call patch should be applied before this.

> 
> >  /* These two functions are used to setup the per zone pages min values */
> > Index: devel-tree-2.6.20-mm2/mm/page_alloc.c
> > ===================================================================
> > --- devel-tree-2.6.20-mm2.orig/mm/page_alloc.c
> > +++ devel-tree-2.6.20-mm2/mm/page_alloc.c
> > @@ -72,32 +72,34 @@ static void __free_pages_ok(struct page 
> >   * TBD: should special case ZONE_DMA32 machines here - in those we normally
> >   * don't need any ZONE_NORMAL reservation
> >   */
> > -int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1] = {
> > -#ifdef CONFIG_ZONE_DMA
> > -	 256,
> > -#endif
> > -#ifdef CONFIG_ZONE_DMA32
> > -	 256,
> > -#endif
> > -#ifdef CONFIG_HIGHMEM
> > -	 32
> > -#endif
> > -};
> > +int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1];
> >  
> 
> Probably an easier way to initialize these instead of 
> zone_variables_init() is like this:
> 
> 	int sysctl_lowmem_reserve_ratio[MAX_POSSIBLE_ZONES-1] = {
> 		[ZONE_DMA]	= 256,
> 		[ZONE_DMA32]	= 256,
> 		[ZONE_HIGHMEM]	= 32 };
> 

AH, I didn't know this initialization method. thanks. will try.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
