Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id B01CB6B0038
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 11:55:32 -0500 (EST)
Received: by mail-oi0-f47.google.com with SMTP id a141so28699669oig.6
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 08:55:32 -0800 (PST)
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com. [209.85.218.46])
        by mx.google.com with ESMTPS id pu8si4094176obb.42.2015.01.29.08.55.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 Jan 2015 08:55:31 -0800 (PST)
Received: by mail-oi0-f46.google.com with SMTP id a141so28736803oig.5
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 08:55:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150129154718.GB26493@n2100.arm.linux.org.uk>
References: <1422347154-15258-1-git-send-email-sumit.semwal@linaro.org>
 <1422347154-15258-2-git-send-email-sumit.semwal@linaro.org>
 <20150129143908.GA26493@n2100.arm.linux.org.uk> <CAO_48GEOQ1pBwirgEWeVVXW-iOmaC=Xerr2VyYYz9t1QDXgVsw@mail.gmail.com>
 <20150129154718.GB26493@n2100.arm.linux.org.uk>
From: Sumit Semwal <sumit.semwal@linaro.org>
Date: Thu, 29 Jan 2015 22:25:10 +0530
Message-ID: <CAO_48GFh3spdGJ=0Mt8BJP0D5EYc2X=KSbmNfYmTMTzsCAMz4A@mail.gmail.com>
Subject: Re: [RFCv3 2/2] dma-buf: add helpers for sharing attacher constraints
 with dma-parms
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, Linaro MM SIG Mailman List <linaro-mm-sig@lists.linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, Rob Clark <robdclark@gmail.com>, Daniel Vetter <daniel@ffwll.ch>, Robin Murphy <robin.murphy@arm.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On 29 January 2015 at 21:17, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Thu, Jan 29, 2015 at 09:00:11PM +0530, Sumit Semwal wrote:
>> So, short answer is, it is left to the exporter to decide. The dma-buf
>> framework should not even attempt to decide or enforce any of the
>> above.
>>
>> At each dma_buf_attach(), there's a callback to the exporter, where
>> the exporter can decide, if it intends to handle these kind of cases,
>> on the best way forward.
>>
>> The exporter might, for example, decide to migrate backing storage,
>
> That's a decision which the exporter can not take.  Think about it...
>
> If subsystem Y has mapped the buffer, it could be accessing the buffer's
> backing storage at the same time that subsystem Z tries to attach to the
> buffer.
>
Well, first up, of course the 'migration of backing storage' is an
orthogonal problem to what this patchset attempts to do - in this, I
am only try to make the relevant information available to the
exporter.

With that out of the way, some thoughts on what you mentioned:

So, IF the exporter needs to support migration of backing storage,
even when subsystem Y has mapped the buffer, the exporter knows this
(because of the map_dma_buf() dma_buf_op) - and the attach() also is
notified to / handled by the exporter. With this information, it could
either:
a) not let the subsystem Z attach (the 'simpler' approach), or
b) hold enough state-information about the Z's attach request
internally, then migrate the pages on the unmap_attachment() callback
from the subsystem Y?

(The exact details for this will need to be thought-of by exporters
actually trying to do migration of pages, or delayed allocation, or
such, though)

> Once the buffer has been exported to another user, the exporter has
> effectively lost control over mediating accesses to that buffer.
>
> All that it can do with the way the dma-buf API is today is to allocate
> a _different_ scatter list pointing at the same backing storage which
> satisfies the segment size and number of segments, etc.
>
> There's also another issue which you haven't addressed.  What if several
> attachments result in lowering max_segment_size and max_segment_count
> such that:
>
>         max_segment_size * max_segment_count < dmabuf->size
>
> but individually, the attachments allow dmabuf->size to be represented
> as a scatterlist?
>
> If an exporter were to take notice of the max_segment_size and
> max_segment_count, the resulting buffer is basically unrepresentable
> as a scatterlist.

Thanks for pointing that out; I guess we'd have to disallow the
attachment which would make that happen. I can add this as another
check in calc_constraints().

>
>> > Please consider the possible sequences of use (such as the scenario
>> > above) when creating or augmenting an API.
>> >
>>
>> I tried to think of the scenarios I could think of, but If you still
>> feel this approach doesn't help with your concerns, I'll graciously
>> accept advice to improve it.
>
> See the new one above :)
>
Another thanks for making me rack my puny brain on these scenarios! :)
[though I strongly suspect I might not have done enough!]
> --
> FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
> according to speedtest.net.

BR,
~Sumit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
