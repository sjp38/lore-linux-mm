Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5D77F6B02FD
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:00:30 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p64so28503005wrc.8
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:00:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y127si11043742wmb.139.2017.06.26.05.00.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Jun 2017 05:00:28 -0700 (PDT)
Subject: Re: [PATCH 4/6] mm: kvmalloc support __GFP_RETRY_MAYFAIL for all
 sizes
References: <20170623085345.11304-1-mhocko@kernel.org>
 <20170623085345.11304-5-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <80500165-94c2-2d5c-ff7a-6310916da288@suse.cz>
Date: Mon, 26 Jun 2017 14:00:27 +0200
MIME-Version: 1.0
In-Reply-To: <20170623085345.11304-5-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, NeilBrown <neilb@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

On 06/23/2017 10:53 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Now that __GFP_RETRY_MAYFAIL has a reasonable semantic regardless of the
> request size we can drop the hackish implementation for !costly orders.
> __GFP_RETRY_MAYFAIL retries as long as the reclaim makes a forward
> progress and backs of when we are out of memory for the requested size.
> Therefore we do not need to enforce__GFP_NORETRY for !costly orders just
> to silent the oom killer anymore.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

The flag is now supported, but not for the embedded page table
allocations, so OOM is still theoretically possible, right?
That should be rare, though. Worth mentioning anywhere?

Other than that.
Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/util.c | 14 ++++----------
>  1 file changed, 4 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/util.c b/mm/util.c
> index 6520f2d4a226..ee250e2cde34 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -339,9 +339,9 @@ EXPORT_SYMBOL(vm_mmap);
>   * Uses kmalloc to get the memory but if the allocation fails then falls back
>   * to the vmalloc allocator. Use kvfree for freeing the memory.
>   *
> - * Reclaim modifiers - __GFP_NORETRY and __GFP_NOFAIL are not supported. __GFP_RETRY_MAYFAIL
> - * is supported only for large (>32kB) allocations, and it should be used only if
> - * kmalloc is preferable to the vmalloc fallback, due to visible performance drawbacks.
> + * Reclaim modifiers - __GFP_NORETRY and __GFP_NOFAIL are not supported.
> + * __GFP_RETRY_MAYFAIL is supported, and it should be used only if kmalloc is
> + * preferable to the vmalloc fallback, due to visible performance drawbacks.
>   *
>   * Any use of gfp flags outside of GFP_KERNEL should be consulted with mm people.
>   */
> @@ -366,13 +366,7 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
>  	if (size > PAGE_SIZE) {
>  		kmalloc_flags |= __GFP_NOWARN;
>  
> -		/*
> -		 * We have to override __GFP_RETRY_MAYFAIL by __GFP_NORETRY for !costly
> -		 * requests because there is no other way to tell the allocator
> -		 * that we want to fail rather than retry endlessly.
> -		 */
> -		if (!(kmalloc_flags & __GFP_RETRY_MAYFAIL) ||
> -				(size <= PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER))
> +		if (!(kmalloc_flags & __GFP_RETRY_MAYFAIL))
>  			kmalloc_flags |= __GFP_NORETRY;
>  	}
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
