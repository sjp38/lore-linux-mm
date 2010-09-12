Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 37D6D6B0098
	for <linux-mm@kvack.org>; Sun, 12 Sep 2010 11:55:03 -0400 (EDT)
Message-Id: <20100912155205.275730419@intel.com>
Date: Sun, 12 Sep 2010 23:50:02 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 17/17] writeback: consolidate balance_dirty_pages() variable names
References: <20100912154945.758129106@intel.com>
Content-Disposition: inline; filename=writeback-cleanup-name-merge.patch
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Li Shaohua <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

Lots of lenthy tests.. Let's compact the names

	*_dirty3 = dirty + writeback + unstable

balance_dirty_pages() only cares about the above dirty sum except
in one place -- on starting background writeback.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   34 ++++++++++++++++------------------
 1 file changed, 16 insertions(+), 18 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2010-09-12 13:30:38.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-09-12 13:34:04.000000000 +0800
@@ -493,8 +493,8 @@ start_over:
 static void balance_dirty_pages(struct address_space *mapping,
 				unsigned long pages_dirtied)
 {
-	long nr_reclaimable, bdi_nr_reclaimable;
-	long nr_writeback, bdi_nr_writeback;
+	long nr_reclaimable;
+	long nr_dirty3, bdi_dirty3;
 	long bdi_prev_dirty3 = 0;
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
@@ -518,7 +518,7 @@ static void balance_dirty_pages(struct a
 		 */
 		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
 					global_page_state(NR_UNSTABLE_NFS);
-		nr_writeback = global_page_state(NR_WRITEBACK);
+		nr_dirty3 = nr_reclaimable + global_page_state(NR_WRITEBACK);
 
 		global_dirty_limits(&background_thresh, &dirty_thresh);
 
@@ -529,7 +529,7 @@ static void balance_dirty_pages(struct a
 		 */
 		thresh = (background_thresh + dirty_thresh) / 2;
 		thresh = thresh * vm_dirty_pressure / VM_DIRTY_PRESSURE;
-		if (nr_reclaimable + nr_writeback <= thresh)
+		if (nr_dirty3 <= thresh)
 			break;
 
 		task_dirties_fraction(current, &numerator, &denominator);
@@ -548,11 +548,11 @@ static void balance_dirty_pages(struct a
 		 * deltas.
 		 */
 		if (bdi_thresh < 2*bdi_stat_error(bdi)) {
-			bdi_nr_reclaimable = bdi_stat_sum(bdi, BDI_RECLAIMABLE);
-			bdi_nr_writeback = bdi_stat_sum(bdi, BDI_WRITEBACK);
+			bdi_dirty3 = bdi_stat_sum(bdi, BDI_RECLAIMABLE) +
+				     bdi_stat_sum(bdi, BDI_WRITEBACK);
 		} else {
-			bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
-			bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
+			bdi_dirty3 = bdi_stat(bdi, BDI_RECLAIMABLE) +
+				     bdi_stat(bdi, BDI_WRITEBACK);
 		}
 
 		/*
@@ -563,11 +563,10 @@ static void balance_dirty_pages(struct a
 		 * So offer a complementary way to break out of the loop when
 		 * enough bdi pages have been cleaned during our pause time.
 		 */
-		if (nr_reclaimable + nr_writeback <= dirty_thresh &&
-		    bdi_prev_dirty3 - (bdi_nr_reclaimable + bdi_nr_writeback) >
-							(long)pages_dirtied * 8)
+		if (nr_dirty3 <= dirty_thresh &&
+		    bdi_prev_dirty3 - bdi_dirty3 > (long)pages_dirtied * 8)
 			break;
-		bdi_prev_dirty3 = bdi_nr_reclaimable + bdi_nr_writeback;
+		bdi_prev_dirty3 = bdi_dirty3;
 
 
 		thresh = bdi_thresh - bdi_thresh / DIRTY_SOFT_THROTTLE_RATIO;
@@ -584,13 +583,13 @@ static void balance_dirty_pages(struct a
 			else if (thresh > bw)
 				thresh = bw;
 		}
-		if (bdi_nr_reclaimable + bdi_nr_writeback <= thresh)
+		if (bdi_dirty3 <= thresh)
 			goto check_exceeded;
 
 		bdi_update_write_bandwidth(bdi, &bw_time, &bw_written);
 
-		gap = bdi_thresh > (bdi_nr_reclaimable + bdi_nr_writeback) ?
-		      bdi_thresh - (bdi_nr_reclaimable + bdi_nr_writeback) : 0;
+		gap = bdi_thresh > bdi_dirty3 ?
+		      bdi_thresh - bdi_dirty3 : 0;
 
 		bw = bdi->write_bandwidth * gap / (bdi_thresh - thresh + 1);
 
@@ -622,9 +621,8 @@ check_exceeded:
 		 * bdi or process from holding back light ones; The latter is
 		 * the last resort safeguard.
 		 */
-		dirty_exceeded =
-			(bdi_nr_reclaimable + bdi_nr_writeback > bdi_thresh)
-			|| (nr_reclaimable + nr_writeback > dirty_thresh);
+		dirty_exceeded = (bdi_dirty3 > bdi_thresh) ||
+				  (nr_dirty3 > dirty_thresh);
 
 		if (!dirty_exceeded)
 			break;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
