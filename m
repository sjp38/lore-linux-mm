Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 48B106B0031
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 18:18:49 -0400 (EDT)
Date: Wed, 17 Jul 2013 15:18:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 4/4 v6]swap: make cluster allocation per-cpu
Message-Id: <20130717151847.53aba2da0125ae45d6b2cf87@linux-foundation.org>
In-Reply-To: <20130715204406.GD7925@kernel.org>
References: <20130715204406.GD7925@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org, hughd@google.com, aquini@redhat.com

On Tue, 16 Jul 2013 04:44:06 +0800 Shaohua Li <shli@kernel.org> wrote:

> swap cluster allocation is to get better request merge to improve performance.
> But the cluster is shared globally, if multiple tasks are doing swap, this will
> cause interleave disk access. While multiple tasks swap is quite common, for
> example, each numa node has a kswapd thread doing swap or multiple
> threads/processes do direct page reclaim.
> 
> We makes the cluster allocation per-cpu here. The interleave disk access issue
> goes away. All tasks will do sequential swap.
> 
> If one CPU can't get its per-cpu cluster (for example, there is no free cluster
> anymore in the swap), it will fallback to scan swap_map.  The CPU can still
> continue swap. We don't need recycle free swap entries of other CPUs.
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

So this is a bit of a hack.  It implements per-mm swap allocation
locality by exploiting a side-effect of the scheduler behavior.

I think I asked this before, but it wasn't reflected in the changelog
so I'll go ahead and ask it again: why do it this way?  Why not, for
example, use per-mm data structures to guarantee the behaviour, rather
than relying upon a scheduler side-effect?

> --- linux.orig/include/linux/swap.h	2013-07-11 19:14:44.121818963 +0800
> +++ linux/include/linux/swap.h	2013-07-11 19:14:48.945758309 +0800
> @@ -192,6 +192,11 @@ struct swap_cluster_info {
>  #define CLUSTER_FLAG_FREE 1 /* This cluster is free */
>  #define CLUSTER_FLAG_NEXT_NULL 2 /* This cluster has no next cluster */
>  
> +struct percpu_cluster {
> +	struct swap_cluster_info index; /* Current cluster index */
> +	unsigned int next; /* Likely next allocation offset */
> +};

Again, documentation, documentation, documentation.  When a kernel
programmer sees a percpu structure, he/she will naturally assume that
it is used to improve multi-cpu scalability.  But that isn't the case
at all!  Here, percpu is being used to get layout benefits.

And it up to you, dear writer, to prevent others from getting misled in
this fashion.  By documenting your intent.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
