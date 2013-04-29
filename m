Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 11DDF6B0078
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 12:32:45 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/3] mm: pagevec: Defer deciding what LRU to add a page to until pagevec drain time
Date: Mon, 29 Apr 2013 17:31:57 +0100
Message-Id: <1367253119-6461-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1367253119-6461-1-git-send-email-mgorman@suse.de>
References: <1367253119-6461-1-git-send-email-mgorman@suse.de>
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
---
 mm/swap.c | 37 +++++++++++++++++--------------------
 1 file changed, 17 insertions(+), 20 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 8a529a0..80fbc37 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -36,7 +36,7 @@
 /* How many pages do we try to swap or page in/out together? */
 int page_cluster;
 
-static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
+static DEFINE_PER_CPU(struct pagevec, lru_add_pvec);
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
 
@@ -456,13 +456,18 @@ EXPORT_SYMBOL(mark_page_accessed);
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
 
@@ -475,13 +480,11 @@ void lru_cache_add_lru(struct page *page, enum lru_list lru)
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
 
@@ -582,15 +585,10 @@ static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
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
@@ -789,17 +787,16 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
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
 }
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
