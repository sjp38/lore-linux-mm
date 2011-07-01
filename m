Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D340E6B004A
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 03:18:11 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C9B6A3EE0AE
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 16:18:07 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AC62145DE61
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 16:18:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8794745DE6A
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 16:18:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BD8C1DB802C
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 16:18:07 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F3581DB8038
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 16:18:07 +0900 (JST)
Date: Fri, 1 Jul 2011 16:10:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] [Cleanup] memcg: export memory cgroup's swappiness v2
Message-Id: <20110701161051.0ab237c5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110701103007.8110f130.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110629190325.28aa2dc6.kamezawa.hiroyu@jp.fujitsu.com>
	<20110630130134.63a1dd37.akpm@linux-foundation.org>
	<20110701085013.4e8cbb02.kamezawa.hiroyu@jp.fujitsu.com>
	<20110701092059.be4400f7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110630180653.1df10f38.akpm@linux-foundation.org>
	<20110701101624.a10b7e34.kamezawa.hiroyu@jp.fujitsu.com>
	<20110701103007.8110f130.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Fri, 1 Jul 2011 10:30:07 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Fri, 1 Jul 2011 10:16:24 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Thu, 30 Jun 2011 18:06:53 -0700
> > Andrew Morton <akpm@linux-foundation.org> wrote:
> > 
> > > On Fri, 1 Jul 2011 09:20:59 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > 
> > > > On Fri, 1 Jul 2011 08:50:13 +0900
> > > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > 
> > > > > On Thu, 30 Jun 2011 13:01:34 -0700
> > > > > Andrew Morton <akpm@linux-foundation.org> wrote:
> > > > 
> > > > > Ok, I'll check it. Maybe I miss !CONFIG_SWAP...
> > > > > 
> > > > 
> > > > v4 here. Thank you for pointing out. I could think of several ways but
> > > > maybe this one is good because using vm_swappines with !CONFIG_SWAP seems
> > > > to be a bug.
> > > 
> > > No, it isn't a bug - swappiness also controls the kernel's eagerness to
> > > unmap and reclaim mmapped pagecache.
> > > 
> > 
> > Oh, really ? I didn't understand that.
> > 
> Hmm, anyway, this new version of fix seems better.

Sorry, this seems still buggy. I'll send a new one in the next week :(

Thanks,
-Kame

