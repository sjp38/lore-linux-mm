Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 82AC36B022B
	for <linux-mm@kvack.org>; Fri,  7 May 2010 13:42:25 -0400 (EDT)
Date: Fri, 7 May 2010 13:42:19 -0400
From: Josef Bacik <josef@redhat.com>
Subject: [PATCH 5/5] Btrfs: add basic DIO read support V2
Message-ID: <20100507174219.GF3360@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: hch@infradead.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

V1->V2
-Use __blockdev_direct_IO instead of helper
-Use KM_IRQ0 for kmap instead of KM_USER0

This provides basic DIO support for reads only.  It does not do any of the work
to recover from mismatching checksums, that will come later.  A few design
changes have been made from Jim's code (sorry Jim!)

1) Use the generic direct-io code.  Jim originally re-wrote all the generic DIO
code in order to account for all of BTRFS's oddities, but thanks to that work it
seems like the best bet is to just ignore compression and such and just opt to
fallback on buffered IO.

2) Fallback on buffered IO for compressed or inline extents.  Jim's code did
it's own buffering to make dio with compressed extents work.  Now we just
fallback onto normal buffered IO.

3) Lock the entire range during DIO.  I originally had it so we would lock the
extents as get_block was called, and then unlock them as the endio function was
called, which worked great, but if we ever had an error in the submit_io hook,
we could have locked an extent that would never be submitted for IO, so we
wouldn't be able to unlock it, so this solution fixed that problem and made it a
bit cleaner.

I've tested this with fsx and everything works great.  This patch depends on my
dio and filemap.c patches to work.  Thanks,

Signed-off-by: Josef Bacik <josef@redhat.com>
---
 fs/btrfs/ctree.h     |    2 +
 fs/btrfs/file-item.c |   25 +++++-
 fs/btrfs/inode.c     |  205 +++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 227 insertions(+), 5 deletions(-)

diff --git a/fs/btrfs/ctree.h b/fs/btrfs/ctree.h
index 746a724..36994e8 100644
--- a/fs/btrfs/ctree.h
+++ b/fs/btrfs/ctree.h
@@ -2257,6 +2257,8 @@ int btrfs_del_csums(struct btrfs_trans_handle *trans,
 		    struct btrfs_root *root, u64 bytenr, u64 len);
 int btrfs_lookup_bio_sums(struct btrfs_root *root, struct inode *inode,
 			  struct bio *bio, u32 *dst);
