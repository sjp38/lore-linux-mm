Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0C4BE90013B
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 06:47:32 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 7/7] mm: vmscan: Immediately reclaim end-of-LRU dirty pages when writeback completes
Date: Wed, 10 Aug 2011 11:47:20 +0100
Message-Id: <1312973240-32576-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1312973240-32576-1-git-send-email-mgorman@suse.de>
References: <1312973240-32576-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>

When direct reclaim encounters a dirty page, it gets recycled around
the LRU for another cycle. This patch marks the page PageReclaim
similar to deactivate_page() so that the page gets reclaimed almost
immediately after the page gets cleaned. This is to avoid reclaiming
clean pages that are younger than a dirty page encountered at the
end of the LRU that might have been something like a use-once page.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Johannes Weiner <jweiner@redhat.com>
---
 include/linux/mmzone.h |    2 +-
 mm/vmscan.c            |   10 +++++++++-
 mm/vmstat.c            |    2 +-
 3 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index b70a0c0..c9c5797 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -100,7 +100,7 @@ enum zone_stat_item {
 	NR_UNSTABLE_NFS,	/* NFS unstable pages */
 	NR_BOUNCE,
 	NR_VMSCAN_WRITE,
-	NR_VMSCAN_WRITE_SKIP,
+	NR_VMSCAN_IMMEDIATE,	/* Prioritise for reclaim when writeback ends */
 	NR_WRITEBACK_TEMP,	/* Writeback using temporary buffers */
 	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
 	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b0437f2..33882a3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -826,7 +826,15 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			 */
 			if (page_is_file_cache(page) &&
 					(!current_is_kswapd() || priority >= DEF_PRIORITY - 2)) {
-				inc_zone_page_state(page, NR_VMSCAN_WRITE_SKIP);
+				/*
+				 * Immediately reclaim when written back.
+				 * Similar in principal to deactivate_page()
+				 * except we already have the page isolated
+				 * and know it's dirty
+				 */
+				inc_zone_page_state(page, NR_VMSCAN_IMMEDIATE);
+				SetPageReclaim(page);
+
 				goto keep_locked;
 			}
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index fd109f3..471b20b 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -702,7 +702,7 @@ const char * const vmstat_text[] = {
 	"nr_unstable",
 	"nr_bounce",
 	"nr_vmscan_write",
-	"nr_vmscan_write_skip",
+	"nr_vmscan_immediate_reclaim",
 	"nr_writeback_temp",
 	"nr_isolated_anon",
 	"nr_isolated_file",
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
