Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CB8109000C6
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 14:46:44 -0400 (EDT)
From: Krishna Reddy <vdumpa@nvidia.com>
Date: Tue, 20 Sep 2011 11:46:32 -0700
Subject: Re: [PATCH 1/2] ARM: initial proof-of-concept IOMMU mapper for
 DMA-mapping
Message-ID: <401E54CE964CD94BAE1EB4A729C7087E1229036B69@HQMAIL04.nvidia.com>
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_401E54CE964CD94BAE1EB4A729C7087E1229036B69HQMAIL04nvidi_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-ARM Kernel <linux-arm-kernel@lists.infradead.org>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linaro-mm-sig <linaro-mm-sig@lists.linaro.org>, linux-mm <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Shariq Hasnain <shariq.hasnain@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>

--_000_401E54CE964CD94BAE1EB4A729C7087E1229036B69HQMAIL04nvidi_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi,
The following change fixes a bug, which causes releasing incorrect iova spa=
ce, in the original patch of this mail thread. It fixes compilation error e=
ither.

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 82d5134..8c16ed7 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -900,10 +900,8 @@ static int __iommu_remove_mapping(struct device *dev, =
dma_addr_t iova, size_t si
        unsigned int count =3D size >> PAGE_SHIFT;
        int i;

-       for (i=3D0; i<count; i++) {
-               iommu_unmap(mapping->domain, iova, 0);
-               iova +=3D PAGE_SIZE;
-       }
+       for (i=3D0; i<count; i++)
+               iommu_unmap(mapping->domain, iova + i * PAGE_SIZE, 0);
        __free_iova(mapping, iova, size);
        return 0;
 }
@@ -1073,7 +1071,7 @@ int arm_iommu_map_sg(struct device *dev, struct scatt=
erlist *sg, int nents,
                size +=3D sg->length;
        }
        __map_sg_chunk(dev, start, size, &dma->dma_address, dir);
-       d->dma_address +=3D offset;
+       dma->dma_address +=3D offset;

        return count;


--_000_401E54CE964CD94BAE1EB4A729C7087E1229036B69HQMAIL04nvidi_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
<meta name=3D"Generator" content=3D"Microsoft Exchange Server">
<!-- converted from rtf -->
<style><!-- .EmailQuote { margin-left: 1pt; padding-left: 4pt; border-left:=
 #800000 2px solid; } --></style>
</head>
<body>
<font face=3D"Consolas, monospace" size=3D"2">
<div>Hi,</div>
<div>The following change fixes a bug, which causes releasing incorrect iov=
a space, in the original patch of this mail thread. It fixes compilation er=
ror either.</div>
<div>&nbsp;</div>
<div>diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c</di=
v>
<div>index 82d5134..8c16ed7 100644</div>
<div>--- a/arch/arm/mm/dma-mapping.c</div>
<div>&#43;&#43;&#43; b/arch/arm/mm/dma-mapping.c</div>
<div>@@ -900,10 &#43;900,8 @@ static int __iommu_remove_mapping(struct devi=
ce *dev, dma_addr_t iova, size_t si</div>
<div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; unsigned int count =3D size=
 &gt;&gt; PAGE_SHIFT;</div>
<div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; int i;</div>
<div>&nbsp;</div>
<div>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; for (i=3D0; i&lt;count; i&#43;&#=
43;) {</div>
<div>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp; iommu_unmap(mapping-&gt;domain, iova, 0);</div>
<div>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp; iova &#43;=3D PAGE_SIZE;</div>
<div>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }</div>
<div>&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; for (i=3D0; i&lt;count; i&#4=
3;&#43;)</div>
<div>&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp; iommu_unmap(mapping-&gt;domain, iova &#43; i * PAGE_SIZ=
E, 0);</div>
<div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; __free_iova(mapping, iova, =
size);</div>
<div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return 0;</div>
<div> }</div>
<div>@@ -1073,7 &#43;1071,7 @@ int arm_iommu_map_sg(struct device *dev, str=
uct scatterlist *sg, int nents,</div>
<div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp; size &#43;=3D sg-&gt;length;</div>
<div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }</div>
<div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; __map_sg_chunk(dev, start, =
size, &amp;dma-&gt;dma_address, dir);</div>
<div>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; d-&gt;dma_address &#43;=3D offse=
t;</div>
<div>&#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; dma-&gt;dma_address &#43;=3D=
 offset;</div>
<div>&nbsp;</div>
<div><font face=3D"Calibri, sans-serif" size=3D"2">&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp; return count;<font face=3D"Calibri, sans-serif"> </font>=
</font></div>
<div><font face=3D"Calibri, sans-serif" size=3D"2">&nbsp;</font></div>
</font>
</body>
</html>

--_000_401E54CE964CD94BAE1EB4A729C7087E1229036B69HQMAIL04nvidi_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
