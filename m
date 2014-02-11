Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id C05596B0037
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 11:32:44 -0500 (EST)
Received: by mail-qc0-f170.google.com with SMTP id e9so13586869qcy.29
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 08:32:44 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id f91si12775874qge.98.2014.02.11.08.32.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 08:32:44 -0800 (PST)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] mm: remove read_cache_page_async
Date: Tue, 11 Feb 2014 11:32:09 -0500
Message-Id: <1392136329-21946-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dwmw2@infradead.org, akpm@linux-foundation.org
Cc: viro@zeniv.linux.org.uk, linux-kernel@vger.kernel.org, linux-mtd@lists.infradead.org, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>

This patch removes read_cache_page_async() which wasn't really needed anywhere
and simplifies the code around it a bit.

read_cache_page_async() is useful when we want to read a page into the cache
without waiting for it to complete. This happens when the appropriate callback
'filler' doesn't complete it's read operation and releases the page lock
immediately, and instead queues a different completion routine to do that.
This never actually happened anywhere in the code.

read_cache_page_async() had 3 different callers:

 - read_cache_page() which is the sync version, it would just wait for
the requested read to complete using wait_on_page_read().
 - JFFS2 would call it from jffs2_gc_fetch_page(), but the filler function
it supplied doesn't do any async reads, and would complete before the
filler function returns - making it actually a sync read.
 - CRAMFS would call it using the read_mapping_page_async() wrapper, with
a similar story to JFFS2 - the filler function doesn't do anything that
reminds async reads and would always complete before the filler function
returns.

To sum it up, the code in mm/filemap.c never took advantage of having
read_cache_page_async(). While there are filler callbacks that do async
reads (such as the block one), we always called it with the read_cache_page().

This patch adds a mandatory wait for read to complete when adding a new
page to the cache, and removes read_cache_page_async() and it's wrappers.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 fs/cramfs/inode.c       |    3 +-
 fs/jffs2/fs.c           |    2 +-
 include/linux/pagemap.h |   10 -------
 mm/filemap.c            |   64 +++++++++++++++++------------------------------
 4 files changed, 25 insertions(+), 54 deletions(-)

