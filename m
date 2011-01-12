Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3ED876B0092
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 14:00:08 -0500 (EST)
Received: from epmmp2 (mailout1.samsung.com [203.254.224.24])
 by mailout1.samsung.com
 (Oracle Communications Messaging Exchange Server 7u4-19.01 64bit (built Sep  7
 2010)) with ESMTP id <0LEX00KH6AZGGZ10@mailout1.samsung.com> for
 linux-mm@kvack.org; Thu, 13 Jan 2011 03:50:05 +0900 (KST)
Received: from AMDC159 ([106.116.37.153])
 by mmp2.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTPA id <0LEX00912AZAPP@mmp2.samsung.com> for linux-mm@kvack.org; Thu,
 13 Jan 2011 03:50:05 +0900 (KST)
Date: Wed, 12 Jan 2011 19:49:56 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv8 00/12] Contiguous Memory Allocator
In-reply-to: <20101223134432.GJ3636@n2100.arm.linux.org.uk>
Message-id: <001c01cbb289$864391f0$92cab5d0$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <cover.1292443200.git.m.nazarewicz@samsung.com>
 <AANLkTim8_=0+-zM5z4j0gBaw3PF3zgpXQNetEn-CfUGb@mail.gmail.com>
 <20101223100642.GD3636@n2100.arm.linux.org.uk>
 <00ea01cba290$4d67f500$e837df00$%szyprowski@samsung.com>
 <20101223121917.GG3636@n2100.arm.linux.org.uk>
 <00ec01cba2a2$af20b8b0$0d622a10$%szyprowski@samsung.com>
 <20101223134432.GJ3636@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
To: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>
Cc: 'Kyungmin Park' <kmpark@infradead.org>, 'Michal Nazarewicz' <m.nazarewicz@samsung.com>, linux-arm-kernel@lists.infradead.org, 'Daniel Walker' <dwalker@codeaurora.org>, 'Johan MOSSBERG' <johan.xx.mossberg@stericsson.com>, 'Mel Gorman' <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, 'Michal Nazarewicz' <mina86@mina86.com>, linux-mm@kvack.org, 'Ankita Garg' <ankita@in.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-media@vger.kernel.org, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>
List-ID: <linux-mm.kvack.org>

Hello,

I'm sorry for the delay. Just got back from my holidays and getting thought
the mails.

On Thursday, December 23, 2010 2:45 PM Russell King - ARM Linux wrote:

> On Thu, Dec 23, 2010 at 02:09:44PM +0100, Marek Szyprowski wrote:
> > Hello,
> >
> > On Thursday, December 23, 2010 1:19 PM Russell King - ARM Linux wrote:
> >
> > > On Thu, Dec 23, 2010 at 11:58:08AM +0100, Marek Szyprowski wrote:
> > > > Actually this contiguous memory allocator is a better replacement for
> > > > alloc_pages() which is used by dma_alloc_coherent(). It is a generic
> > > > framework that is not tied only to ARM architecture.
> > >
> > > ... which is open to abuse.  What I'm trying to find out is - if it
> > > can't be used for DMA, what is it to be used for?
> > >
> > > Or are we inventing an everything-but-ARM framework?
> >
> > We are trying to get something that really works and SOLVES some of the
> > problems with real devices that require contiguous memory for DMA.
> 
> So, here you've confirmed that it's for DMA.

Right, otherwise it wouldn't really make much sense. Note that our proposal
already works for non-arm platforms. 

> > > > > In other words, do we _actually_ have a use for this which doesn't
> > > > > involve doing something like allocating 32MB of memory from it,
> > > > > remapping it so that it's DMA coherent, and then performing DMA
> > > > > on the resulting buffer?
> > > >
> > > > This is an arm specific problem, also related to dma_alloc_coherent()
> > > > allocator. To be 100% conformant with ARM specification we would
> > > > probably need to unmap all pages used by the dma_coherent allocator
> > > > from the LOW MEM area. This is doable, but completely not related
> > > > to the CMA and this patch series.
> > >
> > > You've already been told why we can't unmap pages from the kernel
> > > direct mapping.
> >
> > It requires some amount of work but I see no reason why we shouldn't be
> > able to unmap that pages to stay 100% conformant with ARM spec.
> 
> I have considered - and tried - to do that with the dma_alloc_coherent()
> spec, but it is NOT POSSIBLE to do so - too many factors stand in the
> way of making it work, such as the need bring the system to a complete
> halt to modify all the L1 page tables and broadcast the TLB operations
> to invalidate the old mappings.  None of that can be done from all the
> contexts under which dma_alloc_coherent() is called from.

I understand that this requires a lot of work, but I still think this might
be possible to get it working with some additional constraints.

I understand that modifying L1 page tables is definitely not a proper way of
handling this. It simply costs too much. But what if we consider that the DMA
memory can be only allocated from a specific range of the system memory?
Assuming that this range of memory is known during the boot time, it CAN be
mapped with two-level of tables in MMU. First level mapping will stay the
same all the time for all processes, but it would be possible to unmap the
pages required for DMA from the second level mapping what will be visible
from all the processes at once.

Is there any reason why such solution won't work?

Best regards
--
Marek Szyprowski
Samsung Poland R&D Center



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
