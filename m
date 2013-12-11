Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id A8A386B0038
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 17:47:24 -0500 (EST)
Received: by mail-ee0-f45.google.com with SMTP id d49so3133332eek.18
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 14:47:24 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id 5si21181003eei.60.2013.12.11.14.47.23
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 14:47:23 -0800 (PST)
Date: Wed, 11 Dec 2013 22:47:19 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch] mm: page_alloc: exclude unreclaimable allocations from
 zone fairness policy
Message-ID: <20131211224719.GE11295@suse.de>
References: <1386785356-19911-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1386785356-19911-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Dec 11, 2013 at 01:09:16PM -0500, Johannes Weiner wrote:
> Dave Hansen noted a regression in a microbenchmark that loops around
> open() and close() on an 8-node NUMA machine and bisected it down to
> 81c0a2bb515f ("mm: page_alloc: fair zone allocator policy").  That
> change forces the slab allocations of the file descriptor to spread
> out to all 8 nodes, causing remote references in the page allocator
> and slab.
> 

The original patch was primarily concerned with the fair aging of LRU pages
of zones within a node. This patch uses GFP_MOVABLE_MASK which includes
__GFP_RECLAIMABLE meaning any slab created with SLAB_RECLAIM_ACCOUNT is still
getting the round-robin treatment. Those pages have a different lifecycle
to LRU pages and the shrinkers are only node aware, not zone aware.
While I get this patch probably helps this specific benchmark, was the
use of GFP_MOVABLE_MASK intentional or did you mean to use __GFP_MOVABLE?

Looking at the original patch again I think I made a major mistake when
reviewing it. Considering the effect of the following for NUMA machines

        for_each_zone_zonelist_nodemask(zone, z, zonelist,
                                                high_zoneidx, nodemask) {
		....
                if (alloc_flags & ALLOC_WMARK_LOW) {
                        if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
				continue;
                        if (zone_reclaim_mode &&
                            !zone_local(preferred_zone, zone))
                                continue;
		}


Enabling zone_reclaim_mode sucks badly for workloads that are not paritioned
to fit within NUMA nodes. Consequently, I expect the common case it that
it's disabled by default due to small NUMA distances or manually disabled.

However, the effect of that block is that we allocate NR_ALLOC_BATCH
from local zones then fallback to batch allocating remote nodes! I bet
the numa_hit stats in /proc/vmstat have sucked recently. The original
problem was because the page allocator would try allocating from the
highest zone while kswapd reclaimed from it causing LRU-aging problems.
The problem is not the same between nodes. How do you feel about dropping
the zone_reclaim_mode check above and only round-robin in batches between
zones on the local node?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
