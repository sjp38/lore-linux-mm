Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0FFBD6B0266
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 19:14:34 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 6so18553258pgh.0
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 16:14:34 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id u6si4611766pfh.458.2017.09.25.16.14.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Sep 2017 16:14:32 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH 7/7] xfs: re-enable XFS per-inode DAX
Date: Mon, 25 Sep 2017 17:14:04 -0600
Message-Id: <20170925231404.32723-8-ross.zwisler@linux.intel.com>
In-Reply-To: <20170925231404.32723-1-ross.zwisler@linux.intel.com>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

Re-enable the XFS per-inode DAX flag, preventing S_DAX from changing when
any mappings are present.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/xfs/xfs_ioctl.c | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index 386b437..7a24dd5 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -1012,12 +1012,10 @@ xfs_diflags_to_linux(
 		inode->i_flags |= S_NOATIME;
 	else
 		inode->i_flags &= ~S_NOATIME;
-#if 0	/* disabled until the flag switching races are sorted out */
 	if ((xflags & FS_XFLAG_DAX) || (ip->i_mount->m_flags & XFS_MOUNT_DAX))
 		inode->i_flags |= S_DAX;
 	else
 		inode->i_flags &= ~S_DAX;
-#endif
 }
 
 static bool
@@ -1049,6 +1047,8 @@ xfs_ioctl_setattr_xflags(
 {
 	struct xfs_mount	*mp = ip->i_mount;
 	uint64_t		di_flags2;
+	struct address_space	*mapping = VFS_I(ip)->i_mapping;
+	bool			dax_changing;
 
 	/* Can't change realtime flag if any extents are allocated. */
 	if ((ip->i_d.di_nextents || ip->i_delayed_blks) &&
@@ -1084,10 +1084,23 @@ xfs_ioctl_setattr_xflags(
 	if (di_flags2 && ip->i_d.di_version < 3)
 		return -EINVAL;
 
+	dax_changing = xfs_is_dax_state_changing(fa->fsx_xflags, ip);
+	if (dax_changing) {
+		i_mmap_lock_read(mapping);
+		if (mapping_mapped(mapping)) {
+			i_mmap_unlock_read(mapping);
+			return -EBUSY;
+		}
+	}
+
 	ip->i_d.di_flags = xfs_flags2diflags(ip, fa->fsx_xflags);
 	ip->i_d.di_flags2 = di_flags2;
 
 	xfs_diflags_to_linux(ip);
+
+	if (dax_changing)
+		i_mmap_unlock_read(mapping);
+
 	xfs_trans_ichgtime(tp, ip, XFS_ICHGTIME_CHG);
 	xfs_trans_log_inode(tp, ip, XFS_ILOG_CORE);
 	XFS_STATS_INC(mp, xs_ig_attrchg);
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
