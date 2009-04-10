Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7D2705F0001
	for <linux-mm@kvack.org>; Fri, 10 Apr 2009 02:34:37 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3A6Z791017393
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 10 Apr 2009 15:35:07 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7922545DD78
	for <linux-mm@kvack.org>; Fri, 10 Apr 2009 15:35:07 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 41C0445DD76
	for <linux-mm@kvack.org>; Fri, 10 Apr 2009 15:35:07 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DA101DB8018
	for <linux-mm@kvack.org>; Fri, 10 Apr 2009 15:35:07 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C718C1DB8012
	for <linux-mm@kvack.org>; Fri, 10 Apr 2009 15:35:06 +0900 (JST)
Date: Fri, 10 Apr 2009 15:33:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg remove warning at DEBUG_VM=off
Message-Id: <20090410153335.b52c5f74.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090409222512.bd026a40.akpm@linux-foundation.org>
References: <20090408142042.3fb62eea.kamezawa.hiroyu@jp.fujitsu.com>
	<20090408052715.GX7082@balbir.in.ibm.com>
	<20090409222512.bd026a40.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: balbir@linux.vnet.ibm.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 9 Apr 2009 22:25:12 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 8 Apr 2009 10:57:15 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-08 14:20:42]:
> > 
> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > This is against 2.6.30-rc1. (maybe no problem against mmotm.)
> > > 
> > > ==
> > > Fix warning as
> > > 
> > >   CC      mm/memcontrol.o
> > > mm/memcontrol.c:318: warning: ?$B!Fmem_cgroup_is_obsolete?$B!G defined but not used
> > > 
> > > This is called only from VM_BUG_ON().
> > > 
> > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > ---
> > > Index: linux-2.6.30-rc1/mm/memcontrol.c
> > > ===================================================================
> > > --- linux-2.6.30-rc1.orig/mm/memcontrol.c
> > > +++ linux-2.6.30-rc1/mm/memcontrol.c
> > > @@ -314,13 +314,14 @@ static struct mem_cgroup *try_get_mem_cg
> > >  	return mem;
> > >  }
> > > 
> > > +#ifdef CONFIG_DEBUG_VM
> > >  static bool mem_cgroup_is_obsolete(struct mem_cgroup *mem)
> > >  {
> > >  	if (!mem)
> > >  		return true;
> > >  	return css_is_removed(&mem->css);
> > >  }
> > > -
> > > +#endif
> > 
> > Can we change the code to use
> > 
> >         VM_BUG_ON(!mem || css_is_removed(&mem->css));
> > 
> 
> yup.
> 
> --- a/mm/memcontrol.c~memcg-remove-warning-when-config_debug_vm=n-fix
> +++ a/mm/memcontrol.c
> @@ -314,14 +314,13 @@ static struct mem_cgroup *try_get_mem_cg
>  	return mem;
>  }
>  
> -#ifdef CONFIG_DEBUG_VM
>  static bool mem_cgroup_is_obsolete(struct mem_cgroup *mem)
>  {
>  	if (!mem)
>  		return true;
>  	return css_is_removed(&mem->css);
>  }
> -#endif
> +
>  
>  /*
>   * Call callback function against all cgroup under hierarchy tree.
> @@ -933,7 +932,7 @@ static int __mem_cgroup_try_charge(struc
>  	if (unlikely(!mem))
>  		return 0;
>  
> -	VM_BUG_ON(mem_cgroup_is_obsolete(mem));
> +	VM_BUG_ON(!mem || mem_cgroup_is_obsolete(mem));
>  
>  	while (1) {
>  		int ret;
> _
> 
> Although it really should be
> 
> 	VM_BUG_ON(!mem);
> 	VM_BUG_ON(mem_cgroup_is_obsolete(mem));
> 
> because if that BUG triggers, you'll be wondering which case caused it.
> 
Ah, sorry, I missed the reply.
maybe calling css_is_removed() directly is a choice.
I'll prepare v2.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
