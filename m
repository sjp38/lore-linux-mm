Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2012C6B0253
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 20:47:39 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c73so290919875pfb.7
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 17:47:39 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id s196si25101555pgs.141.2017.01.25.17.47.37
        for <linux-mm@kvack.org>;
        Wed, 25 Jan 2017 17:47:38 -0800 (PST)
Date: Thu, 26 Jan 2017 10:47:36 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 5/5] mm: vmscan: move dirty pages out of the way until
 they're flushed
Message-ID: <20170126014736.GE21211@bbox>
References: <20170123181641.23938-1-hannes@cmpxchg.org>
 <20170123181641.23938-6-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170123181641.23938-6-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Jan 23, 2017 at 01:16:41PM -0500, Johannes Weiner wrote:
> We noticed a performance regression when moving hadoop workloads from
> 3.10 kernels to 4.0 and 4.6. This is accompanied by increased pageout
> activity initiated by kswapd as well as frequent bursts of allocation
> stalls and direct reclaim scans. Even lowering the dirty ratios to the
> equivalent of less than 1% of memory would not eliminate the issue,
> suggesting that dirty pages concentrate where the scanner is looking.
> 
> This can be traced back to recent efforts of thrash avoidance. Where
> 3.10 would not detect refaulting pages and continuously supply clean
> cache to the inactive list, a thrashing workload on 4.0+ will detect
> and activate refaulting pages right away, distilling used-once pages
> on the inactive list much more effectively. This is by design, and it
> makes sense for clean cache. But for the most part our workload's
> cache faults are refaults and its use-once cache is from streaming
> writes. We end up with most of the inactive list dirty, and we don't
> go after the active cache as long as we have use-once pages around.
> 
> But waiting for writes to avoid reclaiming clean cache that *might*
> refault is a bad trade-off. Even if the refaults happen, reads are
> faster than writes. Before getting bogged down on writeback, reclaim
> should first look at *all* cache in the system, even active cache.
> 
> To accomplish this, activate pages that have been dirty or under
> writeback for two inactive LRU cycles. We know at this point that
> there are not enough clean inactive pages left to satisfy memory
> demand in the system. The pages are marked for immediate reclaim,
> meaning they'll get moved back to the inactive LRU tail as soon as
> they're written back and become reclaimable. But in the meantime, by
> reducing the inactive list to only immediately reclaimable pages, we
> allow the scanner to deactivate and refill the inactive list with
> clean cache from the active list tail to guarantee forward progress.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Minchan Kim <minchan@kernel.org>

Every patches look reasaonable to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
