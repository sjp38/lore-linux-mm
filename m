Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B4D068E0038
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 08:06:42 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id u20so7755592pfa.1
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 05:06:42 -0800 (PST)
Received: from mx07-00178001.pphosted.com (mx07-00178001.pphosted.com. [62.209.51.94])
        by mx.google.com with ESMTPS id p5si2345502pls.338.2019.01.10.05.06.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 05:06:41 -0800 (PST)
From: Loic PALLARDY <loic.pallardy@st.com>
Subject: RE: [rpmsg PATCH v2 1/1] rpmsg: virtio_rpmsg_bus: fix unexpected huge
 vmap mappings
Date: Thu, 10 Jan 2019 13:06:23 +0000
Message-ID: <42cbdef19ad74f84bc1222c3ad828487@SFHDAG7NODE2.st.com>
References: <1545812449-32455-1-git-send-email-fugang.duan@nxp.com>
 <CAKv+Gu-zfTZAZfiQt1iUn9otqeDkJP-y-siuBUrWUR-Kq=BsVQ@mail.gmail.com>
 <20181226145048.GA24307@infradead.org>
 <VI1PR0402MB3600AC833D6F29ECC34C8D4CFFB60@VI1PR0402MB3600.eurprd04.prod.outlook.com>
 <20181227121901.GA20892@infradead.org>
 <VI1PR0402MB3600799A06B6BFE5EBF8837FFFB70@VI1PR0402MB3600.eurprd04.prod.outlook.com>
 <VI1PR0402MB36000BD05AF4B242E13D9D05FF840@VI1PR0402MB3600.eurprd04.prod.outlook.com>
In-Reply-To: <VI1PR0402MB36000BD05AF4B242E13D9D05FF840@VI1PR0402MB3600.eurprd04.prod.outlook.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Duan <fugang.duan@nxp.com>, Christoph Hellwig <hch@infradead.org>, "bjorn.andersson@linaro.org" <bjorn.andersson@linaro.org>, "ohad@wizery.com" <ohad@wizery.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Robin Murphy <robin.murphy@arm.com>, "linux-remoteproc@vger.kernel.org" <linux-remoteproc@vger.kernel.org>, "anup@brainfault.org" <anup@brainfault.org>, dl-linux-imx <linux-imx@nxp.com>, Richard Zhu <hongxing.zhu@nxp.com>, Jason Liu <jason.hui.liu@nxp.com>, Peng Fan <peng.fan@nxp.com>

Hi Andy,

