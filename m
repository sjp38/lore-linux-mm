Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8A77A60044A
	for <linux-mm@kvack.org>; Sun,  3 Jan 2010 18:54:23 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o03NsK1X012073
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 4 Jan 2010 08:54:20 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1980F45DE51
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 08:54:20 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id ED27845DE50
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 08:54:19 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 543631DB8041
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 08:54:19 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E5DEC1DB803A
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 08:54:18 +0900 (JST)
Date: Mon, 4 Jan 2010 08:51:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Shared page accounting for memory cgroup
Message-Id: <20100104085108.eaa9c867.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091229182743.GB12533@balbir.in.ibm.com>
References: <20091229182743.GB12533@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 29 Dec 2009 23:57:43 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Hi, Everyone,
> 
> I've been working on heuristics for shared page accounting for the
> memory cgroup. I've tested the patches by creating multiple cgroups
> and running programs that share memory and observed the output.
> 
> Comments?

Hmm? Why we have to do this in the kernel ?

Thanks,
-Kame

> 
> 
> Add shared accounting to memcg
> 
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> Currently there is no accurate way of estimating how many pages are
> shared in a memory cgroup. The accurate way of accounting shared memory
> is to
> 
> 1. Either follow every page rmap and track number of users
> 2. Iterate through the pages and use _mapcount
> 
> We take an intermediate approach (suggested by Kamezawa), we sum up
> the file and anon rss of the mm's belonging to the cgroup and then
> subtract the values of anon rss and file mapped. This should give
> us a good estimate of the pages being shared.
> 
> The shared statistic is called memory.shared_usage_in_bytes and
> does not support hierarchical information, just the information
> for the current cgroup.
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> 
>  Documentation/cgroups/memory.txt |    6 +++++
>  mm/memcontrol.c                  |   43 ++++++++++++++++++++++++++++++++++++++
>  2 files changed, 49 insertions(+), 0 deletions(-)
> 
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index b871f25..c2c70c9 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -341,6 +341,12 @@ Note:
>    - a cgroup which uses hierarchy and it has child cgroup.
>    - a cgroup which uses hierarchy and not the root of hierarchy.
>  
> +5.4 shared_usage_in_bytes
> +  This data lists the number of shared bytes. The data provided
> +  provides an approximation based on the anon and file rss counts
> +  of all the mm's belonging to the cgroup. The sum above is subtracted
> +  from the count of rss and file mapped count maintained within the
> +  memory cgroup statistics (see section 5.2).
>  
>  6. Hierarchy support
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 488b644..8e296be 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3052,6 +3052,45 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
>  	return 0;
>  }
>  
> +static u64 mem_cgroup_shared_read(struct cgroup *cgrp, struct cftype *cft)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> +	struct cgroup_iter it;
> +	struct task_struct *tsk;
> +	u64 total_rss = 0, shared;
> +	struct mm_struct *mm;
> +	s64 val;
> +
> +	cgroup_iter_start(cgrp, &it);
> +	val = mem_cgroup_read_stat(&memcg->stat, MEM_CGROUP_STAT_RSS);
> +	val += mem_cgroup_read_stat(&memcg->stat, MEM_CGROUP_STAT_FILE_MAPPED);
> +	while ((tsk = cgroup_iter_next(cgrp, &it))) {
> +		if (!thread_group_leader(tsk))
> +			continue;
> +		mm = tsk->mm;
> +		/*
> +		 * We can't use get_task_mm(), since mmput() its counterpart
> +		 * can sleep. We know that mm can't become invalid since
> +		 * we hold the css_set_lock (see cgroup_iter_start()).
> +		 */
> +		if (tsk->flags & PF_KTHREAD || !mm)
> +			continue;
> +		total_rss += get_mm_counter(mm, file_rss) +
> +				get_mm_counter(mm, anon_rss);
> +	}
> +	cgroup_iter_end(cgrp, &it);
> +
> +	/*
> +	 * We need to tolerate negative values due to the difference in
> +	 * time of calculating total_rss and val, but the shared value
> +	 * converges to the correct value quite soon depending on the changing
> +	 * memory usage of the workload running in the memory cgroup.
> +	 */
> +	shared = total_rss - val;
> +	shared = max_t(s64, 0, shared);
> +	shared <<= PAGE_SHIFT;
> +	return shared;
> +}
>  
>  static struct cftype mem_cgroup_files[] = {
>  	{
> @@ -3101,6 +3140,10 @@ static struct cftype mem_cgroup_files[] = {
>  		.read_u64 = mem_cgroup_swappiness_read,
>  		.write_u64 = mem_cgroup_swappiness_write,
>  	},
> +	{
> +		.name = "shared_usage_in_bytes",
> +		.read_u64 = mem_cgroup_shared_read,
> +	},
>  };
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> 
> -- 
> 	Balbir
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
