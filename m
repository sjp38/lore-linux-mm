Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2FA686B0031
	for <linux-mm@kvack.org>; Fri, 11 Oct 2013 16:52:02 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id r10so4804560pdi.14
        for <linux-mm@kvack.org>; Fri, 11 Oct 2013 13:52:01 -0700 (PDT)
Date: Fri, 11 Oct 2013 13:51:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/2] fs: buffer: move allocation failure loop into the
 allocator
Message-Id: <20131011135157.cad19680e02cc4140ecdff0b@linux-foundation.org>
In-Reply-To: <1381265890-11333-2-git-send-email-hannes@cmpxchg.org>
References: <1381265890-11333-1-git-send-email-hannes@cmpxchg.org>
	<1381265890-11333-2-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, azurIt <azurit@pobox.sk>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue,  8 Oct 2013 16:58:10 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> Buffer allocation has a very crude indefinite loop around waking the
> flusher threads and performing global NOFS direct reclaim because it
> can not handle allocation failures.
> 
> The most immediate problem with this is that the allocation may fail
> due to a memory cgroup limit, where flushers + direct reclaim might
> not make any progress towards resolving the situation at all.  Because
> unlike the global case, a memory cgroup may not have any cache at all,
> only anonymous pages but no swap.  This situation will lead to a
> reclaim livelock with insane IO from waking the flushers and thrashing
> unrelated filesystem cache in a tight loop.
> 
> Use __GFP_NOFAIL allocations for buffers for now.  This makes sure
> that any looping happens in the page allocator, which knows how to
> orchestrate kswapd, direct reclaim, and the flushers sensibly.  It
> also allows memory cgroups to detect allocations that can't handle
> failure and will allow them to ultimately bypass the limit if reclaim
> can not make progress.
> 
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -1005,9 +1005,19 @@ grow_dev_page(struct block_device *bdev, sector_t block,
>  	struct buffer_head *bh;
>  	sector_t end_block;
>  	int ret = 0;		/* Will call free_more_memory() */
> +	gfp_t gfp_mask;
>  
> -	page = find_or_create_page(inode->i_mapping, index,
> -		(mapping_gfp_mask(inode->i_mapping) & ~__GFP_FS)|__GFP_MOVABLE);
> +	gfp_mask = mapping_gfp_mask(inode->i_mapping) & ~__GFP_FS;
> +	gfp_mask |= __GFP_MOVABLE;
> +	/*
> +	 * XXX: __getblk_slow() can not really deal with failure and
> +	 * will endlessly loop on improvised global reclaim.  Prefer
> +	 * looping in the allocator rather than here, at least that
> +	 * code knows what it's doing.
> +	 */
> +	gfp_mask |= __GFP_NOFAIL;

Yup.  When I added GFP_NOFAIL all those years ago there were numerous
open-coded try-forever loops, and GFP_NOFAIL was more a cleanup than
anything else - move the loop into the page allocator, leaving behind a
sentinel which says "this code sucks and should be fixed".  Of course,
nothing has since been fixed :(

So apart from fixing a bug, this patch continues this conversion.  I
can't think why I didn't do it a decade ago!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
