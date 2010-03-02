Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CD1116B007E
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 08:02:34 -0500 (EST)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp03.in.ibm.com (8.14.3/8.13.1) with ESMTP id o22D2S3D013021
	for <linux-mm@kvack.org>; Tue, 2 Mar 2010 18:32:28 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o22D2SEL2031664
	for <linux-mm@kvack.org>; Tue, 2 Mar 2010 18:32:28 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o22D2RUf026845
	for <linux-mm@kvack.org>; Wed, 3 Mar 2010 00:02:28 +1100
Date: Tue, 2 Mar 2010 18:32:24 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mmotm 2/3] memcg: dirty pages accounting and limiting
 infrastructure
Message-ID: <20100302130223.GF3212@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
 <1267478620-5276-3-git-send-email-arighi@develer.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1267478620-5276-3-git-send-email-arighi@develer.com>
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <arighi@develer.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Andrea Righi <arighi@develer.com> [2010-03-01 22:23:39]:

> Infrastructure to account dirty pages per cgroup and add dirty limit
> interfaces in the cgroupfs:
> 
>  - Direct write-out: memory.dirty_ratio, memory.dirty_bytes
> 
>  - Background write-out: memory.dirty_background_ratio, memory.dirty_background_bytes
> 
> Signed-off-by: Andrea Righi <arighi@develer.com>

Look good, but yet to be tested from my side.


