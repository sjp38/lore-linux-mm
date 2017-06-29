Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 12DC76B02C3
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 09:20:02 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id t194so2615474oif.8
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 06:20:02 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d6si3434572oib.386.2017.06.29.06.20.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 06:20:01 -0700 (PDT)
From: jlayton@kernel.org
Subject: [PATCH v8 01/18] fs: remove call_fsync helper function
Date: Thu, 29 Jun 2017 09:19:37 -0400
Message-Id: <20170629131954.28733-2-jlayton@kernel.org>
In-Reply-To: <20170629131954.28733-1-jlayton@kernel.org>
References: <20170629131954.28733-1-jlayton@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, Liu Bo <bo.li.liu@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

From: Jeff Layton <jlayton@redhat.com>

Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Carlos Maiolino <cmaiolino@redhat.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/sync.c          | 2 +-
 include/linux/fs.h | 6 ------
 ipc/shm.c          | 2 +-
 3 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/fs/sync.c b/fs/sync.c
index 11ba023434b1..2a54c1f22035 100644
--- a/fs/sync.c
+++ b/fs/sync.c
@@ -192,7 +192,7 @@ int vfs_fsync_range(struct file *file, loff_t start, loff_t end, int datasync)
 		spin_unlock(&inode->i_lock);
 		mark_inode_dirty_sync(inode);
 	}
-	return call_fsync(file, start, end, datasync);
+	return file->f_op->fsync(file, start, end, datasync);
 }
 EXPORT_SYMBOL(vfs_fsync_range);
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 1e53cd281437..4ff4498297fa 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1739,12 +1739,6 @@ static inline int call_mmap(struct file *file, struct vm_area_struct *vma)
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
diff --git a/ipc/shm.c b/ipc/shm.c
index 34c4344e8d4b..f45c7959b264 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -452,7 +452,7 @@ static int shm_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 
 	if (!sfd->file->f_op->fsync)
 		return -EINVAL;
-	return call_fsync(sfd->file, start, end, datasync);
+	return sfd->file->f_op->fsync(sfd->file, start, end, datasync);
 }
 
 static long shm_fallocate(struct file *file, int mode, loff_t offset,
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
