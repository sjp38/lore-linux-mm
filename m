Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 1DF6C6B0192
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 02:39:46 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id r10so483634pdi.35
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 23:39:45 -0700 (PDT)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ha5si704059pbc.172.2014.03.19.23.39.43
        for <linux-mm@kvack.org>;
        Wed, 19 Mar 2014 23:39:44 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC v2 2/3] mm: work deactivate_page with anon pages
Date: Thu, 20 Mar 2014 15:38:57 +0900
Message-Id: <1395297538-10491-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1395297538-10491-1-git-send-email-minchan@kernel.org>
References: <1395297538-10491-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, John Stultz <john.stultz@linaro.org>, Jason Evans <je@fb.com>, Minchan Kim <minchan@kernel.org>

Now, deactivate_page works for file page but MADV_FREE will use
it to move lazyfree pages to inactive LRU's tail so this patch
makes deactivate_page work with anon pages as well as file pages.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/mm_inline.h |  9 +++++++++
 mm/swap.c                 | 20 ++++++++++----------
 2 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index cf55945c83fb..0503caafd532 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -22,6 +22,15 @@ static inline int page_is_file_cache(struct page *page)
 	return !PageSwapBacked(page);
 }
 
+static __always_inline void add_page_to_lru_list_tail(struct page *page,
+				struct lruvec *lruvec, enum lru_list lru)
+{
+	int nr_pages = hpage_nr_pages(page);
+	mem_cgroup_update_lru_size(lruvec, lru, nr_pages);
+	list_add_tail(&page->lru, &lruvec->lists[lru]);
+	__mod_zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru, nr_pages);
+}
+
 static __always_inline void add_page_to_lru_list(struct page *page,
 				struct lruvec *lruvec, enum lru_list lru)
 {
diff --git a/mm/swap.c b/mm/swap.c
index 0092097b3f4c..ac13714b5d8b 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -643,14 +643,11 @@ void add_page_to_unevictable_list(struct page *page)
  * If the page isn't page_mapped and dirty/writeback, the page
  * could reclaim asap using PG_reclaim.
  *
- * 1. active, mapped page -> none
- * 2. active, dirty/writeback page -> inactive, head, PG_reclaim
- * 3. inactive, mapped page -> none
- * 4. inactive, dirty/writeback page -> inactive, head, PG_reclaim
- * 5. inactive, clean -> inactive, tail
- * 6. Others -> none
+ * 1. file mapped page -> none
+ * 2. dirty/writeback page -> head of inactive with PG_reclaim
+ * 3. inactive, clean -> tail of inactive
  *
- * In 4, why it moves inactive's head, the VM expects the page would
+ * In 2, why it moves inactive's head, the VM expects the page would
  * be write it out by flusher threads as this is much more effective
  * than the single-page writeout from reclaim.
  */
@@ -667,7 +664,7 @@ static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
 		return;
 
 	/* Some processes are using the page */
-	if (page_mapped(page))
+	if (!PageAnon(page) && page_mapped(page))
 		return;
 
 	active = PageActive(page);
@@ -677,7 +674,6 @@ static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
 	del_page_from_lru_list(page, lruvec, lru + active);
 	ClearPageActive(page);
 	ClearPageReferenced(page);
-	add_page_to_lru_list(page, lruvec, lru);
 
 	if (PageWriteback(page) || PageDirty(page)) {
 		/*
@@ -686,12 +682,16 @@ static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
 		 * is _really_ small and  it's non-critical problem.
 		 */
 		SetPageReclaim(page);
+		add_page_to_lru_list(page, lruvec, lru);
 	} else {
 		/*
 		 * The page's writeback ends up during pagevec
 		 * We moves tha page into tail of inactive.
+		 *
+		 * The lazyfree page move into lru's tail to
+		 * discard easily.
 		 */
-		list_move_tail(&page->lru, &lruvec->lists[lru]);
+		add_page_to_lru_list_tail(page, lruvec, lru);
 		__count_vm_event(PGROTATED);
 	}
 
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
