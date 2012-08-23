Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 9ED546B0044
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 23:57:03 -0400 (EDT)
Received: by lahd3 with SMTP id d3so198144lah.14
        for <linux-mm@kvack.org>; Wed, 22 Aug 2012 20:57:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120822.163648.3800987367886904.hdoyu@nvidia.com>
References: <1345630830-9586-1-git-send-email-hdoyu@nvidia.com>
	<1345630830-9586-3-git-send-email-hdoyu@nvidia.com>
	<CAHQjnOOF7Ca-Dz8K_zcS=gxQsJvKYaWA3tqUeK1RSd-wLYZ44w@mail.gmail.com>
	<20120822.163648.3800987367886904.hdoyu@nvidia.com>
Date: Thu, 23 Aug 2012 12:57:01 +0900
Message-ID: <CAHQjnOMnGMTgrcK+aNsn1OuePdLbPyWkOJoArhUJes4zkwzHAQ@mail.gmail.com>
Subject: [RFC 2/4] ARM: dma-mapping: IOMMU allocates pages from pool with GFP_ATOMIC
From: KyongHo Cho <pullip.cho@samsung.com>
Content-Type: multipart/alternative; boundary=f46d040715c508885304c7e6da3c
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroshi Doyu <hdoyu@nvidia.com>
Cc: "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "arnd@arndb.de" <arnd@arndb.de>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "chunsang.jeong@linaro.org" <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, "subashrp@gmail.com" <subashrp@gmail.com>, "minchan@kernel.org" <minchan@kernel.org>

--f46d040715c508885304c7e6da3c
Content-Type: text/plain; charset=ISO-8859-1

Hi.

We have faced with WQXGA(2560x1600) support and framebuffers become
dramatically larger.
Moreover, high resolution camera sensors also press memory use more than
the screen size.

However, I think that it is enough with your change because allocation
failure of several
contiguous pages also shows that the system don't have enough memory.

On Wed, Aug 22, 2012 at 10:36 PM, Hiroshi Doyu <hdoyu@nvidia.com> wrote:
> Hi,
>
> KyongHo Cho <pullip.cho@samsung.com> wrote @ Wed, 22 Aug 2012 14:47:00
+0200:
>
>> vzalloc() call in __iommu_alloc_buffer() also causes BUG() in atomic
context.
>
> Right.
>
> I've been thinking that kzalloc() may be enough here, since
> vzalloc() was introduced to avoid allocation failure for big chunk of
> memory, but I think that it's unlikely that the number of page array
> can be so big. So I propose to drop vzalloc() here, and just simply to
> use kzalloc only as below(*1).
>
> For example,
>
> 1920(H) x 1080(W) x 4(bytes) ~= 8MiB
>
> For 8 MiB buffer,
>   8(MiB) * 1024 = 8192(KiB)
>   8192(KiB) / 4(KiB/page) = 2048 pages
>   sizeof(struct page *) = 4 bytes
>   2048(pages) * 4(bytes/page) = 8192(bytes) = 8(KiB)
>   8(KiB) / 4(KiB/page) = 2 pages
>
> If the above estimation is right(I hope;)), the necessary pages are
> _at most_ 2 pages. If the system gets into the situation to fail to
> allocate 2 contiguous pages, that's real the problem. I guess that
> that kind of fragmentation problem would be solved with page migration
> or something, especially nowadays devices are getting larger memories.
>
> *1:
> From a613c40d1b3d4fb1577cdb0807a74e8dbd08a3e6 Mon Sep 17 00:00:00 2001
> From: Hiroshi Doyu <hdoyu@nvidia.com>
> Date: Wed, 22 Aug 2012 16:25:54 +0300
> Subject: [PATCH 1/1] ARM: dma-mapping: Use only kzalloc without vzalloc
>
> Use only kzalloc for atomic allocation.
>
> Signed-off-by: Hiroshi Doyu <hdoyu@nvidia.com>
> ---
>  arch/arm/mm/dma-mapping.c |   10 ++--------
>  1 files changed, 2 insertions(+), 8 deletions(-)
>
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index 4656c0f..d4f1cf2 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -1083,10 +1083,7 @@ static struct page **__iommu_alloc_buffer(struct
device *dev, size_t size,
>         int count = size >> PAGE_SHIFT;
>         int array_size = count * sizeof(struct page *);
>
> -       if (array_size <= PAGE_SIZE)
> -               pages = kzalloc(array_size, gfp);
> -       else
> -               pages = vzalloc(array_size);
> +       pages = kzalloc(array_size, gfp);
>         if (!pages)
>                 return NULL;
>
> @@ -1107,10 +1104,7 @@ static struct page **__iommu_alloc_buffer(struct
device *dev, size_t size,
>
>         return pages;
>  error:
> -       if (array_size <= PAGE_SIZE)
> -               kfree(pages);
> -       else
> -               vfree(pages);
> +       kfree(pages);
>         return NULL;
>  }
>
> --
> 1.7.5.4
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a hrefmailto:"dont@kvack.org"> email@kvack.org </a>

--f46d040715c508885304c7e6da3c
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi.<br><br>We have faced with WQXGA(2560x1600) support and framebuffers bec=
ome dramatically larger.<br>Moreover, high resolution camera sensors also p=
ress memory use more than the screen size.<br><br>However, I think that it =
is enough with your change because allocation failure of several<br>
contiguous pages also shows that the system don&#39;t have enough memory.<b=
r><br>On Wed, Aug 22, 2012 at 10:36 PM, Hiroshi Doyu &lt;<a href=3D"mailto:=
hdoyu@nvidia.com">hdoyu@nvidia.com</a>&gt; wrote:<br>&gt; Hi,<br>&gt;<br>
&gt; KyongHo Cho &lt;<a href=3D"mailto:pullip.cho@samsung.com">pullip.cho@s=
amsung.com</a>&gt; wrote @ Wed, 22 Aug 2012 14:47:00 +0200:<br>&gt;<br>&gt;=
&gt; vzalloc() call in __iommu_alloc_buffer() also causes BUG() in atomic c=
ontext.<br>
&gt;<br>&gt; Right.<br>&gt;<br>&gt; I&#39;ve been thinking that kzalloc() m=
ay be enough here, since<br>&gt; vzalloc() was introduced to avoid allocati=
on failure for big chunk of<br>&gt; memory, but I think that it&#39;s unlik=
ely that the number of page array<br>
&gt; can be so big. So I propose to drop vzalloc() here, and just simply to=
<br>&gt; use kzalloc only as below(*1).<br>&gt;<br>&gt; For example,<br>&gt=
;<br>&gt; 1920(H) x 1080(W) x 4(bytes) ~=3D 8MiB<br>&gt;<br>&gt; For 8 MiB =
buffer,<br>
&gt; =A0 8(MiB) * 1024 =3D 8192(KiB)<br>&gt; =A0 8192(KiB) / 4(KiB/page) =
=3D 2048 pages<br>&gt; =A0 sizeof(struct page *) =3D 4 bytes<br>&gt; =A0 20=
48(pages) * 4(bytes/page) =3D 8192(bytes) =3D 8(KiB)<br>&gt; =A0 8(KiB) / 4=
(KiB/page) =3D 2 pages<br>
&gt;<br>&gt; If the above estimation is right(I hope;)), the necessary page=
s are<br>&gt; _at most_ 2 pages. If the system gets into the situation to f=
ail to<br>&gt; allocate 2 contiguous pages, that&#39;s real the problem. I =
guess that<br>
&gt; that kind of fragmentation problem would be solved with page migration=
<br>&gt; or something, especially nowadays devices are getting larger memor=
ies.<br>&gt;<br>&gt; *1:<br>&gt; From a613c40d1b3d4fb1577cdb0807a74e8dbd08a=
3e6 Mon Sep 17 00:00:00 2001<br>
&gt; From: Hiroshi Doyu &lt;<a href=3D"mailto:hdoyu@nvidia.com">hdoyu@nvidi=
a.com</a>&gt;<br>&gt; Date: Wed, 22 Aug 2012 16:25:54 +0300<br>&gt; Subject=
: [PATCH 1/1] ARM: dma-mapping: Use only kzalloc without vzalloc<br>&gt;<br=
>
&gt; Use only kzalloc for atomic allocation.<br>&gt;<br>&gt; Signed-off-by:=
 Hiroshi Doyu &lt;<a href=3D"mailto:hdoyu@nvidia.com">hdoyu@nvidia.com</a>&=
