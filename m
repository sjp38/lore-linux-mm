Date: Fri, 22 Feb 2008 12:53:22 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
In-Reply-To: <47BEBFE5.9000905@linux.vnet.ibm.com>
Message-ID: <Pine.LNX.4.64.0802221249540.6674@blonde.site>
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0802191449490.6254@blonde.site> <20080220.152753.98212356.taka@valinux.co.jp>
 <20080220155049.094056ac.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0802220916290.18145@blonde.site> <47BEAEA9.10801@linux.vnet.ibm.com>
 <Pine.LNX.4.64.0802221144210.379@blonde.site> <47BEBFE5.9000905@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, 22 Feb 2008, Balbir Singh wrote:
> Hugh Dickins wrote:
> > I'd hoped to send out my series last night, but was unable to get
> > quite that far, sorry, and haven't tested the page migration paths yet.
> > The total is not unlike what I already showed, but plus Hirokazu-san's
> > patch and minus shmem's NULL page and minus my rearrangement of
> > mem_cgroup_charge_common.
> 
> Do let me know when you'll have a version to test, I can run LTP, LTP stress
> and other tests overnight.

This is the rollup, I'll try hard not to depart from this later without
good reason - thanks, Hugh

diff -purN 26252/include/linux/memcontrol.h memcg12/include/linux/memcontrol.h
--- 26252/include/linux/memcontrol.h	2008-02-11 07:18:10.000000000 +0000
+++ memcg12/include/linux/memcontrol.h	2008-02-21 20:08:08.000000000 +0000
@@ -32,14 +32,16 @@ struct mm_struct;
 
 extern void mm_init_cgroup(struct mm_struct *mm, struct task_struct *p);
 extern void mm_free_cgroup(struct mm_struct *mm);
-extern void page_assign_page_cgroup(struct page *page,
-					struct page_cgroup *pc);
+
+#define page_reset_bad_cgroup(page)	((page)->page_cgroup = 0)
+
 extern struct page_cgroup *page_get_page_cgroup(struct page *page);
 extern int mem_cgroup_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask);
-extern void mem_cgroup_uncharge(struct page_cgroup *pc);
+extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
+					gfp_t gfp_mask);
 extern void mem_cgroup_uncharge_page(struct page *page);
-extern void mem_cgroup_move_lists(struct page_cgroup *pc, bool active);
+extern void mem_cgroup_move_lists(struct page *page, bool active);
 extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct list_head *dst,
 					unsigned long *scanned, int order,
@@ -47,11 +49,9 @@ extern unsigned long mem_cgroup_isolate_
 					struct mem_cgroup *mem_cont,
 					int active);
 extern void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask);
-extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
-					gfp_t gfp_mask);
 int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
 
-#define vm_match_cgroup(mm, cgroup)	\
+#define mm_match_cgroup(mm, cgroup)	\
 	((cgroup) == rcu_dereference((mm)->mem_cgroup))
 
 extern int mem_cgroup_prepare_migration(struct page *page);
@@ -85,8 +85,7 @@ static inline void mm_free_cgroup(struct
 {
 }
 
-static inline void page_assign_page_cgroup(struct page *page,
-						struct page_cgroup *pc)
+static inline void page_reset_bad_cgroup(struct page *page)
 {
 }
 
@@ -95,33 +94,27 @@ static inline struct page_cgroup *page_g
 	return NULL;
 }
 
-static inline int mem_cgroup_charge(struct page *page, struct mm_struct *mm,
-					gfp_t gfp_mask)
+static inline int mem_cgroup_charge(struct page *page,
+					struct mm_struct *mm, gfp_t gfp_mask)
 {
 	return 0;
 }
 
-static inline void mem_cgroup_uncharge(struct page_cgroup *pc)
+static inline int mem_cgroup_cache_charge(struct page *page,
+					struct mm_struct *mm, gfp_t gfp_mask)
 {
+	return 0;
 }
 
 static inline void mem_cgroup_uncharge_page(struct page *page)
 {
 }
 
