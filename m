Date: Wed, 7 Mar 2007 10:48:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC} memory unplug patchset prep [3/16] define
 is_identity_mapped
Message-Id: <20070307104824.350d1f93.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0703060021320.21900@chino.kir.corp.google.com>
References: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
	<20070306134438.4ba6c561.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0703060021320.21900@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, mel@skynet.ie, clameter@engr.sgi.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Mar 2007 07:55:54 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 6 Mar 2007, KAMEZAWA Hiroyuki wrote:
> 
> > Index: devel-tree-2.6.20-mm2/include/linux/mmzone.h
> > ===================================================================
> > --- devel-tree-2.6.20-mm2.orig/include/linux/mmzone.h
> > +++ devel-tree-2.6.20-mm2/include/linux/mmzone.h
> > @@ -523,6 +523,13 @@ static inline int is_normal_idx(enum zon
> >  	return (idx == ZONE_NORMAL);
> >  }
> >  
> > +static inline int is_identity_map_idx(enum zone_type idx)
> > +{
> > +	if (is_configured_zone(ZONE_HIGHMEM))
> > +		return (idx < ZONE_HIGHMEM);
> > +	else
> > +		return 1;
> > +}
> >  /**
> >   * is_highmem - helper function to quickly check if a struct zone is a 
> >   *              highmem zone or not.  This is an attempt to keep references
> > @@ -549,6 +556,14 @@ static inline int is_dma(struct zone *zo
> >  	return zone == zone->zone_pgdat->node_zones + ZONE_DMA;
> >  }
> >  
> > +static inline int is_identity_map(struct zone *zone)
> > +{
> > +	if (is_configured_zone(ZONE_HIGHMEM)
> > +		return zone_idx(zone) < ZONE_HIGHMEM;
> > +	else
> > +		return 1;
> > +}
> > +
> 
> is_identity_map() isn't specific to any particular architecture nor is it 
> dependent on a configuration option.  Since there's a missing ) in its 
> conditional, I'm wondering how this entire patch was ever tested.
> 
I tested and my tree looks fine...maybe this is patch refresh miss...sorry.


> > Index: devel-tree-2.6.20-mm2/include/linux/page-flags.h
> > ===================================================================
> > --- devel-tree-2.6.20-mm2.orig/include/linux/page-flags.h
> > +++ devel-tree-2.6.20-mm2/include/linux/page-flags.h
> > @@ -162,7 +162,7 @@ static inline void SetPageUptodate(struc
> >  #define __ClearPageSlab(page)	__clear_bit(PG_slab, &(page)->flags)
> >  
> >  #ifdef CONFIG_HIGHMEM
> > -#define PageHighMem(page)	is_highmem(page_zone(page))
> > +#define PageHighMem(page)	(!is_identitiy_map(page_zone(page)))
> >  #else
> >  #define PageHighMem(page)	0 /* needed to optimize away at compile time */
> >  #endif
> 
> I assume this should be defined to !is_identity_map(page_zone(page)).
> 
ok.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
