Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 771432803FE
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 19:55:12 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id r133so20217784pgr.6
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 16:55:12 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id u6si2025768plj.127.2017.08.23.16.55.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 16:55:10 -0700 (PDT)
Subject: [PATCH v6 2/5] fs, xfs: introduce S_IOMAP_SEALED
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 23 Aug 2017 16:48:45 -0700
Message-ID: <150353212577.5039.14069456126848863439.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150353211413.5039.5228914877418362329.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150353211413.5039.5228914877418362329.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-api@vger.kernel.org, linux-nvdimm@lists.01.org, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, luto@kernel.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

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
index c09c16b1ad3b..241f3a272f49 100644
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
index 9c0c7a920304..845587e6928b 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -1730,6 +1730,12 @@ xfs_ioc_swapext(
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
index 47249bbe973c..33d1ee8f51be 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1830,6 +1830,7 @@ struct super_operations {
 #else
 #define S_DAX		0	/* Make all the DAX code disappear */
 #endif
+#define S_IOMAP_SEALED 16384 /* logical-to-physical extent map is fixed */
 
 /*
  * Note that nosuid etc flags are inode-specific: setting some file-system
@@ -1868,6 +1869,7 @@ struct super_operations {
 #define IS_AUTOMOUNT(inode)	((inode)->i_flags & S_AUTOMOUNT)
 #define IS_NOSEC(inode)		((inode)->i_flags & S_NOSEC)
 #define IS_DAX(inode)		((inode)->i_flags & S_DAX)
+#define IS_IOMAP_SEALED(inode) ((inode)->i_flags & S_IOMAP_SEALED)
 
 #define IS_WHITEOUT(inode)	(S_ISCHR(inode->i_mode) && \
 				 (inode)->i_rdev == WHITEOUT_DEV)
diff --git a/mm/filemap.c b/mm/filemap.c
index 2457e34d10e0..4cbcf9d589fa 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2810,6 +2810,11 @@ inline ssize_t generic_write_checks(struct kiocb *iocb, struct iov_iter *from)
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
