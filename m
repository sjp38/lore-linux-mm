Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id DCB786B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 09:58:34 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id l15so24906829wiw.4
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 06:58:34 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id dd2si1596359wib.96.2015.02.03.06.58.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 06:58:33 -0800 (PST)
Date: Tue, 3 Feb 2015 14:58:17 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFCv3 2/2] dma-buf: add helpers for sharing attacher
 constraints with dma-parms
Message-ID: <20150203145817.GT8656@n2100.arm.linux.org.uk>
References: <20150129154718.GB26493@n2100.arm.linux.org.uk>
 <CAF6AEGtTmFg66TK_AFkQ-xp7Nd9Evk3nqe6xCBp7K=77OmXTxA@mail.gmail.com>
 <20150129192610.GE26493@n2100.arm.linux.org.uk>
 <CAF6AEGujk8UC4X6T=yhTrz1s+SyZUQ=m05h_WcxLDGZU6bydbw@mail.gmail.com>
 <20150202165405.GX14009@phenom.ffwll.local>
 <CAF6AEGuESM+e3HSRGM6zLqrp8kqRLGUYvA3KKECdm7m-nt0M=Q@mail.gmail.com>
 <20150203074856.GF14009@phenom.ffwll.local>
 <CAF6AEGu0-TgyE4BjiaSWXQCSk31VU7dogq=6xDRUhi79rGgbxg@mail.gmail.com>
 <20150203143715.GQ8656@n2100.arm.linux.org.uk>
 <CAF6AEGtBfr3fGEoFjFFpy1KrMJMZ-13VPPJX73fAkwiaLk+XGQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAF6AEGtBfr3fGEoFjFFpy1KrMJMZ-13VPPJX73fAkwiaLk+XGQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Clark <robdclark@gmail.com>
Cc: Sumit Semwal <sumit.semwal@linaro.org>, LKML <linux-kernel@vger.kernel.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, Linaro MM SIG Mailman List <linaro-mm-sig@lists.linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, Robin Murphy <robin.murphy@arm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Daniel Vetter <daniel@ffwll.ch>

On Tue, Feb 03, 2015 at 09:44:57AM -0500, Rob Clark wrote:
> On Tue, Feb 3, 2015 at 9:37 AM, Russell King - ARM Linux
> <linux@arm.linux.org.uk> wrote:
> > On Tue, Feb 03, 2015 at 09:04:03AM -0500, Rob Clark wrote:
> >> Since I'm stuck w/ an iommu, instead of built in mmu, my plan was to
> >> drop use of dma-mapping entirely (incl the current call to dma_map_sg,
> >> which I just need until we can use drm_cflush on arm), and
> >> attach/detach iommu domains directly to implement context switches.
> >> At that point, dma_addr_t really has no sensible meaning for me.
> >
> > So how do you intend to import from a subsystem which only gives you
> > the dma_addr_t?
> >
> > If you aren't passing system memory, you have no struct page.  You can't
> > fake up a struct page.  What this means is that struct scatterlist can't
> > represent it any other way.
> 
> Tell the exporter to stop using carveouts, and give me proper memory
> instead.. ;-)
> 
> Well, at least on these SoC's, I think the only valid use for carveout
> memory is the bootloader splashscreen.  And I was planning on just
> hanging on to that for myself for fbdev scanout buffer or other
> internal (non shared) usage..

I wasn't thinking about carveouts - as I already mentioned earlier in this
thread, it may be memory which couldn't possibly ever be system memory -
for example, a separate chunk of memory which is tightly coupled to the
graphics system but not so to the CPU.

In such a case, we wouldn't want to use that as normal system memory, but
we would want to allocate framebuffers and the like from it, and maybe
pass them around.

While it may not be appropriate for MSM, it's still something that needs
to be considered, because there may be (and I know there are) dmabuf
users which do pass memory this way.

So, what I'm saying is that for the purposes of the dmabuf API, we can't
mandate that the scatterlists will contain a valid struct page pointer.
It'd probably be a good idea for the importer to validate the scatterlist
at import time if it has this requirement.

However, thinking about this more, I think that from a generic design
point of view, we really should limit the "struct page" usage to a
special MSM-ism - something which should definitely not be copied by
other drivers.  As has been mentioned previously, if there is a system
MMU which needs to be programmed to map system memory onto the bus, the
struct page becomes absolutely useless, and the only thing that gives
you the correct "handle" to that memory is the dma_addr_t.

Finally, note that n_mapped = dma_map_sg(dev, sg, n_ent, dir) - n_mapped
can be less than n_ent when there's the presence of an IOMMU, since an
IOMMU is permitted to coalesce individual scatterlist entries if it
so chooses, and when walking the scatterlist for DMA purposes, the
scatterlist sg_dma_*() accessors should be used, and it should be
iterated over from 0 to n_mapped, not 0 to n_ent.  It's important to
realise that in driver code, sg->length may not be the same as
sg_dma_len(sg) for exactly this reason:

#ifdef CONFIG_NEED_SG_DMA_LENGTH
#define sg_dma_len(sg)          ((sg)->dma_length)
#else
#define sg_dma_len(sg)          ((sg)->length)
#endif

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
