Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C14306B00EE
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 17:20:43 -0500 (EST)
Date: Thu, 11 Mar 2010 23:20:37 +0100
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH -mmotm 0/5] memcg: per cgroup dirty limit (v6)
Message-ID: <20100311222036.GA2427@linux>
References: <1268175636-4673-1-git-send-email-arighi@develer.com>
 <20100311093913.07c9ca8a.kamezawa.hiroyu@jp.fujitsu.com>
 <20100311101726.f58d24e9.kamezawa.hiroyu@jp.fujitsu.com>
 <1268298865.5279.997.camel@twins>
 <20100311182500.0f3ba994.kamezawa.hiroyu@jp.fujitsu.com>
 <20100311184244.6735076a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100311184244.6735076a.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Vivek Goyal <vgoyal@redhat.com>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 11, 2010 at 06:42:44PM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 11 Mar 2010 18:25:00 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Then, it's not problem that check pc->mem_cgroup is root cgroup or not
> > without spinlock.
> > ==
> > void mem_cgroup_update_stat(struct page *page, int idx, bool charge)
> > {
> > 	pc = lookup_page_cgroup(page);
> > 	if (unlikely(!pc) || mem_cgroup_is_root(pc->mem_cgroup))
> > 		return;	
> > 	...
> > }
> > ==
> > This can be handle in the same logic of "lock failure" path.
> > And we just do ignore accounting.
> > 
> > There are will be no spinlocks....to do more than this,
> > I think we have to use "struct page" rather than "struct page_cgroup".
> > 
> Hmm..like this ? The bad point of this patch is that this will corrupt FILE_MAPPED
> status in root cgroup. This kind of change is not very good.
> So, one way is to use this kind of function only for new parameters. Hmm.

This kind of accouting shouldn't be a big problem for the dirty memory
write-out. The benefit in terms of performance is much more important I
think.

The missing accounting of root cgroup statistics could be an issue if we
move a lot of pages from root cgroup into a child cgroup (when migration
of file cache pages will be supported and enabled). But at worst we'll
continue to write-out pages using the global settings. Remember that
memcg dirty memory is always the min(memcg_dirty_memory, total_dirty_memory),
so even if we're leaking dirty memory accounting at worst we'll touch
the global dirty limit and fallback to the current write-out
implementation.

I'll merge this patch, re-run some tests (kernel build and large file
copy) and post a new version.

Unfortunately at the moment I've not a big machine to use for these
tests, but maybe I can get some help. Vivek has probably a nice hardware
to test this code.. ;)

Thanks!
-Andrea

> ==
> 
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
> Changelog:
>  - removed unnecessary preempt_disable()
>  - added root cgroup check. By this, we do no lock/account in root cgroup.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/memcontrol.h  |    7 ++-
>  include/linux/page_cgroup.h |   15 +++++++
>  mm/memcontrol.c             |   92 +++++++++++++++++++++++++++++++++-----------
>  mm/rmap.c                   |    4 -
>  4 files changed, 94 insertions(+), 24 deletions(-)
> 
> Index: mmotm-2.6.34-Mar9/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.34-Mar9.orig/mm/memcontrol.c
> +++ mmotm-2.6.34-Mar9/mm/memcontrol.c
> @@ -1348,30 +1348,83 @@ bool mem_cgroup_handle_oom(struct mem_cg
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
> +	if (!pc || mem_cgroup_is_root(pc->mem_cgroup))
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
> +	if (PageCgroupFileMapped(pc)) {
> +		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> +		if (!mem_cgroup_is_root(to)) {
> +			__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> +		} else {
> +			ClearPageCgroupFileMapped(pc);
> +		}
> +	}
> +}
> +
> +static void
> +__mem_cgroup_stat_fixup(struct page_cgroup *pc, struct mem_cgroup *mem)
> +{
> +	if (mem_cgroup_is_root(mem))
> +		return;
> +	/* We'are in uncharge() and lock_page_cgroup */
> +	if (PageCgroupFileMapped(pc)) {
> +		__this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> +		ClearPageCgroupFileMapped(pc);
> +	}
>  }
>  
>  /*
> @@ -1810,13 +1863,7 @@ static void __mem_cgroup_move_account(st
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
> @@ -2208,6 +2255,9 @@ __mem_cgroup_uncharge_common(struct page
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
