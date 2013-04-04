Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id C7FC16B0006
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 11:35:01 -0400 (EDT)
Date: Thu, 4 Apr 2013 17:35:00 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC][PATCH 7/7] memcg: kill memcg refcnt
Message-ID: <20130404153500.GO29911@dhcp22.suse.cz>
References: <515BF233.6070308@huawei.com>
 <515BF2E3.4000605@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <515BF2E3.4000605@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Wed 03-04-13 17:14:11, Li Zefan wrote:
> Now memcg has the same life cycle as the corresponding cgroup.
> Kill the useless refcnt.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> ---
>  mm/memcontrol.c | 24 +-----------------------
>  1 file changed, 1 insertion(+), 23 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 45129cd..9714a16 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -297,8 +297,6 @@ struct mem_cgroup {
>  	bool		oom_lock;
>  	atomic_t	under_oom;
>  
> -	atomic_t	refcnt;
> -
>  	int	swappiness;
>  	/* OOM-Killer disable */
>  	int		oom_kill_disable;
> @@ -501,9 +499,6 @@ enum res_type {
>   */
>  static DEFINE_MUTEX(memcg_create_mutex);
>  
> -static void mem_cgroup_get(struct mem_cgroup *memcg);
> -static void mem_cgroup_put(struct mem_cgroup *memcg);
> -
>  static inline
>  struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *s)
>  {
> @@ -6117,22 +6112,6 @@ static void free_rcu(struct rcu_head *rcu_head)
>  	schedule_work(&memcg->work_freeing);
>  }
>  
> -static void mem_cgroup_get(struct mem_cgroup *memcg)
> -{
> -	atomic_inc(&memcg->refcnt);
> -}
> -
> -static void __mem_cgroup_put(struct mem_cgroup *memcg, int count)
> -{
> -	if (atomic_sub_and_test(count, &memcg->refcnt))
> -		call_rcu(&memcg->rcu_freeing, free_rcu);
> -}
> -
> -static void mem_cgroup_put(struct mem_cgroup *memcg)
> -{
> -	__mem_cgroup_put(memcg, 1);
> -}
> -
>  /*
>   * Returns the parent mem_cgroup in memcgroup hierarchy with hierarchy enabled.
>   */
> @@ -6192,7 +6171,6 @@ mem_cgroup_css_alloc(struct cgroup *cont)
>  
>  	memcg->last_scanned_node = MAX_NUMNODES;
>  	INIT_LIST_HEAD(&memcg->oom_notify);
> -	atomic_set(&memcg->refcnt, 1);
>  	memcg->move_charge_at_immigrate = 0;
>  	mutex_init(&memcg->thresholds_lock);
>  	spin_lock_init(&memcg->move_lock);
> @@ -6279,7 +6257,7 @@ static void mem_cgroup_css_free(struct cgroup *cont)
>  
>  	mem_cgroup_sockets_destroy(memcg);
>  
> -	mem_cgroup_put(memcg);
> +	call_rcu(&memcg->rcu_freeing, free_rcu);
>  }
>  
>  #ifdef CONFIG_MMU
> -- 
> 1.8.0.2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
