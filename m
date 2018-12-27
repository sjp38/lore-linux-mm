Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D446A8E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 07:19:36 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 75so20455595pfq.8
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 04:19:36 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z14si17920729pgj.73.2018.12.27.04.19.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 27 Dec 2018 04:19:34 -0800 (PST)
Date: Thu, 27 Dec 2018 13:19:01 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [rpmsg PATCH v2 1/1] rpmsg: virtio_rpmsg_bus: fix unexpected
 huge vmap mappings
Message-ID: <20181227121901.GA20892@infradead.org>
References: <1545812449-32455-1-git-send-email-fugang.duan@nxp.com>
 <CAKv+Gu-zfTZAZfiQt1iUn9otqeDkJP-y-siuBUrWUR-Kq=BsVQ@mail.gmail.com>
 <20181226145048.GA24307@infradead.org>
 <VI1PR0402MB3600AC833D6F29ECC34C8D4CFFB60@VI1PR0402MB3600.eurprd04.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <VI1PR0402MB3600AC833D6F29ECC34C8D4CFFB60@VI1PR0402MB3600.eurprd04.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Duan <fugang.duan@nxp.com>
Cc: Christoph Hellwig <hch@infradead.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Robin Murphy <robin.murphy@arm.com>, "bjorn.andersson@linaro.org" <bjorn.andersson@linaro.org>, "ohad@wizery.com" <ohad@wizery.com>, "linux-remoteproc@vger.kernel.org" <linux-remoteproc@vger.kernel.org>, "anup@brainfault.org" <anup@brainfault.org>, "loic.pallardy@st.com" <loic.pallardy@st.com>, dl-linux-imx <linux-imx@nxp.com>, Richard Zhu <hongxing.zhu@nxp.com>, Jason Liu <jason.hui.liu@nxp.com>, Peng Fan <peng.fan@nxp.com>

Hi Andy,

first please do not write lines longer than 72 characters, as they turn your mail
into an unreadable mess without prior editing..

On Thu, Dec 27, 2018 at 02:36:53AM +0000, Andy Duan wrote:
> Rpmsg is used to communicate with remote cpu like M4, the allocated
> memory is shared by Linux and M4 side. In general, Linux side reserved
> the static memory region like per-device DMA pool as coherent memory
> for the RPMSG receive/transmit buffers. For the static memory region,
> normal page allocator cannot match the requirement unless there have
> protocol to tell M4 the dynamic RPMSG receive/transmit buffers.

In that case you need a OF reserved memory node, like we use for the
"shared-dma-pool" coherent or contiguous allocations.  Currently we
have those two variants wired up the the DMA allocator, but they can
also used directly by drivers.  To be honest I don't really like like
drivers getting too intimate with the memory allocator, but I also
don't think that providing a little glue code to instanciat a CMA
pool for a memory that can be used directly by the driver is much
of an issue.  Most of it could be reused from the existing code,
just with a slightly lower level interfaces.

> To stop to extract pages from dma_alloc_coherent, the rpmsg bus
> implementation base on virtio that already use the scatterlist
> mechanism for vring memory. So for virtio driver like RPMSG bus,
> we have to extract pages from dma_alloc_coherent.

This sentence doesn't parse for me.

> I don't think the patch is one hack,  as we already know the physical
> address for the coherent memory,  just want to get pages, the
> interface "pfn_to_page(PHYS_PFN(x))" is very reasonable to the
> related pages.  

struct scatterlist doesn't (directly) refer to physical address,
it refers to page structures, which encode a kernel virtual
address in the kernel direct mapping, and we intentionally do not
guarantee a return in the kernel direct mapping for the DMA
coherent allocator, as in many cases we have to either allocate
from a special pool, from a special address window or remap
memory to mark it as uncached.  How that is done is an
implenentation detail that is not exposed to drivers and may
change at any time.

> If you stick to use normal page allocator and streaming DMA
> API in RPMSG,  then we have to:
> - add new quirk feature for virtio like the same function as
> "VIRTIO_F_IOMMU_PLATFORM",

You have to do that anyway.  The current !VIRTIO_F_IOMMU_PLATFORM
is completely broken for any virtio devic that is not actually
virtualized but real hardware, and must not be used for real
hardware devices.
