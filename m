Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAB356f0009378
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 11 Nov 2008 12:05:07 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 77BCF45DE51
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 12:05:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 52C1945DE50
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 12:05:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 368CD1DB8044
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 12:05:06 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C54461DB803E
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 12:05:05 +0900 (JST)
Date: Tue, 11 Nov 2008 12:04:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][mm] [PATCH 2/4] Memory cgroup resource counters for
 hierarchy (v2)
Message-Id: <20081111120427.bbb64a44.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081108091047.32236.22994.sendpatchset@localhost.localdomain>
References: <20081108091009.32236.26177.sendpatchset@localhost.localdomain>
	<20081108091047.32236.22994.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sat, 08 Nov 2008 14:40:47 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> 
> Add support for building hierarchies in resource counters. Cgroups allows us
> to build a deep hierarchy, but we currently don't link the resource counters
> belonging to the memory controller control groups, in the same fashion
> as the corresponding cgroup entries in the cgroup hierarchy. This patch
> provides the infrastructure for resource counters that have the same hiearchy
> as their cgroup counter parts.
> 
> These set of patches are based on the resource counter hiearchy patches posted
> by Pavel Emelianov.
> 
> NOTE: Building hiearchies is expensive, deeper hierarchies imply charging
> the all the way up to the root. It is known that hiearchies are expensive,
> so the user needs to be careful and aware of the trade-offs before creating
> very deep ones.
> 
Do you have numbers ?






> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> 
>  include/linux/res_counter.h |    8 ++++++--
>  kernel/res_counter.c        |   42 ++++++++++++++++++++++++++++++++++--------
>  mm/memcontrol.c             |    9 ++++++---
>  3 files changed, 46 insertions(+), 13 deletions(-)
> 
> diff -puN include/linux/res_counter.h~resource-counters-hierarchy-support include/linux/res_counter.h
> --- linux-2.6.28-rc2/include/linux/res_counter.h~resource-counters-hierarchy-support	2008-11-08 14:09:31.000000000 +0530
> +++ linux-2.6.28-rc2-balbir/include/linux/res_counter.h	2008-11-08 14:09:31.000000000 +0530
> @@ -43,6 +43,10 @@ struct res_counter {
>  	 * the routines below consider this to be IRQ-safe
>  	 */
>  	spinlock_t lock;
> +	/*
> +	 * Parent counter, used for hierarchial resource accounting
> +	 */
> +	struct res_counter *parent;
>  };
>  
>  /**
> @@ -87,7 +91,7 @@ enum {
>   * helpers for accounting
>   */
>  
> -void res_counter_init(struct res_counter *counter);
> +void res_counter_init(struct res_counter *counter, struct res_counter *parent);
>  
>  /*
>   * charge - try to consume more resource.
> @@ -103,7 +107,7 @@ void res_counter_init(struct res_counter
>  int __must_check res_counter_charge_locked(struct res_counter *counter,
>  		unsigned long val);
>  int __must_check res_counter_charge(struct res_counter *counter,
> -		unsigned long val);
> +		unsigned long val, struct res_counter **limit_fail_at);
>  
>  /*
>   * uncharge - tell that some portion of the resource is released
> diff -puN kernel/res_counter.c~resource-counters-hierarchy-support kernel/res_counter.c
> --- linux-2.6.28-rc2/kernel/res_counter.c~resource-counters-hierarchy-support	2008-11-08 14:09:31.000000000 +0530
> +++ linux-2.6.28-rc2-balbir/kernel/res_counter.c	2008-11-08 14:09:31.000000000 +0530
> @@ -15,10 +15,11 @@
>  #include <linux/uaccess.h>
>  #include <linux/mm.h>
>  
> -void res_counter_init(struct res_counter *counter)
> +void res_counter_init(struct res_counter *counter, struct res_counter *parent)
>  {
>  	spin_lock_init(&counter->lock);
>  	counter->limit = (unsigned long long)LLONG_MAX;
> +	counter->parent = parent;
>  }
>  
>  int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
> @@ -34,14 +35,34 @@ int res_counter_charge_locked(struct res
>  	return 0;
>  }
>  
> -int res_counter_charge(struct res_counter *counter, unsigned long val)
> +int res_counter_charge(struct res_counter *counter, unsigned long val,
> +			struct res_counter **limit_fail_at)
>  {
>  	int ret;
>  	unsigned long flags;
> +	struct res_counter *c, *u;
>  
> -	spin_lock_irqsave(&counter->lock, flags);
> -	ret = res_counter_charge_locked(counter, val);
> -	spin_unlock_irqrestore(&counter->lock, flags);
> +	*limit_fail_at = NULL;
> +	local_irq_save(flags);
> +	for (c = counter; c != NULL; c = c->parent) {
> +		spin_lock(&c->lock);
> +		ret = res_counter_charge_locked(c, val);
> +		spin_unlock(&c->lock);
> +		if (ret < 0) {
> +			*limit_fail_at = c;
> +			goto undo;
> +		}
> +	}
> +	ret = 0;
> +	goto done;
> +undo:
> +	for (u = counter; u != c; u = u->parent) {
> +		spin_lock(&u->lock);
> +		res_counter_uncharge_locked(u, val);
> +		spin_unlock(&u->lock);
> +	}
> +done:
> +	local_irq_restore(flags);
>  	return ret;
>  }
>  
IMHO, dividing function into

  - res_counter_charge() for res_counter which doesn't need hierarchy.
  - res_counter_charge_hierarchy() fro res_counter with hierarch.

will reduce footprint of other users than memcg. 

All users of res_counter is forced to use hierarchy version ?

Thanks,
-Kame


> @@ -56,10 +77,15 @@ void res_counter_uncharge_locked(struct 
>  void res_counter_uncharge(struct res_counter *counter, unsigned long val)
>  {
>  	unsigned long flags;
> +	struct res_counter *c;
>  
> -	spin_lock_irqsave(&counter->lock, flags);
> -	res_counter_uncharge_locked(counter, val);
> -	spin_unlock_irqrestore(&counter->lock, flags);
> +	local_irq_save(flags);
> +	for (c = counter; c != NULL; c = c->parent) {
> +		spin_lock(&c->lock);
> +		res_counter_uncharge_locked(c, val);
> +		spin_unlock(&c->lock);
> +	}
> +	local_irq_restore(flags);
>  }
>  
>  
> diff -puN mm/memcontrol.c~resource-counters-hierarchy-support mm/memcontrol.c
> --- linux-2.6.28-rc2/mm/memcontrol.c~resource-counters-hierarchy-support	2008-11-08 14:09:31.000000000 +0530
> +++ linux-2.6.28-rc2-balbir/mm/memcontrol.c	2008-11-08 14:09:31.000000000 +0530
> @@ -485,6 +485,7 @@ int mem_cgroup_try_charge(struct mm_stru
>  {
>  	struct mem_cgroup *mem;
>  	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
> +	struct res_counter *fail_res;
>  	/*
>  	 * We always charge the cgroup the mm_struct belongs to.
>  	 * The mm_struct's mem_cgroup changes on task migration if the
> @@ -510,7 +511,7 @@ int mem_cgroup_try_charge(struct mm_stru
>  	}
>  
>  
> -	while (unlikely(res_counter_charge(&mem->res, PAGE_SIZE))) {
> +	while (unlikely(res_counter_charge(&mem->res, PAGE_SIZE, &fail_res))) {
>  		if (!(gfp_mask & __GFP_WAIT))
>  			goto nomem;
>  
> @@ -1175,18 +1176,20 @@ static void mem_cgroup_free(struct mem_c
>  static struct cgroup_subsys_state *
>  mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  {
> -	struct mem_cgroup *mem;
> +	struct mem_cgroup *mem, *parent;
>  	int node;
>  
>  	if (unlikely((cont->parent) == NULL)) {
>  		mem = &init_mem_cgroup;
> +		parent = NULL;
>  	} else {
>  		mem = mem_cgroup_alloc();
> +		parent = mem_cgroup_from_cont(cont->parent);
>  		if (!mem)
>  			return ERR_PTR(-ENOMEM);
>  	}
>  
> -	res_counter_init(&mem->res);
> +	res_counter_init(&mem->res, parent ? &parent->res : NULL);
>  
>  	for_each_node_state(node, N_POSSIBLE)
>  		if (alloc_mem_cgroup_per_zone_info(mem, node))
> _
> 
> -- 
> 	Balbir
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
