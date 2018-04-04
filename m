Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 647EC6B000E
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:05 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id z128so15359331qka.8
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:05 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 78si7197407qkq.78.2018.04.04.12.19.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:04 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 09/79] fs: add struct address_space to read_cache_page() callback argument
Date: Wed,  4 Apr 2018 15:17:56 -0400
Message-Id: <20180404191831.5378-7-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>, Jeff Layton <jlayton@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Add struct address_space to callback arguments of read_cache_page()
and read_cache_pages(). Note this patch only add arguments and modify
callback function signature, it does not make use of the new argument
and thus it should be regression free.

One step toward dropping reliance on page->mapping.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <jbacik@fb.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Jeff Layton <jlayton@redhat.com>
---
 drivers/staging/lustre/lustre/mdc/mdc_request.c |  3 ++-
 fs/9p/vfs_addr.c                                | 13 ++++++++++++-
 fs/afs/file.c                                   |  7 ++++---
 fs/afs/internal.h                               |  2 +-
 fs/exofs/inode.c                                |  5 +++--
 fs/fuse/file.c                                  |  3 ++-
 fs/gfs2/aops.c                                  |  5 +++--
 fs/jffs2/file.c                                 |  6 ++++--
 fs/jffs2/fs.c                                   |  2 +-
 fs/jffs2/os-linux.h                             |  3 ++-
 fs/nfs/dir.c                                    |  3 ++-
 fs/nfs/read.c                                   |  3 ++-
 fs/nfs/symlink.c                                |  6 ++++--
 include/linux/pagemap.h                         |  8 ++++++--
 mm/filemap.c                                    | 14 +++++++++++---
 mm/readahead.c                                  |  4 ++--
 16 files changed, 61 insertions(+), 26 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 03e55bca4ada..4814ef083824 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -1122,7 +1122,8 @@ struct readpage_param {
  * in PAGE_SIZE (if PAGE_SIZE greater than LU_PAGE_SIZE), and the
  * lu_dirpage for this integrated page will be adjusted.
  **/
-static int mdc_read_page_remote(void *data, struct page *page0)
+static int mdc_read_page_remote(void *data, struct address_space *mapping,
+				struct page *page0)
 {
 	struct readpage_param *rp = data;
 	struct page **page_pool;
diff --git a/fs/9p/vfs_addr.c b/fs/9p/vfs_addr.c
index e1cbdfdb7c68..61f70e63a525 100644
--- a/fs/9p/vfs_addr.c
+++ b/fs/9p/vfs_addr.c
@@ -99,6 +99,17 @@ static int v9fs_vfs_readpage(struct file *filp, struct page *page)
 	return v9fs_fid_readpage(filp->private_data, page);
 }
 
+/*
+ * This wrapper is needed to avoid forcing callback cast on read_cache_pages()
+ * and defeating compiler figuring out we are doing something wrong.
+ */
+static int v9fs_vfs_readpage_filler(void *data, struct address_space *mapping,
+				    struct page *page)
+{
+	return v9fs_vfs_readpage(data, page);
+}
+
+
 /**
  * v9fs_vfs_readpages - read a set of pages from 9P
  *
@@ -122,7 +133,7 @@ static int v9fs_vfs_readpages(struct file *filp, struct address_space *mapping,
 	if (ret == 0)
 		return ret;
 
-	ret = read_cache_pages(mapping, pages, (void *)v9fs_vfs_readpage, filp);
+	ret = read_cache_pages(mapping, pages, v9fs_vfs_readpage_filler, filp);
 	p9_debug(P9_DEBUG_VFS, "  = %d\n", ret);
 	return ret;
 }
diff --git a/fs/afs/file.c b/fs/afs/file.c
index a39192ced99e..f457b0144946 100644
--- a/fs/afs/file.c
+++ b/fs/afs/file.c
@@ -247,7 +247,8 @@ int afs_fetch_data(struct afs_vnode *vnode, struct key *key, struct afs_read *de
 /*
  * read page from file, directory or symlink, given a key to use
  */
-int afs_page_filler(void *data, struct page *page)
+int afs_page_filler(void *data, struct address_space *mapping,
+		    struct page *page)
 {
 	struct inode *inode = page->mapping->host;
 	struct afs_vnode *vnode = AFS_FS_I(inode);
@@ -373,14 +374,14 @@ static int afs_readpage(struct file *file, struct page *page)
 	if (file) {
 		key = afs_file_key(file);
 		ASSERT(key != NULL);
-		ret = afs_page_filler(key, page);
+		ret = afs_page_filler(key, page->mapping, page);
 	} else {
 		struct inode *inode = page->mapping->host;
 		key = afs_request_key(AFS_FS_S(inode->i_sb)->cell);
 		if (IS_ERR(key)) {
 			ret = PTR_ERR(key);
 		} else {
-			ret = afs_page_filler(key, page);
+			ret = afs_page_filler(key, page->mapping, page);
 			key_put(key);
 		}
 	}
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index f38d6a561a84..4c449145f668 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -656,7 +656,7 @@ extern void afs_put_wb_key(struct afs_wb_key *);
 extern int afs_open(struct inode *, struct file *);
 extern int afs_release(struct inode *, struct file *);
 extern int afs_fetch_data(struct afs_vnode *, struct key *, struct afs_read *);
-extern int afs_page_filler(void *, struct page *);
+extern int afs_page_filler(void *, struct address_space *, struct page *);
 extern void afs_put_read(struct afs_read *);
 
 /*
diff --git a/fs/exofs/inode.c b/fs/exofs/inode.c
index 0ac62811b341..e7d25af1cf8a 100644
--- a/fs/exofs/inode.c
+++ b/fs/exofs/inode.c
@@ -377,7 +377,8 @@ static int read_exec(struct page_collect *pcol)
  * and will start a new collection. Eventually caller must submit the last
  * segment if present.
  */
-static int readpage_strip(void *data, struct page *page)
+static int readpage_strip(void *data, struct address_space *mapping,
+			  struct page *page)
 {
 	struct page_collect *pcol = data;
 	struct inode *inode = pcol->inode;
@@ -499,7 +500,7 @@ static int _readpage(struct page *page, bool read_4_write)
 	_pcol_init(&pcol, 1, page->mapping->host);
 
 	pcol.read_4_write = read_4_write;
-	ret = readpage_strip(&pcol, page);
+	ret = readpage_strip(&pcol, page->mapping, page);
 	if (ret) {
 		EXOFS_ERR("_readpage => %d\n", ret);
 		return ret;
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index a201fb0ac64f..5f342cbbf015 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -837,7 +837,8 @@ struct fuse_fill_data {
 	unsigned nr_pages;
 };
 
-static int fuse_readpages_fill(void *_data, struct page *page)
+static int fuse_readpages_fill(void *_data, struct address_space *mapping,
+			       struct page *page)
 {
 	struct fuse_fill_data *data = _data;
 	struct fuse_req *req = data->req;
diff --git a/fs/gfs2/aops.c b/fs/gfs2/aops.c
index 2f725b4a386b..45fa202b5fbc 100644
--- a/fs/gfs2/aops.c
+++ b/fs/gfs2/aops.c
@@ -509,7 +509,8 @@ static int stuffed_readpage(struct gfs2_inode *ip, struct page *page)
  * called by gfs2_readpage() once the required lock has been granted.
  */
 
-static int __gfs2_readpage(void *file, struct page *page)
+static int __gfs2_readpage(void *file, struct address_space *mapping,
+			   struct page *page)
 {
 	struct gfs2_inode *ip = GFS2_I(page->mapping->host);
 	struct gfs2_sbd *sdp = GFS2_SB(page->mapping->host);
@@ -553,7 +554,7 @@ static int gfs2_readpage(struct file *file, struct page *page)
 	error = AOP_TRUNCATED_PAGE;
 	lock_page(page);
 	if (page->mapping == mapping && !PageUptodate(page))
-		error = __gfs2_readpage(file, page);
+		error = __gfs2_readpage(file, mapping, page);
 	else
 		unlock_page(page);
 	gfs2_glock_dq(&gh);
diff --git a/fs/jffs2/file.c b/fs/jffs2/file.c
index bd0428bebe9b..e2faea96bce5 100644
--- a/fs/jffs2/file.c
+++ b/fs/jffs2/file.c
@@ -109,8 +109,10 @@ static int jffs2_do_readpage_nolock (struct inode *inode, struct page *pg)
 	return ret;
 }
 
-int jffs2_do_readpage_unlock(struct inode *inode, struct page *pg)
+int jffs2_do_readpage_unlock (void *data, struct address_space *mapping,
+			      struct page *pg)
 {
+	struct inode *inode = data;
 	int ret = jffs2_do_readpage_nolock(inode, pg);
 	unlock_page(pg);
 	return ret;
@@ -123,7 +125,7 @@ static int jffs2_readpage (struct file *filp, struct page *pg)
 	int ret;
 
 	mutex_lock(&f->sem);
-	ret = jffs2_do_readpage_unlock(pg->mapping->host, pg);
+	ret = jffs2_do_readpage_unlock(pg->mapping->host, pg->mapping, pg);
 	mutex_unlock(&f->sem);
 	return ret;
 }
diff --git a/fs/jffs2/fs.c b/fs/jffs2/fs.c
index eab04eca95a3..7fbe8a7843b9 100644
--- a/fs/jffs2/fs.c
+++ b/fs/jffs2/fs.c
@@ -686,7 +686,7 @@ unsigned char *jffs2_gc_fetch_page(struct jffs2_sb_info *c,
 	struct page *pg;
 
 	pg = read_cache_page(inode->i_mapping, offset >> PAGE_SHIFT,
-			     (void *)jffs2_do_readpage_unlock, inode);
+			     jffs2_do_readpage_unlock, inode);
 	if (IS_ERR(pg))
 		return (void *)pg;
 
diff --git a/fs/jffs2/os-linux.h b/fs/jffs2/os-linux.h
index c2fbec19c616..843a1d61ad73 100644
--- a/fs/jffs2/os-linux.h
+++ b/fs/jffs2/os-linux.h
@@ -154,7 +154,8 @@ extern const struct file_operations jffs2_file_operations;
 extern const struct inode_operations jffs2_file_inode_operations;
 extern const struct address_space_operations jffs2_file_address_operations;
 int jffs2_fsync(struct file *, loff_t, loff_t, int);
-int jffs2_do_readpage_unlock (struct inode *inode, struct page *pg);
+int jffs2_do_readpage_unlock (void *data, struct address_space *mapping,
+			      struct page *pg);
 
 /* ioctl.c */
 long jffs2_ioctl(struct file *, unsigned int, unsigned long);
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 2f3f86726f5b..1d988a0e91ee 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -664,7 +664,8 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
  * We only need to convert from xdr once so future lookups are much simpler
  */
 static
-int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page* page)
+int nfs_readdir_filler(nfs_readdir_descriptor_t *desc,
+		       struct address_space *mapping, struct page* page)
 {
 	struct inode	*inode = file_inode(desc->file);
 	int ret;
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 48d7277c60a9..2da6c62b1d3d 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -354,7 +354,8 @@ struct nfs_readdesc {
 };
 
 static int
-readpage_async_filler(void *data, struct page *page)
+readpage_async_filler(void *data, struct address_space *mapping,
+		      struct page *page)
 {
 	struct nfs_readdesc *desc = (struct nfs_readdesc *)data;
 	struct nfs_page *new;
diff --git a/fs/nfs/symlink.c b/fs/nfs/symlink.c
index 06eb44b47885..c0358f77222e 100644
--- a/fs/nfs/symlink.c
+++ b/fs/nfs/symlink.c
@@ -26,8 +26,10 @@
  * and straight-forward than readdir caching.
  */
 
-static int nfs_symlink_filler(struct inode *inode, struct page *page)
+static int nfs_symlink_filler(void *data, struct address_space *mapping,
+			      struct page *page)
 {
+	struct inode *inode = data;
 	int error;
 
 	error = NFS_PROTO(inode)->readlink(inode, page, 0, PAGE_SIZE);
@@ -66,7 +68,7 @@ static const char *nfs_get_link(struct dentry *dentry,
 		if (err)
 			return err;
 		page = read_cache_page(&inode->i_data, 0,
-					(filler_t *)nfs_symlink_filler, inode);
+				       nfs_symlink_filler, inode);
 		if (IS_ERR(page))
 			return ERR_CAST(page);
 	}
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 34ce3ebf97d5..89f5b1db4993 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -239,7 +239,7 @@ static inline gfp_t readahead_gfp_mask(struct address_space *x)
 	return mapping_gfp_mask(x) | __GFP_NORETRY | __GFP_NOWARN;
 }
 
-typedef int filler_t(void *, struct page *);
+typedef int filler_t(void *, struct address_space *, struct page *);
 
 pgoff_t page_cache_next_hole(struct address_space *mapping,
 			     pgoff_t index, unsigned long max_scan);
@@ -395,10 +395,14 @@ extern struct page * read_cache_page_gfp(struct address_space *mapping,
 extern int read_cache_pages(struct address_space *mapping,
 		struct list_head *pages, filler_t *filler, void *data);
 
+int read_mapping_page_readpage_wrapper(void *data,
+				       struct address_space *mapping,
+				       struct page *page);
+
 static inline struct page *read_mapping_page(struct address_space *mapping,
 				pgoff_t index, void *data)
 {
-	filler_t *filler = (filler_t *)mapping->a_ops->readpage;
+	filler_t *filler = read_mapping_page_readpage_wrapper;
 	return read_cache_page(mapping, index, filler, data);
 }
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 693f62212a59..007e0aca723f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2779,7 +2779,7 @@ static struct page *wait_on_page_read(struct page *page)
 
 static struct page *do_read_cache_page(struct address_space *mapping,
 				pgoff_t index,
-				int (*filler)(void *, struct page *),
+				filler_t filler,
 				void *data,
 				gfp_t gfp)
 {
@@ -2801,7 +2801,7 @@ static struct page *do_read_cache_page(struct address_space *mapping,
 		}
 
 filler:
-		err = filler(data, page);
+		err = filler(data, mapping, page);
 		if (err < 0) {
 			put_page(page);
 			return ERR_PTR(err);
@@ -2872,6 +2872,14 @@ static struct page *do_read_cache_page(struct address_space *mapping,
 	return page;
 }
 
+int read_mapping_page_readpage_wrapper(void *data,
+				       struct address_space *mapping,
+				       struct page *page)
+{
+	return mapping->a_ops->readpage(data, page);
+}
+EXPORT_SYMBOL(read_mapping_page_readpage_wrapper);
+
 /**
  * read_cache_page - read into page cache, fill it if needed
  * @mapping:	the page's address_space
@@ -2886,7 +2894,7 @@ static struct page *do_read_cache_page(struct address_space *mapping,
  */
 struct page *read_cache_page(struct address_space *mapping,
 				pgoff_t index,
-				int (*filler)(void *, struct page *),
+				filler_t filler,
 				void *data)
 {
 	return do_read_cache_page(mapping, index, filler, data, mapping_gfp_mask(mapping));
diff --git a/mm/readahead.c b/mm/readahead.c
index c4ca70239233..a20d3992525c 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -81,7 +81,7 @@ static void read_cache_pages_invalidate_pages(struct address_space *mapping,
  * Hides the details of the LRU cache etc from the filesystems.
  */
 int read_cache_pages(struct address_space *mapping, struct list_head *pages,
-			int (*filler)(void *, struct page *), void *data)
+			filler_t filler, void *data)
 {
 	struct page *page;
 	int ret = 0;
@@ -96,7 +96,7 @@ int read_cache_pages(struct address_space *mapping, struct list_head *pages,
 		}
 		put_page(page);
 
-		ret = filler(data, page);
+		ret = filler(data, mapping, page);
 		if (unlikely(ret)) {
 			read_cache_pages_invalidate_pages(mapping, pages);
 			break;
-- 
2.14.3
