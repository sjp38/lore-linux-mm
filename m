Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9A9096B02A4
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 00:13:01 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH 1/4 -mm][memcg] quick ID lookup in memcg
References: <20100805184434.3a29c0f9.kamezawa.hiroyu@jp.fujitsu.com>
	<20100805185713.4d09339e.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 05 Aug 2010 21:12:50 -0700
In-Reply-To: <20100805185713.4d09339e.kamezawa.hiroyu@jp.fujitsu.com>
	(KAMEZAWA Hiroyuki's message of "Thu, 5 Aug 2010 18:57:13 +0900")
Message-ID: <xr93zkx0z8e5.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, vgoyal@redhat.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
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
> Changelog: 20100804
>  - fixed description in init/Kconfig
>
> Changelog: 20100730
>  - fixed rcu_read_unlock() placement.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  init/Kconfig    |   10 ++++++++++
>  mm/memcontrol.c |   48 ++++++++++++++++++++++++++++++++++--------------
>  2 files changed, 44 insertions(+), 14 deletions(-)
>
> Index: mmotm-0727/mm/memcontrol.c
> ===================================================================
> --- mmotm-0727.orig/mm/memcontrol.c
> +++ mmotm-0727/mm/memcontrol.c
> @@ -292,6 +292,30 @@ static bool move_file(void)
>  					&mc.to->move_charge_at_immigrate);
>  }
>  
> +/* 0 is unused */
> +static atomic_t mem_cgroup_num;
> +#define NR_MEMCG_GROUPS (CONFIG_MEM_CGROUP_MAX_GROUPS + 1)
> +static struct mem_cgroup *mem_cgroups[NR_MEMCG_GROUPS] __read_mostly;
> +
> +static struct mem_cgroup *id_to_memcg(unsigned short id)
> +{
> +	/*
> +	 * This array is set to NULL when mem_cgroup is freed.
> +	 * IOW, there are no more references && rcu_synchronized().
> +	 * This lookup-caching is safe.
> +	 */
> +	if (unlikely(!mem_cgroups[id])) {
> +		struct cgroup_subsys_state *css;
> +
> +		rcu_read_lock();
> +		css = css_lookup(&mem_cgroup_subsys, id);
> +		rcu_read_unlock();
> +		if (!css)
> +			return NULL;
> +		mem_cgroups[id] = container_of(css, struct mem_cgroup, css);
> +	}
> +	return mem_cgroups[id];
> +}

I am worried that id may be larger than CONFIG_MEM_CGROUP_MAX_GROUPS and
cause an illegal array index.  I see that
mem_cgroup_uncharge_swapcache() uses css_id() to compute 'id'.
mem_cgroup_num ensures that there are never more than
CONFIG_MEM_CGROUP_MAX_GROUPS memcg active.  But do we have guarantee
that the that all of the css_id of each active memcg are less than
NR_MEMCG_GROUPS?

>  /*
>   * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft
>   * limit reclaim to prevent infinite loops, if they ever occur.
> @@ -1824,18 +1848,7 @@ static void mem_cgroup_cancel_charge(str
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
> @@ -1856,7 +1869,7 @@ struct mem_cgroup *try_get_mem_cgroup_fr
>  		ent.val = page_private(page);
>  		id = lookup_swap_cgroup(ent);
>  		rcu_read_lock();
> -		mem = mem_cgroup_lookup(id);
> +		mem = id_to_memcg(id);
>  		if (mem && !css_tryget(&mem->css))
>  			mem = NULL;
>  		rcu_read_unlock();
> @@ -2208,7 +2221,7 @@ __mem_cgroup_commit_charge_swapin(struct
>  
>  		id = swap_cgroup_record(ent, 0);
>  		rcu_read_lock();
> -		memcg = mem_cgroup_lookup(id);
> +		memcg = id_to_memcg(id);
>  		if (memcg) {
>  			/*
>  			 * This recorded memcg can be obsolete one. So, avoid
> @@ -2472,7 +2485,7 @@ void mem_cgroup_uncharge_swap(swp_entry_
>  
>  	id = swap_cgroup_record(ent, 0);
>  	rcu_read_lock();
> -	memcg = mem_cgroup_lookup(id);
> +	memcg = id_to_memcg(id);
>  	if (memcg) {
>  		/*
>  		 * We uncharge this because swap is freed.
> @@ -3988,6 +4001,9 @@ static struct mem_cgroup *mem_cgroup_all
>  	struct mem_cgroup *mem;
>  	int size = sizeof(struct mem_cgroup);
>  
> +	if (atomic_read(&mem_cgroup_num) == NR_MEMCG_GROUPS)
> +		return NULL;
> +

I think that multiple tasks to be simultaneously running
mem_cgroup_create().  Therefore more than NR_MEMCG_GROUPS memcg may be
created.

>  	/* Can be very big if MAX_NUMNODES is very big */
>  	if (size < PAGE_SIZE)
>  		mem = kmalloc(size, GFP_KERNEL);
> @@ -4025,7 +4041,10 @@ static void __mem_cgroup_free(struct mem
>  	int node;
>  
>  	mem_cgroup_remove_from_trees(mem);
> +	/* No more lookup against this ID */
> +	mem_cgroups[css_id(&mem->css)] = NULL;
>  	free_css_id(&mem_cgroup_subsys, &mem->css);
> +	atomic_dec(&mem_cgroup_num);
>  
>  	for_each_node_state(node, N_POSSIBLE)
>  		free_mem_cgroup_per_zone_info(mem, node);
> @@ -4162,6 +4181,7 @@ mem_cgroup_create(struct cgroup_subsys *
>  	atomic_set(&mem->refcnt, 1);
>  	mem->move_charge_at_immigrate = 0;
>  	mutex_init(&mem->thresholds_lock);
> +	atomic_inc(&mem_cgroup_num);
>  	return &mem->css;
>  free_out:
>  	__mem_cgroup_free(mem);
> Index: mmotm-0727/init/Kconfig
> ===================================================================
> --- mmotm-0727.orig/init/Kconfig
> +++ mmotm-0727/init/Kconfig
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
