Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id F1D039000BD
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 10:59:51 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from eu_spt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LN30080OGBOVY10@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 20 Jun 2011 15:59:49 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LN30020CGBN7F@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 20 Jun 2011 15:59:48 +0100 (BST)
Date: Mon, 20 Jun 2011 16:59:44 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [RFC 0/2] ARM: DMA-mapping & IOMMU integration
In-reply-to: <4DFF59BB.100@gmail.com>
Message-id: <000001cc2f5a$b0f1a3d0$12d4eb70$%szyprowski@samsung.com>
Content-language: pl
References: <1306308920-8602-1-git-send-email-m.szyprowski@samsung.com>
 <4DFF59BB.100@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Subash Patel' <subashrp@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Joerg Roedel' <joro@8bytes.org>, 'Arnd Bergmann' <arnd@arndb.de>, Marek Szyprowski <m.szyprowski@samsung.com>

Hello,

On Monday, June 20, 2011 4:31 PM Subash Patel wrote:

> In function:
> dma_alloc_coherent()->arm_iommu_alloc_attrs()->__iommu_alloc_buffer()
> 
> I have following questions:
> 
> a) Before we come to this point, we would have enabled SYSMMU in a call
> to arm_iommu_init(). Shouldnt the SYSMMU be enabled after call to
> __iommu_alloc_buffer(), but before __iommu_create_mapping()? If in case
> the __iommu_alloc_buffer() fails, we dont disable the SYSMMU.

I want to move enabling and disabling SYSMMU completely to the runtime_pm
framework. As You can notice, the updated SYSMMU driver automatically
becomes a parent of respective multimedia device and a child of the power
domain to which both belongs. This means that sysmmu will operate only
when multimedia device is enabled, what really makes sense. The sysmmu
driver will need to be updated not to poke into the registers if it is
disabled, but this should be really trivial change.

> b) For huge buffer sizes, the pressure on SYSMMU would be very high.
> Cant we have option to dictate the page size for the IOMMU from driver
> in such cases? Should it always be the size of system pages?

This was just a first version of dma-mapping and IOMMU integration, just
to show the development road and start the discussion. Of course in the
final version support for pages larger than 4KiB is highly expected. We
can even reuse the recently posted CMA to allocate large pages for IOMMU
to improve the performance and make sure that the framework will be able
to allocate such pages even if the device is running for long time and 
memory got fragmented by typically movable pages.

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
