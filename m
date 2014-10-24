Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2D3B86B006E
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 17:21:11 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id rd3so1827065pab.28
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 14:21:10 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id p5si5173993pdb.8.2014.10.24.14.21.09
        for <linux-mm@kvack.org>;
        Fri, 24 Oct 2014 14:21:09 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v12 05/20] vfs,ext2: Introduce IS_DAX(inode)
Date: Fri, 24 Oct 2014 17:20:37 -0400
Message-Id: <1414185652-28663-6-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, willy@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>

Use an inode flag to tag inodes which should avoid using the page cache.
Convert ext2 to use it instead of mapping_is_xip().  Prevent I/Os to
files tagged with the DAX flag from falling back to buffered I/O.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
---
 fs/ext2/inode.c    |  9 ++++++---
 fs/ext2/xip.h      |  2 --
 include/linux/fs.h |  6 ++++++
 mm/filemap.c       | 19 ++++++++++++-------
 4 files changed, 24 insertions(+), 12 deletions(-)

diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 36d35c3..0cb0448 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -731,7 +731,7 @@ static int ext2_get_blocks(struct inode *inode,
 		goto cleanup;
 	}
 
-	if (ext2_use_xip(inode->i_sb)) {
+	if (IS_DAX(inode)) {
 		/*
 		 * we need to clear the block
 		 */
@@ -1201,7 +1201,7 @@ static int ext2_setsize(struct inode *inode, loff_t newsize)
 
 	inode_dio_wait(inode);
 
-	if (mapping_is_xip(inode->i_mapping))
+	if (IS_DAX(inode))
 		error = xip_truncate_page(inode->i_mapping, newsize);
 	else if (test_opt(inode->i_sb, NOBH))
 		error = nobh_truncate_page(inode->i_mapping,
@@ -1273,7 +1273,8 @@ void ext2_set_inode_flags(struct inode *inode)
 {
 	unsigned int flags = EXT2_I(inode)->i_flags;
 
-	inode->i_flags &= ~(S_SYNC|S_APPEND|S_IMMUTABLE|S_NOATIME|S_DIRSYNC);
+	inode->i_flags &= ~(S_SYNC | S_APPEND | S_IMMUTABLE | S_NOATIME |
+				S_DIRSYNC | S_DAX);
 	if (flags & EXT2_SYNC_FL)
 		inode->i_flags |= S_SYNC;
 	if (flags & EXT2_APPEND_FL)
@@ -1284,6 +1285,8 @@ void ext2_set_inode_flags(struct inode *inode)
 		inode->i_flags |= S_NOATIME;
 	if (flags & EXT2_DIRSYNC_FL)
 		inode->i_flags |= S_DIRSYNC;
+	if (test_opt(inode->i_sb, XIP))
+		inode->i_flags |= S_DAX;
 }
 
 /* Propagate flags from i_flags to EXT2_I(inode)->i_flags */
diff --git a/fs/ext2/xip.h b/fs/ext2/xip.h
index 18b34d2..29be737 100644
--- a/fs/ext2/xip.h
+++ b/fs/ext2/xip.h
@@ -16,9 +16,7 @@ static inline int ext2_use_xip (struct super_block *sb)
 }
 int ext2_get_xip_mem(struct address_space *, pgoff_t, int,
 				void **, unsigned long *);
-#define mapping_is_xip(map) unlikely(map->a_ops->get_xip_mem)
 #else
-#define mapping_is_xip(map)			0
 #define ext2_xip_verify_sb(sb)			do { } while (0)
 #define ext2_use_xip(sb)			0
 #define ext2_clear_xip_target(inode, chain)	0
diff --git a/include/linux/fs.h b/include/linux/fs.h
index a957d43..ff0acb2 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1587,6 +1587,11 @@ struct super_operations {
 #define S_IMA		1024	/* Inode has an associated IMA struct */
 #define S_AUTOMOUNT	2048	/* Automount/referral quasi-directory */
 #define S_NOSEC		4096	/* no suid or xattr security attributes */
+#ifdef CONFIG_FS_XIP
+#define S_DAX		8192	/* Direct Access, avoiding the page cache */
+#else
+#define S_DAX		0	/* Make all the DAX code disappear */
+#endif
 
 /*
  * Note that nosuid etc flags are inode-specific: setting some file-system
@@ -1624,6 +1629,7 @@ struct super_operations {
 #define IS_IMA(inode)		((inode)->i_flags & S_IMA)
 #define IS_AUTOMOUNT(inode)	((inode)->i_flags & S_AUTOMOUNT)
 #define IS_NOSEC(inode)		((inode)->i_flags & S_NOSEC)
+#define IS_DAX(inode)		((inode)->i_flags & S_DAX)
 
 /*
  * Inode state bits.  Protected by inode->i_lock
diff --git a/mm/filemap.c b/mm/filemap.c
index 14b4642..2b13a4a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1727,9 +1727,11 @@ generic_file_read_iter(struct kiocb *iocb, struct iov_iter *iter)
 		 * we've already read everything we wanted to, or if
 		 * there was a short read because we hit EOF, go ahead
 		 * and return.  Otherwise fallthrough to buffered io for
-		 * the rest of the read.
+		 * the rest of the read.  Buffered reads will not work for
+		 * DAX files, so don't bother trying.
 		 */
-		if (retval < 0 || !iov_iter_count(iter) || *ppos >= size) {
+		if (retval < 0 || !iov_iter_count(iter) || *ppos >= size ||
+		    IS_DAX(inode)) {
 			file_accessed(file);
 			goto out;
 		}
@@ -2593,13 +2595,16 @@ ssize_t __generic_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 		loff_t endbyte;
 
 		written = generic_file_direct_write(iocb, from, pos);
-		if (written < 0 || written == count)
-			goto out;
-
 		/*
-		 * direct-io write to a hole: fall through to buffered I/O
-		 * for completing the rest of the request.
+		 * If the write stopped short of completing, fall back to
+		 * buffered writes.  Some filesystems do this for writes to
+		 * holes, for example.  For DAX files, a buffered write will
+		 * not succeed (even if it did, DAX does not handle dirty
+		 * page-cache pages correctly).
 		 */
+		if (written < 0 || written == count || IS_DAX(inode))
+			goto out;
+
 		pos += written;
 		count -= written;
 
-- 
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
