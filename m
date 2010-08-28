Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 89F4A6B01F0
	for <linux-mm@kvack.org>; Sat, 28 Aug 2010 09:59:16 -0400 (EDT)
From: Hans Verkuil <hverkuil@xs4all.nl>
Subject: Re: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
Date: Sat, 28 Aug 2010 15:58:23 +0200
References: <cover.1282286941.git.m.nazarewicz@samsung.com> <201008281508.19756.hverkuil@xs4all.nl> <1283002486.1975.3479.camel@laptop>
In-Reply-To: <1283002486.1975.3479.camel@laptop>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <201008281558.23501.hverkuil@xs4all.nl>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <m.nazarewicz@samsung.com>, linux-mm@kvack.org, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Jonathan Corbet <corbet@lwn.net>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Pawel Osciak <p.osciak@samsung.com>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Saturday, August 28, 2010 15:34:46 Peter Zijlstra wrote:
> On Sat, 2010-08-28 at 15:08 +0200, Hans Verkuil wrote:
> 
> > > That would be good.  Although I expect that the allocation would need
> > > to be 100% rock-solid reliable, otherwise the end user has a
> > > non-functioning device.
> > 
> > Yes, indeed. And you have to be careful as well how you move pages around.
> > Say that you have a capture and an output v4l device: the first one needs
> > 64 MB contiguous memory and so it allocates that amount, moving pages around
> > as needed. Once allocated that memory is pinned in place since it is needed
> > for DMA. So if the output device also needs 64 MB, then you must have a
> > guarantee that the first allocation didn't fragment the available contiguous
> > memory.
> 
> Isn't the proposed CMA thing vulnerable to the exact same problem? If
> you allow sharing of regions and plug some allocator in there you get
> the same problem. If you can solve it there, you can solve it for any
> kind of reservation scheme.

Since with cma you can assign a region exclusively to a driver you can ensure
that this problem does not occur. Of course, if you allow sharing then you will
end up with the same type of problem unless you know that there is only one
driver at a time that will use that memory.

> > I also wonder how expensive it is to move all the pages around. E.g. if you
> > have a digital camera and want to make a hires picture, then it wouldn't
> > do if it takes a second to move all the pages around making room for the
> > captured picture. The CPUs in many SoCs are not very powerful compared to
> > your average desktop.
> 
> Well, that's a trade-off, if you want to have the memory be usable for
> anything else (which I understood people did want) then you have to pay
> for cleaning it up when you need to use it.
> 
> As for the cost of compaction vs regular page-out of random page-cache
> memory, compaction is actually cheaper, since it doesn't need to write
> out dirty data, and page-out driven writeback sucks due to the
> non-linear nature of it.

There is obviously a trade-off. I was just wondering how costly it is.
E.g. would it be a noticeable delay making 64 MB memory available in this
way on a, say, 600 MHz ARM.
 
> > And how would memory allocations in specific memory ranges (e.g. memory
> > banks) work?
> 
> Make sure you reserve pageblocks in the desired range.
> 
> > Note also that these issues are not limited to embedded systems, also PCI(e)
> > boards can sometimes require massive amounts of DMA-able memory. I have had
> > this happen in the past with the ivtv driver with customers that had 15 or so
> > capture cards in one box. And I'm sure it will happen in the future as well,
> > esp. with upcoming 4k video formats.
> 
> I would sincerely hope PCI(e) devices come with an IOMMU (and all memory
> lines wired up), really, any hardware that doesn't isn't worth the
> silicon its engraved in. Just don't buy it.

In the case of the ivtv driver the PCI device had a broken scatter-gather DMA
engine, which is the underlying reason for these issues. Since I was maintainer
of this driver for a few years I would love to have a reliable solution for the
memory issues. It's not a big deal, 99.99% of all users will never notice
anything, but still... And I don't think there are any affordable or easily
obtainable alternatives to this hardware with similar feature sets, even after
all these years.

Anyway, I agree with your sentiment, but reality can be disappointingly
different :-( And especially with regards to video hardware the creativity of
the hardware designers is boundless -- to the dismay of us linux-media developers.

Regards,

	Hans

-- 
Hans Verkuil - video4linux developer - sponsored by TANDBERG, part of Cisco

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
