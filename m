Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id l05FoAkb020961
	for <linux-mm@kvack.org>; Fri, 5 Jan 2007 10:50:10 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id l05FoAvD298270
	for <linux-mm@kvack.org>; Fri, 5 Jan 2007 10:50:10 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l05Fo9UX010668
	for <linux-mm@kvack.org>; Fri, 5 Jan 2007 10:50:10 -0500
Subject: Re: [patch] fix memmap accounting
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20070105145501.GA9602@osiris.boeblingen.de.ibm.com>
References: <20070105145501.GA9602@osiris.boeblingen.de.ibm.com>
Content-Type: text/plain
Date: Fri, 05 Jan 2007 07:50:01 -0800
Message-Id: <1168012201.8167.33.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-01-05 at 15:55 +0100, Heiko Carstens wrote:
> So the calculation of the number of pages needed for the memmap is wrong.
> It just doesn't work with virtual memmaps since it expects that all pages
> of a memmap are actually backed with physical pages which is not the case
> here.
> 
> This patch fixes it, but I guess something similar is also needed for
> SPARSEMEM and ia64 (with vmemmap).
...
> --- linux-2.6.orig/arch/s390/Kconfig
> +++ linux-2.6/arch/s390/Kconfig
> @@ -30,6 +30,9 @@ config ARCH_HAS_ILOG2_U64
>  	bool
>  	default n
> 
> +config ARCH_HAS_VMEMMAP
> +	def_bool y
> +
>  config GENERIC_HWEIGHT
>  	bool
>  	default y
> Index: linux-2.6/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.orig/mm/page_alloc.c
> +++ linux-2.6/mm/page_alloc.c
> @@ -2629,7 +2629,11 @@ static void __meminit free_area_init_cor
>  		 * is used by this zone for memmap. This affects the watermark
>  		 * and per-cpu initialisations
>  		 */
> +#ifdef CONFIG_ARCH_HAS_VMEMMAP
> +		memmap_pages = (realsize * sizeof(struct page)) >> PAGE_SHIFT;
> +#else
>  		memmap_pages = (size * sizeof(struct page)) >> PAGE_SHIFT;
> +#endif
>  		if (realsize >= memmap_pages) {
>  			realsize -= memmap_pages;
>  			printk(KERN_DEBUG

I'm not sure this is the right fix.  The same issues should, in theory,
be present for SPARSEMEM systems.  So, doing it by architecture alone is
probably a bad idea.  This also just kinda hacks around the problem.  In
any case, at least ia64 also has vmem_map[]s and needs it too.

I think the correct solution here is to either actually record how many
pages we allocate for mem_map[]s or keep the hole information so that it
can also be referenced in this area of the code.  I think the direct
accounting of how many pages went to mem_map[]s is probably best because
it tackles the problem more directly.  Otherwise, we potentially need to
expose the information about how mem_map[]s cover holes on _each_ of the
methods, and effectively recalculate it here.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
