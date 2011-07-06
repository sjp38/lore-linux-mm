Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 243039000C2
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 10:52:44 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 6/8] drivers: add Contiguous Memory Allocator
Date: Wed, 6 Jul 2011 16:51:49 +0200
References: <1309851710-3828-1-git-send-email-m.szyprowski@samsung.com> <201107061609.29996.arnd@arndb.de> <20110706142345.GC8286@n2100.arm.linux.org.uk>
In-Reply-To: <20110706142345.GC8286@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201107061651.49824.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'Mel Gorman' <mel@csn.ul.ie>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Jesse Barker' <jesse.barker@linaro.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, 'Michal Nazarewicz' <mina86@mina86.com>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-media@vger.kernel.org

On Wednesday 06 July 2011, Russell King - ARM Linux wrote:
> On Wed, Jul 06, 2011 at 04:09:29PM +0200, Arnd Bergmann wrote:
> > Maybe you can simply adapt the default location of the contiguous memory
> > are like this:
> > - make CONFIG_CMA depend on CONFIG_HIGHMEM on ARM, at compile time
> > - if ZONE_HIGHMEM exist during boot, put the CMA area in there
> > - otherwise, put the CMA area at the top end of lowmem, and change
> >   the zone sizes so ZONE_HIGHMEM stretches over all of the CMA memory.
> 
> One of the requirements of the allocator is that the returned memory
> should be zero'd (because it can be exposed to userspace via ALSA
> and frame buffers.)
> 
> Zeroing the memory from all the contexts which dma_alloc_coherent
> is called from is a trivial matter if its in lowmem, but highmem is
> harder.

I don't see how. The pages get allocated from an unmapped area
or memory, mapped into the kernel address space as uncached or wc
and then cleared. This should be the same for lowmem or highmem
pages.

What am I missing?

> Another issue is that when a platform has restricted DMA regions,
> they typically don't fall into the highmem zone.  As the dmabounce
> code allocates from the DMA coherent allocator to provide it with
> guaranteed DMA-able memory, that would be rather inconvenient.

True. The dmabounce code would consequently have to allocate
the memory through an internal function that avoids the
contiguous allocation area and goes straight to ZONE_DMA memory
as it does today.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
