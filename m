Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1CKxSAE023054
	for <linux-mm@kvack.org>; Tue, 12 Feb 2008 15:59:28 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1CKxS04245970
	for <linux-mm@kvack.org>; Tue, 12 Feb 2008 15:59:28 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1CKxRnf003953
	for <linux-mm@kvack.org>; Tue, 12 Feb 2008 15:59:28 -0500
Subject: Re: [-mm PATCH] register_memory/unregister_memory clean ups
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1202836953.25604.42.camel@dyn9047017100.beaverton.ibm.com>
References: <20080211114818.74c9dcc7.akpm@linux-foundation.org>
	 <1202765553.25604.12.camel@dyn9047017100.beaverton.ibm.com>
	 <20080212154309.F9DA.Y-GOTO@jp.fujitsu.com>
	 <1202836953.25604.42.camel@dyn9047017100.beaverton.ibm.com>
Content-Type: text/plain
Date: Tue, 12 Feb 2008 12:59:32 -0800
Message-Id: <1202849972.11188.71.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, greg@kroah.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-02-12 at 09:22 -0800, Badari Pulavarty wrote:
> +static void __remove_section(struct zone *zone, unsigned long phys_start_pfn)
> +{
> +	if (!pfn_valid(phys_start_pfn))
> +		return;

I think you need at least a WARN_ON() there.  

I'd probably also not use pfn_valid(), personally.  

> +	unregister_memory_section(__pfn_to_section(phys_start_pfn));
> +	__remove_zone(zone, phys_start_pfn);
> +	sparse_remove_one_section(zone, phys_start_pfn, PAGES_PER_SECTION);
> +}

Can none of this ever fail?

I also think having a function called __remove_section() that takes a
pfn is a bad idea.  How about passing an actual 'struct mem_section *'
into it?  One of the reasons I even made that structure was so that you
could hand it around to things and never be confused about pfn vs. paddr
vs. vaddr vs. section_nr.  Please use it.

>  /*
>   * Reasonably generic function for adding memory.  It is
>   * expected that archs that support memory hotplug will
> @@ -135,6 +153,21 @@ int __add_pages(struct zone *zone, unsig
>  }
>  EXPORT_SYMBOL_GPL(__add_pages);
> 
> +void __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
> +		 unsigned long nr_pages)
> +{
> +	unsigned long i;
> +	int start_sec, end_sec;
> +
> +	start_sec = pfn_to_section_nr(phys_start_pfn);
> +	end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
> +
> +	for (i = start_sec; i <= end_sec; i++)
> +		__remove_section(zone, i << PFN_SECTION_SHIFT);
> +
> +}
> +EXPORT_SYMBOL_GPL(__remove_pages);

I'd like to see some warnings in there if nr_pages or phys_start_pfn are
not section-aligned and some other sanity checks.  If someone is trying
to remove non-section-aligned areas, we either have something wrong, or
some other work to do, first keeping track of what section portions are
"removed".

I'd probably do:

void __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
  		    unsigned long nr_pages)
{
	int i;
	int sections_to_remove;

	/*
	 * We can only remove entire sections.
	 */
	if (phys_start_pfn & ~PAGE_SECTION_MASK)
		return ...;
	if (nr_pages % PAGES_PER_SECTION)
		return ...;
	sections_to_remove = nr_pages / PAGES_PER_SECTION;

	for (i = 0; i < sections_to_remove; i++) {
		unsigned long pfn = phys_start_pfn + i*PAGES_PER_SECTION;
		__remove_section(zone, __pfn_to_section(pfn));
	}
}
	

>  static void grow_zone_span(struct zone *zone,
>  		unsigned long start_pfn, unsigned long end_pfn)
>  {
> Index: linux-2.6.24/mm/sparse.c
> ===================================================================
> --- linux-2.6.24.orig/mm/sparse.c	2008-02-07 17:16:52.000000000 -0800
> +++ linux-2.6.24/mm/sparse.c	2008-02-11 14:12:28.000000000 -0800
> @@ -415,4 +415,44 @@ out:
>  	}
>  	return ret;
>  }
> +
> +void sparse_remove_one_section(struct zone *zone, unsigned long start_pfn,
> +			   int nr_pages)
> +{
> +	unsigned long section_nr = pfn_to_section_nr(start_pfn);
> +	struct pglist_data *pgdat = zone->zone_pgdat;
> +	struct mem_section *ms;
> +	struct page *memmap = NULL;
> +	unsigned long *usemap = NULL;
> +	unsigned long flags;
> +
> +	pgdat_resize_lock(pgdat, &flags);
> +	ms = __pfn_to_section(start_pfn);
> +	if (ms->section_mem_map) {
> +		memmap = ms->section_mem_map & SECTION_MAP_MASK;

You're abusing this memmap variable.  Please make another variable
that's unsigned long and has a nice name if you're actually going to
store an 'unsigned long' in it.  That cast below should be a big red
flag.

> +		usemap = ms->pageblock_flags;
> +		memmap = sparse_decode_mem_map((unsigned long)memmap,
> +				section_nr);
> +		ms->section_mem_map = 0;
> +		ms->pageblock_flags = NULL;
> +	}
> +	pgdat_resize_unlock(pgdat, &flags);

Ugh.  Please put this in its own helper.  Also, sparse_decode_mem_map()
has absolutely no other users.  Please modify it so that you don't have
to do this gunk, like put the '& SECTION_MAP_MASK' in there.  You
probably just need:

struct page *sparse_decode_mem_map(unsigned long coded_mem_map, unsigned long pnum)
{
	/*
	 * mask off the extra low bits of information
	 */
	coded_mem_map &= SECTION_MAP_MASK;
        return ((struct page *)coded_mem_map) + section_nr_to_pfn(pnum);
}

Then, you can just do this:

	memmap = sparse_decode_mem_map(ms->section_mem_map, section_nr);

No casting, no temp variables.  *PLEASE* look around at things and feel
free to modify to modify them.  Otherwise, it'll just become a mess.
(oh, and get rid of the unused attribute on it).

> +
> +	/*
> +	 * Its ugly, but this is the best I can do - HELP !!
> +	 * We don't know where the allocations for section memmap and usemap
> +	 * came from. If they are allocated at the boot time, they would come
> +	 * from bootmem. If they are added through hot-memory-add they could be
> +	 * from sla or vmalloc. If they are allocated as part of hot-mem-add
> +	 * free them up properly. If they are allocated at boot, no easy way
> +	 * to correctly free them :(
> +	 */
> +	if (usemap) {
> +		if (PageSlab(virt_to_page(usemap))) {
> +			kfree(usemap);
> +			if (memmap)
> +				__kfree_section_memmap(memmap, nr_pages);
> +		}
> +	}
> +}

Do what we did with the memmap and store some of its origination
information in the low bits.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
