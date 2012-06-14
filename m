Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id DD30F6B005C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 04:40:26 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (mailout2.samsung.com [203.254.224.25])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M5L00I1CMR8HCV0@mailout2.samsung.com> for
 linux-mm@kvack.org; Thu, 14 Jun 2012 17:40:24 +0900 (KST)
Received: from AMDC159 ([106.116.37.153])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M5L006HLMQHDK80@mmp1.samsung.com> for linux-mm@kvack.org;
 Thu, 14 Jun 2012 17:40:24 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
References: <1339588218-24398-1-git-send-email-m.szyprowski@samsung.com>
 <20120613141211.GJ5979@phenom.dumpdata.com>
In-reply-to: <20120613141211.GJ5979@phenom.dumpdata.com>
Subject: RE: [PATCHv2 0/6] ARM: DMA-mapping: new extensions for buffer sharing
Date: Thu, 14 Jun 2012 10:39:51 +0200
Message-id: <002801cd4a09$49866d00$dc934700$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: pl
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Konrad Rzeszutek Wilk' <konrad.wilk@oracle.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Arnd Bergmann' <arnd@arndb.de>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Krishna Reddy' <vdumpa@nvidia.com>, 'Benjamin Herrenschmidt' <benh@kernel.crashing.org>, 'Hiroshi Doyu' <hdoyu@nvidia.com>, 'Subash Patel' <subash.ramaswamy@linaro.org>, 'Sumit Semwal' <sumit.semwal@linaro.org>, 'Abhinav Kochhar' <abhinav.k@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>

Hi Konrad,

On Wednesday, June 13, 2012 4:12 PM Konrad Rzeszutek Wilk wrote:

> On Wed, Jun 13, 2012 at 01:50:12PM +0200, Marek Szyprowski wrote:
> > Hello,
> >
> > This is an updated version of the patch series introducing a new
> > features to DMA mapping subsystem to let drivers share the allocated
> > buffers (preferably using recently introduced dma_buf framework) easy
> > and efficient.
> >
> > The first extension is DMA_ATTR_NO_KERNEL_MAPPING attribute. It is
> > intended for use with dma_{alloc, mmap, free}_attrs functions. It can be
> > used to notify dma-mapping core that the driver will not use kernel
> > mapping for the allocated buffer at all, so the core can skip creating
> > it. This saves precious kernel virtual address space. Such buffer can be
> > accessed from userspace, after calling dma_mmap_attrs() for it (a
> > typical use case for multimedia buffers). The value returned by
> > dma_alloc_attrs() with this attribute should be considered as a DMA
> > cookie, which needs to be passed to dma_mmap_attrs() and
> > dma_free_attrs() funtions.
> >
> > The second extension is required to let drivers to share the buffers
> > allocated by DMA-mapping subsystem. Right now the driver gets a dma
> > address of the allocated buffer and the kernel virtual mapping for it.
> > If it wants to share it with other device (= map into its dma address
> > space) it usually hacks around kernel virtual addresses to get pointers
> > to pages or assumes that both devices share the DMA address space. Both
> > solutions are just hacks for the special cases, which should be avoided
> > in the final version of buffer sharing. To solve this issue in a generic
> > way, a new call to DMA mapping has been introduced - dma_get_sgtable().
> > It allocates a scatter-list which describes the allocated buffer and
> > lets the driver(s) to use it with other device(s) by calling
> > dma_map_sg() on it.
> 
> What about the cases where the driver wants to share the buffer but there
> are multiple IOMMUs? So the DMA address returned initially would be
> different on the other IOMMUs? Would the driver have to figure this out
> or would the DMA/IOMMU implementation be in charge of that?

This extension is exactly to solve this problem. The driver(s) don't need to be 
aware of the IOMMU or IOMMUs between all the devices which are sharing the buffer.
Using dma_get_sgtable() one can get a scatter list describing the buffer allocated
for device1 and the call dma_map_sg() to map that scatter list to device2 dma
area. If there is device3, one calls dma_get_sgtable() again, gets second scatter
list, then maps it to device3. Weather there is a common IOMMU between those
device or each of the has its separate one, it doesn't matter - it will be hidden
behind dma mapping subsystem and the driver should not care about it.

> And what about IOMMU's that don't do DMA_ATTR_NO_KERNEL_MAPPING?
> Can they just ignore it and do what they did before ? (I presume yes).

The main idea about dma attributes (the beauty of the them) is the fact that all
are optional to implement for the platform core. If the attribute makes no sense
for the particular hardware it can be simply ignored. Attributes can relax some
requirements for dma mapping calls, but if the core ignores them and implements
calls in the most restrictive way the driver (client) will still work fine.

> (snipped)

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
