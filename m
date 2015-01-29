Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id D57846B0038
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 17:18:35 -0500 (EST)
Received: by mail-ie0-f171.google.com with SMTP id tr6so538738ieb.2
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 14:18:34 -0800 (PST)
Received: from mail-ie0-x231.google.com (mail-ie0-x231.google.com. [2607:f8b0:4001:c03::231])
        by mx.google.com with ESMTPS id sc1si179990igb.6.2015.01.29.14.18.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 Jan 2015 14:18:34 -0800 (PST)
Received: by mail-ie0-f177.google.com with SMTP id vy18so215020iec.8
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 14:18:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150129192610.GE26493@n2100.arm.linux.org.uk>
References: <1422347154-15258-1-git-send-email-sumit.semwal@linaro.org>
	<1422347154-15258-2-git-send-email-sumit.semwal@linaro.org>
	<20150129143908.GA26493@n2100.arm.linux.org.uk>
	<CAO_48GEOQ1pBwirgEWeVVXW-iOmaC=Xerr2VyYYz9t1QDXgVsw@mail.gmail.com>
	<20150129154718.GB26493@n2100.arm.linux.org.uk>
	<CAF6AEGtTmFg66TK_AFkQ-xp7Nd9Evk3nqe6xCBp7K=77OmXTxA@mail.gmail.com>
	<20150129192610.GE26493@n2100.arm.linux.org.uk>
Date: Thu, 29 Jan 2015 17:18:33 -0500
Message-ID: <CAF6AEGujk8UC4X6T=yhTrz1s+SyZUQ=m05h_WcxLDGZU6bydbw@mail.gmail.com>
Subject: Re: [RFCv3 2/2] dma-buf: add helpers for sharing attacher constraints
 with dma-parms
From: Rob Clark <robdclark@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Sumit Semwal <sumit.semwal@linaro.org>, LKML <linux-kernel@vger.kernel.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, Linaro MM SIG Mailman List <linaro-mm-sig@lists.linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, Daniel Vetter <daniel@ffwll.ch>, Robin Murphy <robin.murphy@arm.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On Thu, Jan 29, 2015 at 2:26 PM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Thu, Jan 29, 2015 at 01:52:09PM -0500, Rob Clark wrote:
>> Quite possibly for some of these edge some of cases, some of the
>> dma-buf exporters are going to need to get more clever (ie. hand off
>> different scatterlists to different clients).  Although I think by far
>> the two common cases will be "I can support anything via an iommu/mmu"
>> and "I need phys contig".
>>
>> But that isn't an issue w/ dma-buf itself, so much as it is an issue
>> w/ drivers.  I guess there would be more interest in fixing up drivers
>> when actual hw comes along that needs it..
>
> However, validating the attachments is the business of dma-buf.  This
> is actual infrastructure, which should ensure some kind of sanity such
> as the issues I've raised.
>

My initial thought is for dma-buf to not try to prevent something than
an exporter can actually do.. I think the scenario you describe could
be handled by two sg-lists, if the exporter was clever enough.

That all said, I think probably all the existing exporters cache the
sg-list.  And I can't think of any actual hw which would hit this
problem that can be solved by multiple sg-lists for the same physical
memory.  (And the constraint calculation kind of assumes the end
result will be a single sg-list.)  So it seems reasonable to me to
check that max_segment_count * max_segment_size is not smaller than
the buffer.

If it was a less theoretical problem, I think I'd more inclined for a
way that the exporter could override the checks, or something along
those lines.

otoh, if the attachment is just not possible because the buffer has
been already allocated and mapped by someone with more relaxed
constraints.. then I think the driver should be the one returning the
error since dma-buf doesn't know this.

> The whole "we can push it onto our users" is really on - what that
> results in is the users ignoring most of the requirements and just doing
> their own thing, which ultimately ends up with the whole thing turning
> into a disgusting mess - one which becomes very difficult to fix later.

Ideally at some point, dma-mapping or some helpers would support
allocations matching constraints..  I think only actual gpu drivers
want to do crazy enough things that they'd want to bypass dma-mapping.
If everyone else can use dma-mapping and/or helpers then we make it
harder for drivers to do the wrong thing than to do the right thing.

> Now, if we're going to do the "more clever" thing you mention above,
> that rather negates the point of this two-part patch set, which is to
> provide the union of the DMA capabilities of all users.  A union in
> that case is no longer sane as we'd be tailoring the SG lists to each
> user.

It doesn't really negate.. a different sg list representing the same
physical memory cannot suddenly make the buffer physically contiguous
(from the perspective of memory)..

(unless we are not on the same page here, so to speak)

BR,
-R

> If we aren't going to do the "more clever" thing, then yes, we need this
> code to calculate that union, but we _also_ need it to do sanity checking
> right from the start, and refuse conditions which ultimately break the
> ability to make use of that union - in other words, when the union of
> the DMA capabilities means that the dmabuf can't be represented.
>
> Unless we do that, we'll just end up with random drivers interpreting
> what they want from the DMA capabilities, and we'll have some drivers
> exporting (eg) scatterlists which satisfy the maximum byte size of an
> element, but ignoring the maximum number of entries or vice versa, and
> that'll most probably hide the case of "too small a union".
>
> It really doesn't make sense to do both either: that route is even more
> madness, because we'll end up with two classes of drivers - those which
> use the union approach, and those which don't.
>
> The KISS principle applies here.
>
> --
> FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
> according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
