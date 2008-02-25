Date: Mon, 25 Feb 2008 23:36:20 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 02/15] memcg: move_lists on page not page_cgroup
In-Reply-To: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
Message-ID: <Pine.LNX.4.64.0802252335400.27067@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Each caller of mem_cgroup_move_lists is having to use page_get_page_cgroup:
it's more convenient if it acts upon the page itself not the page_cgroup;
and in a later patch this becomes important to handle within memcontrol.c.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 include/linux/memcontrol.h |    5 ++---
 mm/memcontrol.c            |    4 +++-
 mm/swap.c                  |    2 +-
 mm/vmscan.c                |    5 +++--
 4 files changed, 9 insertions(+), 7 deletions(-)

--- memcg01/include/linux/memcontrol.h	2008-02-25 14:05:35.000000000 +0000
+++ memcg02/include/linux/memcontrol.h	2008-02-25 14:05:38.000000000 +0000
@@ -36,7 +36,7 @@ extern int mem_cgroup_charge(struct page
 				gfp_t gfp_mask);
 extern void mem_cgroup_uncharge(struct page_cgroup *pc);
 extern void mem_cgroup_uncharge_page(struct page *page);
-extern void mem_cgroup_move_lists(struct page_cgroup *pc, bool active);
+extern void mem_cgroup_move_lists(struct page *page, bool active);
 extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct list_head *dst,
 					unsigned long *scanned, int order,
@@ -106,8 +106,7 @@ static inline void mem_cgroup_uncharge_p
 {
 }
 
-static inline void mem_cgroup_move_lists(struct page_cgroup *pc,
-						bool active)
+static inline void mem_cgroup_move_lists(struct page *page, bool active)
 {
 }
 
--- memcg01/mm/memcontrol.c	2008-02-25 14:05:35.000000000 +0000
+++ memcg02/mm/memcontrol.c	2008-02-25 14:05:38.000000000 +0000
@@ -407,11 +407,13 @@ int task_in_mem_cgroup(struct task_struc
 /*
  * This routine assumes that the appropriate zone's lru lock is already held
  */
-void mem_cgroup_move_lists(struct page_cgroup *pc, bool active)
+void mem_cgroup_move_lists(struct page *page, bool active)
 {
+	struct page_cgroup *pc;
 	struct mem_cgroup_per_zone *mz;
 	unsigned long flags;
 
+	pc = page_get_page_cgroup(page);
 	if (!pc)
 		return;
 
--- memcg01/mm/swap.c	2008-02-11 07:18:12.000000000 +0000
+++ memcg02/mm/swap.c	2008-02-25 14:05:38.000000000 +0000
@@ -176,7 +176,7 @@ void activate_page(struct page *page)
 		SetPageActive(page);
 		add_page_to_active_list(zone, page);
 		__count_vm_event(PGACTIVATE);
-		mem_cgroup_move_lists(page_get_page_cgroup(page), true);
+		mem_cgroup_move_lists(page, true);
 	}
 	spin_unlock_irq(&zone->lru_lock);
 }
--- memcg01/mm/vmscan.c	2008-02-11 07:18:12.000000000 +0000
+++ memcg02/mm/vmscan.c	2008-02-25 14:05:38.000000000 +0000
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
