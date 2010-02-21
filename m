Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3B8DA6B0047
	for <linux-mm@kvack.org>; Sun, 21 Feb 2010 20:33:54 -0500 (EST)
Date: Sun, 21 Feb 2010 23:52:08 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH v2] Make VM_MAX_READAHEAD a kernel parameter
Message-ID: <20100221155208.GA22319@localhost>
References: <201002091659.27037.knikanth@suse.de> <201002111715.04411.knikanth@suse.de> <20100214213724.GA28392@discord.disaster> <201002151006.37294.knikanth@suse.de> <20100221142600.GA10036@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100221142600.GA10036@localhost>
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: Dave Chinner <david@fromorbit.com>, Ankit Jain <radical@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Jens Axboe <jens.axboe@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> +unsigned long max_readahead_pages = VM_MAX_READAHEAD * 1024 / PAGE_CACHE_SIZE;
> +
> +static int __init readahead(char *str)
> +{
> +	unsigned long bytes;
> +
> +	if (!str)
> +		return -EINVAL;
> +	bytes = memparse(str, &str);
> +	if (*str != '\0')
> +		return -EINVAL;
> +
> +	if (bytes) {
> +		if (bytes < PAGE_CACHE_SIZE)	/* missed 'k'/'m' suffixes? */
> +			return -EINVAL;
> +		if (bytes > 128 << 20)		/* limit to 128MB */
> +			bytes = 128 << 20;
> +	}
> +
> +	max_readahead_pages = bytes / PAGE_CACHE_SIZE;
> +	default_backing_dev_info.ra_pages = max_readahead_pages;
> +	return 0;
> +}
> +
> +early_param("readahead", readahead);

This further optimizes away max_readahead_pages :)

---
make default readahead size a kernel parameter

From: Nikanth Karthikesan <knikanth@suse.de>

Add new kernel parameter "readahead", which allows user to override
the static VM_MAX_READAHEAD=512kb.

CC: Ankit Jain <radical@gmail.com>
CC: Dave Chinner <david@fromorbit.com>
CC: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 Documentation/kernel-parameters.txt |    4 ++++
 block/blk-core.c                    |    3 +--
 fs/fuse/inode.c                     |    2 +-
 mm/readahead.c                      |   22 ++++++++++++++++++++++
 4 files changed, 28 insertions(+), 3 deletions(-)

--- linux.orig/Documentation/kernel-parameters.txt	2010-02-21 22:41:29.000000000 +0800
+++ linux/Documentation/kernel-parameters.txt	2010-02-21 22:41:30.000000000 +0800
@@ -2174,6 +2174,10 @@ and is between 256 and 4096 characters. 
 			Run specified binary instead of /init from the ramdisk,
 			used for early userspace startup. See initrd.
 
+	readahead=nn[KM]
+			Default max readahead size for block devices.
+			Range: 0; 4k - 128m
+
 	reboot=		[BUGS=X86-32,BUGS=ARM,BUGS=IA-64] Rebooting mode
 			Format: <reboot_mode>[,<reboot_mode2>[,...]]
 			See arch/*/kernel/reboot.c or arch/*/kernel/process.c
--- linux.orig/block/blk-core.c	2010-02-21 22:41:29.000000000 +0800
+++ linux/block/blk-core.c	2010-02-21 22:41:30.000000000 +0800
@@ -498,8 +498,7 @@ struct request_queue *blk_alloc_queue_no
 
 	q->backing_dev_info.unplug_io_fn = blk_backing_dev_unplug;
 	q->backing_dev_info.unplug_io_data = q;
-	q->backing_dev_info.ra_pages =
-			(VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
+	q->backing_dev_info.ra_pages = default_backing_dev_info.ra_pages;
 	q->backing_dev_info.state = 0;
 	q->backing_dev_info.capabilities = BDI_CAP_MAP_COPY;
 	q->backing_dev_info.name = "block";
--- linux.orig/fs/fuse/inode.c	2010-02-21 22:41:29.000000000 +0800
+++ linux/fs/fuse/inode.c	2010-02-21 22:41:30.000000000 +0800
@@ -870,7 +870,7 @@ static int fuse_bdi_init(struct fuse_con
 	int err;
 
 	fc->bdi.name = "fuse";
-	fc->bdi.ra_pages = (VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
+	fc->bdi.ra_pages = default_backing_dev_info.ra_pages;
 	fc->bdi.unplug_io_fn = default_unplug_io_fn;
 	/* fuse does it's own writeback accounting */
 	fc->bdi.capabilities = BDI_CAP_NO_ACCT_WB;
--- linux.orig/mm/readahead.c	2010-02-21 22:41:29.000000000 +0800
+++ linux/mm/readahead.c	2010-02-21 22:42:15.000000000 +0800
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
