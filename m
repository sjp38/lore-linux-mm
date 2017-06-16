Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 38BAB83294
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 15:34:39 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id m57so42132972qta.9
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 12:34:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b12si2706355qkg.167.2017.06.16.12.34.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 12:34:38 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v7 03/22] fs: check for writeback errors after syncing out buffers in generic_file_fsync
Date: Fri, 16 Jun 2017 15:34:08 -0400
Message-Id: <20170616193427.13955-4-jlayton@redhat.com>
In-Reply-To: <20170616193427.13955-1-jlayton@redhat.com>
References: <20170616193427.13955-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

ext2 currently does a test+clear of the AS_EIO flag, which is
is problematic for some coming changes.

What we really need to do instead is call filemap_check_errors
in __generic_file_fsync after syncing out the buffers. That
will be sufficient for this case, and help other callers detect
these errors properly as well.

With that, we don't need to twiddle it in ext2.

Suggested-by: Jan Kara <jack@suse.cz>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/ext2/file.c | 2 +-
 fs/libfs.c     | 3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index b21891a6bfca..ed00e7ae0ef3 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -177,7 +177,7 @@ int ext2_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	struct address_space *mapping = sb->s_bdev->bd_inode->i_mapping;
 
 	ret = generic_file_fsync(file, start, end, datasync);
-	if (ret == -EIO || test_and_clear_bit(AS_EIO, &mapping->flags)) {
+	if (ret == -EIO) {
 		/* We don't really know where the IO error happened... */
 		ext2_error(sb, __func__,
 			   "detected IO error when writing metadata buffers");
diff --git a/fs/libfs.c b/fs/libfs.c
index a04395334bb1..1dec90819366 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -991,7 +991,8 @@ int __generic_file_fsync(struct file *file, loff_t start, loff_t end,
 
 out:
 	inode_unlock(inode);
-	return ret;
+	err = filemap_check_errors(inode->i_mapping);
+	return ret ? ret : err;
 }
 EXPORT_SYMBOL(__generic_file_fsync);
 
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
