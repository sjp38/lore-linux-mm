Date: Tue, 19 Feb 2008 16:26:10 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid
 races.
In-Reply-To: <17878602.1203436460680.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0802191605500.16579@blonde.site>
References: <Pine.LNX.4.64.0802191449490.6254@blonde.site>
 <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
 <17878602.1203436460680.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, balbir@linux.vnet.ibm.com, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 20 Feb 2008, kamezawa.hiroyu@jp.fujitsu.com wrote:
> >How should I proceed now?  I think it's best if I press ahead with
> >my patchset, to get that out on to the list; and only then come
> >back to look at yours, while you can be looking at mine.  Then
> >we take the best out of both and push that forward - this does
> >need to be fixed for 2.6.25.
> >
> I'm very glad to hear that you have been working on this already.
> 
> I think it's better to test your one at first because it sounds
> you've already seem the BUG much more than I've seen and
> I think my patch will need more work to be simple.
> 
> Could you post your one ? I'll try it on my box.

Okay, thanks, on the understanding that I may decide things differently
in splitting it up.  And you'll immediately see why I need to split it:
there's several unrelated mods across that area, and a lot of cleanup
(another cleanup I'd like to make but held back from, is remove the
"_page" from mem_cgroup_uncharge_page).

One thing I've already reverted while splitting it: mm/memory.c still
needs to use page_assign_page_cgroup, not in initializing the struct
pages, but its VM_BUG_ON(page_get_page_cgroup) needs to become a bad
page state instead - because most people build without DEBUG_VM, and
page->cgroup must be reset before the next user corrupts through it.

There's a build warning on mem in charge_common which I want to get
rid of; and I've not yet decided if I like that restructuring or not.

Hugh

diff -purN 26252/include/linux/memcontrol.h 26252h/include/linux/memcontrol.h
--- 26252/include/linux/memcontrol.h	2008-02-11 07:18:10.000000000 +0000
+++ 26252h/include/linux/memcontrol.h	2008-02-17 13:05:03.000000000 +0000
@@ -32,14 +32,11 @@ struct mm_struct;
 
 extern void mm_init_cgroup(struct mm_struct *mm, struct task_struct *p);
 extern void mm_free_cgroup(struct mm_struct *mm);
-extern void page_assign_page_cgroup(struct page *page,
-					struct page_cgroup *pc);
 extern struct page_cgroup *page_get_page_cgroup(struct page *page);
 extern int mem_cgroup_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask);
-extern void mem_cgroup_uncharge(struct page_cgroup *pc);
 extern void mem_cgroup_uncharge_page(struct page *page);
-extern void mem_cgroup_move_lists(struct page_cgroup *pc, bool active);
+extern void mem_cgroup_move_lists(struct page *page, bool active);
 extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct list_head *dst,
 					unsigned long *scanned, int order,
@@ -51,7 +48,7 @@ extern int mem_cgroup_cache_charge(struc
 					gfp_t gfp_mask);
 int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
 
-#define vm_match_cgroup(mm, cgroup)	\
+#define mm_match_cgroup(mm, cgroup)	\
 	((cgroup) == rcu_dereference((mm)->mem_cgroup))
 
 extern int mem_cgroup_prepare_migration(struct page *page);
