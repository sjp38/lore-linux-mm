Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 2E34B6B009D
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 02:41:27 -0500 (EST)
Received: by iacb35 with SMTP id b35so33329068iac.14
        for <linux-mm@kvack.org>; Sat, 31 Dec 2011 23:41:26 -0800 (PST)
Date: Sat, 31 Dec 2011 23:41:23 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 1/6] mm: fewer underscores in ____pagevec_lru_add
In-Reply-To: <alpine.LSU.2.00.1112312333380.18500@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1112312339550.18500@eggly.anvils>
References: <alpine.LSU.2.00.1112312333380.18500@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

What's so special about ____pagevec_lru_add() that it needs four
leading underscores?  Nothing, it just helped to distinguish from
__pagevec_lru_add() in 2.6.28 development.  Cut two leading underscores.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/pagevec.h |   10 +++++-----
 mm/swap.c               |   12 ++++++------
 2 files changed, 11 insertions(+), 11 deletions(-)

--- mmotm.orig/include/linux/pagevec.h	2011-12-30 21:21:34.735338589 -0800
+++ mmotm/include/linux/pagevec.h	2011-12-30 21:29:45.671350259 -0800
@@ -21,7 +21,7 @@ struct pagevec {
 };
 
 void __pagevec_release(struct pagevec *pvec);
-void ____pagevec_lru_add(struct pagevec *pvec, enum lru_list lru);
+void __pagevec_lru_add(struct pagevec *pvec, enum lru_list lru);
 unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
 		pgoff_t start, unsigned nr_pages);
 unsigned pagevec_lookup_tag(struct pagevec *pvec,
@@ -66,22 +66,22 @@ static inline void pagevec_release(struc
 
 static inline void __pagevec_lru_add_anon(struct pagevec *pvec)
 {
-	____pagevec_lru_add(pvec, LRU_INACTIVE_ANON);
+	__pagevec_lru_add(pvec, LRU_INACTIVE_ANON);
 }
 
 static inline void __pagevec_lru_add_active_anon(struct pagevec *pvec)
 {
-	____pagevec_lru_add(pvec, LRU_ACTIVE_ANON);
+	__pagevec_lru_add(pvec, LRU_ACTIVE_ANON);
 }
 
 static inline void __pagevec_lru_add_file(struct pagevec *pvec)
 {
-	____pagevec_lru_add(pvec, LRU_INACTIVE_FILE);
+	__pagevec_lru_add(pvec, LRU_INACTIVE_FILE);
 }
 
 static inline void __pagevec_lru_add_active_file(struct pagevec *pvec)
 {
-	____pagevec_lru_add(pvec, LRU_ACTIVE_FILE);
+	__pagevec_lru_add(pvec, LRU_ACTIVE_FILE);
 }
 
 static inline void pagevec_lru_add_file(struct pagevec *pvec)
--- mmotm.orig/mm/swap.c	2011-12-30 21:21:34.735338589 -0800
+++ mmotm/mm/swap.c	2011-12-30 21:29:45.675350259 -0800
@@ -378,7 +378,7 @@ void __lru_cache_add(struct page *page,
 
 	page_cache_get(page);
 	if (!pagevec_add(pvec, page))
-		____pagevec_lru_add(pvec, lru);
+		__pagevec_lru_add(pvec, lru);
 	put_cpu_var(lru_add_pvecs);
 }
 EXPORT_SYMBOL(__lru_cache_add);
@@ -506,7 +506,7 @@ static void drain_cpu_pagevecs(int cpu)
 	for_each_lru(lru) {
 		pvec = &pvecs[lru - LRU_BASE];
 		if (pagevec_count(pvec))
-			____pagevec_lru_add(pvec, lru);
+			__pagevec_lru_add(pvec, lru);
 	}
 
 	pvec = &per_cpu(lru_rotate_pvecs, cpu);
@@ -698,7 +698,7 @@ void lru_add_page_tail(struct zone* zone
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
-static void ____pagevec_lru_add_fn(struct page *page, void *arg)
+static void __pagevec_lru_add_fn(struct page *page, void *arg)
 {
 	enum lru_list lru = (enum lru_list)arg;
 	struct zone *zone = page_zone(page);
@@ -720,14 +720,14 @@ static void ____pagevec_lru_add_fn(struc
  * Add the passed pages to the LRU, then drop the caller's refcount
  * on them.  Reinitialises the caller's pagevec.
  */
-void ____pagevec_lru_add(struct pagevec *pvec, enum lru_list lru)
+void __pagevec_lru_add(struct pagevec *pvec, enum lru_list lru)
 {
 	VM_BUG_ON(is_unevictable_lru(lru));
 
-	pagevec_lru_move_fn(pvec, ____pagevec_lru_add_fn, (void *)lru);
+	pagevec_lru_move_fn(pvec, __pagevec_lru_add_fn, (void *)lru);
 }
 
-EXPORT_SYMBOL(____pagevec_lru_add);
+EXPORT_SYMBOL(__pagevec_lru_add);
 
 /**
  * pagevec_lookup - gang pagecache lookup

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
