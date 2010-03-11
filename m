Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 14C686B00AC
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 02:55:15 -0500 (EST)
Date: Thu, 11 Mar 2010 16:50:20 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH mmotm 2.5/4] memcg: disable irq at page cgroup lock (Re:
 [PATCH -mmotm 3/4] memcg: dirty pages accounting and limiting
 infrastructure)
Message-Id: <20100311165020.86ac904b.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100311151511.579aa8d1.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100308105641.e2e714f4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100308111724.3e48aee3.nishimura@mxp.nes.nec.co.jp>
	<20100308113711.d7a249da.kamezawa.hiroyu@jp.fujitsu.com>
	<20100308170711.4d8b02f0.nishimura@mxp.nes.nec.co.jp>
	<20100308173100.b5997fd4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100309001252.GB13490@linux>
	<20100309091914.4b5f6661.kamezawa.hiroyu@jp.fujitsu.com>
	<20100309102928.9f36d2bb.nishimura@mxp.nes.nec.co.jp>
	<20100309045058.GX3073@balbir.in.ibm.com>
	<20100310104309.c5f9c9a9.nishimura@mxp.nes.nec.co.jp>
	<20100310035624.GP3073@balbir.in.ibm.com>
	<20100311133123.ab10183c.nishimura@mxp.nes.nec.co.jp>
	<20100311134908.48d8b0fc.kamezawa.hiroyu@jp.fujitsu.com>
	<20100311135847.990eee62.nishimura@mxp.nes.nec.co.jp>
	<20100311141300.90b85391.kamezawa.hiroyu@jp.fujitsu.com>
	<20100311151511.579aa8d1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, Andrea Righi <arighi@develer.com>, linux-kernel@vger.kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, Vivek Goyal <vgoyal@redhat.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 11 Mar 2010 15:15:11 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 11 Mar 2010 14:13:00 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Thu, 11 Mar 2010 13:58:47 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > > I'll consider yet another fix for race in account migration if I can.
> > > > 
> > > me too.
> > > 
> > 
> > How about this ? Assume that the race is very rare.
> > 
> > 	1. use trylock when updating statistics.
> > 	   If trylock fails, don't account it.
> > 
> > 	2. add PCG_FLAG for all status as
> > 
> > +	PCG_ACCT_FILE_MAPPED, /* page is accounted as file rss*/
> > +	PCG_ACCT_DIRTY, /* page is dirty */
> > +	PCG_ACCT_WRITEBACK, /* page is being written back to disk */
> > +	PCG_ACCT_WRITEBACK_TEMP, /* page is used as temporary buffer for FUSE */
> > +	PCG_ACCT_UNSTABLE_NFS, /* NFS page not yet committed to the server */
> > 
> > 	3. At reducing counter, check PCG_xxx flags by
> > 	TESTCLEARPCGFLAG()
> > 
> > This is similar to an _used_ method of LRU accounting. And We can think this
> > method's error-range never go too bad number. 
> > 
I agree with you. I've been thinking whether we can remove page cgroup lock
in update_stat as we do in lru handling codes.

> > I think this kind of fuzzy accounting is enough for writeback status.
> > Does anyone need strict accounting ?
> > 
> 
IMHO, we don't need strict accounting.

> How this looks ?
I agree to this direction. One concern is we re-introduce "trylock" again..

Some comments are inlined.

> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, file-mapped is maintaiend. But more generic update function
> will be needed for dirty page accounting.
> 
> For accountig page status, we have to guarantee lock_page_cgroup()
> will be never called under tree_lock held.
> To guarantee that, we use trylock at updating status.
> By this, we do fuzyy accounting, but in almost all case, it's correct.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/memcontrol.h  |    7 +++
>  include/linux/page_cgroup.h |   15 +++++++
>  mm/memcontrol.c             |   88 +++++++++++++++++++++++++++++++++-----------
>  mm/rmap.c                   |    4 +-
>  4 files changed, 90 insertions(+), 24 deletions(-)
> 
> Index: mmotm-2.6.34-Mar9/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.34-Mar9.orig/mm/memcontrol.c
> +++ mmotm-2.6.34-Mar9/mm/memcontrol.c
> @@ -1348,30 +1348,79 @@ bool mem_cgroup_handle_oom(struct mem_cg
>   * Currently used to update mapped file statistics, but the routine can be
>   * generalized to update other statistics as well.
>   */
> -void mem_cgroup_update_file_mapped(struct page *page, int val)
> +void __mem_cgroup_update_stat(struct page_cgroup *pc, int idx, bool charge)
>  {
>  	struct mem_cgroup *mem;
> -	struct page_cgroup *pc;
> -
> -	pc = lookup_page_cgroup(page);
> -	if (unlikely(!pc))
> -		return;
> +	int val;
>  
> -	lock_page_cgroup(pc);
>  	mem = pc->mem_cgroup;
> -	if (!mem)
> -		goto done;
> +	if (!mem || !PageCgroupUsed(pc))
> +		return;
>  
> -	if (!PageCgroupUsed(pc))
> -		goto done;
> +	if (charge)
> +		val = 1;
> +	else
> +		val = -1;
>  
> +	switch (idx) {
> +	case MEMCG_NR_FILE_MAPPED:
> +		if (charge) {
> +			if (!PageCgroupFileMapped(pc))
> +				SetPageCgroupFileMapped(pc);
> +			else
> +				val = 0;
> +		} else {
> +			if (PageCgroupFileMapped(pc))
> +				ClearPageCgroupFileMapped(pc);
> +			else
> +				val = 0;
> +		}
Using !TestSetPageCgroupFileMapped(pc) or TestClearPageCgroupFileMapped(pc) is better ?

> +		idx = MEM_CGROUP_STAT_FILE_MAPPED;
> +		break;
> +	default:
> +		BUG();
> +		break;
> +	}
>  	/*
>  	 * Preemption is already disabled. We can use __this_cpu_xxx
>  	 */
> -	__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED], val);
> +	__this_cpu_add(mem->stat->count[idx], val);
> +}
>  
> -done:
> -	unlock_page_cgroup(pc);
> +void mem_cgroup_update_stat(struct page *page, int idx, bool charge)
> +{
> +	struct page_cgroup *pc;
> +
> +	pc = lookup_page_cgroup(page);
> +	if (unlikely(!pc))
> +		return;
> +
> +	if (trylock_page_cgroup(pc)) {
> +		__mem_cgroup_update_stat(pc, idx, charge);
> +		unlock_page_cgroup(pc);
> +	}
> +	return;
> +}
> +
> +static void mem_cgroup_migrate_stat(struct page_cgroup *pc,
> +	struct mem_cgroup *from, struct mem_cgroup *to)
> +{
> +	preempt_disable();
> +	if (PageCgroupFileMapped(pc)) {
> +		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> +		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> +	}
> +	preempt_enable();
> +}
> +
I think preemption is already disabled here too(by lock_page_cgroup()).

> +static void
> +__mem_cgroup_stat_fixup(struct page_cgroup *pc, struct mem_cgroup *mem)
> +{
> +	/* We'are in uncharge() and lock_page_cgroup */
> +	if (PageCgroupFileMapped(pc)) {
> +		__this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> +		ClearPageCgroupFileMapped(pc);
> +	}
>  }
>  
ditto.

>  /*
> @@ -1810,13 +1859,7 @@ static void __mem_cgroup_move_account(st
>  	VM_BUG_ON(pc->mem_cgroup != from);
>  
>  	page = pc->page;
> -	if (page_mapped(page) && !PageAnon(page)) {
> -		/* Update mapped_file data for mem_cgroup */
> -		preempt_disable();
> -		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> -		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> -		preempt_enable();
> -	}
> +	mem_cgroup_migrate_stat(pc, from, to);
>  	mem_cgroup_charge_statistics(from, pc, false);
>  	if (uncharge)
>  		/* This is not "cancel", but cancel_charge does all we need. */
I welcome this fixup. IIUC, we have stat leak in current implementation.


Thanks,
Daisuke Nishimura.

