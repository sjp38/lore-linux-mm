Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1A34A6B0010
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 20:11:05 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id i189-v6so2542361pge.6
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 17:11:05 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id o5-v6si22612144pgk.300.2018.10.09.17.11.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 17:11:03 -0700 (PDT)
Subject: [PATCH 03/25] xfs: zero posteof blocks when cloning above eof
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Tue, 09 Oct 2018 17:10:59 -0700
Message-ID: <153913025949.32295.17548471289910846210.stgit@magnolia>
In-Reply-To: <153913023835.32295.13962696655740190941.stgit@magnolia>
References: <153913023835.32295.13962696655740190941.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Zorro Lang <zlang@redhat.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, Dave Chinner <dchinner@redhat.com>, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

From: Darrick J. Wong <darrick.wong@oracle.com>

When we're reflinking between two files and the destination file range
is well beyond the destination file's EOF marker, zero any posteof
speculative preallocations in the destination file so that we don't
expose stale disk contents.  The previous strategy of trying to clear
the preallocations does not work if the destination file has the
PREALLOC flag set.

Uncovered by shared/010.

Reported-by: Zorro Lang <zlang@redhat.com>
Bugzilla-id: https://bugzilla.kernel.org/show_bug.cgi?id=201259
Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
Reviewed-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/xfs_reflink.c |   33 +++++++++++++++++++++++++--------
 1 file changed, 25 insertions(+), 8 deletions(-)


diff --git a/fs/xfs/xfs_reflink.c b/fs/xfs/xfs_reflink.c
index ebd65d3e31f3..cbb359e68a72 100644
--- a/fs/xfs/xfs_reflink.c
+++ b/fs/xfs/xfs_reflink.c
@@ -1240,6 +1240,26 @@ xfs_reflink_remap_unlock(
 		inode_unlock_shared(inode_in);
 }
 
+/*
+ * If we're reflinking to a point past the destination file's EOF, we must
+ * zero any speculative post-EOF preallocations that sit between the old EOF
+ * and the destination file offset.
+ */
+static int
+xfs_reflink_zero_posteof(
+	struct xfs_inode	*ip,
+	loff_t			pos)
+{
+	loff_t			isize = i_size_read(VFS_I(ip));
+
+	if (pos <= isize)
+		return 0;
+
+	trace_xfs_zero_eof(ip, isize, pos - isize);
+	return iomap_zero_range(VFS_I(ip), isize, pos - isize, NULL,
+			&xfs_iomap_ops);
+}
+
 /*
  * Prepare two files for range cloning.  Upon a successful return both inodes
  * will have the iolock and mmaplock held, the page cache of the out file
@@ -1293,15 +1313,12 @@ xfs_reflink_remap_prep(
 		goto out_unlock;
 
 	/*
-	 * Clear out post-eof preallocations because we don't have page cache
-	 * backing the delayed allocations and they'll never get freed on
-	 * their own.
+	 * Zero existing post-eof speculative preallocations in the destination
+	 * file.
 	 */
-	if (xfs_can_free_eofblocks(dest, true)) {
-		ret = xfs_free_eofblocks(dest);
-		if (ret)
-			goto out_unlock;
-	}
+	ret = xfs_reflink_zero_posteof(dest, pos_out);
+	if (ret)
+		goto out_unlock;
 
 	/* Set flags and remap blocks. */
 	ret = xfs_reflink_set_inode_flag(src, dest);
