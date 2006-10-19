Message-ID: <453796BC.8050600@shadowen.org>
Date: Thu, 19 Oct 2006 16:16:12 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [RFC] virtual memmap for sparsemem [1/2] arch independent part
References: <20061019172140.5a29962c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20061019172140.5a29962c.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-ia64@vger.kernel.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> This is a patch for virtual memmap on sparsemem against 2.6.19-rc2.
> booted well on my Tiger4.
> 
> In this time, this is just a RFC. comments on patch and advises for benchmarking
> is welcome. (memory hotplug case is not well handled yet.)
> 
> ia64's SPARSEMEM uses SPARSEMEM_EXTREME. This requires 2-level table lookup by
> software for page_to_pfn()/pfn_to_page(). virtual memmap can remove that costs.
> But will consume more TLBs.
> 
> For make patches simple, pfn_valid() uses sparsemem's logic. 

Firstly I am pleased to see that this doesn't convert the whole of
sparsemem to use a virtual map.  That had been suggested and would
really not work for 32 bit.  Good.

> 
> - Kame
> ==
> This patch maps sparsemem's *sparse* memmap into contiguous virtual address range
> starting from virt_memmap_start.
> 
> By this, pfn_to_page, page_to_pfn can be implemented as 
> #define pfn_to_page(pfn)		(virt_memmap_start + (pfn))
> #define page_to_pfn(pg)			(pg - virt_memmap_start)
> 
> 
> Difference from ia64's VIRTUAL_MEMMAP are
> * pfn_valid() uses sparsemem's logic.
> * memmap is allocated per SECTION_SIZE, so there will be some of RESERVED pages.
> * no holes in MAX_ORDER range. so HOLE_IN_ZONE=n here.

This is a good thing too as one of the main issues we've had with the
VIRTUAL_MEMMAP stuff is this need to pfn_valid each and every
conversion.  Of course the same change could be applied there just as well.

> 
> Todo
> - fix vmalloc() case in memory hotadd. (maybe __get_vm_area() can be used.)
> 
> Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
>  include/asm-generic/memory_model.h |    7 +++
>  include/linux/mmzone.h             |    8 +++
>  mm/Kconfig                         |    8 +++
>  mm/sparse.c                        |   85 +++++++++++++++++++++++++++++++++++--
>  4 files changed, 104 insertions(+), 4 deletions(-)
> 
> Index: linux-2.6.19-rc2/mm/Kconfig
> ===================================================================
> --- linux-2.6.19-rc2.orig/mm/Kconfig	2006-10-18 18:13:39.000000000 +0900
> +++ linux-2.6.19-rc2/mm/Kconfig	2006-10-18 18:14:07.000000000 +0900
> @@ -77,6 +77,14 @@
>  	def_bool y
>  	depends on !SPARSEMEM
>  
> +config VMEMMAP_SPARSEMEM
> +	bool "memmap in virtual space"
> +	default y
> +	depends on SPARSEMEM && ARCH_VMEMMAP_SPARSEMEM_SUPPORT
> +	help
> +	  If this option is selected, you can speed up some kernel execution.
> +	  But this consumes large amount of virtual memory area in kernel.
> +
>  #
>  # Both the NUMA code and DISCONTIGMEM use arrays of pg_data_t's
>  # to represent different areas of memory.  This variable allows
> Index: linux-2.6.19-rc2/include/asm-generic/memory_model.h
> ===================================================================
> --- linux-2.6.19-rc2.orig/include/asm-generic/memory_model.h	2006-09-20 12:42:06.000000000 +0900
> +++ linux-2.6.19-rc2/include/asm-generic/memory_model.h	2006-10-18 18:14:07.000000000 +0900
> @@ -47,6 +47,7 @@
>  })
>  
>  #elif defined(CONFIG_SPARSEMEM)
> +#ifndef CONFIG_VMEMMAP_SPARSEMEM

Ok, this is a sub-type of sparsemem, we already have one called extreme
and that is called CONFIG_SPARSMEM_EXTREME so it seems sensible to stay
with this namespace, and call this CONFIG_SPARSEMEM_VMEMMAP.

>  /*
>   * Note: section's mem_map is encorded to reflect its start_pfn.
>   * section[i].section_mem_map == mem_map's address - start_pfn;
> @@ -62,6 +63,12 @@
>  	struct mem_section *__sec = __pfn_to_section(__pfn);	\
>  	__section_mem_map_addr(__sec) + __pfn;		\
>  })
> +#else /* CONFIG_VMEMMAP_SPARSEMEM */
> +
> +#define __pfn_to_page(pfn)	(virt_memmap_start + (pfn))
> +#define __page_to_pfn(pg)	((unsigned long)((pg) - virt_memmap_start))
> +
> +#endif /* CONFIG_VMEMMAP_SPARSEMEM */
>  #endif /* CONFIG_FLATMEM/DISCONTIGMEM/SPARSEMEM */

