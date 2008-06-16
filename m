Date: Mon, 16 Jun 2008 23:09:02 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [Patch 005/005](memory hotplug) free memmaps allocated by bootmem
In-Reply-To: <20080616104434.GG17016@shadowen.org>
References: <20080407214844.887A.E1E9C6FF@jp.fujitsu.com> <20080616104434.GG17016@shadowen.org>
Message-Id: <20080616220228.9EA5.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Yinghai Lu <yhlu.kernel@gmail.com>
List-ID: <linux-mm.kvack.org>

> > Index: current/mm/sparse.c
> > ===================================================================
> > --- current.orig/mm/sparse.c	2008-04-07 20:13:25.000000000 +0900
> > +++ current/mm/sparse.c	2008-04-07 20:27:20.000000000 +0900
> > @@ -8,6 +8,7 @@
> >  #include <linux/module.h>
> >  #include <linux/spinlock.h>
> >  #include <linux/vmalloc.h>
> > +#include "internal.h"
> >  #include <asm/dma.h>
> >  #include <asm/pgalloc.h>
> >  #include <asm/pgtable.h>
> > @@ -360,6 +361,9 @@
> >  {
> >  	return; /* XXX: Not implemented yet */
> >  }
> > +static void free_map_bootmem(struct page *page, unsigned long nr_pages)
> > +{
> > +}
> >  #else
> >  static struct page *__kmalloc_section_memmap(unsigned long nr_pages)
> >  {
> > @@ -397,17 +401,47 @@
> >  		free_pages((unsigned long)memmap,
> >  			   get_order(sizeof(struct page) * nr_pages));
> >  }
> > +
> > +static void free_map_bootmem(struct page *page, unsigned long nr_pages)
> > +{
> > +	unsigned long maps_section_nr, removing_section_nr, i;
> > +	int magic;
> > +
> > +	for (i = 0; i < nr_pages; i++, page++) {
> > +		magic = atomic_read(&page->_mapcount);
> > +
> > +		BUG_ON(magic == NODE_INFO);
> 
> Are we sure the node area was big enough to never allocate usemap's into
> it and change the magic to MIX?  I saw you make the section information
> page sized but not the others.

I don't think this is finish for removing whole of node. Just preparing.
I would like to make section removing at first rather than node.

> > +
> > +		maps_section_nr = pfn_to_section_nr(page_to_pfn(page));
> > +		removing_section_nr = page->private;
> > +
> > +		/*
> > +		 * When this function is called, the removing section is
> > +		 * logical offlined state. This means all pages are isolated
> > +		 * from page allocator. If removing section's memmap is placed
> > +		 * on the same section, it must not be freed.
> > +		 * If it is freed, page allocator may allocate it which will
> > +		 * be removed physically soon.
> > +		 */
> > +		if (maps_section_nr != removing_section_nr)
> > +			put_page_bootmem(page);
> 
> Would the section memmap have its own get_page_bootmem reference here?
> Would that not protect it from release?

It's not protected.



> > Index: current/mm/page_alloc.c
> > ===================================================================
> > --- current.orig/mm/page_alloc.c	2008-04-07 20:12:55.000000000 +0900
> > +++ current/mm/page_alloc.c	2008-04-07 20:13:29.000000000 +0900
> > @@ -568,7 +568,7 @@
> >  /*
> >   * permit the bootmem allocator to evade page validation on high-order frees
> >   */
> > -void __init __free_pages_bootmem(struct page *page, unsigned int order)
> > +void __free_pages_bootmem(struct page *page, unsigned int order)
> 
> not __meminit or something?

Ah, yes. I'll fix it.

Thanks for comments.

Bye.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
