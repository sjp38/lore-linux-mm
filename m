Date: Mon, 25 Feb 2008 12:13:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] radix-tree based page_cgroup. [3/7] move lists
Message-Id: <20080225121323.33fc1364.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080225120758.27648297.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080225120758.27648297.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, taka@valinux.co.jp, Andi Kleen <ak@suse.de>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

mem_cgroup_move_lists() is called from external functions to notify
lru is rotated.

	1. get reference if not freed.
	2. rotate page.
	3. put reference

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 include/linux/memcontrol.h |    7 -----
 mm/memcontrol.c            |   60 ++++++++++++++++++++++++++++++++-------------
 mm/swap.c                  |    2 -
 mm/vmscan.c                |    4 +--
 4 files changed, 47 insertions(+), 26 deletions(-)

Index: linux-2.6.25-rc2/mm/memcontrol.c
===================================================================
--- linux-2.6.25-rc2.orig/mm/memcontrol.c
+++ linux-2.6.25-rc2/mm/memcontrol.c
@@ -310,23 +310,6 @@ int task_in_mem_cgroup(struct task_struc
 }
 
 /*
- * This routine assumes that the appropriate zone's lru lock is already held
- */
-void mem_cgroup_move_lists(struct page_cgroup *pc, bool active)
-{
-	struct mem_cgroup_per_zone *mz;
-	unsigned long flags;
-
-	if (!pc)
-		return;
-
-	mz = page_cgroup_zoneinfo(pc);
-	spin_lock_irqsave(&mz->lru_lock, flags);
-	__mem_cgroup_move_lists(pc, active);
-	spin_unlock_irqrestore(&mz->lru_lock, flags);
-}
-
-/*
  * Calculate mapped_ratio under memory controller. This will be used in
  * vmscan.c for deteremining we have to reclaim mapped pages.
  */
@@ -470,6 +453,27 @@ unsigned long mem_cgroup_isolate_pages(u
 }
 
 /*
+ * Just increment page_cgroup's refcnt and return it.
+ * if there is used one.
+ */
+static struct page_cgroup *page_cgroup_getref(struct page *page)
+{
+	struct page_cgroup *pc = get_page_cgroup(page, 0);
+	struct page_cgroup *ret = NULL;
+	unsigned long flags;
+
+	if (!pc)
+		return ret;
+	spin_lock_irqsave(&pc->lock, flags);
+	if (pc->refcnt) {
+		++pc->refcnt;
+		ret = pc;
+	}
+	spin_unlock_irqrestore(&pc->lock, flags);
+	return ret;
+}
+
+/*
  * Charge the memory controller for page usage.
  * Return
  * 0 if the charge was successful
@@ -635,6 +639,28 @@ void mem_cgroup_uncharge_page(struct pag
 	mem_cgroup_uncharge(get_page_cgroup(page, 0));
 }
 
+void mem_cgroup_move_lists(struct page *page, bool active)
+{
+	struct page_cgroup *pc;
+	struct mem_cgroup_per_zone *mz;
+	unsigned long flags;
+
+	pc = page_cgroup_getref(page);
+	if (!pc)
+		return;
+	/* pc<->page relation ship is stable. */
+	mz = page_cgroup_zoneinfo(pc);
+	spin_lock_irqsave(&mz->lru_lock, flags);
+	/* This check is necessary. Anything can happen because
+	   we relaased lock. */
+	if (!list_empty(&pc->lru))
+		__mem_cgroup_move_lists(pc, active);
+	spin_unlock_irqrestore(&mz->lru_lock, flags);
+
+	mem_cgroup_uncharge_page(page);
+}
+
+
 /*
  * Returns non-zero if a page (under migration) has valid page_cgroup member.
  * Refcnt of page_cgroup is incremented.
Index: linux-2.6.25-rc2/mm/swap.c
===================================================================
--- linux-2.6.25-rc2.orig/mm/swap.c
+++ linux-2.6.25-rc2/mm/swap.c
@@ -176,7 +176,7 @@ void activate_page(struct page *page)
 		SetPageActive(page);
 		add_page_to_active_list(zone, page);
 		__count_vm_event(PGACTIVATE);
-		mem_cgroup_move_lists(page_get_page_cgroup(page), true);
+		mem_cgroup_move_lists(page, true);
 	}
 	spin_unlock_irq(&zone->lru_lock);
 }
Index: linux-2.6.25-rc2/mm/vmscan.c
===================================================================
--- linux-2.6.25-rc2.orig/mm/vmscan.c
+++ linux-2.6.25-rc2/mm/vmscan.c
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
Index: linux-2.6.25-rc2/include/linux/memcontrol.h
===================================================================
--- linux-2.6.25-rc2.orig/include/linux/memcontrol.h
+++ linux-2.6.25-rc2/include/linux/memcontrol.h
@@ -36,7 +36,7 @@ extern int mem_cgroup_charge(struct page
 				gfp_t gfp_mask);
 extern void mem_cgroup_uncharge(struct page_cgroup *pc);
 extern void mem_cgroup_uncharge_page(struct page *page);
-extern void mem_cgroup_move_lists(struct page_cgroup *pc, bool active);
+extern void mem_cgroup_move_lists(struct page *page, bool active);
 extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct list_head *dst,
 					unsigned long *scanned, int order,
@@ -96,11 +96,6 @@ static inline void mem_cgroup_uncharge_p
 {
 }
 
-static inline void mem_cgroup_move_lists(struct page_cgroup *pc,
-						bool active)
-{
-}
-
 static inline int mem_cgroup_cache_charge(struct page *page,
 						struct mm_struct *mm,
 						gfp_t gfp_mask)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
