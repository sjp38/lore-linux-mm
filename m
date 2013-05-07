Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 09F6B6B007D
	for <linux-mm@kvack.org>; Tue,  7 May 2013 10:46:23 -0400 (EDT)
Date: Tue, 7 May 2013 16:46:19 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, memcg: don't take task_lock in task_in_mem_cgroup
Message-ID: <20130507144619.GE9497@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1305030948180.30223@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1305030948180.30223@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 03-05-13 09:49:49, David Rientjes wrote:
> For processes that have detached their mm's, task_in_mem_cgroup()
> unnecessarily takes task_lock() when rcu_read_lock() is all that is
> necessary to call mem_cgroup_from_task().
> 
> While we're here, switch task_in_mem_cgroup() to return bool.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Well spotted!
Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks

> ---
>  include/linux/memcontrol.h |  9 +++++----
>  mm/memcontrol.c            | 11 ++++++-----
>  2 files changed, 11 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -77,7 +77,8 @@ extern void mem_cgroup_uncharge_cache_page(struct page *page);
>  
>  bool __mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
>  				  struct mem_cgroup *memcg);
> -int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg);
> +bool task_in_mem_cgroup(struct task_struct *task,
> +			const struct mem_cgroup *memcg);
>  
>  extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
>  extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
> @@ -273,10 +274,10 @@ static inline bool mm_match_cgroup(struct mm_struct *mm,
>  	return true;
>  }
>  
> -static inline int task_in_mem_cgroup(struct task_struct *task,
> -				     const struct mem_cgroup *memcg)
> +static inline bool task_in_mem_cgroup(struct task_struct *task,
> +				      const struct mem_cgroup *memcg)
>  {
> -	return 1;
> +	return true;
>  }
>  
>  static inline struct cgroup_subsys_state
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1443,11 +1443,12 @@ static bool mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
>  	return ret;
>  }
>  
> -int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg)
> +bool task_in_mem_cgroup(struct task_struct *task,
> +			const struct mem_cgroup *memcg)
>  {
> -	int ret;
>  	struct mem_cgroup *curr = NULL;
>  	struct task_struct *p;
> +	bool ret;
>  
>  	p = find_lock_task_mm(task);
>  	if (p) {
> @@ -1459,14 +1460,14 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg)
>  		 * killer still needs to detect if they have already been oom
>  		 * killed to prevent needlessly killing additional tasks.
>  		 */
> -		task_lock(task);
> +		rcu_read_lock();
>  		curr = mem_cgroup_from_task(task);
>  		if (curr)
>  			css_get(&curr->css);
> -		task_unlock(task);
> +		rcu_read_unlock();
>  	}
>  	if (!curr)
> -		return 0;
> +		return false;
>  	/*
>  	 * We should check use_hierarchy of "memcg" not "curr". Because checking
>  	 * use_hierarchy of "curr" here make this function true if hierarchy is

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