gt;<br>&gt; ---<br>&gt; =A0arch/arm/mm/dma-mapping.c | =A0 10 ++--------<br=
>&gt; =A01 files changed, 2 insertions(+), 8 deletions(-)<br>
&gt;<br>&gt; diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mappi=
ng.c<br>&gt; index 4656c0f..d4f1cf2 100644<br>&gt; --- a/arch/arm/mm/dma-ma=
pping.c<br>&gt; +++ b/arch/arm/mm/dma-mapping.c<br>&gt; @@ -1083,10 +1083,7=
 @@ static struct page **__iommu_alloc_buffer(struct device *dev, size_t si=
ze,<br>
&gt; =A0 =A0 =A0 =A0 int count =3D size &gt;&gt; PAGE_SHIFT;<br>&gt; =A0 =
=A0 =A0 =A0 int array_size =3D count * sizeof(struct page *);<br>&gt;<br>&g=
t; - =A0 =A0 =A0 if (array_size &lt;=3D PAGE_SIZE)<br>&gt; - =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 pages =3D kzalloc(array_size, gfp);<br>
&gt; - =A0 =A0 =A0 else<br>&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 pages =3D vza=
lloc(array_size);<br>&gt; + =A0 =A0 =A0 pages =3D kzalloc(array_size, gfp);=
<br>&gt; =A0 =A0 =A0 =A0 if (!pages)<br>&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 return NULL;<br>&gt;<br>&gt; @@ -1107,10 +1104,7 @@ static struct page =
**__iommu_alloc_buffer(struct device *dev, size_t size,<br>
&gt;<br>&gt; =A0 =A0 =A0 =A0 return pages;<br>&gt; =A0error:<br>&gt; - =A0 =
=A0 =A0 if (array_size &lt;=3D PAGE_SIZE)<br>&gt; - =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 kfree(pages);<br>&gt; - =A0 =A0 =A0 else<br>&gt; - =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 vfree(pages);<br>&gt; + =A0 =A0 =A0 kfree(pages);<br>
&gt; =A0 =A0 =A0 =A0 return NULL;<br>&gt; =A0}<br>&gt;<br>&gt; --<br>&gt; 1=
.7.5.4<br>&gt;<br>&gt; --<br>&gt; To unsubscribe, send a message with &#39;=
unsubscribe linux-mm&#39; in<br>&gt; the body to <a href=3D"mailto:majordom=
o@kvack.org">majordomo@kvack.org</a>. =A0For more info on Linux MM,<br>
&gt; see: <a href=3D"http://www.linux-mm.org/">http://www.linux-mm.org/</a>=
 .<br>&gt; Don&#39;t email: &lt;a hrefmailto:&quot;<a href=3D"mailto:dont@k=
vack.org">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">e=
mail@kvack.org</a> &lt;/a&gt;<br>
<br>

--f46d040715c508885304c7e6da3c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
