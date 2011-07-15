Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id AD5F56B004A
	for <linux-mm@kvack.org>; Fri, 15 Jul 2011 02:28:50 -0400 (EDT)
Received: from spt2.w1.samsung.com (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LOD00LKJ3BZI1@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 15 Jul 2011 07:28:47 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LOD008TR3BYJE@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 15 Jul 2011 07:28:46 +0100 (BST)
Date: Fri, 15 Jul 2011 08:27:58 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [Linaro-mm-sig] [RFC 2/2] ARM: initial proof-of-concept IOMMU
 mapper for DMA-mapping
In-reply-to: 
 <CAB-zwWhRQmv8euqN6jeJP=tXTQgGQ3buRJEf=4aPtTOBsh+Z2Q@mail.gmail.com>
Message-id: <000301cc42b8$569fca30$03df5e90$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=iso-8859-2
Content-language: pl
Content-transfer-encoding: quoted-printable
References: <CAB-zwWhRQmv8euqN6jeJP=tXTQgGQ3buRJEf=4aPtTOBsh+Z2Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Ramirez Luna, Omar'" <omar.ramirez@ti.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Joerg Roedel' <joro@8bytes.org>, 'Arnd Bergmann' <arnd@arndb.de>

Hello,

On Thursday, July 14, 2011 8:33 PM Ramirez Luna, Omar wrote:

> > Add initial proof of concept implementation of DMA-mapping API for
> > devices that have IOMMU support. Right now only dma_alloc_coherent,
> > dma_free_coherent and dma_mmap_coherent functions are supported.
> >
> > Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> > Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> > ---
> ...
> > diff --git a/arch/arm/include/asm/dma-iommu.h =
b/arch/arm/include/asm/dma-
> iommu.h
> > new file mode 100644
> > index 0000000..c246ff3
> > --- /dev/null
> > +++ b/arch/arm/include/asm/dma-iommu.h
> ...
> > +int __init arm_iommu_assign_device(struct device *dev, dma_addr_t =
base,
> dma_addr_t size);
>=20
> __init causes a panic if the iommu is assigned after boot.
>=20
> In OMAP3 the iommu driver controls isp and dsp address spaces, it is
> loaded until any of those 2 drivers is needed.

Well, ok. This was just a proof-of-concept/rfc patch, so it was designed =
only
for our particular case.

> > diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> > index f8c6972..b6397c1 100644
> > --- a/arch/arm/mm/dma-mapping.c
> > +++ b/arch/arm/mm/dma-mapping.c
> ...
> > +static void *arm_iommu_alloc_attrs(struct device *dev, size_t size,
> > + =A0 =A0 =A0 =A0 =A0 dma_addr_t *handle, gfp_t gfp, struct =
dma_attrs *attrs)
> > +{
> > + =A0 =A0 =A0 struct dma_iommu_mapping *mapping =3D =
dev->archdata.mapping;
> > + =A0 =A0 =A0 struct page **pages;
> > + =A0 =A0 =A0 void *addr =3D NULL;
> > + =A0 =A0 =A0 pgprot_t prot;
> > +
> > + =A0 =A0 =A0 if (dma_get_attr(DMA_ATTR_WRITE_COMBINE, attrs))
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 prot =3D =
pgprot_writecombine(pgprot_kernel);
> > + =A0 =A0 =A0 else
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 prot =3D =
pgprot_dmacoherent(pgprot_kernel);
> > +
> > + =A0 =A0 =A0 arm_iommu_init(dev);
>=20
> I found useful to call arm_iommu_init inside arm_iommu_assign_device
> instead. So, then gen_pool is created only once without the
> mapping->pool check, instead of relying on the call to ...alloc_attrs,
> which in my case I never use because I'm implementing
> iommu_map|unmap_sg functions to see how it goes with the dma mapping.

Right, this is still on my todo list, but I wanted to focus on cleanup=20
of dma mapping framework and cma first.

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
