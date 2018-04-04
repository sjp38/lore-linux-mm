Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5F4886B0025
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:11 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id i21so897944qtp.10
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:11 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id v40si4118468qth.86.2018.04.04.12.19.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:10 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 27/79] fs: add struct address_space to fscache_read*() callback arguments
Date: Wed,  4 Apr 2018 15:18:01 -0400
Message-Id: <20180404191831.5378-12-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, David Howells <dhowells@redhat.com>, linux-cachefs@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>, Jeff Layton <jlayton@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Add struct address_space to fscache_read*() callback argument. Note
this patch only add arguments and modify call site conservatily using
page->mapping and thus the end result is as before this patch.

One step toward dropping reliance on page->mapping.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: David Howells <dhowells@redhat.com>
Cc: linux-cachefs@redhat.com
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <jbacik@fb.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Jeff Layton <jlayton@redhat.com>
---
 fs/9p/cache.c                 |  4 +++-
 fs/afs/file.c                 |  4 +++-
 fs/ceph/cache.c               | 10 ++++++----
 fs/cifs/fscache.c             |  6 ++++--
 fs/fscache/page.c             |  1 +
 fs/nfs/fscache.c              |  4 +++-
 include/linux/fscache-cache.h |  2 +-
 include/linux/fscache.h       |  9 ++++++---
 8 files changed, 27 insertions(+), 13 deletions(-)

diff --git a/fs/9p/cache.c b/fs/9p/cache.c
index 8185bfe4492f..3f122d35c54d 100644
--- a/fs/9p/cache.c
+++ b/fs/9p/cache.c
@@ -273,7 +273,8 @@ void __v9fs_fscache_invalidate_page(struct address_space *mapping,
 	}
 }
 
