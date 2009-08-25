Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E82C76B004D
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 11:40:13 -0400 (EDT)
Received: from tyo201.gate.nec.co.jp ([10.7.69.201])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id n7P8E3fd025791
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 17:14:03 +0900 (JST)
Date: Tue, 25 Aug 2009 17:07:35 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][preview] [patch 1/2] memcg: batched uncharge base
Message-Id: <20090825170735.6acd3ace.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090825112919.259ab97c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090825112547.c2692965.kamezawa.hiroyu@jp.fujitsu.com>
	<20090825112919.259ab97c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

First of all, I think these patches are good optimization.

I have a few comments for now.

On Tue, 25 Aug 2009 11:29:19 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> In massive parallel enviroment, res_counter can be a performance bottleneck.
> This patch is a trial for reducing lock contention in memcg.
> 
> One strong techinque to reduce lock contention is reducing calls themselves by
> do some amount of calls into a call, in batch.
> 
> Considering charge/uncharge chatacteristic,
> 	- charge is done one by one via demand-paging.
> 	- uncharge is done by
> 		- in continuous call at munmap, truncate, exit, execve...
> 		- one by one via vmscan/paging.
> 
> It seems we have a chance to batched-uncharge.
> This patch is a base patch for batched uncharge. For avoiding
> scattering memcg's structure as argument, this patch adds memcg batch uncharge
> information to the task. please see start/end usage in next patch.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/memcontrol.h |   12 ++++++++++
>  include/linux/sched.h      |    8 +++++++
>  mm/memcontrol.c            |   51 ++++++++++++++++++++++++++++++++++++++++++---
>  3 files changed, 68 insertions(+), 3 deletions(-)
> 
> Index: linux-2.6.31-rc7/include/linux/memcontrol.h
> ===================================================================
> --- linux-2.6.31-rc7.orig/include/linux/memcontrol.h
> +++ linux-2.6.31-rc7/include/linux/memcontrol.h
> @@ -54,6 +54,10 @@ extern void mem_cgroup_rotate_lru_list(s
>  extern void mem_cgroup_del_lru(struct page *page);
>  extern void mem_cgroup_move_lists(struct page *page,
>  				  enum lru_list from, enum lru_list to);
> +
> +extern void mem_cgroup_uncharge_batch_start(void);
> +extern void mem_cgroup_uncharge_batch_end(void);
> +
>  extern void mem_cgroup_uncharge_page(struct page *page);
>  extern void mem_cgroup_uncharge_cache_page(struct page *page);
>  extern int mem_cgroup_shmem_charge_fallback(struct page *page,
> @@ -148,6 +152,14 @@ static inline void mem_cgroup_cancel_cha
>  {
>  }
>  
> +static inline void mem_cgroup_uncharge_batch_start(void)
> +{
> +}
> +
> +static inline void mem_cgroup_uncharge_batch_start(void)
> +{
> +}
> +
>  static inline void mem_cgroup_uncharge_page(struct page *page)
>  {
>  }
> Index: linux-2.6.31-rc7/mm/memcontrol.c
> ===================================================================
> --- linux-2.6.31-rc7.orig/mm/memcontrol.c
> +++ linux-2.6.31-rc7/mm/memcontrol.c
> @@ -1500,6 +1500,7 @@ __mem_cgroup_uncharge_common(struct page
>  	struct page_cgroup *pc;
>  	struct mem_cgroup *mem = NULL;
>  	struct mem_cgroup_per_zone *mz;
> +	struct memcg_batch_info *batch = NULL;
>  
>  	if (mem_cgroup_disabled())
>  		return NULL;
> @@ -1537,10 +1538,25 @@ __mem_cgroup_uncharge_common(struct page
>  	default:
>  		break;
>  	}
> +	if (current->batch_memcg.batch_mode)
> +		batch = &current->batch_memcg;
>  
> -	res_counter_uncharge(&mem->res, PAGE_SIZE);
> -	if (do_swap_account && (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT))
> -		res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> +	if (!batch || batch->memcg != mem) {
> +		res_counter_uncharge(&mem->res, PAGE_SIZE);
> +		if (do_swap_account &&
> +		    (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT))
> +			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> +		if (batch) {
> +			batch->memcg = mem;
What if we have set batch->memcg to a different memcg and it has some batch->nr_pages(nr_memsw) ?
Shouldn't we flush them first ?

And, it might be a overkill, how about flushing all the batched-uncharges
before invoking oom at __mem_cgroup_try_charge() ?


Thanks,
Daisuke Nishimura.

> +			css_get(&mem->css);
> +		}
> +	} else {
> +		/* instead of modifing res_counter, remember it */
> +		batch->nr_pages += PAGE_SIZE;
> +		if (do_swap_account &&
> +		    (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT))
> +			batch->nr_memsw += PAGE_SIZE;
> +	}
>  	mem_cgroup_charge_statistics(mem, pc, false);
>  
>  	ClearPageCgroupUsed(pc);
> @@ -1582,6 +1598,35 @@ void mem_cgroup_uncharge_cache_page(stru
>  	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE);
>  }
>  
> +void mem_cgroup_uncharge_batch_start(void)
> +{
> +	VM_BUG_ON(current->batch_memcg.batch_mode);
> +	current->batch_memcg.batch_mode = 1;
> +	current->batch_memcg.memcg = NULL;
> +	current->batch_memcg.nr_pages = 0;
> +	current->batch_memcg.nr_memsw = 0;
> +}
> +
> +void mem_cgroup_uncharge_batch_end(void)
> +{
> +	struct mem_cgroup *mem;
> +
> +	VM_BUG_ON(!current->batch_memcg.batch_mode);
> +	current->batch_memcg.batch_mode = 0;
> +
> +	mem = current->batch_memcg.memcg;
> +	if (!mem)
> +		return;
> +	if (current->batch_memcg.nr_pages)
> +		res_counter_uncharge(&mem->res,
> +				     current->batch_memcg.nr_pages);
> +	if (current->batch_memcg.nr_memsw)
> +		res_counter_uncharge(&mem->memsw,
> +				     current->batch_memcg.nr_memsw);
> +	/* we got css's refcnt */
> +	cgroup_release_and_wakeup_rmdir(&mem->css);
> +}
> +
>  #ifdef CONFIG_SWAP
>  /*
>   * called after __delete_from_swap_cache() and drop "page" account.
> Index: linux-2.6.31-rc7/include/linux/sched.h
> ===================================================================
> --- linux-2.6.31-rc7.orig/include/linux/sched.h
> +++ linux-2.6.31-rc7/include/linux/sched.h
> @@ -1480,6 +1480,14 @@ struct task_struct {
>  	/* bitmask of trace recursion */
>  	unsigned long trace_recursion;
>  #endif /* CONFIG_TRACING */
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +	/* For implicit argument for batched uncharge */
> +	struct memcg_batch_info {
> +		struct mem_cgroup *memcg;
> +		int batch_mode;
> +		unsigned long nr_pages, nr_memsw;
> +	} batch_memcg;
> +#endif
>  };
>  
>  /* Future-safe accessor for struct task_struct's cpus_allowed. */
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
