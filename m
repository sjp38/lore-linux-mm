Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id C802C6B004D
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 11:46:01 -0500 (EST)
Date: Wed, 18 Jan 2012 17:45:58 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] [PATCH 4/7 v2] memcg: new scheme to update per-memcg page
 stat accounting.
Message-ID: <20120118164558.GI31112@tiehlicka.suse.cz>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
 <20120113174138.ec7b64d9.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120113174138.ec7b64d9.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Ying Han <yinghan@google.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Fri 13-01-12 17:41:38, KAMEZAWA Hiroyuki wrote:
[...]
> (And Dirty flag has another problem which cannot be handled by flag on
> page_cgroup.)

Is this imporatant for the patch?

> 
> I'd like to remove this flag because
>  - In recent discussions, removing pc->flags is our direction.
>  - This kind of duplication of flag/status is very bad and
>    it's better to use status in 'struct page'.
> 
> This patch is for removing page_cgroup's special flag for
> page-state accounting and for using 'struct page's status itself.

The patch doesn't seem to do so. It just enhances the semantics of the
locking for accounting.

> 
> This patch adds an atomic update support of page statistics accounting
> in memcg. In short, it prevents a page from being moved from a memcg
> to another while updating page status by...
> 
> 	locked = mem_cgroup_begin_update_page_stat(page)
>         modify page
>         mem_cgroup_update_page_stat(page)
>         mem_cgroup_end_update_page_stat(page, locked)
> 
> While begin_update_page_stat() ... end_update_page_stat(),
> the page_cgroup will never be moved to other memcg.
> 
> In usual case, overhead is rcu_read_lock() and rcu_read_unlock(),
> lookup_page_cgroup().
> 
> Note:
>  - I still now considering how to reduce overhead of this scheme.
>    Good idea is welcomed.

So the overhead is increased by one lookup_page_cgroup call, right?

> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I think we do not have many other choices than adding some kind of
locking around both normal and memcg pages updates so this looks like a
good approach.

> ---
>  include/linux/memcontrol.h |   36 ++++++++++++++++++++++++++++++++++
>  mm/memcontrol.c            |   46 ++++++++++++++++++++++++++-----------------
>  mm/rmap.c                  |   14 +++++++++++-
>  3 files changed, 76 insertions(+), 20 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 4d34356..976b58c 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -141,9 +141,35 @@ static inline bool mem_cgroup_disabled(void)
>  	return false;
>  }
>  
> +/*
> + * When we update page->flags,' we'll update some memcg's counter.
> + * Unlike vmstat, memcg has per-memcg stats and page-memcg relationship
> + * can be changed while 'struct page' information is updated.
> + * We need to prevent the race by
> + * 	locked = mem_cgroup_begin_update_page_stat(page)
> + * 	modify 'page'
> + * 	mem_cgroup_update_page_stat(page, idx, val)
> + * 	mem_cgroup_end_update_page_stat(page, locked);
> + */
> +bool __mem_cgroup_begin_update_page_stat(struct page *page);
> +static inline bool mem_cgroup_begin_update_page_stat(struct page *page)

The interface seems to be strange a bit. I would expect bool *locked
parameter because this is some kind of cookie. Return value might be
confusing.