-static inline void mem_cgroup_move_lists(struct page_cgroup *pc,
-						bool active)
-{
-}
-
-static inline int mem_cgroup_cache_charge(struct page *page,
-						struct mm_struct *mm,
-						gfp_t gfp_mask)
+static inline void mem_cgroup_move_lists(struct page *page, bool active)
 {
-	return 0;
 }
 
-static inline int vm_match_cgroup(struct mm_struct *mm, struct mem_cgroup *mem)
+static inline int mm_match_cgroup(struct mm_struct *mm, struct mem_cgroup *mem)
 {
 	return 1;
 }
diff -purN 26252/mm/memcontrol.c memcg12/mm/memcontrol.c
--- 26252/mm/memcontrol.c	2008-02-11 07:18:12.000000000 +0000
+++ memcg12/mm/memcontrol.c	2008-02-21 20:08:34.000000000 +0000
@@ -137,14 +137,21 @@ struct mem_cgroup {
 	 */
 	struct mem_cgroup_stat stat;
 };
+static struct mem_cgroup init_mem_cgroup;
 
 /*
  * We use the lower bit of the page->page_cgroup pointer as a bit spin
- * lock. We need to ensure that page->page_cgroup is atleast two
- * byte aligned (based on comments from Nick Piggin)
+ * lock.  We need to ensure that page->page_cgroup is at least two
+ * byte aligned (based on comments from Nick Piggin).  But since
+ * bit_spin_lock doesn't actually set that lock bit in a non-debug
+ * uniprocessor kernel, we should avoid setting it here too.
  */
 #define PAGE_CGROUP_LOCK_BIT 	0x0
