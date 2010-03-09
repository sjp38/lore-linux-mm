Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A47916B00B1
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 04:07:05 -0500 (EST)
Date: Tue, 9 Mar 2010 10:07:01 +0100
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH mmotm 2.5/4] memcg: disable irq at page cgroup lock
 (Re: [PATCH -mmotm 3/4] memcg: dirty pages accounting and limiting
 infrastructure)
Message-ID: <20100309090701.GA1666@linux>
References: <1267995474-9117-4-git-send-email-arighi@develer.com>
 <20100308104447.c124c1ff.nishimura@mxp.nes.nec.co.jp>
 <20100308105641.e2e714f4.kamezawa.hiroyu@jp.fujitsu.com>
 <20100308111724.3e48aee3.nishimura@mxp.nes.nec.co.jp>
 <20100308113711.d7a249da.kamezawa.hiroyu@jp.fujitsu.com>
 <20100308170711.4d8b02f0.nishimura@mxp.nes.nec.co.jp>
 <20100308173100.b5997fd4.kamezawa.hiroyu@jp.fujitsu.com>
 <20100309001252.GB13490@linux>
 <20100309091914.4b5f6661.kamezawa.hiroyu@jp.fujitsu.com>
 <20100309102928.9f36d2bb.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100309102928.9f36d2bb.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 09, 2010 at 10:29:28AM +0900, Daisuke Nishimura wrote:
