Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id F26866B0006
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 18:24:34 -0500 (EST)
Date: Thu, 17 Jan 2013 15:24:33 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/2]swap: add per-partition lock for swapfile
Message-Id: <20130117152433.9ebfb0f2.akpm@linux-foundation.org>
In-Reply-To: <20121210012510.GB18570@kernel.org>
References: <20121210012510.GB18570@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, hughd@google.com, riel@redhat.com, minchan@kernel.org

On Mon, 10 Dec 2012 09:25:10 +0800
Shaohua Li <shli@kernel.org> wrote:

> swap_lock is heavily contended when I test swap to 3 fast SSD (even slightly
> slower than swap to 2 such SSD). The main contention comes from
> swap_info_get(). This patch tries to fix the gap with adding a new
> per-partition lock.
> 
> global data like nr_swapfiles, total_swap_pages, least_priority and swap_list are
> still protected by swap_lock.
> 
> nr_swap_pages is an atomic now, it can be changed without swap_lock. In theory,
> it's possible get_swap_page() finds no swap pages but actually there are free
> swap pages. But sounds not a big problem.
> 
> accessing partition specific data (like scan_swap_map and so on) is only
> protected by swap_info_struct.lock.
> 
> Changing swap_info_struct.flags need hold swap_lock and swap_info_struct.lock,
> because scan_scan_map() will check it. read the flags is ok with either the
> locks hold.
> 
> If both swap_lock and swap_info_struct.lock must be hold, we always hold the
> former first to avoid deadlock.
> 
> swap_entry_free() can change swap_list. To delete that code, we add a new
> highest_priority_index. Whenever get_swap_page() is called, we check it. If
> it's valid, we use it.
> 
> It's a pitty get_swap_page() still holds swap_lock(). But in practice,
> swap_lock() isn't heavily contended in my test with this patch (or I can say
> there are other much more heavier bottlenecks like TLB flush). And BTW, looks
> get_swap_page() doesn't really need the lock. We never free swap_info[] and we
> check SWAP_WRITEOK flag. The only risk without the lock is we could swapout to
> some low priority swap, but we can quickly recover after several rounds of
> swap, so sounds not a big deal to me. But I'd prefer to fix this if it's a real
> problem.
> 
> ...
>
> --- linux.orig/include/linux/swap.h	2012-12-10 09:02:45.029330611 +0800
> +++ linux/include/linux/swap.h	2012-12-10 09:02:56.101191464 +0800
> @@ -252,6 +252,7 @@ struct swap_info_struct {
>  	unsigned long *frontswap_map;	/* frontswap in-use, one bit per page */
>  	atomic_t frontswap_pages;	/* frontswap pages in-use counter */
>  #endif
> +	spinlock_t lock;
>  };

Please document the lock.  Describe what it protects and its ranking
rules.

>  struct swap_list_t {
> @@ -260,7 +261,8 @@ struct swap_list_t {
>  };
>  
>  /* Swap 50% full? Release swapcache more aggressively.. */
> -#define vm_swap_full() (nr_swap_pages*2 < total_swap_pages)
> +#define vm_swap_full() \
> +	(atomic_long_read(&nr_swap_pages)*2 < total_swap_pages)

May as well turn this into a real C function and move it to mm/internal.h.

>  /* linux/mm/page_alloc.c */
>  extern unsigned long totalram_pages;
> @@ -397,7 +399,7 @@ extern struct page *swapin_readahead(swp
>
> ...
>
> --- linux.orig/include/linux/swap.h	2012-12-10 09:02:45.029330611 +0800
> --- linux.orig/mm/swapfile.c	2012-12-10 09:02:45.037330401 +0800
> +++ linux/mm/swapfile.c	2012-12-10 09:02:56.101191464 +0800
> @@ -47,9 +47,11 @@ static sector_t map_swap_entry(swp_entry
>  
>  DEFINE_SPINLOCK(swap_lock);
>  static unsigned int nr_swapfiles;
> -long nr_swap_pages;
> +atomic_long_t nr_swap_pages;
> +/* protected with swap_lock. reading in vm_swap_full() doesn't need lock */
>  long total_swap_pages;
>  static int least_priority;
> +static atomic_t highest_priority_index = ATOMIC_INIT(-1);

Please document this variable.  What does it mean, what does it do.

>  static const char Bad_file[] = "Bad swap file entry ";
>  static const char Unused_file[] = "Unused swap file entry ";
>
> ...
>
> @@ -417,13 +419,31 @@ swp_entry_t get_swap_page(void)
>  	pgoff_t offset;
>  	int type, next;
>  	int wrapped = 0;
> +	int hp_index;
>  
>  	spin_lock(&swap_lock);
> -	if (nr_swap_pages <= 0)
> +	if (atomic_long_read(&nr_swap_pages) <= 0)
>  		goto noswap;
> -	nr_swap_pages--;
> +	atomic_long_dec(&nr_swap_pages);
>  
>  	for (type = swap_list.next; type >= 0 && wrapped < 2; type = next) {
> +		hp_index = atomic_xchg(&highest_priority_index, -1);
> +		/*
> +		 * highest_priority_index isn't protected by swap_lock, so it
> +		 * can be an invalid value if the corresponding swap is
> +		 * swapoff.

I don't understand this.  How can swap be swapoff?

> 		   We double check the flags here. It's even possible
> +		 * the swap is swapoff and swapon again and its priority is
> +		 * changed. In such rare case, low prority swap might be used,
> +		 * but eventually high priority swap will be used after several
> +		 * rounds of swap.
> +		 */
> +		if (hp_index != -1 && hp_index != type &&
> +		    swap_info[type]->prio < swap_info[hp_index]->prio &&
> +		    (swap_info[hp_index]->flags & SWP_WRITEOK)) {
> +			type = hp_index;
> +			swap_list.next = type;
> +		}
> +
>
> ...
>
> +static void set_highest_priority_index(int type)
> +{
> +	int old_hp_index, new_hp_index;
> +
> +	do {
> +		old_hp_index = atomic_read(&highest_priority_index);
> +		if (old_hp_index != -1 &&
> +			swap_info[old_hp_index]->prio >= swap_info[type]->prio)
> +			break;
> +		new_hp_index = type;
> +	} while (atomic_cmpxchg(&highest_priority_index,
> +		old_hp_index, new_hp_index) != old_hp_index);
> +}

Needs a covering comment explaining what it does and why it does it.

>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
