Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC17444043B
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 15:35:58 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id s33so42332185qtg.1
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 12:35:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m14si2729903qtc.346.2017.06.16.12.35.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 12:35:58 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v7 17/22] ext4: use errseq_t based error handling for reporting data writeback errors
Date: Fri, 16 Jun 2017 15:34:22 -0400
Message-Id: <20170616193427.13955-18-jlayton@redhat.com>
In-Reply-To: <20170616193427.13955-1-jlayton@redhat.com>
References: <20170616193427.13955-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

Add a call to filemap_report_wb_err at the end of ext4_sync_file. This
will ensure that we check and advance the errseq_t in the file, which
allows us to track and report errors on all open fds when they occur.

Note that metadata writeback errors are not yet reported on all fds at
this point. That will be added in a later patch.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/ext4/fsync.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/fs/ext4/fsync.c b/fs/ext4/fsync.c
index 9d549608fd30..03d6259d8662 100644
--- a/fs/ext4/fsync.c
+++ b/fs/ext4/fsync.c
@@ -100,8 +100,10 @@ int ext4_sync_file(struct file *file, loff_t start, loff_t end, int datasync)
 	tid_t commit_tid;
 	bool needs_barrier = false;
 
-	if (unlikely(ext4_forced_shutdown(EXT4_SB(inode->i_sb))))
-		return -EIO;
+	if (unlikely(ext4_forced_shutdown(EXT4_SB(inode->i_sb)))) {
+		ret = -EIO;
+		goto out;
+	}
 
 	J_ASSERT(ext4_journal_current_handle() == NULL);
 
@@ -126,7 +128,8 @@ int ext4_sync_file(struct file *file, loff_t start, loff_t end, int datasync)
 
 	ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
 	if (ret)
-		return ret;
+		goto out;
+
 	/*
 	 * data=writeback,ordered:
 	 *  The caller's filemap_fdatawrite()/wait will sync the data.
@@ -152,12 +155,16 @@ int ext4_sync_file(struct file *file, loff_t start, loff_t end, int datasync)
 		needs_barrier = true;
 	ret = jbd2_complete_transaction(journal, commit_tid);
 	if (needs_barrier) {
-	issue_flush:
+issue_flush:
 		err = blkdev_issue_flush(inode->i_sb->s_bdev, GFP_KERNEL, NULL);
 		if (!ret)
 			ret = err;
 	}
 out:
+	/* Was there a writeback error of the data since last fsync? */
+	err = filemap_report_wb_err(file);
+	if (!ret)
+		ret = err;
 	trace_ext4_sync_file_exit(inode, ret);
 	return ret;
 }
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
