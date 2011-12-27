Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id BC1736B004F
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 03:25:40 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from euspt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LWU00326SQQ4Q20@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 27 Dec 2011 08:25:38 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LWU00IWXSQQN9@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 27 Dec 2011 08:25:38 +0000 (GMT)
Date: Tue, 27 Dec 2011 09:25:25 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 00/14] DMA-mapping framework redesign preparation
In-reply-to: <20111223163516.GO20129@parisc-linux.org>
Message-id: <000901ccc471$15db8bc0$4192a340$%szyprowski@samsung.com>
Content-language: pl
References: <1324643253-3024-1-git-send-email-m.szyprowski@samsung.com>
 <20111223163516.GO20129@parisc-linux.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Matthew Wilcox' <matthew@wil.cx>
Cc: linux-kernel@vger.kernel.org, 'Benjamin Herrenschmidt' <benh@kernel.crashing.org>, 'Thomas Gleixner' <tglx@linutronix.de>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Arnd Bergmann' <arnd@arndb.de>, 'Stephen Rothwell' <sfr@canb.auug.org.au>, microblaze-uclinux@itee.uq.edu.au, linux-arch@vger.kernel.org, x86@kernel.org, linux-sh@vger.kernel.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, discuss@x86-64.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Jonathan Corbet' <corbet@lwn.net>, 'Kyungmin Park' <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>

Hello,

On Friday, December 23, 2011 5:35 PM Matthew Wilcox wrote:

> On Fri, Dec 23, 2011 at 01:27:19PM +0100, Marek Szyprowski wrote:
> > The first issue we identified is the fact that on some platform (again,
> > mainly ARM) there are several functions for allocating DMA buffers:
> > dma_alloc_coherent, dma_alloc_writecombine and dma_alloc_noncoherent
> 
> Is this write-combining from the point of view of the device (ie iommu),
> or from the point of view of the CPU, or both?

It is about write-combining from the CPU point of view. Right now there are
no devices with such advanced memory interface to do write combining on the
DMA side, but I believe that they might appear at some point in the future 
as well.

> > The next step in dma mapping framework update is the introduction of
> > dma_mmap/dma_mmap_attrs() function. There are a number of drivers
> > (mainly V4L2 and ALSA) that only exports the DMA buffers to user space.
> > Creating a userspace mapping with correct page attributes is not an easy
> > task for the driver. Also the DMA-mapping framework is the only place
> > where the complete information about the allocated pages is available,
> > especially if the implementation uses IOMMU controller to provide a
> > contiguous buffer in DMA address space which is scattered in physical
> > memory space.
> 
> Surely we only need a helper which drivrs can call from their mmap routine
> to solve this?

On ARM architecture it is already implemented this way and a bunch of drivers
use dma_mmap_coherent/dma_mmap_writecombine calls. We would like to standardize
these calls across all architectures.

> > Usually these drivers don't touch the buffer data at all, so the mapping
> > in kernel virtual address space is not needed. We can introduce
> > DMA_ATTRIB_NO_KERNEL_MAPPING attribute which lets kernel to skip/ignore
> > creation of kernel virtual mapping. This way we can save previous
> > vmalloc area and simply some mapping operation on a few architectures.
> 
> I really think this wants to be a separate function.  dma_alloc_coherent
> is for allocating memory to be shared between the kernel and a driver;
> we already have dma_map_sg for mapping userspace I/O as an alternative
> interface.  This feels like it's something different again rather than
> an option to dma_alloc_coherent.

That is just a starting point for the discussion. 

I thought about this API a bit and came to conclusion that there is no much
difference between a dma_alloc_coherent which creates a mapping in kernel
virtual space and the one that does not. It is just a hint from the driver
that it will not use that mapping at all. Of course this attribute makes sense
only together with adding a dma_mmap_attrs() call, because otherwise drivers
won't be able to get access to the buffer data.

On coherent architectures where dma_alloc_coherent is just a simple wrapper
around alloc_pages_exact() such attribute can be simply ignored without any
impact on the drivers (that's the main idea behind dma attributes!).
However such hint will help a lot on non-coherent architectures where 
additional work need to be done to provide a cohenent mapping in kernel 
address space. It also saves some precious kernel resources like vmalloc
address range.

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
