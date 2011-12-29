Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id C4E4C6B005C
	for <linux-mm@kvack.org>; Wed, 28 Dec 2011 19:20:34 -0500 (EST)
Received: by iacb35 with SMTP id b35so27277117iac.14
        for <linux-mm@kvack.org>; Wed, 28 Dec 2011 16:20:34 -0800 (PST)
Date: Wed, 28 Dec 2011 16:20:25 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 1/4] memcg: fix split_huge_page_refcounts
In-Reply-To: <alpine.LSU.2.00.1112281613550.8257@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1112281618050.8257@eggly.anvils>
References: <alpine.LSU.2.00.1112281613550.8257@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Shaohua Li <shaohua.li@intel.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

This patch started off as a cleanup: __split_huge_page_refcounts() has to
cope with two scenarios, when the hugepage being split is already on LRU,
and when it is not; but why does it have to split that accounting across
three different sites?  Consolidate it in lru_add_page_tail(), handling
evictable and unevictable alike, and use standard add_page_to_lru_list()
when accounting is needed (when the head is not yet on LRU).

But a recent regression in -next, I guess the removal of PageCgroupAcctLRU
test from mem_cgroup_split_huge_fixup(), makes this now a necessary fix:
under load, the MEM_CGROUP_ZSTAT count was wrapping to a huge number,
messing up reclaim calculations and causing a freeze at rmdir of cgroup.

Add a VM_BUG_ON to mem_cgroup_lru_del_list() when we're about to wrap
that count - this has not been the only such incident.  Document that
lru_add_page_tail() is for Transparent HugePages by #ifdef around it.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
I think this is a fix to
    memcg: simplify LRU handling by new rule
but I've not tried applying immediately after that one,
just on top of next minus Mel's 11/11.

 mm/huge_memory.c |   10 ----------
 mm/memcontrol.c  |   12 ++----------
 mm/swap.c        |   29 +++++++++++++++++++----------
 3 files changed, 21 insertions(+), 30 deletions(-)

--- mmotm.orig/mm/huge_memory.c	2011-12-22 02:53:31.884041564 -0800
+++ mmotm/mm/huge_memory.c	2011-12-28 12:53:23.416367861 -0800
@@ -1229,7 +1229,6 @@ static void __split_huge_page_refcount(s
 {
 	int i;
 	struct zone *zone = page_zone(page);
-	int zonestat;
 	int tail_count = 0;
 
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
@@ -1317,15 +1316,6 @@ static void __split_huge_page_refcount(s
 	__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
 	__mod_zone_page_state(zone, NR_ANON_PAGES, HPAGE_PMD_NR);
 
-	/*
-	 * A hugepage counts for HPAGE_PMD_NR pages on the LRU statistics,
-	 * so adjust those appropriately if this page is on the LRU.
-	 */
-	if (PageLRU(page)) {
-		zonestat = NR_LRU_BASE + page_lru(page);
-		__mod_zone_page_state(zone, zonestat, -(HPAGE_PMD_NR-1));
-	}
-
 	ClearPageCompound(page);
 	compound_unlock(page);
 	spin_unlock_irq(&zone->lru_lock);
--- mmotm.orig/mm/memcontrol.c	2011-12-22 02:53:31.892041564 -0800
+++ mmotm/mm/memcontrol.c	2011-12-28 12:53:23.420367847 -0800
@@ -1076,6 +1076,7 @@ void mem_cgroup_lru_del_list(struct page
 	VM_BUG_ON(!memcg);
 	mz = page_cgroup_zoneinfo(memcg, page);
 	/* huge page split is done under lru_lock. so, we have no races. */
+	VM_BUG_ON(MEM_CGROUP_ZSTAT(mz, lru) < (1 << compound_order(page)));
 	MEM_CGROUP_ZSTAT(mz, lru) -= 1 << compound_order(page);
 }
 
@@ -2468,9 +2469,7 @@ static void __mem_cgroup_commit_charge(s
 void mem_cgroup_split_huge_fixup(struct page *head)
 {
 	struct page_cgroup *head_pc = lookup_page_cgroup(head);
-	struct mem_cgroup_per_zone *mz;
 	struct page_cgroup *pc;
-	enum lru_list lru;
 	int i;
 
 	if (mem_cgroup_disabled())
@@ -2481,15 +2480,8 @@ void mem_cgroup_split_huge_fixup(struct
 		smp_wmb();/* see __commit_charge() */
 		pc->flags = head_pc->flags & ~PCGF_NOCOPY_AT_SPLIT;
 	}
-	/*
-	 * Tail pages will be added to LRU.
-	 * We hold lru_lock,then,reduce counter directly.
-	 */
-	lru = page_lru(head);
-	mz = page_cgroup_zoneinfo(head_pc->mem_cgroup, head);
-	MEM_CGROUP_ZSTAT(mz, lru) -= HPAGE_PMD_NR - 1;
 }
-#endif
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 /**
  * mem_cgroup_move_account - move account of the page
--- mmotm.orig/mm/swap.c	2011-12-28 12:32:02.764338005 -0800
+++ mmotm/mm/swap.c	2011-12-28 12:53:23.420367847 -0800
@@ -650,6 +650,7 @@ void __pagevec_release(struct pagevec *p
 
 EXPORT_SYMBOL(__pagevec_release);
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
 /* used by __split_huge_page_refcount() */
 void lru_add_page_tail(struct zone* zone,
 		       struct page *page, struct page *page_tail)
@@ -666,8 +667,6 @@ void lru_add_page_tail(struct zone* zone
 	SetPageLRU(page_tail);
 
 	if (page_evictable(page_tail, NULL)) {
-		struct lruvec *lruvec;
-
 		if (PageActive(page)) {
 			SetPageActive(page_tail);
 			active = 1;
@@ -677,18 +676,28 @@ void lru_add_page_tail(struct zone* zone
 			lru = LRU_INACTIVE_ANON;
 		}
 		update_page_reclaim_stat(zone, page_tail, file, active);
-		lruvec = mem_cgroup_lru_add_list(zone, page_tail, lru);
-		if (likely(PageLRU(page)))
-			list_add(&page_tail->lru, page->lru.prev);
-		else
-			list_add(&page_tail->lru, lruvec->lists[lru].prev);
-		__mod_zone_page_state(zone, NR_LRU_BASE + lru,
-				      hpage_nr_pages(page_tail));
 	} else {
 		SetPageUnevictable(page_tail);
-		add_page_to_lru_list(zone, page_tail, LRU_UNEVICTABLE);
+		lru = LRU_UNEVICTABLE;
+	}
+
+	if (likely(PageLRU(page)))
+		list_add_tail(&page_tail->lru, &page->lru);
+	else {
+		struct list_head *list_head;
+		/*
+		 * Head page has not yet been counted, as an hpage,
+		 * so we must account for each subpage individually.
+		 *
+		 * Use the standard add function to put page_tail on the list,
+		 * but then correct its position so they all end up in order.
+		 */
+		add_page_to_lru_list(zone, page_tail, lru);
+		list_head = page_tail->lru.prev;
+		list_move_tail(&page_tail->lru, list_head);
 	}
 }
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 static void ____pagevec_lru_add_fn(struct page *page, void *arg)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
