Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0296A6B0148
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 09:20:07 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/8] ARM: dma-mapping: use asm-generic/dma-mapping-common.h
Date: Mon, 27 Jun 2011 15:19:43 +0200
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com> <201106241736.43576.arnd@arndb.de> <000601cc34c4$430f91f0$c92eb5d0$%szyprowski@samsung.com>
In-Reply-To: <000601cc34c4$430f91f0$c92eb5d0$%szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201106271519.43581.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Joerg Roedel' <joro@8bytes.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, Lennert Buytenhek <buytenh@wantstofly.org>

On Monday 27 June 2011, Marek Szyprowski wrote:

> On Friday, June 24, 2011 5:37 PM Arnd Bergmann wrote:
> 
> > On Monday 20 June 2011, Marek Szyprowski wrote:
> > > This patch modifies dma-mapping implementation on ARM architecture to
> > > use common dma_map_ops structure and asm-generic/dma-mapping-common.h
> > > helpers.
> > >
> > > Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> > > Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> > 
> > This is a good idea in general, but I have a few concerns about details:
> > 
> > First of all, should we only allow using dma_map_ops on ARM, or do we
> > also want to support a case where these are all inlined as before?
> 
> I really wonder if it is possible to have a clean implementation of 
> dma_map_ops based and linear inlined dma-mapping framework together.
> Theoretically it should be possible, but it will end with a lot of
> #ifdef hackery which is really hard to follow and understand for 
> anyone but the authors.

Right. It's probably not worth unless there is a significant overhead
in terms of code size or performance in the coherent linear case.

> > I suppose for the majority of the cases, the overhead of the indirect
> > function call is near-zero, compared to the overhead of the cache
> > management operation, so it would only make a difference for coherent
> > systems without an IOMMU. Do we care about micro-optimizing those?
> 
> Even in coherent case, the overhead caused by additional function call
> should have really negligible impact on drivers performance.

What about object code size? I guess since ixp23xx is the only platform
that announces itself as coherent, we probably don't need to worry about
it too much either. Lennert?

On everything else, we only replace a direct functin call with an
indirect one.

>  > > diff --git a/arch/arm/include/asm/dma-mapping.h
> > b/arch/arm/include/asm/dma-mapping.h
> > > index 799669d..f4e4968 100644
> > > --- a/arch/arm/include/asm/dma-mapping.h
> > > +++ b/arch/arm/include/asm/dma-mapping.h
> > > @@ -10,6 +10,27 @@
> > >  #include <asm-generic/dma-coherent.h>
> > >  #include <asm/memory.h>
> > >
> > > +extern struct dma_map_ops dma_ops;
> > > +
> > > +static inline struct dma_map_ops *get_dma_ops(struct device *dev)
> > > +{
> > > +	if (dev->archdata.dma_ops)
> > > +		return dev->archdata.dma_ops;
> > > +	return &dma_ops;
> > > +}
> > 
> > I would not name the global structure just 'dma_ops', the identifier could
> > too easily conflict with a local variable in some driver. How about
> > arm_dma_ops or linear_dma_ops instead?
> 
> I'm fine with both of them. Even arm_linear_dma_ops make some sense.

Ok, just pick one then if nobody has a strong opinion either way.

> > You should not need to make these symbols visible in the header file any
> > more unless they are used outside of the main file later.
> 
> They are used by the dma bounce code once converted to dma_map_ops framework.

Ok, I see.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
