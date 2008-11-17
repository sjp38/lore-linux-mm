Date: Mon, 17 Nov 2008 13:08:56 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Large stack usage in fs code (especially for PPC64)
Message-Id: <20081117130856.92e41cd3.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.1.10.0811171508300.8722@gandalf.stny.rr.com>
References: <alpine.DEB.1.10.0811171508300.8722@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-kernel@vger.kernel.org, paulus@samba.org, benh@kernel.crashing.org, linuxppc-dev@ozlabs.org, torvalds@linux-foundation.org, mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 17 Nov 2008 15:34:13 -0500 (EST)
Steven Rostedt <rostedt@goodmis.org> wrote:

> 
> I've been hitting stack overflows on a PPC64 box, so I ran the ftrace 
> stack_tracer and part of the problem with that box is that it can nest 
> interrupts too deep. But what also worries me is that there's some heavy 
> hitters of stacks in generic code. Namely the fs directory has some.
> 
> Here's the full dump of the stack (PPC64):
>
> ...
>
> do_mpage_readpage. They each use 1280 bytes of stack! Looking at the start 
> of these two:
> 
> int block_read_full_page(struct page *page, get_block_t *get_block)
> {
> 	struct inode *inode = page->mapping->host;
> 	sector_t iblock, lblock;
> 	struct buffer_head *bh, *head, *arr[MAX_BUF_PER_PAGE];
> 	unsigned int blocksize;
> 	int nr, i;
> 	int fully_mapped = 1;
> [...]
> 
> static struct bio *
> do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
> 		sector_t *last_block_in_bio, struct buffer_head *map_bh,
> 		unsigned long *first_logical_block, get_block_t get_block)
> {
> 	struct inode *inode = page->mapping->host;
> 	const unsigned blkbits = inode->i_blkbits;
> 	const unsigned blocks_per_page = PAGE_CACHE_SIZE >> blkbits;
> 	const unsigned blocksize = 1 << blkbits;
> 	sector_t block_in_file;
> 	sector_t last_block;
> 	sector_t last_block_in_file;
> 	sector_t blocks[MAX_BUF_PER_PAGE];
> 	unsigned page_block;
> 	unsigned first_hole = blocks_per_page;
> 	struct block_device *bdev = NULL;
> 	int length;
> 	int fully_mapped = 1;
> 	unsigned nblocks;
> 	unsigned relative_block;
> 
> 
> The thing that hits my eye on both is the MAX_BUF_PER_PAGE usage. That is 
> defined as: 
> 
> define MAX_BUF_PER_PAGE (PAGE_CACHE_SIZE / 512)
> 
> Where PAGE_CACHE_SIZE is the same as PAGE_SIZE.
> 
> On PPC64 I'm told that the page size is 64K, which makes the above equal 
> to: 64K / 512 = 128  multiply that by 8 byte words, we have 1024 bytes.
> 
> The problem with PPC64 is that the stack size is not equal to the page 
> size. The stack size is only 16K not 64K.
> 
> The above stack trace was taken right after boot up and it was already at 
> 14K, not too far from the 16k limit.
> 
> Note, I was using a default config that had CONFIG_IRQSTACKS off and
> CONFIG_PPC_64K_PAGES on.
> 

Far be it from me to apportion blame, but THIS IS ALL LINUS'S FAULT!!!!! :)

I fixed this six years ago.  See http://lkml.org/lkml/2002/6/17/68

I still have the patch but for some reason it appears to get some
rejects.  However I think the approach (whatever it was ;)) is still
usable.  Perhaps some keen young thing has time to get down and redo
it.




This patch fixes some potential stack consumption problems.

The storage for

	sector_t blocks[MAX_BUF_PER_PAGE];
and
	struct buffer_head *arr[MAX_BUF_PER_PAGE];

will consume a kilobyte with 64k page, 64-bit sector_t.  And on
the path

	do_mpage_readpage
	->block_read_full_page
	  -> <page allocation>
	    ->mpage_writepage

they can be nested three-deep.  3k of stack gone.  Presumably in this
case the stack page would be 64k anyway, so that's not a problem. 
However if PAGE_SIZE=4k and PAGE_CACHE_SIZE=64k, we die.

I've yet to see any reason for larger PAGE_CACHE_SIZE, but this is a
neater implementation anyway.  