> ---
>  include/linux/memcontrol.h |   77 ++++++++++-
>  mm/memcontrol.c            |  336 ++++++++++++++++++++++++++++++++++++++++----
>  2 files changed, 384 insertions(+), 29 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 1f9b119..cc88b2e 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -19,12 +19,50 @@
> 
>  #ifndef _LINUX_MEMCONTROL_H
>  #define _LINUX_MEMCONTROL_H
> +
> +#include <linux/writeback.h>
>  #include <linux/cgroup.h>
> +
>  struct mem_cgroup;
>  struct page_cgroup;
>  struct page;
>  struct mm_struct;
> 
> +/* Cgroup memory statistics items exported to the kernel */
> +enum mem_cgroup_page_stat_item {
> +	MEMCG_NR_DIRTYABLE_PAGES,
> +	MEMCG_NR_RECLAIM_PAGES,
> +	MEMCG_NR_WRITEBACK,
> +	MEMCG_NR_DIRTY_WRITEBACK_PAGES,
> +};
> +
> +/*
> + * Statistics for memory cgroup.
> + */
> +enum mem_cgroup_stat_index {
> +	/*
> +	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
> +	 */
> +	MEM_CGROUP_STAT_CACHE,	   /* # of pages charged as cache */
> +	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
> +	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
> +	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
> +	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
> +	MEM_CGROUP_STAT_EVENTS,	/* sum of pagein + pageout for internal use */
> +	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> +	MEM_CGROUP_STAT_SOFTLIMIT, /* decrements on each page in/out.
> +					used by soft limit implementation */
> +	MEM_CGROUP_STAT_THRESHOLDS, /* decrements on each page in/out.
> +					used by threshold implementation */
> +	MEM_CGROUP_STAT_FILE_DIRTY,   /* # of dirty pages in page cache */
> +	MEM_CGROUP_STAT_WRITEBACK,   /* # of pages under writeback */
> +	MEM_CGROUP_STAT_WRITEBACK_TEMP,   /* # of pages under writeback using
> +						temporary buffers */
> +	MEM_CGROUP_STAT_UNSTABLE_NFS,   /* # of NFS unstable pages */
> +
> +	MEM_CGROUP_STAT_NSTATS,
> +};
> +
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
>  /*
>   * All "charge" functions with gfp_mask should use GFP_KERNEL or
> @@ -117,6 +155,13 @@ extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
>  extern int do_swap_account;
>  #endif
> 
> +extern long mem_cgroup_dirty_ratio(void);
> +extern unsigned long mem_cgroup_dirty_bytes(void);
> +extern long mem_cgroup_dirty_background_ratio(void);
> +extern unsigned long mem_cgroup_dirty_background_bytes(void);
> +
> +extern s64 mem_cgroup_page_stat(enum mem_cgroup_page_stat_item item);
> +

Docstyle comments for each function would be appreciated

>  static inline bool mem_cgroup_disabled(void)
>  {
>  	if (mem_cgroup_subsys.disabled)
> @@ -125,7 +170,8 @@ static inline bool mem_cgroup_disabled(void)
>  }
> 
>  extern bool mem_cgroup_oom_called(struct task_struct *task);
> -void mem_cgroup_update_file_mapped(struct page *page, int val);

Good to see you make generic use of this function

> +void mem_cgroup_update_stat(struct page *page,
> +			enum mem_cgroup_stat_index idx, int val);
>  unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>  						gfp_t gfp_mask, int nid,
>  						int zid);
> @@ -300,8 +346,8 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
>  {
>  }
> 
> -static inline void mem_cgroup_update_file_mapped(struct page *page,
> -							int val)
> +static inline void mem_cgroup_update_stat(struct page *page,
> +			enum mem_cgroup_stat_index idx, int val)
>  {
>  }
> 
> @@ -312,6 +358,31 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>  	return 0;
>  }
> 
> +static inline long mem_cgroup_dirty_ratio(void)
> +{
> +	return vm_dirty_ratio;
> +}
> +
> +static inline unsigned long mem_cgroup_dirty_bytes(void)
> +{
> +	return vm_dirty_bytes;
> +}
> +
> +static inline long mem_cgroup_dirty_background_ratio(void)
> +{
> +	return dirty_background_ratio;
> +}
> +
> +static inline unsigned long mem_cgroup_dirty_background_bytes(void)
> +{
> +	return dirty_background_bytes;
> +}
> +
> +static inline s64 mem_cgroup_page_stat(enum mem_cgroup_page_stat_item item)
> +{
> +	return -ENOMEM;
> +}
> +
>  #endif /* CONFIG_CGROUP_MEM_CONT */
> 
>  #endif /* _LINUX_MEMCONTROL_H */
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index a443c30..e74cf66 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -66,31 +66,16 @@ static int really_do_swap_account __initdata = 1; /* for remember boot option*/
>  #define SOFTLIMIT_EVENTS_THRESH (1000)
>  #define THRESHOLDS_EVENTS_THRESH (100)
> 
> -/*
> - * Statistics for memory cgroup.
> - */
> -enum mem_cgroup_stat_index {
> -	/*
> -	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
> -	 */
> -	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
> -	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
> -	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
> -	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
> -	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
> -	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> -	MEM_CGROUP_STAT_SOFTLIMIT, /* decrements on each page in/out.
> -					used by soft limit implementation */
> -	MEM_CGROUP_STAT_THRESHOLDS, /* decrements on each page in/out.
> -					used by threshold implementation */
> -
> -	MEM_CGROUP_STAT_NSTATS,
> -};
> -
>  struct mem_cgroup_stat_cpu {
>  	s64 count[MEM_CGROUP_STAT_NSTATS];
>  };
> 
> +/* Per cgroup page statistics */
> +struct mem_cgroup_page_stat {
> +	enum mem_cgroup_page_stat_item item;
> +	s64 value;
> +};
> +
>  /*
>   * per-zone information in memory controller.
>   */
> @@ -157,6 +142,15 @@ struct mem_cgroup_threshold_ary {
>  static bool mem_cgroup_threshold_check(struct mem_cgroup *mem);
>  static void mem_cgroup_threshold(struct mem_cgroup *mem);
> 
> +enum mem_cgroup_dirty_param {
> +	MEM_CGROUP_DIRTY_RATIO,
> +	MEM_CGROUP_DIRTY_BYTES,
> +	MEM_CGROUP_DIRTY_BACKGROUND_RATIO,
> +	MEM_CGROUP_DIRTY_BACKGROUND_BYTES,
> +
> +	MEM_CGROUP_DIRTY_NPARAMS,
> +};
> +
>  /*
>   * The memory controller data structure. The memory controller controls both
>   * page cache and RSS per cgroup. We would eventually like to provide
> @@ -205,6 +199,9 @@ struct mem_cgroup {
> 
>  	unsigned int	swappiness;
> 
> +	/* control memory cgroup dirty pages */
> +	unsigned long dirty_param[MEM_CGROUP_DIRTY_NPARAMS];
> +

Could you mention what protects this field, is it the reclaim_lock?
BTW, is unsigned long sufficient to represent dirty_param(s)?

>  	/* set when res.limit == memsw.limit */
>  	bool		memsw_is_minimum;
> 
> @@ -1021,6 +1018,164 @@ static unsigned int get_swappiness(struct mem_cgroup *memcg)
>  	return swappiness;
>  }
> 
> +static unsigned long get_dirty_param(struct mem_cgroup *memcg,
> +			enum mem_cgroup_dirty_param idx)
> +{
> +	unsigned long ret;
> +
> +	VM_BUG_ON(idx >= MEM_CGROUP_DIRTY_NPARAMS);
> +	spin_lock(&memcg->reclaim_param_lock);
> +	ret = memcg->dirty_param[idx];
> +	spin_unlock(&memcg->reclaim_param_lock);

Do we need a spinlock if we protect it using RCU? Is precise data very
important?

> +
> +	return ret;
> +}
> +
> +long mem_cgroup_dirty_ratio(void)
> +{
> +	struct mem_cgroup *memcg;
> +	long ret = vm_dirty_ratio;
> +
> +	if (mem_cgroup_disabled())
> +		return ret;
> +	/*
> +	 * It's possible that "current" may be moved to other cgroup while we
> +	 * access cgroup. But precise check is meaningless because the task can
> +	 * be moved after our access and writeback tends to take long time.
> +	 * At least, "memcg" will not be freed under rcu_read_lock().
> +	 */
> +	rcu_read_lock();
> +	memcg = mem_cgroup_from_task(current);
> +	if (likely(memcg))
> +		ret = get_dirty_param(memcg, MEM_CGROUP_DIRTY_RATIO);
> +	rcu_read_unlock();
> +
> +	return ret;
> +}
> +
> +unsigned long mem_cgroup_dirty_bytes(void)
> +{
> +	struct mem_cgroup *memcg;
> +	unsigned long ret = vm_dirty_bytes;
> +
> +	if (mem_cgroup_disabled())
> +		return ret;
> +	rcu_read_lock();
> +	memcg = mem_cgroup_from_task(current);
> +	if (likely(memcg))
> +		ret = get_dirty_param(memcg, MEM_CGROUP_DIRTY_BYTES);
> +	rcu_read_unlock();
> +
> +	return ret;
> +}
> +
> +long mem_cgroup_dirty_background_ratio(void)
> +{
> +	struct mem_cgroup *memcg;
> +	long ret = dirty_background_ratio;
> +
> +	if (mem_cgroup_disabled())
> +		return ret;
> +	rcu_read_lock();
> +	memcg = mem_cgroup_from_task(current);
> +	if (likely(memcg))
> +		ret = get_dirty_param(memcg, MEM_CGROUP_DIRTY_BACKGROUND_RATIO);
> +	rcu_read_unlock();
> +
> +	return ret;
> +}
> +
> +unsigned long mem_cgroup_dirty_background_bytes(void)
> +{
> +	struct mem_cgroup *memcg;
> +	unsigned long ret = dirty_background_bytes;
> +
> +	if (mem_cgroup_disabled())
> +		return ret;
> +	rcu_read_lock();
> +	memcg = mem_cgroup_from_task(current);
> +	if (likely(memcg))
> +		ret = get_dirty_param(memcg, MEM_CGROUP_DIRTY_BACKGROUND_BYTES);
> +	rcu_read_unlock();
> +
> +	return ret;
> +}
> +
> +static inline bool mem_cgroup_can_swap(struct mem_cgroup *memcg)
> +{
> +	return do_swap_account ?
> +			res_counter_read_u64(&memcg->memsw, RES_LIMIT) :

Shouldn't you do a res_counter_read_u64(...) > 0 for readability?
What happens if memcg->res, RES_LIMIT == memcg->memsw, RES_LIMIT?

> +			nr_swap_pages > 0;
> +}
> +
> +static s64 mem_cgroup_get_local_page_stat(struct mem_cgroup *memcg,
> +				enum mem_cgroup_page_stat_item item)
> +{
> +	s64 ret;
> +
> +	switch (item) {
> +	case MEMCG_NR_DIRTYABLE_PAGES:
> +		ret = res_counter_read_u64(&memcg->res, RES_LIMIT) -
> +			res_counter_read_u64(&memcg->res, RES_USAGE);
> +		/* Translate free memory in pages */
> +		ret >>= PAGE_SHIFT;
> +		ret += mem_cgroup_read_stat(memcg, LRU_ACTIVE_FILE) +
> +			mem_cgroup_read_stat(memcg, LRU_INACTIVE_FILE);
> +		if (mem_cgroup_can_swap(memcg))
> +			ret += mem_cgroup_read_stat(memcg, LRU_ACTIVE_ANON) +
> +				mem_cgroup_read_stat(memcg, LRU_INACTIVE_ANON);
> +		break;
> +	case MEMCG_NR_RECLAIM_PAGES:
> +		ret = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_FILE_DIRTY) +
> +			mem_cgroup_read_stat(memcg,
> +					MEM_CGROUP_STAT_UNSTABLE_NFS);
> +		break;
> +	case MEMCG_NR_WRITEBACK:
> +		ret = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_WRITEBACK);
> +		break;
> +	case MEMCG_NR_DIRTY_WRITEBACK_PAGES:
> +		ret = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_WRITEBACK) +
> +			mem_cgroup_read_stat(memcg,
> +				MEM_CGROUP_STAT_UNSTABLE_NFS);
> +		break;
> +	default:
> +		ret = 0;
> +		WARN_ON_ONCE(1);
> +	}
> +	return ret;
> +}
> +
> +static int mem_cgroup_page_stat_cb(struct mem_cgroup *mem, void *data)
> +{
> +	struct mem_cgroup_page_stat *stat = (struct mem_cgroup_page_stat *)data;
> +
> +	stat->value += mem_cgroup_get_local_page_stat(mem, stat->item);
> +	return 0;
> +}
> +
> +s64 mem_cgroup_page_stat(enum mem_cgroup_page_stat_item item)
> +{
> +	struct mem_cgroup_page_stat stat = {};
> +	struct mem_cgroup *memcg;
> +
> +	if (mem_cgroup_disabled())
> +		return -ENOMEM;
> +	rcu_read_lock();
> +	memcg = mem_cgroup_from_task(current);
> +	if (memcg) {
> +		/*
> +		 * Recursively evaulate page statistics against all cgroup
> +		 * under hierarchy tree
> +		 */
> +		stat.item = item;
> +		mem_cgroup_walk_tree(memcg, &stat, mem_cgroup_page_stat_cb);
> +	} else
> +		stat.value = -ENOMEM;
> +	rcu_read_unlock();
> +
> +	return stat.value;
> +}
> +
>  static int mem_cgroup_count_children_cb(struct mem_cgroup *mem, void *data)
>  {
>  	int *val = data;
> @@ -1263,14 +1418,16 @@ static void record_last_oom(struct mem_cgroup *mem)
>  }
> 
>  /*
> - * Currently used to update mapped file statistics, but the routine can be
> - * generalized to update other statistics as well.
> + * Generalized routine to update memory cgroup statistics.
>   */
> -void mem_cgroup_update_file_mapped(struct page *page, int val)
> +void mem_cgroup_update_stat(struct page *page,
> +			enum mem_cgroup_stat_index idx, int val)
>  {
>  	struct mem_cgroup *mem;
>  	struct page_cgroup *pc;
> 
> +	if (mem_cgroup_disabled())
> +		return;
>  	pc = lookup_page_cgroup(page);
>  	if (unlikely(!pc))
>  		return;
> @@ -1286,7 +1443,8 @@ void mem_cgroup_update_file_mapped(struct page *page, int val)
>  	/*
>  	 * Preemption is already disabled. We can use __this_cpu_xxx
>  	 */
> -	__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED], val);
> +	VM_BUG_ON(idx >= MEM_CGROUP_STAT_NSTATS);
> +	__this_cpu_add(mem->stat->count[idx], val);
> 
>  done:
>  	unlock_page_cgroup(pc);
> @@ -3033,6 +3191,10 @@ enum {
>  	MCS_PGPGIN,
>  	MCS_PGPGOUT,
>  	MCS_SWAP,
> +	MCS_FILE_DIRTY,
> +	MCS_WRITEBACK,
> +	MCS_WRITEBACK_TEMP,
> +	MCS_UNSTABLE_NFS,
>  	MCS_INACTIVE_ANON,
>  	MCS_ACTIVE_ANON,
>  	MCS_INACTIVE_FILE,
> @@ -3055,6 +3217,10 @@ struct {
>  	{"pgpgin", "total_pgpgin"},
>  	{"pgpgout", "total_pgpgout"},
>  	{"swap", "total_swap"},
> +	{"filedirty", "dirty_pages"},
> +	{"writeback", "writeback_pages"},
> +	{"writeback_tmp", "writeback_temp_pages"},
> +	{"nfs", "nfs_unstable"},
>  	{"inactive_anon", "total_inactive_anon"},
>  	{"active_anon", "total_active_anon"},
>  	{"inactive_file", "total_inactive_file"},
> @@ -3083,6 +3249,14 @@ static int mem_cgroup_get_local_stat(struct mem_cgroup *mem, void *data)
>  		val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_SWAPOUT);
>  		s->stat[MCS_SWAP] += val * PAGE_SIZE;
>  	}
> +	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_FILE_DIRTY);
> +	s->stat[MCS_FILE_DIRTY] += val;
> +	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_WRITEBACK);
> +	s->stat[MCS_WRITEBACK] += val;
> +	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_WRITEBACK_TEMP);
> +	s->stat[MCS_WRITEBACK_TEMP] += val;
> +	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_UNSTABLE_NFS);
> +	s->stat[MCS_UNSTABLE_NFS] += val;
> 
>  	/* per zone stat */
>  	val = mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_ANON);
> @@ -3467,6 +3641,50 @@ unlock:
>  	return ret;
>  }
> 
> +static u64 mem_cgroup_dirty_read(struct cgroup *cgrp, struct cftype *cft)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> +	int type = cft->private;
> +
> +	return get_dirty_param(memcg, type);
> +}
> +
> +static int
> +mem_cgroup_dirty_write(struct cgroup *cgrp, struct cftype *cft, u64 val)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> +	int type = cft->private;
> +
> +	if (cgrp->parent == NULL)
> +		return -EINVAL;
> +	if (((type == MEM_CGROUP_DIRTY_RATIO) ||
> +		(type == MEM_CGROUP_DIRTY_BACKGROUND_RATIO)) && (val > 100))
> +		return -EINVAL;
> +
> +	spin_lock(&memcg->reclaim_param_lock);
> +	switch (type) {
> +	case MEM_CGROUP_DIRTY_RATIO:
> +		memcg->dirty_param[MEM_CGROUP_DIRTY_RATIO] = val;
> +		memcg->dirty_param[MEM_CGROUP_DIRTY_BYTES] = 0;
> +		break;
> +	case MEM_CGROUP_DIRTY_BYTES:
> +		memcg->dirty_param[MEM_CGROUP_DIRTY_RATIO] = 0;
> +		memcg->dirty_param[MEM_CGROUP_DIRTY_BYTES] = val;
> +		break;
> +	case MEM_CGROUP_DIRTY_BACKGROUND_RATIO:
> +		memcg->dirty_param[MEM_CGROUP_DIRTY_BACKGROUND_RATIO] = val;
> +		memcg->dirty_param[MEM_CGROUP_DIRTY_BACKGROUND_BYTES] = 0;
> +		break;
> +	case MEM_CGROUP_DIRTY_BACKGROUND_BYTES:
> +		memcg->dirty_param[MEM_CGROUP_DIRTY_BACKGROUND_RATIO] = 0;
> +		memcg->dirty_param[MEM_CGROUP_DIRTY_BACKGROUND_BYTES] = val;
> +		break;
> +	}
> +	spin_unlock(&memcg->reclaim_param_lock);
> +
> +	return 0;
> +}
> +
>  static struct cftype mem_cgroup_files[] = {
>  	{
>  		.name = "usage_in_bytes",
> @@ -3518,6 +3736,30 @@ static struct cftype mem_cgroup_files[] = {
>  		.write_u64 = mem_cgroup_swappiness_write,
>  	},
>  	{
> +		.name = "dirty_ratio",
> +		.read_u64 = mem_cgroup_dirty_read,
> +		.write_u64 = mem_cgroup_dirty_write,
> +		.private = MEM_CGROUP_DIRTY_RATIO,
> +	},
> +	{
> +		.name = "dirty_bytes",
> +		.read_u64 = mem_cgroup_dirty_read,
> +		.write_u64 = mem_cgroup_dirty_write,
> +		.private = MEM_CGROUP_DIRTY_BYTES,
> +	},
> +	{
> +		.name = "dirty_background_ratio",
> +		.read_u64 = mem_cgroup_dirty_read,
> +		.write_u64 = mem_cgroup_dirty_write,
> +		.private = MEM_CGROUP_DIRTY_BACKGROUND_RATIO,
> +	},
> +	{
> +		.name = "dirty_background_bytes",
> +		.read_u64 = mem_cgroup_dirty_read,
> +		.write_u64 = mem_cgroup_dirty_write,
> +		.private = MEM_CGROUP_DIRTY_BACKGROUND_BYTES,
> +	},
> +	{
>  		.name = "move_charge_at_immigrate",
>  		.read_u64 = mem_cgroup_move_charge_read,
>  		.write_u64 = mem_cgroup_move_charge_write,
> @@ -3725,6 +3967,19 @@ static int mem_cgroup_soft_limit_tree_init(void)
>  	return 0;
>  }
> 
> +/*
> + * NOTE: called only with &src->reclaim_param_lock held from
> + * mem_cgroup_create().
> + */
> +static inline void
> +copy_dirty_params(struct mem_cgroup *dst, struct mem_cgroup *src)
> +{
> +	int i;
> +
> +	for (i = 0; i < MEM_CGROUP_DIRTY_NPARAMS; i++)
> +		dst->dirty_param[i] = src->dirty_param[i];
> +}
> +
>  static struct cgroup_subsys_state * __ref
>  mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  {
> @@ -3776,8 +4031,37 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  	mem->last_scanned_child = 0;
>  	spin_lock_init(&mem->reclaim_param_lock);
> 
> -	if (parent)
> +	if (parent) {
>  		mem->swappiness = get_swappiness(parent);
> +
> +		spin_lock(&parent->reclaim_param_lock);
> +		copy_dirty_params(mem, parent);
> +		spin_unlock(&parent->reclaim_param_lock);
> +	} else {
> +		/*
> +		 * XXX: should we need a lock here? we could switch from
> +		 * vm_dirty_ratio to vm_dirty_bytes or vice versa but we're not
> +		 * reading them atomically. The same for dirty_background_ratio
> +		 * and dirty_background_bytes.
> +		 *
> +		 * For now, try to read them speculatively and retry if a
> +		 * "conflict" is detected.a

The do while loop is subtle, can we add a validate check,share it with
the write routine and retry if validation fails?

> +		 */
> +		do {
> +			mem->dirty_param[MEM_CGROUP_DIRTY_RATIO] =
> +						vm_dirty_ratio;
> +			mem->dirty_param[MEM_CGROUP_DIRTY_BYTES] =
> +						vm_dirty_bytes;
> +		} while (mem->dirty_param[MEM_CGROUP_DIRTY_RATIO] &&
> +			 mem->dirty_param[MEM_CGROUP_DIRTY_BYTES]);
> +		do {
> +			mem->dirty_param[MEM_CGROUP_DIRTY_BACKGROUND_RATIO] =
> +						dirty_background_ratio;
> +			mem->dirty_param[MEM_CGROUP_DIRTY_BACKGROUND_BYTES] =
> +						dirty_background_bytes;
> +		} while (mem->dirty_param[MEM_CGROUP_DIRTY_BACKGROUND_RATIO] &&
> +			mem->dirty_param[MEM_CGROUP_DIRTY_BACKGROUND_BYTES]);
> +	}
>  	atomic_set(&mem->refcnt, 1);
>  	mem->move_charge_at_immigrate = 0;
>  	mutex_init(&mem->thresholds_lock);
> -- 
> 1.6.3.3
> 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
