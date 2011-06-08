Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 862806B0078
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 16:22:07 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [RFC][PATCH] memcg: break the zone->lru_lock in memcg-aware reclaim.
Date: Wed,  8 Jun 2011 13:20:49 -0700
Message-Id: <1307564449-2215-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, Suleiman Souhlal <suleiman@google.com>
Cc: linux-mm@kvack.org

This patch is based on mmotm-2011-05-12-15-52 plus Johannes patchset
"[patch 0/8] mm: memcg naturalization -rc2".

This patch is only in RFC stage and i have things listed in the TODO.
For now, I would like to collect early feedbacks of the direction, and
more comments are welcomed.

Now with all the efforts of memcg reclaim, we are going to have better
targetting per-memcg reclaim both under global memory pressure and per-memcg
memory pressure. The patch fixes the last piece which making the lru_lock to
be exclusive across memcgs.

The reasons we have the zone->lru_lock shared due to the following:
1. each page is linked both in per-memcg lru as well as per-zone lru due to the
lack of targetting reclaim under global memory pressure.
2. since we have 1), it is easier to maintain and less race conditions to have
the zone->lru_lock shared vs per-memcg lock.

After Johannes patchset, there will be no global lru list when memcg is enabled.
All the pages are in exclusive per-memcg lru. So it makes senses to make the
spinlock exclusive which could be easily causing bad lock contention with lots
of memcgs each running memory intensive workload. The zone->lru_lock is still
being used if memcg is not enabled and there shouldn't be any change in that
condition.

TODO:
1. move the spinlock lru_lock from mem_cgroup_per_zone struct to lruvec.
the later one is introduced by Johannes patch which I think fits the lock
much better.

2. add the changes in the CONFIG_TRANSPARENT_HUGEPAGE and CONFIG_COMPACTION.
in my testing kernel, i don't have those configs enabled.

3. i have test triggers BUG() in __isolate_lru_page() sometimes. looking into
that next.

Test: I created a testcase which is intended to show the zone->lru_lock contention
before vs after the patch. On my 8-core machine, i created 8 memcgs and each is doing
a read from a ramdisk file. The filesize is larger than the hard_limit which triggers
the per-memcg direct reclaim. Here I am using ramdisk to avoid the run-to-run noise
from the hard drive which in turn exaggerate the contention.

1. results from the lock_stat shows the zone->lru_lock contention went down.
without the patch:
--------------------------------------------------------------------------------------------------------------------------------------------
class name    con-bounces    contentions   waittime-min   waittime-max waittime-total    acq-bounces   acquisitions   holdtime-min   holdtime-max holdtime-total
&(&zone->lru_lock)->rlock:       4872501        4882517           0.23         106.26    42040610.52      29395780       35129035   0.00          69.07   125609975.67

With the patch:
--------------------------------------------------------------------------------------------------------------------------------------------
class name    con-bounces    contentions   waittime-min   waittime-max waittime-total    acq-bounces   acquisitions   holdtime-min   holdtime-max holdtime-total
&(&zone->lock)->rlock:          6713           6714           0.27          32.87       14452.22         184249          400523     0.00         994.81      898119.61

2. meanwhile, i measured the "time" on one of the memcgs and compared the "real". I would assume with bad lock contention, the real time might go up due to frequent cpu load balancing. With those runs, i disabled the CONFIG_LOCK_STAT. However, i don't see big difference on the two runs. It implies either the test is not the right indicator or something else outside that I missed.

$ ../ministat real_lock real_nolock
x real_lock
+ real_nolock
--------------------------------------------------------------------------------------------------------------------------------------------
    N           Min           Max        Median           Avg        Stddev
x  10       374.765       387.513       380.896       381.549     4.1587153
+  11       369.487       382.836       378.288     377.63245     4.6018663
No difference proven at 95.0% confidence

Signed-off-by: Suleiman Souhlal <suleiman@google.com>
Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h |   17 +++++++++
 mm/memcontrol.c            |   59 ++++++++++++++++++++++++++----
 mm/swap.c                  |   69 ++++++++++++++++++++---------------
 mm/vmscan.c                |   86 ++++++++++++++++++++++++++++++--------------
 4 files changed, 167 insertions(+), 64 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 6facc12..505f9a13 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -80,6 +80,9 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
 extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 
