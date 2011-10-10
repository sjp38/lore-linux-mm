Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BCA1D6B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 09:12:01 -0400 (EDT)
Date: Mon, 10 Oct 2011 21:11:54 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [RFC][PATCH 2/2] nfs: scale writeback threshold proportional to
 dirty threshold
Message-ID: <20111010131154.GB16847@localhost>
References: <20111003134228.090592370@intel.com>
 <1318248846.14400.21.camel@laptop>
 <20111010130722.GA11387@localhost>
 <20111010131051.GA16847@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111010131051.GA16847@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

nfs_congestion_kb is to control the max allowed writeback and in-commit
pages. It's not reasonable for them to outnumber dirty and to-commit
pages. So each of them should not take more than 1/4 dirty threshold.

Considering that nfs_init_writepagecache() is called on fresh boot,
at the time dirty_thresh is much higher than the real dirty limit after
lots of user space memory consumptions, use 1/8 instead.

We might update nfs_congestion_kb when global dirty limit is changed
at runtime, but whatever, do it simple first.

CC: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/nfs/write.c      |   52 ++++++++++++++++++++++++++++--------------
 mm/page-writeback.c |    6 ++++
 2 files changed, 41 insertions(+), 17 deletions(-)

--- linux-next.orig/fs/nfs/write.c	2011-10-09 21:36:22.000000000 +0800
+++ linux-next/fs/nfs/write.c	2011-10-10 21:05:07.000000000 +0800
@@ -1775,61 +1775,79 @@ int nfs_migrate_page(struct address_spac
 	set_page_private(newpage, (unsigned long)req);
 	ClearPagePrivate(page);
 	set_page_private(page, 0);
 	spin_unlock(&mapping->host->i_lock);
 	page_cache_release(page);
 out_unlock:
 	nfs_clear_page_tag_locked(req);
 out:
 	return ret;
 }
 #endif
 
-int __init nfs_init_writepagecache(void)
+void nfs_update_congestion_thresh(void)
 {
-	nfs_wdata_cachep = kmem_cache_create("nfs_write_data",
-					     sizeof(struct nfs_write_data),
-					     0, SLAB_HWCACHE_ALIGN,
-					     NULL);
-	if (nfs_wdata_cachep == NULL)
-		return -ENOMEM;
-
-	nfs_wdata_mempool = mempool_create_slab_pool(MIN_POOL_WRITE,
-						     nfs_wdata_cachep);
-	if (nfs_wdata_mempool == NULL)
-		return -ENOMEM;
-
-	nfs_commit_mempool = mempool_create_slab_pool(MIN_POOL_COMMIT,
-						      nfs_wdata_cachep);
-	if (nfs_commit_mempool == NULL)
-		return -ENOMEM;
+	unsigned long background_thresh;
+	unsigned long dirty_thresh;
 
 	/*
 	 * NFS congestion size, scale with available memory.
 	 *
 	 *  64MB:    8192k
 	 * 128MB:   11585k
 	 * 256MB:   16384k
 	 * 512MB:   23170k
 	 *   1GB:   32768k
 	 *   2GB:   46340k
 	 *   4GB:   65536k
 	 *   8GB:   92681k
 	 *  16GB:  131072k
 	 *
 	 * This allows larger machines to have larger/more transfers.
 	 * Limit the default to 256M
 	 */
 	nfs_congestion_kb = (16*int_sqrt(totalram_pages)) << (PAGE_SHIFT-10);
 	if (nfs_congestion_kb > 256*1024)
 		nfs_congestion_kb = 256*1024;
 
+	/*
+	 * Limit to 1/8 dirty threshold, so that writeback+in_commit pages
+	 * won't overnumber dirty+to_commit pages.
+	 */
+	global_dirty_limits(&background_thresh, &dirty_thresh);
+	dirty_thresh <<= PAGE_SHIFT - 10;
+
+	if (nfs_congestion_kb > dirty_thresh / 8)
+		nfs_congestion_kb = dirty_thresh / 8;
+}
+
+int __init nfs_init_writepagecache(void)
+{
+	nfs_wdata_cachep = kmem_cache_create("nfs_write_data",
+					     sizeof(struct nfs_write_data),
+					     0, SLAB_HWCACHE_ALIGN,
+					     NULL);
+	if (nfs_wdata_cachep == NULL)
+		return -ENOMEM;
+
+	nfs_wdata_mempool = mempool_create_slab_pool(MIN_POOL_WRITE,
+						     nfs_wdata_cachep);
+	if (nfs_wdata_mempool == NULL)
+		return -ENOMEM;
+
+	nfs_commit_mempool = mempool_create_slab_pool(MIN_POOL_COMMIT,
+						      nfs_wdata_cachep);
+	if (nfs_commit_mempool == NULL)
+		return -ENOMEM;
+
+	nfs_update_congestion_thresh();
+
 	return 0;
 }
 
 void nfs_destroy_writepagecache(void)
 {
 	mempool_destroy(nfs_commit_mempool);
 	mempool_destroy(nfs_wdata_mempool);
 	kmem_cache_destroy(nfs_wdata_cachep);
 }
 
--- linux-next.orig/mm/page-writeback.c	2011-10-09 21:36:06.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-10-10 21:05:07.000000000 +0800
@@ -138,34 +138,39 @@ static struct prop_descriptor vm_dirties
 static int calc_period_shift(void)
 {
 	unsigned long dirty_total;
 
 	if (vm_dirty_bytes)
 		dirty_total = vm_dirty_bytes / PAGE_SIZE;
 	else
 		dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) /
 				100;
 	return 2 + ilog2(dirty_total - 1);
 }
 
+void __weak nfs_update_congestion_thresh(void)
+{
+}
+
 /*
  * update the period when the dirty threshold changes.
  */
 static void update_completion_period(void)
 {
 	int shift = calc_period_shift();
 	prop_change_shift(&vm_completions, shift);
 	prop_change_shift(&vm_dirties, shift);
 
 	writeback_set_ratelimit();
+	nfs_update_congestion_thresh();
 }
 
 int dirty_background_ratio_handler(struct ctl_table *table, int write,
 		void __user *buffer, size_t *lenp,
 		loff_t *ppos)
 {
 	int ret;
 
 	ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
 	if (ret == 0 && write)
 		dirty_background_bytes = 0;
 	return ret;
@@ -438,24 +443,25 @@ unsigned long bdi_dirty_limit(struct bac
 	bdi_writeout_fraction(bdi, &numerator, &denominator);
 
 	bdi_dirty = (dirty * (100 - bdi_min_ratio)) / 100;
 	bdi_dirty *= numerator;
 	do_div(bdi_dirty, denominator);
 
 	bdi_dirty += (dirty * bdi->min_ratio) / 100;
 	if (bdi_dirty > (dirty * bdi->max_ratio) / 100)
 		bdi_dirty = dirty * bdi->max_ratio / 100;
 
 	return bdi_dirty;
 }
+EXPORT_SYMBOL_GPL(global_dirty_limits);
 
 /*
  * Dirty position control.
  *
  * (o) global/bdi setpoints
  *
  * We want the dirty pages be balanced around the global/bdi setpoints.
  * When the number of dirty pages is higher/lower than the setpoint, the
  * dirty position control ratio (and hence task dirty ratelimit) will be
  * decreased/increased to bring the dirty pages back to the setpoint.
  *
  *     pos_ratio = 1 << RATELIMIT_CALC_SHIFT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
