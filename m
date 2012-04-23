Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id C3C226B0044
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 08:02:27 -0400 (EDT)
Received: by wibhm17 with SMTP id hm17so2855119wib.2
        for <linux-mm@kvack.org>; Mon, 23 Apr 2012 05:02:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1334325950-7881-1-git-send-email-m.szyprowski@samsung.com>
References: <1334325950-7881-1-git-send-email-m.szyprowski@samsung.com>
Date: Mon, 23 Apr 2012 21:02:25 +0900
Message-ID: <CALYq+qSMPoVC5OF+oBbt_i7O+_fmogLCtpqTAqHbsv1TcKrPdA@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCH 0/4] ARM: replace custom consistent dma
 region with vmalloc
From: Abhinav Kochhar <kochhar.abhinav@gmail.com>
Content-Type: multipart/alternative; boundary=f46d0442811e5b326e04be576924
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Kyungmin Park <kyungmin.park@samsung.com>

--f46d0442811e5b326e04be576924
Content-Type: text/plain; charset=ISO-8859-1

Hi,

I see a bottle-neck with the current dma-mapping framework.
Issue seems to be with the Virtual memory allocation for access in kernel
address space.

1. In "arch/arm/mm/dma-mapping.c" there is a initialization call to
"consistent_init". It reserves size 32MB of Kernel Address space.
2. "consistent_init" allocates memory for kernel page directory and page
tables.

3. "__iommu_alloc_remap" function allocates virtual memory region in kernel
address space reserved in step 1.

4. "__iommu_alloc_remap" function then maps the allocated pages to the
address space reserved in step 3.

Since the virtual memory area allocated for mapping these pages in kernel
address space is only 32MB,

eventually the calls for allocation and mapping new pages into kernel
address space are going to fail once 32 MB is exhausted.

e.g., For Exynos 5 platform Each framebuffer for 1280x800 resolution
consumes around 4MB.

We have a scenario where X11 DRI driver would allocate Non-contig pages for
all "Pixmaps" through arm_iommu_alloc_attrs" function which will follow the
path given above in steps 1 - 4.

Now the problem is the size limitation of 32MB. We may want to allocate
more than 8 such buffers when X11 DRI driver is integrated.
Possible solutions:

1. Why do we need to create a kernel virtual address space? Are we going to
access these pages in kernel using this address?

If we are not going to access anything in kernel then why do we need to map
these pages in kernel address space?. If we can avoid this then the problem
can be solved.

OR

2 Is it used for only book-keeping to retrieve "struct pages" later on for
passing/mapping to different devices?

If yes, then we have to find another way.

For "dmabuf" framework one solution could be to add a new member variable
"pages" in the exporting driver's local object and use that for
passing/mapping to different devices.

Moreover, even if we increase to say 64 MB that would not be enough for our
use, we never know how many graphic applications would be spawned by the
user.
Let me know your opinion on this.

Regards,
Abhinav

On Fri, Apr 13, 2012 at 11:05 PM, Marek Szyprowski <m.szyprowski@samsung.com
> wrote:

> Hi!
>
> Recent changes to ioremap and unification of vmalloc regions on ARM
> significantly reduces the possible size of the consistent dma region and
> limited allowed dma coherent/writecombine allocations.
>
> This experimental patch series replaces custom consistent dma regions
> usage in dma-mapping framework in favour of generic vmalloc areas
> created on demand for each coherent and writecombine allocations.
>
> This patch is based on vanilla v3.4-rc2 release.
>
> Best regards
> Marek Szyprowski
> Samsung Poland R&D Center
>
>
> Patch summary:
>
> Marek Szyprowski (4):
>  mm: vmalloc: use const void * for caller argument
>  mm: vmalloc: export find_vm_area() function
>  mm: vmalloc: add VM_DMA flag to indicate areas used by dma-mapping
>    framework
>  ARM: remove consistent dma region and use common vmalloc range for
>    dma allocations
>
>  arch/arm/include/asm/dma-mapping.h |    2 +-
>  arch/arm/mm/dma-mapping.c          |  220
> +++++++-----------------------------
>  include/linux/vmalloc.h            |   10 +-
>  mm/vmalloc.c                       |   31 ++++--
>  4 files changed, 67 insertions(+), 196 deletions(-)
>
> --
> 1.7.1.569.g6f426
>
>
> _______________________________________________
> Linaro-mm-sig mailing list
> Linaro-mm-sig@lists.linaro.org
> http://lists.linaro.org/mailman/listinfo/linaro-mm-sig
>

--f46d0442811e5b326e04be576924
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<p>Hi,<br></p><p>I see a bottle-neck with the current dma-mapping=20
framework.<br>Issue seems to be with the Virtual memory allocation for acce=
ss in=20
kernel address space.</p>
<p>1. In &quot;arch/arm/mm/dma-mapping.c&quot; there is a initialization ca=
ll to=20
&quot;consistent_init&quot;. It reserves size 32MB of Kernel Address space.=
 <br>2.=20
