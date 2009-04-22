Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B0C2D6B0047
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 00:42:03 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3M4gf53023821
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 22 Apr 2009 13:42:41 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C556045DD7E
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 13:42:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F29945DD83
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 13:42:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DCF21DB803B
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 13:42:40 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D178E08007
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 13:42:39 +0900 (JST)
Date: Wed, 22 Apr 2009 13:41:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: remove trylock_page_cgroup
Message-Id: <20090422134108.f21e5bba.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090421204104.faf9fc56.akpm@linux-foundation.org>
References: <20090416120316.GG7082@balbir.in.ibm.com>
	<20090417091459.dac2cc39.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417014042.GB18558@balbir.in.ibm.com>
	<20090417110350.3144183d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417034539.GD18558@balbir.in.ibm.com>
	<20090417124951.a8472c86.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417045623.GA3896@balbir.in.ibm.com>
	<20090417141726.a69ebdcc.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417064726.GB3896@balbir.in.ibm.com>
	<20090417155608.eeed1f02.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417141837.GD3896@balbir.in.ibm.com>
	<20090421132551.38e9960a.akpm@linux-foundation.org>
	<20090422090218.6d451a08.kamezawa.hiroyu@jp.fujitsu.com>
	<20090422121641.eb84a07e.kamezawa.hiroyu@jp.fujitsu.com>
	<20090421204104.faf9fc56.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Apr 2009 20:41:04 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 22 Apr 2009 12:16:41 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > How about this ? worth to be tested, I think.
> > -Kame
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Before synchronized-LRU patch, mem cgroup had its own LRU lock.
> > And there was a code which does
> > # assume mz as per zone struct of memcg. 
> > 
> >    spin_lock mz->lru_lock
> > 	lock_page_cgroup(pc).
> >    and
> >    lock_page_cgroup(pc)
> > 	spin_lock mz->lru_lock
> > 
> > because we cannot locate "mz" until we see pc->page_cgroup, we used
> > trylock(). But now, we don't have mz->lru_lock. All cgroup
> > uses zone->lru_lock for handling list. Moreover, manipulation of
> > LRU depends on global LRU now and we can isolate page from LRU by
> > very generic way.(isolate_lru_page()).
> > So, this kind of trylock is not necessary now.
> > 
> > I thought I removed all trylock in synchronized-LRU patch but there
> > is still one. This patch removes trylock used in memcontrol.c and
> > its definition. If someone needs, he should add this again with enough
> > reason.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  include/linux/page_cgroup.h |    5 -----
> >  mm/memcontrol.c             |    3 +--
> >  2 files changed, 1 insertion(+), 7 deletions(-)
> > 
> > Index: mmotm-2.6.30-Apr21/include/linux/page_cgroup.h
> > ===================================================================
> > --- mmotm-2.6.30-Apr21.orig/include/linux/page_cgroup.h
> > +++ mmotm-2.6.30-Apr21/include/linux/page_cgroup.h
> > @@ -61,11 +61,6 @@ static inline void lock_page_cgroup(stru
> >  	bit_spin_lock(PCG_LOCK, &pc->flags);
> >  }
> >  
> > -static inline int trylock_page_cgroup(struct page_cgroup *pc)
> > -{
> > -	return bit_spin_trylock(PCG_LOCK, &pc->flags);
> > -}
> > -
> >  static inline void unlock_page_cgroup(struct page_cgroup *pc)
> >  {
> >  	bit_spin_unlock(PCG_LOCK, &pc->flags);
> > Index: mmotm-2.6.30-Apr21/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-2.6.30-Apr21.orig/mm/memcontrol.c
> > +++ mmotm-2.6.30-Apr21/mm/memcontrol.c
> > @@ -1148,8 +1148,7 @@ static int mem_cgroup_move_account(struc
> >  	from_mz =  mem_cgroup_zoneinfo(from, nid, zid);
> >  	to_mz =  mem_cgroup_zoneinfo(to, nid, zid);
> >  
> > -	if (!trylock_page_cgroup(pc))
> > -		return ret;
> > +	lock_page_cgroup(pc);
> >  
> >  	if (!PageCgroupUsed(pc))
> >  		goto out;
> 
> But we can't remove that nasty `while (loop--)' thing?
> 
every call which use isolate_lru_page() should handle isolatation failure.
But its ok to remove force_empty_list()'s loop-- becasue we do retry
in force_empty()
    force_empty()                   # does retry.
      -> force_empty_list()         # does retry.

> I expect that it will reliably fail if the caller is running as
> SCHED_FIFO and the machine is single-CPU, or if we're trying to yield
> to a SCHED_OTHER task which is pinned to this CPU, etc.  The cond_resched()
> won't work.
> 
Hm, signal_pending() is supported now (so special user scan use alaram())
I used yield() before cond_resched() but I was told don't use it.
Should I replace cond_resched() with congestion_wait(HZ/10) or some ?

But I'd like to do that in other patch than this patch bacause it
chages force_empty()'s logic.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
