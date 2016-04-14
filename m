Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 10C686B0264
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 12:57:19 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id hb4so98289930pac.3
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 09:57:19 -0700 (PDT)
Received: from g1t5425.austin.hp.com (g1t5425.austin.hp.com. [15.216.225.55])
        by mx.google.com with ESMTPS id ey9si13989680pab.123.2016.04.14.09.57.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 09:57:17 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v3 2/2] ext2/4, xfs, blk: call dax_get_unmapped_area() for DAX pmd mappings
Date: Thu, 14 Apr 2016 10:48:31 -0600
Message-Id: <1460652511-19636-3-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1460652511-19636-1-git-send-email-toshi.kani@hpe.com>
References: <1460652511-19636-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, dan.j.williams@intel.com, viro@zeniv.linux.org.uk
Cc: willy@linux.intel.com, ross.zwisler@linux.intel.com, kirill.shutemov@linux.intel.com, david@fromorbit.com, jack@suse.cz, tytso@mit.edu, adilger.kernel@dilger.ca, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>

To support DAX pmd mappings with unmodified applications,
filesystems need to align an mmap address by the pmd size.

Call dax_get_unmapped_area() from f_op->get_unmapped_area.

Note, there is no change in behavior for a non-DAX file.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Theodore Ts'o <tytso@mit.edu>
Cc: Andreas Dilger <adilger.kernel@dilger.ca>
---
 fs/block_dev.c    |    1 +
 fs/ext2/file.c    |    1 +
 fs/ext4/file.c    |    1 +
 fs/xfs/xfs_file.c |    1 +
 4 files changed, 4 insertions(+)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index 20a2c02..52518e0 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -1798,6 +1798,7 @@ const struct file_operations def_blk_fops = {
 	.write_iter	= blkdev_write_iter,
 	.mmap		= blkdev_mmap,
 	.fsync		= blkdev_fsync,
+	.get_unmapped_area = dax_get_unmapped_area,
 	.unlocked_ioctl	= block_ioctl,
 #ifdef CONFIG_COMPAT
 	.compat_ioctl	= compat_blkdev_ioctl,
diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index c1400b1..dbf11eb 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -172,6 +172,7 @@ const struct file_operations ext2_file_operations = {
 	.open		= dquot_file_open,
 	.release	= ext2_release_file,
 	.fsync		= ext2_fsync,
+	.get_unmapped_area = dax_get_unmapped_area,
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= iter_file_splice_write,
 };
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index fa2208b..6c268f8 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -708,6 +708,7 @@ const struct file_operations ext4_file_operations = {
 	.open		= ext4_file_open,
 	.release	= ext4_release_file,
 	.fsync		= ext4_sync_file,
+	.get_unmapped_area = dax_get_unmapped_area,
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= iter_file_splice_write,
 	.fallocate	= ext4_fallocate,
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 569938a..1e409a6 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1708,6 +1708,7 @@ const struct file_operations xfs_file_operations = {
 	.open		= xfs_file_open,
 	.release	= xfs_file_release,
 	.fsync		= xfs_file_fsync,
+	.get_unmapped_area = dax_get_unmapped_area,
 	.fallocate	= xfs_file_fallocate,
 };
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
