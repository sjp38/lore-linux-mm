Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8C99D600533
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 21:46:44 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBS2kfxj016125
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 28 Dec 2009 11:46:41 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 555B945DE59
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 11:46:41 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 260DE45DE51
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 11:46:41 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 039BFE38003
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 11:46:41 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8522B1DB805A
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 11:46:40 +0900 (JST)
Date: Mon, 28 Dec 2009 11:43:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v4 4/4] memcg: implement memory thresholds
Message-Id: <20091228114325.e9b3b3d6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <7a4e1d758b98ca633a0be06e883644ad8813c077.1261858972.git.kirill@shutemov.name>
References: <cover.1261858972.git.kirill@shutemov.name>
	<3f29ccc3c93e2defd70fc1c4ca8c133908b70b0b.1261858972.git.kirill@shutemov.name>
	<59a7f92356bf1508f06d12c501a7aa4feffb1bbc.1261858972.git.kirill@shutemov.name>
	<c2379f3965225b6d62e64c64f8c0e67fee085d7f.1261858972.git.kirill@shutemov.name>
	<7a4e1d758b98ca633a0be06e883644ad8813c077.1261858972.git.kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Alexander Shishkin <virtuoso@slind.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 27 Dec 2009 04:09:02 +0200
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
>  Documentation/cgroups/memory.txt |   19 +++-
>  mm/memcontrol.c                  |  275 ++++++++++++++++++++++++++++++++++++++
>  2 files changed, 293 insertions(+), 1 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index b871f25..195af07 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -414,7 +414,24 @@ NOTE1: Soft limits take effect over a long period of time, since they involve
>  NOTE2: It is recommended to set the soft limit always below the hard limit,
>         otherwise the hard limit will take precedence.
>  
> -8. TODO
> +8. Memory thresholds
> +
> +Memory controler implements memory thresholds using cgroups notification
> +API (see cgroups.txt). It allows to register multiple memory and memsw
> +thresholds and gets notifications when it crosses.
> +
> +To register a threshold application need:
> + - create an eventfd using eventfd(2);
> + - open memory.usage_in_bytes or memory.memsw.usage_in_bytes;
> + - write string like "<event_fd> <memory.usage_in_bytes> <threshold>" to
> +   cgroup.event_control.
> +
> +Application will be notified through eventfd when memory usage crosses
> +threshold in any direction.
> +
> +It's applicable for root and non-root cgroup.
> +
> +9. TODO
>  
>  1. Add support for accounting huge pages (as a separate controller)
>  2. Make per-cgroup scanner reclaim not-shared pages first
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 36eb7af..3a0a6a1 100644
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
> @@ -39,6 +43,8 @@
>  #include <linux/mm_inline.h>
>  #include <linux/page_cgroup.h>
>  #include <linux/cpu.h>
> +#include <linux/eventfd.h>
> +#include <linux/sort.h>
>  #include "internal.h"
>  
>  #include <asm/uaccess.h>
> @@ -56,6 +62,7 @@ static int really_do_swap_account __initdata = 1; /* for remember boot option*/
>  #endif
>  
>  #define SOFTLIMIT_EVENTS_THRESH (1000)
> +#define THRESHOLDS_EVENTS_THRESH (100)
>  
>  /*
>   * Statistics for memory cgroup.
> @@ -72,6 +79,8 @@ enum mem_cgroup_stat_index {
>  	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
>  	MEM_CGROUP_STAT_SOFTLIMIT, /* decrements on each page in/out.
>  					used by soft limit implementation */
> +	MEM_CGROUP_STAT_THRESHOLDS, /* decrements on each page in/out.
> +					used by threshold implementation */
>  
>  	MEM_CGROUP_STAT_NSTATS,
>  };
> @@ -182,6 +191,20 @@ struct mem_cgroup_tree {
>  
>  static struct mem_cgroup_tree soft_limit_tree __read_mostly;
>  
> +struct mem_cgroup_threshold {
> +	struct eventfd_ctx *eventfd;
> +	u64 threshold;
> +};
> +
> +struct mem_cgroup_threshold_ary {
> +	unsigned int size;
> +	atomic_t cur;
> +	struct mem_cgroup_threshold entries[0];
> +};
> +
Why "array" is a choice here ? IOW, why not list ?
How many waiters are expected as usual workload ?

> +static bool mem_cgroup_threshold_check(struct mem_cgroup* mem);
> +static void mem_cgroup_threshold(struct mem_cgroup* mem);
> +
>  /*
>   * The memory controller data structure. The memory controller controls both
>   * page cache and RSS per cgroup. We would eventually like to provide
> @@ -233,6 +256,15 @@ struct mem_cgroup {
>  	/* set when res.limit == memsw.limit */
>  	bool		memsw_is_minimum;
>  
> +	/* protect arrays of thresholds */
> +	struct mutex thresholds_lock;
> +
> +	/* thresholds for memory usage. RCU-protected */
> +	struct mem_cgroup_threshold_ary *thresholds;
> +
> +	/* thresholds for mem+swap usage. RCU-protected */
> +	struct mem_cgroup_threshold_ary *memsw_thresholds;
> +
>  	/*
>  	 * statistics. This must be placed at the end of memcg.
>  	 */
> @@ -525,6 +557,8 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
>  		__mem_cgroup_stat_add_safe(cpustat,
>  				MEM_CGROUP_STAT_PGPGOUT_COUNT, 1);
>  	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_SOFTLIMIT, -1);
> +	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_THRESHOLDS, -1);
> +
>  	put_cpu();
>  }
>  
> @@ -1510,6 +1544,8 @@ charged:
>  	if (mem_cgroup_soft_limit_check(mem))
>  		mem_cgroup_update_tree(mem, page);
>  done:
> +	if (mem_cgroup_threshold_check(mem))
> +		mem_cgroup_threshold(mem);
>  	return 0;
>  nomem:
>  	css_put(&mem->css);
> @@ -2075,6 +2111,8 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>  
>  	if (mem_cgroup_soft_limit_check(mem))
>  		mem_cgroup_update_tree(mem, page);
> +	if (mem_cgroup_threshold_check(mem))
> +		mem_cgroup_threshold(mem);
>  	/* at swapout, this memcg will be accessed to record to swap */
>  	if (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
>  		css_put(&mem->css);
> @@ -3071,12 +3109,246 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
>  	return 0;
>  }
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
> +static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
> +{
> +	struct mem_cgroup_threshold_ary *thresholds;
> +	u64 usage = mem_cgroup_usage(memcg, swap);
> +	int i, cur;
> +
> +	rcu_read_lock();
> +	if (!swap) {
> +		thresholds = rcu_dereference(memcg->thresholds);
> +	} else {
> +		thresholds = rcu_dereference(memcg->memsw_thresholds);
> +	}
> +
> +	if (!thresholds)
> +		goto unlock;
> +
> +	cur = atomic_read(&thresholds->cur);
> +
> +	/* Check if a threshold crossed in any direction */
> +
> +	for(i = cur; i >= 0 &&
> +		unlikely(thresholds->entries[i].threshold > usage); i--) {
> +		atomic_dec(&thresholds->cur);
> +		eventfd_signal(thresholds->entries[i].eventfd, 1);
> +	}
> +
> +	for(i = cur + 1; i < thresholds->size &&
> +		unlikely(thresholds->entries[i].threshold <= usage); i++) {
> +		atomic_inc(&thresholds->cur);
> +		eventfd_signal(thresholds->entries[i].eventfd, 1);
> +	}
> +unlock:
> +	rcu_read_unlock();
> +}
> +
> +static void mem_cgroup_threshold(struct mem_cgroup *memcg)
> +{
> +	__mem_cgroup_threshold(memcg, false);
> +	if (do_swap_account)
> +		__mem_cgroup_threshold(memcg, true);
> +}
> +
> +static int compare_thresholds(const void *a, const void *b)
> +{
> +	const struct mem_cgroup_threshold *_a = a;
> +	const struct mem_cgroup_threshold *_b = b;
> +
> +	return _a->threshold - _b->threshold;
> +}
> +
> +static int mem_cgroup_register_event(struct cgroup *cgrp, struct cftype *cft,
> +		struct eventfd_ctx *eventfd, const char *args)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> +	struct mem_cgroup_threshold_ary *thresholds, *thresholds_new;
> +	int type = MEMFILE_TYPE(cft->private);
> +	u64 threshold, usage;
> +	int size;
> +	int i, ret;
> +
> +	ret = res_counter_memparse_write_strategy(args, &threshold);
> +	if (ret)
> +		return ret;
> +
> +	mutex_lock(&memcg->thresholds_lock);
> +	if (type == _MEM)
> +		thresholds = memcg->thresholds;
> +	else if (type == _MEMSWAP)
> +		thresholds = memcg->memsw_thresholds;
> +	else
> +		BUG();
> +
> +	usage = mem_cgroup_usage(memcg, type == _MEMSWAP);
> +
> +	/* Check if a threshold crossed before adding a new one */
> +	if (thresholds)
> +		__mem_cgroup_threshold(memcg, type == _MEMSWAP);
> +
> +	if (thresholds)
> +		size = thresholds->size + 1;
> +	else
> +		size = 1;
> +
> +	/* Allocate memory for new array of thresholds */
> +	thresholds_new = kmalloc(sizeof(*thresholds_new) +
> +			size * sizeof(struct mem_cgroup_threshold),
> +			GFP_KERNEL);
> +	if (!thresholds_new) {
> +		ret = -ENOMEM;
> +		goto unlock;
> +	}
> +	thresholds_new->size = size;
> +
> +	/* Copy thresholds (if any) to new array */
> +	if (thresholds)
> +		memcpy(thresholds_new->entries, thresholds->entries,
> +				thresholds->size *
> +				sizeof(struct mem_cgroup_threshold));
> +	/* Add new threshold */
> +	thresholds_new->entries[size - 1].eventfd = eventfd;
> +	thresholds_new->entries[size - 1].threshold = threshold;
> +
> +	/* Sort thresholds. Registering of new threshold isn't time-critical */
> +	sort(thresholds_new->entries, size,
> +			sizeof(struct mem_cgroup_threshold),
> +			compare_thresholds, NULL);
> +
> +	/* Find current threshold */
> +	atomic_set(&thresholds_new->cur, -1);
> +	for(i = 0; i < size; i++) {
> +		if (thresholds_new->entries[i].threshold < usage)
> +			atomic_inc(&thresholds_new->cur);
> +	}
> +
> +	/*
> +	 * We need to increment refcnt to be sure that all thresholds
> +	 * will be unregistered before calling __mem_cgroup_free()
> +	 */
> +	mem_cgroup_get(memcg);
> +
> +	if (type == _MEM)
> +		rcu_assign_pointer(memcg->thresholds, thresholds_new);
> +	else
> +		rcu_assign_pointer(memcg->memsw_thresholds, thresholds_new);
> +
> +	synchronize_rcu();

