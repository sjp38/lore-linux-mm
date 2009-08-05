Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 574F26B0096
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 05:36:45 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <200908051136.682859934@firstfloor.org>
In-Reply-To: <200908051136.682859934@firstfloor.org>
Subject: [PATCH] [16/19] HWPOISON: Enable .remove_error_page for migration aware file systems
Message-Id: <20090805093643.E0C00B15D8@basil.firstfloor.org>
Date: Wed,  5 Aug 2009 11:36:43 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: tytso@mit.edu, hch@infradead.org, mfasheh@suse.com, aia21@cantab.net, hugh.dickins@tiscali.co.uk, swhiteho@redhat.com, akpm@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, hidehiro.kawai.ez@hitachi.com
List-ID: <linux-mm.kvack.org>


Enable removing of corrupted pages through truncation
for a bunch of file systems: ext*, xfs, gfs2, ocfs2, ntfs
These should cover most server needs.

I chose the set of migration aware file systems for this
for now, assuming they have been especially audited.
But in general it should be safe for all file systems
on the data area that support read/write and truncate.

Caveat: the hardware error handler does not take i_mutex
for now before calling the truncate function. Is that ok?

Cc: tytso@mit.edu
Cc: hch@infradead.org
Cc: mfasheh@suse.com
Cc: aia21@cantab.net
Cc: hugh.dickins@tiscali.co.uk
Cc: swhiteho@redhat.com
Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 fs/ext2/inode.c             |    2 ++
 fs/ext3/inode.c             |    3 +++
 fs/ext4/inode.c             |    4 ++++
 fs/gfs2/aops.c              |    3 +++
 fs/ntfs/aops.c              |    2 ++
 fs/ocfs2/aops.c             |    1 +
 fs/xfs/linux-2.6/xfs_aops.c |    1 +
 mm/shmem.c                  |    1 +
 8 files changed, 17 insertions(+)

Index: linux/fs/gfs2/aops.c
===================================================================
--- linux.orig/fs/gfs2/aops.c
+++ linux/fs/gfs2/aops.c
@@ -1135,6 +1135,7 @@ static const struct address_space_operat
 	.direct_IO = gfs2_direct_IO,
 	.migratepage = buffer_migrate_page,
 	.is_partially_uptodate = block_is_partially_uptodate,
+	.error_remove_page = generic_error_remove_page,
 };
 
 static const struct address_space_operations gfs2_ordered_aops = {
@@ -1151,6 +1152,7 @@ static const struct address_space_operat
 	.direct_IO = gfs2_direct_IO,
 	.migratepage = buffer_migrate_page,
 	.is_partially_uptodate = block_is_partially_uptodate,
+	.error_remove_page = generic_error_remove_page,
 };
 
 static const struct address_space_operations gfs2_jdata_aops = {
@@ -1166,6 +1168,7 @@ static const struct address_space_operat
 	.invalidatepage = gfs2_invalidatepage,
 	.releasepage = gfs2_releasepage,
 	.is_partially_uptodate = block_is_partially_uptodate,
+	.error_remove_page = generic_error_remove_page,
 };
 
 void gfs2_set_aops(struct inode *inode)
Index: linux/fs/ntfs/aops.c
===================================================================
--- linux.orig/fs/ntfs/aops.c
+++ linux/fs/ntfs/aops.c
@@ -1550,6 +1550,7 @@ const struct address_space_operations nt
 	.migratepage	= buffer_migrate_page,	/* Move a page cache page from
 						   one physical page to an
 						   other. */
+	.error_remove_page = generic_error_remove_page,
 };
 
 /**
@@ -1569,6 +1570,7 @@ const struct address_space_operations nt
 	.migratepage	= buffer_migrate_page,	/* Move a page cache page from
 						   one physical page to an
 						   other. */
+	.error_remove_page = generic_error_remove_page,
 };
 
 #ifdef NTFS_RW
Index: linux/fs/ocfs2/aops.c
===================================================================
--- linux.orig/fs/ocfs2/aops.c
+++ linux/fs/ocfs2/aops.c
@@ -1968,4 +1968,5 @@ const struct address_space_operations oc
 	.releasepage		= ocfs2_releasepage,
 	.migratepage		= buffer_migrate_page,
 	.is_partially_uptodate	= block_is_partially_uptodate,
+	.error_remove_page	= generic_error_remove_page,
 };
