Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 97F646B0270
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 14:52:35 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id y138so37528180wme.7
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:52:35 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id b81si13649721wmc.136.2016.10.24.11.52.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 11:52:34 -0700 (PDT)
Date: Mon, 24 Oct 2016 14:52:23 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Stable 4.4 - NEEDS REVIEW - 1/3] mm: workingset: fix crash in
 shadow node shrinker caused by replace_page_cache_page()
Message-ID: <20161024185223.GA28326@cmpxchg.org>
References: <20161024152605.11707-1-mhocko@kernel.org>
 <20161024152605.11707-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161024152605.11707-2-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Stable tree <stable@vger.kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Antonio SJ Musumeci <trapexit@spawn.link>, Miklos Szeredi <miklos@szeredi.hu>

On Mon, Oct 24, 2016 at 05:26:03PM +0200, Michal Hocko wrote:
> From: Johannes Weiner <hannes@cmpxchg.org>
> 
> Commit 22f2ac51b6d643666f4db093f13144f773ff3f3a upstream.
> 
> Antonio reports the following crash when using fuse under memory pressure:
> 
>   kernel BUG at /build/linux-a2WvEb/linux-4.4.0/mm/workingset.c:346!
>   invalid opcode: 0000 [#1] SMP
>   Modules linked in: all of them
>   CPU: 2 PID: 63 Comm: kswapd0 Not tainted 4.4.0-36-generic #55-Ubuntu
>   Hardware name: System manufacturer System Product Name/P8H67-M PRO, BIOS 3904 04/27/2013
>   task: ffff88040cae6040 ti: ffff880407488000 task.ti: ffff880407488000
>   RIP: shadow_lru_isolate+0x181/0x190
>   Call Trace:
>     __list_lru_walk_one.isra.3+0x8f/0x130
>     list_lru_walk_one+0x23/0x30
>     scan_shadow_nodes+0x34/0x50
>     shrink_slab.part.40+0x1ed/0x3d0
>     shrink_zone+0x2ca/0x2e0
>     kswapd+0x51e/0x990
>     kthread+0xd8/0xf0
>     ret_from_fork+0x3f/0x70
> 
> which corresponds to the following sanity check in the shadow node
> tracking:
> 
>   BUG_ON(node->count & RADIX_TREE_COUNT_MASK);
> 
> The workingset code tracks radix tree nodes that exclusively contain
> shadow entries of evicted pages in them, and this (somewhat obscure)
> line checks whether there are real pages left that would interfere with
> reclaim of the radix tree node under memory pressure.
> 
> While discussing ways how fuse might sneak pages into the radix tree
> past the workingset code, Miklos pointed to replace_page_cache_page(),
> and indeed there is a problem there: it properly accounts for the old
> page being removed - __delete_from_page_cache() does that - but then
> does a raw raw radix_tree_insert(), not accounting for the replacement
> page.  Eventually the page count bits in node->count underflow while
> leaving the node incorrectly linked to the shadow node LRU.
> 
> To address this, make sure replace_page_cache_page() uses the tracked
> page insertion code, page_cache_tree_insert().  This fixes the page
> accounting and makes sure page-containing nodes are properly unlinked
> from the shadow node LRU again.
> 
> Also, make the sanity checks a bit less obscure by using the helpers for
> checking the number of pages and shadows in a radix tree node.
> 
> Fixes: 449dd6984d0e ("mm: keep page cache radix tree nodes in check")
> Link: http://lkml.kernel.org/r/20160919155822.29498-1-hannes@cmpxchg.org
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Reported-by: Antonio SJ Musumeci <trapexit@spawn.link>
> Debugged-by: Miklos Szeredi <miklos@szeredi.hu>
> Cc: <stable@vger.kernel.org>	[3.15+]
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/swap.h |  2 ++
>  mm/filemap.c         | 86 ++++++++++++++++++++++++++--------------------------
>  mm/workingset.c      | 10 +++---
>  3 files changed, 49 insertions(+), 49 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 7ba7dccaf0e7..b28de19aadbf 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -266,6 +266,7 @@ static inline void workingset_node_pages_inc(struct radix_tree_node *node)
>  
>  static inline void workingset_node_pages_dec(struct radix_tree_node *node)
>  {
> +	VM_BUG_ON(!workingset_node_pages(node));
>  	node->count--;
>  }

We should also pull 21f54ddae449 ("Using BUG_ON() as an assert() is
_never_ acceptable") into stable on top of this patch to replace the
BUG_ONs with warnings.

Otherwise this looks good to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
