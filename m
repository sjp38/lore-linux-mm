Date: Wed, 22 Aug 2007 10:28:54 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [Patch](memory hotplug) Hot-add with sparsemem-vmemmap
In-Reply-To: <20070821125922.GG11329@skynet.ie>
References: <20070817155908.7D91.Y-GOTO@jp.fujitsu.com> <20070821125922.GG11329@skynet.ie>
Message-Id: <20070822095447.05E5.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > Index: vmemmap/mm/sparse-vmemmap.c
> > ===================================================================
> > --- vmemmap.orig/mm/sparse-vmemmap.c	2007-08-10 20:17:19.000000000 +0900
> > +++ vmemmap/mm/sparse-vmemmap.c	2007-08-10 21:12:54.000000000 +0900
> > @@ -170,7 +170,7 @@ int __meminit vmemmap_populate(struct pa
> >  }
> >  #endif /* !CONFIG_ARCH_POPULATES_SPARSEMEM_VMEMMAP */
> >  
> > -struct page __init *sparse_early_mem_map_populate(unsigned long pnum, int nid)
> > +struct page *sparse_mem_map_populate(unsigned long pnum, int nid)
> 
> __meminit here instead of __init?

Ah, Yes. Thanks. I'll fix it.

>
> > Index: vmemmap/mm/sparse.c
> > ===================================================================
> > --- vmemmap.orig/mm/sparse.c	2007-08-10 20:17:19.000000000 +0900
> > +++ vmemmap/mm/sparse.c	2007-08-10 21:21:01.000000000 +0900
> > @@ -259,7 +259,7 @@ static unsigned long *sparse_early_usema
> >  }
> >  
> >  #ifndef CONFIG_SPARSEMEM_VMEMMAP
> > -struct page __init *sparse_early_mem_map_populate(unsigned long pnum, int nid)
> > +struct page __init *sparse_mem_map_populate(unsigned long pnum, int nid)
> 
> __meminit again possibly.

Here should use __init. It is called at boot time and uses
alloc_bootmem(). 


> >  #ifdef CONFIG_MEMORY_HOTPLUG
> > +#ifdef CONFIG_SPARSEMEM_VMEMMAP
> > +static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
> > +						 unsigned long nr_pages)
> > +{
> > +	return sparse_mem_map_populate(pnum, nid);
> > +}
> 
> In the other version of __kmalloc_section_memmap(), pages get allocated
> from alloc_pages() and it's obvious it's allocated there. A one line
> comment saying that sparse_mem_map_populate() will make the necessary
> allocations eventually would be nice.
> 
> Not a big deal though.

Ah, Ok. I'll add its comment.

Thanks.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
