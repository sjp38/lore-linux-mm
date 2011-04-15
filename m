Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 82CD1900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 20:46:47 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 7C2223EE0C8
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 09:46:44 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 59BC945DE62
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 09:46:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3985745DE56
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 09:46:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 26098E38001
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 09:46:44 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DC50AE08004
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 09:46:43 +0900 (JST)
Date: Fri, 15 Apr 2011 09:40:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V4 05/10] Implement the select_victim_node within memcg.
Message-Id: <20110415094007.9cfc4a7d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1302821669-29862-6-git-send-email-yinghan@google.com>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
	<1302821669-29862-6-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Thu, 14 Apr 2011 15:54:24 -0700
Ying Han <yinghan@google.com> wrote:

> This add the mechanism for background reclaim which we remember the
> last scanned node and always starting from the next one each time.
> The simple round-robin fasion provide the fairness between nodes for
> each memcg.
> 
> changelog v4..v3:
> 1. split off from the per-memcg background reclaim patch.
> 
> Signed-off-by: Ying Han <yinghan@google.com>

Yeah, looks nice. Thank you for splitting.


> ---
>  include/linux/memcontrol.h |    3 +++
>  mm/memcontrol.c            |   40 ++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 43 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index f7ffd1f..d4ff7f2 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -88,6 +88,9 @@ extern int mem_cgroup_init_kswapd(struct mem_cgroup *mem,
>  				  struct kswapd *kswapd_p);
>  extern void mem_cgroup_clear_kswapd(struct mem_cgroup *mem);
>  extern wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup *mem);
> +extern int mem_cgroup_last_scanned_node(struct mem_cgroup *mem);
> +extern int mem_cgroup_select_victim_node(struct mem_cgroup *mem,
> +					const nodemask_t *nodes);
>  
>  static inline
>  int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c4e1904..e22351a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -279,6 +279,11 @@ struct mem_cgroup {
>  	u64 high_wmark_distance;
>  	u64 low_wmark_distance;
>  
> +	/* While doing per cgroup background reclaim, we cache the
> +	 * last node we reclaimed from
> +	 */
> +	int last_scanned_node;
> +
>  	wait_queue_head_t *kswapd_wait;
>  };
>  
> @@ -1536,6 +1541,32 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>  }
>  
>  /*
> + * Visit the first node after the last_scanned_node of @mem and use that to
> + * reclaim free pages from.
> + */
> +int
> +mem_cgroup_select_victim_node(struct mem_cgroup *mem, const nodemask_t *nodes)
> +{
> +	int next_nid;
> +	int last_scanned;
> +
> +	last_scanned = mem->last_scanned_node;
> +
> +	/* Initial stage and start from node0 */
> +	if (last_scanned == -1)
> +		next_nid = 0;
> +	else
> +		next_nid = next_node(last_scanned, *nodes);
> +

IIUC, mem->last_scanned_node should be initialized to MAX_NUMNODES.
Then, we can remove above check.

Thanks,
-Kame

> +	if (next_nid == MAX_NUMNODES)
> +		next_nid = first_node(*nodes);
> +
> +	mem->last_scanned_node = next_nid;
> +
> +	return next_nid;
> +}
> +
> +/*
>   * Check OOM-Killer is already running under our hierarchy.
>   * If someone is running, return false.
>   */
> @@ -4693,6 +4724,14 @@ wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup *mem)
>  	return mem->kswapd_wait;
>  }
>  
> +int mem_cgroup_last_scanned_node(struct mem_cgroup *mem)
> +{
> +	if (!mem)
> +		return -1;
> +
> +	return mem->last_scanned_node;
> +}
> +
>  static int mem_cgroup_soft_limit_tree_init(void)
>  {
>  	struct mem_cgroup_tree_per_node *rtpn;
> @@ -4768,6 +4807,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  		res_counter_init(&mem->memsw, NULL);
>  	}
>  	mem->last_scanned_child = 0;
> +	mem->last_scanned_node = -1;
>  	INIT_LIST_HEAD(&mem->oom_notify);
>  
>  	if (parent)
> -- 
> 1.7.3.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
