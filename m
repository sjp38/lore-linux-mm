Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7B8506B004A
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 14:32:41 -0400 (EDT)
Received: by mail-wy0-f175.google.com with SMTP id 30so511604wyg.34
        for <linux-mm@kvack.org>; Thu, 14 Jul 2011 11:32:38 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 14 Jul 2011 13:32:38 -0500
Message-ID: <CAB-zwWhRQmv8euqN6jeJP=tXTQgGQ3buRJEf=4aPtTOBsh+Z2Q@mail.gmail.com>
Subject: [Linaro-mm-sig] [RFC 2/2] ARM: initial proof-of-concept IOMMU mapper
 for DMA-mapping
From: "Ramirez Luna, Omar" <omar.ramirez@ti.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Joerg Roedel <joro@8bytes.org>, Arnd Bergmann <arnd@arndb.de>

Hi Marek,

> Add initial proof of concept implementation of DMA-mapping API for
> devices that have IOMMU support. Right now only dma_alloc_coherent,
> dma_free_coherent and dma_mmap_coherent functions are supported.
>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
...
> diff --git a/arch/arm/include/asm/dma-iommu.h b/arch/arm/include/asm/dma-=
iommu.h
> new file mode 100644
> index 0000000..c246ff3
> --- /dev/null
> +++ b/arch/arm/include/asm/dma-iommu.h
...
> +int __init arm_iommu_assign_device(struct device *dev, dma_addr_t base, =
dma_addr_t size);

__init causes a panic if the iommu is assigned after boot.

In OMAP3 the iommu driver controls isp and dsp address spaces, it is
loaded until any of those 2 drivers is needed.

> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index f8c6972..b6397c1 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
...
> +static void *arm_iommu_alloc_attrs(struct device *dev, size_t size,
> + =A0 =A0 =A0 =A0 =A0 dma_addr_t *handle, gfp_t gfp, struct dma_attrs *at=
trs)
> +{
> + =A0 =A0 =A0 struct dma_iommu_mapping *mapping =3D dev->archdata.mapping=
;
> + =A0 =A0 =A0 struct page **pages;
> + =A0 =A0 =A0 void *addr =3D NULL;
> + =A0 =A0 =A0 pgprot_t prot;
> +
> + =A0 =A0 =A0 if (dma_get_attr(DMA_ATTR_WRITE_COMBINE, attrs))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 prot =3D pgprot_writecombine(pgprot_kernel)=
;
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 prot =3D pgprot_dmacoherent(pgprot_kernel);
> +
> + =A0 =A0 =A0 arm_iommu_init(dev);

I found useful to call arm_iommu_init inside arm_iommu_assign_device
instead. So, then gen_pool is created only once without the
mapping->pool check, instead of relying on the call to ...alloc_attrs,
which in my case I never use because I'm implementing
iommu_map|unmap_sg functions to see how it goes with the dma mapping.

Regards,

Omar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