@@ -85,11 +82,6 @@ static inline void mm_free_cgroup(struct
 {
 }
 
-static inline void page_assign_page_cgroup(struct page *page,
-						struct page_cgroup *pc)
-{
-}
-
 static inline struct page_cgroup *page_get_page_cgroup(struct page *page)
 {
 	return NULL;
@@ -101,16 +93,11 @@ static inline int mem_cgroup_charge(stru
 	return 0;
 }
 
-static inline void mem_cgroup_uncharge(struct page_cgroup *pc)
-{
-}
-
 static inline void mem_cgroup_uncharge_page(struct page *page)
 {
 }
 
-static inline void mem_cgroup_move_lists(struct page_cgroup *pc,
-						bool active)
+static inline void mem_cgroup_move_lists(struct page *page, bool active)
 {
 }
 
@@ -121,7 +108,7 @@ static inline int mem_cgroup_cache_charg
 	return 0;
 }
 
-static inline int vm_match_cgroup(struct mm_struct *mm, struct mem_cgroup *mem)
+static inline int mm_match_cgroup(struct mm_struct *mm, struct mem_cgroup *mem)
 {
 	return 1;
 }
diff -purN 26252/mm/memcontrol.c 26252h/mm/memcontrol.c
--- 26252/mm/memcontrol.c	2008-02-11 07:18:12.000000000 +0000
+++ 26252h/mm/memcontrol.c	2008-02-17 13:31:53.000000000 +0000
@@ -137,6 +137,7 @@ struct mem_cgroup {
 	 */
 	struct mem_cgroup_stat stat;
 };
+static struct mem_cgroup init_mem_cgroup;
 
 /*
  * We use the lower bit of the page->page_cgroup pointer as a bit spin
@@ -144,7 +145,7 @@ struct mem_cgroup {
  * byte aligned (based on comments from Nick Piggin)
  */
 #define PAGE_CGROUP_LOCK_BIT 	0x0
-#define PAGE_CGROUP_LOCK 		(1 << PAGE_CGROUP_LOCK_BIT)
+#define PAGE_CGROUP_LOCK 	(1 << PAGE_CGROUP_LOCK_BIT)
 
 /*
  * A page_cgroup page is associated with every page descriptor. The
@@ -154,37 +155,27 @@ struct page_cgroup {
 	struct list_head lru;		/* per cgroup LRU list */
 	struct page *page;
 	struct mem_cgroup *mem_cgroup;
-	atomic_t ref_cnt;		/* Helpful when pages move b/w  */
-					/* mapped and cached states     */
-	int	 flags;
+	int ref_cnt;			/* cached, mapped, migrating */
+	int flags;
 };
 #define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache */
 #define PAGE_CGROUP_FLAG_ACTIVE (0x2)	/* page is active in this cgroup */
 
-static inline int page_cgroup_nid(struct page_cgroup *pc)
+static int page_cgroup_nid(struct page_cgroup *pc)
 {
 	return page_to_nid(pc->page);
 }
 
-static inline enum zone_type page_cgroup_zid(struct page_cgroup *pc)
+static enum zone_type page_cgroup_zid(struct page_cgroup *pc)
 {
 	return page_zonenum(pc->page);
 }
 
-enum {
-	MEM_CGROUP_TYPE_UNSPEC = 0,
-	MEM_CGROUP_TYPE_MAPPED,
-	MEM_CGROUP_TYPE_CACHED,
-	MEM_CGROUP_TYPE_ALL,
-	MEM_CGROUP_TYPE_MAX,
-};
-
 enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
 	MEM_CGROUP_CHARGE_TYPE_MAPPED,
 };
 
-
 /*
  * Always modified under lru lock. Then, not necessary to preempt_disable()
  */
@@ -193,23 +184,22 @@ static void mem_cgroup_charge_statistics
 {
 	int val = (charge)? 1 : -1;
 	struct mem_cgroup_stat *stat = &mem->stat;
-	VM_BUG_ON(!irqs_disabled());
 
+	VM_BUG_ON(!irqs_disabled());
 	if (flags & PAGE_CGROUP_FLAG_CACHE)
-		__mem_cgroup_stat_add_safe(stat,
-					MEM_CGROUP_STAT_CACHE, val);
+		__mem_cgroup_stat_add_safe(stat, MEM_CGROUP_STAT_CACHE, val);
 	else
 		__mem_cgroup_stat_add_safe(stat, MEM_CGROUP_STAT_RSS, val);
 }
 
-static inline struct mem_cgroup_per_zone *
+static struct mem_cgroup_per_zone *
 mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
 {
-	BUG_ON(!mem->info.nodeinfo[nid]);
+	VM_BUG_ON(!mem->info.nodeinfo[nid]);
 	return &mem->info.nodeinfo[nid]->zoneinfo[zid];
 }
 
-static inline struct mem_cgroup_per_zone *
+static struct mem_cgroup_per_zone *
 page_cgroup_zoneinfo(struct page_cgroup *pc)
 {
 	struct mem_cgroup *mem = pc->mem_cgroup;
@@ -234,18 +224,14 @@ static unsigned long mem_cgroup_get_all_
 	return total;
 }
 
-static struct mem_cgroup init_mem_cgroup;
-
-static inline
-struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
+static struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
 {
 	return container_of(cgroup_subsys_state(cont,
 				mem_cgroup_subsys_id), struct mem_cgroup,
 				css);
 }
 
