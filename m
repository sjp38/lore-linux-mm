From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 04/11] readahead: introduce {MAX|MIN}_READAHEAD_PAGES macros for ease of use
Date: Sun, 07 Feb 2010 12:10:17 +0800
Message-ID: <20100207041043.286260529@intel.com>
References: <20100207041013.891441102@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1NdyXr-0000mS-3Z
	for glkm-linux-mm-2@m.gmane.org; Sun, 07 Feb 2010 05:14:51 +0100
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2B19D62000F
	for <linux-mm@kvack.org>; Sat,  6 Feb 2010 23:14:18 -0500 (EST)
Content-Disposition: inline; filename=readahead-min-max-pages.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Wu Fengguang <fengguang.wu@intel.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 block/blk-core.c   |    3 +--
 fs/fuse/inode.c    |    2 +-
 include/linux/mm.h |    3 +++
 mm/backing-dev.c   |    2 +-
 4 files changed, 6 insertions(+), 4 deletions(-)

--- linux.orig/block/blk-core.c	2010-01-30 17:38:48.000000000 +0800
+++ linux/block/blk-core.c	2010-01-30 18:10:01.000000000 +0800
@@ -498,8 +498,7 @@ struct request_queue *blk_alloc_queue_no
 
 	q->backing_dev_info.unplug_io_fn = blk_backing_dev_unplug;
 	q->backing_dev_info.unplug_io_data = q;
-	q->backing_dev_info.ra_pages =
-			(VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
+	q->backing_dev_info.ra_pages = MAX_READAHEAD_PAGES;
 	q->backing_dev_info.state = 0;
 	q->backing_dev_info.capabilities = BDI_CAP_MAP_COPY;
 	q->backing_dev_info.name = "block";
--- linux.orig/fs/fuse/inode.c	2010-01-30 17:38:48.000000000 +0800
+++ linux/fs/fuse/inode.c	2010-01-30 18:10:01.000000000 +0800
@@ -870,7 +870,7 @@ static int fuse_bdi_init(struct fuse_con
 	int err;
 
 	fc->bdi.name = "fuse";
-	fc->bdi.ra_pages = (VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
+	fc->bdi.ra_pages = MAX_READAHEAD_PAGES;
 	fc->bdi.unplug_io_fn = default_unplug_io_fn;
 	/* fuse does it's own writeback accounting */
 	fc->bdi.capabilities = BDI_CAP_NO_ACCT_WB;
--- linux.orig/include/linux/mm.h	2010-01-30 18:09:58.000000000 +0800
+++ linux/include/linux/mm.h	2010-01-30 18:10:01.000000000 +0800
@@ -1187,6 +1187,9 @@ void task_dirty_inc(struct task_struct *
 #define VM_MAX_READAHEAD	512	/* kbytes */
 #define VM_MIN_READAHEAD	32	/* kbytes (includes current page) */
 
+#define MAX_READAHEAD_PAGES (VM_MAX_READAHEAD*1024 / PAGE_CACHE_SIZE)
+#define MIN_READAHEAD_PAGES DIV_ROUND_UP(VM_MIN_READAHEAD*1024, PAGE_CACHE_SIZE)
+
 int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
 			pgoff_t offset, unsigned long nr_to_read);
 
--- linux.orig/mm/backing-dev.c	2010-01-30 17:38:48.000000000 +0800
+++ linux/mm/backing-dev.c	2010-01-30 18:10:01.000000000 +0800
@@ -18,7 +18,7 @@ EXPORT_SYMBOL(default_unplug_io_fn);
 
 struct backing_dev_info default_backing_dev_info = {
 	.name		= "default",
-	.ra_pages	= VM_MAX_READAHEAD * 1024 / PAGE_CACHE_SIZE,
+	.ra_pages	= MAX_READAHEAD_PAGES,
 	.state		= 0,
 	.capabilities	= BDI_CAP_MAP_COPY,
 	.unplug_io_fn	= default_unplug_io_fn,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
