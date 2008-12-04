Date: Thu, 4 Dec 2008 20:00:37 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [Experimental][PATCH  21/21]
 memcg-new-hierarchical-reclaim.patch
Message-Id: <20081204200037.63ff03c9.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081203141423.6f747990.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081203134718.6b60986f.kamezawa.hiroyu@jp.fujitsu.com>
	<20081203141423.6f747990.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

On Wed, 3 Dec 2008 14:14:23 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Implement hierarchy reclaim by cgroup_id.
> 
> What changes:
> 	- reclaim is not done by tree-walk algorithm
> 	- mem_cgroup->last_schan_child is ID, not pointer.
> 	- no cgroup_lock.
> 	- scanning order is just defined by ID's order.
> 	  (Scan by round-robin logic.)
> 
> Changelog: v1 -> v2
> 	- make use of css_tryget();
> 	- count # of loops rather than remembering position.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujisu.com>
> 
> 
>  mm/memcontrol.c |  214 +++++++++++++++++++-------------------------------------
>  1 file changed, 75 insertions(+), 139 deletions(-)
> 
(snip)
>  /*
> - * Visit the first child (need not be the first child as per the ordering
> - * of the cgroup list, since we track last_scanned_child) of @mem and use
> - * that to reclaim free pages from.
> + * This routine select next memcg by ID. Using RCU and tryget().
> + * No cgroup_mutex is required.
>   */
>  static struct mem_cgroup *
> -mem_cgroup_get_first_node(struct mem_cgroup *root_mem)
> +mem_cgroup_select_victim(struct mem_cgroup *root_mem)
>  {
> -	struct cgroup *cgroup;
> +	struct cgroup *cgroup, *root_cgroup;
>  	struct mem_cgroup *ret;
> -	struct mem_cgroup *last_scan = root_mem->last_scanned_child;
> -	bool obsolete = false;
> +	int nextid, rootid, depth, found;
>  
> -	if (last_scan) {
> -		if (css_under_removal(&last_scan->css))
> -			obsolete = true;
> -	} else
> -		obsolete = true;
> +	root_cgroup = root_mem->css.cgroup;
> +	rootid = cgroup_id(root_cgroup);
> +	depth = cgroup_depth(root_cgroup);
> +	found = 0;
> +	ret = NULL;
>  
> -	/*
> -	 * Scan all children under the mem_cgroup mem
> -	 */
> -	cgroup_lock();
> -	if (list_empty(&root_mem->css.cgroup->children)) {
> -		ret = root_mem;
> -		goto done;
> +	rcu_read_lock();
> +	if (!root_mem->use_hierarchy) {
> +		spin_lock(&root_mem->reclaim_param_lock);
> +		root_mem->scan_age++;
> +		spin_unlock(&root_mem->reclaim_param_lock);
> +		css_get(&root_mem->css);
> +		goto out;
>  	}
>  
I think you forgot "ret = root_mem".
I got NULL pointer dereference BUG in my test(I've not tested use_hierarchy case yet).


Thanks,
Daisuke Nishimura.

> -	if (!root_mem->last_scanned_child || obsolete) {
> -
> -		if (obsolete)
> -			mem_cgroup_put(root_mem->last_scanned_child);
> -
> -		cgroup = list_first_entry(&root_mem->css.cgroup->children,
> -				struct cgroup, sibling);
> -		ret = mem_cgroup_from_cont(cgroup);
> -		mem_cgroup_get(ret);
> -	} else
> -		ret = mem_cgroup_get_next_node(root_mem->last_scanned_child,
> -						root_mem);
> +	while (!ret) {
> +		/* ID:0 is not used by cgroup-id */
> +		nextid = root_mem->last_scanned_child + 1;
> +		cgroup = cgroup_get_next(nextid, rootid, depth, &found);
> +		if (cgroup) {
> +			spin_lock(&root_mem->reclaim_param_lock);
> +			root_mem->last_scanned_child = found;
> +			spin_unlock(&root_mem->reclaim_param_lock);
> +			ret = mem_cgroup_from_cont(cgroup);
> +			if (!css_tryget(&ret->css))
> +				ret = NULL;
> +		} else {
> +			spin_lock(&root_mem->reclaim_param_lock);
> +			root_mem->scan_age++;
> +			root_mem->last_scanned_child = 0;
> +			spin_unlock(&root_mem->reclaim_param_lock);
> +		}
> +	}
> +out:
> +	rcu_read_unlock();
>  
> -done:
> -	root_mem->last_scanned_child = ret;
> -	cgroup_unlock();
>  	return ret;
>  }
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
