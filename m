Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 041B46B0169
	for <linux-mm@kvack.org>; Tue, 16 Aug 2011 09:29:40 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 7/9] ARM: DMA: steal memory for DMA coherent mappings
Date: Tue, 16 Aug 2011 15:28:48 +0200
References: <1313146711-1767-1-git-send-email-m.szyprowski@samsung.com> <201108121453.05898.arnd@arndb.de> <20110814075205.GA4986@n2100.arm.linux.org.uk>
In-Reply-To: <20110814075205.GA4986@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201108161528.48954.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>

On Sunday 14 August 2011, Russell King - ARM Linux wrote:
> On Fri, Aug 12, 2011 at 02:53:05PM +0200, Arnd Bergmann wrote:
> > 
> > I thought that our discussion ended with the plan to use this only
> > for ARMv6+ (which has a problem with double mapping) but not on ARMv5
> > and below (which don't have this problem but might need dmabounce).
> 
> I thought we'd decided to have a pool of available CMA memory on ARMv6K
> to satisfy atomic allocations, which can grow and shrink in size, rather
> than setting aside a fixed amount of contiguous system memory.

Hmm, I don't remember the point about dynamically sizing the pool for
ARMv6K, but that can well be an oversight on my part.  I do remember the
part about taking that memory pool from the CMA region as you say.

> ARMv6 and ARMv7+ could use CMA directly, and <= ARMv5 can use the existing
> allocation method.
> 
> Has something changed?

Nothing has changed regarding <=ARMv5. There was a small side discussion
about ARMv6 and ARMv7+ based on the idea that they can either use CMA
directly (doing TLB flushes for every allocation) or they could use the
same method as ARMv6K by setting aside a pool of pages for atomic
allocation. The first approach would consume less memory because it
requires no special pool, the second approach would be simpler because
it unifies the ARMv6K and ARMv6/ARMv7+ cases and also would be slightly
more efficient for atomic allocations because it avoids the expensive
TLB flush.

I didn't have a strong opinion either way, so IIRC Marek said he'd try
out both approaches and then send out the one that looked better, leaning
towards the second for simplicity of having fewer compile-time options.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
