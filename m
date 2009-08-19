Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 00C756B004D
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 10:18:00 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7JEI3qs031117
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 19 Aug 2009 23:18:04 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 75BF545DE5B
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 23:18:03 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 41C4745DE52
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 23:18:03 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 19105E18010
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 23:18:03 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A978BE1800E
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 23:18:02 +0900 (JST)
Message-ID: <f4131456fc4b1dd4f5b8d060e0cbef80.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090819134036.GA7267@localhost>
References: <4A856467.6050102@redhat.com> <20090815054524.GB11387@localhost>
    <20090818224230.A648.A69D9226@jp.fujitsu.com>
    <20090819134036.GA7267@localhost>
Date: Wed, 19 Aug 2009 23:18:01 +0900 (JST)
Subject: Re: [RFC] memcg: move definitions to .h and inline some functions
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

Wu Fengguang さんは書きました：
> On Tue, Aug 18, 2009 at 11:57:52PM +0800, KOSAKI Motohiro wrote:
>>
>> > > This one of the reasons why we unconditionally deactivate
>> > > the active anon pages, and do background scanning of the
>> > > active anon list when reclaiming page cache pages.
>> > >
>> > > We want to always move some pages to the inactive anon
>> > > list, so it does not get too small.
>> >
>> > Right, the current code tries to pull inactive list out of
>> > smallish-size state as long as there are vmscan activities.
>> >
>> > However there is a possible (and tricky) hole: mem cgroups
>> > don't do batched vmscan. shrink_zone() may call shrink_list()
>> > with nr_to_scan=1, in which case shrink_list() _still_ calls
>> > isolate_pages() with the much larger SWAP_CLUSTER_MAX.
>> >
>> > It effectively scales up the inactive list scan rate by 10 times when
>> > it is still small, and may thus prevent it from growing up for ever.
>> >
>> > In that case, LRU becomes FIFO.
>> >
>> > Jeff, can you confirm if the mem cgroup's inactive list is small?
>> > If so, this patch should help.
>>
>> This patch does right thing.
>> However, I would explain why I and memcg folks didn't do that in past
>> days.
>>
>> Strangely, some memcg struct declaration is hide in *.c. Thus we can't
>> make inline function and we hesitated to introduce many function calling
>> overhead.
>>
>> So, Can we move some memcg structure declaration to *.h and make
>> mem_cgroup_get_saved_scan() inlined function?
>
> OK here it is. I have to move big chunks to make it compile, and it
> does reduced a dozen lines of code :)
>
> Is this big copy&paste acceptable? (memcg developers CCed).
>
> Thanks,
> Fengguang

I don't like this. plz add hooks to necessary places, at this stage.
This will be too big for inlined function, anyway.
plz move this after you find overhead is too big.

Thanks,
-Kame


