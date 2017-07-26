Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1C16B037C
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:47:28 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k71so31525662wrc.15
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 04:47:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b186si9093619wme.5.2017.07.26.04.47.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 04:47:26 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 01/10] fscache: Remove unused ->now_uncached callback
Date: Wed, 26 Jul 2017 13:46:55 +0200
Message-Id: <20170726114704.7626-2-jack@suse.cz>
In-Reply-To: <20170726114704.7626-1-jack@suse.cz>
References: <20170726114704.7626-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>

The callback doesn't ever get called. Remove it.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 Documentation/filesystems/caching/netfs-api.txt |  2 --
 fs/9p/cache.c                                   | 29 -----------------
 fs/afs/cache.c                                  | 43 -------------------------
 fs/ceph/cache.c                                 | 31 ------------------
 fs/cifs/cache.c                                 | 31 ------------------
 fs/nfs/fscache-index.c                          | 40 -----------------------
 include/linux/fscache.h                         |  9 ------
 7 files changed, 185 deletions(-)

diff --git a/Documentation/filesystems/caching/netfs-api.txt b/Documentation/filesystems/caching/netfs-api.txt
index aed6b94160b1..0eb31de3a2c1 100644
--- a/Documentation/filesystems/caching/netfs-api.txt
+++ b/Documentation/filesystems/caching/netfs-api.txt
@@ -151,8 +151,6 @@ To define an object, a structure of the following type should be filled out:
 		void (*mark_pages_cached)(void *cookie_netfs_data,
 					  struct address_space *mapping,
 					  struct pagevec *cached_pvec);
-
-		void (*now_uncached)(void *cookie_netfs_data);
 	};
 
 This has the following fields:
diff --git a/fs/9p/cache.c b/fs/9p/cache.c
index 103ca5e1267b..64c58eb26159 100644
--- a/fs/9p/cache.c
+++ b/fs/9p/cache.c
@@ -151,34 +151,6 @@ fscache_checkaux v9fs_cache_inode_check_aux(void *cookie_netfs_data,
 	return FSCACHE_CHECKAUX_OKAY;
 }
 
