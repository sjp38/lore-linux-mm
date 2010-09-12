Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A1CB36B0092
	for <linux-mm@kvack.org>; Sun, 12 Sep 2010 11:55:02 -0400 (EDT)
Message-Id: <20100912155204.121142951@intel.com>
Date: Sun, 12 Sep 2010 23:49:55 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 10/17] writeback: show bdi write bandwidth in debugfs
References: <20100912154945.758129106@intel.com>
Content-Disposition: inline; filename=writeback-bandwidth-show.patch
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Theodore Tso <tytso@mit.edu>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Li Shaohua <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

Add a "BdiWriteBandwidth" entry (and indent others) in /debug/bdi/*/stats.

btw increase digital field width to 10, for keeping the possibly
huge BdiWritten number aligned at least for desktop systems.

This will break user space tools if they are dumb enough to depend on
the number of white spaces.

CC: Theodore Ts'o <tytso@mit.edu>
CC: Jan Kara <jack@suse.cz>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/backing-dev.c |   24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

--- linux-next.orig/mm/backing-dev.c	2010-09-11 08:42:31.000000000 +0800
+++ linux-next/mm/backing-dev.c	2010-09-12 11:13:49.000000000 +0800
@@ -86,21 +86,23 @@ static int bdi_debug_stats_show(struct s
 
 #define K(x) ((x) << (PAGE_SHIFT - 10))
 	seq_printf(m,
-		   "BdiWriteback:     %8lu kB\n"
-		   "BdiReclaimable:   %8lu kB\n"
-		   "BdiDirtyThresh:   %8lu kB\n"
-		   "DirtyThresh:      %8lu kB\n"
-		   "BackgroundThresh: %8lu kB\n"
-		   "BdiWritten:       %8lu kB\n"
-		   "b_dirty:          %8lu\n"
-		   "b_io:             %8lu\n"
-		   "b_more_io:        %8lu\n"
-		   "bdi_list:         %8u\n"
-		   "state:            %8lx\n",
+		   "BdiWriteback:       %10lu kB\n"
+		   "BdiReclaimable:     %10lu kB\n"
+		   "BdiDirtyThresh:     %10lu kB\n"
+		   "DirtyThresh:        %10lu kB\n"
+		   "BackgroundThresh:   %10lu kB\n"
+		   "BdiWritten:         %10lu kB\n"
+		   "BdiWriteBandwidth:  %10lu kBps\n"
+		   "b_dirty:            %10lu\n"
+		   "b_io:               %10lu\n"
+		   "b_more_io:          %10lu\n"
+		   "bdi_list:           %10u\n"
+		   "state:              %10lx\n",
 		   (unsigned long) K(bdi_stat(bdi, BDI_WRITEBACK)),
 		   (unsigned long) K(bdi_stat(bdi, BDI_RECLAIMABLE)),
 		   K(bdi_thresh), K(dirty_thresh), K(background_thresh),
 		   (unsigned long) K(bdi_stat(bdi, BDI_WRITTEN)),
+		   (unsigned long) bdi->write_bandwidth >> 10,
 		   nr_dirty, nr_io, nr_more_io,
 		   !list_empty(&bdi->bdi_list), bdi->state);
 #undef K


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
