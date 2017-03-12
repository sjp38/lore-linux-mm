Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C71E728094E
	for <linux-mm@kvack.org>; Sat, 11 Mar 2017 23:59:57 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id v190so239984749pfb.5
        for <linux-mm@kvack.org>; Sat, 11 Mar 2017 20:59:57 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id l19si7902929pfa.177.2017.03.11.20.59.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 11 Mar 2017 20:59:56 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH v2] fs: Remove set but not checked AOP_FLAG_UNINTERRUPTIBLE flag.
Date: Sun, 12 Mar 2017 13:59:41 +0900
Message-Id: <1489294781-53494-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk, akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Jeff Layton <jlayton@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Nick Piggin <npiggin@gmail.com>

Commit afddba49d18f346e ("fs: introduce write_begin, write_end, and
perform_write aops") introduced AOP_FLAG_UNINTERRUPTIBLE flag which was
checked in pagecache_write_begin(), but that check was removed by
commit 4e02ed4b4a2fae34 ("fs: remove prepare_write/commit_write").

Between these two commits, commit d9414774dc0c7b39 ("cifs: Convert cifs
to new aops.") added a check in cifs_write_begin(), but that check was
soon removed by commit a98ee8c1c707fe32 ("[CIFS] fix regression in
cifs_write_begin/cifs_write_end").

Therefore, AOP_FLAG_UNINTERRUPTIBLE flag is checked nowhere.
Let's remove this flag. This patch has no functionality changes.

Changes since v1:
- shift the flag range down - per Jeff

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Reviewed-by: Jeff Layton <jlayton@redhat.com>
Cc: Nick Piggin <npiggin@gmail.com>
---
 Documentation/filesystems/vfs.txt |  3 +--
 fs/buffer.c                       | 13 +++++--------
 fs/exofs/dir.c                    |  3 +--
 fs/hfs/extent.c                   |  4 ++--
 fs/hfsplus/extents.c              |  5 ++---
 fs/iomap.c                        | 13 +++----------
 fs/namei.c                        |  2 +-
 include/linux/fs.h                |  5 ++---
 mm/filemap.c                      |  6 ------
 9 files changed, 17 insertions(+), 37 deletions(-)

diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index 5692117..9d9fc65 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -695,8 +695,7 @@ struct address_space_operations {
 
   write_end: After a successful write_begin, and data copy, write_end must
         be called. len is the original len passed to write_begin, and copied
-        is the amount that was able to be copied (copied == len is always true
-	if write_begin was called with the AOP_FLAG_UNINTERRUPTIBLE flag).
+        is the amount that was able to be copied.
 
         The filesystem must take care of unlocking the page and releasing it
         refcount, and updating i_size.
diff --git a/fs/buffer.c b/fs/buffer.c
index 2ba9057..584ea92 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -2379,8 +2379,7 @@ int generic_cont_expand_simple(struct inode *inode, loff_t size)
 		goto out;
 
 	err = pagecache_write_begin(NULL, mapping, size, 0,
-				AOP_FLAG_UNINTERRUPTIBLE|AOP_FLAG_CONT_EXPAND,
-				&page, &fsdata);
+				    AOP_FLAG_CONT_EXPAND, &page, &fsdata);
 	if (err)
 		goto out;
 
@@ -2415,9 +2414,8 @@ static int cont_expand_zero(struct file *file, struct address_space *mapping,
 		}
 		len = PAGE_SIZE - zerofrom;
 
-		err = pagecache_write_begin(file, mapping, curpos, len,
-						AOP_FLAG_UNINTERRUPTIBLE,
-						&page, &fsdata);
+		err = pagecache_write_begin(file, mapping, curpos, len, 0,
+					    &page, &fsdata);
 		if (err)
 			goto out;
 		zero_user(page, zerofrom, len);
@@ -2449,9 +2447,8 @@ static int cont_expand_zero(struct file *file, struct address_space *mapping,
 		}
 		len = offset - zerofrom;
 
-		err = pagecache_write_begin(file, mapping, curpos, len,
-						AOP_FLAG_UNINTERRUPTIBLE,
-						&page, &fsdata);
+		err = pagecache_write_begin(file, mapping, curpos, len, 0,
+					    &page, &fsdata);
 		if (err)
 			goto out;
 		zero_user(page, zerofrom, len);
diff --git a/fs/exofs/dir.c b/fs/exofs/dir.c
index 42f9a0a..8eeb694 100644
--- a/fs/exofs/dir.c
+++ b/fs/exofs/dir.c
@@ -405,8 +405,7 @@ int exofs_set_link(struct inode *dir, struct exofs_dir_entry *de,
 	int err;
 
 	lock_page(page);
-	err = exofs_write_begin(NULL, page->mapping, pos, len,
-				AOP_FLAG_UNINTERRUPTIBLE, &page, NULL);
+	err = exofs_write_begin(NULL, page->mapping, pos, len, 0, &page, NULL);
 	if (err)
 		EXOFS_ERR("exofs_set_link: exofs_write_begin FAILED => %d\n",
 			  err);
diff --git a/fs/hfs/extent.c b/fs/hfs/extent.c
index e33a0d3..5d01826 100644
--- a/fs/hfs/extent.c
+++ b/fs/hfs/extent.c
@@ -485,8 +485,8 @@ void hfs_file_truncate(struct inode *inode)
 
 		/* XXX: Can use generic_cont_expand? */
 		size = inode->i_size - 1;
-		res = pagecache_write_begin(NULL, mapping, size+1, 0,
-				AOP_FLAG_UNINTERRUPTIBLE, &page, &fsdata);
+		res = pagecache_write_begin(NULL, mapping, size+1, 0, 0,
+					    &page, &fsdata);
 		if (!res) {
 			res = pagecache_write_end(NULL, mapping, size+1, 0, 0,
 					page, fsdata);
diff --git a/fs/hfsplus/extents.c b/fs/hfsplus/extents.c
index feca524..a3eb640 100644
--- a/fs/hfsplus/extents.c
+++ b/fs/hfsplus/extents.c
@@ -545,9 +545,8 @@ void hfsplus_file_truncate(struct inode *inode)
 		void *fsdata;
 		loff_t size = inode->i_size;
 
-		res = pagecache_write_begin(NULL, mapping, size, 0,
-						AOP_FLAG_UNINTERRUPTIBLE,
-						&page, &fsdata);
+		res = pagecache_write_begin(NULL, mapping, size, 0, 0,
+					    &page, &fsdata);
 		if (res)
 			return;
 		res = pagecache_write_end(NULL, mapping, size,
diff --git a/fs/iomap.c b/fs/iomap.c
index 0de6182..31adc63 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -158,12 +158,6 @@
 	ssize_t written = 0;
 	unsigned int flags = AOP_FLAG_NOFS;
 
-	/*
-	 * Copies from kernel address space cannot fail (NFSD is a big user).
-	 */
-	if (!iter_is_iovec(i))
-		flags |= AOP_FLAG_UNINTERRUPTIBLE;
-
 	do {
 		struct page *page;
 		unsigned long offset;	/* Offset into pagecache page */
@@ -291,8 +285,7 @@
 			return PTR_ERR(rpage);
 
 		status = iomap_write_begin(inode, pos, bytes,
-				AOP_FLAG_NOFS | AOP_FLAG_UNINTERRUPTIBLE,
-				&page, iomap);
+					   AOP_FLAG_NOFS, &page, iomap);
 		put_page(rpage);
 		if (unlikely(status))
 			return status;
@@ -343,8 +336,8 @@ static int iomap_zero(struct inode *inode, loff_t pos, unsigned offset,
 	struct page *page;
 	int status;
 
-	status = iomap_write_begin(inode, pos, bytes,
-			AOP_FLAG_UNINTERRUPTIBLE | AOP_FLAG_NOFS, &page, iomap);
+	status = iomap_write_begin(inode, pos, bytes, AOP_FLAG_NOFS, &page,
+				   iomap);
 	if (status)
 		return status;
 
diff --git a/fs/namei.c b/fs/namei.c
index d41fab7..7b26fb2 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -4763,7 +4763,7 @@ int __page_symlink(struct inode *inode, const char *symname, int len, int nofs)
 	struct page *page;
 	void *fsdata;
 	int err;
-	unsigned int flags = AOP_FLAG_UNINTERRUPTIBLE;
+	unsigned int flags = 0;
 	if (nofs)
 		flags |= AOP_FLAG_NOFS;
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f1d7347..84b18cd 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -250,9 +250,8 @@ enum positive_aop_returns {
 	AOP_TRUNCATED_PAGE	= 0x80001,
 };
 
-#define AOP_FLAG_UNINTERRUPTIBLE	0x0001 /* will not do a short write */
-#define AOP_FLAG_CONT_EXPAND		0x0002 /* called from cont_expand */
-#define AOP_FLAG_NOFS			0x0004 /* used by filesystem to direct
+#define AOP_FLAG_CONT_EXPAND		0x0001 /* called from cont_expand */
+#define AOP_FLAG_NOFS			0x0002 /* used by filesystem to direct
 						* helper code (eg buffer layer)
 						* to clear GFP_FS from alloc */
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 68b166a..2667cb0 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2794,12 +2794,6 @@ ssize_t generic_perform_write(struct file *file,
 	ssize_t written = 0;
 	unsigned int flags = 0;
 
-	/*
-	 * Copies from kernel address space cannot fail (NFSD is a big user).
-	 */
-	if (!iter_is_iovec(i))
-		flags |= AOP_FLAG_UNINTERRUPTIBLE;
-
 	do {
 		struct page *page;
 		unsigned long offset;	/* Offset into pagecache page */
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
