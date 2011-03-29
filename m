Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A41B18D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 22:36:16 -0400 (EDT)
Date: Tue, 29 Mar 2011 11:32:59 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH V2 2/2] add stats to monitor soft_limit reclaim
Message-Id: <20110329113259.7e0111ee.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <1301356270-26859-3-git-send-email-yinghan@google.com>
References: <1301356270-26859-1-git-send-email-yinghan@google.com>
	<1301356270-26859-3-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

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
Do you use this function outside of memcontrol.c in future, right ?
I'm asking just for clarification, and I'm sorry if I miss some past discussions.

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
