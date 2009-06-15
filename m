Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A26E26B005C
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 13:58:12 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 03/11] ext2: Allocate space for mmaped file on page fault
Date: Mon, 15 Jun 2009 19:59:50 +0200
Message-Id: <1245088797-29533-4-git-send-email-jack@suse.cz>
In-Reply-To: <1245088797-29533-1-git-send-email-jack@suse.cz>
References: <1245088797-29533-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, npiggin@suse.de, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

So far we've allocated space at ->writepage() time. This has the disadvantage
that when we hit ENOSPC or other error, we cannot do much - either throw
away the data or keep the page indefinitely (and loose the data on reboot).
So allocate space already when a page is faulted in.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/ext2/file.c  |   26 +++++++++++++++++++++++++-
 fs/ext2/inode.c |    1 +
 2 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index 2b9e47d..d0a5f13 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -19,6 +19,8 @@
  */
 
 #include <linux/time.h>
+#include <linux/mm.h>
+#include <linux/buffer_head.h>
 #include "ext2.h"
 #include "xattr.h"
 #include "acl.h"
@@ -38,6 +40,28 @@ static int ext2_release_file (struct inode * inode, struct file * filp)
 	return 0;
 }
 
+static int ext2_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	return block_page_mkwrite(vma, vmf, ext2_get_block);
+}
+
+static struct vm_operations_struct ext2_file_vm_ops = {
+	.fault		= filemap_fault,
+	.page_mkwrite	= ext2_page_mkwrite,
+};
+
+static int ext2_file_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	struct address_space *mapping = file->f_mapping;
+
+	if (!mapping->a_ops->readpage)
+		return -ENOEXEC;
+	file_accessed(file);
+	vma->vm_ops = &ext2_file_vm_ops;
+	vma->vm_flags |= VM_CAN_NONLINEAR;
+	return 0;
+}
+
 /*
  * We have mostly NULL's here: the current defaults are ok for
  * the ext2 filesystem.
@@ -52,7 +76,7 @@ const struct file_operations ext2_file_operations = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl	= ext2_compat_ioctl,
 #endif
-	.mmap		= generic_file_mmap,
+	.mmap		= ext2_file_mmap,
 	.open		= generic_file_open,
 	.release	= ext2_release_file,
 	.fsync		= simple_fsync,
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 29ed682..3805b6b 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -814,6 +814,7 @@ const struct address_space_operations ext2_aops = {
 	.sync_page		= block_sync_page,
 	.write_begin		= ext2_write_begin,
 	.write_end		= generic_write_end,
+	.extend_i_size		= block_extend_i_size,
 	.bmap			= ext2_bmap,
 	.direct_IO		= ext2_direct_IO,
 	.writepages		= ext2_writepages,
-- 
1.6.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
