Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 911946B01F1
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 04:11:28 -0400 (EDT)
Date: Mon, 30 Aug 2010 17:03:24 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 2/5] memcg: quick memcg lookup array
Message-Id: <20100830170324.16933949.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100825170741.f1f0a220.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100825170435.15f8eb73.kamezawa.hiroyu@jp.fujitsu.com>
	<20100825170741.f1f0a220.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

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
Do we really need to add this new member ?
Can't we safely access "mem(=rcu_dereference(mem_cgroup[id]))" under rcu_read_lock() ?
(iow, "mem" is not freed ?)


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
> @@ -4189,9 +4222,11 @@ mem_cgroup_create(struct cgroup_subsys *
>  	atomic_set(&mem->refcnt, 1);
>  	mem->move_charge_at_immigrate = 0;
>  	mutex_init(&mem->thresholds_lock);
> +	atomic_inc(&mem_cgroup_num);
> +	register_memcg_id(mem);
>  	return &mem->css;
>  free_out:
> -	__mem_cgroup_free(mem);
> +	mem_cgroup_free(mem);
>  	root_mem_cgroup = NULL;
>  	return ERR_PTR(error);
>  }
I think mem_cgroup_num should be increased at mem_cgroup_alloc(), because it
is decreased at __mem_cgroup_free(). Otherwise, it can be decreased while it
has not been increased, if mem_cgroup_create() fails after mem_cgroup_alloc().


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
