Date: Mon, 16 Jun 2008 11:44:34 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [Patch 005/005](memory hotplug) free memmaps allocated by bootmem
Message-ID: <20080616104434.GG17016@shadowen.org>
References: <20080407213519.886E.E1E9C6FF@jp.fujitsu.com> <20080407214844.887A.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080407214844.887A.E1E9C6FF@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Yinghai Lu <yhlu.kernel@gmail.com>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 07, 2008 at 09:50:18PM +0900, Yasunori Goto wrote:
> This patch is to free memmaps which is allocated by bootmem.
> 
> Freeing usemap is not necessary. The pages of usemap may be necessary
> for other sections.
> 
> If removing section is last section on the node,
> its section is the final user of usemap page.
> (usemaps are allocated on its section by previous patch.)
> But it shouldn't be freed too, because the section must be
> logical offline state which all pages are isolated against page allocater.
> If it is freed, page alloctor may use it which will be removed
> physically soon. It will be disaster.
> So, this patch keeps it as it is.
> 
> 
> Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
> 
> ---
>  mm/internal.h       |    3 +--
>  mm/memory_hotplug.c |   11 +++++++++++
>  mm/page_alloc.c     |    2 +-
>  mm/sparse.c         |   51 +++++++++++++++++++++++++++++++++++++++++++++++----
>  4 files changed, 60 insertions(+), 7 deletions(-)
> 
> Index: current/mm/sparse.c
> ===================================================================
> --- current.orig/mm/sparse.c	2008-04-07 20:13:25.000000000 +0900
> +++ current/mm/sparse.c	2008-04-07 20:27:20.000000000 +0900
> @@ -8,6 +8,7 @@
>  #include <linux/module.h>
>  #include <linux/spinlock.h>
>  #include <linux/vmalloc.h>
> +#include "internal.h"
>  #include <asm/dma.h>
>  #include <asm/pgalloc.h>
>  #include <asm/pgtable.h>
> @@ -360,6 +361,9 @@
>  {
>  	return; /* XXX: Not implemented yet */
>  }
> +static void free_map_bootmem(struct page *page, unsigned long nr_pages)
> +{
> +}
>  #else
>  static struct page *__kmalloc_section_memmap(unsigned long nr_pages)
>  {
> @@ -397,17 +401,47 @@
>  		free_pages((unsigned long)memmap,
>  			   get_order(sizeof(struct page) * nr_pages));
>  }
> +
> +static void free_map_bootmem(struct page *page, unsigned long nr_pages)
> +{
> +	unsigned long maps_section_nr, removing_section_nr, i;
> +	int magic;
> +
> +	for (i = 0; i < nr_pages; i++, page++) {
> +		magic = atomic_read(&page->_mapcount);
> +
> +		BUG_ON(magic == NODE_INFO);

Are we sure the node area was big enough to never allocate usemap's into
it and change the magic to MIX?  I saw you make the section information
page sized but not the others.

> +
> +		maps_section_nr = pfn_to_section_nr(page_to_pfn(page));
> +		removing_section_nr = page->private;
> +
> +		/*
> +		 * When this function is called, the removing section is
> +		 * logical offlined state. This means all pages are isolated
> +		 * from page allocator. If removing section's memmap is placed
> +		 * on the same section, it must not be freed.
> +		 * If it is freed, page allocator may allocate it which will
> +		 * be removed physically soon.
> +		 */
> +		if (maps_section_nr != removing_section_nr)
> +			put_page_bootmem(page);

Would the section memmap have its own get_page_bootmem reference here?
Would that not protect it from release?

> +	}
> +}
>  #endif /* CONFIG_SPARSEMEM_VMEMMAP */
>  
>  static void free_section_usemap(struct page *memmap, unsigned long *usemap)
>  {
> +	struct page *usemap_page;
> +	unsigned long nr_pages;
> +
>  	if (!usemap)
>  		return;
>  
> +	usemap_page = virt_to_page(usemap);
>  	/*
>  	 * Check to see if allocation came from hot-plug-add
>  	 */
> -	if (PageSlab(virt_to_page(usemap))) {
> +	if (PageSlab(usemap_page)) {
>  		kfree(usemap);
>  		if (memmap)
>  			__kfree_section_memmap(memmap, PAGES_PER_SECTION);
> @@ -415,10 +449,19 @@
>  	}
>  
>  	/*
> -	 * TODO: Allocations came from bootmem - how do I free up ?
> +	 * The usemap came from bootmem. This is packed with other usemaps
> +	 * on the section which has pgdat at boot time. Just keep it as is now.
>  	 */
> -	printk(KERN_WARNING "Not freeing up allocations from bootmem "
> -			"- leaking memory\n");
> +
> +	if (memmap) {
> +		struct page *memmap_page;
> +		memmap_page = virt_to_page(memmap);
> +
> +		nr_pages = PAGE_ALIGN(PAGES_PER_SECTION * sizeof(struct page))
> +			>> PAGE_SHIFT;
> +
> +		free_map_bootmem(memmap_page, nr_pages);
> +	}
>  }
>  
>  /*
> Index: current/mm/page_alloc.c
> ===================================================================
> --- current.orig/mm/page_alloc.c	2008-04-07 20:12:55.000000000 +0900
> +++ current/mm/page_alloc.c	2008-04-07 20:13:29.000000000 +0900
> @@ -568,7 +568,7 @@
>  /*
>   * permit the bootmem allocator to evade page validation on high-order frees
>   */
> -void __init __free_pages_bootmem(struct page *page, unsigned int order)
> +void __free_pages_bootmem(struct page *page, unsigned int order)

not __meminit or something?

>  {
>  	if (order == 0) {
>  		__ClearPageReserved(page);
> Index: current/mm/internal.h
> ===================================================================
> --- current.orig/mm/internal.h	2008-04-07 20:12:55.000000000 +0900
> +++ current/mm/internal.h	2008-04-07 20:13:29.000000000 +0900
> @@ -34,8 +34,7 @@
>  	atomic_dec(&page->_count);
>  }
>  
> -extern void __init __free_pages_bootmem(struct page *page,
> -						unsigned int order);
> +extern void __free_pages_bootmem(struct page *page, unsigned int order);
>  
>  /*
>   * function for dealing with page's order in buddy system.
> Index: current/mm/memory_hotplug.c
> ===================================================================
> --- current.orig/mm/memory_hotplug.c	2008-04-07 20:12:55.000000000 +0900
> +++ current/mm/memory_hotplug.c	2008-04-07 20:13:29.000000000 +0900
> @@ -199,6 +199,16 @@
>  	return register_new_memory(__pfn_to_section(phys_start_pfn));
>  }
>  
> +#ifdef CONFIG_SPARSEMEM_VMEMMAP
> +static int __remove_section(struct zone *zone, struct mem_section *ms)
> +{
> +	/*
> +	 * XXX: Freeing memmap with vmemmap is not implement yet.
> +	 *      This should be removed later.
> +	 */
> +	return -EBUSY;
> +}
> +#else
>  static int __remove_section(struct zone *zone, struct mem_section *ms)
>  {
>  	unsigned long flags;
> @@ -217,6 +227,7 @@
>  	pgdat_resize_unlock(pgdat, &flags);
>  	return 0;
>  }
> +#endif
>  
>  /*
>   * Reasonably generic function for adding memory.  It is

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
