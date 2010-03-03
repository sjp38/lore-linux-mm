Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 19DE96B0078
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 18:28:58 -0500 (EST)
Date: Thu, 4 Mar 2010 08:25:14 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mmotm 3/3] memcg: dirty pages instrumentation
Message-Id: <20100304082514.e2af30b4.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100303220319.GA2706@linux>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
	<1267478620-5276-4-git-send-email-arighi@develer.com>
	<20100303111238.7133f8af.nishimura@mxp.nes.nec.co.jp>
	<20100303122906.9c613ab2.kamezawa.hiroyu@jp.fujitsu.com>
	<20100303150137.f56d7084.nishimura@mxp.nes.nec.co.jp>
	<20100303151549.5d3d686a.kamezawa.hiroyu@jp.fujitsu.com>
	<20100303172132.fc6d9387.kamezawa.hiroyu@jp.fujitsu.com>
	<20100303220319.GA2706@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <arighi@develer.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Greg@smtp1.linux-foundation.org, Suleiman Souhlal <suleiman@google.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Mar 2010 23:03:19 +0100, Andrea Righi <arighi@develer.com> wrote:
> On Wed, Mar 03, 2010 at 05:21:32PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Wed, 3 Mar 2010 15:15:49 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > Agreed.
> > > Let's try how we can write a code in clean way. (we have time ;)
> > > For now, to me, IRQ disabling while lock_page_cgroup() seems to be a little
> > > over killing. What I really want is lockless code...but it seems impossible
> > > under current implementation.
> > > 
> > > I wonder the fact "the page is never unchareged under us" can give us some chances
> > > ...Hmm.
> > > 
> > 
> > How about this ? Basically, I don't like duplicating information...so,
> > # of new pcg_flags may be able to be reduced.
> > 
> > I'm glad this can be a hint for Andrea-san.
> > 
> > ==
> > ---
> >  include/linux/page_cgroup.h |   44 ++++++++++++++++++++-
> >  mm/memcontrol.c             |   91 +++++++++++++++++++++++++++++++++++++++++++-
> >  2 files changed, 132 insertions(+), 3 deletions(-)
> > 
> > Index: mmotm-2.6.33-Mar2/include/linux/page_cgroup.h
> > ===================================================================
> > --- mmotm-2.6.33-Mar2.orig/include/linux/page_cgroup.h
> > +++ mmotm-2.6.33-Mar2/include/linux/page_cgroup.h
> > @@ -39,6 +39,11 @@ enum {
> >  	PCG_CACHE, /* charged as cache */
> >  	PCG_USED, /* this object is in use. */
> >  	PCG_ACCT_LRU, /* page has been accounted for */
> > +	PCG_MIGRATE_LOCK, /* used for mutual execution of account migration */
> > +	PCG_ACCT_DIRTY,
> > +	PCG_ACCT_WB,
> > +	PCG_ACCT_WB_TEMP,
> > +	PCG_ACCT_UNSTABLE,
> >  };
> >  
> >  #define TESTPCGFLAG(uname, lname)			\
> > @@ -73,6 +78,23 @@ CLEARPCGFLAG(AcctLRU, ACCT_LRU)
> >  TESTPCGFLAG(AcctLRU, ACCT_LRU)
> >  TESTCLEARPCGFLAG(AcctLRU, ACCT_LRU)
> >  
> > +SETPCGFLAG(AcctDirty, ACCT_DIRTY);
> > +CLEARPCGFLAG(AcctDirty, ACCT_DIRTY);
> > +TESTPCGFLAG(AcctDirty, ACCT_DIRTY);
> > +
> > +SETPCGFLAG(AcctWB, ACCT_WB);
> > +CLEARPCGFLAG(AcctWB, ACCT_WB);
> > +TESTPCGFLAG(AcctWB, ACCT_WB);
> > +
> > +SETPCGFLAG(AcctWBTemp, ACCT_WB_TEMP);
> > +CLEARPCGFLAG(AcctWBTemp, ACCT_WB_TEMP);
> > +TESTPCGFLAG(AcctWBTemp, ACCT_WB_TEMP);
> > +
> > +SETPCGFLAG(AcctUnstableNFS, ACCT_UNSTABLE);
> > +CLEARPCGFLAG(AcctUnstableNFS, ACCT_UNSTABLE);
> > +TESTPCGFLAG(AcctUnstableNFS, ACCT_UNSTABLE);
> > +
> > +
> >  static inline int page_cgroup_nid(struct page_cgroup *pc)
> >  {
> >  	return page_to_nid(pc->page);
> > @@ -82,7 +104,9 @@ static inline enum zone_type page_cgroup
> >  {
> >  	return page_zonenum(pc->page);
> >  }
> > -
> > +/*
> > + * lock_page_cgroup() should not be held under mapping->tree_lock
> > + */
> >  static inline void lock_page_cgroup(struct page_cgroup *pc)
> >  {
> >  	bit_spin_lock(PCG_LOCK, &pc->flags);
> > @@ -93,6 +117,24 @@ static inline void unlock_page_cgroup(st
> >  	bit_spin_unlock(PCG_LOCK, &pc->flags);
> >  }
> >  
> > +/*
> > + * Lock order is
> > + * 	lock_page_cgroup()
> > + * 		lock_page_cgroup_migrate()
> > + * This lock is not be lock for charge/uncharge but for account moving.
> > + * i.e. overwrite pc->mem_cgroup. The lock owner should guarantee by itself
> > + * the page is uncharged while we hold this.
> > + */
> > +static inline void lock_page_cgroup_migrate(struct page_cgroup *pc)
> > +{
> > +	bit_spin_lock(PCG_MIGRATE_LOCK, &pc->flags);
> > +}
> > +
> > +static inline void unlock_page_cgroup_migrate(struct page_cgroup *pc)
> > +{
> > +	bit_spin_unlock(PCG_MIGRATE_LOCK, &pc->flags);
> > +}
> > +
> >  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
> >  struct page_cgroup;
> >  
> > Index: mmotm-2.6.33-Mar2/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-2.6.33-Mar2.orig/mm/memcontrol.c
> > +++ mmotm-2.6.33-Mar2/mm/memcontrol.c
> > @@ -87,6 +87,10 @@ enum mem_cgroup_stat_index {
> >  	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
> >  	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> >  	MEM_CGROUP_EVENTS,	/* incremented at every  pagein/pageout */
> > +	MEM_CGROUP_STAT_DIRTY,
> > +	MEM_CGROUP_STAT_WBACK,
> > +	MEM_CGROUP_STAT_WBACK_TEMP,
> > +	MEM_CGROUP_STAT_UNSTABLE_NFS,
> >  
> >  	MEM_CGROUP_STAT_NSTATS,
> >  };
> > @@ -1360,6 +1364,86 @@ done:
> >  }
> >  
> >  /*
> > + * Update file cache's status for memcg. Before calling this,
> > + * mapping->tree_lock should be held and preemption is disabled.
> > + * Then, it's guarnteed that the page is not uncharged while we
> > + * access page_cgroup. We can make use of that.
> > + */
> > +void mem_cgroup_update_stat_locked(struct page *page, int idx, bool set)
> > +{
> > +	struct page_cgroup *pc;
> > +	struct mem_cgroup *mem;
> > +
> > +	pc = lookup_page_cgroup(page);
> > +	/* Not accounted ? */
> > +	if (!PageCgroupUsed(pc))
> > +		return;
> > +	lock_page_cgroup_migrate(pc);
> > +	/*
> > +	 * It's guarnteed that this page is never uncharged.
> > +	 * The only racy problem is moving account among memcgs.
> > +	 */
> > +	switch (idx) {
> > +	case MEM_CGROUP_STAT_DIRTY:
> > +		if (set)
> > +			SetPageCgroupAcctDirty(pc);
> > +		else
> > +			ClearPageCgroupAcctDirty(pc);
> > +		break;
> > +	case MEM_CGROUP_STAT_WBACK:
> > +		if (set)
> > +			SetPageCgroupAcctWB(pc);
> > +		else
> > +			ClearPageCgroupAcctWB(pc);
> > +		break;
> > +	case MEM_CGROUP_STAT_WBACK_TEMP:
> > +		if (set)
> > +			SetPageCgroupAcctWBTemp(pc);
> > +		else
> > +			ClearPageCgroupAcctWBTemp(pc);
> > +		break;
> > +	case MEM_CGROUP_STAT_UNSTABLE_NFS:
> > +		if (set)
> > +			SetPageCgroupAcctUnstableNFS(pc);
> > +		else
> > +			ClearPageCgroupAcctUnstableNFS(pc);
> > +		break;
> > +	default:
> > +		BUG();
> > +		break;
> > +	}
> > +	mem = pc->mem_cgroup;
> > +	if (set)
> > +		__this_cpu_inc(mem->stat->count[idx]);
> > +	else
> > +		__this_cpu_dec(mem->stat->count[idx]);
> > +	unlock_page_cgroup_migrate(pc);
> > +}
> > +
> > +static void move_acct_information(struct mem_cgroup *from,
> > +				struct mem_cgroup *to,
> > +				struct page_cgroup *pc)
> > +{
> > +	/* preemption is disabled, migration_lock is held. */
> > +	if (PageCgroupAcctDirty(pc)) {
> > +		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_DIRTY]);
> > +		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_DIRTY]);
> > +	}
> > +	if (PageCgroupAcctWB(pc)) {
> > +		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_WBACK]);
> > +		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_WBACK]);
> > +	}
> > +	if (PageCgroupAcctWBTemp(pc)) {
> > +		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_WBACK_TEMP]);
> > +		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_WBACK_TEMP]);
> > +	}
> > +	if (PageCgroupAcctUnstableNFS(pc)) {
> > +		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_UNSTABLE_NFS]);
> > +		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_UNSTABLE_NFS]);
> > +	}
> > +}
> > +
> > +/*
> >   * size of first charge trial. "32" comes from vmscan.c's magic value.
> >   * TODO: maybe necessary to use big numbers in big irons.
> >   */
> > @@ -1794,15 +1878,16 @@ static void __mem_cgroup_move_account(st
> >  	VM_BUG_ON(!PageCgroupUsed(pc));
> >  	VM_BUG_ON(pc->mem_cgroup != from);
> >  
> > +	preempt_disable();
> > +	lock_page_cgroup_migrate(pc);
> >  	page = pc->page;
> >  	if (page_mapped(page) && !PageAnon(page)) {
> >  		/* Update mapped_file data for mem_cgroup */
> > -		preempt_disable();
> >  		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> >  		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> > -		preempt_enable();
> >  	}
> >  	mem_cgroup_charge_statistics(from, pc, false);
> > +	move_acct_information(from, to, pc);
> 
> Kame-san, a question. According to is_target_pte_for_mc() it seems we
> don't move file pages across cgroups for now. If !PageAnon(page) we just
> return 0 and the page won't be selected for migration in
> mem_cgroup_move_charge_pte_range().
> 
You're right. It's my TODO to move file pages at task migration.

> So, if I've understood well the code is correct in perspective, but
> right now it's unnecessary. File pages are not moved on task migration
> across cgroups and, at the moment, there's no way for file page
> accounted statistics to go negative.
> 
> Or am I missing something?
> 
__mem_cgroup_move_account() will be called not only at task migration
but also at rmdir, so I think it would be better to handle file pages anyway.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