+spinlock_t *page_lru_lock(struct page *page);
+spinlock_t *mem_cgroup_lru_lock(struct mem_cgroup *mem, struct zone *zone);
+
 static inline
 int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
 {
@@ -378,6 +381,20 @@ static inline
 void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
 {
 }
+
+static inline spinlock_t *page_lru_lock(struct page *page)
+{
+	struct zone *zone;
+
+	zone = page_zone(page);
+	return &zone->lru_lock;
+}
+
+static inline spinlock_t *
+mem_cgroup_lru_lock(struct mem_cgroup *mem, struct zone *zone)
+{
+	return &zone->lru_lock;
+}
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3331ac9..1708397 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -144,6 +144,7 @@ struct mem_cgroup_stat_cpu {
  * per-zone information in memory controller.
  */
 struct mem_cgroup_per_zone {
+	spinlock_t lru_lock;
 	struct lruvec		lruvec;
 	unsigned long		count[NR_LRU_LISTS];
 
@@ -727,6 +728,43 @@ out:
 }
 EXPORT_SYMBOL(mem_cgroup_count_vm_event);
 
+spinlock_t *page_lru_lock(struct page *page)
+{
+	struct page_cgroup *pc;
+	struct zone *zone;
+	struct mem_cgroup_per_zone *mz;
+	struct mem_cgroup *mem;
+
+	zone = page_zone(page);
+	if (mem_cgroup_disabled())
+		return &zone->lru_lock;
+
+	pc = lookup_page_cgroup(page);
+	if (PageCgroupUsed(pc)) {
+		smp_rmb();
+		mem = pc->mem_cgroup;
+	} else
+		mem = root_mem_cgroup;
+
+	mz = page_cgroup_zoneinfo(mem, page);
+
+	return &mz->lru_lock;
+}
+
+spinlock_t *mem_cgroup_lru_lock(struct mem_cgroup *mem, struct zone *zone)
+{
+	struct mem_cgroup_per_zone *mz;
+	int nid, zid;
+
+	if (!mem)
+		return &zone->lru_lock;
+
+	nid = zone_to_nid(zone);
+	zid = zone_idx(zone);
+	mz = mem_cgroup_zoneinfo(mem, nid, zid);
+	return &mz->lru_lock;
+}
+
 /**
  * mem_cgroup_zone_lruvec - get the lru list vector for a zone and memcg
  * @zone: zone of the wanted lruvec
@@ -884,6 +922,7 @@ struct lruvec *mem_cgroup_lru_move_lists(struct zone *zone,
 static void mem_cgroup_lru_del_before_commit(struct page *page)
 {
 	unsigned long flags;
+	spinlock_t *lru_lock;
 	struct zone *zone = page_zone(page);
 	struct page_cgroup *pc = lookup_page_cgroup(page);
 
@@ -898,29 +937,32 @@ static void mem_cgroup_lru_del_before_commit(struct page *page)
 	if (likely(!PageLRU(page)))
 		return;
 
-	spin_lock_irqsave(&zone->lru_lock, flags);
+	lru_lock = page_lru_lock(page);
+	spin_lock_irqsave(lru_lock, flags);
 	/*
 	 * Forget old LRU when this page_cgroup is *not* used. This Used bit
 	 * is guarded by lock_page() because the page is SwapCache.
 	 */
 	if (!PageCgroupUsed(pc))
 		del_page_from_lru(zone, page);
-	spin_unlock_irqrestore(&zone->lru_lock, flags);
+	spin_unlock_irqrestore(lru_lock, flags);
 }
 
 static void mem_cgroup_lru_add_after_commit(struct page *page)
 {
 	unsigned long flags;
+	spinlock_t *lru_lock;
 	struct zone *zone = page_zone(page);
 	struct page_cgroup *pc = lookup_page_cgroup(page);
 
 	/* taking care of that the page is added to LRU while we commit it */
 	if (likely(!PageLRU(page)))
 		return;
-	spin_lock_irqsave(&zone->lru_lock, flags);
+	lru_lock = page_lru_lock(page);
+	spin_lock_irqsave(lru_lock, flags);
 	if (PageLRU(page) && !PageCgroupAcctLRU(pc))
 		add_page_to_lru_list(zone, page, page_lru(page));
-	spin_unlock_irqrestore(&zone->lru_lock, flags);
+	spin_unlock_irqrestore(lru_lock, flags);
 }
 
 int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
@@ -3250,19 +3292,19 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *mem,
 		struct page *page;
 
 		ret = 0;
-		spin_lock_irqsave(&zone->lru_lock, flags);
+		spin_lock_irqsave(&mz->lru_lock, flags);
 		if (list_empty(list)) {
-			spin_unlock_irqrestore(&zone->lru_lock, flags);
+			spin_unlock_irqrestore(&mz->lru_lock, flags);
 			break;
 		}
 		page = list_entry(list->prev, struct page, lru);
 		if (busy == page) {
 			list_move(&page->lru, list);
 			busy = NULL;
-			spin_unlock_irqrestore(&zone->lru_lock, flags);
+			spin_unlock_irqrestore(&mz->lru_lock, flags);
 			continue;
 		}
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+		spin_unlock_irqrestore(&mz->lru_lock, flags);
 
 		pc = lookup_page_cgroup(page);
 
@@ -4315,6 +4357,7 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
 	mem->info.nodeinfo[node] = pn;
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 		mz = &pn->zoneinfo[zone];
+		spin_lock_init(&mz->lru_lock);
 		for_each_lru(l)
 			INIT_LIST_HEAD(&mz->lruvec.lists[l]);
 	}