Could we not leverage the standard infrastructure here.  It almost feels
like if __section_mem_map_addr just returned virt_memmap_start then
things would just come out the same with the compiler able to optimse
things away.  It would stop us having to change this above section which
would perhaps seem nicer?  I've not looked at all the other users of it
to see if that would defeat the rest of sparsemem, so I may be talking
out of my hat.

>  
>  #ifdef CONFIG_OUT_OF_LINE_PFN_TO_PAGE
> Index: linux-2.6.19-rc2/include/linux/mmzone.h
> ===================================================================
> --- linux-2.6.19-rc2.orig/include/linux/mmzone.h	2006-10-18 18:13:39.000000000 +0900
> +++ linux-2.6.19-rc2/include/linux/mmzone.h	2006-10-18 18:14:07.000000000 +0900
> @@ -599,6 +599,14 @@
>  extern struct mem_section mem_section[NR_SECTION_ROOTS][SECTIONS_PER_ROOT];
>  #endif
>  
> +
> +#ifdef CONFIG_VMEMMAP_SPARSEMEM
> +extern struct page *virt_memmap_start;
> +extern void init_vmemmap_sparsemem(void *addr);
> +#else
> +#define init_vmemmap_sparsemem(addr)	do{}while(0)
> +#endif
> +

The existing initialisation function for sparsemem is sparse_init().  It
seems that this one should follow the same scheme if we are part of
sparsemem.  sparse_vmemmap_init() perhaps, though as this is defining
the address of it perhaps, sparse_vmemmap_base() or
sparse_vmemmap_setbase().

>  static inline struct mem_section *__nr_to_section(unsigned long nr)
>  {
>  	if (!mem_section[SECTION_NR_TO_ROOT(nr)])
> Index: linux-2.6.19-rc2/mm/sparse.c
> ===================================================================
> --- linux-2.6.19-rc2.orig/mm/sparse.c	2006-09-20 12:42:06.000000000 +0900
> +++ linux-2.6.19-rc2/mm/sparse.c	2006-10-19 16:58:06.000000000 +0900
> @@ -9,7 +9,81 @@
>  #include <linux/spinlock.h>
>  #include <linux/vmalloc.h>
>  #include <asm/dma.h>
> +#include <asm/pgalloc.h>
>  
> +#ifdef CONFIG_VMEMMAP_SPARSEMEM
> +struct page *virt_memmap_start;
> +EXPORT_SYMBOL_GPL(virt_memmap_start);
> +
> +void init_vmemmap_sparsemem(void *start_addr)
> +{
> +	virt_memmap_start = start_addr;
> +}
> +
> +void *pte_alloc_vmemmap(int node)
> +{
> +	void *ret;
> +	if (system_state == SYSTEM_BOOTING) {
> +		ret = alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE);
> +	} else {
> +		ret = kmalloc_node(PAGE_SIZE, GFP_KERNEL, node);
> +		memset(ret, 0 , PAGE_SIZE);
> +	}
> +	BUG_ON(!ret);
> +	return ret;
> +}

Hmmm, this routine is not __init, but is calling an __init function.  I
assume its safe under the system_state switcheroo, but the tools will
barf about the difference.  Is there a way to mark this up as ok
(assuming it is).

