Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id C66056B002C
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 06:08:07 -0500 (EST)
Received: from euspt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M0900FLC89HQ8@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 02 Mar 2012 11:08:05 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M09003OZ89HOK@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 02 Mar 2012 11:08:05 +0000 (GMT)
Date: Fri, 02 Mar 2012 12:07:59 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv7 9/9] ARM: dma-mapping: add support for IOMMU mapper
In-reply-to: 
 <CAHQjnOO5DLOj8Fw=ZriSnXg8W3k7y8Dnu--Peqe6JJX0xGMhoQ@mail.gmail.com>
Message-id: <015101ccf864$bacb1070$30613150$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=iso-8859-2
Content-language: pl
Content-transfer-encoding: quoted-printable
References: <1330527862-16234-1-git-send-email-m.szyprowski@samsung.com>
 <1330527862-16234-10-git-send-email-m.szyprowski@samsung.com>
 <CAHQjnOO5DLOj8Fw=ZriSnXg8W3k7y8Dnu--Peqe6JJX0xGMhoQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'KyongHo Cho' <pullip.cho@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Arnd Bergmann' <arnd@arndb.de>, 'Benjamin Herrenschmidt' <benh@kernel.crashing.org>, 'Krishna Reddy' <vdumpa@nvidia.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>

Hello,

On Friday, March 02, 2012 9:06 AM KyongHo Cho wrote:

> On Thu, Mar 1, 2012 at 12:04 AM, Marek Szyprowski
> <m.szyprowski@samsung.com> wrote:
> > +/**
> > + * arm_iommu_map_sg - map a set of SG buffers for streaming mode =
DMA
> > + * @dev: valid struct device pointer
> > + * @sg: list of buffers
> > + * @nents: number of buffers to map
> > + * @dir: DMA transfer direction
> > + *
> > + * Map a set of buffers described by scatterlist in streaming mode =
for DMA.
> > + * The scatter gather list elements are merged together (if =
possible) and
> > + * tagged with the appropriate dma address and length. They are =
obtained via
> > + * sg_dma_{address,length}.
> > + */
> > +int arm_iommu_map_sg(struct device *dev, struct scatterlist *sg, =
int nents,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum dma_data_direction =
dir, struct dma_attrs *attrs)
> > +{
> > + =A0 =A0 =A0 struct scatterlist *s =3D sg, *dma =3D sg, *start =3D =
sg;
> > + =A0 =A0 =A0 int i, count =3D 0;
> > + =A0 =A0 =A0 unsigned int offset =3D s->offset;
> > + =A0 =A0 =A0 unsigned int size =3D s->offset + s->length;
> > + =A0 =A0 =A0 unsigned int max =3D dma_get_max_seg_size(dev);
> > +
> > + =A0 =A0 =A0 for (i =3D 1; i < nents; i++) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 s->dma_address =3D ARM_DMA_ERROR;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 s->dma_length =3D 0;
> > +
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 s =3D sg_next(s);
> > +
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (s->offset || (size & ~PAGE_MASK) =
|| size + s->length > max) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if =
(__map_sg_chunk(dev, start, size, &dma->dma_address,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dir) < 0)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto =
bad_mapping;
> > +
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma->dma_address +=3D =
offset;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma->dma_length =3D =
size - offset;
> > +
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size =3D offset =3D =
s->offset;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start =3D s;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma =3D sg_next(dma);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 count +=3D 1;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 size +=3D s->length;
> > + =A0 =A0 =A0 }
> > + =A0 =A0 =A0 if (__map_sg_chunk(dev, start, size, =
&dma->dma_address, dir) < 0)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto bad_mapping;
> > +
> > + =A0 =A0 =A0 dma->dma_address +=3D offset;
> > + =A0 =A0 =A0 dma->dma_length =3D size - offset;
> > +
> > + =A0 =A0 =A0 return count+1;
> > +
> > +bad_mapping:
> > + =A0 =A0 =A0 for_each_sg(sg, s, count, i)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __iommu_remove_mapping(dev, =
sg_dma_address(s), sg_dma_len(s));
> > + =A0 =A0 =A0 return 0;
> > +}
> > +
> This looks that the given sg list specifies the list of physical
> memory chunks and
> the list of IO virtual memory chunks at the same time after calling
> arm_dma_map_sg().
> It can happen that dma_address and dma_length of a sg entry does not
> correspond to
> physical memory information of the sg entry.

Right, that's how it is designed. If fact sg entries describes 2 =
independent=20
lists - one for physical memory chunks and one for virtual memory =
chunks.=20
It might happen that the whole scattered physical memory can be mapped =
into
contiguous virtual memory chunk, what result in only one element =
describing
the io dma addresses. Here is the respective paragraph from=20
Documentation/DMA-API-HOWTO.txt (lines 511-517):

'The implementation is free to merge several consecutive sglist entries
into one (e.g. if DMA mapping is done with PAGE_SIZE granularity, any
consecutive sglist entries can be merged into one provided the first one
ends and the second one starts on a page boundary - in fact this is a =
huge
advantage for cards which either cannot do scatter-gather or have very
limited number of scatter-gather entries) and returns the actual number
of sg entries it mapped them to. On failure 0 is returned.'

> I think it is beneficial for handling IO virtual memory.
>=20
> However, I worry about any other problems caused by a single sg entry =
contains
> information from 2 different context.

What do you mean by the 'context'. DMA mapping assumes that a single =
call to=20
dma_map_sg maps a single memory buffer.

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
