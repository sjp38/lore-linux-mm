Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 616DB6B004A
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 11:46:39 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC 0/2] ARM: DMA-mapping & IOMMU integration
Date: Mon, 13 Jun 2011 17:46:18 +0200
References: <1306308920-8602-1-git-send-email-m.szyprowski@samsung.com> <201106131707.49217.arnd@arndb.de> <BANLkTikR5AE=-wTWzrSJ0TUaks0_rA3mcg@mail.gmail.com>
In-Reply-To: <BANLkTikR5AE=-wTWzrSJ0TUaks0_rA3mcg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201106131746.18972.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: KyongHo Cho <pullip.cho@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Joerg Roedel <joro@8bytes.org>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On Monday 13 June 2011 17:30:44 KyongHo Cho wrote:
> On Tue, Jun 14, 2011 at 12:07 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> > I'm sure that the graphics people will disagree with you on that.
> > Having the frame buffer mapped in write-combine mode is rather
> > important when you want to efficiently output videos from your
> > CPU.
> >
> I agree with you.
> But I am discussing about dma_alloc_writecombine() in ARM.
> You can see that only ARM and AVR32 implement it and there are few
> drivers which use it.
> No function in dma_map_ops corresponds to dma_alloc_writecombine().
> That's why Marek tried to add 'alloc_writecombine' to dma_map_ops.

Yes, and I think Marek's patch is really necessary. The reason we
need dma_alloc_writecombine on ARM is because the page attributes in
the kernel need to match the ones in user space, while other
architectures either handle the writecombine flag outside of the
page table or can have multiple conflicting mappings.

The reason that I suspect AVR32 needs it is to share device drivers
with ARM.

> > I can understand that there are arguments why mapping a DMA buffer into
> > user space doesn't belong into dma_map_ops, but I don't see how the
> > presence of an IOMMU is one of them.
> >
> > The entire purpose of dma_map_ops is to hide from the user whether
> > you have an IOMMU or not, so that would be the main argument for
> > putting it in there, not against doing so.
> >
> I also understand the reasons why dma_map_ops maps a buffer into user space.
> Mapping in device and user space at the same time or in a simple
> approach may look good.
> But I think mapping to user must be and driver-specific.
> Moreover, kernel already provides various ways to map physical memory
> to user space.

I believe the idea of providing dma_mmap_... is to ensure that the
page attributes are not conflicting and the DMA code is the place
that decides on the page attributes for the kernel mapping, so no
other place in the kernel can really know what it should be in user
space.

> And I think that remapping DMA address that is in device address space
> to user space is not a good idea
> because DMA address is not same to physical address semantically if
> features of IOMMU are implemented.

I'm totally not following this argument. This has nothing to do with IOMMU
or not. If you have an IOMMU, the dma code will know where the pages are
anyway, so it can always map them into user space. The dma code might
have an easier way to do it other than follwoing the page tables.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
