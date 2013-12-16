Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id DB08F6B0039
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 05:14:29 -0500 (EST)
Received: by mail-ee0-f50.google.com with SMTP id c41so2093289eek.23
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 02:14:29 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l44si12806818eem.187.2013.12.16.02.14.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 02:14:29 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 3/3] mm: munlock: fix potential race with THP page split
Date: Mon, 16 Dec 2013 11:14:16 +0100
Message-Id: <1387188856-21027-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1387188856-21027-1-git-send-email-vbabka@suse.cz>
References: <52AE07B4.4020203@oracle.com>
 <1387188856-21027-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, joern@logfs.org, Michel Lespinasse <walken@google.com>, Vlastimil Babka <vbabka@suse.cz>, stable@kernel.org

Since commit ff6a6da60 ("mm: accelerate munlock() treatment of THP pages")
munlock skips tail pages of a munlocked THP page. There is some attempt to
prevent bad consequences of racing with a THP page split, but code inspection
indicates that there are two problems that may lead to a non-fatal, yet wrong
outcome.

First, __split_huge_page_refcount() copies flags including PageMlocked from
the head page to the tail pages. Clearing PageMlocked by munlock_vma_page()
in the middle of this operation might result in part of tail pages left with
PageMlocked flag. As the head page still appears to be a THP page until all
tail pages are processed, munlock_vma_page() might think it munlocked the whole
THP page and skip all the former tail pages. Before ff6a6da60, those pages
would be cleared in further iterations of munlock_vma_pages_range(), but
NR_MLOCK would still become undercounted (related the next point).

Second, NR_MLOCK accounting is based on call to hpage_nr_pages() after the
PageMlocked is cleared. The accounting might also become inconsistent due to
race with __split_huge_page_refcount()
 - undercount when HUGE_PMD_NR is subtracted, but some tail pages are left
   with PageMlocked set and counted again (only possible before ff6a6da60)
 - overcount when hpage_nr_pages() sees a normal page (split has already
   finished), but the parallel split has meanwhile cleared PageMlocked from
   additional tail pages

This patch prevents both problems via extending the scope of lru_lock in
munlock_vma_page(). This is convenient because:
- __split_huge_page_refcount() takes lru_lock for its whole operation
- munlock_vma_page() typically takes lru_lock anyway for page isolation

As this becomes a second function where page isolation is done with lru_lock
already held, factor this out to a new __munlock_isolate_lru_page() function
and clean up the code around.

Cc: stable@kernel.org
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/mlock.c | 104 +++++++++++++++++++++++++++++++++++--------------------------
 1 file changed, 60 insertions(+), 44 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index 31383d5..ca597f3 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -91,6 +91,26 @@ void mlock_vma_page(struct page *page)
 }
 
 /*
+ * Isolate a page from LRU with optional get_page() pin.
+ * Assumes lru_lock already held and page already pinned.
+ */
+static bool __munlock_isolate_lru_page(struct page *page, bool getpage)
+{
+	if (PageLRU(page)) {
+		struct lruvec *lruvec = mem_cgroup_page_lruvec(page,
+				page_zone(page));
+
+		if (getpage)
+			get_page(page);
+		ClearPageLRU(page);
+		del_page_from_lru_list(page, lruvec, page_lru(page));
+		return true;
+	}
+
+	return false;
+}
+
+/*
  * Finish munlock after successful page isolation
  *
  * Page must be locked. This is a wrapper for try_to_munlock()
@@ -126,9 +146,9 @@ static void __munlock_isolated_page(struct page *page)
 static void __munlock_isolation_failed(struct page *page)
 {
 	if (PageUnevictable(page))
-		count_vm_event(UNEVICTABLE_PGSTRANDED);
+		__count_vm_event(UNEVICTABLE_PGSTRANDED);
 	else
-		count_vm_event(UNEVICTABLE_PGMUNLOCKED);
+		__count_vm_event(UNEVICTABLE_PGMUNLOCKED);
 }
 
 /**
@@ -149,28 +169,34 @@ static void __munlock_isolation_failed(struct page *page)
 unsigned int munlock_vma_page(struct page *page)
 {
 	unsigned int nr_pages;
+	struct zone *zone = page_zone(page);
 
 	BUG_ON(!PageLocked(page));
 
-	if (TestClearPageMlocked(page)) {
-		nr_pages = hpage_nr_pages(page);
-		mod_zone_page_state(page_zone(page), NR_MLOCK, -nr_pages);
-		if (!isolate_lru_page(page))
-			__munlock_isolated_page(page);
-		else
-			__munlock_isolation_failed(page);
-	} else {
-		nr_pages = hpage_nr_pages(page);
-	}
-
 	/*
-	 * Regardless of the original PageMlocked flag, we determine nr_pages
-	 * after touching the flag. This leaves a possible race with a THP page
-	 * split, such that a whole THP page was munlocked, but nr_pages == 1.
-	 * Returning a smaller mask due to that is OK, the worst that can
-	 * happen is subsequent useless scanning of the former tail pages.
-	 * The NR_MLOCK accounting can however become broken.
+	 * Serialize with any parallel __split_huge_page_refcount() which
+	 * might otherwise copy PageMlocked to part of the tail pages before
+	 * we clear it in the head page. It also stabilizes hpage_nr_pages().
 	 */
