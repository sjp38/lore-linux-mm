Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 002AD6B0107
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 18:34:53 -0500 (EST)
Received: by dadv6 with SMTP id v6so7620078dad.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 15:34:53 -0800 (PST)
Date: Mon, 20 Feb 2012 15:34:28 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 6/10] mm/memcg: take care over pc->mem_cgroup
In-Reply-To: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1202201533260.23274@eggly.anvils>
References: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

page_relock_lruvec() is using lookup_page_cgroup(page)->mem_cgroup
to find the memcg, and hence its per-zone lruvec for the page.  We
therefore need to be careful to see the right pc->mem_cgroup: where
is it updated?

In __mem_cgroup_commit_charge(), under lruvec lock whenever lru
care might be needed, lrucare holding the page off lru at that time.

In mem_cgroup_reset_owner(), not under lruvec lock, but before the
page can be visible to others - except compaction or lumpy reclaim,
which ignore the page because it is not yet PageLRU.

In mem_cgroup_split_huge_fixup(), always under lruvec lock.

In mem_cgroup_move_account(), which holds several locks, but an
lruvec lock not among them: yet it still appears to be safe, because
the page has been taken off its old lru and not yet put on the new.

Be particularly careful in compaction's isolate_migratepages() and
vmscan's lumpy handling in isolate_lru_pages(): those approach the
page by its physical location, and so can encounter pages which
would not be found by any logical lookup.  For those cases we have
to change __isolate_lru_page() slightly: it must leave ClearPageLRU
to the caller, because compaction and lumpy cannot safely interfere
with a page until they have first isolated it and then locked lruvec.

To the list above we have to add __mem_cgroup_uncharge_common(),
and new function mem_cgroup_reset_uncharged_to_root(): the first
resetting pc->mem_cgroup to root_mem_cgroup when a page off lru is
uncharged, and the second when an uncharged page is taken off lru
(which used to be achieved implicitly with the PageAcctLRU flag).

That's because there's a remote risk that compaction or lumpy reclaim
will spy a page while it has PageLRU set; then it's taken off LRU and
freed, its mem_cgroup torn down and freed, the page reallocated (so
get_page_unless_zero again succeeds); then compaction or lumpy reclaim
reach their page_relock_lruvec, using the stale mem_cgroup for locking.

So long as there's one charge on the mem_cgroup, or a page on one of
its lrus, mem_cgroup_force_empty() cannot succeed and the mem_cgroup
cannot be destroyed.  But when an uncharged page is taken off lru,
or a page off lru is uncharged, it no longer protects its old memcg,
and the one stable root_mem_cgroup must then be used for it.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/memcontrol.h |    5 ++
 mm/compaction.c            |   36 ++++++-----------
 mm/memcontrol.c            |   45 +++++++++++++++++++--
 mm/swap.c                  |    2 
 mm/vmscan.c                |   73 +++++++++++++++++++++++++----------
 5 files changed, 114 insertions(+), 47 deletions(-)

