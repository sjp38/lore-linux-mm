Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C378E6B0088
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 19:12:58 -0500 (EST)
Date: Tue, 9 Mar 2010 01:12:52 +0100
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH -mmotm 3/4] memcg: dirty pages accounting and limiting
 infrastructure
Message-ID: <20100309001252.GB13490@linux>
References: <1267995474-9117-1-git-send-email-arighi@develer.com>
 <1267995474-9117-4-git-send-email-arighi@develer.com>
 <20100308104447.c124c1ff.nishimura@mxp.nes.nec.co.jp>
 <20100308105641.e2e714f4.kamezawa.hiroyu@jp.fujitsu.com>
 <20100308111724.3e48aee3.nishimura@mxp.nes.nec.co.jp>
 <20100308113711.d7a249da.kamezawa.hiroyu@jp.fujitsu.com>
 <20100308170711.4d8b02f0.nishimura@mxp.nes.nec.co.jp>
 <20100308173100.b5997fd4.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100308173100.b5997fd4.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 08, 2010 at 05:31:00PM +0900, KAMEZAWA Hiroyuki wrote:
> On Mon, 8 Mar 2010 17:07:11 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > On Mon, 8 Mar 2010 11:37:11 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > On Mon, 8 Mar 2010 11:17:24 +0900
> > > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > 
> > > > > But IIRC, clear_writeback is done under treelock.... No ?
> > > > > 
> > > > The place where NR_WRITEBACK is updated is out of tree_lock.
> > > > 
> > > >    1311 int test_clear_page_writeback(struct page *page)
> > > >    1312 {
> > > >    1313         struct address_space *mapping = page_mapping(page);
> > > >    1314         int ret;
> > > >    1315
> > > >    1316         if (mapping) {
> > > >    1317                 struct backing_dev_info *bdi = mapping->backing_dev_info;
> > > >    1318                 unsigned long flags;
> > > >    1319
> > > >    1320                 spin_lock_irqsave(&mapping->tree_lock, flags);
> > > >    1321                 ret = TestClearPageWriteback(page);
> > > >    1322                 if (ret) {
> > > >    1323                         radix_tree_tag_clear(&mapping->page_tree,
> > > >    1324                                                 page_index(page),
> > > >    1325                                                 PAGECACHE_TAG_WRITEBACK);
> > > >    1326                         if (bdi_cap_account_writeback(bdi)) {
> > > >    1327                                 __dec_bdi_stat(bdi, BDI_WRITEBACK);
> > > >    1328                                 __bdi_writeout_inc(bdi);
> > > >    1329                         }
> > > >    1330                 }
> > > >    1331                 spin_unlock_irqrestore(&mapping->tree_lock, flags);
> > > >    1332         } else {
> > > >    1333                 ret = TestClearPageWriteback(page);
> > > >    1334         }
> > > >    1335         if (ret)
> > > >    1336                 dec_zone_page_state(page, NR_WRITEBACK);
> > > >    1337         return ret;
> > > >    1338 }
> > > 
> > > We can move this up to under tree_lock. Considering memcg, all our target has "mapping".
> > > 
> > > If we newly account bounce-buffers (for NILFS, FUSE, etc..), which has no ->mapping,
> > > we need much more complex new charge/uncharge theory.
> > > 
> > > But yes, adding new lock scheme seems complicated. (Sorry Andrea.)
> > > My concerns is performance. We may need somehing new re-implementation of
> > > locks/migrate/charge/uncharge.
> > > 
> > I agree. Performance is my concern too.
> > 
> > I made a patch below and measured the time(average of 10 times) of kernel build
> > on tmpfs(make -j8 on 8 CPU machine with 2.6.33 defconfig).
> > 
> > <before>
> > - root cgroup: 190.47 sec
> > - child cgroup: 192.81 sec
> > 
> > <after>
> > - root cgroup: 191.06 sec
> > - child cgroup: 193.06 sec
> > 
> > Hmm... about 0.3% slower for root, 0.1% slower for child.
> > 
> 
> Hmm...accepatable ? (sounds it's in error-range)
> 
> BTW, why local_irq_disable() ? 
> local_irq_save()/restore() isn't better ?

Probably there's not the overhead of saving flags? Anyway, it would make
the code much more readable...

Thanks,
-Andrea


> 
> Thanks,
> -Kame
> 
> > ===
> > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > 
> > In current implementation, we don't have to disable irq at lock_page_cgroup()
> > because the lock is never acquired in interrupt context.
> > But we are going to do it in later patch, so this patch encloses all of
> > lock_page_cgroup()/unlock_page_cgroup() with irq_disabled()/irq_enabled().
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > ---
> >  mm/memcontrol.c |   17 +++++++++++++++++
> >  1 files changed, 17 insertions(+), 0 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 02ea959..e5ae1a1 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1359,6 +1359,7 @@ void mem_cgroup_update_file_mapped(struct page *page, int val)
> >  	if (unlikely(!pc))
> >  		return;
> >  
> > +	local_irq_disable();
> >  	lock_page_cgroup(pc);
> >  	mem = pc->mem_cgroup;
> >  	if (!mem)
> > @@ -1374,6 +1375,7 @@ void mem_cgroup_update_file_mapped(struct page *page, int val)
> >  
> >  done:
> >  	unlock_page_cgroup(pc);
> > +	local_irq_enable();
> >  }
> >  
> >  /*
> > @@ -1711,6 +1713,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
> >  	VM_BUG_ON(!PageLocked(page));
> >  
> >  	pc = lookup_page_cgroup(page);
> > +	local_irq_disable();
> >  	lock_page_cgroup(pc);
> >  	if (PageCgroupUsed(pc)) {
> >  		mem = pc->mem_cgroup;
> > @@ -1726,6 +1729,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
> >  		rcu_read_unlock();
> >  	}
> >  	unlock_page_cgroup(pc);
> > +	local_irq_enable();
> >  	return mem;
> >  }
> >  
> > @@ -1742,9 +1746,11 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
> >  	if (!mem)
> >  		return;
> >  
> > +	local_irq_disable();
> >  	lock_page_cgroup(pc);
> >  	if (unlikely(PageCgroupUsed(pc))) {
> >  		unlock_page_cgroup(pc);
> > +		local_irq_enable();
> >  		mem_cgroup_cancel_charge(mem);
> >  		return;
> >  	}
> > @@ -1775,6 +1781,7 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
> >  	mem_cgroup_charge_statistics(mem, pc, true);
> >  
> >  	unlock_page_cgroup(pc);
> > +	local_irq_enable();
> >  	/*
> >  	 * "charge_statistics" updated event counter. Then, check it.
> >  	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
> > @@ -1844,12 +1851,14 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
> >  		struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
> >  {
> >  	int ret = -EINVAL;
> > +	local_irq_disable();
> >  	lock_page_cgroup(pc);
> >  	if (PageCgroupUsed(pc) && pc->mem_cgroup == from) {
> >  		__mem_cgroup_move_account(pc, from, to, uncharge);
> >  		ret = 0;
> >  	}
> >  	unlock_page_cgroup(pc);
> > +	local_irq_enable();
> >  	/*
> >  	 * check events
> >  	 */
> > @@ -1981,12 +1990,15 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
> >  		pc = lookup_page_cgroup(page);
> >  		if (!pc)
> >  			return 0;
> > +		local_irq_disable();
> >  		lock_page_cgroup(pc);
> >  		if (PageCgroupUsed(pc)) {
> >  			unlock_page_cgroup(pc);
> > +			local_irq_enable();
> >  			return 0;
> >  		}
> >  		unlock_page_cgroup(pc);
> > +		local_irq_enable();
> >  	}
> >  
> >  	if (unlikely(!mm && !mem))
> > @@ -2182,6 +2194,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
> >  	if (unlikely(!pc || !PageCgroupUsed(pc)))
> >  		return NULL;
> >  
> > +	local_irq_disable();
> >  	lock_page_cgroup(pc);
> >  
> >  	mem = pc->mem_cgroup;
> > @@ -2222,6 +2235,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
> >  
> >  	mz = page_cgroup_zoneinfo(pc);
> >  	unlock_page_cgroup(pc);
> > +	local_irq_enable();
> >  
> >  	memcg_check_events(mem, page);
> >  	/* at swapout, this memcg will be accessed to record to swap */
> > @@ -2232,6 +2246,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
> >  
> >  unlock_out:
> >  	unlock_page_cgroup(pc);
> > +	local_irq_enable();
> >  	return NULL;
> >  }
> >  
> > @@ -2424,12 +2439,14 @@ int mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr)
> >  		return 0;
> >  
> >  	pc = lookup_page_cgroup(page);
> > +	local_irq_disable();
> >  	lock_page_cgroup(pc);
> >  	if (PageCgroupUsed(pc)) {
> >  		mem = pc->mem_cgroup;
> >  		css_get(&mem->css);
> >  	}
> >  	unlock_page_cgroup(pc);
> > +	local_irq_enable();
> >  
> >  	if (mem) {
> >  		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false);
> > -- 
> > 1.6.4
> > 
> > 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
