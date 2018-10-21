Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id D0BBD6B027B
	for <linux-mm@kvack.org>; Sun, 21 Oct 2018 12:17:13 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id s7-v6so1210203ybp.15
        for <linux-mm@kvack.org>; Sun, 21 Oct 2018 09:17:13 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id p15-v6si13534960ybc.133.2018.10.21.09.17.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Oct 2018 09:17:12 -0700 (PDT)
Subject: [PATCH 17/28] vfs: hide file range comparison function
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Sun, 21 Oct 2018 09:17:02 -0700
Message-ID: <154013862267.29026.2582062504282772214.stgit@magnolia>
In-Reply-To: <154013850285.29026.16168387526580596209.stgit@magnolia>
References: <154013850285.29026.16168387526580596209.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, darrick.wong@oracle.com
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, ocfs2-devel@oss.oracle.com

From: Darrick J. Wong <darrick.wong@oracle.com>

There are no callers of vfs_dedupe_file_range_compare, so we might as
well make it a static helper and remove the export.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
Reviewed-by: Amir Goldstein <amir73il@gmail.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/read_write.c    |  187 +++++++++++++++++++++++++---------------------------
 include/linux/fs.h |    3 -
 2 files changed, 91 insertions(+), 99 deletions(-)


diff --git a/fs/read_write.c b/fs/read_write.c
index c0bcc1a20650..e4d295d0d236 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1752,6 +1752,97 @@ static int generic_remap_check_len(struct inode *inode_in,
 	return (remap_flags & REMAP_FILE_DEDUP) ? -EBADE : -EINVAL;
 }
 
