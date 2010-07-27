Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9F5B3600365
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 04:13:34 -0400 (EDT)
From: Milton Miller <miltonm@bga.com>
Message-Id: <pfn.valid.v4.reply.2@mdm.bga.com>
In-Reply-To: <AANLkTimtTVvorrR9pDVTyPKj0HbYOYY3aR7B-QWGhTei@mail.gmail.com>
References: <1280159163-23386-1-git-send-email-minchan.kim@gmail.com>
	<alpine.DEB.2.00.1007261136160.5438@router.home>
	<pfn.valid.v4.reply.1@mdm.bga.com>
	<AANLkTimtTVvorrR9pDVTyPKj0HbYOYY3aR7B-QWGhTei@mail.gmail.com>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v4
Date: Tue, 27 Jul 2010 03:12:38 -0500
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@arm.linux.org.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Kukjin Kim <kgene.kim@samsung.com>
List-ID: <linux-mm.kvack.org>


On Tue Jul 27 2010 about 02:11:22 Minchan Kim wrote:
> > [Sorry if i missed or added anyone on cc, patchwork.kernel.org  LKML is not
> > working and I'm not subscribed to the list ]
> 
> Readd them. :)

Changed linux-mmc at vger to linxu-mm at kvack.org, from my poor use of grep 
MAINTAINERS.

> On Tue, Jul 27, 2010 at 2:55 PM, <miltonm@xxxxxxx> wrote:
> > On Mon Jul 26 2010 about 12:47:37 EST, Christoph Lameter wrote:
> > > On Tue, 27 Jul 2010, Minchan Kim wrote:
> > >
> > > > This patch registers address of mem_section to memmap itself's page struct's
> > > > pg->private field. This means the page is used for memmap of the section.
> > > > Otherwise, the page is used for other purpose and memmap has a hole.
> >
> > >
> > > > +void mark_valid_memmap(unsigned long start, unsigned long end);
> > > > +
> > > > +#ifdef CONFIG_ARCH_HAS_HOLES_MEMORYMODEL
> > > > +static inline int memmap_valid(unsigned long pfn)
> > > > +{
> > > > + struct page *page = pfn_to_page(pfn);
> > > > + struct page *__pg = virt_to_page(page);
> > > > + return page_private(__pg) == (unsigned long)__pg;
> > >
> > >
> > > What if page->private just happens to be the value of the page struct?
> > > Even if that is not possible today, someday someone may add new
> > > functionality to the kernel where page->pivage == page is used for some
> > > reason.
> > >
> > > Checking for PG_reserved wont work?
> >
> > I had the same thought and suggest setting it to the memory section block,
> > since that is a uniquie value (unlike PG_reserved),
> 
> You mean setting pg->private to mem_section address?
> I hope I understand your point.
> 
> Actually, KAMEZAWA tried it at first version but I changed it.
> That's because I want to support this mechanism to ARM FLATMEM.
> (It doesn't have mem_section)

> >
> > .. and we already have computed it when we use it so we could pass it as
> > a parameter (to both _valid and mark_valid).
> 
> I hope this can support FALTMEM which have holes(ex, ARM).
> 

If we pass a void * to this helper we should be able to find another
symbol.  Looking at the pfn_valid() in arch/arm/mm/init.c I would
probably choose &meminfo as it is already used nearby, and using a single
symbol in would avoid issues if a more specific symbol chosen (eg bank)
were to change at a pfn boundary not PAGE_SIZE / sizeof(struct page).
Similarly the asm-generic/page.h version could use &max_mapnr.

This function is a validation helper for pfn_valid not the only check.

something like

static inline int memmap_valid(unsigned long pfn, void *validate)
{
	struct page *page = pfn_to_page(pfn);
	struct page *__pg = virt_to_page(page);
	return page_private(__pg) == validate;
}

static inline int pfn_valid(unsigned long pfn)
{
	struct mem_section *ms;
	if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
		return 0;
	ms = __nr_to_section(pfn_to_section_nr(pfn));
	return valid_section(ms) && memmap_valid(pfn, ms);
}

> > > > +/*
> > > > + * Fill pg->private on valid mem_map with page itself.
> > > > + * pfn_valid() will check this later. (see include/linux/mmzone.h)
> > > > + * Every arch for supporting hole of mem_map should call
> > > > + * mark_valid_memmap(start, end). please see usage in ARM.
> > > > + */
> > > > +void mark_valid_memmap(unsigned long start, unsigned long end)
> > > > +{
> > > > +	struct mem_section *ms;
> > > > +	unsigned long pos, next;
> > > > +	struct page *pg;
> > > > +	void *memmap, *mapend;
> > > > +
> > > > +	for (pos = start; pos < end; pos = next) {
> > > > +		next = (pos + PAGES_PER_SECTION) & PAGE_SECTION_MASK;
> > > > +		ms = __pfn_to_section(pos);
> > > > +		if (!valid_section(ms))
> > > > +			continue;
> > > > +	
> > > > +		for (memmap = (void*)pfn_to_page(pos),
> > > > +					/* The last page in section */
> > > > +					mapend = pfn_to_page(next-1);
> > > > +				memmap < mapend; memmap += PAGE_SIZE) {
> > > > +			pg = virt_to_page(memmap);
> > > > +			set_page_private(pg, (unsigned long)pg);
> > > > +		}
> > > > +	}
> > > > +}

Hmm, this loop would need to change for sections.   And sizeof(struct
page) % PAGE_SIZE may not be 0, so we want a global symbol for sparsemem
too.  Perhaps the mem_section array.  Using a symbol that is part of
the model pre-checks can remove a global symbol lookup and has the side
effect of making sure our pfn_valid is for the right model.

milton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
