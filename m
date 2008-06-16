Date: Mon, 16 Jun 2008 11:21:31 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [Patch 001/005](memory hotplug) register section/node id to free
Message-ID: <20080616102131.GD17016@shadowen.org>
References: <20080407213519.886E.E1E9C6FF@jp.fujitsu.com> <20080407214318.8870.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080407214318.8870.E1E9C6FF@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Yinghai Lu <yhlu.kernel@gmail.com>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 07, 2008 at 09:45:04PM +0900, Yasunori Goto wrote:
> This is to register information which is node or section's id.
> Kernel can distinguish which node/section uses the pages
> allcated by bootmem. This is basis for hot-remove sections or nodes.
> 
> 
> Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
> 
> ---
> 
>  include/linux/memory_hotplug.h |   27 +++++++++++
>  include/linux/mmzone.h         |    1 
>  mm/bootmem.c                   |    1 
>  mm/memory_hotplug.c            |   99 ++++++++++++++++++++++++++++++++++++++++-
>  mm/sparse.c                    |    3 -
>  5 files changed, 128 insertions(+), 3 deletions(-)
> 
> Index: current/mm/bootmem.c
> ===================================================================
> --- current.orig/mm/bootmem.c	2008-04-07 16:06:49.000000000 +0900
> +++ current/mm/bootmem.c	2008-04-07 20:08:14.000000000 +0900
> @@ -458,6 +458,7 @@
>  
>  unsigned long __init free_all_bootmem_node(pg_data_t *pgdat)
>  {
> +	register_page_bootmem_info_node(pgdat);
>  	return free_all_bootmem_core(pgdat);
>  }
>  
> Index: current/include/linux/memory_hotplug.h
> ===================================================================
> --- current.orig/include/linux/memory_hotplug.h	2008-04-07 16:06:49.000000000 +0900
> +++ current/include/linux/memory_hotplug.h	2008-04-07 16:33:12.000000000 +0900
> @@ -11,6 +11,15 @@
>  struct mem_section;
>  
>  #ifdef CONFIG_MEMORY_HOTPLUG
> +
> +/*
> + * Magic number for free bootmem.
> + * The normal smallest mapcount is -1. Here is smaller value than it.
> + */
> +#define SECTION_INFO		0xfffffffe
> +#define MIX_INFO		0xfffffffd
> +#define NODE_INFO		0xfffffffc

Perhaps these should be defined relative to -1 to make that very
explicit.

#define SECTION_INFO	(-1 - 1)
#define MIX_INFO	(-1 - 2)
#define NODE_INFO	(-1 - 3)

Also from a scan of this patch I cannot see why I might care about the
type of these.  Yes it appears you are going to need a marker to say
which bootmem pages are under this reference counted scheme and which
are not.  From a review perspective having some clue in the leader about
the type and why we care would help.

>From the names I was expecting SECTION related info, NODE related info,
and a MIXture of things.  However, SECTION seems to be the actual sections,
NODE seems to be pgdat information, MIX seems to be usemap?  Why is it
not USEMAP here?  Possibily I will find out in a later patch but a clue
here might help.

