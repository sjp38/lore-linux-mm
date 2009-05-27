Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3B3236B004F
	for <linux-mm@kvack.org>; Wed, 27 May 2009 02:45:05 -0400 (EDT)
Date: Wed, 27 May 2009 15:30:24 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 5/5] (experimental) chase and free cache only swap
Message-Id: <20090527153024.bb275962.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090527141442.d191dc2d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090526121259.b91b3e9d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090526121834.dd9a4193.kamezawa.hiroyu@jp.fujitsu.com>
	<20090527141442.d191dc2d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 27 May 2009 14:14:42 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 26 May 2009 12:18:34 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> This is a replacement for this. (just an idea, not testd.)
> 
> I think this works well. Does anyone has concerns ?
I think so too, except some trivial build errors ;)

I'll test it, but it will take a long time to see the effect of this patch
even if setting the swap space to reasonable size.


Thanks,
Daisuke Nishimura.

> Do I have to modify swap-cluster code to do this in sane way ?
> 
> ---
>  mm/swapfile.c |   40 ++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 40 insertions(+)
> 
> Index: new-trial-swapcount/mm/swapfile.c
> ===================================================================
> --- new-trial-swapcount.orig/mm/swapfile.c
> +++ new-trial-swapcount/mm/swapfile.c
> @@ -74,6 +74,26 @@ static inline unsigned short make_swap_c
>  	return ret;
>  }
>  
> +static int try_to_reuse_swap(struct swap_info_struct *si, unsigned long offset)
> +{
> +	int type = si - swap_info;
> +	swp_entry_t entry = swp_entry(type, offset);
> +	struct page *page;
> +
> +	page = find_get_page(page);
> +	if (!page)
> +		return 0;
> +	if (!trylock_page(page)) {
> +		page_cache_release(page);
> +		return 0;
> +	}
> +	try_to_free_swap(page);
> +	unlock_page(page);
> +	page_cache_release(page);
> +	return 1;
> +}
> +
> +
>  /*
>   * We need this because the bdev->unplug_fn can sleep and we cannot
>   * hold swap_lock while calling the unplug_fn. And swap_lock
> @@ -295,6 +315,18 @@ checks:
>  		goto no_page;
>  	if (offset > si->highest_bit)
>  		scan_base = offset = si->lowest_bit;
> +
> +	/* reuse swap entry of cache-only swap if not busy. */
> +	if (vm_swap_full() && si->swap_map[offset] == SWAP_HAS_CACHE) {
> +		int ret;
> +		spin_unlock(&swap_lock);
> +		ret = try_to_reuse_swap(si, offset));
> +		spin_lock(&swap_lock);
> +		if (ret)
> +			goto checks; /* we released swap_lock */
> +		goto scan;
> +	}
> +
>  	if (si->swap_map[offset])
>  		goto scan;
>  
> @@ -378,6 +410,10 @@ scan:
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
> @@ -389,6 +425,10 @@ scan:
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
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
