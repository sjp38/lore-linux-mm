Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 824646B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 09:07:08 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id n64so1824184wrb.18
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 06:07:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c48si7351789wra.150.2017.09.26.06.07.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 06:07:06 -0700 (PDT)
Date: Tue, 26 Sep 2017 15:07:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V2 1/2] mm: avoid marking swap cached page as lazyfree
Message-ID: <20170926130705.wjtw55kj7cw4k34j@dhcp22.suse.cz>
References: <cover.1506105110.git.shli@fb.com>
 <e4e1de7f06de9f6f50fd64b83d7da7b9597d2d97.1506105110.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e4e1de7f06de9f6f50fd64b83d7da7b9597d2d97.1506105110.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, Artem Savkov <asavkov@redhat.com>, Kernel-team@fb.com, Shaohua Li <shli@fb.com>, stable@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>

On Fri 22-09-17 11:46:30, Shaohua Li wrote:
> From: Shaohua Li <shli@fb.com>
> 
> MADV_FREE clears pte dirty bit and then marks the page lazyfree (clear
> SwapBacked). There is no lock to prevent the page is added to swap cache
> between these two steps by page reclaim. If the page is added to swap
> cache, marking the page lazyfree will confuse page fault if the page is
> reclaimed and refault.

Could you be more specific how exactly what kind of the confusion is the
result? I suspect you are talking about VM_BUG_ON_PAGE in
__add_to_swap_cache right?

I am also not sure how that would actually happen to be honest. If we
raced with the reclaim then the page should have been isolated and so
PageLRU is no longer true. Or am I missing something?

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
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
