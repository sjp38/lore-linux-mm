Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 93B096B0089
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 18:19:39 -0500 (EST)
Message-Id: <20101108231727.139062518@intel.com>
Date: Tue, 09 Nov 2010 07:09:20 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 4/5] writeback: avoid livelocking WB_SYNC_ALL writeback
References: <20101108230916.826791396@intel.com>
Content-Disposition: inline; filename=mutt-wfg-t61-1000-14567-7029f8c2a01ad3a473
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Jan Engelhardt <jengelh@medozas.de>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

From: Jan Kara <jack@suse.cz>

When wb_writeback() is called in WB_SYNC_ALL mode, work->nr_to_write is
usually set to LONG_MAX. The logic in wb_writeback() then calls
__writeback_inodes_sb() with nr_to_write == MAX_WRITEBACK_PAGES and thus
we easily end up with negative nr_to_write after the function returns.
wb_writeback() then decides we need another round of writeback but this
is wrong in some cases! For example when a single large file is
continuously dirtied, we would never finish syncing it because each pass
would be able to write MAX_WRITEBACK_PAGES and inode dirty timestamp
never gets updated (as inode is never completely clean).

Fix the issue by setting nr_to_write to LONG_MAX in WB_SYNC_ALL mode. We
do not need nr_to_write in WB_SYNC_ALL mode anyway since livelock
avoidance is done differently for it.

After this patch, program from http://lkml.org/lkml/2010/10/24/154 is no
longer able to stall sync forever.

Signed-off-by: Jan Kara <jack@suse.cz>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |   27 +++++++++++++++++++++++----
 1 file changed, 23 insertions(+), 4 deletions(-)

  Fengguang, I've been testing with those writeback fixes you reposted
a few days ago and I've been able to still reproduce livelocks with
Jan Engelhard's test case. Using writeback tracing I've tracked the
problem to the above and with this patch, sync finishes OK (well, it still
takes about 15 minutes but that's about expected time given the throughput
I see to the disk - the test case randomly dirties pages in a huge file).
So could you please add this patch to the previous two send them to Jens
for inclusion?

--- linux-next.orig/fs/fs-writeback.c	2010-11-07 22:00:51.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-11-07 22:01:06.000000000 +0800
@@ -630,6 +630,7 @@ static long wb_writeback(struct bdi_writ
 	};
 	unsigned long oldest_jif;
 	long wrote = 0;
+	long write_chunk;
 	struct inode *inode;
 
 	if (wbc.for_kupdate) {
@@ -642,6 +643,24 @@ static long wb_writeback(struct bdi_writ
 		wbc.range_end = LLONG_MAX;
 	}
 
+	/*
+	 * WB_SYNC_ALL mode does livelock avoidance by syncing dirty
+	 * inodes/pages in one big loop. Setting wbc.nr_to_write=LONG_MAX
+	 * here avoids calling into writeback_inodes_wb() more than once.
+	 *
+	 * The intended call sequence for WB_SYNC_ALL writeback is:
+	 *
+	 *      wb_writeback()
+	 *          writeback_inodes_wb()       <== called only once
+	 *              write_cache_pages()     <== called once for each inode
+	 *                   (quickly) tag currently dirty pages
+	 *                   (maybe slowly) sync all tagged pages
+	 */
+	if (wbc.sync_mode == WB_SYNC_NONE)
+		write_chunk = MAX_WRITEBACK_PAGES;
+	else
+		write_chunk = LONG_MAX;
+
 	wbc.wb_start = jiffies; /* livelock avoidance */
 	for (;;) {
 		/*
@@ -667,7 +686,7 @@ static long wb_writeback(struct bdi_writ
 			break;
 
 		wbc.more_io = 0;
-		wbc.nr_to_write = MAX_WRITEBACK_PAGES;
+		wbc.nr_to_write = write_chunk;
 		wbc.pages_skipped = 0;
 
 		trace_wbc_writeback_start(&wbc, wb->bdi);
@@ -677,8 +696,8 @@ static long wb_writeback(struct bdi_writ
 			writeback_inodes_wb(wb, &wbc);
 		trace_wbc_writeback_written(&wbc, wb->bdi);
 
-		work->nr_pages -= MAX_WRITEBACK_PAGES - wbc.nr_to_write;
-		wrote += MAX_WRITEBACK_PAGES - wbc.nr_to_write;
+		work->nr_pages -= write_chunk - wbc.nr_to_write;
+		wrote += write_chunk - wbc.nr_to_write;
 
 		/*
 		 * If we consumed everything, see if we have more
@@ -693,7 +712,7 @@ static long wb_writeback(struct bdi_writ
 		/*
 		 * Did we write something? Try for more
 		 */
-		if (wbc.nr_to_write < MAX_WRITEBACK_PAGES)
+		if (wbc.nr_to_write < write_chunk)
 			continue;
 		/*
 		 * Nothing written. Wait for some inode to


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
