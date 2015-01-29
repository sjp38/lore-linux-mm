Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id A6E806B0081
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 10:47:37 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id h11so11741446wiw.0
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 07:47:37 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id ce3si1435121wib.0.2015.01.29.07.47.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 29 Jan 2015 07:47:36 -0800 (PST)
Date: Thu, 29 Jan 2015 15:47:18 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFCv3 2/2] dma-buf: add helpers for sharing attacher
 constraints with dma-parms
Message-ID: <20150129154718.GB26493@n2100.arm.linux.org.uk>
References: <1422347154-15258-1-git-send-email-sumit.semwal@linaro.org>
 <1422347154-15258-2-git-send-email-sumit.semwal@linaro.org>
 <20150129143908.GA26493@n2100.arm.linux.org.uk>
 <CAO_48GEOQ1pBwirgEWeVVXW-iOmaC=Xerr2VyYYz9t1QDXgVsw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAO_48GEOQ1pBwirgEWeVVXW-iOmaC=Xerr2VyYYz9t1QDXgVsw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, Linaro MM SIG Mailman List <linaro-mm-sig@lists.linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, Rob Clark <robdclark@gmail.com>, Daniel Vetter <daniel@ffwll.ch>, Robin Murphy <robin.murphy@arm.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On Thu, Jan 29, 2015 at 09:00:11PM +0530, Sumit Semwal wrote:
> So, short answer is, it is left to the exporter to decide. The dma-buf
> framework should not even attempt to decide or enforce any of the
> above.
> 
> At each dma_buf_attach(), there's a callback to the exporter, where
> the exporter can decide, if it intends to handle these kind of cases,
> on the best way forward.
> 
> The exporter might, for example, decide to migrate backing storage,

That's a decision which the exporter can not take.  Think about it...

If subsystem Y has mapped the buffer, it could be accessing the buffer's
backing storage at the same time that subsystem Z tries to attach to the
buffer.

Once the buffer has been exported to another user, the exporter has
effectively lost control over mediating accesses to that buffer.

All that it can do with the way the dma-buf API is today is to allocate
a _different_ scatter list pointing at the same backing storage which
satisfies the segment size and number of segments, etc.

There's also another issue which you haven't addressed.  What if several
attachments result in lowering max_segment_size and max_segment_count
such that:

	max_segment_size * max_segment_count < dmabuf->size

but individually, the attachments allow dmabuf->size to be represented
as a scatterlist?

If an exporter were to take notice of the max_segment_size and
max_segment_count, the resulting buffer is basically unrepresentable
as a scatterlist.

> > Please consider the possible sequences of use (such as the scenario
> > above) when creating or augmenting an API.
> >
> 
> I tried to think of the scenarios I could think of, but If you still
> feel this approach doesn't help with your concerns, I'll graciously
> accept advice to improve it.

See the new one above :)

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
