Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 3616F6B0034
	for <linux-mm@kvack.org>; Mon, 13 May 2013 10:59:01 -0400 (EDT)
Date: Mon, 13 May 2013 16:58:57 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 3/4] mm: support remove_mapping in irqcontext
Message-ID: <20130513145857.GD5246@dhcp22.suse.cz>
References: <1368411048-3753-1-git-send-email-minchan@kernel.org>
 <1368411048-3753-4-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1368411048-3753-4-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>

On Mon 13-05-13 11:10:47, Minchan Kim wrote:
[...]
> My rough plan is following as,
> 
> 1. Make mctz->lock beging aware of irq by changing spin_lock with
>    spin_lock_irqsave.

I wouldn't be worried about this one as it is on its way out with the
soft limit rework (the core uncontroversial part ;))

> 2. Introuduce new argument "locked" in __mem_cgroup_uncharge_common
>    so that __mem_cgroup_uncharge_common can avoid lock_page_cgroup in
>    irqcontext to avoid deadlock but caller in irqcontext should be held
>    it in advance by next patch.
> 3. Introduce try_lock_page_cgroup, which will be used __swapcache_free.
> 4. __remove_mapping can held a page_cgroup lock in advance before calling
>    __swapcache_free
> 
> I'd like to listen memcg people's opinions before diving into coding.

It should work. It will require some code moving, though.

> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  fs/splice.c          |  2 +-
>  include/linux/swap.h | 12 ++++++++++-
>  mm/swapfile.c        |  2 +-
>  mm/truncate.c        |  2 +-
>  mm/vmscan.c          | 56 +++++++++++++++++++++++++++++++++++++++++++---------
>  5 files changed, 61 insertions(+), 13 deletions(-)
> 
> diff --git a/fs/splice.c b/fs/splice.c
> index e6b2559..db77694 100644
> --- a/fs/splice.c
> +++ b/fs/splice.c
> @@ -70,7 +70,7 @@ static int page_cache_pipe_buf_steal(struct pipe_inode_info *pipe,
>  		 * If we succeeded in removing the mapping, set LRU flag
>  		 * and return good.
>  		 */
> -		if (remove_mapping(mapping, page)) {
> +		if (remove_mapping(mapping, page, false)) {
>  			buf->flags |= PIPE_BUF_FLAG_LRU;
>  			return 0;
>  		}
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index ca031f7..eb126d2 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -274,7 +274,8 @@ extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
>  						unsigned long *nr_scanned);
>  extern unsigned long shrink_all_memory(unsigned long nr_pages);
>  extern int vm_swappiness;
> -extern int remove_mapping(struct address_space *mapping, struct page *page);
> +extern int remove_mapping(struct address_space *mapping, struct page *page,
> +				bool irqcontext);
>  extern unsigned long vm_total_pages;
>  
>  #ifdef CONFIG_NUMA
> @@ -407,6 +408,9 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
>  }
>  #endif
>  
> +
> +extern struct swap_info_struct *swap_info_get(swp_entry_t entry);
> +
>  #else /* CONFIG_SWAP */
>  
>  #define get_nr_swap_pages()			0L
> @@ -430,6 +434,12 @@ static inline void show_swap_cache_info(void)
>  #define free_swap_and_cache(swp)	is_migration_entry(swp)
>  #define swapcache_prepare(swp)		is_migration_entry(swp)
>  
> +
> +struct swap_info_struct *swap_info_get(swp_entry_t entry)
> +{
> +	return NULL;
> +}
> +
>  static inline int add_swap_count_continuation(swp_entry_t swp, gfp_t gfp_mask)
>  {
>  	return 0;
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 33ebdd5..8a425d4 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -505,7 +505,7 @@ swp_entry_t get_swap_page_of_type(int type)
>  	return (swp_entry_t) {0};
>  }
>  
> -static struct swap_info_struct *swap_info_get(swp_entry_t entry)
> +struct swap_info_struct *swap_info_get(swp_entry_t entry)
>  {
>  	struct swap_info_struct *p;
>  	unsigned long offset, type;
> diff --git a/mm/truncate.c b/mm/truncate.c
> index c75b736..fa1dc60 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -131,7 +131,7 @@ invalidate_complete_page(struct address_space *mapping, struct page *page)
>  	if (page_has_private(page) && !try_to_release_page(page, 0))
>  		return 0;
>  
> -	ret = remove_mapping(mapping, page);
> +	ret = remove_mapping(mapping, page, false);
>  
>  	return ret;
>  }
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index fa6a853..d14c9be 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -450,12 +450,18 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
>   * Same as remove_mapping, but if the page is removed from the mapping, it
>   * gets returned with a refcount of 0.
>   */
> -static int __remove_mapping(struct address_space *mapping, struct page *page)
> +static int __remove_mapping(struct address_space *mapping, struct page *page,
> +				bool irqcontext)
>  {
> +	unsigned long flags;
> +
>  	BUG_ON(!PageLocked(page));
>  	BUG_ON(mapping != page_mapping(page));
>  
> -	spin_lock_irq(&mapping->tree_lock);
> +	if (irqcontext)
> +		spin_lock_irqsave(&mapping->tree_lock, flags);
> +	else
> +		spin_lock_irq(&mapping->tree_lock);
>  	/*
>  	 * The non racy check for a busy page.
>  	 *
> @@ -490,17 +496,45 @@ static int __remove_mapping(struct address_space *mapping, struct page *page)
>  	}
>  
>  	if (PageSwapCache(page)) {
> +		struct swap_info_struct *p;
>  		swp_entry_t swap = { .val = page_private(page) };
> +		p = swap_info_get(swap);
> +		/*
> +		 * If we are irq context, check that we can get a
> +		 * swap_info_strcut->lock before removing the page from
> +		 * swap cache. Because __swapcache_free must be successful.
> +		 * If __swapcache_free can be failed, we should rollback
> +		 * things done by __delete_from_swap_cache and it needs
> +		 * memory allocation for radix tree node in irqcontext
> +		 * That's thing we really want to avoid.
> +		 * TODO : memcg mem_cgroup_uncharge_swapcache handling
> +		 * in irqcontext
> +		 */
> +		if (irqcontext && p && !spin_trylock(&p->lock)) {
> +			page_unfreeze_refs(page, 2);
> +			goto cannot_free;
> +		}
> +
>  		__delete_from_swap_cache(page);
> -		spin_unlock_irq(&mapping->tree_lock);
> -		swapcache_free(swap, page);
> +		if (irqcontext) {
> +			spin_unlock_irqrestore(&mapping->tree_lock, flags);
> +			if (p)
> +				__swapcache_free(p, swap, page);
> +			spin_unlock(&p->lock);
> +		} else {
> +			spin_unlock_irq(&mapping->tree_lock);
> +			swapcache_free(swap, page);
> +		}
>  	} else {
>  		void (*freepage)(struct page *);
>  
>  		freepage = mapping->a_ops->freepage;
>  
>  		__delete_from_page_cache(page);
> -		spin_unlock_irq(&mapping->tree_lock);
> +		if (irqcontext)
> +			spin_unlock_irqrestore(&mapping->tree_lock, flags);
> +		else
> +			spin_unlock_irq(&mapping->tree_lock);
>  		mem_cgroup_uncharge_cache_page(page);
>  
>  		if (freepage != NULL)
> @@ -510,7 +544,10 @@ static int __remove_mapping(struct address_space *mapping, struct page *page)
>  	return 1;
>  
>  cannot_free:
> -	spin_unlock_irq(&mapping->tree_lock);
> +	if (irqcontext)
> +		spin_unlock_irqrestore(&mapping->tree_lock, flags);
> +	else
> +		spin_unlock_irq(&mapping->tree_lock);
>  	return 0;
>  }
>  
> @@ -520,9 +557,10 @@ cannot_free:
>   * successfully detached, return 1.  Assumes the caller has a single ref on
>   * this page.
>   */
> -int remove_mapping(struct address_space *mapping, struct page *page)
> +int remove_mapping(struct address_space *mapping, struct page *page,
> +			bool irqcontext)
>  {
> -	if (__remove_mapping(mapping, page)) {
> +	if (__remove_mapping(mapping, page, irqcontext)) {
>  		/*
>  		 * Unfreezing the refcount with 1 rather than 2 effectively
>  		 * drops the pagecache ref for us without requiring another
> @@ -904,7 +942,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			}
>  		}
>  
> -		if (!mapping || !__remove_mapping(mapping, page))
> +		if (!mapping || !__remove_mapping(mapping, page, false))
>  			goto keep_locked;
>  
>  		/*
> -- 
> 1.8.2.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
