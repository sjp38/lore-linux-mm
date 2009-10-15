Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A46F26B0055
	for <linux-mm@kvack.org>; Wed, 14 Oct 2009 22:40:01 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9F2dwAZ022895
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 15 Oct 2009 11:39:59 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C3A8145DE4E
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 11:39:58 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A403545DE4D
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 11:39:58 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 85FEB1DB803C
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 11:39:58 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E06D1DB803F
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 11:39:58 +0900 (JST)
Date: Thu, 15 Oct 2009 11:37:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/9] swap_info: SWAP_HAS_CACHE cleanups
Message-Id: <20091015113736.d46a6a8a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0910150150570.3291@sister.anvils>
References: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
	<Pine.LNX.4.64.0910150150570.3291@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 Oct 2009 01:52:27 +0100 (BST)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:

> Though swap_count() is useful, I'm finding that swap_has_cache() and
> encode_swapmap() obscure what happens in the swap_map entry, just at
> those points where I need to understand it.  Remove them, and pass
> more usable "usage" values to scan_swap_map(), swap_entry_free() and
> __swap_duplicate(), instead of the SWAP_MAP and SWAP_CACHE enum.
> 
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

I have no objectios to above.
I'll test, later. maybe no troubles.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
> 
>  include/linux/swap.h |    2 
>  mm/swapfile.c        |  155 ++++++++++++++++-------------------------
>  2 files changed, 65 insertions(+), 92 deletions(-)
> 
> --- si4/include/linux/swap.h	2009-10-14 21:26:22.000000000 +0100
> +++ si5/include/linux/swap.h	2009-10-14 21:26:42.000000000 +0100
> @@ -154,7 +154,7 @@ enum {
>  #define SWAP_MAP_MAX	0x7ffe
>  #define SWAP_MAP_BAD	0x7fff
>  #define SWAP_HAS_CACHE  0x8000		/* There is a swap cache of entry. */
> -#define SWAP_COUNT_MASK (~SWAP_HAS_CACHE)
> +
>  /*
>   * The in-memory structure used to track swap areas.
>   */
> --- si4/mm/swapfile.c	2009-10-14 21:26:32.000000000 +0100
> +++ si5/mm/swapfile.c	2009-10-14 21:26:42.000000000 +0100
> @@ -53,30 +53,9 @@ static struct swap_info_struct *swap_inf
>  
>  static DEFINE_MUTEX(swapon_mutex);
>  
> -/* For reference count accounting in swap_map */
> -/* enum for swap_map[] handling. internal use only */
> -enum {
> -	SWAP_MAP = 0,	/* ops for reference from swap users */
> -	SWAP_CACHE,	/* ops for reference from swap cache */
> -};
> -
>  static inline int swap_count(unsigned short ent)
>  {
> -	return ent & SWAP_COUNT_MASK;
> -}
> -
> -static inline bool swap_has_cache(unsigned short ent)
> -{
> -	return !!(ent & SWAP_HAS_CACHE);
> -}
> -
> -static inline unsigned short encode_swapmap(int count, bool has_cache)
> -{
> -	unsigned short ret = count;
> -
> -	if (has_cache)
> -		return SWAP_HAS_CACHE | ret;
> -	return ret;
> +	return ent & ~SWAP_HAS_CACHE;
>  }
>  
>  /* returns 1 if swap entry is freed */
> @@ -224,7 +203,7 @@ static int wait_for_discard(void *word)
>  #define LATENCY_LIMIT		256
>  
>  static inline unsigned long scan_swap_map(struct swap_info_struct *si,
> -					  int cache)
> +					  unsigned short usage)
>  {
>  	unsigned long offset;
>  	unsigned long scan_base;
> @@ -355,10 +334,7 @@ checks:
>  		si->lowest_bit = si->max;
>  		si->highest_bit = 0;
>  	}
> -	if (cache == SWAP_CACHE) /* at usual swap-out via vmscan.c */
> -		si->swap_map[offset] = encode_swapmap(0, true);
> -	else /* at suspend */
> -		si->swap_map[offset] = encode_swapmap(1, false);
> +	si->swap_map[offset] = usage;
>  	si->cluster_next = offset + 1;
>  	si->flags -= SWP_SCANNING;
>  
> @@ -483,7 +459,7 @@ swp_entry_t get_swap_page(void)
>  
>  		swap_list.next = next;
>  		/* This is called for allocating swap entry for cache */
> -		offset = scan_swap_map(si, SWAP_CACHE);
> +		offset = scan_swap_map(si, SWAP_HAS_CACHE);
>  		if (offset) {
>  			spin_unlock(&swap_lock);
>  			return swp_entry(type, offset);
> @@ -508,7 +484,7 @@ swp_entry_t get_swap_page_of_type(int ty
>  	if (si && (si->flags & SWP_WRITEOK)) {
>  		nr_swap_pages--;
>  		/* This is called for allocating swap entry, not cache */
> -		offset = scan_swap_map(si, SWAP_MAP);
> +		offset = scan_swap_map(si, 1);
>  		if (offset) {
>  			spin_unlock(&swap_lock);
>  			return swp_entry(type, offset);
> @@ -555,29 +531,31 @@ out:
>  	return NULL;
>  }
>  
> -static int swap_entry_free(struct swap_info_struct *p,
> -			   swp_entry_t ent, int cache)
> +static unsigned short swap_entry_free(struct swap_info_struct *p,
> +			   swp_entry_t entry, unsigned short usage)
>  {
> -	unsigned long offset = swp_offset(ent);
> -	int count = swap_count(p->swap_map[offset]);
> -	bool has_cache;
> +	unsigned long offset = swp_offset(entry);
> +	unsigned short count;
> +	unsigned short has_cache;
>  
> -	has_cache = swap_has_cache(p->swap_map[offset]);
> +	count = p->swap_map[offset];
> +	has_cache = count & SWAP_HAS_CACHE;
> +	count &= ~SWAP_HAS_CACHE;
>  
> -	if (cache == SWAP_MAP) { /* dropping usage count of swap */
> -		if (count < SWAP_MAP_MAX) {
> -			count--;
> -			p->swap_map[offset] = encode_swapmap(count, has_cache);
> -		}
> -	} else { /* dropping swap cache flag */
> +	if (usage == SWAP_HAS_CACHE) {
>  		VM_BUG_ON(!has_cache);
> -		p->swap_map[offset] = encode_swapmap(count, false);
> +		has_cache = 0;
> +	} else if (count < SWAP_MAP_MAX)
> +		count--;
> +
> +	if (!count)
> +		mem_cgroup_uncharge_swap(entry);
> +
> +	usage = count | has_cache;
> +	p->swap_map[offset] = usage;
>  
> -	}
> -	/* return code. */
> -	count = p->swap_map[offset];
>  	/* free if no reference */
> -	if (!count) {
> +	if (!usage) {
>  		if (offset < p->lowest_bit)
>  			p->lowest_bit = offset;
>  		if (offset > p->highest_bit)
> @@ -588,9 +566,8 @@ static int swap_entry_free(struct swap_i
>  		nr_swap_pages++;
>  		p->inuse_pages--;
>  	}
> -	if (!swap_count(count))
> -		mem_cgroup_uncharge_swap(ent);
> -	return count;
> +
> +	return usage;
>  }
>  
>  /*
> @@ -603,7 +580,7 @@ void swap_free(swp_entry_t entry)
>  
>  	p = swap_info_get(entry);
>  	if (p) {
> -		swap_entry_free(p, entry, SWAP_MAP);
> +		swap_entry_free(p, entry, 1);
>  		spin_unlock(&swap_lock);
>  	}
>  }
> @@ -614,19 +591,13 @@ void swap_free(swp_entry_t entry)
>  void swapcache_free(swp_entry_t entry, struct page *page)
>  {
>  	struct swap_info_struct *p;
> -	int ret;
> +	unsigned short count;
>  
>  	p = swap_info_get(entry);
>  	if (p) {
> -		ret = swap_entry_free(p, entry, SWAP_CACHE);
> -		if (page) {
> -			bool swapout;
> -			if (ret)
> -				swapout = true; /* the end of swap out */
> -			else
> -				swapout = false; /* no more swap users! */
> -			mem_cgroup_uncharge_swapcache(page, entry, swapout);
> -		}
> +		count = swap_entry_free(p, entry, SWAP_HAS_CACHE);
> +		if (page)
> +			mem_cgroup_uncharge_swapcache(page, entry, count != 0);
>  		spin_unlock(&swap_lock);
>  	}
>  }
> @@ -705,7 +676,7 @@ int free_swap_and_cache(swp_entry_t entr
>  
>  	p = swap_info_get(entry);
>  	if (p) {
> -		if (swap_entry_free(p, entry, SWAP_MAP) == SWAP_HAS_CACHE) {
> +		if (swap_entry_free(p, entry, 1) == SWAP_HAS_CACHE) {
>  			page = find_get_page(&swapper_space, entry.val);
>  			if (page && !trylock_page(page)) {
>  				page_cache_release(page);
> @@ -1213,7 +1184,7 @@ static int try_to_unuse(unsigned int typ
>  
>  		if (swap_count(*swap_map) == SWAP_MAP_MAX) {
>  			spin_lock(&swap_lock);
> -			*swap_map = encode_swapmap(0, true);
> +			*swap_map = SWAP_HAS_CACHE;
>  			spin_unlock(&swap_lock);
>  			reset_overflow = 1;
>  		}
> @@ -2112,16 +2083,16 @@ void si_swapinfo(struct sysinfo *val)
>   * - swap-cache reference is requested but there is already one. -> EEXIST
>   * - swap-cache reference is requested but the entry is not used. -> ENOENT
>   */
> -static int __swap_duplicate(swp_entry_t entry, bool cache)
> +static int __swap_duplicate(swp_entry_t entry, unsigned short usage)
>  {
>  	struct swap_info_struct *p;
>  	unsigned long offset, type;
> -	int result = -EINVAL;
> -	int count;
> -	bool has_cache;
> +	unsigned short count;
> +	unsigned short has_cache;
> +	int err = -EINVAL;
>  
>  	if (non_swap_entry(entry))
> -		return -EINVAL;
> +		goto out;
>  
>  	type = swp_type(entry);
>  	if (type >= nr_swapfiles)
> @@ -2130,54 +2101,56 @@ static int __swap_duplicate(swp_entry_t
>  	offset = swp_offset(entry);
>  
>  	spin_lock(&swap_lock);
> -
>  	if (unlikely(offset >= p->max))
>  		goto unlock_out;
>  
> -	count = swap_count(p->swap_map[offset]);
> -	has_cache = swap_has_cache(p->swap_map[offset]);
> +	count = p->swap_map[offset];
> +	has_cache = count & SWAP_HAS_CACHE;
> +	count &= ~SWAP_HAS_CACHE;
> +	err = 0;
>  
> -	if (cache == SWAP_CACHE) { /* called for swapcache/swapin-readahead */
> +	if (usage == SWAP_HAS_CACHE) {
>  
>  		/* set SWAP_HAS_CACHE if there is no cache and entry is used */
> -		if (!has_cache && count) {
> -			p->swap_map[offset] = encode_swapmap(count, true);
> -			result = 0;
> -		} else if (has_cache) /* someone added cache */
> -			result = -EEXIST;
> -		else if (!count) /* no users */
> -			result = -ENOENT;
> +		if (!has_cache && count)
> +			has_cache = SWAP_HAS_CACHE;
> +		else if (has_cache)		/* someone else added cache */
> +			err = -EEXIST;
> +		else				/* no users remaining */
> +			err = -ENOENT;
>  
>  	} else if (count || has_cache) {
> -		if (count < SWAP_MAP_MAX - 1) {
> -			p->swap_map[offset] = encode_swapmap(count + 1,
> -							     has_cache);
> -			result = 0;
> -		} else if (count <= SWAP_MAP_MAX) {
> +
> +		if (count < SWAP_MAP_MAX - 1)
> +			count++;
> +		else if (count <= SWAP_MAP_MAX) {
>  			if (swap_overflow++ < 5)
>  				printk(KERN_WARNING
>  				       "swap_dup: swap entry overflow\n");
> -			p->swap_map[offset] = encode_swapmap(SWAP_MAP_MAX,
> -							      has_cache);
> -			result = 0;
> -		}
> +			count = SWAP_MAP_MAX;
> +		} else
> +			err = -EINVAL;
>  	} else
> -		result = -ENOENT; /* unused swap entry */
> +		err = -ENOENT;			/* unused swap entry */
> +
> +	p->swap_map[offset] = count | has_cache;
> +
>  unlock_out:
>  	spin_unlock(&swap_lock);
>  out:
> -	return result;
> +	return err;
>  
>  bad_file:
>  	printk(KERN_ERR "swap_dup: %s%08lx\n", Bad_file, entry.val);
>  	goto out;
>  }
> +
>  /*
>   * increase reference count of swap entry by 1.
>   */
>  void swap_duplicate(swp_entry_t entry)
>  {
> -	__swap_duplicate(entry, SWAP_MAP);
> +	__swap_duplicate(entry, 1);
>  }
>  
>  /*
> @@ -2190,7 +2163,7 @@ void swap_duplicate(swp_entry_t entry)
>   */
>  int swapcache_prepare(swp_entry_t entry)
>  {
> -	return __swap_duplicate(entry, SWAP_CACHE);
> +	return __swap_duplicate(entry, SWAP_HAS_CACHE);
>  }
>  
>  /*
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
