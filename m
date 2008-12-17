Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EE6906B009B
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 00:17:10 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBH5IqmS003526
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 17 Dec 2008 14:18:52 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 05EF745DE4F
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 14:18:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D642445DE51
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 14:18:51 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C2CE91DB803C
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 14:18:51 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 71EA3E38005
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 14:18:48 +0900 (JST)
Date: Wed, 17 Dec 2008 14:17:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] CGroups: Use hierarchy_mutex in memory controller
Message-Id: <20081217141753.66ba248b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081216113653.090278000@menage.corp.google.com>
References: <20081216113055.713856000@menage.corp.google.com>
	<20081216113653.090278000@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: menage@google.com
Cc: akpm@linux-foundation.org, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Dec 2008 03:30:57 -0800
menage@google.com wrote:

> This patch updates the memory controller to use its hierarchy_mutex
> rather than calling cgroup_lock() to protected against
> cgroup_mkdir()/cgroup_rmdir() from occurring in its hierarchy.
> 
> Signed-off-by: Paul Menage <menage@google.com>
> 
Not doing any special test but passed usual test.

Tested-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
>  mm/memcontrol.c |   14 ++++++--------
>  1 file changed, 6 insertions(+), 8 deletions(-)
> 
> Index: hierarchy_lock-mmotm-2008-12-09/mm/memcontrol.c
> ===================================================================
> --- hierarchy_lock-mmotm-2008-12-09.orig/mm/memcontrol.c
> +++ hierarchy_lock-mmotm-2008-12-09/mm/memcontrol.c
> @@ -154,7 +154,7 @@ struct mem_cgroup {
>  
>  	/*
>  	 * While reclaiming in a hiearchy, we cache the last child we
> -	 * reclaimed from. Protected by cgroup_lock()
> +	 * reclaimed from. Protected by hierarchy_mutex
>  	 */
>  	struct mem_cgroup *last_scanned_child;
>  	/*
> @@ -529,7 +529,7 @@ unsigned long mem_cgroup_isolate_pages(u
>  
>  /*
>   * This routine finds the DFS walk successor. This routine should be
> - * called with cgroup_mutex held
> + * called with hierarchy_mutex held
>   */
>  static struct mem_cgroup *
>  mem_cgroup_get_next_node(struct mem_cgroup *curr, struct mem_cgroup *root_mem)
> @@ -598,7 +598,7 @@ mem_cgroup_get_first_node(struct mem_cgr
>  	/*
>  	 * Scan all children under the mem_cgroup mem
>  	 */
> -	cgroup_lock();
> +	mutex_lock(&mem_cgroup_subsys.hierarchy_mutex);
>  	if (list_empty(&root_mem->css.cgroup->children)) {
>  		ret = root_mem;
>  		goto done;
> @@ -619,7 +619,7 @@ mem_cgroup_get_first_node(struct mem_cgr
>  
>  done:
>  	root_mem->last_scanned_child = ret;
> -	cgroup_unlock();
> +	mutex_unlock(&mem_cgroup_subsys.hierarchy_mutex);
>  	return ret;
>  }
>  
> @@ -683,18 +683,16 @@ static int mem_cgroup_hierarchical_recla
>  	while (next_mem != root_mem) {
>  		if (next_mem->obsolete) {
>  			mem_cgroup_put(next_mem);
> -			cgroup_lock();
>  			next_mem = mem_cgroup_get_first_node(root_mem);
> -			cgroup_unlock();
>  			continue;
>  		}
>  		ret = try_to_free_mem_cgroup_pages(next_mem, gfp_mask, noswap,
>  						   get_swappiness(next_mem));
>  		if (mem_cgroup_check_under_limit(root_mem))
>  			return 0;
> -		cgroup_lock();
> +		mutex_lock(&mem_cgroup_subsys.hierarchy_mutex);
>  		next_mem = mem_cgroup_get_next_node(next_mem, root_mem);
> -		cgroup_unlock();
> +		mutex_unlock(&mem_cgroup_subsys.hierarchy_mutex);
>  	}
>  	return ret;
>  }
> 
> --
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
