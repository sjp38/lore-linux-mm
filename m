Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C6D115F0001
	for <linux-mm@kvack.org>; Fri, 10 Apr 2009 01:28:36 -0400 (EDT)
Date: Thu, 9 Apr 2009 22:25:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg remove warning at DEBUG_VM=off
Message-Id: <20090409222512.bd026a40.akpm@linux-foundation.org>
In-Reply-To: <20090408052715.GX7082@balbir.in.ibm.com>
References: <20090408142042.3fb62eea.kamezawa.hiroyu@jp.fujitsu.com>
	<20090408052715.GX7082@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Apr 2009 10:57:15 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-08 14:20:42]:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > This is against 2.6.30-rc1. (maybe no problem against mmotm.)
> > 
> > ==
> > Fix warning as
> > 
> >   CC      mm/memcontrol.o
> > mm/memcontrol.c:318: warning: ?$B!Fmem_cgroup_is_obsolete?$B!G defined but not used
> > 
> > This is called only from VM_BUG_ON().
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> > Index: linux-2.6.30-rc1/mm/memcontrol.c
> > ===================================================================
> > --- linux-2.6.30-rc1.orig/mm/memcontrol.c
> > +++ linux-2.6.30-rc1/mm/memcontrol.c
> > @@ -314,13 +314,14 @@ static struct mem_cgroup *try_get_mem_cg
> >  	return mem;
> >  }
> > 
> > +#ifdef CONFIG_DEBUG_VM
> >  static bool mem_cgroup_is_obsolete(struct mem_cgroup *mem)
> >  {
> >  	if (!mem)
> >  		return true;
> >  	return css_is_removed(&mem->css);
> >  }
> > -
> > +#endif
> 
> Can we change the code to use
> 
>         VM_BUG_ON(!mem || css_is_removed(&mem->css));
> 

yup.

--- a/mm/memcontrol.c~memcg-remove-warning-when-config_debug_vm=n-fix
+++ a/mm/memcontrol.c
@@ -314,14 +314,13 @@ static struct mem_cgroup *try_get_mem_cg
 	return mem;
 }
 
-#ifdef CONFIG_DEBUG_VM
 static bool mem_cgroup_is_obsolete(struct mem_cgroup *mem)
 {
 	if (!mem)
 		return true;
 	return css_is_removed(&mem->css);
 }
-#endif
+
 
 /*
  * Call callback function against all cgroup under hierarchy tree.
@@ -933,7 +932,7 @@ static int __mem_cgroup_try_charge(struc
 	if (unlikely(!mem))
 		return 0;
 
-	VM_BUG_ON(mem_cgroup_is_obsolete(mem));
+	VM_BUG_ON(!mem || mem_cgroup_is_obsolete(mem));
 
 	while (1) {
 		int ret;
_

Although it really should be

	VM_BUG_ON(!mem);
	VM_BUG_ON(mem_cgroup_is_obsolete(mem));

because if that BUG triggers, you'll be wondering which case caused it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
