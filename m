Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7D8146B0044
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 22:05:07 -0500 (EST)
Date: Fri, 9 Jan 2009 11:51:03 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 3/4] memcg: fix for mem_cgroup_hierarchical_reclaim
Message-Id: <20090109115103.e17b18f2.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090109100830.3e9c90e0.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090108190818.b663ce20.nishimura@mxp.nes.nec.co.jp>
	<20090108191501.dc469a51.nishimura@mxp.nes.nec.co.jp>
	<39822.10.75.179.62.1231412881.squirrel@webmail-b.css.fujitsu.com>
	<20090109100830.3e9c90e0.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, linux-mm@kvack.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, lizf@cn.fujitsu.com, menage@google.com
List-ID: <linux-mm.kvack.org>

On Fri, 9 Jan 2009 10:08:30 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 8 Jan 2009 20:08:01 +0900 (JST)
> "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > Daisuke Nishimura said:
> > > If root_mem has no children, last_scaned_child is set to root_mem itself.
> > > But after some children added to root_mem, mem_cgroup_get_next_node can
> > > mem_cgroup_put the root_mem although root_mem has not been mem_cgroup_get.
> > >
> > > This patch fixes this behavior by:
> > > - Set last_scanned_child to NULL if root_mem has no children or DFS search
> > >   has returned to root_mem itself(root_mem is not a "child" of root_mem).
> > >   Make mem_cgroup_get_first_node return root_mem in this case.
> > >   There are no mem_cgroup_get/put for root_mem.
> > > - Rename mem_cgroup_get_next_node to __mem_cgroup_get_next_node, and
> > >   mem_cgroup_get_first_node to mem_cgroup_get_next_node.
> > >   Make mem_cgroup_hierarchical_reclaim call only new
> > > mem_cgroup_get_next_node.
> > >
> > >
> > > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > 
> > Hmm, seems necessary fix. Then, it's better to rebase my patch on to this.
> > 
> > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Maybe simpler one can be written but my patch remove all this out later....
> > 
> How about this ? (just an exmaple and not tested, sorry)
> 
> 
hmm, I don't think it's much simpler than this one(I don't want last_scanned_child
to point to the mem itself, because it's not a "child").

This part will be re-written by your patch, but this patch is needed
to fix a bug(I saw general protection fault), so let's fix one by one.
I'll post my original version. It's well tested :)


Thanks,
Daisuke Nishimura.

> 
> ---
>  mm/memcontrol.c |   52 ++++++++++++++++++++++------------------------------
>  1 file changed, 22 insertions(+), 30 deletions(-)
> 
> Index: mmotm-2.6.28-Jan7/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.28-Jan7.orig/mm/memcontrol.c
> +++ mmotm-2.6.28-Jan7/mm/memcontrol.c
> @@ -621,6 +621,7 @@ static struct mem_cgroup *
>  mem_cgroup_get_next_node(struct mem_cgroup *curr, struct mem_cgroup *root_mem)
>  {
>  	struct cgroup *cgroup, *curr_cgroup, *root_cgroup;
> +	struct mem_cgroup *orig = root_mem->last_scanned_child;
>  
>  	curr_cgroup = curr->css.cgroup;
>  	root_cgroup = root_mem->css.cgroup;
> @@ -629,19 +630,15 @@ mem_cgroup_get_next_node(struct mem_cgro
>  		/*
>  		 * Walk down to children
>  		 */
> -		mem_cgroup_put(curr);
>  		cgroup = list_entry(curr_cgroup->children.next,
>  						struct cgroup, sibling);
>  		curr = mem_cgroup_from_cont(cgroup);
> -		mem_cgroup_get(curr);
>  		goto done;
>  	}
>  
>  visit_parent:
>  	if (curr_cgroup == root_cgroup) {
> -		mem_cgroup_put(curr);
>  		curr = root_mem;
> -		mem_cgroup_get(curr);
>  		goto done;
>  	}
>  
> @@ -649,11 +646,9 @@ visit_parent:
>  	 * Goto next sibling
>  	 */
>  	if (curr_cgroup->sibling.next != &curr_cgroup->parent->children) {
> -		mem_cgroup_put(curr);
>  		cgroup = list_entry(curr_cgroup->sibling.next, struct cgroup,
>  						sibling);
>  		curr = mem_cgroup_from_cont(cgroup);
> -		mem_cgroup_get(curr);
>  		goto done;
>  	}
>  
> @@ -664,7 +659,10 @@ visit_parent:
>  	goto visit_parent;
>  
>  done:
> +	if (orig)
> +		mem_cgroup_put(orig);
>  	root_mem->last_scanned_child = curr;
> +	mem_cgroup_get(curr);
>  	return curr;
>  }
>  
> @@ -677,35 +675,25 @@ static struct mem_cgroup *
>  mem_cgroup_get_first_node(struct mem_cgroup *root_mem)
>  {
>  	struct cgroup *cgroup;
> -	struct mem_cgroup *ret;
> -	bool obsolete;
> +	struct mem_cgroup *ret, *orig;
>  
> -	obsolete = mem_cgroup_is_obsolete(root_mem->last_scanned_child);
> -
> -	/*
> -	 * Scan all children under the mem_cgroup mem
> -	 */
>  	mutex_lock(&mem_cgroup_subsys.hierarchy_mutex);
> -	if (list_empty(&root_mem->css.cgroup->children)) {
> -		ret = root_mem;
> -		goto done;
> -	}
> -
> -	if (!root_mem->last_scanned_child || obsolete) {
> -
> -		if (obsolete && root_mem->last_scanned_child)
> -			mem_cgroup_put(root_mem->last_scanned_child);
> +	orig = root_mem->last_scanned_child;
>  
> -		cgroup = list_first_entry(&root_mem->css.cgroup->children,
> -				struct cgroup, sibling);
> -		ret = mem_cgroup_from_cont(cgroup);
> +	if (!orig) {
> +		if (list_empty(&root_mem->css.cgroup->children)) {
> +			ret = root_mem;
> +		} else {
> +			cgroup =
> +			    list_first_entry(&root_mem->css.cgroup->children,
> +					struct cgroup, sibling);
> +			ret = mem_cgroup_from_cont(cgroup);
> +		}
> +		root_mem->last_scanned_child = ret;
>  		mem_cgroup_get(ret);
> -	} else
> +	} else /* get_next_node will manage refcnt */
>  		ret = mem_cgroup_get_next_node(root_mem->last_scanned_child,
>  						root_mem);
> -
> -done:
> -	root_mem->last_scanned_child = ret;
>  	mutex_unlock(&mem_cgroup_subsys.hierarchy_mutex);
>  	return ret;
>  }
> @@ -2232,7 +2220,11 @@ static void mem_cgroup_pre_destroy(struc
>  static void mem_cgroup_destroy(struct cgroup_subsys *ss,
>  				struct cgroup *cont)
>  {
> -	mem_cgroup_put(mem_cgroup_from_cont(cont));
> +	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
> +
> +	if (mem->last_scanned_child == mem)
> +		mem_cgroup_put(mem);
> +	mem_cgroup_put(mem);
>  }
>  
>  static int mem_cgroup_populate(struct cgroup_subsys *ss,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
