Date: Fri, 20 Oct 2006 10:00:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] virtual memmap for sparsemem [1/2] arch independent part
Message-Id: <20061020100032.9ab28cb5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <453796BC.8050600@shadowen.org>
References: <20061019172140.5a29962c.kamezawa.hiroyu@jp.fujitsu.com>
	<453796BC.8050600@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 19 Oct 2006 16:16:12 +0100
Andy Whitcroft <apw@shadowen.org> wrote:

> KAMEZAWA Hiroyuki wrote:
> >  #elif defined(CONFIG_SPARSEMEM)
> > +#ifndef CONFIG_VMEMMAP_SPARSEMEM
> 
> Ok, this is a sub-type of sparsemem, we already have one called extreme
> and that is called CONFIG_SPARSMEM_EXTREME so it seems sensible to stay
> with this namespace, and call this CONFIG_SPARSEMEM_VMEMMAP.
> 
looks better. I'll rename.


> > +#else /* CONFIG_VMEMMAP_SPARSEMEM */
> > +
> > +#define __pfn_to_page(pfn)	(virt_memmap_start + (pfn))
> > +#define __page_to_pfn(pg)	((unsigned long)((pg) - virt_memmap_start))
> > +
> > +#endif /* CONFIG_VMEMMAP_SPARSEMEM */
> >  #endif /* CONFIG_FLATMEM/DISCONTIGMEM/SPARSEMEM */
> 
> Could we not leverage the standard infrastructure here.  It almost feels
> like if __section_mem_map_addr just returned virt_memmap_start then
> things would just come out the same with the compiler able to optimse
> things away.  It would stop us having to change this above section which
> would perhaps seem nicer?  I've not looked at all the other users of it
> to see if that would defeat the rest of sparsemem, so I may be talking
> out of my hat.
> 
Hm, Okay. I'll try it in the next time and check how it looks.


> > +
> > +#ifdef CONFIG_VMEMMAP_SPARSEMEM
> > +extern struct page *virt_memmap_start;
> > +extern void init_vmemmap_sparsemem(void *addr);
> > +#else
> > +#define init_vmemmap_sparsemem(addr)	do{}while(0)
> > +#endif
> > +
> 
> The existing initialisation function for sparsemem is sparse_init().  It
> seems that this one should follow the same scheme if we are part of
> sparsemem.  sparse_vmemmap_init() perhaps, though as this is defining
> the address of it perhaps, sparse_vmemmap_base() or
> sparse_vmemmap_setbase().
> 
Okay. 
I have another idea, which Chiristoph mentioned, to make start address
of vmemmap to be constant value. If doing so, this call can be removed.


> > +void init_vmemmap_sparsemem(void *start_addr)
> > +{
> > +	virt_memmap_start = start_addr;
> > +}
> > +
> > +void *pte_alloc_vmemmap(int node)
> > +{
> > +	void *ret;
> > +	if (system_state == SYSTEM_BOOTING) {
> > +		ret = alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE);
> > +	} else {
> > +		ret = kmalloc_node(PAGE_SIZE, GFP_KERNEL, node);
> > +		memset(ret, 0 , PAGE_SIZE);
> > +	}
> > +	BUG_ON(!ret);
> > +	return ret;
> > +}
> 
> Hmmm, this routine is not __init, but is calling an __init function.  I
> assume its safe under the system_state switcheroo, but the tools will
> barf about the difference.  Is there a way to mark this up as ok
> (assuming it is).
Maybe my mistake is to handle booting case and memory-hot-add case in a patch.
And I'll add __init or __meminit to suitable place in the next time.