-#define PAGE_CGROUP_LOCK 		(1 << PAGE_CGROUP_LOCK_BIT)
+#if defined (CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK)
+#define PAGE_CGROUP_LOCK 	(1 << PAGE_CGROUP_LOCK_BIT)
+#else
+#define PAGE_CGROUP_LOCK	0x0
+#endif
 
 /*
  * A page_cgroup page is associated with every page descriptor. The
@@ -154,37 +161,27 @@ struct page_cgroup {
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
@@ -193,23 +190,21 @@ static void mem_cgroup_charge_statistics
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
 	return &mem->info.nodeinfo[nid]->zoneinfo[zid];
 }
 
-static inline struct mem_cgroup_per_zone *
+static struct mem_cgroup_per_zone *
 page_cgroup_zoneinfo(struct page_cgroup *pc)
 {
 	struct mem_cgroup *mem = pc->mem_cgroup;
@@ -234,18 +229,14 @@ static unsigned long mem_cgroup_get_all_
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
@@ -267,81 +258,33 @@ void mm_free_cgroup(struct mm_struct *mm
 
 static inline int page_cgroup_locked(struct page *page)
 {
-	return bit_spin_is_locked(PAGE_CGROUP_LOCK_BIT,
-					&page->page_cgroup);
+	return bit_spin_is_locked(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
 }
 
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
+	VM_BUG_ON(!page_cgroup_locked(page));
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
-}
-
-static void __always_inline unlock_page_cgroup(struct page *page)
-{
-	bit_spin_unlock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
 }
 
-/*
- * Tie new page_cgroup to struct page under lock_page_cgroup()
- * This can fail if the page has been tied to a page_cgroup.
- * If success, returns 0.
- */
-static int page_cgroup_assign_new_page_cgroup(struct page *page,
-						struct page_cgroup *pc)
+static int try_lock_page_cgroup(struct page *page)
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
+	return bit_spin_trylock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
 }
 
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
+static void unlock_page_cgroup(struct page *page)
 {
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
@@ -399,7 +342,7 @@ int task_in_mem_cgroup(struct task_struc
 	int ret;
 
 	task_lock(task);
-	ret = task->mm && vm_match_cgroup(task->mm, mem);
+	ret = task->mm && mm_match_cgroup(task->mm, mem);
 	task_unlock(task);
 	return ret;
 }
@@ -407,18 +350,30 @@ int task_in_mem_cgroup(struct task_struc
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
+	 * with an attempt to rotate_reclaimable_page.  But we cannot
+	 * safely get to page_cgroup without it, so just try_lock it:
+	 * mem_cgroup_isolate_pages allows for page left on wrong list.
+	 */
+	if (!try_lock_page_cgroup(page))
 		return;
 
-	mz = page_cgroup_zoneinfo(pc);
-	spin_lock_irqsave(&mz->lru_lock, flags);
-	__mem_cgroup_move_lists(pc, active);
-	spin_unlock_irqrestore(&mz->lru_lock, flags);
+	pc = page_get_page_cgroup(page);
+	if (pc) {
+		mz = page_cgroup_zoneinfo(pc);
+		spin_lock_irqsave(&mz->lru_lock, flags);
+		__mem_cgroup_move_lists(pc, active);
+		spin_unlock_irqrestore(&mz->lru_lock, flags);
+	}
+	unlock_page_cgroup(page);
 }
 
 /*
@@ -437,6 +392,7 @@ int mem_cgroup_calc_mapped_ratio(struct 
 	rss = (long)mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_RSS);
 	return (int)((rss * 100L) / total);
 }
+
 /*
  * This function is called from vmscan.c. In page reclaiming loop. balance
  * between active and inactive list is calculated. For memory controller
@@ -500,7 +456,6 @@ long mem_cgroup_calc_reclaim_inactive(st
 	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(mem, nid, zid);
 
 	nr_inactive = MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_INACTIVE);
-
 	return (nr_inactive >> priority);
 }
 
@@ -534,7 +489,6 @@ unsigned long mem_cgroup_isolate_pages(u
 		if (scan >= nr_to_scan)
 			break;
 		page = pc->page;
-		VM_BUG_ON(!pc);
 
 		if (unlikely(!PageLRU(page)))
 			continue;
@@ -587,26 +541,21 @@ static int mem_cgroup_charge_common(stru
 	 * with it
 	 */
 retry:
-	if (page) {
-		lock_page_cgroup(page);
-		pc = page_get_page_cgroup(page);
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
+	lock_page_cgroup(page);
+	pc = page_get_page_cgroup(page);
+	/*
+	 * The page_cgroup exists and
+	 * the page has already been accounted.
+	 */
+	if (pc) {
+		VM_BUG_ON(pc->page != page);
+		VM_BUG_ON(pc->ref_cnt <= 0);
+
+		pc->ref_cnt++;
 		unlock_page_cgroup(page);
+		goto done;
 	}
+	unlock_page_cgroup(page);
 
 	pc = kzalloc(sizeof(struct page_cgroup), gfp_mask);
 	if (pc == NULL)
@@ -624,16 +573,11 @@ retry:
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
@@ -642,12 +586,12 @@ retry:
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
 
@@ -658,14 +602,16 @@ retry:
 		congestion_wait(WRITE, HZ/10);
 	}
 
-	atomic_set(&pc->ref_cnt, 1);
+	pc->ref_cnt = 1;
 	pc->mem_cgroup = mem;
 	pc->page = page;
 	pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
 	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE)
 		pc->flags |= PAGE_CGROUP_FLAG_CACHE;
 
