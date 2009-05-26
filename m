Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8DDDD6B004D
	for <linux-mm@kvack.org>; Tue, 26 May 2009 13:37:56 -0400 (EDT)
Date: Tue, 26 May 2009 19:37:36 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC][PATCH 3/5] count cache-only swaps
Message-ID: <20090526173736.GA2843@cmpxchg.org>
References: <20090526121259.b91b3e9d.kamezawa.hiroyu@jp.fujitsu.com> <20090526121638.398c6951.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090526121638.398c6951.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, May 26, 2009 at 12:16:38PM +0900, KAMEZAWA Hiroyuki wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> This patch adds a counter for unused swap caches.
> Maybe useful to see "we're really under shortage of swap".
> 
> The value can be seen as kernel message at Sysrq-m etc.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/swap.h |    3 +++
>  mm/swap_state.c      |    2 ++
>  mm/swapfile.c        |   23 ++++++++++++++++++++---
>  3 files changed, 25 insertions(+), 3 deletions(-)
> 
> Index: new-trial-swapcount/include/linux/swap.h
> ===================================================================
> --- new-trial-swapcount.orig/include/linux/swap.h
> +++ new-trial-swapcount/include/linux/swap.h
> @@ -155,6 +155,7 @@ struct swap_info_struct {
>  	unsigned int max;
>  	unsigned int inuse_pages;
>  	unsigned int old_block_size;
> +	unsigned int cache_only;
>  };
>  
>  struct swap_list_t {
> @@ -298,6 +299,7 @@ extern struct page *swapin_readahead(swp
>  /* linux/mm/swapfile.c */
>  extern long nr_swap_pages;
>  extern long total_swap_pages;
> +extern long nr_cache_only_swaps;
>  extern void si_swapinfo(struct sysinfo *);
>  extern swp_entry_t get_swap_page(void);
>  extern swp_entry_t get_swap_page_of_type(int);
> @@ -358,6 +360,7 @@ static inline void mem_cgroup_uncharge_s
>  #define nr_swap_pages				0L
>  #define total_swap_pages			0L
>  #define total_swapcache_pages			0UL
> +#define nr_cache_only_swaps			0UL
>  
>  #define si_swapinfo(val) \
>  	do { (val)->freeswap = (val)->totalswap = 0; } while (0)
> Index: new-trial-swapcount/mm/swapfile.c
> ===================================================================
> --- new-trial-swapcount.orig/mm/swapfile.c
> +++ new-trial-swapcount/mm/swapfile.c
> @@ -39,6 +39,7 @@ static DEFINE_SPINLOCK(swap_lock);
>  static unsigned int nr_swapfiles;
>  long nr_swap_pages;
>  long total_swap_pages;
> +long nr_cache_only_swaps;
>  static int swap_overflow;
>  static int least_priority;
>  
> @@ -306,9 +307,11 @@ checks:
>  		si->lowest_bit = si->max;
>  		si->highest_bit = 0;
>  	}
> -	if (cache) /* at usual swap-out via vmscan.c */
> +	if (cache) {/* at usual swap-out via vmscan.c */
>  		si->swap_map[offset] = make_swap_count(0, 1);
> -	else /* at suspend */
> +		si->cache_only++;
> +		nr_cache_only_swaps++;
> +	} else /* at suspend */
>  		si->swap_map[offset] = make_swap_count(1, 0);
>  	si->cluster_next = offset + 1;
>  	si->flags -= SWP_SCANNING;
> @@ -513,7 +516,10 @@ static int swap_entry_free(struct swap_i
>  	} else { /* dropping swap cache flag */
>  		VM_BUG_ON(!has_cache);
>  		p->swap_map[offset] = make_swap_count(count, 0);
> -
> +		if (!count) {
> +			p->cache_only--;
> +			nr_cache_only_swaps--;
> +		}
>  	}
>  	/* return code. */
>  	count = p->swap_map[offset];
> @@ -529,6 +535,11 @@ static int swap_entry_free(struct swap_i
>  		p->inuse_pages--;
>  		mem_cgroup_uncharge_swap(ent);
>  	}
> +	if (swap_has_cache(count) && !swap_count(count)) {
> +		nr_cache_only_swaps++;
> +		p->cache_only++;
> +	}
> +
>  	return count;
>  }
>  
> @@ -1128,6 +1139,8 @@ static int try_to_unuse(unsigned int typ
>  		if (swap_count(*swap_map) == SWAP_MAP_MAX) {
>  			spin_lock(&swap_lock);
>  			*swap_map = make_swap_count(0, 1);
> +			si->cache_only++;
> +			nr_cache_only_swaps++;
>  			spin_unlock(&swap_lock);
>  			reset_overflow = 1;
>  		}
> @@ -2033,6 +2046,10 @@ static int __swap_duplicate(swp_entry_t 
>  		if (count < SWAP_MAP_MAX - 1) {
>  			p->swap_map[offset] = make_swap_count(count + 1,
>  							      has_cache);
> +			if (has_cache && !count) {
> +				p->cache_only--;
> +				nr_cache_only_swaps--;
> +			}
>  			result = 1;
>  		} else if (count <= SWAP_MAP_MAX) {
>  			if (swap_overflow++ < 5)
> Index: new-trial-swapcount/mm/swap_state.c
> ===================================================================
> --- new-trial-swapcount.orig/mm/swap_state.c
> +++ new-trial-swapcount/mm/swap_state.c
> @@ -63,6 +63,8 @@ void show_swap_cache_info(void)
>  		swap_cache_info.find_success, swap_cache_info.find_total);
>  	printk("Free swap  = %ldkB\n", nr_swap_pages << (PAGE_SHIFT - 10));
>  	printk("Total swap = %lukB\n", total_swap_pages << (PAGE_SHIFT - 10));
> +	printk("Cache only swap = %lukB\n",
> +	       nr_cache_only_swaps << (PAGE_SHIFT - 10));
>  }

This is shown rather seldomly (sysrq and oom), for that purpose two
counters are overkill.  Maybe remove the global one and sum up the
per-swapdevice counters on demand?

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
