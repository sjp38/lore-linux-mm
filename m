Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 17AC66B006A
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 09:00:56 -0500 (EST)
Received: by fxm8 with SMTP id 8so286227fxm.6
        for <linux-mm@kvack.org>; Fri, 22 Jan 2010 06:00:53 -0800 (PST)
Subject: Re: [PATCH v2] oom-kill: add lowmem usage aware oom kill handling
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <20100122152332.750f50d9.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100122152332.750f50d9.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 22 Jan 2010 23:00:44 +0900
Message-ID: <1264168844.2789.4.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, rientjes@google.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2010-01-22 at 15:23 +0900, KAMEZAWA Hiroyuki wrote:
> updated. thank you for review.
> 
> The patch is onto mmotm-Jan15 (depends on mm-count-lowmem-rss.patch)
> Tested on x86-64/SMP + debug module(to allocated lowmem), works well.
> 
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Default oom-killer uses badness calculation based on process's vm_size
> and some amounts of heuristics. Some users see proc->oom_score and
> proc->oom_adj to control oom-killed tendency under their server.
> 
> Now, we know oom-killer don't work ideally in some situaion, in PCs. Some
> enhancements are demanded. But such enhancements for oom-killer makes
> incomaptibility to oom-controls in enterprise world. So, this patch
> adds sysctl for extensions for oom-killer. Main purpose is for
> making a chance for wider test for new scheme.
> 
> One cause of OOM-Killer is memory shortage in lower zones.
> (If memory is enough, lowmem_reserve_ratio works well. but..)
> I saw lowmem-oom frequently on x86-32 and sometimes on ia64 in
> my cusotmer support jobs. If we just see process's vm_size at oom,
> we can never kill a process which has lowmem.
> At last, there will be an oom-serial-killer.
> 
> Now, we have per-mm lowmem usage counter. We can make use of it
> to select a good victim.
> 
> This patch does
>   - add sysctl for new bahavior.
>   - add CONSTRAINT_LOWMEM to oom's constraint type.
>   - pass constraint to __badness()
>   - change calculation based on constraint. If CONSTRAINT_LOWMEM,
>     use low_rss instead of vmsize.
> 
> Changelog 2010/01/22:
>  - added sysctl
>  - fixed !CONFIG_MMU
>  - fixed fs/proc/base.c breakacge.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  Documentation/sysctl/vm.txt |   16 ++++++++
>  fs/proc/base.c              |    5 +-
>  include/linux/oom.h         |    1 
>  kernel/sysctl.c             |   10 ++++-
>  mm/oom_kill.c               |   87 ++++++++++++++++++++++++++++++++------------
>  5 files changed, 94 insertions(+), 25 deletions(-)
> 
> Index: mmotm-2.6.33-Jan15/include/linux/oom.h
> ===================================================================
> --- mmotm-2.6.33-Jan15.orig/include/linux/oom.h
> +++ mmotm-2.6.33-Jan15/include/linux/oom.h
> @@ -20,6 +20,7 @@ struct notifier_block;
>   */
>  enum oom_constraint {
>  	CONSTRAINT_NONE,
> +	CONSTRAINT_LOWMEM,
>  	CONSTRAINT_CPUSET,
>  	CONSTRAINT_MEMORY_POLICY,
>  };

<snip>
> @@ -475,7 +511,7 @@ void mem_cgroup_out_of_memory(struct mem
>  
>  	read_lock(&tasklist_lock);
>  retry:
> -	p = select_bad_process(&points, mem);
> +	p = select_bad_process(&points, mem, CONSTRAINT_NONE);

Why do you fix this with only CONSTRAINT_NONE?
I think we can know CONSTRAINT_LOWMEM with gfp_mask in here. 

Any problem?

Otherwise, Looks good to me. :)

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
