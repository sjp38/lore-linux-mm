Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 2749D6B005D
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 08:47:03 -0400 (EDT)
Received: by lahd3 with SMTP id d3so637595lah.14
        for <linux-mm@kvack.org>; Wed, 22 Aug 2012 05:47:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1345630830-9586-3-git-send-email-hdoyu@nvidia.com>
References: <1345630830-9586-1-git-send-email-hdoyu@nvidia.com>
	<1345630830-9586-3-git-send-email-hdoyu@nvidia.com>
Date: Wed, 22 Aug 2012 21:47:00 +0900
Message-ID: <CAHQjnOOF7Ca-Dz8K_zcS=gxQsJvKYaWA3tqUeK1RSd-wLYZ44w@mail.gmail.com>
Subject: [RFC 2/4] ARM: dma-mapping: IOMMU allocates pages from pool with GFP_ATOMIC
From: KyongHo Cho <pullip.cho@samsung.com>
Content-Type: multipart/alternative; boundary=f46d0434bfde9af91004c7da2399
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroshi Doyu <hdoyu@nvidia.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "arnd@arndb.de" <arnd@arndb.de>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "chunsang.jeong@linaro.org" <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, "subashrp@gmail.com" <subashrp@gmail.com>, "minchan@kernel.org" <minchan@kernel.org>

--f46d0434bfde9af91004c7da2399
Content-Type: text/plain; charset=ISO-8859-1

Hi.

vzalloc() call in __iommu_alloc_buffer() also causes BUG() in atomic
context.