> +/*
> + * At Hot-add, vmalloc'ed memmap will never call this.
> + * They have been already in suitable address.
> + * Called only when map is allocated by alloc_bootmem()/alloc_pages()

They will?  By who?  If they alloc one it has to be placed in the real
virtual map in VMEMAP mode else it won't be found by pfn_to_page and
family.  I assume I am missing the point of this comment.  Could you
explain more fully ...  Or perhaps this is a bit which is not right yet
as you do say in the heading that hotplug is not right?

> + */
> +static void map_virtual_memmap(unsigned long section, void *map, int node)
> +{
> +	unsigned long vmap_start, vmap_end, vmap;
> +	unsigned long pfn;
> +	void *pg;
> +	pgd_t *pgd;
> +	pud_t *pud;
> +	pmd_t *pmd;
> +	pte_t *pte;
> +
> +	BUG_ON (!virt_memmap_start);
> +
> +	pfn = section_nr_to_pfn(section);
> +	vmap_start = (unsigned long)(virt_memmap_start + pfn);
> +	vmap_end   = (unsigned long)(vmap_start + sizeof(struct page) * PAGES_PER_SECTION);
> +
> +	for (vmap = vmap_start; vmap < vmap_end; vmap += PAGE_SIZE, map += PAGE_SIZE)
> +	{
> +		pgd = pgd_offset_k(vmap);
> +		if (pgd_none(*pgd)) {
> +			pg = pte_alloc_vmemmap(node);
> +			pgd_populate(&init_mm, pgd, pg);
> +		}
> +		pud = pud_offset(pgd, vmap);
> +		if (pud_none(*pud)) {
> +			pg = pte_alloc_vmemmap(node);
> +			pud_populate(&init_mm, pud, pg);
> +		}
> +		pmd = pmd_offset(pud, vmap);
> +		if (pmd_none(*pmd)) {
> +			pg = pte_alloc_vmemmap(node);
> +			pmd_populate_kernel(&init_mm, pmd, pg);
> +		}
> +		pte = pte_offset_kernel(pmd, vmap);
> +		if (pte_none(*pte))
> +			set_pte(pte, pfn_pte(__pa(map) >> PAGE_SHIFT, PAGE_KERNEL));
> +	}
> +	return;
> +}

Its nice to see that this is generic as we can then add large page
support for instance where applicable.  Are there really no helpers in
the world to make this less 'wordy'.

We use this in the fault handler, are we using the above because we
want to assure numa locality of the allocations?  (Which would be valid.)

        pgd = pgd_offset(mm, address);
        pud = pud_alloc(mm, pgd, address);
        if (!pud)
                return VM_FAULT_OOM;
        pmd = pmd_alloc(mm, pud, address);
        if (!pmd)
                return VM_FAULT_OOM;
        pte = pte_alloc_map(mm, pmd, address);
        if (!pte)
                return VM_FAULT_OOM;


> +#else /* CONFIG_VMEMMAP_SPARSEMEM */
> +
> +static inline void map_virtual_memmap(unsigned long section, void *map, int nid)
> +{
> +	return;
> +}
> +
> +#endif /* CONFIG_VMEMMAP_SPARSEMEM */
>  /*
>   * Permanent SPARSEMEM data:
>   *
> @@ -175,13 +249,14 @@
>  }
>  
>  static int sparse_init_one_section(struct mem_section *ms,
> -		unsigned long pnum, struct page *mem_map)
> +		unsigned long pnum, struct page *mem_map, int nid)
>  {
>  	if (!valid_section(ms))
>  		return -EINVAL;
>  
>  	ms->section_mem_map &= ~SECTION_MAP_MASK;
>  	ms->section_mem_map |= sparse_encode_mem_map(mem_map, pnum);
> +	map_virtual_memmap(pnum, mem_map, nid);

We seem to be using mem_map in sparse.c for the mem map, so perhaps this
should be map_virtual_mem_map(), or map_vmap_mem_map() or something?
>  
>  	return 1;
>  }
> @@ -214,10 +289,11 @@
>  	page = alloc_pages(GFP_KERNEL, get_order(memmap_size));
>  	if (page)
>  		goto got_map_page;
> -
> +#ifndef CONFIG_VMEMMAP_SPARSEMEM
>  	ret = vmalloc(memmap_size);
>  	if (ret)
>  		goto got_map_ptr;
> +#endif

I assume we need this because its not really a good thing to have pages
allocated which are already mapped as you are going to map them
elsewhere?  Yes?  This only seems to be used from hotplug, so I'll defer
to Dave.

>  
>  	return NULL;
>  got_map_page:
> @@ -261,7 +337,8 @@
>  		map = sparse_early_mem_map_alloc(pnum);
>  		if (!map)
>  			continue;
> -		sparse_init_one_section(__nr_to_section(pnum), pnum, map);
> +		sparse_init_one_section(__nr_to_section(pnum), pnum, map,
> +					sparse_early_nid(__nr_to_section(pnum)));
>  	}
>  }
>  
> @@ -296,7 +373,7 @@
>  	}
>  	ms->section_mem_map |= SECTION_MARKED_PRESENT;
>  
> -	ret = sparse_init_one_section(ms, section_nr, memmap);
> +	ret = sparse_init_one_section(ms, section_nr, memmap, zone->zone_pgdat->node_id);

In sparse_add_one_section() we already have the pgdat in a local, so
this would better be pgdat->node_id.

>  
>  out:
>  	pgdat_resize_unlock(pgdat, &flags);
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
