Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 4D7726B002C
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 13:37:40 -0500 (EST)
Received: by dadv6 with SMTP id v6so2210426dad.14
        for <linux-mm@kvack.org>; Fri, 02 Mar 2012 10:37:39 -0800 (PST)
Date: Fri, 2 Mar 2012 10:37:04 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 3.3] memcg: fix GPF when cgroup removal races with last
 exit
Message-ID: <alpine.LSU.2.00.1203021030140.2094@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

When moving tasks from old memcg (with move_charge_at_immigrate on new
memcg), followed by removal of old memcg, hit General Protection Fault
in mem_cgroup_lru_del_list() (called from release_pages called from
free_pages_and_swap_cache from tlb_flush_mmu from tlb_finish_mmu from
exit_mmap from mmput from exit_mm from do_exit).

Somewhat reproducible, takes a few hours: the old struct mem_cgroup has
been freed and poisoned by SLAB_DEBUG, but mem_cgroup_lru_del_list() is
still trying to update its stats, and take page off lru before freeing.

A task, or a charge, or a page on lru: each secures a memcg against
removal.  In this case, the last task has been moved out of the old
memcg, and it is exiting: anonymous pages are uncharged one by one
from the memcg, as they are zapped from its pagetables, so the charge
gets down to 0; but the pages themselves are queued in an mmu_gather
for freeing.

Most of those pages will be on lru (and force_empty is careful to
lru_add_drain_all, to add pages from pagevec to lru first), but not
necessarily all: perhaps some have been isolated for page reclaim,
perhaps some isolated for other reasons.  So, force_empty may find
no task, no charge and no page on lru, and let the removal proceed.

There would still be no problem if these pages were immediately
freed; but typically (and the put_page_testzero protocol demands it)
they have to be added back to lru before they are found freeable,
then removed from lru and freed.  We don't see the issue when adding,
because the mem_cgroup_iter() loops keep their own reference to the
memcg being scanned; but when it comes to mem_cgroup_lru_del_list().

I believe this was not an issue in v3.2: there, PageCgroupAcctLRU and
PageCgroupUsed flags were used (like a trick with mirrors) to deflect
view of pc->mem_cgroup to the stable root_mem_cgroup when neither set.
38c5d72f3ebe "memcg: simplify LRU handling by new rule" mercifully
removed those convolutions, but left this General Protection Fault.

But it's surprisingly easy to restore the old behaviour: just check
PageCgroupUsed in mem_cgroup_lru_add_list() (which decides on which
lruvec to add), and reset pc to root_mem_cgroup if page is uncharged.
A risky change? just going back to how it worked before; testing,
and an audit of uses of pc->mem_cgroup, show no problem.

And there's a nice bonus: with mem_cgroup_lru_add_list() itself making
sure that an uncharged page goes to root lru, mem_cgroup_reset_owner()
no longer has any purpose, and we can safely revert 4e5f01c2b9b9
"memcg: clear pc->mem_cgroup if necessary".

Calling update_page_reclaim_stat() after add_page_to_lru_list() in
swap.c is not strictly necessary: the lru_lock there, with RCU before
memcg structures are freed, makes mem_cgroup_get_reclaim_stat_from_page
safe without that; but it seems cleaner to rely on one dependency less.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

I had to delay sending this for a few days, since tests were still
crashing, but differently.  Now I understand why: it's a different bug,
and not even a regression, confined to memcg swap accounting - I'll
send a fix to that one in a couple of days.

Konstantin, I've not yet looked into how this patch affects your
patchsets; but I do know that this surreptitious-switch-to-root
behaviour seemed nightmarish when I was doing per-memcg per-zone
locking (particularly inside something like __activate_page(), where
we del and add under a single lock), and unnecessary once you and I
secure the memcg differently.  So you may just want to revert this in
patches for linux-next; but I've a suspicion that now we understand
it better, this technique might still be usable, and more efficient.

 include/linux/memcontrol.h |    5 -----
 mm/ksm.c                   |   11 -----------
 mm/memcontrol.c            |   30 +++++++++++++-----------------
 mm/migrate.c               |    2 --
 mm/swap.c                  |    8 +++++---
 mm/swap_state.c            |   10 ----------
 6 files changed, 18 insertions(+), 48 deletions(-)

--- 3.3-rc5/include/linux/memcontrol.h	2012-01-24 20:40:19.201922679 -0800
+++ linux/include/linux/memcontrol.h	2012-02-29 10:17:45.180012045 -0800
@@ -129,7 +129,6 @@ extern void mem_cgroup_print_oom_info(st
 extern void mem_cgroup_replace_page_cache(struct page *oldpage,
 					struct page *newpage);
 
-extern void mem_cgroup_reset_owner(struct page *page);
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern int do_swap_account;
 #endif
@@ -392,10 +391,6 @@ static inline void mem_cgroup_replace_pa
 				struct page *newpage)
 {
 }
-
-static inline void mem_cgroup_reset_owner(struct page *page)
-{
-}
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)
--- 3.3-rc5/mm/ksm.c	2012-01-20 08:42:35.000000000 -0800
+++ linux/mm/ksm.c	2012-02-29 10:15:18.456008873 -0800
@@ -28,7 +28,6 @@
 #include <linux/kthread.h>
 #include <linux/wait.h>
 #include <linux/slab.h>
-#include <linux/memcontrol.h>
 #include <linux/rbtree.h>
 #include <linux/memory.h>
 #include <linux/mmu_notifier.h>
