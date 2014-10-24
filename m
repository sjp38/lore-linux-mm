Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id A5A916B0069
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 14:41:34 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id q5so1880234wiv.0
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 11:41:34 -0700 (PDT)
Received: from mail-wi0-x230.google.com (mail-wi0-x230.google.com. [2a00:1450:400c:c05::230])
        by mx.google.com with ESMTPS id de8si2704786wib.98.2014.10.24.11.41.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Oct 2014 11:41:33 -0700 (PDT)
Received: by mail-wi0-f176.google.com with SMTP id n3so1947835wiv.9
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 11:41:32 -0700 (PDT)
Date: Fri, 24 Oct 2014 20:41:30 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 3/3] mm: memcontrol: drop bogus RCU locking from
 mem_cgroup_same_or_subtree()
Message-ID: <20141024184130.GC18956@dhcp22.suse.cz>
References: <1414158589-26094-1-git-send-email-hannes@cmpxchg.org>
 <1414158589-26094-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1414158589-26094-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri 24-10-14 09:49:49, Johannes Weiner wrote:
> None of the mem_cgroup_same_or_subtree() callers actually require it
> to take the RCU lock, either because they hold it themselves or they
> have css references.  Remove it.
> 
> To make the API change clear, rename the leftover helper to
> mem_cgroup_is_descendant() to match cgroup_is_descendant().

