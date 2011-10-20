Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D03776B002C
	for <linux-mm@kvack.org>; Thu, 20 Oct 2011 12:00:09 -0400 (EDT)
Date: Thu, 20 Oct 2011 23:56:42 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 2/2] nfs: scale writeback threshold proportional to dirty
 threshold
Message-ID: <20111020155642.GB7054@localhost>
References: <20111020155542.GA7054@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111020155542.GA7054@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Tang Feng <feng.tang@intel.com>

nfs_congestion_kb is to control the max allowed writeback and in-commit
pages. It's not reasonable for them to outnumber dirty and to-commit
pages. So each of them should not take more than 1/4 dirty threshold.

Considering that nfs_init_writepagecache() is called on fresh boot,
at the time dirty_thresh is much higher than the real dirty limit after
lots of user space memory consumptions, use 1/8 instead.

Feng: fix deadlock by preventing (nfs_congestion_kb == 0)

CC: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Feng Tang <feng.tang@intel.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/nfs/write.c      |   36 +++++++++++++++++-------------------
 mm/page-writeback.c |    6 ++++++
 2 files changed, 23 insertions(+), 19 deletions(-)

--- linux-next.orig/fs/nfs/write.c	2011-10-20 23:45:59.000000000 +0800
+++ linux-next/fs/nfs/write.c	2011-10-20 23:53:16.000000000 +0800
@@ -1782,6 +1782,22 @@ out:
 }
 #endif
 
+void nfs_update_congestion_thresh(void)
+{
+	unsigned long background_thresh;
+	unsigned long dirty_thresh;
+
+	/*
+	 * Limit to 1/8 dirty threshold, so that writeback+in_commit pages
+	 * won't overnumber dirty+to_commit pages.
+	 */
+	global_dirty_limits(&background_thresh, &dirty_thresh);
+	dirty_thresh <<= PAGE_SHIFT - 10;
+	dirty_thresh += 1024;
+
+	nfs_congestion_kb = dirty_thresh / 8;
+}
+
 int __init nfs_init_writepagecache(void)
 {
 	nfs_wdata_cachep = kmem_cache_create("nfs_write_data",
@@ -1801,25 +1817,7 @@ int __init nfs_init_writepagecache(void)
 	if (nfs_commit_mempool == NULL)
 		return -ENOMEM;
 
-	/*
-	 * NFS congestion size, scale with available memory.
-	 *
-	 *  64MB:    8192k
-	 * 128MB:   11585k
-	 * 256MB:   16384k
-	 * 512MB:   23170k
-	 *   1GB:   32768k
-	 *   2GB:   46340k
-	 *   4GB:   65536k
-	 *   8GB:   92681k
-	 *  16GB:  131072k
-	 *
-	 * This allows larger machines to have larger/more transfers.
-	 * Limit the default to 256M
-	 */
-	nfs_congestion_kb = (16*int_sqrt(totalram_pages)) << (PAGE_SHIFT-10);
-	if (nfs_congestion_kb > 256*1024)
-		nfs_congestion_kb = 256*1024;
+	nfs_update_congestion_thresh();
 
 	return 0;
 }
--- linux-next.orig/mm/page-writeback.c	2011-10-20 23:45:23.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-10-20 23:48:07.000000000 +0800
@@ -207,6 +207,10 @@ static int calc_period_shift(void)
 	return 2 + ilog2(dirty_total - 1);
 }
 
+void __weak nfs_update_congestion_thresh(void)
+{
+}
+
 /*
  * update the period when the dirty threshold changes.
  */
@@ -217,6 +221,7 @@ static void update_completion_period(voi
 	prop_change_shift(&vm_dirties, shift);
 
 	writeback_set_ratelimit();
+	nfs_update_congestion_thresh();
 }
 
 int dirty_background_ratio_handler(struct ctl_table *table, int write,
@@ -447,6 +452,7 @@ unsigned long bdi_dirty_limit(struct bac
 
 	return bdi_dirty;
 }
+EXPORT_SYMBOL_GPL(global_dirty_limits);
 
 /*
  * Dirty position control.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