+	spin_lock_irq(&zone->lru_lock);
+
+	nr_pages = hpage_nr_pages(page);
+	if (!TestClearPageMlocked(page))
+		goto unlock_out;
+
+	__mod_zone_page_state(zone, NR_MLOCK, -nr_pages);
+
+	if (__munlock_isolate_lru_page(page, true)) {
+		spin_unlock_irq(&zone->lru_lock);
+		__munlock_isolated_page(page);
+		goto out;
+	}
+	__munlock_isolation_failed(page);
+
+unlock_out:
+	spin_unlock_irq(&zone->lru_lock);
+
+out:
 	return nr_pages - 1;
 }
 
@@ -307,34 +333,24 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
 		struct page *page = pvec->pages[i];
 
 		if (TestClearPageMlocked(page)) {
-			struct lruvec *lruvec;
-			int lru;
-
-			if (PageLRU(page)) {
-				lruvec = mem_cgroup_page_lruvec(page, zone);
-				lru = page_lru(page);
-				/*
-				 * We already have pin from follow_page_mask()
-				 * so we can spare the get_page() here.
-				 */
-				ClearPageLRU(page);
-				del_page_from_lru_list(page, lruvec, lru);
-			} else {
-				__munlock_isolation_failed(page);
-				goto skip_munlock;
-			}
-
-		} else {
-skip_munlock:
 			/*
-			 * We won't be munlocking this page in the next phase
-			 * but we still need to release the follow_page_mask()
-			 * pin. We cannot do it under lru_lock however. If it's
-			 * the last pin, __page_cache_release would deadlock.
+			 * We already have pin from follow_page_mask()
+			 * so we can spare the get_page() here.
 			 */
-			pagevec_add(&pvec_putback, pvec->pages[i]);
-			pvec->pages[i] = NULL;
+			if (__munlock_isolate_lru_page(page, false))
+				continue;
+			else
+				__munlock_isolation_failed(page);
 		}
+
+		/*
+		 * We won't be munlocking this page in the next phase
+		 * but we still need to release the follow_page_mask()
+		 * pin. We cannot do it under lru_lock however. If it's
+		 * the last pin, __page_cache_release() would deadlock.
+		 */
+		pagevec_add(&pvec_putback, pvec->pages[i]);
+		pvec->pages[i] = NULL;
 	}
 	delta_munlocked = -nr + pagevec_count(&pvec_putback);
 	__mod_zone_page_state(zone, NR_MLOCK, delta_munlocked);
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
