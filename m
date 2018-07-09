Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 53F9D6B0280
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 13:31:37 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id u1-v6so1795063wrs.18
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 10:31:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e71-v6sor4265279wmg.30.2018.07.09.10.31.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Jul 2018 10:31:35 -0700 (PDT)
MIME-Version: 1.0
References: <CGME20180709122020eucas1p21a71b092975cb4a3b9954ffc63f699d1@eucas1p2.samsung.com>
 <20180709121956.20200-1-m.szyprowski@samsung.com> <20180709122020eucas1p21a71b092975cb4a3b9954ffc63f699d1~-sqUFoa-h2939329393eucas1p2Y@eucas1p2.samsung.com>
In-Reply-To: <20180709122020eucas1p21a71b092975cb4a3b9954ffc63f699d1~-sqUFoa-h2939329393eucas1p2Y@eucas1p2.samsung.com>
From: =?UTF-8?Q?Micha=C5=82_Nazarewicz?= <mina86@mina86.com>
Date: Mon, 9 Jul 2018 15:25:36 +0100
Message-ID: <CA+pa1O2ewrubkQgSQxMwbXkX6cfry9jK0WDhCjdM1meOZ9dN_w@mail.gmail.com>
Subject: Re: [PATCH 2/2] dma: remove unsupported gfp_mask parameter from dma_alloc_from_contiguous()
Content-Type: multipart/alternative; boundary="0000000000009f36cd05709462d9"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Paul Mackerras <paulus@ozlabs.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Chris Zankel <chris@zankel.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Joerg Roedel <joro@8bytes.org>, Sumit Semwal <sumit.semwal@linaro.org>, Robin Murphy <robin.murphy@arm.com>, Laura Abbott <labbott@redhat.com>, linaro-mm-sig@lists.linaro.org

--0000000000009f36cd05709462d9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 9 Jul 2018 13:20 Marek Szyprowski, <m.szyprowski@samsung.com> wrote=
:

