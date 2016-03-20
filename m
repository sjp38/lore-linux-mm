Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id C621582F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:48:05 -0400 (EDT)
Received: by mail-pf0-f175.google.com with SMTP id 4so106645915pfd.0
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:48:05 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id qx12si13425508pab.169.2016.03.20.11.41.47
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:47 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 22/71] btrfs: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:29 +0300
Message-Id: <1458499278-1516-23-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>

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
Cc: Chris Mason <clm@fb.com>
Cc: Josef Bacik <jbacik@fb.com>
Cc: David Sterba <dsterba@suse.com>
---
 fs/btrfs/check-integrity.c        |  64 +++++-----
 fs/btrfs/compression.c            |  84 ++++++------
 fs/btrfs/ctree.c                  |   8 +-
 fs/btrfs/disk-io.c                |  14 +-
 fs/btrfs/extent-tree.c            |   4 +-
 fs/btrfs/extent_io.c              | 262 +++++++++++++++++++-------------------
 fs/btrfs/extent_io.h              |   6 +-
 fs/btrfs/file-item.c              |   4 +-
 fs/btrfs/file.c                   |  62 ++++-----
 fs/btrfs/free-space-cache.c       |  30 ++---
 fs/btrfs/inode-map.c              |  10 +-
 fs/btrfs/inode.c                  | 120 ++++++++---------
 fs/btrfs/ioctl.c                  |  82 ++++++------
 fs/btrfs/lzo.c                    |  32 ++---
 fs/btrfs/raid56.c                 |  28 ++--
 fs/btrfs/reada.c                  |  30 ++---
 fs/btrfs/relocation.c             |  16 +--
 fs/btrfs/scrub.c                  |  24 ++--
 fs/btrfs/send.c                   |  16 +--
 fs/btrfs/struct-funcs.c           |   4 +-
 fs/btrfs/tests/extent-io-tests.c  |  44 +++----
 fs/btrfs/tests/free-space-tests.c |   2 +-
 fs/btrfs/volumes.c                |  14 +-
 fs/btrfs/zlib.c                   |  38 +++---
 24 files changed, 499 insertions(+), 499 deletions(-)