> ==
> From 7daf93a277e19026bb6edef3e0ac01bbd31dcb5e Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Fri, 1 Jul 2011 10:35:57 +0900
> Subject: [PATCH] export memory cgroup's swappines by mem_cgroup_swappiness()
> 
> Each memory cgroup has 'swappiness' value and it can be accessed by
> get_swappiness(memcg). The major user is try_to_free_mem_cgroup_pages()
> and swappiness is passed by argument. It's propagated by scan_control.
> 
> get_swappiness is static function but some planned updates will need to
> get swappiness from files other than memcontrol.c
> This patch exports get_swappiness() as mem_cgroup_swappiness().
> By this, we can remove the argument of swapiness from try_to_free...
> and drop swappiness from scan_control. only memcg uses it.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Changelog:
>   - move definistions out of CONFIG_SWAP.
>   - fixed/tested allyesconfig/allnoconfig compile failure.
>   - adjusted signedness to vm_swappiness.
>   - drop swappiness from scan_control
> ---
>  include/linux/swap.h |   13 +++++++++----
>  mm/memcontrol.c      |   15 +++++++--------
>  mm/vmscan.c          |   23 ++++++++++-------------
>  3 files changed, 26 insertions(+), 25 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index a273468..28f1490 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -252,11 +252,9 @@ static inline void lru_cache_add_file(struct page *page)
>  extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>  					gfp_t gfp_mask, nodemask_t *mask);
>  extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
> -						  gfp_t gfp_mask, bool noswap,
> -						  unsigned int swappiness);
> +						  gfp_t gfp_mask, bool noswap);
>  extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
>  						gfp_t gfp_mask, bool noswap,
> -						unsigned int swappiness,
>  						struct zone *zone,
>  						unsigned long *nr_scanned);
>  extern int __isolate_lru_page(struct page *page, int mode, int file);
> @@ -299,7 +297,14 @@ static inline void scan_unevictable_unregister_node(struct node *node)
>  
>  extern int kswapd_run(int nid);
>  extern void kswapd_stop(int nid);
> -
> +#ifdef CONFIG_MEM_CGROUP_MEM_RES_CTLR
> +extern int mem_cgroup_swappiness(struct mem_cgroup *mem);
> +#else
> +static inline int mem_cgroup_swappiness(struct mem_cgroup *mem)
> +{
> +	return vm_swappiness;
> +}
> +#endif
>  #ifdef CONFIG_SWAP
>  /* linux/mm/page_io.c */
>  extern int swap_readpage(struct page *);
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 3e7d5e6..db70176 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -249,7 +249,7 @@ struct mem_cgroup {
>  	atomic_t	oom_lock;
>  	atomic_t	refcnt;
>  
> -	unsigned int	swappiness;
> +	int	swappiness;
>  	/* OOM-Killer disable */
>  	int		oom_kill_disable;
>  
> @@ -1330,7 +1330,7 @@ static unsigned long mem_cgroup_margin(struct mem_cgroup *mem)
>  	return margin >> PAGE_SHIFT;
>  }
>  
> -static unsigned int get_swappiness(struct mem_cgroup *memcg)
> +int mem_cgroup_swappiness(struct mem_cgroup *memcg)
>  {
>  	struct cgroup *cgrp = memcg->css.cgroup;
>  
> @@ -1776,12 +1776,11 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>  		/* we use swappiness of local cgroup */
>  		if (check_soft) {
>  			ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
> -				noswap, get_swappiness(victim), zone,
> -				&nr_scanned);
> +				noswap, zone, &nr_scanned);
>  			*total_scanned += nr_scanned;
>  		} else
>  			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
> -						noswap, get_swappiness(victim));
> +						noswap);
>  		css_put(&victim->css);
>  		/*
>  		 * At shrinking usage, we can't check we should stop here or
> @@ -3826,7 +3825,7 @@ try_to_free:
>  			goto out;
>  		}
>  		progress = try_to_free_mem_cgroup_pages(mem, GFP_KERNEL,
> -						false, get_swappiness(mem));
> +						false);
>  		if (!progress) {
>  			nr_retries--;
>  			/* maybe some writeback is necessary */
> @@ -4288,7 +4287,7 @@ static u64 mem_cgroup_swappiness_read(struct cgroup *cgrp, struct cftype *cft)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
>  
> -	return get_swappiness(memcg);
> +	return mem_cgroup_swappiness(memcg);
>  }
>  
>  static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
> @@ -4997,7 +4996,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  	INIT_LIST_HEAD(&mem->oom_notify);
>  
>  	if (parent)
> -		mem->swappiness = get_swappiness(parent);
> +		mem->swappiness = mem_cgroup_swappiness(parent);
>  	atomic_set(&mem->refcnt, 1);
>  	mem->move_charge_at_immigrate = 0;
>  	mutex_init(&mem->thresholds_lock);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 4f49535..fb37699 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -95,8 +95,6 @@ struct scan_control {
>  	/* Can pages be swapped as part of reclaim? */
>  	int may_swap;
>  
> -	int swappiness;
> -
>  	int order;
>  
>  	/*
> @@ -1729,6 +1727,13 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
>  	return shrink_inactive_list(nr_to_scan, zone, sc, priority, file);
>  }
>  
> +static int vmscan_swappiness(struct scan_control *sc)
> +{
> +	if (scanning_global_lru(sc))
> +		return vm_swappiness;
> +	return mem_cgroup_swappiness(sc->mem_cgroup);
> +}
> +
>  /*
>   * Determine how aggressively the anon and file LRU lists should be
>   * scanned.  The relative value of each set of LRU lists is determined
> @@ -1789,8 +1794,8 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
>  	 * With swappiness at 100, anonymous and file have the same priority.
>  	 * This scanning priority is essentially the inverse of IO cost.
>  	 */
> -	anon_prio = sc->swappiness;
> -	file_prio = 200 - sc->swappiness;
> +	anon_prio = vmscan_swappiness(sc);
> +	file_prio = 200 - vmscan_swappiness(sc);
>  
>  	/*
>  	 * OK, so we have swap space and a fair amount of page cache
> @@ -2179,7 +2184,6 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>  		.nr_to_reclaim = SWAP_CLUSTER_MAX,
>  		.may_unmap = 1,
>  		.may_swap = 1,
> -		.swappiness = vm_swappiness,
>  		.order = order,
>  		.mem_cgroup = NULL,
>  		.nodemask = nodemask,
> @@ -2203,7 +2207,6 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>  
>  unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
>  						gfp_t gfp_mask, bool noswap,
> -						unsigned int swappiness,
>  						struct zone *zone,
>  						unsigned long *nr_scanned)
>  {
> @@ -2213,7 +2216,6 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
>  		.may_writepage = !laptop_mode,
>  		.may_unmap = 1,
>  		.may_swap = !noswap,
> -		.swappiness = swappiness,
>  		.order = 0,
>  		.mem_cgroup = mem,
>  	};
> @@ -2242,8 +2244,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
>  
>  unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
>  					   gfp_t gfp_mask,
> -					   bool noswap,
> -					   unsigned int swappiness)
> +					   bool noswap)
>  {
>  	struct zonelist *zonelist;
>  	unsigned long nr_reclaimed;
> @@ -2253,7 +2254,6 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
>  		.may_unmap = 1,
>  		.may_swap = !noswap,
>  		.nr_to_reclaim = SWAP_CLUSTER_MAX,
> -		.swappiness = swappiness,
>  		.order = 0,
>  		.mem_cgroup = mem_cont,
>  		.nodemask = NULL, /* we don't care the placement */
> @@ -2403,7 +2403,6 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>  		 * we want to put equal scanning pressure on each zone.
>  		 */
>  		.nr_to_reclaim = ULONG_MAX,
> -		.swappiness = vm_swappiness,
>  		.order = order,
>  		.mem_cgroup = NULL,
>  	};
> @@ -2862,7 +2861,6 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
>  		.may_writepage = 1,
>  		.nr_to_reclaim = nr_to_reclaim,
>  		.hibernation_mode = 1,
> -		.swappiness = vm_swappiness,
>  		.order = 0,
>  	};
>  	struct shrink_control shrink = {
> @@ -3049,7 +3047,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  		.nr_to_reclaim = max_t(unsigned long, nr_pages,
>  				       SWAP_CLUSTER_MAX),
>  		.gfp_mask = gfp_mask,
> -		.swappiness = vm_swappiness,
>  		.order = order,
>  	};
>  	struct shrink_control shrink = {
> -- 
> 1.7.4.1
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
