Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A47E76B008C
	for <linux-mm@kvack.org>; Wed, 27 May 2009 20:44:17 -0400 (EDT)
Date: Thu, 28 May 2009 09:41:57 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 2/5] add SWAP_HAS_CACHE flag to swap_map
Message-Id: <20090528094157.5c39ac57.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090526121547.ce866fe4.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090526121259.b91b3e9d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090526121547.ce866fe4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

> @@ -1969,17 +2017,33 @@ int swap_duplicate(swp_entry_t entry)
>  	offset = swp_offset(entry);
>  
>  	spin_lock(&swap_lock);
> -	if (offset < p->max && p->swap_map[offset]) {
> -		if (p->swap_map[offset] < SWAP_MAP_MAX - 1) {
> -			p->swap_map[offset]++;
> +
> +	if (unlikely(offset >= p->max))
> +		goto unlock_out;
> +
> +	count = swap_count(p->swap_map[offset]);
> +	has_cache = swap_has_cache(p->swap_map[offset]);
> +	if (cache) {
> +		/* set SWAP_HAS_CACHE if there is no cache and entry is used */
> +		if (!has_cache && count) {
Should we check !has_cache here ?

Concurrent read_swap_cache_async() might have set SWAP_HAS_CACHE, but not have added
a page to swap cache yet when find_get_page() was called.
add_to_swap_cache() would handle the race of concurrent read_swap_cache_async(),
but considering more, swapcache_free() at the end of the loop might dangerous in this case...
So I think it should be like:

	read_swap_cache_async()
		:
		valid = swapcache_prepare(entry);
		if (!valid)
			break;
		if (valid == -EAGAIN);
			continue;

to let the context that succeeded in swapcache_prepare() do add_to_swap_cache().


Thanks,
Daisuke Nishimura.

> +			p->swap_map[offset] = make_swap_count(count, 1);
> +			result = 1;
> +		}
> +	} else if (count || has_cache) {
> +		if (count < SWAP_MAP_MAX - 1) {
> +			p->swap_map[offset] = make_swap_count(count + 1,
> +							      has_cache);
>  			result = 1;
> -		} else if (p->swap_map[offset] <= SWAP_MAP_MAX) {
> +		} else if (count <= SWAP_MAP_MAX) {
>  			if (swap_overflow++ < 5)
> -				printk(KERN_WARNING "swap_dup: swap entry overflow\n");
> -			p->swap_map[offset] = SWAP_MAP_MAX;
> +				printk(KERN_WARNING
> +				       "swap_dup: swap entry overflow\n");
> +			p->swap_map[offset] = make_swap_count(SWAP_MAP_MAX,
> +							      has_cache);
>  			result = 1;
>  		}
>  	}
> +unlock_out:
>  	spin_unlock(&swap_lock);
>  out:
>  	return result;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
