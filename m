Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 77E876B0034
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 18:22:33 -0400 (EDT)
Date: Wed, 12 Jun 2013 15:22:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 4/4 v4]swap: make cluster allocation per-cpu
Message-Id: <20130612152231.d342ac905d8982db6935b739@linux-foundation.org>
In-Reply-To: <20130326053843.GD19646@kernel.org>
References: <20130326053843.GD19646@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org, hughd@google.com, aquini@redhat.com

On Tue, 26 Mar 2013 13:38:43 +0800 Shaohua Li <shli@kernel.org> wrote:

> swap cluster allocation is to get better request merge to improve performance.
> But the cluster is shared globally, if multiple tasks are doing swap, this will
> cause interleave disk access. While multiple tasks swap is quite common, for
> example, each numa node has a kswapd thread doing swap or multiple
> threads/processes do direct page reclaim.
> 
> We makes the cluster allocation per-cpu here. The interleave disk access issue
> goes away. All tasks will do sequential swap.

Why per-cpu rather than, say, per-mm or per-task?

> If one CPU can't get its per-cpu cluster, it will fallback to scan swap_map.

Under what circumstances can a cpu "not get its per-cpu cluster"?  A
cpu can always "get" its per-cpu data, by definition (unless perhaps
interrupts are involved).  Perhaps this description needs some
expanding upon.

> The CPU can still continue swap. We don't need recycle free swap entries of
> other CPUs.
> 
> In my test (swap to a 2-disk raid0 partition), this improves around 10%
> swapout throughput, and request size is increased significantly.
> 
> How does this impact swap readahead is uncertain though. On one side, page
> reclaim always isolates and swaps several adjancent pages, this will make page
> reclaim write the pages sequentially and benefit readahead. On the other side,
> several CPU write pages interleave means the pages don't live _sequentially_
> but relatively _near_. In the per-cpu allocation case, if adjancent pages are
> written by different cpus, they will live relatively _far_.  So how this
> impacts swap readahead depends on how many pages page reclaim isolates and
> swaps one time. If the number is big, this patch will benefit swap readahead.
> Of course, this is about sequential access pattern. The patch has no impact for
> random access pattern, because the new cluster allocation algorithm is just for
> SSD.
> 
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
