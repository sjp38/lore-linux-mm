Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id EF3C26B0005
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 01:16:46 -0500 (EST)
Date: Wed, 23 Jan 2013 15:16:45 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch 2/3 v2]swap: make each swap partition have one
 address_space
Message-ID: <20130123061645.GF2723@blaptop>
References: <20130122022951.GB12293@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130122022951.GB12293@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, riel@redhat.com

Looks good to me. Below just nitpicks.
I saw Andrew already took this into mmotm so I'm not sure he or you will do
next spin but anyway, review goes. Just nitpicks and a question.

On Tue, Jan 22, 2013 at 10:29:51AM +0800, Shaohua Li wrote:
> 
> When I use several fast SSD to do swap, swapper_space.tree_lock is heavily
> contended. This makes each swap partition have one address_space to reduce the
> lock contention. There is an array of address_space for swap. The swap entry
> type is the index to the array.
> 
> In my test with 3 SSD, this increases the swapout throughput 20%.
> 
> V1->V2: simplify code
> 
> Signed-off-by: Shaohua Li <shli@fusionio.com>

Acked-by: Minchan Kim <minchan@kernel.org>

> ---
>  fs/proc/meminfo.c    |    4 +--
>  include/linux/swap.h |    9 ++++----
>  mm/memcontrol.c      |    4 +--
>  mm/mincore.c         |    5 ++--
>  mm/swap.c            |    9 ++++++--
>  mm/swap_state.c      |   57 ++++++++++++++++++++++++++++++++++-----------------
>  mm/swapfile.c        |    5 ++--
>  mm/util.c            |   10 ++++++--
>  8 files changed, 68 insertions(+), 35 deletions(-)
> 
> Index: linux/include/linux/swap.h
> ===================================================================
> --- linux.orig/include/linux/swap.h	2013-01-22 09:13:14.000000000 +0800
> +++ linux/include/linux/swap.h	2013-01-22 09:34:44.923011706 +0800
> @@ -8,7 +8,7 @@
>  #include <linux/memcontrol.h>
>  #include <linux/sched.h>
>  #include <linux/node.h>
> -
> +#include <linux/fs.h>
>  #include <linux/atomic.h>
>  #include <asm/page.h>
>  
> @@ -330,8 +330,9 @@ int generic_swapfile_activate(struct swa
>  		sector_t *);
>  
>  /* linux/mm/swap_state.c */
> -extern struct address_space swapper_space;
> -#define total_swapcache_pages  swapper_space.nrpages
> +extern struct address_space swapper_spaces[];
> +#define swap_address_space(entry) (&swapper_spaces[swp_type(entry)])

How about this naming?

#define swapper_space(entry) (&swapper_spaces[swp_type(entry)])

