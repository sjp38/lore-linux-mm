Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id B68A76B0031
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 10:46:55 -0500 (EST)
Received: by mail-we0-f180.google.com with SMTP id u57so4423746wes.11
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 07:46:55 -0800 (PST)
Received: from mail-wg0-x234.google.com (mail-wg0-x234.google.com [2a00:1450:400c:c00::234])
        by mx.google.com with ESMTPS id mu4si6979117wib.87.2014.02.10.07.46.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Feb 2014 07:46:51 -0800 (PST)
Received: by mail-wg0-f52.google.com with SMTP id b13so4249569wgh.31
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 07:46:51 -0800 (PST)
Date: Mon, 10 Feb 2014 16:46:48 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] cgroup: use an ordered workqueue for cgroup destruction
Message-ID: <20140210154648.GM7117@dhcp22.suse.cz>
References: <alpine.LSU.2.11.1402061541560.31342@eggly.anvils>
 <20140207164321.GE6963@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140207164321.GE6963@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Filipe Brandenburger <filbranden@google.com>, Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Markus Blank-Burian <burian@muenster.de>, Shawn Bohrer <shawn.bohrer@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 07-02-14 11:43:21, Johannes Weiner wrote:
[...]
> Long-term, I think we may want to get rid of the reparenting in
> css_offline() entirely and only do it in the naturally ordered
> css_free() callback.  We only reparent in css_offline() because
> swapout records pin the css and we don't want to hang on to
> potentially gigabytes of unreclaimable (css_tryget() disabled) cache
> indefinitely until the last swapout records disappear.
> 
> So I'm currently mucking around with the following patch, which drops
> the css pin from swapout records and reparents them in css_free().
> It's lightly tested and there might well be dragons but I don't see
> any fundamental problems with it.
> 
> What do you think?

