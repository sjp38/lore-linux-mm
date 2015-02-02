Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id BB4256B0032
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 11:52:46 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id h11so18234665wiw.5
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 08:52:45 -0800 (PST)
Received: from mail-wg0-x229.google.com (mail-wg0-x229.google.com. [2a00:1450:400c:c00::229])
        by mx.google.com with ESMTPS id j17si26562117wiv.104.2015.02.02.08.52.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Feb 2015 08:52:44 -0800 (PST)
Received: by mail-wg0-f41.google.com with SMTP id a1so39922612wgh.0
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 08:52:44 -0800 (PST)
Date: Mon, 2 Feb 2015 17:54:05 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [RFCv3 2/2] dma-buf: add helpers for sharing attacher
 constraints with dma-parms
Message-ID: <20150202165405.GX14009@phenom.ffwll.local>
References: <1422347154-15258-1-git-send-email-sumit.semwal@linaro.org>
 <1422347154-15258-2-git-send-email-sumit.semwal@linaro.org>
 <20150129143908.GA26493@n2100.arm.linux.org.uk>
 <CAO_48GEOQ1pBwirgEWeVVXW-iOmaC=Xerr2VyYYz9t1QDXgVsw@mail.gmail.com>
 <20150129154718.GB26493@n2100.arm.linux.org.uk>
 <CAF6AEGtTmFg66TK_AFkQ-xp7Nd9Evk3nqe6xCBp7K=77OmXTxA@mail.gmail.com>
 <20150129192610.GE26493@n2100.arm.linux.org.uk>
 <CAF6AEGujk8UC4X6T=yhTrz1s+SyZUQ=m05h_WcxLDGZU6bydbw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAF6AEGujk8UC4X6T=yhTrz1s+SyZUQ=m05h_WcxLDGZU6bydbw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Clark <robdclark@gmail.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Sumit Semwal <sumit.semwal@linaro.org>, LKML <linux-kernel@vger.kernel.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, Linaro MM SIG Mailman List <linaro-mm-sig@lists.linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, Daniel Vetter <daniel@ffwll.ch>, Robin Murphy <robin.murphy@arm.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On Thu, Jan 29, 2015 at 05:18:33PM -0500, Rob Clark wrote:
> On Thu, Jan 29, 2015 at 2:26 PM, Russell King - ARM Linux
> <linux@arm.linux.org.uk> wrote:
> > On Thu, Jan 29, 2015 at 01:52:09PM -0500, Rob Clark wrote:
> >> Quite possibly for some of these edge some of cases, some of the
> >> dma-buf exporters are going to need to get more clever (ie. hand off
> >> different scatterlists to different clients).  Although I think by far
> >> the two common cases will be "I can support anything via an iommu/mmu"
> >> and "I need phys contig".
> >>
> >> But that isn't an issue w/ dma-buf itself, so much as it is an issue
> >> w/ drivers.  I guess there would be more interest in fixing up drivers
> >> when actual hw comes along that needs it..
> >
> > However, validating the attachments is the business of dma-buf.  This
> > is actual infrastructure, which should ensure some kind of sanity such
> > as the issues I've raised.
> >
> 
> My initial thought is for dma-buf to not try to prevent something than
> an exporter can actually do.. I think the scenario you describe could
> be handled by two sg-lists, if the exporter was clever enough.

That's already needed, each attachment has it's own sg-list. After all
there's no array of dma_addr_t in the sg tables, so you can't use one sg
for more than one mapping. And due to different iommu different devices
can easily end up with different addresses.

> That all said, I think probably all the existing exporters cache the
> sg-list.  And I can't think of any actual hw which would hit this
> problem that can be solved by multiple sg-lists for the same physical
> memory.  (And the constraint calculation kind of assumes the end
> result will be a single sg-list.)  So it seems reasonable to me to
> check that max_segment_count * max_segment_size is not smaller than
> the buffer.
>
> If it was a less theoretical problem, I think I'd more inclined for a
> way that the exporter could override the checks, or something along
> those lines.
> 
> otoh, if the attachment is just not possible because the buffer has
> been already allocated and mapped by someone with more relaxed
> constraints.. then I think the driver should be the one returning the
> error since dma-buf doesn't know this.

