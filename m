Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id BE4F844043B
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 15:36:05 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id v20so42576712qtg.3
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 12:36:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i21si2795398qtc.125.2017.06.16.12.36.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 12:36:04 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v7 21/22] xfs: minimal conversion to errseq_t writeback error reporting
Date: Fri, 16 Jun 2017 15:34:26 -0400
Message-Id: <20170616193427.13955-22-jlayton@redhat.com>
In-Reply-To: <20170616193427.13955-1-jlayton@redhat.com>
References: <20170616193427.13955-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

Just check and advance the data errseq_t in struct file before
before returning from fsync on normal files. Internal filemap_*
callers are left as-is.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/xfs/xfs_file.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 5fb5a0958a14..bc3b1575e8db 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -134,7 +134,7 @@ xfs_file_fsync(
 	struct inode		*inode = file->f_mapping->host;
 	struct xfs_inode	*ip = XFS_I(inode);
 	struct xfs_mount	*mp = ip->i_mount;
-	int			error = 0;
+	int			error = 0, err2;
 	int			log_flushed = 0;
 	xfs_lsn_t		lsn = 0;
 
@@ -142,10 +142,12 @@ xfs_file_fsync(
 
 	error = filemap_write_and_wait_range(inode->i_mapping, start, end);
 	if (error)
-		return error;
+		goto out;
 
-	if (XFS_FORCED_SHUTDOWN(mp))
-		return -EIO;
+	if (XFS_FORCED_SHUTDOWN(mp)) {
+		error = -EIO;
+		goto out;
+	}
 
 	xfs_iflags_clear(ip, XFS_ITRUNCATED);
 
@@ -197,6 +199,11 @@ xfs_file_fsync(
 	    mp->m_logdev_targp == mp->m_ddev_targp)
 		xfs_blkdev_issue_flush(mp->m_ddev_targp);
 
+out:
+	err2 = filemap_report_wb_err(file);
+	if (!error)
+		error = err2;
+
 	return error;
 }
 
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
