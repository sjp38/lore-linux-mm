Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 828BD6B0255
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 07:47:29 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id c201so31315222wme.0
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 04:47:29 -0800 (PST)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id bk4si18590851wjc.149.2015.12.10.04.47.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 04:47:28 -0800 (PST)
Received: by mail-wm0-f50.google.com with SMTP id v187so31373154wmv.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 04:47:28 -0800 (PST)
Date: Thu, 10 Dec 2015 13:47:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/8] mm: memcontrol: give the kmem states more
 descriptive names
Message-ID: <20151210124726.GI19496@dhcp22.suse.cz>
References: <1449599665-18047-1-git-send-email-hannes@cmpxchg.org>
 <1449599665-18047-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1449599665-18047-4-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue 08-12-15 13:34:20, Johannes Weiner wrote:
> On any given memcg, the kmem accounting feature has three separate
> states: not initialized, structures allocated, and actively accounting
> slab memory. These are represented through a combination of the
> kmem_acct_activated and kmem_acct_active flags, which is confusing.
> 
> Convert to a kmem_state enum with the states NONE, ALLOCATED, and
> ONLINE. Then rename the functions to modify the state accordingly.
> This follows the nomenclature of css object states more closely.

I like this! It is much easier to follow than two separate flags.
 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/memcontrol.h | 15 ++++++++-----
