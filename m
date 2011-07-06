Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0761A9000C2
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 10:56:31 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from eu_spt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LNX001UB2U4CK90@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 06 Jul 2011 15:56:28 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LNX000YI2U3Y5@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 06 Jul 2011 15:56:27 +0100 (BST)
Date: Wed, 06 Jul 2011 16:56:23 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 6/8] drivers: add Contiguous Memory Allocator
In-reply-to: <201107061609.29996.arnd@arndb.de>
Message-id: <007101cc3bec$dfbba8c0$9f32fa40$%szyprowski@samsung.com>
Content-language: pl
References: <1309851710-3828-1-git-send-email-m.szyprowski@samsung.com>
 <20110705113345.GA8286@n2100.arm.linux.org.uk>
 <006301cc3be4$daab1850$900148f0$%szyprowski@samsung.com>
 <201107061609.29996.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Arnd Bergmann' <arnd@arndb.de>
Cc: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Daniel Walker' <dwalker@codeaurora.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'Mel Gorman' <mel@csn.ul.ie>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Michal Nazarewicz' <mina86@mina86.com>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>

Hello,

On Wednesday, July 06, 2011 4:09 PM Arnd Bergmann wrote:

> On Wednesday 06 July 2011, Marek Szyprowski wrote:
> > The only problem that might need to be resolved is GFP_ATOMIC allocation
> > (updating page properties probably requires some locking), but it can be
> > served from a special area which is created on boot without low-memory
> > mapping at all. None sane driver will call dma_alloc_coherent(GFP_ATOMIC)
> > for large buffers anyway.
> 
> Would it be easier to start with a version that only allocated from memory
> without a low-memory mapping at first?
>
> This would be similar to the approach that Russell's fix for the regular
> dma_alloc_coherent has taken, except that you need to also allow the memory
> to be used as highmem user pages.
> 
> Maybe you can simply adapt the default location of the contiguous memory
> are like this:
> - make CONFIG_CMA depend on CONFIG_HIGHMEM on ARM, at compile time
> - if ZONE_HIGHMEM exist during boot, put the CMA area in there
> - otherwise, put the CMA area at the top end of lowmem, and change
>   the zone sizes so ZONE_HIGHMEM stretches over all of the CMA memory.

This will not solve our problems. We need CMA also to create at least one
device private area that for sure will be in low memory (video codec).

I will rewrite ARM dma-mapping & CMA integration patch basing on the latest 
ARM for-next patches and add proof-of-concept of the solution presented in my
previous mail (2-level page tables and unmapping pages from low-mem).

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
