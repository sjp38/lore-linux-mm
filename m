Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id AB4236B0038
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 13:52:11 -0500 (EST)
Received: by mail-ie0-f176.google.com with SMTP id rd18so37202473iec.7
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 10:52:11 -0800 (PST)
Received: from mail-ie0-x22b.google.com (mail-ie0-x22b.google.com. [2607:f8b0:4001:c03::22b])
        by mx.google.com with ESMTPS id j7si1900023igx.15.2015.01.29.10.52.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 Jan 2015 10:52:10 -0800 (PST)
Received: by mail-ie0-f171.google.com with SMTP id tr6so37490201ieb.2
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 10:52:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150129154718.GB26493@n2100.arm.linux.org.uk>
References: <1422347154-15258-1-git-send-email-sumit.semwal@linaro.org>
	<1422347154-15258-2-git-send-email-sumit.semwal@linaro.org>
	<20150129143908.GA26493@n2100.arm.linux.org.uk>
	<CAO_48GEOQ1pBwirgEWeVVXW-iOmaC=Xerr2VyYYz9t1QDXgVsw@mail.gmail.com>
	<20150129154718.GB26493@n2100.arm.linux.org.uk>
Date: Thu, 29 Jan 2015 13:52:09 -0500
Message-ID: <CAF6AEGtTmFg66TK_AFkQ-xp7Nd9Evk3nqe6xCBp7K=77OmXTxA@mail.gmail.com>
Subject: Re: [RFCv3 2/2] dma-buf: add helpers for sharing attacher constraints
 with dma-parms
From: Rob Clark <robdclark@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Sumit Semwal <sumit.semwal@linaro.org>, LKML <linux-kernel@vger.kernel.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, Linaro MM SIG Mailman List <linaro-mm-sig@lists.linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, Daniel Vetter <daniel@ffwll.ch>, Robin Murphy <robin.murphy@arm.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On Thu, Jan 29, 2015 at 10:47 AM, Russell King - ARM Linux
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

The *theory* is that Y is map/unmap'ing the buffer around each use, so
there will be some point where things could be migrated and remapped..
in practice, I am not sure that anyone is doing this yet.

Probably it would be reasonable if a more restrictive subsystem tried
to attach after the buffer was already allocated and mapped in a way
that don't meet the new constraints, then -EBUSY.

But from a quick look it seems like there needs to be a slight fixup
to not return 0 if calc_constraints() fails..

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

Quite possibly for some of these edge some of cases, some of the
dma-buf exporters are going to need to get more clever (ie. hand off
different scatterlists to different clients).  Although I think by far
the two common cases will be "I can support anything via an iommu/mmu"
and "I need phys contig".

But that isn't an issue w/ dma-buf itself, so much as it is an issue
w/ drivers.  I guess there would be more interest in fixing up drivers
when actual hw comes along that needs it..

BR,
-R

> If an exporter were to take notice of the max_segment_size and
> max_segment_count, the resulting buffer is basically unrepresentable
> as a scatterlist.
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
> --
> FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
> according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
