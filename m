Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 28EF65F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 06:13:12 -0400 (EDT)
Received: by fxm22 with SMTP id 22so3778246fxm.38
        for <linux-mm@kvack.org>; Wed, 15 Apr 2009 03:13:21 -0700 (PDT)
Date: Wed, 15 Apr 2009 12:13:17 +0200
From: Andrea Righi <righi.andrea@gmail.com>
Subject: Re: [PATCH] memcg remove warning at DEBUG_VM=off
Message-ID: <20090415101317.GA3240@linux>
References: <20090408142042.3fb62eea.kamezawa.hiroyu@jp.fujitsu.com> <20090408052715.GX7082@balbir.in.ibm.com> <20090409222512.bd026a40.akpm@linux-foundation.org> <20090410153335.b52c5f74.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20090410153335.b52c5f74.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, balbir@linux.vnet.ibm.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 10, 2009 at 03:33:35PM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 9 Apr 2009 22:25:12 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Wed, 8 Apr 2009 10:57:15 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-08 14:20:42]:
> > > 
> > > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > > This is against 2.6.30-rc1. (maybe no problem against mmotm.)
> > > > 
> > > > ==
> > > > Fix warning as
> > > > 
> > > >   CC      mm/memcontrol.o
> > > > mm/memcontrol.c:318: warning: ?$B!Fmem_cgroup_is_obsolete?$B!G defined but not used
> > > > 
> > > > This is called only from VM_BUG_ON().
> > > > 
> > > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > > ---
> > > > Index: linux-2.6.30-rc1/mm/memcontrol.c
> > > > ===================================================================
> > > > --- linux-2.6.30-rc1.orig/mm/memcontrol.c
> > > > +++ linux-2.6.30-rc1/mm/memcontrol.c
> > > > @@ -314,13 +314,14 @@ static struct mem_cgroup *try_get_mem_cg
> > > >  	return mem;
> > > >  }
> > > > 
> > > > +#ifdef CONFIG_DEBUG_VM
> > > >  static bool mem_cgroup_is_obsolete(struct mem_cgroup *mem)
> > > >  {
> > > >  	if (!mem)
> > > >  		return true;
> > > >  	return css_is_removed(&mem->css);
> > > >  }
> > > > -
> > > > +#endif
> > > 
> > > Can we change the code to use
> > > 
> > >         VM_BUG_ON(!mem || css_is_removed(&mem->css));
> > > 
> > 
> > yup.
> > 
> > --- a/mm/memcontrol.c~memcg-remove-warning-when-config_debug_vm=n-fix
> > +++ a/mm/memcontrol.c
> > @@ -314,14 +314,13 @@ static struct mem_cgroup *try_get_mem_cg
> >  	return mem;
> >  }
> >  
> > -#ifdef CONFIG_DEBUG_VM
> >  static bool mem_cgroup_is_obsolete(struct mem_cgroup *mem)
> >  {
> >  	if (!mem)
> >  		return true;
> >  	return css_is_removed(&mem->css);
> >  }
> > -#endif
> > +
> >  
> >  /*
> >   * Call callback function against all cgroup under hierarchy tree.
> > @@ -933,7 +932,7 @@ static int __mem_cgroup_try_charge(struc
> >  	if (unlikely(!mem))
> >  		return 0;
> >  
> > -	VM_BUG_ON(mem_cgroup_is_obsolete(mem));
> > +	VM_BUG_ON(!mem || mem_cgroup_is_obsolete(mem));
> >  
> >  	while (1) {
> >  		int ret;
> > _
> > 
> > Although it really should be
> > 
> > 	VM_BUG_ON(!mem);
> > 	VM_BUG_ON(mem_cgroup_is_obsolete(mem));
> > 
> > because if that BUG triggers, you'll be wondering which case caused it.
> > 
> Ah, sorry, I missed the reply.
> maybe calling css_is_removed() directly is a choice.
> I'll prepare v2.
> 
> Regards,
> -Kame

The warning is still there actually. I've just written a fix and seen
this discussion, maybe I can offload a little bit Kame. ;)

-Andrea
---
memcg: remove warning when CONFIG_DEBUG_VM is not set

Fix the following warning removing mem_cgroup_is_obsolete():

  mm/memcontrol.c:318: warning: a??mem_cgroup_is_obsoletea?? defined but not used

Moreover, split the VM_BUG_ON() checks in two parts to be aware of which
one triggered the bug.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Andrea Righi <righi.andrea@gmail.com>
---
 mm/memcontrol.c |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e44fb0f..8cd6358 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -314,14 +314,6 @@ static struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
 	return mem;
 }
 
-static bool mem_cgroup_is_obsolete(struct mem_cgroup *mem)
-{
-	if (!mem)
-		return true;
-	return css_is_removed(&mem->css);
-}
-
-
 /*
  * Call callback function against all cgroup under hierarchy tree.
  */
@@ -932,7 +924,8 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 	if (unlikely(!mem))
 		return 0;
 
-	VM_BUG_ON(!mem || mem_cgroup_is_obsolete(mem));
+	VM_BUG_ON(!mem);
+	VM_BUG_ON(css_is_removed(&mem->css));
 
 	while (1) {
 		int ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
