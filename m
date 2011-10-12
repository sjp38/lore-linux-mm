Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A74EA6B0047
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 03:02:58 -0400 (EDT)
From: Krishna Reddy <vdumpa@nvidia.com>
Date: Wed, 12 Oct 2011 00:02:34 -0700
Subject: RE: [Linaro-mm-sig] [PATCH 1/2] ARM: initial proof-of-concept IOMMU
 mapper for DMA-mapping
Message-ID: <401E54CE964CD94BAE1EB4A729C7087E3722519C65@HQMAIL04.nvidia.com>
References: <1314971786-15140-1-git-send-email-m.szyprowski@samsung.com>
 <1314971786-15140-2-git-send-email-m.szyprowski@samsung.com>
 <594816116217195c28de13accaf1f9f2.squirrel@www.codeaurora.org>
 <001f01cc786d$d55222c0$7ff66840$%szyprowski@samsung.com>
 <401E54CE964CD94BAE1EB4A729C7087E37225197F8@HQMAIL04.nvidia.com>
 <00b101cc87ee$8976c410$9c644c30$%szyprowski@samsung.com>
 <401E54CE964CD94BAE1EB4A729C7087E3722519A1F@HQMAIL04.nvidia.com>
 <401E54CE964CD94BAE1EB4A729C7087E3722519BF4@HQMAIL04.nvidia.com>
 <00e501cc88a2$b82fc680$288f5380$%szyprowski@samsung.com>
In-Reply-To: <00e501cc88a2$b82fc680$288f5380$%szyprowski@samsung.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Arnd Bergmann' <arnd@arndb.de>, 'Joerg Roedel' <joro@8bytes.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

> >>It looks that You have simplified arm_iommu_map_sg() function too much.
> >>The main advantage of the iommu is to map scattered memory pages into
> >>contiguous dma address space. DMA-mapping is allowed to merge consecuti=
ve
> >>entries in the scatter list if hardware supports that.
> >>http://article.gmane.org/gmane.linux.kernel/1128416
> >I would update arm_iommu_map_sg() back to coalesce the sg list.
> >>MMC drivers seem to be aware of coalescing the SG entries together as t=
hey are using
> dma_sg_len().
>=20
> I have updated the arm_iommu_map_sg() back to coalesce and fixed the issu=
es with it. During
> testing, I found out that mmc host driver doesn't support buffers bigger =
than 64K. To get the
> device working, I had to break the sg entries coalesce when dma_length is=
 about to go beyond
> 64KB. Looks like Mmc host driver(sdhci.c) need to be fixed to handle buff=
ers bigger than 64KB.
> Should the clients be forced to handle bigger buffers or is there any bet=
ter way to handle
> these kind of issues?

>There is struct device_dma_parameters *dma_parms member of struct device. =
You can specify
>maximum segment size for the dma_map_sg function. This will of course comp=
licate this function
>even more...

dma_get_max_seg_size() seem to take care of this issue already. This return=
s default max_seg_size as 64K unless device has defined its own size.


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
