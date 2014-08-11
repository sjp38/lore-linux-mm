Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id D95AF6B0037
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 14:06:10 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id b13so8697250wgh.6
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 11:06:10 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id v11si27382311wjr.176.2014.08.11.11.06.09
        for <linux-mm@kvack.org>;
        Mon, 11 Aug 2014 11:06:09 -0700 (PDT)
Date: Mon, 11 Aug 2014 19:05:42 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCHv6 3/5] common: dma-mapping: Introduce common remapping
 functions
Message-ID: <20140811180542.GI13871@arm.com>
References: <1407529397-6642-1-git-send-email-lauraa@codeaurora.org>
 <1407529397-6642-3-git-send-email-lauraa@codeaurora.org>
 <20140808154556.11c7bf68d1bcf2714c148e3b@linux-foundation.org>
 <53E55C86.3040705@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53E55C86.3040705@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Riley <davidriley@chromium.org>, Arnd Bergmann <arnd@arndb.de>, Will Deacon <Will.Deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thierry Reding <thierry.reding@gmail.com>, Ritesh Harjain <ritesh.harjani@gmail.com>, Russell King <linux@arm.linux.org.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Sat, Aug 09, 2014 at 12:25:58AM +0100, Laura Abbott wrote:
> On 8/8/2014 3:45 PM, Andrew Morton wrote:
> > On Fri,  8 Aug 2014 13:23:15 -0700 Laura Abbott <lauraa@codeaurora.org> wrote:
> >> For architectures without coherent DMA, memory for DMA may
> >> need to be remapped with coherent attributes. Factor out
> >> the the remapping code from arm and put it in a
> >> common location to reduce code duplication.
> >>
> >> As part of this, the arm APIs are now migrated away from
> >> ioremap_page_range to the common APIs which use map_vm_area for remapping.
> >> This should be an equivalent change and using map_vm_area is more
> >> correct as ioremap_page_range is intended to bring in io addresses
> >> into the cpu space and not regular kernel managed memory.
> >>
> >> ...
> >>
> >> @@ -267,3 +269,68 @@ int dma_common_mmap(struct device *dev, struct vm_area_struct *vma,
> >>  	return ret;
> >>  }
> >>  EXPORT_SYMBOL(dma_common_mmap);
> >> +
> >> +/*
> >> + * remaps an allocated contiguous region into another vm_area.
> >> + * Cannot be used in non-sleeping contexts
> >> + */
> >> +
> >> +void *dma_common_contiguous_remap(struct page *page, size_t size,
> >> +			unsigned long vm_flags,
> >> +			pgprot_t prot, const void *caller)
> >> +{
> >> +	int i;
> >> +	struct page **pages;
> >> +	void *ptr;
> >> +
> >> +	pages = kmalloc(sizeof(struct page *) << get_order(size), GFP_KERNEL);
> >> +	if (!pages)
> >> +		return NULL;
> >> +
> >> +	for (i = 0; i < (size >> PAGE_SHIFT); i++)
> >> +		pages[i] = page + i;
> > 
> > Assumes a single mem_map[] array.  That's not the case for sparsemem
> > (at least).
> 
> Good point. I guess the best option is to increment via pfn and call
> pfn_to_page. Either that or go back to slightly abusing
> ioremap_page_range to remap normal memory.

I now noticed you suggested the pfn_to_page(). I think this should work
and it's better than ioremap_page_range().

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
