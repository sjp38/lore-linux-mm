Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2667D9000C2
	for <linux-mm@kvack.org>; Mon,  4 Jul 2011 10:05:48 -0400 (EDT)
Received: by mail-iy0-f169.google.com with SMTP id 8so6219561iyl.14
        for <linux-mm@kvack.org>; Mon, 04 Jul 2011 07:05:46 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v4 08/10] ilru: reduce zone->lru_lock
Date: Mon,  4 Jul 2011 23:04:41 +0900
Message-Id: <100bcc5d254e5e88f91356876b1d2ce463c2309e.1309787991.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1309787991.git.minchan.kim@gmail.com>
References: <cover.1309787991.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1309787991.git.minchan.kim@gmail.com>
References: <cover.1309787991.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

inorder_lru increases zone->lru_lock overhead(pointed out by Mel)
as it doesn't support pagevec.
This patch introduces ilru_add_pvecs and APIs.

The problem of this approach is that we lost information of old page
(ie, source of migration) when pagevec drain happens.
For solving this problem, I introuce old_page in inorder_lru.
It can union with next of struct inorder_lru as new page(ie,
destination of migration) is always detached from ilru list so we can
use next pointer as keeping old page.

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 include/linux/mm_types.h |    8 ++-
 include/linux/pagevec.h  |    1 +
 include/linux/swap.h     |    2 +
 mm/internal.h            |    2 +-
 mm/migrate.c             |  139 ++++----------------------------
 mm/swap.c                |  199 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c              |   65 ++++++---------
 7 files changed, 251 insertions(+), 165 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 3634c04..db192c7 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -33,8 +33,12 @@ struct page;
 struct inorder_lru {
 	/* prev LRU page of isolated page */
 	struct page *prev_page;
-	/* next for singly linked list*/
-	struct inorder_lru *next;
+	union {
+		/* next for singly linked list*/
+		struct inorder_lru *next;
+		/* the source page of migration */
+		struct page *old_page;
+	};
 };
 
 /*
diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
index bab82f4..8f609ea 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -23,6 +23,7 @@ struct pagevec {
 void __pagevec_release(struct pagevec *pvec);
 void __pagevec_free(struct pagevec *pvec);
 void ____pagevec_lru_add(struct pagevec *pvec, enum lru_list lru);
+void ____pagevec_ilru_add(struct pagevec *pvec, enum lru_list lru);
 void pagevec_strip(struct pagevec *pvec);
 unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
 		pgoff_t start, unsigned nr_pages);
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 2208412..78f5249 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -217,7 +217,9 @@ extern unsigned int nr_free_pagecache_pages(void);
 
 
 /* linux/mm/swap.c */
+extern void __ilru_cache_add(struct page *, enum lru_list lru);
 extern void __lru_cache_add(struct page *, enum lru_list lru);
+extern void lru_cache_add_ilru(struct page *, enum lru_list lru);
 extern void lru_cache_add_lru(struct page *, enum lru_list lru);
 extern void lru_add_page_tail(struct zone* zone,
 			      struct page *page, struct page *page_tail);
diff --git a/mm/internal.h b/mm/internal.h
index 8a919c7..cb969e0 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -42,8 +42,8 @@ extern unsigned long highest_memmap_pfn;
 /*
  * in mm/vmscan.c:
  */
-extern void putback_page_to_lru(struct page *page, struct page *head_page);
 extern int isolate_lru_page(struct page *page);
