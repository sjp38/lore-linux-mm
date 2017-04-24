Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 83EAE6B02F4
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:23:34 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id j29so40429302qtj.19
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 06:23:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 54si10595442qtv.179.2017.04.24.06.23.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 06:23:33 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v3 04/20] fs: check for writeback errors after syncing out buffers in generic_file_fsync
Date: Mon, 24 Apr 2017 09:22:43 -0400
Message-Id: <20170424132259.8680-5-jlayton@redhat.com>
In-Reply-To: <20170424132259.8680-1-jlayton@redhat.com>
References: <20170424132259.8680-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, osd-dev@open-osd.org, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk

ext2 currently does a test+clear of the AS_EIO flag, which is
is problematic for some coming changes.

What we really need to do instead is call filemap_check_errors
in __generic_file_fsync after syncing out the buffers. That
will be sufficient for this case, and help other callers detect
these errors properly as well.

With that, we don't need to twiddle it in ext2.

Suggested-by: Jan Kara <jack@suse.cz>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
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
index a8b62e5d43a9..12a48ee442d3 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -991,7 +991,8 @@ int __generic_file_fsync(struct file *file, loff_t start, loff_t end,
 
 out:
 	inode_unlock(inode);
-	return ret;
+	err = filemap_check_errors(inode->i_mapping);
+	return ret ? : err;
 }
 EXPORT_SYMBOL(__generic_file_fsync);
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
