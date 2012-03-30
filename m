Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 26B5A6B0044
	for <linux-mm@kvack.org>; Fri, 30 Mar 2012 02:30:27 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from euspt2 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M1O00FAOQ2CQI10@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 30 Mar 2012 07:30:13 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M1O007BVQ2MEA@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 30 Mar 2012 07:30:22 +0100 (BST)
Date: Fri, 30 Mar 2012 08:30:06 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv7 9/9] ARM: dma-mapping: add support for IOMMU mapper
In-reply-to: <401E54CE964CD94BAE1EB4A729C7087E37978A1E66@HQMAIL04.nvidia.com>
Message-id: <000001cd0e3e$8ce21380$a6a63a80$%szyprowski@samsung.com>
Content-language: pl
References: <1330527862-16234-1-git-send-email-m.szyprowski@samsung.com>
 <1330527862-16234-10-git-send-email-m.szyprowski@samsung.com>
 <20120329101927.8ab6b1993475b7e16ae2258f@nvidia.com>
 <01b301cd0d81$f935d750$eba185f0$%szyprowski@samsung.com>
 <401E54CE964CD94BAE1EB4A729C7087E37978A1E66@HQMAIL04.nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Krishna Reddy' <vdumpa@nvidia.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Arnd Bergmann' <arnd@arndb.de>, 'Benjamin Herrenschmidt' <benh@kernel.crashing.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Andrzej Pietrasiewicz' <andrzej.p@samsung.com>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'KyongHo Cho' <pullip.cho@samsung.com>, 'Hiroshi Doyu' <hdoyu@nvidia.com>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>

Hello,

On Friday, March 30, 2012 4:24 AM Krishna Reddy wrote:

> Hi,
> I have found a bug in arm_iommu_map_sg().
> 
> > +int arm_iommu_map_sg(struct device *dev, struct scatterlist *sg, int nents,
> > +		     enum dma_data_direction dir, struct dma_attrs *attrs) {
> > +	struct scatterlist *s = sg, *dma = sg, *start = sg;
> > +	int i, count = 0;
> > +	unsigned int offset = s->offset;
> > +	unsigned int size = s->offset + s->length;
> > +	unsigned int max = dma_get_max_seg_size(dev);
> > +
> > +	for (i = 1; i < nents; i++) {
> > +		s->dma_address = ARM_DMA_ERROR;
> > +		s->dma_length = 0;
> > +
> > +		s = sg_next(s);
> 
> With above code, the last sg element's dma_length is not getting set to zero.
> This causing additional incorrect  unmapping during arm_iommu_unmap_sg call and
> leading to random crashes.
> The order of above three lines should be as follows.
> 		s = sg_next(s);
> 
> 		s->dma_address = ARM_DMA_ERROR;
> 		s->dma_length = 0;
> 

You are right, the order of those lines must be reversed. In all my test codes the 
scatter list was initially cleared, so I missed this typical off-by-one error. 
Thanks for spotting it!

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
