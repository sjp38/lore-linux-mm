Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id B75AC6B00BD
	for <linux-mm@kvack.org>; Tue, 19 May 2015 10:18:21 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so119496821wic.0
        for <linux-mm@kvack.org>; Tue, 19 May 2015 07:18:21 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id m6si1965642wif.81.2015.05.19.07.18.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 May 2015 07:18:20 -0700 (PDT)
Date: Tue, 19 May 2015 10:18:07 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm, memcg: Optionally disable memcg by default using
 Kconfig
Message-ID: <20150519141807.GA9788@cmpxchg.org>
References: <20150519104057.GC2462@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150519104057.GC2462@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org

CC'ing Tejun and cgroups for the generic cgroup interface part

On Tue, May 19, 2015 at 11:40:57AM +0100, Mel Gorman wrote:
> memcg was reported years ago to have significant overhead when unused. It
> has improved but it's still the case that users that have no knowledge of
> memcg pay a performance penalty.
> 
> This patch adds a Kconfig that controls whether memcg is enabled by default
> and a kernel parameter cgroup_enable= to enable it if desired. Anyone using
> oldconfig will get the historical behaviour. It is not an option for most
> distributions to simply disable MEMCG as there are users that require it
> but they should also be knowledgable enough to use cgroup_enable=.
> 
> This was evaluated using aim9, a page fault microbenchmark and ebizzy
> but I'll focus on the page fault microbenchmark. It can be reproduced
> using pft from mmtests (https://github.com/gormanm/mmtests).  Edit
> configs/config-global-dhp__pagealloc-performance and update MMTESTS to
> only contain pft. This is the relevant part of the profile summary
> 
> /usr/src/linux-4.0-vanilla/mm/memcontrol.c                           6.6441   395842
>   mem_cgroup_try_charge                                                        2.950%   175781

Ouch.  Do you have a way to get the per-instruction breakdown of this?
This function really isn't doing much.  I'll try to reproduce it here
too, I haven't seen such high costs with pft in the past.

>   __mem_cgroup_count_vm_event                                                  1.431%    85239
>   mem_cgroup_page_lruvec                                                       0.456%    27156
>   mem_cgroup_commit_charge                                                     0.392%    23342
>   uncharge_list                                                                0.323%    19256
>   mem_cgroup_update_lru_size                                                   0.278%    16538
>   memcg_check_events                                                           0.216%    12858
>   mem_cgroup_charge_statistics.isra.22                                         0.188%    11172
>   try_charge                                                                   0.150%     8928
>   commit_charge                                                                0.141%     8388
>   get_mem_cgroup_from_mm                                                       0.121%     7184
> 
> It's showing 6.64% overhead in memcontrol.c when no memcgs are in
> use. Applying the patch and disabling memcg reduces this to 0.48%

The frustrating part is that 4.5% of that is not even coming from the
main accounting and tracking work.  I'm looking into getting this
fixed regardless of what happens with this patch.

> /usr/src/linux-4.0-nomemcg-v1r1/mm/memcontrol.c                      0.4834    27511
>   mem_cgroup_page_lruvec                                                       0.161%     9172
>   mem_cgroup_update_lru_size                                                   0.154%     8794
>   mem_cgroup_try_charge                                                        0.126%     7194
>   mem_cgroup_commit_charge                                                     0.041%     2351
> 
> Note that it's not very visible from headline performance figures
> 
> pft faults
>                                        4.0.0                  4.0.0
>                                      vanilla             nomemcg-v1
> Hmean    faults/cpu-1 1443258.1051 (  0.00%) 1530574.6033 (  6.05%)
> Hmean    faults/cpu-3 1340385.9270 (  0.00%) 1375156.5834 (  2.59%)
> Hmean    faults/cpu-5  875599.0222 (  0.00%)  876217.9211 (  0.07%)
> Hmean    faults/cpu-7  601146.6726 (  0.00%)  599068.4360 ( -0.35%)
> Hmean    faults/cpu-8  510728.2754 (  0.00%)  509887.9960 ( -0.16%)
> Hmean    faults/sec-1 1432084.7845 (  0.00%) 1518566.3541 (  6.04%)
> Hmean    faults/sec-3 3943818.1437 (  0.00%) 4036918.0217 (  2.36%)
> Hmean    faults/sec-5 3877573.5867 (  0.00%) 3922745.9207 (  1.16%)
> Hmean    faults/sec-7 3991832.0418 (  0.00%) 3990670.8481 ( -0.03%)
> Hmean    faults/sec-8 3987189.8167 (  0.00%) 3978842.8107 ( -0.21%)
> 
> Low thread counts get a boost but it's within noise as memcg overhead does
> not dominate.  It's not obvious at all at higher thread counts as other
> factors cause more problems. The overall breakdown of CPU usage looks like
> 
>                4.0.0       4.0.0
>              vanilla  nomemcg-v1
> User           41.45       41.11
> System        410.19      404.76
> Elapsed       130.33      126.30
> 
> Despite the relative unimportance, there is at least some justification
> for disabling memcg by default.

I guess so.  The only thing I don't like about this is that it changes
the default of a single controller.  While there is some justification
from an overhead standpoint, it's a little weird in terms of interface
when you boot, say, a distribution kernel and it has cgroups with all
but one resource controller available.

Would it make more sense to provide a Kconfig option that disables all
resource controllers per default?  There is still value in having only
the generic cgroup part for grouped process monitoring and control.

Thanks,
Johannes

> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  Documentation/kernel-parameters.txt |  4 ++++
>  init/Kconfig                        | 15 +++++++++++++++
>  kernel/cgroup.c                     | 20 ++++++++++++++++----
>  mm/memcontrol.c                     |  3 +++
>  4 files changed, 38 insertions(+), 4 deletions(-)
> 
> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> index bfcb1a62a7b4..4f264f906816 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -591,6 +591,10 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>  			cut the overhead, others just disable the usage. So
>  			only cgroup_disable=memory is actually worthy}
>  
> +	cgroup_enable= [KNL] Enable a particular controller
> +			Similar to cgroup_disable except that it enables
> +			controllers that are disabled by default.
> +
>  	checkreqprot	[SELINUX] Set initial checkreqprot flag value.
>  			Format: { "0" | "1" }
>  			See security/selinux/Kconfig help text.
> diff --git a/init/Kconfig b/init/Kconfig
> index f5dbc6d4261b..819b6cc05cba 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -990,6 +990,21 @@ config MEMCG
>  	  Provides a memory resource controller that manages both anonymous
>  	  memory and page cache. (See Documentation/cgroups/memory.txt)
>  
> +config MEMCG_DEFAULT_ENABLED
> +	bool "Automatically enable memory resource controller"
> +	default y
> +	depends on MEMCG
> +	help
> +	  The memory controller has some overhead even if idle as resource
> +	  usage must be tracked in case a group is created and a process
> +	  migrated. As users may not be aware of this and the cgroup_disable=
> +	  option, this config option controls whether it is enabled by
> +	  default. It is assumed that someone that requires the controller
> +	  can find the cgroup_enable= switch.
> +
> +	  Say N if unsure. This is default Y to preserve oldconfig and
> +	  historical behaviour.
> +
>  config MEMCG_SWAP
>  	bool "Memory Resource Controller Swap Extension"
>  	depends on MEMCG && SWAP
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 29a7b2cc593e..0e79db55bf1a 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -5370,7 +5370,7 @@ out_free:
>  	kfree(pathbuf);
>  }
>  
> -static int __init cgroup_disable(char *str)
> +static int __init __cgroup_set_state(char *str, bool disabled)
>  {
>  	struct cgroup_subsys *ss;
>  	char *token;
> @@ -5382,16 +5382,28 @@ static int __init cgroup_disable(char *str)
>  
>  		for_each_subsys(ss, i) {
>  			if (!strcmp(token, ss->name)) {
> -				ss->disabled = 1;
> -				printk(KERN_INFO "Disabling %s control group"
> -					" subsystem\n", ss->name);
> +				ss->disabled = disabled;
> +				printk(KERN_INFO "Setting %s control group"
> +					" subsystem %s\n", ss->name,
> +					disabled ? "disabled" : "enabled");
>  				break;
>  			}
>  		}
>  	}
>  	return 1;
>  }
> +
> +static int __init cgroup_disable(char *str)
> +{
> +	return __cgroup_set_state(str, true);
> +}
> +
> +static int __init cgroup_enable(char *str)
> +{
> +	return __cgroup_set_state(str, false);
> +}
>  __setup("cgroup_disable=", cgroup_disable);
> +__setup("cgroup_enable=", cgroup_enable);
>  
>  static int __init cgroup_set_legacy_files_on_dfl(char *str)
>  {
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index b34ef4a32a3b..ce171ba16949 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5391,6 +5391,9 @@ struct cgroup_subsys memory_cgrp_subsys = {
>  	.dfl_cftypes = memory_files,
>  	.legacy_cftypes = mem_cgroup_legacy_files,
>  	.early_init = 0,
> +#ifndef CONFIG_MEMCG_DEFAULT_ENABLED
> +	.disabled = 1,
> +#endif
>  };
>  
>  /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
