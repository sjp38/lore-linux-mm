Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id A0F186B000E
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 16:50:31 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 2/6] fs: Take mapping lock in generic read paths
Date: Thu, 31 Jan 2013 22:49:50 +0100
Message-Id: <1359668994-13433-3-git-send-email-jack@suse.cz>
In-Reply-To: <1359668994-13433-1-git-send-email-jack@suse.cz>
References: <1359668994-13433-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

Add mapping lock to struct address_space and grab it in all paths
creating pages in page cache to read data into them. That means buffered
read, readahead, and page fault code.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/inode.c              |    2 ++
 include/linux/fs.h      |    4 ++++
 include/linux/pagemap.h |    2 ++
 mm/filemap.c            |   21 ++++++++++++++++++---
 mm/readahead.c          |    8 ++++----
 5 files changed, 30 insertions(+), 7 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 14084b7..85db16c 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -168,6 +168,7 @@ int inode_init_always(struct super_block *sb, struct inode *inode)
 	mapping->private_data = NULL;
 	mapping->backing_dev_info = &default_backing_dev_info;
 	mapping->writeback_index = 0;
+	range_lock_tree_init(&mapping->mapping_lock);
 
 	/*
 	 * If the block_device provides a backing_dev_info for client
@@ -513,6 +514,7 @@ void clear_inode(struct inode *inode)
 	BUG_ON(!list_empty(&inode->i_data.private_list));
 	BUG_ON(!(inode->i_state & I_FREEING));
 	BUG_ON(inode->i_state & I_CLEAR);
+	BUG_ON(inode->i_data.mapping_lock.root.rb_node);
 	/* don't need i_lock here, no concurrent mods to i_state */
 	inode->i_state = I_FREEING | I_CLEAR;
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 7617ee0..2027d25 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -27,6 +27,7 @@
 #include <linux/lockdep.h>
 #include <linux/percpu-rwsem.h>
 #include <linux/blk_types.h>
+#include <linux/range_lock.h>
 
 #include <asm/byteorder.h>
 #include <uapi/linux/fs.h>
@@ -420,6 +421,9 @@ struct address_space {
 	spinlock_t		private_lock;	/* for use by the address_space */
 	struct list_head	private_list;	/* ditto */
 	void			*private_data;	/* ditto */
+	struct range_lock_tree	mapping_lock;	/* Lock protecting creation /
+						 * eviction of pages from
+						 * the mapping */
 } __attribute__((aligned(sizeof(long))));
 	/*
 	 * On most architectures that alignment is already the case; but
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 6da609d..ba81ea9 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -537,6 +537,8 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 				pgoff_t index, gfp_t gfp_mask);
 int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 				pgoff_t index, gfp_t gfp_mask);
+int add_to_page_cache_read(struct page *page, struct address_space *mapping,
+				pgoff_t offset, gfp_t gfp_mask);
 extern void delete_from_page_cache(struct page *page);
 extern void __delete_from_page_cache(struct page *page);
 int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask);
diff --git a/mm/filemap.c b/mm/filemap.c
index 83efee7..4826cb4 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -491,6 +491,20 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 }
 EXPORT_SYMBOL_GPL(add_to_page_cache_lru);
 
+int add_to_page_cache_read(struct page *page, struct address_space *mapping,
+				pgoff_t offset, gfp_t gfp_mask)
+{
+	struct range_lock mapping_lock;
+	int ret;
+
+	range_lock_init(&mapping_lock, offset, offset);
+	range_lock(&mapping->mapping_lock, &mapping_lock);
+	ret = add_to_page_cache_lru(page, mapping, offset, gfp_mask);
+	range_unlock(&mapping->mapping_lock, &mapping_lock);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(add_to_page_cache_read);
+
 #ifdef CONFIG_NUMA
 struct page *__page_cache_alloc(gfp_t gfp)
 {
@@ -1274,7 +1288,7 @@ no_cached_page:
 			desc->error = -ENOMEM;
 			goto out;
 		}
-		error = add_to_page_cache_lru(page, mapping,
+		error = add_to_page_cache_read(page, mapping,
 						index, GFP_KERNEL);
 		if (error) {
 			page_cache_release(page);
@@ -1493,7 +1507,8 @@ static int page_cache_read(struct file *file, pgoff_t offset)
 		if (!page)
 			return -ENOMEM;
 
-		ret = add_to_page_cache_lru(page, mapping, offset, GFP_KERNEL);
+		ret = add_to_page_cache_read(page, mapping, offset,
+						GFP_KERNEL);
 		if (ret == 0)
 			ret = mapping->a_ops->readpage(file, page);
 		else if (ret == -EEXIST)
@@ -1790,7 +1805,7 @@ repeat:
 		page = __page_cache_alloc(gfp | __GFP_COLD);
 		if (!page)
 			return ERR_PTR(-ENOMEM);
-		err = add_to_page_cache_lru(page, mapping, index, gfp);
+		err = add_to_page_cache_read(page, mapping, index, gfp);
 		if (unlikely(err)) {
 			page_cache_release(page);
 			if (err == -EEXIST)
diff --git a/mm/readahead.c b/mm/readahead.c
index 7963f23..28a5e40 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -89,7 +89,7 @@ int read_cache_pages(struct address_space *mapping, struct list_head *pages,
 	while (!list_empty(pages)) {
 		page = list_to_page(pages);
 		list_del(&page->lru);
-		if (add_to_page_cache_lru(page, mapping,
+		if (add_to_page_cache_read(page, mapping,
 					page->index, GFP_KERNEL)) {
 			read_cache_pages_invalidate_page(mapping, page);
 			continue;
@@ -126,11 +126,11 @@ static int read_pages(struct address_space *mapping, struct file *filp,
 
 	for (page_idx = 0; page_idx < nr_pages; page_idx++) {
 		struct page *page = list_to_page(pages);
+
 		list_del(&page->lru);
-		if (!add_to_page_cache_lru(page, mapping,
-					page->index, GFP_KERNEL)) {
+		if (!add_to_page_cache_read(page, mapping,
+					page->index, GFP_KERNEL))
 			mapping->a_ops->readpage(filp, page);
-		}
 		page_cache_release(page);
 	}
 	ret = 0;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