&quot;consistent_init&quot; allocates memory for kernel page directory and =
page=20
tables.</p>
<p>3. &quot;__iommu_alloc_remap&quot; function allocates virtual memory reg=
ion in kernel=20
address space reserved in step 1.</p>
<p>4. &quot;__iommu_alloc_remap&quot; function then maps the allocated page=
s to the=20
address space reserved in step 3.</p>
<p>Since the virtual memory area allocated for mapping these pages in kerne=
l=20
address space is only 32MB, </p>
<p>eventually the calls for allocation and mapping new pages into kernel ad=
dress=20
space are going to fail once 32 MB is exhausted.</p>
<p>e.g., For Exynos 5 platform Each framebuffer for 1280x800 resolution con=
sumes around 4MB.</p>
<p>We have a scenario where X11 DRI driver would allocate Non-contig=20
pages for all &quot;Pixmaps&quot; through arm_iommu_alloc_attrs&quot; funct=
ion which=20
will follow the path given above in steps 1 -=20
4.</p>
<p>Now the problem is the size limitation of 32MB. We may want to allocate =
more=20
than 8 such buffers when X11 DRI driver is integrated.</p>
Possible solutions:
<p>1. Why do we need to create a kernel virtual address space? Are we going=
 to=20
access these pages in kernel using this address? </p>
<p>If we are not going to access anything in kernel then why do we need to =
map=20
these pages in kernel address space?. If we can avoid this then the problem=
 can=20
be solved.</p>
<p>OR</p>
<p>2 Is it used for only book-keeping to retrieve &quot;struct pages&quot; =
later on for=20
passing/mapping to different devices?</p>
<p>If yes, then we have to find another way. <br></p><p>For &quot;dmabuf&qu=
ot; framework one solution could be to add a new member=20
variable &quot;pages&quot; in the exporting driver&#39;s local object and u=
se that=20
for passing/mapping to different devices.</p><p>Moreover, even if we increa=
se to say 64 MB that would not be enough for our use,=20
we never know how many graphic applications would be spawned by the user.</=
p>Let me know your opinion on this.<br><br>Regards,<br>Abhinav<br><br><div =
class=3D"gmail_quote">On Fri, Apr 13, 2012 at 11:05 PM, Marek Szyprowski <s=
pan dir=3D"ltr">&lt;<a href=3D"mailto:m.szyprowski@samsung.com">m.szyprowsk=
i@samsung.com</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">Hi!<br>
<br>
Recent changes to ioremap and unification of vmalloc regions on ARM<br>
significantly reduces the possible size of the consistent dma region and<br=
>
limited allowed dma coherent/writecombine allocations.<br>
<br>
This experimental patch series replaces custom consistent dma regions<br>
usage in dma-mapping framework in favour of generic vmalloc areas<br>
created on demand for each coherent and writecombine allocations.<br>
<br>
This patch is based on vanilla v3.4-rc2 release.<br>
<br>
Best regards<br>
Marek Szyprowski<br>
Samsung Poland R&amp;D Center<br>
<br>
<br>
Patch summary:<br>
<br>
Marek Szyprowski (4):<br>
 =A0mm: vmalloc: use const void * for caller argument<br>
 =A0mm: vmalloc: export find_vm_area() function<br>
 =A0mm: vmalloc: add VM_DMA flag to indicate areas used by dma-mapping<br>
 =A0 =A0framework<br>
 =A0ARM: remove consistent dma region and use common vmalloc range for<br>
 =A0 =A0dma allocations<br>
<br>
=A0arch/arm/include/asm/dma-mapping.h | =A0 =A02 +-<br>
=A0arch/arm/mm/dma-mapping.c =A0 =A0 =A0 =A0 =A0| =A0220 +++++++-----------=
------------------<br>
=A0include/linux/vmalloc.h =A0 =A0 =A0 =A0 =A0 =A0| =A0 10 +-<br>
=A0mm/vmalloc.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 31 ++++--=
<br>
=A04 files changed, 67 insertions(+), 196 deletions(-)<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
--<br>
1.7.1.569.g6f426<br>
<br>
<br>
_______________________________________________<br>
Linaro-mm-sig mailing list<br>
<a href=3D"mailto:Linaro-mm-sig@lists.linaro.org">Linaro-mm-sig@lists.linar=
o.org</a><br>
<a href=3D"http://lists.linaro.org/mailman/listinfo/linaro-mm-sig" target=
=3D"_blank">http://lists.linaro.org/mailman/listinfo/linaro-mm-sig</a><br>
</font></span></blockquote></div><br>

--f46d0442811e5b326e04be576924--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
