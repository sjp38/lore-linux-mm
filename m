Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8F7B66B0047
	for <linux-mm@kvack.org>; Sun, 21 Feb 2010 20:29:37 -0500 (EST)
Date: Sun, 21 Feb 2010 22:26:00 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH v2] Make VM_MAX_READAHEAD a kernel parameter
Message-ID: <20100221142600.GA10036@localhost>
References: <201002091659.27037.knikanth@suse.de> <201002111715.04411.knikanth@suse.de> <20100214213724.GA28392@discord.disaster> <201002151006.37294.knikanth@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201002151006.37294.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: Dave Chinner <david@fromorbit.com>, Ankit Jain <radical@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Jens Axboe <jens.axboe@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Nikanth,

> > > +	readahead=	Default readahead value for block devices.
> > > +
> > 
> > I think the description should define the units (kb) and valid value
> > ranges e.g. page size to something not excessive - say 65536kb.  The
> > above description is, IMO, useless without refering to the source to
> > find out this information....
> > 
> 
> The parameter can be specified with/without any suffix(k/m/g) that memparse() 
> helper function can accept. So it can take 1M, 1024k, 1050620. I checked other 
> parameters that use memparse() to get similar values and they didn't document 
> it. May be this should be described here.

Hope this helps clarify things to user:

+       readahead=nn[KM]
+                       Default max readahead size for block devices.
+                       Range: 0; 4k - 128m

> > And readahead_kb needs to be validated against the range of
> > valid values here.
> > 
> 
> I didn't want to impose artificial restrictions. I think Wu's patch set would 
> be adding some restrictions, like minimum readahead. He could fix it when he 
> modifies the patch to include in his patch set.

OK, I imposed a larger bound -- 128MB.
And values 1-4095 (more exactly: PAGE_CACHE_SIZE) are prohibited mainly to 
catch "readahead=128" where the user really means to do 128 _KB_ readahead.

Christian, with this patch and more patches to scale down readahead
size on small memory/device size, I guess it's no longer necessary to
introduce a CONFIG_READAHEAD_SIZE?

Thanks,
Fengguang
---
make default readahead size a kernel parameter

From: Nikanth Karthikesan <knikanth@suse.de>

Add new kernel parameter "readahead", which would be used instead of the
value of VM_MAX_READAHEAD. If the parameter is not specified, the default
of 128kb would be used.

CC: Ankit Jain <radical@gmail.com>
CC: Dave Chinner <david@fromorbit.com>
CC: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 Documentation/kernel-parameters.txt |    4 ++++
 block/blk-core.c                    |    3 +--
 fs/fuse/inode.c                     |    2 +-
 include/linux/mm.h                  |    2 ++
 mm/readahead.c                      |   26 ++++++++++++++++++++++++++
 5 files changed, 34 insertions(+), 3 deletions(-)

--- linux.orig/Documentation/kernel-parameters.txt	2010-02-21 22:09:41.000000000 +0800
+++ linux/Documentation/kernel-parameters.txt	2010-02-21 22:11:08.000000000 +0800
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
--- linux.orig/block/blk-core.c	2010-02-21 22:09:41.000000000 +0800
+++ linux/block/blk-core.c	2010-02-21 22:09:42.000000000 +0800
@@ -498,8 +498,7 @@ struct request_queue *blk_alloc_queue_no
 
 	q->backing_dev_info.unplug_io_fn = blk_backing_dev_unplug;
 	q->backing_dev_info.unplug_io_data = q;
-	q->backing_dev_info.ra_pages =
-			(VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
+	q->backing_dev_info.ra_pages = max_readahead_pages;
 	q->backing_dev_info.state = 0;
 	q->backing_dev_info.capabilities = BDI_CAP_MAP_COPY;
 	q->backing_dev_info.name = "block";
--- linux.orig/fs/fuse/inode.c	2010-02-21 22:09:41.000000000 +0800
+++ linux/fs/fuse/inode.c	2010-02-21 22:09:42.000000000 +0800
@@ -870,7 +870,7 @@ static int fuse_bdi_init(struct fuse_con
 	int err;
 
 	fc->bdi.name = "fuse";
-	fc->bdi.ra_pages = (VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
+	fc->bdi.ra_pages = max_readahead_pages;
 	fc->bdi.unplug_io_fn = default_unplug_io_fn;
 	/* fuse does it's own writeback accounting */
 	fc->bdi.capabilities = BDI_CAP_NO_ACCT_WB;
--- linux.orig/include/linux/mm.h	2010-02-21 22:09:41.000000000 +0800
+++ linux/include/linux/mm.h	2010-02-21 22:09:42.000000000 +0800
@@ -1187,6 +1187,8 @@ void task_dirty_inc(struct task_struct *
 #define VM_MAX_READAHEAD	128	/* kbytes */
 #define VM_MIN_READAHEAD	16	/* kbytes (includes current page) */
 
+extern unsigned long max_readahead_pages;
+
 int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
 			pgoff_t offset, unsigned long nr_to_read);
 
--- linux.orig/mm/readahead.c	2010-02-21 22:09:41.000000000 +0800
+++ linux/mm/readahead.c	2010-02-21 22:13:44.000000000 +0800
@@ -19,6 +19,32 @@
 #include <linux/pagevec.h>
 #include <linux/pagemap.h>
 
+unsigned long max_readahead_pages = VM_MAX_READAHEAD * 1024 / PAGE_CACHE_SIZE;
+
+static int __init readahead(char *str)
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
+	max_readahead_pages = bytes / PAGE_CACHE_SIZE;
+	default_backing_dev_info.ra_pages = max_readahead_pages;
+	return 0;
+}
+
+early_param("readahead", readahead);
+
 /*
  * Initialise a struct file's readahead state.  Assumes that the caller has
  * memset *ra to zero.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