@@ -1572,16 +1571,6 @@ struct page *ksm_does_need_to_copy(struc
 
 	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
 	if (new_page) {
-		/*
-		 * The memcg-specific accounting when moving
-		 * pages around the LRU lists relies on the
-		 * page's owner (memcg) to be valid.  Usually,
-		 * pages are assigned to a new owner before
-		 * being put on the LRU list, but since this
-		 * is not the case here, the stale owner from
-		 * a previous allocation cycle must be reset.
-		 */
-		mem_cgroup_reset_owner(new_page);
 		copy_user_highpage(new_page, page, address, vma);
 
 		SetPageDirty(new_page);
--- 3.3-rc5/mm/memcontrol.c	2012-02-25 13:02:05.165830574 -0800
+++ linux/mm/memcontrol.c	2012-02-29 14:23:57.492362468 -0800
@@ -1042,6 +1042,19 @@ struct lruvec *mem_cgroup_lru_add_list(s
 
 	pc = lookup_page_cgroup(page);
 	memcg = pc->mem_cgroup;
+
+	/*
+	 * Surreptitiously switch any uncharged page to root:
+	 * an uncharged page off lru does nothing to secure
+	 * its former mem_cgroup from sudden removal.
+	 *
+	 * Our caller holds lru_lock, and PageCgroupUsed is updated
+	 * under page_cgroup lock: between them, they make all uses
+	 * of pc->mem_cgroup safe.
+	 */
+	if (!PageCgroupUsed(pc) && memcg != root_mem_cgroup)
+		pc->mem_cgroup = memcg = root_mem_cgroup;
+
 	mz = page_cgroup_zoneinfo(memcg, page);
 	/* compound_order() is stabilized through lru_lock */
 	MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page);
@@ -3027,23 +3040,6 @@ void mem_cgroup_uncharge_end(void)
 	batch->memcg = NULL;
 }
 
-/*
- * A function for resetting pc->mem_cgroup for newly allocated pages.
- * This function should be called if the newpage will be added to LRU
- * before start accounting.
- */
-void mem_cgroup_reset_owner(struct page *newpage)
-{
-	struct page_cgroup *pc;
-
-	if (mem_cgroup_disabled())
-		return;
-
-	pc = lookup_page_cgroup(newpage);
-	VM_BUG_ON(PageCgroupUsed(pc));
-	pc->mem_cgroup = root_mem_cgroup;
-}
-
 #ifdef CONFIG_SWAP
 /*
  * called after __delete_from_swap_cache() and drop "page" account.
--- 3.3-rc5/mm/migrate.c	2012-02-05 16:33:52.405387309 -0800
+++ linux/mm/migrate.c	2012-02-29 10:14:21.140006935 -0800
@@ -839,8 +839,6 @@ static int unmap_and_move(new_page_t get
 	if (!newpage)
 		return -ENOMEM;
 
-	mem_cgroup_reset_owner(newpage);
-
 	if (page_count(page) == 1) {
 		/* page was freed from under us. So we are done. */
 		goto out;
--- 3.3-rc5/mm/swap.c	2012-02-08 20:50:28.365491381 -0800
+++ linux/mm/swap.c	2012-02-29 14:38:55.556384455 -0800
@@ -652,7 +652,7 @@ EXPORT_SYMBOL(__pagevec_release);
 void lru_add_page_tail(struct zone* zone,
 		       struct page *page, struct page *page_tail)
 {
-	int active;
+	int uninitialized_var(active);
 	enum lru_list lru;
 	const int file = 0;
 
@@ -672,7 +672,6 @@ void lru_add_page_tail(struct zone* zone
 			active = 0;
 			lru = LRU_INACTIVE_ANON;
 		}
-		update_page_reclaim_stat(zone, page_tail, file, active);
 	} else {
 		SetPageUnevictable(page_tail);
 		lru = LRU_UNEVICTABLE;
@@ -693,6 +692,9 @@ void lru_add_page_tail(struct zone* zone
 		list_head = page_tail->lru.prev;
 		list_move_tail(&page_tail->lru, list_head);
 	}
+
+	if (!PageUnevictable(page))
+		update_page_reclaim_stat(zone, page_tail, file, active);
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
@@ -710,8 +712,8 @@ static void __pagevec_lru_add_fn(struct
 	SetPageLRU(page);
 	if (active)
 		SetPageActive(page);
-	update_page_reclaim_stat(zone, page, file, active);
 	add_page_to_lru_list(zone, page, lru);
+	update_page_reclaim_stat(zone, page, file, active);
 }
 
 /*
--- 3.3-rc5/mm/swap_state.c	2012-01-20 08:42:35.000000000 -0800
+++ linux/mm/swap_state.c	2012-02-29 10:14:30.752007622 -0800
@@ -300,16 +300,6 @@ struct page *read_swap_cache_async(swp_e
 			new_page = alloc_page_vma(gfp_mask, vma, addr);
 			if (!new_page)
 				break;		/* Out of memory */
-			/*
-			 * The memcg-specific accounting when moving
-			 * pages around the LRU lists relies on the
-			 * page's owner (memcg) to be valid.  Usually,
-			 * pages are assigned to a new owner before
-			 * being put on the LRU list, but since this
-			 * is not the case here, the stale owner from
-			 * a previous allocation cycle must be reset.
-			 */
-			mem_cgroup_reset_owner(new_page);
 		}
 
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
