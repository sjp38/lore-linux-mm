Message-ID: <45092FE6.3060706@shadowen.org>
Date: Thu, 14 Sep 2006 11:33:10 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [PATCH] Get rid of zone_table
References: <Pine.LNX.4.64.0609131340050.19059@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609131340050.19059@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[Appologies to Dave or yourself if what I am about to say has been
discussed already, but I wanted to read your intent and patch without
any preconceptions of it.]

First I wanted to be sure I have understood what you are proposing,
whilst trying to figure that out I came up with the following diagrams.

In the two diagrams below, we show the two main scenarios.  First page
flags as they appear when NODE,ZONE will fit (FLATMEM and DISCONTIGMEM),
at the top of the diagram.  Second page flags as they appear when
NODE,ZONE will not fit (SPARSEMEM on 32 bit), at the bottom of the
diagram.  The boxes are intended to represent where there is an
indirection through a table/pointer.

Current implementation:

    | Node | Zone | [Section] | xxxxx |      Flags       |
     \___________/
           |
           |
           v
      +-----------+
      | zonetable |-----> &zone
      +-----------+
           ^
           |
      _____|__________________________
     /                                \
    |         Section          | Zone |      Flags       |


Proposed implementation:

    | Node | Zone | [Section] | xxxxx |      Flags       |
     \____/ \____/
        |      |__________________
  .- - -|- - - - - - - -.         |
  .     v               .         v
  . +-----------+       .  +-----------+
  . | node_data |--&node-->| NODE_DATA |----> &zone
  . +-----------+       .  +-----------+
  .     ^               .         ^
   - - -|- - - - - - - -A         |
        |                         |
    +---------------+             |
    | section_table |             |
    +---------------+             |
        ^                         |
        |                         |
      __|_____________________   _|__
     /                        \ /    \
    |         Section          | Zone |      Flags       |


Christoph Lameter wrote:
> The zone table is mostly not needed. If we have a node in the page flags 
> then we can get to the zone via NODE_DATA(). In case of SMP and UP 
> NODE_DATA() is a constant pointer which allows us to access an exact 
> replica of zonetable in the node_zones field. In all of the above cases 
> there will be no need at all for the zone table.

Ok here we are talking about the segment of the second diagram ringed
and marked A.  Yes the compiler/we should be able to optimise this case
to directly use the zonelist.  However, this is also true of the current
scheme and would be a fairly trivial change in that framework.

Something like the below.

@@ -477,7 +477,10 @@ static inline int page_zone_id(struct pa
 }
 static inline struct zone *page_zone(struct page *page)
 {
-       return zone_table[page_zone_id(page)];
+       if (NODE_SHIFT)
+               return zone_table[page_zone_id(page)];
+       else
+               return NODE_DATA(0)->node_zones[page_zonenum(page)];
 }

 static inline unsigned long page_to_nid(struct page *page)
@@@

A similar thing could be done for page_to_nid which should always be zero.

> The only remaining case is if in a NUMA system the node numbers do not fit 
> into the page flags. In that case we make sparse generate a table that 
> maps sections to nodes and use that table to to figure out the node 
> number.
> 
> For sparsemem the zone table seems to be have been fairly large based on 
> the maximum possible number of sections and the number of zones per node.
> 
> The section_to_node table (if we still need it) is still the size of the 
> number of sections but the individual elements are integers (which already 
> saves 50% on 64 bit platforms) and we do not need to duplicate the entries 
> per zone type. So even if we have to keep the table then we shrink it to 
> 1/4th (32bit) or 1/8th )(64bit).

Ok, this is based on half for moving from a pointer to an integer.  The
rest is based on the fact we have 4 zones.  Given most sane
architectures only have ZONE_DMA we should be able to get a large
percentage of this saving just from knowing the highest 'valid' zone per
architecture.

If we consider the zone_table size for the easy case where NODE,ZONE is
in flags, this is of the order of (zones * nodes * sizeof(*)).  As nodes
are numbered sequentially in most systems this has a cache foot print of
the order of (zones * active nodes * sizeof(*)).  Worst case 4 * 1024 *
8 == 32KB, more typical usage of 4 * 8 * 8 = 256B.

