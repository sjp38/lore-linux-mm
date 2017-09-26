Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 27BEC6B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 09:13:42 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r136so11825473wmf.4
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 06:13:42 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e54si7962093wre.203.2017.09.26.06.13.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 06:13:40 -0700 (PDT)
Date: Tue, 26 Sep 2017 15:13:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V2 2/2] mm: fix data corruption caused by lazyfree page
Message-ID: <20170926131338.nissnmlws4ycqy5f@dhcp22.suse.cz>
References: <cover.1506105110.git.shli@fb.com>
 <254ff921294f143a65f30052070b43fec411fc2a.1506105110.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <254ff921294f143a65f30052070b43fec411fc2a.1506105110.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, Artem Savkov <asavkov@redhat.com>, Kernel-team@fb.com, Shaohua Li <shli@fb.com>, stable@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>

On Fri 22-09-17 11:46:31, Shaohua Li wrote:
> From: Shaohua Li <shli@fb.com>
> 
> MADV_FREE clears pte dirty bit and then marks the page lazyfree (clear
> SwapBacked). There is no lock to prevent the page is added to swap cache
> between these two steps by page reclaim. If page reclaim finds such
> page, it will simply add the page to swap cache without pageout the page
> to swap because the page is marked as clean. Next time, page fault will
> read data from the swap slot which doesn't have the original data, so we
> have a data corruption. To fix issue, we mark the page dirty and pageout
> the page.
> 
> However, we shouldn't dirty all pages which is clean and in swap cache.
> swapin page is swap cache and clean too. So we only dirty page which is
> added into swap cache in page reclaim, which shouldn't be swapin page.
> As Minchan suggested, simply dirty the page in add_to_swap can do the
> job.
> 
> Reported-by: Artem Savkov <asavkov@redhat.com>
> Fix: 802a3a92ad7a(mm: reclaim MADV_FREE pages)
> Signed-off-by: Shaohua Li <shli@fb.com>
> Cc: stable@vger.kernel.org
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>

OK the patch makes sense to me
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/swap_state.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 71ce2d1..2d64ec4 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -231,7 +231,7 @@ int add_to_swap(struct page *page)
>  	 * deadlock in the swap out path.
>  	 */
>  	/*
> -	 * Add it to the swap cache.
> +	 * Add it to the swap cache and mark it dirty
>  	 */

this comment is simply useless. It doesn't explain why we need it and it
is trivial to see what we do there. So I would remove it altogether or
make it more useful explaning the MADV_FREE race which would be IMHO
much better.

>  	err = add_to_swap_cache(page, entry,
>  			__GFP_HIGH|__GFP_NOMEMALLOC|__GFP_NOWARN);
> @@ -242,6 +242,7 @@ int add_to_swap(struct page *page)
>  		 * clear SWAP_HAS_CACHE flag.
>  		 */
>  		goto fail;
> +	set_page_dirty(page);
>  
>  	return 1;
>  
> -- 
> 2.9.5
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
