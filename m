Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A51EE6B024D
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 02:25:30 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6S6PS11027985
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Jul 2010 15:25:28 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id DC06F45DE55
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 15:25:27 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B5AF045DE52
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 15:25:27 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 649D01DB8015
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 15:25:27 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 137C61DB8013
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 15:25:27 +0900 (JST)
Date: Wed, 28 Jul 2010 15:20:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 7/7][memcg] use spin lock instead of bit_spin_lock
 in page_cgroup
Message-Id: <20100728152040.f6a0499c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <xr93bp9sm8q1.fsf@ninji.mtv.corp.google.com>
References: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100727170225.64f78b15.kamezawa.hiroyu@jp.fujitsu.com>
	<xr93bp9sm8q1.fsf@ninji.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Jul 2010 23:16:54 -0700
Greg Thelen <gthelen@google.com> wrote:

> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >
> > This patch replaces page_cgroup's bit_spinlock with spinlock. In general,
> > spinlock has good implementation than bit_spin_lock and we should use
> > it if we have a room for it. In 64bit arch, we have extra 4bytes.
> > Let's use it.
> >
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > --
> > Index: mmotm-0719/include/linux/page_cgroup.h
> > ===================================================================
> > --- mmotm-0719.orig/include/linux/page_cgroup.h
> > +++ mmotm-0719/include/linux/page_cgroup.h
> > @@ -10,8 +10,14 @@
> >   * All page cgroups are allocated at boot or memory hotplug event,
> >   * then the page cgroup for pfn always exists.
> >   */
> > +#ifdef CONFIG_64BIT
> > +#define PCG_HAS_SPINLOCK
> > +#endif
> >  struct page_cgroup {
> >  	unsigned long flags;
> > +#ifdef PCG_HAS_SPINLOCK
> > +	spinlock_t	lock;
> > +#endif
> >  	unsigned short mem_cgroup;	/* ID of assigned memory cgroup */
> >  	unsigned short blk_cgroup;	/* Not Used..but will be. */
> >  	struct page *page;
> > @@ -90,6 +96,16 @@ static inline enum zone_type page_cgroup
> >  	return page_zonenum(pc->page);
> >  }
> >  
> > +#ifdef PCG_HAS_SPINLOCK
> > +static inline void lock_page_cgroup(struct page_cgroup *pc)
> > +{
> > +	spin_lock(&pc->lock);
> > +}
> 
> This is minor issue, but this patch breaks usage of PageCgroupLocked().
> Example from __mem_cgroup_move_account() cases panic:
> 	VM_BUG_ON(!PageCgroupLocked(pc));
> 
> I assume that this patch should also delete the following:
> - PCG_LOCK definition from page_cgroup.h
> - TESTPCGFLAG(Locked, LOCK) from page_cgroup.h
> - PCGF_LOCK from memcontrol.c
> 

yes. thank you.

-Kame



> > +static inline void unlock_page_cgroup(struct page_cgroup *pc)
> > +{
> > +	spin_unlock(&pc->lock);
> > +}
> > +#else
> >  static inline void lock_page_cgroup(struct page_cgroup *pc)
> >  {
> >  	bit_spin_lock(PCG_LOCK, &pc->flags);
> > @@ -99,6 +115,7 @@ static inline void unlock_page_cgroup(st
> >  {
> >  	bit_spin_unlock(PCG_LOCK, &pc->flags);
> >  }
> > +#endif
> >  
> >  static inline void SetPCGFileFlag(struct page_cgroup *pc, int idx)
> >  {
> > Index: mmotm-0719/mm/page_cgroup.c
> > ===================================================================
> > --- mmotm-0719.orig/mm/page_cgroup.c
> > +++ mmotm-0719/mm/page_cgroup.c
> > @@ -17,6 +17,9 @@ __init_page_cgroup(struct page_cgroup *p
> >  	pc->mem_cgroup = 0;
> >  	pc->page = pfn_to_page(pfn);
> >  	INIT_LIST_HEAD(&pc->lru);
> > +#ifdef PCG_HAS_SPINLOCK
> > +	spin_lock_init(&pc->lock);
> > +#endif
> >  }
> >  static unsigned long total_usage;
> >  
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
