Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7120B6B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 07:59:30 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id k14so44422719wgh.8
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 04:59:29 -0800 (PST)
Received: from mail-we0-x230.google.com (mail-we0-x230.google.com. [2a00:1450:400c:c03::230])
        by mx.google.com with ESMTPS id gp3si31035397wib.60.2015.02.03.04.59.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 04:59:28 -0800 (PST)
Received: by mail-we0-f176.google.com with SMTP id w62so44757533wes.7
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 04:59:27 -0800 (PST)
Date: Tue, 3 Feb 2015 14:00:49 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [RFCv3 2/2] dma-buf: add helpers for sharing attacher
 constraints with dma-parms
Message-ID: <20150203130049.GN14009@phenom.ffwll.local>
References: <20150129143908.GA26493@n2100.arm.linux.org.uk>
 <CAO_48GEOQ1pBwirgEWeVVXW-iOmaC=Xerr2VyYYz9t1QDXgVsw@mail.gmail.com>
 <20150129154718.GB26493@n2100.arm.linux.org.uk>
 <CAF6AEGtTmFg66TK_AFkQ-xp7Nd9Evk3nqe6xCBp7K=77OmXTxA@mail.gmail.com>
 <20150129192610.GE26493@n2100.arm.linux.org.uk>
 <CAF6AEGujk8UC4X6T=yhTrz1s+SyZUQ=m05h_WcxLDGZU6bydbw@mail.gmail.com>
 <20150202165405.GX14009@phenom.ffwll.local>
 <CAF6AEGuESM+e3HSRGM6zLqrp8kqRLGUYvA3KKECdm7m-nt0M=Q@mail.gmail.com>
 <20150203074856.GF14009@phenom.ffwll.local>
 <20150203122813.GN8656@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150203122813.GN8656@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Daniel Vetter <daniel@ffwll.ch>, Rob Clark <robdclark@gmail.com>, Sumit Semwal <sumit.semwal@linaro.org>, LKML <linux-kernel@vger.kernel.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, Linaro MM SIG Mailman List <linaro-mm-sig@lists.linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, Robin Murphy <robin.murphy@arm.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On Tue, Feb 03, 2015 at 12:28:14PM +0000, Russell King - ARM Linux wrote:
> On Tue, Feb 03, 2015 at 08:48:56AM +0100, Daniel Vetter wrote:
> > On Mon, Feb 02, 2015 at 03:30:21PM -0500, Rob Clark wrote:
> > > On Mon, Feb 2, 2015 at 11:54 AM, Daniel Vetter <daniel@ffwll.ch> wrote:
> > > >> My initial thought is for dma-buf to not try to prevent something than
> > > >> an exporter can actually do.. I think the scenario you describe could
> > > >> be handled by two sg-lists, if the exporter was clever enough.
> > > >
> > > > That's already needed, each attachment has it's own sg-list. After all
> > > > there's no array of dma_addr_t in the sg tables, so you can't use one sg
> > > > for more than one mapping. And due to different iommu different devices
> > > > can easily end up with different addresses.
> > > 
> > > 
> > > Well, to be fair it may not be explicitly stated, but currently one
> > > should assume the dma_addr_t's in the dmabuf sglist are bogus.  With
> > > gpu's that implement per-process/context page tables, I'm not really
> > > sure that there is a sane way to actually do anything else..
> > 
> > Hm, what does per-process/context page tables have to do here? At least on
> > i915 we have a two levels of page tables:
> > - first level for vm/device isolation, used through dma api
> > - 2nd level for per-gpu-context isolation and context switching, handled
> >   internally.
> > 
> > Since atm the dma api doesn't have any context of contexts or different
> > pagetables, I don't see who you could use that at all.
> 
> What I've found with *my* etnaviv drm implementation (not Christian's - I
> found it impossible to work with Christian, especially with the endless
> "msm doesn't do it that way, so we shouldn't" responses and his attitude
> towards cherry-picking my development work [*]) is that it's much easier to
> keep the GPU MMU local to the GPU and under the control of the DRM MM code,
> rather than attaching the IOMMU to the DMA API and handling it that way.
> 
> There are several reasons for that:
> 
> 1. DRM has a better idea about when the memory needs to be mapped to the
>    GPU, and it can more effectively manage the GPU MMU.
> 
> 2. The GPU MMU may have TLBs which can only be flushed via a command in
>    the GPU command stream, so it's fundamentally necessary for the MMU to
>    be managed by the GPU driver so that it knows when (and how) to insert
>    the flushes.

3. Switching between different address spaces (for per gpu context
isolation) often requires intricate knowledge about the gpu and close
coordination. Well maybe just a part of 2 really, but an important one.

Fully agree and tbh I'm not sure whether the current push in arm to expose
all gpu mmus as iommus is solid. Even for pasid (per-context iommu tables)
which is a big official standard there's still a lot of open questions
about how to do it properly. And it requires strict hw support so that the
hw always knows which pasid it should use for a given dma access.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