>  mm/memcontrol.c            | 52 ++++++++++++++++++++++------------------------
>  mm/slab_common.c           |  4 ++--
>  mm/vmscan.c                |  2 +-
>  4 files changed, 38 insertions(+), 35 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 189f04d..54dab4d 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -152,6 +152,12 @@ struct mem_cgroup_thresholds {
>  	struct mem_cgroup_threshold_ary *spare;
>  };
>  
> +enum memcg_kmem_state {
> +	KMEM_NONE,
> +	KMEM_ALLOCATED,
> +	KMEM_ONLINE,
> +};
> +
>  /*
>   * The memory controller data structure. The memory controller controls both
>   * page cache and RSS per cgroup. We would eventually like to provide
> @@ -233,8 +239,7 @@ struct mem_cgroup {
>  #if defined(CONFIG_MEMCG_KMEM)
>          /* Index in the kmem_cache->memcg_params.memcg_caches array */
>  	int kmemcg_id;
> -	bool kmem_acct_activated;
> -	bool kmem_acct_active;
> +	enum memcg_kmem_state kmem_state;
>  #endif
>  
>  	int last_scanned_node;
> @@ -750,9 +755,9 @@ static inline bool memcg_kmem_enabled(void)
>  	return static_branch_unlikely(&memcg_kmem_enabled_key);
>  }
>  
> -static inline bool memcg_kmem_is_active(struct mem_cgroup *memcg)
> +static inline bool memcg_kmem_online(struct mem_cgroup *memcg)
>  {
> -	return memcg->kmem_acct_active;
> +	return memcg->kmem_state == KMEM_ONLINE;
>  }
>  
>  /*
> @@ -850,7 +855,7 @@ static inline bool memcg_kmem_enabled(void)
>  	return false;
>  }
>  
> -static inline bool memcg_kmem_is_active(struct mem_cgroup *memcg)
> +static inline bool memcg_kmem_online(struct mem_cgroup *memcg)
>  {
>  	return false;
>  }
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 02167db..22b8c4f 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2357,7 +2357,7 @@ int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
>  	struct page_counter *counter;
>  	int ret;
>  
> -	if (!memcg_kmem_is_active(memcg))
> +	if (!memcg_kmem_online(memcg))
>  		return 0;
>  
>  	if (!page_counter_try_charge(&memcg->kmem, nr_pages, &counter))
> @@ -2840,14 +2840,13 @@ static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
>  }
>  
>  #ifdef CONFIG_MEMCG_KMEM
> -static int memcg_activate_kmem(struct mem_cgroup *memcg)
> +static int memcg_online_kmem(struct mem_cgroup *memcg)
>  {
>  	int err = 0;
>  	int memcg_id;
>  
>  	BUG_ON(memcg->kmemcg_id >= 0);
> -	BUG_ON(memcg->kmem_acct_activated);
> -	BUG_ON(memcg->kmem_acct_active);
> +	BUG_ON(memcg->kmem_state);
>  
>  	/*
>  	 * For simplicity, we won't allow this to be disabled.  It also can't
> @@ -2877,14 +2876,13 @@ static int memcg_activate_kmem(struct mem_cgroup *memcg)
>  
>  	static_branch_inc(&memcg_kmem_enabled_key);
>  	/*
> -	 * A memory cgroup is considered kmem-active as soon as it gets
> +	 * A memory cgroup is considered kmem-online as soon as it gets
>  	 * kmemcg_id. Setting the id after enabling static branching will
>  	 * guarantee no one starts accounting before all call sites are
>  	 * patched.
>  	 */
>  	memcg->kmemcg_id = memcg_id;
> -	memcg->kmem_acct_activated = true;
> -	memcg->kmem_acct_active = true;
> +	memcg->kmem_state = KMEM_ONLINE;
>  out:
>  	return err;
>  }
> @@ -2896,8 +2894,8 @@ static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
>  
>  	mutex_lock(&memcg_limit_mutex);
>  	/* Top-level cgroup doesn't propagate from root */
> -	if (!memcg_kmem_is_active(memcg)) {
> -		ret = memcg_activate_kmem(memcg);
> +	if (!memcg_kmem_online(memcg)) {
> +		ret = memcg_online_kmem(memcg);
>  		if (ret)
>  			goto out;
>  	}
> @@ -2917,11 +2915,12 @@ static int memcg_propagate_kmem(struct mem_cgroup *memcg)
>  
>  	mutex_lock(&memcg_limit_mutex);
>  	/*
> -	 * If the parent cgroup is not kmem-active now, it cannot be activated
> -	 * after this point, because it has at least one child already.
> +	 * If the parent cgroup is not kmem-online now, it cannot be
> +	 * onlined after this point, because it has at least one child
> +	 * already.
>  	 */
> -	if (memcg_kmem_is_active(parent))
> -		ret = memcg_activate_kmem(memcg);
> +	if (memcg_kmem_online(parent))
> +		ret = memcg_online_kmem(memcg);
>  	mutex_unlock(&memcg_limit_mutex);
>  	return ret;
>  }
> @@ -3568,22 +3567,21 @@ static int memcg_init_kmem(struct mem_cgroup *memcg)
>  	return tcp_init_cgroup(memcg);
>  }
>  
> -static void memcg_deactivate_kmem(struct mem_cgroup *memcg)
> +static void memcg_offline_kmem(struct mem_cgroup *memcg)
>  {
>  	struct cgroup_subsys_state *css;
>  	struct mem_cgroup *parent, *child;
>  	int kmemcg_id;
>  
> -	if (!memcg->kmem_acct_active)
> +	if (memcg->kmem_state != KMEM_ONLINE)
>  		return;
> -
>  	/*
> -	 * Clear the 'active' flag before clearing memcg_caches arrays entries.
> -	 * Since we take the slab_mutex in memcg_deactivate_kmem_caches(), it
> -	 * guarantees no cache will be created for this cgroup after we are
> -	 * done (see memcg_create_kmem_cache()).
> +	 * Clear the online state before clearing memcg_caches array
> +	 * entries. The slab_mutex in memcg_deactivate_kmem_caches()
> +	 * guarantees that no cache will be created for this cgroup
> +	 * after we are done (see memcg_create_kmem_cache()).
>  	 */
> -	memcg->kmem_acct_active = false;
> +	memcg->kmem_state = KMEM_ALLOCATED;
>  
>  	memcg_deactivate_kmem_caches(memcg);
>  
> @@ -3614,9 +3612,9 @@ static void memcg_deactivate_kmem(struct mem_cgroup *memcg)
>  	memcg_free_cache_id(kmemcg_id);
>  }
>  
> -static void memcg_destroy_kmem(struct mem_cgroup *memcg)
> +static void memcg_free_kmem(struct mem_cgroup *memcg)
>  {
> -	if (memcg->kmem_acct_activated) {
> +	if (memcg->kmem_state == KMEM_ALLOCATED) {
>  		memcg_destroy_kmem_caches(memcg);
>  		static_branch_dec(&memcg_kmem_enabled_key);
>  		WARN_ON(page_counter_read(&memcg->kmem));
> @@ -3629,11 +3627,11 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
>  	return 0;
>  }
>  
> -static void memcg_deactivate_kmem(struct mem_cgroup *memcg)
> +static void memcg_offline_kmem(struct mem_cgroup *memcg)
>  {
>  }
>  
> -static void memcg_destroy_kmem(struct mem_cgroup *memcg)
> +static void memcg_free_kmem(struct mem_cgroup *memcg)
>  {
>  }
>  #endif
> @@ -4286,7 +4284,7 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
>  
>  	vmpressure_cleanup(&memcg->vmpressure);
>  
> -	memcg_deactivate_kmem(memcg);
> +	memcg_offline_kmem(memcg);
>  
>  	wb_memcg_offline(memcg);
>  }
> @@ -4295,7 +4293,7 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  
> -	memcg_destroy_kmem(memcg);
> +	memcg_free_kmem(memcg);
>  #ifdef CONFIG_INET
>  	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
>  		static_branch_dec(&memcg_sockets_enabled_key);
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index e016178..8c262e6 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -503,10 +503,10 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
>  	mutex_lock(&slab_mutex);
>  
>  	/*
> -	 * The memory cgroup could have been deactivated while the cache
> +	 * The memory cgroup could have been offlined while the cache
>  	 * creation work was pending.
>  	 */
> -	if (!memcg_kmem_is_active(memcg))
> +	if (!memcg_kmem_online(memcg))
>  		goto out_unlock;
>  
>  	idx = memcg_cache_id(memcg);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 50e54c0..2dbc679 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -411,7 +411,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>  	struct shrinker *shrinker;
>  	unsigned long freed = 0;
>  
> -	if (memcg && !memcg_kmem_is_active(memcg))
> +	if (memcg && !memcg_kmem_online(memcg))
>  		return 0;
>  
>  	if (nr_scanned == 0)
> -- 
> 2.6.3

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
