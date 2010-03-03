Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D37516B0047
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 01:07:22 -0500 (EST)
Date: Wed, 3 Mar 2010 15:01:37 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mmotm 3/3] memcg: dirty pages instrumentation
Message-Id: <20100303150137.f56d7084.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100303122906.9c613ab2.kamezawa.hiroyu@jp.fujitsu.com>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
	<1267478620-5276-4-git-send-email-arighi@develer.com>
	<20100303111238.7133f8af.nishimura@mxp.nes.nec.co.jp>
	<20100303122906.9c613ab2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Mar 2010 12:29:06 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 3 Mar 2010 11:12:38 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > > diff --git a/mm/filemap.c b/mm/filemap.c
> > > index fe09e51..f85acae 100644
> > > --- a/mm/filemap.c
> > > +++ b/mm/filemap.c
> > > @@ -135,6 +135,7 @@ void __remove_from_page_cache(struct page *page)
> > >  	 * having removed the page entirely.
> > >  	 */
> > >  	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
> > > +		mem_cgroup_update_stat(page, MEM_CGROUP_STAT_FILE_DIRTY, -1);
> > >  		dec_zone_page_state(page, NR_FILE_DIRTY);
> > >  		dec_bdi_stat(mapping->backing_dev_info, BDI_DIRTY);
> > >  	}
> > (snip)
> > > @@ -1096,6 +1113,7 @@ int __set_page_dirty_no_writeback(struct page *page)
> > >  void account_page_dirtied(struct page *page, struct address_space *mapping)
> > >  {
> > >  	if (mapping_cap_account_dirty(mapping)) {
> > > +		mem_cgroup_update_stat(page, MEM_CGROUP_STAT_FILE_DIRTY, 1);
> > >  		__inc_zone_page_state(page, NR_FILE_DIRTY);
> > >  		__inc_bdi_stat(mapping->backing_dev_info, BDI_DIRTY);
> > >  		task_dirty_inc(current);
> > As long as I can see, those two functions(at least) calls mem_cgroup_update_state(),
> > which acquires page cgroup lock, under mapping->tree_lock.
> > But as I fixed before in commit e767e056, page cgroup lock must not acquired under
> > mapping->tree_lock.
> > hmm, we should call those mem_cgroup_update_state() outside mapping->tree_lock,
> > or add local_irq_save/restore() around lock/unlock_page_cgroup() to avoid dead-lock.
> > 
> Ah, good catch! But hmmmmmm...
> This account_page_dirtted() seems to be called under IRQ-disabled.
> About  __remove_from_page_cache(), I think page_cgroup should have its own DIRTY flag,
> then, mem_cgroup_uncharge_page() can handle it automatically.
> 
> But. there are no guarantee that following never happens. 
> 	lock_page_cgroup()
> 	    <=== interrupt.
> 	    -> mapping->tree_lock()
> Even if mapping->tree_lock is held with IRQ-disabled.
> Then, if we add local_irq_save(), we have to add it to all lock_page_cgroup().
> 
> Then, hm...some kind of new trick ? as..
> (Follwoing patch is not tested!!)
> 
If we can verify that all callers of mem_cgroup_update_stat() have always either aquired
or not aquired tree_lock, this direction will work fine.
But if we can't, we have to add local_irq_save() to lock_page_cgroup() like below.

===
 include/linux/page_cgroup.h |    8 ++++++--
 mm/memcontrol.c             |   43 +++++++++++++++++++++++++------------------
 2 files changed, 31 insertions(+), 20 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 30b0813..51da916 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -83,15 +83,19 @@ static inline enum zone_type page_cgroup_zid(struct page_cgroup *pc)
 	return page_zonenum(pc->page);
 }
 
-static inline void lock_page_cgroup(struct page_cgroup *pc)
+static inline void __lock_page_cgroup(struct page_cgroup *pc)
 {
 	bit_spin_lock(PCG_LOCK, &pc->flags);
 }
+#define lock_page_cgroup(pc, flags) \
+  do { local_irq_save(flags); __lock_page_cgroup(pc); } while (0)
 
-static inline void unlock_page_cgroup(struct page_cgroup *pc)
+static inline void __unlock_page_cgroup(struct page_cgroup *pc)
 {
 	bit_spin_unlock(PCG_LOCK, &pc->flags);
 }
+#define unlock_page_cgroup(pc, flags) \
+  do { __unlock_page_cgroup(pc); local_irq_restore(flags); } while (0)
 
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct page_cgroup;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 00ed4b1..40b9be4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1327,12 +1327,13 @@ void mem_cgroup_update_file_mapped(struct page *page, int val)
 {
 	struct mem_cgroup *mem;
 	struct page_cgroup *pc;
+	unsigned long flags;
 
 	pc = lookup_page_cgroup(page);
 	if (unlikely(!pc))
 		return;
 
-	lock_page_cgroup(pc);
+	lock_page_cgroup(pc, flags);
 	mem = pc->mem_cgroup;
 	if (!mem)
 		goto done;
@@ -1346,7 +1347,7 @@ void mem_cgroup_update_file_mapped(struct page *page, int val)
 	__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED], val);
 
 done:
