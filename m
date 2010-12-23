Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 97E526B0087
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 08:45:42 -0500 (EST)
Date: Thu, 23 Dec 2010 13:44:32 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCHv8 00/12] Contiguous Memory Allocator
Message-ID: <20101223134432.GJ3636@n2100.arm.linux.org.uk>
References: <cover.1292443200.git.m.nazarewicz@samsung.com> <AANLkTim8_=0+-zM5z4j0gBaw3PF3zgpXQNetEn-CfUGb@mail.gmail.com> <20101223100642.GD3636@n2100.arm.linux.org.uk> <00ea01cba290$4d67f500$e837df00$%szyprowski@samsung.com> <20101223121917.GG3636@n2100.arm.linux.org.uk> <00ec01cba2a2$af20b8b0$0d622a10$%szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00ec01cba2a2$af20b8b0$0d622a10$%szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: 'Kyungmin Park' <kmpark@infradead.org>, 'Michal Nazarewicz' <m.nazarewicz@samsung.com>, linux-arm-kernel@lists.infradead.org, 'Daniel Walker' <dwalker@codeaurora.org>, 'Johan MOSSBERG' <johan.xx.mossberg@stericsson.com>, 'Mel Gorman' <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, 'Michal Nazarewicz' <mina86@mina86.com>, linux-mm@kvack.org, 'Ankita Garg' <ankita@in.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-media@vger.kernel.org, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 23, 2010 at 02:09:44PM +0100, Marek Szyprowski wrote:
> Hello,
> 
> On Thursday, December 23, 2010 1:19 PM Russell King - ARM Linux wrote:
> 
> > On Thu, Dec 23, 2010 at 11:58:08AM +0100, Marek Szyprowski wrote:
> > > Actually this contiguous memory allocator is a better replacement for
> > > alloc_pages() which is used by dma_alloc_coherent(). It is a generic
> > > framework that is not tied only to ARM architecture.
> > 
> > ... which is open to abuse.  What I'm trying to find out is - if it
> > can't be used for DMA, what is it to be used for?
> > 
> > Or are we inventing an everything-but-ARM framework?
> 
> We are trying to get something that really works and SOLVES some of the
> problems with real devices that require contiguous memory for DMA.

So, here you've confirmed that it's for DMA.

> > > > In other words, do we _actually_ have a use for this which doesn't
> > > > involve doing something like allocating 32MB of memory from it,
> > > > remapping it so that it's DMA coherent, and then performing DMA
> > > > on the resulting buffer?
> > >
> > > This is an arm specific problem, also related to dma_alloc_coherent()
> > > allocator. To be 100% conformant with ARM specification we would
> > > probably need to unmap all pages used by the dma_coherent allocator
> > > from the LOW MEM area. This is doable, but completely not related
> > > to the CMA and this patch series.
> > 
> > You've already been told why we can't unmap pages from the kernel
> > direct mapping.
> 
> It requires some amount of work but I see no reason why we shouldn't be
> able to unmap that pages to stay 100% conformant with ARM spec.

I have considered - and tried - to do that with the dma_alloc_coherent()
spec, but it is NOT POSSIBLE to do so - too many factors stand in the
way of making it work, such as the need bring the system to a complete
halt to modify all the L1 page tables and broadcast the TLB operations
to invalidate the old mappings.  None of that can be done from all the
contexts under which dma_alloc_coherent() is called from.

> Please notice that there are also use cases where the memory will not be
> accessed by the CPU at all (like DMA transfers between multimedia devices
> and the system memory).

Rubbish - if you think that, then you have very little understanding of
modern CPUs.  Modern CPUs speculatively access _any_ memory which is
visible to them, and as the ARM architecture progresses, the speculative
prefetching will become more aggressive.  So if you have memory mapped
in the kernel direct map, then you _have_ to assume that the CPU will
fire off accesses to that memory at any time, loading it into its cache.

> > Okay, so I'm just going to assume that CMA has _no_ _business_ being
> > used on ARM, and is not something that should interest anyone in the
> > ARM community.
> 
> Go ahead! Remeber to remove dma_coherent because it also breaks the spec. :)
> Oh, I forgot. We can also remove all device drivers that might use DMA. :)

The only solution I've come up for dma_alloc_coherent() is to reserve
the entire coherent DMA region at boot time, taking it out of the
kernel's view of available memory and thereby preventing it from ever
being mapped or the kernel using that memory for any other purpose.
That's about the best we can realistically do for ARM to conform to the
spec.

Every time I've brought this issue up with you, you've brushed it aside.
So if you feel that the right thing to do is to ignore such issues, you
won't be surprised if I keep opposing your efforts to get this into
mainline.

If you're serious about making this work, then provide some proper code
which shows how to use this for DMA on ARM systems without violating
the architecture specification.  Until you do, I see no hope that CMA
will ever be suitable for use on ARM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
