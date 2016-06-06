Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1B04C6B0262
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 15:51:17 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id rs7so67514779lbb.2
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 12:51:17 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id b8si14623700wjw.57.2016.06.06.12.51.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 12:51:15 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 05/10] mm: remove LRU balancing effect of temporary page isolation
Date: Mon,  6 Jun 2016 15:48:31 -0400
Message-Id: <20160606194836.3624-6-hannes@cmpxchg.org>
In-Reply-To: <20160606194836.3624-1-hannes@cmpxchg.org>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

Isolating an existing LRU page and subsequently putting it back on the
list currently influences the balance between the anon and file LRUs.
For example, heavy page migration or compaction could influence the
balance between the LRUs and make one type more attractive when that
type of page is affected more than the other. That doesn't make sense.

Add a dedicated LRU cache for putback, so that we can tell new LRU
pages from existing ones at the time of linking them to the lists.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/pagevec.h |  2 +-
 include/linux/swap.h    |  1 +
 mm/mlock.c              |  2 +-
 mm/swap.c               | 34 ++++++++++++++++++++++++++++------
 mm/vmscan.c             |  2 +-
 5 files changed, 32 insertions(+), 9 deletions(-)

diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
index b45d391b4540..3f8a2a01131c 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -21,7 +21,7 @@ struct pagevec {
 };
 
 void __pagevec_release(struct pagevec *pvec);
-void __pagevec_lru_add(struct pagevec *pvec);
+void __pagevec_lru_add(struct pagevec *pvec, bool new);
 unsigned pagevec_lookup_entries(struct pagevec *pvec,
 				struct address_space *mapping,
 				pgoff_t start, unsigned nr_entries,
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 38fe1e91ba55..178f084365c2 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -296,6 +296,7 @@ extern unsigned long nr_free_pagecache_pages(void);
 
 /* linux/mm/swap.c */
 extern void lru_cache_add(struct page *);
+extern void lru_cache_putback(struct page *page);
 extern void lru_add_page_tail(struct page *page, struct page *page_tail,
 			 struct lruvec *lruvec, struct list_head *head);
 extern void activate_page(struct page *);
diff --git a/mm/mlock.c b/mm/mlock.c
index 96f001041928..449c291a286d 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -264,7 +264,7 @@ static void __putback_lru_fast(struct pagevec *pvec, int pgrescued)
 	 *__pagevec_lru_add() calls release_pages() so we don't call
 	 * put_page() explicitly
 	 */
-	__pagevec_lru_add(pvec);
+	__pagevec_lru_add(pvec, false);
 	count_vm_events(UNEVICTABLE_PGRESCUED, pgrescued);
 }
 
diff --git a/mm/swap.c b/mm/swap.c
index c6936507abb5..576c721f210b 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -44,6 +44,7 @@
 int page_cluster;
 
 static DEFINE_PER_CPU(struct pagevec, lru_add_pvec);
+static DEFINE_PER_CPU(struct pagevec, lru_putback_pvec);
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_deactivate_file_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
@@ -405,12 +406,23 @@ void lru_cache_add(struct page *page)
 
 	get_page(page);
 	if (!pagevec_space(pvec))
-		__pagevec_lru_add(pvec);
+		__pagevec_lru_add(pvec, true);
 	pagevec_add(pvec, page);
 	put_cpu_var(lru_add_pvec);
 }
 EXPORT_SYMBOL(lru_cache_add);
 
+void lru_cache_putback(struct page *page)
+{
+	struct pagevec *pvec = &get_cpu_var(lru_putback_pvec);
+
+	get_page(page);
+	if (!pagevec_space(pvec))
+		__pagevec_lru_add(pvec, false);
+	pagevec_add(pvec, page);
+	put_cpu_var(lru_putback_pvec);
+}
+
 /**
  * add_page_to_unevictable_list - add a page to the unevictable list
  * @page:  the page to be added to the unevictable list
@@ -561,10 +573,15 @@ static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
  */
 void lru_add_drain_cpu(int cpu)
 {
-	struct pagevec *pvec = &per_cpu(lru_add_pvec, cpu);
+	struct pagevec *pvec;
+
+	pvec = &per_cpu(lru_add_pvec, cpu);
+	if (pagevec_count(pvec))
+		__pagevec_lru_add(pvec, true);
 
+	pvec = &per_cpu(lru_putback_pvec, cpu);
 	if (pagevec_count(pvec))
-		__pagevec_lru_add(pvec);
+		__pagevec_lru_add(pvec, false);
 
 	pvec = &per_cpu(lru_rotate_pvecs, cpu);
 	if (pagevec_count(pvec)) {
@@ -819,12 +836,17 @@ static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
 	int file = page_is_file_cache(page);
 	int active = PageActive(page);
 	enum lru_list lru = page_lru(page);
+	bool new = (bool)arg;
 
 	VM_BUG_ON_PAGE(PageLRU(page), page);
 
 	SetPageLRU(page);
 	add_page_to_lru_list(page, lruvec, lru);
-	update_page_reclaim_stat(lruvec, file, active, hpage_nr_pages(page));
+
+	if (new)
+		update_page_reclaim_stat(lruvec, file, active,
+					 hpage_nr_pages(page));
+
 	trace_mm_lru_insertion(page, lru);
 }
 
@@ -832,9 +854,9 @@ static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
  * Add the passed pages to the LRU, then drop the caller's refcount
  * on them.  Reinitialises the caller's pagevec.
  */
-void __pagevec_lru_add(struct pagevec *pvec)
+void __pagevec_lru_add(struct pagevec *pvec, bool new)
 {
-	pagevec_lru_move_fn(pvec, __pagevec_lru_add_fn, NULL);
+	pagevec_lru_move_fn(pvec, __pagevec_lru_add_fn, (void *)new);
 }
 
 /**
diff --git a/mm/vmscan.c b/mm/vmscan.c
index f79010bbcdd4..8503713bb60e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -737,7 +737,7 @@ redo:
 		 * We know how to handle that.
 		 */
 		is_unevictable = false;
-		lru_cache_add(page);
+		lru_cache_putback(page);
 	} else {
 		/*
 		 * Put unevictable pages directly on zone's unevictable
-- 
2.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