diff --git a/fs/btrfs/check-integrity.c b/fs/btrfs/check-integrity.c
index 861d472564c1..e17b46805aa1 100644
--- a/fs/btrfs/check-integrity.c
+++ b/fs/btrfs/check-integrity.c
@@ -755,7 +755,7 @@ static int btrfsic_process_superblock(struct btrfsic_state *state,
 			BUG_ON(NULL == l);
 
 			ret = btrfsic_read_block(state, &tmp_next_block_ctx);
-			if (ret < (int)PAGE_CACHE_SIZE) {
+			if (ret < (int)PAGE_SIZE) {
 				printk(KERN_INFO
 				       "btrfsic: read @logical %llu failed!\n",
 				       tmp_next_block_ctx.start);
@@ -1229,15 +1229,15 @@ static void btrfsic_read_from_block_data(
 	size_t offset_in_page;
 	char *kaddr;
 	char *dst = (char *)dstv;
-	size_t start_offset = block_ctx->start & ((u64)PAGE_CACHE_SIZE - 1);
-	unsigned long i = (start_offset + offset) >> PAGE_CACHE_SHIFT;
+	size_t start_offset = block_ctx->start & ((u64)PAGE_SIZE - 1);
+	unsigned long i = (start_offset + offset) >> PAGE_SHIFT;
 
 	WARN_ON(offset + len > block_ctx->len);
-	offset_in_page = (start_offset + offset) & (PAGE_CACHE_SIZE - 1);
+	offset_in_page = (start_offset + offset) & (PAGE_SIZE - 1);
 
 	while (len > 0) {
-		cur = min(len, ((size_t)PAGE_CACHE_SIZE - offset_in_page));
-		BUG_ON(i >= DIV_ROUND_UP(block_ctx->len, PAGE_CACHE_SIZE));
+		cur = min(len, ((size_t)PAGE_SIZE - offset_in_page));
+		BUG_ON(i >= DIV_ROUND_UP(block_ctx->len, PAGE_SIZE));
 		kaddr = block_ctx->datav[i];
 		memcpy(dst, kaddr + offset_in_page, cur);
 
@@ -1603,8 +1603,8 @@ static void btrfsic_release_block_ctx(struct btrfsic_block_data_ctx *block_ctx)
 
 		BUG_ON(!block_ctx->datav);
 		BUG_ON(!block_ctx->pagev);
-		num_pages = (block_ctx->len + (u64)PAGE_CACHE_SIZE - 1) >>
-			    PAGE_CACHE_SHIFT;
+		num_pages = (block_ctx->len + (u64)PAGE_SIZE - 1) >>
+			    PAGE_SHIFT;
 		while (num_pages > 0) {
 			num_pages--;
 			if (block_ctx->datav[num_pages]) {
@@ -1635,15 +1635,15 @@ static int btrfsic_read_block(struct btrfsic_state *state,
 	BUG_ON(block_ctx->datav);
 	BUG_ON(block_ctx->pagev);
 	BUG_ON(block_ctx->mem_to_free);
-	if (block_ctx->dev_bytenr & ((u64)PAGE_CACHE_SIZE - 1)) {
+	if (block_ctx->dev_bytenr & ((u64)PAGE_SIZE - 1)) {
 		printk(KERN_INFO
 		       "btrfsic: read_block() with unaligned bytenr %llu\n",
 		       block_ctx->dev_bytenr);
 		return -1;
 	}
 
-	num_pages = (block_ctx->len + (u64)PAGE_CACHE_SIZE - 1) >>
-		    PAGE_CACHE_SHIFT;
+	num_pages = (block_ctx->len + (u64)PAGE_SIZE - 1) >>
+		    PAGE_SHIFT;
 	block_ctx->mem_to_free = kzalloc((sizeof(*block_ctx->datav) +
 					  sizeof(*block_ctx->pagev)) *
 					 num_pages, GFP_NOFS);
@@ -1674,8 +1674,8 @@ static int btrfsic_read_block(struct btrfsic_state *state,
 
 		for (j = i; j < num_pages; j++) {
 			ret = bio_add_page(bio, block_ctx->pagev[j],
-					   PAGE_CACHE_SIZE, 0);
-			if (PAGE_CACHE_SIZE != ret)
+					   PAGE_SIZE, 0);
+			if (PAGE_SIZE != ret)
 				break;
 		}
 		if (j == i) {
@@ -1691,7 +1691,7 @@ static int btrfsic_read_block(struct btrfsic_state *state,
 			return -1;
 		}
 		bio_put(bio);
-		dev_bytenr += (j - i) * PAGE_CACHE_SIZE;
+		dev_bytenr += (j - i) * PAGE_SIZE;
 		i = j;
 	}
 	for (i = 0; i < num_pages; i++) {
@@ -1767,9 +1767,9 @@ static int btrfsic_test_for_metadata(struct btrfsic_state *state,
 	u32 crc = ~(u32)0;
 	unsigned int i;
 
-	if (num_pages * PAGE_CACHE_SIZE < state->metablock_size)
+	if (num_pages * PAGE_SIZE < state->metablock_size)
 		return 1; /* not metadata */
-	num_pages = state->metablock_size >> PAGE_CACHE_SHIFT;
+	num_pages = state->metablock_size >> PAGE_SHIFT;
 	h = (struct btrfs_header *)datav[0];
 
 	if (memcmp(h->fsid, state->root->fs_info->fsid, BTRFS_UUID_SIZE))
@@ -1777,8 +1777,8 @@ static int btrfsic_test_for_metadata(struct btrfsic_state *state,
 
 	for (i = 0; i < num_pages; i++) {
 		u8 *data = i ? datav[i] : (datav[i] + BTRFS_CSUM_SIZE);
-		size_t sublen = i ? PAGE_CACHE_SIZE :
-				    (PAGE_CACHE_SIZE - BTRFS_CSUM_SIZE);
+		size_t sublen = i ? PAGE_SIZE :
+				    (PAGE_SIZE - BTRFS_CSUM_SIZE);
 
 		crc = btrfs_crc32c(crc, data, sublen);
 	}
@@ -1824,14 +1824,14 @@ again:
 		if (block->is_superblock) {
 			bytenr = btrfs_super_bytenr((struct btrfs_super_block *)
 						    mapped_datav[0]);
-			if (num_pages * PAGE_CACHE_SIZE <
+			if (num_pages * PAGE_SIZE <
 			    BTRFS_SUPER_INFO_SIZE) {
 				printk(KERN_INFO
 				       "btrfsic: cannot work with too short bios!\n");
 				return;
 			}
 			is_metadata = 1;
-			BUG_ON(BTRFS_SUPER_INFO_SIZE & (PAGE_CACHE_SIZE - 1));
+			BUG_ON(BTRFS_SUPER_INFO_SIZE & (PAGE_SIZE - 1));
 			processed_len = BTRFS_SUPER_INFO_SIZE;
 			if (state->print_mask &
 			    BTRFSIC_PRINT_MASK_TREE_BEFORE_SB_WRITE) {
@@ -1842,7 +1842,7 @@ again:
 		}
 		if (is_metadata) {
 			if (!block->is_superblock) {
-				if (num_pages * PAGE_CACHE_SIZE <
+				if (num_pages * PAGE_SIZE <
 				    state->metablock_size) {
 					printk(KERN_INFO
 					       "btrfsic: cannot work with too short bios!\n");
@@ -1878,7 +1878,7 @@ again:
 			}
 			block->logical_bytenr = bytenr;
 		} else {
-			if (num_pages * PAGE_CACHE_SIZE <
+			if (num_pages * PAGE_SIZE <
 			    state->datablock_size) {
 				printk(KERN_INFO
 				       "btrfsic: cannot work with too short bios!\n");
@@ -2011,7 +2011,7 @@ again:
 			block->logical_bytenr = bytenr;
 			block->is_metadata = 1;
 			if (block->is_superblock) {
-				BUG_ON(PAGE_CACHE_SIZE !=
+				BUG_ON(PAGE_SIZE !=
 				       BTRFS_SUPER_INFO_SIZE);
 				ret = btrfsic_process_written_superblock(
 						state,
@@ -2170,8 +2170,8 @@ again:
 continue_loop:
 	BUG_ON(!processed_len);
 	dev_bytenr += processed_len;
-	mapped_datav += processed_len >> PAGE_CACHE_SHIFT;
-	num_pages -= processed_len >> PAGE_CACHE_SHIFT;
+	mapped_datav += processed_len >> PAGE_SHIFT;
+	num_pages -= processed_len >> PAGE_SHIFT;
 	goto again;
 }
 
@@ -2952,7 +2952,7 @@ static void __btrfsic_submit_bio(int rw, struct bio *bio)
 			goto leave;
 		cur_bytenr = dev_bytenr;
 		for (i = 0; i < bio->bi_vcnt; i++) {
-			BUG_ON(bio->bi_io_vec[i].bv_len != PAGE_CACHE_SIZE);
+			BUG_ON(bio->bi_io_vec[i].bv_len != PAGE_SIZE);
 			mapped_datav[i] = kmap(bio->bi_io_vec[i].bv_page);
 			if (!mapped_datav[i]) {
 				while (i > 0) {
@@ -3035,16 +3035,16 @@ int btrfsic_mount(struct btrfs_root *root,
 	struct list_head *dev_head = &fs_devices->devices;
 	struct btrfs_device *device;
 
-	if (root->nodesize & ((u64)PAGE_CACHE_SIZE - 1)) {
+	if (root->nodesize & ((u64)PAGE_SIZE - 1)) {
 		printk(KERN_INFO
-		       "btrfsic: cannot handle nodesize %d not being a multiple of PAGE_CACHE_SIZE %ld!\n",
-		       root->nodesize, PAGE_CACHE_SIZE);
+		       "btrfsic: cannot handle nodesize %d not being a multiple of PAGE_SIZE %ld!\n",
+		       root->nodesize, PAGE_SIZE);
 		return -1;
 	}
-	if (root->sectorsize & ((u64)PAGE_CACHE_SIZE - 1)) {
+	if (root->sectorsize & ((u64)PAGE_SIZE - 1)) {
 		printk(KERN_INFO
-		       "btrfsic: cannot handle sectorsize %d not being a multiple of PAGE_CACHE_SIZE %ld!\n",
-		       root->sectorsize, PAGE_CACHE_SIZE);
+		       "btrfsic: cannot handle sectorsize %d not being a multiple of PAGE_SIZE %ld!\n",
+		       root->sectorsize, PAGE_SIZE);
 		return -1;
 	}
 	state = kzalloc(sizeof(*state), GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
index 3346cd8f9910..ff61a41ac90b 100644
--- a/fs/btrfs/compression.c
+++ b/fs/btrfs/compression.c
@@ -119,7 +119,7 @@ static int check_compressed_csum(struct inode *inode,
 		csum = ~(u32)0;
 
 		kaddr = kmap_atomic(page);
-		csum = btrfs_csum_data(kaddr, csum, PAGE_CACHE_SIZE);
+		csum = btrfs_csum_data(kaddr, csum, PAGE_SIZE);
 		btrfs_csum_final(csum, (char *)&csum);
 		kunmap_atomic(kaddr);
 
@@ -190,7 +190,7 @@ csum_failed:
 	for (index = 0; index < cb->nr_pages; index++) {
 		page = cb->compressed_pages[index];
 		page->mapping = NULL;
-		page_cache_release(page);
+		put_page(page);
 	}
 
 	/* do io completion on the original bio */
@@ -224,8 +224,8 @@ out:
 static noinline void end_compressed_writeback(struct inode *inode,
 					      const struct compressed_bio *cb)
 {
-	unsigned long index = cb->start >> PAGE_CACHE_SHIFT;
-	unsigned long end_index = (cb->start + cb->len - 1) >> PAGE_CACHE_SHIFT;
+	unsigned long index = cb->start >> PAGE_SHIFT;
+	unsigned long end_index = (cb->start + cb->len - 1) >> PAGE_SHIFT;
 	struct page *pages[16];
 	unsigned long nr_pages = end_index - index + 1;
 	int i;
@@ -247,7 +247,7 @@ static noinline void end_compressed_writeback(struct inode *inode,
 			if (cb->errors)
 				SetPageError(pages[i]);
 			end_page_writeback(pages[i]);
-			page_cache_release(pages[i]);
+			put_page(pages[i]);
 		}
 		nr_pages -= ret;
 		index += ret;
@@ -304,7 +304,7 @@ static void end_compressed_bio_write(struct bio *bio)
 	for (index = 0; index < cb->nr_pages; index++) {
 		page = cb->compressed_pages[index];
 		page->mapping = NULL;
-		page_cache_release(page);
+		put_page(page);
 	}
 
 	/* finally free the cb struct */
@@ -341,7 +341,7 @@ int btrfs_submit_compressed_write(struct inode *inode, u64 start,
 	int ret;
 	int skip_sum = BTRFS_I(inode)->flags & BTRFS_INODE_NODATASUM;
 
-	WARN_ON(start & ((u64)PAGE_CACHE_SIZE - 1));
+	WARN_ON(start & ((u64)PAGE_SIZE - 1));
 	cb = kmalloc(compressed_bio_size(root, compressed_len), GFP_NOFS);
 	if (!cb)
 		return -ENOMEM;
@@ -374,14 +374,14 @@ int btrfs_submit_compressed_write(struct inode *inode, u64 start,
 		page->mapping = inode->i_mapping;
 		if (bio->bi_iter.bi_size)
 			ret = io_tree->ops->merge_bio_hook(WRITE, page, 0,
-							   PAGE_CACHE_SIZE,
+							   PAGE_SIZE,
 							   bio, 0);
 		else
 			ret = 0;
 
 		page->mapping = NULL;
-		if (ret || bio_add_page(bio, page, PAGE_CACHE_SIZE, 0) <
-		    PAGE_CACHE_SIZE) {
+		if (ret || bio_add_page(bio, page, PAGE_SIZE, 0) <
+		    PAGE_SIZE) {
 			bio_get(bio);
 
 			/*
@@ -410,15 +410,15 @@ int btrfs_submit_compressed_write(struct inode *inode, u64 start,
 			BUG_ON(!bio);
 			bio->bi_private = cb;
 			bio->bi_end_io = end_compressed_bio_write;
-			bio_add_page(bio, page, PAGE_CACHE_SIZE, 0);
+			bio_add_page(bio, page, PAGE_SIZE, 0);
 		}
-		if (bytes_left < PAGE_CACHE_SIZE) {
+		if (bytes_left < PAGE_SIZE) {
 			btrfs_info(BTRFS_I(inode)->root->fs_info,
 					"bytes left %lu compress len %lu nr %lu",
 			       bytes_left, cb->compressed_len, cb->nr_pages);
 		}
-		bytes_left -= PAGE_CACHE_SIZE;
-		first_byte += PAGE_CACHE_SIZE;
+		bytes_left -= PAGE_SIZE;
+		first_byte += PAGE_SIZE;
 		cond_resched();
 	}
 	bio_get(bio);
@@ -457,17 +457,17 @@ static noinline int add_ra_bio_pages(struct inode *inode,
 	int misses = 0;
 
 	page = cb->orig_bio->bi_io_vec[cb->orig_bio->bi_vcnt - 1].bv_page;
-	last_offset = (page_offset(page) + PAGE_CACHE_SIZE);
+	last_offset = (page_offset(page) + PAGE_SIZE);
 	em_tree = &BTRFS_I(inode)->extent_tree;
 	tree = &BTRFS_I(inode)->io_tree;
 
 	if (isize == 0)
 		return 0;
 
-	end_index = (i_size_read(inode) - 1) >> PAGE_CACHE_SHIFT;
+	end_index = (i_size_read(inode) - 1) >> PAGE_SHIFT;
 
 	while (last_offset < compressed_end) {
-		pg_index = last_offset >> PAGE_CACHE_SHIFT;
+		pg_index = last_offset >> PAGE_SHIFT;
 
 		if (pg_index > end_index)
 			break;
@@ -488,11 +488,11 @@ static noinline int add_ra_bio_pages(struct inode *inode,
 			break;
 
 		if (add_to_page_cache_lru(page, mapping, pg_index, GFP_NOFS)) {
-			page_cache_release(page);
+			put_page(page);
 			goto next;
 		}
 
-		end = last_offset + PAGE_CACHE_SIZE - 1;
+		end = last_offset + PAGE_SIZE - 1;
 		/*
 		 * at this point, we have a locked page in the page cache
 		 * for these bytes in the file.  But, we have to make
@@ -502,27 +502,27 @@ static noinline int add_ra_bio_pages(struct inode *inode,
 		lock_extent(tree, last_offset, end);
 		read_lock(&em_tree->lock);
 		em = lookup_extent_mapping(em_tree, last_offset,
-					   PAGE_CACHE_SIZE);
+					   PAGE_SIZE);
 		read_unlock(&em_tree->lock);
 
 		if (!em || last_offset < em->start ||
-		    (last_offset + PAGE_CACHE_SIZE > extent_map_end(em)) ||
+		    (last_offset + PAGE_SIZE > extent_map_end(em)) ||
 		    (em->block_start >> 9) != cb->orig_bio->bi_iter.bi_sector) {
 			free_extent_map(em);
 			unlock_extent(tree, last_offset, end);
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			break;
 		}
 		free_extent_map(em);
 
 		if (page->index == end_index) {
 			char *userpage;
-			size_t zero_offset = isize & (PAGE_CACHE_SIZE - 1);
+			size_t zero_offset = isize & (PAGE_SIZE - 1);
 
 			if (zero_offset) {
 				int zeros;
-				zeros = PAGE_CACHE_SIZE - zero_offset;
+				zeros = PAGE_SIZE - zero_offset;
 				userpage = kmap_atomic(page);
 				memset(userpage + zero_offset, 0, zeros);
 				flush_dcache_page(page);
@@ -531,19 +531,19 @@ static noinline int add_ra_bio_pages(struct inode *inode,
 		}
 
 		ret = bio_add_page(cb->orig_bio, page,
-				   PAGE_CACHE_SIZE, 0);
+				   PAGE_SIZE, 0);
 
-		if (ret == PAGE_CACHE_SIZE) {
+		if (ret == PAGE_SIZE) {
 			nr_pages++;
-			page_cache_release(page);
+			put_page(page);
 		} else {
 			unlock_extent(tree, last_offset, end);
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			break;
 		}
 next:
-		last_offset += PAGE_CACHE_SIZE;
+		last_offset += PAGE_SIZE;
 	}
 	return 0;
 }
@@ -567,7 +567,7 @@ int btrfs_submit_compressed_read(struct inode *inode, struct bio *bio,
 	struct extent_map_tree *em_tree;
 	struct compressed_bio *cb;
 	struct btrfs_root *root = BTRFS_I(inode)->root;
-	unsigned long uncompressed_len = bio->bi_vcnt * PAGE_CACHE_SIZE;
+	unsigned long uncompressed_len = bio->bi_vcnt * PAGE_SIZE;
 	unsigned long compressed_len;
 	unsigned long nr_pages;
 	unsigned long pg_index;
@@ -589,7 +589,7 @@ int btrfs_submit_compressed_read(struct inode *inode, struct bio *bio,
 	read_lock(&em_tree->lock);
 	em = lookup_extent_mapping(em_tree,
 				   page_offset(bio->bi_io_vec->bv_page),
-				   PAGE_CACHE_SIZE);
+				   PAGE_SIZE);
 	read_unlock(&em_tree->lock);
 	if (!em)
 		return -EIO;
@@ -617,7 +617,7 @@ int btrfs_submit_compressed_read(struct inode *inode, struct bio *bio,
 	cb->compress_type = extent_compress_type(bio_flags);
 	cb->orig_bio = bio;
 
-	nr_pages = DIV_ROUND_UP(compressed_len, PAGE_CACHE_SIZE);
+	nr_pages = DIV_ROUND_UP(compressed_len, PAGE_SIZE);
 	cb->compressed_pages = kcalloc(nr_pages, sizeof(struct page *),
 				       GFP_NOFS);
 	if (!cb->compressed_pages)
@@ -640,7 +640,7 @@ int btrfs_submit_compressed_read(struct inode *inode, struct bio *bio,
 	add_ra_bio_pages(inode, em_start + em_len, cb);
 
 	/* include any pages we added in add_ra-bio_pages */
-	uncompressed_len = bio->bi_vcnt * PAGE_CACHE_SIZE;
+	uncompressed_len = bio->bi_vcnt * PAGE_SIZE;
 	cb->len = uncompressed_len;
 
 	comp_bio = compressed_bio_alloc(bdev, cur_disk_byte, GFP_NOFS);
@@ -653,18 +653,18 @@ int btrfs_submit_compressed_read(struct inode *inode, struct bio *bio,
 	for (pg_index = 0; pg_index < nr_pages; pg_index++) {
 		page = cb->compressed_pages[pg_index];
 		page->mapping = inode->i_mapping;
-		page->index = em_start >> PAGE_CACHE_SHIFT;
+		page->index = em_start >> PAGE_SHIFT;
 
 		if (comp_bio->bi_iter.bi_size)
 			ret = tree->ops->merge_bio_hook(READ, page, 0,
-							PAGE_CACHE_SIZE,
+							PAGE_SIZE,
 							comp_bio, 0);
 		else
 			ret = 0;
 
 		page->mapping = NULL;
-		if (ret || bio_add_page(comp_bio, page, PAGE_CACHE_SIZE, 0) <
-		    PAGE_CACHE_SIZE) {
+		if (ret || bio_add_page(comp_bio, page, PAGE_SIZE, 0) <
+		    PAGE_SIZE) {
 			bio_get(comp_bio);
 
 			ret = btrfs_bio_wq_end_io(root->fs_info, comp_bio,
@@ -702,9 +702,9 @@ int btrfs_submit_compressed_read(struct inode *inode, struct bio *bio,
 			comp_bio->bi_private = cb;
 			comp_bio->bi_end_io = end_compressed_bio_read;
 
-			bio_add_page(comp_bio, page, PAGE_CACHE_SIZE, 0);
+			bio_add_page(comp_bio, page, PAGE_SIZE, 0);
 		}
-		cur_disk_byte += PAGE_CACHE_SIZE;
+		cur_disk_byte += PAGE_SIZE;
 	}
 	bio_get(comp_bio);
 
@@ -1013,8 +1013,8 @@ int btrfs_decompress_buf2page(char *buf, unsigned long buf_start,
 
 	/* copy bytes from the working buffer into the pages */
 	while (working_bytes > 0) {
-		bytes = min(PAGE_CACHE_SIZE - *pg_offset,
-			    PAGE_CACHE_SIZE - buf_offset);
+		bytes = min(PAGE_SIZE - *pg_offset,
+			    PAGE_SIZE - buf_offset);
 		bytes = min(bytes, working_bytes);
 		kaddr = kmap_atomic(page_out);
 		memcpy(kaddr + *pg_offset, buf + buf_offset, bytes);
@@ -1027,7 +1027,7 @@ int btrfs_decompress_buf2page(char *buf, unsigned long buf_start,
 		current_buf_start += bytes;
 
 		/* check if we need to pick another page */
-		if (*pg_offset == PAGE_CACHE_SIZE) {
+		if (*pg_offset == PAGE_SIZE) {
 			(*pg_index)++;
 			if (*pg_index >= vcnt)
 				return 0;
diff --git a/fs/btrfs/ctree.c b/fs/btrfs/ctree.c
index 769e0ff1b4ce..1ef1c40d70f4 100644
--- a/fs/btrfs/ctree.c
+++ b/fs/btrfs/ctree.c
@@ -523,7 +523,7 @@ alloc_tree_mod_elem(struct extent_buffer *eb, int slot,
 	if (!tm)
 		return NULL;
 
-	tm->index = eb->start >> PAGE_CACHE_SHIFT;
+	tm->index = eb->start >> PAGE_SHIFT;
 	if (op != MOD_LOG_KEY_ADD) {
 		btrfs_node_key(eb, &tm->key, slot);
 		tm->blockptr = btrfs_node_blockptr(eb, slot);
@@ -588,7 +588,7 @@ tree_mod_log_insert_move(struct btrfs_fs_info *fs_info,
 		goto free_tms;
 	}
 
-	tm->index = eb->start >> PAGE_CACHE_SHIFT;
+	tm->index = eb->start >> PAGE_SHIFT;
 	tm->slot = src_slot;
 	tm->move.dst_slot = dst_slot;
 	tm->move.nr_items = nr_items;
@@ -699,7 +699,7 @@ tree_mod_log_insert_root(struct btrfs_fs_info *fs_info,
 		goto free_tms;
 	}
 
-	tm->index = new_root->start >> PAGE_CACHE_SHIFT;
+	tm->index = new_root->start >> PAGE_SHIFT;
 	tm->old_root.logical = old_root->start;
 	tm->old_root.level = btrfs_header_level(old_root);
 	tm->generation = btrfs_header_generation(old_root);
@@ -739,7 +739,7 @@ __tree_mod_log_search(struct btrfs_fs_info *fs_info, u64 start, u64 min_seq,
 	struct rb_node *node;
 	struct tree_mod_elem *cur = NULL;
 	struct tree_mod_elem *found = NULL;
-	u64 index = start >> PAGE_CACHE_SHIFT;
+	u64 index = start >> PAGE_SHIFT;
 
 	tree_mod_log_read_lock(fs_info);
 	tm_root = &fs_info->tree_mod_log;
diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index 5699bbc23feb..20ce055700f5 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -1055,7 +1055,7 @@ static void btree_invalidatepage(struct page *page, unsigned int offset,
 			   (unsigned long long)page_offset(page));
 		ClearPagePrivate(page);
 		set_page_private(page, 0);
-		page_cache_release(page);
+		put_page(page);
 	}
 }
 
@@ -1756,7 +1756,7 @@ static int setup_bdi(struct btrfs_fs_info *info, struct backing_dev_info *bdi)
 	if (err)
 		return err;
 
-	bdi->ra_pages = VM_MAX_READAHEAD * 1024 / PAGE_CACHE_SIZE;
+	bdi->ra_pages = VM_MAX_READAHEAD * 1024 / PAGE_SIZE;
 	bdi->congested_fn	= btrfs_congested_fn;
 	bdi->congested_data	= info;
 	bdi->capabilities |= BDI_CAP_CGROUP_WRITEBACK;
@@ -2534,7 +2534,7 @@ int open_ctree(struct super_block *sb,
 		err = ret;
 		goto fail_bdi;
 	}
-	fs_info->dirty_metadata_batch = PAGE_CACHE_SIZE *
+	fs_info->dirty_metadata_batch = PAGE_SIZE *
 					(1 + ilog2(nr_cpu_ids));
 
 	ret = percpu_counter_init(&fs_info->delalloc_bytes, 0, GFP_KERNEL);
@@ -2778,7 +2778,7 @@ int open_ctree(struct super_block *sb,
 	 * flag our filesystem as having big metadata blocks if
 	 * they are bigger than the page size
 	 */
-	if (btrfs_super_nodesize(disk_super) > PAGE_CACHE_SIZE) {
+	if (btrfs_super_nodesize(disk_super) > PAGE_SIZE) {
 		if (!(features & BTRFS_FEATURE_INCOMPAT_BIG_METADATA))
 			printk(KERN_INFO "BTRFS: flagging fs with big metadata feature\n");
 		features |= BTRFS_FEATURE_INCOMPAT_BIG_METADATA;
@@ -2828,7 +2828,7 @@ int open_ctree(struct super_block *sb,
 
 	fs_info->bdi.ra_pages *= btrfs_super_num_devices(disk_super);
 	fs_info->bdi.ra_pages = max(fs_info->bdi.ra_pages,
-				    SZ_4M / PAGE_CACHE_SIZE);
+				    SZ_4M / PAGE_SIZE);
 
 	tree_root->nodesize = nodesize;
 	tree_root->sectorsize = sectorsize;
@@ -4060,9 +4060,9 @@ static int btrfs_check_super_valid(struct btrfs_fs_info *fs_info,
 		ret = -EINVAL;
 	}
 	/* Only PAGE SIZE is supported yet */
-	if (sectorsize != PAGE_CACHE_SIZE) {
+	if (sectorsize != PAGE_SIZE) {
 		printk(KERN_ERR "BTRFS: sectorsize %llu not supported yet, only support %lu\n",
-				sectorsize, PAGE_CACHE_SIZE);
+				sectorsize, PAGE_SIZE);
 		ret = -EINVAL;
 	}
 	if (!is_power_of_2(nodesize) || nodesize < sectorsize ||
diff --git a/fs/btrfs/extent-tree.c b/fs/btrfs/extent-tree.c
index e2287c7c10be..e50a13ea4dd8 100644
--- a/fs/btrfs/extent-tree.c
+++ b/fs/btrfs/extent-tree.c
@@ -3452,7 +3452,7 @@ again:
 		num_pages = 1;
 
 	num_pages *= 16;
-	num_pages *= PAGE_CACHE_SIZE;
+	num_pages *= PAGE_SIZE;
 
 	ret = btrfs_check_data_free_space(inode, 0, num_pages);
 	if (ret)
@@ -4639,7 +4639,7 @@ static void shrink_delalloc(struct btrfs_root *root, u64 to_reclaim, u64 orig,
 	loops = 0;
 	while (delalloc_bytes && loops < 3) {
 		max_reclaim = min(delalloc_bytes, to_reclaim);
-		nr_pages = max_reclaim >> PAGE_CACHE_SHIFT;
+		nr_pages = max_reclaim >> PAGE_SHIFT;
 		btrfs_writeback_inodes_sb_nr(root, nr_pages, items);
 		/*
 		 * We need to wait for the async pages to actually start before
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index 392592dc7010..b7608fa4ddc4 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -1365,23 +1365,23 @@ int try_lock_extent(struct extent_io_tree *tree, u64 start, u64 end)
 
 void extent_range_clear_dirty_for_io(struct inode *inode, u64 start, u64 end)
 {
-	unsigned long index = start >> PAGE_CACHE_SHIFT;
-	unsigned long end_index = end >> PAGE_CACHE_SHIFT;
+	unsigned long index = start >> PAGE_SHIFT;
+	unsigned long end_index = end >> PAGE_SHIFT;
 	struct page *page;
 
 	while (index <= end_index) {
 		page = find_get_page(inode->i_mapping, index);
 		BUG_ON(!page); /* Pages should be in the extent_io_tree */
 		clear_page_dirty_for_io(page);
-		page_cache_release(page);
+		put_page(page);
 		index++;
 	}
 }
 
 void extent_range_redirty_for_io(struct inode *inode, u64 start, u64 end)
 {
-	unsigned long index = start >> PAGE_CACHE_SHIFT;
-	unsigned long end_index = end >> PAGE_CACHE_SHIFT;
+	unsigned long index = start >> PAGE_SHIFT;
+	unsigned long end_index = end >> PAGE_SHIFT;
 	struct page *page;
 
 	while (index <= end_index) {
@@ -1389,7 +1389,7 @@ void extent_range_redirty_for_io(struct inode *inode, u64 start, u64 end)
 		BUG_ON(!page); /* Pages should be in the extent_io_tree */
 		__set_page_dirty_nobuffers(page);
 		account_page_redirty(page);
-		page_cache_release(page);
+		put_page(page);
 		index++;
 	}
 }
@@ -1399,15 +1399,15 @@ void extent_range_redirty_for_io(struct inode *inode, u64 start, u64 end)
  */
 static void set_range_writeback(struct extent_io_tree *tree, u64 start, u64 end)
 {
-	unsigned long index = start >> PAGE_CACHE_SHIFT;
-	unsigned long end_index = end >> PAGE_CACHE_SHIFT;
+	unsigned long index = start >> PAGE_SHIFT;
+	unsigned long end_index = end >> PAGE_SHIFT;
 	struct page *page;
 
 	while (index <= end_index) {
 		page = find_get_page(tree->mapping, index);
 		BUG_ON(!page); /* Pages should be in the extent_io_tree */
 		set_page_writeback(page);
-		page_cache_release(page);
+		put_page(page);
 		index++;
 	}
 }
@@ -1558,8 +1558,8 @@ static noinline void __unlock_for_delalloc(struct inode *inode,
 {
 	int ret;
 	struct page *pages[16];
-	unsigned long index = start >> PAGE_CACHE_SHIFT;
-	unsigned long end_index = end >> PAGE_CACHE_SHIFT;
+	unsigned long index = start >> PAGE_SHIFT;
+	unsigned long end_index = end >> PAGE_SHIFT;
 	unsigned long nr_pages = end_index - index + 1;
 	int i;
 
@@ -1573,7 +1573,7 @@ static noinline void __unlock_for_delalloc(struct inode *inode,
 		for (i = 0; i < ret; i++) {
 			if (pages[i] != locked_page)
 				unlock_page(pages[i]);
-			page_cache_release(pages[i]);
+			put_page(pages[i]);
 		}
 		nr_pages -= ret;
 		index += ret;
@@ -1586,9 +1586,9 @@ static noinline int lock_delalloc_pages(struct inode *inode,
 					u64 delalloc_start,
 					u64 delalloc_end)
 {
-	unsigned long index = delalloc_start >> PAGE_CACHE_SHIFT;
+	unsigned long index = delalloc_start >> PAGE_SHIFT;
 	unsigned long start_index = index;
-	unsigned long end_index = delalloc_end >> PAGE_CACHE_SHIFT;
+	unsigned long end_index = delalloc_end >> PAGE_SHIFT;
 	unsigned long pages_locked = 0;
 	struct page *pages[16];
 	unsigned long nrpages;
@@ -1621,11 +1621,11 @@ static noinline int lock_delalloc_pages(struct inode *inode,
 				    pages[i]->mapping != inode->i_mapping) {
 					ret = -EAGAIN;
 					unlock_page(pages[i]);
-					page_cache_release(pages[i]);
+					put_page(pages[i]);
 					goto done;
 				}
 			}
-			page_cache_release(pages[i]);
+			put_page(pages[i]);
 			pages_locked++;
 		}
 		nrpages -= ret;
@@ -1638,7 +1638,7 @@ done:
 		__unlock_for_delalloc(inode, locked_page,
 			      delalloc_start,
 			      ((u64)(start_index + pages_locked - 1)) <<
-			      PAGE_CACHE_SHIFT);
+			      PAGE_SHIFT);
 	}
 	return ret;
 }
@@ -1698,7 +1698,7 @@ again:
 		free_extent_state(cached_state);
 		cached_state = NULL;
 		if (!loops) {
-			max_bytes = PAGE_CACHE_SIZE;
+			max_bytes = PAGE_SIZE;
 			loops = 1;
 			goto again;
 		} else {
@@ -1737,8 +1737,8 @@ void extent_clear_unlock_delalloc(struct inode *inode, u64 start, u64 end,
 	struct extent_io_tree *tree = &BTRFS_I(inode)->io_tree;
 	int ret;
 	struct page *pages[16];
-	unsigned long index = start >> PAGE_CACHE_SHIFT;
-	unsigned long end_index = end >> PAGE_CACHE_SHIFT;
+	unsigned long index = start >> PAGE_SHIFT;
+	unsigned long end_index = end >> PAGE_SHIFT;
 	unsigned long nr_pages = end_index - index + 1;
 	int i;
 
@@ -1759,7 +1759,7 @@ void extent_clear_unlock_delalloc(struct inode *inode, u64 start, u64 end,
 				SetPagePrivate2(pages[i]);
 
 			if (pages[i] == locked_page) {
-				page_cache_release(pages[i]);
+				put_page(pages[i]);
 				continue;
 			}
 			if (page_ops & PAGE_CLEAR_DIRTY)
@@ -1772,7 +1772,7 @@ void extent_clear_unlock_delalloc(struct inode *inode, u64 start, u64 end,
 				end_page_writeback(pages[i]);
 			if (page_ops & PAGE_UNLOCK)
 				unlock_page(pages[i]);
-			page_cache_release(pages[i]);
+			put_page(pages[i]);
 		}
 		nr_pages -= ret;
 		index += ret;
@@ -1961,7 +1961,7 @@ int test_range_bit(struct extent_io_tree *tree, u64 start, u64 end,
 static void check_page_uptodate(struct extent_io_tree *tree, struct page *page)
 {
 	u64 start = page_offset(page);
-	u64 end = start + PAGE_CACHE_SIZE - 1;
+	u64 end = start + PAGE_SIZE - 1;
 	if (test_range_bit(tree, start, end, EXTENT_UPTODATE, 1, NULL))
 		SetPageUptodate(page);
 }
@@ -2071,11 +2071,11 @@ int repair_eb_io_failure(struct btrfs_root *root, struct extent_buffer *eb,
 		struct page *p = eb->pages[i];
 
 		ret = repair_io_failure(root->fs_info->btree_inode, start,
-					PAGE_CACHE_SIZE, start, p,
+					PAGE_SIZE, start, p,
 					start - page_offset(p), mirror_num);
 		if (ret)
 			break;
-		start += PAGE_CACHE_SIZE;
+		start += PAGE_SIZE;
 	}
 
 	return ret;
@@ -2471,8 +2471,8 @@ static void end_bio_extent_writepage(struct bio *bio)
 		 * advance bv_offset and adjust bv_len to compensate.
 		 * Print a warning for nonzero offsets, and an error
 		 * if they don't add up to a full page.  */
-		if (bvec->bv_offset || bvec->bv_len != PAGE_CACHE_SIZE) {
-			if (bvec->bv_offset + bvec->bv_len != PAGE_CACHE_SIZE)
+		if (bvec->bv_offset || bvec->bv_len != PAGE_SIZE) {
+			if (bvec->bv_offset + bvec->bv_len != PAGE_SIZE)
 				btrfs_err(BTRFS_I(page->mapping->host)->root->fs_info,
 				   "partial page write in btrfs with offset %u and length %u",
 					bvec->bv_offset, bvec->bv_len);
@@ -2546,8 +2546,8 @@ static void end_bio_extent_readpage(struct bio *bio)
 		 * advance bv_offset and adjust bv_len to compensate.
 		 * Print a warning for nonzero offsets, and an error
 		 * if they don't add up to a full page.  */
-		if (bvec->bv_offset || bvec->bv_len != PAGE_CACHE_SIZE) {
-			if (bvec->bv_offset + bvec->bv_len != PAGE_CACHE_SIZE)
+		if (bvec->bv_offset || bvec->bv_len != PAGE_SIZE) {
+			if (bvec->bv_offset + bvec->bv_len != PAGE_SIZE)
 				btrfs_err(BTRFS_I(page->mapping->host)->root->fs_info,
 				   "partial page read in btrfs with offset %u and length %u",
 					bvec->bv_offset, bvec->bv_len);
@@ -2603,13 +2603,13 @@ static void end_bio_extent_readpage(struct bio *bio)
 readpage_ok:
 		if (likely(uptodate)) {
 			loff_t i_size = i_size_read(inode);
-			pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
+			pgoff_t end_index = i_size >> PAGE_SHIFT;
 			unsigned off;
 
 			/* Zero out the end if this page straddles i_size */
-			off = i_size & (PAGE_CACHE_SIZE-1);
+			off = i_size & (PAGE_SIZE-1);
 			if (page->index == end_index && off)
-				zero_user_segment(page, off, PAGE_CACHE_SIZE);
+				zero_user_segment(page, off, PAGE_SIZE);
 			SetPageUptodate(page);
 		} else {
 			ClearPageUptodate(page);
@@ -2773,7 +2773,7 @@ static int submit_extent_page(int rw, struct extent_io_tree *tree,
 	struct bio *bio;
 	int contig = 0;
 	int old_compressed = prev_bio_flags & EXTENT_BIO_COMPRESSED;
-	size_t page_size = min_t(size_t, size, PAGE_CACHE_SIZE);
+	size_t page_size = min_t(size_t, size, PAGE_SIZE);
 
 	if (bio_ret && *bio_ret) {
 		bio = *bio_ret;
@@ -2826,7 +2826,7 @@ static void attach_extent_buffer_page(struct extent_buffer *eb,
 {
 	if (!PagePrivate(page)) {
 		SetPagePrivate(page);
-		page_cache_get(page);
+		get_page(page);
 		set_page_private(page, (unsigned long)eb);
 	} else {
 		WARN_ON(page->private != (unsigned long)eb);
@@ -2837,7 +2837,7 @@ void set_page_extent_mapped(struct page *page)
 {
 	if (!PagePrivate(page)) {
 		SetPagePrivate(page);
-		page_cache_get(page);
+		get_page(page);
 		set_page_private(page, EXTENT_PAGE_PRIVATE);
 	}
 }
@@ -2885,7 +2885,7 @@ static int __do_readpage(struct extent_io_tree *tree,
 {
 	struct inode *inode = page->mapping->host;
 	u64 start = page_offset(page);
-	u64 page_end = start + PAGE_CACHE_SIZE - 1;
+	u64 page_end = start + PAGE_SIZE - 1;
 	u64 end;
 	u64 cur = start;
 	u64 extent_offset;
@@ -2914,12 +2914,12 @@ static int __do_readpage(struct extent_io_tree *tree,
 		}
 	}
 
-	if (page->index == last_byte >> PAGE_CACHE_SHIFT) {
+	if (page->index == last_byte >> PAGE_SHIFT) {
 		char *userpage;
-		size_t zero_offset = last_byte & (PAGE_CACHE_SIZE - 1);
+		size_t zero_offset = last_byte & (PAGE_SIZE - 1);
 
 		if (zero_offset) {
-			iosize = PAGE_CACHE_SIZE - zero_offset;
+			iosize = PAGE_SIZE - zero_offset;
 			userpage = kmap_atomic(page);
 			memset(userpage + zero_offset, 0, iosize);
 			flush_dcache_page(page);
@@ -2927,14 +2927,14 @@ static int __do_readpage(struct extent_io_tree *tree,
 		}
 	}
 	while (cur <= end) {
-		unsigned long pnr = (last_byte >> PAGE_CACHE_SHIFT) + 1;
+		unsigned long pnr = (last_byte >> PAGE_SHIFT) + 1;
 		bool force_bio_submit = false;
 
 		if (cur >= last_byte) {
 			char *userpage;
 			struct extent_state *cached = NULL;
 
-			iosize = PAGE_CACHE_SIZE - pg_offset;
+			iosize = PAGE_SIZE - pg_offset;
 			userpage = kmap_atomic(page);
 			memset(userpage + pg_offset, 0, iosize);
 			flush_dcache_page(page);
@@ -3117,7 +3117,7 @@ static inline void __do_contiguous_readpages(struct extent_io_tree *tree,
 	for (index = 0; index < nr_pages; index++) {
 		__do_readpage(tree, pages[index], get_extent, em_cached, bio,
 			      mirror_num, bio_flags, rw, prev_em_start);
-		page_cache_release(pages[index]);
+		put_page(pages[index]);
 	}
 }
 
@@ -3139,10 +3139,10 @@ static void __extent_readpages(struct extent_io_tree *tree,
 		page_start = page_offset(pages[index]);
 		if (!end) {
 			start = page_start;
-			end = start + PAGE_CACHE_SIZE - 1;
+			end = start + PAGE_SIZE - 1;
 			first_index = index;
 		} else if (end + 1 == page_start) {
-			end += PAGE_CACHE_SIZE;
+			end += PAGE_SIZE;
 		} else {
 			__do_contiguous_readpages(tree, &pages[first_index],
 						  index - first_index, start,
@@ -3150,7 +3150,7 @@ static void __extent_readpages(struct extent_io_tree *tree,
 						  bio, mirror_num, bio_flags,
 						  rw, prev_em_start);
 			start = page_start;
-			end = start + PAGE_CACHE_SIZE - 1;
+			end = start + PAGE_SIZE - 1;
 			first_index = index;
 		}
 	}
@@ -3172,7 +3172,7 @@ static int __extent_read_full_page(struct extent_io_tree *tree,
 	struct inode *inode = page->mapping->host;
 	struct btrfs_ordered_extent *ordered;
 	u64 start = page_offset(page);
-	u64 end = start + PAGE_CACHE_SIZE - 1;
+	u64 end = start + PAGE_SIZE - 1;
 	int ret;
 
 	while (1) {
@@ -3231,7 +3231,7 @@ static noinline_for_stack int writepage_delalloc(struct inode *inode,
 			      unsigned long *nr_written)
 {
 	struct extent_io_tree *tree = epd->tree;
-	u64 page_end = delalloc_start + PAGE_CACHE_SIZE - 1;
+	u64 page_end = delalloc_start + PAGE_SIZE - 1;
 	u64 nr_delalloc;
 	u64 delalloc_to_write = 0;
 	u64 delalloc_end = 0;
@@ -3270,11 +3270,11 @@ static noinline_for_stack int writepage_delalloc(struct inode *inode,
 		/*
 		 * delalloc_end is already one less than the total
 		 * length, so we don't subtract one from
-		 * PAGE_CACHE_SIZE
+		 * PAGE_SIZE
 		 */
 		delalloc_to_write += (delalloc_end - delalloc_start +
-				      PAGE_CACHE_SIZE) >>
-				      PAGE_CACHE_SHIFT;
+				      PAGE_SIZE) >>
+				      PAGE_SHIFT;
 		delalloc_start = delalloc_end + 1;
 	}
 	if (wbc->nr_to_write < delalloc_to_write) {
@@ -3323,7 +3323,7 @@ static noinline_for_stack int __extent_writepage_io(struct inode *inode,
 {
 	struct extent_io_tree *tree = epd->tree;
 	u64 start = page_offset(page);
-	u64 page_end = start + PAGE_CACHE_SIZE - 1;
+	u64 page_end = start + PAGE_SIZE - 1;
 	u64 end;
 	u64 cur = start;
 	u64 extent_offset;
@@ -3438,7 +3438,7 @@ static noinline_for_stack int __extent_writepage_io(struct inode *inode,
 		if (ret) {
 			SetPageError(page);
 		} else {
-			unsigned long max_nr = (i_size >> PAGE_CACHE_SHIFT) + 1;
+			unsigned long max_nr = (i_size >> PAGE_SHIFT) + 1;
 
 			set_range_writeback(tree, cur, cur + iosize - 1);
 			if (!PageWriteback(page)) {
@@ -3481,12 +3481,12 @@ static int __extent_writepage(struct page *page, struct writeback_control *wbc,
 	struct inode *inode = page->mapping->host;
 	struct extent_page_data *epd = data;
 	u64 start = page_offset(page);
-	u64 page_end = start + PAGE_CACHE_SIZE - 1;
+	u64 page_end = start + PAGE_SIZE - 1;
 	int ret;
 	int nr = 0;
 	size_t pg_offset = 0;
 	loff_t i_size = i_size_read(inode);
-	unsigned long end_index = i_size >> PAGE_CACHE_SHIFT;
+	unsigned long end_index = i_size >> PAGE_SHIFT;
 	int write_flags;
 	unsigned long nr_written = 0;
 
@@ -3501,10 +3501,10 @@ static int __extent_writepage(struct page *page, struct writeback_control *wbc,
 
 	ClearPageError(page);
 
-	pg_offset = i_size & (PAGE_CACHE_SIZE - 1);
+	pg_offset = i_size & (PAGE_SIZE - 1);
 	if (page->index > end_index ||
 	   (page->index == end_index && !pg_offset)) {
-		page->mapping->a_ops->invalidatepage(page, 0, PAGE_CACHE_SIZE);
+		page->mapping->a_ops->invalidatepage(page, 0, PAGE_SIZE);
 		unlock_page(page);
 		return 0;
 	}
@@ -3514,7 +3514,7 @@ static int __extent_writepage(struct page *page, struct writeback_control *wbc,
 
 		userpage = kmap_atomic(page);
 		memset(userpage + pg_offset, 0,
-		       PAGE_CACHE_SIZE - pg_offset);
+		       PAGE_SIZE - pg_offset);
 		kunmap_atomic(userpage);
 		flush_dcache_page(page);
 	}
@@ -3752,7 +3752,7 @@ static noinline_for_stack int write_one_eb(struct extent_buffer *eb,
 		clear_page_dirty_for_io(p);
 		set_page_writeback(p);
 		ret = submit_extent_page(rw, tree, wbc, p, offset >> 9,
-					 PAGE_CACHE_SIZE, 0, bdev, &epd->bio,
+					 PAGE_SIZE, 0, bdev, &epd->bio,
 					 -1, end_bio_extent_buffer_writepage,
 					 0, epd->bio_flags, bio_flags, false);
 		epd->bio_flags = bio_flags;
@@ -3764,7 +3764,7 @@ static noinline_for_stack int write_one_eb(struct extent_buffer *eb,
 			ret = -EIO;
 			break;
 		}
-		offset += PAGE_CACHE_SIZE;
+		offset += PAGE_SIZE;
 		update_nr_written(p, wbc, 1);
 		unlock_page(p);
 	}
@@ -3808,8 +3808,8 @@ int btree_write_cache_pages(struct address_space *mapping,
 		index = mapping->writeback_index; /* Start from prev offset */
 		end = -1;
 	} else {
-		index = wbc->range_start >> PAGE_CACHE_SHIFT;
-		end = wbc->range_end >> PAGE_CACHE_SHIFT;
+		index = wbc->range_start >> PAGE_SHIFT;
+		end = wbc->range_end >> PAGE_SHIFT;
 		scanned = 1;
 	}
 	if (wbc->sync_mode == WB_SYNC_ALL)
@@ -3952,8 +3952,8 @@ static int extent_write_cache_pages(struct extent_io_tree *tree,
 		index = mapping->writeback_index; /* Start from prev offset */
 		end = -1;
 	} else {
-		index = wbc->range_start >> PAGE_CACHE_SHIFT;
-		end = wbc->range_end >> PAGE_CACHE_SHIFT;
+		index = wbc->range_start >> PAGE_SHIFT;
+		end = wbc->range_end >> PAGE_SHIFT;
 		scanned = 1;
 	}
 	if (wbc->sync_mode == WB_SYNC_ALL)
@@ -4087,8 +4087,8 @@ int extent_write_locked_range(struct extent_io_tree *tree, struct inode *inode,
 	int ret = 0;
 	struct address_space *mapping = inode->i_mapping;
 	struct page *page;
-	unsigned long nr_pages = (end - start + PAGE_CACHE_SIZE) >>
-		PAGE_CACHE_SHIFT;
+	unsigned long nr_pages = (end - start + PAGE_SIZE) >>
+		PAGE_SHIFT;
 
 	struct extent_page_data epd = {
 		.bio = NULL,
@@ -4106,18 +4106,18 @@ int extent_write_locked_range(struct extent_io_tree *tree, struct inode *inode,
 	};
 
 	while (start <= end) {
-		page = find_get_page(mapping, start >> PAGE_CACHE_SHIFT);
+		page = find_get_page(mapping, start >> PAGE_SHIFT);
 		if (clear_page_dirty_for_io(page))
 			ret = __extent_writepage(page, &wbc_writepages, &epd);
 		else {
 			if (tree->ops && tree->ops->writepage_end_io_hook)
 				tree->ops->writepage_end_io_hook(page, start,
-						 start + PAGE_CACHE_SIZE - 1,
+						 start + PAGE_SIZE - 1,
 						 NULL, 1);
 			unlock_page(page);
 		}
-		page_cache_release(page);
-		start += PAGE_CACHE_SIZE;
+		put_page(page);
+		start += PAGE_SIZE;
 	}
 
 	flush_epd_write_bio(&epd);
@@ -4167,7 +4167,7 @@ int extent_readpages(struct extent_io_tree *tree,
 		list_del(&page->lru);
 		if (add_to_page_cache_lru(page, mapping,
 					page->index, GFP_NOFS)) {
-			page_cache_release(page);
+			put_page(page);
 			continue;
 		}
 
@@ -4201,7 +4201,7 @@ int extent_invalidatepage(struct extent_io_tree *tree,
 {
 	struct extent_state *cached_state = NULL;
 	u64 start = page_offset(page);
-	u64 end = start + PAGE_CACHE_SIZE - 1;
+	u64 end = start + PAGE_SIZE - 1;
 	size_t blocksize = page->mapping->host->i_sb->s_blocksize;
 
 	start += ALIGN(offset, blocksize);
@@ -4227,7 +4227,7 @@ static int try_release_extent_state(struct extent_map_tree *map,
 				    struct page *page, gfp_t mask)
 {
 	u64 start = page_offset(page);
-	u64 end = start + PAGE_CACHE_SIZE - 1;
+	u64 end = start + PAGE_SIZE - 1;
 	int ret = 1;
 
 	if (test_range_bit(tree, start, end,
@@ -4266,7 +4266,7 @@ int try_release_extent_mapping(struct extent_map_tree *map,
 {
 	struct extent_map *em;
 	u64 start = page_offset(page);
-	u64 end = start + PAGE_CACHE_SIZE - 1;
+	u64 end = start + PAGE_SIZE - 1;
 
 	if (gfpflags_allow_blocking(mask) &&
 	    page->mapping->host->i_size > SZ_16M) {
@@ -4591,14 +4591,14 @@ static void btrfs_release_extent_buffer_page(struct extent_buffer *eb)
 			ClearPagePrivate(page);
 			set_page_private(page, 0);
 			/* One for the page private */
-			page_cache_release(page);
+			put_page(page);
 		}
 
 		if (mapped)
 			spin_unlock(&page->mapping->private_lock);
 
 		/* One for when we alloced the page */
-		page_cache_release(page);
+		put_page(page);
 	} while (index != 0);
 }
 
@@ -4783,7 +4783,7 @@ struct extent_buffer *find_extent_buffer(struct btrfs_fs_info *fs_info,
 
 	rcu_read_lock();
 	eb = radix_tree_lookup(&fs_info->buffer_radix,
-			       start >> PAGE_CACHE_SHIFT);
+			       start >> PAGE_SHIFT);
 	if (eb && atomic_inc_not_zero(&eb->refs)) {
 		rcu_read_unlock();
 		/*
@@ -4833,7 +4833,7 @@ again:
 		goto free_eb;
 	spin_lock(&fs_info->buffer_lock);
 	ret = radix_tree_insert(&fs_info->buffer_radix,
-				start >> PAGE_CACHE_SHIFT, eb);
+				start >> PAGE_SHIFT, eb);
 	spin_unlock(&fs_info->buffer_lock);
 	radix_tree_preload_end();
 	if (ret == -EEXIST) {
@@ -4866,7 +4866,7 @@ struct extent_buffer *alloc_extent_buffer(struct btrfs_fs_info *fs_info,
 	unsigned long len = fs_info->tree_root->nodesize;
 	unsigned long num_pages = num_extent_pages(start, len);
 	unsigned long i;
-	unsigned long index = start >> PAGE_CACHE_SHIFT;
+	unsigned long index = start >> PAGE_SHIFT;
 	struct extent_buffer *eb;
 	struct extent_buffer *exists = NULL;
 	struct page *p;
@@ -4900,7 +4900,7 @@ struct extent_buffer *alloc_extent_buffer(struct btrfs_fs_info *fs_info,
 			if (atomic_inc_not_zero(&exists->refs)) {
 				spin_unlock(&mapping->private_lock);
 				unlock_page(p);
-				page_cache_release(p);
+				put_page(p);
 				mark_extent_buffer_accessed(exists, p);
 				goto free_eb;
 			}
@@ -4912,7 +4912,7 @@ struct extent_buffer *alloc_extent_buffer(struct btrfs_fs_info *fs_info,
 			 */
 			ClearPagePrivate(p);
 			WARN_ON(PageDirty(p));
-			page_cache_release(p);
+			put_page(p);
 		}
 		attach_extent_buffer_page(eb, p);
 		spin_unlock(&mapping->private_lock);
@@ -4935,7 +4935,7 @@ again:
 
 	spin_lock(&fs_info->buffer_lock);
 	ret = radix_tree_insert(&fs_info->buffer_radix,
-				start >> PAGE_CACHE_SHIFT, eb);
+				start >> PAGE_SHIFT, eb);
 	spin_unlock(&fs_info->buffer_lock);
 	radix_tree_preload_end();
 	if (ret == -EEXIST) {
@@ -4998,7 +4998,7 @@ static int release_extent_buffer(struct extent_buffer *eb)
 
 			spin_lock(&fs_info->buffer_lock);
 			radix_tree_delete(&fs_info->buffer_radix,
-					  eb->start >> PAGE_CACHE_SHIFT);
+					  eb->start >> PAGE_SHIFT);
 			spin_unlock(&fs_info->buffer_lock);
 		} else {
 			spin_unlock(&eb->refs_lock);
@@ -5172,8 +5172,8 @@ int read_extent_buffer_pages(struct extent_io_tree *tree,
 
 	if (start) {
 		WARN_ON(start < eb->start);
-		start_i = (start >> PAGE_CACHE_SHIFT) -
-			(eb->start >> PAGE_CACHE_SHIFT);
+		start_i = (start >> PAGE_SHIFT) -
+			(eb->start >> PAGE_SHIFT);
 	} else {
 		start_i = 0;
 	}
@@ -5256,18 +5256,18 @@ void read_extent_buffer(struct extent_buffer *eb, void *dstv,
 	struct page *page;
 	char *kaddr;
 	char *dst = (char *)dstv;
-	size_t start_offset = eb->start & ((u64)PAGE_CACHE_SIZE - 1);
-	unsigned long i = (start_offset + start) >> PAGE_CACHE_SHIFT;
+	size_t start_offset = eb->start & ((u64)PAGE_SIZE - 1);
+	unsigned long i = (start_offset + start) >> PAGE_SHIFT;
 
 	WARN_ON(start > eb->len);
 	WARN_ON(start + len > eb->start + eb->len);
 
-	offset = (start_offset + start) & (PAGE_CACHE_SIZE - 1);
+	offset = (start_offset + start) & (PAGE_SIZE - 1);
 
 	while (len > 0) {
 		page = eb->pages[i];
 
-		cur = min(len, (PAGE_CACHE_SIZE - offset));
+		cur = min(len, (PAGE_SIZE - offset));
 		kaddr = page_address(page);
 		memcpy(dst, kaddr + offset, cur);
 
@@ -5287,19 +5287,19 @@ int read_extent_buffer_to_user(struct extent_buffer *eb, void __user *dstv,
 	struct page *page;
 	char *kaddr;
 	char __user *dst = (char __user *)dstv;
-	size_t start_offset = eb->start & ((u64)PAGE_CACHE_SIZE - 1);
-	unsigned long i = (start_offset + start) >> PAGE_CACHE_SHIFT;
+	size_t start_offset = eb->start & ((u64)PAGE_SIZE - 1);
+	unsigned long i = (start_offset + start) >> PAGE_SHIFT;
 	int ret = 0;
 
 	WARN_ON(start > eb->len);
 	WARN_ON(start + len > eb->start + eb->len);
 
-	offset = (start_offset + start) & (PAGE_CACHE_SIZE - 1);
+	offset = (start_offset + start) & (PAGE_SIZE - 1);
 
 	while (len > 0) {
 		page = eb->pages[i];
 
-		cur = min(len, (PAGE_CACHE_SIZE - offset));
+		cur = min(len, (PAGE_SIZE - offset));
 		kaddr = page_address(page);
 		if (copy_to_user(dst, kaddr + offset, cur)) {
 			ret = -EFAULT;
@@ -5320,13 +5320,13 @@ int map_private_extent_buffer(struct extent_buffer *eb, unsigned long start,
 			       unsigned long *map_start,
 			       unsigned long *map_len)
 {
-	size_t offset = start & (PAGE_CACHE_SIZE - 1);
+	size_t offset = start & (PAGE_SIZE - 1);
 	char *kaddr;
 	struct page *p;
-	size_t start_offset = eb->start & ((u64)PAGE_CACHE_SIZE - 1);
-	unsigned long i = (start_offset + start) >> PAGE_CACHE_SHIFT;
+	size_t start_offset = eb->start & ((u64)PAGE_SIZE - 1);
+	unsigned long i = (start_offset + start) >> PAGE_SHIFT;
 	unsigned long end_i = (start_offset + start + min_len - 1) >>
-		PAGE_CACHE_SHIFT;
+		PAGE_SHIFT;
 
 	if (i != end_i)
 		return -EINVAL;
@@ -5336,7 +5336,7 @@ int map_private_extent_buffer(struct extent_buffer *eb, unsigned long start,
 		*map_start = 0;
 	} else {
 		offset = 0;
-		*map_start = ((u64)i << PAGE_CACHE_SHIFT) - start_offset;
+		*map_start = ((u64)i << PAGE_SHIFT) - start_offset;
 	}
 
 	if (start + min_len > eb->len) {
@@ -5349,7 +5349,7 @@ int map_private_extent_buffer(struct extent_buffer *eb, unsigned long start,
 	p = eb->pages[i];
 	kaddr = page_address(p);
 	*map = kaddr + offset;
-	*map_len = PAGE_CACHE_SIZE - offset;
+	*map_len = PAGE_SIZE - offset;
 	return 0;
 }
 
@@ -5362,19 +5362,19 @@ int memcmp_extent_buffer(struct extent_buffer *eb, const void *ptrv,
 	struct page *page;
 	char *kaddr;
 	char *ptr = (char *)ptrv;
-	size_t start_offset = eb->start & ((u64)PAGE_CACHE_SIZE - 1);
-	unsigned long i = (start_offset + start) >> PAGE_CACHE_SHIFT;
+	size_t start_offset = eb->start & ((u64)PAGE_SIZE - 1);
+	unsigned long i = (start_offset + start) >> PAGE_SHIFT;
 	int ret = 0;
 
 	WARN_ON(start > eb->len);
 	WARN_ON(start + len > eb->start + eb->len);
 
-	offset = (start_offset + start) & (PAGE_CACHE_SIZE - 1);
+	offset = (start_offset + start) & (PAGE_SIZE - 1);
 
 	while (len > 0) {
 		page = eb->pages[i];
 
-		cur = min(len, (PAGE_CACHE_SIZE - offset));
+		cur = min(len, (PAGE_SIZE - offset));
 
 		kaddr = page_address(page);
 		ret = memcmp(ptr, kaddr + offset, cur);
@@ -5397,19 +5397,19 @@ void write_extent_buffer(struct extent_buffer *eb, const void *srcv,
 	struct page *page;
 	char *kaddr;
 	char *src = (char *)srcv;
-	size_t start_offset = eb->start & ((u64)PAGE_CACHE_SIZE - 1);
-	unsigned long i = (start_offset + start) >> PAGE_CACHE_SHIFT;
+	size_t start_offset = eb->start & ((u64)PAGE_SIZE - 1);
+	unsigned long i = (start_offset + start) >> PAGE_SHIFT;
 
 	WARN_ON(start > eb->len);
 	WARN_ON(start + len > eb->start + eb->len);
 
-	offset = (start_offset + start) & (PAGE_CACHE_SIZE - 1);
+	offset = (start_offset + start) & (PAGE_SIZE - 1);
 
 	while (len > 0) {
 		page = eb->pages[i];
 		WARN_ON(!PageUptodate(page));
 
-		cur = min(len, PAGE_CACHE_SIZE - offset);
+		cur = min(len, PAGE_SIZE - offset);
 		kaddr = page_address(page);
 		memcpy(kaddr + offset, src, cur);
 
@@ -5427,19 +5427,19 @@ void memset_extent_buffer(struct extent_buffer *eb, char c,
 	size_t offset;
 	struct page *page;
 	char *kaddr;
-	size_t start_offset = eb->start & ((u64)PAGE_CACHE_SIZE - 1);
-	unsigned long i = (start_offset + start) >> PAGE_CACHE_SHIFT;
+	size_t start_offset = eb->start & ((u64)PAGE_SIZE - 1);
+	unsigned long i = (start_offset + start) >> PAGE_SHIFT;
 
 	WARN_ON(start > eb->len);
 	WARN_ON(start + len > eb->start + eb->len);
 
-	offset = (start_offset + start) & (PAGE_CACHE_SIZE - 1);
+	offset = (start_offset + start) & (PAGE_SIZE - 1);
 
 	while (len > 0) {
 		page = eb->pages[i];
 		WARN_ON(!PageUptodate(page));
 
-		cur = min(len, PAGE_CACHE_SIZE - offset);
+		cur = min(len, PAGE_SIZE - offset);
 		kaddr = page_address(page);
 		memset(kaddr + offset, c, cur);
 
@@ -5458,19 +5458,19 @@ void copy_extent_buffer(struct extent_buffer *dst, struct extent_buffer *src,
 	size_t offset;
 	struct page *page;
 	char *kaddr;
-	size_t start_offset = dst->start & ((u64)PAGE_CACHE_SIZE - 1);
-	unsigned long i = (start_offset + dst_offset) >> PAGE_CACHE_SHIFT;
+	size_t start_offset = dst->start & ((u64)PAGE_SIZE - 1);
+	unsigned long i = (start_offset + dst_offset) >> PAGE_SHIFT;
 
 	WARN_ON(src->len != dst_len);
 
 	offset = (start_offset + dst_offset) &
-		(PAGE_CACHE_SIZE - 1);
+		(PAGE_SIZE - 1);
 
 	while (len > 0) {
 		page = dst->pages[i];
 		WARN_ON(!PageUptodate(page));
 
-		cur = min(len, (unsigned long)(PAGE_CACHE_SIZE - offset));
+		cur = min(len, (unsigned long)(PAGE_SIZE - offset));
 
 		kaddr = page_address(page);
 		read_extent_buffer(src, kaddr + offset, src_offset, cur);
@@ -5512,7 +5512,7 @@ static inline void eb_bitmap_offset(struct extent_buffer *eb,
 				    unsigned long *page_index,
 				    size_t *page_offset)
 {
-	size_t start_offset = eb->start & ((u64)PAGE_CACHE_SIZE - 1);
+	size_t start_offset = eb->start & ((u64)PAGE_SIZE - 1);
 	size_t byte_offset = BIT_BYTE(nr);
 	size_t offset;
 
@@ -5523,8 +5523,8 @@ static inline void eb_bitmap_offset(struct extent_buffer *eb,
 	 */
 	offset = start_offset + start + byte_offset;
 
-	*page_index = offset >> PAGE_CACHE_SHIFT;
-	*page_offset = offset & (PAGE_CACHE_SIZE - 1);
+	*page_index = offset >> PAGE_SHIFT;
+	*page_offset = offset & (PAGE_SIZE - 1);
 }
 
 /**
@@ -5576,7 +5576,7 @@ void extent_buffer_bitmap_set(struct extent_buffer *eb, unsigned long start,
 		len -= bits_to_set;
 		bits_to_set = BITS_PER_BYTE;
 		mask_to_set = ~0U;
-		if (++offset >= PAGE_CACHE_SIZE && len > 0) {
+		if (++offset >= PAGE_SIZE && len > 0) {
 			offset = 0;
 			page = eb->pages[++i];
 			WARN_ON(!PageUptodate(page));
@@ -5618,7 +5618,7 @@ void extent_buffer_bitmap_clear(struct extent_buffer *eb, unsigned long start,
 		len -= bits_to_clear;
 		bits_to_clear = BITS_PER_BYTE;
 		mask_to_clear = ~0U;
-		if (++offset >= PAGE_CACHE_SIZE && len > 0) {
+		if (++offset >= PAGE_SIZE && len > 0) {
 			offset = 0;
 			page = eb->pages[++i];
 			WARN_ON(!PageUptodate(page));
@@ -5665,7 +5665,7 @@ void memcpy_extent_buffer(struct extent_buffer *dst, unsigned long dst_offset,
 	size_t cur;
 	size_t dst_off_in_page;
 	size_t src_off_in_page;
-	size_t start_offset = dst->start & ((u64)PAGE_CACHE_SIZE - 1);
+	size_t start_offset = dst->start & ((u64)PAGE_SIZE - 1);
 	unsigned long dst_i;
 	unsigned long src_i;
 
@@ -5684,17 +5684,17 @@ void memcpy_extent_buffer(struct extent_buffer *dst, unsigned long dst_offset,
 
 	while (len > 0) {
 		dst_off_in_page = (start_offset + dst_offset) &
-			(PAGE_CACHE_SIZE - 1);
+			(PAGE_SIZE - 1);
 		src_off_in_page = (start_offset + src_offset) &
-			(PAGE_CACHE_SIZE - 1);
+			(PAGE_SIZE - 1);
 
-		dst_i = (start_offset + dst_offset) >> PAGE_CACHE_SHIFT;
-		src_i = (start_offset + src_offset) >> PAGE_CACHE_SHIFT;
+		dst_i = (start_offset + dst_offset) >> PAGE_SHIFT;
+		src_i = (start_offset + src_offset) >> PAGE_SHIFT;
 
-		cur = min(len, (unsigned long)(PAGE_CACHE_SIZE -
+		cur = min(len, (unsigned long)(PAGE_SIZE -
 					       src_off_in_page));
 		cur = min_t(unsigned long, cur,
-			(unsigned long)(PAGE_CACHE_SIZE - dst_off_in_page));
+			(unsigned long)(PAGE_SIZE - dst_off_in_page));
 
 		copy_pages(dst->pages[dst_i], dst->pages[src_i],
 			   dst_off_in_page, src_off_in_page, cur);
@@ -5713,7 +5713,7 @@ void memmove_extent_buffer(struct extent_buffer *dst, unsigned long dst_offset,
 	size_t src_off_in_page;
 	unsigned long dst_end = dst_offset + len - 1;
 	unsigned long src_end = src_offset + len - 1;
-	size_t start_offset = dst->start & ((u64)PAGE_CACHE_SIZE - 1);
+	size_t start_offset = dst->start & ((u64)PAGE_SIZE - 1);
 	unsigned long dst_i;
 	unsigned long src_i;
 
@@ -5732,13 +5732,13 @@ void memmove_extent_buffer(struct extent_buffer *dst, unsigned long dst_offset,
 		return;
 	}
 	while (len > 0) {
-		dst_i = (start_offset + dst_end) >> PAGE_CACHE_SHIFT;
-		src_i = (start_offset + src_end) >> PAGE_CACHE_SHIFT;
+		dst_i = (start_offset + dst_end) >> PAGE_SHIFT;
+		src_i = (start_offset + src_end) >> PAGE_SHIFT;
 
 		dst_off_in_page = (start_offset + dst_end) &
-			(PAGE_CACHE_SIZE - 1);
+			(PAGE_SIZE - 1);
 		src_off_in_page = (start_offset + src_end) &
-			(PAGE_CACHE_SIZE - 1);
+			(PAGE_SIZE - 1);
 
 		cur = min_t(unsigned long, len, src_off_in_page + 1);
 		cur = min(cur, dst_off_in_page + 1);
diff --git a/fs/btrfs/extent_io.h b/fs/btrfs/extent_io.h
index 880d5292e972..9c5abfac3338 100644
--- a/fs/btrfs/extent_io.h
+++ b/fs/btrfs/extent_io.h
@@ -120,7 +120,7 @@ struct extent_state {
 };
 
 #define INLINE_EXTENT_BUFFER_PAGES 16
-#define MAX_INLINE_EXTENT_BUFFER_SIZE (INLINE_EXTENT_BUFFER_PAGES * PAGE_CACHE_SIZE)
+#define MAX_INLINE_EXTENT_BUFFER_SIZE (INLINE_EXTENT_BUFFER_PAGES * PAGE_SIZE)
 struct extent_buffer {
 	u64 start;
 	unsigned long len;
@@ -366,8 +366,8 @@ void wait_on_extent_buffer_writeback(struct extent_buffer *eb);
 
 static inline unsigned long num_extent_pages(u64 start, u64 len)
 {
-	return ((start + len + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT) -
-		(start >> PAGE_CACHE_SHIFT);
+	return ((start + len + PAGE_SIZE - 1) >> PAGE_SHIFT) -
+		(start >> PAGE_SHIFT);
 }
 
 static inline void extent_buffer_get(struct extent_buffer *eb)
diff --git a/fs/btrfs/file-item.c b/fs/btrfs/file-item.c
index a67e1c828d0f..9311b524b1c1 100644
--- a/fs/btrfs/file-item.c
+++ b/fs/btrfs/file-item.c
@@ -31,7 +31,7 @@
 				  size) - 1))
 
 #define MAX_CSUM_ITEMS(r, size) (min_t(u32, __MAX_CSUM_ITEMS(r, size), \
-				       PAGE_CACHE_SIZE))
+				       PAGE_SIZE))
 
 #define MAX_ORDERED_SUM_BYTES(r) ((PAGE_SIZE - \
 				   sizeof(struct btrfs_ordered_sum)) / \
@@ -201,7 +201,7 @@ static int __btrfs_lookup_bio_sums(struct btrfs_root *root,
 		csum = (u8 *)dst;
 	}
 
-	if (bio->bi_iter.bi_size > PAGE_CACHE_SIZE * 8)
+	if (bio->bi_iter.bi_size > PAGE_SIZE * 8)
 		path->reada = READA_FORWARD;
 
 	WARN_ON(bio->bi_vcnt <= 0);
diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index 098bb8f690c9..bbb4b4a618a6 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -413,11 +413,11 @@ static noinline int btrfs_copy_from_user(loff_t pos, size_t write_bytes,
 	size_t copied = 0;
 	size_t total_copied = 0;
 	int pg = 0;
-	int offset = pos & (PAGE_CACHE_SIZE - 1);
+	int offset = pos & (PAGE_SIZE - 1);
 
 	while (write_bytes > 0) {
 		size_t count = min_t(size_t,
-				     PAGE_CACHE_SIZE - offset, write_bytes);
+				     PAGE_SIZE - offset, write_bytes);
 		struct page *page = prepared_pages[pg];
 		/*
 		 * Copy data from userspace to the current page
@@ -447,7 +447,7 @@ static noinline int btrfs_copy_from_user(loff_t pos, size_t write_bytes,
 		if (unlikely(copied == 0))
 			break;
 
-		if (copied < PAGE_CACHE_SIZE - offset) {
+		if (copied < PAGE_SIZE - offset) {
 			offset += copied;
 		} else {
 			pg++;
@@ -472,7 +472,7 @@ static void btrfs_drop_pages(struct page **pages, size_t num_pages)
 		 */
 		ClearPageChecked(pages[i]);
 		unlock_page(pages[i]);
-		page_cache_release(pages[i]);
+		put_page(pages[i]);
 	}
 }
 
@@ -1296,7 +1296,7 @@ static int prepare_uptodate_page(struct inode *inode,
 {
 	int ret = 0;
 
-	if (((pos & (PAGE_CACHE_SIZE - 1)) || force_uptodate) &&
+	if (((pos & (PAGE_SIZE - 1)) || force_uptodate) &&
 	    !PageUptodate(page)) {
 		ret = btrfs_readpage(NULL, page);
 		if (ret)
@@ -1322,7 +1322,7 @@ static noinline int prepare_pages(struct inode *inode, struct page **pages,
 				  size_t write_bytes, bool force_uptodate)
 {
 	int i;
-	unsigned long index = pos >> PAGE_CACHE_SHIFT;
+	unsigned long index = pos >> PAGE_SHIFT;
 	gfp_t mask = btrfs_alloc_write_mask(inode->i_mapping);
 	int err = 0;
 	int faili;
@@ -1344,7 +1344,7 @@ again:
 			err = prepare_uptodate_page(inode, pages[i],
 						    pos + write_bytes, false);
 		if (err) {
-			page_cache_release(pages[i]);
+			put_page(pages[i]);
 			if (err == -EAGAIN) {
 				err = 0;
 				goto again;
@@ -1359,7 +1359,7 @@ again:
 fail:
 	while (faili >= 0) {
 		unlock_page(pages[faili]);
-		page_cache_release(pages[faili]);
+		put_page(pages[faili]);
 		faili--;
 	}
 	return err;
@@ -1387,8 +1387,8 @@ lock_and_cleanup_extent_if_need(struct inode *inode, struct page **pages,
 	int i;
 	int ret = 0;
 
-	start_pos = pos & ~((u64)PAGE_CACHE_SIZE - 1);
-	last_pos = start_pos + ((u64)num_pages << PAGE_CACHE_SHIFT) - 1;
+	start_pos = pos & ~((u64)PAGE_SIZE - 1);
+	last_pos = start_pos + ((u64)num_pages << PAGE_SHIFT) - 1;
 
 	if (start_pos < inode->i_size) {
 		struct btrfs_ordered_extent *ordered;
@@ -1404,7 +1404,7 @@ lock_and_cleanup_extent_if_need(struct inode *inode, struct page **pages,
 					     cached_state, GFP_NOFS);
 			for (i = 0; i < num_pages; i++) {
 				unlock_page(pages[i]);
-				page_cache_release(pages[i]);
+				put_page(pages[i]);
 			}
 			btrfs_start_ordered_extent(inode, ordered, 1);
 			btrfs_put_ordered_extent(ordered);
@@ -1493,8 +1493,8 @@ static noinline ssize_t __btrfs_buffered_write(struct file *file,
 	bool force_page_uptodate = false;
 	bool need_unlock;
 
-	nrptrs = min(DIV_ROUND_UP(iov_iter_count(i), PAGE_CACHE_SIZE),
-			PAGE_CACHE_SIZE / (sizeof(struct page *)));
+	nrptrs = min(DIV_ROUND_UP(iov_iter_count(i), PAGE_SIZE),
+			PAGE_SIZE / (sizeof(struct page *)));
 	nrptrs = min(nrptrs, current->nr_dirtied_pause - current->nr_dirtied);
 	nrptrs = max(nrptrs, 8);
 	pages = kmalloc_array(nrptrs, sizeof(struct page *), GFP_KERNEL);
@@ -1502,12 +1502,12 @@ static noinline ssize_t __btrfs_buffered_write(struct file *file,
 		return -ENOMEM;
 
 	while (iov_iter_count(i) > 0) {
-		size_t offset = pos & (PAGE_CACHE_SIZE - 1);
+		size_t offset = pos & (PAGE_SIZE - 1);
 		size_t write_bytes = min(iov_iter_count(i),
-					 nrptrs * (size_t)PAGE_CACHE_SIZE -
+					 nrptrs * (size_t)PAGE_SIZE -
 					 offset);
 		size_t num_pages = DIV_ROUND_UP(write_bytes + offset,
-						PAGE_CACHE_SIZE);
+						PAGE_SIZE);
 		size_t reserve_bytes;
 		size_t dirty_pages;
 		size_t copied;
@@ -1523,7 +1523,7 @@ static noinline ssize_t __btrfs_buffered_write(struct file *file,
 			break;
 		}
 
-		reserve_bytes = num_pages << PAGE_CACHE_SHIFT;
+		reserve_bytes = num_pages << PAGE_SHIFT;
 
 		if (BTRFS_I(inode)->flags & (BTRFS_INODE_NODATACOW |
 					     BTRFS_INODE_PREALLOC)) {
@@ -1541,8 +1541,8 @@ static noinline ssize_t __btrfs_buffered_write(struct file *file,
 				 * write_bytes, so scale down.
 				 */
 				num_pages = DIV_ROUND_UP(write_bytes + offset,
-							 PAGE_CACHE_SIZE);
-				reserve_bytes = num_pages << PAGE_CACHE_SHIFT;
+							 PAGE_SIZE);
+				reserve_bytes = num_pages << PAGE_SHIFT;
 				goto reserve_metadata;
 			}
 		}
@@ -1602,7 +1602,7 @@ again:
 		} else {
 			force_page_uptodate = false;
 			dirty_pages = DIV_ROUND_UP(copied + offset,
-						   PAGE_CACHE_SIZE);
+						   PAGE_SIZE);
 		}
 
 		/*
@@ -1614,7 +1614,7 @@ again:
 		 */
 		if (num_pages > dirty_pages) {
 			release_bytes = (num_pages - dirty_pages) <<
-				PAGE_CACHE_SHIFT;
+				PAGE_SHIFT;
 			if (copied > 0) {
 				spin_lock(&BTRFS_I(inode)->lock);
 				BTRFS_I(inode)->outstanding_extents++;
@@ -1627,13 +1627,13 @@ again:
 				u64 __pos;
 
 				__pos = round_down(pos, root->sectorsize) +
-					(dirty_pages << PAGE_CACHE_SHIFT);
+					(dirty_pages << PAGE_SHIFT);
 				btrfs_delalloc_release_space(inode, __pos,
 							     release_bytes);
 			}
 		}
 
-		release_bytes = dirty_pages << PAGE_CACHE_SHIFT;
+		release_bytes = dirty_pages << PAGE_SHIFT;
 
 		if (copied > 0)
 			ret = btrfs_dirty_pages(root, inode, pages,
@@ -1655,7 +1655,7 @@ again:
 		if (only_release_metadata && copied > 0) {
 			lockstart = round_down(pos, root->sectorsize);
 			lockend = lockstart +
-				(dirty_pages << PAGE_CACHE_SHIFT) - 1;
+				(dirty_pages << PAGE_SHIFT) - 1;
 
 			set_extent_bit(&BTRFS_I(inode)->io_tree, lockstart,
 				       lockend, EXTENT_NORESERVE, NULL,
@@ -1668,7 +1668,7 @@ again:
 		cond_resched();
 
 		balance_dirty_pages_ratelimited(inode->i_mapping);
-		if (dirty_pages < (root->nodesize >> PAGE_CACHE_SHIFT) + 1)
+		if (dirty_pages < (root->nodesize >> PAGE_SHIFT) + 1)
 			btrfs_btree_balance_dirty(root);
 
 		pos += copied;
@@ -1724,8 +1724,8 @@ static ssize_t __btrfs_direct_write(struct kiocb *iocb,
 		goto out;
 	written += written_buffered;
 	iocb->ki_pos = pos + written_buffered;
-	invalidate_mapping_pages(file->f_mapping, pos >> PAGE_CACHE_SHIFT,
-				 endbyte >> PAGE_CACHE_SHIFT);
+	invalidate_mapping_pages(file->f_mapping, pos >> PAGE_SHIFT,
+				 endbyte >> PAGE_SHIFT);
 out:
 	return written ? written : err;
 }
@@ -2304,7 +2304,7 @@ static int btrfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
 		return ret;
 
 	inode_lock(inode);
-	ino_size = round_up(inode->i_size, PAGE_CACHE_SIZE);
+	ino_size = round_up(inode->i_size, PAGE_SIZE);
 	ret = find_first_non_hole(inode, &offset, &len);
 	if (ret < 0)
 		goto out_only_mutex;
@@ -2317,8 +2317,8 @@ static int btrfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
 	lockstart = round_up(offset, BTRFS_I(inode)->root->sectorsize);
 	lockend = round_down(offset + len,
 			     BTRFS_I(inode)->root->sectorsize) - 1;
-	same_page = ((offset >> PAGE_CACHE_SHIFT) ==
-		    ((offset + len - 1) >> PAGE_CACHE_SHIFT));
+	same_page = ((offset >> PAGE_SHIFT) ==
+		     ((offset + len - 1) >> PAGE_SHIFT));
 
 	/*
 	 * We needn't truncate any page which is beyond the end of the file
@@ -2328,7 +2328,7 @@ static int btrfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
 	 * Only do this if we are in the same page and we aren't doing the
 	 * entire page.
 	 */
-	if (same_page && len < PAGE_CACHE_SIZE) {
+	if (same_page && len < PAGE_SIZE) {
 		if (offset < ino_size) {
 			truncated_page = true;
 			ret = btrfs_truncate_page(inode, offset, len, 0);
diff --git a/fs/btrfs/free-space-cache.c b/fs/btrfs/free-space-cache.c
index 8f835bfa1bdd..5e6062c26129 100644
--- a/fs/btrfs/free-space-cache.c
+++ b/fs/btrfs/free-space-cache.c
@@ -29,7 +29,7 @@
 #include "inode-map.h"
 #include "volumes.h"
 
-#define BITS_PER_BITMAP		(PAGE_CACHE_SIZE * 8)
+#define BITS_PER_BITMAP		(PAGE_SIZE * 8)
 #define MAX_CACHE_BYTES_PER_GIG	SZ_32K
 
 struct btrfs_trim_range {
@@ -295,7 +295,7 @@ static int readahead_cache(struct inode *inode)
 		return -ENOMEM;
 
 	file_ra_state_init(ra, inode->i_mapping);
-	last_index = (i_size_read(inode) - 1) >> PAGE_CACHE_SHIFT;
+	last_index = (i_size_read(inode) - 1) >> PAGE_SHIFT;
 
 	page_cache_sync_readahead(inode->i_mapping, ra, NULL, 0, last_index);
 
@@ -310,14 +310,14 @@ static int io_ctl_init(struct btrfs_io_ctl *io_ctl, struct inode *inode,
 	int num_pages;
 	int check_crcs = 0;
 
-	num_pages = DIV_ROUND_UP(i_size_read(inode), PAGE_CACHE_SIZE);
+	num_pages = DIV_ROUND_UP(i_size_read(inode), PAGE_SIZE);
 
 	if (btrfs_ino(inode) != BTRFS_FREE_INO_OBJECTID)
 		check_crcs = 1;
 
 	/* Make sure we can fit our crcs into the first page */
 	if (write && check_crcs &&
-	    (num_pages * sizeof(u32)) >= PAGE_CACHE_SIZE)
+	    (num_pages * sizeof(u32)) >= PAGE_SIZE)
 		return -ENOSPC;
 
 	memset(io_ctl, 0, sizeof(struct btrfs_io_ctl));
@@ -354,9 +354,9 @@ static void io_ctl_map_page(struct btrfs_io_ctl *io_ctl, int clear)
 	io_ctl->page = io_ctl->pages[io_ctl->index++];
 	io_ctl->cur = page_address(io_ctl->page);
 	io_ctl->orig = io_ctl->cur;
-	io_ctl->size = PAGE_CACHE_SIZE;
+	io_ctl->size = PAGE_SIZE;
 	if (clear)
-		memset(io_ctl->cur, 0, PAGE_CACHE_SIZE);
+		memset(io_ctl->cur, 0, PAGE_SIZE);
 }
 
 static void io_ctl_drop_pages(struct btrfs_io_ctl *io_ctl)
@@ -369,7 +369,7 @@ static void io_ctl_drop_pages(struct btrfs_io_ctl *io_ctl)
 		if (io_ctl->pages[i]) {
 			ClearPageChecked(io_ctl->pages[i]);
 			unlock_page(io_ctl->pages[i]);
-			page_cache_release(io_ctl->pages[i]);
+			put_page(io_ctl->pages[i]);
 		}
 	}
 }
@@ -475,7 +475,7 @@ static void io_ctl_set_crc(struct btrfs_io_ctl *io_ctl, int index)
 		offset = sizeof(u32) * io_ctl->num_pages;
 
 	crc = btrfs_csum_data(io_ctl->orig + offset, crc,
-			      PAGE_CACHE_SIZE - offset);
+			      PAGE_SIZE - offset);
 	btrfs_csum_final(crc, (char *)&crc);
 	io_ctl_unmap_page(io_ctl);
 	tmp = page_address(io_ctl->pages[0]);
@@ -503,7 +503,7 @@ static int io_ctl_check_crc(struct btrfs_io_ctl *io_ctl, int index)
 
 	io_ctl_map_page(io_ctl, 0);
 	crc = btrfs_csum_data(io_ctl->orig + offset, crc,
-			      PAGE_CACHE_SIZE - offset);
+			      PAGE_SIZE - offset);
 	btrfs_csum_final(crc, (char *)&crc);
 	if (val != crc) {
 		btrfs_err_rl(io_ctl->root->fs_info,
@@ -561,7 +561,7 @@ static int io_ctl_add_bitmap(struct btrfs_io_ctl *io_ctl, void *bitmap)
 		io_ctl_map_page(io_ctl, 0);
 	}
 
-	memcpy(io_ctl->cur, bitmap, PAGE_CACHE_SIZE);
+	memcpy(io_ctl->cur, bitmap, PAGE_SIZE);
 	io_ctl_set_crc(io_ctl, io_ctl->index - 1);
 	if (io_ctl->index < io_ctl->num_pages)
 		io_ctl_map_page(io_ctl, 0);
@@ -621,7 +621,7 @@ static int io_ctl_read_bitmap(struct btrfs_io_ctl *io_ctl,
 	if (ret)
 		return ret;
 
-	memcpy(entry->bitmap, io_ctl->cur, PAGE_CACHE_SIZE);
+	memcpy(entry->bitmap, io_ctl->cur, PAGE_SIZE);
 	io_ctl_unmap_page(io_ctl);
 
 	return 0;
@@ -775,7 +775,7 @@ static int __load_free_space_cache(struct btrfs_root *root, struct inode *inode,
 		} else {
 			ASSERT(num_bitmaps);
 			num_bitmaps--;
-			e->bitmap = kzalloc(PAGE_CACHE_SIZE, GFP_NOFS);
+			e->bitmap = kzalloc(PAGE_SIZE, GFP_NOFS);
 			if (!e->bitmap) {
 				kmem_cache_free(
 					btrfs_free_space_cachep, e);
@@ -1660,7 +1660,7 @@ static void recalculate_thresholds(struct btrfs_free_space_ctl *ctl)
 	 * sure we don't go over our overall goal of MAX_CACHE_BYTES_PER_GIG as
 	 * we add more bitmaps.
 	 */
-	bitmap_bytes = (ctl->total_bitmaps + 1) * PAGE_CACHE_SIZE;
+	bitmap_bytes = (ctl->total_bitmaps + 1) * PAGE_SIZE;
 
 	if (bitmap_bytes >= max_bytes) {
 		ctl->extents_thresh = 0;
@@ -2111,7 +2111,7 @@ new_bitmap:
 		}
 
 		/* allocate the bitmap */
-		info->bitmap = kzalloc(PAGE_CACHE_SIZE, GFP_NOFS);
+		info->bitmap = kzalloc(PAGE_SIZE, GFP_NOFS);
 		spin_lock(&ctl->tree_lock);
 		if (!info->bitmap) {
 			ret = -ENOMEM;
@@ -3580,7 +3580,7 @@ again:
 	}
 
 	if (!map) {
-		map = kzalloc(PAGE_CACHE_SIZE, GFP_NOFS);
+		map = kzalloc(PAGE_SIZE, GFP_NOFS);
 		if (!map) {
 			kmem_cache_free(btrfs_free_space_cachep, info);
 			return -ENOMEM;
diff --git a/fs/btrfs/inode-map.c b/fs/btrfs/inode-map.c
index e50316c4af15..72e34e25dd8e 100644
--- a/fs/btrfs/inode-map.c
+++ b/fs/btrfs/inode-map.c
@@ -283,7 +283,7 @@ void btrfs_unpin_free_ino(struct btrfs_root *root)
 }
 
 #define INIT_THRESHOLD	((SZ_32K / 2) / sizeof(struct btrfs_free_space))
-#define INODES_PER_BITMAP (PAGE_CACHE_SIZE * 8)
+#define INODES_PER_BITMAP (PAGE_SIZE * 8)
 
 /*
  * The goal is to keep the memory used by the free_ino tree won't
@@ -317,7 +317,7 @@ static void recalculate_thresholds(struct btrfs_free_space_ctl *ctl)
 	}
 
 	ctl->extents_thresh = (max_bitmaps - ctl->total_bitmaps) *
-				PAGE_CACHE_SIZE / sizeof(*info);
+				PAGE_SIZE / sizeof(*info);
 }
 
 /*
@@ -481,12 +481,12 @@ again:
 
 	spin_lock(&ctl->tree_lock);
 	prealloc = sizeof(struct btrfs_free_space) * ctl->free_extents;
-	prealloc = ALIGN(prealloc, PAGE_CACHE_SIZE);
-	prealloc += ctl->total_bitmaps * PAGE_CACHE_SIZE;
+	prealloc = ALIGN(prealloc, PAGE_SIZE);
+	prealloc += ctl->total_bitmaps * PAGE_SIZE;
 	spin_unlock(&ctl->tree_lock);
 
 	/* Just to make sure we have enough space */
-	prealloc += 8 * PAGE_CACHE_SIZE;
+	prealloc += 8 * PAGE_SIZE;
 
 	ret = btrfs_delalloc_reserve_space(inode, 0, prealloc);
 	if (ret)
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index d96f5cf38a2d..ad15bbfc5003 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -194,7 +194,7 @@ static int insert_inline_extent(struct btrfs_trans_handle *trans,
 		while (compressed_size > 0) {
 			cpage = compressed_pages[i];
 			cur_size = min_t(unsigned long, compressed_size,
-				       PAGE_CACHE_SIZE);
+				       PAGE_SIZE);
 
 			kaddr = kmap_atomic(cpage);
 			write_extent_buffer(leaf, kaddr, ptr, cur_size);
@@ -208,13 +208,13 @@ static int insert_inline_extent(struct btrfs_trans_handle *trans,
 						  compress_type);
 	} else {
 		page = find_get_page(inode->i_mapping,
-				     start >> PAGE_CACHE_SHIFT);
+				     start >> PAGE_SHIFT);
 		btrfs_set_file_extent_compression(leaf, ei, 0);
 		kaddr = kmap_atomic(page);
-		offset = start & (PAGE_CACHE_SIZE - 1);
+		offset = start & (PAGE_SIZE - 1);
 		write_extent_buffer(leaf, kaddr + offset, ptr, size);
 		kunmap_atomic(kaddr);
-		page_cache_release(page);
+		put_page(page);
 	}
 	btrfs_mark_buffer_dirty(leaf);
 	btrfs_release_path(path);
@@ -263,7 +263,7 @@ static noinline int cow_file_range_inline(struct btrfs_root *root,
 		data_len = compressed_size;
 
 	if (start > 0 ||
-	    actual_end > PAGE_CACHE_SIZE ||
+	    actual_end > PAGE_SIZE ||
 	    data_len > BTRFS_MAX_INLINE_DATA_SIZE(root) ||
 	    (!compressed_size &&
 	    (actual_end & (root->sectorsize - 1)) == 0) ||
@@ -322,7 +322,7 @@ out:
 	 * And at reserve time, it's always aligned to page size, so
 	 * just free one page here.
 	 */
-	btrfs_qgroup_free_data(inode, 0, PAGE_CACHE_SIZE);
+	btrfs_qgroup_free_data(inode, 0, PAGE_SIZE);
 	btrfs_free_path(path);
 	btrfs_end_transaction(trans, root);
 	return ret;
@@ -435,8 +435,8 @@ static noinline void compress_file_range(struct inode *inode,
 	actual_end = min_t(u64, isize, end + 1);
 again:
 	will_compress = 0;
-	nr_pages = (end >> PAGE_CACHE_SHIFT) - (start >> PAGE_CACHE_SHIFT) + 1;
-	nr_pages = min_t(unsigned long, nr_pages, SZ_128K / PAGE_CACHE_SIZE);
+	nr_pages = (end >> PAGE_SHIFT) - (start >> PAGE_SHIFT) + 1;
+	nr_pages = min_t(unsigned long, nr_pages, SZ_128K / PAGE_SIZE);
 
 	/*
 	 * we don't want to send crud past the end of i_size through
@@ -514,7 +514,7 @@ again:
 
 		if (!ret) {
 			unsigned long offset = total_compressed &
-				(PAGE_CACHE_SIZE - 1);
+				(PAGE_SIZE - 1);
 			struct page *page = pages[nr_pages_ret - 1];
 			char *kaddr;
 
@@ -524,7 +524,7 @@ again:
 			if (offset) {
 				kaddr = kmap_atomic(page);
 				memset(kaddr + offset, 0,
-				       PAGE_CACHE_SIZE - offset);
+				       PAGE_SIZE - offset);
 				kunmap_atomic(kaddr);
 			}
 			will_compress = 1;
@@ -580,7 +580,7 @@ cont:
 		 * one last check to make sure the compression is really a
 		 * win, compare the page count read with the blocks on disk
 		 */
-		total_in = ALIGN(total_in, PAGE_CACHE_SIZE);
+		total_in = ALIGN(total_in, PAGE_SIZE);
 		if (total_compressed >= total_in) {
 			will_compress = 0;
 		} else {
@@ -594,7 +594,7 @@ cont:
 		 */
 		for (i = 0; i < nr_pages_ret; i++) {
 			WARN_ON(pages[i]->mapping);
-			page_cache_release(pages[i]);
+			put_page(pages[i]);
 		}
 		kfree(pages);
 		pages = NULL;
@@ -650,7 +650,7 @@ cleanup_and_bail_uncompressed:
 free_pages_out:
 	for (i = 0; i < nr_pages_ret; i++) {
 		WARN_ON(pages[i]->mapping);
-		page_cache_release(pages[i]);
+		put_page(pages[i]);
 	}
 	kfree(pages);
 }
@@ -664,7 +664,7 @@ static void free_async_extent_pages(struct async_extent *async_extent)
 
 	for (i = 0; i < async_extent->nr_pages; i++) {
 		WARN_ON(async_extent->pages[i]->mapping);
-		page_cache_release(async_extent->pages[i]);
+		put_page(async_extent->pages[i]);
 	}
 	kfree(async_extent->pages);
 	async_extent->nr_pages = 0;
@@ -966,7 +966,7 @@ static noinline int cow_file_range(struct inode *inode,
 				     PAGE_END_WRITEBACK);
 
 			*nr_written = *nr_written +
-			     (end - start + PAGE_CACHE_SIZE) / PAGE_CACHE_SIZE;
+			     (end - start + PAGE_SIZE) / PAGE_SIZE;
 			*page_started = 1;
 			goto out;
 		} else if (ret < 0) {
@@ -1106,8 +1106,8 @@ static noinline void async_cow_submit(struct btrfs_work *work)
 	async_cow = container_of(work, struct async_cow, work);
 
 	root = async_cow->root;
-	nr_pages = (async_cow->end - async_cow->start + PAGE_CACHE_SIZE) >>
-		PAGE_CACHE_SHIFT;
+	nr_pages = (async_cow->end - async_cow->start + PAGE_SIZE) >>
+		PAGE_SHIFT;
 
 	/*
 	 * atomic_sub_return implies a barrier for waitqueue_active
@@ -1164,8 +1164,8 @@ static int cow_file_range_async(struct inode *inode, struct page *locked_page,
 				async_cow_start, async_cow_submit,
 				async_cow_free);
 
-		nr_pages = (cur_end - start + PAGE_CACHE_SIZE) >>
-			PAGE_CACHE_SHIFT;
+		nr_pages = (cur_end - start + PAGE_SIZE) >>
+			PAGE_SHIFT;
 		atomic_add(nr_pages, &root->fs_info->async_delalloc_pages);
 
 		btrfs_queue_work(root->fs_info->delalloc_workers,
@@ -1960,7 +1960,7 @@ static noinline int add_pending_csums(struct btrfs_trans_handle *trans,
 int btrfs_set_extent_delalloc(struct inode *inode, u64 start, u64 end,
 			      struct extent_state **cached_state)
 {
-	WARN_ON((end & (PAGE_CACHE_SIZE - 1)) == 0);
+	WARN_ON((end & (PAGE_SIZE - 1)) == 0);
 	return set_extent_delalloc(&BTRFS_I(inode)->io_tree, start, end,
 				   cached_state, GFP_NOFS);
 }
@@ -1993,7 +1993,7 @@ again:
 
 	inode = page->mapping->host;
 	page_start = page_offset(page);
-	page_end = page_offset(page) + PAGE_CACHE_SIZE - 1;
+	page_end = page_offset(page) + PAGE_SIZE - 1;
 
 	lock_extent_bits(&BTRFS_I(inode)->io_tree, page_start, page_end,
 			 &cached_state);
@@ -2013,7 +2013,7 @@ again:
 	}
 
 	ret = btrfs_delalloc_reserve_space(inode, page_start,
-					   PAGE_CACHE_SIZE);
+					   PAGE_SIZE);
 	if (ret) {
 		mapping_set_error(page->mapping, ret);
 		end_extent_writepage(page, ret, page_start, page_end);
@@ -2029,7 +2029,7 @@ out:
 			     &cached_state, GFP_NOFS);
 out_page:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	kfree(fixup);
 }
 
@@ -2062,7 +2062,7 @@ static int btrfs_writepage_start_hook(struct page *page, u64 start, u64 end)
 		return -EAGAIN;
 
 	SetPageChecked(page);
-	page_cache_get(page);
+	get_page(page);
 	btrfs_init_work(&fixup->work, btrfs_fixup_helper,
 			btrfs_writepage_fixup_worker, NULL, NULL);
 	fixup->page = page;
@@ -4236,7 +4236,7 @@ static int truncate_inline_extent(struct inode *inode,
 
 	if (btrfs_file_extent_compression(leaf, fi) != BTRFS_COMPRESS_NONE) {
 		loff_t offset = new_size;
-		loff_t page_end = ALIGN(offset, PAGE_CACHE_SIZE);
+		loff_t page_end = ALIGN(offset, PAGE_SIZE);
 
 		/*
 		 * Zero out the remaining of the last page of our inline extent,
@@ -4621,8 +4621,8 @@ int btrfs_truncate_page(struct inode *inode, loff_t from, loff_t len,
 	struct extent_state *cached_state = NULL;
 	char *kaddr;
 	u32 blocksize = root->sectorsize;
-	pgoff_t index = from >> PAGE_CACHE_SHIFT;
-	unsigned offset = from & (PAGE_CACHE_SIZE-1);
+	pgoff_t index = from >> PAGE_SHIFT;
+	unsigned offset = from & (PAGE_SIZE-1);
 	struct page *page;
 	gfp_t mask = btrfs_alloc_write_mask(mapping);
 	int ret = 0;
@@ -4633,7 +4633,7 @@ int btrfs_truncate_page(struct inode *inode, loff_t from, loff_t len,
 	    (!len || ((len & (blocksize - 1)) == 0)))
 		goto out;
 	ret = btrfs_delalloc_reserve_space(inode,
-			round_down(from, PAGE_CACHE_SIZE), PAGE_CACHE_SIZE);
+			round_down(from, PAGE_SIZE), PAGE_SIZE);
 	if (ret)
 		goto out;
 
@@ -4641,21 +4641,21 @@ again:
 	page = find_or_create_page(mapping, index, mask);
 	if (!page) {
 		btrfs_delalloc_release_space(inode,
-				round_down(from, PAGE_CACHE_SIZE),
-				PAGE_CACHE_SIZE);
+				round_down(from, PAGE_SIZE),
+				PAGE_SIZE);
 		ret = -ENOMEM;
 		goto out;
 	}
 
 	page_start = page_offset(page);
-	page_end = page_start + PAGE_CACHE_SIZE - 1;
+	page_end = page_start + PAGE_SIZE - 1;
 
 	if (!PageUptodate(page)) {
 		ret = btrfs_readpage(NULL, page);
 		lock_page(page);
 		if (page->mapping != mapping) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			goto again;
 		}
 		if (!PageUptodate(page)) {
@@ -4673,7 +4673,7 @@ again:
 		unlock_extent_cached(io_tree, page_start, page_end,
 				     &cached_state, GFP_NOFS);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		btrfs_start_ordered_extent(inode, ordered, 1);
 		btrfs_put_ordered_extent(ordered);
 		goto again;
@@ -4692,9 +4692,9 @@ again:
 		goto out_unlock;
 	}
 
-	if (offset != PAGE_CACHE_SIZE) {
+	if (offset != PAGE_SIZE) {
 		if (!len)
-			len = PAGE_CACHE_SIZE - offset;
+			len = PAGE_SIZE - offset;
 		kaddr = kmap(page);
 		if (front)
 			memset(kaddr, 0, offset);
@@ -4711,9 +4711,9 @@ again:
 out_unlock:
 	if (ret)
 		btrfs_delalloc_release_space(inode, page_start,
-					     PAGE_CACHE_SIZE);
+					     PAGE_SIZE);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 out:
 	return ret;
 }
@@ -6701,7 +6701,7 @@ static noinline int uncompress_inline(struct btrfs_path *path,
 
 	read_extent_buffer(leaf, tmp, ptr, inline_size);
 
-	max_size = min_t(unsigned long, PAGE_CACHE_SIZE, max_size);
+	max_size = min_t(unsigned long, PAGE_SIZE, max_size);
 	ret = btrfs_decompress(compress_type, tmp, page,
 			       extent_offset, inline_size, max_size);
 	kfree(tmp);
@@ -6863,8 +6863,8 @@ next:
 
 		size = btrfs_file_extent_inline_len(leaf, path->slots[0], item);
 		extent_offset = page_offset(page) + pg_offset - extent_start;
-		copy_size = min_t(u64, PAGE_CACHE_SIZE - pg_offset,
-				size - extent_offset);
+		copy_size = min_t(u64, PAGE_SIZE - pg_offset,
+				  size - extent_offset);
 		em->start = extent_start + extent_offset;
 		em->len = ALIGN(copy_size, root->sectorsize);
 		em->orig_block_len = em->len;
@@ -6883,9 +6883,9 @@ next:
 				map = kmap(page);
 				read_extent_buffer(leaf, map + pg_offset, ptr,
 						   copy_size);
-				if (pg_offset + copy_size < PAGE_CACHE_SIZE) {
+				if (pg_offset + copy_size < PAGE_SIZE) {
 					memset(map + pg_offset + copy_size, 0,
-					       PAGE_CACHE_SIZE - pg_offset -
+					       PAGE_SIZE - pg_offset -
 					       copy_size);
 				}
 				kunmap(page);
@@ -7320,12 +7320,12 @@ bool btrfs_page_exists_in_range(struct inode *inode, loff_t start, loff_t end)
 	int start_idx;
 	int end_idx;
 
-	start_idx = start >> PAGE_CACHE_SHIFT;
+	start_idx = start >> PAGE_SHIFT;
 
 	/*
 	 * end is the last byte in the last page.  end == start is legal
 	 */
-	end_idx = end >> PAGE_CACHE_SHIFT;
+	end_idx = end >> PAGE_SHIFT;
 
 	rcu_read_lock();
 
@@ -7366,7 +7366,7 @@ bool btrfs_page_exists_in_range(struct inode *inode, loff_t start, loff_t end)
 		 * include/linux/pagemap.h for details.
 		 */
 		if (unlikely(page != *pagep)) {
-			page_cache_release(page);
+			put_page(page);
 			page = NULL;
 		}
 	}
@@ -7374,7 +7374,7 @@ bool btrfs_page_exists_in_range(struct inode *inode, loff_t start, loff_t end)
 	if (page) {
 		if (page->index <= end_idx)
 			found = true;
-		page_cache_release(page);
+		put_page(page);
 	}
 
 	rcu_read_unlock();
@@ -8621,7 +8621,7 @@ static int __btrfs_releasepage(struct page *page, gfp_t gfp_flags)
 	if (ret == 1) {
 		ClearPagePrivate(page);
 		set_page_private(page, 0);
-		page_cache_release(page);
+		put_page(page);
 	}
 	return ret;
 }
@@ -8641,7 +8641,7 @@ static void btrfs_invalidatepage(struct page *page, unsigned int offset,
 	struct btrfs_ordered_extent *ordered;
 	struct extent_state *cached_state = NULL;
 	u64 page_start = page_offset(page);
-	u64 page_end = page_start + PAGE_CACHE_SIZE - 1;
+	u64 page_end = page_start + PAGE_SIZE - 1;
 	int inode_evicting = inode->i_state & I_FREEING;
 
 	/*
@@ -8692,7 +8692,7 @@ static void btrfs_invalidatepage(struct page *page, unsigned int offset,
 
 			if (btrfs_dec_test_ordered_pending(inode, &ordered,
 							   page_start,
-							   PAGE_CACHE_SIZE, 1))
+							   PAGE_SIZE, 1))
 				btrfs_finish_ordered_io(ordered);
 		}
 		btrfs_put_ordered_extent(ordered);
@@ -8714,7 +8714,7 @@ static void btrfs_invalidatepage(struct page *page, unsigned int offset,
 	 * 2) Not written to disk
 	 *    This means the reserved space should be freed here.
 	 */
-	btrfs_qgroup_free_data(inode, page_start, PAGE_CACHE_SIZE);
+	btrfs_qgroup_free_data(inode, page_start, PAGE_SIZE);
 	if (!inode_evicting) {
 		clear_extent_bit(tree, page_start, page_end,
 				 EXTENT_LOCKED | EXTENT_DIRTY |
@@ -8729,7 +8729,7 @@ static void btrfs_invalidatepage(struct page *page, unsigned int offset,
 	if (PagePrivate(page)) {
 		ClearPagePrivate(page);
 		set_page_private(page, 0);
-		page_cache_release(page);
+		put_page(page);
 	}
 }
 
@@ -8766,10 +8766,10 @@ int btrfs_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 	sb_start_pagefault(inode->i_sb);
 	page_start = page_offset(page);
-	page_end = page_start + PAGE_CACHE_SIZE - 1;
+	page_end = page_start + PAGE_SIZE - 1;
 
 	ret = btrfs_delalloc_reserve_space(inode, page_start,
-					   PAGE_CACHE_SIZE);
+					   PAGE_SIZE);
 	if (!ret) {
 		ret = file_update_time(vma->vm_file);
 		reserved = 1;
@@ -8836,14 +8836,14 @@ again:
 	ret = 0;
 
 	/* page is wholly or partially inside EOF */
-	if (page_start + PAGE_CACHE_SIZE > size)
-		zero_start = size & ~PAGE_CACHE_MASK;
+	if (page_start + PAGE_SIZE > size)
+		zero_start = size & ~PAGE_MASK;
 	else
-		zero_start = PAGE_CACHE_SIZE;
+		zero_start = PAGE_SIZE;
 
-	if (zero_start != PAGE_CACHE_SIZE) {
+	if (zero_start != PAGE_SIZE) {
 		kaddr = kmap(page);
-		memset(kaddr + zero_start, 0, PAGE_CACHE_SIZE - zero_start);
+		memset(kaddr + zero_start, 0, PAGE_SIZE - zero_start);
 		flush_dcache_page(page);
 		kunmap(page);
 	}
@@ -8864,7 +8864,7 @@ out_unlock:
 	}
 	unlock_page(page);
 out:
-	btrfs_delalloc_release_space(inode, page_start, PAGE_CACHE_SIZE);
+	btrfs_delalloc_release_space(inode, page_start, PAGE_SIZE);
 out_noreserve:
 	sb_end_pagefault(inode->i_sb);
 	return ret;
@@ -9250,7 +9250,7 @@ static int btrfs_getattr(struct vfsmount *mnt,
 
 	generic_fillattr(inode, stat);
 	stat->dev = BTRFS_I(inode)->root->anon_dev;
-	stat->blksize = PAGE_CACHE_SIZE;
+	stat->blksize = PAGE_SIZE;
 
 	spin_lock(&BTRFS_I(inode)->lock);
 	delalloc_bytes = BTRFS_I(inode)->delalloc_bytes;
diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index 48aee9846329..095a135ef6a2 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -900,7 +900,7 @@ static int check_defrag_in_cache(struct inode *inode, u64 offset, u32 thresh)
 	u64 end;
 
 	read_lock(&em_tree->lock);
-	em = lookup_extent_mapping(em_tree, offset, PAGE_CACHE_SIZE);
+	em = lookup_extent_mapping(em_tree, offset, PAGE_SIZE);
 	read_unlock(&em_tree->lock);
 
 	if (em) {
@@ -990,7 +990,7 @@ static struct extent_map *defrag_lookup_extent(struct inode *inode, u64 start)
 	struct extent_map_tree *em_tree = &BTRFS_I(inode)->extent_tree;
 	struct extent_io_tree *io_tree = &BTRFS_I(inode)->io_tree;
 	struct extent_map *em;
-	u64 len = PAGE_CACHE_SIZE;
+	u64 len = PAGE_SIZE;
 
 	/*
 	 * hopefully we have this extent in the tree already, try without
@@ -1126,15 +1126,15 @@ static int cluster_pages_for_defrag(struct inode *inode,
 	struct extent_io_tree *tree;
 	gfp_t mask = btrfs_alloc_write_mask(inode->i_mapping);
 
-	file_end = (isize - 1) >> PAGE_CACHE_SHIFT;
+	file_end = (isize - 1) >> PAGE_SHIFT;
 	if (!isize || start_index > file_end)
 		return 0;
 
 	page_cnt = min_t(u64, (u64)num_pages, (u64)file_end - start_index + 1);
 
 	ret = btrfs_delalloc_reserve_space(inode,
-			start_index << PAGE_CACHE_SHIFT,
-			page_cnt << PAGE_CACHE_SHIFT);
+			start_index << PAGE_SHIFT,
+			page_cnt << PAGE_SHIFT);
 	if (ret)
 		return ret;
 	i_done = 0;
@@ -1150,7 +1150,7 @@ again:
 			break;
 
 		page_start = page_offset(page);
-		page_end = page_start + PAGE_CACHE_SIZE - 1;
+		page_end = page_start + PAGE_SIZE - 1;
 		while (1) {
 			lock_extent_bits(tree, page_start, page_end,
 					 &cached_state);
@@ -1171,7 +1171,7 @@ again:
 			 */
 			if (page->mapping != inode->i_mapping) {
 				unlock_page(page);
-				page_cache_release(page);
+				put_page(page);
 				goto again;
 			}
 		}
@@ -1181,7 +1181,7 @@ again:
 			lock_page(page);
 			if (!PageUptodate(page)) {
 				unlock_page(page);
-				page_cache_release(page);
+				put_page(page);
 				ret = -EIO;
 				break;
 			}
@@ -1189,7 +1189,7 @@ again:
 
 		if (page->mapping != inode->i_mapping) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			goto again;
 		}
 
@@ -1210,7 +1210,7 @@ again:
 		wait_on_page_writeback(pages[i]);
 
 	page_start = page_offset(pages[0]);
-	page_end = page_offset(pages[i_done - 1]) + PAGE_CACHE_SIZE;
+	page_end = page_offset(pages[i_done - 1]) + PAGE_SIZE;
 
 	lock_extent_bits(&BTRFS_I(inode)->io_tree,
 			 page_start, page_end - 1, &cached_state);
@@ -1224,8 +1224,8 @@ again:
 		BTRFS_I(inode)->outstanding_extents++;
 		spin_unlock(&BTRFS_I(inode)->lock);
 		btrfs_delalloc_release_space(inode,
-				start_index << PAGE_CACHE_SHIFT,
-				(page_cnt - i_done) << PAGE_CACHE_SHIFT);
+				start_index << PAGE_SHIFT,
+				(page_cnt - i_done) << PAGE_SHIFT);
 	}
 
 
@@ -1242,17 +1242,17 @@ again:
 		set_page_extent_mapped(pages[i]);
 		set_page_dirty(pages[i]);
 		unlock_page(pages[i]);
-		page_cache_release(pages[i]);
+		put_page(pages[i]);
 	}
 	return i_done;
 out:
 	for (i = 0; i < i_done; i++) {
 		unlock_page(pages[i]);
-		page_cache_release(pages[i]);
+		put_page(pages[i]);
 	}
 	btrfs_delalloc_release_space(inode,
-			start_index << PAGE_CACHE_SHIFT,
-			page_cnt << PAGE_CACHE_SHIFT);
+			start_index << PAGE_SHIFT,
+			page_cnt << PAGE_SHIFT);
 	return ret;
 
 }
@@ -1275,7 +1275,7 @@ int btrfs_defrag_file(struct inode *inode, struct file *file,
 	int defrag_count = 0;
 	int compress_type = BTRFS_COMPRESS_ZLIB;
 	u32 extent_thresh = range->extent_thresh;
-	unsigned long max_cluster = SZ_256K >> PAGE_CACHE_SHIFT;
+	unsigned long max_cluster = SZ_256K >> PAGE_SHIFT;
 	unsigned long cluster = max_cluster;
 	u64 new_align = ~((u64)SZ_128K - 1);
 	struct page **pages = NULL;
@@ -1319,9 +1319,9 @@ int btrfs_defrag_file(struct inode *inode, struct file *file,
 	/* find the last page to defrag */
 	if (range->start + range->len > range->start) {
 		last_index = min_t(u64, isize - 1,
-			 range->start + range->len - 1) >> PAGE_CACHE_SHIFT;
+			 range->start + range->len - 1) >> PAGE_SHIFT;
 	} else {
-		last_index = (isize - 1) >> PAGE_CACHE_SHIFT;
+		last_index = (isize - 1) >> PAGE_SHIFT;
 	}
 
 	if (newer_than) {
@@ -1333,11 +1333,11 @@ int btrfs_defrag_file(struct inode *inode, struct file *file,
 			 * we always align our defrag to help keep
 			 * the extents in the file evenly spaced
 			 */
-			i = (newer_off & new_align) >> PAGE_CACHE_SHIFT;
+			i = (newer_off & new_align) >> PAGE_SHIFT;
 		} else
 			goto out_ra;
 	} else {
-		i = range->start >> PAGE_CACHE_SHIFT;
+		i = range->start >> PAGE_SHIFT;
 	}
 	if (!max_to_defrag)
 		max_to_defrag = last_index - i + 1;
@@ -1350,7 +1350,7 @@ int btrfs_defrag_file(struct inode *inode, struct file *file,
 		inode->i_mapping->writeback_index = i;
 
 	while (i <= last_index && defrag_count < max_to_defrag &&
-	       (i < DIV_ROUND_UP(i_size_read(inode), PAGE_CACHE_SIZE))) {
+	       (i < DIV_ROUND_UP(i_size_read(inode), PAGE_SIZE))) {
 		/*
 		 * make sure we stop running if someone unmounts
 		 * the FS
@@ -1364,7 +1364,7 @@ int btrfs_defrag_file(struct inode *inode, struct file *file,
 			break;
 		}
 
-		if (!should_defrag_range(inode, (u64)i << PAGE_CACHE_SHIFT,
+		if (!should_defrag_range(inode, (u64)i << PAGE_SHIFT,
 					 extent_thresh, &last_len, &skip,
 					 &defrag_end, range->flags &
 					 BTRFS_DEFRAG_RANGE_COMPRESS)) {
@@ -1373,14 +1373,14 @@ int btrfs_defrag_file(struct inode *inode, struct file *file,
 			 * the should_defrag function tells us how much to skip
 			 * bump our counter by the suggested amount
 			 */
-			next = DIV_ROUND_UP(skip, PAGE_CACHE_SIZE);
+			next = DIV_ROUND_UP(skip, PAGE_SIZE);
 			i = max(i + 1, next);
 			continue;
 		}
 
 		if (!newer_than) {
-			cluster = (PAGE_CACHE_ALIGN(defrag_end) >>
-				   PAGE_CACHE_SHIFT) - i;
+			cluster = (PAGE_ALIGN(defrag_end) >>
+				   PAGE_SHIFT) - i;
 			cluster = min(cluster, max_cluster);
 		} else {
 			cluster = max_cluster;
@@ -1414,20 +1414,20 @@ int btrfs_defrag_file(struct inode *inode, struct file *file,
 				i += ret;
 
 			newer_off = max(newer_off + 1,
-					(u64)i << PAGE_CACHE_SHIFT);
+					(u64)i << PAGE_SHIFT);
 
 			ret = find_new_extents(root, inode, newer_than,
 					       &newer_off, SZ_64K);
 			if (!ret) {
 				range->start = newer_off;
-				i = (newer_off & new_align) >> PAGE_CACHE_SHIFT;
+				i = (newer_off & new_align) >> PAGE_SHIFT;
 			} else {
 				break;
 			}
 		} else {
 			if (ret > 0) {
 				i += ret;
-				last_len += ret << PAGE_CACHE_SHIFT;
+				last_len += ret << PAGE_SHIFT;
 			} else {
 				i++;
 				last_len = 0;
@@ -1724,7 +1724,7 @@ static noinline int btrfs_ioctl_snap_create_v2(struct file *file,
 	if (vol_args->flags & BTRFS_SUBVOL_RDONLY)
 		readonly = true;
 	if (vol_args->flags & BTRFS_SUBVOL_QGROUP_INHERIT) {
-		if (vol_args->size > PAGE_CACHE_SIZE) {
+		if (vol_args->size > PAGE_SIZE) {
 			ret = -EINVAL;
 			goto free_args;
 		}
@@ -2808,12 +2808,12 @@ static struct page *extent_same_get_page(struct inode *inode, pgoff_t index)
 		lock_page(page);
 		if (!PageUptodate(page)) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			return ERR_PTR(-EIO);
 		}
 		if (page->mapping != inode->i_mapping) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			return ERR_PTR(-EAGAIN);
 		}
 	}
@@ -2825,7 +2825,7 @@ static int gather_extent_pages(struct inode *inode, struct page **pages,
 			       int num_pages, u64 off)
 {
 	int i;
-	pgoff_t index = off >> PAGE_CACHE_SHIFT;
+	pgoff_t index = off >> PAGE_SHIFT;
 
 	for (i = 0; i < num_pages; i++) {
 again:
@@ -2934,12 +2934,12 @@ static void btrfs_cmp_data_free(struct cmp_pages *cmp)
 		pg = cmp->src_pages[i];
 		if (pg) {
 			unlock_page(pg);
-			page_cache_release(pg);
+			put_page(pg);
 		}
 		pg = cmp->dst_pages[i];
 		if (pg) {
 			unlock_page(pg);
-			page_cache_release(pg);
+			put_page(pg);
 		}
 	}
 	kfree(cmp->src_pages);
@@ -2951,7 +2951,7 @@ static int btrfs_cmp_data_prepare(struct inode *src, u64 loff,
 				  u64 len, struct cmp_pages *cmp)
 {
 	int ret;
-	int num_pages = PAGE_CACHE_ALIGN(len) >> PAGE_CACHE_SHIFT;
+	int num_pages = PAGE_ALIGN(len) >> PAGE_SHIFT;
 	struct page **src_pgarr, **dst_pgarr;
 
 	/*
@@ -2989,12 +2989,12 @@ static int btrfs_cmp_data(struct inode *src, u64 loff, struct inode *dst,
 	int ret = 0;
 	int i;
 	struct page *src_page, *dst_page;
-	unsigned int cmp_len = PAGE_CACHE_SIZE;
+	unsigned int cmp_len = PAGE_SIZE;
 	void *addr, *dst_addr;
 
 	i = 0;
 	while (len) {
-		if (len < PAGE_CACHE_SIZE)
+		if (len < PAGE_SIZE)
 			cmp_len = len;
 
 		BUG_ON(i >= cmp->num_pages);
@@ -3190,7 +3190,7 @@ ssize_t btrfs_dedupe_file_range(struct file *src_file, u64 loff, u64 olen,
 	if (olen > BTRFS_MAX_DEDUPE_LEN)
 		olen = BTRFS_MAX_DEDUPE_LEN;
 
-	if (WARN_ON_ONCE(bs < PAGE_CACHE_SIZE)) {
+	if (WARN_ON_ONCE(bs < PAGE_SIZE)) {
 		/*
 		 * Btrfs does not support blocksize < page_size. As a
 		 * result, btrfs_cmp_data() won't correctly handle
@@ -3890,7 +3890,7 @@ static noinline int btrfs_clone_files(struct file *file, struct file *file_src,
 	 * data immediately and not the previous data.
 	 */
 	truncate_inode_pages_range(&inode->i_data, destoff,
-				   PAGE_CACHE_ALIGN(destoff + len) - 1);
+				   PAGE_ALIGN(destoff + len) - 1);
 out_unlock:
 	if (!same_inode)
 		btrfs_double_inode_unlock(src, inode);
@@ -4122,7 +4122,7 @@ static long btrfs_ioctl_space_info(struct btrfs_root *root, void __user *arg)
 	/* we generally have at most 6 or so space infos, one for each raid
 	 * level.  So, a whole page should be more than enough for everyone
 	 */
-	if (alloc_size > PAGE_CACHE_SIZE)
+	if (alloc_size > PAGE_SIZE)
 		return -ENOMEM;
 
 	space_args.total_spaces = 0;
diff --git a/fs/btrfs/lzo.c b/fs/btrfs/lzo.c
index a2f051347731..1adfbe7be6b8 100644
--- a/fs/btrfs/lzo.c
+++ b/fs/btrfs/lzo.c
@@ -55,8 +55,8 @@ static struct list_head *lzo_alloc_workspace(void)
 		return ERR_PTR(-ENOMEM);
 
 	workspace->mem = vmalloc(LZO1X_MEM_COMPRESS);
-	workspace->buf = vmalloc(lzo1x_worst_compress(PAGE_CACHE_SIZE));
-	workspace->cbuf = vmalloc(lzo1x_worst_compress(PAGE_CACHE_SIZE));
+	workspace->buf = vmalloc(lzo1x_worst_compress(PAGE_SIZE));
+	workspace->cbuf = vmalloc(lzo1x_worst_compress(PAGE_SIZE));
 	if (!workspace->mem || !workspace->buf || !workspace->cbuf)
 		goto fail;
 
@@ -116,7 +116,7 @@ static int lzo_compress_pages(struct list_head *ws,
 	*total_out = 0;
 	*total_in = 0;
 
-	in_page = find_get_page(mapping, start >> PAGE_CACHE_SHIFT);
+	in_page = find_get_page(mapping, start >> PAGE_SHIFT);
 	data_in = kmap(in_page);
 
 	/*
@@ -133,10 +133,10 @@ static int lzo_compress_pages(struct list_head *ws,
 	tot_out = LZO_LEN;
 	pages[0] = out_page;
 	nr_pages = 1;
-	pg_bytes_left = PAGE_CACHE_SIZE - LZO_LEN;
+	pg_bytes_left = PAGE_SIZE - LZO_LEN;
 
 	/* compress at most one page of data each time */
-	in_len = min(len, PAGE_CACHE_SIZE);
+	in_len = min(len, PAGE_SIZE);
 	while (tot_in < len) {
 		ret = lzo1x_1_compress(data_in, in_len, workspace->cbuf,
 				       &out_len, workspace->mem);
@@ -201,7 +201,7 @@ static int lzo_compress_pages(struct list_head *ws,
 				cpage_out = kmap(out_page);
 				pages[nr_pages++] = out_page;
 
-				pg_bytes_left = PAGE_CACHE_SIZE;
+				pg_bytes_left = PAGE_SIZE;
 				out_offset = 0;
 			}
 		}
@@ -221,12 +221,12 @@ static int lzo_compress_pages(struct list_head *ws,
 
 		bytes_left = len - tot_in;
 		kunmap(in_page);
-		page_cache_release(in_page);
+		put_page(in_page);
 
-		start += PAGE_CACHE_SIZE;
-		in_page = find_get_page(mapping, start >> PAGE_CACHE_SHIFT);
+		start += PAGE_SIZE;
+		in_page = find_get_page(mapping, start >> PAGE_SHIFT);
 		data_in = kmap(in_page);
-		in_len = min(bytes_left, PAGE_CACHE_SIZE);
+		in_len = min(bytes_left, PAGE_SIZE);
 	}
 
 	if (tot_out > tot_in)
@@ -248,7 +248,7 @@ out:
 
 	if (in_page) {
 		kunmap(in_page);
-		page_cache_release(in_page);
+		put_page(in_page);
 	}
 
 	return ret;
@@ -266,7 +266,7 @@ static int lzo_decompress_biovec(struct list_head *ws,
 	char *data_in;
 	unsigned long page_in_index = 0;
 	unsigned long page_out_index = 0;
-	unsigned long total_pages_in = DIV_ROUND_UP(srclen, PAGE_CACHE_SIZE);
+	unsigned long total_pages_in = DIV_ROUND_UP(srclen, PAGE_SIZE);
 	unsigned long buf_start;
 	unsigned long buf_offset = 0;
 	unsigned long bytes;
@@ -289,7 +289,7 @@ static int lzo_decompress_biovec(struct list_head *ws,
 	tot_in = LZO_LEN;
 	in_offset = LZO_LEN;
 	tot_len = min_t(size_t, srclen, tot_len);
-	in_page_bytes_left = PAGE_CACHE_SIZE - LZO_LEN;
+	in_page_bytes_left = PAGE_SIZE - LZO_LEN;
 
 	tot_out = 0;
 	pg_offset = 0;
@@ -345,12 +345,12 @@ cont:
 
 				data_in = kmap(pages_in[++page_in_index]);
 
-				in_page_bytes_left = PAGE_CACHE_SIZE;
+				in_page_bytes_left = PAGE_SIZE;
 				in_offset = 0;
 			}
 		}
 
-		out_len = lzo1x_worst_compress(PAGE_CACHE_SIZE);
+		out_len = lzo1x_worst_compress(PAGE_SIZE);
 		ret = lzo1x_decompress_safe(buf, in_len, workspace->buf,
 					    &out_len);
 		if (need_unmap)
@@ -399,7 +399,7 @@ static int lzo_decompress(struct list_head *ws, unsigned char *data_in,
 	in_len = read_compress_length(data_in);
 	data_in += LZO_LEN;
 
-	out_len = PAGE_CACHE_SIZE;
+	out_len = PAGE_SIZE;
 	ret = lzo1x_decompress_safe(data_in, in_len, workspace->buf, &out_len);
 	if (ret != LZO_E_OK) {
 		printk(KERN_WARNING "BTRFS: decompress failed!\n");
diff --git a/fs/btrfs/raid56.c b/fs/btrfs/raid56.c
index 55161369fab1..0b7792e02dd5 100644
--- a/fs/btrfs/raid56.c
+++ b/fs/btrfs/raid56.c
@@ -270,7 +270,7 @@ static void cache_rbio_pages(struct btrfs_raid_bio *rbio)
 		s = kmap(rbio->bio_pages[i]);
 		d = kmap(rbio->stripe_pages[i]);
 
-		memcpy(d, s, PAGE_CACHE_SIZE);
+		memcpy(d, s, PAGE_SIZE);
 
 		kunmap(rbio->bio_pages[i]);
 		kunmap(rbio->stripe_pages[i]);
@@ -962,7 +962,7 @@ static struct page *page_in_rbio(struct btrfs_raid_bio *rbio,
  */
 static unsigned long rbio_nr_pages(unsigned long stripe_len, int nr_stripes)
 {
-	return DIV_ROUND_UP(stripe_len, PAGE_CACHE_SIZE) * nr_stripes;
+	return DIV_ROUND_UP(stripe_len, PAGE_SIZE) * nr_stripes;
 }
 
 /*
@@ -1078,7 +1078,7 @@ static int rbio_add_io_page(struct btrfs_raid_bio *rbio,
 	u64 disk_start;
 
 	stripe = &rbio->bbio->stripes[stripe_nr];
-	disk_start = stripe->physical + (page_index << PAGE_CACHE_SHIFT);
+	disk_start = stripe->physical + (page_index << PAGE_SHIFT);
 
 	/* if the device is missing, just fail this stripe */
 	if (!stripe->dev->bdev)
@@ -1096,8 +1096,8 @@ static int rbio_add_io_page(struct btrfs_raid_bio *rbio,
 		if (last_end == disk_start && stripe->dev->bdev &&
 		    !last->bi_error &&
 		    last->bi_bdev == stripe->dev->bdev) {
-			ret = bio_add_page(last, page, PAGE_CACHE_SIZE, 0);
-			if (ret == PAGE_CACHE_SIZE)
+			ret = bio_add_page(last, page, PAGE_SIZE, 0);
+			if (ret == PAGE_SIZE)
 				return 0;
 		}
 	}
@@ -1111,7 +1111,7 @@ static int rbio_add_io_page(struct btrfs_raid_bio *rbio,
 	bio->bi_bdev = stripe->dev->bdev;
 	bio->bi_iter.bi_sector = disk_start >> 9;
 
-	bio_add_page(bio, page, PAGE_CACHE_SIZE, 0);
+	bio_add_page(bio, page, PAGE_SIZE, 0);
 	bio_list_add(bio_list, bio);
 	return 0;
 }
@@ -1154,7 +1154,7 @@ static void index_rbio_pages(struct btrfs_raid_bio *rbio)
 	bio_list_for_each(bio, &rbio->bio_list) {
 		start = (u64)bio->bi_iter.bi_sector << 9;
 		stripe_offset = start - rbio->bbio->raid_map[0];
-		page_index = stripe_offset >> PAGE_CACHE_SHIFT;
+		page_index = stripe_offset >> PAGE_SHIFT;
 
 		for (i = 0; i < bio->bi_vcnt; i++) {
 			p = bio->bi_io_vec[i].bv_page;
@@ -1253,7 +1253,7 @@ static noinline void finish_rmw(struct btrfs_raid_bio *rbio)
 		} else {
 			/* raid5 */
 			memcpy(pointers[nr_data], pointers[0], PAGE_SIZE);
-			run_xor(pointers + 1, nr_data - 1, PAGE_CACHE_SIZE);
+			run_xor(pointers + 1, nr_data - 1, PAGE_SIZE);
 		}
 
 
@@ -1914,7 +1914,7 @@ pstripe:
 			/* Copy parity block into failed block to start with */
 			memcpy(pointers[faila],
 			       pointers[rbio->nr_data],
-			       PAGE_CACHE_SIZE);
+			       PAGE_SIZE);
 
 			/* rearrange the pointer array */
 			p = pointers[faila];
@@ -1923,7 +1923,7 @@ pstripe:
 			pointers[rbio->nr_data - 1] = p;
 
 			/* xor in the rest */
-			run_xor(pointers, rbio->nr_data - 1, PAGE_CACHE_SIZE);
+			run_xor(pointers, rbio->nr_data - 1, PAGE_SIZE);
 		}
 		/* if we're doing this rebuild as part of an rmw, go through
 		 * and set all of our private rbio pages in the
@@ -2250,7 +2250,7 @@ void raid56_add_scrub_pages(struct btrfs_raid_bio *rbio, struct page *page,
 	ASSERT(logical + PAGE_SIZE <= rbio->bbio->raid_map[0] +
 				rbio->stripe_len * rbio->nr_data);
 	stripe_offset = (int)(logical - rbio->bbio->raid_map[0]);
-	index = stripe_offset >> PAGE_CACHE_SHIFT;
+	index = stripe_offset >> PAGE_SHIFT;
 	rbio->bio_pages[index] = page;
 }
 
@@ -2365,14 +2365,14 @@ static noinline void finish_parity_scrub(struct btrfs_raid_bio *rbio,
 		} else {
 			/* raid5 */
 			memcpy(pointers[nr_data], pointers[0], PAGE_SIZE);
-			run_xor(pointers + 1, nr_data - 1, PAGE_CACHE_SIZE);
+			run_xor(pointers + 1, nr_data - 1, PAGE_SIZE);
 		}
 
 		/* Check scrubbing pairty and repair it */
 		p = rbio_stripe_page(rbio, rbio->scrubp, pagenr);
 		parity = kmap(p);
-		if (memcmp(parity, pointers[rbio->scrubp], PAGE_CACHE_SIZE))
-			memcpy(parity, pointers[rbio->scrubp], PAGE_CACHE_SIZE);
+		if (memcmp(parity, pointers[rbio->scrubp], PAGE_SIZE))
+			memcpy(parity, pointers[rbio->scrubp], PAGE_SIZE);
 		else
 			/* Parity is right, needn't writeback */
 			bitmap_clear(rbio->dbitmap, pagenr, 1);
diff --git a/fs/btrfs/reada.c b/fs/btrfs/reada.c
index 619f92963e27..bacc55e2655b 100644
--- a/fs/btrfs/reada.c
+++ b/fs/btrfs/reada.c
@@ -116,7 +116,7 @@ static int __readahead_hook(struct btrfs_root *root, struct extent_buffer *eb,
 	struct reada_extent *re;
 	struct btrfs_fs_info *fs_info = root->fs_info;
 	struct list_head list;
-	unsigned long index = start >> PAGE_CACHE_SHIFT;
+	unsigned long index = start >> PAGE_SHIFT;
 	struct btrfs_device *for_dev;
 
 	if (eb)
@@ -259,7 +259,7 @@ static struct reada_zone *reada_find_zone(struct btrfs_fs_info *fs_info,
 	zone = NULL;
 	spin_lock(&fs_info->reada_lock);
 	ret = radix_tree_gang_lookup(&dev->reada_zones, (void **)&zone,
-				     logical >> PAGE_CACHE_SHIFT, 1);
+				     logical >> PAGE_SHIFT, 1);
 	if (ret == 1)
 		kref_get(&zone->refcnt);
 	spin_unlock(&fs_info->reada_lock);
@@ -300,13 +300,13 @@ static struct reada_zone *reada_find_zone(struct btrfs_fs_info *fs_info,
 
 	spin_lock(&fs_info->reada_lock);
 	ret = radix_tree_insert(&dev->reada_zones,
-				(unsigned long)(zone->end >> PAGE_CACHE_SHIFT),
+				(unsigned long)(zone->end >> PAGE_SHIFT),
 				zone);
 
 	if (ret == -EEXIST) {
 		kfree(zone);
 		ret = radix_tree_gang_lookup(&dev->reada_zones, (void **)&zone,
-					     logical >> PAGE_CACHE_SHIFT, 1);
+					     logical >> PAGE_SHIFT, 1);
 		if (ret == 1)
 			kref_get(&zone->refcnt);
 	}
@@ -331,7 +331,7 @@ static struct reada_extent *reada_find_extent(struct btrfs_root *root,
 	int real_stripes;
 	int nzones = 0;
 	int i;
-	unsigned long index = logical >> PAGE_CACHE_SHIFT;
+	unsigned long index = logical >> PAGE_SHIFT;
 	int dev_replace_is_ongoing;
 
 	spin_lock(&fs_info->reada_lock);
@@ -497,7 +497,7 @@ static void reada_extent_put(struct btrfs_fs_info *fs_info,
 			     struct reada_extent *re)
 {
 	int i;
-	unsigned long index = re->logical >> PAGE_CACHE_SHIFT;
+	unsigned long index = re->logical >> PAGE_SHIFT;
 
 	spin_lock(&fs_info->reada_lock);
 	if (--re->refcnt) {
@@ -542,7 +542,7 @@ static void reada_zone_release(struct kref *kref)
 	struct reada_zone *zone = container_of(kref, struct reada_zone, refcnt);
 
 	radix_tree_delete(&zone->device->reada_zones,
-			  zone->end >> PAGE_CACHE_SHIFT);
+			  zone->end >> PAGE_SHIFT);
 
 	kfree(zone);
 }
@@ -591,7 +591,7 @@ static int reada_add_block(struct reada_control *rc, u64 logical,
 static void reada_peer_zones_set_lock(struct reada_zone *zone, int lock)
 {
 	int i;
-	unsigned long index = zone->end >> PAGE_CACHE_SHIFT;
+	unsigned long index = zone->end >> PAGE_SHIFT;
 
 	for (i = 0; i < zone->ndevs; ++i) {
 		struct reada_zone *peer;
@@ -626,7 +626,7 @@ static int reada_pick_zone(struct btrfs_device *dev)
 					     (void **)&zone, index, 1);
 		if (ret == 0)
 			break;
-		index = (zone->end >> PAGE_CACHE_SHIFT) + 1;
+		index = (zone->end >> PAGE_SHIFT) + 1;
 		if (zone->locked) {
 			if (zone->elems > top_locked_elems) {
 				top_locked_elems = zone->elems;
@@ -678,7 +678,7 @@ static int reada_start_machine_dev(struct btrfs_fs_info *fs_info,
 	 * plugging to speed things up
 	 */
 	ret = radix_tree_gang_lookup(&dev->reada_extents, (void **)&re,
-				     dev->reada_next >> PAGE_CACHE_SHIFT, 1);
+				     dev->reada_next >> PAGE_SHIFT, 1);
 	if (ret == 0 || re->logical >= dev->reada_curr_zone->end) {
 		ret = reada_pick_zone(dev);
 		if (!ret) {
@@ -687,7 +687,7 @@ static int reada_start_machine_dev(struct btrfs_fs_info *fs_info,
 		}
 		re = NULL;
 		ret = radix_tree_gang_lookup(&dev->reada_extents, (void **)&re,
-					dev->reada_next >> PAGE_CACHE_SHIFT, 1);
+					dev->reada_next >> PAGE_SHIFT, 1);
 	}
 	if (ret == 0) {
 		spin_unlock(&fs_info->reada_lock);
@@ -836,7 +836,7 @@ static void dump_devs(struct btrfs_fs_info *fs_info, int all)
 				printk(KERN_CONT " curr off %llu",
 					device->reada_next - zone->start);
 			printk(KERN_CONT "\n");
-			index = (zone->end >> PAGE_CACHE_SHIFT) + 1;
+			index = (zone->end >> PAGE_SHIFT) + 1;
 		}
 		cnt = 0;
 		index = 0;
@@ -863,7 +863,7 @@ static void dump_devs(struct btrfs_fs_info *fs_info, int all)
 				}
 			}
 			printk(KERN_CONT "\n");
-			index = (re->logical >> PAGE_CACHE_SHIFT) + 1;
+			index = (re->logical >> PAGE_SHIFT) + 1;
 			if (++cnt > 15)
 				break;
 		}
@@ -879,7 +879,7 @@ static void dump_devs(struct btrfs_fs_info *fs_info, int all)
 		if (ret == 0)
 			break;
 		if (!re->scheduled_for) {
-			index = (re->logical >> PAGE_CACHE_SHIFT) + 1;
+			index = (re->logical >> PAGE_SHIFT) + 1;
 			continue;
 		}
 		printk(KERN_DEBUG
@@ -902,7 +902,7 @@ static void dump_devs(struct btrfs_fs_info *fs_info, int all)
 			}
 		}
 		printk(KERN_CONT "\n");
-		index = (re->logical >> PAGE_CACHE_SHIFT) + 1;
+		index = (re->logical >> PAGE_SHIFT) + 1;
 	}
 	spin_unlock(&fs_info->reada_lock);
 }
diff --git a/fs/btrfs/relocation.c b/fs/btrfs/relocation.c
index 2bd0011450df..3c93968b539d 100644
--- a/fs/btrfs/relocation.c
+++ b/fs/btrfs/relocation.c
@@ -3129,10 +3129,10 @@ static int relocate_file_extent_cluster(struct inode *inode,
 	if (ret)
 		goto out;
 
-	index = (cluster->start - offset) >> PAGE_CACHE_SHIFT;
-	last_index = (cluster->end - offset) >> PAGE_CACHE_SHIFT;
+	index = (cluster->start - offset) >> PAGE_SHIFT;
+	last_index = (cluster->end - offset) >> PAGE_SHIFT;
 	while (index <= last_index) {
-		ret = btrfs_delalloc_reserve_metadata(inode, PAGE_CACHE_SIZE);
+		ret = btrfs_delalloc_reserve_metadata(inode, PAGE_SIZE);
 		if (ret)
 			goto out;
 
@@ -3145,7 +3145,7 @@ static int relocate_file_extent_cluster(struct inode *inode,
 						   mask);
 			if (!page) {
 				btrfs_delalloc_release_metadata(inode,
-							PAGE_CACHE_SIZE);
+							PAGE_SIZE);
 				ret = -ENOMEM;
 				goto out;
 			}
@@ -3162,16 +3162,16 @@ static int relocate_file_extent_cluster(struct inode *inode,
 			lock_page(page);
 			if (!PageUptodate(page)) {
 				unlock_page(page);
-				page_cache_release(page);
+				put_page(page);
 				btrfs_delalloc_release_metadata(inode,
-							PAGE_CACHE_SIZE);
+							PAGE_SIZE);
 				ret = -EIO;
 				goto out;
 			}
 		}
 
 		page_start = page_offset(page);
-		page_end = page_start + PAGE_CACHE_SIZE - 1;
+		page_end = page_start + PAGE_SIZE - 1;
 
 		lock_extent(&BTRFS_I(inode)->io_tree, page_start, page_end);
 
@@ -3191,7 +3191,7 @@ static int relocate_file_extent_cluster(struct inode *inode,
 		unlock_extent(&BTRFS_I(inode)->io_tree,
 			      page_start, page_end);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 
 		index++;
 		balance_dirty_pages_ratelimited(inode->i_mapping);
diff --git a/fs/btrfs/scrub.c b/fs/btrfs/scrub.c
index 92bf5ee732fb..1c6d3267029f 100644
--- a/fs/btrfs/scrub.c
+++ b/fs/btrfs/scrub.c
@@ -703,7 +703,7 @@ static int scrub_fixup_readpage(u64 inum, u64 offset, u64 root, void *fixup_ctx)
 	if (IS_ERR(inode))
 		return PTR_ERR(inode);
 
-	index = offset >> PAGE_CACHE_SHIFT;
+	index = offset >> PAGE_SHIFT;
 
 	page = find_or_create_page(inode->i_mapping, index, GFP_NOFS);
 	if (!page) {
@@ -1636,7 +1636,7 @@ static int scrub_write_page_to_dev_replace(struct scrub_block *sblock,
 	if (spage->io_error) {
 		void *mapped_buffer = kmap_atomic(spage->page);
 
-		memset(mapped_buffer, 0, PAGE_CACHE_SIZE);
+		memset(mapped_buffer, 0, PAGE_SIZE);
 		flush_dcache_page(spage->page);
 		kunmap_atomic(mapped_buffer);
 	}
@@ -4292,8 +4292,8 @@ static int copy_nocow_pages_for_inode(u64 inum, u64 offset, u64 root,
 		goto out;
 	}
 
-	while (len >= PAGE_CACHE_SIZE) {
-		index = offset >> PAGE_CACHE_SHIFT;
+	while (len >= PAGE_SIZE) {
+		index = offset >> PAGE_SHIFT;
 again:
 		page = find_or_create_page(inode->i_mapping, index, GFP_NOFS);
 		if (!page) {
@@ -4324,7 +4324,7 @@ again:
 			 */
 			if (page->mapping != inode->i_mapping) {
 				unlock_page(page);
-				page_cache_release(page);
+				put_page(page);
 				goto again;
 			}
 			if (!PageUptodate(page)) {
@@ -4346,15 +4346,15 @@ again:
 			ret = err;
 next_page:
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 
 		if (ret)
 			break;
 
-		offset += PAGE_CACHE_SIZE;
-		physical_for_dev_replace += PAGE_CACHE_SIZE;
-		nocow_ctx_logical += PAGE_CACHE_SIZE;
-		len -= PAGE_CACHE_SIZE;
+		offset += PAGE_SIZE;
+		physical_for_dev_replace += PAGE_SIZE;
+		nocow_ctx_logical += PAGE_SIZE;
+		len -= PAGE_SIZE;
 	}
 	ret = COPY_COMPLETE;
 out:
@@ -4388,8 +4388,8 @@ static int write_page_nocow(struct scrub_ctx *sctx,
 	bio->bi_iter.bi_size = 0;
 	bio->bi_iter.bi_sector = physical_for_dev_replace >> 9;
 	bio->bi_bdev = dev->bdev;
-	ret = bio_add_page(bio, page, PAGE_CACHE_SIZE, 0);
-	if (ret != PAGE_CACHE_SIZE) {
+	ret = bio_add_page(bio, page, PAGE_SIZE, 0);
+	if (ret != PAGE_SIZE) {
 leave_with_eio:
 		bio_put(bio);
 		btrfs_dev_stat_inc_and_print(dev, BTRFS_DEV_STAT_WRITE_ERRS);
diff --git a/fs/btrfs/send.c b/fs/btrfs/send.c
index 63a6152be04b..f5b875c8c2d8 100644
--- a/fs/btrfs/send.c
+++ b/fs/btrfs/send.c
@@ -4448,9 +4448,9 @@ static ssize_t fill_read_buf(struct send_ctx *sctx, u64 offset, u32 len)
 	struct page *page;
 	char *addr;
 	struct btrfs_key key;
-	pgoff_t index = offset >> PAGE_CACHE_SHIFT;
+	pgoff_t index = offset >> PAGE_SHIFT;
 	pgoff_t last_index;
-	unsigned pg_offset = offset & ~PAGE_CACHE_MASK;
+	unsigned pg_offset = offset & ~PAGE_MASK;
 	ssize_t ret = 0;
 
 	key.objectid = sctx->cur_ino;
@@ -4470,7 +4470,7 @@ static ssize_t fill_read_buf(struct send_ctx *sctx, u64 offset, u32 len)
 	if (len == 0)
 		goto out;
 
-	last_index = (offset + len - 1) >> PAGE_CACHE_SHIFT;
+	last_index = (offset + len - 1) >> PAGE_SHIFT;
 
 	/* initial readahead */
 	memset(&sctx->ra, 0, sizeof(struct file_ra_state));
@@ -4480,7 +4480,7 @@ static ssize_t fill_read_buf(struct send_ctx *sctx, u64 offset, u32 len)
 
 	while (index <= last_index) {
 		unsigned cur_len = min_t(unsigned, len,
-					 PAGE_CACHE_SIZE - pg_offset);
+					 PAGE_SIZE - pg_offset);
 		page = find_or_create_page(inode->i_mapping, index, GFP_NOFS);
 		if (!page) {
 			ret = -ENOMEM;
@@ -4492,7 +4492,7 @@ static ssize_t fill_read_buf(struct send_ctx *sctx, u64 offset, u32 len)
 			lock_page(page);
 			if (!PageUptodate(page)) {
 				unlock_page(page);
-				page_cache_release(page);
+				put_page(page);
 				ret = -EIO;
 				break;
 			}
@@ -4502,7 +4502,7 @@ static ssize_t fill_read_buf(struct send_ctx *sctx, u64 offset, u32 len)
 		memcpy(sctx->read_buf + ret, addr + pg_offset, cur_len);
 		kunmap(page);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		index++;
 		pg_offset = 0;
 		len -= cur_len;
@@ -4803,7 +4803,7 @@ static int clone_range(struct send_ctx *sctx,
 		type = btrfs_file_extent_type(leaf, ei);
 		if (type == BTRFS_FILE_EXTENT_INLINE) {
 			ext_len = btrfs_file_extent_inline_len(leaf, slot, ei);
-			ext_len = PAGE_CACHE_ALIGN(ext_len);
+			ext_len = PAGE_ALIGN(ext_len);
 		} else {
 			ext_len = btrfs_file_extent_num_bytes(leaf, ei);
 		}
@@ -4885,7 +4885,7 @@ static int send_write_or_clone(struct send_ctx *sctx,
 		 * but there may be items after this page.  Make
 		 * sure to send the whole thing
 		 */
-		len = PAGE_CACHE_ALIGN(len);
+		len = PAGE_ALIGN(len);
 	} else {
 		len = btrfs_file_extent_num_bytes(path->nodes[0], ei);
 	}
diff --git a/fs/btrfs/struct-funcs.c b/fs/btrfs/struct-funcs.c
index b976597b0721..42752e5ead15 100644
--- a/fs/btrfs/struct-funcs.c
+++ b/fs/btrfs/struct-funcs.c
@@ -66,7 +66,7 @@ u##bits btrfs_get_token_##bits(struct extent_buffer *eb, void *ptr,	\
 									\
 	if (token && token->kaddr && token->offset <= offset &&		\
 	    token->eb == eb &&						\
-	   (token->offset + PAGE_CACHE_SIZE >= offset + size)) {	\
+	   (token->offset + PAGE_SIZE >= offset + size)) {		\
 		kaddr = token->kaddr;					\
 		p = kaddr + part_offset - token->offset;		\
 		res = get_unaligned_le##bits(p + off);			\
@@ -104,7 +104,7 @@ void btrfs_set_token_##bits(struct extent_buffer *eb,			\
 									\
 	if (token && token->kaddr && token->offset <= offset &&		\
 	    token->eb == eb &&						\
-	   (token->offset + PAGE_CACHE_SIZE >= offset + size)) {	\
+	   (token->offset + PAGE_SIZE >= offset + size)) {		\
 		kaddr = token->kaddr;					\
 		p = kaddr + part_offset - token->offset;		\
 		put_unaligned_le##bits(val, p + off);			\
diff --git a/fs/btrfs/tests/extent-io-tests.c b/fs/btrfs/tests/extent-io-tests.c
index 669b58201e36..70948b13bc81 100644
--- a/fs/btrfs/tests/extent-io-tests.c
+++ b/fs/btrfs/tests/extent-io-tests.c
@@ -32,8 +32,8 @@ static noinline int process_page_range(struct inode *inode, u64 start, u64 end,
 {
 	int ret;
 	struct page *pages[16];
-	unsigned long index = start >> PAGE_CACHE_SHIFT;
-	unsigned long end_index = end >> PAGE_CACHE_SHIFT;
+	unsigned long index = start >> PAGE_SHIFT;
+	unsigned long end_index = end >> PAGE_SHIFT;
 	unsigned long nr_pages = end_index - index + 1;
 	int i;
 	int count = 0;
@@ -49,9 +49,9 @@ static noinline int process_page_range(struct inode *inode, u64 start, u64 end,
 				count++;
 			if (flags & PROCESS_UNLOCK && PageLocked(pages[i]))
 				unlock_page(pages[i]);
-			page_cache_release(pages[i]);
+			put_page(pages[i]);
 			if (flags & PROCESS_RELEASE)
-				page_cache_release(pages[i]);
+				put_page(pages[i]);
 		}
 		nr_pages -= ret;
 		index += ret;
@@ -93,7 +93,7 @@ static int test_find_delalloc(void)
 	 * everything to make sure our pages don't get evicted and screw up our
 	 * test.
 	 */
-	for (index = 0; index < (total_dirty >> PAGE_CACHE_SHIFT); index++) {
+	for (index = 0; index < (total_dirty >> PAGE_SHIFT); index++) {
 		page = find_or_create_page(inode->i_mapping, index, GFP_KERNEL);
 		if (!page) {
 			test_msg("Failed to allocate test page\n");
@@ -104,7 +104,7 @@ static int test_find_delalloc(void)
 		if (index) {
 			unlock_page(page);
 		} else {
-			page_cache_get(page);
+			get_page(page);
 			locked_page = page;
 		}
 	}
@@ -129,7 +129,7 @@ static int test_find_delalloc(void)
 	}
 	unlock_extent(&tmp, start, end);
 	unlock_page(locked_page);
-	page_cache_release(locked_page);
+	put_page(locked_page);
 
 	/*
 	 * Test this scenario
@@ -139,7 +139,7 @@ static int test_find_delalloc(void)
 	 */
 	test_start = SZ_64M;
 	locked_page = find_lock_page(inode->i_mapping,
-				     test_start >> PAGE_CACHE_SHIFT);
+				     test_start >> PAGE_SHIFT);
 	if (!locked_page) {
 		test_msg("Couldn't find the locked page\n");
 		goto out_bits;
@@ -165,7 +165,7 @@ static int test_find_delalloc(void)
 	}
 	unlock_extent(&tmp, start, end);
 	/* locked_page was unlocked above */
-	page_cache_release(locked_page);
+	put_page(locked_page);
 
 	/*
 	 * Test this scenario
@@ -174,7 +174,7 @@ static int test_find_delalloc(void)
 	 */
 	test_start = max_bytes + 4096;
 	locked_page = find_lock_page(inode->i_mapping, test_start >>
-				     PAGE_CACHE_SHIFT);
+				     PAGE_SHIFT);
 	if (!locked_page) {
 		test_msg("Could'nt find the locked page\n");
 		goto out_bits;
@@ -225,13 +225,13 @@ static int test_find_delalloc(void)
 	 * range we want to find.
 	 */
 	page = find_get_page(inode->i_mapping,
-			     (max_bytes + SZ_1M) >> PAGE_CACHE_SHIFT);
+			     (max_bytes + SZ_1M) >> PAGE_SHIFT);
 	if (!page) {
 		test_msg("Couldn't find our page\n");
 		goto out_bits;
 	}
 	ClearPageDirty(page);
-	page_cache_release(page);
+	put_page(page);
 
 	/* We unlocked it in the previous test */
 	lock_page(locked_page);
@@ -239,7 +239,7 @@ static int test_find_delalloc(void)
 	end = 0;
 	/*
 	 * Currently if we fail to find dirty pages in the delalloc range we
-	 * will adjust max_bytes down to PAGE_CACHE_SIZE and then re-search.  If
+	 * will adjust max_bytes down to PAGE_SIZE and then re-search.  If
 	 * this changes at any point in the future we will need to fix this
 	 * tests expected behavior.
 	 */
@@ -249,9 +249,9 @@ static int test_find_delalloc(void)
 		test_msg("Didn't find our range\n");
 		goto out_bits;
 	}
-	if (start != test_start && end != test_start + PAGE_CACHE_SIZE - 1) {
+	if (start != test_start && end != test_start + PAGE_SIZE - 1) {
 		test_msg("Expected start %Lu end %Lu, got start %Lu end %Lu\n",
-			 test_start, test_start + PAGE_CACHE_SIZE - 1, start,
+			 test_start, test_start + PAGE_SIZE - 1, start,
 			 end);
 		goto out_bits;
 	}
@@ -265,7 +265,7 @@ out_bits:
 	clear_extent_bits(&tmp, 0, total_dirty - 1, (unsigned)-1, GFP_KERNEL);
 out:
 	if (locked_page)
-		page_cache_release(locked_page);
+		put_page(locked_page);
 	process_page_range(inode, 0, total_dirty - 1,
 			   PROCESS_UNLOCK | PROCESS_RELEASE);
 	iput(inode);
@@ -298,9 +298,9 @@ static int __test_eb_bitmaps(unsigned long *bitmap, struct extent_buffer *eb,
 		return -EINVAL;
 	}
 
-	bitmap_set(bitmap, (PAGE_CACHE_SIZE - sizeof(long) / 2) * BITS_PER_BYTE,
+	bitmap_set(bitmap, (PAGE_SIZE - sizeof(long) / 2) * BITS_PER_BYTE,
 		   sizeof(long) * BITS_PER_BYTE);
-	extent_buffer_bitmap_set(eb, PAGE_CACHE_SIZE - sizeof(long) / 2, 0,
+	extent_buffer_bitmap_set(eb, PAGE_SIZE - sizeof(long) / 2, 0,
 				 sizeof(long) * BITS_PER_BYTE);
 	if (memcmp_extent_buffer(eb, bitmap, 0, len) != 0) {
 		test_msg("Setting straddling pages failed\n");
@@ -309,10 +309,10 @@ static int __test_eb_bitmaps(unsigned long *bitmap, struct extent_buffer *eb,
 
 	bitmap_set(bitmap, 0, len * BITS_PER_BYTE);
 	bitmap_clear(bitmap,
-		     (PAGE_CACHE_SIZE - sizeof(long) / 2) * BITS_PER_BYTE,
+		     (PAGE_SIZE - sizeof(long) / 2) * BITS_PER_BYTE,
 		     sizeof(long) * BITS_PER_BYTE);
 	extent_buffer_bitmap_set(eb, 0, 0, len * BITS_PER_BYTE);
-	extent_buffer_bitmap_clear(eb, PAGE_CACHE_SIZE - sizeof(long) / 2, 0,
+	extent_buffer_bitmap_clear(eb, PAGE_SIZE - sizeof(long) / 2, 0,
 				   sizeof(long) * BITS_PER_BYTE);
 	if (memcmp_extent_buffer(eb, bitmap, 0, len) != 0) {
 		test_msg("Clearing straddling pages failed\n");
@@ -353,7 +353,7 @@ static int __test_eb_bitmaps(unsigned long *bitmap, struct extent_buffer *eb,
 
 static int test_eb_bitmaps(void)
 {
-	unsigned long len = PAGE_CACHE_SIZE * 4;
+	unsigned long len = PAGE_SIZE * 4;
 	unsigned long *bitmap;
 	struct extent_buffer *eb;
 	int ret;
@@ -379,7 +379,7 @@ static int test_eb_bitmaps(void)
 
 	/* Do it over again with an extent buffer which isn't page-aligned. */
 	free_extent_buffer(eb);
-	eb = __alloc_dummy_extent_buffer(NULL, PAGE_CACHE_SIZE / 2, len);
+	eb = __alloc_dummy_extent_buffer(NULL, PAGE_SIZE / 2, len);
 	if (!eb) {
 		test_msg("Couldn't allocate test extent buffer\n");
 		kfree(bitmap);
diff --git a/fs/btrfs/tests/free-space-tests.c b/fs/btrfs/tests/free-space-tests.c
index c9ad97b1e690..514247515312 100644
--- a/fs/btrfs/tests/free-space-tests.c
+++ b/fs/btrfs/tests/free-space-tests.c
@@ -22,7 +22,7 @@
 #include "../disk-io.h"
 #include "../free-space-cache.h"
 
-#define BITS_PER_BITMAP		(PAGE_CACHE_SIZE * 8)
+#define BITS_PER_BITMAP		(PAGE_SIZE * 8)
 
 /*
  * This test just does basic sanity checking, making sure we can add an exten
diff --git a/fs/btrfs/volumes.c b/fs/btrfs/volumes.c
index 366b335946fa..eeb6da7976a5 100644
--- a/fs/btrfs/volumes.c
+++ b/fs/btrfs/volumes.c
@@ -1024,16 +1024,16 @@ int btrfs_scan_one_device(const char *path, fmode_t flags, void *holder,
 	}
 
 	/* make sure our super fits in the device */
-	if (bytenr + PAGE_CACHE_SIZE >= i_size_read(bdev->bd_inode))
+	if (bytenr + PAGE_SIZE >= i_size_read(bdev->bd_inode))
 		goto error_bdev_put;
 
 	/* make sure our super fits in the page */
-	if (sizeof(*disk_super) > PAGE_CACHE_SIZE)
+	if (sizeof(*disk_super) > PAGE_SIZE)
 		goto error_bdev_put;
 
 	/* make sure our super doesn't straddle pages on disk */
-	index = bytenr >> PAGE_CACHE_SHIFT;
-	if ((bytenr + sizeof(*disk_super) - 1) >> PAGE_CACHE_SHIFT != index)
+	index = bytenr >> PAGE_SHIFT;
+	if ((bytenr + sizeof(*disk_super) - 1) >> PAGE_SHIFT != index)
 		goto error_bdev_put;
 
 	/* pull in the page with our super */
@@ -1046,7 +1046,7 @@ int btrfs_scan_one_device(const char *path, fmode_t flags, void *holder,
 	p = kmap(page);
 
 	/* align our pointer to the offset of the super block */
-	disk_super = p + (bytenr & ~PAGE_CACHE_MASK);
+	disk_super = p + (bytenr & ~PAGE_MASK);
 
 	if (btrfs_super_bytenr(disk_super) != bytenr ||
 	    btrfs_super_magic(disk_super) != BTRFS_MAGIC)
@@ -1074,7 +1074,7 @@ int btrfs_scan_one_device(const char *path, fmode_t flags, void *holder,
 
 error_unmap:
 	kunmap(page);
-	page_cache_release(page);
+	put_page(page);
 
 error_bdev_put:
 	blkdev_put(bdev, flags);
@@ -6522,7 +6522,7 @@ int btrfs_read_sys_array(struct btrfs_root *root)
 	 * but sb spans only this function. Add an explicit SetPageUptodate call
 	 * to silence the warning eg. on PowerPC 64.
 	 */
-	if (PAGE_CACHE_SIZE > BTRFS_SUPER_INFO_SIZE)
+	if (PAGE_SIZE > BTRFS_SUPER_INFO_SIZE)
 		SetPageUptodate(sb->pages[0]);
 
 	write_extent_buffer(sb, super_copy, 0, BTRFS_SUPER_INFO_SIZE);
diff --git a/fs/btrfs/zlib.c b/fs/btrfs/zlib.c
index 82990b8f872b..88d274e8ecf2 100644
--- a/fs/btrfs/zlib.c
+++ b/fs/btrfs/zlib.c
@@ -59,7 +59,7 @@ static struct list_head *zlib_alloc_workspace(void)
 	workspacesize = max(zlib_deflate_workspacesize(MAX_WBITS, MAX_MEM_LEVEL),
 			zlib_inflate_workspacesize());
 	workspace->strm.workspace = vmalloc(workspacesize);
-	workspace->buf = kmalloc(PAGE_CACHE_SIZE, GFP_NOFS);
+	workspace->buf = kmalloc(PAGE_SIZE, GFP_NOFS);
 	if (!workspace->strm.workspace || !workspace->buf)
 		goto fail;
 
@@ -103,7 +103,7 @@ static int zlib_compress_pages(struct list_head *ws,
 	workspace->strm.total_in = 0;
 	workspace->strm.total_out = 0;
 
-	in_page = find_get_page(mapping, start >> PAGE_CACHE_SHIFT);
+	in_page = find_get_page(mapping, start >> PAGE_SHIFT);
 	data_in = kmap(in_page);
 
 	out_page = alloc_page(GFP_NOFS | __GFP_HIGHMEM);
@@ -117,8 +117,8 @@ static int zlib_compress_pages(struct list_head *ws,
 
 	workspace->strm.next_in = data_in;
 	workspace->strm.next_out = cpage_out;
-	workspace->strm.avail_out = PAGE_CACHE_SIZE;
-	workspace->strm.avail_in = min(len, PAGE_CACHE_SIZE);
+	workspace->strm.avail_out = PAGE_SIZE;
+	workspace->strm.avail_in = min(len, PAGE_SIZE);
 
 	while (workspace->strm.total_in < len) {
 		ret = zlib_deflate(&workspace->strm, Z_SYNC_FLUSH);
@@ -156,7 +156,7 @@ static int zlib_compress_pages(struct list_head *ws,
 			cpage_out = kmap(out_page);
 			pages[nr_pages] = out_page;
 			nr_pages++;
-			workspace->strm.avail_out = PAGE_CACHE_SIZE;
+			workspace->strm.avail_out = PAGE_SIZE;
 			workspace->strm.next_out = cpage_out;
 		}
 		/* we're all done */
@@ -170,14 +170,14 @@ static int zlib_compress_pages(struct list_head *ws,
 
 			bytes_left = len - workspace->strm.total_in;
 			kunmap(in_page);
-			page_cache_release(in_page);
+			put_page(in_page);
 
-			start += PAGE_CACHE_SIZE;
+			start += PAGE_SIZE;
 			in_page = find_get_page(mapping,
-						start >> PAGE_CACHE_SHIFT);
+						start >> PAGE_SHIFT);
 			data_in = kmap(in_page);
 			workspace->strm.avail_in = min(bytes_left,
-							   PAGE_CACHE_SIZE);
+							   PAGE_SIZE);
 			workspace->strm.next_in = data_in;
 		}
 	}
@@ -205,7 +205,7 @@ out:
 
 	if (in_page) {
 		kunmap(in_page);
-		page_cache_release(in_page);
+		put_page(in_page);
 	}
 	return ret;
 }
@@ -223,18 +223,18 @@ static int zlib_decompress_biovec(struct list_head *ws, struct page **pages_in,
 	size_t total_out = 0;
 	unsigned long page_in_index = 0;
 	unsigned long page_out_index = 0;
-	unsigned long total_pages_in = DIV_ROUND_UP(srclen, PAGE_CACHE_SIZE);
+	unsigned long total_pages_in = DIV_ROUND_UP(srclen, PAGE_SIZE);
 	unsigned long buf_start;
 	unsigned long pg_offset;
 
 	data_in = kmap(pages_in[page_in_index]);
 	workspace->strm.next_in = data_in;
-	workspace->strm.avail_in = min_t(size_t, srclen, PAGE_CACHE_SIZE);
+	workspace->strm.avail_in = min_t(size_t, srclen, PAGE_SIZE);
 	workspace->strm.total_in = 0;
 
 	workspace->strm.total_out = 0;
 	workspace->strm.next_out = workspace->buf;
-	workspace->strm.avail_out = PAGE_CACHE_SIZE;
+	workspace->strm.avail_out = PAGE_SIZE;
 	pg_offset = 0;
 
 	/* If it's deflate, and it's got no preset dictionary, then
@@ -274,7 +274,7 @@ static int zlib_decompress_biovec(struct list_head *ws, struct page **pages_in,
 		}
 
 		workspace->strm.next_out = workspace->buf;
-		workspace->strm.avail_out = PAGE_CACHE_SIZE;
+		workspace->strm.avail_out = PAGE_SIZE;
 
 		if (workspace->strm.avail_in == 0) {
 			unsigned long tmp;
@@ -288,7 +288,7 @@ static int zlib_decompress_biovec(struct list_head *ws, struct page **pages_in,
 			workspace->strm.next_in = data_in;
 			tmp = srclen - workspace->strm.total_in;
 			workspace->strm.avail_in = min(tmp,
-							   PAGE_CACHE_SIZE);
+							   PAGE_SIZE);
 		}
 	}
 	if (ret != Z_STREAM_END)
@@ -325,7 +325,7 @@ static int zlib_decompress(struct list_head *ws, unsigned char *data_in,
 	workspace->strm.total_in = 0;
 
 	workspace->strm.next_out = workspace->buf;
-	workspace->strm.avail_out = PAGE_CACHE_SIZE;
+	workspace->strm.avail_out = PAGE_SIZE;
 	workspace->strm.total_out = 0;
 	/* If it's deflate, and it's got no preset dictionary, then
 	   we can tell zlib to skip the adler32 check. */
@@ -368,8 +368,8 @@ static int zlib_decompress(struct list_head *ws, unsigned char *data_in,
 		else
 			buf_offset = 0;
 
-		bytes = min(PAGE_CACHE_SIZE - pg_offset,
-			    PAGE_CACHE_SIZE - buf_offset);
+		bytes = min(PAGE_SIZE - pg_offset,
+			    PAGE_SIZE - buf_offset);
 		bytes = min(bytes, bytes_left);
 
 		kaddr = kmap_atomic(dest_page);
@@ -380,7 +380,7 @@ static int zlib_decompress(struct list_head *ws, unsigned char *data_in,
 		bytes_left -= bytes;
 next:
 		workspace->strm.next_out = workspace->buf;
-		workspace->strm.avail_out = PAGE_CACHE_SIZE;
+		workspace->strm.avail_out = PAGE_SIZE;
 	}
 
 	if (ret != Z_STREAM_END && bytes_left != 0)
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
