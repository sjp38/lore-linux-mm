Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1A6EE6B0169
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 04:02:00 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from spt2.w1.samsung.com ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LQ200KQSBN9Z020@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 17 Aug 2011 09:01:57 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LQ20052WBN82K@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 17 Aug 2011 09:01:56 +0100 (BST)
Date: Wed, 17 Aug 2011 10:01:22 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 7/9] ARM: DMA: steal memory for DMA coherent mappings
In-reply-to: <201108161626.26130.arnd@arndb.de>
Message-id: <006b01cc5cb3$dac09fa0$9041dee0$%szyprowski@samsung.com>
Content-language: pl
References: <1313146711-1767-1-git-send-email-m.szyprowski@samsung.com>
 <201108161528.48954.arnd@arndb.de>
 <20110816135516.GC17310@n2100.arm.linux.org.uk>
 <201108161626.26130.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Arnd Bergmann' <arnd@arndb.de>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Michal Nazarewicz' <mina86@mina86.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Marek Szyprowski' <m.szyprowski@samsung.com>

Hello,

On Tuesday, August 16, 2011 4:26 PM Arnd Bergmann wrote:
> On Tuesday 16 August 2011, Russell King - ARM Linux wrote:
> > On Tue, Aug 16, 2011 at 03:28:48PM +0200, Arnd Bergmann wrote:
> > > Hmm, I don't remember the point about dynamically sizing the pool for
> > > ARMv6K, but that can well be an oversight on my part.  I do remember the
> > > part about taking that memory pool from the CMA region as you say.
> >
> > If you're setting aside a pool of pages, then you have to dynamically
> > size it.  I did mention during our discussion about this.
> >
> > The problem is that a pool of fixed size is two fold: you need it to be
> > sufficiently large that it can satisfy all allocations which come along
> > in atomic context.  Yet, we don't want the pool to be too large because
> > then it prevents the memory being used for other purposes.
> >
> > Basically, the total number of pages in the pool can be a fixed size,
> > but as they are depleted through allocation, they need to be
> > re-populated from CMA to re-build the reserve for future atomic
> > allocations.  If the pool becomes larger via frees, then obviously
> > we need to give pages back.
> 
> Ok, thanks for the reminder. I must have completely missed this part
> of the discussion.
> 
> When I briefly considered this problem, my own conclusion was that
> the number of atomic DMA allocations would always be very low
> because they tend to be short-lived (e.g. incoming network packets),
> so we could ignore this problem and just use a smaller reservation
> size. While this seems to be true in general (see "git grep -w -A3
> dma_alloc_coherent | grep ATOMIC"), there is one very significant
> case that we cannot ignore, which is pci_alloc_consistent.
> 
> This function is still called by hundreds of PCI drivers and always
> does dma_alloc_coherent(..., GFP_ATOMIC), even for long-lived
> allocations and those that are too large to be ignored.
> 
> So at least for the case where we have PCI devices, I agree that
> we need to have the dynamic pool.

Do we really need the dynamic pool for the first version? I would like to
know how much memory can be allocated in GFP_ATOMIC context. What are the
typical sizes of such allocations?

Maybe for the first version a static pool with reasonably small size
(like 128KiB) will be more than enough? This size can be even board
depended or changed with kernel command line for systems that really
needs more memory.

I noticed one more problem. The size of the CMA managed area must be
the multiple of 16MiBs (MAX_ORDER+1). This means that the smallest CMA area
is 16MiB. These values comes from the internals of the kernel memory 
management design and page blocks are the only entities that can be managed
with page migration code.

I'm not sure if all ARMv6+ boards have at least 32MiB of memory be able to
create a CMA area.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
