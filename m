Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8121E600429
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 19:48:29 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o72NpTfO007441
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 3 Aug 2010 08:51:29 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1868D45DE56
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 08:51:29 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D8D5845DE4F
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 08:51:28 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id ADBDFE38003
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 08:51:28 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 67634E08003
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 08:51:28 +0900 (JST)
Date: Tue, 3 Aug 2010 08:46:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 7/7][memcg] use spin lock instead of bit_spin_lock
 in page_cgroup
Message-Id: <20100803084638.f95f55ed.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100802180911.GZ3863@balbir.in.ibm.com>
References: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100727170225.64f78b15.kamezawa.hiroyu@jp.fujitsu.com>
	<xr93bp9sm8q1.fsf@ninji.mtv.corp.google.com>
	<20100802180911.GZ3863@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Greg Thelen <gthelen@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Aug 2010 23:39:11 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * Greg Thelen <gthelen@google.com> [2010-07-27 23:16:54]:
> 
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
> > 
> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > >
> > > This patch replaces page_cgroup's bit_spinlock with spinlock. In general,
> > > spinlock has good implementation than bit_spin_lock and we should use
> > > it if we have a room for it. In 64bit arch, we have extra 4bytes.
> > > Let's use it.
> > >
> > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > --
> > > Index: mmotm-0719/include/linux/page_cgroup.h
> > > ===================================================================
> > > --- mmotm-0719.orig/include/linux/page_cgroup.h
> > > +++ mmotm-0719/include/linux/page_cgroup.h
> > > @@ -10,8 +10,14 @@
> > >   * All page cgroups are allocated at boot or memory hotplug event,
> > >   * then the page cgroup for pfn always exists.
> > >   */
> > > +#ifdef CONFIG_64BIT
> > > +#define PCG_HAS_SPINLOCK
> > > +#endif
> > >  struct page_cgroup {
> > >  	unsigned long flags;
> > > +#ifdef PCG_HAS_SPINLOCK
> > > +	spinlock_t	lock;
> > > +#endif
> > >  	unsigned short mem_cgroup;	/* ID of assigned memory cgroup */
> > >  	unsigned short blk_cgroup;	/* Not Used..but will be. */
> > >  	struct page *page;
> > > @@ -90,6 +96,16 @@ static inline enum zone_type page_cgroup
> > >  	return page_zonenum(pc->page);
> > >  }
> > >  
> > > +#ifdef PCG_HAS_SPINLOCK
> > > +static inline void lock_page_cgroup(struct page_cgroup *pc)
> > > +{
> > > +	spin_lock(&pc->lock);
> > > +}
> > 
> > This is minor issue, but this patch breaks usage of PageCgroupLocked().
> > Example from __mem_cgroup_move_account() cases panic:
> > 	VM_BUG_ON(!PageCgroupLocked(pc));
> > 
> > I assume that this patch should also delete the following:
> > - PCG_LOCK definition from page_cgroup.h
> > - TESTPCGFLAG(Locked, LOCK) from page_cgroup.h
> > - PCGF_LOCK from memcontrol.c
> >
> 
> 
> Good catch! But from my understanding of the code we use spinlock_t
> only for 64 bit systems, so we still need the PCG* and TESTPGFLAGS.
>  
The latest sets have proper calls.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
