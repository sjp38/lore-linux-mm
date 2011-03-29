Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 76ACE8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 21:29:13 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E79373EE0C3
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 10:29:10 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CC69145DE95
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 10:29:10 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A24B345DE92
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 10:29:10 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 93F0AE08007
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 10:29:10 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 55FB7E08005
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 10:29:10 +0900 (JST)
Date: Tue, 29 Mar 2011 10:22:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V2 2/2] add stats to monitor soft_limit reclaim
Message-Id: <20110329102242.d2f6d583.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1301356270-26859-3-git-send-email-yinghan@google.com>
References: <1301356270-26859-1-git-send-email-yinghan@google.com>
	<1301356270-26859-3-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Mon, 28 Mar 2011 16:51:10 -0700
Ying Han <yinghan@google.com> wrote:

> The stat is added:
> 
> /dev/cgroup/*/memory.stat
> soft_steal:        - # of pages reclaimed from soft_limit hierarchical reclaim
> total_soft_steal:  - # sum of all children's "soft_steal"
> 
> Change log v2...v1
> 1. removed the counting on number of skips on shrink_zone. This is due to the
> change on the previous patch.
> 
> Signed-off-by: Ying Han <yinghan@google.com>

Hmm...


> ---
>  Documentation/cgroups/memory.txt |    2 ++
>  include/linux/memcontrol.h       |    5 +++++
>  mm/memcontrol.c                  |   14 ++++++++++++++
>  3 files changed, 21 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index b6ed61c..dcda6c5 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -385,6 +385,7 @@ mapped_file	- # of bytes of mapped file (includes tmpfs/shmem)
>  pgpgin		- # of pages paged in (equivalent to # of charging events).
>  pgpgout		- # of pages paged out (equivalent to # of uncharging events).
>  swap		- # of bytes of swap usage
> +soft_steal	- # of pages reclaimed from global hierarchical reclaim
>  inactive_anon	- # of bytes of anonymous memory and swap cache memory on
>  		LRU list.
>  active_anon	- # of bytes of anonymous and swap cache memory on active
> @@ -406,6 +407,7 @@ total_mapped_file	- sum of all children's "cache"
>  total_pgpgin		- sum of all children's "pgpgin"
>  total_pgpgout		- sum of all children's "pgpgout"
>  total_swap		- sum of all children's "swap"
> +total_soft_steal	- sum of all children's "soft_steal"
>  total_inactive_anon	- sum of all children's "inactive_anon"
>  total_active_anon	- sum of all children's "active_anon"
>  total_inactive_file	- sum of all children's "inactive_file"
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 01281ac..151ab40 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -115,6 +115,7 @@ struct zone_reclaim_stat*
>  mem_cgroup_get_reclaim_stat_from_page(struct page *page);
>  extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
>  					struct task_struct *p);
> +void mem_cgroup_soft_steal(struct mem_cgroup *memcg, int val);
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
>  extern int do_swap_account;
> @@ -356,6 +357,10 @@ static inline void mem_cgroup_split_huge_fixup(struct page *head,
>  {
>  }
>  
> +static inline void mem_cgroup_soft_steal(struct mem_cgroup *memcg,
> +					 int val)
> +{
> +}
>  #endif /* CONFIG_CGROUP_MEM_CONT */
>  
>  #if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 67fff28..5e4aa41 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -94,6 +94,8 @@ enum mem_cgroup_events_index {
>  	MEM_CGROUP_EVENTS_PGPGIN,	/* # of pages paged in */
>  	MEM_CGROUP_EVENTS_PGPGOUT,	/* # of pages paged out */
>  	MEM_CGROUP_EVENTS_COUNT,	/* # of pages paged in/out */
> +	MEM_CGROUP_EVENTS_SOFT_STEAL,	/* # of pages reclaimed from */
> +					/* oft reclaim               */
>  	MEM_CGROUP_EVENTS_NSTATS,
>  };
>  /*
> @@ -624,6 +626,11 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
>  	preempt_enable();
>  }
>  
> +void mem_cgroup_soft_steal(struct mem_cgroup *mem, int val)
> +{
> +	this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_SOFT_STEAL], val);
> +}
> +
>  static unsigned long mem_cgroup_get_local_zonestat(struct mem_cgroup *mem,
>  					enum lru_list idx)
>  {
> @@ -3326,6 +3333,9 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>  						&nr_scanned);
>  		nr_reclaimed += reclaimed;
>  		*total_scanned += nr_scanned;
> +
> +		mem_cgroup_soft_steal(mz->mem, reclaimed);
> +

Here, you add "the number of reclaimed pages from the all descendants under me".
Could you move this to mem_cgroup_hierarchical_reclaim() ? Then, you can report
the correct stats even with hierarchy enabled.

Even if the value is recorded into hierarchy, total_steal will show total.

BTW, soft_scan and soft_total_scan aren't necessary ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