Hugh has posted something like this back in December
(http://marc.info/?l=linux-mm&m=138718299304670&w=2).
I am not entirely happy about scanning potentially huge amount of 
swap records.

A trivial optimization would check the memsw counter and break out early
but it would still leave a potentially full scan possible. I guess we
shouldn't care much about when css_free is called. I think we should
split the reparenting into two parts. LRU reparent without any hard
requirements and charges reparent which guarantees that nothing is left
behind.
The first one called css_offline and the second one from css_free.

kmem accounting pins memcg as well btw so taking care of swap is not
sufficient to guarantee an early css_free.

> ---
>  include/linux/page_cgroup.h |   8 ++++
>  mm/memcontrol.c             | 101 +++++++++++++-------------------------------
>  mm/page_cgroup.c            |  41 ++++++++++++++++++
>  3 files changed, 78 insertions(+), 72 deletions(-)
> 
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 777a524716db..3ededda8934f 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -111,6 +111,8 @@ extern unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
>  					unsigned short old, unsigned short new);
>  extern unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id);
>  extern unsigned short lookup_swap_cgroup_id(swp_entry_t ent);
> +extern unsigned long swap_cgroup_migrate(unsigned short old,
> +					 unsigned short new);
>  extern int swap_cgroup_swapon(int type, unsigned long max_pages);
>  extern void swap_cgroup_swapoff(int type);
>  #else
> @@ -127,6 +129,12 @@ unsigned short lookup_swap_cgroup_id(swp_entry_t ent)
>  	return 0;
>  }
>  
> +static inline unsigned long swap_cgroup_migrate(unsigned short old,
> +						unsigned short new)
> +{
> +	return 0;
> +}
> +
>  static inline int
>  swap_cgroup_swapon(int type, unsigned long max_pages)
>  {
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 53385cd4e6f0..e2a0d3986c74 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -892,11 +892,9 @@ static long mem_cgroup_read_stat(struct mem_cgroup *memcg,
>  	return val;
>  }
>  
> -static void mem_cgroup_swap_statistics(struct mem_cgroup *memcg,
> -					 bool charge)
> +static void mem_cgroup_swap_statistics(struct mem_cgroup *memcg, long nr_pages)
>  {
> -	int val = (charge) ? 1 : -1;
> -	this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_SWAP], val);
> +	this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_SWAP], nr_pages);
>  }
>  
>  static unsigned long mem_cgroup_read_events(struct mem_cgroup *memcg,
> @@ -4234,15 +4232,12 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype,
>  	 */
>  
>  	unlock_page_cgroup(pc);
> -	/*
> -	 * even after unlock, we have memcg->res.usage here and this memcg
> -	 * will never be freed, so it's safe to call css_get().
> -	 */
> +
>  	memcg_check_events(memcg, page);
> -	if (do_swap_account && ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT) {
> -		mem_cgroup_swap_statistics(memcg, true);
> -		css_get(&memcg->css);
> -	}
> +
> +	if (do_swap_account && ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
> +		mem_cgroup_swap_statistics(memcg, 1);
> +
>  	/*
>  	 * Migration does not charge the res_counter for the
>  	 * replacement page, so leave it alone when phasing out the
> @@ -4351,10 +4346,6 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
>  
>  	memcg = __mem_cgroup_uncharge_common(page, ctype, false);
>  
> -	/*
> -	 * record memcg information,  if swapout && memcg != NULL,
> -	 * css_get() was called in uncharge().
> -	 */
>  	if (do_swap_account && swapout && memcg)
>  		swap_cgroup_record(ent, mem_cgroup_id(memcg));
>  }
> @@ -4383,8 +4374,7 @@ void mem_cgroup_uncharge_swap(swp_entry_t ent)
>  		 */
>  		if (!mem_cgroup_is_root(memcg))
>  			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
> -		mem_cgroup_swap_statistics(memcg, false);
> -		css_put(&memcg->css);
> +		mem_cgroup_swap_statistics(memcg, -1);
>  	}
>  	rcu_read_unlock();
>  }
> @@ -4412,20 +4402,8 @@ static int mem_cgroup_move_swap_account(swp_entry_t entry,
>  	new_id = mem_cgroup_id(to);
>  
>  	if (swap_cgroup_cmpxchg(entry, old_id, new_id) == old_id) {
> -		mem_cgroup_swap_statistics(from, false);
> -		mem_cgroup_swap_statistics(to, true);
> -		/*
> -		 * This function is only called from task migration context now.
> -		 * It postpones res_counter and refcount handling till the end
> -		 * of task migration(mem_cgroup_clear_mc()) for performance
> -		 * improvement. But we cannot postpone css_get(to)  because if
> -		 * the process that has been moved to @to does swap-in, the
> -		 * refcount of @to might be decreased to 0.
> -		 *
> -		 * We are in attach() phase, so the cgroup is guaranteed to be
> -		 * alive, so we can just call css_get().
> -		 */
> -		css_get(&to->css);
> +		mem_cgroup_swap_statistics(from, -1);
> +		mem_cgroup_swap_statistics(to, 1);
>  		return 0;
>  	}
>  	return -EINVAL;
> @@ -6611,7 +6589,6 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
>  	kmem_cgroup_css_offline(memcg);
>  
>  	mem_cgroup_invalidate_reclaim_iterators(memcg);
> -	mem_cgroup_reparent_charges(memcg);
>  	mem_cgroup_destroy_all_caches(memcg);
>  	vmpressure_cleanup(&memcg->vmpressure);
>  }
> @@ -6619,41 +6596,26 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
>  static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> +	unsigned long swaps_moved;
> +	struct mem_cgroup *parent;
> +
>  	/*
> -	 * XXX: css_offline() would be where we should reparent all
> -	 * memory to prepare the cgroup for destruction.  However,
> -	 * memcg does not do css_tryget() and res_counter charging
> -	 * under the same RCU lock region, which means that charging
> -	 * could race with offlining.  Offlining only happens to
> -	 * cgroups with no tasks in them but charges can show up
> -	 * without any tasks from the swapin path when the target
> -	 * memcg is looked up from the swapout record and not from the
> -	 * current task as it usually is.  A race like this can leak
> -	 * charges and put pages with stale cgroup pointers into
> -	 * circulation:
> -	 *
> -	 * #0                        #1
> -	 *                           lookup_swap_cgroup_id()
> -	 *                           rcu_read_lock()
> -	 *                           mem_cgroup_lookup()
> -	 *                           css_tryget()
> -	 *                           rcu_read_unlock()
> -	 * disable css_tryget()
> -	 * call_rcu()
> -	 *   offline_css()
> -	 *     reparent_charges()
> -	 *                           res_counter_charge()
> -	 *                           css_put()
> -	 *                             css_free()
> -	 *                           pc->mem_cgroup = dead memcg
> -	 *                           add page to lru
> -	 *
> -	 * The bulk of the charges are still moved in offline_css() to
> -	 * avoid pinning a lot of pages in case a long-term reference
> -	 * like a swapout record is deferring the css_free() to long
> -	 * after offlining.  But this makes sure we catch any charges
> -	 * made after offlining:
> +	 * Migrate all swap entries to the parent.  There are no more
> +	 * references to the css, so no new swap out records can show
> +	 * up.  Any concurrently faulting pages will either get this
> +	 * offline cgroup and charge the faulting task, or get the
> +	 * migrated parent id and charge the parent for the in-memory
> +	 * page.  uncharge_swap() will balance the res_counter in the
> +	 * parent either way, whether it still fixes this group's
> +	 * res_counter is irrelevant at this point.
>  	 */
> +	parent = parent_mem_cgroup(memcg);
> +	if (!parent)
> +		parent = root_mem_cgroup;
> +	swaps_moved = swap_cgroup_migrate(mem_cgroup_id(memcg),
> +					  mem_cgroup_id(parent));
> +	mem_cgroup_swap_statistics(parent, swaps_moved);
> +
>  	mem_cgroup_reparent_charges(memcg);
>  
>  	memcg_destroy_kmem(memcg);
> @@ -6966,7 +6928,6 @@ static void __mem_cgroup_clear_mc(void)
>  {
>  	struct mem_cgroup *from = mc.from;
>  	struct mem_cgroup *to = mc.to;
> -	int i;
>  
>  	/* we must uncharge all the leftover precharges from mc.to */
>  	if (mc.precharge) {
> @@ -6981,16 +6942,13 @@ static void __mem_cgroup_clear_mc(void)
>  		__mem_cgroup_cancel_charge(mc.from, mc.moved_charge);
>  		mc.moved_charge = 0;
>  	}
> -	/* we must fixup refcnts and charges */
> +	/* we must fixup charges */
>  	if (mc.moved_swap) {
>  		/* uncharge swap account from the old cgroup */
>  		if (!mem_cgroup_is_root(mc.from))
>  			res_counter_uncharge(&mc.from->memsw,
>  						PAGE_SIZE * mc.moved_swap);
>  
> -		for (i = 0; i < mc.moved_swap; i++)
> -			css_put(&mc.from->css);
> -
>  		if (!mem_cgroup_is_root(mc.to)) {
>  			/*
>  			 * we charged both to->res and to->memsw, so we should
> @@ -6999,7 +6957,6 @@ static void __mem_cgroup_clear_mc(void)
>  			res_counter_uncharge(&mc.to->res,
>  						PAGE_SIZE * mc.moved_swap);
>  		}
> -		/* we've already done css_get(mc.to) */
>  		mc.moved_swap = 0;
>  	}
>  	memcg_oom_recover(from);
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index cfd162882c00..ca04feaae7fe 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -459,6 +459,47 @@ unsigned short lookup_swap_cgroup_id(swp_entry_t ent)
>  	return lookup_swap_cgroup(ent, NULL)->id;
>  }
>  
> +/**
> + * swap_cgroup_migrate - migrate all entries of one id to another
> + * @old: old id
> + * @new: new id
> + *
> + * Caller has to be able to deal with swapon/swapoff racing.
> + *
> + * Returns number of migrated entries.
> + */
> +unsigned long swap_cgroup_migrate(unsigned short old, unsigned short new)
> +{
> +	unsigned long migrated = 0;
> +	unsigned int type;
> +
> +	for (type = 0; type < MAX_SWAPFILES; type++) {
> +		struct swap_cgroup_ctrl *ctrl;
> +		unsigned long flags;
> +		unsigned int page;
> +
> +		ctrl = &swap_cgroup_ctrl[type];
> +		spin_lock_irqsave(&ctrl->lock, flags);
> +		for (page = 0; page < ctrl->length; page++) {
> +			struct swap_cgroup *base;
> +			pgoff_t offset;
> +
> +			base = page_address(ctrl->map[page]);
> +			for (offset = 0; offset < SC_PER_PAGE; offset++) {
> +				struct swap_cgroup *sc;
> +
> +				sc = base + offset;
> +				if (sc->id == old) {
> +					sc->id = new;
> +					migrated++;
> +				}
> +			}
> +		}
> +		spin_unlock_irqrestore(&ctrl->lock, flags);
> +	}
> +	return migrated;
> +}
> +
>  int swap_cgroup_swapon(int type, unsigned long max_pages)
>  {
>  	void *array;
> -- 
> 1.8.5.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
