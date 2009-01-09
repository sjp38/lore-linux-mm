Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DD4CC6B0044
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 00:33:27 -0500 (EST)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp08.in.ibm.com (8.13.1/8.13.1) with ESMTP id n095JVSE013156
	for <linux-mm@kvack.org>; Fri, 9 Jan 2009 10:49:31 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n095XP1k4083818
	for <linux-mm@kvack.org>; Fri, 9 Jan 2009 11:03:26 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id n095XKYU016202
	for <linux-mm@kvack.org>; Fri, 9 Jan 2009 16:33:21 +1100
Date: Fri, 9 Jan 2009 11:03:23 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 3/4] memcg: fix for mem_cgroup_hierarchical_reclaim
Message-ID: <20090109053323.GD9737@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090108190818.b663ce20.nishimura@mxp.nes.nec.co.jp> <20090108191501.dc469a51.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090108191501.dc469a51.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizf@cn.fujitsu.com, menage@google.com
List-ID: <linux-mm.kvack.org>

* Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> [2009-01-08 19:15:01]:

> If root_mem has no children, last_scaned_child is set to root_mem itself.
> But after some children added to root_mem, mem_cgroup_get_next_node can
> mem_cgroup_put the root_mem although root_mem has not been mem_cgroup_get.
>

Good catch!
 
> This patch fixes this behavior by:
> - Set last_scanned_child to NULL if root_mem has no children or DFS search
>   has returned to root_mem itself(root_mem is not a "child" of root_mem).
>   Make mem_cgroup_get_first_node return root_mem in this case.
>   There are no mem_cgroup_get/put for root_mem.
> - Rename mem_cgroup_get_next_node to __mem_cgroup_get_next_node, and
>   mem_cgroup_get_first_node to mem_cgroup_get_next_node.
>   Make mem_cgroup_hierarchical_reclaim call only new mem_cgroup_get_next_node.
>

How have you tested these changes? When I wrote up the patches, I did
several tests to make sure that all nodes in the hierarchy are covered
while reclaiming in order.
 
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  mm/memcontrol.c |   37 +++++++++++++++++++++----------------
>  1 files changed, 21 insertions(+), 16 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 288e22c..dc38a0e 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -622,7 +622,7 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
>   * called with hierarchy_mutex held
>   */
>  static struct mem_cgroup *
> -mem_cgroup_get_next_node(struct mem_cgroup *curr, struct mem_cgroup *root_mem)
> +__mem_cgroup_get_next_node(struct mem_cgroup *curr, struct mem_cgroup *root_mem)
>  {
>  	struct cgroup *cgroup, *curr_cgroup, *root_cgroup;
> 
> @@ -644,8 +644,8 @@ mem_cgroup_get_next_node(struct mem_cgroup *curr, struct mem_cgroup *root_mem)
>  visit_parent:
>  	if (curr_cgroup == root_cgroup) {
>  		mem_cgroup_put(curr);
> -		curr = root_mem;
> -		mem_cgroup_get(curr);
> +		/* caller handles NULL case */
> +		curr = NULL;
>  		goto done;
>  	}
> 
> @@ -668,7 +668,6 @@ visit_parent:
>  	goto visit_parent;
> 
>  done:
> -	root_mem->last_scanned_child = curr;
>  	return curr;
>  }
> 
> @@ -678,20 +677,29 @@ done:
>   * that to reclaim free pages from.
>   */
>  static struct mem_cgroup *
> -mem_cgroup_get_first_node(struct mem_cgroup *root_mem)
> +mem_cgroup_get_next_node(struct mem_cgroup *root_mem)
>  {
>  	struct cgroup *cgroup;
>  	struct mem_cgroup *ret;
>  	bool obsolete;
> 
> -	obsolete = mem_cgroup_is_obsolete(root_mem->last_scanned_child);
> -
>  	/*
>  	 * Scan all children under the mem_cgroup mem
>  	 */
>  	mutex_lock(&mem_cgroup_subsys.hierarchy_mutex);
> +
> +	obsolete = mem_cgroup_is_obsolete(root_mem->last_scanned_child);
> +
>  	if (list_empty(&root_mem->css.cgroup->children)) {
> -		ret = root_mem;
> +		/*
> +		 * root_mem might have children before and last_scanned_child
> +		 * may point to one of them.
> +		 */
> +		if (root_mem->last_scanned_child) {
> +			VM_BUG_ON(!obsolete);
> +			mem_cgroup_put(root_mem->last_scanned_child);
> +		}
> +		ret = NULL;
>  		goto done;
>  	}
> 
> @@ -705,13 +713,13 @@ mem_cgroup_get_first_node(struct mem_cgroup *root_mem)
>  		ret = mem_cgroup_from_cont(cgroup);
>  		mem_cgroup_get(ret);
>  	} else
> -		ret = mem_cgroup_get_next_node(root_mem->last_scanned_child,
> +		ret = __mem_cgroup_get_next_node(root_mem->last_scanned_child,
>  						root_mem);
> 
>  done:
>  	root_mem->last_scanned_child = ret;
>  	mutex_unlock(&mem_cgroup_subsys.hierarchy_mutex);
> -	return ret;
> +	return (ret) ? ret : root_mem;
>  }
> 
>  static bool mem_cgroup_check_under_limit(struct mem_cgroup *mem)
> @@ -769,21 +777,18 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>  	if (!root_mem->use_hierarchy)
>  		return ret;
> 
> -	next_mem = mem_cgroup_get_first_node(root_mem);
> +	next_mem = mem_cgroup_get_next_node(root_mem);
> 
>  	while (next_mem != root_mem) {
>  		if (mem_cgroup_is_obsolete(next_mem)) {
> -			mem_cgroup_put(next_mem);
> -			next_mem = mem_cgroup_get_first_node(root_mem);
> +			next_mem = mem_cgroup_get_next_node(root_mem);
>  			continue;
>  		}
>  		ret = try_to_free_mem_cgroup_pages(next_mem, gfp_mask, noswap,
>  						   get_swappiness(next_mem));
>  		if (mem_cgroup_check_under_limit(root_mem))
>  			return 0;
> -		mutex_lock(&mem_cgroup_subsys.hierarchy_mutex);
> -		next_mem = mem_cgroup_get_next_node(next_mem, root_mem);
> -		mutex_unlock(&mem_cgroup_subsys.hierarchy_mutex);
> +		next_mem = mem_cgroup_get_next_node(root_mem);
>  	}
>  	return ret;
>  }
> 


Looks good to me, I need to test it though

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
