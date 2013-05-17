Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 1CD7B6B0036
	for <linux-mm@kvack.org>; Fri, 17 May 2013 05:48:16 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/5] mm: pagevec: Defer deciding what LRU to add a page to until pagevec drain time
Date: Fri, 17 May 2013 10:48:04 +0100
Message-Id: <1368784087-956-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1368784087-956-1-git-send-email-mgorman@suse.de>
References: <1368784087-956-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Lyahkov <alexey.lyashkov@gmail.com>, Andrew Perepechko <anserper@ya.ru>, Robin Dong <sanbai@taobao.com>
Cc: Theodore Tso <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Bernd Schubert <bernd.schubert@fastmail.fm>, David Howells <dhowells@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-ext4 <linux-ext4@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>

mark_page_accessed cannot activate an inactive page that is located on
an inactive LRU pagevec. Hints from filesystems may be ignored as a
result. In preparation for fixing that problem, this patch removes the
per-LRU pagevecs and leaves just one pagevec. The final LRU the page is
added to is deferred until the pagevec is drained.

This means that fewer pagevecs are available and potentially there is
greater contention on the LRU lock. However, this only applies in the case
where there is an almost perfect mix of file, anon, active and inactive
pages being added to the LRU. In practice I expect that we are adding
stream of pages of a particular time and that the changes in contention
will barely be measurable.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
---
 mm/swap.c | 47 +++++++++++++++++++++--------------------------
 1 file changed, 21 insertions(+), 26 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 53c9ceb..868b493 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -40,7 +40,7 @@
 /* How many pages do we try to swap or page in/out together? */
 int page_cluster;
 
-static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
+static DEFINE_PER_CPU(struct pagevec, lru_add_pvec);
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
 
@@ -452,22 +452,25 @@ void mark_page_accessed(struct page *page)
 EXPORT_SYMBOL(mark_page_accessed);
 
 /*
- * Order of operations is important: flush the pagevec when it's already
- * full, not when adding the last page, to make sure that last page is
- * not added to the LRU directly when passed to this function. Because
- * mark_page_accessed() (called after this when writing) only activates
- * pages that are on the LRU, linear writes in subpage chunks would see
- * every PAGEVEC_SIZE page activated, which is unexpected.
+ * Queue the page for addition to the LRU via pagevec. The decision on whether
+ * to add the page to the [in]active [file|anon] list is deferred until the
+ * pagevec is drained. This gives a chance for the caller of __lru_cache_add()
+ * have the page added to the active list using mark_page_accessed().
  */
 void __lru_cache_add(struct page *page, enum lru_list lru)
 {
-	struct pagevec *pvec = &get_cpu_var(lru_add_pvecs)[lru];
+	struct pagevec *pvec = &get_cpu_var(lru_add_pvec);
+
+	if (is_active_lru(lru))
+		SetPageActive(page);
+	else
+		ClearPageActive(page);
 
 	page_cache_get(page);
 	if (!pagevec_space(pvec))
 		__pagevec_lru_add(pvec, lru);
 	pagevec_add(pvec, page);
-	put_cpu_var(lru_add_pvecs);
+	put_cpu_var(lru_add_pvec);
 }
 EXPORT_SYMBOL(__lru_cache_add);
 
@@ -480,13 +483,11 @@ void lru_cache_add_lru(struct page *page, enum lru_list lru)
 {
 	if (PageActive(page)) {
 		VM_BUG_ON(PageUnevictable(page));
-		ClearPageActive(page);
 	} else if (PageUnevictable(page)) {
 		VM_BUG_ON(PageActive(page));
-		ClearPageUnevictable(page);
 	}
 
-	VM_BUG_ON(PageLRU(page) || PageActive(page) || PageUnevictable(page));
+	VM_BUG_ON(PageLRU(page));
 	__lru_cache_add(page, lru);
 }
 
@@ -587,15 +588,10 @@ static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
  */
 void lru_add_drain_cpu(int cpu)
 {
-	struct pagevec *pvecs = per_cpu(lru_add_pvecs, cpu);
-	struct pagevec *pvec;
-	int lru;
+	struct pagevec *pvec = &per_cpu(lru_add_pvec, cpu);
 
-	for_each_lru(lru) {
-		pvec = &pvecs[lru - LRU_BASE];
-		if (pagevec_count(pvec))
-			__pagevec_lru_add(pvec, lru);
-	}
+	if (pagevec_count(pvec))
+		__pagevec_lru_add(pvec, NR_LRU_LISTS);
 
 	pvec = &per_cpu(lru_rotate_pvecs, cpu);
 	if (pagevec_count(pvec)) {
@@ -799,17 +795,16 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
 static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
 				 void *arg)
 {
-	enum lru_list lru = (enum lru_list)arg;
-	int file = is_file_lru(lru);
-	int active = is_active_lru(lru);
+	enum lru_list requested_lru = (enum lru_list)arg;
+	int file = page_is_file_cache(page);
+	int active = PageActive(page);
+	enum lru_list lru = page_lru(page);
 
-	VM_BUG_ON(PageActive(page));
+	WARN_ON_ONCE(requested_lru < NR_LRU_LISTS && requested_lru != lru);
 	VM_BUG_ON(PageUnevictable(page));
 	VM_BUG_ON(PageLRU(page));
 
 	SetPageLRU(page);
-	if (active)
-		SetPageActive(page);
 	add_page_to_lru_list(page, lruvec, lru);
 	update_page_reclaim_stat(lruvec, file, active);
 	trace_mm_lru_insertion(page, page_to_pfn(page), lru, trace_pagemap_flags(page));
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