Let us consider the likely sizes of the zone_table for a SPARSEMEM
configuration:

1) the 32bit case.  Here we have a limitation of a maximum of 6 bits
worth of sections (64 of them).  So the maximum zone_table size is 4 *
64 * 4 == 1024, so 1KB of zone_table.

2) the 64bit case.  If we assume we have 1024 node limit plus 4 zones,
then we can have 256k sections before we will not be able to fit the
node in.  So if we assume a 4MB section size (which is low) then we can
represent 1TB of ram before that occurs?  As sections are intended to
represent the installable unit for a machine, that should tend to scale
with the overall memory size as machines tend to have a maximum physical
slots.  So my expectations for a machine with 1TB of ram is that the
memory would come in 256MB or even 1GB increments.  Thus we should be
able to represent 256TB without needing a zone_table.  So any savings on
64bit feel illusory.  All of these calculations are without the
optimisation of removing the zone when we only have 1 active zone, or
moving the zone down into the bottom half of the flags (logically at least).

> 
> Tested on IA64(NUMA) and x86_64 (UP)
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 

General comments.  Although this may seem of the same order of
complexity and therefore a performance drop in, there does seem to be a
significant number of additional indirections on a NUMA system.
Particularly in 32 bit, for 64 bit we should never expect node/zone to
be absent from the flags.  Of course there is a cache footprint trade
off here, which may make these additional indirections very cheap as
node_data may well be hot anyway so there is a case for comparitive
benchmarks.

I can see a very valid case for optimising the UP/SMP case where
NODE_DATA is a constant.  But that could be optimised as I indicate
above without a complete rewrite.

I guess this all means much more if you have a SPARSMEME section/node
count configuration that significantly busts the 256Tb/1024 node
combinations on 64bit.

Finally, if the change here was a valid one benchmark wise or whatever,
I think it would be nicer to push this in through the same interface we
currently have as that would allow other shaped zone_tables to be
brought back should a new memory layout come along.

-apw

