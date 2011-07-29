Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8031E6B00EE
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 10:24:56 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from eu_spt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LP300ITYMPIUU80@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 29 Jul 2011 15:24:54 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LP3006S8MPGBS@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 29 Jul 2011 15:24:53 +0100 (BST)
Date: Fri, 29 Jul 2011 16:24:52 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [RFC] ARM: dma_map|unmap_sg plus iommu
In-reply-to: <20110729105422.GB13522@8bytes.org>
Message-id: <004201cc4dfb$47ee4770$d7cad650$%szyprowski@samsung.com>
Content-language: pl
References: 
 <CAB-zwWjb+2ExjNDB3OtHmRmgaHMnO-VgEe9VZk_wU=ryrq_AGw@mail.gmail.com>
 <000301cc4dc4$31b53630$951fa290$%szyprowski@samsung.com>
 <20110729093555.GA13522@8bytes.org>
 <001901cc4dd8$4afb4e40$e0f1eac0$%szyprowski@samsung.com>
 <20110729105422.GB13522@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Joerg Roedel' <joro@8bytes.org>
Cc: "'Ramirez Luna, Omar'" <omar.ramirez@ti.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Arnd Bergmann' <arnd@arndb.de>, 'Ohad Ben-Cohen' <ohad@wizery.com>, 'Marek Szyprowski' <m.szyprowski@samsung.com>

Hello,

On Friday, July 29, 2011 12:54 PM Joerg Roedel wrote:

> On Fri, Jul 29, 2011 at 12:14:25PM +0200, Marek Szyprowski wrote:
> > > This sounds rather hacky. How about partitioning the address space for
> > > the device and give the dma-api only a part of it. The other parts can
> > > be directly mapped using the iommu-api then.
> >
> > Well, I'm not convinced that iommu-api should be used by the device drivers
> > directly. If possible we should rather extend dma-mapping than use such
hacks.
> 
> Building this into dma-api would turn it into an iommu-api. The line
> between the apis are clear. The iommu-api provides direct mapping
> of bus-addresses to system-addresses while the dma-api puts a memory
> manager on-top which deals with bus-address allocation itself.
> So if you want to map bus-addresses directly the iommu-api is the way to
> go. This is in no way a hack.

The problem starts when you want to use the same driver on two different
systems:
one with iommu and one without. Our driver depends only on dma-mapping and the
fact
that the first allocation starts from the right address. On systems without
iommu,
board code calls bootmem_reserve() and dma_declare_coherent() for the required 
memory range. Systems with IOMMU just sets up device io address space to start 
at the specified address. This works fine, because in our system each device has
its own, private iommu controller and private address space.

Right now I have no idea how to handle this better. Perhaps with should be
possible
to specify somehow the target dma_address when doing memory allocation, but I'm
not
really convinced yet if this is really required.

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
