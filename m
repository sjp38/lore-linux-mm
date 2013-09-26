Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id D76CE6B0037
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 10:16:15 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so1387000pab.1
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 07:16:15 -0700 (PDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so1196581pbc.17
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 07:16:13 -0700 (PDT)
Message-Id: <20130926141602.309768162@kernel.org>
Date: Thu, 26 Sep 2013 22:14:30 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [RFC 2/4] cleancache: make get_page async possible
References: <20130926141428.392345308@kernel.org>
Content-Disposition: inline; filename=cleancache-async-get_page.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: sjenning@linux.vnet.ibm.com, bob.liu@oracle.com, dan.magenheimer@oracle.com

Make cleancache get_page support async page fetch. Just normal page read,
cleancache unlock the page after page fetch is finished.

But we don't support IO error from cleancache get_page. That is if cleancache
get_page fails, we can't fallback to normal page read.

Signed-off-by: Shaohua Li <shli@kernel.org>
---
 drivers/xen/tmem.c         |    8 +++++---
 fs/btrfs/extent_io.c       |   10 ++++++++--
 fs/mpage.c                 |   15 ++++++++++++---
 include/linux/cleancache.h |   11 +++++++----
 mm/cleancache.c            |    5 +++--
 5 files changed, 35 insertions(+), 14 deletions(-)

Index: linux/fs/btrfs/extent_io.c
===================================================================
--- linux.orig/fs/btrfs/extent_io.c	2013-09-26 21:21:14.530330681 +0800
+++ linux/fs/btrfs/extent_io.c	2013-09-26 21:21:14.522330771 +0800
@@ -2530,6 +2530,12 @@ readpage_ok:
 	bio_put(bio);
 }
 
+static void extent_end_get_page(struct page *page, int err)
+{
+	SetPageUptodate(page);
+	unlock_page(page);
+}
+
 /*
  * this allocates from the btrfs_bioset.  We're returning a bio right now
  * but you can call btrfs_io_bio for the appropriate container_of magic
@@ -2770,10 +2776,10 @@ static int __do_readpage(struct extent_i
 
 	end = page_end;
 	if (!PageUptodate(page)) {
-		if (cleancache_get_page(page) == 0) {
+		if (cleancache_get_page(page, extent_end_get_page) == 0) {
 			BUG_ON(blocksize != PAGE_SIZE);
 			unlock_extent(tree, start, end);
-			goto out;
+			return 0;
 		}
 	}
 
Index: linux/fs/mpage.c
===================================================================
--- linux.orig/fs/mpage.c	2013-09-26 21:21:14.530330681 +0800
+++ linux/fs/mpage.c	2013-09-26 21:21:14.522330771 +0800
@@ -71,6 +71,14 @@ static void mpage_end_io(struct bio *bio
 	bio_put(bio);
 }
 
+static void mpage_end_get_page(struct page *page, int err)
+{
+	/* We don't support IO error so far */
+	WARN_ON(err);
+	SetPageUptodate(page);
+	unlock_page(page);
+}
+
 static struct bio *mpage_bio_submit(int rw, struct bio *bio)
 {
 	bio->bi_end_io = mpage_end_io;
@@ -273,9 +281,10 @@ do_mpage_readpage(struct bio *bio, struc
 	}
 
 	if (fully_mapped && blocks_per_page == 1 && !PageUptodate(page) &&
-	    cleancache_get_page(page) == 0) {
-		SetPageUptodate(page);
-		goto confused;
+	    cleancache_get_page(page, mpage_end_get_page) == 0) {
+		if (bio)
+			bio = mpage_bio_submit(READ, bio);
+		goto out;
 	}
 
 	/*
Index: linux/include/linux/cleancache.h
===================================================================
--- linux.orig/include/linux/cleancache.h	2013-09-26 21:21:14.530330681 +0800
+++ linux/include/linux/cleancache.h	2013-09-26 21:21:14.526330726 +0800
@@ -25,7 +25,8 @@ struct cleancache_ops {
 	int (*init_fs)(size_t);
 	int (*init_shared_fs)(char *uuid, size_t);
 	int (*get_page)(int, struct cleancache_filekey,
-			pgoff_t, struct page *);
+			pgoff_t, struct page *,
+			void (*end_get_page)(struct page *, int err));
 	void (*put_page)(int, struct cleancache_filekey,
 			pgoff_t, struct page *);
 	void (*invalidate_page)(int, struct cleancache_filekey, pgoff_t);
@@ -37,7 +38,8 @@ extern struct cleancache_ops *
 	cleancache_register_ops(struct cleancache_ops *ops);
 extern void __cleancache_init_fs(struct super_block *);
 extern void __cleancache_init_shared_fs(char *, struct super_block *);
-extern int  __cleancache_get_page(struct page *);
+extern int  __cleancache_get_page(struct page *,
+	void (*end_get_page)(struct page *page, int err));
 extern void __cleancache_put_page(struct page *);
 extern void __cleancache_invalidate_page(struct address_space *, struct page *);
 extern void __cleancache_invalidate_inode(struct address_space *);
@@ -84,12 +86,13 @@ static inline void cleancache_init_share
 		__cleancache_init_shared_fs(uuid, sb);
 }
 
-static inline int cleancache_get_page(struct page *page)
+static inline int cleancache_get_page(struct page *page,
+	void (*end_get_page)(struct page *page, int err))
 {
 	int ret = -1;
 
 	if (cleancache_enabled && cleancache_fs_enabled(page))
-		ret = __cleancache_get_page(page);
+		ret = __cleancache_get_page(page, end_get_page);
 	return ret;
 }
 
Index: linux/mm/cleancache.c
===================================================================
--- linux.orig/mm/cleancache.c	2013-09-26 21:21:14.530330681 +0800
+++ linux/mm/cleancache.c	2013-09-26 21:21:14.526330726 +0800
@@ -225,7 +225,8 @@ static int get_poolid_from_fake(int fake
  * a backend is registered and whether the sb->cleancache_poolid
  * is correct.
  */
-int __cleancache_get_page(struct page *page)
+int __cleancache_get_page(struct page *page,
+	void (*end_get_page)(struct page *page, int err))
 {
 	int ret = -1;
 	int pool_id;
@@ -248,7 +249,7 @@ int __cleancache_get_page(struct page *p
 
 	if (pool_id >= 0)
 		ret = cleancache_ops->get_page(pool_id,
-				key, page->index, page);
+				key, page->index, page, end_get_page);
 	if (ret == 0)
 		cleancache_succ_gets++;
 	else
Index: linux/drivers/xen/tmem.c
===================================================================
--- linux.orig/drivers/xen/tmem.c	2013-09-26 21:21:14.530330681 +0800
+++ linux/drivers/xen/tmem.c	2013-09-26 21:21:14.526330726 +0800
@@ -184,7 +184,8 @@ static void tmem_cleancache_put_page(int
 }
 
 static int tmem_cleancache_get_page(int pool, struct cleancache_filekey key,
-				    pgoff_t index, struct page *page)
+				    pgoff_t index, struct page *page,
+				    void (*end_get_page)(struct page *, int))
 {
 	u32 ind = (u32) index;
 	struct tmem_oid oid = *(struct tmem_oid *)&key;
@@ -197,9 +198,10 @@ static int tmem_cleancache_get_page(int
 	if (ind != index)
 		return -1;
 	ret = xen_tmem_get_page((u32)pool, oid, ind, pfn);
-	if (ret == 1)
+	if (ret == 1) {
+		end_get_page(page, 0);
 		return 0;
-	else
+	} else
 		return -1;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