diff --git a/fs/cramfs/inode.c b/fs/cramfs/inode.c
index 06610cf..a1f801c 100644
--- a/fs/cramfs/inode.c
+++ b/fs/cramfs/inode.c
@@ -195,8 +195,7 @@ static void *cramfs_read(struct super_block *sb, unsigned int offset, unsigned i
 		struct page *page = NULL;
 
 		if (blocknr + i < devsize) {
-			page = read_mapping_page_async(mapping, blocknr + i,
-									NULL);
+			page = read_mapping_page(mapping, blocknr + i, NULL);
 			/* synchronous error? */
 			if (IS_ERR(page))
 				page = NULL;
diff --git a/fs/jffs2/fs.c b/fs/jffs2/fs.c
index 5e36504..601afd1 100644
--- a/fs/jffs2/fs.c
+++ b/fs/jffs2/fs.c
@@ -690,7 +690,7 @@ unsigned char *jffs2_gc_fetch_page(struct jffs2_sb_info *c,
 	struct inode *inode = OFNI_EDONI_2SFFJ(f);
 	struct page *pg;
 
-	pg = read_cache_page_async(inode->i_mapping, offset >> PAGE_CACHE_SHIFT,
+	pg = read_cache_page(inode->i_mapping, offset >> PAGE_CACHE_SHIFT,
 			     (void *)jffs2_do_readpage_unlock, inode);
 	if (IS_ERR(pg))
 		return (void *)pg;
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index e772973..4f591df 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -289,8 +289,6 @@ static inline struct page *grab_cache_page(struct address_space *mapping,
 
 extern struct page * grab_cache_page_nowait(struct address_space *mapping,
 				pgoff_t index);
-extern struct page * read_cache_page_async(struct address_space *mapping,
-				pgoff_t index, filler_t *filler, void *data);
 extern struct page * read_cache_page(struct address_space *mapping,
 				pgoff_t index, filler_t *filler, void *data);
 extern struct page * read_cache_page_gfp(struct address_space *mapping,
@@ -298,14 +296,6 @@ extern struct page * read_cache_page_gfp(struct address_space *mapping,
 extern int read_cache_pages(struct address_space *mapping,
 		struct list_head *pages, filler_t *filler, void *data);
 
-static inline struct page *read_mapping_page_async(
-				struct address_space *mapping,
-				pgoff_t index, void *data)
-{
-	filler_t *filler = (filler_t *)mapping->a_ops->readpage;
-	return read_cache_page_async(mapping, index, filler, data);
-}
-
 static inline struct page *read_mapping_page(struct address_space *mapping,
 				pgoff_t index, void *data)
 {
diff --git a/mm/filemap.c b/mm/filemap.c
index 8d44788..0ad619d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2130,6 +2130,18 @@ int generic_file_readonly_mmap(struct file * file, struct vm_area_struct * vma)
 EXPORT_SYMBOL(generic_file_mmap);
 EXPORT_SYMBOL(generic_file_readonly_mmap);
 
+static struct page *wait_on_page_read(struct page *page)
+{
+	if (!IS_ERR(page)) {
+		wait_on_page_locked(page);
+		if (!PageUptodate(page)) {
+			page_cache_release(page);
+			page = ERR_PTR(-EIO);
+		}
+	}
+	return page;
+}
+
 static struct page *__read_cache_page(struct address_space *mapping,
 				pgoff_t index,
 				int (*filler)(void *, struct page *),
@@ -2156,6 +2168,8 @@ repeat:
 		if (err < 0) {
 			page_cache_release(page);
 			page = ERR_PTR(err);
+		} else {
+			page = wait_on_page_read(page);
 		}
 	}
 	return page;
@@ -2192,6 +2206,10 @@ retry:
 	if (err < 0) {
 		page_cache_release(page);
 		return ERR_PTR(err);
+	} else {
+		page = wait_on_page_read(page);
+		if (IS_ERR(page))
+			return page;
 	}
 out:
 	mark_page_accessed(page);
@@ -2199,40 +2217,25 @@ out:
 }
 
 /**
- * read_cache_page_async - read into page cache, fill it if needed
+ * read_cache_page - read into page cache, fill it if needed
  * @mapping:	the page's address_space
  * @index:	the page index
  * @filler:	function to perform the read
  * @data:	first arg to filler(data, page) function, often left as NULL
  *
- * Same as read_cache_page, but don't wait for page to become unlocked
- * after submitting it to the filler.
- *
  * Read into the page cache. If a page already exists, and PageUptodate() is
- * not set, try to fill the page but don't wait for it to become unlocked.
+ * not set, try to fill the page and wait for it to become unlocked.
  *
  * If the page does not get brought uptodate, return -EIO.
  */
-struct page *read_cache_page_async(struct address_space *mapping,
+struct page *read_cache_page(struct address_space *mapping,
 				pgoff_t index,
 				int (*filler)(void *, struct page *),
 				void *data)
 {
 	return do_read_cache_page(mapping, index, filler, data, mapping_gfp_mask(mapping));
 }
-EXPORT_SYMBOL(read_cache_page_async);
-
-static struct page *wait_on_page_read(struct page *page)
-{
-	if (!IS_ERR(page)) {
-		wait_on_page_locked(page);
-		if (!PageUptodate(page)) {
-			page_cache_release(page);
-			page = ERR_PTR(-EIO);
-		}
-	}
-	return page;
-}
+EXPORT_SYMBOL(read_cache_page);
 
 /**
  * read_cache_page_gfp - read into page cache, using specified page allocation flags.
@@ -2251,31 +2254,10 @@ struct page *read_cache_page_gfp(struct address_space *mapping,
 {
 	filler_t *filler = (filler_t *)mapping->a_ops->readpage;
 
-	return wait_on_page_read(do_read_cache_page(mapping, index, filler, NULL, gfp));
+	return do_read_cache_page(mapping, index, filler, NULL, gfp);
 }
 EXPORT_SYMBOL(read_cache_page_gfp);
 
-/**
- * read_cache_page - read into page cache, fill it if needed
- * @mapping:	the page's address_space
- * @index:	the page index
- * @filler:	function to perform the read
- * @data:	first arg to filler(data, page) function, often left as NULL
- *
- * Read into the page cache. If a page already exists, and PageUptodate() is
- * not set, try to fill the page then wait for it to become unlocked.
- *
- * If the page does not get brought uptodate, return -EIO.
- */
-struct page *read_cache_page(struct address_space *mapping,
-				pgoff_t index,
-				int (*filler)(void *, struct page *),
-				void *data)
-{
-	return wait_on_page_read(read_cache_page_async(mapping, index, filler, data));
-}
-EXPORT_SYMBOL(read_cache_page);
-
 static size_t __iovec_copy_from_user_inatomic(char *vaddr,
 			const struct iovec *iov, size_t base, size_t bytes)
 {
-- 
1.7.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
