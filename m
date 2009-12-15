Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8DC406B0044
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:01:59 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBF21tS2014108
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 15 Dec 2009 11:01:56 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6990945DE82
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 11:01:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3007445DE79
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 11:01:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D9251DB8049
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 11:01:55 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D0E41DB804A
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 11:01:54 +0900 (JST)
Date: Tue, 15 Dec 2009 10:58:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH RFC v2 4/4] memcg: implement memory thresholds
Message-Id: <20091215105850.87203454.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <9e6e8d687224c6cbc54281f7c3d07983f701f93d.1260571675.git.kirill@shutemov.name>
References: <cover.1260571675.git.kirill@shutemov.name>
	<ca59c422b495907678915db636f70a8d029cbf3a.1260571675.git.kirill@shutemov.name>
	<c1847dfb5c4fed1374b7add236d38e0db02eeef3.1260571675.git.kirill@shutemov.name>
	<747ea0ec22b9348208c80f86f7a813728bf8e50a.1260571675.git.kirill@shutemov.name>
	<9e6e8d687224c6cbc54281f7c3d07983f701f93d.1260571675.git.kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 12 Dec 2009 00:59:19 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> It allows to register multiple memory and memsw thresholds and gets
> notifications when it crosses.
> 
> To register a threshold application need:
> - create an eventfd;
> - open memory.usage_in_bytes or memory.memsw.usage_in_bytes;
> - write string like "<event_fd> <memory.usage_in_bytes> <threshold>" to
>   cgroup.event_control.
> 
> Application will be notified through eventfd when memory usage crosses
> threshold in any direction.
> 
> It's applicable for root and non-root cgroup.
> 
> It uses stats to track memory usage, simmilar to soft limits. It checks
> if we need to send event to userspace on every 100 page in/out. I guess
> it's good compromise between performance and accuracy of thresholds.
> 
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> ---
>  mm/memcontrol.c |  263 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 263 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c6081cc..5ba2140 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -6,6 +6,10 @@
>   * Copyright 2007 OpenVZ SWsoft Inc
>   * Author: Pavel Emelianov <xemul@openvz.org>
>   *
> + * Memory thresholds
> + * Copyright (C) 2009 Nokia Corporation
> + * Author: Kirill A. Shutemov
> + *
>   * This program is free software; you can redistribute it and/or modify
>   * it under the terms of the GNU General Public License as published by
>   * the Free Software Foundation; either version 2 of the License, or
> @@ -38,6 +42,7 @@
>  #include <linux/vmalloc.h>
>  #include <linux/mm_inline.h>
>  #include <linux/page_cgroup.h>
> +#include <linux/eventfd.h>
>  #include "internal.h"
>  
>  #include <asm/uaccess.h>
> @@ -56,6 +61,7 @@ static int really_do_swap_account __initdata = 1; /* for remember boot option*/
>  
>  static DEFINE_MUTEX(memcg_tasklist);	/* can be hold under cgroup_mutex */
>  #define SOFTLIMIT_EVENTS_THRESH (1000)
> +#define THRESHOLDS_EVENTS_THRESH (100)
>  
>  /*
>   * Statistics for memory cgroup.
> @@ -72,6 +78,8 @@ enum mem_cgroup_stat_index {
>  	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
>  	MEM_CGROUP_STAT_SOFTLIMIT, /* decrements on each page in/out.
>  					used by soft limit implementation */
> +	MEM_CGROUP_STAT_THRESHOLDS, /* decrements on each page in/out.
> +					used by threshold implementation */
>  
>  	MEM_CGROUP_STAT_NSTATS,
>  };
> @@ -182,6 +190,15 @@ struct mem_cgroup_tree {
>  
>  static struct mem_cgroup_tree soft_limit_tree __read_mostly;
>  
> +struct mem_cgroup_threshold {
> +	struct list_head list;
> +	struct eventfd_ctx *eventfd;
> +	u64 threshold;
> +};
> +
> +static bool mem_cgroup_threshold_check(struct mem_cgroup* mem);
> +static void mem_cgroup_threshold(struct mem_cgroup* mem, bool swap);
> +
>  /*
>   * The memory controller data structure. The memory controller controls both
>   * page cache and RSS per cgroup. We would eventually like to provide
> @@ -233,6 +250,19 @@ struct mem_cgroup {
>  	/* set when res.limit == memsw.limit */
>  	bool		memsw_is_minimum;
>  
> +	/* protect lists of thresholds*/
> +	spinlock_t thresholds_lock;
> +
> +	/* thresholds for memory usage */
> +	struct list_head thresholds;
> +	struct mem_cgroup_threshold *below_threshold;
> +	struct mem_cgroup_threshold *above_threshold;
> +
> +	/* thresholds for mem+swap usage */
> +	struct list_head memsw_thresholds;
> +	struct mem_cgroup_threshold *memsw_below_threshold;
> +	struct mem_cgroup_threshold *memsw_above_threshold;
> +
>  	/*
>  	 * statistics. This must be placed at the end of memcg.
>  	 */
> @@ -519,6 +549,8 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
>  		__mem_cgroup_stat_add_safe(cpustat,
>  				MEM_CGROUP_STAT_PGPGOUT_COUNT, 1);
>  	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_SOFTLIMIT, -1);
> +	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_THRESHOLDS, -1);
> +
>  	put_cpu();
>  }
>  
> @@ -1363,6 +1395,11 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  	if (mem_cgroup_soft_limit_check(mem))
>  		mem_cgroup_update_tree(mem, page);
>  done:
> +	if (mem_cgroup_threshold_check(mem)) {
> +		mem_cgroup_threshold(mem, false);
> +		if (do_swap_account)
> +			mem_cgroup_threshold(mem, true);
> +	}
>  	return 0;
>  nomem:
>  	css_put(&mem->css);
> @@ -1906,6 +1943,11 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>  
>  	if (mem_cgroup_soft_limit_check(mem))
>  		mem_cgroup_update_tree(mem, page);
> +	if (mem_cgroup_threshold_check(mem)) {
> +		mem_cgroup_threshold(mem, false);
> +		if (do_swap_account)
> +			mem_cgroup_threshold(mem, true);
> +	}
>  	/* at swapout, this memcg will be accessed to record to swap */
>  	if (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
>  		css_put(&mem->css);
> @@ -2860,11 +2902,181 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
>  }
>  
>  
> +static bool mem_cgroup_threshold_check(struct mem_cgroup *mem)
> +{
> +	bool ret = false;
> +	int cpu;
> +	s64 val;
> +	struct mem_cgroup_stat_cpu *cpustat;
> +
> +	cpu = get_cpu();
> +	cpustat = &mem->stat.cpustat[cpu];
> +	val = __mem_cgroup_stat_read_local(cpustat, MEM_CGROUP_STAT_THRESHOLDS);
> +	if (unlikely(val < 0)) {
> +		__mem_cgroup_stat_set(cpustat, MEM_CGROUP_STAT_THRESHOLDS,
> +				THRESHOLDS_EVENTS_THRESH);
> +		ret = true;
> +	}
> +	put_cpu();
> +	return ret;
> +}
> +