> 
> > +/*
> > + * At Hot-add, vmalloc'ed memmap will never call this.
> > + * They have been already in suitable address.
> > + * Called only when map is allocated by alloc_bootmem()/alloc_pages()
> 
> They will?  By who?  

> If they alloc one it has to be placed in the real
> virtual map in VMEMAP mode else it won't be found by pfn_to_page and
> family.  I assume I am missing the point of this comment.  Could you
> explain more fully ...  Or perhaps this is a bit which is not right yet
> as you do say in the heading that hotplug is not right?
> 

Sorry...What I wanted to say here was that vmalloced memmap by memory-hotplug
cannot be handled by this routine. 
I'll divide memory-hotplug case from this patch to make things clearer.


> > + */
> > +static void map_virtual_memmap(unsigned long section, void *map, int node)
> > +{
> > +	unsigned long vmap_start, vmap_end, vmap;
> > +	unsigned long pfn;
> > +	void *pg;
> > +	pgd_t *pgd;
> > +	pud_t *pud;
> > +	pmd_t *pmd;
> > +	pte_t *pte;
> > +
> > +	BUG_ON (!virt_memmap_start);
> > +
> > +	pfn = section_nr_to_pfn(section);
> > +	vmap_start = (unsigned long)(virt_memmap_start + pfn);
> > +	vmap_end   = (unsigned long)(vmap_start + sizeof(struct page) * PAGES_PER_SECTION);
> > +
> > +	for (vmap = vmap_start; vmap < vmap_end; vmap += PAGE_SIZE, map += PAGE_SIZE)
> > +	{
> > +		pgd = pgd_offset_k(vmap);
> > +		if (pgd_none(*pgd)) {
> > +			pg = pte_alloc_vmemmap(node);
> > +			pgd_populate(&init_mm, pgd, pg);
> > +		}
> > +		pud = pud_offset(pgd, vmap);
> > +		if (pud_none(*pud)) {
> > +			pg = pte_alloc_vmemmap(node);
> > +			pud_populate(&init_mm, pud, pg);
> > +		}
> > +		pmd = pmd_offset(pud, vmap);
> > +		if (pmd_none(*pmd)) {
> > +			pg = pte_alloc_vmemmap(node);
> > +			pmd_populate_kernel(&init_mm, pmd, pg);
> > +		}
> > +		pte = pte_offset_kernel(pmd, vmap);
> > +		if (pte_none(*pte))
> > +			set_pte(pte, pfn_pte(__pa(map) >> PAGE_SHIFT, PAGE_KERNEL));
> > +	}
> > +	return;
> > +}
> 
> Its nice to see that this is generic as we can then add large page
> support for instance where applicable.  Are there really no helpers in
> the world to make this less 'wordy'.
> 
> We use this in the fault handler, are we using the above because we
> want to assure numa locality of the allocations?  (Which would be valid.)
> 
yes, for NUMA allocation. and for using alloc_bootmem().


> >  	ms->section_mem_map &= ~SECTION_MAP_MASK;
> >  	ms->section_mem_map |= sparse_encode_mem_map(mem_map, pnum);
> > +	map_virtual_memmap(pnum, mem_map, nid);
> 
> We seem to be using mem_map in sparse.c for the mem map, so perhaps this
> should be map_virtual_mem_map(), or map_vmap_mem_map() or something?
Okay, will rename.

> >  
> >  	return 1;
> >  }
> > @@ -214,10 +289,11 @@
> >  	page = alloc_pages(GFP_KERNEL, get_order(memmap_size));
> >  	if (page)
> >  		goto got_map_page;
> > -
> > +#ifndef CONFIG_VMEMMAP_SPARSEMEM
> >  	ret = vmalloc(memmap_size);
> >  	if (ret)
> >  		goto got_map_ptr;
> > +#endif
> 
> I assume we need this because its not really a good thing to have pages
> allocated which are already mapped as you are going to map them
> elsewhere?  Yes?  T
Yes.
> his only seems to be used from hotplug, so I'll defer to Dave.
I'll add hotplug handling later.

 
> > -	ret = sparse_init_one_section(ms, section_nr, memmap);
> > +	ret = sparse_init_one_section(ms, section_nr, memmap, zone->zone_pgdat->node_id);
> 
> In sparse_add_one_section() we already have the pgdat in a local, so
> this would better be pgdat->node_id.
> 
Okay, thanks.

Thank you for comments.
I'll refresh this patch.

Regards,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