> +
>  /*
>   * pgdat resizing functions
>   */
> @@ -145,6 +154,18 @@
>  #endif /* CONFIG_NUMA */
>  #endif /* CONFIG_HAVE_ARCH_NODEDATA_EXTENSION */
>  
> +#ifdef CONFIG_SPARSEMEM_VMEMMAP
> +static inline void register_page_bootmem_info_node(struct pglist_data *pgdat)
> +{
> +}
> +static inline void put_page_bootmem(struct page *page)
> +{
> +}
> +#else
> +extern void register_page_bootmem_info_node(struct pglist_data *pgdat);
> +extern void put_page_bootmem(struct page *page);
> +#endif
> +
>  #else /* ! CONFIG_MEMORY_HOTPLUG */
>  /*
>   * Stub functions for when hotplug is off
> @@ -172,6 +193,10 @@
>  	return -ENOSYS;
>  }
>  
> +static inline void register_page_bootmem_info_node(struct pglist_data *pgdat)
> +{
> +}
> +
>  #endif /* ! CONFIG_MEMORY_HOTPLUG */
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> @@ -192,5 +217,7 @@
>  extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
>  								int nr_pages);
>  extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms);
> +extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
> +					  unsigned long pnum);
>  
>  #endif /* __LINUX_MEMORY_HOTPLUG_H */
> Index: current/include/linux/mmzone.h
> ===================================================================
> --- current.orig/include/linux/mmzone.h	2008-04-07 16:06:49.000000000 +0900
> +++ current/include/linux/mmzone.h	2008-04-07 18:29:08.000000000 +0900
> @@ -879,6 +879,7 @@
>  	return &mem_section[SECTION_NR_TO_ROOT(nr)][nr & SECTION_ROOT_MASK];
>  }
>  extern int __section_nr(struct mem_section* ms);
> +extern unsigned long usemap_size(void);
>  
>  /*
>   * We use the lower bits of the mem_map pointer to store
> Index: current/mm/memory_hotplug.c
> ===================================================================
> --- current.orig/mm/memory_hotplug.c	2008-04-07 16:06:49.000000000 +0900
> +++ current/mm/memory_hotplug.c	2008-04-07 20:08:13.000000000 +0900
> @@ -59,8 +59,105 @@
>  	return;
>  }
>  
> -
>  #ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
> +#ifndef CONFIG_SPARSEMEM_VMEMMAP
> +static void get_page_bootmem(unsigned long info,  struct page *page, int magic)
> +{
> +	atomic_set(&page->_mapcount, magic);
> +	SetPagePrivate(page);
> +	set_page_private(page, info);
> +	atomic_inc(&page->_count);
> +}

Although I guess these 'magic' constants are effectivly magic numbers it
is also the type.  So I do wonder if this would be better called type.

> +
> +void put_page_bootmem(struct page *page)
> +{
> +	int magic;
> +
> +	magic = atomic_read(&page->_mapcount);
> +	BUG_ON(magic >= -1);
> +
> +	if (atomic_dec_return(&page->_count) == 1) {
> +		ClearPagePrivate(page);
> +		set_page_private(page, 0);
> +		reset_page_mapcount(page);
> +		__free_pages_bootmem(page, 0);
> +	}
> +
> +}

That seems pretty sensible, using _count to track track the number of
users of this page to allow it to be tracked.  But there was no mention
of this in the changelog, so I was about to complain that the get_ was a
strange name for something which set the magic numbers.  It mirroring
get_page, put_page makes the name sensible.  But please document that in
the changelog.

The BUG in put_page_bootmem I assume is effectivly saying "this page was
not reference counted and so cannot be freed with this call".  Is there
anything stopping us simply reference counting all bootmem allocations
in this manner?  So that any of them could be released?

Also how does this scheme cope with things being merged into the end of
the blocks you mark as freeable.  bootmem can pack small things into the
end of the previous allocation if they fit and alignment allows.  Is it
not possible that such allocations would get packed in, but not
accounted for in the _count so that when hotplug frees these things the
bootmem page would get dropped, but still have useful data in it?

> +
> +void register_page_bootmem_info_section(unsigned long start_pfn)
> +{
> +	unsigned long *usemap, mapsize, section_nr, i;
> +	struct mem_section *ms;
> +	struct page *page, *memmap;
> +
> +	if (!pfn_valid(start_pfn))
> +		return;
> +
> +	section_nr = pfn_to_section_nr(start_pfn);
> +	ms = __nr_to_section(section_nr);
> +
> +	/* Get section's memmap address */
> +	memmap = sparse_decode_mem_map(ms->section_mem_map, section_nr);
> +
> +	/*
> +	 * Get page for the memmap's phys address
> +	 * XXX: need more consideration for sparse_vmemmap...
> +	 */
> +	page = virt_to_page(memmap);
> +	mapsize = sizeof(struct page) * PAGES_PER_SECTION;
> +	mapsize = PAGE_ALIGN(mapsize) >> PAGE_SHIFT;
> +
> +	/* remember memmap's page */
> +	for (i = 0; i < mapsize; i++, page++)
> +		get_page_bootmem(section_nr, page, SECTION_INFO);
> +
> +	usemap = __nr_to_section(section_nr)->pageblock_flags;
> +	page = virt_to_page(usemap);
> +
> +	mapsize = PAGE_ALIGN(usemap_size()) >> PAGE_SHIFT;
> +
> +	for (i = 0; i < mapsize; i++, page++)
> +		get_page_bootmem(section_nr, page, MIX_INFO);
> +

