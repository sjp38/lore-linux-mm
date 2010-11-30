Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8A0456B0071
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 02:14:25 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAU7EM9m026134
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 30 Nov 2010 16:14:22 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5BE9C45DE60
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 16:14:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C108245DE6E
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 16:14:21 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FF70E3800C
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 16:14:21 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9ED47E38002
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 16:14:20 +0900 (JST)
Date: Tue, 30 Nov 2010 16:08:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] Add kswapd descriptor.
Message-Id: <20101130160838.4c66febf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1291099785-5433-2-git-send-email-yinghan@google.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
	<1291099785-5433-2-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 29 Nov 2010 22:49:42 -0800
Ying Han <yinghan@google.com> wrote:

> There is a kswapd kernel thread for each memory node. We add a different kswapd
> for each cgroup. The kswapd is sleeping in the wait queue headed at kswapd_wait
> field of a kswapd descriptor. The kswapd descriptor stores information of node
> or cgroup and it allows the global and per cgroup background reclaim to share
> common reclaim algorithms.
> 
> This patch addes the kswapd descriptor and changes per zone kswapd_wait to the
> common data structure.
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
>  include/linux/mmzone.h |    3 +-
>  include/linux/swap.h   |   10 +++++
>  mm/memcontrol.c        |    2 +
>  mm/mmzone.c            |    2 +-
>  mm/page_alloc.c        |    9 +++-
>  mm/vmscan.c            |   98 +++++++++++++++++++++++++++++++++--------------
>  6 files changed, 90 insertions(+), 34 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 39c24eb..c77dfa2 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -642,8 +642,7 @@ typedef struct pglist_data {
>  	unsigned long node_spanned_pages; /* total size of physical page
>  					     range, including holes */
>  	int node_id;
> -	wait_queue_head_t kswapd_wait;
> -	struct task_struct *kswapd;
> +	wait_queue_head_t *kswapd_wait;
>  	int kswapd_max_order;
>  } pg_data_t;
>  
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index eba53e7..2e6cb58 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -26,6 +26,16 @@ static inline int current_is_kswapd(void)
>  	return current->flags & PF_KSWAPD;
>  }
>  
> +struct kswapd {
> +	struct task_struct *kswapd_task;
> +	wait_queue_head_t kswapd_wait;
> +	struct mem_cgroup *kswapd_mem;
> +	pg_data_t *kswapd_pgdat;
> +};
> +
> +#define MAX_KSWAPDS MAX_NUMNODES
> +extern struct kswapd kswapds[MAX_KSWAPDS];
> +int kswapd(void *p);

Why this is required ? Can't we allocate this at boot (if necessary) ?
Why exsiting kswapd is also controlled under this structure ?
At the 1st look, this just seem to increase the size of changes....

IMHO, implementing background-reclaim-for-memcg is cleaner than reusing kswapd..
kswapd has tons of unnecessary checks.

Regards,
-Kame

