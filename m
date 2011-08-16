Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DBC1F6B0169
	for <linux-mm@kvack.org>; Tue, 16 Aug 2011 09:55:53 -0400 (EDT)
Date: Tue, 16 Aug 2011 14:55:16 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 7/9] ARM: DMA: steal memory for DMA coherent mappings
Message-ID: <20110816135516.GC17310@n2100.arm.linux.org.uk>
References: <1313146711-1767-1-git-send-email-m.szyprowski@samsung.com> <201108121453.05898.arnd@arndb.de> <20110814075205.GA4986@n2100.arm.linux.org.uk> <201108161528.48954.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201108161528.48954.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>

On Tue, Aug 16, 2011 at 03:28:48PM +0200, Arnd Bergmann wrote:
> On Sunday 14 August 2011, Russell King - ARM Linux wrote:
> > On Fri, Aug 12, 2011 at 02:53:05PM +0200, Arnd Bergmann wrote:
> > > 
> > > I thought that our discussion ended with the plan to use this only
> > > for ARMv6+ (which has a problem with double mapping) but not on ARMv5
> > > and below (which don't have this problem but might need dmabounce).
> > 
> > I thought we'd decided to have a pool of available CMA memory on ARMv6K
> > to satisfy atomic allocations, which can grow and shrink in size, rather
> > than setting aside a fixed amount of contiguous system memory.
> 
> Hmm, I don't remember the point about dynamically sizing the pool for
> ARMv6K, but that can well be an oversight on my part.  I do remember the
> part about taking that memory pool from the CMA region as you say.

If you're setting aside a pool of pages, then you have to dynamically
size it.  I did mention during our discussion about this.

The problem is that a pool of fixed size is two fold: you need it to be
sufficiently large that it can satisfy all allocations which come along
in atomic context.  Yet, we don't want the pool to be too large because
then it prevents the memory being used for other purposes.

Basically, the total number of pages in the pool can be a fixed size,
but as they are depleted through allocation, they need to be
re-populated from CMA to re-build the reserve for future atomic
allocations.  If the pool becomes larger via frees, then obviously
we need to give pages back.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
