Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 786EE6B00F3
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 05:49:29 -0400 (EDT)
Received: from euspt2 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M2D001J21YBF3@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Thu, 12 Apr 2012 10:49:23 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M2D00BD01YCI0@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 12 Apr 2012 10:49:25 +0100 (BST)
Date: Thu, 12 Apr 2012 11:49:23 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv8 10/10] ARM: dma-mapping: add support for IOMMU mapper
In-reply-to: <201204101158.29590.arnd@arndb.de>
Message-id: <026f01cd1891$8a2f1b80$9e8d5280$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=iso-8859-2
Content-language: pl
Content-transfer-encoding: quoted-printable
References: <1334055852-19500-1-git-send-email-m.szyprowski@samsung.com>
 <1334055852-19500-11-git-send-email-m.szyprowski@samsung.com>
 <201204101158.29590.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Arnd Bergmann' <arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, iommu@lists.linux-foundation.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Joerg Roedel' <joro@8bytes.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Krishna Reddy' <vdumpa@nvidia.com>, 'KyongHo Cho' <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, 'Benjamin Herrenschmidt' <benh@kernel.crashing.org>, 'Konrad Rzeszutek Wilk' <konrad.wilk@oracle.com>, 'Hiroshi Doyu' <hdoyu@nvidia.com>, 'Subash Patel' <subashrp@gmail.com>

Hi Arnd,

On Tuesday, April 10, 2012 1:58 PM Arnd Bergmann wrote:

> On Tuesday 10 April 2012, Marek Szyprowski wrote:
> > +/**
> > + * arm_iommu_create_mapping
> > + * @bus: pointer to the bus holding the client device (for IOMMU =
calls)
> > + * @base: start address of the valid IO address space
> > + * @size: size of the valid IO address space
> > + * @order: accuracy of the IO addresses allocations
> > + *
> > + * Creates a mapping structure which holds information about =
used/unused
> > + * IO address ranges, which is required to perform memory =
allocation and
> > + * mapping with IOMMU aware functions.
> > + *
> > + * The client device need to be attached to the mapping with
> > + * arm_iommu_attach_device function.
> > + */
> > +struct dma_iommu_mapping *
> > +arm_iommu_create_mapping(struct bus_type *bus, dma_addr_t base, =
size_t size,
> > +                        int order)
> > +{
> > +       unsigned int count =3D size >> (PAGE_SHIFT + order);
> > +       unsigned int bitmap_size =3D BITS_TO_LONGS(count) * =
sizeof(long);
> > +       struct dma_iommu_mapping *mapping;
> > +       int err =3D -ENOMEM;
> > +
> > +       if (!count)
> > +               return ERR_PTR(-EINVAL);
> > +
> > +       mapping =3D kzalloc(sizeof(struct dma_iommu_mapping), =
GFP_KERNEL);
> > +       if (!mapping)
> > +               goto err;
> > +
> > +       mapping->bitmap =3D kzalloc(bitmap_size, GFP_KERNEL);
> > +       if (!mapping->bitmap)
> > +               goto err2;
> > +
> > +       mapping->base =3D base;
> > +       mapping->bits =3D BITS_PER_BYTE * bitmap_size;
> > +       mapping->order =3D order;
> > +       spin_lock_init(&mapping->lock);
> > +
> > +       mapping->domain =3D iommu_domain_alloc(bus);
> > +       if (!mapping->domain)
> > +               goto err3;
> > +
> > +       kref_init(&mapping->kref);
> > +       return mapping;
> > +err3:
> > +       kfree(mapping->bitmap);
> > +err2:
> > +       kfree(mapping);
> > +err:
> > +       return ERR_PTR(err);
> > +}
> > +EXPORT_SYMBOL(arm_iommu_create_mapping);
>=20
> I don't understand this function, mostly I guess because you have not
> provided any users. A few questions here:
>=20
> * What is ARM specific about it that it is named =
arm_iommu_create_mapping?
>   Isn't this completely generic, at least on the interface side?

This function is quite generic. It creates 'struct dma_iommu_mapping' =
object,
which is stored in the client's device arch data. This object mainly =
stores
information about io/dma address space: base address, allocation bitmap =
and
respective iommu domain. Please note that more than one device can be =
assigned
to the given dma_iommu_mapping to match different hardware topologies.

This function is called by the board/(sub-)platform startup code to =
initialize
iommu based dma-mapping. For the example usage please refer to=20
s5p_create_iommu_mapping() function in arch/arm/mach-exynos/dev-sysmmu.c =
on=20
3.4-rc2-arm-dma-v8-samsung branch in=20
git://git.linaro.org/people/mszyprowski/linux-dma-mapping.git

GITWeb shortcut:=20
http://git.linaro.org/gitweb?p=3Dpeople/mszyprowski/linux-dma-mapping.git=
;a=3Dblob;f=3Darch/arm/mach-exyno
s/dev-sysmmu.c;h=3D31f2d6caf0e9949def18abd18af3f9d16737ae19;hb=3D60250937=
50d41f88406042e6486e331b806dc87
5#l283

> * Why is this exported to modules? Which device drivers do you expect
>   to call it?

I thought it might be useful to use modules for registering devices, but =

now I see that no platform use such approach. I will drop these exports=20
unless someone finds a real use case for them.

> * Why do you pass the bus_type in here? That seems like the completely
>   wrong thing to do when all devices are on the same bus type (e.g.
>   amba or platform) but are connected to different instances that each
>   have their own iommu. I guess this is a question for J=F6rg, because =
the
>   base iommu interface provides iommu_domain_alloc().

That's only a consequence of the iommu api. I would also prefer to use =
client=20
device pointer here instead of the bus id, but maybe I don't have enough =

knowledge about desktop IOMMUs. I suspect that there is also a need to =
assign
one IOMMU driver to the whole bus (like pci bus) and it originates from =
such
systems. In embedded world we usually have only one iommu driver which=20
operates on the platform bus devices. On Samsung Exynos4 we have over a =
dozen
SYSMMU controllers for various multimedia blocks, but they are all =
exactly=20
the same. We use one iommu ops structure and store a pointer to the real =

iommu controller instance inside arch data of the client struct device.
=20
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
