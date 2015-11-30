Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 595116B0038
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 17:28:50 -0500 (EST)
Received: by qgcc31 with SMTP id c31so130387341qgc.3
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 14:28:50 -0800 (PST)
Received: from prod-mail-xrelay05.akamai.com (prod-mail-xrelay05.akamai.com. [23.79.238.179])
        by mx.google.com with ESMTP id k61si47294986qgf.23.2015.11.30.14.28.49
        for <linux-mm@kvack.org>;
        Mon, 30 Nov 2015 14:28:49 -0800 (PST)
Subject: Re: [PATCH 09/13] mm: memcontrol: generalize the socket accounting
 jump label
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
 <1448401925-22501-10-git-send-email-hannes@cmpxchg.org>
 <565CBAC2.3080804@akamai.com> <20151130215007.GA31903@cmpxchg.org>
From: Jason Baron <jbaron@akamai.com>
Message-ID: <565CCDA1.905@akamai.com>
Date: Mon, 30 Nov 2015 17:28:49 -0500
MIME-Version: 1.0
In-Reply-To: <20151130215007.GA31903@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, "peterz@infradead.org" <peterz@infradead.org>

On 11/30/2015 04:50 PM, Johannes Weiner wrote:
> On Mon, Nov 30, 2015 at 04:08:18PM -0500, Jason Baron wrote:
>> We're trying to move to the updated API, so this should be:
>> static_branch_unlikely(&memcg_sockets_enabled_key)
>>
>> see: include/linux/jump_label.h for details.
> 
> Good point. There is another struct static_key in there as well. How
> about the following on top of this series?
> 

Looks fine - you may be able to make use of
'static_branch_enable()/disable()' instead of the inc()/dec() to simply
set the branch direction, if you think its more readable. Although I
didn't look to see if it would be racy here.

Thanks,

-Jason


> ---
> From b784aa0323628d43272e13a67ead2a2ce0e93ea6 Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Mon, 30 Nov 2015 16:41:38 -0500
> Subject: [PATCH] mm: memcontrol: switch to the updated jump-label API
> 
> According to <linux/jump_label.h> the direct use of struct static_key
> is deprecated. Update the socket and slab accounting code accordingly.
> 
> Reported-by: Jason Baron <jbaron@akamai.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/memcontrol.h |  8 ++++----
>  mm/memcontrol.c            | 12 ++++++------
>  net/ipv4/tcp_memcontrol.c  |  4 ++--
>  3 files changed, 12 insertions(+), 12 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index a8df46c..9a19590 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -704,8 +704,8 @@ static inline void mem_cgroup_wb_stats(struct bdi_writeback *wb,
>  
>  #ifdef CONFIG_INET
>  struct sock;
> -extern struct static_key memcg_sockets_enabled_key;
> -#define mem_cgroup_sockets_enabled static_key_false(&memcg_sockets_enabled_key)
> +extern struct static_key_false memcg_sockets_enabled_key;
> +#define mem_cgroup_sockets_enabled static_branch_unlikely(&memcg_sockets_enabled_key)
>  void sock_update_memcg(struct sock *sk);
>  void sock_release_memcg(struct sock *sk);
>  bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
> @@ -727,7 +727,7 @@ static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
>  #endif /* CONFIG_INET */
>  
>  #ifdef CONFIG_MEMCG_KMEM
> -extern struct static_key memcg_kmem_enabled_key;
> +extern struct static_key_false memcg_kmem_enabled_key;
>  
>  extern int memcg_nr_cache_ids;
>  void memcg_get_cache_ids(void);
> @@ -743,7 +743,7 @@ void memcg_put_cache_ids(void);
>  
>  static inline bool memcg_kmem_enabled(void)
>  {
> -	return static_key_false(&memcg_kmem_enabled_key);
> +	return static_branch_unlikely(&memcg_kmem_enabled_key);
>  }
>  
>  static inline bool memcg_kmem_is_active(struct mem_cgroup *memcg)
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index a0da91f..5fe45d68 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -346,7 +346,7 @@ void memcg_put_cache_ids(void)
>   * conditional to this static branch, we'll have to allow modules that does
>   * kmem_cache_alloc and the such to see this symbol as well
>   */
> -struct static_key memcg_kmem_enabled_key;
> +DEFINE_STATIC_KEY_FALSE(memcg_kmem_enabled_key);
>  EXPORT_SYMBOL(memcg_kmem_enabled_key);
>  
>  #endif /* CONFIG_MEMCG_KMEM */
> @@ -2883,7 +2883,7 @@ static int memcg_activate_kmem(struct mem_cgroup *memcg,
>  	err = page_counter_limit(&memcg->kmem, nr_pages);
>  	VM_BUG_ON(err);
>  
> -	static_key_slow_inc(&memcg_kmem_enabled_key);
> +	static_branch_inc(&memcg_kmem_enabled_key);
>  	/*
>  	 * A memory cgroup is considered kmem-active as soon as it gets
>  	 * kmemcg_id. Setting the id after enabling static branching will
> @@ -3622,7 +3622,7 @@ static void memcg_destroy_kmem(struct mem_cgroup *memcg)
>  {
>  	if (memcg->kmem_acct_activated) {
>  		memcg_destroy_kmem_caches(memcg);
> -		static_key_slow_dec(&memcg_kmem_enabled_key);
> +		static_branch_dec(&memcg_kmem_enabled_key);
>  		WARN_ON(page_counter_read(&memcg->kmem));
>  	}
>  	tcp_destroy_cgroup(memcg);
> @@ -4258,7 +4258,7 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
>  
>  #ifdef CONFIG_INET
>  	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
> -		static_key_slow_inc(&memcg_sockets_enabled_key);
> +		static_branch_inc(&memcg_sockets_enabled_key);
>  #endif
>  
>  	/*
> @@ -4302,7 +4302,7 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
>  	memcg_destroy_kmem(memcg);
>  #ifdef CONFIG_INET
>  	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
> -		static_key_slow_dec(&memcg_sockets_enabled_key);
> +		static_branch_dec(&memcg_sockets_enabled_key);
>  #endif
>  	__mem_cgroup_free(memcg);
>  }
> @@ -5494,7 +5494,7 @@ void mem_cgroup_replace_page(struct page *oldpage, struct page *newpage)
>  
>  #ifdef CONFIG_INET
>  
> -struct static_key memcg_sockets_enabled_key;
> +DEFINE_STATIC_KEY_FALSE(memcg_sockets_enabled_key);
>  EXPORT_SYMBOL(memcg_sockets_enabled_key);
>  
>  void sock_update_memcg(struct sock *sk)
> diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
> index 9a22e2d..18bc7f7 100644
> --- a/net/ipv4/tcp_memcontrol.c
> +++ b/net/ipv4/tcp_memcontrol.c
> @@ -34,7 +34,7 @@ void tcp_destroy_cgroup(struct mem_cgroup *memcg)
>  		return;
>  
>  	if (memcg->tcp_mem.active)
> -		static_key_slow_dec(&memcg_sockets_enabled_key);
> +		static_branch_dec(&memcg_sockets_enabled_key);
>  }
>  
>  static int tcp_update_limit(struct mem_cgroup *memcg, unsigned long nr_pages)
> @@ -65,7 +65,7 @@ static int tcp_update_limit(struct mem_cgroup *memcg, unsigned long nr_pages)
>  		 * because when this value change, the code to process it is not
>  		 * patched in yet.
>  		 */
> -		static_key_slow_inc(&memcg_sockets_enabled_key);
> +		static_branch_inc(&memcg_sockets_enabled_key);
>  		memcg->tcp_mem.active = true;
>  	}
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
