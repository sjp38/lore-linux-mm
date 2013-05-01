Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 6F98C6B0157
	for <linux-mm@kvack.org>; Wed,  1 May 2013 01:41:43 -0400 (EDT)
Received: by mail-ia0-f169.google.com with SMTP id l29so1145606iag.28
        for <linux-mm@kvack.org>; Tue, 30 Apr 2013 22:41:42 -0700 (PDT)
Message-ID: <5180AB0E.6030407@gmail.com>
Date: Wed, 01 May 2013 13:41:34 +0800
From: Sam Ben <sam.bennn@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm: Ensure that mark_page_accessed moves pages to
 the active list
References: <1367253119-6461-1-git-send-email-mgorman@suse.de> <1367253119-6461-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1367253119-6461-3-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Alexey Lyahkov <alexey.lyashkov@gmail.com>, Andrew Perepechko <anserper@ya.ru>, Robin Dong <sanbai@taobao.com>, Theodore Tso <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Bernd Schubert <bernd.schubert@fastmail.fm>, David Howells <dhowells@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-ext4 <linux-ext4@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>

Hi Mel,
On 04/30/2013 12:31 AM, Mel Gorman wrote:
> If a page is on a pagevec then it is !PageLRU and mark_page_accessed()
> may fail to move a page to the active list as expected. Now that the
> LRU is selected at LRU drain time, mark pages PageActive if they are
> on a pagevec so it gets moved to the correct list at LRU drain time.
> Using a debugging patch it was found that for a simple git checkout
> based workload that pages were never added to the active file list in

Could you show us the details of your workload?

> practice but with this patch applied they are.
>
> 				before   after
> LRU Add Active File                  0  757121
> LRU Add Active Anon            2678833 2633924
> LRU Add Inactive File          8821711 8085543
> LRU Add Inactive Anon              183     200
>
> The question to consider is if this is universally safe. If the page
> was isolated for reclaim and there is a parallel mark_page_accessed()
> then vmscan.c will get upset when it finds an isolated PageActive page.
> Similarly a potential race exists between a per-cpu drain on a pagevec
> list and an activation on a remote CPU.
>
> 				lru_add_drain_cpu
> 				__pagevec_lru_add
> 				  lru = page_lru(page);
> mark_page_accessed
>    if (PageLRU(page))
>      activate_page
>    else
>      SetPageActive
> 				  SetPageLRU(page);
> 				  add_page_to_lru_list(page, lruvec, lru);
>
> A PageActive page is now added to the inactivate list.
>
> While this looks strange, I think it is sufficiently harmless that additional
> barriers to address the case is not justified.  Unfortunately, while I never
> witnessed it myself, these parallel updates potentially trigger defensive
> DEBUG_VM checks on PageActive and hence they are removed by this patch.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>   mm/swap.c   | 18 ++++++++++++------
>   mm/vmscan.c |  3 ---
>   2 files changed, 12 insertions(+), 9 deletions(-)
>
> diff --git a/mm/swap.c b/mm/swap.c
> index 80fbc37..2a10d08 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -437,8 +437,17 @@ void activate_page(struct page *page)
>   void mark_page_accessed(struct page *page)
>   {
>   	if (!PageActive(page) && !PageUnevictable(page) &&
> -			PageReferenced(page) && PageLRU(page)) {
> -		activate_page(page);
> +			PageReferenced(page)) {
> +
> +		/*
> +		 * If the page is on the LRU, promote immediately. Otherwise,
> +		 * assume the page is on a pagevec, mark it active and it'll
> +		 * be moved to the active LRU on the next drain
> +		 */
> +		if (PageLRU(page))
> +			activate_page(page);
> +		else
> +			SetPageActive(page);
>   		ClearPageReferenced(page);
>   	} else if (!PageReferenced(page)) {
>   		SetPageReferenced(page);
> @@ -478,11 +487,8 @@ EXPORT_SYMBOL(__lru_cache_add);
>    */
>   void lru_cache_add_lru(struct page *page, enum lru_list lru)
>   {
> -	if (PageActive(page)) {
> +	if (PageActive(page))
>   		VM_BUG_ON(PageUnevictable(page));
> -	} else if (PageUnevictable(page)) {
> -		VM_BUG_ON(PageActive(page));
> -	}
>   
>   	VM_BUG_ON(PageLRU(page));
>   	__lru_cache_add(page, lru);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 88c5fed..751b897 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -704,7 +704,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>   		if (!trylock_page(page))
>   			goto keep;
>   
> -		VM_BUG_ON(PageActive(page));
>   		VM_BUG_ON(page_zone(page) != zone);
>   
>   		sc->nr_scanned++;
> @@ -935,7 +934,6 @@ activate_locked:
>   		/* Not a candidate for swapping, so reclaim swap space. */
>   		if (PageSwapCache(page) && vm_swap_full())
>   			try_to_free_swap(page);
> -		VM_BUG_ON(PageActive(page));
>   		SetPageActive(page);
>   		pgactivate++;
>   keep_locked:
> @@ -3488,7 +3486,6 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
>   		if (page_evictable(page)) {
>   			enum lru_list lru = page_lru_base_type(page);
>   
> -			VM_BUG_ON(PageActive(page));
>   			ClearPageUnevictable(page);
>   			del_page_from_lru_list(page, lruvec, LRU_UNEVICTABLE);
>   			add_page_to_lru_list(page, lruvec, lru);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
