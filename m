Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id C9C8F6B00D8
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 22:38:11 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id v10so5544836pde.37
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 19:38:11 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id an4si1160499pad.149.2014.06.09.19.38.09
        for <linux-mm@kvack.org>;
        Mon, 09 Jun 2014 19:38:10 -0700 (PDT)
Date: Tue, 10 Jun 2014 11:41:57 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 1/3] CMA: generalize CMA reserved area management
 functionality
Message-ID: <20140610024157.GA19036@js1304-P5Q-DELUXE>
References: <1401757919-30018-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1401757919-30018-2-git-send-email-iamjoonsoo.kim@lge.com>
 <xa1tzjhujxbz.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <xa1tzjhujxbz.fsf@mina86.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Tue, Jun 03, 2014 at 08:56:00AM +0200, Michal Nazarewicz wrote:
> On Tue, Jun 03 2014, Joonsoo Kim wrote:
> > Currently, there are two users on CMA functionality, one is the DMA
> > subsystem and the other is the kvm on powerpc. They have their own code
> > to manage CMA reserved area even if they looks really similar.
> > From my guess, it is caused by some needs on bitmap management. Kvm side
> > wants to maintain bitmap not for 1 page, but for more size. Eventually it
> > use bitmap where one bit represents 64 pages.
> >
> > When I implement CMA related patches, I should change those two places
> > to apply my change and it seem to be painful to me. I want to change
> > this situation and reduce future code management overhead through
> > this patch.
> >
> > This change could also help developer who want to use CMA in their
> > new feature development, since they can use CMA easily without
> > copying & pasting this reserved area management code.
> >
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Some small comments below, but in general
> 
> Acked-by: Michal Nazarewicz <mina86@mina86.com>

Hello, Michal.

Thanks!

> 
> >
> > diff --git a/include/linux/cma.h b/include/linux/cma.h
> > new file mode 100644
> > index 0000000..60ba06f
> > --- /dev/null
> > +++ b/include/linux/cma.h
> > @@ -0,0 +1,28 @@
> > +/*
> > + * Contiguous Memory Allocator
> > + *
> > + * Copyright LG Electronics Inc., 2014
> > + * Written by:
> > + *	Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > + *
> > + * This program is free software; you can redistribute it and/or
> > + * modify it under the terms of the GNU General Public License as
> > + * published by the Free Software Foundation; either version 2 of the
> > + * License or (at your optional) any later version of the license.
> > + *
> 
> Superfluous empty comment line.
> 
> Also, I'm not certain whether this copyright notice is appropriate here,
> but that's another story.

Yeah, I will remove copyright notice in .h file.

> 
> > + */
> > +
> > +#ifndef __CMA_H__
> > +#define __CMA_H__
> > +
> > +struct cma;
> > +
> > +extern struct page *cma_alloc(struct cma *cma, unsigned long count,
> > +				unsigned long align);
> > +extern bool cma_release(struct cma *cma, struct page *pages,
> > +				unsigned long count);
> > +extern int __init cma_declare_contiguous(phys_addr_t size, phys_addr_t base,
> > +				phys_addr_t limit, phys_addr_t alignment,
> > +				unsigned long bitmap_shift, bool fixed,
> > +				struct cma **res_cma);
> > +#endif
> 
> > diff --git a/mm/cma.c b/mm/cma.c
> > new file mode 100644
> > index 0000000..0dae88d
> > --- /dev/null
> > +++ b/mm/cma.c
> > @@ -0,0 +1,329 @@
> 
> > +static int __init cma_activate_area(struct cma *cma)
> > +{
> > +	int max_bitmapno = cma_bitmap_max_no(cma);
> > +	int bitmap_size = BITS_TO_LONGS(max_bitmapno) * sizeof(long);
> > +	unsigned long base_pfn = cma->base_pfn, pfn = base_pfn;
> > +	unsigned i = cma->count >> pageblock_order;
> > +	struct zone *zone;
> > +
> > +	pr_debug("%s()\n", __func__);
> > +	if (!cma->count)
> > +		return 0;
> 
> Alternatively:
> 
> +	if (!i)
> +		return 0;

I prefer cma->count than i, since it represents what it does itself.

> > +
> > +	cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
> > +	if (!cma->bitmap)
> > +		return -ENOMEM;
> > +
> > +	WARN_ON_ONCE(!pfn_valid(pfn));
> > +	zone = page_zone(pfn_to_page(pfn));
> > +
> > +	do {
> > +		unsigned j;
> > +
> > +		base_pfn = pfn;
> > +		for (j = pageblock_nr_pages; j; --j, pfn++) {
> > +			WARN_ON_ONCE(!pfn_valid(pfn));
> > +			/*
> > +			 * alloc_contig_range requires the pfn range
> > +			 * specified to be in the same zone. Make this
> > +			 * simple by forcing the entire CMA resv range
> > +			 * to be in the same zone.
> > +			 */
> > +			if (page_zone(pfn_to_page(pfn)) != zone)
> > +				goto err;
> > +		}
> > +		init_cma_reserved_pageblock(pfn_to_page(base_pfn));
> > +	} while (--i);
> > +
> > +	mutex_init(&cma->lock);
> > +	return 0;
> > +
> > +err:
> > +	kfree(cma->bitmap);
> > +	return -EINVAL;
> > +}
> 
> > +static int __init cma_init_reserved_areas(void)
> > +{
> > +	int i;
> > +
> > +	for (i = 0; i < cma_area_count; i++) {
> > +		int ret = cma_activate_area(&cma_areas[i]);
> > +
> > +		if (ret)
> > +			return ret;
> > +	}
> > +
> > +	return 0;
> > +}
> 
> Or even:
> 
> static int __init cma_init_reserved_areas(void)
> {
> 	int i, ret = 0;
> 	for (i = 0; !ret && i < cma_area_count; ++i)
> 		ret = cma_activate_area(&cma_areas[i]);
> 	return ret;
> }

