Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 3B64E6B016B
	for <linux-mm@kvack.org>; Tue, 16 Aug 2011 05:30:14 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from eu_spt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LQ00056JL2BM1A0@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 16 Aug 2011 10:30:11 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LQ00096SL2AI4@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 16 Aug 2011 10:30:10 +0100 (BST)
Date: Tue, 16 Aug 2011 11:29:37 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 8/9] ARM: integrate CMA with DMA-mapping subsystem
In-reply-to: <201108121700.30967.arnd@arndb.de>
Message-id: <002b01cc5bf7$0460e350$0d22a9f0$%szyprowski@samsung.com>
Content-language: pl
References: <1313146711-1767-1-git-send-email-m.szyprowski@samsung.com>
 <1313146711-1767-9-git-send-email-m.szyprowski@samsung.com>
 <201108121700.30967.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Arnd Bergmann' <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Daniel Walker' <dwalker@codeaurora.org>, 'Russell King' <linux@arm.linux.org.uk>, 'Jonathan Corbet' <corbet@lwn.net>, 'Mel Gorman' <mel@csn.ul.ie>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Michal Nazarewicz' <mina86@mina86.com>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>

Hello,

On Friday, August 12, 2011 5:01 PM Arnd Bergmann wrote:

> On Friday 12 August 2011, Marek Szyprowski wrote:
> > @@ -82,16 +103,16 @@ static struct page *__dma_alloc_buffer(struct device
*dev,
> size_t size, gfp_t gf
> >  	if (mask < 0xffffffffULL)
> >  		gfp |= GFP_DMA;
> >
> > -	page = alloc_pages(gfp, order);
> > -	if (!page)
> > -		return NULL;
> > -
> >  	/*
> > -	 * Now split the huge page and free the excess pages
> > +	 * Allocate contiguous memory
> >  	 */
> > -	split_page(page, order);
> > -	for (p = page + (size >> PAGE_SHIFT), e = page + (1 << order); p < e;
p++)
> > -		__free_page(p);
> > +	if (cma_available())
> > +		page = dma_alloc_from_contiguous(dev, count, order);
> > +	else
> > +		page = __dma_alloc_system_pages(count, gfp, order);
> > +
> > +	if (!page)
> > +		return NULL;
> 
> Why do you need the fallback here? I would assume that CMA now has to be
available
> on ARMv6 and up to work at all. When you allocate from
__dma_alloc_system_pages(),
> wouldn't that necessarily fail in the dma_remap_area() stage?

It is not a fallback - I've just merged 2 cases together (CMA case and
coheren/nommu
arch). I agree that such mixed code might be confusing.

> >
> > -	if (arch_is_coherent() || nommu()) {
> > +	if (arch_is_coherent() || nommu() ||
> > +	   (cma_available() && !(gfp & GFP_ATOMIC))) {
> > +		/*
> > +		 * Allocate from system or CMA pages
> > +		 */
> >  		struct page *page = __dma_alloc_buffer(dev, size, gfp);
> >  		if (!page)
> >  			return NULL;
> > +		dma_remap_area(page, size, area->prot);
> >  		pfn = page_to_pfn(page);
> >  		ret = page_address(page);
> 
> Similarly with coherent and nommu. It seems to me that lumping too
> many cases together creates extra complexity here.
> 
> How about something like
> 
> 	if (arch_is_coherent() || nommu())
> 		ret = alloc_simple_buffer();
> 	else if (arch_is_v4_v5())
> 		ret = alloc_remap();
> 	else if (gfp & GFP_ATOMIC)
> 		ret = alloc_from_pool();
> 	else
> 		ret = alloc_from_contiguous();
> 
> This also allows a natural conversion to dma_map_ops when we get there.

Ok. Is it ok to enable CMA permanently for ARMv6+? If CMA is left conditional
the dma pool code will be much more complicated, because it will need to support
both CMA and non-CMA cases.

> >  	/* reserve any platform specific memblock areas */
> >  	if (mdesc->reserve)
> >  		mdesc->reserve();
> >
> > +	dma_coherent_reserve();
> > +	dma_contiguous_reserve();
> > +
> >  	memblock_analyze();
> >  	memblock_dump_all();
> >  }
> 
> Since we can handle most allocations using CMA on ARMv6+, I would think
> that we can have a much smaller reserved area. Have you tried changing
> dma_coherent_reserve() to allocate out of the contiguous area instead of
> wasting a full 2MB section of memory?

I will move the reserved pool directly into CMA area, so it can be shrunk below
2MiB.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
