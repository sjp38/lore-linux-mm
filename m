Date: Wed, 19 Sep 2007 16:46:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] page->mapping clarification [3/3] changes in /fs
 generic
Message-Id: <20070919164630.ed4aa624.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070919164308.281f9960.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070919164308.281f9960.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, ricknu-0@student.ltu.se
List-ID: <linux-mm.kvack.org>

Make use of page-cache.h in fs-generic layer.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---
 fs/buffer.c       |   43 ++++++++++++++++++++++---------------------
 fs/fs-writeback.c |    2 +-
 fs/libfs.c        |    2 +-
 fs/mpage.c        |   13 +++++++------
 4 files changed, 31 insertions(+), 29 deletions(-)

Index: linux-2.6.23-rc6-mm1/fs/buffer.c
===================================================================
--- linux-2.6.23-rc6-mm1.orig/fs/buffer.c
+++ linux-2.6.23-rc6-mm1/fs/buffer.c
@@ -467,7 +467,7 @@ static void end_buffer_async_write(struc
 					"I/O error on %s\n",
 			       bdevname(bh->b_bdev, b));
 		}
-		set_bit(AS_EIO, &page->mapping->flags);
+		set_bit(AS_EIO, &page_mapping_cache(page)->flags);
 		set_buffer_write_io_error(bh);
 		clear_buffer_uptodate(bh);
 		SetPageError(page);
