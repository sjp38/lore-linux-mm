Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id B44A99003C7
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 16:29:42 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so173157522pab.1
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 13:29:42 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id bw10si15993860pdb.206.2015.07.10.13.29.35
        for <linux-mm@kvack.org>;
        Fri, 10 Jul 2015 13:29:35 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 02/10] dax: Move DAX-related functions to a new header
Date: Fri, 10 Jul 2015 16:29:17 -0400
Message-Id: <1436560165-8943-3-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1436560165-8943-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1436560165-8943-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <willy@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

In order to handle the !CONFIG_TRANSPARENT_HUGEPAGES case, we need to
return VM_FAULT_FALLBACK from the inlined dax_pmd_fault(), which is
defined in linux/mm.h.  Given that we don't want to include <linux/mm.h>
in <linux/fs.h>, the easiest solution is to move the DAX-related functions
to a new header, <linux/dax.h>.  We could also have moved VM_FAULT_*
definitions to a new header, or a different header that isn't quite
such a boil-the-ocean header as <linux/mm.h>, but this felt like the
best option.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 fs/block_dev.c      |  1 +
 fs/ext2/file.c      |  1 +
 fs/ext2/inode.c     |  1 +
 fs/ext4/file.c      |  1 +
 fs/ext4/indirect.c  |  1 +
 fs/ext4/inode.c     |  1 +
 fs/xfs/xfs_buf.h    |  1 +
 include/linux/dax.h | 21 +++++++++++++++++++++
 include/linux/fs.h  | 14 --------------
 9 files changed, 28 insertions(+), 14 deletions(-)
 create mode 100644 include/linux/dax.h

diff --git a/fs/block_dev.c b/fs/block_dev.c
index 1982437..9be2d7e 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -28,6 +28,7 @@
 #include <linux/namei.h>
 #include <linux/log2.h>
 #include <linux/cleancache.h>
+#include <linux/dax.h>
 #include <asm/uaccess.h>
 #include "internal.h"
 
diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index 3b57c9f..db4c299 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -20,6 +20,7 @@
 
 #include <linux/time.h>
 #include <linux/pagemap.h>
+#include <linux/dax.h>
 #include <linux/quotaops.h>
 #include "ext2.h"
 #include "xattr.h"
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 27c85ea..1488248 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -25,6 +25,7 @@
 #include <linux/time.h>
 #include <linux/highuid.h>
 #include <linux/pagemap.h>
+#include <linux/dax.h>
 #include <linux/quotaops.h>
 #include <linux/writeback.h>
 #include <linux/buffer_head.h>
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index e5bdcb7..34d814f 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -22,6 +22,7 @@
 #include <linux/fs.h>
 #include <linux/mount.h>
 #include <linux/path.h>
+#include <linux/dax.h>
 #include <linux/quotaops.h>
 #include <linux/pagevec.h>
 #include <linux/uio.h>
diff --git a/fs/ext4/indirect.c b/fs/ext4/indirect.c
index 4f6ac49..2468261 100644
--- a/fs/ext4/indirect.c
+++ b/fs/ext4/indirect.c
@@ -22,6 +22,7 @@
 
 #include "ext4_jbd2.h"
 #include "truncate.h"
+#include <linux/dax.h>
 #include <linux/uio.h>
 
 #include <trace/events/ext4.h>
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index ae54de4..26a32da 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -22,6 +22,7 @@
 #include <linux/time.h>
 #include <linux/highuid.h>
 #include <linux/pagemap.h>
+#include <linux/dax.h>
 #include <linux/quotaops.h>
 #include <linux/string.h>
 #include <linux/buffer_head.h>
diff --git a/fs/xfs/xfs_buf.h b/fs/xfs/xfs_buf.h
index 331c1cc..c79b717 100644
--- a/fs/xfs/xfs_buf.h
+++ b/fs/xfs/xfs_buf.h
@@ -23,6 +23,7 @@
 #include <linux/spinlock.h>
 #include <linux/mm.h>
 #include <linux/fs.h>
+#include <linux/dax.h>
 #include <linux/buffer_head.h>
 #include <linux/uio.h>
 #include <linux/list_lru.h>
diff --git a/include/linux/dax.h b/include/linux/dax.h
new file mode 100644
index 0000000..4f27d3d
--- /dev/null
+++ b/include/linux/dax.h
@@ -0,0 +1,21 @@
+#ifndef _LINUX_DAX_H
+#define _LINUX_DAX_H
+
+#include <linux/fs.h>
+#include <linux/mm.h>
+#include <asm/pgtable.h>
+
+ssize_t dax_do_io(struct kiocb *, struct inode *, struct iov_iter *, loff_t,
+		  get_block_t, dio_iodone_t, int flags);
+int dax_clear_blocks(struct inode *, sector_t block, long size);
+int dax_zero_page_range(struct inode *, loff_t from, unsigned len, get_block_t);
+int dax_truncate_page(struct inode *, loff_t from, get_block_t);
+int dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t,
+		dax_iodone_t);
+int __dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t,
+		dax_iodone_t);
+int dax_pfn_mkwrite(struct vm_area_struct *, struct vm_fault *);
+#define dax_mkwrite(vma, vmf, gb, iod)		dax_fault(vma, vmf, gb, iod)
+#define __dax_mkwrite(vma, vmf, gb, iod)	__dax_fault(vma, vmf, gb, iod)
+
+#endif
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 47053b3..824102a 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -51,7 +51,6 @@ struct swap_info_struct;
 struct seq_file;
 struct workqueue_struct;
 struct iov_iter;
-struct vm_fault;
 
 extern void __init inode_init(void);
 extern void __init inode_init_early(void);
@@ -2656,19 +2655,6 @@ extern loff_t fixed_size_llseek(struct file *file, loff_t offset,
 extern int generic_file_open(struct inode * inode, struct file * filp);
 extern int nonseekable_open(struct inode * inode, struct file * filp);
 
-ssize_t dax_do_io(struct kiocb *, struct inode *, struct iov_iter *, loff_t,
-		  get_block_t, dio_iodone_t, int flags);
-int dax_clear_blocks(struct inode *, sector_t block, long size);
-int dax_zero_page_range(struct inode *, loff_t from, unsigned len, get_block_t);
-int dax_truncate_page(struct inode *, loff_t from, get_block_t);
-int dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t,
-		dax_iodone_t);
-int __dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t,
-		dax_iodone_t);
-int dax_pfn_mkwrite(struct vm_area_struct *, struct vm_fault *);
-#define dax_mkwrite(vma, vmf, gb, iod)		dax_fault(vma, vmf, gb, iod)
-#define __dax_mkwrite(vma, vmf, gb, iod)	__dax_fault(vma, vmf, gb, iod)
-
 #ifdef CONFIG_BLOCK
 typedef void (dio_submit_t)(int rw, struct bio *bio, struct inode *inode,
 			    loff_t file_offset);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
