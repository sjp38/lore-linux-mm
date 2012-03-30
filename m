Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id C2D866B004D
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 22:24:47 -0400 (EDT)
From: Krishna Reddy <vdumpa@nvidia.com>
Date: Thu, 29 Mar 2012 19:24:21 -0700
Subject: RE: [PATCHv7 9/9] ARM: dma-mapping: add support for IOMMU mapper
Message-ID: <401E54CE964CD94BAE1EB4A729C7087E37978A1E66@HQMAIL04.nvidia.com>
References: <1330527862-16234-1-git-send-email-m.szyprowski@samsung.com>
 <1330527862-16234-10-git-send-email-m.szyprowski@samsung.com>
 <20120329101927.8ab6b1993475b7e16ae2258f@nvidia.com>
 <01b301cd0d81$f935d750$eba185f0$%szyprowski@samsung.com>
In-Reply-To: <01b301cd0d81$f935d750$eba185f0$%szyprowski@samsung.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-samsung-soc@vger.kernel.org" <linux-samsung-soc@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Arnd Bergmann' <arnd@arndb.de>, 'Benjamin Herrenschmidt' <benh@kernel.crashing.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'KyongHo Cho' <pullip.cho@samsung.com>, Hiroshi Doyu <hdoyu@nvidia.com>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>

Hi,
I have found a bug in arm_iommu_map_sg().=20

> +int arm_iommu_map_sg(struct device *dev, struct scatterlist *sg, int nen=
ts,
> +		     enum dma_data_direction dir, struct dma_attrs *attrs) {
> +	struct scatterlist *s =3D sg, *dma =3D sg, *start =3D sg;
> +	int i, count =3D 0;
> +	unsigned int offset =3D s->offset;
> +	unsigned int size =3D s->offset + s->length;
> +	unsigned int max =3D dma_get_max_seg_size(dev);
> +
> +	for (i =3D 1; i < nents; i++) {
> +		s->dma_address =3D ARM_DMA_ERROR;
> +		s->dma_length =3D 0;
> +
> +		s =3D sg_next(s);

With above code, the last sg element's dma_length is not getting set to zer=
o.
This causing additional incorrect  unmapping during arm_iommu_unmap_sg call=
 and=20
leading to random crashes.
The order of above three lines should be as follows.
		s =3D sg_next(s);

		s->dma_address =3D ARM_DMA_ERROR;
		s->dma_length =3D 0;


-KR
--nvpublic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
