Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 55FDA6B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 07:26:03 -0400 (EDT)
Date: Mon, 23 May 2011 13:25:58 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [Patch] mm: remove noswapaccount kernel parameter
Message-ID: <20110523112558.GC11439@tiehlicka.suse.cz>
References: <BANLkTinLvqa0DiayLOwvxE9zBmqb4Y7Rww@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTinLvqa0DiayLOwvxE9zBmqb4Y7Rww@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Am??rico Wang <xiyou.wangcong@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon 23-05-11 19:08:08, Am??rico Wang wrote:
> noswapaccount is deprecated by swapaccount=0, and it is scheduled
> to be removed in 2.6.40.

Similar patch is already in the Andrew's tree
(memsw-remove-noswapaccount-kernel-parameter.patch). Andrew, are you
going to push it?
Btw. the patch is missing documentation part which is present here.

> 
> Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> 
> ---

>  Documentation/feature-removal-schedule.txt |   16 ----------------
>  Documentation/kernel-parameters.txt        |    3 ---
>  init/Kconfig                               |    4 ++--
>  mm/memcontrol.c                            |    8 --------
>  mm/page_cgroup.c                           |    2 +-
>  5 files changed, 3 insertions(+), 30 deletions(-)
> 
> diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
> index 4cba260..688328a 100644
> --- a/Documentation/feature-removal-schedule.txt
> +++ b/Documentation/feature-removal-schedule.txt
> @@ -519,22 +519,6 @@ Files:	net/netfilter/xt_connlimit.c
>  
>  ----------------------------
>  
> -What:	noswapaccount kernel command line parameter
> -When:	2.6.40
> -Why:	The original implementation of memsw feature enabled by
> -	CONFIG_CGROUP_MEM_RES_CTLR_SWAP could be disabled by the noswapaccount
> -	kernel parameter (introduced in 2.6.29-rc1). Later on, this decision
> -	turned out to be not ideal because we cannot have the feature compiled
> -	in and disabled by default and let only interested to enable it
> -	(e.g. general distribution kernels might need it). Therefore we have
> -	added swapaccount[=0|1] parameter (introduced in 2.6.37) which provides
> -	the both possibilities. If we remove noswapaccount we will have
> -	less command line parameters with the same functionality and we
> -	can also cleanup the parameter handling a bit ().
> -Who:	Michal Hocko <mhocko@suse.cz>
> -
> -----------------------------
> -
>  What:	ipt_addrtype match include file
>  When:	2012
>  Why:	superseded by xt_addrtype
> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> index c603ef7..1931450 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -1777,9 +1777,6 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>  
>  	nosoftlockup	[KNL] Disable the soft-lockup detector.
>  
> -	noswapaccount	[KNL] Disable accounting of swap in memory resource
> -			controller. (See Documentation/cgroups/memory.txt)
> -
>  	nosync		[HW,M68K] Disables sync negotiation for all devices.
>  
>  	notsc		[BUGS=X86-32] Disable Time Stamp Counter
> diff --git a/init/Kconfig b/init/Kconfig
> index c8b172e..ef46c0d 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -673,7 +673,7 @@ config CGROUP_MEM_RES_CTLR_SWAP
>  	  be careful about enabling this. When memory resource controller
>  	  is disabled by boot option, this will be automatically disabled and
>  	  there will be no overhead from this. Even when you set this config=y,
> -	  if boot option "noswapaccount" is set, swap will not be accounted.
> +	  if boot option "swapaccount=0" is set, swap will not be accounted.
>  	  Now, memory usage of swap_cgroup is 2 bytes per entry. If swap page
>  	  size is 4096bytes, 512k per 1Gbytes of swap.
>  config CGROUP_MEM_RES_CTLR_SWAP_ENABLED
> @@ -688,7 +688,7 @@ config CGROUP_MEM_RES_CTLR_SWAP_ENABLED
>  	  parameter should have this option unselected.
>  	  For those who want to have the feature enabled by default should
>  	  select this option (if, for some reason, they need to disable it
> -	  then noswapaccount does the trick).
> +	  then swapaccount=0 does the trick).
>  
>  config CGROUP_PERF
>  	bool "Enable perf_event per-cpu per-container group (cgroup) monitoring"
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 010f916..e992fdf 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5176,12 +5176,4 @@ static int __init enable_swap_account(char *s)
>  	return 1;
>  }
>  __setup("swapaccount", enable_swap_account);
> -
> -static int __init disable_swap_account(char *s)
> -{
> -	printk_once("noswapaccount is deprecated and will be removed in 2.6.40. Use swapaccount=0 instead\n");
> -	enable_swap_account("=0");
> -	return 1;
> -}
> -__setup("noswapaccount", disable_swap_account);
>  #endif
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 2daadc3..b7bc8c0 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -502,7 +502,7 @@ int swap_cgroup_swapon(int type, unsigned long max_pages)
>  nomem:
>  	printk(KERN_INFO "couldn't allocate enough memory for swap_cgroup.\n");
>  	printk(KERN_INFO
> -		"swap_cgroup can be disabled by noswapaccount boot option\n");
> +		"swap_cgroup can be disabled by swapaccount=0 boot option\n");
>  	return -ENOMEM;
>  }
>  


-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