>  /*
>   * MAX_SWAPFILES defines the maximum number of swaptypes: things which can
>   * be swapped to.  The swap type and the offset into that swap type are
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index a4034b6..dca3590 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -263,6 +263,8 @@ struct mem_cgroup {
>  	 */
>  	struct mem_cgroup_stat_cpu nocpu_base;
>  	spinlock_t pcp_counter_lock;
> +
> +	wait_queue_head_t *kswapd_wait;
>  };
>  
>  /* Stuffs for move charges at task migration. */
> diff --git a/mm/mmzone.c b/mm/mmzone.c
> index e35bfb8..c7cbed5 100644
> --- a/mm/mmzone.c
> +++ b/mm/mmzone.c
> @@ -102,7 +102,7 @@ unsigned long zone_nr_free_pages(struct zone *zone)
>  	 * free pages are low, get a better estimate for free pages
>  	 */
>  	if (nr_free_pages < zone->percpu_drift_mark &&
> -			!waitqueue_active(&zone->zone_pgdat->kswapd_wait))
> +			!waitqueue_active(zone->zone_pgdat->kswapd_wait))
>  		return zone_page_state_snapshot(zone, NR_FREE_PAGES);
>  
>  	return nr_free_pages;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index b48dea2..a15bc1c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4070,13 +4070,18 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
>  	int nid = pgdat->node_id;
>  	unsigned long zone_start_pfn = pgdat->node_start_pfn;
>  	int ret;
> +	struct kswapd *kswapd_p;
>  
>  	pgdat_resize_init(pgdat);
>  	pgdat->nr_zones = 0;
> -	init_waitqueue_head(&pgdat->kswapd_wait);
>  	pgdat->kswapd_max_order = 0;
>  	pgdat_page_cgroup_init(pgdat);
> -	
> +
> +	kswapd_p = &kswapds[nid];
> +	init_waitqueue_head(&kswapd_p->kswapd_wait);
> +	pgdat->kswapd_wait = &kswapd_p->kswapd_wait;
> +	kswapd_p->kswapd_pgdat = pgdat;
> +
>  	for (j = 0; j < MAX_NR_ZONES; j++) {
>  		struct zone *zone = pgdat->node_zones + j;
>  		unsigned long size, realsize, memmap_pages;
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index b8a6fdc..e08005e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2115,12 +2115,18 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
>  
>  	return nr_reclaimed;
>  }
> +
>  #endif
>  
> +DEFINE_SPINLOCK(kswapds_spinlock);
> +struct kswapd kswapds[MAX_KSWAPDS];
> +
>  /* is kswapd sleeping prematurely? */
> -static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
> +static int sleeping_prematurely(struct kswapd *kswapd, int order,
> +				long remaining)
>  {
>  	int i;
> +	pg_data_t *pgdat = kswapd->kswapd_pgdat;
>  
>  	/* If a direct reclaimer woke kswapd within HZ/10, it's premature */
>  	if (remaining)
> @@ -2377,21 +2383,28 @@ out:
>   * If there are applications that are active memory-allocators
>   * (most normal use), this basically shouldn't matter.
>   */
> -static int kswapd(void *p)
> +int kswapd(void *p)
>  {
>  	unsigned long order;
> -	pg_data_t *pgdat = (pg_data_t*)p;
> +	struct kswapd *kswapd_p = (struct kswapd *)p;
> +	pg_data_t *pgdat = kswapd_p->kswapd_pgdat;
> +	struct mem_cgroup *mem = kswapd_p->kswapd_mem;
> +	wait_queue_head_t *wait_h = &kswapd_p->kswapd_wait;
>  	struct task_struct *tsk = current;
>  	DEFINE_WAIT(wait);
>  	struct reclaim_state reclaim_state = {
>  		.reclaimed_slab = 0,
>  	};
> -	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
> +	const struct cpumask *cpumask;
>  
>  	lockdep_set_current_reclaim_state(GFP_KERNEL);
>  
> -	if (!cpumask_empty(cpumask))
> -		set_cpus_allowed_ptr(tsk, cpumask);
> +	if (pgdat) {
> +		BUG_ON(pgdat->kswapd_wait != wait_h);
> +		cpumask = cpumask_of_node(pgdat->node_id);
> +		if (!cpumask_empty(cpumask))
> +			set_cpus_allowed_ptr(tsk, cpumask);
> +	}
>  	current->reclaim_state = &reclaim_state;
>  
>  	/*
> @@ -2414,9 +2427,13 @@ static int kswapd(void *p)
>  		unsigned long new_order;
>  		int ret;
>  
> -		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
> -		new_order = pgdat->kswapd_max_order;
> -		pgdat->kswapd_max_order = 0;
> +		prepare_to_wait(wait_h, &wait, TASK_INTERRUPTIBLE);
> +		if (pgdat) {
> +			new_order = pgdat->kswapd_max_order;
> +			pgdat->kswapd_max_order = 0;
> +		} else
> +			new_order = 0;
> +
>  		if (order < new_order) {
>  			/*
>  			 * Don't sleep if someone wants a larger 'order'
> @@ -2428,10 +2445,12 @@ static int kswapd(void *p)
>  				long remaining = 0;
>  
>  				/* Try to sleep for a short interval */
> -				if (!sleeping_prematurely(pgdat, order, remaining)) {
> +				if (!sleeping_prematurely(kswapd_p, order,
> +							remaining)) {
>  					remaining = schedule_timeout(HZ/10);
> -					finish_wait(&pgdat->kswapd_wait, &wait);
> -					prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
> +					finish_wait(wait_h, &wait);
> +					prepare_to_wait(wait_h, &wait,
> +							TASK_INTERRUPTIBLE);
>  				}
>  
>  				/*
> @@ -2439,20 +2458,25 @@ static int kswapd(void *p)
>  				 * premature sleep. If not, then go fully
>  				 * to sleep until explicitly woken up
>  				 */
> -				if (!sleeping_prematurely(pgdat, order, remaining)) {
> -					trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
> +				if (!sleeping_prematurely(kswapd_p, order,
> +								remaining)) {
> +					if (pgdat)
> +						trace_mm_vmscan_kswapd_sleep(
> +								pgdat->node_id);
>  					schedule();
>  				} else {
>  					if (remaining)
> -						count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
> +						count_vm_event(
> +						KSWAPD_LOW_WMARK_HIT_QUICKLY);
>  					else
> -						count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
> +						count_vm_event(
> +						KSWAPD_HIGH_WMARK_HIT_QUICKLY);
>  				}
>  			}
> -
> -			order = pgdat->kswapd_max_order;
> +			if (pgdat)
> +				order = pgdat->kswapd_max_order;
>  		}
> -		finish_wait(&pgdat->kswapd_wait, &wait);
> +		finish_wait(wait_h, &wait);
>  
>  		ret = try_to_freeze();
>  		if (kthread_should_stop())
> @@ -2476,6 +2500,7 @@ static int kswapd(void *p)
>  void wakeup_kswapd(struct zone *zone, int order)
>  {
>  	pg_data_t *pgdat;
> +	wait_queue_head_t *wait;
>  
>  	if (!populated_zone(zone))
>  		return;
> @@ -2488,9 +2513,10 @@ void wakeup_kswapd(struct zone *zone, int order)
>  	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
>  	if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
>  		return;
> -	if (!waitqueue_active(&pgdat->kswapd_wait))
> +	wait = pgdat->kswapd_wait;
> +	if (!waitqueue_active(wait))
>  		return;
> -	wake_up_interruptible(&pgdat->kswapd_wait);
> +	wake_up_interruptible(wait);
>  }
>  
>  /*
> @@ -2587,7 +2613,10 @@ static int __devinit cpu_callback(struct notifier_block *nfb,
>  
>  			if (cpumask_any_and(cpu_online_mask, mask) < nr_cpu_ids)
>  				/* One of our CPUs online: restore mask */
> -				set_cpus_allowed_ptr(pgdat->kswapd, mask);
> +				if (kswapds[nid].kswapd_task)
> +					set_cpus_allowed_ptr(
> +						kswapds[nid].kswapd_task,
> +						mask);
>  		}
>  	}
>  	return NOTIFY_OK;
> @@ -2599,19 +2628,20 @@ static int __devinit cpu_callback(struct notifier_block *nfb,
>   */
>  int kswapd_run(int nid)
>  {
> -	pg_data_t *pgdat = NODE_DATA(nid);
> +	struct task_struct *thr;
>  	int ret = 0;
>  
> -	if (pgdat->kswapd)
> +	if (kswapds[nid].kswapd_task)
>  		return 0;
>  
> -	pgdat->kswapd = kthread_run(kswapd, pgdat, "kswapd%d", nid);
> -	if (IS_ERR(pgdat->kswapd)) {
> +	thr = kthread_run(kswapd, &kswapds[nid], "kswapd%d", nid);
> +	if (IS_ERR(thr)) {
>  		/* failure at boot is fatal */
>  		BUG_ON(system_state == SYSTEM_BOOTING);
>  		printk("Failed to start kswapd on node %d\n",nid);
>  		ret = -1;
>  	}
> +	kswapds[nid].kswapd_task = thr;
>  	return ret;
>  }
>  
> @@ -2620,10 +2650,20 @@ int kswapd_run(int nid)
>   */
>  void kswapd_stop(int nid)
>  {
> -	struct task_struct *kswapd = NODE_DATA(nid)->kswapd;
> +	struct task_struct *thr;
> +	struct kswapd *kswapd_p;
> +	wait_queue_head_t *wait;
> +
> +	pg_data_t *pgdat = NODE_DATA(nid);
> +
> +	spin_lock(&kswapds_spinlock);
> +	wait = pgdat->kswapd_wait;
> +	kswapd_p = container_of(wait, struct kswapd, kswapd_wait);
> +	thr = kswapd_p->kswapd_task;
> +	spin_unlock(&kswapds_spinlock);
>  
> -	if (kswapd)
> -		kthread_stop(kswapd);
> +	if (thr)
> +		kthread_stop(thr);
>  }
>  
>  static int __init kswapd_init(void)
> -- 
> 1.7.3.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
