From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 04/16] readahead: make default readahead size a kernel parameter
Date: Mon, 01 Mar 2010 13:26:55 +0800
Message-ID: <20100301053620.823064620@intel.com>
References: <20100301052651.857984880@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1NlyLN-0005IQ-K0
	for glkm-linux-mm-2@m.gmane.org; Mon, 01 Mar 2010 06:39:01 +0100
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 09D4B6B008C
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 00:38:57 -0500 (EST)
Content-Disposition: inline; filename=readahead-kernel-parameter.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Ankit Jain <radical@gmail.com>, Dave Chinner <david@fromorbit.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Nikanth Karthikesan <knikanth@suse.de>, Wu Fengguang <fengguang.wu@intel.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Vivek Goyal <vgoyal@redhat.com>, Matt Mackall <mpm@selenic.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

From: Nikanth Karthikesan <knikanth@suse.de>

Add new kernel parameter "readahead=", which allows user to override
the static VM_MAX_READAHEAD=512kb.

CC: Ankit Jain <radical@gmail.com>
CC: Dave Chinner <david@fromorbit.com>
CC: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 Documentation/kernel-parameters.txt |    4 ++++
 block/blk-core.c                    |    3 +--
 fs/fuse/inode.c                     |    2 +-
 mm/readahead.c                      |   22 ++++++++++++++++++++++
 4 files changed, 28 insertions(+), 3 deletions(-)

--- linux.orig/Documentation/kernel-parameters.txt	2010-02-24 10:44:26.000000000 +0800
+++ linux/Documentation/kernel-parameters.txt	2010-02-24 10:44:42.000000000 +0800
@@ -2200,6 +2200,10 @@ and is between 256 and 4096 characters. 
 			Run specified binary instead of /init from the ramdisk,
 			used for early userspace startup. See initrd.
 
+	readahead=nn[KM]
+			Default max readahead size for block devices.
+			Range: 0; 4k - 128m
+
 	reboot=		[BUGS=X86-32,BUGS=ARM,BUGS=IA-64] Rebooting mode
 			Format: <reboot_mode>[,<reboot_mode2>[,...]]
 			See arch/*/kernel/reboot.c or arch/*/kernel/process.c
--- linux.orig/block/blk-core.c	2010-02-24 10:44:26.000000000 +0800
+++ linux/block/blk-core.c	2010-02-24 10:44:42.000000000 +0800
@@ -498,8 +498,7 @@ struct request_queue *blk_alloc_queue_no
 
 	q->backing_dev_info.unplug_io_fn = blk_backing_dev_unplug;
 	q->backing_dev_info.unplug_io_data = q;
-	q->backing_dev_info.ra_pages =
-			(VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
+	q->backing_dev_info.ra_pages = default_backing_dev_info.ra_pages;
 	q->backing_dev_info.state = 0;
 	q->backing_dev_info.capabilities = BDI_CAP_MAP_COPY;
 	q->backing_dev_info.name = "block";
--- linux.orig/fs/fuse/inode.c	2010-02-24 10:44:26.000000000 +0800
+++ linux/fs/fuse/inode.c	2010-02-24 10:44:42.000000000 +0800
@@ -870,7 +870,7 @@ static int fuse_bdi_init(struct fuse_con
 	int err;
 
 	fc->bdi.name = "fuse";
-	fc->bdi.ra_pages = (VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
+	fc->bdi.ra_pages = default_backing_dev_info.ra_pages;
 	fc->bdi.unplug_io_fn = default_unplug_io_fn;
 	/* fuse does it's own writeback accounting */
 	fc->bdi.capabilities = BDI_CAP_NO_ACCT_WB;
--- linux.orig/mm/readahead.c	2010-02-24 10:44:40.000000000 +0800
+++ linux/mm/readahead.c	2010-02-24 10:44:42.000000000 +0800
@@ -19,6 +19,28 @@
 #include <linux/pagevec.h>
 #include <linux/pagemap.h>
 
+static int __init config_readahead_size(char *str)
+{
+	unsigned long bytes;
+
+	if (!str)
+		return -EINVAL;
+	bytes = memparse(str, &str);
+	if (*str != '\0')
+		return -EINVAL;
+
+	if (bytes) {
+		if (bytes < PAGE_CACHE_SIZE)	/* missed 'k'/'m' suffixes? */
+			return -EINVAL;
+		if (bytes > 128 << 20)		/* limit to 128MB */
+			bytes = 128 << 20;
+	}
+
+	default_backing_dev_info.ra_pages = bytes / PAGE_CACHE_SIZE;
+	return 0;
+}
+early_param("readahead", config_readahead_size);
+
 /*
  * Initialise a struct file's readahead state.  Assumes that the caller has
  * memset *ra to zero.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