-static inline
-struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
+static struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
 {
 	return container_of(task_subsys_state(p, mem_cgroup_subsys_id),
 				struct mem_cgroup, css);
@@ -265,83 +251,29 @@ void mm_free_cgroup(struct mm_struct *mm
 	css_put(&mm->mem_cgroup->css);
 }
 
-static inline int page_cgroup_locked(struct page *page)
-{
-	return bit_spin_is_locked(PAGE_CGROUP_LOCK_BIT,
-					&page->page_cgroup);
-}
-
-void page_assign_page_cgroup(struct page *page, struct page_cgroup *pc)
+static void page_assign_page_cgroup(struct page *page, struct page_cgroup *pc)
 {
-	int locked;
-
-	/*
-	 * While resetting the page_cgroup we might not hold the
-	 * page_cgroup lock. free_hot_cold_page() is an example
-	 * of such a scenario
-	 */
-	if (pc)
-		VM_BUG_ON(!page_cgroup_locked(page));
-	locked = (page->page_cgroup & PAGE_CGROUP_LOCK);
-	page->page_cgroup = ((unsigned long)pc | locked);
+	page->page_cgroup = ((unsigned long)pc | PAGE_CGROUP_LOCK);
 }
 
 struct page_cgroup *page_get_page_cgroup(struct page *page)
 {
-	return (struct page_cgroup *)
-		(page->page_cgroup & ~PAGE_CGROUP_LOCK);
+	return (struct page_cgroup *) (page->page_cgroup & ~PAGE_CGROUP_LOCK);
 }
 
-static void __always_inline lock_page_cgroup(struct page *page)
+static void lock_page_cgroup(struct page *page)
 {
 	bit_spin_lock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
-	VM_BUG_ON(!page_cgroup_locked(page));
 }
 
-static void __always_inline unlock_page_cgroup(struct page *page)
+static int try_lock_page_cgroup(struct page *page)
 {
-	bit_spin_unlock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
+	return bit_spin_trylock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
 }
 
-/*
- * Tie new page_cgroup to struct page under lock_page_cgroup()
- * This can fail if the page has been tied to a page_cgroup.
- * If success, returns 0.
- */
-static int page_cgroup_assign_new_page_cgroup(struct page *page,
-						struct page_cgroup *pc)
+static void unlock_page_cgroup(struct page *page)
 {
-	int ret = 0;
-
-	lock_page_cgroup(page);
-	if (!page_get_page_cgroup(page))
-		page_assign_page_cgroup(page, pc);
-	else /* A page is tied to other pc. */
-		ret = 1;
-	unlock_page_cgroup(page);
-	return ret;
-}
-
-/*
- * Clear page->page_cgroup member under lock_page_cgroup().
- * If given "pc" value is different from one page->page_cgroup,
- * page->cgroup is not cleared.
- * Returns a value of page->page_cgroup at lock taken.
- * A can can detect failure of clearing by following
- *  clear_page_cgroup(page, pc) == pc
- */
-
-static struct page_cgroup *clear_page_cgroup(struct page *page,
-						struct page_cgroup *pc)
-{
-	struct page_cgroup *ret;
-	/* lock and clear */
-	lock_page_cgroup(page);
-	ret = page_get_page_cgroup(page);
-	if (likely(ret == pc))
-		page_assign_page_cgroup(page, NULL);
-	unlock_page_cgroup(page);
-	return ret;
+	bit_spin_unlock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
 }
 
 static void __mem_cgroup_remove_list(struct page_cgroup *pc)
@@ -399,7 +331,7 @@ int task_in_mem_cgroup(struct task_struc
 	int ret;
 
 	task_lock(task);
-	ret = task->mm && vm_match_cgroup(task->mm, mem);
+	ret = task->mm && mm_match_cgroup(task->mm, mem);
 	task_unlock(task);
 	return ret;
 }
@@ -407,17 +339,43 @@ int task_in_mem_cgroup(struct task_struc
 /*
  * This routine assumes that the appropriate zone's lru lock is already held
  */
-void mem_cgroup_move_lists(struct page_cgroup *pc, bool active)
+void mem_cgroup_move_lists(struct page *page, bool active)
 {
+	struct page_cgroup *pc;
 	struct mem_cgroup_per_zone *mz;
 	unsigned long flags;
 
-	if (!pc)
+	/*
+	 * We cannot lock_page_cgroup while holding zone's lru_lock,
+	 * because other holders of lock_page_cgroup can be interrupted
+	 * with an attempt to rotate_reclaimable_page.
+	 *
+	 * Change lock_page_cgroup to an interrupt-disabling lock?
+	 * Perhaps, but we'd prefer not.  Hold zone's lru_lock while
+	 * uncharging?  Overhead we'd again prefer to avoid - though
+	 * it may turn out to be just right to uncharge when finally
+	 * removing a page from LRU; but there are probably awkward
+	 * details to that which would need shaking down.
+	 */
+	if (!try_lock_page_cgroup(page))
 		return;
 
-	mz = page_cgroup_zoneinfo(pc);
+	pc = page_get_page_cgroup(page);
+	mz = pc? page_cgroup_zoneinfo(pc): NULL;
+	unlock_page_cgroup(page);
+
+	if (!mz)
+		return;
+
+	/*
+	 * The memory used for this mem_cgroup_per_zone could get
+	 * reused before we take its lru_lock: we probably want to
+	 * use a SLAB_DESTROY_BY_RCU kmem_cache for it.  But that's
+	 * an unlikely race, so for now continue testing without it.
+	 */
 	spin_lock_irqsave(&mz->lru_lock, flags);
-	__mem_cgroup_move_lists(pc, active);
+	if (page_get_page_cgroup(page) == pc)
+		__mem_cgroup_move_lists(pc, active);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
 }
 
@@ -437,6 +395,7 @@ int mem_cgroup_calc_mapped_ratio(struct 
 	rss = (long)mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_RSS);
 	return (int)((rss * 100L) / total);
 }
+
 /*
  * This function is called from vmscan.c. In page reclaiming loop. balance
  * between active and inactive list is calculated. For memory controller
@@ -500,7 +459,6 @@ long mem_cgroup_calc_reclaim_inactive(st
 	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(mem, nid, zid);
 
 	nr_inactive = MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_INACTIVE);
-
 	return (nr_inactive >> priority);
 }
 
@@ -534,7 +492,6 @@ unsigned long mem_cgroup_isolate_pages(u
 		if (scan >= nr_to_scan)
 			break;
 		page = pc->page;
-		VM_BUG_ON(!pc);
 
 		if (unlikely(!PageLRU(page)))
 			continue;
@@ -575,9 +532,11 @@ static int mem_cgroup_charge_common(stru
 {
 	struct mem_cgroup *mem;
 	struct page_cgroup *pc;
+	struct page_cgroup *new_pc = NULL;
 	unsigned long flags;
 	unsigned long nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct mem_cgroup_per_zone *mz;
+	int error;
 
 	/*
 	 * Should page_cgroup's go to their own slab?
@@ -586,31 +545,20 @@ static int mem_cgroup_charge_common(stru
 	 * to see if the cgroup page already has a page_cgroup associated
 	 * with it
 	 */
-retry:
+
 	if (page) {
+		error = 0;
 		lock_page_cgroup(page);
 		pc = page_get_page_cgroup(page);
-		/*
-		 * The page_cgroup exists and
-		 * the page has already been accounted.
-		 */
-		if (pc) {
-			if (unlikely(!atomic_inc_not_zero(&pc->ref_cnt))) {
-				/* this page is under being uncharged ? */
-				unlock_page_cgroup(page);
-				cpu_relax();
-				goto retry;
-			} else {
-				unlock_page_cgroup(page);
-				goto done;
-			}
-		}
+		if (pc)
+			goto incref;
 		unlock_page_cgroup(page);
 	}
 
-	pc = kzalloc(sizeof(struct page_cgroup), gfp_mask);
-	if (pc == NULL)
-		goto err;
+	error = -ENOMEM;
+	new_pc = kzalloc(sizeof(struct page_cgroup), gfp_mask);
+	if (!new_pc)
+		goto done;
 
 	/*
 	 * We always charge the cgroup the mm_struct belongs to.
@@ -624,16 +572,11 @@ retry:
 	rcu_read_lock();
 	mem = rcu_dereference(mm->mem_cgroup);
 	/*
-	 * For every charge from the cgroup, increment reference
-	 * count
+	 * For every charge from the cgroup, increment reference count
 	 */
 	css_get(&mem->css);
 	rcu_read_unlock();
 
-	/*
-	 * If we created the page_cgroup, we should free it on exceeding
-	 * the cgroup limit.
-	 */
 	while (res_counter_charge(&mem->res, PAGE_SIZE)) {
 		if (!(gfp_mask & __GFP_WAIT))
 			goto out;
@@ -642,12 +585,12 @@ retry:
 			continue;
 
 		/*
- 		 * try_to_free_mem_cgroup_pages() might not give us a full
- 		 * picture of reclaim. Some pages are reclaimed and might be
- 		 * moved to swap cache or just unmapped from the cgroup.
- 		 * Check the limit again to see if the reclaim reduced the
- 		 * current usage of the cgroup before giving up
- 		 */
+		 * try_to_free_mem_cgroup_pages() might not give us a full
+		 * picture of reclaim. Some pages are reclaimed and might be
+		 * moved to swap cache or just unmapped from the cgroup.
+		 * Check the limit again to see if the reclaim reduced the
+		 * current usage of the cgroup before giving up
+		 */
 		if (res_counter_check_under_limit(&mem->res))
 			continue;
 
@@ -658,106 +601,101 @@ retry:
 		congestion_wait(WRITE, HZ/10);
 	}
 
-	atomic_set(&pc->ref_cnt, 1);
-	pc->mem_cgroup = mem;
-	pc->page = page;
-	pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
+	error = 0;
+	if (!page)
+		goto out;
+
+	new_pc->ref_cnt = 1;
+	new_pc->mem_cgroup = mem;
+	new_pc->page = page;
+	new_pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
 	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE)
