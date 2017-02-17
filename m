Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9FD7D6B0038
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 13:42:49 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 65so68786627pgi.7
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 10:42:49 -0800 (PST)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id b85si11014490pfe.118.2017.02.17.10.42.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 10:42:48 -0800 (PST)
Received: by mail-pf0-x22d.google.com with SMTP id c73so15362668pfb.0
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 10:42:48 -0800 (PST)
Date: Fri, 17 Feb 2017 10:42:37 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: swap_cluster_info lockdep splat
In-Reply-To: <874lzt6znd.fsf@yhuang-dev.intel.com>
Message-ID: <alpine.LSU.2.11.1702171036010.1638@eggly.anvils>
References: <20170216052218.GA13908@bbox> <87o9y2a5ji.fsf@yhuang-dev.intel.com> <alpine.LSU.2.11.1702161050540.21773@eggly.anvils> <1487273646.2833.100.camel@linux.intel.com> <alpine.LSU.2.11.1702161702490.24224@eggly.anvils>
 <874lzt6znd.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Hugh Dickins <hughd@google.com>, Tim Chen <tim.c.chen@linux.intel.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 17 Feb 2017, Huang, Ying wrote:
> 
> I found a memory leak in __read_swap_cache_async() introduced by mm-swap
> series, and confirmed it via testing.  Could you verify whether it fixed
> your cases?  Thanks a lot for reporting.

Well caught!  That indeed fixes the leak I've been seeing: my load has
now passed the 7 hour danger mark, with no indication of slowing down.
I'll keep it running until I need to try something else on that machine,
but all good for now.

You could add
Tested-by: Hugh Dickins <hughd@google.com>
but don't bother: I'm sure Andrew will simply fold this fix into the
fixed patch later on.

Thanks,
Hugh

> 
> Best Regards,
> Huang, Ying
> 
> ------------------------------------------------------------------------->
> From 4b96423796ab7435104eb2cb4dcf5d525b9e0800 Mon Sep 17 00:00:00 2001
> From: Huang Ying <ying.huang@intel.com>
> Date: Fri, 17 Feb 2017 10:31:37 +0800
> Subject: [PATCH] mm, swap: Fix memory leak in __read_swap_cache_async()
> 
> The memory may be leaked in __read_swap_cache_async().  For the cases
> as below,
> 
> CPU 0						CPU 1
> -----						-----
> 
> find_get_page() == NULL
> __swp_swapcount() != 0
> new_page = alloc_page_vma()
> radix_tree_maybe_preload()
> 						swap in swap slot
> swapcache_prepare() == -EEXIST
> cond_resched()
> 						reclaim the swap slot
> find_get_page() == NULL
> __swp_swapcount() == 0
> return NULL				<- new_page leaked here !!!
> 
> The memory leak has been confirmed via checking the value of new_page
> when returning inside the loop in __read_swap_cache_async().
> 
> This is fixed via replacing return with break inside of loop in
> __read_swap_cache_async(), so that there is opportunity for the
> new_page to be checked and freed.
> 
> Reported-by: Hugh Dickins <hughd@google.com>
> Cc: Tim Chen <tim.c.chen@linux.intel.com>
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> ---
>  mm/swap_state.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 2126e9ba23b2..473b71e052a8 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -333,7 +333,7 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
>  		 * else swap_off will be aborted if we return NULL.
>  		 */
>  		if (!__swp_swapcount(entry) && swap_slot_cache_enabled)
> -			return NULL;
> +			break;
>  
>  		/*
>  		 * Get a new page to read into from swap.
> -- 
> 2.11.0
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
