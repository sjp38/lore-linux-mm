Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 50716828F4
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:42:21 -0400 (EDT)
Received: by mail-pf0-f171.google.com with SMTP id u190so238224800pfb.3
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:42:21 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id p86si16668950pfa.161.2016.03.20.11.42.14
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:42:14 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 59/71] reiserfs: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:41:06 +0300
Message-Id: <1458499278-1516-60-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
with promise that one day it will be possible to implement page cache with
bigger chunks than PAGE_SIZE.

This promise never materialized. And unlikely will.

We have many places where PAGE_CACHE_SIZE assumed to be equal to
PAGE_SIZE. And it's constant source of confusion on whether PAGE_CACHE_*
or PAGE_* constant should be used in a particular case, especially on the
border between fs and mm.

Global switching to PAGE_CACHE_SIZE != PAGE_SIZE would cause to much
breakage to be doable.

Let's stop pretending that pages in page cache are special. They are not.

The changes are pretty straight-forward:

 - <foo> << (PAGE_CACHE_SHIFT - PAGE_SHIFT) -> <foo>;

 - PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} -> PAGE_{SIZE,SHIFT,MASK,ALIGN};

 - page_cache_get() -> get_page();

 - page_cache_release() -> put_page();

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/squashfs/block.c        |  4 ++--
 fs/squashfs/cache.c        | 18 +++++++++---------
 fs/squashfs/decompressor.c |  2 +-
 fs/squashfs/file.c         | 24 ++++++++++++------------
 fs/squashfs/file_direct.c  | 22 +++++++++++-----------
 fs/squashfs/lz4_wrapper.c  |  8 ++++----
 fs/squashfs/lzo_wrapper.c  |  8 ++++----
 fs/squashfs/page_actor.c   |  4 ++--
 fs/squashfs/page_actor.h   |  2 +-
 fs/squashfs/super.c        |  2 +-
 fs/squashfs/symlink.c      |  6 +++---
 fs/squashfs/xz_wrapper.c   |  4 ++--
 fs/squashfs/zlib_wrapper.c |  4 ++--
 13 files changed, 54 insertions(+), 54 deletions(-)

