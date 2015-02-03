Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0555A6B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 09:25:32 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id b16so26824057igk.1
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 06:25:31 -0800 (PST)
Received: from mail-ie0-x22d.google.com (mail-ie0-x22d.google.com. [2607:f8b0:4001:c03::22d])
        by mx.google.com with ESMTPS id i4si9756156icx.102.2015.02.03.06.25.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 06:25:31 -0800 (PST)
Received: by mail-ie0-f173.google.com with SMTP id tr6so25368930ieb.4
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 06:25:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150203122813.GN8656@n2100.arm.linux.org.uk>
References: <1422347154-15258-2-git-send-email-sumit.semwal@linaro.org>
	<20150129143908.GA26493@n2100.arm.linux.org.uk>
	<CAO_48GEOQ1pBwirgEWeVVXW-iOmaC=Xerr2VyYYz9t1QDXgVsw@mail.gmail.com>
	<20150129154718.GB26493@n2100.arm.linux.org.uk>
	<CAF6AEGtTmFg66TK_AFkQ-xp7Nd9Evk3nqe6xCBp7K=77OmXTxA@mail.gmail.com>
	<20150129192610.GE26493@n2100.arm.linux.org.uk>
	<CAF6AEGujk8UC4X6T=yhTrz1s+SyZUQ=m05h_WcxLDGZU6bydbw@mail.gmail.com>
	<20150202165405.GX14009@phenom.ffwll.local>
	<CAF6AEGuESM+e3HSRGM6zLqrp8kqRLGUYvA3KKECdm7m-nt0M=Q@mail.gmail.com>
	<20150203074856.GF14009@phenom.ffwll.local>
	<20150203122813.GN8656@n2100.arm.linux.org.uk>
Date: Tue, 3 Feb 2015 09:25:30 -0500
Message-ID: <CAF6AEGuu=xBY-Con2CVYJ5kPfNk-emT6DqCuukiGErPzntcusA@mail.gmail.com>
Subject: Re: [RFCv3 2/2] dma-buf: add helpers for sharing attacher constraints
 with dma-parms
From: Rob Clark <robdclark@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Daniel Vetter <daniel@ffwll.ch>, Sumit Semwal <sumit.semwal@linaro.org>, LKML <linux-kernel@vger.kernel.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, Linaro MM SIG Mailman List <linaro-mm-sig@lists.linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, Robin Murphy <robin.murphy@arm.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On Tue, Feb 3, 2015 at 7:28 AM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Tue, Feb 03, 2015 at 08:48:56AM +0100, Daniel Vetter wrote:
>> On Mon, Feb 02, 2015 at 03:30:21PM -0500, Rob Clark wrote:
>> > On Mon, Feb 2, 2015 at 11:54 AM, Daniel Vetter <daniel@ffwll.ch> wrote:
>> > >> My initial thought is for dma-buf to not try to prevent something than
>> > >> an exporter can actually do.. I think the scenario you describe could
>> > >> be handled by two sg-lists, if the exporter was clever enough.
>> > >
>> > > That's already needed, each attachment has it's own sg-list. After all
>> > > there's no array of dma_addr_t in the sg tables, so you can't use one sg
>> > > for more than one mapping. And due to different iommu different devices
>> > > can easily end up with different addresses.
>> >
>> >
>> > Well, to be fair it may not be explicitly stated, but currently one
>> > should assume the dma_addr_t's in the dmabuf sglist are bogus.  With
>> > gpu's that implement per-process/context page tables, I'm not really
>> > sure that there is a sane way to actually do anything else..
>>
>> Hm, what does per-process/context page tables have to do here? At least on
>> i915 we have a two levels of page tables:
>> - first level for vm/device isolation, used through dma api
>> - 2nd level for per-gpu-context isolation and context switching, handled
>>   internally.
>>
>> Since atm the dma api doesn't have any context of contexts or different
>> pagetables, I don't see who you could use that at all.
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
>

If gpu mmu needs some/all updates to happen from command-stream then
probably better to handle it internally..

That is a slightly different scenario from msm, where we have many
instances of the same iommu[*] scattered through the SoC in front of
various different devices.

BR,
-R

[*] at least from iommu register layout, same driver is used for all
instances.. but maybe the tlb+walker are maybe more tightly integrated
to the gpu, but that is just speculation on implementation details
based on some paper I found along the way

>
> * - as a direct result of that, I've stopped all further development of
> etnaviv drm, and I'm intending to strip it out from my Xorg DDX driver
> as the etnaviv drm API which Christian wants is completely incompatible
> with the non-etnaviv drm, and that just creates far too much pain in the
> DDX driver.
>
> --
> FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
> according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
