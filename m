Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 422826B0081
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 07:52:30 -0400 (EDT)
Message-ID: <51C832F8.2090707@oracle.com>
Date: Mon, 24 Jun 2013 19:52:24 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: [RFC PATCH] vfs: export lseek_execute() to modules
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org

From: Jie Liu <jeff.liu@oracle.com>

For those file systems(btrfs/ext4/xfs/ocfs2/tmpfs) that support
SEEK_DATA/SEEK_HOLE functions, we end up handling the similar
matter in lseek_execute() to verify the final offset.

To reduce the duplications, this patch make lseek_execute() public
accessible so that we can call it directly from them.

Thanks Dave Chinner for this suggestion.

Signed-off-by: Jie Liu <jeff.liu@oracle.com>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Chris Mason <chris.mason@fusionio.com>
Cc: Josef Bacik <jbacik@fusionio.com>
Cc: Ben Myers <bpm@sgi.com>
Cc: Ted Tso <tytso@mit.edu>
Cc: Hugh Dickins <hughd@google.com>
Cc: Mark Fasheh <mfasheh@suse.com>
Cc: Joel Becker <jlbec@evilplan.org>
---
 fs/btrfs/file.c    |   15 +--------------
 fs/ext4/file.c     |   24 ++----------------------
 fs/ocfs2/file.c    |   12 +-----------
 fs/read_write.c    |    5 +++--
 fs/xfs/xfs_file.c  |    6 ++----
 include/linux/fs.h |    2 ++
 mm/shmem.c         |    5 +----
 7 files changed, 12 insertions(+), 57 deletions(-)

diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index 4205ba7..a56eced 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -2425,20 +2425,7 @@ static loff_t btrfs_file_llseek(struct file *file, loff_t offset, int whence)
 		}
 	}
 
-	if (offset < 0 && !(file->f_mode & FMODE_UNSIGNED_OFFSET)) {
-		offset = -EINVAL;
-		goto out;
-	}
-	if (offset > inode->i_sb->s_maxbytes) {
-		offset = -EINVAL;
-		goto out;
-	}
-
-	/* Special lock needed here? */
-	if (offset != file->f_pos) {
-		file->f_pos = offset;
-		file->f_version = 0;
-	}
+	offset = lseek_execute(file, inode, offset, inode->i_sb->s_maxbytes);
 out:
 	mutex_unlock(&inode->i_mutex);
 	return offset;
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index b1b4d51..f4b6971 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -494,17 +494,7 @@ static loff_t ext4_seek_data(struct file *file, loff_t offset, loff_t maxsize)
 	if (dataoff > isize)
 		return -ENXIO;
 
-	if (dataoff < 0 && !(file->f_mode & FMODE_UNSIGNED_OFFSET))
-		return -EINVAL;
-	if (dataoff > maxsize)
-		return -EINVAL;
-
-	if (dataoff != file->f_pos) {
-		file->f_pos = dataoff;
-		file->f_version = 0;
-	}
-
-	return dataoff;
+	return lseek_execute(file, inode, dataoff, maxsize);
 }
 
 /*
@@ -580,17 +570,7 @@ static loff_t ext4_seek_hole(struct file *file, loff_t offset, loff_t maxsize)
 	if (holeoff > isize)
 		holeoff = isize;
 
-	if (holeoff < 0 && !(file->f_mode & FMODE_UNSIGNED_OFFSET))
-		return -EINVAL;
-	if (holeoff > maxsize)
-		return -EINVAL;
-
-	if (holeoff != file->f_pos) {
-		file->f_pos = holeoff;
-		file->f_version = 0;
-	}
-
-	return holeoff;
+	return lseek_execute(file, inode, holeoff, maxsize);
 }
 
 /*
diff --git a/fs/ocfs2/file.c b/fs/ocfs2/file.c
index ff54014..13af684 100644
--- a/fs/ocfs2/file.c
+++ b/fs/ocfs2/file.c
@@ -2646,17 +2646,7 @@ static loff_t ocfs2_file_llseek(struct file *file, loff_t offset, int whence)
 		goto out;
 	}
 
-	if (offset < 0 && !(file->f_mode & FMODE_UNSIGNED_OFFSET))
-		ret = -EINVAL;
-	if (!ret && offset > inode->i_sb->s_maxbytes)
-		ret = -EINVAL;
-	if (ret)
-		goto out;
-
-	if (offset != file->f_pos) {
-		file->f_pos = offset;
-		file->f_version = 0;
-	}
+	offset = lseek_execute(file, inode, offset, inode->i_sb->s_maxbytes);
 
 out:
 	mutex_unlock(&inode->i_mutex);
diff --git a/fs/read_write.c b/fs/read_write.c
index 2cefa41..5900bda3 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -41,8 +41,8 @@ static inline int unsigned_offsets(struct file *file)
 	return file->f_mode & FMODE_UNSIGNED_OFFSET;
 }
 
-static loff_t lseek_execute(struct file *file, struct inode *inode,
-		loff_t offset, loff_t maxsize)
+loff_t lseek_execute(struct file *file, struct inode *inode,
+		     loff_t offset, loff_t maxsize)
 {
 	if (offset < 0 && !unsigned_offsets(file))
 		return -EINVAL;
@@ -55,6 +55,7 @@ static loff_t lseek_execute(struct file *file, struct inode *inode,
 	}
 	return offset;
 }
+EXPORT_SYMBOL(lseek_execute);
 
 /**
  * generic_file_llseek_size - generic llseek implementation for regular files
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index a5f2042..d052e88 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1270,8 +1270,7 @@ xfs_seek_data(
 	}
 
 out:
-	if (offset != file->f_pos)
-		file->f_pos = offset;
+	offset = lseek_execute(file, inode, offset, inode->i_sb->s_maxbytes);
 
 out_unlock:
 	xfs_iunlock_map_shared(ip, lock);
@@ -1379,8 +1378,7 @@ out:
 	 * situation in particular.
 	 */
 	offset = min_t(loff_t, offset, isize);
-	if (offset != file->f_pos)
-		file->f_pos = offset;
+	offset = lseek_execute(file, inode, offset, inode->i_sb->s_maxbytes);
 
 out_unlock:
 	xfs_iunlock_map_shared(ip, lock);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 65c2be2..00becde 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2419,6 +2419,8 @@ extern void
 file_ra_state_init(struct file_ra_state *ra, struct address_space *mapping);
 extern loff_t noop_llseek(struct file *file, loff_t offset, int whence);
 extern loff_t no_llseek(struct file *file, loff_t offset, int whence);
+extern loff_t lseek_execute(struct file *file, struct inode *inode,
+			    loff_t offset, loff_t maxsize);
 extern loff_t generic_file_llseek(struct file *file, loff_t offset, int whence);
 extern loff_t generic_file_llseek_size(struct file *file, loff_t offset,
 		int whence, loff_t maxsize, loff_t eof);
diff --git a/mm/shmem.c b/mm/shmem.c
index 5e6a842..47ffb4a 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1798,10 +1798,7 @@ static loff_t shmem_file_llseek(struct file *file, loff_t offset, int whence)
 		}
 	}
 
-	if (offset >= 0 && offset != file->f_pos) {
-		file->f_pos = offset;
-		file->f_version = 0;
-	}
+	offset = lseek_execute(file, inode, offset, MAX_LFS_FILESIZE);
 	mutex_unlock(&inode->i_mutex);
 	return offset;
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
