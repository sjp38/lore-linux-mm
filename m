Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 917488D0030
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 03:47:08 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9T7l4BL002422
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 29 Oct 2010 16:47:04 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1786F45DE51
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 16:47:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E71C245DE4F
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 16:47:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C2D89E08008
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 16:47:03 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 63015E08001
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 16:47:03 +0900 (JST)
Date: Fri, 29 Oct 2010 16:41:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v4 08/11] memcg: add dirty limits to mem_cgroup
Message-Id: <20101029164131.ec98e874.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1288336154-23256-9-git-send-email-gthelen@google.com>
References: <1288336154-23256-1-git-send-email-gthelen@google.com>
	<1288336154-23256-9-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, 29 Oct 2010 00:09:11 -0700
Greg Thelen <gthelen@google.com> wrote:

> Extend mem_cgroup to contain dirty page limits.  Also add routines
> allowing the kernel to query the dirty usage of a memcg.
> 
> These interfaces not used by the kernel yet.  A subsequent commit
> will add kernel calls to utilize these new routines.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>
> Signed-off-by: Andrea Righi <arighi@develer.com>
> ---
> Changelog since v3:
> - Previously memcontrol.c used struct vm_dirty_param and vm_dirty_param() to
>   advertise dirty memory limits.  Now struct dirty_info and
>   mem_cgroup_dirty_info() is used to share dirty limits between memcontrol and
>   the rest of the kernel.
> - __mem_cgroup_has_dirty_limit() now returns false if use_hierarchy is set.

This seems Okay for our starting point. Hierarchy is always problem..



> - memcg_hierarchical_free_pages() now uses parent_mem_cgroup() and is simpler.
> - created internal routine, __mem_cgroup_has_dirty_limit(), to consolidate the
>   logic.
> 



