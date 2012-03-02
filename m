Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 779D36B004D
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 03:05:32 -0500 (EST)
Received: by lagz14 with SMTP id z14so2386573lag.14
        for <linux-mm@kvack.org>; Fri, 02 Mar 2012 00:05:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1330527862-16234-10-git-send-email-m.szyprowski@samsung.com>
References: <1330527862-16234-1-git-send-email-m.szyprowski@samsung.com>
	<1330527862-16234-10-git-send-email-m.szyprowski@samsung.com>
Date: Fri, 2 Mar 2012 17:05:30 +0900
Message-ID: <CAHQjnOO5DLOj8Fw=ZriSnXg8W3k7y8Dnu--Peqe6JJX0xGMhoQ@mail.gmail.com>
Subject: Re: [PATCHv7 9/9] ARM: dma-mapping: add support for IOMMU mapper
From: KyongHo Cho <pullip.cho@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, Shariq Hasnain <shariq.hasnain@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Krishna Reddy <vdumpa@nvidia.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>

On Thu, Mar 1, 2012 at 12:04 AM, Marek Szyprowski
<m.szyprowski@samsung.com> wrote:
> +/**
> + * arm_iommu_map_sg - map a set of SG buffers for streaming mode DMA
> + * @dev: valid struct device pointer
> + * @sg: list of buffers
> + * @nents: number of buffers to map
> + * @dir: DMA transfer direction
> + *
> + * Map a set of buffers described by scatterlist in streaming mode for D=
MA.
> + * The scatter gather list elements are merged together (if possible) an=
d
> + * tagged with the appropriate dma address and length. They are obtained=
 via
> + * sg_dma_{address,length}.
> + */
> +int arm_iommu_map_sg(struct device *dev, struct scatterlist *sg, int nen=
ts,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum dma_data_direction dir, str=
uct dma_attrs *attrs)
> +{
> + =A0 =A0 =A0 struct scatterlist *s =3D sg, *dma =3D sg, *start =3D sg;
> + =A0 =A0 =A0 int i, count =3D 0;
> + =A0 =A0 =A0 unsigned int offset =3D s->offset;
> + =A0 =A0 =A0 unsigned int size =3D s->offset + s->length;
> + =A0 =A0 =A0 unsigned int max =3D dma_get_max_seg_size(dev);
> +
> + =A0 =A0 =A0 for (i =3D 1; i < nents; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 s->dma_address =3D ARM_DMA_ERROR;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 s->dma_length =3D 0;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 s =3D sg_next(s);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (s->offset || (size & ~PAGE_MASK) || siz=
e + s->length > max) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (__map_sg_chunk(dev, sta=
rt, size, &dma->dma_address,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dir) < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto bad_ma=
pping;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma->dma_address +=3D offse=
t;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma->dma_length =3D size - =
offset;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size =3D offset =3D s->offs=
et;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start =3D s;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma =3D sg_next(dma);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 count +=3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 size +=3D s->length;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 if (__map_sg_chunk(dev, start, size, &dma->dma_address, dir=
) < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto bad_mapping;
> +
> + =A0 =A0 =A0 dma->dma_address +=3D offset;
> + =A0 =A0 =A0 dma->dma_length =3D size - offset;
> +
> + =A0 =A0 =A0 return count+1;
> +
> +bad_mapping:
> + =A0 =A0 =A0 for_each_sg(sg, s, count, i)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __iommu_remove_mapping(dev, sg_dma_address(=
s), sg_dma_len(s));
> + =A0 =A0 =A0 return 0;
> +}
> +
This looks that the given sg list specifies the list of physical
memory chunks and
the list of IO virtual memory chunks at the same time after calling
arm_dma_map_sg().
It can happen that dma_address and dma_length of a sg entry does not
correspond to
physical memory information of the sg entry.

I think it is beneficial for handling IO virtual memory.

However, I worry about any other problems caused by a single sg entry conta=
ins
information from 2 different context.

Regards,

Cho KyongHo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
