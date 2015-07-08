Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3FE776B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 11:39:40 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so133659944pac.2
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 08:39:40 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ng15si4665736pdb.208.2015.07.08.08.39.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 08:39:39 -0700 (PDT)
Date: Wed, 8 Jul 2015 18:39:26 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 1/8] memcg: export struct mem_cgroup
Message-ID: <20150708153925.GA2436@esperanza>
References: <1436358472-29137-1-git-send-email-mhocko@kernel.org>
 <1436358472-29137-2-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1436358472-29137-2-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

Hi Michal,

On Wed, Jul 08, 2015 at 02:27:45PM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.cz>
> 
> mem_cgroup structure is defined in mm/memcontrol.c currently which
> means that the code outside of this file has to use external API even
> for trivial access stuff.
> 
> This patch exports mm_struct with its dependencies and makes some of the

IMO it's a step in the right direction. A few nit picks below.

> exported functions inlines. This even helps to reduce the code size a bit
> (make defconfig + CONFIG_MEMCG=y)
> 
> text		data    bss     dec     	 hex 	filename
> 12355346        1823792 1089536 15268674         e8fb42 vmlinux.before
> 12354970        1823792 1089536 15268298         e8f9ca vmlinux.after
> 
> This is not much (370B) but better than nothing. We also save a function
> call in some hot paths like callers of mem_cgroup_count_vm_event which is
> used for accounting.
> 
> The patch doesn't introduce any functional changes.
> 
> Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  include/linux/memcontrol.h | 365 +++++++++++++++++++++++++++++++++++++++++----
>  include/linux/swap.h       |  10 +-
>  include/net/sock.h         |  28 ----
>  mm/memcontrol.c            | 305 -------------------------------------
>  mm/memory-failure.c        |   2 +-
>  mm/slab_common.c           |   2 +-
>  mm/vmscan.c                |   2 +-
>  7 files changed, 344 insertions(+), 370 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 73b02b0a8f60..f5a8d0bbef8d 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -23,8 +23,11 @@
>  #include <linux/vm_event_item.h>
>  #include <linux/hardirq.h>
>  #include <linux/jump_label.h>
> +#include <linux/page_counter.h>
> +#include <linux/vmpressure.h>
> +#include <linux/mmzone.h>
> +#include <linux/writeback.h>
>  
> -struct mem_cgroup;

I think we still need this forward declaration e.g. for defining
reclaim_iter.

>  struct page;
>  struct mm_struct;
>  struct kmem_cache;
> @@ -67,12 +70,221 @@ enum mem_cgroup_events_index {
>  	MEMCG_NR_EVENTS,
>  };
>  
> +/*
> + * Per memcg event counter is incremented at every pagein/pageout. With THP,
> + * it will be incremated by the number of pages. This counter is used for
> + * for trigger some periodic events. This is straightforward and better
> + * than using jiffies etc. to handle periodic memcg event.
> + */
> +enum mem_cgroup_events_target {
> +	MEM_CGROUP_TARGET_THRESH,
> +	MEM_CGROUP_TARGET_SOFTLIMIT,
> +	MEM_CGROUP_TARGET_NUMAINFO,
> +	MEM_CGROUP_NTARGETS,
> +};
> +
> +struct mem_cgroup_stat_cpu {
> +	long count[MEM_CGROUP_STAT_NSTATS];
> +	unsigned long events[MEMCG_NR_EVENTS];
> +	unsigned long nr_page_events;
> +	unsigned long targets[MEM_CGROUP_NTARGETS];
> +};
> +
> +struct reclaim_iter {

I think we'd better rename it to mem_cgroup_reclaim_iter.

> +	struct mem_cgroup *position;
> +	/* scan generation, increased every round-trip */
> +	unsigned int generation;
> +};
> +
> +/*
> + * per-zone information in memory controller.
> + */
> +struct mem_cgroup_per_zone {
> +	struct lruvec		lruvec;
> +	unsigned long		lru_size[NR_LRU_LISTS];
> +
> +	struct reclaim_iter	iter[DEF_PRIORITY + 1];
> +
> +	struct rb_node		tree_node;	/* RB tree node */
> +	unsigned long		usage_in_excess;/* Set to the value by which */
> +						/* the soft limit is exceeded*/
> +	bool			on_tree;
> +	struct mem_cgroup	*memcg;		/* Back pointer, we cannot */
> +						/* use container_of	   */
> +};
> +
> +struct mem_cgroup_per_node {
> +	struct mem_cgroup_per_zone zoneinfo[MAX_NR_ZONES];
> +};
> +
> +struct mem_cgroup_threshold {
> +	struct eventfd_ctx *eventfd;
> +	unsigned long threshold;
> +};
> +
> +/* For threshold */
> +struct mem_cgroup_threshold_ary {
> +	/* An array index points to threshold just below or equal to usage. */
> +	int current_threshold;
> +	/* Size of entries[] */
> +	unsigned int size;
> +	/* Array of thresholds */
> +	struct mem_cgroup_threshold entries[0];
> +};
> +
> +struct mem_cgroup_thresholds {
> +	/* Primary thresholds array */
> +	struct mem_cgroup_threshold_ary *primary;
> +	/*
> +	 * Spare threshold array.
> +	 * This is needed to make mem_cgroup_unregister_event() "never fail".
> +	 * It must be able to store at least primary->size - 1 entries.
> +	 */
> +	struct mem_cgroup_threshold_ary *spare;
> +};