> -----Original Message-----
> From: Andy Duan <fugang.duan@nxp.com>
> Sent: jeudi 10 janvier 2019 02:45
> To: Christoph Hellwig <hch@infradead.org>; bjorn.andersson@linaro.org;
> ohad@wizery.com
> Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>; Andrew Morton
> <akpm@linux-foundation.org>; Linux-MM <linux-mm@kvack.org>; Robin
> Murphy <robin.murphy@arm.com>; linux-remoteproc@vger.kernel.org;
> anup@brainfault.org; Loic PALLARDY <loic.pallardy@st.com>; dl-linux-imx
> <linux-imx@nxp.com>; Richard Zhu <hongxing.zhu@nxp.com>; Jason Liu
> <jason.hui.liu@nxp.com>; Peng Fan <peng.fan@nxp.com>
> Subject: RE: [rpmsg PATCH v2 1/1] rpmsg: virtio_rpmsg_bus: fix unexpected
> huge vmap mappings
>=20
> From: Andy Duan Sent: 2018=1B$BG/=1B(B12=1B$B7n=1B(B28=1B$BF|=1B(B 9:48
> > From: Christoph Hellwig <hch@infradead.org> Sent: 2018=1B$BG/=1B(B12=1B=
$B7n=1B(B27=1B$BF|=1B(B
> > 20:19
> > > On Thu, Dec 27, 2018 at 02:36:53AM +0000, Andy Duan wrote:
> > > > Rpmsg is used to communicate with remote cpu like M4, the allocated
> > > > memory is shared by Linux and M4 side. In general, Linux side
> > > > reserved the static memory region like per-device DMA pool as
> > > > coherent memory for the RPMSG receive/transmit buffers. For the
> > > > static memory region, normal page allocator cannot match the
> > > > requirement unless there have protocol to tell M4 the dynamic RPMSG
> > receive/transmit buffers.
> > >
> > > In that case you need a OF reserved memory node, like we use for the
> > > "shared-dma-pool" coherent or contiguous allocations.  Currently we
> > > have those two variants wired up the the DMA allocator, but they can
> > > also used directly by drivers.  To be honest I don't really like like
> > > drivers getting too intimate with the memory allocator, but I also
> > > don't think that providing a little glue code to instanciat a CMA poo=
l
> > > for a memory that can be used directly by the driver is much of an
> > > issue.  Most of it could be reused from the existing code, just with =
a
> slightly
> > lower level interfaces.
> > >
> > > > To stop to extract pages from dma_alloc_coherent, the rpmsg bus
> > > > implementation base on virtio that already use the scatterlist
> > > > mechanism for vring memory. So for virtio driver like RPMSG bus, we
> > > > have to extract pages from dma_alloc_coherent.
> > >
> > > This sentence doesn't parse for me.
> >
> > Virtio supply the APIs that require the scatterlist pages for virtio in=
/out buf:
> > int virtqueue_add_inbuf(struct virtqueue *vq,
> >                         struct scatterlist *sg, unsigned int num,
> >                         void *data,
> >                         gfp_t gfp)
> > int virtqueue_add_outbuf(struct virtqueue *vq,
> >                          struct scatterlist *sg, unsigned int num,
> >                          void *data,
> >                          gfp_t gfp)
> >
> >
> > >
> > > > I don't think the patch is one hack,  as we already know the
> > > > physical address for the coherent memory,  just want to get pages,
> > > > the interface "pfn_to_page(PHYS_PFN(x))" is very reasonable to the
> > > > related pages.
> > >
> > > struct scatterlist doesn't (directly) refer to physical address, it
> > > refers to page structures, which encode a kernel virtual address in
> > > the kernel direct mapping, and we intentionally do not guarantee a
> > > return in the kernel direct mapping for the DMA coherent allocator, a=
s
> > > in many cases we have to either allocate from a special pool, from a
> > > special address window or remap memory to mark it as uncached.  How
> > > that is done is an implenentation detail that is not exposed to drive=
rs and
> > may change at any time.
> > >
> > > > If you stick to use normal page allocator and streaming DMA API in
> > > > RPMSG,  then we have to:
> > > > - add new quirk feature for virtio like the same function as
> > > > "VIRTIO_F_IOMMU_PLATFORM",
> > >
> > > You have to do that anyway.
> >
> > I discuss with our team, use page allocator cannot match our requiremen=
t.
> > i.MX8QM/QXP platforms have partition feature that limit M4 only access
> fixed
> > ddr memory region. Suppose other platforms also have similar limitation
> for
> > secure case.
> >
> > So it requires to use OF reserved memory for the "shared-dma-pool"
> coherent
> > or contiguous allocations.
> >
> Do you have any other comments for the patch ?

I tried your patch on ST platform and it doesn't compile neither on kernel =
v5.0-rc1 nor on Bjorn's rpmsg-next.
dma_to_phys() is unknown as dma-direct.h not included and =1B$B!F=1B(Bstruc=
t virtproc_info=1B$B!G=1B(B has no member named =1B$B!F=1B(Bbufs_dev=1B$B!G=
=1B(B.

Could you please send a new version fixing compilation issue. I would like =
to test it on my platform to provide you feedback.

Regards,
Loic

> Current driver break remoteproc on NXP i.MX8 platform , the patch is bugf=
ix
> the virtio rpmsg bus, we hope the patch enter to next and stable tree if =
no
> other comments.