I think that originial implementation is better, since it seems
more readable to me.

> > +int __init cma_declare_contiguous(phys_addr_t size, phys_addr_t base,
> > +				phys_addr_t limit, phys_addr_t alignment,
> > +				unsigned long bitmap_shift, bool fixed,
> > +				struct cma **res_cma)
> > +{
> > +	struct cma *cma = &cma_areas[cma_area_count];
> 
> Perhaps it would make sense to move this initialisation to the far end
> of this function?

Yes, I will move it down.

> > +	int ret = 0;
> > +
> > +	pr_debug("%s(size %lx, base %08lx, limit %08lx, alignment %08lx)\n",
> > +			__func__, (unsigned long)size, (unsigned long)base,
> > +			(unsigned long)limit, (unsigned long)alignment);
> > +
> > +	/* Sanity checks */
> > +	if (cma_area_count == ARRAY_SIZE(cma_areas)) {
> > +		pr_err("Not enough slots for CMA reserved regions!\n");
> > +		return -ENOSPC;
> > +	}
> > +
> > +	if (!size)
> > +		return -EINVAL;
> > +
> > +	/*
> > +	 * Sanitise input arguments.
> > +	 * CMA area should be at least MAX_ORDER - 1 aligned. Otherwise,
> > +	 * CMA area could be merged into other MIGRATE_TYPE by buddy mechanism
> > +	 * and CMA property will be broken.
> > +	 */
> > +	alignment >>= PAGE_SHIFT;
> > +	alignment = PAGE_SIZE << max3(MAX_ORDER - 1, pageblock_order,
> > +						(int)alignment);
> > +	base = ALIGN(base, alignment);
> > +	size = ALIGN(size, alignment);
> > +	limit &= ~(alignment - 1);
> > +	/* size should be aligned with bitmap_shift */
> > +	BUG_ON(!IS_ALIGNED(size >> PAGE_SHIFT, 1 << cma->bitmap_shift));
> 
> cma->bitmap_shift is not yet initialised thus the above line should be:
> 
> 	BUG_ON(!IS_ALIGNED(size >> PAGE_SHIFT, 1 << bitmap_shift));

Yes, I will fix it.

> > +
> > +	/* Reserve memory */
> > +	if (base && fixed) {
> > +		if (memblock_is_region_reserved(base, size) ||
> > +		    memblock_reserve(base, size) < 0) {
> > +			ret = -EBUSY;
> > +			goto err;
> > +		}
> > +	} else {
> > +		phys_addr_t addr = memblock_alloc_range(size, alignment, base,
> > +							limit);
> > +		if (!addr) {
> > +			ret = -ENOMEM;
> > +			goto err;
> > +		} else {
> > +			base = addr;
> > +		}
> > +	}
> > +
> > +	/*
> > +	 * Each reserved area must be initialised later, when more kernel
> > +	 * subsystems (like slab allocator) are available.
> > +	 */
> > +	cma->base_pfn = PFN_DOWN(base);
> > +	cma->count = size >> PAGE_SHIFT;
> > +	cma->bitmap_shift = bitmap_shift;
> > +	*res_cma = cma;
> > +	cma_area_count++;
> > +
> > +	pr_info("CMA: reserved %ld MiB at %08lx\n", (unsigned long)size / SZ_1M,
> > +		(unsigned long)base);
> 
> Doesn't this message end up being: a??cma: CMA: reserved a?|a??? pr_fmt adds
> a??cma:a?? at the beginning, doesn't it?  So we should probably drop a??CMA:a??
> here.

Okay. Will do.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
