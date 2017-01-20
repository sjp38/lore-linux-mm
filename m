Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B207A6B0033
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 04:00:17 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id d140so4159562wmd.4
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 01:00:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n6si2643900wmn.62.2017.01.20.01.00.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Jan 2017 01:00:16 -0800 (PST)
Subject: Re: [patch] mm, oom: header nodemask is NULL when cpusets are
 disabled
References: <alpine.DEB.2.10.1701181347320.142399@chino.kir.corp.google.com>
 <279f10c2-3eaa-c641-094f-3070db67d84f@suse.cz>
 <alpine.DEB.2.10.1701191454470.2381@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <e32b48f0-e345-2a44-9f95-0403eeb6a4fd@suse.cz>
Date: Fri, 20 Jan 2017 10:00:06 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1701191454470.2381@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>

On 01/19/2017 11:57 PM, David Rientjes wrote:
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
> 

Could we simplify both patches with something like this?
Although the sizeof("null") is not the nicest thing, because it relies on knowledge
that pointer() in lib/vsprintf.c uses this string. Maybe Rasmus has some better idea?

Thanks,
Vlastimil

diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
index f746e44d4046..4add88ef63f0 100644
--- a/include/linux/nodemask.h
+++ b/include/linux/nodemask.h
@@ -103,7 +103,7 @@ extern nodemask_t _unused_nodemask_arg_;
  *
  * Can be used to provide arguments for '%*pb[l]' when printing a nodemask.
  */
-#define nodemask_pr_args(maskp)		MAX_NUMNODES, (maskp)->bits
+#define nodemask_pr_args(maskp)		((maskp) ? MAX_NUMNODES : (int) sizeof("null")), ((maskp) ? (maskp)->bits : NULL)
 
 /*
  * The inline keyword gives the compiler room to decide to inline, or

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
