Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5C1C56B0033
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 04:25:25 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id p5so5269617pgn.7
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 01:25:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p91si6102245plb.83.2017.09.19.01.25.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Sep 2017 01:25:24 -0700 (PDT)
Date: Tue, 19 Sep 2017 10:25:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: use vmalloc fallback for large kmem
 memcg arrays
Message-ID: <20170919082517.gpqwxywsd53vyjto@dhcp22.suse.cz>
References: <20170918184919.20644-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170918184919.20644-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon 18-09-17 14:49:19, Johannes Weiner wrote:
> For quick per-memcg indexing, slab caches and list_lru structures
> maintain linear arrays of descriptors. As the number of concurrent
> memory cgroups in the system goes up, this requires large contiguous
> allocations (8k cgroups = order-5, 16k cgroups = order-6 etc.) for
> every existing slab cache and list_lru, which can easily fail on
> loaded systems. E.g.:
> 
> mkdir: page allocation failure: order:5, mode:0x14040c0(GFP_KERNEL|__GFP_COMP), nodemask=(null)
> CPU: 1 PID: 6399 Comm: mkdir Not tainted 4.13.0-mm1-00065-g720bbe532b7c-dirty #481
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-20170228_101828-anatol 04/01/2014
> Call Trace:
>  dump_stack+0x70/0x9d
>  warn_alloc+0xd6/0x170
>  ? __alloc_pages_direct_compact+0x4c/0x110
>  __alloc_pages_nodemask+0xf50/0x1430
>  ? __lock_acquire+0xd19/0x1360
>  ? memcg_update_all_list_lrus+0x2e/0x2e0
>  ? __mutex_lock+0x7c/0x950
>  ? memcg_update_all_list_lrus+0x2e/0x2e0
>  alloc_pages_current+0x60/0xc0
>  kmalloc_order_trace+0x29/0x1b0
>  __kmalloc+0x1f4/0x320
>  memcg_update_all_list_lrus+0xca/0x2e0
>  mem_cgroup_css_alloc+0x612/0x670
>  cgroup_apply_control_enable+0x19e/0x360
>  cgroup_mkdir+0x322/0x490
>  kernfs_iop_mkdir+0x55/0x80
>  vfs_mkdir+0xd0/0x120
>  SyS_mkdirat+0x6c/0xe0
>  SyS_mkdir+0x14/0x20
>  entry_SYSCALL_64_fastpath+0x18/0xad
> RIP: 0033:0x7f9ff36cee87
> RSP: 002b:00007ffc7612d758 EFLAGS: 00000202 ORIG_RAX: 0000000000000053
> RAX: ffffffffffffffda RBX: 00007ffc7612da48 RCX: 00007f9ff36cee87
> RDX: 00000000000001ff RSI: 00000000000001ff RDI: 00007ffc7612de86
> RBP: 0000000000000002 R08: 00000000000001ff R09: 0000000000401db0
> R10: 00000000000001e2 R11: 0000000000000202 R12: 0000000000000000
> R13: 00007ffc7612da40 R14: 0000000000000000 R15: 0000000000000000
> Mem-Info:
> active_anon:2965 inactive_anon:19 isolated_anon:0
>  active_file:100270 inactive_file:98846 isolated_file:0
>  unevictable:0 dirty:0 writeback:0 unstable:0
>  slab_reclaimable:7328 slab_unreclaimable:16402
>  mapped:771 shmem:52 pagetables:278 bounce:0
>  free:13718 free_pcp:0 free_cma:0
> 
> This output is from an artificial reproducer, but we have repeatedly
> observed order-7 failures in production in the Facebook fleet. These
> systems become useless as they cannot run more jobs, even though there
> is plenty of memory to allocate 128 individual pages.
> 
> Use kvmalloc and kvzalloc to fall back to vmalloc space if these
> arrays prove too large for allocating them physically contiguous.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/list_lru.c    | 12 ++++++------
>  mm/slab_common.c | 22 +++++++++++++++-------
>  2 files changed, 21 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/list_lru.c b/mm/list_lru.c
> index 7a40fa2be858..f141f0c80ff3 100644
> --- a/mm/list_lru.c
> +++ b/mm/list_lru.c
> @@ -325,12 +325,12 @@ static int memcg_init_list_lru_node(struct list_lru_node *nlru)
>  {
>  	int size = memcg_nr_cache_ids;
>  
> -	nlru->memcg_lrus = kmalloc(size * sizeof(void *), GFP_KERNEL);
> +	nlru->memcg_lrus = kvmalloc(size * sizeof(void *), GFP_KERNEL);
>  	if (!nlru->memcg_lrus)
>  		return -ENOMEM;
>  
>  	if (__memcg_init_list_lru_node(nlru->memcg_lrus, 0, size)) {
> -		kfree(nlru->memcg_lrus);
> +		kvfree(nlru->memcg_lrus);
>  		return -ENOMEM;
>  	}
>  
> @@ -340,7 +340,7 @@ static int memcg_init_list_lru_node(struct list_lru_node *nlru)
>  static void memcg_destroy_list_lru_node(struct list_lru_node *nlru)
>  {
>  	__memcg_destroy_list_lru_node(nlru->memcg_lrus, 0, memcg_nr_cache_ids);
> -	kfree(nlru->memcg_lrus);
> +	kvfree(nlru->memcg_lrus);
>  }
>  
>  static int memcg_update_list_lru_node(struct list_lru_node *nlru,
> @@ -351,12 +351,12 @@ static int memcg_update_list_lru_node(struct list_lru_node *nlru,
>  	BUG_ON(old_size > new_size);
>  
>  	old = nlru->memcg_lrus;
> -	new = kmalloc(new_size * sizeof(void *), GFP_KERNEL);
> +	new = kvmalloc(new_size * sizeof(void *), GFP_KERNEL);
>  	if (!new)
>  		return -ENOMEM;
>  
>  	if (__memcg_init_list_lru_node(new, old_size, new_size)) {
> -		kfree(new);
> +		kvfree(new);
>  		return -ENOMEM;
>  	}
>  
> @@ -373,7 +373,7 @@ static int memcg_update_list_lru_node(struct list_lru_node *nlru,
>  	nlru->memcg_lrus = new;
>  	spin_unlock_irq(&nlru->lock);
>  
> -	kfree(old);
> +	kvfree(old);
>  	return 0;
>  }
>  
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 904a83be82de..80164599ca5d 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -165,9 +165,9 @@ static int init_memcg_params(struct kmem_cache *s,
>  	if (!memcg_nr_cache_ids)
>  		return 0;
>  
> -	arr = kzalloc(sizeof(struct memcg_cache_array) +
> -		      memcg_nr_cache_ids * sizeof(void *),
> -		      GFP_KERNEL);
> +	arr = kvzalloc(sizeof(struct memcg_cache_array) +
> +		       memcg_nr_cache_ids * sizeof(void *),
> +		       GFP_KERNEL);
>  	if (!arr)
>  		return -ENOMEM;
>  
> @@ -178,15 +178,23 @@ static int init_memcg_params(struct kmem_cache *s,
>  static void destroy_memcg_params(struct kmem_cache *s)
>  {
>  	if (is_root_cache(s))
> -		kfree(rcu_access_pointer(s->memcg_params.memcg_caches));
> +		kvfree(rcu_access_pointer(s->memcg_params.memcg_caches));
> +}
> +
> +static void free_memcg_params(struct rcu_head *rcu)
> +{
> +	struct memcg_cache_array *old;
> +
> +	old = container_of(rcu, struct memcg_cache_array, rcu);
> +	kvfree(old);
>  }
>  
>  static int update_memcg_params(struct kmem_cache *s, int new_array_size)
>  {
>  	struct memcg_cache_array *old, *new;
>  
> -	new = kzalloc(sizeof(struct memcg_cache_array) +
> -		      new_array_size * sizeof(void *), GFP_KERNEL);
> +	new = kvzalloc(sizeof(struct memcg_cache_array) +
> +		       new_array_size * sizeof(void *), GFP_KERNEL);
>  	if (!new)
>  		return -ENOMEM;
>  
> @@ -198,7 +206,7 @@ static int update_memcg_params(struct kmem_cache *s, int new_array_size)
>  
>  	rcu_assign_pointer(s->memcg_params.memcg_caches, new);
>  	if (old)
> -		kfree_rcu(old, rcu);
> +		call_rcu(&old->rcu, free_memcg_params);
>  	return 0;
>  }
>  
> -- 
> 2.14.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