-static void v9fs_cache_inode_now_uncached(void *cookie_netfs_data)
-{
-	struct v9fs_inode *v9inode = cookie_netfs_data;
-	struct pagevec pvec;
-	pgoff_t first;
-	int loop, nr_pages;
-
-	pagevec_init(&pvec, 0);
-	first = 0;
-
-	for (;;) {
-		nr_pages = pagevec_lookup(&pvec, v9inode->vfs_inode.i_mapping,
-					  first,
-					  PAGEVEC_SIZE - pagevec_count(&pvec));
-		if (!nr_pages)
-			break;
-
-		for (loop = 0; loop < nr_pages; loop++)
-			ClearPageFsCache(pvec.pages[loop]);
-
-		first = pvec.pages[nr_pages - 1]->index + 1;
-
-		pvec.nr = nr_pages;
-		pagevec_release(&pvec);
-		cond_resched();
-	}
-}
-
 const struct fscache_cookie_def v9fs_cache_inode_index_def = {
 	.name		= "9p.inode",
 	.type		= FSCACHE_COOKIE_TYPE_DATAFILE,
@@ -186,7 +158,6 @@ const struct fscache_cookie_def v9fs_cache_inode_index_def = {
 	.get_attr	= v9fs_cache_inode_get_attr,
 	.get_aux	= v9fs_cache_inode_get_aux,
 	.check_aux	= v9fs_cache_inode_check_aux,
-	.now_uncached	= v9fs_cache_inode_now_uncached,
 };
 
 void v9fs_cache_inode_get_cookie(struct inode *inode)
diff --git a/fs/afs/cache.c b/fs/afs/cache.c
index 577763c3d88b..1fe855191261 100644
--- a/fs/afs/cache.c
+++ b/fs/afs/cache.c
@@ -39,7 +39,6 @@ static uint16_t afs_vnode_cache_get_aux(const void *cookie_netfs_data,
 static enum fscache_checkaux afs_vnode_cache_check_aux(void *cookie_netfs_data,
 						       const void *buffer,
 						       uint16_t buflen);
-static void afs_vnode_cache_now_uncached(void *cookie_netfs_data);
 
 struct fscache_netfs afs_cache_netfs = {
 	.name			= "afs",
@@ -75,7 +74,6 @@ struct fscache_cookie_def afs_vnode_cache_index_def = {
 	.get_attr		= afs_vnode_cache_get_attr,
 	.get_aux		= afs_vnode_cache_get_aux,
 	.check_aux		= afs_vnode_cache_check_aux,
-	.now_uncached		= afs_vnode_cache_now_uncached,
 };
 
 /*
@@ -359,44 +357,3 @@ static enum fscache_checkaux afs_vnode_cache_check_aux(void *cookie_netfs_data,
 	_leave(" = SUCCESS");
 	return FSCACHE_CHECKAUX_OKAY;
 }
-
-/*
- * indication the cookie is no longer uncached
- * - this function is called when the backing store currently caching a cookie
- *   is removed
- * - the netfs should use this to clean up any markers indicating cached pages
- * - this is mandatory for any object that may have data
- */
-static void afs_vnode_cache_now_uncached(void *cookie_netfs_data)
-{
-	struct afs_vnode *vnode = cookie_netfs_data;
-	struct pagevec pvec;
-	pgoff_t first;
-	int loop, nr_pages;
-
-	_enter("{%x,%x,%Lx}",
-	       vnode->fid.vnode, vnode->fid.unique, vnode->status.data_version);
-
-	pagevec_init(&pvec, 0);
-	first = 0;
-
-	for (;;) {
-		/* grab a bunch of pages to clean */
-		nr_pages = pagevec_lookup(&pvec, vnode->vfs_inode.i_mapping,
-					  first,
-					  PAGEVEC_SIZE - pagevec_count(&pvec));
-		if (!nr_pages)
-			break;
-
-		for (loop = 0; loop < nr_pages; loop++)
-			ClearPageFsCache(pvec.pages[loop]);
-
-		first = pvec.pages[nr_pages - 1]->index + 1;
-
-		pvec.nr = nr_pages;
-		pagevec_release(&pvec);
-		cond_resched();
-	}
-
-	_leave("");
-}
diff --git a/fs/ceph/cache.c b/fs/ceph/cache.c
index fd1172823f86..6d3baf61b4d5 100644
--- a/fs/ceph/cache.c
+++ b/fs/ceph/cache.c
@@ -194,36 +194,6 @@ static enum fscache_checkaux ceph_fscache_inode_check_aux(
 	return FSCACHE_CHECKAUX_OKAY;
 }
 
-static void ceph_fscache_inode_now_uncached(void* cookie_netfs_data)
-{
-	struct ceph_inode_info* ci = cookie_netfs_data;
-	struct pagevec pvec;
-	pgoff_t first;
-	int loop, nr_pages;
-
-	pagevec_init(&pvec, 0);
-	first = 0;
-
-	dout("ceph inode 0x%p now uncached", ci);
-
-	while (1) {
-		nr_pages = pagevec_lookup(&pvec, ci->vfs_inode.i_mapping, first,
-					  PAGEVEC_SIZE - pagevec_count(&pvec));
-
-		if (!nr_pages)
-			break;
-
-		for (loop = 0; loop < nr_pages; loop++)
-			ClearPageFsCache(pvec.pages[loop]);
-
-		first = pvec.pages[nr_pages - 1]->index + 1;
-
-		pvec.nr = nr_pages;
-		pagevec_release(&pvec);
-		cond_resched();
-	}
-}
-
 static const struct fscache_cookie_def ceph_fscache_inode_object_def = {
 	.name		= "CEPH.inode",
 	.type		= FSCACHE_COOKIE_TYPE_DATAFILE,
@@ -231,7 +201,6 @@ static const struct fscache_cookie_def ceph_fscache_inode_object_def = {
 	.get_attr	= ceph_fscache_inode_get_attr,
 	.get_aux	= ceph_fscache_inode_get_aux,
 	.check_aux	= ceph_fscache_inode_check_aux,
-	.now_uncached	= ceph_fscache_inode_now_uncached,
 };
 
 void ceph_fscache_register_inode_cookie(struct inode *inode)
diff --git a/fs/cifs/cache.c b/fs/cifs/cache.c
index 6c665bf4a27c..2c14020e5e1d 100644
--- a/fs/cifs/cache.c
+++ b/fs/cifs/cache.c
@@ -292,36 +292,6 @@ fscache_checkaux cifs_fscache_inode_check_aux(void *cookie_netfs_data,
 	return FSCACHE_CHECKAUX_OKAY;
 }
 
-static void cifs_fscache_inode_now_uncached(void *cookie_netfs_data)
-{
-	struct cifsInodeInfo *cifsi = cookie_netfs_data;
-	struct pagevec pvec;
-	pgoff_t first;
-	int loop, nr_pages;
-
-	pagevec_init(&pvec, 0);
-	first = 0;
-
-	cifs_dbg(FYI, "%s: cifs inode 0x%p now uncached\n", __func__, cifsi);
-
-	for (;;) {
-		nr_pages = pagevec_lookup(&pvec,
-					  cifsi->vfs_inode.i_mapping, first,
-					  PAGEVEC_SIZE - pagevec_count(&pvec));
-		if (!nr_pages)
-			break;
-
-		for (loop = 0; loop < nr_pages; loop++)
-			ClearPageFsCache(pvec.pages[loop]);
-
-		first = pvec.pages[nr_pages - 1]->index + 1;
-
-		pvec.nr = nr_pages;
-		pagevec_release(&pvec);
-		cond_resched();
-	}
-}
-
 const struct fscache_cookie_def cifs_fscache_inode_object_def = {
 	.name		= "CIFS.uniqueid",
 	.type		= FSCACHE_COOKIE_TYPE_DATAFILE,
@@ -329,5 +299,4 @@ const struct fscache_cookie_def cifs_fscache_inode_object_def = {
 	.get_attr	= cifs_fscache_inode_get_attr,
 	.get_aux	= cifs_fscache_inode_get_aux,
 	.check_aux	= cifs_fscache_inode_check_aux,
-	.now_uncached	= cifs_fscache_inode_now_uncached,
 };
diff --git a/fs/nfs/fscache-index.c b/fs/nfs/fscache-index.c
index 777b055063f6..3025fe8584a0 100644
--- a/fs/nfs/fscache-index.c
+++ b/fs/nfs/fscache-index.c
@@ -252,45 +252,6 @@ enum fscache_checkaux nfs_fscache_inode_check_aux(void *cookie_netfs_data,
 }
 
 /*
- * Indication from FS-Cache that the cookie is no longer cached
- * - This function is called when the backing store currently caching a cookie
- *   is removed
- * - The netfs should use this to clean up any markers indicating cached pages
- * - This is mandatory for any object that may have data
- */
-static void nfs_fscache_inode_now_uncached(void *cookie_netfs_data)
-{
-	struct nfs_inode *nfsi = cookie_netfs_data;
-	struct pagevec pvec;
-	pgoff_t first;
-	int loop, nr_pages;
-
-	pagevec_init(&pvec, 0);
-	first = 0;
-
-	dprintk("NFS: nfs_inode_now_uncached: nfs_inode 0x%p\n", nfsi);
-
-	for (;;) {
-		/* grab a bunch of pages to unmark */
-		nr_pages = pagevec_lookup(&pvec,
-					  nfsi->vfs_inode.i_mapping,
-					  first,
-					  PAGEVEC_SIZE - pagevec_count(&pvec));
-		if (!nr_pages)
-			break;
-
-		for (loop = 0; loop < nr_pages; loop++)
-			ClearPageFsCache(pvec.pages[loop]);
-
-		first = pvec.pages[nr_pages - 1]->index + 1;
-
-		pvec.nr = nr_pages;
-		pagevec_release(&pvec);
-		cond_resched();
-	}
-}
-
-/*
  * Get an extra reference on a read context.
  * - This function can be absent if the completion function doesn't require a
  *   context.
@@ -330,7 +291,6 @@ const struct fscache_cookie_def nfs_fscache_inode_object_def = {
 	.get_attr	= nfs_fscache_inode_get_attr,
 	.get_aux	= nfs_fscache_inode_get_aux,
 	.check_aux	= nfs_fscache_inode_check_aux,
-	.now_uncached	= nfs_fscache_inode_now_uncached,
 	.get_context	= nfs_fh_get_context,
 	.put_context	= nfs_fh_put_context,
 };
diff --git a/include/linux/fscache.h b/include/linux/fscache.h
index 115bb81912cc..f4ff47d4a893 100644
--- a/include/linux/fscache.h
+++ b/include/linux/fscache.h
@@ -143,15 +143,6 @@ struct fscache_cookie_def {
 	void (*mark_page_cached)(void *cookie_netfs_data,
 				 struct address_space *mapping,
 				 struct page *page);
-
-	/* indicate the cookie is no longer cached
-	 * - this function is called when the backing store currently caching
-	 *   a cookie is removed
-	 * - the netfs should use this to clean up any markers indicating
-	 *   cached pages
-	 * - this is mandatory for any object that may have data
-	 */
-	void (*now_uncached)(void *cookie_netfs_data);
 };
 
 /*
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
