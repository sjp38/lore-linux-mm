Date: Fri, 18 Apr 2008 17:15:23 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH]Fix usemap for DISCONTIG/FLATMEM with not-aligned zone initilaization.
Message-ID: <20080418161522.GB9147@csn.ul.ie>
References: <48080706.50305@cn.fujitsu.com> <48080930.5090905@cn.fujitsu.com> <48080B86.7040200@cn.fujitsu.com> <20080418211214.299f91cd.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080418211214.299f91cd.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Shi Weihua <shiwh@cn.fujitsu.com>, akpm@linux-foundation.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On (18/04/08 21:12), KAMEZAWA Hiroyuki didst pronounce:
> On Fri, 18 Apr 2008 10:46:30 +0800
> Shi Weihua <shiwh@cn.fujitsu.com> wrote:
> > We found commit 9442ec9df40d952b0de185ae5638a74970388e01
> > causes this boot failure by git-bisect.
> > And, we found the following change caused the boot failure.
> > -------------------------------------
> > @@ -2528,7 +2535,6 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zon
> >                 set_page_links(page, zone, nid, pfn);
> >                 init_page_count(page);
> >                 reset_page_mapcount(page);
> > -               page_assign_page_cgroup(page, NULL);
> >                 SetPageReserved(page);
> > 
> >                 /*
> > -------------------------------------
> Finally, above was not guilty. patch is below. Mel, could you review below ?
> 

Sure.

> This happens because this box's start_pfn == 256 and memmap_init_zone(),
> called by ia64's virtual_mem_map() passed aligned pfn.
> patch is against 2.6.25.
> 

Ouch.

> -Kame
> ==
> This patch is quick workaround. If someone can write a clearer patch, please.
> Tested under ia64/torublesome machine. works well.
> ****
> 
> At boot, memmap_init_zone(size, zone, start_pfn, context) is called.
> 
> In usual,  memmap_init_zone() 's start_pfn is equal to zone->zone_start_pfn.
> But ia64's virtual memmap under CONFIG_DISCONTIGMEM passes an aligned pfn
> to this function.
> 

Yes. All architectures can optionally pass in their own values here.
Like other aspects of mm-init, the values were trusted and as we've seen
repeatedly, this was not a good plan.

> When start_pfn is smaller than zone->zone_start_pfn, set_pageblock_migratetype()
> causes a memory corruption, because bitmap_idx in usemap (pagetype bitmap)
> is calculated by "pfn - start_pfn" and out-of-range.
> (See set_pageblock_flags_group()//pfn_to_bitidx() in page_alloc.c)
> 
> On my ia64 box case, which has start_pfn = 256, bitmap_idx == -3
> and set_pageblock_flags_group() corrupts memory.
> 
> This patch fixes the calculation of bitmap_idx and bitmap_size for pagetype.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ---
>  include/linux/mmzone.h |    1 +
>  mm/page_alloc.c        |   22 ++++++++++++++--------
>  2 files changed, 15 insertions(+), 8 deletions(-)
> 
> Index: linux-2.6.25/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.25.orig/mm/page_alloc.c
> +++ linux-2.6.25/mm/page_alloc.c
> @@ -2546,8 +2546,7 @@ void __meminit memmap_init_zone(unsigned
>  		 * the start are marked MIGRATE_RESERVE by
>  		 * setup_zone_migrate_reserve()
>  		 */
> -		if ((pfn & (pageblock_nr_pages-1)))
> -			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
> +		set_pageblock_migratetype(page, MIGRATE_MOVABLE);
>  

The point of the if there was so that set_pageblock_migratetype() would
only be called once per pageblock. The impact with an unaligned zone is
that the first block is not set and will be used for UNMOVABLE pages
initially. However, this is not a major impact and there is no need to
call set_pageblock_migratetype for every page.

