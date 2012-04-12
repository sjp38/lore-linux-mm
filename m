Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 8AE1D6B0107
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 08:13:43 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from euspt2 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M2D00LGG8M7N100@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 12 Apr 2012 13:13:19 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M2D00MKQ8MQDO@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 12 Apr 2012 13:13:39 +0100 (BST)
Date: Thu, 12 Apr 2012 14:13:37 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH] ARM: Exynos4: integrate SYSMMU driver with DMA-mapping
 interface
In-reply-to: <201204121109.28753.arnd@arndb.de>
Message-id: <028f01cd18a5$b0721770$11564650$%szyprowski@samsung.com>
Content-language: pl
References: <1334155004-5700-1-git-send-email-m.szyprowski@samsung.com>
 <4F869AF4.3080402@gmail.com>
 <026301cd188d$32613860$9723a920$%szyprowski@samsung.com>
 <201204121109.28753.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Arnd Bergmann' <arnd@arndb.de>
Cc: 'Subash Patel' <subashrp@gmail.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, iommu@lists.linux-foundation.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Joerg Roedel' <joro@8bytes.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Krishna Reddy' <vdumpa@nvidia.com>, 'KyongHo Cho' <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, 'Benjamin Herrenschmidt' <benh@kernel.crashing.org>, 'Konrad Rzeszutek Wilk' <konrad.wilk@oracle.com>, 'Hiroshi Doyu' <hdoyu@nvidia.com>





> -----Original Message-----
> From: Arnd Bergmann [mailto:arnd@arndb.de]
> Sent: Thursday, April 12, 2012 1:09 PM
> To: Marek Szyprowski
> Cc: 'Subash Patel'; linux-arm-kernel@lists.infradead.org; linaro-mm-sig@lists.linaro.org;
> linux-mm@kvack.org; linux-arch@vger.kernel.org; iommu@lists.linux-foundation.org; 'Kyungmin
> Park'; 'Joerg Roedel'; 'Russell King - ARM Linux'; 'Chunsang Jeong'; 'Krishna Reddy'; 'KyongHo
> Cho'; Andrzej Pietrasiewicz; 'Benjamin Herrenschmidt'; 'Konrad Rzeszutek Wilk'; 'Hiroshi Doyu'
> Subject: Re: [PATCH] ARM: Exynos4: integrate SYSMMU driver with DMA-mapping interface
> 
> On Thursday 12 April 2012, Marek Szyprowski wrote:
> > +
> > > > +/*
> > > > + * s5p_sysmmu_late_init
> > > > + * Create DMA-mapping IOMMU context for specified devices. This function must
> > > > + * be called later, once SYSMMU driver gets registered and probed.
> > > > + */
> > > > +static int __init s5p_sysmmu_late_init(void)
> > > > +{
> > > > +   platform_set_sysmmu(&SYSMMU_PLATDEV(fimc0).dev,&s5p_device_fimc0.dev);
> > > > +   platform_set_sysmmu(&SYSMMU_PLATDEV(fimc1).dev,&s5p_device_fimc1.dev);
> > > > +   platform_set_sysmmu(&SYSMMU_PLATDEV(fimc2).dev,&s5p_device_fimc2.dev);
> > > > +   platform_set_sysmmu(&SYSMMU_PLATDEV(fimc3).dev,&s5p_device_fimc3.dev);
> > > > +   platform_set_sysmmu(&SYSMMU_PLATDEV(mfc_l).dev,&s5p_device_mfc_l.dev);
> > > > +   platform_set_sysmmu(&SYSMMU_PLATDEV(mfc_r).dev,&s5p_device_mfc_r.dev);
> > > > +
> > > > +   s5p_create_iommu_mapping(&s5p_device_fimc0.dev, 0x20000000, SZ_128M, 4);
> > > > +   s5p_create_iommu_mapping(&s5p_device_fimc1.dev, 0x20000000, SZ_128M, 4);
> > > > +   s5p_create_iommu_mapping(&s5p_device_fimc2.dev, 0x20000000, SZ_128M, 4);
> > > > +   s5p_create_iommu_mapping(&s5p_device_fimc3.dev, 0x20000000, SZ_128M, 4);
> > > > +   s5p_create_iommu_mapping(&s5p_device_mfc_l.dev, 0x20000000, SZ_128M, 4);
> > > > +   s5p_create_iommu_mapping(&s5p_device_mfc_r.dev, 0x40000000, SZ_128M, 4);
> > > > +
> > > > +   return 0;
> > > > +}
> > > > +device_initcall(s5p_sysmmu_late_init);
> > >
> > > Shouldn't these things be specific to a SoC? With this RFC, it happens
> > > that you will predefine the IOMMU attachment and mapping information for
> > > devices in common location (dev-sysmmu.c)? This may lead to problems
> > > because there are some IP's with SYSMMU support in exynos5, but not
> > > available in exynos4 (eg: GSC, FIMC-LITE, FIMC-ISP) Previously we used
> > > to do above declaration in individual machine file, which I think was
> > > more meaningful.
> >
> > Right, I simplified the code too much. Keeping these definitions inside machine
> > files was a better idea. I completely forgot that Exynos sub-platform now covers
> > both Exynos4 and Exynos5 SoC families.
> 
> Ideally the information about iommu attachment should come from the
> device tree. We have the "dma-ranges" properties that define how a dma
> address space is mapped. I am not entirely sure how that works when you
> have multiple IOMMUs and if that requires defining addititional properties,
> but I think we should make it so that we don't have to hardcode specific
> devices in the source.

Right, until that time machine/board files are imho ok.

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
