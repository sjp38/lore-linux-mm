Message-Id: <20071227053401.429081553@sgi.com>
References: <20071227053246.902699851@sgi.com>
Date: Wed, 26 Dec 2007 21:32:54 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 08/18] Use page_cache_xxx in fs/libfs.c
Content-Disposition: inline; filename=0009-Use-page_cache_xxx-in-fs-libfs.c.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, David Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

Use page_cache_xxx in fs/libfs.c

Reviewed-by: Dave Chinner <dgc@sgi.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/libfs.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

Index: linux-2.6.24-rc6-mm1/fs/libfs.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/fs/libfs.c	2007-12-26 17:47:02.519408561 -0800
+++ linux-2.6.24-rc6-mm1/fs/libfs.c	2007-12-26 19:51:07.826143940 -0800
@@ -17,7 +17,8 @@ int simple_getattr(struct vfsmount *mnt,
 {
 	struct inode *inode = dentry->d_inode;
 	generic_fillattr(inode, stat);
-	stat->blocks = inode->i_mapping->nrpages << (PAGE_CACHE_SHIFT - 9);
+	stat->blocks = inode->i_mapping->nrpages <<
+				(page_cache_shift(inode->i_mapping) - 9);
 	return 0;
 }
 
@@ -341,10 +342,10 @@ int simple_prepare_write(struct file *fi
 			unsigned from, unsigned to)
 {
 	if (!PageUptodate(page)) {
-		if (to - from != PAGE_CACHE_SIZE)
+		if (to - from != page_cache_size(file->f_mapping))
 			zero_user_segments(page,
 				0, from,
-				to, PAGE_CACHE_SIZE);
+				to, page_cache_size(file->f_mapping));
 	}
 	return 0;
 }
@@ -372,8 +373,9 @@ int simple_write_begin(struct file *file
 static int simple_commit_write(struct file *file, struct page *page,
 			       unsigned from, unsigned to)
 {
-	struct inode *inode = page->mapping->host;
-	loff_t pos = ((loff_t)page->index << PAGE_CACHE_SHIFT) + to;
+	struct address_space *mapping = page->mapping;
+	struct inode *inode = mapping->host;
+	loff_t pos = page_cache_pos(mapping, page->index, to);
 
 	if (!PageUptodate(page))
 		SetPageUptodate(page);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
