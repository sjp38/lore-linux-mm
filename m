Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7B0486B0035
	for <linux-mm@kvack.org>; Mon, 12 May 2014 07:12:02 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d49so4578808eek.1
        for <linux-mm@kvack.org>; Mon, 12 May 2014 04:12:01 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l44si10283796eem.13.2014.05.12.04.12.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 May 2014 04:12:01 -0700 (PDT)
Date: Mon, 12 May 2014 12:11:55 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/4] swap: change swap_list_head to plist, add
 swap_avail_head
Message-ID: <20140512111155.GM23991@suse.de>
References: <1397336454-13855-1-git-send-email-ddstreet@ieee.org>
 <1399057350-16300-1-git-send-email-ddstreet@ieee.org>
 <1399057350-16300-5-git-send-email-ddstreet@ieee.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1399057350-16300-5-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Weijie Yang <weijieut@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shaohua Li <shli@fusionio.com>

On Fri, May 02, 2014 at 03:02:30PM -0400, Dan Streetman wrote:
> Originally get_swap_page() started iterating through the singly-linked
> list of swap_info_structs using swap_list.next or highest_priority_index,
> which both were intended to point to the highest priority active swap
> target that was not full.  The first patch in this series changed the
> singly-linked list to a doubly-linked list, and removed the logic to start
> at the highest priority non-full entry; it starts scanning at the highest
> priority entry each time, even if the entry is full.
> 
> Replace the manually ordered swap_list_head with a plist, renamed to
> swap_active_head for clarity.  Add a new plist, swap_avail_head.
> The original swap_active_head plist contains all active swap_info_structs,
> as before, while the new swap_avail_head plist contains only
> swap_info_structs that are active and available, i.e. not full.
> Add a new spinlock, swap_avail_lock, to protect the swap_avail_head list.
> 
> Mel Gorman suggested using plists since they internally handle ordering
> the list entries based on priority, which is exactly what swap was doing
> manually.  All the ordering code is now removed, and swap_info_struct
> entries and simply added to their corresponding plist and automatically
> ordered correctly.
> 
> Using a new plist for available swap_info_structs simplifies and
> optimizes get_swap_page(), which no longer has to iterate over full
> swap_info_structs.  Using a new spinlock for swap_avail_head plist
> allows each swap_info_struct to add or remove themselves from the
> plist when they become full or not-full; previously they could not
> do so because the swap_info_struct->lock is held when they change
> from full<->not-full, and the swap_lock protecting the main
> swap_active_head must be ordered before any swap_info_struct->lock.
> 
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Shaohua Li <shli@fusionio.com>
> 
> ---
> 
> Mel, I tried moving the ordering and rotating code into common list functions
> and I also tried plists, and you were right, using plists is much simpler and
> more maintainable.  The only required update to plist is the plist_rotate()
> function, which is even simpler to use in get_swap_page() than the
> list_rotate_left() function.
> 
> After looking more closely at plists, I don't see how they would reduce
> performance, so I don't think there is any concern there, although Shaohua if
> you have time it might be nice to check this updated patch set's performance.
> I will note that if CONFIG_DEBUG_PI_LIST is set, there's quite a lot of list
> checking going on for each list modification including rotate; that config is
> set if "RT Mutex debugging, deadlock detection" is set, so I assume in that
> case overall system performance is expected to be less than optimal.
> 
> Also, I might have over-commented in this patch; if so I can remove/reduce
> some of it. :)
> 
> Changelog since v1 https://lkml.org/lkml/2014/4/12/73
>   -use plists instead of regular lists
>   -update/add comments
> 
>  include/linux/swap.h     |   3 +-
>  include/linux/swapfile.h |   2 +-
>  mm/frontswap.c           |   6 +-
>  mm/swapfile.c            | 142 +++++++++++++++++++++++++++++------------------
>  4 files changed, 94 insertions(+), 59 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 8bb85d6..9155bcd 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -214,7 +214,8 @@ struct percpu_cluster {
>  struct swap_info_struct {
>  	unsigned long	flags;		/* SWP_USED etc: see above */
>  	signed short	prio;		/* swap priority of this type */
> -	struct list_head list;		/* entry in swap list */
> +	struct plist_node list;		/* entry in swap_active_head */
> +	struct plist_node avail_list;	/* entry in swap_avail_head */
>  	signed char	type;		/* strange name for an index */
>  	unsigned int	max;		/* extent of the swap_map */
>  	unsigned char *swap_map;	/* vmalloc'ed array of usage counts */
> diff --git a/include/linux/swapfile.h b/include/linux/swapfile.h
> index 2eab382..388293a 100644
> --- a/include/linux/swapfile.h
> +++ b/include/linux/swapfile.h
> @@ -6,7 +6,7 @@
>   * want to expose them to the dozens of source files that include swap.h
>   */
>  extern spinlock_t swap_lock;
> -extern struct list_head swap_list_head;
> +extern struct plist_head swap_active_head;
>  extern struct swap_info_struct *swap_info[];
>  extern int try_to_unuse(unsigned int, bool, unsigned long);
>  
> diff --git a/mm/frontswap.c b/mm/frontswap.c
> index fae1160..c30eec5 100644
> --- a/mm/frontswap.c
> +++ b/mm/frontswap.c
> @@ -331,7 +331,7 @@ static unsigned long __frontswap_curr_pages(void)
>  	struct swap_info_struct *si = NULL;
>  
>  	assert_spin_locked(&swap_lock);
> -	list_for_each_entry(si, &swap_list_head, list)
> +	plist_for_each_entry(si, &swap_active_head, list)
>  		totalpages += atomic_read(&si->frontswap_pages);
>  	return totalpages;
>  }
> @@ -346,7 +346,7 @@ static int __frontswap_unuse_pages(unsigned long total, unsigned long *unused,
>  	unsigned long pages = 0, pages_to_unuse = 0;
>  
>  	assert_spin_locked(&swap_lock);
> -	list_for_each_entry(si, &swap_list_head, list) {
> +	plist_for_each_entry(si, &swap_active_head, list) {
>  		si_frontswap_pages = atomic_read(&si->frontswap_pages);
>  		if (total_pages_to_unuse < si_frontswap_pages) {
>  			pages = pages_to_unuse = total_pages_to_unuse;
> @@ -408,7 +408,7 @@ void frontswap_shrink(unsigned long target_pages)
>  	/*
>  	 * we don't want to hold swap_lock while doing a very
>  	 * lengthy try_to_unuse, but swap_list may change
> -	 * so restart scan from swap_list_head each time
> +	 * so restart scan from swap_active_head each time
>  	 */
>  	spin_lock(&swap_lock);
>  	ret = __frontswap_shrink(target_pages, &pages_to_unuse, &type);
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 6c95a8c..ec230e3 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -61,7 +61,22 @@ static const char Unused_offset[] = "Unused swap offset entry ";
>   * all active swap_info_structs
>   * protected with swap_lock, and ordered by priority.
>   */
> -LIST_HEAD(swap_list_head);
> +PLIST_HEAD(swap_active_head);
> +
> +/*
> + * all available (active, not full) swap_info_structs
> + * protected with swap_avail_lock, ordered by priority.
> + * This is used by get_swap_page() instead of swap_active_head
> + * because swap_active_head includes all swap_info_structs,
> + * but get_swap_page() doesn't need to look at full ones.
> + * This uses its own lock instead of swap_lock because when a
> + * swap_info_struct changes between not-full/full, it needs to
> + * add/remove itself to/from this list, but the swap_info_struct->lock
> + * is held and the locking order requires swap_lock to be taken
> + * before any swap_info_struct->lock.
> + */
> +static PLIST_HEAD(swap_avail_head);
> +static DEFINE_SPINLOCK(swap_avail_lock);
>  
>  struct swap_info_struct *swap_info[MAX_SWAPFILES];
>  
> @@ -594,6 +609,9 @@ checks:
>  	if (si->inuse_pages == si->pages) {
>  		si->lowest_bit = si->max;
>  		si->highest_bit = 0;
> +		spin_lock(&swap_avail_lock);
> +		plist_del(&si->avail_list, &swap_avail_head);
> +		spin_unlock(&swap_avail_lock);
>  	}
>  	si->swap_map[offset] = usage;
>  	inc_cluster_info_page(si, si->cluster_info, offset);
> @@ -645,57 +663,60 @@ swp_entry_t get_swap_page(void)
>  {
>  	struct swap_info_struct *si, *next;
>  	pgoff_t offset;
> -	struct list_head *tmp;
>  
> -	spin_lock(&swap_lock);
>  	if (atomic_long_read(&nr_swap_pages) <= 0)
>  		goto noswap;
>  	atomic_long_dec(&nr_swap_pages);
>  
> -	list_for_each(tmp, &swap_list_head) {
> -		si = list_entry(tmp, typeof(*si), list);
> +	spin_lock(&swap_avail_lock);
> +start_over:
> +	plist_for_each_entry_safe(si, next, &swap_avail_head, avail_list) {
> +		/* rotate si to tail of same-priority siblings */
> +		plist_rotate(&si->avail_list, &swap_avail_head);
> +		spin_unlock(&swap_avail_lock);
>  		spin_lock(&si->lock);
>  		if (!si->highest_bit || !(si->flags & SWP_WRITEOK)) {
> +			spin_lock(&swap_avail_lock);
> +			if (plist_node_empty(&si->avail_list)) {
> +				spin_unlock(&si->lock);
> +				goto nextsi;
> +			}

It's a corner case but rather than dropping the swap_avail_lock early and
retaking it to remove an entry from avail_list, you could just drop it
after this check but before the scan_swap_map. It's not a big deal so
whether you change this or not

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
