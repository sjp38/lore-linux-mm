Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 14E59900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 21:47:10 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E27503EE0B5
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 10:47:07 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C6D9A45DE54
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 10:47:07 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B1D5045DE55
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 10:47:07 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A3A94E38003
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 10:47:07 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 637F0E08001
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 10:47:07 +0900 (JST)
Date: Fri, 15 Apr 2011 10:40:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V4 09/10] Add API to export per-memcg kswapd pid.
Message-Id: <20110415104029.93272e86.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1302821669-29862-10-git-send-email-yinghan@google.com>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
	<1302821669-29862-10-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Thu, 14 Apr 2011 15:54:28 -0700
Ying Han <yinghan@google.com> wrote:

> This add the API which exports per-memcg kswapd thread pid. The kswapd
> thread is named as "memcg_" + css_id, and the pid can be used to put
> kswapd thread into cpu cgroup later.
> 
> $ mkdir /dev/cgroup/memory/A
> $ cat /dev/cgroup/memory/A/memory.kswapd_pid
> memcg_null 0
> 
> $ echo 500m >/dev/cgroup/memory/A/memory.limit_in_bytes
> $ echo 50m >/dev/cgroup/memory/A/memory.high_wmark_distance
> $ ps -ef | grep memcg
> root      6727     2  0 14:32 ?        00:00:00 [memcg_3]
> root      6729  6044  0 14:32 ttyS0    00:00:00 grep memcg
> 
> $ cat memory.kswapd_pid
> memcg_3 6727
> 
> changelog v4..v3
> 1. Add the API based on KAMAZAWA's request on patch v3.
> 
> Signed-off-by: Ying Han <yinghan@google.com>

Thank you.

> ---
>  include/linux/swap.h |    2 ++
>  mm/memcontrol.c      |   33 +++++++++++++++++++++++++++++++++
>  mm/vmscan.c          |    2 +-
>  3 files changed, 36 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 319b800..2d3e21a 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -34,6 +34,8 @@ struct kswapd {
>  };
>  
>  int kswapd(void *p);
> +extern spinlock_t kswapds_spinlock;
> +
>  /*
>   * MAX_SWAPFILES defines the maximum number of swaptypes: things which can
>   * be swapped to.  The swap type and the offset into that swap type are
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 1b23ff4..606b680 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4493,6 +4493,35 @@ static int mem_cgroup_wmark_read(struct cgroup *cgrp,
>  	return 0;
>  }
>  
> +static int mem_cgroup_kswapd_pid_read(struct cgroup *cgrp,
> +	struct cftype *cft,  struct cgroup_map_cb *cb)
> +{
> +	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
> +	struct task_struct *kswapd_thr = NULL;
> +	struct kswapd *kswapd_p = NULL;
> +	wait_queue_head_t *wait;
> +	char name[TASK_COMM_LEN];
> +	pid_t pid = 0;
> +

I think '0' is ... not very good. This '0' implies there is no kswapd.
But 0 is root pid. I have no idea. Do you have no concern ?

Otherewise, the interface seems good.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>




> +	sprintf(name, "memcg_null");
> +
> +	spin_lock(&kswapds_spinlock);
> +	wait = mem_cgroup_kswapd_wait(mem);
> +	if (wait) {
> +		kswapd_p = container_of(wait, struct kswapd, kswapd_wait);
> +		kswapd_thr = kswapd_p->kswapd_task;
> +		if (kswapd_thr) {
> +			get_task_comm(name, kswapd_thr);
> +			pid = kswapd_thr->pid;
> +		}
> +	}
> +	spin_unlock(&kswapds_spinlock);
> +
> +	cb->fill(cb, name, pid);
> +
> +	return 0;
> +}
> +
>  static int mem_cgroup_oom_control_read(struct cgroup *cgrp,
>  	struct cftype *cft,  struct cgroup_map_cb *cb)
>  {
> @@ -4610,6 +4639,10 @@ static struct cftype mem_cgroup_files[] = {
>  		.name = "reclaim_wmarks",
>  		.read_map = mem_cgroup_wmark_read,
>  	},
> +	{
> +		.name = "kswapd_pid",
> +		.read_map = mem_cgroup_kswapd_pid_read,
> +	},
>  };
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c081112..df4e5dd 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2249,7 +2249,7 @@ static bool pgdat_balanced(pg_data_t *pgdat, unsigned long balanced_pages,
>  	return balanced_pages > (present_pages >> 2);
>  }
>  
> -static DEFINE_SPINLOCK(kswapds_spinlock);
> +DEFINE_SPINLOCK(kswapds_spinlock);
>  #define is_node_kswapd(kswapd_p) (!(kswapd_p)->kswapd_mem)
>  
>  /* is kswapd sleeping prematurely? */
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
