Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6167A9000D4
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 09:45:56 -0400 (EDT)
Message-Id: <20111003134536.209467893@intel.com>
Date: Mon, 03 Oct 2011 21:42:29 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 01/11] writeback: account per-bdi accumulated dirtied pages
References: <20111003134228.090592370@intel.com>
Content-Disposition: inline; filename=writeback-bdi-dirtied.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Jan Kara <jack@suse.cz>, Michael Rubin <mrubin@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

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

--- linux-next.orig/include/linux/backing-dev.h	2011-10-03 21:05:32.000000000 +0800
+++ linux-next/include/linux/backing-dev.h	2011-10-03 21:05:33.000000000 +0800
@@ -40,6 +40,7 @@ typedef int (congested_fn)(void *, int);
 enum bdi_stat_item {
 	BDI_RECLAIMABLE,
 	BDI_WRITEBACK,
+	BDI_DIRTIED,
 	BDI_WRITTEN,
 	NR_BDI_STAT_ITEMS
 };
--- linux-next.orig/mm/page-writeback.c	2011-10-03 21:05:32.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-10-03 21:05:33.000000000 +0800
@@ -1322,6 +1322,7 @@ void account_page_dirtied(struct page *p
 		__inc_zone_page_state(page, NR_FILE_DIRTY);
 		__inc_zone_page_state(page, NR_DIRTIED);
 		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
+		__inc_bdi_stat(mapping->backing_dev_info, BDI_DIRTIED);
 		task_dirty_inc(current);
 		task_io_account_write(PAGE_CACHE_SIZE);
 	}
--- linux-next.orig/mm/backing-dev.c	2011-10-03 21:05:32.000000000 +0800
+++ linux-next/mm/backing-dev.c	2011-10-03 21:05:33.000000000 +0800
@@ -97,6 +97,7 @@ static int bdi_debug_stats_show(struct s
 		   "BdiDirtyThresh:     %10lu kB\n"
 		   "DirtyThresh:        %10lu kB\n"
 		   "BackgroundThresh:   %10lu kB\n"
+		   "BdiDirtied:         %10lu kB\n"
 		   "BdiWritten:         %10lu kB\n"
 		   "BdiWriteBandwidth:  %10lu kBps\n"
 		   "b_dirty:            %10lu\n"
@@ -109,6 +110,7 @@ static int bdi_debug_stats_show(struct s
 		   K(bdi_thresh),
 		   K(dirty_thresh),
 		   K(background_thresh),
+		   (unsigned long) K(bdi_stat(bdi, BDI_DIRTIED)),
 		   (unsigned long) K(bdi_stat(bdi, BDI_WRITTEN)),
 		   (unsigned long) K(bdi->write_bandwidth),
 		   nr_dirty,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
