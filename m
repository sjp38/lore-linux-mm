Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 322038D0080
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 23:53:27 -0500 (EST)
Date: Tue, 16 Nov 2010 13:48:00 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC PATCH] Make swap accounting default behavior configurable
 v3
Message-Id: <20101116134800.7d8b612d.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20101115083540.GA20156@tiehlicka.suse.cz>
References: <20101110125154.GC5867@tiehlicka.suse.cz>
	<20101111094613.eab2ec0b.nishimura@mxp.nes.nec.co.jp>
	<20101111093155.GA20630@tiehlicka.suse.cz>
	<20101112094118.b02b669f.nishimura@mxp.nes.nec.co.jp>
	<20101112083103.GB7285@tiehlicka.suse.cz>
	<20101115101335.8880fd87.nishimura@mxp.nes.nec.co.jp>
	<20101115083540.GA20156@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, balbir@linux.vnet.ibm.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Thank you for your work.
Daisuke Nishimura.

On Mon, 15 Nov 2010 09:35:40 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> On Mon 15-11-10 10:13:35, Daisuke Nishimura wrote:
> > On Fri, 12 Nov 2010 09:31:03 +0100
> [...]
> > > diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> > > index ed45e98..7077148 100644
> > > --- a/Documentation/kernel-parameters.txt
> > > +++ b/Documentation/kernel-parameters.txt
> > > @@ -1752,6 +1752,8 @@ and is between 256 and 4096 characters. It is defined in the file
> > >  
> > >  	noswapaccount	[KNL] Disable accounting of swap in memory resource
> > >  			controller. (See Documentation/cgroups/memory.txt)
> > > +	swapaccount	[KNL] Enable accounting of swap in memory resource
> > > +			controller. (See Documentation/cgroups/memory.txt)
> > >  
> > >  	nosync		[HW,M68K] Disables sync negotiation for all devices.
> > >  
> > (I've add Andrew and Balbir to CC-list.)
> > It seems that almost all parameters are listed in alphabetic order in the document,
> > so I think it would be better to obey the rule.
> 
> You are right. The header of the file says:
> 
> " The following is a consolidated list of the kernel parameters as
> implemented (mostly) by the __setup() macro and sorted into English
> Dictionary order (defined as ignoring all punctuation and sorting digits
> before letters in a case insensitive manner), and with descriptions
> where known."
> 
> Updated patch follows bellow.
> 
> > 
> > Thanks,
> > Daisuke Nishimura.
> 
> Changes since v2:
> * put the new parameter description to the proper (alphabetically sorted)
>   place in Documentation/kernel-parameters.txt
> 
> Changes since v1:
> * do not remove noswapaccount parameter and add swapaccount parameter instead
> * Documentation/kernel-parameters.txt updated
> ---
> 
> From 21df3801e2b65f47a2807534487ebb353dad6340 Mon Sep 17 00:00:00 2001
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
> behavior (CGROUP_MEM_RES_CTLR_SWAP_ENABLED). If the option is selected
> then the feature is turned on by default.
> 
> It also adds a new boot parameter swapaccount which (contrary to
> noswapaccount) enables the feature. (I would consider swapaccount=yes|no
> semantic with removed noswapaccount parameter much better but this
> parameter is kind of API which might be in use and unexpected breakage
> is no-go.)
> 
> The default behavior is unchanged (if CONFIG_CGROUP_MEM_RES_CTLR_SWAP is
> enabled then CONFIG_CGROUP_MEM_RES_CTLR_SWAP_ENABLED is enabled as well)
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  Documentation/kernel-parameters.txt |    3 +++
>  init/Kconfig                        |   13 +++++++++++++
>  mm/memcontrol.c                     |   15 ++++++++++++++-
>  3 files changed, 30 insertions(+), 1 deletions(-)
> 
> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> index ed45e98..14eafa5 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -2385,6 +2385,9 @@ and is between 256 and 4096 characters. It is defined in the file
>  			improve throughput, but will also increase the
>  			amount of memory reserved for use by the client.
>  
> +	swapaccount	[KNL] Enable accounting of swap in memory resource
> +			controller. (See Documentation/cgroups/memory.txt)
> +
>  	swiotlb=	[IA-64] Number of I/O TLB slabs
>  
>  	switches=	[HW,M68k]
> diff --git a/init/Kconfig b/init/Kconfig
> index 88c1046..c972899 100644
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
> +	  and let the user enable it by swapaccount boot command line
> +	  parameter should have this option unselected.
> +	  For those who want to have the feature enabled by default should
> +	  select this option (if, for some reason, they need to disable it
> +	  then noswapaccount does the trick).
>  
>  menuconfig CGROUP_SCHED
>  	bool "Group CPU scheduler"
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 9a99cfa..4f479fe 100644
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
> @@ -4909,6 +4916,12 @@ struct cgroup_subsys mem_cgroup_subsys = {
>  };
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> +static int __init enable_swap_account(char *s)
> +{
> +	really_do_swap_account = 1;
> +	return 1;
> +}
> +__setup("swapaccount", enable_swap_account);
>  
>  static int __init disable_swap_account(char *s)
>  {
> -- 
> 1.7.2.3
> 
> -- 
> Michal Hocko
> L3 team 
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9    
> Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
