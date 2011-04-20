Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C2B418D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 21:22:17 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 685933EE0C3
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 10:22:14 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B2E545DE8A
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 10:22:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1467645DE9F
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 10:22:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E790EE18004
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 10:22:13 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9AD591DB8038
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 10:22:13 +0900 (JST)
Date: Wed, 20 Apr 2011 10:15:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V6 09/10] Add API to export per-memcg kswapd pid.
Message-Id: <20110420101533.d19622ce.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1303185466-2532-10-git-send-email-yinghan@google.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<1303185466-2532-10-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Mon, 18 Apr 2011 20:57:45 -0700
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
> changelog v6..v5
> 1. Remove the legacy spinlock which has been removed from previous post.
> 
> changelog v5..v4
> 1. Initialize the memcg-kswapd pid to -1 instead of 0.
> 2. Remove the kswapds_spinlock.
> 
> changelog v4..v3
> 1. Add the API based on KAMAZAWA's request on patch v3.
> 
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Ying Han <yinghan@google.com>

I'm very sorry but please drop this. There is a discussion that
we should use thread pool rather than one-thread-per-one-memcg.
If so, we need to remove this interface and we'll see regression.

I think we need some control knobs as priority/share in thread pools finally...
(So, I want to use cpu cgroup.) If not, there will be unfair utilization of
cpu/thread. But for now, it seems adding this is too early.


> ---
>  mm/memcontrol.c |   31 +++++++++++++++++++++++++++++++
>  1 files changed, 31 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index d5b284c..0b108b9 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4533,6 +4533,33 @@ static int mem_cgroup_wmark_read(struct cgroup *cgrp,
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
> +	pid_t pid = -1;
> +
> +	sprintf(name, "memcg_null");
> +
> +	wait = mem_cgroup_kswapd_wait(mem);
> +	if (wait) {
> +		kswapd_p = container_of(wait, struct kswapd, kswapd_wait);
> +		kswapd_thr = kswapd_p->kswapd_task;
> +		if (kswapd_thr) {
> +			get_task_comm(name, kswapd_thr);
> +			pid = kswapd_thr->pid;
> +		}
> +	}
> +
> +	cb->fill(cb, name, pid);
> +
> +	return 0;
> +}
> +
>  static int mem_cgroup_oom_control_read(struct cgroup *cgrp,
>  	struct cftype *cft,  struct cgroup_map_cb *cb)
>  {
> @@ -4650,6 +4677,10 @@ static struct cftype mem_cgroup_files[] = {
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
> -- 
> 1.7.3.1
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
