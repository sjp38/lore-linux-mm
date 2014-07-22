Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id EDD7D6B0035
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 11:56:44 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id f8so695823wiw.0
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 08:56:43 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id qa1si1826099wjc.13.2014.07.22.08.56.41
        for <linux-mm@kvack.org>;
        Tue, 22 Jul 2014 08:56:42 -0700 (PDT)
Date: Tue, 22 Jul 2014 16:56:22 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCHv4 5/5] arm64: Add atomic pool for non-coherent and CMA
 allocations.
Message-ID: <20140722155622.GL2219@arm.com>
References: <1404324218-4743-1-git-send-email-lauraa@codeaurora.org>
 <1404324218-4743-6-git-send-email-lauraa@codeaurora.org>
 <20140718134343.GA4608@arm.com>
 <53CD9601.5070001@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53CD9601.5070001@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Will Deacon <Will.Deacon@arm.com>, David Riley <davidriley@chromium.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Ritesh Harjain <ritesh.harjani@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Jul 21, 2014 at 11:36:49PM +0100, Laura Abbott wrote:
> On 7/18/2014 6:43 AM, Catalin Marinas wrote:
> > On Wed, Jul 02, 2014 at 07:03:38PM +0100, Laura Abbott wrote:
> >> @@ -73,50 +124,56 @@ static void __dma_free_coherent(struct device *dev, size_t size,
> >>  				void *vaddr, dma_addr_t dma_handle,
> >>  				struct dma_attrs *attrs)
> >>  {
> >> +	bool freed;
> >> +	phys_addr_t paddr = dma_to_phys(dev, dma_handle);
> >> +
> >>  	if (dev == NULL) {
> >>  		WARN_ONCE(1, "Use an actual device structure for DMA allocation\n");
> >>  		return;
> >>  	}
> >>  
> >> -	if (IS_ENABLED(CONFIG_DMA_CMA)) {
> >> -		phys_addr_t paddr = dma_to_phys(dev, dma_handle);
> >>  
> >> -		dma_release_from_contiguous(dev,
> >> +	freed = dma_release_from_contiguous(dev,
> >>  					phys_to_page(paddr),
> >>  					size >> PAGE_SHIFT);
> >> -	} else {
> >> +	if (!freed)
> >>  		swiotlb_free_coherent(dev, size, vaddr, dma_handle);
> >> -	}
> >>  }
> > 
> > Is __dma_free_coherent() ever called in atomic context? If yes, the
> > dma_release_from_contiguous() may not like it since it tries to acquire
> > a mutex. But since we don't have the gfp flags here, we don't have an
> > easy way to know what to call.
> > 
> > So the initial idea of always calling __alloc_from_pool() for both
> > coherent/non-coherent cases would work better (but still with a single
> > shared pool, see below).
> 
> We should be okay
> 
> __dma_free_coherent -> dma_release_from_contiguous -> cma_release which
> bounds checks the CMA region before taking any mutexes unless I missed
> something.

Ah, good point. I missed the pfn range check in
dma_release_from_contiguous.

> The existing behavior on arm is to not allow non-atomic allocations to be
> freed atomic context when CMA is enabled so we'd be giving arm64 more
> leeway there.  Is being able to free non-atomic allocations in atomic
> context really necessary?

No. I was worried that an atomic coherent allocation (falling back to
swiotlb) would trigger some CMA mutex in atomic context on the freeing
path. But you are right, it shouldn't happen.

> >> +		page = dma_alloc_from_contiguous(NULL, nr_pages,
> >> +					get_order(atomic_pool_size));
> >> +	else
> >> +		page = alloc_pages(GFP_KERNEL, get_order(atomic_pool_size));
> > 
> > One problem here is that the atomic pool wouldn't be able to honour
> > GFP_DMA (in the latest kernel, CMA is by default in ZONE_DMA). You
> > should probably pass GFP_KERNEL|GFP_DMA here. You could also use the
> > swiotlb_alloc_coherent() which, with a NULL dev, assumes 32-bit DMA mask
> > but it still expects GFP_DMA to be passed.
> > 
> 
> I think I missed updating this to GFP_DMA. The only advantage I would see
> to using swiotlb_alloc_coherent vs. alloc_pages directly would be to
> allow the fallback to using a bounce buffer if __get_free_pages failed.
> I'll keep this as alloc_pages for now; it can be changed later if there
> is a particular need for swiotlb behavior.

That's fine. Since we don't have a device at this point, I don't see how
swiotlb could fall back to the bounce buffer.

Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
