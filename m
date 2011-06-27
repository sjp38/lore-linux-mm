Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 05AB06B007E
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 08:24:39 -0400 (EDT)
Received: from spt2.w1.samsung.com (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LNG00HIH7RLAH@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Mon, 27 Jun 2011 13:23:45 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LNG002IJ7RJEO@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Jun 2011 13:23:44 +0100 (BST)
Date: Mon, 27 Jun 2011 14:23:40 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 7/8] common: dma-mapping: change alloc/free_coherent method
 to more generic alloc/free_attrs
In-reply-to: <201106241751.35655.arnd@arndb.de>
Message-id: <000701cc34c5$0c50b800$24f22800$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
 <1308556213-24970-8-git-send-email-m.szyprowski@samsung.com>
 <201106241751.35655.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Arnd Bergmann' <arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Joerg Roedel' <joro@8bytes.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>

Hello,

On Friday, June 24, 2011 5:52 PM Arnd Bergmann wrote:

> On Monday 20 June 2011, Marek Szyprowski wrote:
> > Introduce new alloc/free/mmap methods that take attributes argument.
> > alloc/free_coherent can be implemented on top of the new alloc/free
> > calls with NULL attributes. dma_alloc_non_coherent can be implemented
> > using DMA_ATTR_NONCOHERENT attribute, dma_alloc_writecombine can also
> > use separate DMA_ATTR_WRITECOMBINE attribute. This way the drivers will
> > get more generic, platform independent way of allocating dma memory
> > buffers with specific parameters.
> >
> > One more attribute can be usefull: DMA_ATTR_NOKERNELVADDR. Buffers with
> > such attribute will not have valid kernel virtual address. They might be
> > usefull for drivers that only exports the DMA buffers to userspace (like
> > for example V4L2 or ALSA).
> >
> > mmap method is introduced to let the drivers create a user space mapping
> > for a DMA buffer in generic, architecture independent way.
> >
> > TODO: update all dma_map_ops clients for all architectures
> >
> > Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> > Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> 
> Yes, I think that is good, but the change needs to be done atomically
> across all architectures.

Yes, I'm aware of this and I will include such changes in the next version
of my patches.

> This should be easy enough as I believe
> all other architectures that use dma_map_ops don't even require
> dma_alloc_noncoherent but just define it to dma_alloc_coherent
> because they have only coherent memory in regular device drivers.

Right, this should be quite simple. I will also add DMA_ATTR_NON_COHERENT
attribute for implementing dma_alloc_noncoherent() call.

> On a related note, do you plan to make the CMA work use this
> transparently, or do you want to have a DMA_ATTR_LARGE or
> DMA_ATTR_CONTIGUOUS for CMA?

IMHO it will be better to hide the CMA from the drivers. Memory allocated
from CMA doesn't really differ from the one allocated by dma_alloc_coherent()
(which internally use alloc_pages()), so I really see no reason for adding
additional attribute for it.

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
