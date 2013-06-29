Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 9BAB36B0033
	for <linux-mm@kvack.org>; Sat, 29 Jun 2013 13:44:53 -0400 (EDT)
Subject: [PATCH 06/16] fuse: Trust kernel i_size only - v4
From: Maxim Patlasov <MPatlasov@parallels.com>
Date: Sat, 29 Jun 2013 21:44:40 +0400
Message-ID: <20130629174304.20175.84433.stgit@maximpc.sw.ru>
In-Reply-To: <20130629172211.20175.70154.stgit@maximpc.sw.ru>
References: <20130629172211.20175.70154.stgit@maximpc.sw.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: miklos@szeredi.hu
Cc: riel@redhat.com, dev@parallels.com, xemul@parallels.com, fuse-devel@lists.sourceforge.net, bfoster@redhat.com, linux-kernel@vger.kernel.org, jbottomley@parallels.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, fengguang.wu@intel.com, devel@openvz.org, mgorman@suse.de

From: Pavel Emelyanov <xemul@openvz.org>

Make fuse think that when writeback is on the inode's i_size is always
up-to-date and not update it with the value received from the userspace.
This is done because the page cache code may update i_size without letting
the FS know.

This assumption implies fixing the previously introduced short-read helper --
when a short read occurs the 'hole' is filled with zeroes.

fuse_file_fallocate() is also fixed because now we should keep i_size up to
date, so it must be updated if FUSE_FALLOCATE request succeeded.

Changed in v2:
 - improved comment in fuse_short_read()
 - fixed fuse_file_fallocate() for KEEP_SIZE mode

Changed in v3:
 - fixed fuse_fillattr() not to use local i_size if writeback-cache is off
 - added a comment explaining why we cannot trust attr.size from server

Changed in v4:
 - do not change fuse_file_fallocate() because what we need is already
   implemented in commits a200a2d and 14c1441

Signed-off-by: Maxim V. Patlasov <MPatlasov@parallels.com>
---
 fs/fuse/dir.c   |   13 +++++++++++--
 fs/fuse/file.c  |   26 ++++++++++++++++++++++++--
 fs/fuse/inode.c |   11 +++++++++--
 3 files changed, 44 insertions(+), 6 deletions(-)

diff --git a/fs/fuse/dir.c b/fs/fuse/dir.c
index f3f783d..b755884 100644
--- a/fs/fuse/dir.c
+++ b/fs/fuse/dir.c
@@ -851,6 +851,11 @@ static void fuse_fillattr(struct inode *inode, struct fuse_attr *attr,
 			  struct kstat *stat)
 {
 	unsigned int blkbits;
+	struct fuse_conn *fc = get_fuse_conn(inode);
+
+	/* see the comment in fuse_change_attributes() */
+	if (fc->writeback_cache && S_ISREG(inode->i_mode))
+		attr->size = i_size_read(inode);
 
 	stat->dev = inode->i_sb->s_dev;
 	stat->ino = attr->ino;
@@ -1576,6 +1581,7 @@ int fuse_do_setattr(struct inode *inode, struct iattr *attr,
 	struct fuse_setattr_in inarg;
 	struct fuse_attr_out outarg;
 	bool is_truncate = false;
+	bool is_wb = fc->writeback_cache;
 	loff_t oldsize;
 	int err;
 
@@ -1645,7 +1651,9 @@ int fuse_do_setattr(struct inode *inode, struct iattr *attr,
 	fuse_change_attributes_common(inode, &outarg.attr,
 				      attr_timeout(&outarg));
 	oldsize = inode->i_size;
-	i_size_write(inode, outarg.attr.size);
+	/* see the comment in fuse_change_attributes() */
+	if (!is_wb || is_truncate || !S_ISREG(inode->i_mode))
+		i_size_write(inode, outarg.attr.size);
 
 	if (is_truncate) {
 		/* NOTE: this may release/reacquire fc->lock */
@@ -1657,7 +1665,8 @@ int fuse_do_setattr(struct inode *inode, struct iattr *attr,
 	 * Only call invalidate_inode_pages2() after removing
 	 * FUSE_NOWRITE, otherwise fuse_launder_page() would deadlock.
 	 */
-	if (S_ISREG(inode->i_mode) && oldsize != outarg.attr.size) {
+	if ((is_truncate || !is_wb) &&
+	    S_ISREG(inode->i_mode) && oldsize != outarg.attr.size) {
 		truncate_pagecache(inode, oldsize, outarg.attr.size);
 		invalidate_inode_pages2(inode->i_mapping);
 	}
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 90fb235..98bc0d0 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -658,9 +658,31 @@ static void fuse_short_read(struct fuse_req *req, struct inode *inode,
 			    u64 attr_ver)
 {
 	size_t num_read = req->out.args[0].size;
+	struct fuse_conn *fc = get_fuse_conn(inode);
+
+	if (fc->writeback_cache) {
+		/*
+		 * A hole in a file. Some data after the hole are in page cache,
+		 * but have not reached the client fs yet. So, the hole is not
+		 * present there.
+		 */
+		int i;
+		int start_idx = num_read >> PAGE_CACHE_SHIFT;
+		size_t off = num_read & (PAGE_CACHE_SIZE - 1);
+
+		for (i = start_idx; i < req->num_pages; i++) {
+			struct page *page = req->pages[i];
+			void *mapaddr = kmap_atomic(page);
 
-	loff_t pos = page_offset(req->pages[0]) + num_read;
-	fuse_read_update_size(inode, pos, attr_ver);
+			memset(mapaddr + off, 0, PAGE_CACHE_SIZE - off);
+
+			kunmap_atomic(mapaddr);
+			off = 0;
+		}
+	} else {
+		loff_t pos = page_offset(req->pages[0]) + num_read;
+		fuse_read_update_size(inode, pos, attr_ver);
+	}
 }
 
 static int fuse_readpage(struct file *file, struct page *page)
diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
index 9a0cdde..121638d 100644
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -197,6 +197,7 @@ void fuse_change_attributes(struct inode *inode, struct fuse_attr *attr,
 {
 	struct fuse_conn *fc = get_fuse_conn(inode);
 	struct fuse_inode *fi = get_fuse_inode(inode);
+	bool is_wb = fc->writeback_cache;
 	loff_t oldsize;
 	struct timespec old_mtime;
 
@@ -210,10 +211,16 @@ void fuse_change_attributes(struct inode *inode, struct fuse_attr *attr,
 	fuse_change_attributes_common(inode, attr, attr_valid);
 
 	oldsize = inode->i_size;
-	i_size_write(inode, attr->size);
+	/*
+	 * In case of writeback_cache enabled, the cached writes beyond EOF
+	 * extend local i_size without keeping userspace server in sync. So,
+	 * attr->size coming from server can be stale. We cannot trust it.
+	 */
+	if (!is_wb || !S_ISREG(inode->i_mode))
+		i_size_write(inode, attr->size);
 	spin_unlock(&fc->lock);
 
-	if (S_ISREG(inode->i_mode)) {
+	if (!is_wb && S_ISREG(inode->i_mode)) {
 		bool inval = false;
 
 		if (oldsize != attr->size) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
