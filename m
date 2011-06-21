Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 17ABF6B0182
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 07:47:13 -0400 (EDT)
MIME-version: 1.0
Content-type: text/plain; charset=iso-8859-2
Received: from eu_spt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LN500G5D22NJW50@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 21 Jun 2011 12:47:11 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LN5000ES22MRG@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 21 Jun 2011 12:47:10 +0100 (BST)
Date: Tue, 21 Jun 2011 13:47:03 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [Linaro-mm-sig] [PATCH 3/8] ARM: dma-mapping: use
 asm-generic/dma-mapping-common.h
In-reply-to: <BANLkTimHE2jzQAav465WaG3iWVeHPyNRNQ@mail.gmail.com>
Message-id: <002501cc3008$f000d600$d0028200$%szyprowski@samsung.com>
Content-language: pl
Content-transfer-encoding: quoted-printable
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
 <1308556213-24970-4-git-send-email-m.szyprowski@samsung.com>
 <BANLkTimHE2jzQAav465WaG3iWVeHPyNRNQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'KyongHo Cho' <pullip.cho@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Joerg Roedel' <joro@8bytes.org>, 'Arnd Bergmann' <arnd@arndb.de>

Hello,

On Monday, June 20, 2011 4:33 PM KyongHo Cho wrote:

> On Mon, Jun 20, 2011 at 4:50 PM, Marek Szyprowski
> <m.szyprowski@samsung.com> wrote:
> > +static inline void set_dma_ops(struct device *dev, struct =
dma_map_ops
> *ops)
> > +{
> > + =A0 =A0 =A0 dev->archdata.dma_ops =3D ops;
> > +}
> > +
>=20
> Who calls set_dma_ops()?
> In the mach. initialization part?

Yes, some board, machine or device bus initialization code is supposed =
to
call this function. Just 'git grep dma_set_ops' and you will see. In my
patch series one of the clients of set_dma_ops function is dmabounce=20
framework (it is called in dmabounce_register_dev() function).

> What if a device driver does not want to use arch's dma_map_ops
> when machine init procedure set a dma_map_ops?

Could you elaborate on this case? The whole point of dma-mapping =
framework
is to hide the implementation of DMA mapping operation from the driver.=20
The driver should never fiddle with dma map ops directly.

> Even though, may arch defiens their dma_map_ops in archdata of device
> structure,
> I think it is not a good idea that is device structure contains a
> pointer to dma_map_ops
> that may not be common to all devices in a board.

It is up to the board/bus startup code to set dma ops correctly.

> I also think that it is better to attach and to detach dma_map_ops
> dynamically.

What's the point of such operations? Why do you want to change dma
mapping methods in runtime?

> Moreover, a mapping is not permanent in our Exynos platform
> because a System MMU may be turned off while runtime.

This is theoretically possible. The System MMU (Samsung IOMMU
controller) driver can change dma_map_ops back to NULL on remove moving
back the client device to generic ARM dma mapping implementation.

> DMA API must come with IOMMU API to initialize IOMMU in runtime.

I don't understand what's the problem here.=20

Best regards
--=20
Marek Szyprowski
Samsung Poland R&D Center



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
