Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 2C1406B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 09:18:17 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id bs8so22095623wib.5
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 06:18:16 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.24])
        by mx.google.com with ESMTPS id a20si31470555wiw.25.2015.02.03.06.18.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Feb 2015 06:18:15 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFCv3 2/2] dma-buf: add helpers for sharing attacher constraints with dma-parms
Date: Tue, 03 Feb 2015 15:17:27 +0100
Message-ID: <4689826.8DDCrX2ZhK@wuerfel>
In-Reply-To: <CAF6AEGu0-TgyE4BjiaSWXQCSk31VU7dogq=6xDRUhi79rGgbxg@mail.gmail.com>
References: <1422347154-15258-1-git-send-email-sumit.semwal@linaro.org> <20150203074856.GF14009@phenom.ffwll.local> <CAF6AEGu0-TgyE4BjiaSWXQCSk31VU7dogq=6xDRUhi79rGgbxg@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Rob Clark <robdclark@gmail.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Sumit Semwal <sumit.semwal@linaro.org>, LKML <linux-kernel@vger.kernel.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, Linaro MM SIG Mailman List <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, Robin Murphy <robin.murphy@arm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Daniel Vetter <daniel@ffwll.ch>

On Tuesday 03 February 2015 09:04:03 Rob Clark wrote:
> On Tue, Feb 3, 2015 at 2:48 AM, Daniel Vetter <daniel@ffwll.ch> wrote:
> > On Mon, Feb 02, 2015 at 03:30:21PM -0500, Rob Clark wrote:
> >> On Mon, Feb 2, 2015 at 11:54 AM, Daniel Vetter <daniel@ffwll.ch> wrote:
> >> >> My initial thought is for dma-buf to not try to prevent something than
> >> >> an exporter can actually do.. I think the scenario you describe could
> >> >> be handled by two sg-lists, if the exporter was clever enough.
> >> >
> >> > That's already needed, each attachment has it's own sg-list. After all
> >> > there's no array of dma_addr_t in the sg tables, so you can't use one sg
> >> > for more than one mapping. And due to different iommu different devices
> >> > can easily end up with different addresses.
> >>
> >>
> >> Well, to be fair it may not be explicitly stated, but currently one
> >> should assume the dma_addr_t's in the dmabuf sglist are bogus.  With
> >> gpu's that implement per-process/context page tables, I'm not really
> >> sure that there is a sane way to actually do anything else..
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
> Since I'm stuck w/ an iommu, instead of built in mmu, my plan was to
> drop use of dma-mapping entirely (incl the current call to dma_map_sg,
> which I just need until we can use drm_cflush on arm), and
> attach/detach iommu domains directly to implement context switches.
> At that point, dma_addr_t really has no sensible meaning for me.

I think what you see here is a quite common hardware setup and we really
lack the right abstraction for it at the moment. Everybody seems to
work around it with a mix of the dma-mapping API and the iommu API.
These are doing different things, and even though the dma-mapping API
can be implemented on top of the iommu API, they are not really compatible.

The drm_clflush helpers don't seem like the right solution to me,
because all other devices outside of drm will face the same issue,
and I suspect we should fill the missing gaps in the API in a
more generic way.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
