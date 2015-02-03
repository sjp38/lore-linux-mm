Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id CEB7A6B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 15:07:29 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id h11so24289094wiw.1
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 12:07:29 -0800 (PST)
Received: from mail-wg0-x234.google.com (mail-wg0-x234.google.com. [2a00:1450:400c:c00::234])
        by mx.google.com with ESMTPS id eq1si44964994wjd.19.2015.02.03.12.07.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 12:07:28 -0800 (PST)
Received: by mail-wg0-f52.google.com with SMTP id y19so46600176wgg.11
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 12:07:27 -0800 (PST)
Date: Tue, 3 Feb 2015 21:08:49 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [Linaro-mm-sig] [RFCv3 2/2] dma-buf: add helpers for sharing
 attacher constraints with dma-parms
Message-ID: <20150203200849.GY14009@phenom.ffwll.local>
References: <1422347154-15258-1-git-send-email-sumit.semwal@linaro.org>
 <3783167.LiVXgA35gN@wuerfel>
 <20150203155404.GV8656@n2100.arm.linux.org.uk>
 <6906596.JU5vQoa1jV@wuerfel>
 <20150203165829.GW8656@n2100.arm.linux.org.uk>
 <CAF6AEGuf6XBe3YOjhtbBcSyqJrkZ7sNMfc83hZdnKsE3P=vSuw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAF6AEGuf6XBe3YOjhtbBcSyqJrkZ7sNMfc83hZdnKsE3P=vSuw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Clark <robdclark@gmail.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Robin Murphy <robin.murphy@arm.com>, LKML <linux-kernel@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Daniel Vetter <daniel@ffwll.ch>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>

On Tue, Feb 03, 2015 at 12:35:34PM -0500, Rob Clark wrote:
> On Tue, Feb 3, 2015 at 11:58 AM, Russell King - ARM Linux
> <linux@arm.linux.org.uk> wrote:
> >
> > Okay, but switching contexts is not something which the DMA API has
> > any knowledge of (so it can't know which context to associate with
> > which mapping.)  While it knows which device, it has no knowledge
> > (nor is there any way for it to gain knowledge) about contexts.
> >
> > My personal view is that extending the DMA API in this way feels quite
> > dirty - it's a violation of the DMA API design, which is to (a) demark
> > the buffer ownership between CPU and DMA agent, and (b) to translate
> > buffer locations into a cookie which device drivers can use to instruct
> > their device to access that memory.  To see why, consider... that you
> > map a buffer to a device in context A, and then you switch to context B,
> > which means the dma_addr_t given previously is no longer valid.  You
> > then try to unmap it... which is normally done using the (now no longer
> > valid) dma_addr_t.
> >
> > It seems to me that to support this at DMA API level, we would need to
> > completely revamp the DMA API, which IMHO isn't going to be nice.  (It
> > would mean that we end up with three APIs - the original PCI DMA API,
> > the existing DMA API, and some new DMA API.)
> >
> > Do we have any views on how common this feature is?
> >
> 
> I can't think of cases outside of GPU's..  if it were more common I'd
> be in favor of teaching dma api about multiple contexts, but right now
> I think that would just amount to forcing a lot of churn on everyone
> else for the benefit of GPU's.
> 
> IMHO it makes more sense for GPU drivers to bypass the dma api if they
> need to.  Plus, sooner or later, someone will discover that with some
> trick or optimization they can get moar fps, but the extra layer of
> abstraction will just be getting in the way.

See my other reply, but all existing full-blown drivers don't bypass the
dma api. Instead it's just a two-level scheme:
1. First level is dma api. Might or might not contain a system iommu.
2. 2nd level is the gpu-private iommu which is also used for per context
address spaces. Thus far all drivers just rolled their own drivers for
this (it's kinda fused to the chips on x86 hw anyway), but it looks like
using the iommu api gives us a somewhat suitable abstraction for code
sharing.

Imo you need both, otherwise we start leaking stuff like cpu cache
flushing all over the place. Looking at i915 (where the dma api assumes
that everything is coherent, which is kinda not the case) that won't be
pretty. And there's still the issue that you might nest a system iommu
and a 2nd level iommu for per-context pagetables (this is real and what's
going on right now on intel hw).
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