> ---
>
> memcg: move definitions to .h and inline some functions
>
> So as to make inline functions.
>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  include/linux/memcontrol.h |  154 ++++++++++++++++++++++++++++++-----
>  mm/memcontrol.c            |  131 -----------------------------
>  2 files changed, 134 insertions(+), 151 deletions(-)
>
> --- linux.orig/include/linux/memcontrol.h	2009-08-19 20:18:55.000000000
> +0800
> +++ linux/include/linux/memcontrol.h	2009-08-19 20:51:06.000000000 +0800
> @@ -20,11 +20,144 @@
>  #ifndef _LINUX_MEMCONTROL_H
>  #define _LINUX_MEMCONTROL_H
>  #include <linux/cgroup.h>
> -struct mem_cgroup;
> +#include <linux/res_counter.h>
>  struct page_cgroup;
>  struct page;
>  struct mm_struct;
>
> +/*
> + * Statistics for memory cgroup.
> + */
> +enum mem_cgroup_stat_index {
> +	/*
> +	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
> +	 */
> +	MEM_CGROUP_STAT_CACHE,		/* # of pages charged as cache */
> +	MEM_CGROUP_STAT_RSS,		/* # of pages charged as anon rss */
> +	MEM_CGROUP_STAT_MAPPED_FILE,	/* # of pages charged as file rss */
> +	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
> +	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
> +
> +	MEM_CGROUP_STAT_NSTATS,
> +};
> +
> +struct mem_cgroup_stat_cpu {
> +	s64 count[MEM_CGROUP_STAT_NSTATS];
> +} ____cacheline_aligned_in_smp;
> +
> +struct mem_cgroup_stat {
> +	struct mem_cgroup_stat_cpu cpustat[0];
> +};
> +
> +/*
> + * per-zone information in memory controller.
> + */
> +struct mem_cgroup_per_zone {
> +	/*
> +	 * spin_lock to protect the per cgroup LRU
> +	 */
> +	struct list_head	lists[NR_LRU_LISTS];
> +	unsigned long		count[NR_LRU_LISTS];
> +
> +	struct zone_reclaim_stat reclaim_stat;
> +};
> +/* Macro for accessing counter */
> +#define MEM_CGROUP_ZSTAT(mz, idx)	((mz)->count[(idx)])
> +
> +struct mem_cgroup_per_node {
> +	struct mem_cgroup_per_zone zoneinfo[MAX_NR_ZONES];
> +};
> +
> +struct mem_cgroup_lru_info {
> +	struct mem_cgroup_per_node *nodeinfo[MAX_NUMNODES];
> +};
> +
> +/*
> + * The memory controller data structure. The memory controller controls
> both
> + * page cache and RSS per cgroup. We would eventually like to provide
> + * statistics based on the statistics developed by Rik Van Riel for
> clock-pro,
> + * to help the administrator determine what knobs to tune.
> + *
> + * TODO: Add a water mark for the memory controller. Reclaim will begin
> when
> + * we hit the water mark. May be even add a low water mark, such that
> + * no reclaim occurs from a cgroup at it's low water mark, this is
> + * a feature that will be implemented much later in the future.
> + */
> +struct mem_cgroup {
> +	struct cgroup_subsys_state css;
> +	/*
> +	 * the counter to account for memory usage
> +	 */
> +	struct res_counter res;
> +	/*
> +	 * the counter to account for mem+swap usage.
> +	 */
> +	struct res_counter memsw;
> +	/*
> +	 * Per cgroup active and inactive list, similar to the
> +	 * per zone LRU lists.
> +	 */
> +	struct mem_cgroup_lru_info info;
> +
> +	/*
> +	  protect against reclaim related member.
> +	*/
> +	spinlock_t reclaim_param_lock;
> +
> +	int	prev_priority;	/* for recording reclaim priority */
> +
> +	/*
> +	 * While reclaiming in a hiearchy, we cache the last child we
> +	 * reclaimed from.
> +	 */
> +	int last_scanned_child;
> +	/*
> +	 * Should the accounting and control be hierarchical, per subtree?
> +	 */
> +	bool use_hierarchy;
> +	unsigned long	last_oom_jiffies;
> +	atomic_t	refcnt;
> +
> +	unsigned int	swappiness;
> +
> +	/* set when res.limit == memsw.limit */
> +	bool		memsw_is_minimum;
> +
> +	/*
> +	 * statistics. This must be placed at the end of memcg.
> +	 */
> +	struct mem_cgroup_stat stat;
> +};
> +
> +static inline struct mem_cgroup_per_zone *
> +mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
> +{
> +	return &mem->info.nodeinfo[nid]->zoneinfo[zid];
> +}
> +
> +static inline unsigned long
> +mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
> +			 struct zone *zone,
> +			 enum lru_list lru)
> +{
> +	int nid = zone->zone_pgdat->node_id;
> +	int zid = zone_idx(zone);
> +	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid, zid);
> +
> +	return MEM_CGROUP_ZSTAT(mz, lru);
> +}
> +
> +static inline struct zone_reclaim_stat *
> +mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg, struct zone *zone)
> +{
> +	int nid = zone->zone_pgdat->node_id;
> +	int zid = zone_idx(zone);
> +	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid, zid);
> +
> +	return &mz->reclaim_stat;
> +}
> +
> +
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
>  /*
>   * All "charge" functions with gfp_mask should use GFP_KERNEL or
> @@ -95,11 +228,6 @@ extern void mem_cgroup_record_reclaim_pr
>  							int priority);
>  int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
>  int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
> -unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
> -				       struct zone *zone,
> -				       enum lru_list lru);
> -struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup
> *memcg,
> -						      struct zone *zone);
>  struct zone_reclaim_stat*
>  mem_cgroup_get_reclaim_stat_from_page(struct page *page);
>  extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
> @@ -246,20 +374,6 @@ mem_cgroup_inactive_file_is_low(struct m
>  	return 1;
>  }
>
> -static inline unsigned long
> -mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg, struct zone *zone,
> -			 enum lru_list lru)
> -{
> -	return 0;
> -}
> -
> -
> -static inline struct zone_reclaim_stat*
> -mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg, struct zone *zone)
> -{
> -	return NULL;
> -}
> -
>  static inline struct zone_reclaim_stat*
>  mem_cgroup_get_reclaim_stat_from_page(struct page *page)
>  {
> --- linux.orig/mm/memcontrol.c	2009-08-19 20:14:56.000000000 +0800
> +++ linux/mm/memcontrol.c	2009-08-19 20:46:50.000000000 +0800
> @@ -55,30 +55,6 @@ static int really_do_swap_account __init
>  static DEFINE_MUTEX(memcg_tasklist);	/* can be hold under cgroup_mutex */
>
>  /*
> - * Statistics for memory cgroup.
> - */
> -enum mem_cgroup_stat_index {
> -	/*
> -	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
> -	 */
> -	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
> -	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
> -	MEM_CGROUP_STAT_MAPPED_FILE,  /* # of pages charged as file rss */
> -	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
> -	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
> -
> -	MEM_CGROUP_STAT_NSTATS,
> -};
> -
> -struct mem_cgroup_stat_cpu {
> -	s64 count[MEM_CGROUP_STAT_NSTATS];
> -} ____cacheline_aligned_in_smp;
> -
> -struct mem_cgroup_stat {
> -	struct mem_cgroup_stat_cpu cpustat[0];
> -};
> -
> -/*
>   * For accounting under irq disable, no need for increment preempt count.
>   */
>  static inline void __mem_cgroup_stat_add_safe(struct mem_cgroup_stat_cpu
> *stat,
> @@ -106,86 +82,6 @@ static s64 mem_cgroup_local_usage(struct
>  	return ret;
>  }
>
> -/*
> - * per-zone information in memory controller.
> - */
> -struct mem_cgroup_per_zone {
> -	/*
> -	 * spin_lock to protect the per cgroup LRU
> -	 */
> -	struct list_head	lists[NR_LRU_LISTS];
> -	unsigned long		count[NR_LRU_LISTS];
> -
> -	struct zone_reclaim_stat reclaim_stat;
> -};
> -/* Macro for accessing counter */
> -#define MEM_CGROUP_ZSTAT(mz, idx)	((mz)->count[(idx)])
> -
> -struct mem_cgroup_per_node {
> -	struct mem_cgroup_per_zone zoneinfo[MAX_NR_ZONES];
> -};
> -
> -struct mem_cgroup_lru_info {
> -	struct mem_cgroup_per_node *nodeinfo[MAX_NUMNODES];
> -};
> -
> -/*
> - * The memory controller data structure. The memory controller controls
> both
> - * page cache and RSS per cgroup. We would eventually like to provide
> - * statistics based on the statistics developed by Rik Van Riel for
> clock-pro,
> - * to help the administrator determine what knobs to tune.
> - *
> - * TODO: Add a water mark for the memory controller. Reclaim will begin
> when
> - * we hit the water mark. May be even add a low water mark, such that
> - * no reclaim occurs from a cgroup at it's low water mark, this is
> - * a feature that will be implemented much later in the future.
> - */
> -struct mem_cgroup {
> -	struct cgroup_subsys_state css;
> -	/*
> -	 * the counter to account for memory usage
> -	 */
> -	struct res_counter res;
> -	/*
> -	 * the counter to account for mem+swap usage.
> -	 */
> -	struct res_counter memsw;
> -	/*
> -	 * Per cgroup active and inactive list, similar to the
> -	 * per zone LRU lists.
> -	 */
> -	struct mem_cgroup_lru_info info;
> -
> -	/*
> -	  protect against reclaim related member.
> -	*/
> -	spinlock_t reclaim_param_lock;
> -
> -	int	prev_priority;	/* for recording reclaim priority */
> -
> -	/*
> -	 * While reclaiming in a hiearchy, we cache the last child we
> -	 * reclaimed from.
> -	 */
> -	int last_scanned_child;
> -	/*
> -	 * Should the accounting and control be hierarchical, per subtree?
> -	 */
> -	bool use_hierarchy;
> -	unsigned long	last_oom_jiffies;
> -	atomic_t	refcnt;
> -
> -	unsigned int	swappiness;
> -
> -	/* set when res.limit == memsw.limit */
> -	bool		memsw_is_minimum;
> -
> -	/*
> -	 * statistics. This must be placed at the end of memcg.
> -	 */
> -	struct mem_cgroup_stat stat;
> -};
> -
>  enum charge_type {
>  	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
>  	MEM_CGROUP_CHARGE_TYPE_MAPPED,
> @@ -244,12 +140,6 @@ static void mem_cgroup_charge_statistics
>  }
>
>  static struct mem_cgroup_per_zone *
> -mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
> -{
> -	return &mem->info.nodeinfo[nid]->zoneinfo[zid];
> -}
> -
> -static struct mem_cgroup_per_zone *
>  page_cgroup_zoneinfo(struct page_cgroup *pc)
>  {
>  	struct mem_cgroup *mem = pc->mem_cgroup;
> @@ -586,27 +476,6 @@ int mem_cgroup_inactive_file_is_low(stru
>  	return (active > inactive);
>  }
>
> -unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
> -				       struct zone *zone,
> -				       enum lru_list lru)
> -{
> -	int nid = zone->zone_pgdat->node_id;
> -	int zid = zone_idx(zone);
> -	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid, zid);
> -
> -	return MEM_CGROUP_ZSTAT(mz, lru);
> -}
> -
> -struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup
> *memcg,
> -						      struct zone *zone)
> -{
> -	int nid = zone->zone_pgdat->node_id;
> -	int zid = zone_idx(zone);
> -	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(memcg, nid, zid);
> -
> -	return &mz->reclaim_stat;
> -}
> -
>  struct zone_reclaim_stat *
>  mem_cgroup_get_reclaim_stat_from_page(struct page *page)
>  {
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
