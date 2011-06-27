Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id D46556B007E
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 08:18:09 -0400 (EDT)
Received: from eu_spt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LNG00JJ47I7GW@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Mon, 27 Jun 2011 13:18:07 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LNG00J9V7I6IV@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Jun 2011 13:18:06 +0100 (BST)
Date: Mon, 27 Jun 2011 14:18:02 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 3/8] ARM: dma-mapping: use asm-generic/dma-mapping-common.h
In-reply-to: <201106241736.43576.arnd@arndb.de>
Message-id: <000601cc34c4$430f91f0$c92eb5d0$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
 <1308556213-24970-4-git-send-email-m.szyprowski@samsung.com>
 <201106241736.43576.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Arnd Bergmann' <arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Joerg Roedel' <joro@8bytes.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>

Hello,

On Friday, June 24, 2011 5:37 PM Arnd Bergmann wrote:

> On Monday 20 June 2011, Marek Szyprowski wrote:
> > This patch modifies dma-mapping implementation on ARM architecture to
> > use common dma_map_ops structure and asm-generic/dma-mapping-common.h
> > helpers.
> >
> > Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> > Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> 
> This is a good idea in general, but I have a few concerns about details:
> 
> First of all, should we only allow using dma_map_ops on ARM, or do we
> also want to support a case where these are all inlined as before?

I really wonder if it is possible to have a clean implementation of 
dma_map_ops based and linear inlined dma-mapping framework together.
Theoretically it should be possible, but it will end with a lot of
#ifdef hackery which is really hard to follow and understand for 
anyone but the authors.

> I suppose for the majority of the cases, the overhead of the indirect
> function call is near-zero, compared to the overhead of the cache
> management operation, so it would only make a difference for coherent
> systems without an IOMMU. Do we care about micro-optimizing those?

Even in coherent case, the overhead caused by additional function call
should have really negligible impact on drivers performance.

 > > diff --git a/arch/arm/include/asm/dma-mapping.h
> b/arch/arm/include/asm/dma-mapping.h
> > index 799669d..f4e4968 100644
> > --- a/arch/arm/include/asm/dma-mapping.h
> > +++ b/arch/arm/include/asm/dma-mapping.h
> > @@ -10,6 +10,27 @@
> >  #include <asm-generic/dma-coherent.h>
> >  #include <asm/memory.h>
> >
> > +extern struct dma_map_ops dma_ops;
> > +
> > +static inline struct dma_map_ops *get_dma_ops(struct device *dev)
> > +{
> > +	if (dev->archdata.dma_ops)
> > +		return dev->archdata.dma_ops;
> > +	return &dma_ops;
> > +}
> 
> I would not name the global structure just 'dma_ops', the identifier could
> too easily conflict with a local variable in some driver. How about
> arm_dma_ops or linear_dma_ops instead?

I'm fine with both of them. Even arm_linear_dma_ops make some sense.

> >  /*
> >   * The scatter list versions of the above methods.
> >   */
> > -extern int dma_map_sg(struct device *, struct scatterlist *, int,
> > -		enum dma_data_direction);
> > -extern void dma_unmap_sg(struct device *, struct scatterlist *, int,
> > +extern int arm_dma_map_sg(struct device *, struct scatterlist *, int,
> > +		enum dma_data_direction, struct dma_attrs *attrs);
> > +extern void arm_dma_unmap_sg(struct device *, struct scatterlist *, int,
> > +		enum dma_data_direction, struct dma_attrs *attrs);
> > +extern void arm_dma_sync_sg_for_cpu(struct device *, struct scatterlist
> *, int,
> >  		enum dma_data_direction);
> > -extern void dma_sync_sg_for_cpu(struct device *, struct scatterlist *,
> int,
> > +extern void arm_dma_sync_sg_for_device(struct device *, struct
> scatterlist *, int,
> >  		enum dma_data_direction);
> > -extern void dma_sync_sg_for_device(struct device *, struct scatterlist *,
> int,
> > -		enum dma_data_direction);
> > -
> 
> You should not need to make these symbols visible in the header file any
> more unless they are used outside of the main file later.

They are used by the dma bounce code once converted to dma_map_ops framework.

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
