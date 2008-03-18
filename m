From: Andi Kleen <andi@firstfloor.org>
References: <20080318209.039112899@firstfloor.org>
In-Reply-To: <20080318209.039112899@firstfloor.org>
Subject: [PATCH prototype] [4/8] Add readahead function to read-ahead based on a bitmap
Message-Id: <20080318010938.523C11B41E1@basil.firstfloor.org>
Date: Tue, 18 Mar 2008 02:09:38 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Andi Kleen <andi@firstfloor.org>

---
 include/linux/mm.h |    3 ++
 mm/filemap.c       |    2 -
 mm/readahead.c     |   57 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 61 insertions(+), 1 deletion(-)

Index: linux/mm/readahead.c
===================================================================
--- linux.orig/mm/readahead.c
+++ linux/mm/readahead.c
@@ -117,6 +117,26 @@ out:
 	return ret;
 }
 
+static int preallocate_page(struct address_space *mapping,
+			    pgoff_t page_offset, struct list_head *page_pool)
+{
+	struct page *page;
+
+	/* silently cries for a gang lookup */
+	rcu_read_lock();
+	page = radix_tree_lookup(&mapping->page_tree, page_offset);
+	rcu_read_unlock();
+	if (page)
+		return 0;
+
+	page = page_cache_alloc_cold(mapping);
+	if (!page)
+		return 0;
+	page->index = page_offset;
+	list_add(&page->lru, page_pool);
+	return 1;
+}
+
 /*
  * do_page_cache_readahead actually reads a chunk of disk.  It allocates all
  * the pages first, then submits them all for I/O. This avoids the very bad
@@ -140,6 +160,7 @@ __do_page_cache_readahead(struct address
 	int page_idx;
 	int ret = 0;
 	loff_t isize = i_size_read(inode);
+	int n;
 
 	if (isize == 0)
 		goto out;
@@ -216,6 +237,42 @@ int force_page_cache_readahead(struct ad
 }
 
 /*
+ * Read-ahead a page for each bit set in the bitmap.
+ */
+void readahead_bitmap(struct file *f, pgoff_t pgoffset, unsigned long *bitmap,
+		     unsigned nbits)
+{
+	long bit, n;
+	LIST_HEAD(page_pool);
+	loff_t isize = i_size_read(f->f_dentry->d_inode);
+	unsigned long end_index;
+	struct address_space *mapping = f->f_mapping;
+
+	if (isize == 0)
+		return;
+
+	end_index = ((isize - 1) >> PAGE_CACHE_SHIFT);
+
+	if (!mapping->a_ops || (!mapping->a_ops->readpages  &&
+				!mapping->a_ops->readpage))
+		return;
+
+	bit = -1;
+	n = 0;
+	while ((bit = find_next_bit(bitmap, nbits, bit + 1)) < nbits) {
+		if (pgoffset + bit >= end_index)
+			break;
+		n += preallocate_page(f->f_mapping, pgoffset + bit,&page_pool);
+		if (n >= (MAX_PINNED_CHUNK / PAGE_CACHE_SIZE)) {
+			read_pages(f->f_mapping, f, &page_pool, n);
+			n = 0;
+		}
+	}
+	if (n > 0)
+		read_pages(f->f_mapping, f, &page_pool, n);
+}
+
+/*
  * This version skips the IO if the queue is read-congested, and will tell the
  * block layer to abandon the readahead if request allocation would block.
  *
Index: linux/mm/filemap.c
===================================================================
--- linux.orig/mm/filemap.c
+++ linux/mm/filemap.c
@@ -1240,7 +1240,7 @@ static ssize_t
 do_readahead(struct address_space *mapping, struct file *filp,
 	     pgoff_t index, unsigned long nr)
 {
-	if (!mapping || !mapping->a_ops || !mapping->a_ops->readpage)
+	if (!mapping || !mapping->a_ops)
 		return -EINVAL;
 
 	force_page_cache_readahead(mapping, filp, index,
Index: linux/include/linux/mm.h
===================================================================
--- linux.orig/include/linux/mm.h
+++ linux/include/linux/mm.h
@@ -1104,6 +1104,9 @@ void page_cache_sync_readahead(struct ad
 			       pgoff_t offset,
 			       unsigned long size);
 
+void readahead_bitmap(struct file *f, pgoff_t pgoffset, unsigned long *bitmap,
+		      unsigned nbits);
+
 void page_cache_async_readahead(struct address_space *mapping,
 				struct file_ra_state *ra,
 				struct file *filp,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
