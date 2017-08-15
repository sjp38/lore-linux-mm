Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5D5046B0292
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 02:18:37 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id y129so1757013pgy.1
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 23:18:37 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id a68si5049258pgc.191.2017.08.14.23.18.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 23:18:36 -0700 (PDT)
Subject: [PATCH v4 1/3] fs, xfs: introduce S_IOMAP_SEALED
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 14 Aug 2017 23:12:11 -0700
Message-ID: <150277753139.23945.12474457435649645890.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150277752553.23945.13932394738552748440.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150277752553.23945.13932394738552748440.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: darrick.wong@oracle.com
Cc: Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, luto@kernel.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

When a filesystem sees this flag set it will not allow changes to the
file-offset to physical-block-offset relationship of any extent in the
file. The extent of the extents covered by the global S_IOMAP_SEALED is
filesystem specific. In other words it is similar to the inode-wide
XFS_DIFLAG2_REFLINK flag where we make the distinction apply globally to
the inode even though we could theoretically limit that effect to a
sub-range of the file.

The interface that sets this flag (mmap(..., MAP_DIRECT, ...)) will be
careful to document that it is implementation specific whether the
'sealed' restrictions apply to a sub-range or the whole file.
Applications should be prepared for unrelated ranges in the file to be
effected.

The term 'sealed' is used instead of 'immutable' to better indicate that
this is a file property that is temporary and can be undone.

Cc: Jan Kara <jack@suse.cz>
Cc: Jeff Moyer <jmoyer@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/attr.c                |   10 ++++++++++
 fs/open.c                |    6 ++++++
 fs/read_write.c          |    3 +++
 fs/xfs/libxfs/xfs_bmap.c |    5 +++++
 fs/xfs/xfs_bmap_util.c   |    3 +++
 fs/xfs/xfs_ioctl.c       |    6 ++++++
 include/linux/fs.h       |    2 ++
 mm/filemap.c             |    5 +++++
 8 files changed, 40 insertions(+)

diff --git a/fs/attr.c b/fs/attr.c
index 135304146120..d940386e0ca9 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -112,6 +112,16 @@ EXPORT_SYMBOL(setattr_prepare);
  */
 int inode_newsize_ok(const struct inode *inode, loff_t offset)
 {
+	if (IS_IOMAP_SEALED(inode)) {
+		/*
+		 * Any size change is disallowed. Size increases may
+		 * dirty metadata that an application is not prepared to
+		 * sync, and a size decrease may expose free blocks to
+		 * in-flight DMA.
+		 */
+		return -ETXTBSY;
+	}
+
 	if (inode->i_size < offset) {
 		unsigned long limit;
 
diff --git a/fs/open.c b/fs/open.c
index 35bb784763a4..92d89ec2d6b3 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -292,6 +292,12 @@ int vfs_fallocate(struct file *file, int mode, loff_t offset, loff_t len)
 		return -ETXTBSY;
 
 	/*
+	 * We cannot allow any allocation changes on an iomap sealed file
+	 */
+	if (IS_IOMAP_SEALED(inode))
+		return -ETXTBSY;
+
+	/*
 	 * Revalidate the write permissions, in case security policy has
 	 * changed since the files were opened.
 	 */
diff --git a/fs/read_write.c b/fs/read_write.c
index 0cc7033aa413..55700ca85f7e 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1706,6 +1706,9 @@ int vfs_clone_file_prep_inodes(struct inode *inode_in, loff_t pos_in,
 	if (IS_SWAPFILE(inode_in) || IS_SWAPFILE(inode_out))
 		return -ETXTBSY;
 
+	if (IS_IOMAP_SEALED(inode_in) || IS_IOMAP_SEALED(inode_out))
+		return -ETXTBSY;
+
 	/* Don't reflink dirs, pipes, sockets... */
 	if (S_ISDIR(inode_in->i_mode) || S_ISDIR(inode_out->i_mode))
 		return -EISDIR;
diff --git a/fs/xfs/libxfs/xfs_bmap.c b/fs/xfs/libxfs/xfs_bmap.c
index a2d64666cdd4..84d8ee9f414c 100644
--- a/fs/xfs/libxfs/xfs_bmap.c
+++ b/fs/xfs/libxfs/xfs_bmap.c
@@ -4481,6 +4481,11 @@ xfs_bmapi_write(
 	if (XFS_FORCED_SHUTDOWN(mp))
 		return -EIO;
 
+	/* fail any attempts to mutate data extents */
+	if (IS_IOMAP_SEALED(VFS_I(ip))
+			&& !(flags & (XFS_BMAPI_METADATA | XFS_BMAPI_ATTRFORK)))
+		return -ETXTBSY;
+
 	ifp = XFS_IFORK_PTR(ip, whichfork);
 
 	XFS_STATS_INC(mp, xs_blk_mapw);
diff --git a/fs/xfs/xfs_bmap_util.c b/fs/xfs/xfs_bmap_util.c
index 93e955262d07..ef4c4e8b0f58 100644
--- a/fs/xfs/xfs_bmap_util.c
+++ b/fs/xfs/xfs_bmap_util.c
@@ -1294,6 +1294,9 @@ xfs_free_file_space(
 
 	trace_xfs_free_file_space(ip);
 
+	if (IS_IOMAP_SEALED(VFS_I(ip)))
+		return -ETXTBSY;
+
 	error = xfs_qm_dqattach(ip, 0);
 	if (error)
 		return error;
diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index e75c40a47b7d..b716d184ae9a 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -1755,6 +1755,12 @@ xfs_ioc_swapext(
 		goto out_put_tmp_file;
 	}
 
+	if (IS_IOMAP_SEALED(file_inode(f.file)) ||
+	    IS_IOMAP_SEALED(file_inode(tmp.file))) {
+		error = -EINVAL;
+		goto out_put_tmp_file;
+	}
+
 	/*
 	 * We need to ensure that the fds passed in point to XFS inodes
 	 * before we cast and access them as XFS structures as we have no
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 6e1fd5d21248..1104e5df39ef 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1829,6 +1829,7 @@ struct super_operations {
 #else
 #define S_DAX		0	/* Make all the DAX code disappear */
 #endif
+#define S_IOMAP_SEALED 16384 /* logical-to-physical extent map is fixed */
 
 /*
  * Note that nosuid etc flags are inode-specific: setting some file-system
@@ -1867,6 +1868,7 @@ struct super_operations {
 #define IS_AUTOMOUNT(inode)	((inode)->i_flags & S_AUTOMOUNT)
 #define IS_NOSEC(inode)		((inode)->i_flags & S_NOSEC)
 #define IS_DAX(inode)		((inode)->i_flags & S_DAX)
+#define IS_IOMAP_SEALED(inode) ((inode)->i_flags & S_IOMAP_SEALED)
 
 #define IS_WHITEOUT(inode)	(S_ISCHR(inode->i_mode) && \
 				 (inode)->i_rdev == WHITEOUT_DEV)
diff --git a/mm/filemap.c b/mm/filemap.c
index a49702445ce0..4c929961b538 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2806,6 +2806,11 @@ inline ssize_t generic_write_checks(struct kiocb *iocb, struct iov_iter *from)
 	if (unlikely(pos >= inode->i_sb->s_maxbytes))
 		return -EFBIG;
 
+	/* Are we about to mutate the block map on a sealed file? */
+	if (IS_IOMAP_SEALED(inode)
+			&& (pos + iov_iter_count(from) > i_size_read(inode)))
+		return -ETXTBSY;
+
 	iov_iter_truncate(from, inode->i_sb->s_maxbytes - pos);
 	return iov_iter_count(from);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
