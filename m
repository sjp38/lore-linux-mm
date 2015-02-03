Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 698006B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 12:35:43 -0500 (EST)
Received: by mail-ie0-f175.google.com with SMTP id ar1so26914845iec.6
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 09:35:43 -0800 (PST)
Received: from mail-ig0-x230.google.com (mail-ig0-x230.google.com. [2607:f8b0:4001:c05::230])
        by mx.google.com with ESMTPS id rs6si10200880igb.46.2015.02.03.09.35.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Feb 2015 09:35:34 -0800 (PST)
Received: by mail-ig0-f176.google.com with SMTP id hl2so28386899igb.3
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 09:35:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150203165829.GW8656@n2100.arm.linux.org.uk>
References: <1422347154-15258-1-git-send-email-sumit.semwal@linaro.org>
	<3783167.LiVXgA35gN@wuerfel>
	<20150203155404.GV8656@n2100.arm.linux.org.uk>
	<6906596.JU5vQoa1jV@wuerfel>
	<20150203165829.GW8656@n2100.arm.linux.org.uk>
Date: Tue, 3 Feb 2015 12:35:34 -0500
Message-ID: <CAF6AEGuf6XBe3YOjhtbBcSyqJrkZ7sNMfc83hZdnKsE3P=vSuw@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [RFCv3 2/2] dma-buf: add helpers for sharing
 attacher constraints with dma-parms
From: Rob Clark <robdclark@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Arnd Bergmann <arnd@arndb.de>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Robin Murphy <robin.murphy@arm.com>, LKML <linux-kernel@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Daniel Vetter <daniel@ffwll.ch>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>

On Tue, Feb 3, 2015 at 11:58 AM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
>
> Okay, but switching contexts is not something which the DMA API has
> any knowledge of (so it can't know which context to associate with
> which mapping.)  While it knows which device, it has no knowledge
> (nor is there any way for it to gain knowledge) about contexts.
>
> My personal view is that extending the DMA API in this way feels quite
> dirty - it's a violation of the DMA API design, which is to (a) demark
> the buffer ownership between CPU and DMA agent, and (b) to translate
> buffer locations into a cookie which device drivers can use to instruct
> their device to access that memory.  To see why, consider... that you
> map a buffer to a device in context A, and then you switch to context B,
> which means the dma_addr_t given previously is no longer valid.  You
> then try to unmap it... which is normally done using the (now no longer
> valid) dma_addr_t.
>
> It seems to me that to support this at DMA API level, we would need to
> completely revamp the DMA API, which IMHO isn't going to be nice.  (It
> would mean that we end up with three APIs - the original PCI DMA API,
> the existing DMA API, and some new DMA API.)
>
> Do we have any views on how common this feature is?
>

I can't think of cases outside of GPU's..  if it were more common I'd
be in favor of teaching dma api about multiple contexts, but right now
I think that would just amount to forcing a lot of churn on everyone
else for the benefit of GPU's.

IMHO it makes more sense for GPU drivers to bypass the dma api if they
need to.  Plus, sooner or later, someone will discover that with some
trick or optimization they can get moar fps, but the extra layer of
abstraction will just be getting in the way.

BR,
-R

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