-	unlock_page_cgroup(pc);
+	unlock_page_cgroup(pc, flags);
 }
 
 /*
@@ -1680,11 +1681,12 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 	struct page_cgroup *pc;
 	unsigned short id;
 	swp_entry_t ent;
+	unsigned long flags;
 
 	VM_BUG_ON(!PageLocked(page));
 
 	pc = lookup_page_cgroup(page);
-	lock_page_cgroup(pc);
+	lock_page_cgroup(pc, flags);
 	if (PageCgroupUsed(pc)) {
 		mem = pc->mem_cgroup;
 		if (mem && !css_tryget(&mem->css))
@@ -1698,7 +1700,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 			mem = NULL;
 		rcu_read_unlock();
 	}
-	unlock_page_cgroup(pc);
+	unlock_page_cgroup(pc, flags);
 	return mem;
 }
 
@@ -1711,13 +1713,15 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
 				     struct page_cgroup *pc,
 				     enum charge_type ctype)
 {
+	unsigned long flags;
+
 	/* try_charge() can return NULL to *memcg, taking care of it. */
 	if (!mem)
 		return;
 
-	lock_page_cgroup(pc);
+	lock_page_cgroup(pc, flags);
 	if (unlikely(PageCgroupUsed(pc))) {
-		unlock_page_cgroup(pc);
+		unlock_page_cgroup(pc, flags);
 		mem_cgroup_cancel_charge(mem);
 		return;
 	}
@@ -1747,7 +1751,7 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
 
 	mem_cgroup_charge_statistics(mem, pc, true);
 
-	unlock_page_cgroup(pc);
+	unlock_page_cgroup(pc, flags);
 	/*
 	 * "charge_statistics" updated event counter. Then, check it.
 	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
@@ -1817,12 +1821,13 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
 		struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
 {
 	int ret = -EINVAL;
-	lock_page_cgroup(pc);
+	unsigned long flags;
+	lock_page_cgroup(pc, flags);
 	if (PageCgroupUsed(pc) && pc->mem_cgroup == from) {
 		__mem_cgroup_move_account(pc, from, to, uncharge);
 		ret = 0;
 	}
-	unlock_page_cgroup(pc);
+	unlock_page_cgroup(pc, flags);
 	/*
 	 * check events
 	 */
@@ -1949,17 +1954,17 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 	 */
 	if (!(gfp_mask & __GFP_WAIT)) {
 		struct page_cgroup *pc;
-
+		unsigned long flags;
 
 		pc = lookup_page_cgroup(page);
 		if (!pc)
 			return 0;
-		lock_page_cgroup(pc);
+		lock_page_cgroup(pc, flags);
 		if (PageCgroupUsed(pc)) {
-			unlock_page_cgroup(pc);
+			unlock_page_cgroup(pc, flags);
 			return 0;
 		}
-		unlock_page_cgroup(pc);
+		unlock_page_cgroup(pc, flags);
 	}
 
 	if (unlikely(!mm && !mem))
@@ -2141,6 +2146,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem = NULL;
 	struct mem_cgroup_per_zone *mz;
+	unsigned long flags;
 
 	if (mem_cgroup_disabled())
 		return NULL;
@@ -2155,7 +2161,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 	if (unlikely(!pc || !PageCgroupUsed(pc)))
 		return NULL;
 
-	lock_page_cgroup(pc);
+	lock_page_cgroup(pc, flags);
 
 	mem = pc->mem_cgroup;
 
@@ -2194,7 +2200,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 	 */
 
 	mz = page_cgroup_zoneinfo(pc);
-	unlock_page_cgroup(pc);
+	unlock_page_cgroup(pc, flags);
 
 	memcg_check_events(mem, page);
 	/* at swapout, this memcg will be accessed to record to swap */
@@ -2204,7 +2210,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 	return mem;
 
 unlock_out:
-	unlock_page_cgroup(pc);
+	unlock_page_cgroup(pc, flags);
 	return NULL;
 }
 
@@ -2392,17 +2398,18 @@ int mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr)
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem = NULL;
 	int ret = 0;
+	unsigned long flags;
 
 	if (mem_cgroup_disabled())
 		return 0;
 
 	pc = lookup_page_cgroup(page);
-	lock_page_cgroup(pc);
+	lock_page_cgroup(pc, flags);
 	if (PageCgroupUsed(pc)) {
 		mem = pc->mem_cgroup;
 		css_get(&mem->css);
 	}
-	unlock_page_cgroup(pc);
+	unlock_page_cgroup(pc, flags);
 
 	if (mem) {
 		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false);


