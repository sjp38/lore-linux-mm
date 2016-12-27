Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7F1416B0038
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 02:45:07 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id n189so399115811pga.4
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 23:45:07 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 17si13683149pfq.99.2016.12.26.23.45.05
        for <linux-mm@kvack.org>;
        Mon, 26 Dec 2016 23:45:06 -0800 (PST)
Date: Tue, 27 Dec 2016 16:45:03 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v4 0/9] mm/swap: Regular page swap optimizations
Message-ID: <20161227074503.GA10616@bbox>
References: <cover.1481317367.git.tim.c.chen@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1481317367.git.tim.c.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>, jack@suse.cz

Hi,

On Fri, Dec 09, 2016 at 01:09:13PM -0800, Tim Chen wrote:
> Change Log:
> v4:
> 1. Fix a bug in unlock cluster in add_swap_count_continuation(). We
> should use unlock_cluster() instead of unlock_cluser_or_swap_info().
> 2. During swap off, handle race when swap slot is marked unused but allocated,
> and not yet placed in swap cache.  Wait for swap slot to be placed in swap cache
> and not abort swap off.
> 3. Initialize n_ret in get_swap_pages().
> 
> v3:
> 1. Fix bug that didn't check for page already in swap cache before skipping
> read ahead and return null page.
> 2. Fix bug that didn't try to allocate from global pool if allocation
> from swap slot cache did not succeed.
> 3. Fix memory allocation bug for spaces to store split up 64MB radix tree
> 4. Fix problems caused by races between get_swap_page, cpu online/offline and
> swap_on/off
> 
> v2: 
> 1. Fix bug in the index limit used in scan_swap_map_try_ssd_cluster
> when searching for empty slots in cluster.
> 2. Fix bug in swap off that incorrectly determines if we still have
> swap devices left.
> 3. Port patches to mmotm-2016-10-11-15-46 branch
> 
> Andrew,
> 
> We're updating this patch series with some minor fixes.
> Please consider this patch series for inclusion to 4.10.
>  
> Times have changed.  Coming generation of Solid state Block device
> latencies are getting down to sub 100 usec, which is within an order of
> magnitude of DRAM, and their performance is orders of magnitude higher
> than the single- spindle rotational media we've swapped to historically.
> 
> This could benefit many usage scenearios.  For example cloud providers who
> overcommit their memory (as VM don't use all the memory provisioned).
> Having a fast swap will allow them to be more aggressive in memory
> overcommit and fit more VMs to a platform.
> 
> In our testing [see footnote], the median latency that the
> kernel adds to a page fault is 15 usec, which comes quite close
> to the amount that will be contributed by the underlying I/O
> devices.
> 
> The software latency comes mostly from contentions on the locks
> protecting the radix tree of the swap cache and also the locks protecting
> the individual swap devices.  The lock contentions already consumed
> 35% of cpu cycles in our test.  In the very near future,
> software latency will become the bottleneck to swap performnace as
> block device I/O latency gets within the shouting distance of DRAM speed.
> 
> This patch set, plus a previous patch Ying already posted
> (commit: f6498b3f) reduced the median page fault latency
> from 15 usec to 4 usec (375% reduction) for DRAM based pmem
> block device.

The patchset has used several techniqueus to reduce lock contention, for example,
batching alloc/free, fine-grained lock and cluster distribution to avoid cache
false-sharing. Each items has different complexity and benefits so could you
show the number for each step of pathchset? It would be better to include the
nubmer in each description. It helps how the patch is important when we consider
complexitiy of the patch.

> 
> Patch 1 is a clean up patch.

Could it be separated patch?

> Patch 2 creates a lock per cluster, this gives us a more fine graind lock
>         that can be used for accessing swap_map, and not lock the whole
>         swap device

I hope you make three steps to review easier. You can create some functions like
swap_map_lock and cluster_lock which are wrapper functions just hold swap_lock.
It doesn't change anything performance pov but it clearly shows what kinds of lock
we should use in specific context.

Then, you can introduce more fine-graind lock in next patch and apply it into
those wrapper functions.

And last patch, you can adjust cluster distribution to avoid false-sharing.
And the description should include how it's bad in testing so it's worth.

Frankly speaking, although I'm huge user of bit_spin_lock(zram/zsmalloc
have used it heavily), I don't like swap subsystem uses it.
During zram development, it really hurts debugging due to losing lockdep.
The reason zram have used it is by size concern of embedded world but server
would be not critical so please consider trade-off of spinlock vs. bit_spin_lock.

> Patch 3 splits the swap cache radix tree into 64MB chunks, reducing
>         the rate that we have to contende for the radix tree.

To me, it's rather hacky. I think it might be common problem for page cache
so can we think another generalized way like range_lock? Ccing Jan.

> Patch 4 eliminates unnecessary page allocation for read ahead.

Could it be separated patch?

> Patch 5-9 create a per cpu cache of the swap slots, so we don't have
>         to contend on the swap device to get a swap slot or to release
>         a swap slot.  And we allocate and release the swap slots
>         in batches for better efficiency.


To me, idea is good although I feel the amount of code is rather huge and
messy so it should include the number about the benefit, at least.

And it might make some of patches in this patchset if we put this batching
ahead before other patches redundant.

Sorry for vague commenting. In this phase, it's really hard to review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
