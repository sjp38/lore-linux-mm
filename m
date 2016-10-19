Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B48E96B026D
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 15:34:52 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e6so3554412pfk.2
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 12:34:52 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 62si41746891pfi.104.2016.10.19.12.34.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Oct 2016 12:34:51 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v8 15/16] xfs: use struct iomap based DAX PMD fault path
Date: Wed, 19 Oct 2016 13:34:34 -0600
Message-Id: <1476905675-32581-16-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1476905675-32581-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1476905675-32581-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

Switch xfs_filemap_pmd_fault() from using dax_pmd_fault() to the new and
improved dax_iomap_pmd_fault().  Also, now that it has no more users,
remove xfs_get_blocks_dax_fault().

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 fs/xfs/xfs_aops.c | 26 +++++---------------------
 fs/xfs/xfs_aops.h |  3 ---
 fs/xfs/xfs_file.c |  2 +-
 3 files changed, 6 insertions(+), 25 deletions(-)

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 3e57a56..561cf14 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -1298,8 +1298,7 @@ __xfs_get_blocks(
 	sector_t		iblock,
 	struct buffer_head	*bh_result,
 	int			create,
-	bool			direct,
-	bool			dax_fault)
+	bool			direct)
 {
 	struct xfs_inode	*ip = XFS_I(inode);
 	struct xfs_mount	*mp = ip->i_mount;
@@ -1420,13 +1419,8 @@ __xfs_get_blocks(
 		if (ISUNWRITTEN(&imap))
 			set_buffer_unwritten(bh_result);
 		/* direct IO needs special help */
-		if (create) {
-			if (dax_fault)
-				ASSERT(!ISUNWRITTEN(&imap));
-			else
-				xfs_map_direct(inode, bh_result, &imap, offset,
-						is_cow);
-		}
+		if (create)
+			xfs_map_direct(inode, bh_result, &imap, offset, is_cow);
 	}
 
 	/*
@@ -1466,7 +1460,7 @@ xfs_get_blocks(
 	struct buffer_head	*bh_result,
 	int			create)
 {
-	return __xfs_get_blocks(inode, iblock, bh_result, create, false, false);
+	return __xfs_get_blocks(inode, iblock, bh_result, create, false);
 }
 
 int
@@ -1476,17 +1470,7 @@ xfs_get_blocks_direct(
 	struct buffer_head	*bh_result,
 	int			create)
 {
-	return __xfs_get_blocks(inode, iblock, bh_result, create, true, false);
-}
-
-int
-xfs_get_blocks_dax_fault(
-	struct inode		*inode,
-	sector_t		iblock,
-	struct buffer_head	*bh_result,
-	int			create)
-{
-	return __xfs_get_blocks(inode, iblock, bh_result, create, true, true);
+	return __xfs_get_blocks(inode, iblock, bh_result, create, true);
 }
 
 /*
diff --git a/fs/xfs/xfs_aops.h b/fs/xfs/xfs_aops.h
index b3c6634..34dc00d 100644
--- a/fs/xfs/xfs_aops.h
+++ b/fs/xfs/xfs_aops.h
@@ -59,9 +59,6 @@ int	xfs_get_blocks(struct inode *inode, sector_t offset,
 		       struct buffer_head *map_bh, int create);
 int	xfs_get_blocks_direct(struct inode *inode, sector_t offset,
 			      struct buffer_head *map_bh, int create);
-int	xfs_get_blocks_dax_fault(struct inode *inode, sector_t offset,
-			         struct buffer_head *map_bh, int create);
-
 int	xfs_end_io_direct_write(struct kiocb *iocb, loff_t offset,
 		ssize_t size, void *private);
 int	xfs_setfilesize(struct xfs_inode *ip, xfs_off_t offset, size_t size);
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index e7f35d54..ca2ab73 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1711,7 +1711,7 @@ xfs_filemap_pmd_fault(
 	}
 
 	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
-	ret = dax_pmd_fault(vma, addr, pmd, flags, xfs_get_blocks_dax_fault);
+	ret = dax_iomap_pmd_fault(vma, addr, pmd, flags, &xfs_iomap_ops);
 	xfs_iunlock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
 
 	if (flags & FAULT_FLAG_WRITE)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
