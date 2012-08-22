Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 2010C6B006C
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 03:15:01 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 4/5] vmscan: get rid of unnecessary nr_dirty ret variable
Date: Wed, 22 Aug 2012 16:15:16 +0900
Message-Id: <1345619717-5322-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1345619717-5322-1-git-send-email-minchan@kernel.org>
References: <1345619717-5322-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>

Now anyone don't use nr_dirty so remove it.

Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmscan.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0e2550c..1a66680 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -674,7 +674,6 @@ static enum page_references page_check_references(struct page *page,
 static unsigned long shrink_page_list(struct list_head *page_list,
 				      struct zone *zone,
 				      struct scan_control *sc,
-				      unsigned long *ret_nr_dirty,
 				      unsigned long *ret_nr_writeback)
 {
 	LIST_HEAD(ret_pages);
@@ -955,7 +954,6 @@ keep:
 	list_splice(&ret_pages, page_list);
 	count_vm_events(PGACTIVATE, pgactivate);
 	mem_cgroup_uncharge_end();
-	*ret_nr_dirty += nr_dirty;
 	*ret_nr_writeback += nr_writeback;
 	return nr_reclaimed;
 }
@@ -1236,7 +1234,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	unsigned long nr_scanned;
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_taken;
-	unsigned long nr_dirty = 0;
 	unsigned long nr_writeback = 0;
 	isolate_mode_t isolate_mode = 0;
 	int file = is_file_lru(lru);
@@ -1278,8 +1275,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	if (nr_taken == 0)
 		return 0;
 
-	nr_reclaimed = shrink_page_list(&page_list, zone, sc,
-						&nr_dirty, &nr_writeback);
+	nr_reclaimed = shrink_page_list(&page_list, zone, sc, &nr_writeback);
 
 	spin_lock_irq(&zone->lru_lock);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
