Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 182F86B0069
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 02:08:15 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id d134so87228058pfd.0
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 23:08:15 -0800 (PST)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTP id h1si5974023plh.3.2017.01.19.23.08.12
        for <linux-mm@kvack.org>;
        Thu, 19 Jan 2017 23:08:14 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <alpine.DEB.2.10.1701181347320.142399@chino.kir.corp.google.com> <279f10c2-3eaa-c641-094f-3070db67d84f@suse.cz> <alpine.DEB.2.10.1701191454470.2381@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1701191454470.2381@chino.kir.corp.google.com>
Subject: Re: [patch] mm, oom: header nodemask is NULL when cpusets are disabled
Date: Fri, 20 Jan 2017 15:07:55 +0800
Message-ID: <001801d272eb$ece5f460$c6b1dd20$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'David Rientjes' <rientjes@google.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Vlastimil Babka' <vbabka@suse.cz>
Cc: 'Michal Hocko' <mhocko@kernel.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>

On Friday, January 20, 2017 6:58 AM David Rientjes wrote: 
> 
> Commit 82e7d3abec86 ("oom: print nodemask in the oom report") implicitly
> sets the allocation nodemask to cpuset_current_mems_allowed when there is
> no effective mempolicy.  cpuset_current_mems_allowed is only effective
> when cpusets are enabled, which is also printed by dump_header(), so
> setting the nodemask to cpuset_current_mems_allowed is redundant and
> prevents debugging issues where ac->nodemask is not set properly in the
> page allocator.
> 
> This provides better debugging output since
> cpuset_print_current_mems_allowed() is already provided.
> 
> Suggested-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  mm/oom_kill.c | 16 +++++++++-------
>  1 file changed, 9 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -403,12 +403,14 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
> 
>  static void dump_header(struct oom_control *oc, struct task_struct *p)
>  {
> -	nodemask_t *nm = (oc->nodemask) ? oc->nodemask : &cpuset_current_mems_allowed;
> -
> -	pr_warn("%s invoked oom-killer: gfp_mask=%#x(%pGg), nodemask=%*pbl, order=%d, oom_score_adj=%hd\n",
> -		current->comm, oc->gfp_mask, &oc->gfp_mask,
> -		nodemask_pr_args(nm), oc->order,
> -		current->signal->oom_score_adj);
> +	pr_warn("%s invoked oom-killer: gfp_mask=%#x(%pGg), nodemask=",
> +		current->comm, oc->gfp_mask, &oc->gfp_mask);
> +	if (oc->nodemask)
> +		pr_cont("%*pbl", nodemask_pr_args(oc->nodemask));
> +	else
> +		pr_cont("(null)\n");

Nit: no newline needed.

> +	pr_cont(",  order=%d, oom_score_adj=%hd\n",
> +		oc->order, current->signal->oom_score_adj);
>  	if (!IS_ENABLED(CONFIG_COMPACTION) && oc->order)
>  		pr_warn("COMPACTION is disabled!!!\n");
> 
> @@ -417,7 +419,7 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
>  	if (oc->memcg)
>  		mem_cgroup_print_oom_info(oc->memcg, p);
>  	else
> -		show_mem(SHOW_MEM_FILTER_NODES, nm);
> +		show_mem(SHOW_MEM_FILTER_NODES, oc->nodemask);
>  	if (sysctl_oom_dump_tasks)
>  		dump_tasks(oc->memcg, oc->nodemask);
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
