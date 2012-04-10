Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id AF8EF6B0083
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 08:57:53 -0400 (EDT)
Received: from euspt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M29008WPLCCHB@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Tue, 10 Apr 2012 13:57:48 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M2900C5SLCF19@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 10 Apr 2012 13:57:52 +0100 (BST)
Date: Tue, 10 Apr 2012 14:57:48 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv8 10/10] ARM: dma-mapping: add support for IOMMU mapper
In-reply-to: <201204101158.29590.arnd@arndb.de>
Message-id: <002d01cd1719$87ac7520$97055f60$%szyprowski@samsung.com>
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
>=20
> * Why is this exported to modules? Which device drivers do you expect
>   to call it?
>=20
> * Why do you pass the bus_type in here? That seems like the completely
>   wrong thing to do when all devices are on the same bus type (e.g.
>   amba or platform) but are connected to different instances that each
>   have their own iommu. I guess this is a question for J=F6rg, because =
the
>   base iommu interface provides iommu_domain_alloc().

I will soon post a patch which shows how my IOMMU aware dma-mapping=20
integrates with Samsung Exynos4 SYSMMU driver, so I will be able to =
answer
all your questions by pointing to the respective lines in either IOMMU
framework or my integration code.

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