> Index: linux-2.6.18-rc6-mm2/include/linux/mm.h
> ===================================================================
> --- linux-2.6.18-rc6-mm2.orig/include/linux/mm.h	2006-09-13 14:17:24.798144329 -0500
> +++ linux-2.6.18-rc6-mm2/include/linux/mm.h	2006-09-13 15:42:22.040414207 -0500
> @@ -395,7 +395,9 @@
>   * We are going to use the flags for the page to node mapping if its in
>   * there.  This includes the case where there is no node, so it is implicit.
>   */
> -#define FLAGS_HAS_NODE		(NODES_WIDTH > 0 || NODES_SHIFT == 0)
> +#if !(NODES_WIDTH > 0 || NODES_SHIFT == 0)
> +#define NODE_NOT_IN_PAGE_FLAGS
> +#endif
>  
>  #ifndef PFN_SECTION_SHIFT
>  #define PFN_SECTION_SHIFT 0
> @@ -410,13 +412,13 @@
>  #define NODES_PGSHIFT		(NODES_PGOFF * (NODES_WIDTH != 0))
>  #define ZONES_PGSHIFT		(ZONES_PGOFF * (ZONES_WIDTH != 0))
>  
> -/* NODE:ZONE or SECTION:ZONE is used to lookup the zone from a page. */
> -#if FLAGS_HAS_NODE
> -#define ZONETABLE_SHIFT		(NODES_SHIFT + ZONES_SHIFT)
> +/* NODE:ZONE or SECTION:ZONE is used to ID a zone for the buddy allcator */
> +#ifdef NODE_NOT_IN_PAGE_FLAGS
> +#define ZONEID_SHIFT		(SECTIONS_SHIFT + ZONES_SHIFT)
>  #else
> -#define ZONETABLE_SHIFT		(SECTIONS_SHIFT + ZONES_SHIFT)
> +#define ZONEID_SHIFT		(NODES_SHIFT + ZONES_SHIFT)
>  #endif
> -#define ZONETABLE_PGSHIFT	ZONES_PGSHIFT
> +#define ZONEID_PGSHIFT		ZONES_PGSHIFT
>  
>  #if SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > FLAGS_RESERVED
>  #error SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > FLAGS_RESERVED
> @@ -425,23 +427,24 @@
>  #define ZONES_MASK		((1UL << ZONES_WIDTH) - 1)
>  #define NODES_MASK		((1UL << NODES_WIDTH) - 1)
>  #define SECTIONS_MASK		((1UL << SECTIONS_WIDTH) - 1)
> -#define ZONETABLE_MASK		((1UL << ZONETABLE_SHIFT) - 1)
> +#define ZONEID_MASK		((1UL << ZONEID_SHIFT) - 1)
>  
>  static inline enum zone_type page_zonenum(struct page *page)
>  {
>  	return (page->flags >> ZONES_PGSHIFT) & ZONES_MASK;
>  }
>  
> -struct zone;
> -extern struct zone *zone_table[];
> -
> +/*
> + * The identification function is only used by the buddy allocator for
> + * determining if two pages could be buddies. We are not really
> + * identify a zone since we could be using a the section number
> + * id if we have not node id available in page flags.
> + * We guarantee only that it will return the same value for two
> + * combinable pages in a zone.
> + */
>  static inline int page_zone_id(struct page *page)
>  {
> -	return (page->flags >> ZONETABLE_PGSHIFT) & ZONETABLE_MASK;
> -}
> -static inline struct zone *page_zone(struct page *page)
> -{
> -	return zone_table[page_zone_id(page)];
> +	return (page->flags >> ZONEID_PGSHIFT) & ZONEID_MASK;
>  }
>  
>  static inline unsigned long zone_to_nid(struct zone *zone)
> @@ -449,13 +452,20 @@
>  	return zone->zone_pgdat->node_id;
>  }
>  
> +#ifdef NODE_NOT_IN_PAGE_FLAGS
> +extern unsigned long page_to_nid(struct page *page);
> +#else
>  static inline unsigned long page_to_nid(struct page *page)
>  {
> -	if (FLAGS_HAS_NODE)
> -		return (page->flags >> NODES_PGSHIFT) & NODES_MASK;
> -	else
> -		return zone_to_nid(page_zone(page));
> +	return (page->flags >> NODES_PGSHIFT) & NODES_MASK;
>  }
> +#endif
> +
> +static inline struct zone *page_zone(struct page *page)
> +{
> +	return &NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)];
> +}
> +
>  static inline unsigned long page_to_section(struct page *page)
>  {
>  	return (page->flags >> SECTIONS_PGSHIFT) & SECTIONS_MASK;
> @@ -472,6 +482,7 @@
>  	page->flags &= ~(NODES_MASK << NODES_PGSHIFT);
>  	page->flags |= (node & NODES_MASK) << NODES_PGSHIFT;
>  }
> +
>  static inline void set_page_section(struct page *page, unsigned long section)
>  {
>  	page->flags &= ~(SECTIONS_MASK << SECTIONS_PGSHIFT);
> @@ -972,8 +983,6 @@
>  extern void show_mem(void);
>  extern void si_meminfo(struct sysinfo * val);
>  extern void si_meminfo_node(struct sysinfo *val, int nid);
> -extern void zonetable_add(struct zone *zone, int nid, enum zone_type zid,
> -					unsigned long pfn, unsigned long size);
>  
>  #ifdef CONFIG_NUMA
>  extern void setup_per_cpu_pageset(void);
> Index: linux-2.6.18-rc6-mm2/mm/sparse.c
> ===================================================================
> --- linux-2.6.18-rc6-mm2.orig/mm/sparse.c	2006-09-13 14:17:24.805957488 -0500
> +++ linux-2.6.18-rc6-mm2/mm/sparse.c	2006-09-13 15:10:24.845606274 -0500
> @@ -24,6 +24,21 @@
>  #endif
>  EXPORT_SYMBOL(mem_section);
>  
> +#ifdef NODE_NOT_IN_PAGE_FLAGS
> +/*
> + * If we did not store the node number in the page then we have to
> + * do a lookup in the section_to_node_table in order to find which
> + * node the page belongs to.
> + */
> +static int section_to_node_table[NR_MEM_SECTIONS];
> +
> +extern unsigned long page_to_nid(struct page *page)
> +{
> +	return section_to_node_table[page_to_section(page)];
> +}
> +EXPORT_SYMBOL(page_to_nid);
> +#endif
> +
>  #ifdef CONFIG_SPARSEMEM_EXTREME
>  static struct mem_section *sparse_index_alloc(int nid)
>  {
> @@ -49,6 +64,10 @@
>  	struct mem_section *section;
>  	int ret = 0;
>  
> +#ifdef NODE_NOT_IN_PAGE_FLAGS
> +	section_to_node_table[section_nr] = nid;
> +#endif
> +
>  	if (mem_section[root])
>  		return -EEXIST;
>  
> Index: linux-2.6.18-rc6-mm2/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.18-rc6-mm2.orig/mm/page_alloc.c	2006-09-13 14:17:24.812794002 -0500
> +++ linux-2.6.18-rc6-mm2/mm/page_alloc.c	2006-09-13 14:18:11.739602442 -0500
> @@ -82,13 +82,6 @@
>  
>  EXPORT_SYMBOL(totalram_pages);
>  
> -/*
> - * Used by page_zone() to look up the address of the struct zone whose
> - * id is encoded in the upper bits of page->flags
> - */
> -struct zone *zone_table[1 << ZONETABLE_SHIFT] __read_mostly;
> -EXPORT_SYMBOL(zone_table);
> -
>  static char *zone_names[MAX_NR_ZONES] = {
>  	 "DMA",
>  #ifdef CONFIG_ZONE_DMA32
> @@ -1808,20 +1801,6 @@
>  	}
>  }
>  
> -#define ZONETABLE_INDEX(x, zone_nr)	((x << ZONES_SHIFT) | zone_nr)
> -void zonetable_add(struct zone *zone, int nid, enum zone_type zid,
> -		unsigned long pfn, unsigned long size)
> -{
> -	unsigned long snum = pfn_to_section_nr(pfn);
> -	unsigned long end = pfn_to_section_nr(pfn + size);
> -
> -	if (FLAGS_HAS_NODE)
> -		zone_table[ZONETABLE_INDEX(nid, zid)] = zone;
> -	else
> -		for (; snum <= end; snum++)
> -			zone_table[ZONETABLE_INDEX(snum, zid)] = zone;
> -}
> -
>  #ifndef __HAVE_ARCH_MEMMAP_INIT
>  #define memmap_init(size, nid, zone, start_pfn) \
>  	memmap_init_zone((size), (nid), (zone), (start_pfn))
> @@ -2525,7 +2504,6 @@
>  		if (!size)
>  			continue;
>  
> -		zonetable_add(zone, nid, j, zone_start_pfn, size);
>  		ret = init_currently_empty_zone(zone, zone_start_pfn, size);
>  		BUG_ON(ret);
>  		zone_start_pfn += size;
> Index: linux-2.6.18-rc6-mm2/mm/memory_hotplug.c
> ===================================================================
> --- linux-2.6.18-rc6-mm2.orig/mm/memory_hotplug.c	2006-09-13 14:17:24.823537096 -0500
> +++ linux-2.6.18-rc6-mm2/mm/memory_hotplug.c	2006-09-13 14:18:11.750345535 -0500
> @@ -72,7 +72,6 @@
>  			return ret;
>  	}
>  	memmap_init_zone(nr_pages, nid, zone_type, phys_start_pfn);
> -	zonetable_add(zone, nid, zone_type, phys_start_pfn, nr_pages);
>  	return 0;
>  }
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
