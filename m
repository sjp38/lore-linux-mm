Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5E9956B0044
	for <linux-mm@kvack.org>; Tue, 30 Dec 2008 17:28:53 -0500 (EST)
Date: Tue, 30 Dec 2008 14:28:05 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] cpuset,mm: fix allocating page cache/slab object on the
 unallowed node when memory spread is set
Message-Id: <20081230142805.3c6f78e3.akpm@linux-foundation.org>
In-Reply-To: <49547B93.5090905@cn.fujitsu.com>
References: <49547B93.5090905@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: miaox@cn.fujitsu.com
Cc: menage@google.com, cl@linux-foundation.org, penberg@cs.helsinki.fi, mpm@selenic.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Dec 2008 14:37:07 +0800
Miao Xie <miaox@cn.fujitsu.com> wrote:

> The task still allocated the page caches on old node after modifying its
> cpuset's mems when 'memory_spread_page' was set, it is caused by the old
> mem_allowed_list of the task. Slab has the same problem.

ok...

> diff --git a/mm/filemap.c b/mm/filemap.c
> index f3e5f89..d978983 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -517,6 +517,9 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
>  #ifdef CONFIG_NUMA
>  struct page *__page_cache_alloc(gfp_t gfp)
>  {
> +	if ((gfp & __GFP_WAIT) && !in_interrupt())
> +		cpuset_update_task_memory_state();
> +
>  	if (cpuset_do_page_mem_spread()) {
>  		int n = cpuset_mem_spread_node();
>  		return alloc_pages_node(n, gfp, 0);
> diff --git a/mm/slab.c b/mm/slab.c
> index 0918751..3b6e3d7 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3460,6 +3460,9 @@ __cache_alloc(struct kmem_cache *cachep, gfp_t flags, void *caller)
>  	if (should_failslab(cachep, flags))
>  		return NULL;
>  
> +	if ((flags & __GFP_WAIT) && !in_interrupt())
> +		cpuset_update_task_memory_state();
> +
>  	cache_alloc_debugcheck_before(cachep, flags);
>  	local_irq_save(save_flags);
>  	objp = __do_cache_alloc(cachep, flags);

Problems.

a) There's no need to test in_interrupt().  Any caller who passed us
   __GFP_WAIT from interrupt context is horridly buggy and needs to be
   fixed.

b) Even if the caller _did_ set __GFP_WAIT, there's no guarantee
   that we're deadlock safe here.  Does anyone ever do a __GFP_WAIT
   allocation while holding callback_mutex?  If so, it'll deadlock.

c) These are two of the kernel's hottest code paths.  We really
   really really really don't want to be polling for some dopey
   userspace admin change on each call to __cache_alloc()!

d) How does slub handle this problem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
