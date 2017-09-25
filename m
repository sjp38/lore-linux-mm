Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A57716B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 01:07:15 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y29so11640327pff.6
        for <linux-mm@kvack.org>; Sun, 24 Sep 2017 22:07:15 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id t65si3535615pgb.16.2017.09.24.22.07.13
        for <linux-mm@kvack.org>;
        Sun, 24 Sep 2017 22:07:14 -0700 (PDT)
Date: Mon, 25 Sep 2017 14:07:11 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH V2 1/2] mm: avoid marking swap cached page as lazyfree
Message-ID: <20170925050711.GA27410@bbox>
References: <cover.1506105110.git.shli@fb.com>
 <e4e1de7f06de9f6f50fd64b83d7da7b9597d2d97.1506105110.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e4e1de7f06de9f6f50fd64b83d7da7b9597d2d97.1506105110.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, Artem Savkov <asavkov@redhat.com>, Kernel-team@fb.com, Shaohua Li <shli@fb.com>, stable@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Sep 22, 2017 at 11:46:30AM -0700, Shaohua Li wrote:
> From: Shaohua Li <shli@fb.com>
> 
> MADV_FREE clears pte dirty bit and then marks the page lazyfree (clear
> SwapBacked). There is no lock to prevent the page is added to swap cache
> between these two steps by page reclaim. If the page is added to swap
> cache, marking the page lazyfree will confuse page fault if the page is
> reclaimed and refault.

If page is added to swapcache while it stays lru_lazyfree_pvec,
it ends up having !PG_swapbacked, PG_swapcache and !PG_dirty.
Most important thing is PG_dirty. Without it, VM will reclaim the
page without *writeback* so we lose the data.

Although we prevent the page adding to swapcache, we lose the data
unless we apply [2/2] so this patch alone doesn't fix the problem.
That's why I said to you we don't need to separate patches.

> 
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
