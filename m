Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4C3596B0012
	for <linux-mm@kvack.org>; Fri, 13 May 2011 11:21:52 -0400 (EDT)
Date: Fri, 13 May 2011 10:21:46 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/4] Reduce impact to overall system of SLUB using
 high-order allocations V2
In-Reply-To: <1305295404-12129-1-git-send-email-mgorman@suse.de>
Message-ID: <alpine.DEB.2.00.1105131009530.24193@router.home>
References: <1305295404-12129-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Fri, 13 May 2011, Mel Gorman wrote:

> SLUB using high orders is the trigger but not the root cause as SLUB
> has been using high orders for a while. The following four patches
> aim to fix the problems in reclaim while reducing the cost for SLUB
> using those high orders.
>
> Patch 1 corrects logic introduced by commit [1741c877: mm:
> 	kswapd: keep kswapd awake for high-order allocations until
> 	a percentage of the node is balanced] to allow kswapd to
> 	go to sleep when balanced for high orders.

The above looks good.

> Patch 2 prevents kswapd waking up in response to SLUBs speculative
> 	use of high orders.

Not sure if that is necessary since it seems that we triggered kswapd
before? Why not continue to do it? Once kswapd has enough higher order
pages kswapd should no longer be triggered right?

> Patch 3 further reduces the cost by prevent SLUB entering direct
> 	compaction or reclaim paths on the grounds that falling
> 	back to order-0 should be cheaper.

Its cheaper for reclaim path true but more expensive in terms of SLUBs
management costs of the data and it also increases the memory wasted. A
higher order means denser packing of objects less page management
overhead. Fallback is not for free. Reasonable effort should be made to
allocate the page order requested.

> Patch 4 notes that even when kswapd is failing to keep up with
> 	allocation requests, it should still go to sleep when its
> 	quota has expired to prevent it spinning.

Looks good too.

Overall, it looks like the compaction logic and the modifications to
reclaim introduced recently with the intend to increase the amount of
physically contiguous memory is not working as expected.

SLUBs chance of getting higher order pages should be *increasing* as a
result of these changes. The above looks like the chances are decreasing
now.

This is a matter of future concern. The metadata management overhead
in the kernel is continually increasing since memory sizes keep growing
and we typically manage memory in 4k chunks. Through large allocation
sizes we can reduce that management overhead but we can only do this if we
have an effective way of defragmenting memory to get longer contiguous
chunks that can be managed to a single page struct.

Please make sure that compaction and related measures really work properly.

The patches suggest that the recent modifications are not improving the
situation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
