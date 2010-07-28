Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 98B9B6B02A4
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 03:09:37 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [RFC][PATCH 5/7][memcg] memcg lockless update of file mapped
References: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100727165938.633a1ede.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 28 Jul 2010 00:09:21 -0700
In-Reply-To: <20100727165938.633a1ede.kamezawa.hiroyu@jp.fujitsu.com>
	(KAMEZAWA Hiroyuki's message of "Tue, 27 Jul 2010 16:59:38 +0900")
Message-ID: <xr93pqy8krq6.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> At accounting file events per memory cgroup, we need to find memory cgroup
> via page_cgroup->mem_cgroup. Now, we use lock_page_cgroup().
>
> But, considering the context which page-cgroup for files are accessed,
> we can use alternative light-weight mutual execusion in the most case.
> At handling file-caches, the only race we have to take care of is "moving"
> account, IOW, overwriting page_cgroup->mem_cgroup. Because file status
> update is done while the page-cache is in stable state, we don't have to
> take care of race with charge/uncharge.
>
> Unlike charge/uncharge, "move" happens not so frequently. It happens only when
> rmdir() and task-moving (with a special settings.)
> This patch adds a race-checker for file-cache-status accounting v.s. account
> moving. The new per-cpu-per-memcg counter MEM_CGROUP_ON_MOVE is added.
> The routine for account move 
>   1. Increment it before start moving
>   2. Call synchronize_rcu()
>   3. Decrement it after the end of moving.
> By this, file-status-counting routine can check it needs to call
> lock_page_cgroup(). In most case, I doesn't need to call it.
>
> Note: update_file_mapped is safe against charge/uncharge even if it's
> not under address_space->tree_lock or lock_page(). Because it's under
> page_table_lock(), anyone can't unmap it...then, anyone can't uncharge().
>
>
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |   64 ++++++++++++++++++++++++++++++++++++++++++++++++++++----
>  1 file changed, 60 insertions(+), 4 deletions(-)
>
> Index: mmotm-0719/mm/memcontrol.c
> ===================================================================
> --- mmotm-0719.orig/mm/memcontrol.c
> +++ mmotm-0719/mm/memcontrol.c
> @@ -89,6 +89,7 @@ enum mem_cgroup_stat_index {
>  	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
>  	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
>  	MEM_CGROUP_EVENTS,	/* incremented at every  pagein/pageout */
> +	MEM_CGROUP_ON_MOVE,   /* A check for locking move account/status */
>  
>  	MEM_CGROUP_STAT_NSTATS,
>  };
> @@ -1071,7 +1072,48 @@ static unsigned int get_swappiness(struc
>  	return swappiness;
>  }
>  
> -/* A routine for testing mem is not under move_account */
> +static void mem_cgroup_start_move(struct mem_cgroup *mem)
> +{
> +	int cpu;
> +	/* for fast checking in mem_cgroup_update_file_stat() etc..*/
> +	spin_lock(&mc.lock);
> +	for_each_possible_cpu(cpu)
> +		per_cpu(mem->stat->count[MEM_CGROUP_ON_MOVE], cpu) += 1;
> +	spin_unlock(&mc.lock);
> +
> +	synchronize_rcu();
> +}
> +
> +static void mem_cgroup_end_move(struct mem_cgroup *mem)
> +{
> +	int cpu;
> +
> +	if (!mem)
> +		return;
> +	/* for fast checking in mem_cgroup_update_file_stat() etc..*/
> +	spin_lock(&mc.lock);
> +	for_each_possible_cpu(cpu)
> +		per_cpu(mem->stat->count[MEM_CGROUP_ON_MOVE], cpu) -= 1;
> +	spin_unlock(&mc.lock);
> +}
> +
> +/*
> + * mem_cgroup_is_moved -- checking a cgroup is mc.from target or not.
> + *                          used for avoiding race.
> + * mem_cgroup_under_move -- checking a cgroup is mc.from or mc.to or
> + *			    under hierarchy of them. used for waiting at
> + *			    memory pressure.
> + * Result of is_moved can be trusted until the end of rcu_read_unlock().
> + * The caller must do
> + *	rcu_read_lock();
> + *	result = mem_cgroup_is_moved();
> + *	.....make use of result here....
> + *	rcu_read_unlock();
> + */
> +static bool mem_cgroup_is_moved(struct mem_cgroup *mem)
> +{

Could we add an assertion to confirm locking contract is upheld:
	VM_BUG_ON(!rcu_read_lock_held());

> +	return this_cpu_read(mem->stat->count[MEM_CGROUP_ON_MOVE]) > 0;
> +}
>  
>  static bool mem_cgroup_under_move(struct mem_cgroup *mem)
>  {
> @@ -1470,13 +1512,21 @@ void mem_cgroup_update_file_mapped(struc
>  {
>  	struct mem_cgroup *mem;
>  	struct page_cgroup *pc;
> +	bool need_lock = false;
>  
>  	pc = lookup_page_cgroup(page);
>  	if (unlikely(!pc))
>  		return;
> -
> -	lock_page_cgroup(pc);
> +	rcu_read_lock();
>  	mem = id_to_mem(pc->mem_cgroup);
> +	if (!mem)
> +		goto done;
> +	need_lock = mem_cgroup_is_moved(mem);
> +	if (need_lock) {
> +		/* need to serialize with move_account */
> +		lock_page_cgroup(pc);
> +		mem = id_to_mem(pc->mem_cgroup);
> +	}
>  	if (!mem || !PageCgroupUsed(pc))
>  		goto done;

Could we add a preemption() check here to ensure that the
__this_cpu_xxx() is safe to use?

	/*
	 * Preemption is already disabled. We can use __this_cpu_xxx
	 */
+        VM_BUG_ON(preemptible());

> @@ -1492,7 +1542,9 @@ void mem_cgroup_update_file_mapped(struc
>  	}
>  
>  done:
> -	unlock_page_cgroup(pc);
> +	if (need_lock)
> +		unlock_page_cgroup(pc);
> +	rcu_read_unlock();
>  }
>  
>  /*
> @@ -3024,6 +3076,7 @@ move_account:
>  		lru_add_drain_all();
>  		drain_all_stock_sync();
>  		ret = 0;
> +		mem_cgroup_start_move(mem);
>  		for_each_node_state(node, N_HIGH_MEMORY) {
>  			for (zid = 0; !ret && zid < MAX_NR_ZONES; zid++) {
>  				enum lru_list l;
> @@ -3037,6 +3090,7 @@ move_account:
>  			if (ret)
>  				break;
>  		}
> +		mem_cgroup_end_move(mem);
>  		memcg_oom_recover(mem);
>  		/* it seems parent cgroup doesn't have enough mem */
>  		if (ret == -ENOMEM)
> @@ -4503,6 +4557,7 @@ static void mem_cgroup_clear_mc(void)
>  	mc.to = NULL;
>  	mc.moving_task = NULL;
>  	spin_unlock(&mc.lock);
> +	mem_cgroup_end_move(from);
>  	memcg_oom_recover(from);
>  	memcg_oom_recover(to);
>  	wake_up_all(&mc.waitq);
> @@ -4533,6 +4588,7 @@ static int mem_cgroup_can_attach(struct 
>  			VM_BUG_ON(mc.moved_charge);
>  			VM_BUG_ON(mc.moved_swap);
>  			VM_BUG_ON(mc.moving_task);
> +			mem_cgroup_start_move(from);
>  			spin_lock(&mc.lock);
>  			mc.from = from;
>  			mc.to = mem;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
