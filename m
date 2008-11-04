Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA49EHIG017086
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 4 Nov 2008 18:14:17 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 97C9845DD7F
	for <linux-mm@kvack.org>; Tue,  4 Nov 2008 18:14:17 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6282C45DD7E
	for <linux-mm@kvack.org>; Tue,  4 Nov 2008 18:14:17 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 36C841DB803B
	for <linux-mm@kvack.org>; Tue,  4 Nov 2008 18:14:17 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E6B291DB803F
	for <linux-mm@kvack.org>; Tue,  4 Nov 2008 18:14:16 +0900 (JST)
Date: Tue, 4 Nov 2008 18:13:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 3/5] memcg : mem+swap controller kconfig
Message-Id: <20081104181343.3b0eb168.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081104175406.cb46d68d.nishimura@mxp.nes.nec.co.jp>
References: <20081031115057.6da3dafd.kamezawa.hiroyu@jp.fujitsu.com>
	<20081031115510.3ba13f3b.kamezawa.hiroyu@jp.fujitsu.com>
	<20081104175406.cb46d68d.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, hugh@veritas.com, taka@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Tue, 4 Nov 2008 17:54:06 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> > +static void __init enable_swap_cgroup(void)
> > +{
> > +	if (really_do_swap_account)
> > +		do_swap_account = 1;
> > +}
> I think check for !mem_cgroup_subsys.disabled is also needed here.
> 

Hmm, mem_cgroup_create() is called even when disabled ?
.......seems so.

Ok, will fix. thank you for checking it.

Regards,
-Kame


> 
> Thanks,
> Daisuke Nishimura.
> 
> > +#else
> > +static void __init enable_swap_cgroup(void)
> > +{
> > +}
> > +#endif
> > +
> >  static struct cgroup_subsys_state *
> >  mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
> >  {
> > @@ -1377,6 +1398,7 @@ mem_cgroup_create(struct cgroup_subsys *
> >  
> >  	if (unlikely((cont->parent) == NULL)) {
> >  		mem = &init_mem_cgroup;
> > +		enable_swap_cgroup();
> >  	} else {
> >  		mem = mem_cgroup_alloc();
> >  		if (!mem)
> > @@ -1460,3 +1482,13 @@ struct cgroup_subsys mem_cgroup_subsys =
> >  	.attach = mem_cgroup_move_task,
> >  	.early_init = 0,
> >  };
> > +
> > +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> > +
> > +static int __init disable_swap_account(char *s)
> > +{
> > +	really_do_swap_account = 0;
> > +	return 1;
> > +}
> > +__setup("noswapaccount", disable_swap_account);
> > +#endif
> > Index: mmotm-2.6.28-rc2+/Documentation/kernel-parameters.txt
> > ===================================================================
> > --- mmotm-2.6.28-rc2+.orig/Documentation/kernel-parameters.txt
> > +++ mmotm-2.6.28-rc2+/Documentation/kernel-parameters.txt
> > @@ -1543,6 +1543,9 @@ and is between 256 and 4096 characters. 
> >  
> >  	nosoftlockup	[KNL] Disable the soft-lockup detector.
> >  
> > +	noswapaccount	[KNL] Disable accounting of swap in memory resource
> > +			controller. (See Documentation/controllers/memory.txt)
> > +
> >  	nosync		[HW,M68K] Disables sync negotiation for all devices.
> >  
> >  	notsc		[BUGS=X86-32] Disable Time Stamp Counter
> > Index: mmotm-2.6.28-rc2+/include/linux/memcontrol.h
> > ===================================================================
> > --- mmotm-2.6.28-rc2+.orig/include/linux/memcontrol.h
> > +++ mmotm-2.6.28-rc2+/include/linux/memcontrol.h
> > @@ -77,6 +77,9 @@ extern void mem_cgroup_record_reclaim_pr
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