-		pc->flags |= PAGE_CGROUP_FLAG_CACHE;
+		new_pc->flags |= PAGE_CGROUP_FLAG_CACHE;
 
-	if (!page || page_cgroup_assign_new_page_cgroup(page, pc)) {
-		/*
-		 * Another charge has been added to this page already.
-		 * We take lock_page_cgroup(page) again and read
-		 * page->cgroup, increment refcnt.... just retry is OK.
-		 */
-		res_counter_uncharge(&mem->res, PAGE_SIZE);
-		css_put(&mem->css);
-		kfree(pc);
-		if (!page)
-			goto done;
-		goto retry;
-	}
+	lock_page_cgroup(page);
+	pc = page_get_page_cgroup(page);
+	if (!pc) {
+		page_assign_page_cgroup(page, new_pc);
+		unlock_page_cgroup(page);
 
-	mz = page_cgroup_zoneinfo(pc);
-	spin_lock_irqsave(&mz->lru_lock, flags);
-	/* Update statistics vector */
-	__mem_cgroup_add_list(pc);
-	spin_unlock_irqrestore(&mz->lru_lock, flags);
+		mz = page_cgroup_zoneinfo(new_pc);
+		spin_lock_irqsave(&mz->lru_lock, flags);
+		__mem_cgroup_add_list(new_pc);
+		spin_unlock_irqrestore(&mz->lru_lock, flags);
+		goto done;
+	}
 
