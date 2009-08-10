Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id EEB8F6B006A
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 02:00:12 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7A6058r006437
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 10 Aug 2009 15:00:06 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6931645DD71
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 15:00:05 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 446D745DE4C
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 15:00:05 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 27C541DB8040
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 15:00:05 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B06061DB8042
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 15:00:04 +0900 (JST)
Date: Mon, 10 Aug 2009 14:58:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][1/2] mm: add_to_swap_cache() must not sleep
Message-Id: <20090810145813.1daef011.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090810144941.ab642063.nishimura@mxp.nes.nec.co.jp>
References: <20090810112326.3526b11d.nishimura@mxp.nes.nec.co.jp>
	<20090810112641.02e1db72.nishimura@mxp.nes.nec.co.jp>
	<20090810121644.6fe466f9.kamezawa.hiroyu@jp.fujitsu.com>
	<20090810144941.ab642063.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Mon, 10 Aug 2009 14:49:41 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> Thank you for your suggestion. It's a good idea.
> 
> How about this one (Passed build test only) ?
> 
> If it's good for you, I'll resend it removing RFC after a long term test,
> unless someone else tell me not to. 
> 

Seems very nice to me. I hope answers from swap-people is good..

Thanks,
-Kame

> ===
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> After commit 355cfa73(mm: modify swap_map and add SWAP_HAS_CACHE flag),
> read_swap_cache_async() will busy-wait while a entry doesn't on swap cache
> but it has SWAP_HAS_CACHE flag.
> 
> Such entries can exist on add/delete path of swap cache.
> On add path, add_to_swap_cache() is called soon after SWAP_HAS_CACHE flag
> is set, and on delete path, swapcache_free() will be called (SWAP_HAS_CACHE
> flag is cleared) soon after __delete_from_swap_cache() is called.
> So, the busy-wait works well in most cases.
> 
> But this mechanism can cause soft lockup if add_to_swap_cache() sleeps
> and read_swap_cache_async() tries to swap-in the same entry on the same cpu.
> 
> This patch calls radix_tree_preload() before swapcache_prepare() and divide
> add_to_swap_cache() into two part: radix_tree_preload() part and
> radix_tree_insert() part(define it as __add_to_swap_cache()).
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  mm/swap_state.c |   70 ++++++++++++++++++++++++++++++++++++-------------------
>  1 files changed, 46 insertions(+), 24 deletions(-)
> 
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 42cd38e..0313a13 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -66,10 +66,10 @@ void show_swap_cache_info(void)
>  }
>  
>  /*
> - * add_to_swap_cache resembles add_to_page_cache_locked on swapper_space,
> + * __add_to_swap_cache resembles add_to_page_cache_locked on swapper_space,
>   * but sets SwapCache flag and private instead of mapping and index.
>   */
> -int add_to_swap_cache(struct page *page, swp_entry_t entry, gfp_t gfp_mask)
> +static int __add_to_swap_cache(struct page *page, swp_entry_t entry)
>  {
>  	int error;
>  
> @@ -77,28 +77,37 @@ int add_to_swap_cache(struct page *page, swp_entry_t entry, gfp_t gfp_mask)
>  	VM_BUG_ON(PageSwapCache(page));
>  	VM_BUG_ON(!PageSwapBacked(page));
>  
> +	page_cache_get(page);
> +	SetPageSwapCache(page);
> +	set_page_private(page, entry.val);
> +
> +	spin_lock_irq(&swapper_space.tree_lock);
> +	error = radix_tree_insert(&swapper_space.page_tree, entry.val, page);
> +	if (likely(!error)) {
> +		total_swapcache_pages++;
> +		__inc_zone_page_state(page, NR_FILE_PAGES);
> +		INC_CACHE_INFO(add_total);
> +	}
> +	spin_unlock_irq(&swapper_space.tree_lock);
> +
> +	if (unlikely(error)) {
> +		set_page_private(page, 0UL);
> +		ClearPageSwapCache(page);
> +		page_cache_release(page);
> +	}
> +
> +	return error;
> +}
> +
> +
> +int add_to_swap_cache(struct page *page, swp_entry_t entry, gfp_t gfp_mask)
> +{
> +	int error;
> +
>  	error = radix_tree_preload(gfp_mask);
>  	if (!error) {
> -		page_cache_get(page);
> -		SetPageSwapCache(page);
> -		set_page_private(page, entry.val);
> -
> -		spin_lock_irq(&swapper_space.tree_lock);
> -		error = radix_tree_insert(&swapper_space.page_tree,
> -						entry.val, page);
> -		if (likely(!error)) {
> -			total_swapcache_pages++;
> -			__inc_zone_page_state(page, NR_FILE_PAGES);
> -			INC_CACHE_INFO(add_total);
> -		}
> -		spin_unlock_irq(&swapper_space.tree_lock);
> +		error = __add_to_swap_cache(page, entry);
>  		radix_tree_preload_end();
> -
> -		if (unlikely(error)) {
> -			set_page_private(page, 0UL);
> -			ClearPageSwapCache(page);
> -			page_cache_release(page);
> -		}
>  	}
>  	return error;
>  }
> @@ -289,13 +298,24 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
>  		}
>  
>  		/*
> +		 * call radix_tree_preload() while we can wait.
> +		 */
> +		err = radix_tree_preload(gfp_mask & GFP_KERNEL);
> +		if (err)
> +			break;
> +
> +		/*
>  		 * Swap entry may have been freed since our caller observed it.
>  		 */
>  		err = swapcache_prepare(entry);
> -		if (err == -EEXIST) /* seems racy */
> +		if (err == -EEXIST) {	/* seems racy */
> +			radix_tree_preload_end();
>  			continue;
> -		if (err)           /* swp entry is obsolete ? */
> +		}
> +		if (err) {		/* swp entry is obsolete ? */
> +			radix_tree_preload_end();
>  			break;
> +		}
>  
>  		/*
>  		 * Associate the page with swap entry in the swap cache.
> @@ -307,8 +327,9 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
>  		 */
>  		__set_page_locked(new_page);
>  		SetPageSwapBacked(new_page);
> -		err = add_to_swap_cache(new_page, entry, gfp_mask & GFP_KERNEL);
> +		err = __add_to_swap_cache(new_page, entry);
>  		if (likely(!err)) {
> +			radix_tree_preload_end();
>  			/*
>  			 * Initiate read into locked page and return.
>  			 */
> @@ -316,6 +337,7 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
>  			swap_readpage(new_page);
>  			return new_page;
>  		}
> +		radix_tree_preload_end();
>  		ClearPageSwapBacked(new_page);
>  		__clear_page_locked(new_page);
>  		swapcache_free(entry, NULL);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