>  		INIT_LIST_HEAD(&page->lru);
>  #ifdef WANT_PAGE_VIRTUAL
> @@ -2815,6 +2814,48 @@ static __meminit void zone_pcp_init(stru
>  			zone->name, zone->present_pages, batch);
>  }
>  
> +#ifndef CONFIG_SPARSEMEM
> +/*
> + * Calculate the size of the zone->blockflags rounded to an unsigned long
> + * Start by making sure zonesize is a multiple of pageblock_order by rounding
> + * up. Then use 1 NR_PAGEBLOCK_BITS worth of bits per pageblock, finally
> + * round what is now in bits to nearest long in bits, then return it in
> + * bytes.
> + */
> +static unsigned long __init usemap_size(struct zone* zone)
> +{
> +	unsigned long usemapsize;
> +	unsigned long usemapbase = zone->zone_start_pfn;
> +	unsigned long usemapend = zone->zone_start_pfn + zone->spanned_pages;
> +
> +	usemapbase = ALIGN(usemapbase, pageblock_nr_pages);
> +	usemapend = roundup(usemapend, pageblock_nr_pages);
> +	usemapsize = usemapend - usemapbase;
> +	usemapsize = usemapsize >> pageblock_order;
> +	usemapsize *= NR_PAGEBLOCK_BITS;
> +	usemapsize = roundup(usemapsize, 8 * sizeof(unsigned long));
> +
> +	return usemapsize / 8;
> +}
> +
> +static void __init setup_usemap(struct pglist_data *pgdat,
> +				struct zone *zone)
> +{
> +	unsigned long usemapsize = usemap_size(zone);
> +	zone->pageblock_base_pfn = zone->zone_start_pfn;
> +	zone->pageblock_flags = NULL;
> +	if (usemapsize) {
> +		zone->pageblock_base_pfn =
> +			ALIGN(zone->zone_start_pfn, pageblock_nr_pages);
> +		zone->pageblock_flags = alloc_bootmem_node(pgdat, usemapsize);
> +		memset(zone->pageblock_flags, 0, usemapsize);
> +	}
> +}
> +#else
> +static void inline setup_usemap(struct pglist_data *pgdat,
> +				struct zone *zone) {}
> +#endif /* CONFIG_SPARSEMEM */
> +

This is a pretty large change for what seems to be a fairly basic problem -
alignment issues during boot where I'm guessing we are writing past the end
of the bitmap. Even if the virtual memmap is covering non-existant pages,
the PFNs there for bitmaps and the like should still not be getting used
and the map size is already rounded up to the pageblock size. It's also
expanding the size of zone which seems overkill.

I think I have a possible alternative fix below.

