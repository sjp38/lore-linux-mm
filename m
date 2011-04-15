Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0B9D4900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 20:41:31 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0287B3EE0C0
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 09:41:28 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DC37745DE56
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 09:41:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C3AF445DE54
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 09:41:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B3494E08003
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 09:41:27 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 72995E38001
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 09:41:27 +0900 (JST)
Date: Fri, 15 Apr 2011 09:34:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V4 04/10] Infrastructure to support per-memcg reclaim.
Message-Id: <20110415093451.1f701df8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1302821669-29862-5-git-send-email-yinghan@google.com>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
	<1302821669-29862-5-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Thu, 14 Apr 2011 15:54:23 -0700
Ying Han <yinghan@google.com> wrote:

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
> changelog v4..v3:
> 1. fix up the kswapd_run and kswapd_stop for online_pages() and offline_pages.
> 2. drop the PF_MEMALLOC flag for memcg kswapd for now per KAMAZAWA's request.
> 
> changelog v3..v2:
> 1. split off from the initial patch which includes all changes of the following
> three patches.
> 
> Signed-off-by: Ying Han <yinghan@google.com>


> ---
>  include/linux/memcontrol.h |    5 ++
>  include/linux/swap.h       |    5 +-
>  mm/memcontrol.c            |   29 ++++++++
>  mm/memory_hotplug.c        |    4 +-
>  mm/vmscan.c                |  157 ++++++++++++++++++++++++++++++--------------
>  5 files changed, 147 insertions(+), 53 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 3ece36d..f7ffd1f 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -24,6 +24,7 @@ struct mem_cgroup;
>  struct page_cgroup;
>  struct page;
>  struct mm_struct;
> +struct kswapd;
>  
>  /* Stats that can be updated by kernel. */
>  enum mem_cgroup_page_stat_item {
> @@ -83,6 +84,10 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
>  extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
>  extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
>  extern int mem_cgroup_watermark_ok(struct mem_cgroup *mem, int charge_flags);
> +extern int mem_cgroup_init_kswapd(struct mem_cgroup *mem,
> +				  struct kswapd *kswapd_p);
> +extern void mem_cgroup_clear_kswapd(struct mem_cgroup *mem);
> +extern wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup *mem);
>  
>  static inline
>  int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index f43d406..17e0511 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -30,6 +30,7 @@ struct kswapd {
>  	struct task_struct *kswapd_task;
>  	wait_queue_head_t kswapd_wait;
>  	pg_data_t *kswapd_pgdat;
> +	struct mem_cgroup *kswapd_mem;
>  };
>  
>  int kswapd(void *p);
> @@ -303,8 +304,8 @@ static inline void scan_unevictable_unregister_node(struct node *node)
>  }
>  #endif
>  
> -extern int kswapd_run(int nid);
> -extern void kswapd_stop(int nid);
> +extern int kswapd_run(int nid, struct mem_cgroup *mem);
> +extern void kswapd_stop(int nid, struct mem_cgroup *mem);
>  
>  #ifdef CONFIG_MMU
>  /* linux/mm/shmem.c */
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 685645c..c4e1904 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -278,6 +278,8 @@ struct mem_cgroup {
>  	 */
>  	u64 high_wmark_distance;
>  	u64 low_wmark_distance;
> +
> +	wait_queue_head_t *kswapd_wait;
>  };

I think mem_cgroup can include 'struct kswapd' itself and don't need to
alloc it dynamically.

Other parts seems ok to me.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