+int btrfs_lookup_bio_sums_dio(struct btrfs_root *root, struct inode *inode,
+			      struct bio *bio, u64 logical_offset, u32 *dst);
 int btrfs_insert_file_extent(struct btrfs_trans_handle *trans,
 			     struct btrfs_root *root,
 			     u64 objectid, u64 pos,
diff --git a/fs/btrfs/file-item.c b/fs/btrfs/file-item.c
index 54a2550..34ea718 100644
--- a/fs/btrfs/file-item.c
+++ b/fs/btrfs/file-item.c
@@ -149,13 +149,14 @@ int btrfs_lookup_file_extent(struct btrfs_trans_handle *trans,
 }
 
 
-int btrfs_lookup_bio_sums(struct btrfs_root *root, struct inode *inode,
-			  struct bio *bio, u32 *dst)
+static int __btrfs_lookup_bio_sums(struct btrfs_root *root,
+				   struct inode *inode, struct bio *bio,
+				   u64 logical_offset, u32 *dst, int dio)
 {
 	u32 sum;
 	struct bio_vec *bvec = bio->bi_io_vec;
 	int bio_index = 0;
-	u64 offset;
+	u64 offset = 0;
 	u64 item_start_offset = 0;
 	u64 item_last_offset = 0;
 	u64 disk_bytenr;
@@ -174,8 +175,11 @@ int btrfs_lookup_bio_sums(struct btrfs_root *root, struct inode *inode,
 	WARN_ON(bio->bi_vcnt <= 0);
 
 	disk_bytenr = (u64)bio->bi_sector << 9;
+	if (dio)
+		offset = logical_offset;
 	while (bio_index < bio->bi_vcnt) {
-		offset = page_offset(bvec->bv_page) + bvec->bv_offset;
+		if (!dio)
+			offset = page_offset(bvec->bv_page) + bvec->bv_offset;
 		ret = btrfs_find_ordered_sum(inode, offset, disk_bytenr, &sum);
 		if (ret == 0)
 			goto found;
@@ -238,6 +242,7 @@ found:
 		else
 			set_state_private(io_tree, offset, sum);
 		disk_bytenr += bvec->bv_len;
+		offset += bvec->bv_len;
 		bio_index++;
 		bvec++;
 	}
@@ -245,6 +250,18 @@ found:
 	return 0;
 }
 
+int btrfs_lookup_bio_sums(struct btrfs_root *root, struct inode *inode,
+			  struct bio *bio, u32 *dst)
+{
+	return __btrfs_lookup_bio_sums(root, inode, bio, 0, dst, 0);
+}
+
+int btrfs_lookup_bio_sums_dio(struct btrfs_root *root, struct inode *inode,
+			      struct bio *bio, u64 offset, u32 *dst)
+{
+	return __btrfs_lookup_bio_sums(root, inode, bio, offset, dst, 1);
+}
+
 int btrfs_lookup_csums_range(struct btrfs_root *root, u64 start, u64 end,
 			     struct list_head *list)
 {
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 2bfdc64..ebd6cb5 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -4875,11 +4875,214 @@ out:
 	return em;
 }
 
+static int btrfs_get_blocks_direct(struct inode *inode, sector_t iblock,
+				   struct buffer_head *bh_result, int create)
+{
+	struct extent_map *em;
+	u64 start = iblock << inode->i_blkbits;
+	u64 len = bh_result->b_size;
+
+
+	em = btrfs_get_extent(inode, NULL, 0, start, len, 0);
+	if (IS_ERR(em))
+		return PTR_ERR(em);
+
+	/*
+	 * Ok for INLINE and COMPRESSED extents we need to fallback on buffered
+	 * io.  INLINE is special, and we could probably kludge it in here, but
+	 * it's still buffered so for safety lets just fall back to the generic
+	 * buffered path.
+	 *
+	 * For COMPRESSED we _have_ to read the entire extent in so we can
+	 * decompress it, so there will be buffering required no matter what we
+	 * do, so go ahead and fallback to buffered.
+	 *
+	 * We return -ENOTBLK because thats what makes DIO go ahead and go back
+	 * to buffered IO.  Don't blame me, this is the price we pay for using
+	 * the generic code.
+	 */
+	if (test_bit(EXTENT_FLAG_COMPRESSED, &em->flags) ||
+	    em->block_start == EXTENT_MAP_INLINE) {
+		free_extent_map(em);
+		return -ENOTBLK;
+	}
+
+	/* Just a good old fashioned hole, return */
+	if (em->block_start == EXTENT_MAP_HOLE) {
+		free_extent_map(em);
+		return 0;
+	}
+
+	/*
+	 * We use the relative offset in the file so that our own submit bio
+	 * routine will do the mapping to the real blocks.
+	 */
+	bh_result->b_blocknr = start >> inode->i_blkbits;
+	bh_result->b_size = em->len - (start - em->start);
+	bh_result->b_bdev = em->bdev;
+	set_buffer_mapped(bh_result);
+	set_buffer_boundary(bh_result);
+
+	free_extent_map(em);
+
+	return 0;
+}
+
+struct btrfs_dio_private {
+	struct inode *inode;
+	u64 logical_offset;
+	u32 *csums;
+	void *private;
+};
+
+static void btrfs_endio_direct(struct bio *bio, int err)
+{
+	struct bio_vec *bvec_end = bio->bi_io_vec + bio->bi_vcnt - 1;
+	struct bio_vec *bvec = bio->bi_io_vec;
+	struct btrfs_dio_private *dip = bio->bi_private;
+	struct inode *inode = dip->inode;
+	struct btrfs_root *root = BTRFS_I(inode)->root;
+	u64 start;
+	u32 *private = dip->csums;
+
+	start = dip->logical_offset;
+	do {
+		if (!(BTRFS_I(inode)->flags & BTRFS_INODE_NODATASUM)) {
+			struct page *page = bvec->bv_page;
+			char *kaddr;
+			u32 csum = ~(u32)0;
+
+			kaddr = kmap_atomic(page, KM_IRQ0);
+			csum = btrfs_csum_data(root, kaddr + bvec->bv_offset,
+					       csum, bvec->bv_len);
+			btrfs_csum_final(csum, (char *)&csum);
+			kunmap_atomic(kaddr, KM_IRQ0);
+
+			if (csum != *private) {
+				printk(KERN_ERR "btrfs csum failed ino %lu off"
+				      " %llu csum %u private %u\n",
+				      inode->i_ino, (unsigned long long)start,
+				      csum, *private);
+				err = -EIO;
+			}
+		}
+
+		start += bvec->bv_len;
+		private++;
+		bvec++;
+	} while (bvec <= bvec_end);
+
+	bio->bi_private = dip->private;
+
+	kfree(dip->csums);
+	kfree(dip);
+	dio_end_io(bio, err);
+}
+
+static void btrfs_submit_direct(int rw, struct bio *bio, struct inode *inode)
+{
+	struct btrfs_root *root = BTRFS_I(inode)->root;
+	struct extent_map *em;
+	struct btrfs_dio_private *dip;
+	struct bio_vec *bvec = bio->bi_io_vec;
+	u64 start;
+	int skip_sum;
+	int ret = 0;
+
+	dip = kmalloc(sizeof(*dip), GFP_NOFS);
+	if (!dip) {
+		bio_endio(bio, -ENOMEM);
+		return;
+	}
+
+	dip->csums = kmalloc(sizeof(u32) * bio->bi_vcnt, GFP_NOFS);
+	if (!dip->csums) {
+		kfree(dip);
+		bio_endio(bio, -ENOMEM);
+	}
+
+	dip->private = bio->bi_private;
+	dip->inode = inode;
+	dip->logical_offset = (u64)bio->bi_sector << 9;
+
+	start = dip->logical_offset;
+	em = btrfs_get_extent(inode, NULL, 0, start, bvec->bv_len, 0);
+	if (IS_ERR(em)) {
+		ret = PTR_ERR(em);
+		goto out_err;
+	}
+
+	if (em->block_start >= EXTENT_MAP_LAST_BYTE) {
+		printk(KERN_ERR "dio to inode resulted in a bad extent "
+		       "(%llu) %llu\n", (unsigned long long)em->block_start, start);
+		ret = -EIO;
+		free_extent_map(em);
+		goto out_err;
+	}
+
+	bio->bi_sector =
+		(em->block_start + (dip->logical_offset - em->start)) >> 9;
+	bio->bi_private = dip;
+
+	free_extent_map(em);
+	skip_sum = BTRFS_I(inode)->flags & BTRFS_INODE_NODATASUM;
+
+	bio->bi_end_io = btrfs_endio_direct;
+
+	ret = btrfs_bio_wq_end_io(root->fs_info, bio, 0);
+	if (ret)
+		goto out_err;
+
+	if (!skip_sum)
+		btrfs_lookup_bio_sums_dio(root, inode, bio,
+					  dip->logical_offset, dip->csums);
+
+	ret = btrfs_map_bio(root, rw, bio, 0, 0);
+	if (ret)
+		goto out_err;
+	return;
+out_err:
+	kfree(dip->csums);
+	kfree(dip);
+	bio_endio(bio, ret);
+}
+
 static ssize_t btrfs_direct_IO(int rw, struct kiocb *iocb,
 			const struct iovec *iov, loff_t offset,
 			unsigned long nr_segs)
 {
-	return -EINVAL;
+	struct file *file = iocb->ki_filp;
+	struct inode *inode = file->f_mapping->host;
+	struct extent_state *cached_state = NULL;
+	struct btrfs_ordered_extent *ordered;
+	ssize_t ret;
+
+	if (rw == WRITE)
+		return 0;
+
+	while (1) {
+		lock_extent_bits(&BTRFS_I(inode)->io_tree, offset,
+				 offset + iov_length(iov, nr_segs) - 1, 0,
+				 &cached_state, GFP_NOFS);
+		ordered = btrfs_lookup_ordered_extent(inode, offset);
+		if (!ordered)
+			break;
+		unlock_extent_cached(&BTRFS_I(inode)->io_tree, offset,
+				     offset + iov_length(iov, nr_segs) - 1,
+				     &cached_state, GFP_NOFS);
+		btrfs_start_ordered_extent(inode, ordered, 1);
+		btrfs_put_ordered_extent(ordered);
+		cond_resched();
+	}
+
+	ret = __blockdev_direct_IO(rw, iocb, inode, NULL, iov, offset, nr_segs,
+				   btrfs_get_blocks_direct, NULL,
+				   btrfs_submit_direct, 0);
+
+	unlock_extent_cached(&BTRFS_I(inode)->io_tree, offset,
+			     offset + iov_length(iov, nr_segs) - 1,
+			     &cached_state, GFP_NOFS);
+	return ret;
 }
 
 static int btrfs_fiemap(struct inode *inode, struct fiemap_extent_info *fieinfo,
-- 
1.6.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
