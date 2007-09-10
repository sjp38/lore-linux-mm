Date: Mon, 10 Sep 2007 18:44:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] add page->mapping handling interface [3/35] changes in
 generic parts
Message-Id: <20070910184432.df3b0a3d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Changes page->mapping hanlding of generic fs routine and kexec.
(other than mm layer..)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---
 fs/buffer.c    |   43 ++++++++++++++++++++++---------------------
 fs/libfs.c     |    2 +-
 fs/mpage.c     |   13 +++++++------
 kernel/kexec.c |    2 +-
 4 files changed, 31 insertions(+), 29 deletions(-)

Index: test-2.6.23-rc4-mm1/kernel/kexec.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/kernel/kexec.c
+++ test-2.6.23-rc4-mm1/kernel/kexec.c
@@ -347,7 +347,7 @@ static struct page *kimage_alloc_pages(g
 	pages = alloc_pages(gfp_mask, order);
 	if (pages) {
 		unsigned int count, i;
-		pages->mapping = NULL;
+		pages->mapping = 0;
 		set_page_private(pages, order);
 		count = 1 << order;
 		for (i = 0; i < count; i++)
Index: test-2.6.23-rc4-mm1/fs/buffer.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/buffer.c
+++ test-2.6.23-rc4-mm1/fs/buffer.c
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
+	if (page_is_pagecache(page)) {	/* Race with truncate? */
 		WARN_ON_ONCE(warn && !PageUptodate(page));
 
 		if (mapping_cap_account_dirty(mapping)) {
@@ -1202,7 +1202,8 @@ void __bforget(struct buffer_head *bh)
 {
 	clear_buffer_dirty(bh);
 	if (!list_empty(&bh->b_assoc_buffers)) {
-		struct address_space *buffer_mapping = bh->b_page->mapping;
+		struct address_space *buffer_mapping =
+					page_mapping_cache(bh->b_page);
 
 		spin_lock(&buffer_mapping->private_lock);
 		list_del_init(&bh->b_assoc_buffers);
@@ -1542,7 +1543,7 @@ void create_empty_buffers(struct page *p
 	} while (bh);
 	tail->b_this_page = head;
 
-	spin_lock(&page->mapping->private_lock);
+	spin_lock(&page_mapping_cache(page)->private_lock);
 	if (PageUptodate(page) || PageDirty(page)) {
 		bh = head;
 		do {
@@ -1554,7 +1555,7 @@ void create_empty_buffers(struct page *p
 		} while (bh != head);
 	}
 	attach_page_buffers(page, head);
-	spin_unlock(&page->mapping->private_lock);
+	spin_unlock(&page_mapping_cache(page)->private_lock);
 }
 EXPORT_SYMBOL(create_empty_buffers);
 
@@ -1761,7 +1762,7 @@ recover:
 	} while ((bh = bh->b_this_page) != head);
 	SetPageError(page);
 	BUG_ON(PageWriteback(page));
-	mapping_set_error(page->mapping, err);
+	mapping_set_error(page_mapping_cache(page), err);
 	set_page_writeback(page);
 	do {
 		struct buffer_head *next = bh->b_this_page;
@@ -2075,7 +2076,7 @@ EXPORT_SYMBOL(generic_write_end);
  */
 int block_read_full_page(struct page *page, get_block_t *get_block)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	sector_t iblock, lblock;
 	struct buffer_head *bh, *head, *arr[MAX_BUF_PER_PAGE];
 	unsigned int blocksize;
@@ -2296,7 +2297,7 @@ out:
 int block_prepare_write(struct page *page, unsigned from, unsigned to,
 			get_block_t *get_block)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	int err = __block_prepare_write(inode, page, from, to, get_block);
 	if (err)
 		ClearPageUptodate(page);
@@ -2305,7 +2306,7 @@ int block_prepare_write(struct page *pag
 
 int block_commit_write(struct page *page, unsigned from, unsigned to)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	__block_commit_write(inode,page,from,to);
 	return 0;
 }
@@ -2313,7 +2314,7 @@ int block_commit_write(struct page *page
 int generic_commit_write(struct file *file, struct page *page,
 		unsigned from, unsigned to)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	loff_t pos = ((loff_t)page->index << PAGE_CACHE_SHIFT) + to;
 	__block_commit_write(inode,page,from,to);
 	/*
@@ -2353,7 +2354,7 @@ block_page_mkwrite(struct vm_area_struct
 
 	lock_page(page);
 	size = i_size_read(inode);
-	if ((page->mapping != inode->i_mapping) ||
+	if ((!pagecache_consistent(page, inode->i_mapping)) ||
 	    (page_offset(page) > size)) {
 		/* page got truncated out from underneath us */
 		goto out_unlock;
@@ -2391,7 +2392,7 @@ static void end_buffer_read_nobh(struct 
 int nobh_prepare_write(struct page *page, unsigned from, unsigned to,
 			get_block_t *get_block)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	const unsigned blkbits = inode->i_blkbits;
 	const unsigned blocksize = 1 << blkbits;
 	struct buffer_head *head, *bh;
@@ -2505,7 +2506,7 @@ failed:
 	 * the handling of potential IO errors during writeout would be hard
 	 * (could try doing synchronous writeout, but what if that fails too?)
 	 */
-	spin_lock(&page->mapping->private_lock);
+	spin_lock(&page_mapping_cache(page)->private_lock);
 	bh = head;
 	block_start = 0;
 	do {
@@ -2535,7 +2536,7 @@ next:
 		bh = bh->b_this_page;
 	} while (bh != head);
 	attach_page_buffers(page, head);
-	spin_unlock(&page->mapping->private_lock);
+	spin_unlock(&page_mapping_cache(page)->private_lock);
 
 	return ret;
 }
@@ -2548,7 +2549,7 @@ EXPORT_SYMBOL(nobh_prepare_write);
 int nobh_commit_write(struct file *file, struct page *page,
 		unsigned from, unsigned to)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	loff_t pos = ((loff_t)page->index << PAGE_CACHE_SHIFT) + to;
 
 	if (page_has_buffers(page))
@@ -2572,7 +2573,7 @@ EXPORT_SYMBOL(nobh_commit_write);
 int nobh_writepage(struct page *page, get_block_t *get_block,
 			struct writeback_control *wbc)
 {
-	struct inode * const inode = page->mapping->host;
+	struct inode * const inode = page_inode(page);
 	loff_t i_size = i_size_read(inode);
 	const pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
 	unsigned offset;
@@ -2737,7 +2738,7 @@ out:
 int block_write_full_page(struct page *page, get_block_t *get_block,
 			struct writeback_control *wbc)
 {
-	struct inode * const inode = page->mapping->host;
+	struct inode * const inode = page_inode(page);
 	loff_t i_size = i_size_read(inode);
 	const pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
 	unsigned offset;
@@ -2966,8 +2967,8 @@ drop_buffers(struct page *page, struct b
 
 	bh = head;
 	do {
-		if (buffer_write_io_error(bh) && page->mapping)
-			set_bit(AS_EIO, &page->mapping->flags);
+		if (buffer_write_io_error(bh) && page_is_pagecache(page))
+			set_bit(AS_EIO, &page_mapping_cache(page)->flags);
 		if (buffer_busy(bh))
 			goto failed;
 		bh = bh->b_this_page;
@@ -2989,7 +2990,7 @@ failed:
 
 int try_to_free_buffers(struct page *page)
 {
-	struct address_space * const mapping = page->mapping;
+	struct address_space * const mapping = page_mapping_cache(page);
 	struct buffer_head *buffers_to_free = NULL;
 	int ret = 0;
 
Index: test-2.6.23-rc4-mm1/fs/libfs.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/libfs.c
+++ test-2.6.23-rc4-mm1/fs/libfs.c
@@ -374,7 +374,7 @@ int simple_write_begin(struct file *file
 static int simple_commit_write(struct file *file, struct page *page,
 			       unsigned from, unsigned to)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	loff_t pos = ((loff_t)page->index << PAGE_CACHE_SHIFT) + to;
 
 	if (!PageUptodate(page))
Index: test-2.6.23-rc4-mm1/fs/mpage.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/mpage.c
+++ test-2.6.23-rc4-mm1/fs/mpage.c
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
