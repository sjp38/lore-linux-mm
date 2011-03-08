Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5D60F8D0040
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 17:31:30 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 1/5] writeback: account per-bdi accumulated written pages
Date: Tue,  8 Mar 2011 23:31:11 +0100
Message-Id: <1299623475-5512-2-git-send-email-jack@suse.cz>
In-Reply-To: <1299623475-5512-1-git-send-email-jack@suse.cz>
References: <1299623475-5512-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>

Introduce the BDI_WRITTEN counter. It will be used for waking up
waiters in balance_dirty_pages().

Peter Zijlstra <a.p.zijlstra@chello.nl>:
Move BDI_WRITTEN accounting into __bdi_writeout_inc().
This will cover and fix fuse, which only calls bdi_writeout_inc().

CC: Andrew Morton <akpm@linux-foundation.org>
CC: Christoph Hellwig <hch@infradead.org>
CC: Dave Chinner <david@fromorbit.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Jan Kara <jack@suse.cz>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/backing-dev.h |    1 +
 mm/backing-dev.c            |    6 ++++--
 mm/page-writeback.c         |    1 +
 3 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 4ce34fa..63ab4a5 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -40,6 +40,7 @@ typedef int (congested_fn)(void *, int);
 enum bdi_stat_item {
 	BDI_RECLAIMABLE,
 	BDI_WRITEBACK,
+	BDI_WRITTEN,
 	NR_BDI_STAT_ITEMS
 };
 
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 027100d..4d14072 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -92,6 +92,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   "BdiDirtyThresh:   %8lu kB\n"
 		   "DirtyThresh:      %8lu kB\n"
 		   "BackgroundThresh: %8lu kB\n"
+		   "BdiWritten:       %8lu kB\n"
 		   "b_dirty:          %8lu\n"
 		   "b_io:             %8lu\n"
 		   "b_more_io:        %8lu\n"
@@ -99,8 +100,9 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   "state:            %8lx\n",
 		   (unsigned long) K(bdi_stat(bdi, BDI_WRITEBACK)),
 		   (unsigned long) K(bdi_stat(bdi, BDI_RECLAIMABLE)),
-		   K(bdi_thresh), K(dirty_thresh),
-		   K(background_thresh), nr_dirty, nr_io, nr_more_io,
+		   K(bdi_thresh), K(dirty_thresh), K(background_thresh),
+		   (unsigned long) K(bdi_stat(bdi, BDI_WRITTEN)),
+		   nr_dirty, nr_io, nr_more_io,
 		   !list_empty(&bdi->bdi_list), bdi->state);
 #undef K
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 2cb01f6..c472c1c 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -219,6 +219,7 @@ int dirty_bytes_handler(struct ctl_table *table, int write,
  */
 static inline void __bdi_writeout_inc(struct backing_dev_info *bdi)
 {
+	__inc_bdi_stat(bdi, BDI_WRITTEN);
 	__prop_inc_percpu_max(&vm_completions, &bdi->completions,
 			      bdi->max_prop_frac);
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
