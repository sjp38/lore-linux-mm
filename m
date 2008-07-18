Date: Fri, 18 Jul 2008 14:15:11 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [mmtom] please drop memcg-handle-swap-cache set (memcg handle
 swap cache rework).
Message-Id: <20080718141511.a28d1ba1.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080717124556.3e4b6e20.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080717124556.3e4b6e20.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Hi, Kamezawa-san.

On Thu, 17 Jul 2008 12:45:56 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Now, SwapCache is handled by memcg (in -mm) but it became complicated than I thought of.
> 
> followings are queued in -mm now.
>   memcg-handle-swap-cache.patch
>   memcg-handle-swap-cache-fix.patch
>   memcg-handle-swap-cache-fix-shmem-page-migration-incorrectness-on-memcgroup.patch
> 
> And I have memcg-handle-shmem-swap-cache-fix.patch....
> 
> Balbir argued that "This is too complicated!", ok, let's rework.
> 
> Andrew, could you drop above 3 patches ? I'd like to retry with clear logic.
> 
> I'm testing this new version now. Basic logic is not changed but corner case
> handling is clearer than previous one. If there is something unclear, 
> please tell me.  I'd like to write easy-to-understand one.
> 
> ==
> This patch tries to catch SwapCache usage by memcg in following Rule.
> 
> 1. just ignore add_to_swap_cache()
> 2. if a page is uncharged,
> 	(a) don't uncharge when PageSwapCache(page)
> 	(b) don't uncharge when the page is mapped.
> 	(c) don't uncharge when the page is still on radix-tree.
>             This can be checked by (page->mapping && !PageAnon(page))
> 
> 3. __delete_from_swap_cache() calles uncharge after clearing PageSwapCache flag.
> 4. mem_cgroup_uncharge_cache() is called only after page->mapping is cleared.
> 5. migration has some corner case and handled.
> 
> This is a replacement for
>   memcg-handle-swap-cache.patch
>   memcg-handle-swap-cache-fix.patch
>   memcg-handle-swap-cache-fix-shmem-page-migration-incorrectness-on-memcgroup.patch
> 
> And includes enhancements to cache shmem's SwapCache.
> 
> Changes:
>   - leave "rss" as "rss" (better name ?)
>   - for !page->mapping test (c), placement of callers of
>     mem_cgroup_uncharge_cache_page() is changed.
>   - add VM_BUG_ON(page->mapping) to mem_cgroup_uncharge_cache_page()
>   - shmem's SwapCache is also handled in sane way.
> 
> Concerns:
>   - shmem.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> 

I prefer this version, and it looks good to me.