> +{
> +	if (mem_cgroup_disabled())
> +		return false;
> +	return __mem_cgroup_begin_update_page_stat(page);
> +}
>  void mem_cgroup_update_page_stat(struct page *page,
>  				 enum mem_cgroup_page_stat_item idx,
>  				 int val);
> +void __mem_cgroup_end_update_page_stat(struct page *page, bool locked);
> +static inline void
> +mem_cgroup_end_update_page_stat(struct page *page, bool locked)
> +{
> +	if (mem_cgroup_disabled())
> +		return;
> +	__mem_cgroup_end_update_page_stat(page, locked);
> +}
> +
>  
>  static inline void mem_cgroup_inc_page_stat(struct page *page,
>  					    enum mem_cgroup_page_stat_item idx)
> @@ -356,6 +382,16 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
>  {
>  }
>  
> +static inline bool mem_cgroup_begin_update_page_stat(struct page *page)
> +{
> +	return false;
> +}
> +
> +static inline void
> +mem_cgroup_end_update_page_stat(struct page *page, bool locked)
> +{
> +}
> +
>  static inline void mem_cgroup_inc_page_stat(struct page *page,
>  					    enum mem_cgroup_page_stat_item idx)
>  {
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 61e276f..30ef810 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1912,29 +1912,43 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask)
>   * possibility of race condition. If there is, we take a lock.
>   */
>  
> +bool __mem_cgroup_begin_update_page_stat(struct page *page)
> +{
> +	struct page_cgroup *pc = lookup_page_cgroup(page);
> +	bool locked = false;
> +	struct mem_cgroup *memcg;
> +
> +	rcu_read_lock();
> +	memcg = pc->mem_cgroup;
> +
> +	if (!memcg || !PageCgroupUsed(pc))
> +		goto out;
> +	if (mem_cgroup_stealed(memcg)) {
> +		mem_cgroup_account_move_rlock(page);
> +		locked = true;
> +	}
> +out:
> +	return locked;
> +}
> +
> +void __mem_cgroup_end_update_page_stat(struct page *page, bool locked)
> +{
> +	if (locked)
> +		mem_cgroup_account_move_runlock(page);
> +	rcu_read_unlock();
> +}
> +
>  void mem_cgroup_update_page_stat(struct page *page,
>  				 enum mem_cgroup_page_stat_item idx, int val)
>  {
> -	struct mem_cgroup *memcg;
>  	struct page_cgroup *pc = lookup_page_cgroup(page);
> -	bool need_unlock = false;
> +	struct mem_cgroup *memcg = pc->mem_cgroup;
>  
>  	if (mem_cgroup_disabled())
>  		return;
>  
> -	rcu_read_lock();
> -	memcg = pc->mem_cgroup;
>  	if (unlikely(!memcg || !PageCgroupUsed(pc)))
> -		goto out;
> -	/* pc->mem_cgroup is unstable ? */
> -	if (unlikely(mem_cgroup_stealed(memcg))) {
> -		/* take a lock against to access pc->mem_cgroup */
> -		mem_cgroup_account_move_rlock(page);
> -		need_unlock = true;
> -		memcg = pc->mem_cgroup;
> -		if (!memcg || !PageCgroupUsed(pc))
> -			goto out;
> -	}
> +		return;
>  
>  	switch (idx) {
>  	case MEMCG_NR_FILE_MAPPED:
> @@ -1950,10 +1964,6 @@ void mem_cgroup_update_page_stat(struct page *page,
>  
>  	this_cpu_add(memcg->stat->count[idx], val);
>  
> -out:
> -	if (unlikely(need_unlock))
> -		mem_cgroup_account_move_runlock(page);
> -	rcu_read_unlock();
>  	return;
>  }
>  EXPORT_SYMBOL(mem_cgroup_update_page_stat);

We need to export mem_cgroup_{begin,end}_update_page_stat as well.
Btw. Why is this exported anyway?

> diff --git a/mm/rmap.c b/mm/rmap.c
> index aa547d4..def60d1 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1150,10 +1150,13 @@ void page_add_new_anon_rmap(struct page *page,
>   */
>  void page_add_file_rmap(struct page *page)
>  {
> +	bool locked = mem_cgroup_begin_update_page_stat(page);
> +
>  	if (atomic_inc_and_test(&page->_mapcount)) {
>  		__inc_zone_page_state(page, NR_FILE_MAPPED);
>  		mem_cgroup_inc_page_stat(page, MEMCG_NR_FILE_MAPPED);
>  	}
> +	mem_cgroup_end_update_page_stat(page, locked);
>  }
>  
>  /**
> @@ -1164,10 +1167,14 @@ void page_add_file_rmap(struct page *page)
>   */
>  void page_remove_rmap(struct page *page)
>  {
> +	bool locked = false;
> +
> +	if (!PageAnon(page))
> +		locked = mem_cgroup_begin_update_page_stat(page);

Doesn't look nice. We shouldn't care about which pages update stats at
this level...

> +
>  	/* page still mapped by someone else? */
>  	if (!atomic_add_negative(-1, &page->_mapcount))
> -		return;
> -
> +		goto out;
>  	/*
>  	 * Now that the last pte has gone, s390 must transfer dirty
>  	 * flag from storage key to struct page.  We can usually skip
> @@ -1204,6 +1211,9 @@ void page_remove_rmap(struct page *page)
>  	 * Leaving it set also helps swapoff to reinstate ptes
>  	 * faster for those pages still in swapcache.
>  	 */
> +out:
> +	if (!PageAnon(page))
> +		mem_cgroup_end_update_page_stat(page, locked);
>  }
>  
>  /*
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
