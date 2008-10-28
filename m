Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9S0988e023028
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 28 Oct 2008 09:09:08 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 573A22AC026
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 09:09:08 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 26AAC12C044
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 09:09:08 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 11BF01DB8038
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 09:09:08 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id BB8231DB8037
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 09:09:07 +0900 (JST)
Date: Tue, 28 Oct 2008 09:08:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 9/11] memcg : mem+swap controlelr kconfig
Message-Id: <20081028090840.9a30d419.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081027153911.c28285ad.nishimura@mxp.nes.nec.co.jp>
References: <20081023175800.73afc957.kamezawa.hiroyu@jp.fujitsu.com>
	<20081023181220.80dc24c5.kamezawa.hiroyu@jp.fujitsu.com>
	<20081027153911.c28285ad.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Oct 2008 15:39:11 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Thu, 23 Oct 2008 18:12:20 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Config and control variable for mem+swap controller.
> > 
> > This patch adds CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> > (memory resource controller swap extension.)
> > 
> > For accounting swap, it's obvious that we have to use additional memory
> > to remember "who uses swap". This adds more overhead.
> > So, it's better to offer "choice" to users. This patch adds 2 choices.
> > 
> > This patch adds 2 parameters to enable swap extenstion or not.
> >   - CONFIG
> >   - boot option
> > 
> > This version uses policy of "default is enable if configured."
> > please tell me you dislike this. See patches following this in detail...
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > 
> >  Documentation/kernel-parameters.txt |    3 +++
> >  include/linux/memcontrol.h          |    3 +++
> >  init/Kconfig                        |   16 ++++++++++++++++
> >  mm/memcontrol.c                     |   17 +++++++++++++++++
> >  4 files changed, 39 insertions(+)
> > 
> > Index: mmotm-2.6.27+/init/Kconfig
> > ===================================================================
> > --- mmotm-2.6.27+.orig/init/Kconfig
> > +++ mmotm-2.6.27+/init/Kconfig
> > @@ -613,6 +613,22 @@ config KALLSYMS_EXTRA_PASS
> >  	   reported.  KALLSYMS_EXTRA_PASS is only a temporary workaround while
> >  	   you wait for kallsyms to be fixed.
> >  
> > +config CGROUP_MEM_RES_CTLR_SWAP
> > +	bool "Memory Resource Controller Swap Extension(EXPERIMENTAL)"
> > +	depends on CGROUP_MEM_RES_CTLR && SWAP && EXPERIMENTAL
> > +	help
> > +	  Add swap management feature to memory resource controller. When you
> > +	  enable this, you can limit mem+swap usage per cgroup. In other words,
> > +	  when you disable this, memory resource controller have no cares to
> > +	  usage of swap...a process can exhaust the all swap. This extension
> > +	  is useful when you want to avoid exhausion of swap but this itself
> > +	  adds more overheads and consumes memory for remembering information.
> > +	  Especially if you use 32bit system or small memory system,
> > +	  please be careful to enable this. When memory resource controller
> > +	  is disabled by boot option, this will be automatiaclly disabled and
> > +	  there will be no overhead from this. Even when you set this config=y,
> > +	  if boot option "noswapaccount" is set, swap will not be accounted.
> > +
> >  
> hmm... "cgroup_disable=memory" doesn't fully disable this feature.
> 
> Even if specifying "cgroup_disable=memory", memory for table of swap_cgroup
> is allocated at swapon because "do_swap_account" is not turned off.
> 


AH, ok. I see. will be fixed.

Thanks,
-Kame

> I think it can be turned off adding some codes at mem_cgroup_create() like:
> 
> ===
> @@ -1881,6 +1881,8 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>         int node;
> 
>         if (unlikely((cont->parent) == NULL)) {
> +               if (mem_cgroup_subsys.disabled)
> +                       do_swap_account = 0;
>                 mem = &init_mem_cgroup;
>                 cpu_memcgroup_callback(&memcgroup_nb,
>                                         (unsigned long)CPU_UP_PREPARE,
> ===
> 
> BTW, is there any reason to call cgroup_init_subsys() even when the subsys
> is disabled by boot option?
> 
> 
> Thanks,
> Daisuke Nishimura.
> 
> >  config HOTPLUG
> >  	bool "Support for hot-pluggable devices" if EMBEDDED
> > Index: mmotm-2.6.27+/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-2.6.27+.orig/mm/memcontrol.c
> > +++ mmotm-2.6.27+/mm/memcontrol.c
> > @@ -41,6 +41,13 @@
> >  struct cgroup_subsys mem_cgroup_subsys __read_mostly;
> >  #define MEM_CGROUP_RECLAIM_RETRIES	5
> >  
> > +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> > +int do_swap_account __read_mostly = 1;
> > +#else
> > +#define do_swap_account		(0)
> > +#endif
> > +
> > +
> >  /*
> >   * Statistics for memory cgroup.
> >   */
> > @@ -1658,3 +1665,13 @@ struct cgroup_subsys mem_cgroup_subsys =
> >  	.attach = mem_cgroup_move_task,
> >  	.early_init = 0,
> >  };
> > +
> > +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> > +
> > +static int __init disable_swap_account(char *s)
> > +{
> > +	do_swap_account = 0;
> > +	return 1;
> > +}
> > +__setup("noswapaccount", disable_swap_account);
> > +#endif
> > Index: mmotm-2.6.27+/Documentation/kernel-parameters.txt
> > ===================================================================
> > --- mmotm-2.6.27+.orig/Documentation/kernel-parameters.txt
> > +++ mmotm-2.6.27+/Documentation/kernel-parameters.txt
> > @@ -1540,6 +1540,9 @@ and is between 256 and 4096 characters. 
> >  
> >  	nosoftlockup	[KNL] Disable the soft-lockup detector.
> >  
> > +	noswapaccount	[KNL] Disable accounting of swap in memory resource
> > +			controller. (See Documentation/controllers/memory.txt)
> > +
> >  	nosync		[HW,M68K] Disables sync negotiation for all devices.
> >  
> >  	notsc		[BUGS=X86-32] Disable Time Stamp Counter
> > Index: mmotm-2.6.27+/include/linux/memcontrol.h
> > ===================================================================
> > --- mmotm-2.6.27+.orig/include/linux/memcontrol.h
> > +++ mmotm-2.6.27+/include/linux/memcontrol.h
> > @@ -80,6 +80,9 @@ extern void mem_cgroup_record_reclaim_pr
> >  extern long mem_cgroup_calc_reclaim(struct mem_cgroup *mem, struct zone *zone,
> >  					int priority, enum lru_list lru);
> >  
> > +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> > +extern int do_swap_account;
> > +#endif
> >  
> >  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
> >  struct mem_cgroup;
> > 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