Could you add explanation when you use synchronize_rcu() ?

> +	kfree(thresholds);

Can't this be freed by RCU instead of synchronize_rcu() ?


> +unlock:
> +	mutex_unlock(&memcg->thresholds_lock);
> +
> +	return ret;
> +}
> +
> +static int mem_cgroup_unregister_event(struct cgroup *cgrp, struct cftype *cft,
> +		struct eventfd_ctx *eventfd)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> +	struct mem_cgroup_threshold_ary *thresholds, *thresholds_new;
> +	int type = MEMFILE_TYPE(cft->private);
> +	u64 usage;
> +	int size = 0;
> +	int i, j, ret;
> +
> +	mutex_lock(&memcg->thresholds_lock);
> +	if (type == _MEM)
> +		thresholds = memcg->thresholds;
> +	else if (type == _MEMSWAP)
> +		thresholds = memcg->memsw_thresholds;
> +	else
> +		BUG();
> +
> +	/*
> +	 * Something went wrong if we trying to unregister a threshold
> +	 * if we don't have thresholds
> +	 */
> +	BUG_ON(!thresholds);
> +
> +	usage = mem_cgroup_usage(memcg, type == _MEMSWAP);
> +
> +	/* Check if a threshold crossed before removing */
> +	__mem_cgroup_threshold(memcg, type == _MEMSWAP);
> +
> +	/* Calculate new number of threshold */
> +	for(i = 0; i < thresholds->size; i++) {
> +		if (thresholds->entries[i].eventfd != eventfd)
> +			size++;
> +	}
> +
> +	/* Set thresholds array to NULL if we don't have thresholds */
> +	if (!size) {
> +		thresholds_new = NULL;
> +		goto assign;
> +	}
> +
> +	/* Allocate memory for new array of thresholds */
> +	thresholds_new = kmalloc(sizeof(*thresholds_new) +
> +			size * sizeof(struct mem_cgroup_threshold),
> +			GFP_KERNEL);
> +	if (!thresholds_new) {
> +		ret = -ENOMEM;
> +		goto unlock;
> +	}
> +	thresholds_new->size = size;
> +
> +	/* Copy thresholds and find current threshold */
> +	atomic_set(&thresholds_new->cur, -1);
> +	for(i = 0, j = 0; i < thresholds->size; i++) {
> +		if (thresholds->entries[i].eventfd == eventfd)
> +			continue;
> +
> +		thresholds_new->entries[j] = thresholds->entries[i];
> +		if (thresholds_new->entries[j].threshold < usage)
> +			atomic_inc(&thresholds_new->cur);
It's better to do atomic set after loop.

> +		j++;
> +	}

