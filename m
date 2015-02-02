Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id EAA656B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 00:53:56 -0500 (EST)
Received: by mail-oi0-f46.google.com with SMTP id a141so42894776oig.5
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 21:53:56 -0800 (PST)
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com. [209.85.218.48])
        by mx.google.com with ESMTPS id dv10si8750519obc.102.2015.02.01.21.53.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 01 Feb 2015 21:53:55 -0800 (PST)
Received: by mail-oi0-f48.google.com with SMTP id v63so42777280oia.7
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 21:53:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150129192610.GE26493@n2100.arm.linux.org.uk>
References: <1422347154-15258-1-git-send-email-sumit.semwal@linaro.org>
 <1422347154-15258-2-git-send-email-sumit.semwal@linaro.org>
 <20150129143908.GA26493@n2100.arm.linux.org.uk> <CAO_48GEOQ1pBwirgEWeVVXW-iOmaC=Xerr2VyYYz9t1QDXgVsw@mail.gmail.com>
 <20150129154718.GB26493@n2100.arm.linux.org.uk> <CAF6AEGtTmFg66TK_AFkQ-xp7Nd9Evk3nqe6xCBp7K=77OmXTxA@mail.gmail.com>
 <20150129192610.GE26493@n2100.arm.linux.org.uk>
From: Sumit Semwal <sumit.semwal@linaro.org>
Date: Mon, 2 Feb 2015 11:23:35 +0530
Message-ID: <CAO_48GGqtYWMnweUx_8_p4HOyf58h2q0PbvehVNN5Wm5p_N00w@mail.gmail.com>
Subject: Re: [RFCv3 2/2] dma-buf: add helpers for sharing attacher constraints
 with dma-parms
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Rob Clark <robdclark@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, Linaro MM SIG Mailman List <linaro-mm-sig@lists.linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, Daniel Vetter <daniel@ffwll.ch>, Robin Murphy <robin.murphy@arm.com>, Marek Szyprowski <m.szyprowski@samsung.com>

Hi Russell,

On 30 January 2015 at 00:56, Russell King - ARM Linux
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
> The whole "we can push it onto our users" is really on - what that
> results in is the users ignoring most of the requirements and just doing
> their own thing, which ultimately ends up with the whole thing turning
> into a disgusting mess - one which becomes very difficult to fix later.
>
> Now, if we're going to do the "more clever" thing you mention above,
> that rather negates the point of this two-part patch set, which is to
> provide the union of the DMA capabilities of all users.  A union in
> that case is no longer sane as we'd be tailoring the SG lists to each
> user.
>
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
I agree, and I'll add the check for
max_segment_size * max_segment_count < dmabuf->size
and resend; will that be alright with you?

> It really doesn't make sense to do both either: that route is even more
> madness, because we'll end up with two classes of drivers - those which
> use the union approach, and those which don't.
>
> The KISS principle applies here.
>
> --
> FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
> according to speedtest.net.


Best regards,
~Sumit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
