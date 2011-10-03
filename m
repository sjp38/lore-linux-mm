Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id BA2099000DA
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 09:45:58 -0400 (EDT)
Message-Id: <20111003134537.584729093@intel.com>
Date: Mon, 03 Oct 2011 21:42:39 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 11/11] writeback: per-bdi background threshold
References: <20111003134228.090592370@intel.com>
Content-Disposition: inline; filename=writeback-bdi-background-thresh.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

One thing puzzled me is that in JBOD case, the per-disk writeout
performance is smaller than the corresponding single-disk case even
when they have comparable bdi_thresh. Tracing shows find that in single
disk case, bdi_writeback is always kept high while in JBOD case, it
could drop low from time to time and correspondingly bdi_reclaimable
could sometimes rush high.

The fix is to watch bdi_reclaimable and kick background writeback as
soon as it goes high. This resembles the global background threshold
but in per-bdi manner. The trick is, as long as bdi_reclaimable does
not go high, bdi_writeback naturally won't go low because
bdi_reclaimable+bdi_writeback ~= bdi_thresh.

With less fluctuated writeback pages, JBOD performance is observed to
increase noticeably in various cases.

vmstat:nr_written values before/after patch:

  3.1.0-rc4-wo-underrun+      3.1.0-rc4-bgthresh3+  
------------------------  ------------------------  
               125596480       +25.9%    158179363  JBOD-10HDD-16G/ext4-100dd-1M-24p-16384M-20:10-X
                61790815      +110.4%    130032231  JBOD-10HDD-16G/ext4-10dd-1M-24p-16384M-20:10-X
                58853546        -0.1%     58823828  JBOD-10HDD-16G/ext4-1dd-1M-24p-16384M-20:10-X
               110159811       +24.7%    137355377  JBOD-10HDD-16G/xfs-100dd-1M-24p-16384M-20:10-X
                69544762       +10.8%     77080047  JBOD-10HDD-16G/xfs-10dd-1M-24p-16384M-20:10-X
                50644862        +0.5%     50890006  JBOD-10HDD-16G/xfs-1dd-1M-24p-16384M-20:10-X
                42677090       +28.0%     54643527  JBOD-10HDD-thresh=100M/ext4-100dd-1M-24p-16384M-100M:10-X
                47491324       +13.3%     53785605  JBOD-10HDD-thresh=100M/ext4-10dd-1M-24p-16384M-100M:10-X
                52548986        +0.9%     53001031  JBOD-10HDD-thresh=100M/ext4-1dd-1M-24p-16384M-100M:10-X
                26783091       +36.8%     36650248  JBOD-10HDD-thresh=100M/xfs-100dd-1M-24p-16384M-100M:10-X
                35526347       +14.0%     40492312  JBOD-10HDD-thresh=100M/xfs-10dd-1M-24p-16384M-100M:10-X
                44670723        -1.1%     44177606  JBOD-10HDD-thresh=100M/xfs-1dd-1M-24p-16384M-100M:10-X
               127996037       +22.4%    156719990  JBOD-10HDD-thresh=2G/ext4-100dd-1M-24p-16384M-2048M:10-X
                57518856        +3.8%     59677625  JBOD-10HDD-thresh=2G/ext4-10dd-1M-24p-16384M-2048M:10-X
                51919909       +12.2%     58269894  JBOD-10HDD-thresh=2G/ext4-1dd-1M-24p-16384M-2048M:10-X
                86410514       +79.0%    154660433  JBOD-10HDD-thresh=2G/xfs-100dd-1M-24p-16384M-2048M:10-X
                40132519       +38.6%     55617893  JBOD-10HDD-thresh=2G/xfs-10dd-1M-24p-16384M-2048M:10-X
                48423248        +7.5%     52042927  JBOD-10HDD-thresh=2G/xfs-1dd-1M-24p-16384M-2048M:10-X
               206041046       +44.1%    296846536  JBOD-10HDD-thresh=4G/xfs-100dd-1M-24p-16384M-4096M:10-X
                72312903       -19.4%     58272885  JBOD-10HDD-thresh=4G/xfs-10dd-1M-24p-16384M-4096M:10-X
                50635672        -0.5%     50384787  JBOD-10HDD-thresh=4G/xfs-1dd-1M-24p-16384M-4096M:10-X
                68308534      +115.7%    147324758  JBOD-10HDD-thresh=800M/ext4-100dd-1M-24p-16384M-800M:10-X
                57882933       +14.5%     66269621  JBOD-10HDD-thresh=800M/ext4-10dd-1M-24p-16384M-800M:10-X
                52183472       +12.8%     58855181  JBOD-10HDD-thresh=800M/ext4-1dd-1M-24p-16384M-800M:10-X
                53788956       +94.2%    104460352  JBOD-10HDD-thresh=800M/xfs-100dd-1M-24p-16384M-800M:10-X
                44493342       +35.5%     60298210  JBOD-10HDD-thresh=800M/xfs-10dd-1M-24p-16384M-800M:10-X
                42641209       +18.9%     50681038  JBOD-10HDD-thresh=800M/xfs-1dd-1M-24p-16384M-800M:10-X

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |   17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2011-10-02 10:28:55.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2011-10-02 10:42:22.000000000 +0800
@@ -658,14 +658,21 @@ long writeback_inodes_wb(struct bdi_writ
 	return nr_pages - work.nr_pages;
 }
 
-static inline bool over_bground_thresh(void)
+static bool over_bground_thresh(struct backing_dev_info *bdi)
 {
 	unsigned long background_thresh, dirty_thresh;
 
 	global_dirty_limits(&background_thresh, &dirty_thresh);
 
-	return (global_page_state(NR_FILE_DIRTY) +
-		global_page_state(NR_UNSTABLE_NFS) > background_thresh);
+	if (global_page_state(NR_FILE_DIRTY) +
+	    global_page_state(NR_UNSTABLE_NFS) > background_thresh)
+		return true;
+
+	if (bdi_stat(bdi, BDI_RECLAIMABLE) >
+				bdi_dirty_limit(bdi, background_thresh))
+		return true;
+
+	return false;
 }
 
 /*
@@ -727,7 +734,7 @@ static long wb_writeback(struct bdi_writ
 		 * For background writeout, stop when we are below the
 		 * background dirty threshold
 		 */
-		if (work->for_background && !over_bground_thresh())
+		if (work->for_background && !over_bground_thresh(wb->bdi))
 			break;
 
 		if (work->for_kupdate) {
@@ -811,7 +818,7 @@ static unsigned long get_nr_dirty_pages(
 
 static long wb_check_background_flush(struct bdi_writeback *wb)
 {
-	if (over_bground_thresh()) {
+	if (over_bground_thresh(wb->bdi)) {
 
 		struct wb_writeback_work work = {
 			.nr_pages	= LONG_MAX,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