> @@ -2208,6 +2251,9 @@ __mem_cgroup_uncharge_common(struct page
>  		__do_uncharge(mem, ctype);
>  	if (ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
>  		mem_cgroup_swap_statistics(mem, true);
> +	if (unlikely(PCG_PageStatMask & pc->flags))
> +		__mem_cgroup_stat_fixup(pc, mem);
> +
>  	mem_cgroup_charge_statistics(mem, pc, false);
>  
>  	ClearPageCgroupUsed(pc);
> Index: mmotm-2.6.34-Mar9/include/linux/page_cgroup.h
> ===================================================================
> --- mmotm-2.6.34-Mar9.orig/include/linux/page_cgroup.h
> +++ mmotm-2.6.34-Mar9/include/linux/page_cgroup.h
> @@ -39,6 +39,8 @@ enum {
>  	PCG_CACHE, /* charged as cache */
>  	PCG_USED, /* this object is in use. */
>  	PCG_ACCT_LRU, /* page has been accounted for */
> +	/* for cache-status accounting */
> +	PCG_FILE_MAPPED,
>  };
>  
>  #define TESTPCGFLAG(uname, lname)			\
> @@ -57,6 +59,10 @@ static inline void ClearPageCgroup##unam
>  static inline int TestClearPageCgroup##uname(struct page_cgroup *pc)	\
>  	{ return test_and_clear_bit(PCG_##lname, &pc->flags);  }
>  
> +/* Page/File stat flag mask */
> +#define PCG_PageStatMask	((1 << PCG_FILE_MAPPED))
> +
> +
>  TESTPCGFLAG(Locked, LOCK)
>  
>  /* Cache flag is set only once (at allocation) */
> @@ -73,6 +79,10 @@ CLEARPCGFLAG(AcctLRU, ACCT_LRU)
>  TESTPCGFLAG(AcctLRU, ACCT_LRU)
>  TESTCLEARPCGFLAG(AcctLRU, ACCT_LRU)
>  
> +TESTPCGFLAG(FileMapped, FILE_MAPPED)
> +SETPCGFLAG(FileMapped, FILE_MAPPED)
> +CLEARPCGFLAG(FileMapped, FILE_MAPPED)
> +
>  static inline int page_cgroup_nid(struct page_cgroup *pc)
>  {
>  	return page_to_nid(pc->page);
> @@ -93,6 +103,11 @@ static inline void unlock_page_cgroup(st
>  	bit_spin_unlock(PCG_LOCK, &pc->flags);
>  }
>  
> +static inline int trylock_page_cgroup(struct page_cgroup *pc)
> +{
> +	return bit_spin_trylock(PCG_LOCK, &pc->flags);
> +}
> +
>  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
>  struct page_cgroup;
>  
> Index: mmotm-2.6.34-Mar9/include/linux/memcontrol.h
> ===================================================================
> --- mmotm-2.6.34-Mar9.orig/include/linux/memcontrol.h
> +++ mmotm-2.6.34-Mar9/include/linux/memcontrol.h
> @@ -124,7 +124,12 @@ static inline bool mem_cgroup_disabled(v
>  	return false;
>  }
>  
> -void mem_cgroup_update_file_mapped(struct page *page, int val);
> +enum mem_cgroup_page_stat_item {
> +	MEMCG_NR_FILE_MAPPED,
> +	MEMCG_NR_FILE_NSTAT,
> +};
> +
> +void mem_cgroup_update_stat(struct page *page, int idx, bool charge);
>  unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>  						gfp_t gfp_mask, int nid,
>  						int zid);
> Index: mmotm-2.6.34-Mar9/mm/rmap.c
> ===================================================================
> --- mmotm-2.6.34-Mar9.orig/mm/rmap.c
> +++ mmotm-2.6.34-Mar9/mm/rmap.c
> @@ -829,7 +829,7 @@ void page_add_file_rmap(struct page *pag
>  {
>  	if (atomic_inc_and_test(&page->_mapcount)) {
>  		__inc_zone_page_state(page, NR_FILE_MAPPED);
> -		mem_cgroup_update_file_mapped(page, 1);
> +		mem_cgroup_update_stat(page, MEMCG_NR_FILE_MAPPED, true);
>  	}
>  }
>  
> @@ -861,7 +861,7 @@ void page_remove_rmap(struct page *page)
>  		__dec_zone_page_state(page, NR_ANON_PAGES);
>  	} else {
>  		__dec_zone_page_state(page, NR_FILE_MAPPED);
> -		mem_cgroup_update_file_mapped(page, -1);
> +		mem_cgroup_update_stat(page, MEMCG_NR_FILE_MAPPED, false);
>  	}
>  	/*
>  	 * It would be tidy to reset the PageAnon mapping here,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
