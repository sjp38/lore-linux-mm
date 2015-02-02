Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 100FB6B006C
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 17:36:11 -0500 (EST)
Received: by mail-ig0-f179.google.com with SMTP id l13so20449297iga.0
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 14:36:10 -0800 (PST)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id ly5si8452290icb.101.2015.02.02.14.36.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Feb 2015 14:36:10 -0800 (PST)
Received: by mail-ig0-f179.google.com with SMTP id l13so20449275iga.0
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 14:36:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150202214616.GI8656@n2100.arm.linux.org.uk>
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
	<20150202214616.GI8656@n2100.arm.linux.org.uk>
Date: Mon, 2 Feb 2015 17:36:10 -0500
Message-ID: <CAF6AEGvE78a9u9=C6HbuuYs_zwGf6opdXUNfxb51kixFa7zLwA@mail.gmail.com>
Subject: Re: [RFCv3 2/2] dma-buf: add helpers for sharing attacher constraints
 with dma-parms
From: Rob Clark <robdclark@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Sumit Semwal <sumit.semwal@linaro.org>, LKML <linux-kernel@vger.kernel.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, Linaro MM SIG Mailman List <linaro-mm-sig@lists.linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, Robin Murphy <robin.murphy@arm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Daniel Vetter <daniel@ffwll.ch>

On Mon, Feb 2, 2015 at 4:46 PM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Mon, Feb 02, 2015 at 03:30:21PM -0500, Rob Clark wrote:
>> On Mon, Feb 2, 2015 at 11:54 AM, Daniel Vetter <daniel@ffwll.ch> wrote:
>> >> My initial thought is for dma-buf to not try to prevent something than
>> >> an exporter can actually do.. I think the scenario you describe could
>> >> be handled by two sg-lists, if the exporter was clever enough.
>> >
>> > That's already needed, each attachment has it's own sg-list. After all
>> > there's no array of dma_addr_t in the sg tables, so you can't use one sg
>> > for more than one mapping. And due to different iommu different devices
>> > can easily end up with different addresses.
>>
>>
>> Well, to be fair it may not be explicitly stated, but currently one
>> should assume the dma_addr_t's in the dmabuf sglist are bogus.  With
>> gpu's that implement per-process/context page tables, I'm not really
>> sure that there is a sane way to actually do anything else..
>
> That's incorrect - and goes dead against the design of scatterlists.

yeah, a bit of an abuse, although I'm not sure I see a much better way
when a device vaddr depends on user context..

> Not only that, but it is entirely possible that you may get handed
> memory via dmabufs for which there are no struct page's associated
> with that memory - think about display systems which have their own
> video memory which is accessible to the GPU, but it isn't system
> memory.

well, I guess anyways when it comes to sharing buffers, it won't be
the vram placement of the bo that gets shared ;-)

BR,
-R

> In those circumstances, you have to use the dma_addr_t's and not the
> pages.
>
> --
> FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
> according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
