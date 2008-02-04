Message-Id: <20080204170528.097544613@szeredi.hu>
References: <20080204170409.991123259@szeredi.hu>
Date: Mon, 04 Feb 2008 18:04:12 +0100
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [patch 2/3] fuse: clean up setting i_size in write
Content-Disposition: inline; filename=fuse_write_update_size.patch
Sender: owner-linux-mm@kvack.org
From: Miklos Szeredi <mszeredi@suse.cz>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Extract common code for setting i_size in write functions into a
common helper.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---

Index: linux/fs/fuse/file.c
===================================================================
--- linux.orig/fs/fuse/file.c	2008-02-04 13:01:39.000000000 +0100
+++ linux/fs/fuse/file.c	2008-02-04 13:02:03.000000000 +0100
@@ -610,13 +610,24 @@ static int fuse_write_begin(struct file 
 	return 0;
 }
 
+static void fuse_write_update_size(struct inode *inode, loff_t pos)
+{
+	struct fuse_conn *fc = get_fuse_conn(inode);
+	struct fuse_inode *fi = get_fuse_inode(inode);
+
+	spin_lock(&fc->lock);
+	fi->attr_version = ++fc->attr_version;
+	if (pos > inode->i_size)
+		i_size_write(inode, pos);
+	spin_unlock(&fc->lock);
+}
+
 static int fuse_buffered_write(struct file *file, struct inode *inode,
 			       loff_t pos, unsigned count, struct page *page)
 {
 	int err;
 	size_t nres;
 	struct fuse_conn *fc = get_fuse_conn(inode);
-	struct fuse_inode *fi = get_fuse_inode(inode);
 	unsigned offset = pos & (PAGE_CACHE_SIZE - 1);
 	struct fuse_req *req;
 
@@ -643,12 +654,7 @@ static int fuse_buffered_write(struct fi
 		err = -EIO;
 	if (!err) {
 		pos += nres;
-		spin_lock(&fc->lock);
-		fi->attr_version = ++fc->attr_version;
-		if (pos > inode->i_size)
-			i_size_write(inode, pos);
-		spin_unlock(&fc->lock);
-
+		fuse_write_update_size(inode, pos);
 		if (count == PAGE_CACHE_SIZE)
 			SetPageUptodate(page);
 	}
@@ -766,12 +772,8 @@ static ssize_t fuse_direct_io(struct fil
 	}
 	fuse_put_request(fc, req);
 	if (res > 0) {
-		if (write) {
-			spin_lock(&fc->lock);
-			if (pos > inode->i_size)
-				i_size_write(inode, pos);
-			spin_unlock(&fc->lock);
-		}
+		if (write)
+			fuse_write_update_size(inode, pos);
 		*ppos = pos;
 	}
 	fuse_invalidate_attr(inode);

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
