Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E3D126B0085
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 19:52:16 -0500 (EST)
Date: Thu, 11 Nov 2010 09:46:13 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC PATCH] Make swap accounting default behavior configurable
Message-Id: <20101111094613.eab2ec0b.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20101110125154.GC5867@tiehlicka.suse.cz>
References: <20101110125154.GC5867@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 10 Nov 2010 13:51:54 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> Hi,
> could you consider the patch bellow? It basically changes the default
> swap accounting behavior (when it is turned on in configuration) to be
> configurable as well. 
> 
> The rationale is described in the patch but in short it makes it much
> more easier to enable this feature in distribution kernels as the
> functionality can be provided in the general purpose kernel (with the
> option disabled) without any drawbacks and interested users can enable
> it. This is not possible currently.
> 
> I am aware that boot command line parameter name change is not ideal but
> the original semantic wasn't good enough and I don't like
> noswapaccount=yes|no very much. 
> 
> If we really have to stick to it I can rework the patch to keep the name
> and just add the yes|no logic, though. Or we can keep the original one
> and add swapaccount paramete which would mean the oposite as the other
> one.
> 
hmm, I agree that current parameter name(noswapaccount) is not desirable
for yes|no, but IMHO changing the user interface(iow, making what worked before 
unusable) is worse.

Although I'm not sure how many people are using this parameter, I vote for
using "noswapaccount[=(yes|no)]".
And you should update Documentation/kernel-parameters.txt too.

Thanks,
Daisuke Nishimura.

> The patch is based on the current Linus tree.
> 
> Any thoughts?
> ---
> 
> From c874f2c1ff1493e49611f19308434e564c2d37c6 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Wed, 10 Nov 2010 13:30:04 +0100
> Subject: [PATCH] Make swap accounting default behavior configurable
> 
> Swap accounting can be configured by CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> configuration option and then it is turned on by default. There is
> a boot option (noswapaccount) which can disable this feature.
> 
> This makes it hard for distributors to enable the configuration option
> as this feature leads to a bigger memory consumption and this is a no-go
> for general purpose distribution kernel. On the other hand swap
> accounting may be very usuful for some workloads.
> 
> This patch adds a new configuration option which controls the default
> behavior (CGROUP_MEM_RES_CTLR_SWAP_ENABLED) and changes the original
> noswapaccount parameter to swapaccount=true|false which provides
> a more fine grained way to control this feature.
> 
> The default behavior is unchanged (if CONFIG_CGROUP_MEM_RES_CTLR_SWAP is
> enabled then CONFIG_CGROUP_MEM_RES_CTLR_SWAP_ENABLED is enabled as well)
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  init/Kconfig    |   13 +++++++++++++
>  mm/memcontrol.c |   19 ++++++++++++++-----
>  2 files changed, 27 insertions(+), 5 deletions(-)
> 
> diff --git a/init/Kconfig b/init/Kconfig
> index 88c1046..61d55a7 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -613,6 +613,19 @@ config CGROUP_MEM_RES_CTLR_SWAP
>  	  if boot option "noswapaccount" is set, swap will not be accounted.
>  	  Now, memory usage of swap_cgroup is 2 bytes per entry. If swap page
>  	  size is 4096bytes, 512k per 1Gbytes of swap.
> +config CGROUP_MEM_RES_CTLR_SWAP_ENABLED
> +	bool "Memory Resource Controller Swap Extension enabled by default"
> +	depends on CGROUP_MEM_RES_CTLR_SWAP
> +	default y
> +	help
> +	  Memory Resource Controller Swap Extension comes with its price in
> +	  a bigger memory consumption. General purpose distribution kernels
> +	  which want to enable the feautre but keep it disabled by default
> +	  and let the user enable it by swapaccount=true boot command line
> +	  parameter should have this option unselected.
> +	  For those who want to have the feature enabled by default should
> +	  select this option (if, for some reason, they need to disable it
> +	  then swapaccount=false does the trick).
>  
>  menuconfig CGROUP_SCHED
>  	bool "Group CPU scheduler"
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 9a99cfa..7c699b3 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -61,7 +61,14 @@ struct mem_cgroup *root_mem_cgroup __read_mostly;
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
>  /* Turned on only when memory cgroup is enabled && really_do_swap_account = 1 */
>  int do_swap_account __read_mostly;
> -static int really_do_swap_account __initdata = 1; /* for remember boot option*/
> +
> +/* for remember boot option*/
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP_ENABLED
> +static int really_do_swap_account __initdata = 1;
> +#else
> +static int really_do_swap_account __initdata = 0;
> +#endif
> +
>  #else
>  #define do_swap_account		(0)
>  #endif
> @@ -4909,11 +4916,13 @@ struct cgroup_subsys mem_cgroup_subsys = {
>  };
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> -
> -static int __init disable_swap_account(char *s)
> +static int __init enable_swap_account(char *s)
>  {
> -	really_do_swap_account = 0;
> +	if (!s || !strcmp(s, "true"))
> +		really_do_swap_account = 1;
> +	else if (!strcmp(s, "false"))
> +		really_do_swap_account = 0;
>  	return 1;
>  }
> -__setup("noswapaccount", disable_swap_account);
> +__setup("swapaccount", enable_swap_account);
>  #endif
> -- 
> 1.7.2.3
> 
> 
> -- 
> Michal Hocko
> L3 team 
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9    
> Czech Republic
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
