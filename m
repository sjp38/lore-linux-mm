Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B0D51900134
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 09:58:56 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 6/8] drivers: add Contiguous Memory Allocator
Date: Tue, 5 Jul 2011 15:58:39 +0200
References: <1309851710-3828-1-git-send-email-m.szyprowski@samsung.com> <201107051427.44899.arnd@arndb.de> <20110705123035.GD8286@n2100.arm.linux.org.uk>
In-Reply-To: <20110705123035.GD8286@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201107051558.39344.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Daniel Walker <dwalker@codeaurora.org>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Chunsang Jeong <chunsang.jeong@linaro.org>, Jesse Barker <jesse.barker@linaro.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Michal Nazarewicz <mina86@mina86.com>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Ankita Garg <ankita@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-media@vger.kernel.org

On Tuesday 05 July 2011, Russell King - ARM Linux wrote:
> On Tue, Jul 05, 2011 at 02:27:44PM +0200, Arnd Bergmann wrote:
> > It's also a preexisting problem as far as I can tell, and it needs
> > to be solved in __dma_alloc for both cases, dma_alloc_from_contiguous
> > and __alloc_system_pages as introduced in patch 7.
> 
> Which is now resolved in linux-next, and has been through this cycle
> as previously discussed.
> 
> It's taken some time because the guy who tested the patch for me said
> he'd review other platforms but never did, so I've just about given up
> waiting and stuffed it in ready for the 3.1 merge window irrespective
> of anything else.

Ah, sorry I missed that patch on the mailing list, found it now in
your for-next branch.

If I'm reading your "ARM: DMA: steal memory for DMA coherent mappings"
correctly, the idea is to have a per-platform compile-time amount
of memory that is reserved purely for coherent allocations and
taking out of the buddy allocator, right?

As you say, this solves the problem for the non-CMA case, and does
not apply to CMA because the entire point of CMA is not to remove
the pages from the buddy allocator in order to preserve memory.

So with your patch getting merged, patch 7/8 obviously has both a
conflict and introduces a regression against the fix you did.
Consequently that patch needs to be redone in a way that fits on
top of your patch and avoids the double-mapping problem.

What about the rest? As I mentioned in private, adding invasive features
to core code is obviously not nice if it can be avoided, but my feeling
is that we can no longer claim that there is no need for this with so
much hardware relying on large contiguous memory ranges for DMA.
The patches have come a long way since the first version, especially
regarding the device driver interface and I think they are about as
good as it gets in that regard.

I do understand that without patch 7, there isn't a single architecture
using the feature, which is somewhat silly, but I'm also convinced
that other architectures will start using it, and that a solution for the
double mapping in the ways I mentioned in my previous mail is going
to happen. Probably not in 3.1 then, but we could put the patches into
-mm anyway until we get there.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