diff --git a/mm/swap.c b/mm/swap.c
index 9ae3a4b..265f061 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -50,12 +50,14 @@ static void __page_cache_release(struct page *page)
 	if (PageLRU(page)) {
 		unsigned long flags;
 		struct zone *zone = page_zone(page);
+		spinlock_t *lru_lock;
 
-		spin_lock_irqsave(&zone->lru_lock, flags);
+		lru_lock = page_lru_lock(page);
+		spin_lock_irqsave(lru_lock, flags);
 		VM_BUG_ON(!PageLRU(page));
 		__ClearPageLRU(page);
 		del_page_from_lru(zone, page);
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+		spin_unlock_irqrestore(lru_lock, flags);
 	}
 }
 
@@ -184,24 +186,23 @@ static void pagevec_lru_move_fn(struct pagevec *pvec,
 				void *arg)
 {
 	int i;
-	struct zone *zone = NULL;
 	unsigned long flags = 0;
+	spinlock_t *old_lock = NULL;
 
 	for (i = 0; i < pagevec_count(pvec); i++) {
 		struct page *page = pvec->pages[i];
-		struct zone *pagezone = page_zone(page);
+		spinlock_t *lru_lock = page_lru_lock(page);
 
-		if (pagezone != zone) {
-			if (zone)
-				spin_unlock_irqrestore(&zone->lru_lock, flags);
-			zone = pagezone;
-			spin_lock_irqsave(&zone->lru_lock, flags);
+		if (lru_lock != old_lock) {
+			if (old_lock)
+				spin_unlock_irqrestore(old_lock, flags);
+			old_lock = lru_lock;
+			spin_lock_irqsave(old_lock, flags);
 		}
-
 		(*move_fn)(page, arg);
 	}
-	if (zone)
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+	if (old_lock)
+		spin_unlock_irqrestore(old_lock, flags);
 	release_pages(pvec->pages, pvec->nr, pvec->cold);
 	pagevec_reinit(pvec);
 }
@@ -322,11 +323,12 @@ static inline void activate_page_drain(int cpu)
 
 void activate_page(struct page *page)
 {
-	struct zone *zone = page_zone(page);
+	spinlock_t *lru_lock;
 
-	spin_lock_irq(&zone->lru_lock);
+	lru_lock = page_lru_lock(page);
+	spin_lock_irq(lru_lock)
 	__activate_page(page, NULL);
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(lru_lock);
 }
 #endif
 
@@ -393,12 +395,14 @@ void lru_cache_add_lru(struct page *page, enum lru_list lru)
 void add_page_to_unevictable_list(struct page *page)
 {
 	struct zone *zone = page_zone(page);
+	spinlock_t *lru_lock;
 
-	spin_lock_irq(&zone->lru_lock);
+	lru_lock = page_lru_lock(page);
+	spin_lock_irq(lru_lock);
 	SetPageUnevictable(page);
 	SetPageLRU(page);
 	add_page_to_lru_list(zone, page, LRU_UNEVICTABLE);
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(lru_lock);
 }
 
 /*
@@ -568,14 +572,16 @@ void release_pages(struct page **pages, int nr, int cold)
 	struct pagevec pages_to_free;
 	struct zone *zone = NULL;
 	unsigned long uninitialized_var(flags);
+	spinlock_t *old_lock = NULL;
 
 	pagevec_init(&pages_to_free, cold);
 	for (i = 0; i < nr; i++) {
 		struct page *page = pages[i];
 
 		if (unlikely(PageCompound(page))) {
-			if (zone) {
-				spin_unlock_irqrestore(&zone->lru_lock, flags);
+			if (old_lock) {
+				spin_unlock_irqrestore(old_lock, flags);
+				old_lock = NULL;
 				zone = NULL;
 			}
 			put_compound_page(page);
@@ -587,13 +593,14 @@ void release_pages(struct page **pages, int nr, int cold)
 
 		if (PageLRU(page)) {
 			struct zone *pagezone = page_zone(page);
+			spinlock_t *lru_lock = page_lru_lock(page);
 
-			if (pagezone != zone) {
-				if (zone)
-					spin_unlock_irqrestore(&zone->lru_lock,
-									flags);
+			if (lru_lock != old_lock) {
+				if (old_lock)
+					spin_unlock_irqrestore(old_lock, flags);
+				old_lock = lru_lock;
 				zone = pagezone;
-				spin_lock_irqsave(&zone->lru_lock, flags);
+				spin_lock_irqsave(old_lock, flags);
 			}
 			VM_BUG_ON(!PageLRU(page));
 			__ClearPageLRU(page);
@@ -601,16 +608,17 @@ void release_pages(struct page **pages, int nr, int cold)
 		}
 
 		if (!pagevec_add(&pages_to_free, page)) {
-			if (zone) {
-				spin_unlock_irqrestore(&zone->lru_lock, flags);
+			if (old_lock) {
+				spin_unlock_irqrestore(old_lock, flags);
+				old_lock = NULL;
 				zone = NULL;
 			}
 			__pagevec_free(&pages_to_free);
 			pagevec_reinit(&pages_to_free);
   		}
 	}
-	if (zone)
-		spin_unlock_irqrestore(&zone->lru_lock, flags);
+	if (old_lock)
+		spin_unlock_irqrestore(old_lock, flags);
 
 	pagevec_free(&pages_to_free);
 }
@@ -642,11 +650,14 @@ void lru_add_page_tail(struct zone* zone,
 	int active;
 	enum lru_list lru;
 	const int file = 0;
+	spinlock_t *lru_lock;
+
+	lru_lock = page_lru_lock(page);
 
 	VM_BUG_ON(!PageHead(page));
 	VM_BUG_ON(PageCompound(page_tail));
 	VM_BUG_ON(PageLRU(page_tail));
-	VM_BUG_ON(!spin_is_locked(&zone->lru_lock));
+	VM_BUG_ON(!spin_is_locked(lru_lock));
 
 	SetPageLRU(page_tail);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a825404..78dd95c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1248,8 +1248,9 @@ int isolate_lru_page(struct page *page)
 
 	if (PageLRU(page)) {
 		struct zone *zone = page_zone(page);
+		spinlock_t *lru_lock = page_lru_lock(page);
 
-		spin_lock_irq(&zone->lru_lock);
+		spin_lock_irq(lru_lock);
 		if (PageLRU(page)) {
 			int lru = page_lru(page);
 			ret = 0;
@@ -1258,7 +1259,7 @@ int isolate_lru_page(struct page *page)
 
 			del_page_from_lru_list(zone, page, lru);
 		}
-		spin_unlock_irq(&zone->lru_lock);
+		spin_unlock_irq(lru_lock);
 	}
 	return ret;
 }
@@ -1299,22 +1300,28 @@ putback_lru_pages(struct zone *zone, struct scan_control *sc,
 	struct page *page;
 	struct pagevec pvec;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
+	spinlock_t *lru_lock;
 
 	pagevec_init(&pvec, 1);
 
+	if (scanning_global_lru(sc))
+		lru_lock = &zone->lru_lock;
+	else
+		lru_lock = mem_cgroup_lru_lock(sc->mem_cgroup, zone);
+
 	/*
 	 * Put back any unfreeable pages.
 	 */
-	spin_lock(&zone->lru_lock);
+	spin_lock(lru_lock);
 	while (!list_empty(page_list)) {
 		int lru;
 		page = lru_to_page(page_list);
 		VM_BUG_ON(PageLRU(page));
 		list_del(&page->lru);
 		if (unlikely(!page_evictable(page, NULL))) {
-			spin_unlock_irq(&zone->lru_lock);
+			spin_unlock_irq(lru_lock);
 			putback_lru_page(page);
-			spin_lock_irq(&zone->lru_lock);
+			spin_lock_irq(lru_lock);
 			continue;
 		}
 		SetPageLRU(page);
@@ -1326,15 +1333,15 @@ putback_lru_pages(struct zone *zone, struct scan_control *sc,
 			reclaim_stat->recent_rotated[file] += numpages;
 		}
 		if (!pagevec_add(&pvec, page)) {
-			spin_unlock_irq(&zone->lru_lock);
+			spin_unlock_irq(lru_lock);
 			__pagevec_release(&pvec);
-			spin_lock_irq(&zone->lru_lock);
+			spin_lock_irq(lru_lock);
 		}
 	}
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
 	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
 
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(lru_lock);
 	pagevec_release(&pvec);
 }
 
