Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2C727900119
	for <linux-mm@kvack.org>; Wed, 13 Jul 2011 10:31:37 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 4/5] mm: vmscan: Immediately reclaim end-of-LRU dirty pages when writeback completes
Date: Wed, 13 Jul 2011 15:31:26 +0100
Message-Id: <1310567487-15367-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1310567487-15367-1-git-send-email-mgorman@suse.de>
References: <1310567487-15367-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>

When direct reclaim encounters a dirty page, it gets recycled around
the LRU for another cycle. This patch marks the page PageReclaim using
deactivate_page() so that the page gets reclaimed almost immediately
after the page gets cleaned. This is to avoid reclaiming clean pages
that are younger than a dirty page encountered at the end of the LRU
that might have been something like a use-once page.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |    2 +-
 mm/vmscan.c            |   10 ++++++++--
 mm/vmstat.c            |    2 +-
 3 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c4508a2..bea7858 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -100,7 +100,7 @@ enum zone_stat_item {
 	NR_UNSTABLE_NFS,	/* NFS unstable pages */
 	NR_BOUNCE,
 	NR_VMSCAN_WRITE,
-	NR_VMSCAN_WRITE_SKIP,
+	NR_VMSCAN_INVALIDATE,
 	NR_VMSCAN_THROTTLED,
 	NR_WRITEBACK_TEMP,	/* Writeback using temporary buffers */
 	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9826086..8e00aee 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -834,8 +834,13 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			 */
 			if (page_is_file_cache(page) &&
 					(!current_is_kswapd() || priority >= DEF_PRIORITY - 2)) {
-				inc_zone_page_state(page, NR_VMSCAN_WRITE_SKIP);
-				goto keep_locked;
+				inc_zone_page_state(page, NR_VMSCAN_INVALIDATE);
+
+				/* Immediately reclaim when written back */
+				unlock_page(page);
+				deactivate_page(page);
+
+				goto keep_dirty;
 			}
 
 			if (references == PAGEREF_RECLAIM_CLEAN)
@@ -956,6 +961,7 @@ keep:
 		reset_reclaim_mode(sc);
 keep_lumpy:
 		list_add(&page->lru, &ret_pages);
+keep_dirty:
 		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
 	}
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 59ee17c..2c82ae5 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -702,7 +702,7 @@ const char * const vmstat_text[] = {
 	"nr_unstable",
 	"nr_bounce",
 	"nr_vmscan_write",
-	"nr_vmscan_write_skip",
+	"nr_vmscan_invalidate",
 	"nr_vmscan_throttled",
 	"nr_writeback_temp",
 	"nr_isolated_anon",
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
