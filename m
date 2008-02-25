Date: Mon, 25 Feb 2008 23:43:17 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 09/15] memcg: memcontrol whitespace cleanups
In-Reply-To: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
Message-ID: <Pine.LNX.4.64.0802252342110.27067@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Sorry, before getting down to more important changes, I'd like to do some
cleanup in memcontrol.c.  This patch doesn't change the code generated,
but cleans up whitespace, moves up a double declaration, removes an unused
enum, removes void returns, removes misleading comments, that kind of thing.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/memcontrol.c |   94 +++++++++++++---------------------------------
 1 file changed, 28 insertions(+), 66 deletions(-)

--- memcg08/mm/memcontrol.c	2008-02-25 14:06:02.000000000 +0000
+++ memcg09/mm/memcontrol.c	2008-02-25 14:06:09.000000000 +0000
@@ -137,6 +137,7 @@ struct mem_cgroup {
 	 */
 	struct mem_cgroup_stat stat;
 };
+static struct mem_cgroup init_mem_cgroup;
 
 /*
  * We use the lower bit of the page->page_cgroup pointer as a bit spin
@@ -162,7 +163,7 @@ struct page_cgroup {
 	struct mem_cgroup *mem_cgroup;
 	atomic_t ref_cnt;		/* Helpful when pages move b/w  */
 					/* mapped and cached states     */
-	int	 flags;
+	int flags;
 };
 #define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache */
 #define PAGE_CGROUP_FLAG_ACTIVE (0x2)	/* page is active in this cgroup */
@@ -177,20 +178,11 @@ static inline enum zone_type page_cgroup
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
@@ -199,11 +191,10 @@ static void mem_cgroup_charge_statistics
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
@@ -240,8 +231,6 @@ static unsigned long mem_cgroup_get_all_
 	return total;
 }
 