-static void v9fs_vfs_readpage_complete(struct page *page, void *data,
+static void v9fs_vfs_readpage_complete(struct address_space *mapping,
+				       struct page *page, void *data,
 				       int error)
 {
 	if (!error)
@@ -299,6 +300,7 @@ int __v9fs_readpage_from_fscache(struct inode *inode, struct page *page)
 		return -ENOBUFS;
 
 	ret = fscache_read_or_alloc_page(v9inode->fscache,
+					 page->mapping,
 					 page,
 					 v9fs_vfs_readpage_complete,
 					 NULL,
diff --git a/fs/afs/file.c b/fs/afs/file.c
index f87e997b9df9..23ff51343dd3 100644
--- a/fs/afs/file.c
+++ b/fs/afs/file.c
@@ -203,7 +203,8 @@ void afs_put_read(struct afs_read *req)
 /*
  * deal with notification that a page was read from the cache
  */
-static void afs_file_readpage_read_complete(struct page *page,
+static void afs_file_readpage_read_complete(struct address_space *mapping,
+					    struct page *page,
 					    void *data,
 					    int error)
 {
@@ -271,6 +272,7 @@ int afs_page_filler(void *data, struct address_space *mapping,
 	/* is it cached? */
 #ifdef CONFIG_AFS_FSCACHE
 	ret = fscache_read_or_alloc_page(vnode->cache,
+					 page->mapping,
 					 page,
 					 afs_file_readpage_read_complete,
 					 NULL,
diff --git a/fs/ceph/cache.c b/fs/ceph/cache.c
index a3ab265d3215..14438f1ed7e0 100644
--- a/fs/ceph/cache.c
+++ b/fs/ceph/cache.c
@@ -266,7 +266,9 @@ void ceph_fscache_file_set_cookie(struct inode *inode, struct file *filp)
 	}
 }
 
-static void ceph_readpage_from_fscache_complete(struct page *page, void *data, int error)
+static void ceph_readpage_from_fscache_complete(struct address_space *mapping,
+						struct page *page, void *data,
+						int error)
 {
 	if (!error)
 		SetPageUptodate(page);
@@ -293,9 +295,9 @@ int ceph_readpage_from_fscache(struct inode *inode, struct page *page)
 	if (!cache_valid(ci))
 		return -ENOBUFS;
 
-	ret = fscache_read_or_alloc_page(ci->fscache, page,
-					 ceph_readpage_from_fscache_complete, NULL,
-					 GFP_KERNEL);
+	ret = fscache_read_or_alloc_page(ci->fscache, page->mapping, page,
+					 ceph_readpage_from_fscache_complete,
+					 NULL, GFP_KERNEL);
 
 	switch (ret) {
 		case 0: /* Page found */
diff --git a/fs/cifs/fscache.c b/fs/cifs/fscache.c
index 8d4b7bc8ae91..25f259a83fe0 100644
--- a/fs/cifs/fscache.c
+++ b/fs/cifs/fscache.c
@@ -140,7 +140,8 @@ int cifs_fscache_release_page(struct page *page, gfp_t gfp)
 	return 1;
 }
 
-static void cifs_readpage_from_fscache_complete(struct page *page, void *ctx,
+static void cifs_readpage_from_fscache_complete(struct address_space *mapping,
+						struct page *page, void *ctx,
 						int error)
 {
 	cifs_dbg(FYI, "%s: (0x%p/%d)\n", __func__, page, error);
@@ -158,7 +159,8 @@ int __cifs_readpage_from_fscache(struct inode *inode, struct page *page)
 
 	cifs_dbg(FYI, "%s: (fsc:%p, p:%p, i:0x%p\n",
 		 __func__, CIFS_I(inode)->fscache, page, inode);
-	ret = fscache_read_or_alloc_page(CIFS_I(inode)->fscache, page,
+	ret = fscache_read_or_alloc_page(CIFS_I(inode)->fscache,
+					 page->mapping, page,
 					 cifs_readpage_from_fscache_complete,
 					 NULL,
 					 GFP_KERNEL);
diff --git a/fs/fscache/page.c b/fs/fscache/page.c
index 7112b42ad8c5..0c3d322a7b52 100644
--- a/fs/fscache/page.c
+++ b/fs/fscache/page.c
@@ -408,6 +408,7 @@ int fscache_wait_for_operation_activation(struct fscache_object *object,
  *   0		- dispatched a read - it'll call end_io_func() when finished
  */
 int __fscache_read_or_alloc_page(struct fscache_cookie *cookie,
+				 struct address_space *mapping,
 				 struct page *page,
 				 fscache_rw_complete_t end_io_func,
 				 void *context,
diff --git a/fs/nfs/fscache.c b/fs/nfs/fscache.c
index d63bea8bbfbb..e1cf607f8959 100644
--- a/fs/nfs/fscache.c
+++ b/fs/nfs/fscache.c
@@ -301,7 +301,8 @@ void __nfs_fscache_invalidate_page(struct page *page, struct inode *inode)
  * Handle completion of a page being read from the cache.
  * - Called in process (keventd) context.
  */
-static void nfs_readpage_from_fscache_complete(struct page *page,
+static void nfs_readpage_from_fscache_complete(struct address_space *mapping,
+					       struct page *page,
 					       void *context,
 					       int error)
 {
@@ -334,6 +335,7 @@ int __nfs_readpage_from_fscache(struct nfs_open_context *ctx,
 		 nfs_i_fscache(inode), page, page->index, page->flags, inode);
 
 	ret = fscache_read_or_alloc_page(nfs_i_fscache(inode),
+					 page->mapping,
 					 page,
 					 nfs_readpage_from_fscache_complete,
 					 ctx,
diff --git a/include/linux/fscache-cache.h b/include/linux/fscache-cache.h
index 4c467ef50159..7ae49d0306d5 100644
--- a/include/linux/fscache-cache.h
+++ b/include/linux/fscache-cache.h
@@ -468,7 +468,7 @@ void fscache_set_store_limit(struct fscache_object *object, loff_t i_size)
 static inline void fscache_end_io(struct fscache_retrieval *op,
 				  struct page *page, int error)
 {
-	op->end_io_func(page, op->context, error);
+	op->end_io_func(op->mapping, page, op->context, error);
 }
 
 static inline void __fscache_use_cookie(struct fscache_cookie *cookie)
diff --git a/include/linux/fscache.h b/include/linux/fscache.h
index 13db0098d3a9..f62df8c68e7a 100644
--- a/include/linux/fscache.h
+++ b/include/linux/fscache.h
@@ -50,7 +50,8 @@ struct fscache_cache_tag;
 struct fscache_cookie;
 struct fscache_netfs;
 
-typedef void (*fscache_rw_complete_t)(struct page *page,
+typedef void (*fscache_rw_complete_t)(struct address_space *mapping,
+				      struct page *page,
 				      void *context,
 				      int error);
 
@@ -216,6 +217,7 @@ extern int __fscache_attr_changed(struct fscache_cookie *);
 extern void __fscache_invalidate(struct fscache_cookie *);
 extern void __fscache_wait_on_invalidate(struct fscache_cookie *);
 extern int __fscache_read_or_alloc_page(struct fscache_cookie *,
+					struct address_space *mapping,
 					struct page *,
 					fscache_rw_complete_t,
 					void *,
@@ -530,14 +532,15 @@ int fscache_reserve_space(struct fscache_cookie *cookie, loff_t size)
  */
 static inline
 int fscache_read_or_alloc_page(struct fscache_cookie *cookie,
+			       struct address_space *mapping,
 			       struct page *page,
 			       fscache_rw_complete_t end_io_func,
 			       void *context,
 			       gfp_t gfp)
 {
 	if (fscache_cookie_valid(cookie) && fscache_cookie_enabled(cookie))
-		return __fscache_read_or_alloc_page(cookie, page, end_io_func,
-						    context, gfp);
+		return __fscache_read_or_alloc_page(cookie, mapping, page,
+						    end_io_func, context, gfp);
 	else
 		return -ENOBUFS;
 }
-- 
2.14.3
