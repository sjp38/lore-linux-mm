Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id A6D7683294
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 15:35:35 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id o21so42433520qtb.13
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 12:35:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z195si2632810qka.55.2017.06.16.12.35.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 12:35:34 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v7 09/22] fs: always sync metadata in __generic_file_fsync
Date: Fri, 16 Jun 2017 15:34:14 -0400
Message-Id: <20170616193427.13955-10-jlayton@redhat.com>
In-Reply-To: <20170616193427.13955-1-jlayton@redhat.com>
References: <20170616193427.13955-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

If there were previously both metadata and data writeback errors when
fsync is called, then it will currently take two calls to fsync() to
clear them on some filesystems.

The problem is in __generic_file_fsync, which won't try to write back
the metadata if the data flush fails. Fix this by always attempting to
write out the metadata, even when a flush of the data reports an error.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/libfs.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/libfs.c b/fs/libfs.c
index 1dec90819366..c93e77ecb49c 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -974,12 +974,12 @@ int __generic_file_fsync(struct file *file, loff_t start, loff_t end,
 	int err;
 	int ret;
 
-	err = filemap_write_and_wait_range(inode->i_mapping, start, end);
-	if (err)
-		return err;
+	ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
 
 	inode_lock(inode);
-	ret = sync_mapping_buffers(inode->i_mapping);
+	err = sync_mapping_buffers(inode->i_mapping);
+	if (ret == 0)
+		ret = err;
 	if (!(inode->i_state & I_DIRTY_ALL))
 		goto out;
 	if (datasync && !(inode->i_state & I_DIRTY_DATASYNC))
@@ -988,7 +988,6 @@ int __generic_file_fsync(struct file *file, loff_t start, loff_t end,
 	err = sync_inode_metadata(inode, 1);
 	if (ret == 0)
 		ret = err;
-
 out:
 	inode_unlock(inode);
 	err = filemap_check_errors(inode->i_mapping);
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
