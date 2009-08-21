Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C130E6B007E
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 11:19:22 -0400 (EDT)
Subject: [RFC PATCH] mm: balance_dirty_pages. reduce calls to
 global_page_state to reduce cache references
From: Richard Kennedy <richard@rsk.demon.co.uk>
Content-Type: text/plain
Date: Fri, 21 Aug 2009 12:59:21 +0100
Message-Id: <1250855961.2226.94.camel@castor>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "chris.mason" <chris.mason@oracle.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jens Axboe <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>

Reducing the number of times balance_dirty_pages calls global_page_state
reduces the cache references and so improves write performance on a
variety of workloads.

'perf stats' of simple fio write tests shows the reduction in cache
access.
Where the test is fio 'write,mmap,600Mb,pre_read' on AMD AthlonX2 with
3Gb memory (dirty_threshold approx 600 Mb)
running each test 10 times, taking the average & standard deviation

		average (s.d.) in millions (10^6)
2.6.31-rc6	661 (9.88)
+patch		604 (4.19)

Achieving this reduction is by dropping clip_bdi_dirty_limit as it  
rereads the counters to apply the dirty_threshold and moving this check
up into balance_dirty_pages where it has already read the counters.

Also by rearrange the for loop to only contain one copy of the limit
tests allows the pdflush test after the loop to use the local copies of
the counters rather than rereading then.

In the common case with no throttling it now calls global_page_state 5
fewer times and bdi_stat 2 fewer.

I have tried to retain the existing behavior as much as possible, but
have added NR_WRITEBACK_TEMP to nr_writeback. This counter was used in
clip_bdi_dirty_limit but not in balance_dirty_pages, grep suggests this
is only used by FUSE but I haven't done any testing on that. It does
seem logical to count all the WRITEBACK pages when making the throttling
decisions so this change should be more correct ;)

I have been running this patch for over a week and have had no problems
with it and generally see improved disk write performance on a variety
of tests & workloads, even in the worst cases performance is the same as
the unpatched kernel. I also tried this on a Intel ATOM 330 twincore
system and saw similar improvements.

    
Signed-off-by: Richard Kennedy <richard@rsk.demon.co.uk>
----
 page-writeback.c |  116 ++++++++++++++++++++-----------------------------------
 1 file changed, 43 insertions(+), 73 deletions(-)

This patch is against 2.6.31-rc6.



diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 81627eb..6f18e40 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -260,32 +260,6 @@ static void bdi_writeout_fraction(struct backing_dev_info *bdi,
 	}
 }
 
-/*
- * Clip the earned share of dirty pages to that which is actually available.
- * This avoids exceeding the total dirty_limit when the floating averages
- * fluctuate too quickly.
- */
-static void clip_bdi_dirty_limit(struct backing_dev_info *bdi,
-		unsigned long dirty, unsigned long *pbdi_dirty)
-{
-	unsigned long avail_dirty;
-
-	avail_dirty = global_page_state(NR_FILE_DIRTY) +
-		 global_page_state(NR_WRITEBACK) +
-		 global_page_state(NR_UNSTABLE_NFS) +
-		 global_page_state(NR_WRITEBACK_TEMP);
-
-	if (avail_dirty < dirty)
-		avail_dirty = dirty - avail_dirty;
-	else
-		avail_dirty = 0;
-
-	avail_dirty += bdi_stat(bdi, BDI_RECLAIMABLE) +
-		bdi_stat(bdi, BDI_WRITEBACK);
-
-	*pbdi_dirty = min(*pbdi_dirty, avail_dirty);
-}
-
 static inline void task_dirties_fraction(struct task_struct *tsk,
 		long *numerator, long *denominator)
 {
@@ -478,7 +452,6 @@ get_dirty_limits(unsigned long *pbackground, unsigned long *pdirty,
 			bdi_dirty = dirty * bdi->max_ratio / 100;
 
 		*pbdi_dirty = bdi_dirty;
-		clip_bdi_dirty_limit(bdi, dirty, pbdi_dirty);
 		task_dirty_limit(current, pbdi_dirty);
 	}
 }
