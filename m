Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 84F9D44043B
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 15:36:07 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id x58so42650217qtc.0
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 12:36:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e55si2784654qte.49.2017.06.16.12.36.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 12:36:06 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v7 22/22] btrfs: minimal conversion to errseq_t writeback error reporting on fsync
Date: Fri, 16 Jun 2017 15:34:27 -0400
Message-Id: <20170616193427.13955-23-jlayton@redhat.com>
In-Reply-To: <20170616193427.13955-1-jlayton@redhat.com>
References: <20170616193427.13955-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

Just check and advance the errseq_t in the file before returning.
Internal callers of filemap_* functions are left as-is.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/btrfs/file.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index 0f102a1b851f..609226beea43 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -2017,7 +2017,7 @@ int btrfs_sync_file(struct file *file, loff_t start, loff_t end, int datasync)
 	struct btrfs_root *root = BTRFS_I(inode)->root;
 	struct btrfs_trans_handle *trans;
 	struct btrfs_log_ctx ctx;
-	int ret = 0;
+	int ret = 0, err;
 	bool full_sync = 0;
 	u64 len;
 
@@ -2036,7 +2036,7 @@ int btrfs_sync_file(struct file *file, loff_t start, loff_t end, int datasync)
 	 */
 	ret = start_ordered_ops(inode, start, end);
 	if (ret)
-		return ret;
+		goto out;
 
 	inode_lock(inode);
 	atomic_inc(&root->log_batch);
@@ -2233,6 +2233,9 @@ int btrfs_sync_file(struct file *file, loff_t start, loff_t end, int datasync)
 		ret = btrfs_end_transaction(trans);
 	}
 out:
+	err = filemap_report_wb_err(file);
+	if (!ret)
+		ret = err;
 	return ret > 0 ? -EIO : ret;
 }
 
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
