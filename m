Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E1D9F6B0082
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 23:08:59 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V1 1/2] memcg: break the zone->lru_lock in memcg-aware reclaim
Date: Tue, 14 Jun 2011 20:08:10 -0700
Message-Id: <1308107291-2909-2-git-send-email-yinghan@google.com>
In-Reply-To: <1308107291-2909-1-git-send-email-yinghan@google.com>
References: <1308107291-2909-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

This patch removes the places where we hold the zone->lru_lock and replaces
it with per-memcg mz->lru lock. Two supporting functions are added to return
the right lock for a page or a mem_cgroup.

Two flags are used to identify the right memcg LRU lock, AcctLRU bit and Used
bit. When we delete page from LRU, the AcctLRU bit is used since we first
uncharge the page and remove it from lru. When we add page into LRU, the Used bit
is used since we first charge the page and then add into the LRU list.

Signed-off-by: Suleiman Souhlal <suleiman@google.com>
Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h |   17 +++++++
 mm/compaction.c            |   41 +++++++++++------
 mm/huge_memory.c           |    5 +-
 mm/memcontrol.c            |   63 +++++++++++++++++++++++---
 mm/swap.c                  |   69 ++++++++++++++++------------
 mm/vmscan.c                |  106 ++++++++++++++++++++++++++++++-------------
 6 files changed, 215 insertions(+), 86 deletions(-)

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
diff --git a/mm/compaction.c b/mm/compaction.c
index 021a296..9fcbb98 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -251,6 +251,7 @@ static unsigned long isolate_migratepages(struct zone *zone,
 	unsigned long last_pageblock_nr = 0, pageblock_nr;
 	unsigned long nr_scanned = 0, nr_isolated = 0;
 	struct list_head *migratelist = &cc->migratepages;
+	spinlock_t *old_lru_lock = NULL;
 
 	/* Do not scan outside zone boundaries */
 	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
@@ -278,35 +279,44 @@ static unsigned long isolate_migratepages(struct zone *zone,
 
 	/* Time to isolate some pages for migration */
 	cond_resched();
-	spin_lock_irq(&zone->lru_lock);
+
 	for (; low_pfn < end_pfn; low_pfn++) {
 		struct page *page;
 		bool locked = true;
+		spinlock_t *lru_lock;
+
+		if (!pfn_valid_within(low_pfn))
+			continue;
+
+		/* Get the page and skip if free */
+		page = pfn_to_page(low_pfn);
+		if (PageBuddy(page))
+			continue;
+
+		lru_lock = page_lru_lock(page);
+		if (lru_lock != old_lru_lock) {
+			if (locked && old_lru_lock)
+				spin_unlock_irq(old_lru_lock);
+			old_lru_lock = lru_lock;
+			spin_lock_irq(old_lru_lock);
+		}
 
 		/* give a chance to irqs before checking need_resched() */
 		if (!((low_pfn+1) % SWAP_CLUSTER_MAX)) {
-			spin_unlock_irq(&zone->lru_lock);
+			spin_unlock_irq(old_lru_lock);
 			locked = false;
 		}
-		if (need_resched() || spin_is_contended(&zone->lru_lock)) {
+		if (need_resched() || spin_is_contended(old_lru_lock)) {
 			if (locked)
-				spin_unlock_irq(&zone->lru_lock);
+				spin_unlock_irq(old_lru_lock);
 			cond_resched();
-			spin_lock_irq(&zone->lru_lock);
+			spin_lock_irq(old_lru_lock);
 			if (fatal_signal_pending(current))
 				break;
 		} else if (!locked)
-			spin_lock_irq(&zone->lru_lock);
+			spin_lock_irq(old_lru_lock);
 
-		if (!pfn_valid_within(low_pfn))
-			continue;
 		nr_scanned++;
-
-		/* Get the page and skip if free */
-		page = pfn_to_page(low_pfn);
-		if (PageBuddy(page))
-			continue;
-
 		/*
 		 * For async migration, also only scan in MOVABLE blocks. Async
 		 * migration is optimistic to see if the minimum amount of work
@@ -353,7 +363,8 @@ static unsigned long isolate_migratepages(struct zone *zone,
 
 	acct_isolated(zone, cc);
 
-	spin_unlock_irq(&zone->lru_lock);
+	if (old_lru_lock)
+		spin_unlock_irq(old_lru_lock);
 	cc->migrate_pfn = low_pfn;
 
 	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d3f601d..8d910c0 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1156,9 +1156,10 @@ static void __split_huge_page_refcount(struct page *page)
 	unsigned long head_index = page->index;
 	struct zone *zone = page_zone(page);
 	int zonestat;
+	spinlock_t *lru_lock = page_lru_lock(page);
 
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(lru_lock);
 	compound_lock(page);
 
 	for (i = 1; i < HPAGE_PMD_NR; i++) {
@@ -1238,7 +1239,7 @@ static void __split_huge_page_refcount(struct page *page)
 
 	ClearPageCompound(page);
 	compound_unlock(page);
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(lru_lock);
 
 	for (i = 1; i < HPAGE_PMD_NR; i++) {
 		struct page *page_tail = page + i;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9ba531c..f18669b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -144,6 +144,7 @@ struct mem_cgroup_stat_cpu {
  * per-zone information in memory controller.
  */
 struct mem_cgroup_per_zone {
+	spinlock_t lru_lock;
 	struct lruvec		lruvec;
 	unsigned long		count[NR_LRU_LISTS];
 
@@ -727,6 +728,46 @@ out:
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
+
+	lock_page_cgroup(pc);
+	if (PageCgroupAcctLRU(pc) || PageCgroupUsed(pc)) {
+		smp_rmb();
+		mem = pc->mem_cgroup;
+	} else
+		mem = root_mem_cgroup;
+	unlock_page_cgroup(pc);
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
+	if (mem_cgroup_disabled())
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
@@ -884,6 +925,7 @@ struct lruvec *mem_cgroup_lru_move_lists(struct zone *zone,
 static void mem_cgroup_lru_del_before_commit(struct page *page)
 {
 	unsigned long flags;
+	spinlock_t *lru_lock;
 	struct zone *zone = page_zone(page);
 	struct page_cgroup *pc = lookup_page_cgroup(page);
 
@@ -898,29 +940,33 @@ static void mem_cgroup_lru_del_before_commit(struct page *page)
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
+
+	lru_lock = page_lru_lock(page);
+	spin_lock_irqsave(lru_lock, flags);
 	if (PageLRU(page) && !PageCgroupAcctLRU(pc))
 		add_page_to_lru_list(zone, page, page_lru(page));
-	spin_unlock_irqrestore(&zone->lru_lock, flags);
+	spin_unlock_irqrestore(lru_lock, flags);
 }
 
 int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
@@ -3267,19 +3313,19 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *mem,
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
 
@@ -4332,6 +4378,7 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
 	mem->info.nodeinfo[node] = pn;
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 		mz = &pn->zoneinfo[zone];
+		spin_lock_init(&mz->lru_lock);
 		for_each_lru(l)
 			INIT_LIST_HEAD(&mz->lruvec.lists[l]);
 	}
diff --git a/mm/swap.c b/mm/swap.c
index 9ae3a4b..dce5871 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -31,6 +31,7 @@
 #include <linux/backing-dev.h>
 #include <linux/memcontrol.h>
 #include <linux/gfp.h>
+#include <linux/page_cgroup.h>
 
 #include "internal.h"
 
@@ -50,12 +51,14 @@ static void __page_cache_release(struct page *page)
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
 
@@ -184,24 +187,23 @@ static void pagevec_lru_move_fn(struct pagevec *pvec,
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
@@ -322,11 +324,12 @@ static inline void activate_page_drain(int cpu)
 
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
 
@@ -393,12 +396,15 @@ void lru_cache_add_lru(struct page *page, enum lru_list lru)
 void add_page_to_unevictable_list(struct page *page)
 {
 	struct zone *zone = page_zone(page);
+	spinlock_t *lru_lock;
+
+	lru_lock = page_lru_lock(page);
 
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(lru_lock);
 	SetPageUnevictable(page);
 	SetPageLRU(page);
 	add_page_to_lru_list(zone, page, LRU_UNEVICTABLE);
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(lru_lock);
 }
 
 /*
@@ -568,14 +574,16 @@ void release_pages(struct page **pages, int nr, int cold)
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
@@ -587,13 +595,14 @@ void release_pages(struct page **pages, int nr, int cold)
 
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
@@ -601,16 +610,17 @@ void release_pages(struct page **pages, int nr, int cold)
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
@@ -642,11 +652,12 @@ void lru_add_page_tail(struct zone* zone,
 	int active;
 	enum lru_list lru;
 	const int file = 0;
+	spinlock_t *lru_lock = page_lru_lock(page);
 
 	VM_BUG_ON(!PageHead(page));
 	VM_BUG_ON(PageCompound(page_tail));
 	VM_BUG_ON(PageLRU(page_tail));
-	VM_BUG_ON(!spin_is_locked(&zone->lru_lock));
+	VM_BUG_ON(!spin_is_locked(lru_lock));
 
 	SetPageLRU(page_tail);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a825404..b132cc2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -42,6 +42,7 @@
 #include <linux/delayacct.h>
 #include <linux/sysctl.h>
 #include <linux/oom.h>
+#include <linux/page_cgroup.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -1003,27 +1004,35 @@ int __isolate_lru_page(struct page *page, int mode, int file)
 	int ret = -EINVAL;
 
 	/* Only take pages on the LRU. */
-	if (!PageLRU(page))
+	if (!PageLRU(page)) {
+		trace_printk("%d\n", 1);
 		return ret;
+	}
 
 	/*
 	 * When checking the active state, we need to be sure we are
 	 * dealing with comparible boolean values.  Take the logical not
 	 * of each.
 	 */
-	if (mode != ISOLATE_BOTH && (!PageActive(page) != !mode))
+	if (mode != ISOLATE_BOTH && (!PageActive(page) != !mode)) {
+		trace_printk("%d\n", 2);
 		return ret;
+	}
 
-	if (mode != ISOLATE_BOTH && page_is_file_cache(page) != file)
+	if (mode != ISOLATE_BOTH && page_is_file_cache(page) != file) {
+		trace_printk("%d\n", 3);
 		return ret;
+	}
 
 	/*
 	 * When this function is being called for lumpy reclaim, we
 	 * initially look into all LRU pages, active, inactive and
 	 * unevictable; only give shrink_page_list evictable pages.
 	 */
-	if (PageUnevictable(page))
+	if (PageUnevictable(page)) {
+		trace_printk("%d\n", 4);
 		return ret;
+	}
 
 	ret = -EBUSY;
 
@@ -1069,6 +1078,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	unsigned long nr_lumpy_dirty = 0;
 	unsigned long nr_lumpy_failed = 0;
 	unsigned long scan;
+	spinlock_t *lru_lock;
 
 	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
 		struct page *page;
@@ -1112,10 +1122,13 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		 */
 		zone_id = page_zone_id(page);
 		page_pfn = page_to_pfn(page);
+		lru_lock = page_lru_lock(page);
+
 		pfn = page_pfn & ~((1 << order) - 1);
 		end_pfn = pfn + (1 << order);
 		for (; pfn < end_pfn; pfn++) {
 			struct page *cursor_page;
+			spinlock_t *cursor_lru_lock;
 
 			/* The target page is in the block, ignore it. */
 			if (unlikely(pfn == page_pfn))
@@ -1140,6 +1153,14 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			    !PageSwapCache(cursor_page))
 				break;
 
+			/*
+			 * We give up the lumpy reclaim if the page needs
+			 * different lock to prevent deadlock.
+			 */
+			cursor_lru_lock = page_lru_lock(cursor_page);
+			if (cursor_lru_lock != lru_lock)
+				break;
+
 			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
 				mem_cgroup_lru_del(cursor_page);
 				list_move(&cursor_page->lru, dst);
@@ -1248,8 +1269,9 @@ int isolate_lru_page(struct page *page)
 
 	if (PageLRU(page)) {
 		struct zone *zone = page_zone(page);
+		spinlock_t *lru_lock = page_lru_lock(page);
 
-		spin_lock_irq(&zone->lru_lock);
+		spin_lock_irq(lru_lock);
 		if (PageLRU(page)) {
 			int lru = page_lru(page);
 			ret = 0;
@@ -1258,7 +1280,7 @@ int isolate_lru_page(struct page *page)
 
 			del_page_from_lru_list(zone, page, lru);
 		}
-		spin_unlock_irq(&zone->lru_lock);
+		spin_unlock_irq(lru_lock);
 	}
 	return ret;
 }
@@ -1299,22 +1321,25 @@ putback_lru_pages(struct zone *zone, struct scan_control *sc,
 	struct page *page;
 	struct pagevec pvec;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
-
+	spinlock_t *lru_lock;
 	pagevec_init(&pvec, 1);
 
 	/*
 	 * Put back any unfreeable pages.
 	 */
-	spin_lock(&zone->lru_lock);
+	lru_lock = mem_cgroup_lru_lock(sc->mem_cgroup, zone);
+	spin_lock(lru_lock);
 	while (!list_empty(page_list)) {
 		int lru;
+
 		page = lru_to_page(page_list);
 		VM_BUG_ON(PageLRU(page));
+
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
@@ -1326,15 +1351,15 @@ putback_lru_pages(struct zone *zone, struct scan_control *sc,
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
 
@@ -1424,6 +1449,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 	unsigned long nr_taken;
 	unsigned long nr_anon;
 	unsigned long nr_file;
+	spinlock_t *lru_lock;
 
 	while (unlikely(too_many_isolated(zone, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -1435,8 +1461,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 
 	set_reclaim_mode(priority, sc, false);
 	lru_add_drain();
-	spin_lock_irq(&zone->lru_lock);
 
+	lru_lock = mem_cgroup_lru_lock(sc->mem_cgroup, zone);
+
+	spin_lock_irq(lru_lock);
 	nr_taken = isolate_pages(nr_to_scan,
 				 &page_list, &nr_scanned, sc->order,
 				 sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
@@ -1454,13 +1482,13 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
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
 
@@ -1510,6 +1538,7 @@ static void move_active_pages_to_lru(struct zone *zone,
 	unsigned long pgmoved = 0;
 	struct pagevec pvec;
 	struct page *page;
+	spinlock_t *lru_lock;
 
 	pagevec_init(&pvec, 1);
 
@@ -1524,13 +1553,14 @@ static void move_active_pages_to_lru(struct zone *zone,
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
@@ -1550,9 +1580,13 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	struct page *page;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 	unsigned long nr_rotated = 0;
+	spinlock_t *lru_lock;
 
 	lru_add_drain();
-	spin_lock_irq(&zone->lru_lock);
+
+	lru_lock = mem_cgroup_lru_lock(sc->mem_cgroup, zone);
+
+	spin_lock_irq(lru_lock);
 	nr_taken = isolate_pages(nr_pages, &l_hold,
 				 &pgscanned, sc->order,
 				 ISOLATE_ACTIVE, zone,
@@ -1569,7 +1603,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	else
 		__mod_zone_page_state(zone, NR_ACTIVE_ANON, -nr_taken);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(lru_lock);
 
 	while (!list_empty(&l_hold)) {
 		cond_resched();
@@ -1605,7 +1639,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	/*
 	 * Move pages back to the lru list.
 	 */
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(lru_lock);
 	/*
 	 * Count referenced pages from currently used mappings as rotated,
 	 * even though only some of them are actually re-activated.  This
@@ -1619,7 +1653,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	move_active_pages_to_lru(zone, &l_inactive,
 						LRU_BASE   + file * LRU_FILE);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(lru_lock);
 }
 
 #ifdef CONFIG_SWAP
@@ -1747,7 +1781,9 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
 	enum lru_list l;
 	int noswap = 0;
 	int force_scan = 0;
+	spinlock_t *lru_lock;
 
+	lru_lock = mem_cgroup_lru_lock(sc->mem_cgroup, zone);
 
 	anon  = zone_nr_lru_pages(zone, sc->mem_cgroup, LRU_ACTIVE_ANON) +
 		zone_nr_lru_pages(zone, sc->mem_cgroup, LRU_INACTIVE_ANON);
@@ -1802,7 +1838,7 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
 	 *
 	 * anon in [0], file in [1]
 	 */
-	spin_lock_irq(&zone->lru_lock);
+	spin_lock_irq(lru_lock);
 	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
 		reclaim_stat->recent_scanned[0] /= 2;
 		reclaim_stat->recent_rotated[0] /= 2;
@@ -1823,7 +1859,7 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
 
 	fp = (file_prio + 1) * (reclaim_stat->recent_scanned[1] + 1);
 	fp /= reclaim_stat->recent_rotated[1] + 1;
-	spin_unlock_irq(&zone->lru_lock);
+	spin_unlock_irq(lru_lock);
 
 	fraction[0] = ap;
 	fraction[1] = fp;
@@ -3238,6 +3274,7 @@ void scan_mapping_unevictable_pages(struct address_space *mapping)
 			 PAGE_CACHE_SHIFT;
 	struct zone *zone;
 	struct pagevec pvec;
+	spinlock_t *old_lock;
 
 	if (mapping->nrpages == 0)
 		return;
@@ -3249,29 +3286,32 @@ void scan_mapping_unevictable_pages(struct address_space *mapping)
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
@@ -3293,6 +3333,7 @@ void scan_mapping_unevictable_pages(struct address_space *mapping)
 static void scan_zone_unevictable_pages(struct zone *zone)
 {
 	struct mem_cgroup *first, *mem = NULL;
+	spinlock_t *lru_lock;
 
 	first = mem = mem_cgroup_hierarchy_walk(NULL, mem);
 	do {
@@ -3303,6 +3344,7 @@ static void scan_zone_unevictable_pages(struct zone *zone)
 		nr_to_scan = zone_nr_lru_pages(zone, mem, LRU_UNEVICTABLE);
 		lruvec = mem_cgroup_zone_lruvec(zone, mem);
 		list = &lruvec->lists[LRU_UNEVICTABLE];
+		lru_lock = mem_cgroup_lru_lock(mem, zone);
 
 		while (nr_to_scan > 0) {
 			unsigned long batch_size;
@@ -3311,7 +3353,7 @@ static void scan_zone_unevictable_pages(struct zone *zone)
 			batch_size = min(nr_to_scan,
 					 SCAN_UNEVICTABLE_BATCH_SIZE);
 
-			spin_lock_irq(&zone->lru_lock);
+			spin_lock_irq(lru_lock);
 			for (scan = 0; scan < batch_size; scan++) {
 				struct page *page;
 
@@ -3323,7 +3365,7 @@ static void scan_zone_unevictable_pages(struct zone *zone)
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
