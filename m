Date: Mon, 28 Apr 2008 09:39:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] Fix usemap initialization v3
Message-Id: <20080428093917.ea6f2647.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080427121817.03b432ca.akpm@linux-foundation.org>
References: <20080418161522.GB9147@csn.ul.ie>
	<48080706.50305@cn.fujitsu.com>
	<48080930.5090905@cn.fujitsu.com>
	<48080B86.7040200@cn.fujitsu.com>
	<20080418211214.299f91cd.kamezawa.hiroyu@jp.fujitsu.com>
	<21878461.1208539556838.kamezawa.hiroyu@jp.fujitsu.com>
	<20080421112048.78f0ec76.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0804211250000.16476@blonde.site>
	<20080422104043.215c7dc4.kamezawa.hiroyu@jp.fujitsu.com>
	<20080423134621.6020dd83.kamezawa.hiroyu@jp.fujitsu.com>
	<20080427121817.03b432ca.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, Mel Gorman <mel@csn.ul.ie>, Shi Weihua <shiwh@cn.fujitsu.com>, balbir@linux.vnet.ibm.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 27 Apr 2008 12:18:17 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > ---
> >  mm/page_alloc.c |   14 ++++++++++++--
> >  1 file changed, 12 insertions(+), 2 deletions(-)
> > 
> > Index: linux-2.6.25/mm/page_alloc.c
> > ===================================================================
> > --- linux-2.6.25.orig/mm/page_alloc.c
> > +++ linux-2.6.25/mm/page_alloc.c
> > @@ -2518,7 +2518,9 @@ void __meminit memmap_init_zone(unsigned
> >  	struct page *page;
> >  	unsigned long end_pfn = start_pfn + size;
> >  	unsigned long pfn;
> > +	struct zone *z;
> >  
> > +	z = &NODE_DATA(nid)->node_zones[zone];
> >  	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
> >  		/*
> >  		 * There can be holes in boot-time mem_map[]s
> > @@ -2536,7 +2538,6 @@ void __meminit memmap_init_zone(unsigned
> >  		init_page_count(page);
> >  		reset_page_mapcount(page);
> >  		SetPageReserved(page);
> > -
> >  		/*
> >  		 * Mark the block movable so that blocks are reserved for
> >  		 * movable at startup. This will force kernel allocations
> > @@ -2545,8 +2546,15 @@ void __meminit memmap_init_zone(unsigned
> >  		 * kernel allocations are made. Later some blocks near
> >  		 * the start are marked MIGRATE_RESERVE by
> >  		 * setup_zone_migrate_reserve()
> > +		 *
> > +		 * bitmap is created for zone's valid pfn range. but memmap
> > +		 * can be created for invalid pages (for alignment)
> > +		 * check here not to call set_pageblock_migratetype() against
> > +		 * pfn out of zone.
> >  		 */
> > -		if ((pfn & (pageblock_nr_pages-1)))
> > +		if ((z->zone_start_pfn <= pfn)
> > +		    && (pfn < z->zone_start_pfn + z->spanned_pages)
> > +		    && !(pfn & (pageblock_nr_pages - 1)))
> >  			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
> >  
> >  		INIT_LIST_HEAD(&page->lru);
> > @@ -4460,6 +4468,8 @@ void set_pageblock_flags_group(struct pa
> >  	pfn = page_to_pfn(page);
> >  	bitmap = get_pageblock_bitmap(zone, pfn);
> >  	bitidx = pfn_to_bitidx(zone, pfn);
> > +	VM_BUG_ON(pfn < zone->zone_start_pfn);
> > +	VM_BUG_ON(pfn >= zone->zone_start_pfn + zone->spanned_pages);
> >  
> >  	for (; start_bitidx <= end_bitidx; start_bitidx++, value <<= 1)
> >  		if (flags & value)
> 
> Do we think this is needed in 2.6.25.x?
> 
Yes, I think.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