Hmm..is this "copy array" usual coding style for handling eventfd ?


> +
> +assign:
> +	if (type == _MEM)
> +		rcu_assign_pointer(memcg->thresholds, thresholds_new);
> +	else
> +		rcu_assign_pointer(memcg->memsw_thresholds, thresholds_new);
> +
> +	synchronize_rcu();
> +
> +	for(i = 0; i < thresholds->size - size; i++)
> +		mem_cgroup_put(memcg);
> +
> +	kfree(thresholds);
> +unlock:
> +	mutex_unlock(&memcg->thresholds_lock);
> +
> +	return ret;
> +}
>  
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
> @@ -3128,6 +3400,8 @@ static struct cftype memsw_cgroup_files[] = {
>  		.name = "memsw.usage_in_bytes",
>  		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_USAGE),
>  		.read_u64 = mem_cgroup_read,
> +		.register_event = mem_cgroup_register_event,
> +		.unregister_event = mem_cgroup_unregister_event,
>  	},
>  	{
>  		.name = "memsw.max_usage_in_bytes",
> @@ -3367,6 +3641,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  	if (parent)
>  		mem->swappiness = get_swappiness(parent);
>  	atomic_set(&mem->refcnt, 1);
> +	mutex_init(&mem->thresholds_lock);
>  	return &mem->css;
>  free_out:
>  	__mem_cgroup_free(mem);
> -- 
> 1.6.5.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
