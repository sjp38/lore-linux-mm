Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0B3F06B0071
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 09:03:35 -0400 (EDT)
Received: by mail-la0-f53.google.com with SMTP id gq15so814873lab.12
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 06:03:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qr5si2532355lbb.54.2014.10.23.06.03.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Oct 2014 06:03:33 -0700 (PDT)
Date: Thu, 23 Oct 2014 15:03:31 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/2] mm: memcontrol: fix missed end-writeback page
 accounting
Message-ID: <20141023130331.GC23011@dhcp22.suse.cz>
References: <1414002568-21042-1-git-send-email-hannes@cmpxchg.org>
 <1414002568-21042-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1414002568-21042-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 22-10-14 14:29:28, Johannes Weiner wrote:
> 0a31bc97c80c ("mm: memcontrol: rewrite uncharge API") changed page
> migration to uncharge the old page right away.  The page is locked,
> unmapped, truncated, and off the LRU, but it could race with writeback
> ending, which then doesn't unaccount the page properly:
> 
> test_clear_page_writeback()              migration
>   acquire pc->mem_cgroup->move_lock

I do not think that mentioning move_lock is important/helpful here
because the hot path which is taken all the time (except when there is a
task move in progress) doesn't take it.
Besides that it is not even relevant for the race.

>                                            wait_on_page_writeback()
>   TestClearPageWriteback()
>                                            mem_cgroup_migrate()
>                                              clear PCG_USED
>   if (PageCgroupUsed(pc))
>     decrease memcg pages under writeback
>   release pc->mem_cgroup->move_lock
> 
> The per-page statistics interface is heavily optimized to avoid a
> function call and a lookup_page_cgroup() in the file unmap fast path,
> which means it doesn't verify whether a page is still charged before
> clearing PageWriteback() and it has to do it in the stat update later.
> 
> Rework it so that it looks up the page's memcg once at the beginning
> of the transaction and then uses it throughout.  The charge will be
> verified before clearing PageWriteback() and migration can't uncharge
> the page as long as that is still set.  The RCU lock will protect the
> memcg past uncharge.
> 
> As far as losing the optimization goes, the following test results are
> from a microbenchmark that maps, faults, and unmaps a 4GB sparse file
> three times in a nested fashion, so that there are two negative passes
> that don't account but still go through the new transaction overhead.
> There is no actual difference:
> 
> old:     33.195102545 seconds time elapsed       ( +-  0.01% )
> new:     33.199231369 seconds time elapsed       ( +-  0.03% )
> 
> The time spent in page_remove_rmap()'s callees still adds up to the
> same, but the time spent in the function itself seems reduced:
> 
>     # Children      Self  Command        Shared Object       Symbol
> old:     0.12%     0.11%  filemapstress  [kernel.kallsyms]   [k] page_remove_rmap
> new:     0.12%     0.08%  filemapstress  [kernel.kallsyms]   [k] page_remove_rmap
>
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: "3.17" <stable@kernel.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> ---
>  include/linux/memcontrol.h | 58 ++++++++++++++--------------------------------
>  mm/memcontrol.c            | 54 ++++++++++++++++++------------------------
>  mm/page-writeback.c        | 22 ++++++++++--------
>  mm/rmap.c                  | 20 ++++++++--------
>  4 files changed, 61 insertions(+), 93 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 0daf383f8f1c..ea007615e8f9 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -139,48 +139,23 @@ static inline bool mem_cgroup_disabled(void)
>  	return false;
>  }
>  
> -void __mem_cgroup_begin_update_page_stat(struct page *page, bool *locked,
> -					 unsigned long *flags);
> -
> -extern atomic_t memcg_moving;
> -
> -static inline void mem_cgroup_begin_update_page_stat(struct page *page,
> -					bool *locked, unsigned long *flags)
> -{
> -	if (mem_cgroup_disabled())
> -		return;
> -	rcu_read_lock();
> -	*locked = false;
> -	if (atomic_read(&memcg_moving))
> -		__mem_cgroup_begin_update_page_stat(page, locked, flags);
> -}
> -
> -void __mem_cgroup_end_update_page_stat(struct page *page,
> -				unsigned long *flags);
> -static inline void mem_cgroup_end_update_page_stat(struct page *page,
> -					bool *locked, unsigned long *flags)
> -{
> -	if (mem_cgroup_disabled())
> -		return;
> -	if (*locked)
> -		__mem_cgroup_end_update_page_stat(page, flags);
> -	rcu_read_unlock();
> -}
> -
> -void mem_cgroup_update_page_stat(struct page *page,
> -				 enum mem_cgroup_stat_index idx,
> -				 int val);
> -
> -static inline void mem_cgroup_inc_page_stat(struct page *page,
> +struct mem_cgroup *mem_cgroup_begin_page_stat(struct page *page, bool *locked,
> +					      unsigned long *flags);
> +void mem_cgroup_end_page_stat(struct mem_cgroup *memcg, bool locked,
> +			      unsigned long flags);
> +void mem_cgroup_update_page_stat(struct mem_cgroup *memcg,
> +				 enum mem_cgroup_stat_index idx, int val);
> +
> +static inline void mem_cgroup_inc_page_stat(struct mem_cgroup *memcg,
>  					    enum mem_cgroup_stat_index idx)
>  {
> -	mem_cgroup_update_page_stat(page, idx, 1);
> +	mem_cgroup_update_page_stat(memcg, idx, 1);
>  }
>  
> -static inline void mem_cgroup_dec_page_stat(struct page *page,
> +static inline void mem_cgroup_dec_page_stat(struct mem_cgroup *memcg,
>  					    enum mem_cgroup_stat_index idx)
>  {
> -	mem_cgroup_update_page_stat(page, idx, -1);
> +	mem_cgroup_update_page_stat(memcg, idx, -1);
>  }
>  
>  unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
> @@ -315,13 +290,14 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
>  {
>  }
>  
> -static inline void mem_cgroup_begin_update_page_stat(struct page *page,
> +static inline struct mem_cgroup *mem_cgroup_begin_page_stat(struct page *page,
>  					bool *locked, unsigned long *flags)
>  {
> +	return NULL;
>  }
>  
> -static inline void mem_cgroup_end_update_page_stat(struct page *page,
> -					bool *locked, unsigned long *flags)
> +static inline void mem_cgroup_end_page_stat(struct mem_cgroup *memcg,
> +					bool locked, unsigned long flags)
>  {
>  }
>  
> @@ -343,12 +319,12 @@ static inline bool mem_cgroup_oom_synchronize(bool wait)
>  	return false;
>  }
>  
> -static inline void mem_cgroup_inc_page_stat(struct page *page,
> +static inline void mem_cgroup_inc_page_stat(struct mem_cgroup *memcg,
>  					    enum mem_cgroup_stat_index idx)
>  {
>  }
>  
> -static inline void mem_cgroup_dec_page_stat(struct page *page,
> +static inline void mem_cgroup_dec_page_stat(struct mem_cgroup *memcg,
>  					    enum mem_cgroup_stat_index idx)
>  {
>  }
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 3a203c7ec6c7..d84f316ac901 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1463,12 +1463,8 @@ int mem_cgroup_swappiness(struct mem_cgroup *memcg)
>   *         start move here.
>   */
>  
> -/* for quick checking without looking up memcg */
> -atomic_t memcg_moving __read_mostly;
> -
>  static void mem_cgroup_start_move(struct mem_cgroup *memcg)
>  {
> -	atomic_inc(&memcg_moving);
>  	atomic_inc(&memcg->moving_account);
>  	synchronize_rcu();
>  }
> @@ -1479,10 +1475,8 @@ static void mem_cgroup_end_move(struct mem_cgroup *memcg)
>  	 * Now, mem_cgroup_clear_mc() may call this function with NULL.
>  	 * We check NULL in callee rather than caller.
>  	 */
> -	if (memcg) {
> -		atomic_dec(&memcg_moving);
> +	if (memcg)
>  		atomic_dec(&memcg->moving_account);
> -	}
>  }
>  
>  /*
> @@ -2132,26 +2126,32 @@ cleanup:
>   * account and taking the move_lock in the slowpath.
>   */
>  
> -void __mem_cgroup_begin_update_page_stat(struct page *page,
> -				bool *locked, unsigned long *flags)
> +struct mem_cgroup *mem_cgroup_begin_page_stat(struct page *page,
> +					      bool *locked,
> +					      unsigned long *flags)
>  {
>  	struct mem_cgroup *memcg;
>  	struct page_cgroup *pc;
>  
> +	rcu_read_lock();
> +
> +	if (mem_cgroup_disabled())
> +		return NULL;
> +
>  	pc = lookup_page_cgroup(page);
>  again:
>  	memcg = pc->mem_cgroup;
>  	if (unlikely(!memcg || !PageCgroupUsed(pc)))
> -		return;
> +		return NULL;
>  	/*
>  	 * If this memory cgroup is not under account moving, we don't
>  	 * need to take move_lock_mem_cgroup(). Because we already hold
>  	 * rcu_read_lock(), any calls to move_account will be delayed until
>  	 * rcu_read_unlock().
>  	 */
> -	VM_BUG_ON(!rcu_read_lock_held());
> +	*locked = false;
>  	if (atomic_read(&memcg->moving_account) <= 0)
> -		return;
> +		return memcg;
>  
>  	move_lock_mem_cgroup(memcg, flags);
>  	if (memcg != pc->mem_cgroup || !PageCgroupUsed(pc)) {
> @@ -2159,36 +2159,26 @@ again:
>  		goto again;
>  	}
>  	*locked = true;
> +
> +	return memcg;
>  }
>  
> -void __mem_cgroup_end_update_page_stat(struct page *page, unsigned long *flags)
> +void mem_cgroup_end_page_stat(struct mem_cgroup *memcg, bool locked,
> +			      unsigned long flags)
>  {
> -	struct page_cgroup *pc = lookup_page_cgroup(page);
> +	if (memcg && locked)
> +		move_unlock_mem_cgroup(memcg, &flags);
>  
> -	/*
> -	 * It's guaranteed that pc->mem_cgroup never changes while
> -	 * lock is held because a routine modifies pc->mem_cgroup
> -	 * should take move_lock_mem_cgroup().
> -	 */
> -	move_unlock_mem_cgroup(pc->mem_cgroup, flags);
> +	rcu_read_unlock();
>  }
>  
> -void mem_cgroup_update_page_stat(struct page *page,
> +void mem_cgroup_update_page_stat(struct mem_cgroup *memcg,
>  				 enum mem_cgroup_stat_index idx, int val)
>  {
> -	struct mem_cgroup *memcg;
> -	struct page_cgroup *pc = lookup_page_cgroup(page);
> -	unsigned long uninitialized_var(flags);
> -
> -	if (mem_cgroup_disabled())
> -		return;
> -
>  	VM_BUG_ON(!rcu_read_lock_held());
> -	memcg = pc->mem_cgroup;
> -	if (unlikely(!memcg || !PageCgroupUsed(pc)))
> -		return;
>  
> -	this_cpu_add(memcg->stat->count[idx], val);
> +	if (memcg)
> +		this_cpu_add(memcg->stat->count[idx], val);
>  }
>  
>  /*
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index ff6a5b07211e..19ceae87522d 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -2327,11 +2327,12 @@ EXPORT_SYMBOL(clear_page_dirty_for_io);
>  int test_clear_page_writeback(struct page *page)
>  {
>  	struct address_space *mapping = page_mapping(page);
> -	int ret;
> -	bool locked;
>  	unsigned long memcg_flags;
> +	struct mem_cgroup *memcg;
> +	bool locked;
> +	int ret;
>  
> -	mem_cgroup_begin_update_page_stat(page, &locked, &memcg_flags);
> +	memcg = mem_cgroup_begin_page_stat(page, &locked, &memcg_flags);
>  	if (mapping) {
>  		struct backing_dev_info *bdi = mapping->backing_dev_info;
>  		unsigned long flags;
> @@ -2352,22 +2353,23 @@ int test_clear_page_writeback(struct page *page)
>  		ret = TestClearPageWriteback(page);
>  	}
>  	if (ret) {
> -		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
> +		mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_WRITEBACK);
>  		dec_zone_page_state(page, NR_WRITEBACK);
>  		inc_zone_page_state(page, NR_WRITTEN);
>  	}
> -	mem_cgroup_end_update_page_stat(page, &locked, &memcg_flags);
> +	mem_cgroup_end_page_stat(memcg, locked, memcg_flags);
>  	return ret;
>  }
>  
>  int __test_set_page_writeback(struct page *page, bool keep_write)
>  {
>  	struct address_space *mapping = page_mapping(page);
> -	int ret;
> -	bool locked;
>  	unsigned long memcg_flags;
> +	struct mem_cgroup *memcg;
> +	bool locked;
> +	int ret;
>  
> -	mem_cgroup_begin_update_page_stat(page, &locked, &memcg_flags);
> +	memcg = mem_cgroup_begin_page_stat(page, &locked, &memcg_flags);
>  	if (mapping) {
>  		struct backing_dev_info *bdi = mapping->backing_dev_info;
>  		unsigned long flags;
> @@ -2394,10 +2396,10 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
>  		ret = TestSetPageWriteback(page);
>  	}
>  	if (!ret) {
> -		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
> +		mem_cgroup_inc_page_stat(memcg, MEM_CGROUP_STAT_WRITEBACK);
>  		inc_zone_page_state(page, NR_WRITEBACK);
>  	}
> -	mem_cgroup_end_update_page_stat(page, &locked, &memcg_flags);
> +	mem_cgroup_end_page_stat(memcg, locked, memcg_flags);
>  	return ret;
>  
>  }
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 116a5053415b..f574046f77d4 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1042,15 +1042,16 @@ void page_add_new_anon_rmap(struct page *page,
>   */
>  void page_add_file_rmap(struct page *page)
>  {
> -	bool locked;
> +	struct mem_cgroup *memcg;
>  	unsigned long flags;
> +	bool locked;
>  
> -	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
> +	memcg = mem_cgroup_begin_page_stat(page, &locked, &flags);
>  	if (atomic_inc_and_test(&page->_mapcount)) {
>  		__inc_zone_page_state(page, NR_FILE_MAPPED);
> -		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
> +		mem_cgroup_inc_page_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED);
>  	}
> -	mem_cgroup_end_update_page_stat(page, &locked, &flags);
> +	mem_cgroup_end_page_stat(memcg, locked, flags);
>  }
>  
>  /**
> @@ -1061,9 +1062,10 @@ void page_add_file_rmap(struct page *page)
>   */
>  void page_remove_rmap(struct page *page)
>  {
> +	struct mem_cgroup *uninitialized_var(memcg);
>  	bool anon = PageAnon(page);
> -	bool locked;
>  	unsigned long flags;
> +	bool locked;
>  
>  	/*
>  	 * The anon case has no mem_cgroup page_stat to update; but may
> @@ -1071,7 +1073,7 @@ void page_remove_rmap(struct page *page)
>  	 * we hold the lock against page_stat move: so avoid it on anon.
>  	 */
>  	if (!anon)
> -		mem_cgroup_begin_update_page_stat(page, &locked, &flags);
> +		memcg = mem_cgroup_begin_page_stat(page, &locked, &flags);
>  
>  	/* page still mapped by someone else? */
>  	if (!atomic_add_negative(-1, &page->_mapcount))
> @@ -1096,8 +1098,7 @@ void page_remove_rmap(struct page *page)
>  				-hpage_nr_pages(page));
>  	} else {
>  		__dec_zone_page_state(page, NR_FILE_MAPPED);
> -		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
> -		mem_cgroup_end_update_page_stat(page, &locked, &flags);
> +		mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED);
>  	}
>  	if (unlikely(PageMlocked(page)))
>  		clear_page_mlock(page);
> @@ -1110,10 +1111,9 @@ void page_remove_rmap(struct page *page)
>  	 * Leaving it set also helps swapoff to reinstate ptes
>  	 * faster for those pages still in swapcache.
>  	 */
> -	return;
>  out:
>  	if (!anon)
> -		mem_cgroup_end_update_page_stat(page, &locked, &flags);
> +		mem_cgroup_end_page_stat(memcg, locked, flags);
>  }
>  
>  /*
> -- 
> 2.1.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