diff --git a/fs/squashfs/block.c b/fs/squashfs/block.c
index 0cea9b9236d0..2c2618410d51 100644
--- a/fs/squashfs/block.c
+++ b/fs/squashfs/block.c
@@ -181,11 +181,11 @@ int squashfs_read_data(struct super_block *sb, u64 index, int length,
 			in = min(bytes, msblk->devblksize - offset);
 			bytes -= in;
 			while (in) {
-				if (pg_offset == PAGE_CACHE_SIZE) {
+				if (pg_offset == PAGE_SIZE) {
 					data = squashfs_next_page(output);
 					pg_offset = 0;
 				}
-				avail = min_t(int, in, PAGE_CACHE_SIZE -
+				avail = min_t(int, in, PAGE_SIZE -
 						pg_offset);
 				memcpy(data + pg_offset, bh[k]->b_data + offset,
 						avail);
diff --git a/fs/squashfs/cache.c b/fs/squashfs/cache.c
index 1cb70a0b2168..23813c078cc9 100644
--- a/fs/squashfs/cache.c
+++ b/fs/squashfs/cache.c
@@ -30,7 +30,7 @@
  * access the metadata and fragment caches.
  *
  * To avoid out of memory and fragmentation issues with vmalloc the cache
- * uses sequences of kmalloced PAGE_CACHE_SIZE buffers.
+ * uses sequences of kmalloced PAGE_SIZE buffers.
  *
  * It should be noted that the cache is not used for file datablocks, these
  * are decompressed and cached in the page-cache in the normal way.  The
@@ -231,7 +231,7 @@ void squashfs_cache_delete(struct squashfs_cache *cache)
 /*
  * Initialise cache allocating the specified number of entries, each of
  * size block_size.  To avoid vmalloc fragmentation issues each entry
- * is allocated as a sequence of kmalloced PAGE_CACHE_SIZE buffers.
+ * is allocated as a sequence of kmalloced PAGE_SIZE buffers.
  */
 struct squashfs_cache *squashfs_cache_init(char *name, int entries,
 	int block_size)
@@ -255,7 +255,7 @@ struct squashfs_cache *squashfs_cache_init(char *name, int entries,
 	cache->unused = entries;
 	cache->entries = entries;
 	cache->block_size = block_size;
-	cache->pages = block_size >> PAGE_CACHE_SHIFT;
+	cache->pages = block_size >> PAGE_SHIFT;
 	cache->pages = cache->pages ? cache->pages : 1;
 	cache->name = name;
 	cache->num_waiters = 0;
@@ -275,7 +275,7 @@ struct squashfs_cache *squashfs_cache_init(char *name, int entries,
 		}
 
 		for (j = 0; j < cache->pages; j++) {
-			entry->data[j] = kmalloc(PAGE_CACHE_SIZE, GFP_KERNEL);
+			entry->data[j] = kmalloc(PAGE_SIZE, GFP_KERNEL);
 			if (entry->data[j] == NULL) {
 				ERROR("Failed to allocate %s buffer\n", name);
 				goto cleanup;
@@ -314,10 +314,10 @@ int squashfs_copy_data(void *buffer, struct squashfs_cache_entry *entry,
 		return min(length, entry->length - offset);
 
 	while (offset < entry->length) {
-		void *buff = entry->data[offset / PAGE_CACHE_SIZE]
-				+ (offset % PAGE_CACHE_SIZE);
+		void *buff = entry->data[offset / PAGE_SIZE]
+				+ (offset % PAGE_SIZE);
 		int bytes = min_t(int, entry->length - offset,
-				PAGE_CACHE_SIZE - (offset % PAGE_CACHE_SIZE));
+				PAGE_SIZE - (offset % PAGE_SIZE));
 
 		if (bytes >= remaining) {
 			memcpy(buffer, buff, remaining);
@@ -415,7 +415,7 @@ struct squashfs_cache_entry *squashfs_get_datablock(struct super_block *sb,
  */
 void *squashfs_read_table(struct super_block *sb, u64 block, int length)
 {
-	int pages = (length + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	int pages = (length + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	int i, res;
 	void *table, *buffer, **data;
 	struct squashfs_page_actor *actor;
@@ -436,7 +436,7 @@ void *squashfs_read_table(struct super_block *sb, u64 block, int length)
 		goto failed2;
 	}
 
-	for (i = 0; i < pages; i++, buffer += PAGE_CACHE_SIZE)
+	for (i = 0; i < pages; i++, buffer += PAGE_SIZE)
 		data[i] = buffer;
 
 	res = squashfs_read_data(sb, block, length |
diff --git a/fs/squashfs/decompressor.c b/fs/squashfs/decompressor.c
index e9034bf6e5ae..d2bc13636f79 100644
--- a/fs/squashfs/decompressor.c
+++ b/fs/squashfs/decompressor.c
@@ -102,7 +102,7 @@ static void *get_comp_opts(struct super_block *sb, unsigned short flags)
 	 * Read decompressor specific options from file system if present
 	 */
 	if (SQUASHFS_COMP_OPTS(flags)) {
-		buffer = kmalloc(PAGE_CACHE_SIZE, GFP_KERNEL);
+		buffer = kmalloc(PAGE_SIZE, GFP_KERNEL);
 		if (buffer == NULL) {
 			comp_opts = ERR_PTR(-ENOMEM);
 			goto out;
diff --git a/fs/squashfs/file.c b/fs/squashfs/file.c
index e5c9689062ba..13d80947bf9e 100644
--- a/fs/squashfs/file.c
+++ b/fs/squashfs/file.c
@@ -175,7 +175,7 @@ static long long read_indexes(struct super_block *sb, int n,
 {
 	int err, i;
 	long long block = 0;
-	__le32 *blist = kmalloc(PAGE_CACHE_SIZE, GFP_KERNEL);
+	__le32 *blist = kmalloc(PAGE_SIZE, GFP_KERNEL);
 
 	if (blist == NULL) {
 		ERROR("read_indexes: Failed to allocate block_list\n");
@@ -183,7 +183,7 @@ static long long read_indexes(struct super_block *sb, int n,
 	}
 
 	while (n) {
-		int blocks = min_t(int, n, PAGE_CACHE_SIZE >> 2);
+		int blocks = min_t(int, n, PAGE_SIZE >> 2);
 
 		err = squashfs_read_metadata(sb, blist, start_block,
 				offset, blocks << 2);
@@ -377,19 +377,19 @@ void squashfs_copy_cache(struct page *page, struct squashfs_cache_entry *buffer,
 	struct inode *inode = page->mapping->host;
 	struct squashfs_sb_info *msblk = inode->i_sb->s_fs_info;
 	void *pageaddr;
-	int i, mask = (1 << (msblk->block_log - PAGE_CACHE_SHIFT)) - 1;
+	int i, mask = (1 << (msblk->block_log - PAGE_SHIFT)) - 1;
 	int start_index = page->index & ~mask, end_index = start_index | mask;
 
 	/*
 	 * Loop copying datablock into pages.  As the datablock likely covers
-	 * many PAGE_CACHE_SIZE pages (default block size is 128 KiB) explicitly
+	 * many PAGE_SIZE pages (default block size is 128 KiB) explicitly
 	 * grab the pages from the page cache, except for the page that we've
 	 * been called to fill.
 	 */
 	for (i = start_index; i <= end_index && bytes > 0; i++,
-			bytes -= PAGE_CACHE_SIZE, offset += PAGE_CACHE_SIZE) {
+			bytes -= PAGE_SIZE, offset += PAGE_SIZE) {
 		struct page *push_page;
-		int avail = buffer ? min_t(int, bytes, PAGE_CACHE_SIZE) : 0;
+		int avail = buffer ? min_t(int, bytes, PAGE_SIZE) : 0;
 
 		TRACE("bytes %d, i %d, available_bytes %d\n", bytes, i, avail);
 
@@ -404,14 +404,14 @@ void squashfs_copy_cache(struct page *page, struct squashfs_cache_entry *buffer,
 
 		pageaddr = kmap_atomic(push_page);
 		squashfs_copy_data(pageaddr, buffer, offset, avail);
-		memset(pageaddr + avail, 0, PAGE_CACHE_SIZE - avail);
+		memset(pageaddr + avail, 0, PAGE_SIZE - avail);
 		kunmap_atomic(pageaddr);
 		flush_dcache_page(push_page);
 		SetPageUptodate(push_page);
 skip_page:
 		unlock_page(push_page);
 		if (i != page->index)
-			page_cache_release(push_page);
+			put_page(push_page);
 	}
 }
 
@@ -454,7 +454,7 @@ static int squashfs_readpage(struct file *file, struct page *page)
 {
 	struct inode *inode = page->mapping->host;
 	struct squashfs_sb_info *msblk = inode->i_sb->s_fs_info;
-	int index = page->index >> (msblk->block_log - PAGE_CACHE_SHIFT);
+	int index = page->index >> (msblk->block_log - PAGE_SHIFT);
 	int file_end = i_size_read(inode) >> msblk->block_log;
 	int res;
 	void *pageaddr;
@@ -462,8 +462,8 @@ static int squashfs_readpage(struct file *file, struct page *page)
 	TRACE("Entered squashfs_readpage, page index %lx, start block %llx\n",
 				page->index, squashfs_i(inode)->start);
 
-	if (page->index >= ((i_size_read(inode) + PAGE_CACHE_SIZE - 1) >>
-					PAGE_CACHE_SHIFT))
+	if (page->index >= ((i_size_read(inode) + PAGE_SIZE - 1) >>
+					PAGE_SHIFT))
 		goto out;
 
 	if (index < file_end || squashfs_i(inode)->fragment_block ==
@@ -487,7 +487,7 @@ error_out:
 	SetPageError(page);
 out:
 	pageaddr = kmap_atomic(page);
-	memset(pageaddr, 0, PAGE_CACHE_SIZE);
+	memset(pageaddr, 0, PAGE_SIZE);
 	kunmap_atomic(pageaddr);
 	flush_dcache_page(page);
 	if (!PageError(page))
diff --git a/fs/squashfs/file_direct.c b/fs/squashfs/file_direct.c
index 43e7a7eddac0..cb485d8e0e91 100644
--- a/fs/squashfs/file_direct.c
+++ b/fs/squashfs/file_direct.c
@@ -30,8 +30,8 @@ int squashfs_readpage_block(struct page *target_page, u64 block, int bsize)
 	struct inode *inode = target_page->mapping->host;
 	struct squashfs_sb_info *msblk = inode->i_sb->s_fs_info;
 
-	int file_end = (i_size_read(inode) - 1) >> PAGE_CACHE_SHIFT;
-	int mask = (1 << (msblk->block_log - PAGE_CACHE_SHIFT)) - 1;
+	int file_end = (i_size_read(inode) - 1) >> PAGE_SHIFT;
+	int mask = (1 << (msblk->block_log - PAGE_SHIFT)) - 1;
 	int start_index = target_page->index & ~mask;
 	int end_index = start_index | mask;
 	int i, n, pages, missing_pages, bytes, res = -ENOMEM;
@@ -68,7 +68,7 @@ int squashfs_readpage_block(struct page *target_page, u64 block, int bsize)
 
 		if (PageUptodate(page[i])) {
 			unlock_page(page[i]);
-			page_cache_release(page[i]);
+			put_page(page[i]);
 			page[i] = NULL;
 			missing_pages++;
 		}
@@ -96,10 +96,10 @@ int squashfs_readpage_block(struct page *target_page, u64 block, int bsize)
 		goto mark_errored;
 
 	/* Last page may have trailing bytes not filled */
-	bytes = res % PAGE_CACHE_SIZE;
+	bytes = res % PAGE_SIZE;
 	if (bytes) {
 		pageaddr = kmap_atomic(page[pages - 1]);
-		memset(pageaddr + bytes, 0, PAGE_CACHE_SIZE - bytes);
+		memset(pageaddr + bytes, 0, PAGE_SIZE - bytes);
 		kunmap_atomic(pageaddr);
 	}
 
@@ -109,7 +109,7 @@ int squashfs_readpage_block(struct page *target_page, u64 block, int bsize)
 		SetPageUptodate(page[i]);
 		unlock_page(page[i]);
 		if (page[i] != target_page)
-			page_cache_release(page[i]);
+			put_page(page[i]);
 	}
 
 	kfree(actor);
@@ -127,7 +127,7 @@ mark_errored:
 		flush_dcache_page(page[i]);
 		SetPageError(page[i]);
 		unlock_page(page[i]);
-		page_cache_release(page[i]);
+		put_page(page[i]);
 	}
 
 out:
@@ -153,21 +153,21 @@ static int squashfs_read_cache(struct page *target_page, u64 block, int bsize,
 	}
 
 	for (n = 0; n < pages && bytes > 0; n++,
-			bytes -= PAGE_CACHE_SIZE, offset += PAGE_CACHE_SIZE) {
-		int avail = min_t(int, bytes, PAGE_CACHE_SIZE);
+			bytes -= PAGE_SIZE, offset += PAGE_SIZE) {
+		int avail = min_t(int, bytes, PAGE_SIZE);
 
 		if (page[n] == NULL)
 			continue;
 
 		pageaddr = kmap_atomic(page[n]);
 		squashfs_copy_data(pageaddr, buffer, offset, avail);
-		memset(pageaddr + avail, 0, PAGE_CACHE_SIZE - avail);
+		memset(pageaddr + avail, 0, PAGE_SIZE - avail);
 		kunmap_atomic(pageaddr);
 		flush_dcache_page(page[n]);
 		SetPageUptodate(page[n]);
 		unlock_page(page[n]);
 		if (page[n] != target_page)
-			page_cache_release(page[n]);
+			put_page(page[n]);
 	}
 
 out:
diff --git a/fs/squashfs/lz4_wrapper.c b/fs/squashfs/lz4_wrapper.c
index c31e2bc9c081..ff4468bd18b0 100644
--- a/fs/squashfs/lz4_wrapper.c
+++ b/fs/squashfs/lz4_wrapper.c
@@ -117,13 +117,13 @@ static int lz4_uncompress(struct squashfs_sb_info *msblk, void *strm,
 	data = squashfs_first_page(output);
 	buff = stream->output;
 	while (data) {
-		if (bytes <= PAGE_CACHE_SIZE) {
+		if (bytes <= PAGE_SIZE) {
 			memcpy(data, buff, bytes);
 			break;
 		}
-		memcpy(data, buff, PAGE_CACHE_SIZE);
-		buff += PAGE_CACHE_SIZE;
-		bytes -= PAGE_CACHE_SIZE;
+		memcpy(data, buff, PAGE_SIZE);
+		buff += PAGE_SIZE;
+		bytes -= PAGE_SIZE;
 		data = squashfs_next_page(output);
 	}
 	squashfs_finish_page(output);
diff --git a/fs/squashfs/lzo_wrapper.c b/fs/squashfs/lzo_wrapper.c
index 244b9fbfff7b..934c17e96590 100644
--- a/fs/squashfs/lzo_wrapper.c
+++ b/fs/squashfs/lzo_wrapper.c
@@ -102,13 +102,13 @@ static int lzo_uncompress(struct squashfs_sb_info *msblk, void *strm,
 	data = squashfs_first_page(output);
 	buff = stream->output;
 	while (data) {
-		if (bytes <= PAGE_CACHE_SIZE) {
+		if (bytes <= PAGE_SIZE) {
 			memcpy(data, buff, bytes);
 			break;
 		} else {
-			memcpy(data, buff, PAGE_CACHE_SIZE);
-			buff += PAGE_CACHE_SIZE;
-			bytes -= PAGE_CACHE_SIZE;
+			memcpy(data, buff, PAGE_SIZE);
+			buff += PAGE_SIZE;
+			bytes -= PAGE_SIZE;
 			data = squashfs_next_page(output);
 		}
 	}
diff --git a/fs/squashfs/page_actor.c b/fs/squashfs/page_actor.c
index 5a1c11f56441..9b7b1b6a7892 100644
--- a/fs/squashfs/page_actor.c
+++ b/fs/squashfs/page_actor.c
@@ -48,7 +48,7 @@ struct squashfs_page_actor *squashfs_page_actor_init(void **buffer,
 	if (actor == NULL)
 		return NULL;
 
-	actor->length = length ? : pages * PAGE_CACHE_SIZE;
+	actor->length = length ? : pages * PAGE_SIZE;
 	actor->buffer = buffer;
 	actor->pages = pages;
 	actor->next_page = 0;
@@ -88,7 +88,7 @@ struct squashfs_page_actor *squashfs_page_actor_init_special(struct page **page,
 	if (actor == NULL)
 		return NULL;
 
-	actor->length = length ? : pages * PAGE_CACHE_SIZE;
+	actor->length = length ? : pages * PAGE_SIZE;
 	actor->page = page;
 	actor->pages = pages;
 	actor->next_page = 0;
diff --git a/fs/squashfs/page_actor.h b/fs/squashfs/page_actor.h
index 26dd82008b82..98537eab27e2 100644
--- a/fs/squashfs/page_actor.h
+++ b/fs/squashfs/page_actor.h
@@ -24,7 +24,7 @@ static inline struct squashfs_page_actor *squashfs_page_actor_init(void **page,
 	if (actor == NULL)
 		return NULL;
 
-	actor->length = length ? : pages * PAGE_CACHE_SIZE;
+	actor->length = length ? : pages * PAGE_SIZE;
 	actor->page = page;
 	actor->pages = pages;
 	actor->next_page = 0;
diff --git a/fs/squashfs/super.c b/fs/squashfs/super.c
index 5e79bfa4f260..cf01e15a7b16 100644
--- a/fs/squashfs/super.c
+++ b/fs/squashfs/super.c
@@ -152,7 +152,7 @@ static int squashfs_fill_super(struct super_block *sb, void *data, int silent)
 	 * Check the system page size is not larger than the filesystem
 	 * block size (by default 128K).  This is currently not supported.
 	 */
-	if (PAGE_CACHE_SIZE > msblk->block_size) {
+	if (PAGE_SIZE > msblk->block_size) {
 		ERROR("Page size > filesystem block size (%d).  This is "
 			"currently not supported!\n", msblk->block_size);
 		goto failed_mount;
diff --git a/fs/squashfs/symlink.c b/fs/squashfs/symlink.c
index dbcc2f54bad4..d688ef42a6a1 100644
--- a/fs/squashfs/symlink.c
+++ b/fs/squashfs/symlink.c
@@ -48,10 +48,10 @@ static int squashfs_symlink_readpage(struct file *file, struct page *page)
 	struct inode *inode = page->mapping->host;
 	struct super_block *sb = inode->i_sb;
 	struct squashfs_sb_info *msblk = sb->s_fs_info;
-	int index = page->index << PAGE_CACHE_SHIFT;
+	int index = page->index << PAGE_SHIFT;
 	u64 block = squashfs_i(inode)->start;
 	int offset = squashfs_i(inode)->offset;
-	int length = min_t(int, i_size_read(inode) - index, PAGE_CACHE_SIZE);
+	int length = min_t(int, i_size_read(inode) - index, PAGE_SIZE);
 	int bytes, copied;
 	void *pageaddr;
 	struct squashfs_cache_entry *entry;
@@ -94,7 +94,7 @@ static int squashfs_symlink_readpage(struct file *file, struct page *page)
 		copied = squashfs_copy_data(pageaddr + bytes, entry, offset,
 								length - bytes);
 		if (copied == length - bytes)
-			memset(pageaddr + length, 0, PAGE_CACHE_SIZE - length);
+			memset(pageaddr + length, 0, PAGE_SIZE - length);
 		else
 			block = entry->next_index;
 		kunmap_atomic(pageaddr);
diff --git a/fs/squashfs/xz_wrapper.c b/fs/squashfs/xz_wrapper.c
index c609624e4b8a..6bfaef73d065 100644
--- a/fs/squashfs/xz_wrapper.c
+++ b/fs/squashfs/xz_wrapper.c
@@ -141,7 +141,7 @@ static int squashfs_xz_uncompress(struct squashfs_sb_info *msblk, void *strm,
 	stream->buf.in_pos = 0;
 	stream->buf.in_size = 0;
 	stream->buf.out_pos = 0;
-	stream->buf.out_size = PAGE_CACHE_SIZE;
+	stream->buf.out_size = PAGE_SIZE;
 	stream->buf.out = squashfs_first_page(output);
 
 	do {
@@ -158,7 +158,7 @@ static int squashfs_xz_uncompress(struct squashfs_sb_info *msblk, void *strm,
 			stream->buf.out = squashfs_next_page(output);
 			if (stream->buf.out != NULL) {
 				stream->buf.out_pos = 0;
-				total += PAGE_CACHE_SIZE;
+				total += PAGE_SIZE;
 			}
 		}
 
diff --git a/fs/squashfs/zlib_wrapper.c b/fs/squashfs/zlib_wrapper.c
index 8727caba6882..2ec24d128bce 100644
--- a/fs/squashfs/zlib_wrapper.c
+++ b/fs/squashfs/zlib_wrapper.c
@@ -69,7 +69,7 @@ static int zlib_uncompress(struct squashfs_sb_info *msblk, void *strm,
 	int zlib_err, zlib_init = 0, k = 0;
 	z_stream *stream = strm;
 
-	stream->avail_out = PAGE_CACHE_SIZE;
+	stream->avail_out = PAGE_SIZE;
 	stream->next_out = squashfs_first_page(output);
 	stream->avail_in = 0;
 
@@ -85,7 +85,7 @@ static int zlib_uncompress(struct squashfs_sb_info *msblk, void *strm,
 		if (stream->avail_out == 0) {
 			stream->next_out = squashfs_next_page(output);
 			if (stream->next_out != NULL)
-				stream->avail_out = PAGE_CACHE_SIZE;
+				stream->avail_out = PAGE_SIZE;
 		}
 
 		if (!zlib_init) {
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
