Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id E10356B004F
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 04:31:20 -0500 (EST)
Date: Thu, 8 Dec 2011 10:31:17 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [BUGFIX][PATCH v2] add mem_cgroup_replace_page_cache.
Message-ID: <20111208093117.GB9242@tiehlicka.suse.cz>
References: <20111206123923.1432ab52.kamezawa.hiroyu@jp.fujitsu.com>
 <20111207111455.GA18249@tiehlicka.suse.cz>
 <20111208161829.b6101de6.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111208161829.b6101de6.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Miklos Szeredi <mszeredi@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Thu 08-12-11 16:18:29, KAMEZAWA Hiroyuki wrote:
> On Wed, 7 Dec 2011 12:14:55 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > Other than that looks ok.
> > 
> 
> Thank you for review. v2 here. This patch is for the latest linux-next.
> ==
> From 82067c96323cf464d9b18867025414526fc7ce84 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 8 Dec 2011 16:31:15 +0900
> Subject: [PATCH] [BUGFIX][PATCH v2] memcg: add mem_cgroup_replace_page_cache() for fixing LRU issue.
> 
> commit ef6a3c6311 adds a function replace_page_cache_page(). This
> function replaces a page in radix-tree with a new page.
> At doing this, memory cgroup need to fix up the accounting information.
> memcg need to check PCG_USED bit etc.
> 
> In some(many?) case, 'newpage' is on LRU before calling replace_page_cache().
> So, memcg's LRU accounting information should be fixed, too.
> 
> This patch adds mem_cgroup_replace_page_cache() and removing old hooks.
> In that function, old pages will be unaccounted without touching res_counter
> and new page will be accounted to the memcg (of old page). At overwriting
> pc->mem_cgroup of newpage, take zone->lru_lock and avoid race with
> LRU handling.
> 
> Background:
>   replace_page_cache_page() is called by FUSE code in its splice() handling.
>   Here, 'newpage' is replacing oldpage but this newpage is not a newly allocated
>   page and may be on LRU. LRU mis-accounting will be critical for memory cgroup
>   because rmdir() checks the whole LRU is empty and there is no account leak.
>   If a page is on the other LRU than it should be, rmdir() will fail.
> 
> Changelog: v1 -> v2
>   - fixed mem_cgroup_disabled() check missing.
>   - added comments.
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Looks good now

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks
> ---
>  include/linux/memcontrol.h |    6 ++++++
>  mm/filemap.c               |   18 ++----------------
>  mm/memcontrol.c            |   44 ++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 52 insertions(+), 16 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 4b70e05..bd3b102 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -123,6 +123,8 @@ struct zone_reclaim_stat*
>  mem_cgroup_get_reclaim_stat_from_page(struct page *page);
>  extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
>  					struct task_struct *p);
> +extern void mem_cgroup_replace_page_cache(struct page *oldpage,
> +					struct page *newpage);
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
>  extern int do_swap_account;
> @@ -382,6 +384,10 @@ static inline
>  void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
>  {
>  }
> +static inline void mem_cgroup_replace_page_cache(struct page *oldpage,
> +				struct page *newpage)
> +{
> +}
>  #endif /* CONFIG_CGROUP_MEM_CONT */
>  
>  #if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)
> diff --git a/mm/filemap.c b/mm/filemap.c
> index a7b572b..4642211 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -393,24 +393,11 @@ EXPORT_SYMBOL(filemap_write_and_wait_range);
>  int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
>  {
>  	int error;
> -	struct mem_cgroup *memcg = NULL;
>  
>  	VM_BUG_ON(!PageLocked(old));
>  	VM_BUG_ON(!PageLocked(new));
>  	VM_BUG_ON(new->mapping);
>  
> -	/*
> -	 * This is not page migration, but prepare_migration and
> -	 * end_migration does enough work for charge replacement.
> -	 *
> -	 * In the longer term we probably want a specialized function
> -	 * for moving the charge from old to new in a more efficient
> -	 * manner.
> -	 */
> -	error = mem_cgroup_prepare_migration(old, new, &memcg, gfp_mask);
> -	if (error)
> -		return error;
> -
>  	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
>  	if (!error) {
>  		struct address_space *mapping = old->mapping;
> @@ -432,13 +419,12 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
>  		if (PageSwapBacked(new))
>  			__inc_zone_page_state(new, NR_SHMEM);
>  		spin_unlock_irq(&mapping->tree_lock);
> +		/* mem_cgroup codes must not be called under tree_lock */
> +		mem_cgroup_replace_page_cache(old, new);
>  		radix_tree_preload_end();
>  		if (freepage)
>  			freepage(old);
>  		page_cache_release(old);
> -		mem_cgroup_end_migration(memcg, old, new, true);
> -	} else {
> -		mem_cgroup_end_migration(memcg, old, new, false);
>  	}
>  
>  	return error;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8880a32..52edaef 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3306,6 +3306,50 @@ void mem_cgroup_end_migration(struct mem_cgroup *memcg,
>  	cgroup_release_and_wakeup_rmdir(&memcg->css);
>  }
>  
> +/*
> + * At replace page cache, newpage is not under any memcg but it's on
> + * LRU. So, this function doesn't touch res_counter but handles LRU
> + * in correct way. Both pages are locked so we cannot race with uncharge.
> + */
> +void mem_cgroup_replace_page_cache(struct page *oldpage,
> +				  struct page *newpage)
> +{
> +	struct mem_cgroup *memcg;
> +	struct page_cgroup *pc;
> +	struct zone *zone;
> +	enum charge_type type = MEM_CGROUP_CHARGE_TYPE_CACHE;
> +	unsigned long flags;
> +
> +	if (mem_cgroup_disabled())
> +		return;
> +
> +	pc = lookup_page_cgroup(oldpage);
> +	/* fix accounting on old pages */
> +	lock_page_cgroup(pc);
> +	memcg = pc->mem_cgroup;
> +	mem_cgroup_charge_statistics(memcg, PageCgroupCache(pc), -1);
> +	ClearPageCgroupUsed(pc);
> +	unlock_page_cgroup(pc);
> +
> +	if (PageSwapBacked(oldpage))
> +		type = MEM_CGROUP_CHARGE_TYPE_SHMEM;
> +
> +	zone = page_zone(newpage);
> +	pc = lookup_page_cgroup(newpage);
> +	/*
> +	 * Even if newpage->mapping was NULL before starting replacement,
> +	 * the newpage may be on LRU(or pagevec for LRU) already. We lock
> +	 * LRU while we overwrite pc->mem_cgroup.
> +	 */
> +	spin_lock_irqsave(&zone->lru_lock, flags);
> +	if (PageLRU(newpage))
> +		del_page_from_lru_list(zone, newpage, page_lru(newpage));
> +	__mem_cgroup_commit_charge(memcg, newpage, 1, pc, type);
> +	if (PageLRU(newpage))
> +		add_page_to_lru_list(zone, newpage, page_lru(newpage));
> +	spin_unlock_irqrestore(&zone->lru_lock, flags);
> +}
> +
>  #ifdef CONFIG_DEBUG_VM
>  static struct page_cgroup *lookup_page_cgroup_used(struct page *page)
>  {
> -- 
> 1.7.4.1
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