-	if (!page || page_cgroup_assign_new_page_cgroup(page, pc)) {
+	lock_page_cgroup(page);
+	if (page_get_page_cgroup(page)) {
+		unlock_page_cgroup(page);
 		/*
 		 * Another charge has been added to this page already.
 		 * We take lock_page_cgroup(page) again and read
@@ -674,14 +620,13 @@ retry:
 		res_counter_uncharge(&mem->res, PAGE_SIZE);
 		css_put(&mem->css);
 		kfree(pc);
-		if (!page)
-			goto done;
 		goto retry;
 	}
+	page_assign_page_cgroup(page, pc);
+	unlock_page_cgroup(page);
 
 	mz = page_cgroup_zoneinfo(pc);
 	spin_lock_irqsave(&mz->lru_lock, flags);
-	/* Update statistics vector */
 	__mem_cgroup_add_list(pc);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
 
@@ -694,70 +639,61 @@ err:
 	return -ENOMEM;
 }
 
-int mem_cgroup_charge(struct page *page, struct mm_struct *mm,
-			gfp_t gfp_mask)
+int mem_cgroup_charge(struct page *page, struct mm_struct *mm, gfp_t gfp_mask)
 {
 	return mem_cgroup_charge_common(page, mm, gfp_mask,
-			MEM_CGROUP_CHARGE_TYPE_MAPPED);
+				MEM_CGROUP_CHARGE_TYPE_MAPPED);
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
+	return mem_cgroup_charge_common(page, mm, gfp_mask,
 				MEM_CGROUP_CHARGE_TYPE_CACHE);
-	return ret;
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
+		mz = page_cgroup_zoneinfo(pc);
+		spin_lock_irqsave(&mz->lru_lock, flags);
+		__mem_cgroup_remove_list(pc);
+		spin_unlock_irqrestore(&mz->lru_lock, flags);
+
+		mem = pc->mem_cgroup;
+		res_counter_uncharge(&mem->res, PAGE_SIZE);
+		css_put(&mem->css);
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
 
@@ -765,50 +701,46 @@ void mem_cgroup_uncharge_page(struct pag
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
- * We know both *page* and *newpage* are now not-on-LRU and Pg_locked.
+ * We know both *page* and *newpage* are now not-on-LRU and PG_locked.
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
 
@@ -821,7 +753,6 @@ retry:
 	spin_lock_irqsave(&mz->lru_lock, flags);
 	__mem_cgroup_add_list(pc);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
-	return;
 }
 
 /*
@@ -830,14 +761,13 @@ retry:
  * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
  */
 #define FORCE_UNCHARGE_BATCH	(128)
-static void
-mem_cgroup_force_empty_list(struct mem_cgroup *mem,
+static void mem_cgroup_force_empty_list(struct mem_cgroup *mem,
 			    struct mem_cgroup_per_zone *mz,
 			    int active)
 {
 	struct page_cgroup *pc;
 	struct page *page;
-	int count;
+	int count = FORCE_UNCHARGE_BATCH;
 	unsigned long flags;
 	struct list_head *list;
 
@@ -846,46 +776,36 @@ mem_cgroup_force_empty_list(struct mem_c
 	else
 		list = &mz->inactive_list;
 
-	if (list_empty(list))
-		return;
-retry:
-	count = FORCE_UNCHARGE_BATCH;
 	spin_lock_irqsave(&mz->lru_lock, flags);
-
-	while (--count && !list_empty(list)) {
+	while (!list_empty(list)) {
 		pc = list_entry(list->prev, struct page_cgroup, lru);
 		page = pc->page;
-		/* Avoid race with charge */
-		atomic_set(&pc->ref_cnt, 0);
-		if (clear_page_cgroup(page, pc) == pc) {
-			css_put(&mem->css);
-			res_counter_uncharge(&mem->res, PAGE_SIZE);
-			__mem_cgroup_remove_list(pc);
-			kfree(pc);
-		} else 	/* being uncharged ? ...do relax */
-			break;
+		get_page(page);
+		spin_unlock_irqrestore(&mz->lru_lock, flags);
+		mem_cgroup_uncharge_page(page);
+		put_page(page);
+		if (--count <= 0) {
+			count = FORCE_UNCHARGE_BATCH;
+			cond_resched();
+		}
+		spin_lock_irqsave(&mz->lru_lock, flags);
 	}
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
-	if (!list_empty(list)) {
-		cond_resched();
-		goto retry;
-	}
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
+
 	css_get(&mem->css);
 	/*
 	 * page reclaim code (kswapd etc..) will move pages between
-`	 * active_list <-> inactive_list while we don't take a lock.
+	 * active_list <-> inactive_list while we don't take a lock.
 	 * So, we have to do loop here until all lists are empty.
 	 */
 	while (mem->res.usage > 0) {
@@ -907,9 +827,7 @@ out:
 	return ret;
 }
 
-
-
-int mem_cgroup_write_strategy(char *buf, unsigned long long *tmp)
+static int mem_cgroup_write_strategy(char *buf, unsigned long long *tmp)
 {
 	*tmp = memparse(buf, &buf);
 	if (*buf != '\0')
@@ -946,8 +864,7 @@ static ssize_t mem_force_empty_write(str
 				size_t nbytes, loff_t *ppos)
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
-	int ret;
-	ret = mem_cgroup_force_empty(mem);
+	int ret = mem_cgroup_force_empty(mem);
 	if (!ret)
 		ret = nbytes;
 	return ret;
@@ -956,7 +873,6 @@ static ssize_t mem_force_empty_write(str
 /*
  * Note: This should be removed if cgroup supports write-only file.
  */
-
 static ssize_t mem_force_empty_read(struct cgroup *cont,
 				struct cftype *cft,
 				struct file *file, char __user *userbuf,
@@ -965,7 +881,6 @@ static ssize_t mem_force_empty_read(stru
 	return -EINVAL;
 }
 
-
 static const struct mem_cgroup_stat_desc {
 	const char *msg;
 	u64 unit;
@@ -1018,8 +933,6 @@ static int mem_control_stat_open(struct 
 	return single_open(file, mem_control_stat_show, cont);
 }
 
-
-
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
@@ -1085,9 +998,6 @@ static void free_mem_cgroup_per_zone_inf
 	kfree(mem->info.nodeinfo[node]);
 }
 
-
-static struct mem_cgroup init_mem_cgroup;
-
 static struct cgroup_subsys_state *
 mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 {
@@ -1177,7 +1087,6 @@ static void mem_cgroup_move_task(struct 
 
 out:
 	mmput(mm);
-	return;
 }
 
 struct cgroup_subsys mem_cgroup_subsys = {
diff -purN 26252/mm/memory.c memcg12/mm/memory.c
--- 26252/mm/memory.c	2008-02-15 23:43:20.000000000 +0000
+++ memcg12/mm/memory.c	2008-02-21 20:07:58.000000000 +0000
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
diff -purN 26252/mm/page_alloc.c memcg12/mm/page_alloc.c
--- 26252/mm/page_alloc.c	2008-02-11 07:18:12.000000000 +0000
+++ memcg12/mm/page_alloc.c	2008-02-21 20:08:04.000000000 +0000
@@ -221,13 +221,19 @@ static inline int bad_range(struct zone 
 
 static void bad_page(struct page *page)
 {
-	printk(KERN_EMERG "Bad page state in process '%s'\n"
-		KERN_EMERG "page:%p flags:0x%0*lx mapping:%p mapcount:%d count:%d\n"
-		KERN_EMERG "Trying to fix it up, but a reboot is needed\n"
-		KERN_EMERG "Backtrace:\n",
+	void *pc = page_get_page_cgroup(page);
+
+	printk(KERN_EMERG "Bad page state in process '%s'\n" KERN_EMERG
+		"page:%p flags:0x%0*lx mapping:%p mapcount:%d count:%d\n",
 		current->comm, page, (int)(2*sizeof(unsigned long)),
 		(unsigned long)page->flags, page->mapping,
 		page_mapcount(page), page_count(page));
+	if (pc) {
+		printk(KERN_EMERG "cgroup:%p\n", pc);
+		page_reset_bad_cgroup(page);
+	}
+	printk(KERN_EMERG "Trying to fix it up, but a reboot is needed\n"
+		KERN_EMERG "Backtrace:\n");
 	dump_stack();
 	page->flags &= ~(1 << PG_lru	|
 			1 << PG_private |
@@ -453,6 +459,7 @@ static inline int free_pages_check(struc
 {
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
+		(page_get_page_cgroup(page) != NULL) |
 		(page_count(page) != 0)  |
 		(page->flags & (
 			1 << PG_lru	|
@@ -602,6 +609,7 @@ static int prep_new_page(struct page *pa
 {
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
+		(page_get_page_cgroup(page) != NULL) |
 		(page_count(page) != 0)  |
 		(page->flags & (
 			1 << PG_lru	|
@@ -988,7 +996,6 @@ static void free_hot_cold_page(struct pa
 
 	if (!PageHighMem(page))
 		debug_check_no_locks_freed(page_address(page), PAGE_SIZE);
-	VM_BUG_ON(page_get_page_cgroup(page));
 	arch_free_page(page, 0);
 	kernel_map_pages(page, 1, 0);
 
@@ -2527,7 +2534,6 @@ void __meminit memmap_init_zone(unsigned
 		set_page_links(page, zone, nid, pfn);
 		init_page_count(page);
 		reset_page_mapcount(page);
-		page_assign_page_cgroup(page, NULL);
 		SetPageReserved(page);
 
 		/*
diff -purN 26252/mm/rmap.c memcg12/mm/rmap.c
--- 26252/mm/rmap.c	2008-02-11 07:18:12.000000000 +0000
+++ memcg12/mm/rmap.c	2008-02-21 20:07:51.000000000 +0000
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
diff -purN 26252/mm/shmem.c memcg12/mm/shmem.c
--- 26252/mm/shmem.c	2008-02-11 07:18:12.000000000 +0000
+++ memcg12/mm/shmem.c	2008-02-21 20:08:34.000000000 +0000
@@ -1370,14 +1370,17 @@ repeat:
 			shmem_swp_unmap(entry);
 			spin_unlock(&info->lock);
 			unlock_page(swappage);
-			page_cache_release(swappage);
 			if (error == -ENOMEM) {
 				/* allow reclaim from this memory cgroup */
-				error = mem_cgroup_cache_charge(NULL,
+				error = mem_cgroup_cache_charge(swappage,
 					current->mm, gfp & ~__GFP_HIGHMEM);
-				if (error)
+				if (error) {
+					page_cache_release(swappage);
 					goto failed;
+				}
+				mem_cgroup_uncharge_page(swappage);
 			}
+			page_cache_release(swappage);
 			goto repeat;
 		}
 	} else if (sgp == SGP_READ && !filepage) {
diff -purN 26252/mm/swap.c memcg12/mm/swap.c
--- 26252/mm/swap.c	2008-02-11 07:18:12.000000000 +0000
+++ memcg12/mm/swap.c	2008-02-21 20:08:01.000000000 +0000
@@ -176,7 +176,7 @@ void activate_page(struct page *page)
 		SetPageActive(page);
 		add_page_to_active_list(zone, page);
 		__count_vm_event(PGACTIVATE);
-		mem_cgroup_move_lists(page_get_page_cgroup(page), true);
+		mem_cgroup_move_lists(page, true);
 	}
 	spin_unlock_irq(&zone->lru_lock);
 }
diff -purN 26252/mm/vmscan.c memcg12/mm/vmscan.c
--- 26252/mm/vmscan.c	2008-02-11 07:18:12.000000000 +0000
+++ memcg12/mm/vmscan.c	2008-02-21 20:08:01.000000000 +0000
@@ -1128,7 +1128,7 @@ static void shrink_active_list(unsigned 
 		ClearPageActive(page);
 
 		list_move(&page->lru, &zone->inactive_list);
-		mem_cgroup_move_lists(page_get_page_cgroup(page), false);
+		mem_cgroup_move_lists(page, false);
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
 			__mod_zone_page_state(zone, NR_INACTIVE, pgmoved);
@@ -1156,8 +1156,9 @@ static void shrink_active_list(unsigned 
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 		VM_BUG_ON(!PageActive(page));
+
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