-done:
-	return 0;
+incref:
+	VM_BUG_ON(pc->page != page);
+	VM_BUG_ON(pc->ref_cnt <= 0);
+	pc->ref_cnt++;
+	unlock_page_cgroup(page);
 out:
-	css_put(&mem->css);
-	kfree(pc);
-err:
-	return -ENOMEM;
+	if (new_pc) {
+		if (!error)
+			res_counter_uncharge(&mem->res, PAGE_SIZE);
+		css_put(&mem->css);
+		kfree(new_pc);
+	}
+done:
+	return error;
 }
 
-int mem_cgroup_charge(struct page *page, struct mm_struct *mm,
-			gfp_t gfp_mask)
+int mem_cgroup_charge(struct page *page, struct mm_struct *mm, gfp_t gfp_mask)
 {
 	return mem_cgroup_charge_common(page, mm, gfp_mask,
 			MEM_CGROUP_CHARGE_TYPE_MAPPED);
 }
 
-/*
- * See if the cached pages should be charged at all?
- */
 int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask)
 {
-	int ret = 0;
 	if (!mm)
 		mm = &init_mm;
-
-	ret = mem_cgroup_charge_common(page, mm, gfp_mask,
-				MEM_CGROUP_CHARGE_TYPE_CACHE);
-	return ret;
+	return mem_cgroup_charge_common(page, mm, gfp_mask,
+			MEM_CGROUP_CHARGE_TYPE_CACHE);
 }
 
 /*
  * Uncharging is always a welcome operation, we never complain, simply
- * uncharge. This routine should be called with lock_page_cgroup held
+ * uncharge.
  */
