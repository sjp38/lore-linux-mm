Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9A0C29000C2
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 09:59:07 -0400 (EDT)
Received: from spt2.w1.samsung.com (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LNX000P006GZW@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 06 Jul 2011 14:59:04 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LNX00DUG06E5W@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 06 Jul 2011 14:59:03 +0100 (BST)
Date: Wed, 06 Jul 2011 15:58:58 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 6/8] drivers: add Contiguous Memory Allocator
In-reply-to: <20110705113345.GA8286@n2100.arm.linux.org.uk>
Message-id: <006301cc3be4$daab1850$900148f0$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1309851710-3828-1-git-send-email-m.szyprowski@samsung.com>
 <1309851710-3828-7-git-send-email-m.szyprowski@samsung.com>
 <20110705113345.GA8286@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Daniel Walker' <dwalker@codeaurora.org>, 'Arnd Bergmann' <arnd@arndb.de>, 'Jonathan Corbet' <corbet@lwn.net>, 'Mel Gorman' <mel@csn.ul.ie>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Michal Nazarewicz' <mina86@mina86.com>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>

Hello,

On Tuesday, July 05, 2011 1:34 PM Russell King - ARM Linux wrote:

> On Tue, Jul 05, 2011 at 09:41:48AM +0200, Marek Szyprowski wrote:
> > The Contiguous Memory Allocator is a set of helper functions for DMA
> > mapping framework that improves allocations of contiguous memory chunks.
> >
> > CMA grabs memory on system boot, marks it with CMA_MIGRATE_TYPE and
> > gives back to the system. Kernel is allowed to allocate movable pages
> > within CMA's managed memory so that it can be used for example for page
> > cache when DMA mapping do not use it. On dma_alloc_from_contiguous()
> > request such pages are migrated out of CMA area to free required
> > contiguous block and fulfill the request. This allows to allocate large
> > contiguous chunks of memory at any time assuming that there is enough
> > free memory available in the system.
> >
> > This code is heavily based on earlier works by Michal Nazarewicz.
> 
> And how are you addressing the technical concerns about aliasing of
> cache attributes which I keep bringing up with this and you keep
> ignoring and telling me that I'm standing in your way.

I'm perfectly aware of the issues with aliasing of cache attributes.

My idea is to change low memory linear mapping for all CMA areas on boot
time to use 2 level page tables (4KiB mappings instead of super-section
mappings). This way the page properties for a single page in CMA area can
be changed/updated at any time to match required coherent/writecombine
attributes. Linear mapping can be even removed completely if we want to 
create the it elsewhere in the address space. 

The only problem that might need to be resolved is GFP_ATOMIC allocation
(updating page properties probably requires some locking), but it can be
served from a special area which is created on boot without low-memory
mapping at all. None sane driver will call dma_alloc_coherent(GFP_ATOMIC)
for large buffers anyway.

CMA limits the memory area from which coherent pages are being taken quite
well, so the change in the linear mapping method should have no significant
impact on the system performance.

I didn't implement such solution yet, because it is really hard to handle
all issues at the same time and creating the allocator was just a first
step.

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
