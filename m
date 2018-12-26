Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 59D3C8E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 09:50:58 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id t26so15319013pgu.18
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 06:50:58 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b8si32443628pge.384.2018.12.26.06.50.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 26 Dec 2018 06:50:57 -0800 (PST)
Date: Wed, 26 Dec 2018 06:50:48 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [rpmsg PATCH v2 1/1] rpmsg: virtio_rpmsg_bus: fix unexpected
 huge vmap mappings
Message-ID: <20181226145048.GA24307@infradead.org>
References: <1545812449-32455-1-git-send-email-fugang.duan@nxp.com>
 <CAKv+Gu-zfTZAZfiQt1iUn9otqeDkJP-y-siuBUrWUR-Kq=BsVQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu-zfTZAZfiQt1iUn9otqeDkJP-y-siuBUrWUR-Kq=BsVQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Andy Duan <fugang.duan@nxp.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Christoph Hellwig <hch@infradead.org>, Robin Murphy <robin.murphy@arm.com>, "bjorn.andersson@linaro.org" <bjorn.andersson@linaro.org>, "ohad@wizery.com" <ohad@wizery.com>, "linux-remoteproc@vger.kernel.org" <linux-remoteproc@vger.kernel.org>, "anup@brainfault.org" <anup@brainfault.org>, "loic.pallardy@st.com" <loic.pallardy@st.com>, dl-linux-imx <linux-imx@nxp.com>, Richard Zhu <hongxing.zhu@nxp.com>, Jason Liu <jason.hui.liu@nxp.com>, Peng Fan <peng.fan@nxp.com>

On Wed, Dec 26, 2018 at 01:27:25PM +0100, Ard Biesheuvel wrote:
> If there are legal uses for vmalloc_to_page() even if the region is
> not mapped down to pages [which appears to be the case here], I'd
> prefer to fix vmalloc_to_page() instead of adding this hack. Or
> perhaps we need a sg_xxx helper that translates any virtual address
> (vmalloc or otherwise) into a scatterlist entry?

What rpmsg does is completely bogus and needs to be fixed ASAP.  The
virtual address returned from dma_alloc_coherent must not be passed to
virt_to_page or vmalloc_to_page, but only use as a kernel virtual
address.  It might not be backed by pages, or might create aliases that
must not be used with VIVT caches.

rpmsg needs to either stop trying to extract pages from
dma_alloc_coherent, or just replace its use of dma_alloc_coherent
with the normal page allocator and the streaming DMA API.