+extern void putback_ilru_page(struct page *page);
 extern void putback_lru_page(struct page *page);
 
 /*
diff --git a/mm/migrate.c b/mm/migrate.c
index b997de5..cf73477 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -84,48 +84,15 @@ void putback_lru_pages(struct list_head *l)
 	}
 }
 
-/*
- * Check if page and prev are on same LRU.
- * zone->lru_lock must be hold.
- */
-static bool same_lru(struct page *page, struct page *prev)
-{
-	bool ret = false;
-	if (!prev || !PageLRU(prev))
-		goto out;
-
-	if (unlikely(PageUnevictable(prev)))
-		goto out;
-
-	if (page_lru_base_type(page) != page_lru_base_type(prev))
-		goto out;
-
-	ret = true;
-out:
-	return ret;
-}
-
-
 void putback_ilru_pages(struct inorder_lru *l)
 {
-	struct zone *zone;
-	struct page *page, *page2, *prev;
-
+	struct page *page, *page2;
 	list_for_each_ilru_entry_safe(page, page2, l, ilru) {
 		ilru_list_del(page, l);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
-		zone = page_zone(page);
-		spin_lock_irq(&zone->lru_lock);
-		prev = page->ilru.prev_page;
-		if (same_lru(page, prev)) {
-			putback_page_to_lru(page, prev);
-			spin_unlock_irq(&zone->lru_lock);
-			put_page(page);
-		} else {
-			spin_unlock_irq(&zone->lru_lock);
-			putback_lru_page(page);
-		}
+		page->ilru.old_page = page;
+		putback_ilru_page(page);
 	}
 }
 /*
@@ -864,74 +831,19 @@ out:
 	return rc;
 }
 
-/*
- * We need adjust prev_page of ilru_list when we putback newpage
- * and free old page. Let's think about it.
- * For example,
- *
- * Notation)
- * PHY : page physical layout on memory
- * LRU : page logical layout as LRU order
- * ilru : inorder_lru list
- * PN : old page(ie, source page of migration)
- * PN' : new page(ie, destination page of migration)
- *
- * Let's assume there is below layout.
- * PHY : H - P1 - P2 - P3 - P4 - P5 - T
- * LRU : H - P5 - P4 - P3 - P2 - P1 - T
- * ilru :
- *
- * We isolate P2,P3,P4 so inorder_lru has following as.
- *
- * PHY : H - P1 - P2 - P3 - P4 - P5 - T
- * LRU : H - P5 - P1 - T
- * ilru : (P4,P5) - (P3,P4) - (P2,P3)
- *
- * After 1st putback happens,
- *
- * PHY : H - P1 - P2 - P3 - P4 - P5 - T
- * LRU : H - P5 - P4' - P1 - T
- * ilru : (P3,P4) - (P2,P3)
- * P4' is a newpage and P4(ie, old page) would freed
- *
- * In 2nd putback, P3 would try findding P4 but P4 would be freed.
- * so same_lru returns 'false' so that inorder_lru doesn't work any more.
- * The bad effect continues until P2. That's too bad.
- * For fixing, we define adjust_ilru_prev_page. It works following as.
- *
- * After 1st putback,
- *
- * PHY : H - P1 - P2 - P3 - P4 - P5 - T
- * LRU : H - P5 - P4' - P1 - T
- * ilru : (P3,P4') - (P2,P3)
- * It replaces prev pointer of pages remained in inorder_lru list with
- * new one's so in 2nd putback,
- *
- * PHY : H - P1 - P2 - P3 - P4 - P5 - T
- * LRU : H - P5 - P4' - P3' - P1 -  T
- * ilru : (P2,P3')
- *
- * In 3rd putback,
- *
- * PHY : H - P1 - P2 - P3 - P4 - P5 - T
- * LRU : H - P5 - P4' - P3' - P2' - P1 - T
- * ilru :
- */
-static inline void adjust_ilru_prev_page(struct inorder_lru *head,
-		struct page *prev_page, struct page *new_page)
-{
-	struct page *page;
-	list_for_each_ilru_entry(page, head, ilru)
-		if (page->ilru.prev_page == prev_page)
-			page->ilru.prev_page = new_page;
-}
-
 void __put_ilru_pages(struct page *page, struct page *newpage,
-		struct inorder_lru *prev_lru, struct inorder_lru *ihead)
+			struct inorder_lru *prev_lru)
 {
 	struct page *prev_page;
-	struct zone *zone;
 	prev_page = page->ilru.prev_page;
+
+	newpage->ilru.prev_page = prev_page;
+	/*
+	 * We need keeping old page which is the source page
+	 * of migration for adjusting prev_page of pages in pagevec.
+	 * Look at adjust_ilru_list.
+	 */
+	newpage->ilru.old_page = page;
 	/*
 	 * A page that has been migrated has all references
 	 * removed and will be freed. A page that has not been
@@ -941,29 +853,13 @@ void __put_ilru_pages(struct page *page, struct page *newpage,
 	ilru_list_del(page, prev_lru);
 	dec_zone_page_state(page, NR_ISOLATED_ANON +
 			page_is_file_cache(page));
+	putback_lru_page(page);
 
 	/*
 	 * Move the new page to the LRU. If migration was not successful
 	 * then this will free the page.
 	 */
-	zone = page_zone(newpage);
-	spin_lock_irq(&zone->lru_lock);
-	if (same_lru(page, prev_page)) {
-		putback_page_to_lru(newpage, prev_page);
-		spin_unlock_irq(&zone->lru_lock);
-		/*
-		 * The newpage replaced LRU position of old page and
-		 * old one would be freed. So let's adjust prev_page of pages
-		 * remained in inorder_lru list.
-		 */
-		adjust_ilru_prev_page(ihead, page, newpage);
-		put_page(newpage);
-	} else {
-		spin_unlock_irq(&zone->lru_lock);
-		putback_lru_page(newpage);
-	}
-
-	putback_lru_page(page);
+	putback_ilru_page(newpage);
 }
 
 /*
@@ -974,7 +870,7 @@ void __put_ilru_pages(struct page *page, struct page *newpage,
  */
 static int unmap_and_move_ilru(new_page_t get_new_page, unsigned long private,
 		struct page *page, int force, bool offlining, bool sync,
-		struct inorder_lru *prev_lru, struct inorder_lru *ihead)
+		struct inorder_lru *prev_lru)
 {
 	int rc = 0;
 	int *result = NULL;
@@ -995,7 +891,7 @@ static int unmap_and_move_ilru(new_page_t get_new_page, unsigned long private,
 	rc = __unmap_and_move(page, newpage, force, offlining, sync);
 out:
 	if (rc != -EAGAIN)
-		__put_ilru_pages(page, newpage, prev_lru, ihead);
+		__put_ilru_pages(page, newpage, prev_lru);
 	else
 		putback_lru_page(newpage);
 
@@ -1166,8 +1062,7 @@ int migrate_ilru_pages(struct inorder_lru *ihead, new_page_t get_new_page,
 			cond_resched();
 
 			rc = unmap_and_move_ilru(get_new_page, private,
-					page, pass > 2, offlining,
-					sync, prev, ihead);
+					page, pass > 2, offlining, sync, prev);
 
 			switch (rc) {
 			case -ENOMEM:
diff --git a/mm/swap.c b/mm/swap.c
index bdaf329..611013d 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -37,6 +37,7 @@
 /* How many pages do we try to swap or page in/out together? */
 int page_cluster;
 
+static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], ilru_add_pvecs);
 static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
@@ -179,6 +180,33 @@ void put_pages_list(struct list_head *pages)
 }
 EXPORT_SYMBOL(put_pages_list);
 
