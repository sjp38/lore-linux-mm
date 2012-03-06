Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 77EDD6B004A
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 17:48:53 -0500 (EST)
From: Krishna Reddy <vdumpa@nvidia.com>
Date: Tue, 6 Mar 2012 14:48:42 -0800
Subject: RE: [PATCHv7 9/9] ARM: dma-mapping: add support for IOMMU mapper
Message-ID: <401E54CE964CD94BAE1EB4A729C7087E37970113FE@HQMAIL04.nvidia.com>
References: <1330527862-16234-1-git-send-email-m.szyprowski@samsung.com>
 <1330527862-16234-10-git-send-email-m.szyprowski@samsung.com>
 <20120305134721.0ab0d0e6de56fa30250059b1@nvidia.com>
 <000001ccfaea$00c16f70$02444e50$%szyprowski@samsung.com>
In-Reply-To: <000001ccfaea$00c16f70$02444e50$%szyprowski@samsung.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Hiroshi Doyu <hdoyu@nvidia.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-samsung-soc@vger.kernel.org" <linux-samsung-soc@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Arnd Bergmann' <arnd@arndb.de>, 'Benjamin Herrenschmidt' <benh@kernel.crashing.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'KyongHo Cho' <pullip.cho@samsung.com>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>

> > +struct dma_iommu_mapping *
> > +arm_iommu_create_mapping(struct bus_type *bus, dma_addr_t base, size_t=
 size,
> > +                        int order)
> > +{
> > +       unsigned int count =3D (size >> PAGE_SHIFT) - order;
> > +       unsigned int bitmap_size =3D BITS_TO_LONGS(count) * sizeof(long=
);

The count calculation doesn't seem correct. "order" is log2 number and
 size >> PAGE_SHIFT is number of pages.=20

If size is passed as 64*4096(256KB) and order is 6(allocation granularity i=
s 2^6 pages=3D256KB),
 just 1 bit is enough to manage allocations.  So it should be 4 bytes or on=
e long.

But the calculation gives count =3D 64 - 6 =3D 58 and=20
Bitmap_size gets set to (58/(4*8)) * 4 =3D 8 bytes, which is incorrect.

It should be as follows.
unsigned int count =3D 1 << get_order(size) - order;
unsigned int bitmap_size =3D BITS_TO_LONGS(count) * sizeof(long) * BITS_PER=
_BYTE;

-KR

--nvpublic


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