I am concerned that some of these pages might be in the numa remap space?
If they are they were not part of bootmem, will they free correctly in the
same manner?  They are necessarily not mapped at the correct kernel virtual
address so the __pa() is not going to find the right struct page is it?

Perhaps if you simply reference counted all bootmem allocations you
would avoid this problem?

> +}
> +
> +void register_page_bootmem_info_node(struct pglist_data *pgdat)
> +{
> +	unsigned long i, pfn, end_pfn, nr_pages;
> +	int node = pgdat->node_id;
> +	struct page *page;
> +	struct zone *zone;
> +
> +	nr_pages = PAGE_ALIGN(sizeof(struct pglist_data)) >> PAGE_SHIFT;
> +	page = virt_to_page(pgdat);
> +
> +	for (i = 0; i < nr_pages; i++, page++)
> +		get_page_bootmem(node, page, NODE_INFO);
> +
> +	zone = &pgdat->node_zones[0];
> +	for (; zone < pgdat->node_zones + MAX_NR_ZONES - 1; zone++) {
> +		if (zone->wait_table) {
> +			nr_pages = zone->wait_table_hash_nr_entries
> +				* sizeof(wait_queue_head_t);
> +			nr_pages = PAGE_ALIGN(nr_pages) >> PAGE_SHIFT;
> +			page = virt_to_page(zone->wait_table);
> +
> +			for (i = 0; i < nr_pages; i++, page++)
> +				get_page_bootmem(node, page, NODE_INFO);
> +		}
> +	}
> +
> +	pfn = pgdat->node_start_pfn;
> +	end_pfn = pfn + pgdat->node_spanned_pages;
> +
> +	/* register_section info */
> +	for (; pfn < end_pfn; pfn += PAGES_PER_SECTION)
> +		register_page_bootmem_info_section(pfn);
> +
> +}
> +#endif /* !CONFIG_SPARSEMEM_VMEMMAP */
> +
>  static int __add_zone(struct zone *zone, unsigned long phys_start_pfn)
>  {
>  	struct pglist_data *pgdat = zone->zone_pgdat;
> Index: current/mm/sparse.c
> ===================================================================
> --- current.orig/mm/sparse.c	2008-04-07 16:06:49.000000000 +0900
> +++ current/mm/sparse.c	2008-04-07 20:08:16.000000000 +0900
> @@ -200,7 +200,6 @@
>  /*
>   * Decode mem_map from the coded memmap
>   */
> -static
>  struct page *sparse_decode_mem_map(unsigned long coded_mem_map, unsigned long pnum)
>  {
>  	/* mask off the extra low bits of information */
> @@ -223,7 +222,7 @@
>  	return 1;
>  }
>  
> -static unsigned long usemap_size(void)
> +unsigned long usemap_size(void)
>  {
>  	unsigned long size_bytes;
>  	size_bytes = roundup(SECTION_BLOCKFLAGS_BITS, 8) / 8;
> 

I wonder if these export changes might make more sense as a separate
patch, they are effectivly just noise.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
