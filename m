Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 03B006B0038
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 10:32:18 -0400 (EDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 5/6] mm: munlock: bypass per-cpu pvec for putback_lru_page
Date: Mon,  5 Aug 2013 16:32:04 +0200
Message-Id: <1375713125-18163-6-git-send-email-vbabka@suse.cz>
In-Reply-To: <1375713125-18163-1-git-send-email-vbabka@suse.cz>
References: <1375713125-18163-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: joern@logfs.org
Cc: mgorman@suse.de, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

After introducing batching by pagevecs into munlock_vma_range(), we can further
improve performance by bypassing the copying into per-cpu pagevec and the
get_page/put_page pair associated with that. Instead we perform LRU putback
directly from our pagevec. However, this is possible only for single-mapped
pages that are evictable after munlock. Unevictable pages require rechecking
after putting on the unevictable list, so for those we fallback to
putback_lru_page(), hich handles that.

After this patch, a 13% speedup was measured for munlocking a 56GB large memory
area with THP disabled.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/mlock.c | 85 ++++++++++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 72 insertions(+), 13 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index d112e06..5c38475 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -227,6 +227,49 @@ static int __mlock_posix_error_return(long retval)
 }
 
 /*
+ * Prepare page for fast batched LRU putback via putback_lru_evictable_pagevec()
+ *
+ * The fast path is available only for evictable pages with single mapping.
+ * Then we can bypass the per-cpu pvec and get better performance.
+ * when mapcount > 1 we need try_to_munlock() which can fail.
+ * when !page_evictable(), we need the full redo logic of putback_lru_page to
+ * avoid leaving evictable page in unevictable list.
+ *
+ * In case of success, @page is added to @pvec and @pgrescued is incremented
+ * in case that the page was previously unevictable. @page is also unlocked.
+ */
+static bool __putback_lru_fast_prepare(struct page *page, struct pagevec *pvec,
+		int *pgrescued)
+{
+	VM_BUG_ON(PageLRU(page));
+	VM_BUG_ON(!PageLocked(page));
+
+	if (page_mapcount(page) <= 1 && page_evictable(page)) {
+		pagevec_add(pvec, page);
+		if (TestClearPageUnevictable(page))
+			*pgrescued++;
+		unlock_page(page);
+		return true;
+	}
+
+	return false;
+}
+
+/*
+ * Putback multiple evictable pages to the LRU
+ *
+ * Batched putback of evictable pages that bypasses the per-cpu pvec. Some of
+ * the pages might have meanwhile become unevictable but that is OK.
+ */
+static void __putback_lru_fast(struct pagevec *pvec, int pgrescued)
+{
+	count_vm_events(UNEVICTABLE_PGMUNLOCKED, pagevec_count(pvec));
+	/* This includes put_page so we don't call it explicitly */
+	__pagevec_lru_add(pvec);
+	count_vm_events(UNEVICTABLE_PGRESCUED, pgrescued);
+}
+
+/*
  * Munlock a batch of pages from the same zone
  *
  * The work is split to two main phases. First phase clears the Mlocked flag
@@ -239,6 +282,8 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
 	int i;
 	int nr = pagevec_count(pvec);
 	int delta_munlocked = -nr;
+	struct pagevec pvec_putback;
+	int pgrescued = 0;
 
 	/* Phase 1: page isolation */
 	spin_lock_irq(&zone->lru_lock);
@@ -249,21 +294,18 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
 			struct lruvec *lruvec;
 			int lru;
 
-			switch (__isolate_lru_page(page,
-						ISOLATE_UNEVICTABLE)) {
-			case 0:
+			if (PageLRU(page)) {
 				lruvec = mem_cgroup_page_lruvec(page, zone);
 				lru = page_lru(page);
-				del_page_from_lru_list(page, lruvec, lru);
-				break;
 
-			case -EINVAL:
+				get_page(page);
+				ClearPageLRU(page);
+				del_page_from_lru_list(page, lruvec, lru);
+			} else {
 				__munlock_isolation_failed(page);
 				goto skip_munlock;
-
-			default:
-				BUG();
 			}
+
 		} else {
 skip_munlock:
 			/*
@@ -279,7 +321,8 @@ skip_munlock:
 	__mod_zone_page_state(zone, NR_MLOCK, delta_munlocked);
 	spin_unlock_irq(&zone->lru_lock);
 
-	/* Phase 2: page munlock and putback */
+	/* Phase 2: page munlock */
+	pagevec_init(&pvec_putback, 0);
 	for (i = 0; i < nr; i++) {
 		struct page *page = pvec->pages[i];
 
@@ -287,10 +330,26 @@ skip_munlock:
 			continue;
 
 		lock_page(page);
-		__munlock_isolated_page(page);
-		unlock_page(page);
-		put_page(page); /* pin from follow_page_mask() */
+		if (!__putback_lru_fast_prepare(page, &pvec_putback,
+				&pgrescued)) {
+			/* Slow path */
+			__munlock_isolated_page(page);
+			unlock_page(page);
+		}
 	}
+
+	/* Phase 3: page putback for pages that qualified for the fast path */
+	if (pagevec_count(&pvec_putback))
+		__putback_lru_fast(&pvec_putback, pgrescued);
+
+	/* Phase 4: put_page to return pin from follow_page_mask() */
+	for (i = 0; i < nr; i++) {
+		struct page *page = pvec->pages[i];
+
+		if (likely(page))
+			put_page(page);
+	}
+
 	pagevec_reinit(pvec);
 }
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
