Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 86CE46B0005
	for <linux-mm@kvack.org>; Tue,  3 May 2016 17:00:58 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 77so63059076pfz.3
        for <linux-mm@kvack.org>; Tue, 03 May 2016 14:00:58 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id 145si318688pfy.175.2016.05.03.14.00.57
        for <linux-mm@kvack.org>;
        Tue, 03 May 2016 14:00:57 -0700 (PDT)
Message-ID: <1462309239.21143.6.camel@linux.intel.com>
Subject: [PATCH 0/7] mm: Improve swap path scalability with batched
 operations
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Tue, 03 May 2016 14:00:39 -0700
In-Reply-To: <cover.1462306228.git.tim.c.chen@linux.intel.com>
References: <cover.1462306228.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>
Cc: "Kirill A.Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, Aaron Lu <aaron.lu@intel.com>, Huang Ying <ying.huang@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

The page swap out path is not scalable due to the numerous locks
acquired and released along the way, which are all executed on a page
by page basis, e.g.:

1. The acquisition of the mapping tree lock in swap cache when adding
a page to swap cache, and then again when deleting a page from swap cache after
it has been swapped out.A 
2. The acquisition of the lock on swap device to allocate a swap slot for
a page to be swapped out.A 

With the advent of high speed block devices that's several ordersA A 
of magnitude faster than the old spinning disks, these bottlenecks
become fairly significant, especially on server class machines
with many theads running.A A To reduce these locking costs, this patch
series attempt to batch the pages on the following oprations needed
on for swap:
1. Allocate swap slots in large batches, so locks on the swap device
don't need to be acquired as often.A 
2. Add anonymous pages to the swap cache for the same swap device inA A A A A A A A A A A A A 
batches, so the mapping tree lock can be acquired less.
3. Delete pages from swap cache also in batches.

We experimented the effect of this patches. We set up N threads to access
memory in excess of memory capcity, causing swap.A A In experiments using
a single pmem based fast block device on a 2 socket machine, we saw
that for 1 thread, there is a ~25% increase in swap throughput and for
16 threads, the swap throughput increase by ~85%, when compared with the
vanilla kernel. Batching helps even for 1 thread because of contention
with kswapd when doing direct memory reclaim.

Feedbacks and reviews to this patch series are much appreciated.

Thanks.

Tim


Tim Chen (7):
A  mm: Cleanup - Reorganize the shrink_page_list code into smaller
A A A A functions
A  mm: Group the processing of anonymous pages to be swapped in
A A A A shrink_page_list
A  mm: Add new functions to allocate swap slots in batches
A  mm: Shrink page list batch allocates swap slots for page swapping
A  mm: Batch addtion of pages to swap cache
A  mm: Cleanup - Reorganize code to group handling of page
A  mm: Batch unmapping of pages that are in swap cache

A include/linux/swap.h |A A 29 ++-
A mm/swap_state.cA A A A A A | 253 +++++++++++++-----
A mm/swapfile.cA A A A A A A A | 215 +++++++++++++--
A mm/vmscan.cA A A A A A A A A A | 725 ++++++++++++++++++++++++++++++++++++++-------------
A 4 files changed, 945 insertions(+), 277 deletions(-)

--A 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
