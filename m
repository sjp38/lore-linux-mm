Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 470F36B0402
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 03:45:27 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH 2/5] memcg: use array and ID for quick look up
References: <20100820185552.426ff12e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100820185917.87876cb0.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 24 Aug 2010 00:44:59 -0700
Message-ID: <xr9339u4pi84.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kamezawa.hiroyuki@gmail.com
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Now, memory cgroup has an ID per cgroup and make use of it at
>  - hierarchy walk,
>  - swap recording.
>
> This patch is for making more use of it. The final purpose is
> to replace page_cgroup->mem_cgroup's pointer to an unsigned short.
>
> This patch caches a pointer of memcg in an array. By this, we
> don't have to call css_lookup() which requires radix-hash walk.
> This saves some amount of memory footprint at lookup memcg via id.
>
> Changelog: 20100811
>  - adjusted onto mmotm-2010-08-11
>  - fixed RCU related parts.
>  - use attach_id() callback.
>
> Changelog: 20100804
>  - fixed description in init/Kconfig
>
> Changelog: 20100730
>  - fixed rcu_read_unlock() placement.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  init/Kconfig    |   10 ++++++
>  mm/memcontrol.c |   83 ++++++++++++++++++++++++++++++++++++++++++--------------
>  2 files changed, 73 insertions(+), 20 deletions(-)
>
> Index: mmotm-0811/mm/memcontrol.c
> ===================================================================
> --- mmotm-0811.orig/mm/memcontrol.c
> +++ mmotm-0811/mm/memcontrol.c
> @@ -195,6 +195,7 @@ static void mem_cgroup_oom_notify(struct
>   */
>  struct mem_cgroup {
>  	struct cgroup_subsys_state css;
> +	int	valid; /* for checking validness under RCU access.*/
>  	/*
>  	 * the counter to account for memory usage
>  	 */
> @@ -294,6 +295,29 @@ static bool move_file(void)
>  					&mc.to->move_charge_at_immigrate);
>  }
>  
> +/* 0 is unused */
> +static atomic_t mem_cgroup_num;
> +#define NR_MEMCG_GROUPS (CONFIG_MEM_CGROUP_MAX_GROUPS + 1)
> +static struct mem_cgroup *mem_cgroups[NR_MEMCG_GROUPS] __read_mostly;
> +
> +/* Must be called under rcu_read_lock */
> +static struct mem_cgroup *id_to_memcg(unsigned short id)
> +{
> +	struct mem_cgroup *ret;
> +	/* see mem_cgroup_free() */
> +	ret = rcu_dereference_check(mem_cgroups[id], rch_read_lock_held());

I think this be rcu_read_lock_held() instead of rch_read_lock_held()?

> +	if (likely(ret && ret->valid))
> +		return ret;
> +	return NULL;
> +}
> +
> +static void register_memcg_id(struct mem_cgroup *mem)
> +{
> +	int id = css_id(&mem->css);
> +	rcu_assign_pointer(mem_cgroups[id], mem);
> +	VM_BUG_ON(!mem->valid);
> +}
> +
>  /*
>   * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft
>   * limit reclaim to prevent infinite loops, if they ever occur.
> @@ -1847,18 +1871,7 @@ static void mem_cgroup_cancel_charge(str
>   * it's concern. (dropping refcnt from swap can be called against removed
>   * memcg.)
>   */
> -static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
> -{
> -	struct cgroup_subsys_state *css;
>  
> -	/* ID 0 is unused ID */
> -	if (!id)
> -		return NULL;
> -	css = css_lookup(&mem_cgroup_subsys, id);
> -	if (!css)
> -		return NULL;
> -	return container_of(css, struct mem_cgroup, css);
> -}
>  
>  struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
>  {
> @@ -1879,7 +1892,7 @@ struct mem_cgroup *try_get_mem_cgroup_fr
>  		ent.val = page_private(page);
>  		id = lookup_swap_cgroup(ent);
>  		rcu_read_lock();
> -		mem = mem_cgroup_lookup(id);
> +		mem = id_to_memcg(id);
>  		if (mem && !css_tryget(&mem->css))
>  			mem = NULL;
>  		rcu_read_unlock();
> @@ -2231,7 +2244,7 @@ __mem_cgroup_commit_charge_swapin(struct
>  
>  		id = swap_cgroup_record(ent, 0);
>  		rcu_read_lock();
> -		memcg = mem_cgroup_lookup(id);
> +		memcg = id_to_memcg(id);
>  		if (memcg) {
>  			/*
>  			 * This recorded memcg can be obsolete one. So, avoid
> @@ -2240,9 +2253,10 @@ __mem_cgroup_commit_charge_swapin(struct
>  			if (!mem_cgroup_is_root(memcg))
>  				res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
>  			mem_cgroup_swap_statistics(memcg, false);
> +			rcu_read_unlock();
>  			mem_cgroup_put(memcg);
> -		}
> -		rcu_read_unlock();
> +		} else
> +			rcu_read_unlock();
>  	}
>  	/*
>  	 * At swapin, we may charge account against cgroup which has no tasks.
> @@ -2495,7 +2509,7 @@ void mem_cgroup_uncharge_swap(swp_entry_
>  
>  	id = swap_cgroup_record(ent, 0);
>  	rcu_read_lock();
> -	memcg = mem_cgroup_lookup(id);
> +	memcg = id_to_memcg(id);
>  	if (memcg) {
>  		/*
>  		 * We uncharge this because swap is freed.
> @@ -2504,9 +2518,10 @@ void mem_cgroup_uncharge_swap(swp_entry_
>  		if (!mem_cgroup_is_root(memcg))
>  			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
>  		mem_cgroup_swap_statistics(memcg, false);
> +		rcu_read_unlock();
>  		mem_cgroup_put(memcg);
> -	}
> -	rcu_read_unlock();
> +	} else
> +		rcu_read_unlock();
>  }
>  
>  /**
> @@ -4010,6 +4025,9 @@ static struct mem_cgroup *mem_cgroup_all
>  	struct mem_cgroup *mem;
>  	int size = sizeof(struct mem_cgroup);
>  
> +	if (atomic_read(&mem_cgroup_num) == NR_MEMCG_GROUPS)
> +		return NULL;
> +
>  	/* Can be very big if MAX_NUMNODES is very big */
>  	if (size < PAGE_SIZE)
>  		mem = kmalloc(size, GFP_KERNEL);
> @@ -4020,6 +4038,7 @@ static struct mem_cgroup *mem_cgroup_all
>  		return NULL;
>  
>  	memset(mem, 0, size);
> +	mem->valid = 1;
>  	mem->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
>  	if (!mem->stat) {
>  		if (size < PAGE_SIZE)
> @@ -4049,6 +4068,7 @@ static void __mem_cgroup_free(struct mem
>  	mem_cgroup_remove_from_trees(mem);
>  	free_css_id(&mem_cgroup_subsys, &mem->css);
>  
> +	atomic_dec(&mem_cgroup_num);
>  	for_each_node_state(node, N_POSSIBLE)
>  		free_mem_cgroup_per_zone_info(mem, node);
>  
> @@ -4059,6 +4079,19 @@ static void __mem_cgroup_free(struct mem
>  		vfree(mem);
>  }
>  
> +static void mem_cgroup_free(struct mem_cgroup *mem)
> +{
> +	/* No more lookup */
> +	mem->valid = 0;
> +	rcu_assign_pointer(mem_cgroups[css_id(&mem->css)], NULL);
> +	/*
> +	 * Because we call vfree() etc...use synchronize_rcu() rather than
> + 	 * call_rcu();
> + 	 */
> +	synchronize_rcu();
> +	__mem_cgroup_free(mem);
> +}
> +
>  static void mem_cgroup_get(struct mem_cgroup *mem)
>  {
>  	atomic_inc(&mem->refcnt);
> @@ -4068,7 +4101,7 @@ static void __mem_cgroup_put(struct mem_
>  {
>  	if (atomic_sub_and_test(count, &mem->refcnt)) {
>  		struct mem_cgroup *parent = parent_mem_cgroup(mem);
> -		__mem_cgroup_free(mem);
> +		mem_cgroup_free(mem);
>  		if (parent)
>  			mem_cgroup_put(parent);
>  	}
> @@ -4184,13 +4217,22 @@ mem_cgroup_create(struct cgroup_subsys *
>  	atomic_set(&mem->refcnt, 1);
>  	mem->move_charge_at_immigrate = 0;
>  	mutex_init(&mem->thresholds_lock);
> +	atomic_inc(&mem_cgroup_num);
>  	return &mem->css;
>  free_out:
> -	__mem_cgroup_free(mem);
> +	mem_cgroup_free(mem);
>  	root_mem_cgroup = NULL;
>  	return ERR_PTR(error);
>  }
>  
> +static void
> +mem_cgroup_id_attached(struct cgroup_subsys *ss, struct cgroup *cont)
> +{
> +	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
> +
> +	register_memcg_id(mem);
> +}
> +
>  static int mem_cgroup_pre_destroy(struct cgroup_subsys *ss,
>  					struct cgroup *cont)
>  {
> @@ -4714,6 +4756,7 @@ struct cgroup_subsys mem_cgroup_subsys =
>  	.can_attach = mem_cgroup_can_attach,
>  	.cancel_attach = mem_cgroup_cancel_attach,
>  	.attach = mem_cgroup_move_task,
> +	.id_attached = mem_cgroup_id_attached,
>  	.early_init = 0,
>  	.use_id = 1,
>  };
> Index: mmotm-0811/init/Kconfig
> ===================================================================
> --- mmotm-0811.orig/init/Kconfig
> +++ mmotm-0811/init/Kconfig
> @@ -594,6 +594,16 @@ config CGROUP_MEM_RES_CTLR_SWAP
>  	  Now, memory usage of swap_cgroup is 2 bytes per entry. If swap page
>  	  size is 4096bytes, 512k per 1Gbytes of swap.
>  
> +config MEM_CGROUP_MAX_GROUPS
> +	int "Maximum number of memory cgroups on a system"
> +	range 1 65535
> +	default 8192 if 64BIT
> +	default 2048 if 32BIT
> +	help
> +	  Memory cgroup has limitation of the number of groups created.
> +	  Please select your favorite value. The more you allow, the more
> +	  memory(a pointer per group) will be consumed.
> +
>  menuconfig CGROUP_SCHED
>  	bool "Group CPU scheduler"
>  	depends on EXPERIMENTAL && CGROUPS

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
