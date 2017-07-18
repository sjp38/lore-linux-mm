Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 344C36B0279
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 12:00:30 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id l200so5549057lfb.6
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 09:00:30 -0700 (PDT)
Received: from forwardcorp1g.cmail.yandex.net (forwardcorp1g.cmail.yandex.net. [87.250.241.190])
        by mx.google.com with ESMTPS id u19si1181357lff.162.2017.07.18.09.00.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jul 2017 09:00:27 -0700 (PDT)
Subject: [PATCH RFC] mm: allow isolation for pages not inserted into lru
 lists yet
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Tue, 18 Jul 2017 19:00:23 +0300
Message-ID: <150039362282.196778.7901790444249317003.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Shaohua Li <shli@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>
Cc: linux-kernel@vger.kernel.org

Pages are added into lru lists via per-cpu page vectors in order
to combine these insertions and reduce lru lock contention.

These pending pages cannot be isolated and moved into another lru.
This breaks in some cases page activation and makes mlock-munlock
much more complicated.

Also this breaks newly added swapless MADV_FREE: if it cannot move
anon page into file lru then page could never be freed lazily.

This patch rearranges lru list handling to allow lru isolation for
such pages. It set PageLRU earlier and initialize page->lru to mark
pages still pending for lru insert.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 include/linux/mm_inline.h |   10 ++++++++--
 mm/swap.c                 |   26 ++++++++++++++++++++++++--
 2 files changed, 32 insertions(+), 4 deletions(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index e030a68ead7e..6618c588ee40 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -60,8 +60,14 @@ static __always_inline void add_page_to_lru_list_tail(struct page *page,
 static __always_inline void del_page_from_lru_list(struct page *page,
 				struct lruvec *lruvec, enum lru_list lru)
 {
-	list_del(&page->lru);
-	update_lru_size(lruvec, lru, page_zonenum(page), -hpage_nr_pages(page));
+	/*
+	 * Empty list head means page is not drained to lru list yet.
+	 */
+	if (likely(!list_empty(&page->lru))) {
+		list_del(&page->lru);
+		update_lru_size(lruvec, lru, page_zonenum(page),
+				-hpage_nr_pages(page));
+	}
 }
 
 /**
diff --git a/mm/swap.c b/mm/swap.c
index 23fc6e049cda..ba4c98074a09 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -400,13 +400,35 @@ void mark_page_accessed(struct page *page)
 }
 EXPORT_SYMBOL(mark_page_accessed);
 
+static void __pagevec_lru_add_drain_fn(struct page *page, struct lruvec *lruvec,
+				       void *arg)
+{
+	/* Check for isolated or already added pages */
+	if (likely(PageLRU(page) && list_empty(&page->lru))) {
+		int file = page_is_file_cache(page);
+		int active = PageActive(page);
+		enum lru_list lru = page_lru(page);
+
+		add_page_to_lru_list(page, lruvec, lru);
+		update_page_reclaim_stat(lruvec, file, active);
+		trace_mm_lru_insertion(page, lru);
+	}
+}
+
 static void __lru_cache_add(struct page *page)
 {
 	struct pagevec *pvec = &get_cpu_var(lru_add_pvec);
 
+	/*
+	 * Set PageLRU right here and initialize list head to
+	 * allow page isolation while it on the way to the LRU list.
+	 */
+	VM_BUG_ON_PAGE(PageLRU(page), page);
+	INIT_LIST_HEAD(&page->lru);
 	get_page(page);
+	SetPageLRU(page);
 	if (!pagevec_add(pvec, page) || PageCompound(page))
-		__pagevec_lru_add(pvec);
+		pagevec_lru_move_fn(pvec, __pagevec_lru_add_drain_fn, NULL);
 	put_cpu_var(lru_add_pvec);
 }
 
@@ -611,7 +633,7 @@ void lru_add_drain_cpu(int cpu)
 	struct pagevec *pvec = &per_cpu(lru_add_pvec, cpu);
 
 	if (pagevec_count(pvec))
-		__pagevec_lru_add(pvec);
+		pagevec_lru_move_fn(pvec, __pagevec_lru_add_drain_fn, NULL);
 
 	pvec = &per_cpu(lru_rotate_pvecs, cpu);
 	if (pagevec_count(pvec)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
