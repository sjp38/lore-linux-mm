Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4144E6B004A
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 12:17:36 -0400 (EDT)
Date: Tue, 21 Sep 2010 12:13:36 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [RFCv5 7/9] mm: vcm: Virtual Contiguous Memory framework added
Message-ID: <20100921161336.GA21173@dumpdata.com>
References: <cover.1283749231.git.mina86@mina86.com>
 <528bda37c43c55cde9f89d56882cea2113d8d7d4.1283749231.git.mina86@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <528bda37c43c55cde9f89d56882cea2113d8d7d4.1283749231.git.mina86@mina86.com>
Sender: owner-linux-mm@kvack.org
To: Michal Nazarewicz <m.nazarewicz@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Jonathan Corbet <corbet@lwn.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Pawel Osciak <p.osciak@samsung.com>, Peter Zijlstra <peterz@infradead.org>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> +* The Virtual Contiguous Memory Manager
> +
> +The VCMM was built to solve the system-wide memory mapping issues that
> +occur when many bus-masters have IOMMUs.
> +
> +An IOMMU maps device addresses to physical addresses.  It also
> +insulates the system from spurious or malicious device bus
> +transactions and allows fine-grained mapping attribute control.  The
> +Linux kernel core does not contain a generic API to handle IOMMU
> +mapped memory; device driver writers must implement device specific
> +code to interoperate with the Linux kernel core.  As the number of
> +IOMMUs increases, coordinating the many address spaces mapped by all
> +discrete IOMMUs becomes difficult without in-kernel support.

Looking at the set of calls and the examples it struck me as similar
to the agp.h API (drivers/char/agp/). It has allocate, bind, de-allocate.
Naturally it has no bus device mapping, but the DRM code that utilizes
the AGP API bridge has that: drivers/gpu/drm/ati_pcigart.c (DRM API).

Then there are the radeon and nouveau drivers that program the GPU GART
bypassing the AGP API but still utilize the DMA API.

The nice ASCII art you included in your writeup looks to cover those
use cases.

What I am ineptly trying to say is that is that we have a bunch
of APIs that do this, and in case where they are inadequate (or just
look to be a one-off solution) we have functions that are similar in API
view but differ in implementation (check out how the Nouveau programs
its VMM compared to how the Radeon does it).

Your API offers a way to unify all of that, but it looks to be
an API on top of the other ones. You would still have to implement
different mechanisms for the utilizing this say on the radeon driver:
AGP API, or the home-grown GPU GART programming, and then the DMA API
wrapped around them all. Oh, and the DMA API sits on top of the IOMMU API.

I am not sure how this would solve the proliferation of different APIs
- it sounds like it just adds another piece where you still have to
shoe-in the other APIs in.

But I do understand the problem you are facing. You want to switch
to different IOMMUs for different drivers using only one API. Folks have
been asking about whether it makes sense to include your algorithms in
expanding the memory allocator to have huge chunks of memory reserved
for specific drivers. But that does not solve the IOMMU problem.

So my question is, would it perhaps make sense to concentrate on the DMA API?
Could we expand it so that for specific devices it sets the DMA API
to use a different IOMMU? If you look at the Calgary IOMMU - that is a perfect
example of your problem  - it is only used if the specific devices which fall
within its control - all other DMA operations are utilized by the SWIOTLB
(the default IOMMU).

Would it possible to do something similar to that so when CMA is activated
it scans the region list, finds which devices can share the same memory region
and sets the struct device DMA API to point to a CMA IOMMU which is happy
to utilize the memory allocator reserved chunks of memory (that would
be the code lifted from your CMA and stuck in the memory allocate)
and allowing different drivers (those on the whitelist) to share the same region?

This has the extra benefit that it would inclusive allow all drivers
that utilize the DMA API to use this without any extra VCMA/CMA API calls?

P.S.
I am quite X86 specific here - I don't know much about ARM (is there some
desktop box I can buy with it?), so I am probably missing some details.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
