Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 6D26B6B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 02:47:36 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id z12so43063086wgg.3
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 23:47:36 -0800 (PST)
Received: from mail-wg0-x22f.google.com (mail-wg0-x22f.google.com. [2a00:1450:400c:c00::22f])
        by mx.google.com with ESMTPS id t10si27667714wia.44.2015.02.02.23.47.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Feb 2015 23:47:35 -0800 (PST)
Received: by mail-wg0-f47.google.com with SMTP id n12so43033353wgh.6
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 23:47:34 -0800 (PST)
Date: Tue, 3 Feb 2015 08:48:56 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [RFCv3 2/2] dma-buf: add helpers for sharing attacher
 constraints with dma-parms
Message-ID: <20150203074856.GF14009@phenom.ffwll.local>
References: <1422347154-15258-1-git-send-email-sumit.semwal@linaro.org>
 <1422347154-15258-2-git-send-email-sumit.semwal@linaro.org>
 <20150129143908.GA26493@n2100.arm.linux.org.uk>
 <CAO_48GEOQ1pBwirgEWeVVXW-iOmaC=Xerr2VyYYz9t1QDXgVsw@mail.gmail.com>
 <20150129154718.GB26493@n2100.arm.linux.org.uk>
 <CAF6AEGtTmFg66TK_AFkQ-xp7Nd9Evk3nqe6xCBp7K=77OmXTxA@mail.gmail.com>
 <20150129192610.GE26493@n2100.arm.linux.org.uk>
 <CAF6AEGujk8UC4X6T=yhTrz1s+SyZUQ=m05h_WcxLDGZU6bydbw@mail.gmail.com>
 <20150202165405.GX14009@phenom.ffwll.local>
 <CAF6AEGuESM+e3HSRGM6zLqrp8kqRLGUYvA3KKECdm7m-nt0M=Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAF6AEGuESM+e3HSRGM6zLqrp8kqRLGUYvA3KKECdm7m-nt0M=Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Clark <robdclark@gmail.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Sumit Semwal <sumit.semwal@linaro.org>, LKML <linux-kernel@vger.kernel.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, Linaro MM SIG Mailman List <linaro-mm-sig@lists.linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, Robin Murphy <robin.murphy@arm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Daniel Vetter <daniel@ffwll.ch>

On Mon, Feb 02, 2015 at 03:30:21PM -0500, Rob Clark wrote:
> On Mon, Feb 2, 2015 at 11:54 AM, Daniel Vetter <daniel@ffwll.ch> wrote:
> >> My initial thought is for dma-buf to not try to prevent something than
> >> an exporter can actually do.. I think the scenario you describe could
> >> be handled by two sg-lists, if the exporter was clever enough.
> >
> > That's already needed, each attachment has it's own sg-list. After all
> > there's no array of dma_addr_t in the sg tables, so you can't use one sg
> > for more than one mapping. And due to different iommu different devices
> > can easily end up with different addresses.
> 
> 
> Well, to be fair it may not be explicitly stated, but currently one
> should assume the dma_addr_t's in the dmabuf sglist are bogus.  With
> gpu's that implement per-process/context page tables, I'm not really
> sure that there is a sane way to actually do anything else..

Hm, what does per-process/context page tables have to do here? At least on
i915 we have a two levels of page tables:
- first level for vm/device isolation, used through dma api
- 2nd level for per-gpu-context isolation and context switching, handled
  internally.

Since atm the dma api doesn't have any context of contexts or different
pagetables, I don't see who you could use that at all.
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
