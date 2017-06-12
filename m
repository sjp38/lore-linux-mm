Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id BAAE96B03A8
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 08:23:47 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id u51so11519145qte.15
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 05:23:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s4si8381195qkf.202.2017.06.12.05.23.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jun 2017 05:23:47 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v6 15/20] fs: have call_fsync call filemap_report_wb_err if FS_WB_ERRSEQ is set
Date: Mon, 12 Jun 2017 08:23:11 -0400
Message-Id: <20170612122316.13244-20-jlayton@redhat.com>
In-Reply-To: <20170612122316.13244-1-jlayton@redhat.com>
References: <20170612122316.13244-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

Allow filesystems to opt-in to a final check of wb_err if FS_WB_ERRSEQ
is set. Technically, we could just plumb these calls into all of the
fsync operations, but I think this means less code, changes and churn.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/fs.h | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 17ba6284ab14..ef3feeec80b2 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1742,12 +1742,6 @@ static inline int call_mmap(struct file *file, struct vm_area_struct *vma)
 	return file->f_op->mmap(file, vma);
 }
 
-static inline int call_fsync(struct file *file, loff_t start, loff_t end,
-			     int datasync)
-{
-	return file->f_op->fsync(file, start, end, datasync);
-}
-
 ssize_t rw_copy_check_uvector(int type, const struct iovec __user * uvector,
 			      unsigned long nr_segs, unsigned long fast_segs,
 			      struct iovec *fast_pointer,
@@ -2583,6 +2577,20 @@ static inline errseq_t filemap_sample_wb_err(struct address_space *mapping)
 	return errseq_sample(&mapping->wb_err);
 }
 
+static inline int call_fsync(struct file *file, loff_t start, loff_t end,
+			     int datasync)
+{
+	int ret;
+
+	ret = file->f_op->fsync(file, start, end, datasync);
+	if (file->f_mapping->host->i_sb->s_type->fs_flags & FS_WB_ERRSEQ) {
+		int ret2 = filemap_report_wb_err(file);
+		if (!ret)
+			ret = ret2;
+	}
+	return ret;
+}
+
 extern int vfs_fsync_range(struct file *file, loff_t start, loff_t end,
 			   int datasync);
 extern int vfs_fsync(struct file *file, int datasync);
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
