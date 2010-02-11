Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D19A06B0071
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 06:44:06 -0500 (EST)
From: Nikanth Karthikesan <knikanth@suse.de>
Subject: Re: [PATCH v2] Make VM_MAX_READAHEAD a kernel parameter
Date: Thu, 11 Feb 2010 17:15:03 +0530
References: <201002091659.27037.knikanth@suse.de> <201002111546.35036.knikanth@suse.de> <d24465cb1002110315x4af18888na55aa8d61478e094@mail.gmail.com>
In-Reply-To: <d24465cb1002110315x4af18888na55aa8d61478e094@mail.gmail.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201002111715.04411.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Ankit Jain <radical@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Jens Axboe <jens.axboe@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thursday 11 February 2010 16:45:24 Ankit Jain wrote:
> > +static int __init readahead(char *str)
> > +{
> > +       if (!str)
> > +               return -EINVAL;
> > +       vm_max_readahead_kb = memparse(str, &str) / 1024ULL;
> 
> Just wondering, shouldn't you check whether the str had a valid value
> [memparse (str, &next); next > str ..] and if it didn't, then use the
> DEFAULT_VM_MAX_READAHEAD ? Otherwise, incase of a invalid
> value, the readahead value will become zero.
> 

Thanks for the review. Here is the fixed patch that checks whether all of the
parameters value is consumed.

Thanks
Nikanth

From: Nikanth Karthikesan <knikanth@suse.de>

Add new kernel parameter "readahead", which would be used instead of the
value of VM_MAX_READAHEAD. If the parameter is not specified, the default
of 128kb would be used.

Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>

---

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 736d456..354e6f1 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2148,6 +2148,8 @@ and is between 256 and 4096 characters. It is defined in the file
 			Format: <reboot_mode>[,<reboot_mode2>[,...]]
 			See arch/*/kernel/reboot.c or arch/*/kernel/process.c
 
+	readahead=	Default readahead value for block devices.
+
 	relax_domain_level=
 			[KNL, SMP] Set scheduler's default relax_domain_level.
 			See Documentation/cgroups/cpusets.txt.
diff --git a/block/blk-core.c b/block/blk-core.c
index 718897e..02ed748 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -499,7 +499,7 @@ struct request_queue *blk_alloc_queue_node(gfp_t gfp_mask, int node_id)
 	q->backing_dev_info.unplug_io_fn = blk_backing_dev_unplug;
 	q->backing_dev_info.unplug_io_data = q;
 	q->backing_dev_info.ra_pages =
-			(VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
+			(vm_max_readahead_kb * 1024) / PAGE_CACHE_SIZE;
 	q->backing_dev_info.state = 0;
 	q->backing_dev_info.capabilities = BDI_CAP_MAP_COPY;
 	q->backing_dev_info.name = "block";
diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
index 1a822ce..a593578 100644
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -870,7 +870,7 @@ static int fuse_bdi_init(struct fuse_conn *fc, struct super_block *sb)
 	int err;
 
 	fc->bdi.name = "fuse";
-	fc->bdi.ra_pages = (VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
+	fc->bdi.ra_pages = (vm_max_readahead_kb * 1024) / PAGE_CACHE_SIZE;
 	fc->bdi.unplug_io_fn = default_unplug_io_fn;
 	/* fuse does it's own writeback accounting */
 	fc->bdi.capabilities = BDI_CAP_NO_ACCT_WB;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 60c467b..17825d7 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1188,9 +1188,11 @@ int write_one_page(struct page *page, int wait);
 void task_dirty_inc(struct task_struct *tsk);
 
 /* readahead.c */
-#define VM_MAX_READAHEAD	128	/* kbytes */
+#define DEFAULT_VM_MAX_READAHEAD       128     /* kbytes */
 #define VM_MIN_READAHEAD	16	/* kbytes (includes current page) */
 
+extern unsigned long vm_max_readahead_kb;
+
 int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
 			pgoff_t offset, unsigned long nr_to_read);
 
diff --git a/init/main.c b/init/main.c
index 4cb47a1..6c451d2 100644
--- a/init/main.c
+++ b/init/main.c
@@ -70,6 +70,7 @@
 #include <linux/sfi.h>
 #include <linux/shmem_fs.h>
 #include <trace/boot.h>
+#include <linux/backing-dev.h>
 
 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -249,6 +250,24 @@ static int __init loglevel(char *str)
 
 early_param("loglevel", loglevel);
 
+static int __init readahead(char *str)
+{
+	unsigned long readahead_kb;
+
+	if (!str)
+		return -EINVAL;
+	readahead_kb = memparse(str, &str) / 1024ULL;
+	if (*str != '\0')
+		return -EINVAL;
+
+	vm_max_readahead_kb = readahead_kb;
+	default_backing_dev_info.ra_pages = vm_max_readahead_kb
+						* 1024 / PAGE_CACHE_SIZE;
+	return 0;
+}
+
+early_param("readahead", readahead);
+
 /*
  * Unknown boot options get handed to init, unless they look like
  * unused parameters (modprobe will find them in /proc/cmdline).
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 0e8ca03..e33ff34 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -18,7 +18,7 @@ EXPORT_SYMBOL(default_unplug_io_fn);
 
 struct backing_dev_info default_backing_dev_info = {
 	.name		= "default",
-	.ra_pages	= VM_MAX_READAHEAD * 1024 / PAGE_CACHE_SIZE,
+	.ra_pages	= DEFAULT_VM_MAX_READAHEAD * 1024 / PAGE_CACHE_SIZE,
 	.state		= 0,
 	.capabilities	= BDI_CAP_MAP_COPY,
 	.unplug_io_fn	= default_unplug_io_fn,
diff --git a/mm/readahead.c b/mm/readahead.c
index 033bc13..516f8da 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -17,6 +17,8 @@
 #include <linux/pagevec.h>
 #include <linux/pagemap.h>
 
+unsigned long vm_max_readahead_kb = DEFAULT_VM_MAX_READAHEAD;
+
 /*
  * Initialise a struct file's readahead state.  Assumes that the caller has
  * memset *ra to zero.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