I think we'd better define these structures inside CONFIG_MEMCG section,
just like struct mem_cgroup.

> +
> +/*
> + * Bits in struct cg_proto.flags
> + */
> +enum cg_proto_flags {
> +	/* Currently active and new sockets should be assigned to cgroups */
> +	MEMCG_SOCK_ACTIVE,
> +	/* It was ever activated; we must disarm static keys on destruction */
> +	MEMCG_SOCK_ACTIVATED,
> +};
> +
> +struct cg_proto {
> +	struct page_counter	memory_allocated;	/* Current allocated memory. */
> +	struct percpu_counter	sockets_allocated;	/* Current number of sockets. */
> +	int			memory_pressure;
> +	long			sysctl_mem[3];
> +	unsigned long		flags;
> +	/*
> +	 * memcg field is used to find which memcg we belong directly
> +	 * Each memcg struct can hold more than one cg_proto, so container_of
> +	 * won't really cut.
> +	 *
> +	 * The elegant solution would be having an inverse function to
> +	 * proto_cgroup in struct proto, but that means polluting the structure
> +	 * for everybody, instead of just for memcg users.
> +	 */
> +	struct mem_cgroup	*memcg;
> +};

I'd prefer to leave it where it is now. I don't see any reason why we
have to embed it into mem_cgroup, so may be we'd better keep a pointer
to it in struct mem_cgroup instead?

> +
>  #ifdef CONFIG_MEMCG
> +/*
> + * The memory controller data structure. The memory controller controls both
> + * page cache and RSS per cgroup. We would eventually like to provide
> + * statistics based on the statistics developed by Rik Van Riel for clock-pro,
> + * to help the administrator determine what knobs to tune.
> + */
> +struct mem_cgroup {
> +	struct cgroup_subsys_state css;
> +
> +	/* Accounted resources */
> +	struct page_counter memory;
> +	struct page_counter memsw;
> +	struct page_counter kmem;
> +
> +	/* Normal memory consumption range */
> +	unsigned long low;
> +	unsigned long high;
> +
> +	unsigned long soft_limit;
> +
> +	/* vmpressure notifications */
> +	struct vmpressure vmpressure;
> +
> +	/* css_online() has been completed */
> +	int initialized;
> +
> +	/*
> +	 * Should the accounting and control be hierarchical, per subtree?
> +	 */
> +	bool use_hierarchy;
> +
> +	/* protected by memcg_oom_lock */
> +	bool		oom_lock;
> +	int		under_oom;
> +
> +	int	swappiness;
> +	/* OOM-Killer disable */
> +	int		oom_kill_disable;
> +
> +	/* protect arrays of thresholds */
> +	struct mutex thresholds_lock;
> +
> +	/* thresholds for memory usage. RCU-protected */
> +	struct mem_cgroup_thresholds thresholds;
> +
> +	/* thresholds for mem+swap usage. RCU-protected */
> +	struct mem_cgroup_thresholds memsw_thresholds;
> +
> +	/* For oom notifier event fd */
> +	struct list_head oom_notify;
> +
> +	/*
> +	 * Should we move charges of a task when a task is moved into this
> +	 * mem_cgroup ? And what type of charges should we move ?
> +	 */
> +	unsigned long move_charge_at_immigrate;
> +	/*
> +	 * set > 0 if pages under this cgroup are moving to other cgroup.
> +	 */
> +	atomic_t		moving_account;
> +	/* taken only while moving_account > 0 */
> +	spinlock_t		move_lock;
> +	struct task_struct	*move_lock_task;
> +	unsigned long		move_lock_flags;
> +	/*
> +	 * percpu counter.
> +	 */
> +	struct mem_cgroup_stat_cpu __percpu *stat;
> +	spinlock_t pcp_counter_lock;
> +
> +#if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_INET)
> +	struct cg_proto tcp_mem;
> +#endif
> +#if defined(CONFIG_MEMCG_KMEM)
> +        /* Index in the kmem_cache->memcg_params.memcg_caches array */
> +	int kmemcg_id;
> +	bool kmem_acct_activated;
> +	bool kmem_acct_active;
> +#endif
> +
> +	int last_scanned_node;
> +#if MAX_NUMNODES > 1
> +	nodemask_t	scan_nodes;
> +	atomic_t	numainfo_events;
> +	atomic_t	numainfo_updating;
> +#endif
> +
> +#ifdef CONFIG_CGROUP_WRITEBACK
> +	struct list_head cgwb_list;
> +	struct wb_domain cgwb_domain;
> +#endif
> +
> +	/* List of events which userspace want to receive */
> +	struct list_head event_list;
> +	spinlock_t event_list_lock;
> +
> +	struct mem_cgroup_per_node *nodeinfo[0];
> +	/* WARNING: nodeinfo must be the last member here */
> +};
>  extern struct cgroup_subsys_state *mem_cgroup_root_css;
>  
> -void mem_cgroup_events(struct mem_cgroup *memcg,
> +/**
> + * mem_cgroup_events - count memory events against a cgroup
> + * @memcg: the memory cgroup
> + * @idx: the event index
> + * @nr: the number of events to account for
> + */
> +static inline void mem_cgroup_events(struct mem_cgroup *memcg,
>  		       enum mem_cgroup_events_index idx,
> -		       unsigned int nr);
> +		       unsigned int nr)
> +{
> +	this_cpu_add(memcg->stat->events[idx], nr);
> +}
>  
>  bool mem_cgroup_low(struct mem_cgroup *root, struct mem_cgroup *memcg);
>  
> @@ -90,15 +302,31 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
>  struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
>  struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
>  
> -bool mem_cgroup_is_descendant(struct mem_cgroup *memcg,
> -			      struct mem_cgroup *root);
>  bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg);
>  
>  extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
>  extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
>  
>  extern struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg);