+static void pagevec_ilru_move_fn(struct pagevec *pvec,
+		void (*move_fn)(struct page *page, void *arg, int idx),
+		void *arg)
+{
+	int i;
+	struct zone *zone = NULL;
+	unsigned long flags = 0;
+
+	for (i = 0; i < pagevec_count(pvec); i++) {
+		struct page *page = pvec->pages[i];
+		struct zone *pagezone = page_zone(page);
+
+		if (pagezone != zone) {
+			if (zone)
+				spin_unlock_irqrestore(&zone->lru_lock, flags);
+			zone = pagezone;
+			spin_lock_irqsave(&zone->lru_lock, flags);
+		}
+
+		(*move_fn)(page, arg, i);
+	}
+	if (zone)
+		spin_unlock_irqrestore(&zone->lru_lock, flags);
+	release_pages(pvec->pages, pvec->nr, pvec->cold);
+	pagevec_reinit(pvec);
+}
+
 static void pagevec_lru_move_fn(struct pagevec *pvec,
 				void (*move_fn)(struct page *page, void *arg),
 				void *arg)
@@ -348,6 +376,16 @@ void mark_page_accessed(struct page *page)
 
 EXPORT_SYMBOL(mark_page_accessed);
 
+void __ilru_cache_add(struct page *page, enum lru_list lru)
+{
+	struct pagevec *pvec = &get_cpu_var(ilru_add_pvecs)[lru];
+
+	page_cache_get(page);
+	if (!pagevec_add(pvec, page))
+		____pagevec_ilru_add(pvec, lru);
+	put_cpu_var(ilru_add_pvecs);
+}
+
 void __lru_cache_add(struct page *page, enum lru_list lru)
 {
 	struct pagevec *pvec = &get_cpu_var(lru_add_pvecs)[lru];
@@ -360,6 +398,25 @@ void __lru_cache_add(struct page *page, enum lru_list lru)
 EXPORT_SYMBOL(__lru_cache_add);
 
 /**
+ * lru_cache_add_ilru - add a page to a page list
+ * @page: the page to be added to the LRU.
+ * @lru: the LRU list to which the page is added.
+ */
+void lru_cache_add_ilru(struct page *page, enum lru_list lru)
+{
+	if (PageActive(page)) {
+		VM_BUG_ON(PageUnevictable(page));
+		ClearPageActive(page);
+	} else if (PageUnevictable(page)) {
+		VM_BUG_ON(PageActive(page));
+		ClearPageUnevictable(page);
+	}
+
+	VM_BUG_ON(PageLRU(page) || PageActive(page) || PageUnevictable(page));
+	__ilru_cache_add(page, lru);
+}
+
+/**
  * lru_cache_add_lru - add a page to a page list
  * @page: the page to be added to the LRU.
  * @lru: the LRU list to which the page is added.
@@ -484,6 +541,13 @@ static void drain_cpu_pagevecs(int cpu)
 			____pagevec_lru_add(pvec, lru);
 	}
 
+	pvecs = per_cpu(ilru_add_pvecs, cpu);
+	for_each_lru(lru) {
+		pvec = &pvecs[lru - LRU_BASE];
+		if (pagevec_count(pvec))
+			____pagevec_ilru_add(pvec, lru);
+	}
+
 	pvec = &per_cpu(lru_rotate_pvecs, cpu);
 	if (pagevec_count(pvec)) {
 		unsigned long flags;
@@ -669,6 +733,130 @@ void lru_add_page_tail(struct zone* zone,
 	}
 }
 
+/*
+ * We need adjust prev_page of ilru_list when we putback newpage
+ * and free old page. Let's think about it.
+ * For example,
+ *
+ * Notation)
+ * PHY : page physical layout on memory
+ * LRU : page logical layout as LRU order
+ * ilru : inorder_lru list
+ * PN : old page(ie, source page of migration)
+ * PN' : new page(ie, destination page of migration)
+ *
+ * Let's assume there is below layout.
+ * PHY : H - P1 - P2 - P3 - P4 - P5 - T
+ * LRU : H - P5 - P4 - P3 - P2 - P1 - T
+ * ilru :
+ *
+ * We isolate P2,P3,P4 so inorder_lru has following as.
+ *
+ * PHY : H - P1 - P2 - P3 - P4 - P5 - T
+ * LRU : H - P5 - P1 - T
+ * ilru : (P4,P5) - (P3,P4) - (P2,P3)
+ *
+ * After 1st putback happens,
+ *
+ * PHY : H - P1 - P2 - P3 - P4 - P5 - T
+ * LRU : H - P5 - P4' - P1 - T
+ * ilru : (P3,P4) - (P2,P3)
+ * P4' is a newpage and P4(ie, old page) would freed
+ *
+ * In 2nd putback, P3 would try findding P4 but P4 would be freed.
+ * so same_lru returns 'false' so that inorder_lru doesn't work any more.
+ * The bad effect continues until P2. That's too bad.
+ * For fixing, we define adjust_ilru_list. It works following as.
+ *
+ * After 1st putback,
+ *
+ * PHY : H - P1 - P2 - P3 - P4 - P5 - T
+ * LRU : H - P5 - P4' - P1 - T
+ * ilru : (P3,P4') - (P2,P3)
+ * It replaces prev pointer of pages remained in inorder_lru list with
+ * new one's so in 2nd putback,
+ *
+ * PHY : H - P1 - P2 - P3 - P4 - P5 - T
+ * LRU : H - P5 - P4' - P3' - P1 -  T
+ * ilru : (P2,P3')
+ *
+ * In 3rd putback,
+ *
+ * PHY : H - P1 - P2 - P3 - P4 - P5 - T
+ * LRU : H - P5 - P4' - P3' - P2' - P1 - T
+ * ilru :
+ */
+static inline void adjust_ilru_list(enum lru_list lru,
+		struct page *old_page,	struct page *new_page, int idx)
+{
+	int i;
+	struct pagevec *pvec = &get_cpu_var(ilru_add_pvecs)[lru];
+	for (i = idx + 1; i < pagevec_count(pvec); i++) {
+		struct page *page = pvec->pages[i];
+		if (page->ilru.prev_page == old_page)
+			page->ilru.prev_page = new_page;
+	}
+}
+
+/*
+ * Check if page and prev are on same LRU.
+ * zone->lru_lock must be hold.
+ */
+static bool same_lru(struct page *page, struct page *prev)
+{
+	bool ret = false;
+	if (!prev || !PageLRU(prev))
+		goto out;
+
+	if (unlikely(PageUnevictable(prev)))
+		goto out;
+
+	if (page_lru_base_type(page) != page_lru_base_type(prev))
+		goto out;
+
+	ret = true;
+out:
+	return ret;
+}
+
+static void ____pagevec_ilru_add_fn(struct page *page, void *arg, int idx)
+{
+	enum lru_list lru = (enum lru_list)arg;
+	struct zone *zone = page_zone(page);
+	int file, active;
+
+	struct page *prev_page = page->ilru.prev_page;
+	struct page *old_page = page->ilru.old_page;
+
+	VM_BUG_ON(PageActive(page));
+	VM_BUG_ON(PageUnevictable(page));
+	VM_BUG_ON(PageLRU(page));
+
+	SetPageLRU(page);
+
+	if (same_lru(page, prev_page)) {
+		active = PageActive(prev_page);
+		file = page_is_file_cache(page);
+		if (active)
+			SetPageActive(page);
+		/*
+		 * The newpage will replace LRU position of old page.
+		 * So let's adjust prev_page of pages remained
+		 * in ilru_add_pvecs for same_lru wokring.
+		 */
+		adjust_ilru_list(lru, old_page, page, idx);
+		__add_page_to_lru_list(zone, page, lru, &prev_page->lru);
+	} else {
+		file = is_file_lru(lru);
+		active = is_active_lru(lru);
+		if (active)
+			SetPageActive(page);
+		add_page_to_lru_list(zone, page, lru);
+	}
+
+	update_page_reclaim_stat(zone, page, file, active);
+}
+
 static void ____pagevec_lru_add_fn(struct page *page, void *arg)
 {
 	enum lru_list lru = (enum lru_list)arg;
@@ -691,6 +879,17 @@ static void ____pagevec_lru_add_fn(struct page *page, void *arg)
  * Add the passed pages to the LRU, then drop the caller's refcount
  * on them.  Reinitialises the caller's pagevec.
  */
+void ____pagevec_ilru_add(struct pagevec *pvec, enum lru_list lru)
+{
+	VM_BUG_ON(is_unevictable_lru(lru));
+
+	pagevec_ilru_move_fn(pvec, ____pagevec_ilru_add_fn, (void *)lru);
+}
+
+/*
+ * Add the passed pages to the LRU, then drop the caller's refcount
+ * on them.  Reinitialises the caller's pagevec.
+ */
 void ____pagevec_lru_add(struct pagevec *pvec, enum lru_list lru)
 {
 	VM_BUG_ON(is_unevictable_lru(lru));
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 938dea9..957c225 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -565,45 +565,7 @@ int remove_mapping(struct address_space *mapping, struct page *page)
 	return 0;
 }
 
-/**
- * putback_page_to_lru - put isolated @page onto @head
- * @page: page to be put back to appropriate lru list
- * @head_page: lru position to be put back
- *
- * Insert previously isolated @page to appropriate position of lru list
- * zone->lru_lock must be hold.
- */
-void putback_page_to_lru(struct page *page, struct page *head_page)
-{
-	int lru, active, file;
-	struct zone *zone = page_zone(page);
-
-	VM_BUG_ON(PageLRU(page));
-
-	lru = page_lru(head_page);
-	active = is_active_lru(lru);
-	file = is_file_lru(lru);
-
-	if (active)
-		SetPageActive(page);
-	else
-		ClearPageActive(page);
-
-	update_page_reclaim_stat(zone, page, file, active);
-	SetPageLRU(page);
-	__add_page_to_lru_list(zone, page, lru, &head_page->lru);
-}
-
-/**
- * putback_lru_page - put previously isolated page onto appropriate LRU list
- * @page: page to be put back to appropriate lru list
- *
- * Add previously isolated @page to appropriate LRU list.
- * Page may still be unevictable for other reasons.
- *
- * lru_lock must not be held, interrupts must be enabled.
- */
-void putback_lru_page(struct page *page)
+static void __putback_lru_core(struct page *page, bool inorder)
 {
 	int lru;
 	int active = !!TestClearPageActive(page);
@@ -622,7 +584,10 @@ redo:
 		 * We know how to handle that.
 		 */
 		lru = active + page_lru_base_type(page);
-		lru_cache_add_lru(page, lru);
+		if (inorder)
+			lru_cache_add_ilru(page, lru);
+		else
+			lru_cache_add_lru(page, lru);
 	} else {
 		/*
 		 * Put unevictable pages directly on zone's unevictable
@@ -650,6 +615,7 @@ redo:
 	if (lru == LRU_UNEVICTABLE && page_evictable(page, NULL)) {
 		if (!isolate_lru_page(page)) {
 			put_page(page);
+			inorder = false;
 			goto redo;
 		}
 		/* This means someone else dropped this page from LRU
@@ -666,6 +632,25 @@ redo:
 	put_page(page);		/* drop ref from isolate */
 }
 
+/**
+ * putback_lru_page - put previously isolated page onto appropriate LRU list's head
+ * @page: page to be put back to appropriate lru list
+ *
+ * Add previously isolated @page to appropriate LRU list's head
+ * Page may still be unevictable for other reasons.
+ *
+ * lru_lock must not be held, interrupts must be enabled.
+ */
+void putback_lru_page(struct page *page)
+{
+	__putback_lru_core(page, false);
+}
+
+void putback_ilru_page(struct page *page)
+{
+	__putback_lru_core(page, true);
+}
+
 enum page_references {
 	PAGEREF_RECLAIM,
 	PAGEREF_RECLAIM_CLEAN,
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