--- mmotm.orig/include/linux/memcontrol.h	2012-02-18 11:57:42.675524592 -0800
+++ mmotm/include/linux/memcontrol.h	2012-02-18 11:57:49.103524745 -0800
@@ -65,6 +65,7 @@ extern int mem_cgroup_cache_charge(struc
 struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
 extern struct mem_cgroup *mem_cgroup_from_lruvec(struct lruvec *lruvec);
 extern void mem_cgroup_update_lru_size(struct lruvec *, enum lru_list, int);
+extern void mem_cgroup_reset_uncharged_to_root(struct page *);
 
 /* For coalescing uncharge for reducing memcg' overhead*/
 extern void mem_cgroup_uncharge_start(void);
@@ -251,6 +252,10 @@ static inline void mem_cgroup_update_lru
 {
 }
 
+static inline void mem_cgroup_reset_uncharged_to_root(struct page *page)
+{
+}
+
 static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 {
 	return NULL;
--- mmotm.orig/mm/compaction.c	2012-02-18 11:57:42.675524592 -0800
+++ mmotm/mm/compaction.c	2012-02-18 11:57:49.103524745 -0800
@@ -356,28 +356,6 @@ static isolate_migrate_t isolate_migrate
 			continue;
 		}
 
-		if (!lruvec) {
-			/*
-			 * We do need to take the lock before advancing to
-			 * check PageLRU etc., but there's no guarantee that
-			 * the page we're peeking at has a stable memcg here.
-			 */
-			lruvec = &zone->lruvec;
-			lock_lruvec(lruvec);
-		}
-		if (!PageLRU(page))
-			continue;
-
-		/*
-		 * PageLRU is set, and lru_lock excludes isolation,
-		 * splitting and collapsing (collapsing has already
-		 * happened if PageLRU is set).
-		 */
-		if (PageTransHuge(page)) {
-			low_pfn += (1 << compound_order(page)) - 1;
-			continue;
-		}
-
 		if (!cc->sync)
 			mode |= ISOLATE_ASYNC_MIGRATE;
 
@@ -386,10 +364,24 @@ static isolate_migrate_t isolate_migrate
 			continue;
 
 		page_relock_lruvec(page, &lruvec);
+		if (unlikely(!PageLRU(page) || PageUnevictable(page) ||
+						PageTransHuge(page))) {
+			/*
+			 * lru_lock excludes splitting a huge page,
+			 * but we cannot hold lru_lock while freeing page.
+			 */
+			low_pfn += (1 << compound_order(page)) - 1;
+			unlock_lruvec(lruvec);
+			lruvec = NULL;
+			put_page(page);
+			continue;
+		}
 
 		VM_BUG_ON(PageTransCompound(page));
 
 		/* Successfully isolated */
+		ClearPageLRU(page);
+		mem_cgroup_reset_uncharged_to_root(page);
 		del_page_from_lru_list(page, lruvec, page_lru(page));
 		list_add(&page->lru, migratelist);
 		cc->nr_migratepages++;
--- mmotm.orig/mm/memcontrol.c	2012-02-18 11:57:42.679524592 -0800
+++ mmotm/mm/memcontrol.c	2012-02-18 11:57:49.107524745 -0800
@@ -1069,6 +1069,33 @@ void page_relock_lruvec(struct page *pag
 	*lruvp = lruvec;
 }
 
+void mem_cgroup_reset_uncharged_to_root(struct page *page)
+{
+	struct page_cgroup *pc;
+
+	if (mem_cgroup_disabled())
+		return;
+
+	VM_BUG_ON(PageLRU(page));
+
+	/*
+	 * Once an uncharged page is isolated from the mem_cgroup's lru,
+	 * it no longer protects that mem_cgroup from rmdir: reset to root.
+	 *
+	 * __page_cache_release() and release_pages() may be called at
+	 * interrupt time: we cannot lock_page_cgroup() then (we might
+	 * have interrupted a section with page_cgroup already locked),
+	 * nor do we need to since the page is frozen and about to be freed.
+	 */
+	pc = lookup_page_cgroup(page);
+	if (page_count(page))
+		lock_page_cgroup(pc);
+	if (!PageCgroupUsed(pc) && pc->mem_cgroup != root_mem_cgroup)
+		pc->mem_cgroup = root_mem_cgroup;
+	if (page_count(page))
+		unlock_page_cgroup(pc);
+}
+
 /**
  * mem_cgroup_update_lru_size - account for adding or removing an lru page
  * @lruvec: mem_cgroup per zone lru vector
@@ -2865,6 +2892,7 @@ __mem_cgroup_uncharge_common(struct page
 	struct mem_cgroup *memcg = NULL;
 	unsigned int nr_pages = 1;
 	struct page_cgroup *pc;
+	struct lruvec *lruvec;
 	bool anon;
 
 	if (mem_cgroup_disabled())
@@ -2884,6 +2912,7 @@ __mem_cgroup_uncharge_common(struct page
 	if (unlikely(!PageCgroupUsed(pc)))
 		return NULL;
 
+	lruvec = page_lock_lruvec(page);
 	lock_page_cgroup(pc);
 
 	memcg = pc->mem_cgroup;
@@ -2915,14 +2944,17 @@ __mem_cgroup_uncharge_common(struct page
 	mem_cgroup_charge_statistics(memcg, anon, -nr_pages);
 
 	ClearPageCgroupUsed(pc);
+
 	/*
-	 * pc->mem_cgroup is not cleared here. It will be accessed when it's
-	 * freed from LRU. This is safe because uncharged page is expected not
-	 * to be reused (freed soon). Exception is SwapCache, it's handled by
-	 * special functions.
+	 * Once an uncharged page is isolated from the mem_cgroup's lru,
+	 * it no longer protects that mem_cgroup from rmdir: reset to root.
 	 */
+	if (!PageLRU(page) && pc->mem_cgroup != root_mem_cgroup)
+		pc->mem_cgroup = root_mem_cgroup;
 
 	unlock_page_cgroup(pc);
+	unlock_lruvec(lruvec);
+
 	/*
 	 * even after unlock, we have memcg->res.usage here and this memcg
 	 * will never be freed.
@@ -2939,6 +2971,7 @@ __mem_cgroup_uncharge_common(struct page
 
 unlock_out:
 	unlock_page_cgroup(pc);
+	unlock_lruvec(lruvec);
 	return NULL;
 }
 
@@ -3327,7 +3360,9 @@ static struct page_cgroup *lookup_page_c
 	 * the first time, i.e. during boot or memory hotplug;
 	 * or when mem_cgroup_disabled().
 	 */
-	if (likely(pc) && PageCgroupUsed(pc))
+	if (!pc || PageCgroupUsed(pc))
+		return pc;
+	if (pc->mem_cgroup && pc->mem_cgroup != root_mem_cgroup)
 		return pc;
 	return NULL;
 }
