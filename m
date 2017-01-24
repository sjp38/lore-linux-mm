Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BFAFD6B0033
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 05:12:59 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id p192so25198138wme.1
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 02:12:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g130si17678378wma.147.2017.01.24.02.12.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Jan 2017 02:12:58 -0800 (PST)
Date: Tue, 24 Jan 2017 11:12:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, oom: header nodemask is NULL when cpusets are
 disabled
Message-ID: <20170124101255.GC6867@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1701181347320.142399@chino.kir.corp.google.com>
 <279f10c2-3eaa-c641-094f-3070db67d84f@suse.cz>
 <alpine.DEB.2.10.1701191454470.2381@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1701191454470.2381@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 19-01-17 14:57:36, David Rientjes wrote:
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

With the removed \n addressed in the follow up fix
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
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

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