> On Tue, 9 Mar 2010 09:19:14 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Tue, 9 Mar 2010 01:12:52 +0100
> > Andrea Righi <arighi@develer.com> wrote:
> > 
> > > On Mon, Mar 08, 2010 at 05:31:00PM +0900, KAMEZAWA Hiroyuki wrote:
> > > > On Mon, 8 Mar 2010 17:07:11 +0900
> > > > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > > 
> > > > > On Mon, 8 Mar 2010 11:37:11 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > > > On Mon, 8 Mar 2010 11:17:24 +0900
> > > > > > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > > > > 
> > > > > > > > But IIRC, clear_writeback is done under treelock.... No ?
> > > > > > > > 
> > > > > > > The place where NR_WRITEBACK is updated is out of tree_lock.
> > > > > > > 
> > > > > > >    1311 int test_clear_page_writeback(struct page *page)
> > > > > > >    1312 {
> > > > > > >    1313         struct address_space *mapping = page_mapping(page);
> > > > > > >    1314         int ret;
> > > > > > >    1315
> > > > > > >    1316         if (mapping) {
> > > > > > >    1317                 struct backing_dev_info *bdi = mapping->backing_dev_info;
> > > > > > >    1318                 unsigned long flags;
> > > > > > >    1319
> > > > > > >    1320                 spin_lock_irqsave(&mapping->tree_lock, flags);
> > > > > > >    1321                 ret = TestClearPageWriteback(page);
> > > > > > >    1322                 if (ret) {
> > > > > > >    1323                         radix_tree_tag_clear(&mapping->page_tree,
> > > > > > >    1324                                                 page_index(page),
> > > > > > >    1325                                                 PAGECACHE_TAG_WRITEBACK);
> > > > > > >    1326                         if (bdi_cap_account_writeback(bdi)) {
> > > > > > >    1327                                 __dec_bdi_stat(bdi, BDI_WRITEBACK);
> > > > > > >    1328                                 __bdi_writeout_inc(bdi);
> > > > > > >    1329                         }
> > > > > > >    1330                 }
> > > > > > >    1331                 spin_unlock_irqrestore(&mapping->tree_lock, flags);
> > > > > > >    1332         } else {
> > > > > > >    1333                 ret = TestClearPageWriteback(page);
> > > > > > >    1334         }
> > > > > > >    1335         if (ret)
> > > > > > >    1336                 dec_zone_page_state(page, NR_WRITEBACK);
> > > > > > >    1337         return ret;
> > > > > > >    1338 }
> > > > > > 
> > > > > > We can move this up to under tree_lock. Considering memcg, all our target has "mapping".
> > > > > > 
> > > > > > If we newly account bounce-buffers (for NILFS, FUSE, etc..), which has no ->mapping,
> > > > > > we need much more complex new charge/uncharge theory.
> > > > > > 
> > > > > > But yes, adding new lock scheme seems complicated. (Sorry Andrea.)
> > > > > > My concerns is performance. We may need somehing new re-implementation of
> > > > > > locks/migrate/charge/uncharge.
> > > > > > 
> > > > > I agree. Performance is my concern too.
> > > > > 
> > > > > I made a patch below and measured the time(average of 10 times) of kernel build
> > > > > on tmpfs(make -j8 on 8 CPU machine with 2.6.33 defconfig).
> > > > > 
> > > > > <before>
> > > > > - root cgroup: 190.47 sec
> > > > > - child cgroup: 192.81 sec
> > > > > 
> > > > > <after>
> > > > > - root cgroup: 191.06 sec
> > > > > - child cgroup: 193.06 sec
> > > > > 
> > > > > Hmm... about 0.3% slower for root, 0.1% slower for child.
> > > > > 
> > > > 
> > > > Hmm...accepatable ? (sounds it's in error-range)
> > > > 
> > > > BTW, why local_irq_disable() ? 
> > > > local_irq_save()/restore() isn't better ?
> > > 
> > > Probably there's not the overhead of saving flags? 
> > maybe.
> > 
> > > Anyway, it would make the code much more readable...
> > > 
> > ok.
> > 
> > please go ahead in this direction. Nishimura-san, would you post an
> > independent patch ? If no, Andrea-san, please.
> > 
> This is the updated version.
> 
> Andrea-san, can you merge this into your patch set ?

OK, I'll merge, do some tests and post a new version.

Thanks!
-Andrea

> 
> ===
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> In current implementation, we don't have to disable irq at lock_page_cgroup()
> because the lock is never acquired in interrupt context.
> But we are going to call it in later patch in an interrupt context or with
> irq disabled, so this patch disables irq at lock_page_cgroup() and enables it
> at unlock_page_cgroup().
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  include/linux/page_cgroup.h |   16 ++++++++++++++--
>  mm/memcontrol.c             |   43 +++++++++++++++++++++++++------------------
>  2 files changed, 39 insertions(+), 20 deletions(-)
> 
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 30b0813..0d2f92c 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -83,16 +83,28 @@ static inline enum zone_type page_cgroup_zid(struct page_cgroup *pc)
>  	return page_zonenum(pc->page);
>  }
>  
> -static inline void lock_page_cgroup(struct page_cgroup *pc)
> +static inline void __lock_page_cgroup(struct page_cgroup *pc)
>  {
>  	bit_spin_lock(PCG_LOCK, &pc->flags);
>  }
>  
> -static inline void unlock_page_cgroup(struct page_cgroup *pc)
> +static inline void __unlock_page_cgroup(struct page_cgroup *pc)
>  {
>  	bit_spin_unlock(PCG_LOCK, &pc->flags);
>  }
>  
> +#define lock_page_cgroup(pc, flags)		\
> +	do {					\
> +		local_irq_save(flags);		\
> +		__lock_page_cgroup(pc);		\
> +	} while (0)
> +
> +#define unlock_page_cgroup(pc, flags)		\
> +	do {					\
> +		__unlock_page_cgroup(pc);	\
> +		local_irq_restore(flags);	\
> +	} while (0)
> +
>  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
>  struct page_cgroup;
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 7fab84e..a9fd736 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1352,12 +1352,13 @@ void mem_cgroup_update_file_mapped(struct page *page, int val)
>  {
>  	struct mem_cgroup *mem;
>  	struct page_cgroup *pc;
> +	unsigned long flags;
>  
>  	pc = lookup_page_cgroup(page);
>  	if (unlikely(!pc))
>  		return;
>  
> -	lock_page_cgroup(pc);
> +	lock_page_cgroup(pc, flags);
>  	mem = pc->mem_cgroup;
>  	if (!mem)
>  		goto done;
> @@ -1371,7 +1372,7 @@ void mem_cgroup_update_file_mapped(struct page *page, int val)
>  	__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED], val);
>  
>  done:
> -	unlock_page_cgroup(pc);
> +	unlock_page_cgroup(pc, flags);
>  }
>  
>  /*
> @@ -1705,11 +1706,12 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
>  	struct page_cgroup *pc;
>  	unsigned short id;
>  	swp_entry_t ent;
> +	unsigned long flags;
>  
>  	VM_BUG_ON(!PageLocked(page));
>  
>  	pc = lookup_page_cgroup(page);
> -	lock_page_cgroup(pc);
> +	lock_page_cgroup(pc, flags);
>  	if (PageCgroupUsed(pc)) {
>  		mem = pc->mem_cgroup;
>  		if (mem && !css_tryget(&mem->css))
> @@ -1723,7 +1725,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
>  			mem = NULL;
>  		rcu_read_unlock();
>  	}
> -	unlock_page_cgroup(pc);
> +	unlock_page_cgroup(pc, flags);
>  	return mem;
>  }
>  
> @@ -1736,13 +1738,15 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
>  				     struct page_cgroup *pc,
>  				     enum charge_type ctype)
>  {
> +	unsigned long flags;
> +
>  	/* try_charge() can return NULL to *memcg, taking care of it. */
>  	if (!mem)
>  		return;
>  
> -	lock_page_cgroup(pc);
> +	lock_page_cgroup(pc, flags);
>  	if (unlikely(PageCgroupUsed(pc))) {
> -		unlock_page_cgroup(pc);
> +		unlock_page_cgroup(pc, flags);
>  		mem_cgroup_cancel_charge(mem);
>  		return;
>  	}
> @@ -1772,7 +1776,7 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
>  
>  	mem_cgroup_charge_statistics(mem, pc, true);
>  
> -	unlock_page_cgroup(pc);
> +	unlock_page_cgroup(pc, flags);
>  	/*
>  	 * "charge_statistics" updated event counter. Then, check it.
>  	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
> @@ -1842,12 +1846,13 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
>  		struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
>  {
>  	int ret = -EINVAL;
> -	lock_page_cgroup(pc);
> +	unsigned long flags;
> +	lock_page_cgroup(pc, flags);
>  	if (PageCgroupUsed(pc) && pc->mem_cgroup == from) {
>  		__mem_cgroup_move_account(pc, from, to, uncharge);
>  		ret = 0;
>  	}
> -	unlock_page_cgroup(pc);
> +	unlock_page_cgroup(pc, flags);
>  	/*
>  	 * check events
>  	 */
> @@ -1974,17 +1979,17 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>  	 */
>  	if (!(gfp_mask & __GFP_WAIT)) {
>  		struct page_cgroup *pc;
> -
> +		unsigned long flags;
>  
>  		pc = lookup_page_cgroup(page);
>  		if (!pc)
>  			return 0;
> -		lock_page_cgroup(pc);
> +		lock_page_cgroup(pc, flags);
>  		if (PageCgroupUsed(pc)) {
> -			unlock_page_cgroup(pc);
> +			unlock_page_cgroup(pc, flags);
>  			return 0;
>  		}
> -		unlock_page_cgroup(pc);
> +		unlock_page_cgroup(pc, flags);
>  	}
>  
>  	if (unlikely(!mm && !mem))
> @@ -2166,6 +2171,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>  	struct page_cgroup *pc;
>  	struct mem_cgroup *mem = NULL;
>  	struct mem_cgroup_per_zone *mz;
> +	unsigned long flags;
>  
>  	if (mem_cgroup_disabled())
>  		return NULL;
> @@ -2180,7 +2186,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>  	if (unlikely(!pc || !PageCgroupUsed(pc)))
>  		return NULL;
>  
> -	lock_page_cgroup(pc);
> +	lock_page_cgroup(pc, flags);
>  
>  	mem = pc->mem_cgroup;
>  
> @@ -2219,7 +2225,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>  	 */
>  
>  	mz = page_cgroup_zoneinfo(pc);
> -	unlock_page_cgroup(pc);
> +	unlock_page_cgroup(pc, flags);
>  
>  	memcg_check_events(mem, page);
>  	/* at swapout, this memcg will be accessed to record to swap */
> @@ -2229,7 +2235,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>  	return mem;
>  
>  unlock_out:
> -	unlock_page_cgroup(pc);
> +	unlock_page_cgroup(pc, flags);
>  	return NULL;
>  }
>  
> @@ -2417,17 +2423,18 @@ int mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr)
>  	struct page_cgroup *pc;
>  	struct mem_cgroup *mem = NULL;
>  	int ret = 0;
> +	unsigned long flags;
>  
>  	if (mem_cgroup_disabled())
>  		return 0;
>  
>  	pc = lookup_page_cgroup(page);
> -	lock_page_cgroup(pc);
> +	lock_page_cgroup(pc, flags);
>  	if (PageCgroupUsed(pc)) {
>  		mem = pc->mem_cgroup;
>  		css_get(&mem->css);
>  	}
> -	unlock_page_cgroup(pc);
> +	unlock_page_cgroup(pc, flags);
>  
>  	if (mem) {
>  		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false);
> -- 
> 1.6.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