The patch removes MAX_BUF_PER_PAGE and instead walks the page's buffer
ring to work out which buffers need to be submitted.



--- 2.5.22/fs/mpage.c~stack-space	Sun Jun 16 22:50:17 2002
+++ 2.5.22-akpm/fs/mpage.c	Sun Jun 16 22:50:17 2002
@@ -169,8 +169,9 @@ do_mpage_readpage(struct bio *bio, struc
 	const unsigned blocksize = 1 << blkbits;
 	struct bio_vec *bvec;
 	sector_t block_in_file;
-	sector_t last_block;
-	sector_t blocks[MAX_BUF_PER_PAGE];
+	sector_t last_file_block;
+	sector_t first_page_block = -1;
+	sector_t last_page_block = -1;
 	unsigned page_block;
 	unsigned first_hole = blocks_per_page;
 	struct block_device *bdev = NULL;
@@ -180,12 +181,12 @@ do_mpage_readpage(struct bio *bio, struc
 		goto confused;
 
 	block_in_file = page->index << (PAGE_CACHE_SHIFT - blkbits);
-	last_block = (inode->i_size + blocksize - 1) >> blkbits;
+	last_file_block = (inode->i_size + blocksize - 1) >> blkbits;
 
 	for (page_block = 0; page_block < blocks_per_page;
 				page_block++, block_in_file++) {
 		bh.b_state = 0;
-		if (block_in_file < last_block) {
+		if (block_in_file < last_file_block) {
 			if (get_block(inode, block_in_file, &bh, 0))
 				goto confused;
 		}
@@ -199,10 +200,14 @@ do_mpage_readpage(struct bio *bio, struc
 		if (first_hole != blocks_per_page)
 			goto confused;		/* hole -> non-hole */
 
-		/* Contiguous blocks? */
-		if (page_block && blocks[page_block-1] != bh.b_blocknr-1)
-			goto confused;
-		blocks[page_block] = bh.b_blocknr;
+		if (page_block) {
+			/* Contiguous blocks? */
+			if (bh.b_blocknr != last_page_block + 1)
+				goto confused;
+		} else {
+			first_page_block = bh.b_blocknr;
+		}
+		last_page_block = bh.b_blocknr;
 		bdev = bh.b_bdev;
 	}
 
@@ -222,7 +227,7 @@ do_mpage_readpage(struct bio *bio, struc
 	 * This page will go to BIO.  Do we need to send this BIO off first?
 	 */
 	if (bio && (bio->bi_idx == bio->bi_vcnt ||
-			*last_block_in_bio != blocks[0] - 1))
+			*last_block_in_bio != first_page_block - 1))
 		bio = mpage_bio_submit(READ, bio);
 
 	if (bio == NULL) {
@@ -230,7 +235,7 @@ do_mpage_readpage(struct bio *bio, struc
 
 		if (nr_bvecs > nr_pages)
 			nr_bvecs = nr_pages;
-		bio = mpage_alloc(bdev, blocks[0] << (blkbits - 9),
+		bio = mpage_alloc(bdev, first_page_block << (blkbits - 9),
 					nr_bvecs, GFP_KERNEL);
 		if (bio == NULL)
 			goto confused;
@@ -244,7 +249,7 @@ do_mpage_readpage(struct bio *bio, struc
 	if (buffer_boundary(&bh) || (first_hole != blocks_per_page))
 		bio = mpage_bio_submit(READ, bio);
 	else
-		*last_block_in_bio = blocks[blocks_per_page - 1];
+		*last_block_in_bio = last_page_block;
 out:
 	return bio;
 
@@ -322,9 +327,10 @@ mpage_writepage(struct bio *bio, struct 
 	unsigned long end_index;
 	const unsigned blocks_per_page = PAGE_CACHE_SIZE >> blkbits;
 	struct bio_vec *bvec;
-	sector_t last_block;
+	sector_t last_file_block;
 	sector_t block_in_file;
-	sector_t blocks[MAX_BUF_PER_PAGE];
+	sector_t first_page_block = -1;
+	sector_t last_page_block = -1;
 	unsigned page_block;
 	unsigned first_unmapped = blocks_per_page;
 	struct block_device *bdev = NULL;
@@ -355,11 +361,13 @@ mpage_writepage(struct bio *bio, struct 
 
 			if (!buffer_dirty(bh) || !buffer_uptodate(bh))
 				goto confused;
-			if (page_block) {
-				if (bh->b_blocknr != blocks[page_block-1] + 1)
+			if (page_block++) {
+				if (bh->b_blocknr != last_page_block + 1)
 					goto confused;
+			} else {
+				first_page_block = bh->b_blocknr;
 			}
-			blocks[page_block++] = bh->b_blocknr;
+			last_page_block = bh->b_blocknr;
 			boundary = buffer_boundary(bh);
 			bdev = bh->b_bdev;
 		} while ((bh = bh->b_this_page) != head);
@@ -381,7 +389,7 @@ mpage_writepage(struct bio *bio, struct 
 	 */
 	BUG_ON(!PageUptodate(page));
 	block_in_file = page->index << (PAGE_CACHE_SHIFT - blkbits);
-	last_block = (inode->i_size - 1) >> blkbits;
+	last_file_block = (inode->i_size - 1) >> blkbits;
 	for (page_block = 0; page_block < blocks_per_page; ) {
 		struct buffer_head map_bh;
 
@@ -392,13 +400,16 @@ mpage_writepage(struct bio *bio, struct 
 			unmap_underlying_metadata(map_bh.b_bdev,
 						map_bh.b_blocknr);
 		if (page_block) {
-			if (map_bh.b_blocknr != blocks[page_block-1] + 1)
+			if (map_bh.b_blocknr != last_page_block + 1)
 				goto confused;
+		} else {
+			first_page_block = map_bh.b_blocknr;
 		}
-		blocks[page_block++] = map_bh.b_blocknr;
+		page_block++;
+		last_page_block = map_bh.b_blocknr;
 		boundary = buffer_boundary(&map_bh);
 		bdev = map_bh.b_bdev;
-		if (block_in_file == last_block)
+		if (block_in_file == last_file_block)
 			break;
 		block_in_file++;
 	}
@@ -424,13 +435,13 @@ page_is_mapped:
 	 * This page will go to BIO.  Do we need to send this BIO off first?
 	 */
 	if (bio && (bio->bi_idx == bio->bi_vcnt ||
-				*last_block_in_bio != blocks[0] - 1))
+				*last_block_in_bio != first_page_block - 1))
 		bio = mpage_bio_submit(WRITE, bio);
 
 	if (bio == NULL) {
 		unsigned nr_bvecs = MPAGE_BIO_MAX_SIZE / PAGE_CACHE_SIZE;
 
-		bio = mpage_alloc(bdev, blocks[0] << (blkbits - 9),
+		bio = mpage_alloc(bdev, first_page_block << (blkbits - 9),
 					nr_bvecs, GFP_NOFS);
 		if (bio == NULL)
 			goto confused;
@@ -464,7 +475,7 @@ page_is_mapped:
 	if (boundary || (first_unmapped != blocks_per_page))
 		bio = mpage_bio_submit(WRITE, bio);
 	else
-		*last_block_in_bio = blocks[blocks_per_page - 1];
+		*last_block_in_bio = last_page_block;
 	goto out;
 
 confused:
--- 2.5.22/fs/buffer.c~stack-space	Sun Jun 16 22:50:17 2002
+++ 2.5.22-akpm/fs/buffer.c	Sun Jun 16 23:22:48 2002
@@ -1799,7 +1799,7 @@ int block_read_full_page(struct page *pa
 {
 	struct inode *inode = page->mapping->host;
 	unsigned long iblock, lblock;
-	struct buffer_head *bh, *head, *arr[MAX_BUF_PER_PAGE];
+	struct buffer_head *bh, *head;
 	unsigned int blocksize, blocks;
 	int nr, i;
 
@@ -1842,7 +1842,7 @@ int block_read_full_page(struct page *pa
 			if (buffer_uptodate(bh))
 				continue;
 		}
-		arr[nr++] = bh;
+		nr++;
 	} while (i++, iblock++, (bh = bh->b_this_page) != head);
 
 	if (!nr) {
@@ -1857,24 +1857,26 @@ int block_read_full_page(struct page *pa
 	}
 
 	/* Stage two: lock the buffers */
-	for (i = 0; i < nr; i++) {
-		bh = arr[i];
-		lock_buffer(bh);
-		mark_buffer_async_read(bh);
-	}
+	do {
+		if (!buffer_uptodate(bh)) {
+			lock_buffer(bh);
+			mark_buffer_async_read(bh);
+		}
+	} while ((bh = bh->b_this_page) != head);
 
 	/*
 	 * Stage 3: start the IO.  Check for uptodateness
 	 * inside the buffer lock in case another process reading
 	 * the underlying blockdev brought it uptodate (the sct fix).
 	 */
-	for (i = 0; i < nr; i++) {
-		bh = arr[i];
-		if (buffer_uptodate(bh))
-			end_buffer_async_read(bh, 1);
-		else
-			submit_bh(READ, bh);
-	}
+	do {
+		if (buffer_async_read(bh)) {
+			if (buffer_uptodate(bh))
+				end_buffer_async_read(bh, 1);
+			else
+				submit_bh(READ, bh);
+		}
+	} while ((bh = bh->b_this_page) != head);
 	return 0;
 }
 
@@ -2490,8 +2492,8 @@ static void bh_mempool_free(void *elemen
 	return kmem_cache_free(bh_cachep, element);
 }
 
-#define NR_RESERVED (10*MAX_BUF_PER_PAGE)
-#define MAX_UNUSED_BUFFERS NR_RESERVED+20
+
+#define MEMPOOL_BUFFERS (32 * PAGE_CACHE_SIZE / 512)
 
 void __init buffer_init(void)
 {
@@ -2500,7 +2502,7 @@ void __init buffer_init(void)
 	bh_cachep = kmem_cache_create("buffer_head",
 			sizeof(struct buffer_head), 0,
 			SLAB_HWCACHE_ALIGN, init_buffer_head, NULL);
-	bh_mempool = mempool_create(MAX_UNUSED_BUFFERS, bh_mempool_alloc,
+	bh_mempool = mempool_create(MEMPOOL_BUFFERS, bh_mempool_alloc,
 				bh_mempool_free, NULL);
 	for (i = 0; i < ARRAY_SIZE(bh_wait_queue_heads); i++)
 		init_waitqueue_head(&bh_wait_queue_heads[i].wqh);
--- 2.5.22/fs/block_dev.c~stack-space	Sun Jun 16 22:50:17 2002
+++ 2.5.22-akpm/fs/block_dev.c	Sun Jun 16 22:50:17 2002
@@ -23,8 +23,6 @@
 
 #include <asm/uaccess.h>
 
-#define MAX_BUF_PER_PAGE (PAGE_CACHE_SIZE / 512)
-
 static unsigned long max_block(struct block_device *bdev)
 {
 	unsigned int retval = ~0U;
--- 2.5.22/include/linux/buffer_head.h~stack-space	Sun Jun 16 22:50:17 2002
+++ 2.5.22-akpm/include/linux/buffer_head.h	Sun Jun 16 23:22:47 2002
@@ -29,8 +29,6 @@ enum bh_state_bits {
 			 */
 };
 
-#define MAX_BUF_PER_PAGE (PAGE_CACHE_SIZE / 512)
-
 struct page;
 struct kiobuf;
 struct buffer_head;
--- 2.5.22/fs/ntfs/aops.c~stack-space	Sun Jun 16 22:50:17 2002
+++ 2.5.22-akpm/fs/ntfs/aops.c	Sun Jun 16 23:22:46 2002
@@ -104,7 +104,7 @@ static int ntfs_file_read_block(struct p
 	LCN lcn;
 	ntfs_inode *ni;
 	ntfs_volume *vol;
-	struct buffer_head *bh, *head, *arr[MAX_BUF_PER_PAGE];
+	struct buffer_head *bh, *head;
 	sector_t iblock, lblock, zblock;
 	unsigned int blocksize, blocks, vcn_ofs;
 	int i, nr;
@@ -116,11 +116,12 @@ static int ntfs_file_read_block(struct p
 	blocksize_bits = VFS_I(ni)->i_blkbits;
 	blocksize = 1 << blocksize_bits;
 
-	if (!page_has_buffers(page))
+	if (!page_has_buffers(page)) {
 		create_empty_buffers(page, blocksize, 0);
+		if (!page_has_buffers(page))	/* This can't happen */
+			return -ENOMEM;
+	}
 	bh = head = page_buffers(page);
-	if (!bh)
-		return -ENOMEM;
 
 	blocks = PAGE_CACHE_SIZE >> blocksize_bits;
 	iblock = page->index << (PAGE_CACHE_SHIFT - blocksize_bits);
@@ -138,10 +139,12 @@ static int ntfs_file_read_block(struct p
 	/* Loop through all the buffers in the page. */
 	nr = i = 0;
 	do {
+		BUG_ON(buffer_async_read(bh));
 		if (unlikely(buffer_uptodate(bh)))
 			continue;
 		if (unlikely(buffer_mapped(bh))) {
-			arr[nr++] = bh;
+			set_buffer_async_read(bh);
+			nr++;
 			continue;
 		}
 		bh->b_bdev = vol->sb->s_bdev;
@@ -167,7 +170,8 @@ retry_remap:
 				set_buffer_mapped(bh);
 				/* Only read initialized data blocks. */
 				if (iblock < zblock) {
-					arr[nr++] = bh;
+					set_buffer_async_read(bh);
+					nr++;
 					continue;
 				}
 				/* Fully non-initialized data block, zero it. */
@@ -208,15 +212,18 @@ handle_zblock:
 	/* Check we have at least one buffer ready for i/o. */
 	if (nr) {
 		/* Lock the buffers. */
-		for (i = 0; i < nr; i++) {
-			struct buffer_head *tbh = arr[i];
-			lock_buffer(tbh);
-			tbh->b_end_io = end_buffer_read_file_async;
-			set_buffer_async_read(tbh);
-		}
+		do {
+			if (buffer_async_read(bh)) {
+				lock_buffer(bh);
+				bh->b_end_io = end_buffer_read_file_async;
+			}
+		} while ((bh = bh->b_this_page) != head);
+
 		/* Finally, start i/o on the buffers. */
-		for (i = 0; i < nr; i++)
-			submit_bh(READ, arr[i]);
+		do {
+			if (buffer_async_read(bh))
+				submit_bh(READ, bh);
+		} while ((bh = bh->b_this_page) != head);
 		return 0;
 	}
 	/* No i/o was scheduled on any of the buffers. */
@@ -404,7 +411,7 @@ static int ntfs_mftbmp_readpage(ntfs_vol
 {
 	VCN vcn;
 	LCN lcn;
-	struct buffer_head *bh, *head, *arr[MAX_BUF_PER_PAGE];
+	struct buffer_head *bh, *head;
 	sector_t iblock, lblock, zblock;
 	unsigned int blocksize, blocks, vcn_ofs;
 	int nr, i;
@@ -416,11 +423,12 @@ static int ntfs_mftbmp_readpage(ntfs_vol
 	blocksize = vol->sb->s_blocksize;
 	blocksize_bits = vol->sb->s_blocksize_bits;
 
-	if (!page_has_buffers(page))
+	if (!page_has_buffers(page)) {
 		create_empty_buffers(page, blocksize, 0);
+		if (!page_has_buffers(page))	/* This can't happen */
+			return -ENOMEM;
+	}
 	bh = head = page_buffers(page);
-	if (!bh)
-		return -ENOMEM;
 
 	blocks = PAGE_CACHE_SIZE >> blocksize_bits;
 	iblock = page->index << (PAGE_CACHE_SHIFT - blocksize_bits);
@@ -431,10 +439,12 @@ static int ntfs_mftbmp_readpage(ntfs_vol
 	/* Loop through all the buffers in the page. */
 	nr = i = 0;
 	do {
+		BUG_ON(buffer_async_read(bh));
 		if (unlikely(buffer_uptodate(bh)))
 			continue;
 		if (unlikely(buffer_mapped(bh))) {
-			arr[nr++] = bh;
+			set_buffer_async_read(bh);
+			nr++;
 			continue;
 		}
 		bh->b_bdev = vol->sb->s_bdev;
@@ -457,7 +467,8 @@ static int ntfs_mftbmp_readpage(ntfs_vol
 				set_buffer_mapped(bh);
 				/* Only read initialized data blocks. */
 				if (iblock < zblock) {
-					arr[nr++] = bh;
+					set_buffer_async_read(bh);
+					nr++;
 					continue;
 				}
 				/* Fully non-initialized data block, zero it. */
@@ -491,15 +502,18 @@ handle_zblock:
 	/* Check we have at least one buffer ready for i/o. */
 	if (nr) {
 		/* Lock the buffers. */
-		for (i = 0; i < nr; i++) {
-			struct buffer_head *tbh = arr[i];
-			lock_buffer(tbh);
-			tbh->b_end_io = end_buffer_read_mftbmp_async;
-			set_buffer_async_read(tbh);
-		}
+		do {
+			if (buffer_async_read(bh)) {
+				lock_buffer(bh);
+				bh->b_end_io = end_buffer_read_mftbmp_async;
+			}
+		} while ((bh = bh->b_this_page) != head);
+
 		/* Finally, start i/o on the buffers. */
-		for (i = 0; i < nr; i++)
-			submit_bh(READ, arr[i]);
+		do {
+			if (buffer_async_read(bh))
+				submit_bh(READ, bh);
+		} while ((bh = bh->b_this_page) != head);
 		return 0;
 	}
 	/* No i/o was scheduled on any of the buffers. */
@@ -643,7 +657,7 @@ int ntfs_mst_readpage(struct file *dir, 
 	LCN lcn;
 	ntfs_inode *ni;
 	ntfs_volume *vol;
-	struct buffer_head *bh, *head, *arr[MAX_BUF_PER_PAGE];
+	struct buffer_head *bh, *head;
 	sector_t iblock, lblock, zblock;
 	unsigned int blocksize, blocks, vcn_ofs;
 	int i, nr;
@@ -658,11 +672,12 @@ int ntfs_mst_readpage(struct file *dir, 
 	blocksize_bits = VFS_I(ni)->i_blkbits;
 	blocksize = 1 << blocksize_bits;
 
-	if (!page_has_buffers(page))
+	if (!page_has_buffers(page)) {
 		create_empty_buffers(page, blocksize, 0);
+		if (!page_has_buffers(page))	/* This can't happen */
+			return -ENOMEM;
+	}
 	bh = head = page_buffers(page);
-	if (!bh)
-		return -ENOMEM;
 
 	blocks = PAGE_CACHE_SIZE >> blocksize_bits;
 	iblock = page->index << (PAGE_CACHE_SHIFT - blocksize_bits);
@@ -678,10 +693,12 @@ int ntfs_mst_readpage(struct file *dir, 
 	/* Loop through all the buffers in the page. */
 	nr = i = 0;
 	do {
+		BUG_ON(buffer_async_read(bh));
 		if (unlikely(buffer_uptodate(bh)))
 			continue;
 		if (unlikely(buffer_mapped(bh))) {
-			arr[nr++] = bh;
+			set_buffer_async_read(bh);
+			nr++;
 			continue;
 		}
 		bh->b_bdev = vol->sb->s_bdev;
@@ -707,7 +724,8 @@ retry_remap:
 				set_buffer_mapped(bh);
 				/* Only read initialized data blocks. */
 				if (iblock < zblock) {
-					arr[nr++] = bh;
+					set_buffer_async_read(bh);
+					nr++;
 					continue;
 				}
 				/* Fully non-initialized data block, zero it. */
@@ -748,15 +766,18 @@ handle_zblock:
 	/* Check we have at least one buffer ready for i/o. */
 	if (nr) {
 		/* Lock the buffers. */
-		for (i = 0; i < nr; i++) {
-			struct buffer_head *tbh = arr[i];
-			lock_buffer(tbh);
-			tbh->b_end_io = end_buffer_read_mst_async;
-			set_buffer_async_read(tbh);
-		}
+		do {
+			if (buffer_async_read(bh)) {
+				lock_buffer(bh);
+				bh->b_end_io = end_buffer_read_mst_async;
+			}
+		} while ((bh = bh->b_this_page) != head);
+
 		/* Finally, start i/o on the buffers. */
-		for (i = 0; i < nr; i++)
-			submit_bh(READ, arr[i]);
+		do {
+			if (buffer_async_read(bh))
+				submit_bh(READ, bh);
+		} while ((bh = bh->b_this_page) != head);
 		return 0;
 	}
 	/* No i/o was scheduled on any of the buffers. */

-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
