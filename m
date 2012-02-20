Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 5B3626B00F6
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 12:23:35 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so6268158bkt.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 09:23:34 -0800 (PST)
Subject: [PATCH v2 15/22] mm: push lruvecs from pagevec_lru_move_fn() to
 iterator
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 20 Feb 2012 21:23:32 +0400
Message-ID: <20120220172332.22196.35036.stgit@zurg>
In-Reply-To: <20120220171138.22196.65847.stgit@zurg>
References: <20120220171138.22196.65847.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Push lruvec pointer from pagevec_lru_move_fn() to iterator function.
Push lruvec pointer into lru_add_page_tail()

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/swap.h |    2 +-
 mm/huge_memory.c     |    4 +++-
 mm/swap.c            |   23 +++++++++++------------
 3 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 7394100..e0b1674 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -224,7 +224,7 @@ extern unsigned int nr_free_pagecache_pages(void);
 /* linux/mm/swap.c */
 extern void __lru_cache_add(struct page *, enum lru_list lru);
 extern void lru_cache_add_lru(struct page *, enum lru_list lru);
-extern void lru_add_page_tail(struct zone* zone,
+extern void lru_add_page_tail(struct lruvec *lruvec,
 			      struct page *page, struct page *page_tail);
 extern void lru_cache_add_list(struct list_head *pages,
 			       int size, enum lru_list lru);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 91d3efb..09e7069 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1229,10 +1229,12 @@ static void __split_huge_page_refcount(struct page *page)
 {
 	int i;
 	struct zone *zone = page_zone(page);
+	struct lruvec *lruvec;
 	int tail_count = 0;
 
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
 	spin_lock_irq(&zone->lru_lock);
+	lruvec = page_lruvec(page);
 	compound_lock(page);
 	/* complete memcg works before add pages to LRU */
 	mem_cgroup_split_huge_fixup(page);
@@ -1308,7 +1310,7 @@ static void __split_huge_page_refcount(struct page *page)
 		BUG_ON(!PageSwapBacked(page_tail));
 
 
-		lru_add_page_tail(zone, page, page_tail);
+		lru_add_page_tail(lruvec, page, page_tail);
 	}
 	atomic_sub(tail_count, &page->_count);
 	BUG_ON(atomic_read(&page->_count) <= 0);
diff --git a/mm/swap.c b/mm/swap.c
index a549f11..ca51e5f 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -209,7 +209,8 @@ void put_pages_list(struct list_head *pages)
 EXPORT_SYMBOL(put_pages_list);
 
 static void pagevec_lru_move_fn(struct pagevec *pvec,
-				void (*move_fn)(struct page *page, void *arg),
+				void (*move_fn)(struct lruvec *lruvec,
+						struct page *page, void *arg),
 				void *arg)
 {
 	int i;
@@ -219,6 +220,7 @@ static void pagevec_lru_move_fn(struct pagevec *pvec,
 	for (i = 0; i < pagevec_count(pvec); i++) {
 		struct page *page = pvec->pages[i];
 		struct zone *pagezone = page_zone(page);
+		struct lruvec *lruvec;
 
 		if (pagezone != zone) {
 			if (zone)
@@ -227,7 +229,8 @@ static void pagevec_lru_move_fn(struct pagevec *pvec,
 			spin_lock_irqsave(&zone->lru_lock, flags);
 		}
 
-		(*move_fn)(page, arg);
+		lruvec = page_lruvec(page);
+		(*move_fn)(lruvec, page, arg);
 	}
 	if (zone)
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
@@ -235,13 +238,13 @@ static void pagevec_lru_move_fn(struct pagevec *pvec,
 	pagevec_reinit(pvec);
 }
 
-static void pagevec_move_tail_fn(struct page *page, void *arg)
+static void pagevec_move_tail_fn(struct lruvec *lruvec,
+				 struct page *page, void *arg)
 {
 	int *pgmoved = arg;
 
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
 		enum lru_list lru = page_lru_base_type(page);
-		struct lruvec *lruvec = page_lruvec(page);
 
 		list_move_tail(&page->lru, &lruvec->pages_lru[lru]);
 		(*pgmoved)++;
@@ -291,11 +294,10 @@ static void update_page_reclaim_stat(struct lruvec *lruvec, enum lru_list lru)
 		reclaim_stat->recent_rotated[file]++;
 }
 
-static void __activate_page(struct page *page, void *arg)
+static void __activate_page(struct lruvec *lruvec, struct page *page, void *arg)
 {
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
 		int lru = page_lru_base_type(page);
-		struct lruvec *lruvec = page_lruvec(page);
 
 		del_page_from_lru_list(lruvec, page, lru);
 
@@ -508,11 +510,10 @@ void add_page_to_unevictable_list(struct page *page)
  * be write it out by flusher threads as this is much more effective
  * than the single-page writeout from reclaim.
  */
-static void lru_deactivate_fn(struct page *page, void *arg)
+static void lru_deactivate_fn(struct lruvec *lruvec, struct page *page, void *arg)
 {
 	int lru, file;
 	bool active;
-	struct lruvec *lruvec;
 
 	if (!PageLRU(page))
 		return;
@@ -528,7 +529,6 @@ static void lru_deactivate_fn(struct page *page, void *arg)
 
 	file = page_is_file_cache(page);
 	lru = page_lru_base_type(page);
-	lruvec = page_lruvec(page);
 	del_page_from_lru_list(lruvec, page, lru + active);
 	ClearPageActive(page);
 	ClearPageReferenced(page);
@@ -716,16 +716,15 @@ EXPORT_SYMBOL(__pagevec_release);
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 /* used by __split_huge_page_refcount() */
-void lru_add_page_tail(struct zone* zone,
+void lru_add_page_tail(struct lruvec *lruvec,
 		       struct page *page, struct page *page_tail)
 {
 	enum lru_list lru;
-	struct lruvec *lruvec = page_lruvec(page);
 
 	VM_BUG_ON(!PageHead(page));
 	VM_BUG_ON(PageCompound(page_tail));
 	VM_BUG_ON(PageLRU(page_tail));
-	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&zone->lru_lock));
+	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&lruvec_zone(lruvec)->lru_lock));
 
 	SetPageLRU(page_tail);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