+/*
+ * Read a page's worth of file data into the page cache.  Return the page
+ * locked.
+ */
+static struct page *vfs_dedupe_get_page(struct inode *inode, loff_t offset)
+{
+	struct page *page;
+
+	page = read_mapping_page(inode->i_mapping, offset >> PAGE_SHIFT, NULL);
+	if (IS_ERR(page))
+		return page;
+	if (!PageUptodate(page)) {
+		put_page(page);
+		return ERR_PTR(-EIO);
+	}
+	lock_page(page);
+	return page;
+}
+
+/*
+ * Compare extents of two files to see if they are the same.
+ * Caller must have locked both inodes to prevent write races.
+ */
+static int vfs_dedupe_file_range_compare(struct inode *src, loff_t srcoff,
+					 struct inode *dest, loff_t destoff,
+					 loff_t len, bool *is_same)
+{
+	loff_t src_poff;
+	loff_t dest_poff;
+	void *src_addr;
+	void *dest_addr;
+	struct page *src_page;
+	struct page *dest_page;
+	loff_t cmp_len;
+	bool same;
+	int error;
+
+	error = -EINVAL;
+	same = true;
+	while (len) {
+		src_poff = srcoff & (PAGE_SIZE - 1);
+		dest_poff = destoff & (PAGE_SIZE - 1);
+		cmp_len = min(PAGE_SIZE - src_poff,
+			      PAGE_SIZE - dest_poff);
+		cmp_len = min(cmp_len, len);
+		if (cmp_len <= 0)
+			goto out_error;
+
+		src_page = vfs_dedupe_get_page(src, srcoff);
+		if (IS_ERR(src_page)) {
+			error = PTR_ERR(src_page);
+			goto out_error;
+		}
+		dest_page = vfs_dedupe_get_page(dest, destoff);
+		if (IS_ERR(dest_page)) {
+			error = PTR_ERR(dest_page);
+			unlock_page(src_page);
+			put_page(src_page);
+			goto out_error;
+		}
+		src_addr = kmap_atomic(src_page);
+		dest_addr = kmap_atomic(dest_page);
+
+		flush_dcache_page(src_page);
+		flush_dcache_page(dest_page);
+
+		if (memcmp(src_addr + src_poff, dest_addr + dest_poff, cmp_len))
+			same = false;
+
+		kunmap_atomic(dest_addr);
+		kunmap_atomic(src_addr);
+		unlock_page(dest_page);
+		unlock_page(src_page);
+		put_page(dest_page);
+		put_page(src_page);
+
+		if (!same)
+			break;
+
+		srcoff += cmp_len;
+		destoff += cmp_len;
+		len -= cmp_len;
+	}
+
+	*is_same = same;
+	return 0;
+
+out_error:
+	return error;
+}
+
 /*
  * Check that the two inodes are eligible for cloning, the ranges make
  * sense, and then flush all dirty data.  Caller must ensure that the
@@ -1923,102 +2014,6 @@ loff_t vfs_clone_file_range(struct file *file_in, loff_t pos_in,
 }
 EXPORT_SYMBOL(vfs_clone_file_range);
 
-/*
- * Read a page's worth of file data into the page cache.  Return the page
- * locked.
- */
-static struct page *vfs_dedupe_get_page(struct inode *inode, loff_t offset)
-{
-	struct address_space *mapping;
-	struct page *page;
-	pgoff_t n;
-
-	n = offset >> PAGE_SHIFT;
-	mapping = inode->i_mapping;
-	page = read_mapping_page(mapping, n, NULL);
-	if (IS_ERR(page))
-		return page;
-	if (!PageUptodate(page)) {
-		put_page(page);
-		return ERR_PTR(-EIO);
-	}
-	lock_page(page);
-	return page;
-}
-
-/*
- * Compare extents of two files to see if they are the same.
- * Caller must have locked both inodes to prevent write races.
- */
-int vfs_dedupe_file_range_compare(struct inode *src, loff_t srcoff,
-				  struct inode *dest, loff_t destoff,
-				  loff_t len, bool *is_same)
-{
-	loff_t src_poff;
-	loff_t dest_poff;
-	void *src_addr;
-	void *dest_addr;
-	struct page *src_page;
-	struct page *dest_page;
-	loff_t cmp_len;
-	bool same;
-	int error;
-
-	error = -EINVAL;
-	same = true;
-	while (len) {
-		src_poff = srcoff & (PAGE_SIZE - 1);
-		dest_poff = destoff & (PAGE_SIZE - 1);
-		cmp_len = min(PAGE_SIZE - src_poff,
-			      PAGE_SIZE - dest_poff);
-		cmp_len = min(cmp_len, len);
-		if (cmp_len <= 0)
-			goto out_error;
-
-		src_page = vfs_dedupe_get_page(src, srcoff);
-		if (IS_ERR(src_page)) {
-			error = PTR_ERR(src_page);
-			goto out_error;
-		}
-		dest_page = vfs_dedupe_get_page(dest, destoff);
-		if (IS_ERR(dest_page)) {
-			error = PTR_ERR(dest_page);
-			unlock_page(src_page);
-			put_page(src_page);
-			goto out_error;
-		}
-		src_addr = kmap_atomic(src_page);
-		dest_addr = kmap_atomic(dest_page);
-
-		flush_dcache_page(src_page);
-		flush_dcache_page(dest_page);
-
-		if (memcmp(src_addr + src_poff, dest_addr + dest_poff, cmp_len))
-			same = false;
-
-		kunmap_atomic(dest_addr);
-		kunmap_atomic(src_addr);
-		unlock_page(dest_page);
-		unlock_page(src_page);
-		put_page(dest_page);
-		put_page(src_page);
-
-		if (!same)
-			break;
-
-		srcoff += cmp_len;
-		destoff += cmp_len;
-		len -= cmp_len;
-	}
-
-	*is_same = same;
-	return 0;
-
-out_error:
-	return error;
-}
-EXPORT_SYMBOL(vfs_dedupe_file_range_compare);
-
 loff_t vfs_dedupe_file_range_one(struct file *src_file, loff_t src_pos,
 				 struct file *dst_file, loff_t dst_pos,
 				 loff_t len, unsigned int remap_flags)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 34c22d695011..346036a84f18 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1853,9 +1853,6 @@ extern loff_t do_clone_file_range(struct file *file_in, loff_t pos_in,
 extern loff_t vfs_clone_file_range(struct file *file_in, loff_t pos_in,
 				   struct file *file_out, loff_t pos_out,
 				   loff_t len, unsigned int remap_flags);
-extern int vfs_dedupe_file_range_compare(struct inode *src, loff_t srcoff,
-					 struct inode *dest, loff_t destoff,
-					 loff_t len, bool *is_same);
 extern int vfs_dedupe_file_range(struct file *file,
 				 struct file_dedupe_range *same);
 extern loff_t vfs_dedupe_file_range_one(struct file *src_file, loff_t src_pos,