>  __meminit int init_currently_empty_zone(struct zone *zone,
>  					unsigned long zone_start_pfn,
>  					unsigned long size,
> @@ -2829,6 +2870,8 @@ __meminit int init_currently_empty_zone(
>  
>  	zone->zone_start_pfn = zone_start_pfn;
>  
> +	setup_usemap(pgdat, zone);
> +
>  	memmap_init(size, pgdat->node_id, zone_idx(zone), zone_start_pfn);
>  
>  	zone_init_free_lists(zone);
> @@ -3240,40 +3283,6 @@ static void __meminit calculate_node_tot
>  							realtotalpages);
>  }
>  
> -#ifndef CONFIG_SPARSEMEM
> -/*
> - * Calculate the size of the zone->blockflags rounded to an unsigned long
> - * Start by making sure zonesize is a multiple of pageblock_order by rounding
> - * up. Then use 1 NR_PAGEBLOCK_BITS worth of bits per pageblock, finally
> - * round what is now in bits to nearest long in bits, then return it in
> - * bytes.
> - */
> -static unsigned long __init usemap_size(unsigned long zonesize)
> -{
> -	unsigned long usemapsize;
> -
> -	usemapsize = roundup(zonesize, pageblock_nr_pages);
> -	usemapsize = usemapsize >> pageblock_order;
> -	usemapsize *= NR_PAGEBLOCK_BITS;
> -	usemapsize = roundup(usemapsize, 8 * sizeof(unsigned long));
> -
> -	return usemapsize / 8;
> -}
> -
> -static void __init setup_usemap(struct pglist_data *pgdat,
> -				struct zone *zone, unsigned long zonesize)
> -{
> -	unsigned long usemapsize = usemap_size(zonesize);
> -	zone->pageblock_flags = NULL;
> -	if (usemapsize) {
> -		zone->pageblock_flags = alloc_bootmem_node(pgdat, usemapsize);
> -		memset(zone->pageblock_flags, 0, usemapsize);
> -	}
> -}
> -#else
> -static void inline setup_usemap(struct pglist_data *pgdat,
> -				struct zone *zone, unsigned long zonesize) {}
> -#endif /* CONFIG_SPARSEMEM */
>  
>  #ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
>  
> @@ -3396,7 +3405,6 @@ static void __paginginit free_area_init_
>  			continue;
>  
>  		set_pageblock_order(pageblock_default_order());
> -		setup_usemap(pgdat, zone, size);
>  		ret = init_currently_empty_zone(zone, zone_start_pfn,
>  						size, MEMMAP_EARLY);
>  		BUG_ON(ret);
> @@ -4408,7 +4416,7 @@ static inline int pfn_to_bitidx(struct z
>  	pfn &= (PAGES_PER_SECTION-1);
>  	return (pfn >> pageblock_order) * NR_PAGEBLOCK_BITS;
>  #else
> -	pfn = pfn - zone->zone_start_pfn;
> +	pfn = pfn - zone->pageblock_base_pfn;
>  	return (pfn >> pageblock_order) * NR_PAGEBLOCK_BITS;
>  #endif /* CONFIG_SPARSEMEM */
>  }
> Index: linux-2.6.25/include/linux/mmzone.h
> ===================================================================
> --- linux-2.6.25.orig/include/linux/mmzone.h
> +++ linux-2.6.25/include/linux/mmzone.h
> @@ -250,6 +250,7 @@ struct zone {
>  	 * Flags for a pageblock_nr_pages block. See pageblock-flags.h.
>  	 * In SPARSEMEM, this map is stored in struct mem_section
>  	 */
> +	unsigned long		pageblock_base_pfn;
>  	unsigned long		*pageblock_flags;
>  #endif /* CONFIG_SPARSEMEM */
>  

What about something like the following? Instead of expanding the size of
structures, it sanity checks input parameters. It touches a number of places
because of an API change but it is otherwise straight-forward.

Unfortunately, I do not have an IA-64 machine that can reproduce the problem
to see if this still fixes it or not so a test as well as a review would be
appreciated. What should happen is the machine boots but prints a warning
about the unexpected PFN ranges. It boot-tested fine on a number of other
machines (x86-32 x86-64 and ppc64).

====
Subject: [PATCH] Sanity check input parameters to memmap_init_zone()

It is possible for architectures to define their own memmap_init() function
and call memmap_init_zone() directly. It was assumed that the data was
always valid due. However, on IA64 discontig with virtual memmap, aligned
PFNs are passed in regardless of the zone boundary. This results in the
pageblock bitmap helpers using invalid values resulting in corrupted memory.

Rather than fixing IA-64, this patch adds sanity checks on the data passed from
the architecture. When invalid values are found, they are fixed up and a
warning is printed once as a hint to the architecture maintainers to fix up the
arch-specific code.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
--- 
 arch/ia64/mm/init.c        |    4 ++--
 arch/s390/mm/vmem.c        |    2 +-
 include/asm-ia64/pgtable.h |    2 +-
 include/asm-s390/pgtable.h |    2 +-
 include/linux/mm.h         |    2 +-
 mm/memory_hotplug.c        |    4 +---
 mm/page_alloc.c            |   24 ++++++++++++++++++++----
 7 files changed, 27 insertions(+), 13 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-clean/arch/ia64/mm/init.c linux-2.6.25-rc9-alternative-ia64-discontig-fix/arch/ia64/mm/init.c
--- linux-2.6.25-rc9-clean/arch/ia64/mm/init.c	2008-04-11 21:32:29.000000000 +0100
+++ linux-2.6.25-rc9-alternative-ia64-discontig-fix/arch/ia64/mm/init.c	2008-04-18 14:25:29.000000000 +0100
@@ -469,7 +469,7 @@ struct memmap_init_callback_data {
 	struct page *start;
 	struct page *end;
 	int nid;
-	unsigned long zone;
+	struct zone *zone;
 };
 
 static int __meminit
@@ -504,7 +504,7 @@ virtual_memmap_init (u64 start, u64 end,
 }
 
 void __meminit
-memmap_init (unsigned long size, int nid, unsigned long zone,
+memmap_init (unsigned long size, int nid, struct zone *zone,
 	     unsigned long start_pfn)
 {
 	if (!vmem_map)
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-clean/arch/s390/mm/vmem.c linux-2.6.25-rc9-alternative-ia64-discontig-fix/arch/s390/mm/vmem.c
--- linux-2.6.25-rc9-clean/arch/s390/mm/vmem.c	2008-04-11 21:32:29.000000000 +0100
+++ linux-2.6.25-rc9-alternative-ia64-discontig-fix/arch/s390/mm/vmem.c	2008-04-18 14:23:57.000000000 +0100
@@ -25,7 +25,7 @@ struct memory_segment {
 
 static LIST_HEAD(mem_segs);
 
-void __meminit memmap_init(unsigned long size, int nid, unsigned long zone,
+void __meminit memmap_init(unsigned long size, int nid, struct zone *zone,
 			   unsigned long start_pfn)
 {
 	struct page *start, *end;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-clean/include/asm-ia64/pgtable.h linux-2.6.25-rc9-alternative-ia64-discontig-fix/include/asm-ia64/pgtable.h
--- linux-2.6.25-rc9-clean/include/asm-ia64/pgtable.h	2008-04-11 21:32:29.000000000 +0100
+++ linux-2.6.25-rc9-alternative-ia64-discontig-fix/include/asm-ia64/pgtable.h	2008-04-18 14:26:04.000000000 +0100
@@ -562,7 +562,7 @@ extern struct page *zero_page_memmap_ptr
 #  ifdef CONFIG_VIRTUAL_MEM_MAP
   /* arch mem_map init routine is needed due to holes in a virtual mem_map */
 #   define __HAVE_ARCH_MEMMAP_INIT
-    extern void memmap_init (unsigned long size, int nid, unsigned long zone,
+    extern void memmap_init (unsigned long size, int nid, struct zone *zone,
 			     unsigned long start_pfn);
 #  endif /* CONFIG_VIRTUAL_MEM_MAP */
 # endif /* !__ASSEMBLY__ */
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-clean/include/asm-s390/pgtable.h linux-2.6.25-rc9-alternative-ia64-discontig-fix/include/asm-s390/pgtable.h
--- linux-2.6.25-rc9-clean/include/asm-s390/pgtable.h	2008-04-11 21:32:29.000000000 +0100
+++ linux-2.6.25-rc9-alternative-ia64-discontig-fix/include/asm-s390/pgtable.h	2008-04-18 15:33:21.000000000 +0100
@@ -973,7 +973,7 @@ extern int remove_shared_memory(unsigned
 #define pgtable_cache_init()	do { } while (0)
 
 #define __HAVE_ARCH_MEMMAP_INIT
-extern void memmap_init(unsigned long, int, unsigned long, unsigned long);
+extern void memmap_init(unsigned long, int, struct zone *, unsigned long);
 
 #include <asm-generic/pgtable.h>
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-clean/include/linux/mm.h linux-2.6.25-rc9-alternative-ia64-discontig-fix/include/linux/mm.h
--- linux-2.6.25-rc9-clean/include/linux/mm.h	2008-04-11 21:32:29.000000000 +0100
+++ linux-2.6.25-rc9-alternative-ia64-discontig-fix/include/linux/mm.h	2008-04-18 14:28:06.000000000 +0100
@@ -995,7 +995,7 @@ extern int early_pfn_to_nid(unsigned lon
 #endif /* CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID */
 #endif /* CONFIG_ARCH_POPULATES_NODE_MAP */
 extern void set_dma_reserve(unsigned long new_dma_reserve);
-extern void memmap_init_zone(unsigned long, int, unsigned long,
+extern void memmap_init_zone(unsigned long, int, struct zone *,
 				unsigned long, enum memmap_context);
 extern void setup_per_zone_pages_min(void);
 extern void mem_init(void);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-clean/mm/memory_hotplug.c linux-2.6.25-rc9-alternative-ia64-discontig-fix/mm/memory_hotplug.c
--- linux-2.6.25-rc9-clean/mm/memory_hotplug.c	2008-04-11 21:32:29.000000000 +0100
+++ linux-2.6.25-rc9-alternative-ia64-discontig-fix/mm/memory_hotplug.c	2008-04-18 14:26:33.000000000 +0100
@@ -65,9 +65,7 @@ static int __add_zone(struct zone *zone,
 	struct pglist_data *pgdat = zone->zone_pgdat;
 	int nr_pages = PAGES_PER_SECTION;
 	int nid = pgdat->node_id;
-	int zone_type;
 
-	zone_type = zone - pgdat->node_zones;
 	if (!zone->wait_table) {
 		int ret = 0;
 		ret = init_currently_empty_zone(zone, phys_start_pfn,
@@ -75,7 +73,7 @@ static int __add_zone(struct zone *zone,
 		if (ret < 0)
 			return ret;
 	}
-	memmap_init_zone(nr_pages, nid, zone_type,
+	memmap_init_zone(nr_pages, nid, zone,
 			 phys_start_pfn, MEMMAP_HOTPLUG);
 	return 0;
 }
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-clean/mm/page_alloc.c linux-2.6.25-rc9-alternative-ia64-discontig-fix/mm/page_alloc.c
--- linux-2.6.25-rc9-clean/mm/page_alloc.c	2008-04-11 21:32:29.000000000 +0100
+++ linux-2.6.25-rc9-alternative-ia64-discontig-fix/mm/page_alloc.c	2008-04-18 14:41:40.000000000 +0100
@@ -2512,12 +2512,28 @@ static void setup_zone_migrate_reserve(s
  * up by free_all_bootmem() once the early boot process is
  * done. Non-atomic initialization, single-pass.
  */
-void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
+void __meminit memmap_init_zone(unsigned long size, int nid, struct zone *zone,
 		unsigned long start_pfn, enum memmap_context context)
 {
 	struct page *page;
 	unsigned long end_pfn = start_pfn + size;
 	unsigned long pfn;
+	int zoneidx = zone_idx(zone);
+
+	/*
+	 * Sanity check the values passed in. It is possible an architecture
+	 * calling this function directly will use values outside of the memory
+	 * they registered
+	 */
+	if (start_pfn < zone->zone_start_pfn) {
+		WARN_ON_ONCE(1);
+		start_pfn = zone->zone_start_pfn;
+	}
+
+	if (size > zone->spanned_pages) {
+		WARN_ON_ONCE(1);
+		size = zone->spanned_pages;
+	}
 
 	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
 		/*
@@ -2532,7 +2548,7 @@ void __meminit memmap_init_zone(unsigned
 				continue;
 		}
 		page = pfn_to_page(pfn);
-		set_page_links(page, zone, nid, pfn);
+		set_page_links(page, zoneidx, nid, pfn);
 		init_page_count(page);
 		reset_page_mapcount(page);
 		SetPageReserved(page);
@@ -2552,7 +2568,7 @@ void __meminit memmap_init_zone(unsigned
 		INIT_LIST_HEAD(&page->lru);
 #ifdef WANT_PAGE_VIRTUAL
 		/* The shift won't overflow because ZONE_NORMAL is below 4G. */
-		if (!is_highmem_idx(zone))
+		if (!is_highmem_idx(zoneidx))
 			set_page_address(page, __va(pfn << PAGE_SHIFT));
 #endif
 	}
@@ -2829,7 +2845,7 @@ __meminit int init_currently_empty_zone(
 
 	zone->zone_start_pfn = zone_start_pfn;
 
-	memmap_init(size, pgdat->node_id, zone_idx(zone), zone_start_pfn);
+	memmap_init(size, pgdat->node_id, zone, zone_start_pfn);
 
 	zone_init_free_lists(zone);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
