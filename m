Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6C1EC6B0313
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 09:20:12 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id t188so1200795oih.15
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 06:20:12 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d130si3474743oig.22.2017.06.29.06.20.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 06:20:11 -0700 (PDT)
From: jlayton@kernel.org
Subject: [PATCH v8 05/18] jbd2: don't clear and reset errors after waiting on writeback
Date: Thu, 29 Jun 2017 09:19:41 -0400
Message-Id: <20170629131954.28733-6-jlayton@kernel.org>
In-Reply-To: <20170629131954.28733-1-jlayton@kernel.org>
References: <20170629131954.28733-1-jlayton@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, Liu Bo <bo.li.liu@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

From: Jeff Layton <jlayton@redhat.com>

Resetting this flag is almost certainly racy, and will be problematic
with some coming changes.

Make filemap_fdatawait_keep_errors return int, but not clear the flag(s).
Have jbd2 call it instead of filemap_fdatawait and don't attempt to
re-set the error flag if it fails.

Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Carlos Maiolino <cmaiolino@redhat.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/jbd2/commit.c   | 16 ++++------------
 include/linux/fs.h |  2 +-
 mm/filemap.c       | 16 ++++++++++++++--
 3 files changed, 19 insertions(+), 15 deletions(-)

diff --git a/fs/jbd2/commit.c b/fs/jbd2/commit.c
index b6b194ec1b4f..3c1c31321d9b 100644
--- a/fs/jbd2/commit.c
+++ b/fs/jbd2/commit.c
@@ -263,18 +263,10 @@ static int journal_finish_inode_data_buffers(journal_t *journal,
 			continue;
 		jinode->i_flags |= JI_COMMIT_RUNNING;
 		spin_unlock(&journal->j_list_lock);
-		err = filemap_fdatawait(jinode->i_vfs_inode->i_mapping);
-		if (err) {
-			/*
-			 * Because AS_EIO is cleared by
-			 * filemap_fdatawait_range(), set it again so
-			 * that user process can get -EIO from fsync().
-			 */
-			mapping_set_error(jinode->i_vfs_inode->i_mapping, -EIO);
-
-			if (!ret)
-				ret = err;
-		}
+		err = filemap_fdatawait_keep_errors(
+				jinode->i_vfs_inode->i_mapping);
+		if (!ret)
+			ret = err;
 		spin_lock(&journal->j_list_lock);
 		jinode->i_flags &= ~JI_COMMIT_RUNNING;
 		smp_mb();
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 4ff4498297fa..74872c0f1c07 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2508,7 +2508,7 @@ extern int write_inode_now(struct inode *, int);
 extern int filemap_fdatawrite(struct address_space *);
 extern int filemap_flush(struct address_space *);
 extern int filemap_fdatawait(struct address_space *);
-extern void filemap_fdatawait_keep_errors(struct address_space *);
+extern int filemap_fdatawait_keep_errors(struct address_space *mapping);
 extern int filemap_fdatawait_range(struct address_space *, loff_t lstart,
 				   loff_t lend);
 extern int filemap_write_and_wait(struct address_space *mapping);
diff --git a/mm/filemap.c b/mm/filemap.c
index 6f1be573a5e6..e5711b2728f4 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -309,6 +309,16 @@ int filemap_check_errors(struct address_space *mapping)
 }
 EXPORT_SYMBOL(filemap_check_errors);
 
+static int filemap_check_and_keep_errors(struct address_space *mapping)
+{
+	/* Check for outstanding write errors */
+	if (test_bit(AS_EIO, &mapping->flags))
+		return -EIO;
+	if (test_bit(AS_ENOSPC, &mapping->flags))
+		return -ENOSPC;
+	return 0;
+}
+
 /**
  * __filemap_fdatawrite_range - start writeback on mapping dirty pages in range
  * @mapping:	address space structure to write
@@ -453,15 +463,17 @@ EXPORT_SYMBOL(filemap_fdatawait_range);
  * call sites are system-wide / filesystem-wide data flushers: e.g. sync(2),
  * fsfreeze(8)
  */
-void filemap_fdatawait_keep_errors(struct address_space *mapping)
+int filemap_fdatawait_keep_errors(struct address_space *mapping)
 {
 	loff_t i_size = i_size_read(mapping->host);
 
 	if (i_size == 0)
-		return;
+		return 0;
 
 	__filemap_fdatawait_range(mapping, 0, i_size - 1);
+	return filemap_check_and_keep_errors(mapping);
 }
+EXPORT_SYMBOL(filemap_fdatawait_keep_errors);
 
 /**
  * filemap_fdatawait - wait for all under-writeback pages to complete
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