> Changelog since v1:
> - Rename (for clarity):
>   - mem_cgroup_write_page_stat_item -> mem_cgroup_page_stat_item
>   - mem_cgroup_read_page_stat_item -> mem_cgroup_nr_pages_item
> - Removed unnecessary get_ prefix from get_xxx() functions.
> - Avoid lockdep warnings by using rcu_read_[un]lock() in
>   mem_cgroup_has_dirty_limit().
> 
>  include/linux/memcontrol.h |   30 ++++++
>  mm/memcontrol.c            |  248 +++++++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 277 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index ef2eec7..736d318 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -19,6 +19,7 @@
>  
>  #ifndef _LINUX_MEMCONTROL_H
>  #define _LINUX_MEMCONTROL_H
> +#include <linux/writeback.h>
>  #include <linux/cgroup.h>
>  struct mem_cgroup;
>  struct page_cgroup;
> @@ -33,6 +34,14 @@ enum mem_cgroup_page_stat_item {
>  	MEMCG_NR_FILE_UNSTABLE_NFS, /* # of NFS unstable pages */
>  };
>  
> +/* Cgroup memory statistics items exported to the kernel. */
> +enum mem_cgroup_nr_pages_item {
> +	MEMCG_NR_DIRTYABLE_PAGES,
> +	MEMCG_NR_RECLAIM_PAGES,
> +	MEMCG_NR_WRITEBACK,
> +	MEMCG_NR_DIRTY_WRITEBACK_PAGES,
> +};
> +
>  extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
>  					struct list_head *dst,
>  					unsigned long *scanned, int order,
> @@ -145,6 +154,11 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
>  	mem_cgroup_update_page_stat(page, idx, -1);
>  }
>  
> +bool mem_cgroup_has_dirty_limit(void);
> +bool mem_cgroup_dirty_info(unsigned long sys_available_mem,
> +			   struct dirty_info *info);
> +s64 mem_cgroup_page_stat(enum mem_cgroup_nr_pages_item item);
> +
>  unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>  						gfp_t gfp_mask);
>  u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
> @@ -326,6 +340,22 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
>  {
>  }
>  
> +static inline bool mem_cgroup_has_dirty_limit(void)
> +{
> +	return false;
> +}
> +
> +static inline bool mem_cgroup_dirty_info(unsigned long sys_available_mem,
> +					 struct dirty_info *info)
> +{
> +	return false;
> +}
> +
> +static inline s64 mem_cgroup_page_stat(enum mem_cgroup_nr_pages_item item)
> +{
> +	return -ENOSYS;
> +}
> +
>  static inline
>  unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>  					    gfp_t gfp_mask)
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 7f91029..52d688d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -188,6 +188,14 @@ struct mem_cgroup_eventfd_list {
>  static void mem_cgroup_threshold(struct mem_cgroup *mem);
>  static void mem_cgroup_oom_notify(struct mem_cgroup *mem);
>  
> +/* Dirty memory parameters */
> +struct vm_dirty_param {
> +	int dirty_ratio;
> +	int dirty_background_ratio;
> +	unsigned long dirty_bytes;
> +	unsigned long dirty_background_bytes;
> +};
> +
>  /*
>   * The memory controller data structure. The memory controller controls both
>   * page cache and RSS per cgroup. We would eventually like to provide
> @@ -233,6 +241,10 @@ struct mem_cgroup {
>  	atomic_t	refcnt;
>  
>  	unsigned int	swappiness;
> +
> +	/* control memory cgroup dirty pages */
> +	struct vm_dirty_param dirty_param;
> +
>  	/* OOM-Killer disable */
>  	int		oom_kill_disable;
>  
> @@ -1132,6 +1144,232 @@ static unsigned int get_swappiness(struct mem_cgroup *memcg)
>  	return swappiness;
>  }
>  
> +/*
> + * Return true if the current memory cgroup has local dirty memory settings.
> + * There is an allowed race between the current task migrating in-to/out-of the
> + * root cgroup while this routine runs.  So the return value may be incorrect if
> + * the current task is being simultaneously migrated.
> + */
> +static bool __mem_cgroup_has_dirty_limit(struct mem_cgroup *mem)
> +{
> +	if (!mem)
> +		return false;
> +	if (mem_cgroup_is_root(mem))
> +		return false;
> +	/*
> +	 * The current memcg implementation does not yet support hierarchical
> +	 * dirty limits.
> +	 */
> +	if (mem->use_hierarchy)
> +		return false;
> +	return true;
> +}
> +
> +bool mem_cgroup_has_dirty_limit(void)
> +{
> +	struct mem_cgroup *mem;
> +	bool ret;
> +
> +	if (mem_cgroup_disabled())
> +		return false;
> +
> +	rcu_read_lock();
> +	mem = mem_cgroup_from_task(current);
> +	ret = __mem_cgroup_has_dirty_limit(mem);
> +	rcu_read_unlock();
> +
> +	return ret;
> +}
> +
> +/*
> + * Returns a snapshot of the current dirty limits which is not synchronized with
> + * the routines that change the dirty limits.  If this routine races with an
> + * update to the dirty bytes/ratio value, then the caller must handle the case
> + * where both dirty_[background_]_ratio and _bytes are set.
> + */
> +static void __mem_cgroup_dirty_param(struct vm_dirty_param *param,
> +				     struct mem_cgroup *mem)
> +{
> +	if (__mem_cgroup_has_dirty_limit(mem)) {
> +		param->dirty_ratio = mem->dirty_param.dirty_ratio;
> +		param->dirty_bytes = mem->dirty_param.dirty_bytes;
> +		param->dirty_background_ratio =
> +			mem->dirty_param.dirty_background_ratio;
> +		param->dirty_background_bytes =
> +			mem->dirty_param.dirty_background_bytes;
> +	} else {
> +		param->dirty_ratio = vm_dirty_ratio;
> +		param->dirty_bytes = vm_dirty_bytes;
> +		param->dirty_background_ratio = dirty_background_ratio;
> +		param->dirty_background_bytes = dirty_background_bytes;
> +	}
> +}
> +
> +/*
> + * Return the background-writeback and dirty-throttling thresholds as well as
> + * dirty usage metrics.
> + *
> + * The current task may be moved to another cgroup while this routine accesses
> + * the dirty limit.  But a precise check is meaningless because the task can be
> + * moved after our access and writeback tends to take long time.  At least,
> + * "memcg" will not be freed while holding rcu_read_lock().
> + */
> +bool mem_cgroup_dirty_info(unsigned long sys_available_mem,
> +			   struct dirty_info *info)
> +{
> +	s64 available_mem;
> +	struct vm_dirty_param dirty_param;
> +	struct mem_cgroup *memcg;
> +
> +	if (mem_cgroup_disabled())
> +		return false;
> +
> +	rcu_read_lock();
> +	memcg = mem_cgroup_from_task(current);
> +	if (!__mem_cgroup_has_dirty_limit(memcg)) {
> +		rcu_read_unlock();
> +		return false;
> +	}
> +	__mem_cgroup_dirty_param(&dirty_param, memcg);
> +	rcu_read_unlock();

Hmm, don't we need to get css_get() for this "memcg" ?

> +
> +	available_mem = mem_cgroup_page_stat(MEMCG_NR_DIRTYABLE_PAGES);
> +	if (available_mem < 0)
> +		return false;
> +
> +	available_mem = min((unsigned long)available_mem, sys_available_mem);
> +
This seems nice.

> +	if (dirty_param.dirty_bytes)
> +		info->dirty_thresh =
> +			DIV_ROUND_UP(dirty_param.dirty_bytes, PAGE_SIZE);
> +	else
> +		info->dirty_thresh =
> +			(dirty_param.dirty_ratio * available_mem) / 100;
> +
> +	if (dirty_param.dirty_background_bytes)
> +		info->background_thresh =
> +			DIV_ROUND_UP(dirty_param.dirty_background_bytes,
> +				     PAGE_SIZE);
> +	else
> +		info->background_thresh =
> +			(dirty_param.dirty_background_ratio *
> +			       available_mem) / 100;
> +

Okay, then these will be finally double-checked with system's dirty-info.
Right ?

Thanks,
-Kame

> +	info->nr_reclaimable =
> +		mem_cgroup_page_stat(MEMCG_NR_RECLAIM_PAGES);
> +	if (info->nr_reclaimable < 0)
> +		return false;
> +
> +	info->nr_writeback = mem_cgroup_page_stat(MEMCG_NR_WRITEBACK);
> +	if (info->nr_writeback < 0)
> +		return false;
> +
> +	return true;
> +}
> +
> +static inline bool mem_cgroup_can_swap(struct mem_cgroup *memcg)
> +{
> +	if (!do_swap_account)
> +		return nr_swap_pages > 0;
> +	return !memcg->memsw_is_minimum &&
> +		(res_counter_read_u64(&memcg->memsw, RES_LIMIT) > 0);
> +}
> +
> +static s64 mem_cgroup_local_page_stat(struct mem_cgroup *mem,
> +				      enum mem_cgroup_nr_pages_item item)
> +{
> +	s64 ret;
> +
> +	switch (item) {
> +	case MEMCG_NR_DIRTYABLE_PAGES:
> +		ret = mem_cgroup_read_stat(mem, LRU_ACTIVE_FILE) +
> +			mem_cgroup_read_stat(mem, LRU_INACTIVE_FILE);
> +		if (mem_cgroup_can_swap(mem))
> +			ret += mem_cgroup_read_stat(mem, LRU_ACTIVE_ANON) +
> +				mem_cgroup_read_stat(mem, LRU_INACTIVE_ANON);
> +		break;
> +	case MEMCG_NR_RECLAIM_PAGES:
> +		ret = mem_cgroup_read_stat(mem,	MEM_CGROUP_STAT_FILE_DIRTY) +
> +			mem_cgroup_read_stat(mem,
> +					     MEM_CGROUP_STAT_FILE_UNSTABLE_NFS);
> +		break;
> +	case MEMCG_NR_WRITEBACK:
> +		ret = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_FILE_WRITEBACK);
> +		break;
> +	case MEMCG_NR_DIRTY_WRITEBACK_PAGES:
> +		ret = mem_cgroup_read_stat(mem,
> +					   MEM_CGROUP_STAT_FILE_WRITEBACK) +
> +			mem_cgroup_read_stat(mem,
> +					     MEM_CGROUP_STAT_FILE_UNSTABLE_NFS);
> +		break;
> +	default:
> +		BUG();
> +		break;
> +	}
> +	return ret;
> +}
> +
> +/*
> + * Return the number of pages that the @mem cgroup could allocate.  If
> + * use_hierarchy is set, then this involves parent mem cgroups to find the
> + * cgroup with the smallest free space.
> + */
> +static unsigned long long
> +memcg_hierarchical_free_pages(struct mem_cgroup *mem)
> +{
> +	unsigned long free, min_free;
> +
> +	min_free = global_page_state(NR_FREE_PAGES) << PAGE_SHIFT;
> +
> +	while (mem) {
> +		free = res_counter_read_u64(&mem->res, RES_LIMIT) -
> +			res_counter_read_u64(&mem->res, RES_USAGE);
> +		min_free = min(min_free, free);
> +		mem = parent_mem_cgroup(mem);
> +	}
> +
> +	/* Translate free memory in pages */
> +	return min_free >> PAGE_SHIFT;
> +}
> +
> +/*
> + * mem_cgroup_page_stat() - get memory cgroup file cache statistics
> + * @item:      memory statistic item exported to the kernel
> + *
> + * Return the accounted statistic value or negative value if current task is
> + * root cgroup.
> + */
> +s64 mem_cgroup_page_stat(enum mem_cgroup_nr_pages_item item)
> +{
> +	struct mem_cgroup *mem;
> +	struct mem_cgroup *iter;
> +	s64 value;
> +
> +	rcu_read_lock();
> +	mem = mem_cgroup_from_task(current);
> +	if (__mem_cgroup_has_dirty_limit(mem)) {
> +		/*
> +		 * If we're looking for dirtyable pages we need to evaluate
> +		 * free pages depending on the limit and usage of the parents
> +		 * first of all.
> +		 */
> +		if (item == MEMCG_NR_DIRTYABLE_PAGES)
> +			value = memcg_hierarchical_free_pages(mem);
> +		else
> +			value = 0;
> +		/*
> +		 * Recursively evaluate page statistics against all cgroup
> +		 * under hierarchy tree
> +		 */
> +		for_each_mem_cgroup_tree(iter, mem)
> +			value += mem_cgroup_local_page_stat(iter, item);
> +	} else
> +		value = -EINVAL;
> +	rcu_read_unlock();
> +
> +	return value;
> +}
> +
>  static void mem_cgroup_start_move(struct mem_cgroup *mem)
>  {
>  	int cpu;
> @@ -4440,8 +4678,16 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  	spin_lock_init(&mem->reclaim_param_lock);
>  	INIT_LIST_HEAD(&mem->oom_notify);
>  
> -	if (parent)
> +	if (parent) {
>  		mem->swappiness = get_swappiness(parent);
> +		__mem_cgroup_dirty_param(&mem->dirty_param, parent);
> +	} else {
> +		/*
> +		 * The root cgroup dirty_param field is not used, instead,
> +		 * system-wide dirty limits are used.
> +		 */
> +	}
> +
>  	atomic_set(&mem->refcnt, 1);
>  	mem->move_charge_at_immigrate = 0;
>  	mutex_init(&mem->thresholds_lock);
> -- 
> 1.7.3.1
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
