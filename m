Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C4CEB8D0017
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 20:21:50 -0500 (EST)
Date: Mon, 15 Nov 2010 10:13:35 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC PATCH] Make swap accounting default behavior configurable
 v2
Message-Id: <20101115101335.8880fd87.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20101112083103.GB7285@tiehlicka.suse.cz>
References: <20101110125154.GC5867@tiehlicka.suse.cz>
	<20101111094613.eab2ec0b.nishimura@mxp.nes.nec.co.jp>
	<20101111093155.GA20630@tiehlicka.suse.cz>
	<20101112094118.b02b669f.nishimura@mxp.nes.nec.co.jp>
	<20101112083103.GB7285@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, balbir@linux.vnet.ibm.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 12 Nov 2010 09:31:03 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> On Fri 12-11-10 09:41:18, Daisuke Nishimura wrote:
> > On Thu, 11 Nov 2010 10:31:55 +0100
> > Michal Hocko <mhocko@suse.cz> wrote:
> > 
> > > On Thu 11-11-10 09:46:13, Daisuke Nishimura wrote:
> > > > On Wed, 10 Nov 2010 13:51:54 +0100
> > > > Michal Hocko <mhocko@suse.cz> wrote:
> > > > 
> > > > > Hi,
> > > > > could you consider the patch bellow? It basically changes the default
> > > > > swap accounting behavior (when it is turned on in configuration) to be
> > > > > configurable as well. 
> > > > > 
> > > > > The rationale is described in the patch but in short it makes it much
> > > > > more easier to enable this feature in distribution kernels as the
> > > > > functionality can be provided in the general purpose kernel (with the
> > > > > option disabled) without any drawbacks and interested users can enable
> > > > > it. This is not possible currently.
> > > > > 
> > > > > I am aware that boot command line parameter name change is not ideal but
> > > > > the original semantic wasn't good enough and I don't like
> > > > > noswapaccount=yes|no very much. 
> > > > > 
> > > > > If we really have to stick to it I can rework the patch to keep the name
> > > > > and just add the yes|no logic, though. Or we can keep the original one
> > > > > and add swapaccount paramete which would mean the oposite as the other
> > > > > one.
> > > > > 
> > > > hmm, I agree that current parameter name(noswapaccount) is not desirable
> > > > for yes|no, but IMHO changing the user interface(iow, making what worked before 
> > > > unusable) is worse.
> > > > 
> > > > Although I'm not sure how many people are using this parameter, I vote for
> > > > using "noswapaccount[=(yes|no)]".
> > > 
> > > Isn't a new swapaccount parameter better than that? I know we don't want
> > > to have too many parameters but having a something with a clear meaning
> > > is better IMO (noswapaccount=no doesn't sound very intuitive to me).
> > > 
> > Fair enough. It's just an trade-off between compatibility and understandability.
> > 
> > > > And you should update Documentation/kernel-parameters.txt too.
> > > 
> > > Yes, I am aware of that and will do that once there is an agreement on
> > > the patch itself. At this stage, I just wanted to have a feadback about
> > > the change.
> > > 
> > I'll ack your patch when it's been released with documentation update.
> 
> Changes since v1:
> * do not remove noswapaccount parameter and add swapaccount parameter
>   instead
> * Documentation/kernel-parameters.txt updated
> 
> --- 
> From c60e3d76702cd9b4b5b13c01be335da31d03bc1c Mon Sep 17 00:00:00 2001
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
>  Documentation/kernel-parameters.txt |    2 ++
>  init/Kconfig                        |   13 +++++++++++++
>  mm/memcontrol.c                     |   15 ++++++++++++++-
>  3 files changed, 29 insertions(+), 1 deletions(-)
> 
> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> index ed45e98..7077148 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -1752,6 +1752,8 @@ and is between 256 and 4096 characters. It is defined in the file
>  
>  	noswapaccount	[KNL] Disable accounting of swap in memory resource
>  			controller. (See Documentation/cgroups/memory.txt)
> +	swapaccount	[KNL] Enable accounting of swap in memory resource
> +			controller. (See Documentation/cgroups/memory.txt)
>  
>  	nosync		[HW,M68K] Disables sync negotiation for all devices.
>  
(I've add Andrew and Balbir to CC-list.)
It seems that almost all parameters are listed in alphabetic order in the document,
so I think it would be better to obey the rule.

Thanks,
Daisuke Nishimura.

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
