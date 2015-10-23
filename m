Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 89E856B0038
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 08:38:34 -0400 (EDT)
Received: by wicfx6 with SMTP id fx6so29434132wic.1
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 05:38:34 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id t2si24676886wjf.33.2015.10.23.05.38.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Oct 2015 05:38:32 -0700 (PDT)
Received: by wicll6 with SMTP id ll6so29486053wic.0
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 05:38:32 -0700 (PDT)
Date: Fri, 23 Oct 2015 14:38:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/8] net: consolidate memcg socket buffer tracking and
 accounting
Message-ID: <20151023123830.GL2410@dhcp22.suse.cz>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <1445487696-21545-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1445487696-21545-4-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 22-10-15 00:21:31, Johannes Weiner wrote:
> The tcp memory controller has extensive provisions for future memory
> accounting interfaces that won't materialize after all. Cut the code
> base down to what's actually used, now and in the likely future.
> 
> - There won't be any different protocol counters in the future, so a
>   direct sock->sk_memcg linkage is enough. This eliminates a lot of
>   callback maze and boilerplate code, and restores most of the socket
>   allocation code to pre-tcp_memcontrol state.
> 
> - There won't be a tcp control soft limit, so integrating the memcg
>   code into the global skmem limiting scheme complicates things
>   unnecessarily. Replace all that with simple and clear charge and
>   uncharge calls--hidden behind a jump label--to account skb memory.
> 
> - The previous jump label code was an elaborate state machine that
>   tracked the number of cgroups with an active socket limit in order
>   to enable the skmem tracking and accounting code only when actively
>   necessary. But this is overengineered: it was meant to protect the
>   people who never use this feature in the first place. Simply enable
>   the branches once when the first limit is set until the next reboot.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

The changelog is certainly attractive. I have looked through the patch
but my knowledge of the networking subsystem and its memory management
is close to zero so I cannot really do a competent review.

Anyway I support any simplification of the tcp kmem accounting. If
networking people are OK with the changes, including reduction of the
functionality as described by Vladimir then no objections from me for
this to be merged.

