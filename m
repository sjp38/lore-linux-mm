Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id AA0F96B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 02:45:24 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id z12so43054864wgg.3
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 23:45:24 -0800 (PST)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com. [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id bl3si27529094wib.29.2015.02.02.23.45.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Feb 2015 23:45:22 -0800 (PST)
Received: by mail-wi0-f173.google.com with SMTP id r20so22087681wiv.0
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 23:45:22 -0800 (PST)
Date: Tue, 3 Feb 2015 08:46:43 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [RFCv3 2/2] dma-buf: add helpers for sharing attacher
 constraints with dma-parms
Message-ID: <20150203074643.GE14009@phenom.ffwll.local>
References: <1422347154-15258-2-git-send-email-sumit.semwal@linaro.org>
 <20150129143908.GA26493@n2100.arm.linux.org.uk>
 <CAO_48GEOQ1pBwirgEWeVVXW-iOmaC=Xerr2VyYYz9t1QDXgVsw@mail.gmail.com>
 <20150129154718.GB26493@n2100.arm.linux.org.uk>
 <CAF6AEGtTmFg66TK_AFkQ-xp7Nd9Evk3nqe6xCBp7K=77OmXTxA@mail.gmail.com>
 <20150129192610.GE26493@n2100.arm.linux.org.uk>
 <CAF6AEGujk8UC4X6T=yhTrz1s+SyZUQ=m05h_WcxLDGZU6bydbw@mail.gmail.com>
 <20150202165405.GX14009@phenom.ffwll.local>
 <CAF6AEGuESM+e3HSRGM6zLqrp8kqRLGUYvA3KKECdm7m-nt0M=Q@mail.gmail.com>
 <20150202214616.GI8656@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150202214616.GI8656@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Rob Clark <robdclark@gmail.com>, Sumit Semwal <sumit.semwal@linaro.org>, LKML <linux-kernel@vger.kernel.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, Linaro MM SIG Mailman List <linaro-mm-sig@lists.linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, Robin Murphy <robin.murphy@arm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Daniel Vetter <daniel@ffwll.ch>

On Mon, Feb 02, 2015 at 09:46:16PM +0000, Russell King - ARM Linux wrote:
> On Mon, Feb 02, 2015 at 03:30:21PM -0500, Rob Clark wrote:
> > On Mon, Feb 2, 2015 at 11:54 AM, Daniel Vetter <daniel@ffwll.ch> wrote:
> > >> My initial thought is for dma-buf to not try to prevent something than
> > >> an exporter can actually do.. I think the scenario you describe could
> > >> be handled by two sg-lists, if the exporter was clever enough.
> > >
> > > That's already needed, each attachment has it's own sg-list. After all
> > > there's no array of dma_addr_t in the sg tables, so you can't use one sg
> > > for more than one mapping. And due to different iommu different devices
> > > can easily end up with different addresses.
> > 
> > 
> > Well, to be fair it may not be explicitly stated, but currently one
> > should assume the dma_addr_t's in the dmabuf sglist are bogus.  With
> > gpu's that implement per-process/context page tables, I'm not really
> > sure that there is a sane way to actually do anything else..
> 
> That's incorrect - and goes dead against the design of scatterlists.
> 
> Not only that, but it is entirely possible that you may get handed
> memory via dmabufs for which there are no struct page's associated
> with that memory - think about display systems which have their own
> video memory which is accessible to the GPU, but it isn't system
> memory.
> 
> In those circumstances, you have to use the dma_addr_t's and not the
> pages.

Yeah exactly. At least with i915 we'd really want to be able to share
stolen memory in some cases, and since that's stolen there's no struct
pages for them. On top of that any cpu access is also blocked to that
range in the memory controller, so the dma_addr_t is really the _only_
thing you can use to get at those memory ranges. And afaik the camera pipe
on intel soc can get there - unfortunately that one doesn't have an
upstream driver :(

And just to clarify: All current dma-buf exporter that I've seen implement
the sg mapping correctly and _do_ map the sg table into device address
space with dma_map_sg. In other words: The dma_addr_t are all valid, it's
just that e.g. with ttm no one has bothered to teach ttm a dma-buf
correctly. The internal abstraction is all there, ttm-internal buffer
object interface match what dma-buf exposes fairly closes (hey I didn't do
shit when designing those interfaces ;-)
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
