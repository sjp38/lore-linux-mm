Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 632416B0035
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 14:05:17 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id bs8so4676316wib.9
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 11:05:16 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id l1si18958179wif.13.2014.08.11.11.05.14
        for <linux-mm@kvack.org>;
        Mon, 11 Aug 2014 11:05:14 -0700 (PDT)
Date: Mon, 11 Aug 2014 19:04:36 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCHv6 3/5] common: dma-mapping: Introduce common remapping
 functions
Message-ID: <20140811180436.GH13871@arm.com>
References: <1407529397-6642-1-git-send-email-lauraa@codeaurora.org>
 <1407529397-6642-3-git-send-email-lauraa@codeaurora.org>
 <20140808154556.11c7bf68d1bcf2714c148e3b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140808154556.11c7bf68d1bcf2714c148e3b@linux-foundation.org>
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Laura Abbott <lauraa@codeaurora.org>, Will Deacon <Will.Deacon@arm.com>, Russell King <linux@arm.linux.org.uk>, David Riley <davidriley@chromium.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Ritesh Harjain <ritesh.harjani@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thierry Reding <thierry.reding@gmail.com>, Arnd Bergmann <arnd@arndb.de>

On Fri, Aug 08, 2014 at 11:45:56PM +0100, Andrew Morton wrote:
> On Fri,  8 Aug 2014 13:23:15 -0700 Laura Abbott <lauraa@codeaurora.org> wrote:
> > For architectures without coherent DMA, memory for DMA may
> > need to be remapped with coherent attributes. Factor out
> > the the remapping code from arm and put it in a
> > common location to reduce code duplication.
> > 
> > As part of this, the arm APIs are now migrated away from
> > ioremap_page_range to the common APIs which use map_vm_area for remapping.
> > This should be an equivalent change and using map_vm_area is more
> > correct as ioremap_page_range is intended to bring in io addresses
> > into the cpu space and not regular kernel managed memory.
> > 
> > ...
> >
> > @@ -267,3 +269,68 @@ int dma_common_mmap(struct device *dev, struct vm_area_struct *vma,
> >  	return ret;
> >  }
> >  EXPORT_SYMBOL(dma_common_mmap);
> > +
> > +/*
> > + * remaps an allocated contiguous region into another vm_area.
> > + * Cannot be used in non-sleeping contexts
> > + */
> > +
> > +void *dma_common_contiguous_remap(struct page *page, size_t size,
> > +			unsigned long vm_flags,
> > +			pgprot_t prot, const void *caller)
> > +{
> > +	int i;
> > +	struct page **pages;
> > +	void *ptr;
> > +
> > +	pages = kmalloc(sizeof(struct page *) << get_order(size), GFP_KERNEL);
> > +	if (!pages)
> > +		return NULL;
> > +
> > +	for (i = 0; i < (size >> PAGE_SHIFT); i++)
> > +		pages[i] = page + i;
> 
> Assumes a single mem_map[] array.  That's not the case for sparsemem
> (at least).

Good point. The "page" pointer (and memory range) passed to this
function has been allocated with alloc_pages(), so the range is
guaranteed to be physically contiguous but it does not imply a single
mem_map[] array. For arm64 with SPARSEMEM_VMEMMAP_ENABLE it's safe but
not all architectures use this (especially on 32-bit).

What about using pfn_to_page(pfn + i)?

Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
