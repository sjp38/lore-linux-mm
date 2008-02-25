Date: Mon, 25 Feb 2008 23:50:27 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 14/15] memcg: simplify force_empty and move_lists
In-Reply-To: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
Message-ID: <Pine.LNX.4.64.0802252349100.27067@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
From: Hirokazu Takahashi <taka@valinux.co.jp>
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

As for force_empty, though this may not be the main topic here,
mem_cgroup_force_empty_list() can be implemented simpler.
It is possible to make the function just call mem_cgroup_uncharge_page()
instead of releasing page_cgroups by itself.  The tip is to call get_page()
before invoking mem_cgroup_uncharge_page(), so the page won't be released
during this function.

Kamezawa-san points out that by the time mem_cgroup_uncharge_page()
uncharges, the page might have been reassigned to an lru of a different
mem_cgroup, and now be emptied from that; but Hugh claims that's okay,
the end state is the same as when it hasn't gone to another list.

And once force_empty stops taking lock_page_cgroup within mz->lru_lock,
mem_cgroup_move_lists() can be simplified to take mz->lru_lock directly
while holding page_cgroup lock (but still has to use try_lock_page_cgroup).

Signed-off-by: Hirokazu Takahashi <taka@valinux.co.jp>
Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/memcontrol.c |   62 +++++++++-------------------------------------
 1 file changed, 13 insertions(+), 49 deletions(-)

--- memcg13/mm/memcontrol.c	2008-02-25 14:06:25.000000000 +0000
+++ memcg14/mm/memcontrol.c	2008-02-25 14:06:28.000000000 +0000
@@ -353,7 +353,6 @@ int task_in_mem_cgroup(struct task_struc
 void mem_cgroup_move_lists(struct page *page, bool active)
 {
 	struct page_cgroup *pc;
-	struct mem_cgroup *mem;
 	struct mem_cgroup_per_zone *mz;
 	unsigned long flags;
 
@@ -367,35 +366,14 @@ void mem_cgroup_move_lists(struct page *
 	if (!try_lock_page_cgroup(page))
 		return;
 
-	/*
-	 * Now page_cgroup is stable, but we cannot acquire mz->lru_lock
-	 * while holding it, because mem_cgroup_force_empty_list does the
-	 * reverse.  Get a hold on the mem_cgroup before unlocking, so that
-	 * the zoneinfo remains stable, then take mz->lru_lock; then check
-	 * that page still points to pc and pc (even if freed and reassigned
-	 * to that same page meanwhile) still points to the same mem_cgroup.
-	 * Then we know mz still points to the right spinlock, so it's safe
-	 * to move_lists (page->page_cgroup might be reset while we do so, but
-	 * that doesn't matter: pc->page is stable till we drop mz->lru_lock).
-	 * We're being a little naughty not to try_lock_page_cgroup again
-	 * inside there, but we are safe, aren't we?  Aren't we?  Whistle...
-	 */
 	pc = page_get_page_cgroup(page);
 	if (pc) {
-		mem = pc->mem_cgroup;
 		mz = page_cgroup_zoneinfo(pc);
-		css_get(&mem->css);
-
-		unlock_page_cgroup(page);
-
 		spin_lock_irqsave(&mz->lru_lock, flags);
-		if (page_get_page_cgroup(page) == pc && pc->mem_cgroup == mem)
-			__mem_cgroup_move_lists(pc, active);
+		__mem_cgroup_move_lists(pc, active);
 		spin_unlock_irqrestore(&mz->lru_lock, flags);
-
-		css_put(&mem->css);
-	} else
-		unlock_page_cgroup(page);
+	}
+	unlock_page_cgroup(page);
 }
 
 /*
@@ -789,7 +767,7 @@ static void mem_cgroup_force_empty_list(
 {
 	struct page_cgroup *pc;
 	struct page *page;
-	int count;
+	int count = FORCE_UNCHARGE_BATCH;
 	unsigned long flags;
 	struct list_head *list;
 
@@ -798,35 +776,21 @@ static void mem_cgroup_force_empty_list(
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
-		lock_page_cgroup(page);
-		if (page_get_page_cgroup(page) == pc) {
-			page_assign_page_cgroup(page, NULL);
-			unlock_page_cgroup(page);
-			__mem_cgroup_remove_list(pc);
-			res_counter_uncharge(&mem->res, PAGE_SIZE);
-			css_put(&mem->css);
-			kfree(pc);
-		} else {
-			/* racing uncharge: let page go then retry */
-			unlock_page_cgroup(page);
-			break;
+		get_page(page);
+		spin_unlock_irqrestore(&mz->lru_lock, flags);
+		mem_cgroup_uncharge_page(page);
+		put_page(page);
+		if (--count <= 0) {
+			count = FORCE_UNCHARGE_BATCH;
+			cond_resched();
 		}
+		spin_lock_irqsave(&mz->lru_lock, flags);
 	}
-
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
-	if (!list_empty(list)) {
-		cond_resched();
-		goto retry;
-	}
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