--- mmotm.orig/mm/swap.c	2012-02-18 11:57:42.679524592 -0800
+++ mmotm/mm/swap.c	2012-02-18 11:57:49.107524745 -0800
@@ -52,6 +52,7 @@ static void __page_cache_release(struct
 		lruvec = page_lock_lruvec(page);
 		VM_BUG_ON(!PageLRU(page));
 		__ClearPageLRU(page);
+		mem_cgroup_reset_uncharged_to_root(page);
 		del_page_from_lru_list(page, lruvec, page_off_lru(page));
 		unlock_lruvec(lruvec);
 	}
@@ -583,6 +584,7 @@ void release_pages(struct page **pages,
 			page_relock_lruvec(page, &lruvec);
 			VM_BUG_ON(!PageLRU(page));
 			__ClearPageLRU(page);
+			mem_cgroup_reset_uncharged_to_root(page);
 			del_page_from_lru_list(page, lruvec, page_off_lru(page));
 		}
 
--- mmotm.orig/mm/vmscan.c	2012-02-18 11:57:42.679524592 -0800
+++ mmotm/mm/vmscan.c	2012-02-18 11:57:49.107524745 -0800
@@ -1087,11 +1087,11 @@ int __isolate_lru_page(struct page *page
 
 	if (likely(get_page_unless_zero(page))) {
 		/*
-		 * Be careful not to clear PageLRU until after we're
-		 * sure the page is not being freed elsewhere -- the
-		 * page release code relies on it.
+		 * Beware of interface change: now leave ClearPageLRU(page)
+		 * to the caller, because memcg's lumpy and compaction
+		 * cases (approaching the page by its physical location)
+		 * may not have the right lru_lock yet.
 		 */
-		ClearPageLRU(page);
 		ret = 0;
 	}
 
@@ -1154,7 +1154,16 @@ static unsigned long isolate_lru_pages(u
 
 		switch (__isolate_lru_page(page, mode, file)) {
 		case 0:
+#ifdef CONFIG_DEBUG_VM
+			/* check lock on page is lock we already got */
+			page_relock_lruvec(page, &lruvec);
+			BUG_ON(lruvec != home_lruvec);
+			BUG_ON(page != lru_to_page(src));
+			BUG_ON(page_lru(page) != lru);
+#endif
+			ClearPageLRU(page);
 			isolated_pages = hpage_nr_pages(page);
+			mem_cgroup_reset_uncharged_to_root(page);
 			mem_cgroup_update_lru_size(lruvec, lru, -isolated_pages);
 			list_move(&page->lru, dst);
 			nr_taken += isolated_pages;
@@ -1211,21 +1220,7 @@ static unsigned long isolate_lru_pages(u
 			    !PageSwapCache(cursor_page))
 				break;
 
-			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
-				mem_cgroup_page_relock_lruvec(cursor_page,
-								&lruvec);
-				isolated_pages = hpage_nr_pages(cursor_page);
-				mem_cgroup_update_lru_size(lruvec,
-					page_lru(cursor_page), -isolated_pages);
-				list_move(&cursor_page->lru, dst);
-
-				nr_taken += isolated_pages;
-				nr_lumpy_taken += isolated_pages;
-				if (PageDirty(cursor_page))
-					nr_lumpy_dirty += isolated_pages;
-				scan++;
-				pfn += isolated_pages - 1;
-			} else {
+			if (__isolate_lru_page(cursor_page, mode, file) != 0) {
 				/*
 				 * Check if the page is freed already.
 				 *
@@ -1243,13 +1238,50 @@ static unsigned long isolate_lru_pages(u
 					continue;
 				break;
 			}
+
+			/*
+			 * This locking call is a no-op in the non-memcg
+			 * case, since we already hold the right lru_lock;
+			 * but it may change the lock in the memcg case.
+			 * It is then vital to recheck PageLRU (but not
+			 * necessary to recheck isolation mode).
+			 */
+			mem_cgroup_page_relock_lruvec(cursor_page, &lruvec);
+
+			if (PageLRU(cursor_page) &&
+			    !PageUnevictable(cursor_page)) {
+				ClearPageLRU(cursor_page);
+				isolated_pages = hpage_nr_pages(cursor_page);
+				mem_cgroup_reset_uncharged_to_root(cursor_page);
+				mem_cgroup_update_lru_size(lruvec,
+					page_lru(cursor_page), -isolated_pages);
+				list_move(&cursor_page->lru, dst);
+
+				nr_taken += isolated_pages;
+				nr_lumpy_taken += isolated_pages;
+				if (PageDirty(cursor_page))
+					nr_lumpy_dirty += isolated_pages;
+				scan++;
+				pfn += isolated_pages - 1;
+			} else {
+				/* Cannot hold lru_lock while freeing page */
+				unlock_lruvec(lruvec);
+				lruvec = NULL;
+				put_page(cursor_page);
+				break;
+			}
 		}
 
 		/* If we break out of the loop above, lumpy reclaim failed */
 		if (pfn < end_pfn)
 			nr_lumpy_failed++;
 
-		lruvec = home_lruvec;
+		if (lruvec != home_lruvec) {
+			if (lruvec)
+				unlock_lruvec(lruvec);
+			lruvec = home_lruvec;
+			lock_lruvec(lruvec);
+		}
 	}
 
 	*nr_scanned = scan;
@@ -1301,6 +1333,7 @@ int isolate_lru_page(struct page *page)
 			int lru = page_lru(page);
 			get_page(page);
 			ClearPageLRU(page);
+			mem_cgroup_reset_uncharged_to_root(page);
 			del_page_from_lru_list(page, lruvec, lru);
 			ret = 0;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
