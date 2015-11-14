Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id EE4C86B025F
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 19:07:49 -0500 (EST)
Received: by pacej9 with SMTP id ej9so7742453pac.2
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 16:07:49 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id z4si30586026pbv.39.2015.11.13.16.07.45
        for <linux-mm@kvack.org>;
        Fri, 13 Nov 2015 16:07:45 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v2 10/11] ext4: add support for DAX fsync/msync
Date: Fri, 13 Nov 2015 17:06:49 -0700
Message-Id: <1447459610-14259-11-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1447459610-14259-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1447459610-14259-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

To properly support the new DAX fsync/msync infrastructure filesystems
need to call dax_pfn_mkwrite() so that DAX can properly track when a user
write faults on a previously cleaned address.  They also need to call
dax_fsync() in the filesystem fsync() path.  This dax_fsync() call uses
addresses retrieved from get_block() so it needs to be ordered with
respect to truncate.  This is accomplished by using the same locking that
was set up for DAX page faults.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/ext4/file.c  |  4 +++-
 fs/ext4/fsync.c | 12 ++++++++++--
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 749b222..8c8965c 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -291,8 +291,8 @@ static int ext4_dax_pfn_mkwrite(struct vm_area_struct *vma,
 {
 	struct inode *inode = file_inode(vma->vm_file);
 	struct super_block *sb = inode->i_sb;
-	int ret = VM_FAULT_NOPAGE;
 	loff_t size;
+	int ret;
 
 	sb_start_pagefault(sb);
 	file_update_time(vma->vm_file);
@@ -300,6 +300,8 @@ static int ext4_dax_pfn_mkwrite(struct vm_area_struct *vma,
 	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	if (vmf->pgoff >= size)
 		ret = VM_FAULT_SIGBUS;
+	else
+		ret = dax_pfn_mkwrite(vma, vmf);
 	up_read(&EXT4_I(inode)->i_mmap_sem);
 	sb_end_pagefault(sb);
 
diff --git a/fs/ext4/fsync.c b/fs/ext4/fsync.c
index 8850254..e87c29b 100644
--- a/fs/ext4/fsync.c
+++ b/fs/ext4/fsync.c
@@ -27,6 +27,7 @@
 #include <linux/sched.h>
 #include <linux/writeback.h>
 #include <linux/blkdev.h>
+#include <linux/dax.h>
 
 #include "ext4.h"
 #include "ext4_jbd2.h"
@@ -86,7 +87,8 @@ static int ext4_sync_parent(struct inode *inode)
 
 int ext4_sync_file(struct file *file, loff_t start, loff_t end, int datasync)
 {
-	struct inode *inode = file->f_mapping->host;
+	struct address_space *mapping = file->f_mapping;
+	struct inode *inode = mapping->host;
 	struct ext4_inode_info *ei = EXT4_I(inode);
 	journal_t *journal = EXT4_SB(inode->i_sb)->s_journal;
 	int ret = 0, err;
@@ -112,7 +114,13 @@ int ext4_sync_file(struct file *file, loff_t start, loff_t end, int datasync)
 		goto out;
 	}
 
-	ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
+	if (dax_mapping(mapping)) {
+		down_read(&ei->i_mmap_sem);
+		dax_fsync(mapping, start, end);
+		up_read(&ei->i_mmap_sem);
+	}
+
+	ret = filemap_write_and_wait_range(mapping, start, end);
 	if (ret)
 		return ret;
 	/*
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
