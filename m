Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6F09F6B0114
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 05:58:35 -0400 (EDT)
Subject: Re: [PATCH 0/3]HTLB mapping for drivers (take 2)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20090825111031.GD21335@csn.ul.ie>
References: <alpine.LFD.2.00.0908172317470.32114@casper.infradead.org>
	 <56e00de0908180329p2a37da3fp43ddcb8c2d63336a@mail.gmail.com>
	 <202cde0e0908182248we01324em2d24b9e741727a7b@mail.gmail.com>
	 <20090819100553.GE24809@csn.ul.ie>
	 <202cde0e0908200003w43b91ac3v8a149ec1ace45d6d@mail.gmail.com>
	 <20090825104731.GA21335@csn.ul.ie> <1251198054.15197.40.camel@pasglop>
	 <20090825111031.GD21335@csn.ul.ie>
Content-Type: text/plain
Date: Wed, 26 Aug 2009 19:58:05 +1000
Message-Id: <1251280685.1379.67.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Alexey Korolev <akorolex@gmail.com>, Eric Munson <linux-mm@mgebm.net>, Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2009-08-25 at 12:10 +0100, Mel Gorman wrote:
> On Tue, Aug 25, 2009 at 09:00:54PM +1000, Benjamin Herrenschmidt wrote:
> > On Tue, 2009-08-25 at 11:47 +0100, Mel Gorman wrote:
> > 
> > > Why? One hugepage of default size will be one TLB entry. Each hugepage
> > > after that will be additional TLB entries so there is no savings on
> > > translation overhead.
> > > 
> > > Getting contiguous pages beyond the hugepage boundary is not a matter
> > > for GFP flags.
> > 
> > Note: This patch reminds me of something else I had on the backburner
> > for a while and never got a chance to actually implement...
> > 
> > There's various cases of drivers that could have good uses of hugetlb
> > mappings of device memory. For example, framebuffers.
> > 
> 
> Where is the buffer located? If it's in kernel space, than any contiguous
> allocation will be automatically backed by huge PTEs. As framebuffer allocation
> is probably happening early in boot, just calling alloc_pages() might do?

It's not a memory buffer, it's MMIO space (device memory, off your PCI
bus for example).

> Adam Litke at one point posted a pagetable-abstraction that would have
> been the first step on a path like this. It hurt the normal fastpath
> though and was ultimately put aside.

Which is why I think we should stick to just splitting hugetlb which
will not affect the normal path at all. Normal path for normal page,
HUGETLB VMAs for other sizes, whether they are backed with memory or by
anything else.

> It's the sort of thing that has been resisted in the past, largely
> because the only user at the time was about transparent hugepage
> promotion/demotion. It would need to be a really strong incentive to
> revive the effort.

Why ? I'm not proposing to hack the normal path. Just splitting
hugetlbfs in two which is reasonably easy to do, to allow drivers who
map large chunks of MMIO space to use larger page sizes.

This is the case of pretty much any discrete video card, a chunk of
RDMA-style devices, and possibly more.

It's a reasonably simple change that has 0 effect on the non-hugetlb
path. I think I'll just have to bite the bullet and send a demo patch
when I'm no longer bogged down :-)

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
