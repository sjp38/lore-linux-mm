Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 265A16B0069
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 19:14:26 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 6so18552776pgh.0
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 16:14:26 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 142si4752383pgg.395.2017.09.25.16.14.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Sep 2017 16:14:24 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH 1/7] xfs: always use DAX if mount option is used
Date: Mon, 25 Sep 2017 17:13:58 -0600
Message-Id: <20170925231404.32723-2-ross.zwisler@linux.intel.com>
In-Reply-To: <20170925231404.32723-1-ross.zwisler@linux.intel.com>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

Before support for the per-inode DAX flag was disabled the XFS the code had
an issue where the user couldn't reliably tell whether or not DAX was being
used to service page faults and I/O when the DAX mount option was used.  In
this case each inode within the mounted filesystem started with S_DAX set
due to the mount option, but it could be cleared if someone touched the
individual inode flag.

For example (v4.13 and before):

  # mount | grep dax
  /dev/pmem0 on /mnt type xfs
  (rw,relatime,seclabel,attr2,dax,inode64,sunit=4096,swidth=4096,noquota)

  # touch /mnt/a /mnt/b   # both files currently use DAX

  # xfs_io -c "lsattr" /mnt/*  # neither has the DAX inode option set
  ----------e----- /mnt/a
  ----------e----- /mnt/b

  # xfs_io -c "chattr -x" /mnt/a  # this clears S_DAX for /mnt/a

  # xfs_io -c "lsattr" /mnt/*
  ----------e----- /mnt/a
  ----------e----- /mnt/b

We end up with both /mnt/a and /mnt/b looking identical from the point of
view of the mount option and from lsattr, but one is using DAX and the
other is not.

Fix this by always doing DAX I/O when either the mount option is set or
when the DAX inode flag is set.  This means that DAX will always be used
for all inodes on a filesystem mounted with -o dax, making the usage
reliable and detectable.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/xfs/xfs_ioctl.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
index 5049e8a..26faeb9 100644
--- a/fs/xfs/xfs_ioctl.c
+++ b/fs/xfs/xfs_ioctl.c
@@ -1013,7 +1013,7 @@ xfs_diflags_to_linux(
 	else
 		inode->i_flags &= ~S_NOATIME;
 #if 0	/* disabled until the flag switching races are sorted out */
-	if (xflags & FS_XFLAG_DAX)
+	if ((xflags & FS_XFLAG_DAX) || (ip->i_mount->m_flags & XFS_MOUNT_DAX))
 		inode->i_flags |= S_DAX;
 	else
 		inode->i_flags &= ~S_DAX;
@@ -1104,7 +1104,14 @@ xfs_ioctl_setattr_dax_invalidate(
 			return -EINVAL;
 	}
 
-	/* If the DAX state is not changing, we have nothing to do here. */
+	/*
+	 * If the DAX state is not changing, we have nothing to do here.  If
+	 * the DAX mount option was used we will update the DAX inode flag as
+	 * the user requested but we will continue to use DAX for I/O and page
+	 * faults regardless of how the inode flag is set.
+	 */
+	if (ip->i_mount->m_flags & XFS_MOUNT_DAX)
+		return 0;
 	if ((fa->fsx_xflags & FS_XFLAG_DAX) && IS_DAX(inode))
 		return 0;
 	if (!(fa->fsx_xflags & FS_XFLAG_DAX) && !IS_DAX(inode))
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