@@ -678,7 +678,7 @@ void write_boundary_block(struct block_d
 void mark_buffer_dirty_inode(struct buffer_head *bh, struct inode *inode)
 {
 	struct address_space *mapping = inode->i_mapping;
-	struct address_space *buffer_mapping = bh->b_page->mapping;
+	struct address_space *buffer_mapping = page_mapping_cache(bh->b_page);
 
 	mark_buffer_dirty(bh);
 	if (!mapping->assoc_mapping) {
@@ -713,7 +713,7 @@ static int __set_page_dirty(struct page 
 		return 0;
 
 	write_lock_irq(&mapping->tree_lock);
-	if (page->mapping) {	/* Race with truncate? */
+	if (is_page_consistent(page, mapping)) {/* Race with truncate? */
 		WARN_ON_ONCE(warn && !PageUptodate(page));
 
 		if (mapping_cap_account_dirty(mapping)) {
@@ -1204,7 +1204,8 @@ void __bforget(struct buffer_head *bh)
 {
 	clear_buffer_dirty(bh);
 	if (!list_empty(&bh->b_assoc_buffers)) {
-		struct address_space *buffer_mapping = bh->b_page->mapping;
+		struct address_space *buffer_mapping;
+		buffer_mapping = page_mapping_cache(bh->b_page);
 
 		spin_lock(&buffer_mapping->private_lock);
 		list_del_init(&bh->b_assoc_buffers);
@@ -1544,7 +1545,7 @@ void create_empty_buffers(struct page *p
 	} while (bh);
 	tail->b_this_page = head;
 
-	spin_lock(&page->mapping->private_lock);
+	spin_lock(&page_mapping_cache(page)->private_lock);
 	if (PageUptodate(page) || PageDirty(page)) {
 		bh = head;
 		do {
@@ -1556,7 +1557,7 @@ void create_empty_buffers(struct page *p
 		} while (bh != head);
 	}
 	attach_page_buffers(page, head);
-	spin_unlock(&page->mapping->private_lock);
+	spin_unlock(&page_mapping_cache(page)->private_lock);
 }
 EXPORT_SYMBOL(create_empty_buffers);
 
@@ -1763,7 +1764,7 @@ recover:
 	} while ((bh = bh->b_this_page) != head);
 	SetPageError(page);
 	BUG_ON(PageWriteback(page));
-	mapping_set_error(page->mapping, err);
+	mapping_set_error(page_mapping_cache(page), err);
 	set_page_writeback(page);
 	do {
 		struct buffer_head *next = bh->b_this_page;
@@ -2077,7 +2078,7 @@ EXPORT_SYMBOL(generic_write_end);
  */
 int block_read_full_page(struct page *page, get_block_t *get_block)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	sector_t iblock, lblock;
 	struct buffer_head *bh, *head, *arr[MAX_BUF_PER_PAGE];
 	unsigned int blocksize;
@@ -2298,7 +2299,7 @@ out:
 int block_prepare_write(struct page *page, unsigned from, unsigned to,
 			get_block_t *get_block)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	int err = __block_prepare_write(inode, page, from, to, get_block);
 	if (err)
 		ClearPageUptodate(page);
@@ -2307,7 +2308,7 @@ int block_prepare_write(struct page *pag
 
 int block_commit_write(struct page *page, unsigned from, unsigned to)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	__block_commit_write(inode,page,from,to);
 	return 0;
 }
@@ -2315,7 +2316,7 @@ int block_commit_write(struct page *page
 int generic_commit_write(struct file *file, struct page *page,
 		unsigned from, unsigned to)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	loff_t pos = ((loff_t)page->index << PAGE_CACHE_SHIFT) + to;
 	__block_commit_write(inode,page,from,to);
 	/*
@@ -2355,7 +2356,7 @@ block_page_mkwrite(struct vm_area_struct
 
 	lock_page(page);
 	size = i_size_read(inode);
-	if ((page->mapping != inode->i_mapping) ||
+	if (!is_page_consistent(page, inode->i_mapping) ||
 	    (page_offset(page) > size)) {
 		/* page got truncated out from underneath us */
 		goto out_unlock;
@@ -2393,7 +2394,7 @@ static void end_buffer_read_nobh(struct 
 int nobh_prepare_write(struct page *page, unsigned from, unsigned to,
 			get_block_t *get_block)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	const unsigned blkbits = inode->i_blkbits;
 	const unsigned blocksize = 1 << blkbits;
 	struct buffer_head *head, *bh;
@@ -2507,7 +2508,7 @@ failed:
 	 * the handling of potential IO errors during writeout would be hard
 	 * (could try doing synchronous writeout, but what if that fails too?)
 	 */
-	spin_lock(&page->mapping->private_lock);
+	spin_lock(&page_mapping_cache(page)->private_lock);
 	bh = head;
 	block_start = 0;
 	do {
@@ -2537,7 +2538,7 @@ next:
 		bh = bh->b_this_page;
 	} while (bh != head);
 	attach_page_buffers(page, head);
-	spin_unlock(&page->mapping->private_lock);
+	spin_unlock(&page_mapping_cache(page)->private_lock);
 
 	return ret;
 }
@@ -2550,7 +2551,7 @@ EXPORT_SYMBOL(nobh_prepare_write);
 int nobh_commit_write(struct file *file, struct page *page,
 		unsigned from, unsigned to)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	loff_t pos = ((loff_t)page->index << PAGE_CACHE_SHIFT) + to;
 
 	if (page_has_buffers(page))
@@ -2574,7 +2575,7 @@ EXPORT_SYMBOL(nobh_commit_write);
 int nobh_writepage(struct page *page, get_block_t *get_block,
 			struct writeback_control *wbc)
 {
-	struct inode * const inode = page->mapping->host;
+	struct inode * const inode = page_inode(page);
 	loff_t i_size = i_size_read(inode);
 	const pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
 	unsigned offset;
@@ -2739,7 +2740,7 @@ out:
 int block_write_full_page(struct page *page, get_block_t *get_block,
 			struct writeback_control *wbc)
 {
-	struct inode * const inode = page->mapping->host;
+	struct inode * const inode = page_inode(page);
 	loff_t i_size = i_size_read(inode);
 	const pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
 	unsigned offset;
@@ -2968,8 +2969,8 @@ drop_buffers(struct page *page, struct b
 
 	bh = head;
 	do {
-		if (buffer_write_io_error(bh) && page->mapping)
-			set_bit(AS_EIO, &page->mapping->flags);
+		if (buffer_write_io_error(bh) && page_is_pagecache(page))
+			set_bit(AS_EIO, &page_mapping_cache(page)->flags);
 		if (buffer_busy(bh))
 			goto failed;
 		bh = bh->b_this_page;
@@ -2991,7 +2992,7 @@ failed:
 
 int try_to_free_buffers(struct page *page)
 {
-	struct address_space * const mapping = page->mapping;
+	struct address_space * const mapping = page_mapping_cache(page);
 	struct buffer_head *buffers_to_free = NULL;
 	int ret = 0;
 
Index: linux-2.6.23-rc6-mm1/fs/fs-writeback.c
===================================================================
--- linux-2.6.23-rc6-mm1.orig/fs/fs-writeback.c
+++ linux-2.6.23-rc6-mm1/fs/fs-writeback.c
@@ -99,7 +99,7 @@ static void __check_dirty_inode_list(str
  * the block-special inode (/dev/hda1) itself.  And the ->dirtied_when field of
  * the kernel-internal blockdev inode represents the dirtying time of the
  * blockdev's pages.  This is why for I_DIRTY_PAGES we always use
- * page->mapping->host, so the page-dirtying time is recorded in the internal
+ * page_inode(page), so the page-dirtying time is recorded in the internal
  * blockdev inode.
  */
 void __mark_inode_dirty(struct inode *inode, int flags)
Index: linux-2.6.23-rc6-mm1/fs/libfs.c
===================================================================
--- linux-2.6.23-rc6-mm1.orig/fs/libfs.c
+++ linux-2.6.23-rc6-mm1/fs/libfs.c
@@ -374,7 +374,7 @@ int simple_write_begin(struct file *file
 static int simple_commit_write(struct file *file, struct page *page,
 			       unsigned from, unsigned to)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	loff_t pos = ((loff_t)page->index << PAGE_CACHE_SHIFT) + to;
 
 	if (!PageUptodate(page))
Index: linux-2.6.23-rc6-mm1/fs/mpage.c
===================================================================
--- linux-2.6.23-rc6-mm1.orig/fs/mpage.c
+++ linux-2.6.23-rc6-mm1/fs/mpage.c
@@ -81,8 +81,9 @@ static int mpage_end_io_write(struct bio
 
 		if (!uptodate){
 			SetPageError(page);
-			if (page->mapping)
-				set_bit(AS_EIO, &page->mapping->flags);
+			if (page_is_pagecache(page))
+				set_bit(AS_EIO,
+					&page_mapping_cache(page)->flags);
 		}
 		end_page_writeback(page);
 	} while (bvec >= bio->bi_io_vec);
@@ -133,7 +134,7 @@ mpage_alloc(struct block_device *bdev,
 static void 
 map_buffer_to_page(struct page *page, struct buffer_head *bh, int page_block) 
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct buffer_head *page_bh, *head;
 	int block = 0;
 
@@ -177,7 +178,7 @@ do_mpage_readpage(struct bio *bio, struc
 		sector_t *last_block_in_bio, struct buffer_head *map_bh,
 		unsigned long *first_logical_block, get_block_t get_block)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	const unsigned blkbits = inode->i_blkbits;
 	const unsigned blocks_per_page = PAGE_CACHE_SIZE >> blkbits;
 	const unsigned blocksize = 1 << blkbits;
@@ -460,8 +461,8 @@ static int __mpage_writepage(struct page
 {
 	struct mpage_data *mpd = data;
 	struct bio *bio = mpd->bio;
-	struct address_space *mapping = page->mapping;
-	struct inode *inode = page->mapping->host;
+	struct address_space *mapping = page_mapping_cache(page);
+	struct inode *inode = page_inode(page);
 	const unsigned blkbits = inode->i_blkbits;
 	unsigned long end_index;
 	const unsigned blocks_per_page = PAGE_CACHE_SIZE >> blkbits;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
