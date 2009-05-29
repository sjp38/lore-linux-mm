Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CAE186B0055
	for <linux-mm@kvack.org>; Fri, 29 May 2009 17:54:58 -0400 (EDT)
Date: Fri, 29 May 2009 14:55:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/4] reuse unused swap entry if necessary
Message-Id: <20090529145510.b4ff541e.akpm@linux-foundation.org>
In-Reply-To: <20090528142047.3069543b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090528135455.0c83bedc.kamezawa.hiroyu@jp.fujitsu.com>
	<20090528142047.3069543b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, hugh.dickins@tiscali.co.uk, hannes@cmpxchg.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 May 2009 14:20:47 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, we can know a swap entry is just used as SwapCache via swap_map,
> without looking up swap cache.
> 
> Then, we have a chance to reuse swap-cache-only swap entries in
> get_swap_pages().
> 
> This patch tries to free swap-cache-only swap entries if swap is
> not enough.
> Note: We hit following path when swap_cluster code cannot find
> a free cluster. Then, vm_swap_full() is not only condition to allow
> the kernel to reclaim unused swap.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/swapfile.c |   39 +++++++++++++++++++++++++++++++++++++++
>  1 file changed, 39 insertions(+)
> 
> Index: new-trial-swapcount2/mm/swapfile.c
> ===================================================================
> --- new-trial-swapcount2.orig/mm/swapfile.c
> +++ new-trial-swapcount2/mm/swapfile.c
> @@ -73,6 +73,25 @@ static inline unsigned short make_swap_c
>  	return ret;
>  }
>  
> +static int
> +try_to_reuse_swap(struct swap_info_struct *si, unsigned long offset)
> +{
> +	int type = si - swap_info;
> +	swp_entry_t entry = swp_entry(type, offset);
> +	struct page *page;
> +	int ret = 0;
> +
> +	page = find_get_page(&swapper_space, entry.val);
> +	if (!page)
> +		return 0;
> +	if (trylock_page(page)) {
> +		ret = try_to_free_swap(page);
> +		unlock_page(page);
> +	}
> +	page_cache_release(page);
> +	return ret;
> +}

This function could do with some comments explaining what it does, and
why.  Also describing the semantics of its return value.

afacit it's misnamed.  It doesn't 'reuse' anything.  It in fact tries
to release a swap entry so that (presumably) its _caller_ can reuse the
swap slot.

The missing comment should also explain why this function is forced to
use the nasty trylock_page().

Why _is_ this function forced to use the nasty trylock_page()?

>  /*
>   * We need this because the bdev->unplug_fn can sleep and we cannot
>   * hold swap_lock while calling the unplug_fn. And swap_lock
> @@ -294,6 +313,18 @@ checks:
>  		goto no_page;
>  	if (offset > si->highest_bit)
>  		scan_base = offset = si->lowest_bit;
> +
> +	/* reuse swap entry of cache-only swap if not busy. */
> +	if (vm_swap_full() && si->swap_map[offset] == SWAP_HAS_CACHE) {
> +		int ret;
> +		spin_unlock(&swap_lock);
> +		ret = try_to_reuse_swap(si, offset);
> +		spin_lock(&swap_lock);
> +		if (ret)
> +			goto checks; /* we released swap_lock. retry. */
> +		goto scan; /* In some racy case */
> +	}

So..  what prevents an infinite (or long) busy loop here?  It appears
that if try_to_reuse_swap() returned non-zero, it will have cleared
si->swap_map[offset], so we don't rerun try_to_reuse_swap().  Yes?

`ret' is a poor choice of identifier.  It is usually used to hold the
value which this function will be returning.  Ditto `retval'.  But that
is not this variable's role in this case.  Perhaps a better name would
be slot_was_freed or something.

>  	if (si->swap_map[offset])
>  		goto scan;
>  
> @@ -375,6 +406,10 @@ scan:
>  			spin_lock(&swap_lock);
>  			goto checks;
>  		}
> +		if (vm_swap_full() && si->swap_map[offset] == SWAP_HAS_CACHE) {
> +			spin_lock(&swap_lock);
> +			goto checks;
> +		}
>  		if (unlikely(--latency_ration < 0)) {
>  			cond_resched();
>  			latency_ration = LATENCY_LIMIT;
> @@ -386,6 +421,10 @@ scan:
>  			spin_lock(&swap_lock);
>  			goto checks;
>  		}
> +		if (vm_swap_full() && si->swap_map[offset] == SWAP_HAS_CACHE) {
> +			spin_lock(&swap_lock);
> +			goto checks;
> +		}
>  		if (unlikely(--latency_ration < 0)) {
>  			cond_resched();
>  			latency_ration = LATENCY_LIMIT;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