>  mm/filemap.c    |    2 +-
>  mm/memcontrol.c |   14 ++++++++------
>  mm/migrate.c    |   22 +++++++++++++++++-----
>  mm/swap_state.c |    1 +
>  4 files changed, 27 insertions(+), 12 deletions(-)
> 
> Index: mmtom-stamp-2008-07-15-15-39/mm/filemap.c
> ===================================================================
> --- mmtom-stamp-2008-07-15-15-39.orig/mm/filemap.c
> +++ mmtom-stamp-2008-07-15-15-39/mm/filemap.c
> @@ -115,11 +115,11 @@ void __remove_from_page_cache(struct pag
>  {
>  	struct address_space *mapping = page->mapping;
>  
> -	mem_cgroup_uncharge_cache_page(page);
>  	radix_tree_delete(&mapping->page_tree, page->index);
>  	page->mapping = NULL;
>  	mapping->nrpages--;
>  	__dec_zone_page_state(page, NR_FILE_PAGES);
> +	mem_cgroup_uncharge_cache_page(page);
>  	BUG_ON(page_mapped(page));
>  
>  	/*
> Index: mmtom-stamp-2008-07-15-15-39/mm/memcontrol.c
> ===================================================================
> --- mmtom-stamp-2008-07-15-15-39.orig/mm/memcontrol.c
> +++ mmtom-stamp-2008-07-15-15-39/mm/memcontrol.c
> @@ -44,10 +44,10 @@ static struct kmem_cache *page_cgroup_ca
>   */
>  enum mem_cgroup_stat_index {
>  	/*
> -	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
> +	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss + swapcache.
>  	 */
>  	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
> -	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as rss */
> +	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as rss/swapcache */
>  	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
>  	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
>  
> @@ -697,10 +697,11 @@ __mem_cgroup_uncharge_common(struct page
>  		goto unlock;
>  
>  	VM_BUG_ON(pc->page != page);
> -
> -	if ((ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
> -	    && ((pc->flags & PAGE_CGROUP_FLAG_CACHE)
> -		|| page_mapped(page)))
> +	/* When this is called for removing a page cache in radix-tree,
> +	   page->mapping must be NULL before here. */
> +	if (likely(ctype != MEM_CGROUP_CHARGE_TYPE_FORCE))
> +	    if (PageSwapCache(page) || page_mapped(page)
> +	        || (page->mapping && !PageAnon(page)))
>  		goto unlock;
>  

I got checkpatch error/warning here.

I think this should be:

===
	if (likely(ctype != MEM_CGROUP_CHARGE_TYPE_FORCE))
		if (PageSwapCache(page) || page_mapped(page)
		    || (page->mapping && !PageAnon(page)))
 			goto unlock;
===

>  	mz = page_cgroup_zoneinfo(pc);
> @@ -729,6 +730,7 @@ void mem_cgroup_uncharge_page(struct pag
>  void mem_cgroup_uncharge_cache_page(struct page *page)
>  {
>  	VM_BUG_ON(page_mapped(page));
> +	VM_BUG_ON(page->mapping);
>  	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE);
>  }
>  
> Index: mmtom-stamp-2008-07-15-15-39/mm/migrate.c
> ===================================================================
> --- mmtom-stamp-2008-07-15-15-39.orig/mm/migrate.c
> +++ mmtom-stamp-2008-07-15-15-39/mm/migrate.c
> @@ -358,9 +358,6 @@ static int migrate_page_move_mapping(str
>  	__inc_zone_page_state(newpage, NR_FILE_PAGES);
>  
>  	write_unlock_irq(&mapping->tree_lock);
> -	if (!PageSwapCache(newpage)) {
> -		mem_cgroup_uncharge_cache_page(page);
> -	}
>  
>  	return 0;
>  }
> @@ -398,12 +395,27 @@ static void migrate_page_copy(struct pag
>   	}
>  
>  #ifdef CONFIG_SWAP
> -	ClearPageSwapCache(page);
> +	if (PageSwapCache(page)) {
> +		/*
> +		 * SwapCache is removed implicitly. To uncharge SwapCache,
> +		 * SwapCache flag should be cleared.
> +		 */
> +		ClearPageSwapCache(page);
> +		mem_cgroup_uncharge_page(page);
> +	}
>  #endif
>  	ClearPageActive(page);
>  	ClearPagePrivate(page);
>  	set_page_private(page, 0);
> -	page->mapping = NULL;
> +
> +	if (!PageAnon(page)) {
> +		/*
> +		 * This page was removed from radix-tree implicitly.
> +		 */
> +		page->mapping = NULL;
> +		mem_cgroup_uncharge_cache_page(page);
> +	} else
> +		page->mapping = NULL;
>  

page->mapping will be cleared anyway, so I prefer:

===
	page->mapping = NULL;

	if (!PageAnon(page))
		/*
		 * This page was removed from radix-tree implicitly.
		 */
		mem_cgroup_uncharge_cache_page(page);
===

>  	/*
>  	 * If any waiters have accumulated on the new page then
> Index: mmtom-stamp-2008-07-15-15-39/mm/swap_state.c
> ===================================================================
> --- mmtom-stamp-2008-07-15-15-39.orig/mm/swap_state.c
> +++ mmtom-stamp-2008-07-15-15-39/mm/swap_state.c
> @@ -110,6 +110,7 @@ void __delete_from_swap_cache(struct pag
>  	total_swapcache_pages--;
>  	__dec_zone_page_state(page, NR_FILE_PAGES);
>  	INC_CACHE_INFO(del_total);
> +	mem_cgroup_uncharge_page(page);
>  }
>  
>  /**


	Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