Hmm. please check 

	if (likely(list_empty(&mem->thesholds) &&
	           list_empty(&mem->memsw_thresholds)))
		return;

or adds a flag as mem->no_threshold_check to skip this routine quickly.

_OR_
I personally don't like to have 2 counters to catch events.

How about this ?

   adds 
   struct mem_cgroup {
	atomic_t	event_counter; // this is incremented per 32
                                           page-in/out
        atomic_t last_softlimit_check;
        atomic_t last_thresh_check;
   };

static bool mem_cgroup_threshold_check(struct mem_cgroup *mem)
{
	decrement percpu event counter.
	if (percpu counter reaches 0) {
		if  (atomic_dec_and_test(&mem->check_thresh) {
			check threashold.
			reset counter.
		}
		if  (atomic_dec_and_test(&memc->check_softlimit) {
			update softlimit tree.
			reset counter.
		}
		reset percpu counter.
	}
}

Then, you can have a counter like system-wide event counter.


> +static void mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
> +{
> +	struct mem_cgroup_threshold **below, **above;
> +	struct list_head *thresholds;
> +	u64 usage = mem_cgroup_usage(memcg, swap);
> +
> +	if (!swap) {
> +		thresholds = &memcg->thresholds;
> +		above = &memcg->above_threshold;
> +		below = &memcg->below_threshold;
> +	} else {
> +		thresholds = &memcg->memsw_thresholds;
> +		above = &memcg->memsw_above_threshold;
> +		below = &memcg->memsw_below_threshold;
> +	}
> +
> +	spin_lock(&memcg->thresholds_lock);
> +	if ((*above)->threshold <= usage) {
> +		*below = *above;
> +		list_for_each_entry_continue((*above), thresholds, list) {
> +			eventfd_signal((*below)->eventfd, 1);
> +			if ((*above)->threshold > usage)
> +				break;
> +			*below = *above;
> +		}
> +	} else if ((*below)->threshold > usage) {
> +		*above = *below;
> +		list_for_each_entry_continue_reverse((*below), thresholds,
> +				list) {
> +			eventfd_signal((*above)->eventfd, 1);
> +			if ((*below)->threshold <= usage)
> +				break;
> +			*above = *below;
> +		}
> +	}
> +	spin_unlock(&memcg->thresholds_lock);
> +}

Could you adds comment on above check ?

And do we need *spin_lock* here ? Can't you use RCU list walk ?

If you use have to use spinlock here, this is a system-wide spinlock,
threshold as "100" is too small, I think.
Even if you can't use spinlock, please use mutex. (with checking gfp_mask).

Thanks,
-Kame


> +
> +static void mem_cgroup_invalidate_thresholds(struct mem_cgroup *memcg,
> +		bool swap)
> +{
> +	struct list_head *thresholds;
> +	struct mem_cgroup_threshold **below, **above;
> +	u64 usage = mem_cgroup_usage(memcg, swap);
> +
> +	if (!swap) {
> +		thresholds = &memcg->thresholds;
> +		above = &memcg->above_threshold;
> +		below = &memcg->below_threshold;
> +	} else {
> +		thresholds = &memcg->memsw_thresholds;
> +		above = &memcg->memsw_above_threshold;
> +		below = &memcg->memsw_below_threshold;
> +	}
> +
> +	*below = NULL;
> +	list_for_each_entry((*above), thresholds, list) {
> +		if ((*above)->threshold > usage) {
> +			BUG_ON(!*below);
> +			break;
> +		}
> +		*below = *above;
> +	}
> +}
> +
> +static inline struct mem_cgroup_threshold *mem_cgroup_threshold_alloc(void)
> +{
> +	struct mem_cgroup_threshold *new;
> +
> +	new = kmalloc(sizeof(*new), GFP_KERNEL);
> +	if (!new)
> +		return NULL;
> +	INIT_LIST_HEAD(&new->list);
> +
> +	return new;
> +}
> +
> +static int mem_cgroup_register_event(struct cgroup *cgrp, struct cftype *cft,
> +		struct eventfd_ctx *eventfd, const char *args)
> +{
> +	u64 threshold;
> +	struct mem_cgroup_threshold *new, *tmp;
> +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> +	struct list_head *thresholds;
> +	int type = MEMFILE_TYPE(cft->private);
> +	int ret;
> +
> +	ret = res_counter_memparse_write_strategy(args, &threshold);
> +	if (ret)
> +		return ret;
> +
> +	new = mem_cgroup_threshold_alloc();
> +	if (!new)
> +		return -ENOMEM;
> +	new->eventfd = eventfd;
> +	new->threshold = threshold;
> +
> +	if (type == _MEM)
> +		thresholds = &memcg->thresholds;
> +	else if (type == _MEMSWAP)
> +		thresholds = &memcg->memsw_thresholds;
> +	else
> +		BUG();
> +
> +	/* Check if a threshold crossed before adding a new one */
> +	mem_cgroup_threshold(memcg, type == _MEMSWAP);
> +
> +	spin_lock(&memcg->thresholds_lock);
> +	list_for_each_entry(tmp, thresholds, list)
> +		if (new->threshold < tmp->threshold) {
> +			list_add_tail(&new->list, &tmp->list);
> +			break;
> +		}
> +	mem_cgroup_invalidate_thresholds(memcg, type == _MEMSWAP);
> +	spin_unlock(&memcg->thresholds_lock);
> +
> +	return 0;
> +}
> +
> +static int mem_cgroup_unregister_event(struct cgroup *cgrp, struct cftype *cft,
> +		struct eventfd_ctx *eventfd)
> +{
> +	struct mem_cgroup_threshold *threshold, *tmp;
> +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> +	struct list_head *thresholds;
> +	int type = MEMFILE_TYPE(cft->private);
> +
> +	if (type == _MEM)
> +		thresholds = &memcg->thresholds;
> +	else if (type == _MEMSWAP)
> +		thresholds = &memcg->memsw_thresholds;
> +	else
> +		BUG();
> +
> +	/* Check if a threshold crossed before adding a new one */
> +	mem_cgroup_threshold(memcg, type == _MEMSWAP);
> +
> +	spin_lock(&memcg->thresholds_lock);
> +	list_for_each_entry_safe(threshold, tmp, thresholds, list)
> +		if (threshold->eventfd == eventfd) {
> +			list_del(&threshold->list);
> +			kfree(threshold);
> +		}
> +	mem_cgroup_invalidate_thresholds(memcg, type == _MEMSWAP);
> +	spin_unlock(&memcg->thresholds_lock);
> +
> +	return 0;
> +}
> +
>  static struct cftype mem_cgroup_files[] = {
>  	{
>  		.name = "usage_in_bytes",
>  		.private = MEMFILE_PRIVATE(_MEM, RES_USAGE),
>  		.read_u64 = mem_cgroup_read,
> +		.register_event = mem_cgroup_register_event,
> +		.unregister_event = mem_cgroup_unregister_event,
>  	},
>  	{
>  		.name = "max_usage_in_bytes",
> @@ -2916,6 +3128,8 @@ static struct cftype memsw_cgroup_files[] = {
>  		.name = "memsw.usage_in_bytes",
>  		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_USAGE),
>  		.read_u64 = mem_cgroup_read,
> +		.register_event = mem_cgroup_register_event,
> +		.unregister_event = mem_cgroup_unregister_event,
>  	},
>  	{
>  		.name = "memsw.max_usage_in_bytes",
> @@ -2990,6 +3204,48 @@ static void free_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
>  	kfree(mem->info.nodeinfo[node]);
>  }
>  
> +static int mem_cgroup_thresholds_init(struct mem_cgroup *mem)
> +{
> +	INIT_LIST_HEAD(&mem->thresholds);
> +	INIT_LIST_HEAD(&mem->memsw_thresholds);
> +
> +	mem->below_threshold = mem_cgroup_threshold_alloc();
> +	list_add(&mem->below_threshold->list, &mem->thresholds);
> +	mem->below_threshold->threshold = 0ULL;
> +
> +	mem->above_threshold = mem_cgroup_threshold_alloc();
> +	list_add_tail(&mem->above_threshold->list, &mem->thresholds);
> +	mem->above_threshold->threshold = RESOURCE_MAX;
> +
> +	mem->memsw_below_threshold = mem_cgroup_threshold_alloc();
> +	list_add(&mem->memsw_below_threshold->list, &mem->memsw_thresholds);
> +	mem->memsw_below_threshold->threshold = 0ULL;
> +
> +	mem->memsw_above_threshold = mem_cgroup_threshold_alloc();
> +	list_add_tail(&mem->memsw_above_threshold->list, &mem->memsw_thresholds);
> +	mem->memsw_above_threshold->threshold = RESOURCE_MAX;
> +
> +	return 0;
> +}
> +
> +static void mem_cgroup_thresholds_free(struct mem_cgroup *mem)
> +{
> +	/* Make sure that lists have only two elements */
> +	BUG_ON((mem->below_threshold) &&
> +			(mem->above_threshold) &&
> +			(mem->below_threshold->list.next !=
> +			 &mem->above_threshold->list));
> +	BUG_ON((mem->memsw_below_threshold) &&
> +			(mem->memsw_above_threshold) &&
> +			(mem->below_threshold->list.next !=
> +			 &mem->above_threshold->list));
> +
> +	kfree(mem->below_threshold);
> +	kfree(mem->above_threshold);
> +	kfree(mem->memsw_below_threshold);
> +	kfree(mem->memsw_above_threshold);
> +}
> +
>  static int mem_cgroup_size(void)
>  {
>  	int cpustat_size = nr_cpu_ids * sizeof(struct mem_cgroup_stat_cpu);
> @@ -3026,6 +3282,8 @@ static void __mem_cgroup_free(struct mem_cgroup *mem)
>  {
>  	int node;
>  
> +	mem_cgroup_thresholds_free(mem);
> +
>  	mem_cgroup_remove_from_trees(mem);
>  	free_css_id(&mem_cgroup_subsys, &mem->css);
>  
> @@ -3145,6 +3403,11 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  	mem->last_scanned_child = 0;
>  	spin_lock_init(&mem->reclaim_param_lock);
>  
> +	spin_lock_init(&mem->thresholds_lock);
> +	error = mem_cgroup_thresholds_init(mem);
> +	if (error)
> +		goto free_out;
> +
>  	if (parent)
>  		mem->swappiness = get_swappiness(parent);
>  	atomic_set(&mem->refcnt, 1);
> -- 
> 1.6.5.3
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