@@ -512,45 +485,12 @@ static void balance_dirty_pages(struct address_space *mapping)
 		};
 
 		get_dirty_limits(&background_thresh, &dirty_thresh,
-				&bdi_thresh, bdi);
+				 &bdi_thresh, bdi);
 
 		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
-					global_page_state(NR_UNSTABLE_NFS);
-		nr_writeback = global_page_state(NR_WRITEBACK);
-
-		bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
-		bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
-
-		if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
-			break;
-
-		/*
-		 * Throttle it only when the background writeback cannot
-		 * catch-up. This avoids (excessively) small writeouts
-		 * when the bdi limits are ramping up.
-		 */
-		if (nr_reclaimable + nr_writeback <
-				(background_thresh + dirty_thresh) / 2)
-			break;
-
-		if (!bdi->dirty_exceeded)
-			bdi->dirty_exceeded = 1;
-
-		/* Note: nr_reclaimable denotes nr_dirty + nr_unstable.
-		 * Unstable writes are a feature of certain networked
-		 * filesystems (i.e. NFS) in which data may have been
-		 * written to the server's write cache, but has not yet
-		 * been flushed to permanent storage.
-		 * Only move pages to writeback if this bdi is over its
-		 * threshold otherwise wait until the disk writes catch
-		 * up.
-		 */
-		if (bdi_nr_reclaimable > bdi_thresh) {
-			writeback_inodes(&wbc);
-			pages_written += write_chunk - wbc.nr_to_write;
-			get_dirty_limits(&background_thresh, &dirty_thresh,
-				       &bdi_thresh, bdi);
-		}
+			global_page_state(NR_UNSTABLE_NFS);
+		nr_writeback = global_page_state(NR_WRITEBACK) +
+			global_page_state(NR_WRITEBACK_TEMP);
 
 		/*
 		 * In order to avoid the stacked BDI deadlock we need
@@ -570,16 +510,48 @@ static void balance_dirty_pages(struct address_space *mapping)
 			bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
 		}
 
-		if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
-			break;
-		if (pages_written >= write_chunk)
-			break;		/* We've done our duty */
+		/* always throttle if over threshold */
+		if (nr_reclaimable + nr_writeback < dirty_thresh) {
+
+			if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
+				break;
+
+			/*
+			 * Throttle it only when the background writeback cannot
+			 * catch-up. This avoids (excessively) small writeouts
+			 * when the bdi limits are ramping up.
+			 */
+			if (nr_reclaimable + nr_writeback <
+			    (background_thresh + dirty_thresh) / 2)
+				break;
+
+			/* done enough? */
+			if (pages_written >= write_chunk)
+				break;
+		}
+		if (!bdi->dirty_exceeded)
+			bdi->dirty_exceeded = 1;
 
+		/* Note: nr_reclaimable denotes nr_dirty + nr_unstable.
+		 * Unstable writes are a feature of certain networked
+		 * filesystems (i.e. NFS) in which data may have been
+		 * written to the server's write cache, but has not yet
+		 * been flushed to permanent storage.
+		 * Only move pages to writeback if this bdi is over its
+		 * threshold otherwise wait until the disk writes catch
+		 * up.
+		 */
+		if (bdi_nr_reclaimable > bdi_thresh) {
+			writeback_inodes(&wbc);
+			pages_written += write_chunk - wbc.nr_to_write;
+			if (wbc.nr_to_write == 0)
+				continue;
+		}
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
 	}
 
 	if (bdi_nr_reclaimable + bdi_nr_writeback < bdi_thresh &&
-			bdi->dirty_exceeded)
+	    bdi->dirty_exceeded)
 		bdi->dirty_exceeded = 0;
 
 	if (writeback_in_progress(bdi))
@@ -593,10 +565,8 @@ static void balance_dirty_pages(struct address_space *mapping)
 	 * In normal mode, we start background writeout at the lower
 	 * background_thresh, to keep the amount of dirty memory low.
 	 */
-	if ((laptop_mode && pages_written) ||
-			(!laptop_mode && (global_page_state(NR_FILE_DIRTY)
-					  + global_page_state(NR_UNSTABLE_NFS)
-					  > background_thresh)))
+	if ((laptop_mode && pages_written) || (!laptop_mode &&
+	     (nr_reclaimable > background_thresh)))
 		pdflush_operation(background_writeout, 0);
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
