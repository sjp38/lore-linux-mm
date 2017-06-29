Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id C68126B03A7
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 09:20:45 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id 191so21740965oii.4
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 06:20:45 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n206si3353800oif.283.2017.06.29.06.20.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 06:20:45 -0700 (PDT)
From: jlayton@kernel.org
Subject: [PATCH v8 18/18] btrfs: minimal conversion to errseq_t writeback error reporting on fsync
Date: Thu, 29 Jun 2017 09:19:54 -0400
Message-Id: <20170629131954.28733-19-jlayton@kernel.org>
In-Reply-To: <20170629131954.28733-1-jlayton@kernel.org>
References: <20170629131954.28733-1-jlayton@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, Liu Bo <bo.li.liu@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

From: Jeff Layton <jlayton@redhat.com>

Just check and advance the errseq_t in the file before returning.
Internal callers of filemap_* functions are left as-is.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/btrfs/file.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index da1096eb1a40..1f57e1a523d9 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -2011,7 +2011,7 @@ int btrfs_sync_file(struct file *file, loff_t start, loff_t end, int datasync)
 	struct btrfs_root *root = BTRFS_I(inode)->root;
 	struct btrfs_trans_handle *trans;
 	struct btrfs_log_ctx ctx;
-	int ret = 0;
+	int ret = 0, err;
 	bool full_sync = 0;
 	u64 len;
 
@@ -2030,7 +2030,7 @@ int btrfs_sync_file(struct file *file, loff_t start, loff_t end, int datasync)
 	 */
 	ret = start_ordered_ops(inode, start, end);
 	if (ret)
-		return ret;
+		goto out;
 
 	inode_lock(inode);
 	atomic_inc(&root->log_batch);
@@ -2227,6 +2227,9 @@ int btrfs_sync_file(struct file *file, loff_t start, loff_t end, int datasync)
 		ret = btrfs_end_transaction(trans);
 	}
 out:
+	err = file_check_and_advance_wb_err(file);
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