-void mem_cgroup_uncharge(struct page_cgroup *pc)
+void mem_cgroup_uncharge_page(struct page *page)
 {
+	struct page_cgroup *pc;
 	struct mem_cgroup *mem;
 	struct mem_cgroup_per_zone *mz;
-	struct page *page;
 	unsigned long flags;
 
 	/*
 	 * Check if our page_cgroup is valid
 	 */
+	lock_page_cgroup(page);
+	pc = page_get_page_cgroup(page);
 	if (!pc)
-		return;
+		goto unlock;
 
-	if (atomic_dec_and_test(&pc->ref_cnt)) {
-		page = pc->page;
-		mz = page_cgroup_zoneinfo(pc);
-		/*
-		 * get page->cgroup and clear it under lock.
-		 * force_empty can drop page->cgroup without checking refcnt.
-		 */
+	VM_BUG_ON(pc->page != page);
+	VM_BUG_ON(pc->ref_cnt <= 0);
+
+	if (--(pc->ref_cnt) == 0) {
+		page_assign_page_cgroup(page, NULL);
 		unlock_page_cgroup(page);
-		if (clear_page_cgroup(page, pc) == pc) {
-			mem = pc->mem_cgroup;
-			css_put(&mem->css);
-			res_counter_uncharge(&mem->res, PAGE_SIZE);
-			spin_lock_irqsave(&mz->lru_lock, flags);
-			__mem_cgroup_remove_list(pc);
-			spin_unlock_irqrestore(&mz->lru_lock, flags);
-			kfree(pc);
-		}
-		lock_page_cgroup(page);
+
+		mem = pc->mem_cgroup;
+		css_put(&mem->css);
+		res_counter_uncharge(&mem->res, PAGE_SIZE);
+
+		mz = page_cgroup_zoneinfo(pc);
+		spin_lock_irqsave(&mz->lru_lock, flags);
+		__mem_cgroup_remove_list(pc);
+		spin_unlock_irqrestore(&mz->lru_lock, flags);
+
+		kfree(pc);
+		return;
 	}
-}
 
-void mem_cgroup_uncharge_page(struct page *page)
-{
-	lock_page_cgroup(page);
-	mem_cgroup_uncharge(page_get_page_cgroup(page));
+unlock:
 	unlock_page_cgroup(page);
 }
 
@@ -765,50 +703,46 @@ void mem_cgroup_uncharge_page(struct pag
  * Returns non-zero if a page (under migration) has valid page_cgroup member.
  * Refcnt of page_cgroup is incremented.
  */
-
 int mem_cgroup_prepare_migration(struct page *page)
 {
 	struct page_cgroup *pc;
-	int ret = 0;
+
 	lock_page_cgroup(page);
 	pc = page_get_page_cgroup(page);
-	if (pc && atomic_inc_not_zero(&pc->ref_cnt))
-		ret = 1;
+	if (pc)
+		pc->ref_cnt++;
 	unlock_page_cgroup(page);
-	return ret;
+	return pc != NULL;
 }
 
 void mem_cgroup_end_migration(struct page *page)
 {
-	struct page_cgroup *pc;
-
-	lock_page_cgroup(page);
-	pc = page_get_page_cgroup(page);
-	mem_cgroup_uncharge(pc);
-	unlock_page_cgroup(page);
+	mem_cgroup_uncharge_page(page);
 }
+
 /*
  * We know both *page* and *newpage* are now not-on-LRU and Pg_locked.
  * And no race with uncharge() routines because page_cgroup for *page*
  * has extra one reference by mem_cgroup_prepare_migration.
  */
-
 void mem_cgroup_page_migration(struct page *page, struct page *newpage)
 {
 	struct page_cgroup *pc;
-	struct mem_cgroup *mem;
-	unsigned long flags;
 	struct mem_cgroup_per_zone *mz;
-retry:
+	unsigned long flags;
+
+	lock_page_cgroup(page);
 	pc = page_get_page_cgroup(page);
-	if (!pc)
+	if (!pc) {
+		unlock_page_cgroup(page);
 		return;
-	mem = pc->mem_cgroup;
+	}
+
+	page_assign_page_cgroup(page, NULL);
+	unlock_page_cgroup(page);
+
 	mz = page_cgroup_zoneinfo(pc);
-	if (clear_page_cgroup(page, pc) != pc)
-		goto retry;
 	spin_lock_irqsave(&mz->lru_lock, flags);
-
 	__mem_cgroup_remove_list(pc);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
 
@@ -821,7 +755,6 @@ retry:
 	spin_lock_irqsave(&mz->lru_lock, flags);
 	__mem_cgroup_add_list(pc);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
-	return;
 }
 
 /*
@@ -830,8 +763,7 @@ retry:
  * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
  */
 #define FORCE_UNCHARGE_BATCH	(128)
-static void
-mem_cgroup_force_empty_list(struct mem_cgroup *mem,
+static void mem_cgroup_force_empty_list(struct mem_cgroup *mem,
 			    struct mem_cgroup_per_zone *mz,
 			    int active)
 {
@@ -855,30 +787,33 @@ retry:
 	while (--count && !list_empty(list)) {
 		pc = list_entry(list->prev, struct page_cgroup, lru);
 		page = pc->page;
-		/* Avoid race with charge */
-		atomic_set(&pc->ref_cnt, 0);
-		if (clear_page_cgroup(page, pc) == pc) {
+		lock_page_cgroup(page);
+		if (page_get_page_cgroup(page) == pc) {
+			page_assign_page_cgroup(page, NULL);
+			unlock_page_cgroup(page);
 			css_put(&mem->css);
 			res_counter_uncharge(&mem->res, PAGE_SIZE);
 			__mem_cgroup_remove_list(pc);
 			kfree(pc);
-		} else 	/* being uncharged ? ...do relax */
+		} else {
+			/* racing uncharge: let page go then retry */
+			unlock_page_cgroup(page);
 			break;
+		}
 	}
+
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
 	if (!list_empty(list)) {
 		cond_resched();
 		goto retry;
 	}
-	return;
 }
 
 /*
  * make mem_cgroup's charge to be 0 if there is no task.
  * This enables deleting this mem_cgroup.
  */
-
-int mem_cgroup_force_empty(struct mem_cgroup *mem)
+static int mem_cgroup_force_empty(struct mem_cgroup *mem)
 {
 	int ret = -EBUSY;
 	int node, zid;
@@ -907,9 +842,7 @@ out:
 	return ret;
 }
 
-
-
-int mem_cgroup_write_strategy(char *buf, unsigned long long *tmp)
+static int mem_cgroup_write_strategy(char *buf, unsigned long long *tmp)
 {
 	*tmp = memparse(buf, &buf);
 	if (*buf != '\0')
@@ -956,7 +889,6 @@ static ssize_t mem_force_empty_write(str
 /*
  * Note: This should be removed if cgroup supports write-only file.
  */
-
 static ssize_t mem_force_empty_read(struct cgroup *cont,
 				struct cftype *cft,
 				struct file *file, char __user *userbuf,
@@ -965,7 +897,6 @@ static ssize_t mem_force_empty_read(stru
 	return -EINVAL;
 }
 
-
 static const struct mem_cgroup_stat_desc {
 	const char *msg;
 	u64 unit;
@@ -1018,8 +949,6 @@ static int mem_control_stat_open(struct 
 	return single_open(file, mem_control_stat_show, cont);
 }
 
-
-
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
@@ -1085,9 +1014,6 @@ static void free_mem_cgroup_per_zone_inf
 	kfree(mem->info.nodeinfo[node]);
 }
 
-
-static struct mem_cgroup init_mem_cgroup;
-
 static struct cgroup_subsys_state *
 mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 {
@@ -1177,7 +1103,6 @@ static void mem_cgroup_move_task(struct 
 
 out:
 	mmput(mm);
-	return;
 }
 
 struct cgroup_subsys mem_cgroup_subsys = {
diff -purN 26252/mm/memory.c 26252h/mm/memory.c
--- 26252/mm/memory.c	2008-02-15 23:43:20.000000000 +0000
+++ 26252h/mm/memory.c	2008-02-17 10:26:22.000000000 +0000
@@ -1711,7 +1711,7 @@ unlock:
 	}
 	return ret;
 oom_free_new:
-	__free_page(new_page);
+	page_cache_release(new_page);
 oom:
 	if (old_page)
 		page_cache_release(old_page);
@@ -2093,12 +2093,9 @@ static int do_swap_page(struct mm_struct
 	unlock_page(page);
 
 	if (write_access) {
-		/* XXX: We could OR the do_wp_page code with this one? */
-		if (do_wp_page(mm, vma, address,
-				page_table, pmd, ptl, pte) & VM_FAULT_OOM) {
-			mem_cgroup_uncharge_page(page);
-			ret = VM_FAULT_OOM;
-		}
+		ret |= do_wp_page(mm, vma, address, page_table, pmd, ptl, pte);
+		if (ret & VM_FAULT_ERROR)
+			ret &= VM_FAULT_ERROR;
 		goto out;
 	}
 
@@ -2163,7 +2160,7 @@ release:
 	page_cache_release(page);
 	goto unlock;
 oom_free_page:
-	__free_page(page);
+	page_cache_release(page);
 oom:
 	return VM_FAULT_OOM;
 }
diff -purN 26252/mm/page_alloc.c 26252h/mm/page_alloc.c
--- 26252/mm/page_alloc.c	2008-02-11 07:18:12.000000000 +0000
+++ 26252h/mm/page_alloc.c	2008-02-17 10:26:11.000000000 +0000
@@ -981,6 +981,7 @@ static void free_hot_cold_page(struct pa
 	struct per_cpu_pages *pcp;
 	unsigned long flags;
 
+	VM_BUG_ON(page_get_page_cgroup(page));
 	if (PageAnon(page))
 		page->mapping = NULL;
 	if (free_pages_check(page))
@@ -988,7 +989,6 @@ static void free_hot_cold_page(struct pa
 
 	if (!PageHighMem(page))
 		debug_check_no_locks_freed(page_address(page), PAGE_SIZE);
-	VM_BUG_ON(page_get_page_cgroup(page));
 	arch_free_page(page, 0);
 	kernel_map_pages(page, 1, 0);
 
@@ -2527,7 +2527,6 @@ void __meminit memmap_init_zone(unsigned
 		set_page_links(page, zone, nid, pfn);
 		init_page_count(page);
 		reset_page_mapcount(page);
-		page_assign_page_cgroup(page, NULL);
 		SetPageReserved(page);
 
 		/*
diff -purN 26252/mm/rmap.c 26252h/mm/rmap.c
--- 26252/mm/rmap.c	2008-02-11 07:18:12.000000000 +0000
+++ 26252h/mm/rmap.c	2008-02-17 10:26:22.000000000 +0000
@@ -321,7 +321,7 @@ static int page_referenced_anon(struct p
 		 * counting on behalf of references from different
 		 * cgroups
 		 */
-		if (mem_cont && !vm_match_cgroup(vma->vm_mm, mem_cont))
+		if (mem_cont && !mm_match_cgroup(vma->vm_mm, mem_cont))
 			continue;
 		referenced += page_referenced_one(page, vma, &mapcount);
 		if (!mapcount)
@@ -382,7 +382,7 @@ static int page_referenced_file(struct p
 		 * counting on behalf of references from different
 		 * cgroups
 		 */
-		if (mem_cont && !vm_match_cgroup(vma->vm_mm, mem_cont))
+		if (mem_cont && !mm_match_cgroup(vma->vm_mm, mem_cont))
 			continue;
 		if ((vma->vm_flags & (VM_LOCKED|VM_MAYSHARE))
 				  == (VM_LOCKED|VM_MAYSHARE)) {
diff -purN 26252/mm/swap.c 26252h/mm/swap.c
--- 26252/mm/swap.c	2008-02-11 07:18:12.000000000 +0000
+++ 26252h/mm/swap.c	2008-02-17 13:01:50.000000000 +0000
@@ -176,7 +176,7 @@ void activate_page(struct page *page)
 		SetPageActive(page);
 		add_page_to_active_list(zone, page);
 		__count_vm_event(PGACTIVATE);
-		mem_cgroup_move_lists(page_get_page_cgroup(page), true);
+		mem_cgroup_move_lists(page, true);
 	}
 	spin_unlock_irq(&zone->lru_lock);
 }
diff -purN 26252/mm/vmscan.c 26252h/mm/vmscan.c
--- 26252/mm/vmscan.c	2008-02-11 07:18:12.000000000 +0000
+++ 26252h/mm/vmscan.c	2008-02-17 13:02:33.000000000 +0000
@@ -1128,7 +1128,7 @@ static void shrink_active_list(unsigned 
 		ClearPageActive(page);
 
 		list_move(&page->lru, &zone->inactive_list);
-		mem_cgroup_move_lists(page_get_page_cgroup(page), false);
+		mem_cgroup_move_lists(page, false);
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
 			__mod_zone_page_state(zone, NR_INACTIVE, pgmoved);
@@ -1157,7 +1157,7 @@ static void shrink_active_list(unsigned 
 		SetPageLRU(page);
 		VM_BUG_ON(!PageActive(page));
 		list_move(&page->lru, &zone->active_list);
-		mem_cgroup_move_lists(page_get_page_cgroup(page), true);
+		mem_cgroup_move_lists(page, true);
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
 			__mod_zone_page_state(zone, NR_ACTIVE, pgmoved);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
