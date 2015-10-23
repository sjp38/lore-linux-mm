Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id F3B446B0038
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 08:39:38 -0400 (EDT)
Received: by wikq8 with SMTP id q8so75047175wik.1
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 05:39:38 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id bz5si4792441wib.23.2015.10.23.05.39.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Oct 2015 05:39:32 -0700 (PDT)
Received: by wicfv8 with SMTP id fv8so30132872wic.0
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 05:39:32 -0700 (PDT)
Date: Fri, 23 Oct 2015 14:39:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/8] mm: memcontrol: prepare for unified hierarchy socket
 accounting
Message-ID: <20151023123930.GM2410@dhcp22.suse.cz>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <1445487696-21545-5-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1445487696-21545-5-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 22-10-15 00:21:32, Johannes Weiner wrote:
> The unified hierarchy memory controller will account socket
> memory. Move the infrastructure functions accordingly.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 136 ++++++++++++++++++++++++++++----------------------------
>  1 file changed, 68 insertions(+), 68 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c41e6d7..3789050 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -287,74 +287,6 @@ static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
>  	return mem_cgroup_from_css(css);
>  }
>  
> -/* Writing them here to avoid exposing memcg's inner layout */
> -#if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
> -
> -DEFINE_STATIC_KEY_FALSE(mem_cgroup_sockets);
> -
> -void sock_update_memcg(struct sock *sk)
> -{
> -	struct mem_cgroup *memcg;
> -	/*
> -	 * Socket cloning can throw us here with sk_cgrp already
> -	 * filled. It won't however, necessarily happen from
> -	 * process context. So the test for root memcg given
> -	 * the current task's memcg won't help us in this case.
> -	 *
> -	 * Respecting the original socket's memcg is a better
> -	 * decision in this case.
> -	 */
> -	if (sk->sk_memcg) {
> -		BUG_ON(mem_cgroup_is_root(sk->sk_memcg));
> -		css_get(&sk->sk_memcg->css);
> -		return;
> -	}
> -
> -	rcu_read_lock();
> -	memcg = mem_cgroup_from_task(current);
> -	if (css_tryget_online(&memcg->css))
> -		sk->sk_memcg = memcg;
> -	rcu_read_unlock();
> -}
> -EXPORT_SYMBOL(sock_update_memcg);
> -
> -void sock_release_memcg(struct sock *sk)
> -{
> -	if (sk->sk_memcg)
> -		css_put(&sk->sk_memcg->css);
> -}
> -
> -/**
> - * mem_cgroup_charge_skmem - charge socket memory
> - * @memcg: memcg to charge
> - * @nr_pages: number of pages to charge
> - *
> - * Charges @nr_pages to @memcg. Returns %true if the charge fit within
> - * the memcg's configured limit, %false if the charge had to be forced.
> - */
> -bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
> -{
> -	struct page_counter *counter;
> -
> -	if (page_counter_try_charge(&memcg->skmem, nr_pages, &counter))
> -		return true;
> -
> -	page_counter_charge(&memcg->skmem, nr_pages);
> -	return false;
> -}
> -
> -/**
> - * mem_cgroup_uncharge_skmem - uncharge socket memory
> - * @memcg: memcg to uncharge
> - * @nr_pages: number of pages to uncharge
> - */
> -void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
> -{
> -	page_counter_uncharge(&memcg->skmem, nr_pages);
> -}
> -
> -#endif
> -
>  #ifdef CONFIG_MEMCG_KMEM
>  /*
>   * This will be the memcg's index in each cache's ->memcg_params.memcg_caches.
> @@ -5521,6 +5453,74 @@ void mem_cgroup_replace_page(struct page *oldpage, struct page *newpage)
>  	commit_charge(newpage, memcg, true);
>  }
>  
> +/* Writing them here to avoid exposing memcg's inner layout */
> +#if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
> +
> +DEFINE_STATIC_KEY_FALSE(mem_cgroup_sockets);
> +
> +void sock_update_memcg(struct sock *sk)
> +{
> +	struct mem_cgroup *memcg;
> +	/*
> +	 * Socket cloning can throw us here with sk_cgrp already
> +	 * filled. It won't however, necessarily happen from
> +	 * process context. So the test for root memcg given
> +	 * the current task's memcg won't help us in this case.
> +	 *
> +	 * Respecting the original socket's memcg is a better
> +	 * decision in this case.
> +	 */
> +	if (sk->sk_memcg) {
> +		BUG_ON(mem_cgroup_is_root(sk->sk_memcg));
> +		css_get(&sk->sk_memcg->css);
> +		return;
> +	}
> +
> +	rcu_read_lock();
> +	memcg = mem_cgroup_from_task(current);
> +	if (css_tryget_online(&memcg->css))
> +		sk->sk_memcg = memcg;
> +	rcu_read_unlock();
> +}
> +EXPORT_SYMBOL(sock_update_memcg);
> +
> +void sock_release_memcg(struct sock *sk)
> +{
> +	if (sk->sk_memcg)
> +		css_put(&sk->sk_memcg->css);
> +}
> +
> +/**
> + * mem_cgroup_charge_skmem - charge socket memory
> + * @memcg: memcg to charge
> + * @nr_pages: number of pages to charge
> + *
> + * Charges @nr_pages to @memcg. Returns %true if the charge fit within
> + * the memcg's configured limit, %false if the charge had to be forced.
> + */
> +bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
> +{
> +	struct page_counter *counter;
> +
> +	if (page_counter_try_charge(&memcg->skmem, nr_pages, &counter))
> +		return true;
> +
> +	page_counter_charge(&memcg->skmem, nr_pages);
> +	return false;
> +}
> +
> +/**
> + * mem_cgroup_uncharge_skmem - uncharge socket memory
> + * @memcg: memcg to uncharge
> + * @nr_pages: number of pages to uncharge
> + */
> +void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
> +{
> +	page_counter_uncharge(&memcg->skmem, nr_pages);
> +}
> +
> +#endif
> +
>  /*
>   * subsys_initcall() for memory controller.
>   *
> -- 
> 2.6.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
