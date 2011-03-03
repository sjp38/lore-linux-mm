Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5A6E38D0040
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 03:17:57 -0500 (EST)
Message-Id: <20110303074950.430258205@intel.com>
Date: Thu, 03 Mar 2011 14:45:19 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 14/27] writeback: account per-bdi accumulated dirtied pages
References: <20110303064505.718671603@intel.com>
Content-Disposition: inline; filename=writeback-bdi-dirtied.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Michael Rubin <mrubin@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Introduce the BDI_DIRTIED counter. It will be used for estimating the
bdi's dirty bandwidth.

CC: Jan Kara <jack@suse.cz>
CC: Michael Rubin <mrubin@google.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/backing-dev.h |    1 +
 mm/backing-dev.c            |    2 ++
 mm/page-writeback.c         |    1 +
 3 files changed, 4 insertions(+)

--- linux-next.orig/include/linux/backing-dev.h	2011-03-03 14:44:16.000000000 +0800
+++ linux-next/include/linux/backing-dev.h	2011-03-03 14:44:18.000000000 +0800
@@ -40,6 +40,7 @@ typedef int (congested_fn)(void *, int);
 enum bdi_stat_item {
 	BDI_RECLAIMABLE,
 	BDI_WRITEBACK,
+	BDI_DIRTIED,
 	BDI_WRITTEN,
 	NR_BDI_STAT_ITEMS
 };
--- linux-next.orig/mm/page-writeback.c	2011-03-03 14:44:16.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-03-03 14:44:18.000000000 +0800
@@ -1127,6 +1127,7 @@ void account_page_dirtied(struct page *p
 		__inc_zone_page_state(page, NR_FILE_DIRTY);
 		__inc_zone_page_state(page, NR_DIRTIED);
 		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
+		__inc_bdi_stat(mapping->backing_dev_info, BDI_DIRTIED);
 		task_dirty_inc(current);
 		task_io_account_write(PAGE_CACHE_SIZE);
 	}
--- linux-next.orig/mm/backing-dev.c	2011-03-03 14:44:16.000000000 +0800
+++ linux-next/mm/backing-dev.c	2011-03-03 14:44:18.000000000 +0800
@@ -92,6 +92,7 @@ static int bdi_debug_stats_show(struct s
 		   "BdiDirtyThresh:   %8lu kB\n"
 		   "DirtyThresh:      %8lu kB\n"
 		   "BackgroundThresh: %8lu kB\n"
+		   "BdiDirtied:       %8lu kB\n"
 		   "BdiWritten:       %8lu kB\n"
 		   "b_dirty:          %8lu\n"
 		   "b_io:             %8lu\n"
@@ -101,6 +102,7 @@ static int bdi_debug_stats_show(struct s
 		   (unsigned long) K(bdi_stat(bdi, BDI_WRITEBACK)),
 		   (unsigned long) K(bdi_stat(bdi, BDI_RECLAIMABLE)),
 		   K(bdi_thresh), K(dirty_thresh), K(background_thresh),
+		   (unsigned long) K(bdi_stat(bdi, BDI_DIRTIED)),
 		   (unsigned long) K(bdi_stat(bdi, BDI_WRITTEN)),
 		   nr_dirty, nr_io, nr_more_io,
 		   !list_empty(&bdi->bdi_list), bdi->state);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