On Wed, Aug 22, 2012 at 7:20 PM, Hiroshi Doyu <hdoyu@nvidia.com> wrote:
> Makes use of the same atomic pool from DMA, and skips kernel page
> mapping which can involves sleep'able operation at allocating a kernel
> page table.
>
> Signed-off-by: Hiroshi Doyu <hdoyu@nvidia.com>
> ---
>  arch/arm/mm/dma-mapping.c |   22 ++++++++++++++++++----
>  1 files changed, 18 insertions(+), 4 deletions(-)
>
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index aec0c06..9260107 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -1028,7 +1028,6 @@ static struct page **__iommu_alloc_buffer(struct
device *dev, size_t size,
>         struct page **pages;
>         int count = size >> PAGE_SHIFT;
>         int array_size = count * sizeof(struct page *);
> -       int err;
>
>         if (array_size <= PAGE_SIZE)
>                 pages = kzalloc(array_size, gfp);
> @@ -1037,9 +1036,20 @@ static struct page **__iommu_alloc_buffer(struct
device *dev, size_t size,
>         if (!pages)
>                 return NULL;
>
> -       err = __alloc_fill_pages(&pages, count, gfp);
> -       if (err)
> -               goto error
> +       if (gfp & GFP_ATOMIC) {
> +               struct page *page;
> +               int i;
> +               void *addr = __alloc_from_pool(size, &page);
> +               if (!addr)
> +                       goto err_out;
> +
> +               for (i = 0; i < count; i++)
> +                       pages[i] = page + i;
> +       } else {
> +               int err = __alloc_fill_pages(&pages, count, gfp);
> +               if (err)
> +                       goto error;
> +       }
>
>         return pages;
>  error:
> @@ -1055,6 +1065,10 @@ static int __iommu_free_buffer(struct device *dev,
struct page **pages, size_t s
>         int count = size >> PAGE_SHIFT;
>         int array_size = count * sizeof(struct page *);
>         int i;
> +
> +       if (__free_from_pool(page_address(pages[0]), size))
> +               return 0;
> +
>         for (i = 0; i < count; i++)
>                 if (pages[i])
>                         __free_pages(pages[i], 0);
> --
> 1.7.5.4
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--f46d0434bfde9af91004c7da2399
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi.<br><br>vzalloc() call in __iommu_alloc_buffer() also causes BUG() in at=
omic context.<br><br><br>On Wed, Aug 22, 2012 at 7:20 PM, Hiroshi Doyu &lt;=
<a href=3D"mailto:hdoyu@nvidia.com">hdoyu@nvidia.com</a>&gt; wrote:<br>&gt;=
 Makes use of the same atomic pool from DMA, and skips kernel page<br>
&gt; mapping which can involves sleep&#39;able operation at allocating a ke=
rnel<br>&gt; page table.<br>&gt;<br>&gt; Signed-off-by: Hiroshi Doyu &lt;<a=
 href=3D"mailto:hdoyu@nvidia.com">hdoyu@nvidia.com</a>&gt;<br>&gt; ---<br>
&gt; =A0arch/arm/mm/dma-mapping.c | =A0 22 ++++++++++++++++++----<br>&gt; =
=A01 files changed, 18 insertions(+), 4 deletions(-)<br>&gt;<br>&gt; diff -=
-git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c<br>&gt; index =
aec0c06..9260107 100644<br>
&gt; --- a/arch/arm/mm/dma-mapping.c<br>&gt; +++ b/arch/arm/mm/dma-mapping.=
c<br>&gt; @@ -1028,7 +1028,6 @@ static struct page **__iommu_alloc_buffer(s=
truct device *dev, size_t size,<br>&gt; =A0 =A0 =A0 =A0 struct page **pages=
;<br>
&gt; =A0 =A0 =A0 =A0 int count =3D size &gt;&gt; PAGE_SHIFT;<br>&gt; =A0 =
=A0 =A0 =A0 int array_size =3D count * sizeof(struct page *);<br>&gt; - =A0=
 =A0 =A0 int err;<br>&gt;<br>&gt; =A0 =A0 =A0 =A0 if (array_size &lt;=3D PA=
GE_SIZE)<br>&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pages =3D kzalloc(array_si=
ze, gfp);<br>
&gt; @@ -1037,9 +1036,20 @@ static struct page **__iommu_alloc_buffer(struc=
t device *dev, size_t size,<br>&gt; =A0 =A0 =A0 =A0 if (!pages)<br>&gt; =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;<br>&gt;<br>&gt; - =A0 =A0 =A0 err=
 =3D __alloc_fill_pages(&amp;pages, count, gfp);<br>
&gt; - =A0 =A0 =A0 if (err)<br>&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto erro=
r<br>&gt; + =A0 =A0 =A0 if (gfp &amp; GFP_ATOMIC) {<br>&gt; + =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 struct page *page;<br>&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 in=
t i;<br>&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *addr =3D __alloc_from_pool=
(size, &amp;page);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!addr)<br>&gt; + =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 goto err_out;<br>&gt; +<br>&gt; + =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 for (i =3D 0; i &lt; count; i++)<br>&gt; + =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 pages[i] =3D page + i;<br>&gt; + =A0 =A0 =A0 } else=
 {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int err =3D __alloc_fill_pages(&amp;page=
s, count, gfp);<br>&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err)<br>&gt; + =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto error;<br>&gt; + =A0 =A0 =
=A0 }<br>&gt;<br>&gt; =A0 =A0 =A0 =A0 return pages;<br>&gt; =A0error:<br>
&gt; @@ -1055,6 +1065,10 @@ static int __iommu_free_buffer(struct device *d=
ev, struct page **pages, size_t s<br>&gt; =A0 =A0 =A0 =A0 int count =3D siz=
e &gt;&gt; PAGE_SHIFT;<br>&gt; =A0 =A0 =A0 =A0 int array_size =3D count * s=
izeof(struct page *);<br>
&gt; =A0 =A0 =A0 =A0 int i;<br>&gt; +<br>&gt; + =A0 =A0 =A0 if (__free_from=
_pool(page_address(pages[0]), size))<br>&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
return 0;<br>&gt; +<br>&gt; =A0 =A0 =A0 =A0 for (i =3D 0; i &lt; count; i++=
)<br>&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pages[i])<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __free_pages(pages[i],=
 0);<br>&gt; --<br>&gt; 1.7.5.4<br>&gt;<br>&gt; --<br>&gt; To unsubscribe, =
send a message with &#39;unsubscribe linux-mm&#39; in<br>&gt; the body to <=
a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org</a>. =A0For more =
info on Linux MM,<br>
&gt; see: <a href=3D"http://www.linux-mm.org/">http://www.linux-mm.org/</a>=
 .<br>&gt; Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:don=
t@kvack.org">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org=
">email@kvack.org</a> &lt;/a&gt;<br>
<br>

--f46d0434bfde9af91004c7da2399--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
