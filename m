Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8F1008D003A
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 03:21:01 -0500 (EST)
Message-Id: <20110303074950.306247535@intel.com>
Date: Thu, 03 Mar 2011 14:45:18 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 13/27] writeback: account per-bdi accumulated written pages
References: <20110303064505.718671603@intel.com>
Content-Disposition: inline; filename=writeback-bdi-written.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Michael Rubin <mrubin@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

From: Jan Kara <jack@suse.cz>

Introduce the BDI_WRITTEN counter. It will be used for estimating the
bdi's write bandwidth.

Peter Zijlstra <a.p.zijlstra@chello.nl>:
Move BDI_WRITTEN accounting into __bdi_writeout_inc().
This will cover and fix fuse, which only calls bdi_writeout_inc().

CC: Michael Rubin <mrubin@google.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Jan Kara <jack@suse.cz>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/backing-dev.h |    1 +
 mm/backing-dev.c            |    6 ++++--
 mm/page-writeback.c         |    1 +
 3 files changed, 6 insertions(+), 2 deletions(-)

--- linux-next.orig/include/linux/backing-dev.h	2011-03-03 14:03:37.000000000 +0800
+++ linux-next/include/linux/backing-dev.h	2011-03-03 14:04:06.000000000 +0800
@@ -40,6 +40,7 @@ typedef int (congested_fn)(void *, int);
 enum bdi_stat_item {
 	BDI_RECLAIMABLE,
 	BDI_WRITEBACK,
+	BDI_WRITTEN,
 	NR_BDI_STAT_ITEMS
 };
 
--- linux-next.orig/mm/backing-dev.c	2011-03-03 14:03:37.000000000 +0800
+++ linux-next/mm/backing-dev.c	2011-03-03 14:04:06.000000000 +0800
@@ -92,6 +92,7 @@ static int bdi_debug_stats_show(struct s
 		   "BdiDirtyThresh:   %8lu kB\n"
 		   "DirtyThresh:      %8lu kB\n"
 		   "BackgroundThresh: %8lu kB\n"
+		   "BdiWritten:       %8lu kB\n"
 		   "b_dirty:          %8lu\n"
 		   "b_io:             %8lu\n"
 		   "b_more_io:        %8lu\n"
@@ -99,8 +100,9 @@ static int bdi_debug_stats_show(struct s
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
 
--- linux-next.orig/mm/page-writeback.c	2011-03-03 14:04:01.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-03-03 14:04:06.000000000 +0800
@@ -219,6 +219,7 @@ int dirty_bytes_handler(struct ctl_table
  */
 static inline void __bdi_writeout_inc(struct backing_dev_info *bdi)
 {
+	__inc_bdi_stat(bdi, BDI_WRITTEN);
 	__prop_inc_percpu_max(&vm_completions, &bdi->completions,
 			      bdi->max_prop_frac);
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