Looks good.

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/memcontrol.h | 13 +++++-----
>  mm/memcontrol.c            | 59 +++++++++++++---------------------------------
>  mm/oom_kill.c              |  4 ++--
>  3 files changed, 24 insertions(+), 52 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index e32ab948f589..d4575a1d6e99 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -68,10 +68,9 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
>  struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
>  struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
>  
> -bool __mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
> -				  struct mem_cgroup *memcg);
> -bool task_in_mem_cgroup(struct task_struct *task,
> -			const struct mem_cgroup *memcg);
> +bool mem_cgroup_is_descendant(struct mem_cgroup *memcg,
> +			      struct mem_cgroup *root);
> +bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg);
>  
>  extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
>  extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
> @@ -79,8 +78,8 @@ extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
>  extern struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg);
>  extern struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *css);
>  
> -static inline
> -bool mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *memcg)
> +static inline bool mm_match_cgroup(struct mm_struct *mm,
> +				   struct mem_cgroup *memcg)
>  {
>  	struct mem_cgroup *task_memcg;
>  	bool match = false;
> @@ -88,7 +87,7 @@ bool mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *memcg)
>  	rcu_read_lock();
>  	task_memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
>  	if (task_memcg)
> -		match = __mem_cgroup_same_or_subtree(memcg, task_memcg);
> +		match = mem_cgroup_is_descendant(task_memcg, memcg);
>  	rcu_read_unlock();
>  	return match;
>  }
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 15b1c5110a8f..f75b92a44ac6 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1307,41 +1307,24 @@ void mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
>  	VM_BUG_ON((long)(*lru_size) < 0);
>  }
>  
> -/*
> - * Checks whether given mem is same or in the root_mem_cgroup's
> - * hierarchy subtree
> - */
> -bool __mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
> -				  struct mem_cgroup *memcg)
> +bool mem_cgroup_is_descendant(struct mem_cgroup *memcg, struct mem_cgroup *root)
>  {
> -	if (root_memcg == memcg)
> +	if (root == memcg)
>  		return true;
> -	if (!root_memcg->use_hierarchy)
> +	if (!root->use_hierarchy)
>  		return false;
> -	return cgroup_is_descendant(memcg->css.cgroup, root_memcg->css.cgroup);
> -}
> -
> -static bool mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
> -				       struct mem_cgroup *memcg)
> -{
> -	bool ret;
> -
> -	rcu_read_lock();
> -	ret = __mem_cgroup_same_or_subtree(root_memcg, memcg);
> -	rcu_read_unlock();
> -	return ret;
> +	return cgroup_is_descendant(memcg->css.cgroup, root->css.cgroup);
>  }
>  
> -bool task_in_mem_cgroup(struct task_struct *task,
> -			const struct mem_cgroup *memcg)
> +bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg)
>  {
> -	struct mem_cgroup *curr;
> +	struct mem_cgroup *task_memcg;
>  	struct task_struct *p;
>  	bool ret;
>  
>  	p = find_lock_task_mm(task);
>  	if (p) {
> -		curr = get_mem_cgroup_from_mm(p->mm);
> +		task_memcg = get_mem_cgroup_from_mm(p->mm);
>  		task_unlock(p);
>  	} else {
>  		/*
> @@ -1350,18 +1333,12 @@ bool task_in_mem_cgroup(struct task_struct *task,
>  		 * killed to prevent needlessly killing additional tasks.
>  		 */
>  		rcu_read_lock();
> -		curr = mem_cgroup_from_task(task);
> -		css_get(&curr->css);
> +		task_memcg = mem_cgroup_from_task(task);
> +		css_get(&task_memcg->css);
>  		rcu_read_unlock();
>  	}
> -	/*
> -	 * We should check use_hierarchy of "memcg" not "curr". Because checking
> -	 * use_hierarchy of "curr" here make this function true if hierarchy is
> -	 * enabled in "curr" and "curr" is a child of "memcg" in *cgroup*
> -	 * hierarchy(even if use_hierarchy is disabled in "memcg").
> -	 */
> -	ret = mem_cgroup_same_or_subtree(memcg, curr);
> -	css_put(&curr->css);
> +	ret = mem_cgroup_is_descendant(task_memcg, memcg);
> +	css_put(&task_memcg->css);
>  	return ret;
>  }
>  
> @@ -1446,8 +1423,8 @@ static bool mem_cgroup_under_move(struct mem_cgroup *memcg)
>  	if (!from)
>  		goto unlock;
>  
> -	ret = mem_cgroup_same_or_subtree(memcg, from)
> -		|| mem_cgroup_same_or_subtree(memcg, to);
> +	ret = mem_cgroup_is_descendant(from, memcg) ||
> +		mem_cgroup_is_descendant(to, memcg);
>  unlock:
>  	spin_unlock(&mc.lock);
>  	return ret;
> @@ -1813,12 +1790,8 @@ static int memcg_oom_wake_function(wait_queue_t *wait,
>  	oom_wait_info = container_of(wait, struct oom_wait_info, wait);
>  	oom_wait_memcg = oom_wait_info->memcg;
>  
> -	/*
> -	 * Both of oom_wait_info->memcg and wake_memcg are stable under us.
> -	 * Then we can use css_is_ancestor without taking care of RCU.
> -	 */
> -	if (!mem_cgroup_same_or_subtree(oom_wait_memcg, wake_memcg)
> -		&& !mem_cgroup_same_or_subtree(wake_memcg, oom_wait_memcg))
> +	if (!mem_cgroup_is_descendant(wake_memcg, oom_wait_memcg) &&
> +	    !mem_cgroup_is_descendant(oom_wait_memcg, wake_memcg))
>  		return 0;
>  	return autoremove_wake_function(wait, mode, sync, arg);
>  }
> @@ -2138,7 +2111,7 @@ static void drain_all_stock(struct mem_cgroup *root_memcg)
>  		memcg = stock->cached;
>  		if (!memcg || !stock->nr_pages)
>  			continue;
> -		if (!mem_cgroup_same_or_subtree(root_memcg, memcg))
> +		if (!mem_cgroup_is_descendant(memcg, root_memcg))
>  			continue;
>  		if (!test_and_set_bit(FLUSHING_CACHED_CHARGE, &stock->flags)) {
>  			if (cpu == curcpu)
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 3348280eef89..864bba992735 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -119,7 +119,7 @@ found:
>  
>  /* return true if the task is not adequate as candidate victim task. */
>  static bool oom_unkillable_task(struct task_struct *p,
> -		const struct mem_cgroup *memcg, const nodemask_t *nodemask)
> +		struct mem_cgroup *memcg, const nodemask_t *nodemask)
>  {
>  	if (is_global_init(p))
>  		return true;
> @@ -353,7 +353,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>   * State information includes task's pid, uid, tgid, vm size, rss, nr_ptes,
>   * swapents, oom_score_adj value, and name.
>   */
> -static void dump_tasks(const struct mem_cgroup *memcg, const nodemask_t *nodemask)
> +static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
>  {
>  	struct task_struct *p;
>  	struct task_struct *task;
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
