Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 891226B002D
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 05:30:18 -0500 (EST)
Date: Tue, 15 Nov 2011 10:30:07 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
Message-ID: <20111115103007.GB27150@suse.de>
References: <20111114140421.GA27150@suse.de>
 <20111114183812.GC4414@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20111114183812.GC4414@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Colin Cross <ccross@android.com>, Pekka Enberg <penberg@cs.helsinki.fi>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon, Nov 14, 2011 at 07:38:12PM +0100, Andrea Arcangeli wrote:
> On Mon, Nov 14, 2011 at 02:04:21PM +0000, Mel Gorman wrote:
> > In his fix, he avoided retrying the allocation if reclaim made no
> > progress and __GFP_FS was not set. The problem is that this would
> > result in GFP_NOIO allocations failing that previously succeeded
> > which would be very unfortunate.
> 
> GFP_NOFS are made by filesystems/buffers to avoid locking up on fs/vfs
> locking. Those also should be able to handle failure gracefully but
> userland is more likely to get a -ENOMEM from these (for example
> during direct-io) if those fs allocs fails.

I was also vaguely recalling Roland's talk at day 2 of kernel summit
(reported at http://lwn.net/Articles/464500/) where he talked about
error handling. One point he made was that some filesystems ran into
problems in the event of memory allocation failure. I didn't audit
if the block layer handles it better but one way or the other I did
not want to throw the the block or filesystem layers curve balls.

> So clearly it sounds risky
> to apply the modification quoted above and risk having any GFP_NOFS
> fail. Said that I'm afraid we're not deadlock safe with current code
> that cannot fail but there's no easy solution and no way to fix it in
> the short term, and it's only a theoretical concern.

It's still a valid concern. The expectation is that we are protected
from deadlocks a combination of mempools and the watermarks forcing
processes to stall in direct reclaim leaving a cushion of pages for
reclaim using PF_MEMALLOC to always make forward progress. Patches
that break how watermarks work tend to lead to deadlock.

> For !__GFP_FS allocations, __GFP_NOFAIL is the default for order <=
> PAGE_ALLOC_COSTLY_ORDER and __GFP_NORETRY is the default for order >
> PAGE_ALLOC_COSTLY_ORDER. This inconsistency is not so clean in my
> view.

Is your concern that the behaviour of the allocator changes quite
significantly for orders < PAGE_ALLOC_COSTLY_ORDER?

I agree with you that it would be nicer if there was a gradual scaling
back of how much work the allocator did that depended on order. To
date there has not been much pressure or motivation to implement it.

> Also for GFP_KERNEL/USER/__GFP_FS regular allocations the
> __GFP_NOFAIL looks more like a __GFP_MAY_OOM.  But if we fix that and
> we drop __GFP_NORETRY, and we set __GFP_NOFAIL within the
> GFP_NOFS/NOIO #defines (to remove the magic PAGE_ALLOC_COSTLY_ORDER
> check in should_alloc_retry) we may loop forever if somebody allocates
> several mbytes of huge contiguous RAM with GFP_NOIO. So at least
> there's a practical explanation for the current code.
> 

Yep.

> Patch looks good to me (and safer) even if I don't like keeping
> infinite loops from a purely theoretical standpoint.

>From a more practical point of view, I am generally more concerned
with abnormally large stalls from within the page allocator which
is what patches like "Do not stall in synchronous compaction for THP
allocations" address.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
