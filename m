Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 227656B004D
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 08:13:54 -0500 (EST)
Date: Tue, 2 Feb 2010 14:13:41 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFP-V2 0/3] Make mmu_notifier_invalidate_range_start able to
 sleep.
Message-ID: <20100202131341.GI4135@random.random>
References: <20100202040145.555474000@alcatraz.americas.sgi.com>
 <20100202080947.GA28736@infradead.org>
 <20100202125943.GH4135@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100202125943.GH4135@random.random>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Robin Holt <holt@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 02, 2010 at 01:59:43PM +0100, Andrea Arcangeli wrote:
> slowdown the locking even if it leaves holes and corrupts memory when
> XPMEM can be opened by luser. It really depends if the user having
> access to XPMEM device is malicious, if we know it's not (assume
> avatar distributed rendering in closed environment or whatever) this
> again is an ok hack.

>From another point of view: if the userland has to be as trusted as
the kernel for this hack to be ok, I don't get it why it's not ok to
just schedule unconditionally in the invalidate_range_start without
altering the API and gracefully deadlock in the i_mmap_lock. If the
secondary mappings cannot be teardown without scheduling, it means the
page will be swapped out but the physical pages can be still written
to despite the page being swapped out and reused by something else
leading to trivial memory corruption if the user having access to
xpmem device is malicious.

Like Andrew already said, we've no clue what the "bool atomic"
parameter will be used for and so it's next to impossible to judge the
validity of this hack (because an hack that is). We don't know how
xpmem will react to that event, all we know is that it won't be able
to invalidate secondary mappings by the time this call returns leading
to memory corruption. If it panics or if it ignores the invalidate
when atomic=1, it's equivalent or worse than just schedule in
atomic. If it schedule in atomic there's zero risk of memory
corruption at least and no need of altering the API. So even for
distro this hack to the API isn't necessary but only srcu and tlb
flush deferral is needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