> +extern unsigned long total_swapcache_pages(void);
>  extern void show_swap_cache_info(void);
>  extern int add_to_swap(struct page *);
>  extern int add_to_swap_cache(struct page *, swp_entry_t, gfp_t);
> @@ -382,7 +383,7 @@ mem_cgroup_uncharge_swapcache(struct pag
>  
>  #define nr_swap_pages				0L
>  #define total_swap_pages			0L
> -#define total_swapcache_pages			0UL
> +#define total_swapcache_pages()			0UL
>  
>  #define si_swapinfo(val) \
>  	do { (val)->freeswap = (val)->totalswap = 0; } while (0)
> Index: linux/mm/memcontrol.c
> ===================================================================
> --- linux.orig/mm/memcontrol.c	2013-01-22 09:13:14.000000000 +0800
Acked-by: Minchan Kim <minchan@kernel.org>

> +++ linux/mm/memcontrol.c	2013-01-22 09:29:29.374977700 +0800
> @@ -6279,7 +6279,7 @@ static struct page *mc_handle_swap_pte(s
>  	 * Because lookup_swap_cache() updates some statistics counter,
>  	 * we call find_get_page() with swapper_space directly.
>  	 */
> -	page = find_get_page(&swapper_space, ent.val);
> +	page = find_get_page(swap_address_space(ent), ent.val);
>  	if (do_swap_account)
>  		entry->val = ent.val;
>  
> @@ -6320,7 +6320,7 @@ static struct page *mc_handle_file_pte(s
>  		swp_entry_t swap = radix_to_swp_entry(page);
>  		if (do_swap_account)
>  			*entry = swap;
> -		page = find_get_page(&swapper_space, swap.val);
> +		page = find_get_page(swap_address_space(swap), swap.val);
>  	}
>  #endif
>  	return page;
> Index: linux/mm/mincore.c
> ===================================================================
> --- linux.orig/mm/mincore.c	2013-01-22 09:13:14.000000000 +0800
> +++ linux/mm/mincore.c	2013-01-22 09:29:29.378977649 +0800
> @@ -75,7 +75,7 @@ static unsigned char mincore_page(struct
>  	/* shmem/tmpfs may return swap: account for swapcache page too. */
>  	if (radix_tree_exceptional_entry(page)) {
>  		swp_entry_t swap = radix_to_swp_entry(page);
> -		page = find_get_page(&swapper_space, swap.val);
> +		page = find_get_page(swap_address_space(swap), swap.val);
>  	}
>  #endif
>  	if (page) {
> @@ -135,7 +135,8 @@ static void mincore_pte_range(struct vm_
>  			} else {
>  #ifdef CONFIG_SWAP
>  				pgoff = entry.val;
> -				*vec = mincore_page(&swapper_space, pgoff);
> +				*vec = mincore_page(swap_address_space(entry),
> +					pgoff);
>  #else
>  				WARN_ON(1);
>  				*vec = 1;
> Index: linux/mm/swap.c
> ===================================================================
> --- linux.orig/mm/swap.c	2013-01-22 09:13:14.000000000 +0800
> +++ linux/mm/swap.c	2013-01-22 09:29:29.378977649 +0800
> @@ -855,9 +855,14 @@ EXPORT_SYMBOL(pagevec_lookup_tag);
>  void __init swap_setup(void)
>  {
>  	unsigned long megs = totalram_pages >> (20 - PAGE_SHIFT);
> -
>  #ifdef CONFIG_SWAP
> -	bdi_init(swapper_space.backing_dev_info);
> +	int i;
> +
> +	for (i = 0; i < MAX_SWAPFILES; i++) {
> +		bdi_init(swapper_spaces[i].backing_dev_info);
> +		spin_lock_init(&swapper_spaces[i].tree_lock);
> +		INIT_LIST_HEAD(&swapper_spaces[i].i_mmap_nonlinear);
> +	}
>  #endif
>  
>  	/* Use a smaller cluster for small-memory machines */
> Index: linux/mm/swap_state.c
> ===================================================================
> --- linux.orig/mm/swap_state.c	2013-01-22 09:13:14.000000000 +0800
> +++ linux/mm/swap_state.c	2013-01-22 09:29:29.378977649 +0800
> @@ -36,12 +36,12 @@ static struct backing_dev_info swap_back
>  	.capabilities	= BDI_CAP_NO_ACCT_AND_WRITEBACK | BDI_CAP_SWAP_BACKED,
>  };
>  
> -struct address_space swapper_space = {
> -	.page_tree	= RADIX_TREE_INIT(GFP_ATOMIC|__GFP_NOWARN),
> -	.tree_lock	= __SPIN_LOCK_UNLOCKED(swapper_space.tree_lock),
> -	.a_ops		= &swap_aops,
> -	.i_mmap_nonlinear = LIST_HEAD_INIT(swapper_space.i_mmap_nonlinear),
> -	.backing_dev_info = &swap_backing_dev_info,
> +struct address_space swapper_spaces[MAX_SWAPFILES] = {
> +	[0 ... MAX_SWAPFILES - 1] = {
> +		.page_tree	= RADIX_TREE_INIT(GFP_ATOMIC|__GFP_NOWARN),
> +		.a_ops		= &swap_aops,
> +		.backing_dev_info = &swap_backing_dev_info,
> +	}
>  };
>  
>  #define INC_CACHE_INFO(x)	do { swap_cache_info.x++; } while (0)
> @@ -53,9 +53,19 @@ static struct {
>  	unsigned long find_total;
>  } swap_cache_info;
>  
> +unsigned long total_swapcache_pages(void)
> +{
> +	int i;
> +	unsigned long ret = 0;
> +
> +	for (i = 0; i < MAX_SWAPFILES; i++)
> +		ret += swapper_spaces[i].nrpages;
> +	return ret;
> +}
> +
>  void show_swap_cache_info(void)
>  {
> -	printk("%lu pages in swap cache\n", total_swapcache_pages);
> +	printk("%lu pages in swap cache\n", total_swapcache_pages());
>  	printk("Swap cache stats: add %lu, delete %lu, find %lu/%lu\n",
>  		swap_cache_info.add_total, swap_cache_info.del_total,
>  		swap_cache_info.find_success, swap_cache_info.find_total);
> @@ -70,23 +80,26 @@ void show_swap_cache_info(void)
>  static int __add_to_swap_cache(struct page *page, swp_entry_t entry)
>  {
>  	int error;
> +	struct address_space *address_space;
>  
>  	VM_BUG_ON(!PageLocked(page));
>  	VM_BUG_ON(PageSwapCache(page));
>  	VM_BUG_ON(!PageSwapBacked(page));
>  
>  	page_cache_get(page);
> -	SetPageSwapCache(page);
>  	set_page_private(page, entry.val);
> +	SetPageSwapCache(page);

Why did you move this line? Is there any special reason?

>  
> -	spin_lock_irq(&swapper_space.tree_lock);
> -	error = radix_tree_insert(&swapper_space.page_tree, entry.val, page);
> +	address_space = swap_address_space(entry);
> +	spin_lock_irq(&address_space->tree_lock);
> +	error = radix_tree_insert(&address_space->page_tree,
> +					entry.val, page);

How about introducing utility functions to hold a lock from entry?

lock_swapper_space(entry);
unlock_swapper_space(entry);

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