@@ -1424,6 +1431,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 	unsigned long nr_taken;
 	unsigned long nr_anon;
 	unsigned long nr_file;
+	spinlock_t *lru_lock;
 
 	while (unlikely(too_many_isolated(zone, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -1435,8 +1443,13 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 
 	set_reclaim_mode(priority, sc, false);
 	lru_add_drain();
-	spin_lock_irq(&zone->lru_lock);
 
+	if (scanning_global_lru(sc))
+		lru_lock = &zone->lru_lock;
+	else
+		lru_lock = mem_cgroup_lru_lock(sc->mem_cgroup, zone);
+
+	spin_lock_irq(lru_lock);
 	nr_taken = isolate_pages(nr_to_scan,
 				 &page_list, &nr_scanned, sc->order,
 				 sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
@@ -1454,13 +1467,13 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 	}
 
 	if (nr_taken == 0) {
-		spin_unlock_irq(&zone->lru_lock);
+		spin_unlock_irq(lru_lock);
 		return 0;
 	}
 
 	update_isolated_counts(zone, sc, &nr_anon, &nr_file, &page_list);
 
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(lru_lock);
 
 	nr_reclaimed = shrink_page_list(&page_list, zone, sc);
 
@@ -1510,6 +1523,7 @@ static void move_active_pages_to_lru(struct zone *zone,
 	unsigned long pgmoved = 0;
 	struct pagevec pvec;
 	struct page *page;
+	spinlock_t *lru_lock;
 
 	pagevec_init(&pvec, 1);
 
@@ -1524,13 +1538,14 @@ static void move_active_pages_to_lru(struct zone *zone,
 		lruvec = mem_cgroup_lru_add_list(zone, page, lru);
 		list_move(&page->lru, &lruvec->lists[lru]);
 		pgmoved += hpage_nr_pages(page);
+		lru_lock = page_lru_lock(page);
 
 		if (!pagevec_add(&pvec, page) || list_empty(list)) {
-			spin_unlock_irq(&zone->lru_lock);
+			spin_unlock_irq(lru_lock);
 			if (buffer_heads_over_limit)
 				pagevec_strip(&pvec);
 			__pagevec_release(&pvec);
-			spin_lock_irq(&zone->lru_lock);
+			spin_lock_irq(lru_lock);
 		}
 	}
 	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
@@ -1550,9 +1565,15 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	struct page *page;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 	unsigned long nr_rotated = 0;
+	spinlock_t *lru_lock;
 
 	lru_add_drain();
-	spin_lock_irq(&zone->lru_lock);
+	if (scanning_global_lru(sc))
+		lru_lock = &zone->lru_lock;
+	else
+		lru_lock = mem_cgroup_lru_lock(sc->mem_cgroup, zone);
+
+	spin_lock_irq(lru_lock);
 	nr_taken = isolate_pages(nr_pages, &l_hold,
 				 &pgscanned, sc->order,
 				 ISOLATE_ACTIVE, zone,
@@ -1569,7 +1590,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	else
 		__mod_zone_page_state(zone, NR_ACTIVE_ANON, -nr_taken);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(lru_lock);
 
 	while (!list_empty(&l_hold)) {
 		cond_resched();
@@ -1605,7 +1626,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	/*
 	 * Move pages back to the lru list.
 	 */
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(lru_lock);
 	/*
 	 * Count referenced pages from currently used mappings as rotated,
 	 * even though only some of them are actually re-activated.  This
@@ -1619,7 +1640,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	move_active_pages_to_lru(zone, &l_inactive,
 						LRU_BASE   + file * LRU_FILE);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(lru_lock);
 }
 
 #ifdef CONFIG_SWAP
@@ -1747,7 +1768,12 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
 	enum lru_list l;
 	int noswap = 0;
 	int force_scan = 0;
+	spinlock_t *lru_lock;
 
+	if (scanning_global_lru(sc))
+		lru_lock = &zone->lru_lock;
+	else
+		lru_lock = mem_cgroup_lru_lock(sc->mem_cgroup, zone);
 
 	anon  = zone_nr_lru_pages(zone, sc->mem_cgroup, LRU_ACTIVE_ANON) +
 		zone_nr_lru_pages(zone, sc->mem_cgroup, LRU_INACTIVE_ANON);
@@ -1802,7 +1828,7 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
 	 *
 	 * anon in [0], file in [1]
 	 */
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(lru_lock);
 	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
 		reclaim_stat->recent_scanned[0] /= 2;
 		reclaim_stat->recent_rotated[0] /= 2;
@@ -1823,7 +1849,7 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
 
 	fp = (file_prio + 1) * (reclaim_stat->recent_scanned[1] + 1);
 	fp /= reclaim_stat->recent_rotated[1] + 1;
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(lru_lock);
 
 	fraction[0] = ap;
 	fraction[1] = fp;
@@ -3238,6 +3264,7 @@ void scan_mapping_unevictable_pages(struct address_space *mapping)
 			 PAGE_CACHE_SHIFT;
 	struct zone *zone;
 	struct pagevec pvec;
+	spinlock_t *old_lock;
 
 	if (mapping->nrpages == 0)
 		return;
@@ -3249,29 +3276,32 @@ void scan_mapping_unevictable_pages(struct address_space *mapping)
 		int pg_scanned = 0;
 
 		zone = NULL;
+		old_lock = NULL;
 
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 			pgoff_t page_index = page->index;
 			struct zone *pagezone = page_zone(page);
+			spinlock_t *lru_lock = page_lru_lock(page);
 
 			pg_scanned++;
 			if (page_index > next)
 				next = page_index;
 			next++;
 
-			if (pagezone != zone) {
-				if (zone)
-					spin_unlock_irq(&zone->lru_lock);
+			if (lru_lock != old_lock) {
+				if (old_lock)
+					spin_unlock_irq(old_lock);
+				old_lock = lru_lock;
 				zone = pagezone;
-				spin_lock_irq(&zone->lru_lock);
+				spin_lock_irq(old_lock);
 			}
 
 			if (PageLRU(page) && PageUnevictable(page))
 				check_move_unevictable_page(page, zone);
 		}
-		if (zone)
-			spin_unlock_irq(&zone->lru_lock);
+		if (old_lock)
+			spin_unlock_irq(old_lock);
 		pagevec_release(&pvec);
 
 		count_vm_events(UNEVICTABLE_PGSCANNED, pg_scanned);
@@ -3293,6 +3323,7 @@ void scan_mapping_unevictable_pages(struct address_space *mapping)
 static void scan_zone_unevictable_pages(struct zone *zone)
 {
 	struct mem_cgroup *first, *mem = NULL;
+	spinlock_t *lru_lock;
 
 	first = mem = mem_cgroup_hierarchy_walk(NULL, mem);
 	do {
@@ -3303,6 +3334,7 @@ static void scan_zone_unevictable_pages(struct zone *zone)
 		nr_to_scan = zone_nr_lru_pages(zone, mem, LRU_UNEVICTABLE);
 		lruvec = mem_cgroup_zone_lruvec(zone, mem);
 		list = &lruvec->lists[LRU_UNEVICTABLE];
+		lru_lock = mem_cgroup_lru_lock(mem, zone);
 
 		while (nr_to_scan > 0) {
 			unsigned long batch_size;
@@ -3311,7 +3343,7 @@ static void scan_zone_unevictable_pages(struct zone *zone)
 			batch_size = min(nr_to_scan,
 					 SCAN_UNEVICTABLE_BATCH_SIZE);
 
-			spin_lock_irq(&zone->lru_lock);
+			spin_lock_irq(lru_lock);
 			for (scan = 0; scan < batch_size; scan++) {
 				struct page *page;
 
@@ -3323,7 +3355,7 @@ static void scan_zone_unevictable_pages(struct zone *zone)
 					check_move_unevictable_page(page, zone);
 				unlock_page(page);
 			}
-			spin_unlock_irq(&zone->lru_lock);
+			spin_unlock_irq(lru_lock);
 			nr_to_scan -= batch_size;
 		}
 		mem = mem_cgroup_hierarchy_walk(NULL, mem);
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
