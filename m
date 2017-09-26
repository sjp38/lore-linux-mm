Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2C8616B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 16:23:30 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id h16so13533199wrf.0
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 13:23:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n43si7604913wrb.385.2017.09.26.13.23.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 13:23:28 -0700 (PDT)
Date: Tue, 26 Sep 2017 22:23:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V3 1/2] mm: avoid marking swap cached page as lazyfree
Message-ID: <20170926202324.ay6ets5nke7h5yil@dhcp22.suse.cz>
References: <cover.1506446061.git.shli@fb.com>
 <6537ef3814398c0073630b03f176263bc81f0902.1506446061.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6537ef3814398c0073630b03f176263bc81f0902.1506446061.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, asavkov@redhat.com, Kernel-team@fb.com, Shaohua Li <shli@fb.com>, stable@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>

On Tue 26-09-17 10:26:25, Shaohua Li wrote:
> From: Shaohua Li <shli@fb.com>
> 
> MADV_FREE clears pte dirty bit and then marks the page lazyfree (clear
> SwapBacked). There is no lock to prevent the page is added to swap cache
> between these two steps by page reclaim. Page reclaim could add the page
> to swap cache and unmap the page. After page reclaim, the page is added
> back to lru. At that time, we probably start draining per-cpu pagevec
> and mark the page lazyfree. So the page could be in a state with
> SwapBacked cleared and PG_swapcache set. Next time there is a refault in
> the virtual address, do_swap_page can find the page from swap cache but
> the page has PageSwapCache false because SwapBacked isn't set, so
> do_swap_page will bail out and do nothing. The task will keep running
> into fault handler.

Thanks for the clarification in the changelog. It is much more clear
now!

> Reported-and-tested-by: Artem Savkov <asavkov@redhat.com>
> Fix: 802a3a92ad7a(mm: reclaim MADV_FREE pages)
> Signed-off-by: Shaohua Li <shli@fb.com>
> Cc: stable@vger.kernel.org
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Reviewed-by: Rik van Riel <riel@redhat.com>

Marking for stable as suggested by Johannes makes perfect sense to me.
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/swap.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index 9295ae9..a77d68f 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -575,7 +575,7 @@ static void lru_lazyfree_fn(struct page *page, struct lruvec *lruvec,
>  			    void *arg)
>  {
>  	if (PageLRU(page) && PageAnon(page) && PageSwapBacked(page) &&
> -	    !PageUnevictable(page)) {
> +	    !PageSwapCache(page) && !PageUnevictable(page)) {
>  		bool active = PageActive(page);
>  
>  		del_page_from_lru_list(page, lruvec,
> @@ -665,7 +665,7 @@ void deactivate_file_page(struct page *page)
>  void mark_page_lazyfree(struct page *page)
>  {
>  	if (PageLRU(page) && PageAnon(page) && PageSwapBacked(page) &&
> -	    !PageUnevictable(page)) {
> +	    !PageSwapCache(page) && !PageUnevictable(page)) {
>  		struct pagevec *pvec = &get_cpu_var(lru_lazyfree_pvecs);
>  
>  		get_page(page);
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
