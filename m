Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 185F06B0083
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 11:00:15 -0400 (EDT)
Received: by pzk26 with SMTP id 26so470360pzk.14
        for <linux-mm@kvack.org>; Thu, 16 Sep 2010 08:00:18 -0700 (PDT)
Date: Fri, 17 Sep 2010 00:00:10 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [RFC]pagealloc: compensate a task for direct page reclaim
Message-ID: <20100916150009.GD16115@barrios-desktop>
References: <1284636396.1726.5.camel@shli-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1284636396.1726.5.camel@shli-laptop>
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 16, 2010 at 07:26:36PM +0800, Shaohua Li wrote:
> A task enters into direct page reclaim, free some memory. But sometimes
> the task can't get a free page after direct page reclaim because
> other tasks take them (this is quite common in a multi-task workload
> in my test). This behavior will bring extra latency to the task and is
> unfair. Since the task already gets penalty, we'd better give it a compensation.
> If a task frees some pages from direct page reclaim, we cache one freed page,
> and the task will get it soon. We only consider order 0 allocation, because
> it's hard to cache order > 0 page.
> 
> Below is a trace output when a task frees some pages in try_to_free_pages(), but
> get_page_from_freelist() can't get a page in direct page reclaim.
> 
> <...>-809   [004]   730.218991: __alloc_pages_nodemask: progress 147, order 0, pid 809, comm mmap_test
> <...>-806   [001]   730.237969: __alloc_pages_nodemask: progress 147, order 0, pid 806, comm mmap_test
> <...>-810   [005]   730.237971: __alloc_pages_nodemask: progress 147, order 0, pid 810, comm mmap_test
> <...>-809   [004]   730.237972: __alloc_pages_nodemask: progress 147, order 0, pid 809, comm mmap_test
> <...>-811   [006]   730.241409: __alloc_pages_nodemask: progress 147, order 0, pid 811, comm mmap_test
> <...>-809   [004]   730.241412: __alloc_pages_nodemask: progress 147, order 0, pid 809, comm mmap_test
> <...>-812   [007]   730.241435: __alloc_pages_nodemask: progress 147, order 0, pid 812, comm mmap_test
> <...>-809   [004]   730.245036: __alloc_pages_nodemask: progress 147, order 0, pid 809, comm mmap_test
> <...>-809   [004]   730.260360: __alloc_pages_nodemask: progress 147, order 0, pid 809, comm mmap_test
> <...>-805   [000]   730.260362: __alloc_pages_nodemask: progress 147, order 0, pid 805, comm mmap_test
> <...>-811   [006]   730.263877: __alloc_pages_nodemask: progress 147, order 0, pid 811, comm mmap_test
> 

The idea is good.

I think we need to reserve at least one page for direct reclaimer who make the effort so that
it can reduce latency of stalled process.

But I don't like this implementation. 

1. It selects random page of reclaimed pages as cached page.
This doesn't consider requestor's migratetype so that it causes fragment problem in future. 

2. It skips buddy allocator. It means we lost coalescence chance so that fragement problem
would be severe than old. 

In addition, I think this patch needs some number about enhancing of latency 
and fragmentation if you are going with this approach.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
