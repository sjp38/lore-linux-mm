Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2DD806B0038
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 05:43:12 -0500 (EST)
Received: by wmec201 with SMTP id c201so74878160wme.0
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 02:43:11 -0800 (PST)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id c12si4704896wmh.122.2015.11.13.02.43.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Nov 2015 02:43:11 -0800 (PST)
Received: by wmdw130 with SMTP id w130so23399743wmd.0
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 02:43:10 -0800 (PST)
Date: Fri, 13 Nov 2015 11:43:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 10/14] mm: memcontrol: generalize the socket accounting
 jump label
Message-ID: <20151113104308.GD2632@dhcp22.suse.cz>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-11-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447371693-25143-11-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu 12-11-15 18:41:29, Johannes Weiner wrote:
> The unified hierarchy memory controller is going to use this jump
> label as well to control the networking callbacks. Move it to the
> memory controller code and give it a more generic name.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Yes it makes more sense in memcg proper
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/memcontrol.h | 4 ++++
>  include/net/sock.h         | 7 -------
>  mm/memcontrol.c            | 3 +++
>  net/core/sock.c            | 5 -----
>  net/ipv4/tcp_memcontrol.c  | 4 ++--
>  5 files changed, 9 insertions(+), 14 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 1c71f27..4cf5afa 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -693,6 +693,8 @@ static inline void mem_cgroup_wb_stats(struct bdi_writeback *wb,
>  
>  #if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
>  struct sock;
> +extern struct static_key memcg_sockets_enabled_key;
> +#define mem_cgroup_sockets_enabled static_key_false(&memcg_sockets_enabled_key)
>  void sock_update_memcg(struct sock *sk);
>  void sock_release_memcg(struct sock *sk);
>  bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
> @@ -701,6 +703,8 @@ static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
>  {
>  	return memcg->tcp_mem.memory_pressure;
>  }
> +#else
> +#define mem_cgroup_sockets_enabled 0
>  #endif /* CONFIG_INET && CONFIG_MEMCG_KMEM */
>  
>  #ifdef CONFIG_MEMCG_KMEM
> diff --git a/include/net/sock.h b/include/net/sock.h
> index b439dcc..bf1b901 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1065,13 +1065,6 @@ static inline void sk_refcnt_debug_release(const struct sock *sk)
>  #define sk_refcnt_debug_release(sk) do { } while (0)
>  #endif /* SOCK_REFCNT_DEBUG */
>  
> -#if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_NET)
> -extern struct static_key memcg_socket_limit_enabled;
> -#define mem_cgroup_sockets_enabled static_key_false(&memcg_socket_limit_enabled)
> -#else
> -#define mem_cgroup_sockets_enabled 0
> -#endif
> -
>  static inline bool sk_stream_memory_free(const struct sock *sk)
>  {
>  	if (sk->sk_wmem_queued >= sk->sk_sndbuf)
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 89b1d9e..658bef2 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -291,6 +291,9 @@ static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
>  /* Writing them here to avoid exposing memcg's inner layout */
>  #if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
>  
> +struct static_key memcg_sockets_enabled_key;
> +EXPORT_SYMBOL(memcg_sockets_enabled_key);
> +
>  void sock_update_memcg(struct sock *sk)
>  {
>  	struct mem_cgroup *memcg;
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 6486b0d..c5435b5 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -201,11 +201,6 @@ EXPORT_SYMBOL(sk_net_capable);
>  static struct lock_class_key af_family_keys[AF_MAX];
>  static struct lock_class_key af_family_slock_keys[AF_MAX];
>  
> -#if defined(CONFIG_MEMCG_KMEM)
> -struct static_key memcg_socket_limit_enabled;
> -EXPORT_SYMBOL(memcg_socket_limit_enabled);
> -#endif
> -
>  /*
>   * Make lock validator output more readable. (we pre-construct these
>   * strings build-time, so that runtime initialization of socket
> diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
> index 47addc3..17df9dd 100644
> --- a/net/ipv4/tcp_memcontrol.c
> +++ b/net/ipv4/tcp_memcontrol.c
> @@ -34,7 +34,7 @@ void tcp_destroy_cgroup(struct mem_cgroup *memcg)
>  		return;
>  
>  	if (test_bit(MEMCG_SOCK_ACTIVATED, &memcg->tcp_mem.flags))
> -		static_key_slow_dec(&memcg_socket_limit_enabled);
> +		static_key_slow_dec(&memcg_sockets_enabled_key);
>  }
>  
>  static int tcp_update_limit(struct mem_cgroup *memcg, unsigned long nr_pages)
> @@ -73,7 +73,7 @@ static int tcp_update_limit(struct mem_cgroup *memcg, unsigned long nr_pages)
>  		 */
>  		if (!test_and_set_bit(MEMCG_SOCK_ACTIVATED,
>  				      &memcg->tcp_mem.flags))
> -			static_key_slow_inc(&memcg_socket_limit_enabled);
> +			static_key_slow_inc(&memcg_sockets_enabled_key);
>  		set_bit(MEMCG_SOCK_ACTIVE, &memcg->tcp_mem.flags);
>  	}
>  
> -- 
> 2.6.2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
