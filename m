Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id A393F6B0083
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 03:54:03 -0400 (EDT)
Received: by mail-lpp01m010-f41.google.com with SMTP id z14so991336lag.14
        for <linux-mm@kvack.org>; Thu, 26 Apr 2012 00:54:03 -0700 (PDT)
Subject: [PATCH 03/12] mm/vmscan: push lruvec pointer into isolate_lru_pages()
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 26 Apr 2012 11:53:59 +0400
Message-ID: <20120426075359.18961.96466.stgit@zurg>
In-Reply-To: <20120426074632.18961.17803.stgit@zurg>
References: <20120426074632.18961.17803.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch moves mem_cgroup_zone_lruvec() call from isolate_lru_pages() into
shrink_[in]active_list(), further patches pushes it to shrink_zone() step by step.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/vmscan.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d81750c..49e79d5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1027,7 +1027,7 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode)
  * Appropriate locks must be held before calling this function.
  *
  * @nr_to_scan:	The number of pages to look through on the list.
- * @mz:		The mem_cgroup_zone to pull pages from.
+ * @lruvec:	The LRU vector to pull pages from.
  * @dst:	The temp list to put pages on to.
  * @nr_scanned:	The number of pages that were scanned.
  * @sc:		The scan_control struct for this reclaim session
@@ -1037,17 +1037,15 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode)
  * returns how many pages were moved onto *@dst.
  */
 static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
-		struct mem_cgroup_zone *mz, struct list_head *dst,
+		struct lruvec *lruvec, struct list_head *dst,
 		unsigned long *nr_scanned, struct scan_control *sc,
 		isolate_mode_t mode, enum lru_list lru)
 {
-	struct lruvec *lruvec;
 	struct list_head *src;
 	unsigned long nr_taken = 0;
 	unsigned long scan;
 	int file = is_file_lru(lru);
 
-	lruvec = mem_cgroup_zone_lruvec(mz->zone, mz->mem_cgroup);
 	src = &lruvec->lists[lru];
 
 	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
@@ -1274,6 +1272,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 	int file = is_file_lru(lru);
 	struct zone *zone = mz->zone;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(mz);
+	struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, mz->mem_cgroup);
 
 	while (unlikely(too_many_isolated(zone, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -1292,8 +1291,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 
 	spin_lock_irq(&zone->lru_lock);
 
-	nr_taken = isolate_lru_pages(nr_to_scan, mz, &page_list, &nr_scanned,
-				     sc, isolate_mode, lru);
+	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &page_list,
+				     &nr_scanned, sc, isolate_mode, lru);
 	if (global_reclaim(sc)) {
 		zone->pages_scanned += nr_scanned;
 		if (current_is_kswapd())
@@ -1439,6 +1438,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	isolate_mode_t isolate_mode = 0;
 	int file = is_file_lru(lru);
 	struct zone *zone = mz->zone;
+	struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, mz->mem_cgroup);
 
 	lru_add_drain();
 
@@ -1449,8 +1449,8 @@ static void shrink_active_list(unsigned long nr_to_scan,
 
 	spin_lock_irq(&zone->lru_lock);
 
-	nr_taken = isolate_lru_pages(nr_to_scan, mz, &l_hold, &nr_scanned, sc,
-				     isolate_mode, lru);
+	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &l_hold,
+				     &nr_scanned, sc, isolate_mode, lru);
 	if (global_reclaim(sc))
 		zone->pages_scanned += nr_scanned;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