> The CMA memory allocator doesn't support standard gfp flags for memory
> allocation, so there is no point having it as a parameter for
> dma_alloc_from_contiguous() function. Replace it by a boolean no_warn
> argument, which covers all the underlaying cma_alloc() function supports.
>
> This will help to avoid giving false feeling that this function supports
> standard gfp flags and callers can pass __GFP_ZERO to get zeroed buffer,
> what has already been an issue: see commit dd65a941f6ba ("arm64:
> dma-mapping: clear buffers allocated with FORCE_CONTIGUOUS flag").
>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
>

Acked-by: Micha=C5=82 Nazarewicz <mina86@mina86.com>

---
>  arch/arm/mm/dma-mapping.c      | 5 +++--
>  arch/arm64/mm/dma-mapping.c    | 4 ++--
>  arch/xtensa/kernel/pci-dma.c   | 2 +-
>  drivers/iommu/amd_iommu.c      | 2 +-
>  drivers/iommu/intel-iommu.c    | 3 ++-
>  include/linux/dma-contiguous.h | 4 ++--
>  kernel/dma/contiguous.c        | 7 +++----
>  kernel/dma/direct.c            | 3 ++-
>  8 files changed, 16 insertions(+), 14 deletions(-)
>
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index be0fa7e39c26..121c6c3ba9e0 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -594,7 +594,7 @@ static void *__alloc_from_contiguous(struct device
> *dev, size_t size,
>         struct page *page;
>         void *ptr =3D NULL;
>
> -       page =3D dma_alloc_from_contiguous(dev, count, order, gfp);
> +       page =3D dma_alloc_from_contiguous(dev, count, order, gfp &
> __GFP_NOWARN);
>         if (!page)
>                 return NULL;
>
> @@ -1294,7 +1294,8 @@ static struct page **__iommu_alloc_buffer(struct
> device *dev, size_t size,
>                 unsigned long order =3D get_order(size);
>                 struct page *page;
>
> -               page =3D dma_alloc_from_contiguous(dev, count, order, gfp=
);
> +               page =3D dma_alloc_from_contiguous(dev, count, order,
> +                                                gfp & __GFP_NOWARN);
>                 if (!page)
>                         goto error;
>
> diff --git a/arch/arm64/mm/dma-mapping.c b/arch/arm64/mm/dma-mapping.c
> index 61e93f0b5482..072c51fb07d7 100644
> --- a/arch/arm64/mm/dma-mapping.c
> +++ b/arch/arm64/mm/dma-mapping.c
> @@ -355,7 +355,7 @@ static int __init atomic_pool_init(void)
>
>         if (dev_get_cma_area(NULL))
>                 page =3D dma_alloc_from_contiguous(NULL, nr_pages,
> -                                                pool_size_order,
> GFP_KERNEL);
> +                                                pool_size_order, false);
>         else
>                 page =3D alloc_pages(GFP_DMA32, pool_size_order);
>
> @@ -573,7 +573,7 @@ static void *__iommu_alloc_attrs(struct device *dev,
> size_t size,
>                 struct page *page;
>
>                 page =3D dma_alloc_from_contiguous(dev, size >> PAGE_SHIF=
T,
> -                                                get_order(size), gfp);
> +                                       get_order(size), gfp &
> __GFP_NOWARN);
>                 if (!page)
>                         return NULL;
>
> diff --git a/arch/xtensa/kernel/pci-dma.c b/arch/xtensa/kernel/pci-dma.c
> index ba4640cc0093..b2c7ba91fb08 100644
> --- a/arch/xtensa/kernel/pci-dma.c
> +++ b/arch/xtensa/kernel/pci-dma.c
> @@ -137,7 +137,7 @@ static void *xtensa_dma_alloc(struct device *dev,
> size_t size,
>
>         if (gfpflags_allow_blocking(flag))
>                 page =3D dma_alloc_from_contiguous(dev, count,
> get_order(size),
> -                                                flag);
> +                                                flag & __GFP_NOWARN);
>
>         if (!page)
>                 page =3D alloc_pages(flag, get_order(size));
> diff --git a/drivers/iommu/amd_iommu.c b/drivers/iommu/amd_iommu.c
> index 64cfe854e0f5..5ec97ffb561a 100644
> --- a/drivers/iommu/amd_iommu.c
> +++ b/drivers/iommu/amd_iommu.c
> @@ -2622,7 +2622,7 @@ static void *alloc_coherent(struct device *dev,
> size_t size,
>                         return NULL;
>
>                 page =3D dma_alloc_from_contiguous(dev, size >> PAGE_SHIF=
T,
> -                                                get_order(size), flag);
> +                                       get_order(size), flag &
> __GFP_NOWARN);
>                 if (!page)
>                         return NULL;
>         }
> diff --git a/drivers/iommu/intel-iommu.c b/drivers/iommu/intel-iommu.c
> index 869321c594e2..dd2d343428ab 100644
> --- a/drivers/iommu/intel-iommu.c
> +++ b/drivers/iommu/intel-iommu.c
> @@ -3746,7 +3746,8 @@ static void *intel_alloc_coherent(struct device
> *dev, size_t size,
>         if (gfpflags_allow_blocking(flags)) {
>                 unsigned int count =3D size >> PAGE_SHIFT;
>
> -               page =3D dma_alloc_from_contiguous(dev, count, order, fla=
gs);
> +               page =3D dma_alloc_from_contiguous(dev, count, order,
> +                                                flags & __GFP_NOWARN);
>                 if (page && iommu_no_mapping(dev) &&
>                     page_to_phys(page) + size > dev->coherent_dma_mask) {
>                         dma_release_from_contiguous(dev, page, count);
> diff --git a/include/linux/dma-contiguous.h
> b/include/linux/dma-contiguous.h
> index 3c5a4cb3eb95..f247e8aa5e3d 100644
> --- a/include/linux/dma-contiguous.h
> +++ b/include/linux/dma-contiguous.h
> @@ -112,7 +112,7 @@ static inline int dma_declare_contiguous(struct devic=
e
> *dev, phys_addr_t size,
>  }
>
>  struct page *dma_alloc_from_contiguous(struct device *dev, size_t count,
> -                                      unsigned int order, gfp_t gfp_mask=
);
> +                                      unsigned int order, bool no_warn);
>  bool dma_release_from_contiguous(struct device *dev, struct page *pages,
>                                  int count);
>
> @@ -145,7 +145,7 @@ int dma_declare_contiguous(struct device *dev,
> phys_addr_t size,
>
>  static inline
>  struct page *dma_alloc_from_contiguous(struct device *dev, size_t count,
> -                                      unsigned int order, gfp_t gfp_mask=
)
> +                                      unsigned int order, bool no_warn)
>  {
>         return NULL;
>  }
> diff --git a/kernel/dma/contiguous.c b/kernel/dma/contiguous.c
> index 19ea5d70150c..286d82329eb0 100644
> --- a/kernel/dma/contiguous.c
> +++ b/kernel/dma/contiguous.c
> @@ -178,7 +178,7 @@ int __init dma_contiguous_reserve_area(phys_addr_t
> size, phys_addr_t base,
>   * @dev:   Pointer to device for which the allocation is performed.
>   * @count: Requested number of pages.
>   * @align: Requested alignment of pages (in PAGE_SIZE order).
> - * @gfp_mask: GFP flags to use for this allocation.
> + * @no_warn: Avoid printing message about failed allocation.
>   *
>   * This function allocates memory buffer for specified device. It uses
>   * device specific contiguous memory area if available or the default
> @@ -186,13 +186,12 @@ int __init dma_contiguous_reserve_area(phys_addr_t
> size, phys_addr_t base,
>   * function.
>   */
>  struct page *dma_alloc_from_contiguous(struct device *dev, size_t count,
> -                                      unsigned int align, gfp_t gfp_mask=
)
> +                                      unsigned int align, bool no_warn)
>  {
>         if (align > CONFIG_CMA_ALIGNMENT)
>                 align =3D CONFIG_CMA_ALIGNMENT;
>
> -       return cma_alloc(dev_get_cma_area(dev), count, align,
> -                        gfp_mask & __GFP_NOWARN);
> +       return cma_alloc(dev_get_cma_area(dev), count, align, no_warn);
>  }
>
>  /**
> diff --git a/kernel/dma/direct.c b/kernel/dma/direct.c
> index 8be8106270c2..e0241beeb645 100644
> --- a/kernel/dma/direct.c
> +++ b/kernel/dma/direct.c
> @@ -78,7 +78,8 @@ void *dma_direct_alloc(struct device *dev, size_t size,
> dma_addr_t *dma_handle,
>  again:
>         /* CMA can be used only in the context which permits sleeping */
>         if (gfpflags_allow_blocking(gfp)) {
> -               page =3D dma_alloc_from_contiguous(dev, count, page_order=
,
> gfp);
> +               page =3D dma_alloc_from_contiguous(dev, count, page_order=
,
> +                                                gfp & __GFP_NOWARN);
>                 if (page && !dma_coherent_ok(dev, page_to_phys(page),
> size)) {
>                         dma_release_from_contiguous(dev, page, count);
>                         page =3D NULL;
> --
> 2.17.1
>
>

--0000000000009f36cd05709462d9
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><div class=3D"gmail_quote"><div dir=3D"ltr">On Mon, =
9 Jul 2018 13:20 Marek Szyprowski, &lt;<a href=3D"mailto:m.szyprowski@samsu=
ng.com">m.szyprowski@samsung.com</a>&gt; wrote:<br></div><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex">The CMA memory allocator doesn&#39;t support standard gfp fla=
gs for memory<br>
allocation, so there is no point having it as a parameter for<br>
dma_alloc_from_contiguous() function. Replace it by a boolean no_warn<br>
argument, which covers all the underlaying cma_alloc() function supports.<b=
r>
<br>
This will help to avoid giving false feeling that this function supports<br=
>
standard gfp flags and callers can pass __GFP_ZERO to get zeroed buffer,<br=
>
what has already been an issue: see commit dd65a941f6ba (&quot;arm64:<br>
dma-mapping: clear buffers allocated with FORCE_CONTIGUOUS flag&quot;).<br>
<br>
Signed-off-by: Marek Szyprowski &lt;<a href=3D"mailto:m.szyprowski@samsung.=
com" target=3D"_blank" rel=3D"noreferrer">m.szyprowski@samsung.com</a>&gt;<=
br></blockquote></div></div><div dir=3D"auto"><br></div><div dir=3D"auto"><=
span style=3D"font-family:sans-serif">Acked-by: Micha=C5=82 Nazarewicz &lt;=
<a href=3D"mailto:mina86@mina86.com">mina86@mina86.com</a>&gt;</span><br></=
div><div dir=3D"auto"><br></div><div dir=3D"auto"><div class=3D"gmail_quote=
"><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:=
1px #ccc solid;padding-left:1ex">
---<br>
=C2=A0arch/arm/mm/dma-mapping.c=C2=A0 =C2=A0 =C2=A0 | 5 +++--<br>
=C2=A0arch/arm64/mm/dma-mapping.c=C2=A0 =C2=A0 | 4 ++--<br>
=C2=A0arch/xtensa/kernel/pci-dma.c=C2=A0 =C2=A0| 2 +-<br>
=C2=A0drivers/iommu/amd_iommu.c=C2=A0 =C2=A0 =C2=A0 | 2 +-<br>
=C2=A0drivers/iommu/intel-iommu.c=C2=A0 =C2=A0 | 3 ++-<br>
=C2=A0include/linux/dma-contiguous.h | 4 ++--<br>
=C2=A0kernel/dma/contiguous.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 | 7 +++----<br>
=C2=A0kernel/dma/direct.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 3 ++-<=
br>
=C2=A08 files changed, 16 insertions(+), 14 deletions(-)<br>
<br>
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c<br>
index be0fa7e39c26..121c6c3ba9e0 100644<br>
--- a/arch/arm/mm/dma-mapping.c<br>
+++ b/arch/arm/mm/dma-mapping.c<br>
@@ -594,7 +594,7 @@ static void *__alloc_from_contiguous(struct device *dev=
, size_t size,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct page *page;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 void *ptr =3D NULL;<br>
<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D dma_alloc_from_contiguous(dev, count, =
order, gfp);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D dma_alloc_from_contiguous(dev, count, =
order, gfp &amp; __GFP_NOWARN);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!page)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return NULL;<br>
<br>
@@ -1294,7 +1294,8 @@ static struct page **__iommu_alloc_buffer(struct devi=
ce *dev, size_t size,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long order=
 =3D get_order(size);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct page *page;<=
br>
<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D dma_alloc_=
from_contiguous(dev, count, order, gfp);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D dma_alloc_=
from_contiguous(dev, count, order,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 gfp &amp; __GFP_NOWARN);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!page)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 goto error;<br>
<br>
diff --git a/arch/arm64/mm/dma-mapping.c b/arch/arm64/mm/dma-mapping.c<br>
index 61e93f0b5482..072c51fb07d7 100644<br>
--- a/arch/arm64/mm/dma-mapping.c<br>
+++ b/arch/arm64/mm/dma-mapping.c<br>
@@ -355,7 +355,7 @@ static int __init atomic_pool_init(void)<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (dev_get_cma_area(NULL))<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D dma_alloc_=
from_contiguous(NULL, nr_pages,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 pool_size_order, GFP_KERNEL);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 pool_size_order, false);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 else<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D alloc_page=
s(GFP_DMA32, pool_size_order);<br>
<br>
@@ -573,7 +573,7 @@ static void *__iommu_alloc_attrs(struct device *dev, si=
ze_t size,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct page *page;<=
br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D dma_alloc_=
from_contiguous(dev, size &gt;&gt; PAGE_SHIFT,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 get_order(size), gfp);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0get_order=
(size), gfp &amp; __GFP_NOWARN);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!page)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 return NULL;<br>
<br>
diff --git a/arch/xtensa/kernel/pci-dma.c b/arch/xtensa/kernel/pci-dma.c<br=
>
index ba4640cc0093..b2c7ba91fb08 100644<br>
--- a/arch/xtensa/kernel/pci-dma.c<br>
+++ b/arch/xtensa/kernel/pci-dma.c<br>
@@ -137,7 +137,7 @@ static void *xtensa_dma_alloc(struct device *dev, size_=
t size,<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (gfpflags_allow_blocking(flag))<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D dma_alloc_=
from_contiguous(dev, count, get_order(size),<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 flag);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 flag &amp; __GFP_NOWARN);<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!page)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D alloc_page=
s(flag, get_order(size));<br>
diff --git a/drivers/iommu/amd_iommu.c b/drivers/iommu/amd_iommu.c<br>
index 64cfe854e0f5..5ec97ffb561a 100644<br>
--- a/drivers/iommu/amd_iommu.c<br>
+++ b/drivers/iommu/amd_iommu.c<br>
@@ -2622,7 +2622,7 @@ static void *alloc_coherent(struct device *dev, size_=
t size,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 return NULL;<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D dma_alloc_=
from_contiguous(dev, size &gt;&gt; PAGE_SHIFT,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 get_order(size), flag);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0get_order=
(size), flag &amp; __GFP_NOWARN);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!page)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 return NULL;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
diff --git a/drivers/iommu/intel-iommu.c b/drivers/iommu/intel-iommu.c<br>
index 869321c594e2..dd2d343428ab 100644<br>
--- a/drivers/iommu/intel-iommu.c<br>
+++ b/drivers/iommu/intel-iommu.c<br>
@@ -3746,7 +3746,8 @@ static void *intel_alloc_coherent(struct device *dev,=
 size_t size,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (gfpflags_allow_blocking(flags)) {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned int count =
=3D size &gt;&gt; PAGE_SHIFT;<br>
<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D dma_alloc_=
from_contiguous(dev, count, order, flags);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D dma_alloc_=
from_contiguous(dev, count, order,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 flags &amp; __GFP_NOWARN);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (page &amp;&amp;=
 iommu_no_mapping(dev) &amp;&amp;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page_=
to_phys(page) + size &gt; dev-&gt;coherent_dma_mask) {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 dma_release_from_contiguous(dev, page, count);<br>
diff --git a/include/linux/dma-contiguous.h b/include/linux/dma-contiguous.=
h<br>
index 3c5a4cb3eb95..f247e8aa5e3d 100644<br>
--- a/include/linux/dma-contiguous.h<br>
+++ b/include/linux/dma-contiguous.h<br>
@@ -112,7 +112,7 @@ static inline int dma_declare_contiguous(struct device =
*dev, phys_addr_t size,<br>
=C2=A0}<br>
<br>
=C2=A0struct page *dma_alloc_from_contiguous(struct device *dev, size_t cou=
nt,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned int or=
der, gfp_t gfp_mask);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned int or=
der, bool no_warn);<br>
=C2=A0bool dma_release_from_contiguous(struct device *dev, struct page *pag=
es,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int count);<br>
<br>
@@ -145,7 +145,7 @@ int dma_declare_contiguous(struct device *dev, phys_add=
r_t size,<br>
<br>
=C2=A0static inline<br>
=C2=A0struct page *dma_alloc_from_contiguous(struct device *dev, size_t cou=
nt,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned int or=
der, gfp_t gfp_mask)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned int or=
der, bool no_warn)<br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return NULL;<br>
=C2=A0}<br>
diff --git a/kernel/dma/contiguous.c b/kernel/dma/contiguous.c<br>
index 19ea5d70150c..286d82329eb0 100644<br>
--- a/kernel/dma/contiguous.c<br>
+++ b/kernel/dma/contiguous.c<br>
@@ -178,7 +178,7 @@ int __init dma_contiguous_reserve_area(phys_addr_t size=
, phys_addr_t base,<br>
=C2=A0 * @dev:=C2=A0 =C2=A0Pointer to device for which the allocation is pe=
rformed.<br>
=C2=A0 * @count: Requested number of pages.<br>
=C2=A0 * @align: Requested alignment of pages (in PAGE_SIZE order).<br>
- * @gfp_mask: GFP flags to use for this allocation.<br>
+ * @no_warn: Avoid printing message about failed allocation.<br>
=C2=A0 *<br>
=C2=A0 * This function allocates memory buffer for specified device. It use=
s<br>
=C2=A0 * device specific contiguous memory area if available or the default=
<br>
@@ -186,13 +186,12 @@ int __init dma_contiguous_reserve_area(phys_addr_t si=
ze, phys_addr_t base,<br>
=C2=A0 * function.<br>
=C2=A0 */<br>
=C2=A0struct page *dma_alloc_from_contiguous(struct device *dev, size_t cou=
nt,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned int al=
ign, gfp_t gfp_mask)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned int al=
ign, bool no_warn)<br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (align &gt; CONFIG_CMA_ALIGNMENT)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 align =3D CONFIG_CM=
A_ALIGNMENT;<br>
<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0return cma_alloc(dev_get_cma_area(dev), count, =
align,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 gfp_mask &amp; __GFP_NOWARN);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return cma_alloc(dev_get_cma_area(dev), count, =
align, no_warn);<br>
=C2=A0}<br>
<br>
=C2=A0/**<br>
diff --git a/kernel/dma/direct.c b/kernel/dma/direct.c<br>
index 8be8106270c2..e0241beeb645 100644<br>
--- a/kernel/dma/direct.c<br>
+++ b/kernel/dma/direct.c<br>
@@ -78,7 +78,8 @@ void *dma_direct_alloc(struct device *dev, size_t size, d=
ma_addr_t *dma_handle,<br>
=C2=A0again:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /* CMA can be used only in the context which pe=
rmits sleeping */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (gfpflags_allow_blocking(gfp)) {<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D dma_alloc_=
from_contiguous(dev, count, page_order, gfp);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D dma_alloc_=
from_contiguous(dev, count, page_order,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 gfp &amp; __GFP_NOWARN);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (page &amp;&amp;=
 !dma_coherent_ok(dev, page_to_phys(page), size)) {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 dma_release_from_contiguous(dev, page, count);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 page =3D NULL;<br>
-- <br>
2.17.1<br>
<br>
</blockquote></div></div></div>

--0000000000009f36cd05709462d9--