> ==
> ---
>  include/linux/page_cgroup.h |   14 ++++++++++++++
>  mm/memcontrol.c             |   27 +++++++++++++++++----------
>  2 files changed, 31 insertions(+), 10 deletions(-)
> 
> Index: mmotm-2.6.33-Feb11/include/linux/page_cgroup.h
> ===================================================================
> --- mmotm-2.6.33-Feb11.orig/include/linux/page_cgroup.h
> +++ mmotm-2.6.33-Feb11/include/linux/page_cgroup.h
> @@ -39,6 +39,7 @@ enum {
>  	PCG_CACHE, /* charged as cache */
>  	PCG_USED, /* this object is in use. */
>  	PCG_ACCT_LRU, /* page has been accounted for */
> +	PCG_MIGRATE, /* page cgroup is under memcg account migration */
>  };
>  
>  #define TESTPCGFLAG(uname, lname)			\
> @@ -73,6 +74,8 @@ CLEARPCGFLAG(AcctLRU, ACCT_LRU)
>  TESTPCGFLAG(AcctLRU, ACCT_LRU)
>  TESTCLEARPCGFLAG(AcctLRU, ACCT_LRU)
>  
> +TESTPCGFLAG(Migrate, MIGRATE)
> +
>  static inline int page_cgroup_nid(struct page_cgroup *pc)
>  {
>  	return page_to_nid(pc->page);
> @@ -93,6 +96,17 @@ static inline void unlock_page_cgroup(st
>  	bit_spin_unlock(PCG_LOCK, &pc->flags);
>  }
>  
> +static inline unsigned long page_cgroup_migration_lock(struct page_cgroup *pc)
> +{
> +	local_irq_save(flags);
> +	bit_spin_lock(PCG_MIGRATE, &pc->flags);
> +}
> +static inline void
> +page_cgroup_migration_lock(struct page_cgroup *pc, unsigned long flags)
> +{
> +	bit_spin_lock(PCG_MIGRATE, &pc->flags);
> +	local_irq_restore(flags);
> +}
>  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
>  struct page_cgroup;
>  
> Index: mmotm-2.6.33-Feb11/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.33-Feb11.orig/mm/memcontrol.c
> +++ mmotm-2.6.33-Feb11/mm/memcontrol.c
> @@ -1321,7 +1321,7 @@ bool mem_cgroup_handle_oom(struct mem_cg
>   * Currently used to update mapped file statistics, but the routine can be
>   * generalized to update other statistics as well.
>   */
> -void mem_cgroup_update_file_mapped(struct page *page, int val)
> +void mem_cgroup_update_file_mapped(struct page *page, int val, int locked)
>  {
>  	struct mem_cgroup *mem;
>  	struct page_cgroup *pc;
> @@ -1329,22 +1329,27 @@ void mem_cgroup_update_file_mapped(struc
>  	pc = lookup_page_cgroup(page);
>  	if (unlikely(!pc))
>  		return;
> -
> -	lock_page_cgroup(pc);
> +	/*
> +	 * if locked==1, mapping->tree_lock is held. We don't have to take
> +	 * care of charge/uncharge. just think about migration.
> +	 */
> +	if (!locked)
> +		lock_page_cgroup(pc);
> +	else
> +		page_cgroup_migration_lock(pc);
>  	mem = pc->mem_cgroup;
> -	if (!mem)
> +	if (!mem || !PageCgroupUsed(pc))
>  		goto done;
> -
> -	if (!PageCgroupUsed(pc))
> -		goto done;
> -
>  	/*
>  	 * Preemption is already disabled. We can use __this_cpu_xxx
>  	 */
>  	__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED], val);
>  
>  done:
> -	unlock_page_cgroup(pc);
> +	if (!locked)
> +		lock_page_cgroup(pc);
> +	else
> +		page_cgroup_migration_unlock(pc);
>  }
>  
>  /*
> @@ -1785,7 +1790,8 @@ static void __mem_cgroup_move_account(st
>  	VM_BUG_ON(!PageCgroupLocked(pc));
>  	VM_BUG_ON(!PageCgroupUsed(pc));
>  	VM_BUG_ON(pc->mem_cgroup != from);
> -
> +		
> +	page_cgroup_migration_lock(pc);
>  	page = pc->page;
>  	if (page_mapped(page) && !PageAnon(page)) {
>  		/* Update mapped_file data for mem_cgroup */
> @@ -1802,6 +1808,7 @@ static void __mem_cgroup_move_account(st
>  	/* caller should have done css_get */
>  	pc->mem_cgroup = to;
>  	mem_cgroup_charge_statistics(to, pc, true);
> +	page_cgroup_migration_lock(pc);
>  	/*
>  	 * We charges against "to" which may not have any tasks. Then, "to"
>  	 * can be under rmdir(). But in current implementation, caller of
> 
> 
> 
> 
> Thanks,
> -Kame
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