Index: linux/fs/xfs/linux-2.6/xfs_aops.c
===================================================================
--- linux.orig/fs/xfs/linux-2.6/xfs_aops.c
+++ linux/fs/xfs/linux-2.6/xfs_aops.c
@@ -1636,4 +1636,5 @@ const struct address_space_operations xf
 	.direct_IO		= xfs_vm_direct_IO,
 	.migratepage		= buffer_migrate_page,
 	.is_partially_uptodate  = block_is_partially_uptodate,
+	.error_remove_page	= generic_error_remove_page,
 };
Index: linux/mm/shmem.c
===================================================================
--- linux.orig/mm/shmem.c
+++ linux/mm/shmem.c
@@ -2421,6 +2421,7 @@ static const struct address_space_operat
 	.write_end	= shmem_write_end,
 #endif
 	.migratepage	= migrate_page,
+	.error_remove_page = generic_error_remove_page,
 };
 
 static const struct file_operations shmem_file_operations = {
Index: linux/fs/ext2/inode.c
===================================================================
--- linux.orig/fs/ext2/inode.c
+++ linux/fs/ext2/inode.c
@@ -819,6 +819,7 @@ const struct address_space_operations ex
 	.writepages		= ext2_writepages,
 	.migratepage		= buffer_migrate_page,
 	.is_partially_uptodate	= block_is_partially_uptodate,
+	.error_remove_page	= generic_error_remove_page,
 };
 
 const struct address_space_operations ext2_aops_xip = {
@@ -837,6 +838,7 @@ const struct address_space_operations ex
 	.direct_IO		= ext2_direct_IO,
 	.writepages		= ext2_writepages,
 	.migratepage		= buffer_migrate_page,
+	.error_remove_page	= generic_error_remove_page,
 };
 
 /*
Index: linux/fs/ext3/inode.c
===================================================================
--- linux.orig/fs/ext3/inode.c
+++ linux/fs/ext3/inode.c
@@ -1819,6 +1819,7 @@ static const struct address_space_operat
 	.direct_IO		= ext3_direct_IO,
 	.migratepage		= buffer_migrate_page,
 	.is_partially_uptodate  = block_is_partially_uptodate,
+	.error_remove_page	= generic_error_remove_page,
 };
 
 static const struct address_space_operations ext3_writeback_aops = {
@@ -1834,6 +1835,7 @@ static const struct address_space_operat
 	.direct_IO		= ext3_direct_IO,
 	.migratepage		= buffer_migrate_page,
 	.is_partially_uptodate  = block_is_partially_uptodate,
+	.error_remove_page	= generic_error_remove_page,
 };
 
 static const struct address_space_operations ext3_journalled_aops = {
@@ -1848,6 +1850,7 @@ static const struct address_space_operat
 	.invalidatepage		= ext3_invalidatepage,
 	.releasepage		= ext3_releasepage,
 	.is_partially_uptodate  = block_is_partially_uptodate,
+	.error_remove_page	= generic_error_remove_page,
 };
 
 void ext3_set_aops(struct inode *inode)
Index: linux/fs/ext4/inode.c
===================================================================
--- linux.orig/fs/ext4/inode.c
+++ linux/fs/ext4/inode.c
@@ -3373,6 +3373,7 @@ static const struct address_space_operat
 	.direct_IO		= ext4_direct_IO,
 	.migratepage		= buffer_migrate_page,
 	.is_partially_uptodate  = block_is_partially_uptodate,
+	.error_remove_page	= generic_error_remove_page,
 };
 
 static const struct address_space_operations ext4_writeback_aops = {
@@ -3388,6 +3389,7 @@ static const struct address_space_operat
 	.direct_IO		= ext4_direct_IO,
 	.migratepage		= buffer_migrate_page,
 	.is_partially_uptodate  = block_is_partially_uptodate,
+	.error_remove_page	= generic_error_remove_page,
 };
 
 static const struct address_space_operations ext4_journalled_aops = {
@@ -3402,6 +3404,7 @@ static const struct address_space_operat
 	.invalidatepage		= ext4_invalidatepage,
 	.releasepage		= ext4_releasepage,
 	.is_partially_uptodate  = block_is_partially_uptodate,
+	.error_remove_page	= generic_error_remove_page,
 };
 
 static const struct address_space_operations ext4_da_aops = {
@@ -3418,6 +3421,7 @@ static const struct address_space_operat
 	.direct_IO		= ext4_direct_IO,
 	.migratepage		= buffer_migrate_page,
 	.is_partially_uptodate  = block_is_partially_uptodate,
+	.error_remove_page	= generic_error_remove_page,
 };
 
 void ext4_set_aops(struct inode *inode)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
