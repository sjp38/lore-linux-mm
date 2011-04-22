Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 490318D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 01:11:58 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 6AE5C3EE0AE
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 14:11:55 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5449945DF0E
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 14:11:55 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3DD3845DF07
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 14:11:55 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DFBB1DB803C
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 14:11:55 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C52041DB802C
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 14:11:54 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH V7 5/9] Infrastructure to support per-memcg reclaim.
In-Reply-To: <1303446260-21333-6-git-send-email-yinghan@google.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com> <1303446260-21333-6-git-send-email-yinghan@google.com>
Message-Id: <20110422141220.FA62.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 22 Apr 2011 14:11:53 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

> Add the kswapd_mem field in kswapd descriptor which links the kswapd
> kernel thread to a memcg. The per-memcg kswapd is sleeping in the wait
> queue headed at kswapd_wait field of the kswapd descriptor.
> 
> The kswapd() function is now shared between global and per-memcg kswapd. It
> is passed in with the kswapd descriptor which contains the information of
> either node or memcg. Then the new function balance_mem_cgroup_pgdat is
> invoked if it is per-mem kswapd thread, and the implementation of the function
> is on the following patch.
> 
> change v7..v6:
> 1. change the threading model of memcg from per-memcg-per-thread to thread-pool.
> this is based on the patch from KAMAZAWA.
> 
> change v6..v5:
> 1. rename is_node_kswapd to is_global_kswapd to match the scanning_global_lru.
> 2. revert the sleeping_prematurely change, but keep the kswapd_try_to_sleep()
> for memcg.
> 
> changelog v4..v3:
> 1. fix up the kswapd_run and kswapd_stop for online_pages() and offline_pages.
> 2. drop the PF_MEMALLOC flag for memcg kswapd for now per KAMAZAWA's request.
> 
> changelog v3..v2:
> 1. split off from the initial patch which includes all changes of the following
> three patches.
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Looks ok. but this one have some ugly coding style.

functioon()
{
	if (is_global_kswapd()) {
		looooooooong lines
		...
		..
	} else {
		another looooooong lines
		...
		..
	}
}

please pay attention more to keep simpler code.
However, I don't think this patch has major issue. I expect I can ack next version.



> ---
>  include/linux/swap.h |    2 +-
>  mm/memory_hotplug.c  |    2 +-
>  mm/vmscan.c          |  156 +++++++++++++++++++++++++++++++-------------------
>  3 files changed, 100 insertions(+), 60 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 9b91ca4..a062f0b 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -303,7 +303,7 @@ static inline void scan_unevictable_unregister_node(struct node *node)
>  }
>  #endif
>  
> -extern int kswapd_run(int nid);
> +extern int kswapd_run(int nid, int id);

"id" is bad name. there is no information. please use memcg-id or so on.


>  extern void kswapd_stop(int nid);
>  
>  #ifdef CONFIG_MMU
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 321fc74..36b4eed 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -462,7 +462,7 @@ int online_pages(unsigned long pfn, unsigned long nr_pages)
>  	setup_per_zone_wmarks();
>  	calculate_zone_inactive_ratio(zone);
>  	if (onlined_pages) {
> -		kswapd_run(zone_to_nid(zone));
> +		kswapd_run(zone_to_nid(zone), 0);
>  		node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
>  	}
>  
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 7aba681..63c557e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2241,6 +2241,8 @@ static bool pgdat_balanced(pg_data_t *pgdat, unsigned long balanced_pages,
>  	return balanced_pages > (present_pages >> 2);
>  }
>  
> +#define is_global_kswapd(kswapd_p) ((kswapd_p)->kswapd_pgdat)

please use inline function.



