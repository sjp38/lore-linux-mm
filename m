Date: Mon, 2 Apr 2007 14:00:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/2] Generic Virtual Memmap suport for SPARSEMEM
In-Reply-To: <1175547000.22373.89.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0704021351590.1224@schroedinger.engr.sgi.com>
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>
 <1175547000.22373.89.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <hansendc@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Apr 2007, Dave Hansen wrote:

> First of all, nice set of patches.
> 
> On Sat, 2007-03-31 at 23:10 -0800, Christoph Lameter wrote:
> > --- linux-2.6.21-rc5-mm2.orig/include/asm-generic/memory_model.h	2007-03-31 22:47:14.000000000 -0700
> > +++ linux-2.6.21-rc5-mm2/include/asm-generic/memory_model.h	2007-03-31 22:59:35.000000000 -0700
> > @@ -47,6 +47,13 @@
> >  })
> > 
> >  #elif defined(CONFIG_SPARSEMEM)
> > +#ifdef CONFIG_SPARSE_VIRTUAL
> > +/*
> > + * We have a virtual memmap that makes lookups very simple
> > + */
> > +#define __pfn_to_page(pfn)	(vmemmap + (pfn))
> > +#define __page_to_pfn(page)	((page) - vmemmap)
> > +#else
> >  /*
> >   * Note: section's mem_map is encorded to reflect its start_pfn.
> >   * section[i].section_mem_map == mem_map's address - start_pfn;
> > @@ -62,6 +69,7 @@
> >  	struct mem_section *__sec = __pfn_to_section(__pfn);	\
> >  	__section_mem_map_addr(__sec) + __pfn;		\
> >  })
> > +#endif
> >  #endif /* CONFIG_FLATMEM/DISCONTIGMEM/SPARSEMEM */
> 
> Any chance this can be done without embedding this inside another
> #ifdef?  I really hate untangling the mess when an #endif goes
> missing.  
> 
> Any reason this can't just be another #elif?

Sure.

> > +	} else
> > +		return __alloc_bootmem_node(NODE_DATA(node), size, size,
> > +					__pa(MAX_DMA_ADDRESS));
> > +}
> 
> Hmmmmmmm.  Can we combine this with sparse_index_alloc()?  Also, why not
> just use the slab for this?

Use a slab for page sized allocations? No.

> Let's get rid of the _block() part, too.  I'm not sure it does any good.
> At least make it _bytes() so that we know what the units are.  Also, if
> you're just going to round up internally and _not_ use the slab, can you
> just make the argument in pages, or even order?

Its used for page sized allocations.
 
> Can you think of any times when we'd want that BUG_ON() to be a
> WARN_ON(), instead?  I can see preferring having my mem_map[] on the
> wrong node than hitting a BUG().

We should probably have some error handling there instead of the BUG.

> > +#ifndef ARCH_POPULATES_VIRTUAL_MEMMAP
> > +/*
> > + * Virtual memmap populate functionality for architectures that support
> > + * PMDs for huge pages like i386, x86_64 etc.
> > + */
> 
> How about:
> 
> /*
>  * Virtual memmap support for architectures that use Linux pagetables
>  * natively in hardware, and support mapping huge pages with PMD
>  * entries.
>  */
> 
> It wouldn't make sense to map the vmemmap area with Linux pagetables on
> an arch that didn't use them in hardware, right?  So, perhaps this
> doesn't quite belong in mm/sparse.c.  Perhaps we need
> arch/x86/sparse.c. ;)

I just extended this in V2 to also work on IA64. Its pretty generic.

> > +static void vmemmap_pop_pmd(pud_t *pud, unsigned long addr,
> > +				unsigned long end, int node)
> > +{
> > +	pmd_t *pmd;
> > +
> > +	end = pmd_addr_end(addr, end);
> > +
> > +	for (pmd = pmd_offset(pud, addr); addr < end;
> > +			pmd++, addr += PMD_SIZE) {
> > +  		if (pmd_none(*pmd)) {
> > +  			void *block;
> > +			pte_t pte;
> > +
> > +			block = vmemmap_alloc_block(PMD_SIZE, node);
> > +			pte = pfn_pte(__pa(block) >> PAGE_SHIFT,
> > +						PAGE_KERNEL);
> > +			pte_mkdirty(pte);
> > +			pte_mkwrite(pte);
> > +			pte_mkyoung(pte);
> > +			mk_pte_huge(pte);
> > +			set_pmd(pmd, __pmd(pte_val(pte)));
> > +		}
> > +	}
> > +}
> 
> Nitpick: I think this would look quite a bit neater with a little less
> indentation.
> 
> How about making the loop start with
> 
> 	if (!pmd_none(*pmd))
> 		continue;
> 
> It should bring the rest of the code in a bit and make that long line
> more readable.

V2 has the pmd setup separated out in a separate function.

> > +{
> > +	pgd_t *pgd;
> > +	unsigned long addr = (unsigned long)(start_page);
> > +	unsigned long end = pgd_addr_end(addr,
> > +			(unsigned long)((start_page + nr)));
> 
> There appear to be a few extra parentheses on these lines.

Right. Fixed.

> > +	for (pgd = pgd_offset_k(addr); addr < end;
> > +				pgd++, addr += PGDIR_SIZE) {
> > +
> > +		if (pgd_none(*pgd))
> > +			pgd_populate(&init_mm, pgd,
> > +				vmemmap_alloc_block(PAGE_SIZE, node));
> > +		vmemmap_pop_pud(pgd, addr, end, node);
> > +	}
> > +}
> > +#endif
> > +#endif /* CONFIG_SPARSE_VIRTUAL */
> 
> We don't really need these #ifdefs embedded inside of each other,
> either, right?  Kconfig should take care of enforcing the dependency.

Ok.

> > +#ifdef CONFIG_SPARSE_VIRTUAL
> > +	map = pfn_to_page(pnum * PAGES_PER_SECTION);
> > +	vmemmap_populate(map, PAGES_PER_SECTION, nid);
> > +#else
> >  	map = alloc_bootmem_node(NODE_DATA(nid),
> >  			sizeof(struct page) * PAGES_PER_SECTION);
> > +#endif
> 
> We really worked hard to keep #ifdefs out of the code flow in that file
> and keep it as clean as possible.  Could we hide this behind a helper?  

This is a major diffference in how sparsemem works. I think this needs to 
stay.

> 
>          map = alloc_remap(nid, sizeof(struct page) * PAGES_PER_SECTION);
>          if (map)
>                  return map;
> 
> +        map = alloc_vmemmap(map, PAGES_PER_SECTION, nid);
> +        if (map)
> +                return map;
> +
>          map = alloc_bootmem_node(NODE_DATA(nid),
>                          sizeof(struct page) * PAGES_PER_SECTION);
>          if (map)
>                  return map;
> 
> Then, do whatever magic you want in alloc_vmemmap().

That would break if alloc_vmemmap returns NULL because it cannot allocate 
memory.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
