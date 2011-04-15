Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1EEC9900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 21:18:32 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 163C13EE081
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 10:18:29 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id ECE7A45DE96
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 10:18:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D112345DE91
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 10:18:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C526CE08001
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 10:18:28 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8461EE08004
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 10:18:28 +0900 (JST)
Date: Fri, 15 Apr 2011 10:11:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V4 06/10] Per-memcg background reclaim.
Message-Id: <20110415101148.80cb6721.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1302821669-29862-7-git-send-email-yinghan@google.com>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
	<1302821669-29862-7-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Thu, 14 Apr 2011 15:54:25 -0700
Ying Han <yinghan@google.com> wrote:

> This is the main loop of per-memcg background reclaim which is implemented in
> function balance_mem_cgroup_pgdat().
> 
> The function performs a priority loop similar to global reclaim. During each
> iteration it invokes balance_pgdat_node() for all nodes on the system, which
> is another new function performs background reclaim per node. After reclaiming
> each node, it checks mem_cgroup_watermark_ok() and breaks the priority loop if
> it returns true.
> 
> changelog v4..v3:
> 1. split the select_victim_node and zone_unreclaimable to a seperate patches
> 2. remove the logic tries to do zone balancing.
> 
> changelog v3..v2:
> 1. change mz->all_unreclaimable to be boolean.
> 2. define ZONE_RECLAIMABLE_RATE macro shared by zone and per-memcg reclaim.
> 3. some more clean-up.
> 
> changelog v2..v1:
> 1. move the per-memcg per-zone clear_unreclaimable into uncharge stage.
> 2. shared the kswapd_run/kswapd_stop for per-memcg and global background
> reclaim.
> 3. name the per-memcg memcg as "memcg-id" (css->id). And the global kswapd
> keeps the same name.
> 4. fix a race on kswapd_stop while the per-memcg-per-zone info could be accessed
> after freeing.
> 5. add the fairness in zonelist where memcg remember the last zone reclaimed
> from.
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
>  mm/vmscan.c |  161 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 161 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 4deb9c8..b8345d2 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -47,6 +47,8 @@
>  
>  #include <linux/swapops.h>
>  
> +#include <linux/res_counter.h>
> +
>  #include "internal.h"
>  
>  #define CREATE_TRACE_POINTS
> @@ -111,6 +113,8 @@ struct scan_control {
>  	 * are scanned.
>  	 */
>  	nodemask_t	*nodemask;
> +
> +	int priority;
>  };
>  
>  #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
> @@ -2632,11 +2636,168 @@ static void kswapd_try_to_sleep(struct kswapd *kswapd_p, int order,
>  	finish_wait(wait_h, &wait);
>  }
>  
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +/*
> + * The function is used for per-memcg LRU. It scanns all the zones of the
> + * node and returns the nr_scanned and nr_reclaimed.
> + */
> +static void balance_pgdat_node(pg_data_t *pgdat, int order,
> +					struct scan_control *sc)
> +{
> +	int i;
> +	unsigned long total_scanned = 0;
> +	struct mem_cgroup *mem_cont = sc->mem_cgroup;
> +	int priority = sc->priority;
> +
> +	/*
> +	 * Now scan the zone in the dma->highmem direction, and we scan
> +	 * every zones for each node.
> +	 *
> +	 * We do this because the page allocator works in the opposite
> +	 * direction.  This prevents the page allocator from allocating
> +	 * pages behind kswapd's direction of progress, which would
> +	 * cause too much scanning of the lower zones.
> +	 */

I guess this comment is a cut-n-paste from global kswapd. It works when
alloc_page() stalls....hmm, I'd like to think whether dma->highmem direction
is good in this case.

As you know, memcg works against user's memory, memory should be in highmem zone.
Memcg-kswapd is not for memory-shortage, but for voluntary page dropping by
_user_.

If this memcg-kswapd drops pages from lower zones first, ah, ok, it's good for
the system because memcg's pages should be on higher zone if we have free memory.

So, I think the reason for dma->highmem is different from global kswapd.




> +	for (i = 0; i < pgdat->nr_zones; i++) {
> +		struct zone *zone = pgdat->node_zones + i;
> +
> +		if (!populated_zone(zone))
> +			continue;
> +
> +		sc->nr_scanned = 0;
> +		shrink_zone(priority, zone, sc);
> +		total_scanned += sc->nr_scanned;
> +
> +		/*
> +		 * If we've done a decent amount of scanning and
> +		 * the reclaim ratio is low, start doing writepage
> +		 * even in laptop mode
> +		 */
> +		if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
> +		    total_scanned > sc->nr_reclaimed + sc->nr_reclaimed / 2) {
> +			sc->may_writepage = 1;
> +		}
> +	}
> +
> +	sc->nr_scanned = total_scanned;
> +	return;
> +}
> +
> +/*
> + * Per cgroup background reclaim.
> + * TODO: Take off the order since memcg always do order 0
> + */
> +static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *mem_cont,
> +					      int order)
> +{
> +	int i, nid;
> +	int start_node;
> +	int priority;
> +	bool wmark_ok;
> +	int loop;
> +	pg_data_t *pgdat;
> +	nodemask_t do_nodes;
> +	unsigned long total_scanned;
> +	struct scan_control sc = {
> +		.gfp_mask = GFP_KERNEL,
> +		.may_unmap = 1,
> +		.may_swap = 1,
> +		.nr_to_reclaim = ULONG_MAX,
> +		.swappiness = vm_swappiness,
> +		.order = order,
> +		.mem_cgroup = mem_cont,
> +	};
> +
> +loop_again:
> +	do_nodes = NODE_MASK_NONE;
> +	sc.may_writepage = !laptop_mode;

I think may_writepage should start from '0' always. We're not sure
the system is in memory shortage...we just want to release memory
volunatary. write_page will add huge costs, I guess.

For exmaple,
	sc.may_writepage = !!loop
may be better for memcg.

BTW, you set nr_to_reclaim as ULONG_MAX here and doesn't modify it later.

I think you should add some logic to fix it to right value. 

For example, before calling shrink_zone(),

sc->nr_to_reclaim = min(SWAP_CLUSETR_MAX, memcg_usage_in_this_zone() / 100);  # 1% in this zone.

if we love 'fair pressure for each zone'.






> +	sc.nr_reclaimed = 0;
> +	total_scanned = 0;
> +
> +	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
> +		sc.priority = priority;
> +		wmark_ok = false;
> +		loop = 0;
> +
> +		/* The swap token gets in the way of swapout... */
> +		if (!priority)
> +			disable_swap_token();
> +
> +		if (priority == DEF_PRIORITY)
> +			do_nodes = node_states[N_ONLINE];
> +
> +		while (1) {
> +			nid = mem_cgroup_select_victim_node(mem_cont,
> +							&do_nodes);
> +
> +			/* Indicate we have cycled the nodelist once
> +			 * TODO: we might add MAX_RECLAIM_LOOP for preventing
> +			 * kswapd burning cpu cycles.
> +			 */
> +			if (loop == 0) {
> +				start_node = nid;
> +				loop++;
> +			} else if (nid == start_node)
> +				break;
> +
> +			pgdat = NODE_DATA(nid);
> +			balance_pgdat_node(pgdat, order, &sc);
> +			total_scanned += sc.nr_scanned;
> +
> +			/* Set the node which has at least
> +			 * one reclaimable zone
> +			 */
> +			for (i = pgdat->nr_zones - 1; i >= 0; i--) {
> +				struct zone *zone = pgdat->node_zones + i;
> +
> +				if (!populated_zone(zone))
> +					continue;

How about checking whether memcg has pages on this node ?

> +			}
> +			if (i < 0)
> +				node_clear(nid, do_nodes);
> +
> +			if (mem_cgroup_watermark_ok(mem_cont,
> +							CHARGE_WMARK_HIGH)) {
> +				wmark_ok = true;
> +				goto out;
> +			}
> +
> +			if (nodes_empty(do_nodes)) {
> +				wmark_ok = true;
> +				goto out;
> +			}
> +		}
> +
> +		/* All the nodes are unreclaimable, kswapd is done */
> +		if (nodes_empty(do_nodes)) {
> +			wmark_ok = true;
> +			goto out;
> +		}

Can this happen ?


> +
> +		if (total_scanned && priority < DEF_PRIORITY - 2)
> +			congestion_wait(WRITE, HZ/10);
> +
> +		if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX)
> +			break;
> +	}
> +out:
> +	if (!wmark_ok) {
> +		cond_resched();
> +
> +		try_to_freeze();
> +
> +		goto loop_again;
> +	}
> +
> +	return sc.nr_reclaimed;
> +}
> +#else
>  static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *mem_cont,
>  							int order)
>  {
>  	return 0;
>  }
> +#endif
>  


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
