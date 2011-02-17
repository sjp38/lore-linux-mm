Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0FBEE8D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 00:42:36 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id EFFB23EE0B5
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 14:42:08 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D35D345DD74
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 14:42:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F77745DE4E
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 14:42:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9313C1DB8038
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 14:42:08 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 509291DB803A
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 14:42:08 +0900 (JST)
Date: Thu, 17 Feb 2011 14:35:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v2 2/2] memcg: use native word page statistics counters
Message-Id: <20110217143557.bea67346.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1297920842-17299-3-git-send-email-gthelen@google.com>
References: <1297920842-17299-1-git-send-email-gthelen@google.com>
	<1297920842-17299-3-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 16 Feb 2011 21:34:02 -0800
Greg Thelen <gthelen@google.com> wrote:

> From: Johannes Weiner <hannes@cmpxchg.org>
> 
> The statistic counters are in units of pages, there is no reason to
> make them 64-bit wide on 32-bit machines.
> 
> Make them native words.  Since they are signed, this leaves 31 bit on
> 32-bit machines, which can represent roughly 8TB assuming a page size
> of 4k.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Greg Thelen <gthelen@google.com>


Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



> ---
> Changelog since -v1:
> * rebased to latest mmotm
> 
>  mm/memcontrol.c |   29 ++++++++++++++---------------
>  1 files changed, 14 insertions(+), 15 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index a11ff1e..1c2704a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -107,7 +107,7 @@ enum mem_cgroup_events_index {
>  };
>  
>  struct mem_cgroup_stat_cpu {
> -	s64 count[MEM_CGROUP_STAT_NSTATS];
> +	long count[MEM_CGROUP_STAT_NSTATS];
>  	unsigned long events[MEM_CGROUP_EVENTS_NSTATS];
>  };
>  
> @@ -546,11 +546,11 @@ mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_zone *mctz)
>   * common workload, threashold and synchonization as vmstat[] should be
>   * implemented.
>   */
> -static s64 mem_cgroup_read_stat(struct mem_cgroup *mem,
> -		enum mem_cgroup_stat_index idx)
> +static long mem_cgroup_read_stat(struct mem_cgroup *mem,
> +				 enum mem_cgroup_stat_index idx)
>  {
> +	long val = 0;
>  	int cpu;
> -	s64 val = 0;
>  
>  	get_online_cpus();
>  	for_each_online_cpu(cpu)
> @@ -564,9 +564,9 @@ static s64 mem_cgroup_read_stat(struct mem_cgroup *mem,
>  	return val;
>  }
>  
> -static s64 mem_cgroup_local_usage(struct mem_cgroup *mem)
> +static long mem_cgroup_local_usage(struct mem_cgroup *mem)
>  {
> -	s64 ret;
> +	long ret;
>  
>  	ret = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_RSS);
>  	ret += mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_CACHE);
> @@ -1761,7 +1761,7 @@ static void mem_cgroup_drain_pcp_counter(struct mem_cgroup *mem, int cpu)
>  
>  	spin_lock(&mem->pcp_counter_lock);
>  	for (i = 0; i < MEM_CGROUP_STAT_DATA; i++) {
> -		s64 x = per_cpu(mem->stat->count[i], cpu);
> +		long x = per_cpu(mem->stat->count[i], cpu);
>  
>  		per_cpu(mem->stat->count[i], cpu) = 0;
>  		mem->nocpu_base.count[i] += x;
> @@ -3473,13 +3473,13 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
>  }
>  
>  
> -static u64 mem_cgroup_get_recursive_idx_stat(struct mem_cgroup *mem,
> -				enum mem_cgroup_stat_index idx)
> +static unsigned long mem_cgroup_recursive_stat(struct mem_cgroup *mem,
> +					       enum mem_cgroup_stat_index idx)
>  {
>  	struct mem_cgroup *iter;
> -	s64 val = 0;
> +	long val = 0;
>  
> -	/* each per cpu's value can be minus.Then, use s64 */
> +	/* Per-cpu values can be negative, use a signed accumulator */
>  	for_each_mem_cgroup_tree(iter, mem)
>  		val += mem_cgroup_read_stat(iter, idx);
>  
> @@ -3499,12 +3499,11 @@ static inline u64 mem_cgroup_usage(struct mem_cgroup *mem, bool swap)
>  			return res_counter_read_u64(&mem->memsw, RES_USAGE);
>  	}
>  
> -	val = mem_cgroup_get_recursive_idx_stat(mem, MEM_CGROUP_STAT_CACHE);
> -	val += mem_cgroup_get_recursive_idx_stat(mem, MEM_CGROUP_STAT_RSS);
> +	val = mem_cgroup_recursive_stat(mem, MEM_CGROUP_STAT_CACHE);
> +	val += mem_cgroup_recursive_stat(mem, MEM_CGROUP_STAT_RSS);
>  
>  	if (swap)
> -		val += mem_cgroup_get_recursive_idx_stat(mem,
> -				MEM_CGROUP_STAT_SWAPOUT);
> +		val += mem_cgroup_recursive_stat(mem, MEM_CGROUP_STAT_SWAPOUT);
>  
>  	return val << PAGE_SHIFT;
>  }
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
