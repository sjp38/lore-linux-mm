Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E9FDA6B0044
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 06:08:05 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n08B83Gl023236
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 8 Jan 2009 20:08:03 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9DFDA45DD7C
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 20:08:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 68F6945DD75
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 20:08:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B13FAE18008
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 20:08:02 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 574391DB803C
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 20:08:02 +0900 (JST)
Message-ID: <39822.10.75.179.62.1231412881.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090108191501.dc469a51.nishimura@mxp.nes.nec.co.jp>
References: <20090108190818.b663ce20.nishimura@mxp.nes.nec.co.jp>
    <20090108191501.dc469a51.nishimura@mxp.nes.nec.co.jp>
Date: Thu, 8 Jan 2009 20:08:01 +0900 (JST)
Subject: Re: [RFC][PATCH 3/4] memcg: fix for mem_cgroup_hierarchical_reclaim
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, balbir@linux.vnet.ibm.com, lizf@cn.fujitsu.com, menage@google.com
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura said:
> If root_mem has no children, last_scaned_child is set to root_mem itself.
> But after some children added to root_mem, mem_cgroup_get_next_node can
> mem_cgroup_put the root_mem although root_mem has not been mem_cgroup_get.
>
> This patch fixes this behavior by:
> - Set last_scanned_child to NULL if root_mem has no children or DFS search
>   has returned to root_mem itself(root_mem is not a "child" of root_mem).
>   Make mem_cgroup_get_first_node return root_mem in this case.
>   There are no mem_cgroup_get/put for root_mem.
> - Rename mem_cgroup_get_next_node to __mem_cgroup_get_next_node, and
>   mem_cgroup_get_first_node to mem_cgroup_get_next_node.
>   Make mem_cgroup_hierarchical_reclaim call only new
> mem_cgroup_get_next_node.
>
>
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Hmm, seems necessary fix. Then, it's better to rebase my patch on to this.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Maybe simpler one can be written but my patch remove all this out later....

Thanks,
-Kame

> ---
>  mm/memcontrol.c |   37 +++++++++++++++++++++----------------
>  1 files changed, 21 insertions(+), 16 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 288e22c..dc38a0e 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -622,7 +622,7 @@ unsigned long mem_cgroup_isolate_pages(unsigned long
> nr_to_scan,
>   * called with hierarchy_mutex held
>   */
>  static struct mem_cgroup *
> -mem_cgroup_get_next_node(struct mem_cgroup *curr, struct mem_cgroup
> *root_mem)
> +__mem_cgroup_get_next_node(struct mem_cgroup *curr, struct mem_cgroup
> *root_mem)
>  {
>  	struct cgroup *cgroup, *curr_cgroup, *root_cgroup;
>
> @@ -644,8 +644,8 @@ mem_cgroup_get_next_node(struct mem_cgroup *curr,
> struct mem_cgroup *root_mem)
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
> @@ -705,13 +713,13 @@ mem_cgroup_get_first_node(struct mem_cgroup
> *root_mem)
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
> @@ -769,21 +777,18 @@ static int mem_cgroup_hierarchical_reclaim(struct
> mem_cgroup *root_mem,
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
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