Thanks!
> ---
>  include/linux/memcontrol.h   |  64 ++++++++-----------
>  include/net/sock.h           | 135 +++------------------------------------
>  include/net/tcp.h            |   3 -
>  include/net/tcp_memcontrol.h |   7 ---
>  mm/memcontrol.c              | 101 +++++++++++++++--------------
>  net/core/sock.c              |  78 ++++++-----------------
>  net/ipv4/sysctl_net_ipv4.c   |   1 -
>  net/ipv4/tcp.c               |   3 +-
>  net/ipv4/tcp_ipv4.c          |   9 +--
>  net/ipv4/tcp_memcontrol.c    | 147 +++++++------------------------------------
>  net/ipv4/tcp_output.c        |   6 +-
>  net/ipv6/tcp_ipv6.c          |   3 -
>  12 files changed, 136 insertions(+), 421 deletions(-)
>  delete mode 100644 include/net/tcp_memcontrol.h
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 19ff87b..5b72f83 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -85,34 +85,6 @@ enum mem_cgroup_events_target {
>  	MEM_CGROUP_NTARGETS,
>  };
>  
> -/*
> - * Bits in struct cg_proto.flags
> - */
> -enum cg_proto_flags {
> -	/* Currently active and new sockets should be assigned to cgroups */
> -	MEMCG_SOCK_ACTIVE,
> -	/* It was ever activated; we must disarm static keys on destruction */
> -	MEMCG_SOCK_ACTIVATED,
> -};
> -
> -struct cg_proto {
> -	struct page_counter	memory_allocated;	/* Current allocated memory. */
> -	struct percpu_counter	sockets_allocated;	/* Current number of sockets. */
> -	int			memory_pressure;
> -	long			sysctl_mem[3];
> -	unsigned long		flags;
> -	/*
> -	 * memcg field is used to find which memcg we belong directly
> -	 * Each memcg struct can hold more than one cg_proto, so container_of
> -	 * won't really cut.
> -	 *
> -	 * The elegant solution would be having an inverse function to
> -	 * proto_cgroup in struct proto, but that means polluting the structure
> -	 * for everybody, instead of just for memcg users.
> -	 */
> -	struct mem_cgroup	*memcg;
> -};
> -
>  #ifdef CONFIG_MEMCG
>  struct mem_cgroup_stat_cpu {
>  	long count[MEM_CGROUP_STAT_NSTATS];
> @@ -185,8 +157,15 @@ struct mem_cgroup {
>  
>  	/* Accounted resources */
>  	struct page_counter memory;
> +
> +	/*
> +	 * Legacy non-resource counters. In unified hierarchy, all
> +	 * memory is accounted and limited through memcg->memory.
> +	 * Consumer breakdown happens in the statistics.
> +	 */
>  	struct page_counter memsw;
>  	struct page_counter kmem;
> +	struct page_counter skmem;
>  
>  	/* Normal memory consumption range */
>  	unsigned long low;
> @@ -246,9 +225,6 @@ struct mem_cgroup {
>  	 */
>  	struct mem_cgroup_stat_cpu __percpu *stat;
>  
> -#if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_INET)
> -	struct cg_proto tcp_mem;
> -#endif
>  #if defined(CONFIG_MEMCG_KMEM)
>          /* Index in the kmem_cache->memcg_params.memcg_caches array */
>  	int kmemcg_id;
> @@ -676,12 +652,6 @@ void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
>  }
>  #endif /* CONFIG_MEMCG */
>  
> -enum {
> -	UNDER_LIMIT,
> -	SOFT_LIMIT,
> -	OVER_LIMIT,
> -};
> -
>  #ifdef CONFIG_CGROUP_WRITEBACK
>  
>  struct list_head *mem_cgroup_cgwb_list(struct mem_cgroup *memcg);
> @@ -707,15 +677,35 @@ static inline void mem_cgroup_wb_stats(struct bdi_writeback *wb,
>  
>  struct sock;
>  #if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
> +extern struct static_key_false mem_cgroup_sockets;
> +static inline bool mem_cgroup_do_sockets(void)
> +{
> +	return static_branch_unlikely(&mem_cgroup_sockets);
> +}
>  void sock_update_memcg(struct sock *sk);
>  void sock_release_memcg(struct sock *sk);
> +bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
> +void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
>  #else
> +static inline bool mem_cgroup_do_sockets(void)
> +{
> +	return false;
> +}
>  static inline void sock_update_memcg(struct sock *sk)
>  {
>  }
>  static inline void sock_release_memcg(struct sock *sk)
>  {
>  }
> +static inline bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg,
> +					   unsigned int nr_pages)
> +{
> +	return true;
> +}
> +static inline void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg,
> +					     unsigned int nr_pages)
> +{
> +}
>  #endif /* CONFIG_INET && CONFIG_MEMCG_KMEM */
>  
>  #ifdef CONFIG_MEMCG_KMEM
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 59a7196..67795fc 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -69,22 +69,6 @@
>  #include <net/tcp_states.h>
>  #include <linux/net_tstamp.h>
>  
> -struct cgroup;
> -struct cgroup_subsys;
> -#ifdef CONFIG_NET
> -int mem_cgroup_sockets_init(struct mem_cgroup *memcg, struct cgroup_subsys *ss);
> -void mem_cgroup_sockets_destroy(struct mem_cgroup *memcg);
> -#else
> -static inline
> -int mem_cgroup_sockets_init(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
> -{
> -	return 0;
> -}
> -static inline
> -void mem_cgroup_sockets_destroy(struct mem_cgroup *memcg)
> -{
> -}
> -#endif
>  /*
>   * This structure really needs to be cleaned up.
>   * Most of it is for TCP, and not used by any of
> @@ -243,7 +227,6 @@ struct sock_common {
>  	/* public: */
>  };
>  
> -struct cg_proto;
>  /**
>    *	struct sock - network layer representation of sockets
>    *	@__sk_common: shared layout with inet_timewait_sock
> @@ -310,7 +293,7 @@ struct cg_proto;
>    *	@sk_security: used by security modules
>    *	@sk_mark: generic packet mark
>    *	@sk_classid: this socket's cgroup classid
> -  *	@sk_cgrp: this socket's cgroup-specific proto data
> +  *	@sk_memcg: this socket's memcg association
>    *	@sk_write_pending: a write to stream socket waits to start
>    *	@sk_state_change: callback to indicate change in the state of the sock
>    *	@sk_data_ready: callback to indicate there is data to be processed
> @@ -447,7 +430,7 @@ struct sock {
>  #ifdef CONFIG_CGROUP_NET_CLASSID
>  	u32			sk_classid;
>  #endif
> -	struct cg_proto		*sk_cgrp;
> +	struct mem_cgroup	*sk_memcg;
>  	void			(*sk_state_change)(struct sock *sk);
>  	void			(*sk_data_ready)(struct sock *sk);
>  	void			(*sk_write_space)(struct sock *sk);
> @@ -1051,18 +1034,6 @@ struct proto {
>  #ifdef SOCK_REFCNT_DEBUG
>  	atomic_t		socks;
>  #endif
> -#ifdef CONFIG_MEMCG_KMEM
> -	/*
> -	 * cgroup specific init/deinit functions. Called once for all
> -	 * protocols that implement it, from cgroups populate function.
> -	 * This function has to setup any files the protocol want to
> -	 * appear in the kmem cgroup filesystem.
> -	 */
> -	int			(*init_cgroup)(struct mem_cgroup *memcg,
> -					       struct cgroup_subsys *ss);
> -	void			(*destroy_cgroup)(struct mem_cgroup *memcg);
> -	struct cg_proto		*(*proto_cgroup)(struct mem_cgroup *memcg);
> -#endif
>  };
>  
>  int proto_register(struct proto *prot, int alloc_slab);
> @@ -1093,23 +1064,6 @@ static inline void sk_refcnt_debug_release(const struct sock *sk)
>  #define sk_refcnt_debug_release(sk) do { } while (0)
>  #endif /* SOCK_REFCNT_DEBUG */
>  
> -#if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_NET)
> -extern struct static_key memcg_socket_limit_enabled;
> -static inline struct cg_proto *parent_cg_proto(struct proto *proto,
> -					       struct cg_proto *cg_proto)
> -{
> -	return proto->proto_cgroup(parent_mem_cgroup(cg_proto->memcg));
> -}
> -#define mem_cgroup_sockets_enabled static_key_false(&memcg_socket_limit_enabled)
> -#else
> -#define mem_cgroup_sockets_enabled 0
> -static inline struct cg_proto *parent_cg_proto(struct proto *proto,
> -					       struct cg_proto *cg_proto)
> -{
> -	return NULL;
> -}
> -#endif
> -
>  static inline bool sk_stream_memory_free(const struct sock *sk)
>  {
>  	if (sk->sk_wmem_queued >= sk->sk_sndbuf)
> @@ -1136,9 +1090,6 @@ static inline bool sk_under_memory_pressure(const struct sock *sk)
>  	if (!sk->sk_prot->memory_pressure)
>  		return false;
>  
> -	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
> -		return !!sk->sk_cgrp->memory_pressure;
> -
>  	return !!*sk->sk_prot->memory_pressure;
>  }
>  
> @@ -1146,61 +1097,19 @@ static inline void sk_leave_memory_pressure(struct sock *sk)
>  {
>  	int *memory_pressure = sk->sk_prot->memory_pressure;
>  
> -	if (!memory_pressure)
> -		return;
> -
> -	if (*memory_pressure)
> +	if (memory_pressure && *memory_pressure)
>  		*memory_pressure = 0;
> -
> -	if (mem_cgroup_sockets_enabled && sk->sk_cgrp) {
> -		struct cg_proto *cg_proto = sk->sk_cgrp;
> -		struct proto *prot = sk->sk_prot;
> -
> -		for (; cg_proto; cg_proto = parent_cg_proto(prot, cg_proto))
> -			cg_proto->memory_pressure = 0;
> -	}
> -
>  }
>  
>  static inline void sk_enter_memory_pressure(struct sock *sk)
>  {
> -	if (!sk->sk_prot->enter_memory_pressure)
> -		return;
> -
> -	if (mem_cgroup_sockets_enabled && sk->sk_cgrp) {
> -		struct cg_proto *cg_proto = sk->sk_cgrp;
> -		struct proto *prot = sk->sk_prot;
> -
> -		for (; cg_proto; cg_proto = parent_cg_proto(prot, cg_proto))
> -			cg_proto->memory_pressure = 1;
> -	}
> -
> -	sk->sk_prot->enter_memory_pressure(sk);
> +	if (sk->sk_prot->enter_memory_pressure)
> +		sk->sk_prot->enter_memory_pressure(sk);
>  }
>  
>  static inline long sk_prot_mem_limits(const struct sock *sk, int index)
>  {
> -	long *prot = sk->sk_prot->sysctl_mem;
> -	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
> -		prot = sk->sk_cgrp->sysctl_mem;
> -	return prot[index];
> -}
> -
> -static inline void memcg_memory_allocated_add(struct cg_proto *prot,
> -					      unsigned long amt,
> -					      int *parent_status)
> -{
> -	page_counter_charge(&prot->memory_allocated, amt);
> -
> -	if (page_counter_read(&prot->memory_allocated) >
> -	    prot->memory_allocated.limit)
> -		*parent_status = OVER_LIMIT;
> -}
> -
> -static inline void memcg_memory_allocated_sub(struct cg_proto *prot,
> -					      unsigned long amt)
> -{
> -	page_counter_uncharge(&prot->memory_allocated, amt);
> +	return sk->sk_prot->sysctl_mem[index];
>  }
>  
>  static inline long
> @@ -1208,24 +1117,14 @@ sk_memory_allocated(const struct sock *sk)
>  {
>  	struct proto *prot = sk->sk_prot;
>  
> -	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
> -		return page_counter_read(&sk->sk_cgrp->memory_allocated);
> -
>  	return atomic_long_read(prot->memory_allocated);
>  }
>  
>  static inline long
> -sk_memory_allocated_add(struct sock *sk, int amt, int *parent_status)
> +sk_memory_allocated_add(struct sock *sk, int amt)
>  {
>  	struct proto *prot = sk->sk_prot;
>  
> -	if (mem_cgroup_sockets_enabled && sk->sk_cgrp) {
> -		memcg_memory_allocated_add(sk->sk_cgrp, amt, parent_status);
> -		/* update the root cgroup regardless */
> -		atomic_long_add_return(amt, prot->memory_allocated);
> -		return page_counter_read(&sk->sk_cgrp->memory_allocated);
> -	}
> -
>  	return atomic_long_add_return(amt, prot->memory_allocated);
>  }
>  
> @@ -1234,9 +1133,6 @@ sk_memory_allocated_sub(struct sock *sk, int amt)
>  {
>  	struct proto *prot = sk->sk_prot;
>  
> -	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
> -		memcg_memory_allocated_sub(sk->sk_cgrp, amt);
> -
>  	atomic_long_sub(amt, prot->memory_allocated);
>  }
>  
> @@ -1244,13 +1140,6 @@ static inline void sk_sockets_allocated_dec(struct sock *sk)
>  {
>  	struct proto *prot = sk->sk_prot;
>  
> -	if (mem_cgroup_sockets_enabled && sk->sk_cgrp) {
> -		struct cg_proto *cg_proto = sk->sk_cgrp;
> -
> -		for (; cg_proto; cg_proto = parent_cg_proto(prot, cg_proto))
> -			percpu_counter_dec(&cg_proto->sockets_allocated);
> -	}
> -
>  	percpu_counter_dec(prot->sockets_allocated);
>  }
>  
> @@ -1258,13 +1147,6 @@ static inline void sk_sockets_allocated_inc(struct sock *sk)
>  {
>  	struct proto *prot = sk->sk_prot;
>  
> -	if (mem_cgroup_sockets_enabled && sk->sk_cgrp) {
> -		struct cg_proto *cg_proto = sk->sk_cgrp;
> -
> -		for (; cg_proto; cg_proto = parent_cg_proto(prot, cg_proto))
> -			percpu_counter_inc(&cg_proto->sockets_allocated);
> -	}
> -
>  	percpu_counter_inc(prot->sockets_allocated);
>  }
>  
> @@ -1273,9 +1155,6 @@ sk_sockets_allocated_read_positive(struct sock *sk)
>  {
>  	struct proto *prot = sk->sk_prot;
>  
> -	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
> -		return percpu_counter_read_positive(&sk->sk_cgrp->sockets_allocated);
> -
>  	return percpu_counter_read_positive(prot->sockets_allocated);
>  }
>  
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index eed94fc..77b6c7e 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -291,9 +291,6 @@ extern int tcp_memory_pressure;
>  /* optimized version of sk_under_memory_pressure() for TCP sockets */
>  static inline bool tcp_under_memory_pressure(const struct sock *sk)
>  {
> -	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
> -		return !!sk->sk_cgrp->memory_pressure;
> -
>  	return tcp_memory_pressure;
>  }
>  /*
> diff --git a/include/net/tcp_memcontrol.h b/include/net/tcp_memcontrol.h
> deleted file mode 100644
> index 05b94d9..0000000
> --- a/include/net/tcp_memcontrol.h
> +++ /dev/null
> @@ -1,7 +0,0 @@
> -#ifndef _TCP_MEMCG_H
> -#define _TCP_MEMCG_H
> -
> -struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg);
> -int tcp_init_cgroup(struct mem_cgroup *memcg, struct cgroup_subsys *ss);
> -void tcp_destroy_cgroup(struct mem_cgroup *memcg);
> -#endif /* _TCP_MEMCG_H */
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e54f434..c41e6d7 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -66,7 +66,6 @@
>  #include "internal.h"
>  #include <net/sock.h>
>  #include <net/ip.h>
> -#include <net/tcp_memcontrol.h>
>  #include "slab.h"
>  
>  #include <asm/uaccess.h>
> @@ -291,58 +290,68 @@ static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
>  /* Writing them here to avoid exposing memcg's inner layout */
>  #if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
>  
> +DEFINE_STATIC_KEY_FALSE(mem_cgroup_sockets);
> +
>  void sock_update_memcg(struct sock *sk)
>  {
> -	if (mem_cgroup_sockets_enabled) {
> -		struct mem_cgroup *memcg;
> -		struct cg_proto *cg_proto;
> -
> -		BUG_ON(!sk->sk_prot->proto_cgroup);
> -
> -		/* Socket cloning can throw us here with sk_cgrp already
> -		 * filled. It won't however, necessarily happen from
> -		 * process context. So the test for root memcg given
> -		 * the current task's memcg won't help us in this case.
> -		 *
> -		 * Respecting the original socket's memcg is a better
> -		 * decision in this case.
> -		 */
> -		if (sk->sk_cgrp) {
> -			BUG_ON(mem_cgroup_is_root(sk->sk_cgrp->memcg));
> -			css_get(&sk->sk_cgrp->memcg->css);
> -			return;
> -		}
> -
> -		rcu_read_lock();
> -		memcg = mem_cgroup_from_task(current);
> -		cg_proto = sk->sk_prot->proto_cgroup(memcg);
> -		if (cg_proto && test_bit(MEMCG_SOCK_ACTIVE, &cg_proto->flags) &&
> -		    css_tryget_online(&memcg->css)) {
> -			sk->sk_cgrp = cg_proto;
> -		}
> -		rcu_read_unlock();
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
>  	}
> +
> +	rcu_read_lock();
> +	memcg = mem_cgroup_from_task(current);
> +	if (css_tryget_online(&memcg->css))
> +		sk->sk_memcg = memcg;
> +	rcu_read_unlock();
>  }
>  EXPORT_SYMBOL(sock_update_memcg);
>  
>  void sock_release_memcg(struct sock *sk)
>  {
> -	if (mem_cgroup_sockets_enabled && sk->sk_cgrp) {
> -		struct mem_cgroup *memcg;
> -		WARN_ON(!sk->sk_cgrp->memcg);
> -		memcg = sk->sk_cgrp->memcg;
> -		css_put(&sk->sk_cgrp->memcg->css);
> -	}
> +	if (sk->sk_memcg)
> +		css_put(&sk->sk_memcg->css);
>  }
>  
> -struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg)
> +/**
> + * mem_cgroup_charge_skmem - charge socket memory
> + * @memcg: memcg to charge
> + * @nr_pages: number of pages to charge
> + *
> + * Charges @nr_pages to @memcg. Returns %true if the charge fit within
> + * the memcg's configured limit, %false if the charge had to be forced.
> + */
> +bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
>  {
> -	if (!memcg || mem_cgroup_is_root(memcg))
> -		return NULL;
> +	struct page_counter *counter;
> +
> +	if (page_counter_try_charge(&memcg->skmem, nr_pages, &counter))
> +		return true;
>  
> -	return &memcg->tcp_mem;
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
>  }
> -EXPORT_SYMBOL(tcp_proto_cgroup);
>  
>  #endif
>  
> @@ -3592,13 +3601,7 @@ static int mem_cgroup_oom_control_write(struct cgroup_subsys_state *css,
>  #ifdef CONFIG_MEMCG_KMEM
>  static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
>  {
> -	int ret;
> -
> -	ret = memcg_propagate_kmem(memcg);
> -	if (ret)
> -		return ret;
> -
> -	return mem_cgroup_sockets_init(memcg, ss);
> +	return memcg_propagate_kmem(memcg);
>  }
>  
>  static void memcg_deactivate_kmem(struct mem_cgroup *memcg)
> @@ -3654,7 +3657,6 @@ static void memcg_destroy_kmem(struct mem_cgroup *memcg)
>  		static_key_slow_dec(&memcg_kmem_enabled_key);
>  		WARN_ON(page_counter_read(&memcg->kmem));
>  	}
> -	mem_cgroup_sockets_destroy(memcg);
>  }
>  #else
>  static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
> @@ -4218,6 +4220,7 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
>  		memcg->soft_limit = PAGE_COUNTER_MAX;
>  		page_counter_init(&memcg->memsw, NULL);
>  		page_counter_init(&memcg->kmem, NULL);
> +		page_counter_init(&memcg->skmem, NULL);
>  	}
>  
>  	memcg->last_scanned_node = MAX_NUMNODES;
> @@ -4266,6 +4269,7 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
>  		memcg->soft_limit = PAGE_COUNTER_MAX;
>  		page_counter_init(&memcg->memsw, &parent->memsw);
>  		page_counter_init(&memcg->kmem, &parent->kmem);
> +		page_counter_init(&memcg->skmem, &parent->skmem);
>  
>  		/*
>  		 * No need to take a reference to the parent because cgroup
> @@ -4277,6 +4281,7 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
>  		memcg->soft_limit = PAGE_COUNTER_MAX;
>  		page_counter_init(&memcg->memsw, NULL);
>  		page_counter_init(&memcg->kmem, NULL);
> +		page_counter_init(&memcg->skmem, NULL);
>  		/*
>  		 * Deeper hierachy with use_hierarchy == false doesn't make
>  		 * much sense so let cgroup subsystem know about this
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 0fafd27..0debff5 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -194,44 +194,6 @@ bool sk_net_capable(const struct sock *sk, int cap)
>  }
>  EXPORT_SYMBOL(sk_net_capable);
>  
> -
> -#ifdef CONFIG_MEMCG_KMEM
> -int mem_cgroup_sockets_init(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
> -{
> -	struct proto *proto;
> -	int ret = 0;
> -
> -	mutex_lock(&proto_list_mutex);
> -	list_for_each_entry(proto, &proto_list, node) {
> -		if (proto->init_cgroup) {
> -			ret = proto->init_cgroup(memcg, ss);
> -			if (ret)
> -				goto out;
> -		}
> -	}
> -
> -	mutex_unlock(&proto_list_mutex);
> -	return ret;
> -out:
> -	list_for_each_entry_continue_reverse(proto, &proto_list, node)
> -		if (proto->destroy_cgroup)
> -			proto->destroy_cgroup(memcg);
> -	mutex_unlock(&proto_list_mutex);
> -	return ret;
> -}
> -
> -void mem_cgroup_sockets_destroy(struct mem_cgroup *memcg)
> -{
> -	struct proto *proto;
> -
> -	mutex_lock(&proto_list_mutex);
> -	list_for_each_entry_reverse(proto, &proto_list, node)
> -		if (proto->destroy_cgroup)
> -			proto->destroy_cgroup(memcg);
> -	mutex_unlock(&proto_list_mutex);
> -}
> -#endif
> -
>  /*
>   * Each address family might have different locking rules, so we have
>   * one slock key per address family:
> @@ -239,11 +201,6 @@ void mem_cgroup_sockets_destroy(struct mem_cgroup *memcg)
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
> @@ -1476,12 +1433,6 @@ void sk_free(struct sock *sk)
>  }
>  EXPORT_SYMBOL(sk_free);
>  
> -static void sk_update_clone(const struct sock *sk, struct sock *newsk)
> -{
> -	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
> -		sock_update_memcg(newsk);
> -}
> -
>  /**
>   *	sk_clone_lock - clone a socket, and lock its clone
>   *	@sk: the socket to clone
> @@ -1577,7 +1528,8 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
>  		sk_set_socket(newsk, NULL);
>  		newsk->sk_wq = NULL;
>  
> -		sk_update_clone(sk, newsk);
> +		if (mem_cgroup_do_sockets())
> +			sock_update_memcg(newsk);
>  
>  		if (newsk->sk_prot->sockets_allocated)
>  			sk_sockets_allocated_inc(newsk);
> @@ -2036,27 +1988,27 @@ int __sk_mem_schedule(struct sock *sk, int size, int kind)
>  	struct proto *prot = sk->sk_prot;
>  	int amt = sk_mem_pages(size);
>  	long allocated;
> -	int parent_status = UNDER_LIMIT;
>  
>  	sk->sk_forward_alloc += amt * SK_MEM_QUANTUM;
>  
> -	allocated = sk_memory_allocated_add(sk, amt, &parent_status);
> +	allocated = sk_memory_allocated_add(sk, amt);
> +
> +	if (mem_cgroup_do_sockets() && sk->sk_memcg &&
> +	    !mem_cgroup_charge_skmem(sk->sk_memcg, amt))
> +		goto suppress_allocation;
>  
>  	/* Under limit. */
> -	if (parent_status == UNDER_LIMIT &&
> -			allocated <= sk_prot_mem_limits(sk, 0)) {
> +	if (allocated <= sk_prot_mem_limits(sk, 0)) {
>  		sk_leave_memory_pressure(sk);
>  		return 1;
>  	}
>  
> -	/* Under pressure. (we or our parents) */
> -	if ((parent_status > SOFT_LIMIT) ||
> -			allocated > sk_prot_mem_limits(sk, 1))
> +	/* Under pressure. */
> +	if (allocated > sk_prot_mem_limits(sk, 1))
>  		sk_enter_memory_pressure(sk);
>  
> -	/* Over hard limit (we or our parents) */
> -	if ((parent_status == OVER_LIMIT) ||
> -			(allocated > sk_prot_mem_limits(sk, 2)))
> +	/* Over hard limit. */
> +	if (allocated > sk_prot_mem_limits(sk, 2))
>  		goto suppress_allocation;
>  
>  	/* guarantee minimum buffer size under pressure */
> @@ -2105,6 +2057,9 @@ suppress_allocation:
>  
>  	sk_memory_allocated_sub(sk, amt);
>  
> +	if (mem_cgroup_do_sockets() && sk->sk_memcg)
> +		mem_cgroup_uncharge_skmem(sk->sk_memcg, amt);
> +
>  	return 0;
>  }
>  EXPORT_SYMBOL(__sk_mem_schedule);
> @@ -2120,6 +2075,9 @@ void __sk_mem_reclaim(struct sock *sk, int amount)
>  	sk_memory_allocated_sub(sk, amount);
>  	sk->sk_forward_alloc -= amount << SK_MEM_QUANTUM_SHIFT;
>  
> +	if (mem_cgroup_do_sockets() && sk->sk_memcg)
> +		mem_cgroup_uncharge_skmem(sk->sk_memcg, amount);
> +
>  	if (sk_under_memory_pressure(sk) &&
>  	    (sk_memory_allocated(sk) < sk_prot_mem_limits(sk, 0)))
>  		sk_leave_memory_pressure(sk);
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index 894da3a..1f00819 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -24,7 +24,6 @@
>  #include <net/cipso_ipv4.h>
>  #include <net/inet_frag.h>
>  #include <net/ping.h>
> -#include <net/tcp_memcontrol.h>
>  
>  static int zero;
>  static int one = 1;
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index ac1bdbb..ec931c0 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -421,7 +421,8 @@ void tcp_init_sock(struct sock *sk)
>  	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
>  
>  	local_bh_disable();
> -	sock_update_memcg(sk);
> +	if (mem_cgroup_do_sockets())
> +		sock_update_memcg(sk);
>  	sk_sockets_allocated_inc(sk);
>  	local_bh_enable();
>  }
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 30dd45c..bb5f4f2 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -73,7 +73,6 @@
>  #include <net/timewait_sock.h>
>  #include <net/xfrm.h>
>  #include <net/secure_seq.h>
> -#include <net/tcp_memcontrol.h>
>  #include <net/busy_poll.h>
>  
>  #include <linux/inet.h>
> @@ -1808,7 +1807,8 @@ void tcp_v4_destroy_sock(struct sock *sk)
>  	tcp_saved_syn_free(tp);
>  
>  	sk_sockets_allocated_dec(sk);
> -	sock_release_memcg(sk);
> +	if (mem_cgroup_do_sockets())
> +		sock_release_memcg(sk);
>  }
>  EXPORT_SYMBOL(tcp_v4_destroy_sock);
>  
> @@ -2330,11 +2330,6 @@ struct proto tcp_prot = {
>  	.compat_setsockopt	= compat_tcp_setsockopt,
>  	.compat_getsockopt	= compat_tcp_getsockopt,
>  #endif
> -#ifdef CONFIG_MEMCG_KMEM
> -	.init_cgroup		= tcp_init_cgroup,
> -	.destroy_cgroup		= tcp_destroy_cgroup,
> -	.proto_cgroup		= tcp_proto_cgroup,
> -#endif
>  };
>  EXPORT_SYMBOL(tcp_prot);
>  
> diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
> index 2379c1b..09a37eb 100644
> --- a/net/ipv4/tcp_memcontrol.c
> +++ b/net/ipv4/tcp_memcontrol.c
> @@ -1,107 +1,10 @@
> -#include <net/tcp.h>
> -#include <net/tcp_memcontrol.h>
> -#include <net/sock.h>
> -#include <net/ip.h>
> -#include <linux/nsproxy.h>
> +#include <linux/page_counter.h>
>  #include <linux/memcontrol.h>
> +#include <linux/cgroup.h>
>  #include <linux/module.h>
> -
> -int tcp_init_cgroup(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
> -{
> -	/*
> -	 * The root cgroup does not use page_counters, but rather,
> -	 * rely on the data already collected by the network
> -	 * subsystem
> -	 */
> -	struct mem_cgroup *parent = parent_mem_cgroup(memcg);
> -	struct page_counter *counter_parent = NULL;
> -	struct cg_proto *cg_proto, *parent_cg;
> -
> -	cg_proto = tcp_prot.proto_cgroup(memcg);
> -	if (!cg_proto)
> -		return 0;
> -
> -	cg_proto->sysctl_mem[0] = sysctl_tcp_mem[0];
> -	cg_proto->sysctl_mem[1] = sysctl_tcp_mem[1];
> -	cg_proto->sysctl_mem[2] = sysctl_tcp_mem[2];
> -	cg_proto->memory_pressure = 0;
> -	cg_proto->memcg = memcg;
> -
> -	parent_cg = tcp_prot.proto_cgroup(parent);
> -	if (parent_cg)
> -		counter_parent = &parent_cg->memory_allocated;
> -
> -	page_counter_init(&cg_proto->memory_allocated, counter_parent);
> -	percpu_counter_init(&cg_proto->sockets_allocated, 0, GFP_KERNEL);
> -
> -	return 0;
> -}
> -EXPORT_SYMBOL(tcp_init_cgroup);
> -
> -void tcp_destroy_cgroup(struct mem_cgroup *memcg)
> -{
> -	struct cg_proto *cg_proto;
> -
> -	cg_proto = tcp_prot.proto_cgroup(memcg);
> -	if (!cg_proto)
> -		return;
> -
> -	percpu_counter_destroy(&cg_proto->sockets_allocated);
> -
> -	if (test_bit(MEMCG_SOCK_ACTIVATED, &cg_proto->flags))
> -		static_key_slow_dec(&memcg_socket_limit_enabled);
> -
> -}
> -EXPORT_SYMBOL(tcp_destroy_cgroup);
> -
> -static int tcp_update_limit(struct mem_cgroup *memcg, unsigned long nr_pages)
> -{
> -	struct cg_proto *cg_proto;
> -	int i;
> -	int ret;
> -
> -	cg_proto = tcp_prot.proto_cgroup(memcg);
> -	if (!cg_proto)
> -		return -EINVAL;
> -
> -	ret = page_counter_limit(&cg_proto->memory_allocated, nr_pages);
> -	if (ret)
> -		return ret;
> -
> -	for (i = 0; i < 3; i++)
> -		cg_proto->sysctl_mem[i] = min_t(long, nr_pages,
> -						sysctl_tcp_mem[i]);
> -
> -	if (nr_pages == PAGE_COUNTER_MAX)
> -		clear_bit(MEMCG_SOCK_ACTIVE, &cg_proto->flags);
> -	else {
> -		/*
> -		 * The active bit needs to be written after the static_key
> -		 * update. This is what guarantees that the socket activation
> -		 * function is the last one to run. See sock_update_memcg() for
> -		 * details, and note that we don't mark any socket as belonging
> -		 * to this memcg until that flag is up.
> -		 *
> -		 * We need to do this, because static_keys will span multiple
> -		 * sites, but we can't control their order. If we mark a socket
> -		 * as accounted, but the accounting functions are not patched in
> -		 * yet, we'll lose accounting.
> -		 *
> -		 * We never race with the readers in sock_update_memcg(),
> -		 * because when this value change, the code to process it is not
> -		 * patched in yet.
> -		 *
> -		 * The activated bit is used to guarantee that no two writers
> -		 * will do the update in the same memcg. Without that, we can't
> -		 * properly shutdown the static key.
> -		 */
> -		if (!test_and_set_bit(MEMCG_SOCK_ACTIVATED, &cg_proto->flags))
> -			static_key_slow_inc(&memcg_socket_limit_enabled);
> -		set_bit(MEMCG_SOCK_ACTIVE, &cg_proto->flags);
> -	}
> -
> -	return 0;
> -}
> +#include <linux/kernfs.h>
> +#include <linux/mutex.h>
> +#include <net/tcp.h>
>  
>  enum {
>  	RES_USAGE,
> @@ -124,11 +27,17 @@ static ssize_t tcp_cgroup_write(struct kernfs_open_file *of,
>  	switch (of_cft(of)->private) {
>  	case RES_LIMIT:
>  		/* see memcontrol.c */
> +		if (memcg == root_mem_cgroup) {
> +			ret = -EINVAL;
> +			break;
> +		}
>  		ret = page_counter_memparse(buf, "-1", &nr_pages);
>  		if (ret)
>  			break;
>  		mutex_lock(&tcp_limit_mutex);
> -		ret = tcp_update_limit(memcg, nr_pages);
> +		ret = page_counter_limit(&memcg->skmem, nr_pages);
> +		if (!ret)
> +			static_branch_enable(&mem_cgroup_sockets);
>  		mutex_unlock(&tcp_limit_mutex);
>  		break;
>  	default:
> @@ -141,32 +50,28 @@ static ssize_t tcp_cgroup_write(struct kernfs_open_file *of,
>  static u64 tcp_cgroup_read(struct cgroup_subsys_state *css, struct cftype *cft)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> -	struct cg_proto *cg_proto = tcp_prot.proto_cgroup(memcg);
>  	u64 val;
>  
>  	switch (cft->private) {
>  	case RES_LIMIT:
> -		if (!cg_proto)
> -			return PAGE_COUNTER_MAX;
> -		val = cg_proto->memory_allocated.limit;
> +		val = memcg->skmem.limit;
>  		val *= PAGE_SIZE;
>  		break;
>  	case RES_USAGE:
> -		if (!cg_proto)
> +		if (memcg == root_mem_cgroup)
>  			val = atomic_long_read(&tcp_memory_allocated);
>  		else
> -			val = page_counter_read(&cg_proto->memory_allocated);
> +			val = page_counter_read(&memcg->skmem);
>  		val *= PAGE_SIZE;
>  		break;
>  	case RES_FAILCNT:
> -		if (!cg_proto)
> -			return 0;
> -		val = cg_proto->memory_allocated.failcnt;
> +		val = memcg->skmem.failcnt;
>  		break;
>  	case RES_MAX_USAGE:
> -		if (!cg_proto)
> -			return 0;
> -		val = cg_proto->memory_allocated.watermark;
> +		if (memcg == root_mem_cgroup)
> +			val = 0;
> +		else
> +			val = memcg->skmem.watermark;
>  		val *= PAGE_SIZE;
>  		break;
>  	default:
> @@ -178,20 +83,14 @@ static u64 tcp_cgroup_read(struct cgroup_subsys_state *css, struct cftype *cft)
>  static ssize_t tcp_cgroup_reset(struct kernfs_open_file *of,
>  				char *buf, size_t nbytes, loff_t off)
>  {
> -	struct mem_cgroup *memcg;
> -	struct cg_proto *cg_proto;
> -
> -	memcg = mem_cgroup_from_css(of_css(of));
> -	cg_proto = tcp_prot.proto_cgroup(memcg);
> -	if (!cg_proto)
> -		return nbytes;
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
>  
>  	switch (of_cft(of)->private) {
>  	case RES_MAX_USAGE:
> -		page_counter_reset_watermark(&cg_proto->memory_allocated);
> +		page_counter_reset_watermark(&memcg->skmem);
>  		break;
>  	case RES_FAILCNT:
> -		cg_proto->memory_allocated.failcnt = 0;
> +		memcg->skmem.failcnt = 0;
>  		break;
>  	}
>  
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 19adedb..b496fc9 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2819,13 +2819,15 @@ begin_fwd:
>   */
>  void sk_forced_mem_schedule(struct sock *sk, int size)
>  {
> -	int amt, status;
> +	int amt;
>  
>  	if (size <= sk->sk_forward_alloc)
>  		return;
>  	amt = sk_mem_pages(size);
>  	sk->sk_forward_alloc += amt * SK_MEM_QUANTUM;
> -	sk_memory_allocated_add(sk, amt, &status);
> +	sk_memory_allocated_add(sk, amt);
> +	if (mem_cgroup_do_sockets() && sk->sk_memcg)
> +		mem_cgroup_charge_skmem(sk->sk_memcg, amt);
>  }
>  
>  /* Send a FIN. The caller locks the socket for us.
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index f495d18..cf19e65 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -1862,9 +1862,6 @@ struct proto tcpv6_prot = {
>  	.compat_setsockopt	= compat_tcp_setsockopt,
>  	.compat_getsockopt	= compat_tcp_getsockopt,
>  #endif
> -#ifdef CONFIG_MEMCG_KMEM
> -	.proto_cgroup		= tcp_proto_cgroup,
> -#endif
>  	.clear_sk		= tcp_v6_clear_sk,
>  };
>  
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
