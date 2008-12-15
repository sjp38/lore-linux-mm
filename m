Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6FC166B0070
	for <linux-mm@kvack.org>; Mon, 15 Dec 2008 18:20:27 -0500 (EST)
Date: Mon, 15 Dec 2008 15:21:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm: pagecache gfp flags fix
Message-Id: <20081215152144.00a84c4f.akpm@linux-foundation.org>
In-Reply-To: <20081212044120.GD15804@wotan.suse.de>
References: <20081212044120.GD15804@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Dec 2008 05:41:20 +0100
Nick Piggin <npiggin@suse.de> wrote:

> This patch doesn't actually fix a regression, but a longer standing bug.
> --
> 
> Frustratingly, gfp_t is really divided into two classes of flags. One are the
> context dependent ones (can we sleep? can we enter filesystem? block subsystem?
> should we use some extra reserves, etc.). The other ones are the type of memory
> required and depend on how the algorithm is implemented rather than the point
> at which the memory is allocated (highmem? dma memory? etc).
> 
> Some of functions which allocate a page and add it to page cache take a gfp_t,
> but sometimes those functions or their callers aren't really doing the right
> thing: when allocating pagecache page, the memory type should be
> mapping_gfp_mask(mapping). When allocating radix tree nodes, the memory type
> should be kernel mapped (not highmem) memory. The gfp_t argument should only
> really be needed for context dependent options.
> 
> This patch doesn't really solve that tangle in a nice way, but it does attempt
> to fix a couple of bugs.
> 
> - find_or_create_page changes its radix-tree allocation to only include the
>   main context dependent flags in order so the pagecache page may be allocated
>   from arbitrary types of memory without affecting the radix-tree. In practice,
>   slab allocations don't come from highmem anyway, and radix-tree only uses
>   slab allocations. So there isn't a practical change (unless some fs uses
>   GFP_DMA for pages).
> 
> - grab_cache_page_nowait() is changed to allocate radix-tree nodes with
>   GFP_NOFS, because it is not supposed to reenter the filesystem. This bug
>   could cause lock recursion if a filesystem is not expecting the function
>   to reenter the fs (as-per documentation).
> 
> Filesystems should be careful about exactly what semantics they want and what
> they get when fiddling with gfp_t masks to allocate pagecache. One should be
> as liberal as possible with the type of memory that can be used, and same
> for the the context specific flags.

ug.  So at present page_symlink() can call write_begin() which will do
a GFP_KERNEL/GFP_USER allocation even though we hold fs locks?

In which calling context does this happen?

This is a pretty big ugly patch.  I'm thinking that we merge into
2.6.29 and backport into 2.6.28.x.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
