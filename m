Date: Tue, 25 Nov 2008 20:58:32 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [mm] [PATCH 3/4] Memory cgroup hierarchical reclaim (v4)
Message-Id: <20081125205832.38f8c365.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081116081055.25166.85066.sendpatchset@balbir-laptop>
References: <20081116081034.25166.7586.sendpatchset@balbir-laptop>
	<20081116081055.25166.85066.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

Hi.

Unfortunately, trying to hold cgroup_mutex at reclaim causes dead lock.

For example, when attaching a task to some cpuset directory(memory_migrate=on),

    cgroup_tasks_write (hold cgroup_mutex)
        attach_task_by_pid
            cgroup_attach_task
                cpuset_attach
                    cpuset_migrate_mm
                        :
                        unmap_and_move
                            mem_cgroup_prepare_migration
                                mem_cgroup_try_charge
                                    mem_cgroup_hierarchical_reclaim

I think similar problem can also happen when removing memcg's directory.

Any ideas?


Thanks,
Daisuke Nishimura.

On Sun, 16 Nov 2008 13:40:55 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> This patch introduces hierarchical reclaim. When an ancestor goes over its
> limit, the charging routine points to the parent that is above its limit.
> The reclaim process then starts from the last scanned child of the ancestor
> and reclaims until the ancestor goes below its limit.
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> 
>  mm/memcontrol.c |  170 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 167 insertions(+), 3 deletions(-)
> 
> diff -puN mm/memcontrol.c~memcg-hierarchical-reclaim mm/memcontrol.c
> --- linux-2.6.28-rc4/mm/memcontrol.c~memcg-hierarchical-reclaim	2008-11-16 13:17:33.000000000 +0530
> +++ linux-2.6.28-rc4-balbir/mm/memcontrol.c	2008-11-16 13:17:33.000000000 +0530
> @@ -142,6 +142,13 @@ struct mem_cgroup {
>  	struct mem_cgroup_lru_info info;
>  
>  	int	prev_priority;	/* for recording reclaim priority */
> +
> +	/*
> +	 * While reclaiming in a hiearchy, we cache the last child we
> +	 * reclaimed from. Protected by cgroup_lock()
> +	 */
> +	struct mem_cgroup *last_scanned_child;
> +
>  	int		obsolete;
>  	atomic_t	refcnt;
>  	/*
> @@ -460,6 +467,153 @@ unsigned long mem_cgroup_isolate_pages(u
>  	return nr_taken;
>  }
>  
> +static struct mem_cgroup *
> +mem_cgroup_from_res_counter(struct res_counter *counter)
> +{
> +	return container_of(counter, struct mem_cgroup, res);
> +}
> +
> +/*
> + * This routine finds the DFS walk successor. This routine should be
> + * called with cgroup_mutex held
> + */
> +static struct mem_cgroup *
> +mem_cgroup_get_next_node(struct mem_cgroup *curr, struct mem_cgroup *root_mem)
> +{
> +	struct cgroup *cgroup, *curr_cgroup, *root_cgroup;
> +
> +	curr_cgroup = curr->css.cgroup;
> +	root_cgroup = root_mem->css.cgroup;
> +
> +	if (!list_empty(&curr_cgroup->children)) {
> +		/*
> +		 * Walk down to children
> +		 */
> +		mem_cgroup_put(curr);
> +		cgroup = list_entry(curr_cgroup->children.next,
> +						struct cgroup, sibling);
> +		curr = mem_cgroup_from_cont(cgroup);
> +		mem_cgroup_get(curr);
> +		goto done;
> +	}
> +
> +visit_parent:
> +	if (curr_cgroup == root_cgroup) {
> +		mem_cgroup_put(curr);
> +		curr = root_mem;
> +		mem_cgroup_get(curr);
> +		goto done;
> +	}
> +
> +	/*
> +	 * Goto next sibling
> +	 */
> +	if (curr_cgroup->sibling.next != &curr_cgroup->parent->children) {
> +		mem_cgroup_put(curr);
> +		cgroup = list_entry(curr_cgroup->sibling.next, struct cgroup,
> +						sibling);
> +		curr = mem_cgroup_from_cont(cgroup);
> +		mem_cgroup_get(curr);
> +		goto done;
> +	}
> +
> +	/*
> +	 * Go up to next parent and next parent's sibling if need be
> +	 */
> +	curr_cgroup = curr_cgroup->parent;
> +	goto visit_parent;
> +
> +done:
> +	root_mem->last_scanned_child = curr;
> +	return curr;
> +}
> +
> +/*
> + * Visit the first child (need not be the first child as per the ordering
> + * of the cgroup list, since we track last_scanned_child) of @mem and use
> + * that to reclaim free pages from.
> + */
> +static struct mem_cgroup *
> +mem_cgroup_get_first_node(struct mem_cgroup *root_mem)
> +{
> +	struct cgroup *cgroup;
> +	struct mem_cgroup *ret;
> +	bool obsolete = (root_mem->last_scanned_child &&
> +				root_mem->last_scanned_child->obsolete);
> +
> +	/*
> +	 * Scan all children under the mem_cgroup mem
> +	 */
> +	cgroup_lock();
> +	if (list_empty(&root_mem->css.cgroup->children)) {
> +		ret = root_mem;
> +		goto done;
> +	}
> +
> +	if (!root_mem->last_scanned_child || obsolete) {
> +
> +		if (obsolete)
> +			mem_cgroup_put(root_mem->last_scanned_child);
> +
> +		cgroup = list_first_entry(&root_mem->css.cgroup->children,
> +				struct cgroup, sibling);
> +		ret = mem_cgroup_from_cont(cgroup);
> +		mem_cgroup_get(ret);
> +	} else
> +		ret = mem_cgroup_get_next_node(root_mem->last_scanned_child,
> +						root_mem);
> +
> +done:
> +	root_mem->last_scanned_child = ret;
> +	cgroup_unlock();
> +	return ret;
> +}
> +
> +/*
> + * Dance down the hierarchy if needed to reclaim memory. We remember the
> + * last child we reclaimed from, so that we don't end up penalizing
> + * one child extensively based on its position in the children list.
> + *
> + * root_mem is the original ancestor that we've been reclaim from.
> + */
> +static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> +						gfp_t gfp_mask, bool noswap)
> +{
> +	struct mem_cgroup *next_mem;
> +	int ret = 0;
> +
> +	/*
> +	 * Reclaim unconditionally and don't check for return value.
> +	 * We need to reclaim in the current group and down the tree.
> +	 * One might think about checking for children before reclaiming,
> +	 * but there might be left over accounting, even after children
> +	 * have left.
> +	 */
> +	ret = try_to_free_mem_cgroup_pages(root_mem, gfp_mask, noswap);
> +	if (res_counter_check_under_limit(&root_mem->res))
> +		return 0;
> +
> +	next_mem = mem_cgroup_get_first_node(root_mem);
> +
> +	while (next_mem != root_mem) {
> +		if (next_mem->obsolete) {
> +			mem_cgroup_put(next_mem);
> +			cgroup_lock();
> +			next_mem = mem_cgroup_get_first_node(root_mem);
> +			cgroup_unlock();
> +			continue;
> +		}
> +		ret = try_to_free_mem_cgroup_pages(next_mem, gfp_mask, noswap);
> +		if (res_counter_check_under_limit(&root_mem->res)) {
> +			return 0;
> +		}
> +		cgroup_lock();
> +		next_mem = mem_cgroup_get_next_node(next_mem, root_mem);
> +		cgroup_unlock();
> +	}
> +	return ret;
> +}
> +
>  /*
>   * Unlike exported interface, "oom" parameter is added. if oom==true,
>   * oom-killer can be invoked.
> @@ -468,7 +622,7 @@ static int __mem_cgroup_try_charge(struc
>  			gfp_t gfp_mask, struct mem_cgroup **memcg,
>  			bool oom)
>  {
> -	struct mem_cgroup *mem;
> +	struct mem_cgroup *mem, *mem_over_limit;
>  	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
>  	struct res_counter *fail_res;
>  	/*
> @@ -514,8 +668,16 @@ static int __mem_cgroup_try_charge(struc
>  		if (!(gfp_mask & __GFP_WAIT))
>  			goto nomem;
>  
> -		if (try_to_free_mem_cgroup_pages(mem, gfp_mask, noswap))
> -			continue;
> +		/*
> +		 * Is one of our ancestors over their limit?
> +		 */
> +		if (fail_res)
> +			mem_over_limit = mem_cgroup_from_res_counter(fail_res);
> +		else
> +			mem_over_limit = mem;
> +
> +		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, gfp_mask,
> +							noswap);
>  
>  		/*
>  		 * try_to_free_mem_cgroup_pages() might not give us a full
> @@ -1710,6 +1872,8 @@ mem_cgroup_create(struct cgroup_subsys *
>  	res_counter_init(&mem->memsw, parent ? &parent->memsw : NULL);
>  
>  
> +	mem->last_scanned_child = NULL;
> +
>  	return &mem->css;
>  free_out:
>  	for_each_node_state(node, N_POSSIBLE)
> _
> 
> -- 
> 	Balbir
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