-static struct mem_cgroup init_mem_cgroup;
-
 static inline
 struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
 {
@@ -273,8 +262,7 @@ void mm_free_cgroup(struct mm_struct *mm
 
 static inline int page_cgroup_locked(struct page *page)
 {
-	return bit_spin_is_locked(PAGE_CGROUP_LOCK_BIT,
-					&page->page_cgroup);
+	return bit_spin_is_locked(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
 }
 
 static void page_assign_page_cgroup(struct page *page, struct page_cgroup *pc)
@@ -285,8 +273,7 @@ static void page_assign_page_cgroup(stru
 
 struct page_cgroup *page_get_page_cgroup(struct page *page)
 {
-	return (struct page_cgroup *)
-		(page->page_cgroup & ~PAGE_CGROUP_LOCK);
+	return (struct page_cgroup *) (page->page_cgroup & ~PAGE_CGROUP_LOCK);
 }
 
 static void __always_inline lock_page_cgroup(struct page *page)
@@ -308,7 +295,6 @@ static void __always_inline unlock_page_
  * A can can detect failure of clearing by following
  *  clear_page_cgroup(page, pc) == pc
  */
-
 static struct page_cgroup *clear_page_cgroup(struct page *page,
 						struct page_cgroup *pc)
 {
@@ -417,6 +403,7 @@ int mem_cgroup_calc_mapped_ratio(struct 
 	rss = (long)mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_RSS);
 	return (int)((rss * 100L) / total);
 }
+
 /*
  * This function is called from vmscan.c. In page reclaiming loop. balance
  * between active and inactive list is calculated. For memory controller
@@ -480,7 +467,6 @@ long mem_cgroup_calc_reclaim_inactive(st
 	struct mem_cgroup_per_zone *mz = mem_cgroup_zoneinfo(mem, nid, zid);
 
 	nr_inactive = MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_INACTIVE);
-
 	return (nr_inactive >> priority);
 }
 
@@ -601,16 +587,11 @@ retry:
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
@@ -619,12 +600,12 @@ retry:
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
 
@@ -660,7 +641,6 @@ retry:
 
 	mz = page_cgroup_zoneinfo(pc);
 	spin_lock_irqsave(&mz->lru_lock, flags);
-	/* Update statistics vector */
 	__mem_cgroup_add_list(pc);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
 
@@ -673,26 +653,19 @@ err:
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
@@ -742,11 +715,11 @@ unlock:
  * Returns non-zero if a page (under migration) has valid page_cgroup member.
  * Refcnt of page_cgroup is incremented.
  */
-
 int mem_cgroup_prepare_migration(struct page *page)
 {
 	struct page_cgroup *pc;
 	int ret = 0;
+
 	lock_page_cgroup(page);
 	pc = page_get_page_cgroup(page);
 	if (pc && atomic_inc_not_zero(&pc->ref_cnt))
@@ -759,28 +732,30 @@ void mem_cgroup_end_migration(struct pag
 {
 	mem_cgroup_uncharge_page(page);
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
 	struct mem_cgroup *mem;
 	unsigned long flags;
 	struct mem_cgroup_per_zone *mz;
+
 retry:
 	pc = page_get_page_cgroup(page);
 	if (!pc)
 		return;
+
 	mem = pc->mem_cgroup;
 	mz = page_cgroup_zoneinfo(pc);
 	if (clear_page_cgroup(page, pc) != pc)
 		goto retry;
-	spin_lock_irqsave(&mz->lru_lock, flags);
 
+	spin_lock_irqsave(&mz->lru_lock, flags);
 	__mem_cgroup_remove_list(pc);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
 
@@ -793,7 +768,6 @@ retry:
 	spin_lock_irqsave(&mz->lru_lock, flags);
 	__mem_cgroup_add_list(pc);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
-	return;
 }
 
 /*
@@ -802,8 +776,7 @@ retry:
  * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
  */
 #define FORCE_UNCHARGE_BATCH	(128)
-static void
-mem_cgroup_force_empty_list(struct mem_cgroup *mem,
+static void mem_cgroup_force_empty_list(struct mem_cgroup *mem,
 			    struct mem_cgroup_per_zone *mz,
 			    int active)
 {
@@ -837,27 +810,27 @@ retry:
 		} else 	/* being uncharged ? ...do relax */
 			break;
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
 int mem_cgroup_force_empty(struct mem_cgroup *mem)
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
@@ -879,8 +852,6 @@ out:
 	return ret;
 }
 
-
-
 int mem_cgroup_write_strategy(char *buf, unsigned long long *tmp)
 {
 	*tmp = memparse(buf, &buf);
@@ -918,8 +889,7 @@ static ssize_t mem_force_empty_write(str
 				size_t nbytes, loff_t *ppos)
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
-	int ret;
-	ret = mem_cgroup_force_empty(mem);
+	int ret = mem_cgroup_force_empty(mem);
 	if (!ret)
 		ret = nbytes;
 	return ret;
@@ -928,7 +898,6 @@ static ssize_t mem_force_empty_write(str
 /*
  * Note: This should be removed if cgroup supports write-only file.
  */
-
 static ssize_t mem_force_empty_read(struct cgroup *cont,
 				struct cftype *cft,
 				struct file *file, char __user *userbuf,
@@ -937,7 +906,6 @@ static ssize_t mem_force_empty_read(stru
 	return -EINVAL;
 }
 
-
 static const struct mem_cgroup_stat_desc {
 	const char *msg;
 	u64 unit;
@@ -990,8 +958,6 @@ static int mem_control_stat_open(struct 
 	return single_open(file, mem_control_stat_show, cont);
 }
 
-
-
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
@@ -1057,9 +1023,6 @@ static void free_mem_cgroup_per_zone_inf
 	kfree(mem->info.nodeinfo[node]);
 }
 
-
-static struct mem_cgroup init_mem_cgroup;
-
 static struct cgroup_subsys_state *
 mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 {
@@ -1149,7 +1112,6 @@ static void mem_cgroup_move_task(struct 
 
 out:
 	mmput(mm);
-	return;
 }
 
 struct cgroup_subsys mem_cgroup_subsys = {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