> +
>  /* is kswapd sleeping prematurely? */
>  static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
>  					int classzone_idx)
> @@ -2583,40 +2585,46 @@ static void kswapd_try_to_sleep(struct kswapd *kswapd_p, int order,
>  
>  	prepare_to_wait(wait_h, &wait, TASK_INTERRUPTIBLE);
>  
> -	/* Try to sleep for a short interval */
> -	if (!sleeping_prematurely(pgdat, order, remaining, classzone_idx)) {
> -		remaining = schedule_timeout(HZ/10);
> -		finish_wait(wait_h, &wait);
> -		prepare_to_wait(wait_h, &wait, TASK_INTERRUPTIBLE);
> -	}
> -
> -	/*
> -	 * After a short sleep, check if it was a premature sleep. If not, then
> -	 * go fully to sleep until explicitly woken up.
> -	 */
> -	if (!sleeping_prematurely(pgdat, order, remaining, classzone_idx)) {
> -		trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
> +	if (is_global_kswapd(kswapd_p)) {

bad indentation. :-/
please don't increase coding mess.

	if (!is_global_kswapd(kswapd_p)) {
		kswapd_try_to_sleep_memcg();
		return;
	}

is simpler.


> +		/* Try to sleep for a short interval */
> +		if (!sleeping_prematurely(pgdat, order,
> +				remaining, classzone_idx)) {
> +			remaining = schedule_timeout(HZ/10);
> +			finish_wait(wait_h, &wait);
> +			prepare_to_wait(wait_h, &wait, TASK_INTERRUPTIBLE);
> +		}
>  
>  		/*
> -		 * vmstat counters are not perfectly accurate and the estimated
> -		 * value for counters such as NR_FREE_PAGES can deviate from the
> -		 * true value by nr_online_cpus * threshold. To avoid the zone
> -		 * watermarks being breached while under pressure, we reduce the
> -		 * per-cpu vmstat threshold while kswapd is awake and restore
> -		 * them before going back to sleep.
> +		 * After a short sleep, check if it was a premature sleep.
> +		 * If not, then go fully to sleep until explicitly woken up.
>  		 */
> -		set_pgdat_percpu_threshold(pgdat, calculate_normal_threshold);
> -		schedule();
> -		set_pgdat_percpu_threshold(pgdat, calculate_pressure_threshold);
> +		if (!sleeping_prematurely(pgdat, order,
> +					remaining, classzone_idx)) {
> +			trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
> +			set_pgdat_percpu_threshold(pgdat,
> +					calculate_normal_threshold);
> +			schedule();
> +			set_pgdat_percpu_threshold(pgdat,
> +					calculate_pressure_threshold);
> +		} else {
> +			if (remaining)
> +				count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
> +			else
> +				count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
> +		}
>  	} else {
> -		if (remaining)
> -			count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
> -		else
> -			count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
> +		/* For now, we just check the remaining works.*/
> +		if (mem_cgroup_kswapd_can_sleep())
> +			schedule();
>  	}
>  	finish_wait(wait_h, &wait);


>  }
>  
> +static unsigned long shrink_mem_cgroup(struct mem_cgroup *mem_cont, int order)
> +{
> +	return 0;
> +}
> +
>  /*
>   * The background pageout daemon, started as a kernel thread
>   * from the init process.
> @@ -2636,6 +2644,7 @@ int kswapd(void *p)
>  	int classzone_idx;
>  	struct kswapd *kswapd_p = (struct kswapd *)p;
>  	pg_data_t *pgdat = kswapd_p->kswapd_pgdat;
> +	struct mem_cgroup *mem;
>  	struct task_struct *tsk = current;
>  
>  	struct reclaim_state reclaim_state = {
> @@ -2645,9 +2654,11 @@ int kswapd(void *p)
>  
>  	lockdep_set_current_reclaim_state(GFP_KERNEL);
>  
> -	cpumask = cpumask_of_node(pgdat->node_id);
> -	if (!cpumask_empty(cpumask))
> -		set_cpus_allowed_ptr(tsk, cpumask);
> +	if (is_global_kswapd(kswapd_p)) {
> +		cpumask = cpumask_of_node(pgdat->node_id);
> +		if (!cpumask_empty(cpumask))
> +			set_cpus_allowed_ptr(tsk, cpumask);
> +	}
>  	current->reclaim_state = &reclaim_state;
>  
>  	/*
> @@ -2662,7 +2673,10 @@ int kswapd(void *p)
>  	 * us from recursively trying to free more memory as we're
>  	 * trying to free the first piece of memory in the first place).
>  	 */
> -	tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
> +	if (is_global_kswapd(kswapd_p))
> +		tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
> +	else
> +		tsk->flags |= PF_SWAPWRITE | PF_KSWAPD;
>  	set_freezable();
>  
>  	order = 0;
> @@ -2672,36 +2686,48 @@ int kswapd(void *p)
>  		int new_classzone_idx;
>  		int ret;
>  
> -		new_order = pgdat->kswapd_max_order;
> -		new_classzone_idx = pgdat->classzone_idx;
> -		pgdat->kswapd_max_order = 0;
> -		pgdat->classzone_idx = MAX_NR_ZONES - 1;
> -		if (order < new_order || classzone_idx > new_classzone_idx) {
> -			/*
> -			 * Don't sleep if someone wants a larger 'order'
> -			 * allocation or has tigher zone constraints
> -			 */
> -			order = new_order;
> -			classzone_idx = new_classzone_idx;
> -		} else {
> -			kswapd_try_to_sleep(kswapd_p, order, classzone_idx);
> -			order = pgdat->kswapd_max_order;
> -			classzone_idx = pgdat->classzone_idx;
> +		if (is_global_kswapd(kswapd_p)) {
> +			new_order = pgdat->kswapd_max_order;
> +			new_classzone_idx = pgdat->classzone_idx;
>  			pgdat->kswapd_max_order = 0;
>  			pgdat->classzone_idx = MAX_NR_ZONES - 1;
> -		}
> +			if (order < new_order ||
> +					classzone_idx > new_classzone_idx) {
> +				/*
> +				 * Don't sleep if someone wants a larger 'order'
> +				 * allocation or has tigher zone constraints
> +				 */
> +				order = new_order;
> +				classzone_idx = new_classzone_idx;
> +			} else {
> +				kswapd_try_to_sleep(kswapd_p, order,
> +						    classzone_idx);
> +				order = pgdat->kswapd_max_order;
> +				classzone_idx = pgdat->classzone_idx;
> +				pgdat->kswapd_max_order = 0;
> +				pgdat->classzone_idx = MAX_NR_ZONES - 1;

-ETOODEEPNEST.


> +			}
> +		} else
> +			kswapd_try_to_sleep(kswapd_p, order, classzone_idx);
>  
>  		ret = try_to_freeze();
>  		if (kthread_should_stop())
>  			break;
>  
> +		if (ret)
> +			continue;
>  		/*
>  		 * We can speed up thawing tasks if we don't call balance_pgdat
>  		 * after returning from the refrigerator
>  		 */
> -		if (!ret) {
> +		if (is_global_kswapd(kswapd_p)) {
>  			trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
>  			order = balance_pgdat(pgdat, order, &classzone_idx);
> +		} else {
> +			mem = mem_cgroup_get_shrink_target();
> +			if (mem)
> +				shrink_mem_cgroup(mem, order);
> +			mem_cgroup_put_shrink_target(mem);
>  		}



>  	}
>  	return 0;
> @@ -2845,30 +2871,44 @@ static int __devinit cpu_callback(struct notifier_block *nfb,
>   * This kswapd start function will be called by init and node-hot-add.
>   * On node-hot-add, kswapd will moved to proper cpus if cpus are hot-added.
>   */
> -int kswapd_run(int nid)
> +int kswapd_run(int nid, int memcgid)
>  {
> -	pg_data_t *pgdat = NODE_DATA(nid);
>  	struct task_struct *kswapd_tsk;
> +	pg_data_t *pgdat = NULL;
>  	struct kswapd *kswapd_p;
> +	static char name[TASK_COMM_LEN];
>  	int ret = 0;
>  
> -	if (pgdat->kswapd)
> -		return 0;
> +	if (!memcgid) {
> +		pgdat = NODE_DATA(nid);
> +		if (pgdat->kswapd)
> +			return ret;
> +	}
>  
>  	kswapd_p = kzalloc(sizeof(struct kswapd), GFP_KERNEL);
>  	if (!kswapd_p)
>  		return -ENOMEM;
>  
> -	pgdat->kswapd = kswapd_p;
> -	kswapd_p->kswapd_wait = &pgdat->kswapd_wait;
> -	kswapd_p->kswapd_pgdat = pgdat;
> +	if (!memcgid) {
> +		pgdat->kswapd = kswapd_p;
> +		kswapd_p->kswapd_wait = &pgdat->kswapd_wait;
> +		kswapd_p->kswapd_pgdat = pgdat;
> +		snprintf(name, TASK_COMM_LEN, "kswapd_%d", nid);
> +	} else {
> +		kswapd_p->kswapd_wait = mem_cgroup_kswapd_waitq();
> +		snprintf(name, TASK_COMM_LEN, "memcg_%d", memcgid);
> +	}
>  
> -	kswapd_tsk = kthread_run(kswapd, kswapd_p, "kswapd%d", nid);

You seems to change kswapd name slightly.



> +	kswapd_tsk = kthread_run(kswapd, kswapd_p, name);
>  	if (IS_ERR(kswapd_tsk)) {
>  		/* failure at boot is fatal */
>  		BUG_ON(system_state == SYSTEM_BOOTING);
> -		printk("Failed to start kswapd on node %d\n",nid);
> -		pgdat->kswapd = NULL;
> +		if (!memcgid) {
> +			printk(KERN_ERR "Failed to start kswapd on node %d\n",
> +								nid);
> +			pgdat->kswapd = NULL;
> +		} else
> +			printk(KERN_ERR "Failed to start kswapd on memcg\n");

Why don't you show memcg-id here?


>  		kfree(kswapd_p);
>  		ret = -1;
>  	} else
> @@ -2899,7 +2939,7 @@ static int __init kswapd_init(void)
>  
>  	swap_setup();
>  	for_each_node_state(nid, N_HIGH_MEMORY)
> - 		kswapd_run(nid);
> +		kswapd_run(nid, 0);
>  	hotcpu_notifier(cpu_callback, 0);
>  	return 0;
>  }
> -- 
> 1.7.3.1
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