Importers currently cache the mapped sg list aggressively (i915) or
outright pin it for as long as possible (everyone else). So any kind of
moving stuff around is pretty much impossible with current drivers.

The even worse violation of the dma-buf spec is that all the ttm drivers
don't use the sg table correctly at all. They assume that each physical
page has exactly one sg table entry, and then fish out the struct page *
pointer from that to build up their own bo management stuff and ignore
everything else.

> > The whole "we can push it onto our users" is really on - what that
> > results in is the users ignoring most of the requirements and just doing
> > their own thing, which ultimately ends up with the whole thing turning
> > into a disgusting mess - one which becomes very difficult to fix later.
> 
> Ideally at some point, dma-mapping or some helpers would support
> allocations matching constraints..  I think only actual gpu drivers
> want to do crazy enough things that they'd want to bypass dma-mapping.
> If everyone else can use dma-mapping and/or helpers then we make it
> harder for drivers to do the wrong thing than to do the right thing.
> 
> > Now, if we're going to do the "more clever" thing you mention above,
> > that rather negates the point of this two-part patch set, which is to
> > provide the union of the DMA capabilities of all users.  A union in
> > that case is no longer sane as we'd be tailoring the SG lists to each
> > user.
> 
> It doesn't really negate.. a different sg list representing the same
> physical memory cannot suddenly make the buffer physically contiguous
> (from the perspective of memory)..
> 
> (unless we are not on the same page here, so to speak)

Or someone was not chip and put a decent iommu in front of the same IP
block. E.g. the raspi gpu needs contiguous memory for rendering, but the
same block is used elsewhere but then with an iommu.

But thinking about all this I wonder whether we really should start with
some kind of constraint solving. It feels fairly leaky compared to the
encapsulation the dma api provides, and so isn't really better for
upstream than just using ion (which completely gives up on this problem
and relies on userspace allocating correct buffers).

And if we step away for a bit there's already a bunch of things that the
current dma api fails at, and which is just a bit a worse problem with
dma-buf sharing: There's not really a generic way to map an sg table
zero-copy, i.e. there's no generic way to avoid bounce buffers. And that's
already hurting all the existing gpu drivers: ttm essentially does
page-sized allocs for everything and then has it's own dma allocator on
top of that page-cache. i915 has some other hacks to at least not fail the
bounce buffer allocator too badly. Grepping for SWIOTLB in drm is fairly
interesting.

So imo if our goal is to keep the abstraction provided by the dma api
somewhat intact we should first figure out to map an sg table without
copying any data. If we have that any exporter can then easily check
whether an attachment works out by test-mapping stuff. A bit inefficient,
but at least possible (and exporters could cache the mapped sg table if so
desired). And we could rip out a pile of hacks from drm drivers.

The other problem is is coherency management. Even in the single-device
usecase current dma-buf isn't up to things since on many socs the same
device can use both coherent and non-coherent transactions. And if you map
the same memory multiple times we don't really want to flush cpu caches
multiple times (ppl alreay have massive caches and stuff to avoid the
cpu cache flush when there's just one device using the buffer object).
Again this probably needs some core dma api extensions. And again we could
probably throw away a bunch of driver code (at least in i915,
unfortunately there's no intel v4l driver to test non-coherent sharing on
x86).

With all that resolved somehow (and all these issues already affect
single-device dma api usage by gpu drivers) the bit left would be figuring
out where to allocate things. And I'm not even sure whether we should
really bother to implement this in the kernel (no matter how I slice it it
always looks like we're leaking the dma api abstractions) but just with a
few tries in userspace:

- Allocate shared buffers from the scanout engine (or v4l, though that
  doesn't yet support exporting).

- If you can't import, try it the other way round. This isn't perfect for
  cross-process + cross-device bo sharing, but then pretty much all
  compositors have a gpu rendering fallback anyway because this problem is
  a bit too complex to solve perfectly. Of course for the next frame
  compositor can provide a new buffer which hopefully works out better.

- Userspace just knows where to allocate. Imo that's not actually
  unreasonable since if you really have that tricky requirements you
  probably also have insane buffer layouts and then all bets for generic
  code are off anyway.

Cheers, Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
