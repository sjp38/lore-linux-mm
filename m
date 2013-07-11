Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 856FB6B0037
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 10:56:28 -0400 (EDT)
Date: Thu, 11 Jul 2013 16:56:25 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V4 5/6] memcg: patch
 mem_cgroup_{begin,end}_update_page_stat() out if only root memcg exists
Message-ID: <20130711145625.GK21667@dhcp22.suse.cz>
References: <1373044710-27371-1-git-send-email-handai.szj@taobao.com>
 <1373045623-27712-1-git-send-email-handai.szj@taobao.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373045623-27712-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, gthelen@google.com, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, fengguang.wu@intel.com, mgorman@suse.de, Sha Zhengju <handai.szj@taobao.com>

On Sat 06-07-13 01:33:43, Sha Zhengju wrote:
> From: Sha Zhengju <handai.szj@taobao.com>
> 
> If memcg is enabled and no non-root memcg exists, all allocated
> pages belongs to root_mem_cgroup and wil go through root memcg
> statistics routines.  So in order to reduce overheads after adding
> memcg dirty/writeback accounting in hot paths, we use jump label to
> patch mem_cgroup_{begin,end}_update_page_stat() in or out when not
> used.

I do not think this is enough. How much do you save? One atomic read.
This doesn't seem like a killer.

I hoped we could simply not account at all and move counters to the root
cgroup once the label gets enabled.

Besides that, the current patch is racy. Consider what happens when:

mem_cgroup_begin_update_page_stat
					arm_inuse_keys
							mem_cgroup_move_account
mem_cgroup_move_account_page_stat
mem_cgroup_end_update_page_stat

The race window is small of course but it is there. I guess we need
rcu_read_lock at least.

> If no non-root memcg comes to life, we do not need to accquire moving
> locks, so patch them out.
>
> cc: Michal Hocko <mhocko@suse.cz>
> cc: Greg Thelen <gthelen@google.com>
> cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> cc: Andrew Morton <akpm@linux-foundation.org>
> cc: Fengguang Wu <fengguang.wu@intel.com>
> cc: Mel Gorman <mgorman@suse.de>
> ---
>  include/linux/memcontrol.h |   15 +++++++++++++++
>  mm/memcontrol.c            |   23 ++++++++++++++++++++++-
>  2 files changed, 37 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index ccd35d8..0483e1a 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -55,6 +55,13 @@ struct mem_cgroup_reclaim_cookie {
>  };
>  
>  #ifdef CONFIG_MEMCG
> +
> +extern struct static_key memcg_inuse_key;
> +static inline bool mem_cgroup_in_use(void)
> +{
> +	return static_key_false(&memcg_inuse_key);
> +}
> +
>  /*
>   * All "charge" functions with gfp_mask should use GFP_KERNEL or
>   * (gfp_mask & GFP_RECLAIM_MASK). In current implementatin, memcg doesn't
> @@ -159,6 +166,8 @@ static inline void mem_cgroup_begin_update_page_stat(struct page *page,
>  {
>  	if (mem_cgroup_disabled())
>  		return;
> +	if (!mem_cgroup_in_use())
> +		return;
>  	rcu_read_lock();
>  	*locked = false;
>  	if (atomic_read(&memcg_moving))
> @@ -172,6 +181,8 @@ static inline void mem_cgroup_end_update_page_stat(struct page *page,
>  {
>  	if (mem_cgroup_disabled())
>  		return;
> +	if (!mem_cgroup_in_use())
> +		return;
>  	if (*locked)
>  		__mem_cgroup_end_update_page_stat(page, flags);
>  	rcu_read_unlock();
> @@ -215,6 +226,10 @@ void mem_cgroup_print_bad_page(struct page *page);
>  #endif
>  #else /* CONFIG_MEMCG */
>  struct mem_cgroup;
> +static inline bool mem_cgroup_in_use(void)
> +{
> +	return false;
> +}
>  
>  static inline int mem_cgroup_newpage_charge(struct page *page,
>  					struct mm_struct *mm, gfp_t gfp_mask)
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 9126abc..a85f7c5 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -463,6 +463,13 @@ enum res_type {
>  #define MEM_CGROUP_RECLAIM_SHRINK_BIT	0x1
>  #define MEM_CGROUP_RECLAIM_SHRINK	(1 << MEM_CGROUP_RECLAIM_SHRINK_BIT)
>  
> +/* static_key used for marking memcg in use or not. We use this jump label to
> + * patch some memcg page stat accounting code in or out.
> + * The key will be increased when non-root memcg is created, and be decreased
> + * when memcg is destroyed.
> + */
> +struct static_key memcg_inuse_key;
> +
>  /*
>   * The memcg_create_mutex will be held whenever a new cgroup is created.
>   * As a consequence, any change that needs to protect against new child cgroups
> @@ -630,10 +637,22 @@ static void disarm_kmem_keys(struct mem_cgroup *memcg)
>  }
>  #endif /* CONFIG_MEMCG_KMEM */
>  
> +static void disarm_inuse_keys(struct mem_cgroup *memcg)
> +{
> +	if (!mem_cgroup_is_root(memcg))
> +		static_key_slow_dec(&memcg_inuse_key);
> +}
> +
> +static void arm_inuse_keys(void)
> +{
> +	static_key_slow_inc(&memcg_inuse_key);
> +}
> +
>  static void disarm_static_keys(struct mem_cgroup *memcg)
>  {
>  	disarm_sock_keys(memcg);
>  	disarm_kmem_keys(memcg);
> +	disarm_inuse_keys(memcg);
>  }
>  
>  static void drain_all_stock_async(struct mem_cgroup *memcg);
> @@ -2298,7 +2317,6 @@ void mem_cgroup_update_page_stat(struct page *page,
>  {
>  	struct mem_cgroup *memcg;
>  	struct page_cgroup *pc = lookup_page_cgroup(page);
> -	unsigned long uninitialized_var(flags);
>  
>  	if (mem_cgroup_disabled())
>  		return;
> @@ -6293,6 +6311,9 @@ mem_cgroup_css_online(struct cgroup *cont)
>  	}
>  
>  	error = memcg_init_kmem(memcg, &mem_cgroup_subsys);
> +	if (!error)
> +		arm_inuse_keys();
> +
>  	mutex_unlock(&memcg_create_mutex);
>  	return error;
>  }
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