It's a trivial one line function, so why not inline it too?

> -extern struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *css);
> +static inline
> +struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *css){
> +	return css ? container_of(css, struct mem_cgroup, css) : NULL;
> +}
> +
> +struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *,
> +				   struct mem_cgroup *,
> +				   struct mem_cgroup_reclaim_cookie *);
> +void mem_cgroup_iter_break(struct mem_cgroup *, struct mem_cgroup *);
> +
> +static inline bool mem_cgroup_is_descendant(struct mem_cgroup *memcg,
> +			      struct mem_cgroup *root)
> +{
> +	if (root == memcg)
> +		return true;
> +	if (!root->use_hierarchy)
> +		return false;
> +	return cgroup_is_descendant(memcg->css.cgroup, root->css.cgroup);
> +}
>  
>  static inline bool mm_match_cgroup(struct mm_struct *mm,
>  				   struct mem_cgroup *memcg)
[...]
> @@ -184,13 +463,31 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>  						gfp_t gfp_mask,
>  						unsigned long *total_scanned);
>  
> -void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
>  static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
>  					     enum vm_event_item idx)
>  {
> +	struct mem_cgroup *memcg;
> +
>  	if (mem_cgroup_disabled())
>  		return;
> -	__mem_cgroup_count_vm_event(mm, idx);
> +
> +	rcu_read_lock();
> +	memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
> +	if (unlikely(!memcg))
> +		goto out;
> +
> +	switch (idx) {
> +	case PGFAULT:
> +		this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGFAULT]);
> +		break;
> +	case PGMAJFAULT:
> +		this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGMAJFAULT]);
> +		break;
> +	default:
> +		BUG();

This switch-case looks bulky and weird. Let's make this function accept
MEM_CGROUP_EVENTS_PGFAULT/PGMAJFAULT directly instead.

> +	}
> +out:
> +	rcu_read_unlock();
>  }
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  void mem_cgroup_split_huge_fixup(struct page *head);
[...]
> @@ -463,7 +754,15 @@ void __memcg_kmem_commit_charge(struct page *page,
>  				       struct mem_cgroup *memcg, int order);
>  void __memcg_kmem_uncharge_pages(struct page *page, int order);
>  
> -int memcg_cache_id(struct mem_cgroup *memcg);
> +/*
> + * helper for acessing a memcg's index. It will be used as an index in the
> + * child cache array in kmem_cache, and also to derive its name. This function
> + * will return -1 when this is not a kmem-limited memcg.
> + */
> +static inline int memcg_cache_id(struct mem_cgroup *memcg)
> +{
> +	return memcg ? memcg->kmemcg_id : -1;
> +}

We can inline memcg_kmem_is_active too.

>  
>  struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep);
>  void __memcg_kmem_put_cache(struct kmem_cache *cachep);
[...]

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
