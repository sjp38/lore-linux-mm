From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC v2] arm:extend the reserved mrmory for initrd to be page
 aligned
Date: Fri, 5 Dec 2014 17:27:02 +0000
Message-ID: <20141205172701.GW11285@n2100.arm.linux.org.uk>
References: <35FD53F367049845BC99AC72306C23D103D6DB491609@CNBJMBX05.corpusers.net>
 <20140915113325.GD12361@n2100.arm.linux.org.uk>
 <20141204120305.GC17783@e104818-lin.cambridge.arm.com>
 <20141205120506.GH1630@arm.com>
 <20141205170745.GA31222@e104818-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141205170745.GA31222@e104818-lin.cambridge.arm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, "Wang, Yalin" <Yalin.Wang@sonymobile.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'linux-arm-msm@vger.kernel.org'" <linux-arm-msm@vger.kernel.org>, Peter Maydell <Peter.Maydell@arm.com>
List-Id: linux-mm.kvack.org

On Fri, Dec 05, 2014 at 05:07:45PM +0000, Catalin Marinas wrote:
> On Fri, Dec 05, 2014 at 12:05:06PM +0000, Will Deacon wrote:
> > Care to submit this as a proper patch? We should at least fix Peter's issue
> > before doing things like extending headers, which won't work for older
> > kernels anyway.
> 
> Quick fix is the revert of the whole patch, together with removing
> PAGE_ALIGN(end) in poison_init_mem() on arm32. If Russell is ok with
> this patch, we can take it via the arm64 tree, otherwise I'll send you a
> partial revert only for the arm64 part.

Not really.  Let's look at the history.

For years, we've been poisoning memory, page aligning the end pointer.
This has never been an issue.

However, patch 8167/1 changed things so we freed the overlapping pages.
Since we've always poisoned up to the end of the final page, freeing it
should not be a problem, especially as (I said above) we've been poisoning
it for years.

The issue is more about what happens at the start.

In any case:

> >From 8e317c6be00abe280de4dcdd598d2e92009174b6 Mon Sep 17 00:00:00 2001
> From: Catalin Marinas <catalin.marinas@arm.com>
> Date: Fri, 5 Dec 2014 16:41:52 +0000
> Subject: [PATCH] Revert "ARM: 8167/1: extend the reserved memory for initrd to
>  be page aligned"
> 
> This reverts commit 421520ba98290a73b35b7644e877a48f18e06004. There is
> no guarantee that the boot-loader places other images like dtb in a
> different page than initrd start/end. When this happens, such pages must
> not be freed. The free_reserved_area() already takes care of rounding up
> "start" and rounding down "end" to avoid freeing partially used pages.
> 
> In addition to the revert, this patch also removes the arm32
> PAGE_ALIGN(end) when calculating the size of the memory to be poisoned.

which makes the summary line rather misleading, and I really don't think
we need to do this on ARM for the simple reason that we've been doing it
for soo long that it can't be an issue.

-- 
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.
