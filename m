Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id C388B6B010D
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 11:31:40 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from spt2.w1.samsung.com ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LN300922HSRDF30@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 20 Jun 2011 16:31:39 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LN300C85HSPOA@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 20 Jun 2011 16:31:38 +0100 (BST)
Date: Mon, 20 Jun 2011 17:31:34 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 5/8] ARM: dma-mapping: move all dma bounce code to separate
 dma ops structure
In-reply-to: <20110620144247.GF26089@n2100.arm.linux.org.uk>
Message-id: <000901cc2f5f$237795a0$6a66c0e0$%szyprowski@samsung.com>
Content-language: pl
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
 <1308556213-24970-6-git-send-email-m.szyprowski@samsung.com>
 <20110620144247.GF26089@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Joerg Roedel' <joro@8bytes.org>, 'Arnd Bergmann' <arnd@arndb.de>, Marek Szyprowski <m.szyprowski@samsung.com>

Hello,

On Monday, June 20, 2011 4:43 PM Russell King - ARM Linux wrote:

> On Mon, Jun 20, 2011 at 09:50:10AM +0200, Marek Szyprowski wrote:
> > This patch removes dma bounce hooks from the common dma mapping
> > implementation on ARM architecture and creates a separate set of
> > dma_map_ops for dma bounce devices.
> 
> Why all this additional indirection for no gain?

I've did it to really separate dmabounce code and let it be completely 
independent of particular internal functions of the main generic dma-mapping
code.

dmabounce is just one of possible dma-mapping implementation and it is really
convenient to have it closed into common interface (dma_map_ops) rather than
having it spread around and hardcoded behind some #ifdefs in generic ARM
dma-mapping.

There will be also other dma-mapping implementations in the future - I 
thinking mainly of some iommu capable versions. 

In terms of speed I really doubt that these changes have any impact on the
system performance, but they significantly improves the code readability 
(see next patch with cleanup of dma-mapping.c).

> > @@ -278,7 +278,7 @@ static inline dma_addr_t map_single(struct device
> *dev, void *ptr, size_t size,
> >  		 * We don't need to sync the DMA buffer since
> >  		 * it was allocated via the coherent allocators.
> >  		 */
> > -		__dma_single_cpu_to_dev(ptr, size, dir);
> > +		dma_ops.sync_single_for_device(dev, dma_addr, size, dir);
> >  	}
> >
> >  	return dma_addr;
> > @@ -317,7 +317,7 @@ static inline void unmap_single(struct device *dev,
> dma_addr_t dma_addr,
> >  		}
> >  		free_safe_buffer(dev->archdata.dmabounce, buf);
> >  	} else {
> > -		__dma_single_dev_to_cpu(dma_to_virt(dev, dma_addr), size, dir);
> > +		dma_ops.sync_single_for_cpu(dev, dma_addr, size, dir);
> >  	}
> >  }

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
