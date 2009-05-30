Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2C3916B007E
	for <linux-mm@kvack.org>; Sat, 30 May 2009 02:10:08 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4U666h1008529
	for <linux-mm@kvack.org>; Sat, 30 May 2009 02:06:06 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4U6ADnV257962
	for <linux-mm@kvack.org>; Sat, 30 May 2009 02:10:13 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4U6ADR2022053
	for <linux-mm@kvack.org>; Sat, 30 May 2009 02:10:13 -0400
Date: Sat, 30 May 2009 14:10:08 +0800
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/4] modify swap_map and add SWAP_HAS_CACHE flag.
Message-ID: <20090530061008.GE24073@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090528135455.0c83bedc.kamezawa.hiroyu@jp.fujitsu.com> <20090528141900.c93fe1d5.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090528141900.c93fe1d5.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-05-28 14:19:00]:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> This is a part of patches for fixing memcg's swap account leak. But, IMHO,
> not a bad patch even if no memcg.
> 
> Now, reference to swap is counted by swap_map[], an array of unsigned short.
> There are 2 kinds of references to swap.
>  - reference from swap entry
>  - reference from swap cache
> Then, 
>  - If there is swap cache && swap's refcnt is 1, there is only swap cache.
>   (*) swapcount(entry) == 1 && find_get_page(swapper_space, entry) != NULL
> 
> This counting logic have worked well for a long time. But considering that
> we cannot know there is a _real_ reference or not by swap_map[], current usage
> of counter is not very good.
> 
> This patch adds a flag SWAP_HAS_CACHE and recored information that a swap entry
> has a cache or not. This will remove -1 magic used in swapfile.c and be a help
> to avoid unnecessary find_get_page().
> 
> Changelog: v1->v2
>  - fixed swapcache_prepare()'s return code.
>  - changed swap_duplicate() be void function.
>  - fixed racy case in swapoff().
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/swap.h |   14 ++-
>  mm/swap_state.c      |    5 +
>  mm/swapfile.c        |  203 ++++++++++++++++++++++++++++++++++++---------------
>  3 files changed, 160 insertions(+), 62 deletions(-)
> 
> Index: new-trial-swapcount2/include/linux/swap.h
> ===================================================================
> --- new-trial-swapcount2.orig/include/linux/swap.h
> +++ new-trial-swapcount2/include/linux/swap.h
> @@ -129,9 +129,10 @@ enum {
> 
>  #define SWAP_CLUSTER_MAX 32
> 
> -#define SWAP_MAP_MAX	0x7fff
> -#define SWAP_MAP_BAD	0x8000
> -
> +#define SWAP_MAP_MAX	0x7ffe
> +#define SWAP_MAP_BAD	0x7fff
> +#define SWAP_HAS_CACHE  0x8000		/* There is a swap cache of entry. */

Why count, can't we use swp->flags?

> +#define SWAP_COUNT_MASK (~SWAP_HAS_CACHE)
>  /*
>   * The in-memory structure used to track swap areas.
>   */
> @@ -300,7 +301,7 @@ extern long total_swap_pages;
>  extern void si_swapinfo(struct sysinfo *);
>  extern swp_entry_t get_swap_page(void);
>  extern swp_entry_t get_swap_page_of_type(int);
> -extern int swap_duplicate(swp_entry_t);
> +extern void swap_duplicate(swp_entry_t);
>  extern int swapcache_prepare(swp_entry_t);
>  extern int valid_swaphandles(swp_entry_t, unsigned long *);
>  extern void swap_free(swp_entry_t);
> @@ -372,9 +373,12 @@ static inline void show_swap_cache_info(
>  }
> 
>  #define free_swap_and_cache(swp)	is_migration_entry(swp)
> -#define swap_duplicate(swp)		is_migration_entry(swp)
>  #define swapcache_prepare(swp)		is_migration_entry(swp)
> 
> +static inline void swap_duplicate(swp_entry_t swp)
> +{
> +}
> +
>  static inline void swap_free(swp_entry_t swp)
>  {
>  }
> Index: new-trial-swapcount2/mm/swapfile.c
> ===================================================================
> --- new-trial-swapcount2.orig/mm/swapfile.c
> +++ new-trial-swapcount2/mm/swapfile.c
> @@ -53,6 +53,26 @@ static struct swap_info_struct swap_info
> 
>  static DEFINE_MUTEX(swapon_mutex);
> 
> +/* For reference count accounting in swap_map */
> +static inline int swap_count(unsigned short ent)
> +{
> +	return ent & SWAP_COUNT_MASK;
> +}
> +
> +static inline int swap_has_cache(unsigned short ent)
> +{
> +	return ent & SWAP_HAS_CACHE;
> +}
> +
> +static inline unsigned short make_swap_count(int count, int has_cache)
> +{
> +	unsigned short ret = count;
> +
> +	if (has_cache)
> +		return SWAP_HAS_CACHE | ret;
> +	return ret;
> +}

make_swap_count() does not make too much sense in terms of the name
for the function. Should it be called generate_swap_count or
assign_swap_count_info?

> +
>  /*
>   * We need this because the bdev->unplug_fn can sleep and we cannot
>   * hold swap_lock while calling the unplug_fn. And swap_lock
> @@ -167,7 +187,8 @@ static int wait_for_discard(void *word)
>  #define SWAPFILE_CLUSTER	256
>  #define LATENCY_LIMIT		256
> 
> -static inline unsigned long scan_swap_map(struct swap_info_struct *si)
> +static inline unsigned long scan_swap_map(struct swap_info_struct *si,
> +					  int cache)

Can we please use bool for readability or even better an enum?

Looks good at first glance otherwise. I think distinguishing between
the counts is good, but also complex. Overall the patch is useful.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
