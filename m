Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0BAEE6B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 08:04:19 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id k12so121356551lfb.2
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 05:04:18 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id i3si19897841wjh.75.2016.09.19.05.04.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Sep 2016 05:04:17 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id 133so14581927wmq.2
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 05:04:17 -0700 (PDT)
Date: Mon, 19 Sep 2016 14:04:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] mm: memcontrol: consolidate cgroup socket tracking
Message-ID: <20160919120415.GO10785@dhcp22.suse.cz>
References: <20160914194846.11153-1-hannes@cmpxchg.org>
 <20160914194846.11153-3-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160914194846.11153-3-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, "David S. Miller" <davem@davemloft.net>, linux-mm@kvack.org, cgroups@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Vladimir Davydov <vdavydov.dev@gmail.com>

[Fixup Vladimir's email]

same here I do not feel familiar with the code enough to give my ack but
Vladimir might be in a better position

On Wed 14-09-16 15:48:46, Johannes Weiner wrote:
> The cgroup core and the memory controller need to track socket
> ownership for different purposes, but the tracking sites being
> entirely different is kind of ugly.
> 
> Be a better citizen and rename the memory controller callbacks to
> match the cgroup core callbacks, then move them to the same place.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/memcontrol.h |  4 ++--
>  mm/memcontrol.c            | 19 +++++++++++--------
>  net/core/sock.c            |  6 +++---
>  net/ipv4/tcp.c             |  2 --
>  net/ipv4/tcp_ipv4.c        |  3 ---
>  5 files changed, 16 insertions(+), 18 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 0710143723bc..ca11b3e6dd65 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -773,8 +773,8 @@ static inline void mem_cgroup_wb_stats(struct bdi_writeback *wb,
>  #endif	/* CONFIG_CGROUP_WRITEBACK */
>  
>  struct sock;
> -void sock_update_memcg(struct sock *sk);
> -void sock_release_memcg(struct sock *sk);
> +void mem_cgroup_sk_alloc(struct sock *sk);
> +void mem_cgroup_sk_free(struct sock *sk);
>  bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
>  void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
>  #ifdef CONFIG_MEMCG
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 60bb830abc34..2caf1ee86e78 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2939,7 +2939,7 @@ static int memcg_update_tcp_limit(struct mem_cgroup *memcg, unsigned long limit)
>  		/*
>  		 * The active flag needs to be written after the static_key
>  		 * update. This is what guarantees that the socket activation
> -		 * function is the last one to run. See sock_update_memcg() for
> +		 * function is the last one to run. See mem_cgroup_sk_alloc() for
>  		 * details, and note that we don't mark any socket as belonging
>  		 * to this memcg until that flag is up.
>  		 *
> @@ -2948,7 +2948,7 @@ static int memcg_update_tcp_limit(struct mem_cgroup *memcg, unsigned long limit)
>  		 * as accounted, but the accounting functions are not patched in
>  		 * yet, we'll lose accounting.
>  		 *
> -		 * We never race with the readers in sock_update_memcg(),
> +		 * We never race with the readers in mem_cgroup_sk_alloc(),
>  		 * because when this value change, the code to process it is not
>  		 * patched in yet.
>  		 */
> @@ -5651,11 +5651,15 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage)
>  DEFINE_STATIC_KEY_FALSE(memcg_sockets_enabled_key);
>  EXPORT_SYMBOL(memcg_sockets_enabled_key);
>  
> -void sock_update_memcg(struct sock *sk)
> +void mem_cgroup_sk_alloc(struct sock *sk)
>  {
>  	struct mem_cgroup *memcg;
>  
> -	/* Socket cloning can throw us here with sk_cgrp already
> +	if (!mem_cgroup_sockets_enabled)
> +		return;
> +
> +	/*
> +	 * Socket cloning can throw us here with sk_memcg already
>  	 * filled. It won't however, necessarily happen from
>  	 * process context. So the test for root memcg given
>  	 * the current task's memcg won't help us in this case.
> @@ -5680,12 +5684,11 @@ void sock_update_memcg(struct sock *sk)
>  out:
>  	rcu_read_unlock();
>  }
> -EXPORT_SYMBOL(sock_update_memcg);
>  
> -void sock_release_memcg(struct sock *sk)
> +void mem_cgroup_sk_free(struct sock *sk)
>  {
> -	WARN_ON(!sk->sk_memcg);
> -	css_put(&sk->sk_memcg->css);
> +	if (sk->sk_memcg)
> +		css_put(&sk->sk_memcg->css);
>  }
>  
>  /**
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 038e660ef844..c73e28fc9c2a 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1363,6 +1363,7 @@ static void sk_prot_free(struct proto *prot, struct sock *sk)
>  	slab = prot->slab;
>  
>  	cgroup_sk_free(&sk->sk_cgrp_data);
> +	mem_cgroup_sk_free(sk);
>  	security_sk_free(sk);
>  	if (slab != NULL)
>  		kmem_cache_free(slab, sk);
> @@ -1399,6 +1400,7 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
>  		sock_net_set(sk, net);
>  		atomic_set(&sk->sk_wmem_alloc, 1);
>  
> +		mem_cgroup_sk_alloc(sk);
>  		cgroup_sk_alloc(&sk->sk_cgrp_data);
>  		sock_update_classid(&sk->sk_cgrp_data);
>  		sock_update_netprioidx(&sk->sk_cgrp_data);
> @@ -1545,6 +1547,7 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
>  		newsk->sk_incoming_cpu = raw_smp_processor_id();
>  		atomic64_set(&newsk->sk_cookie, 0);
>  
> +		mem_cgroup_sk_alloc(newsk);
>  		cgroup_sk_alloc(&newsk->sk_cgrp_data);
>  
>  		/*
> @@ -1569,9 +1572,6 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
>  		sk_set_socket(newsk, NULL);
>  		newsk->sk_wq = NULL;
>  
> -		if (mem_cgroup_sockets_enabled && sk->sk_memcg)
> -			sock_update_memcg(newsk);
> -
>  		if (newsk->sk_prot->sockets_allocated)
>  			sk_sockets_allocated_inc(newsk);
>  
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index a13fcb369f52..fc76ef51a5f4 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -421,8 +421,6 @@ void tcp_init_sock(struct sock *sk)
>  	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
>  
>  	local_bh_disable();
> -	if (mem_cgroup_sockets_enabled)
> -		sock_update_memcg(sk);
>  	sk_sockets_allocated_inc(sk);
>  	local_bh_enable();
>  }
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 04b989328558..b8fc74a66299 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1872,9 +1872,6 @@ void tcp_v4_destroy_sock(struct sock *sk)
>  	local_bh_disable();
>  	sk_sockets_allocated_dec(sk);
>  	local_bh_enable();
> -
> -	if (mem_cgroup_sockets_enabled && sk->sk_memcg)
> -		sock_release_memcg(sk);
>  }
>  EXPORT_SYMBOL(tcp_v4_destroy_sock);
>  
> -- 
> 2.9.3

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
