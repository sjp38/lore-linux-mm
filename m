Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B25CD6B0055
	for <linux-mm@kvack.org>; Sat, 28 Feb 2009 06:45:41 -0500 (EST)
Date: Sat, 28 Feb 2009 12:45:35 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch 5/5] xfs: fsblock conversion
Message-ID: <20090228114535.GI28496@wotan.suse.de>
References: <20090228112858.GD28496@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090228112858.GD28496@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>
List-ID: <linux-mm.kvack.org>



---
 fs/xfs/linux-2.6/xfs_aops.c  |  463 ++++++++++++++++++++++++-------------------
 fs/xfs/linux-2.6/xfs_aops.h  |   10 
 fs/xfs/linux-2.6/xfs_buf.c   |    1 
 fs/xfs/linux-2.6/xfs_buf.h   |    2 
 fs/xfs/linux-2.6/xfs_file.c  |    2 
 fs/xfs/linux-2.6/xfs_iops.c  |    3 
 fs/xfs/linux-2.6/xfs_super.c |    5 
 7 files changed, 276 insertions(+), 210 deletions(-)

Index: linux-2.6/fs/xfs/linux-2.6/xfs_aops.c
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/xfs_aops.c
+++ linux-2.6/fs/xfs/linux-2.6/xfs_aops.c
@@ -77,25 +77,38 @@ xfs_ioend_wake(
 }
 
 STATIC void
+__xfs_count_block_state(
+	struct fsblock		*fsb,
+	int			*delalloc,
+	int			*unmapped,
+	int			*unwritten)
+{
+	if ((fsb->flags & (BL_uptodate|BL_mapped)) == BL_uptodate)
+		(*unmapped) = 1;
+	else if (fsb->flags & BL_unwritten)
+		(*unwritten) = 1;
+	else if (fsb->flags & BL_delay)
+		(*delalloc) = 1;
+}
+STATIC void
 xfs_count_page_state(
 	struct page		*page,
 	int			*delalloc,
 	int			*unmapped,
 	int			*unwritten)
 {
-	struct buffer_head	*bh, *head;
+	struct fsblock	*fsb;
 
 	*delalloc = *unmapped = *unwritten = 0;
 
-	bh = head = page_buffers(page);
-	do {
-		if (buffer_uptodate(bh) && !buffer_mapped(bh))
-			(*unmapped) = 1;
-		else if (buffer_unwritten(bh))
-			(*unwritten) = 1;
-		else if (buffer_delay(bh))
-			(*delalloc) = 1;
-	} while ((bh = bh->b_this_page) != head);
+	fsb = page_blocks(page);
+	if (fsblock_midpage(fsb)) {
+		__xfs_count_block_state(fsb, delalloc, unmapped, unwritten);
+	} else {
+		struct fsblock *b;
+		for_each_block(fsb, b)
+			__xfs_count_block_state(b, delalloc, unmapped, unwritten);
+	}
 }
 
 #if defined(XFS_RW_TRACE)
@@ -111,7 +124,7 @@ xfs_page_trace(
 	loff_t		offset = page_offset(page);
 	int		delalloc = -1, unmapped = -1, unwritten = -1;
 
-	if (page_has_buffers(page))
+	if (PageBlocks(page))
 		xfs_count_page_state(page, &delalloc, &unmapped, &unwritten);
 
 	ip = XFS_I(inode);
@@ -171,7 +184,7 @@ xfs_finish_ioend(
 
 /*
  * We're now finished for good with this ioend structure.
- * Update the page state via the associated buffer_heads,
+ * Update the page state via the associated fsblocks,
  * release holds on the inode and bio, and finally free
  * up memory.  Do not use the ioend after this.
  */
@@ -179,12 +192,14 @@ STATIC void
 xfs_destroy_ioend(
 	xfs_ioend_t		*ioend)
 {
-	struct buffer_head	*bh, *next;
+	struct fsblock	*fsb, *next;
 	struct xfs_inode	*ip = XFS_I(ioend->io_inode);
 
-	for (bh = ioend->io_buffer_head; bh; bh = next) {
-		next = bh->b_private;
-		bh->b_end_io(bh, !ioend->io_error);
+	for (fsb = ioend->io_fsb_head; fsb; fsb = next) {
+		next = fsb->private;
+		fsb->private = NULL;
+		unlock_block(fsb);
+		fsblock_end_io(fsb, !ioend->io_error);
 	}
 
 	/*
@@ -334,8 +349,8 @@ xfs_alloc_ioend(
 	ioend->io_list = NULL;
 	ioend->io_type = type;
 	ioend->io_inode = inode;
-	ioend->io_buffer_head = NULL;
-	ioend->io_buffer_tail = NULL;
+	ioend->io_fsb_head = NULL;
+	ioend->io_fsb_tail = NULL;
 	atomic_inc(&XFS_I(ioend->io_inode)->i_iocount);
 	ioend->io_offset = 0;
 	ioend->io_size = 0;
@@ -412,10 +427,11 @@ xfs_submit_ioend_bio(
 
 STATIC struct bio *
 xfs_alloc_ioend_bio(
-	struct buffer_head	*bh)
+	struct fsblock	*fsb)
 {
 	struct bio		*bio;
-	int			nvecs = bio_get_nr_vecs(bh->b_bdev);
+	struct block_device	*bdev = fsb->page->mapping->host->i_sb->s_bdev;
+	int			nvecs = bio_get_nr_vecs(bdev);
 
 	do {
 		bio = bio_alloc(GFP_NOIO, nvecs);
@@ -423,24 +439,34 @@ xfs_alloc_ioend_bio(
 	} while (!bio);
 
 	ASSERT(bio->bi_private == NULL);
-	bio->bi_sector = bh->b_blocknr * (bh->b_size >> 9);
-	bio->bi_bdev = bh->b_bdev;
+	bio->bi_sector = fsb->block_nr << (fsblock_bits(fsb) - 9);
+	bio->bi_bdev = bdev;
 	bio_get(bio);
 	return bio;
 }
 
 STATIC void
 xfs_start_buffer_writeback(
-	struct buffer_head	*bh)
+	struct fsblock	*fsb)
 {
-	ASSERT(buffer_mapped(bh));
-	ASSERT(buffer_locked(bh));
-	ASSERT(!buffer_delay(bh));
-	ASSERT(!buffer_unwritten(bh));
-
-	mark_buffer_async_write(bh);
-	set_buffer_uptodate(bh);
-	clear_buffer_dirty(bh);
+	ASSERT(fsb->flags & BL_mapped);
+	ASSERT(fsb->flags & BL_locked);
+	ASSERT(!(fsb->flags & BL_delay));
+	ASSERT(!(fsb->flags & BL_unwritten));
+	ASSERT(!(fsb->flags & BL_uptodate));
+
+	spin_lock_block_irq(fsb);
+	fsb->count++;
+	fsb->flags |= BL_writeback;
+	clear_block_dirty(fsb);
+	/*
+	 * XXX: really want to keep block dirty bit in sync with page dirty
+	 * bit, (ie. clear_block_dirty_check_page(fsb, fsb->page, 1);), but
+	 * they get manipulated in different places (xfs_start_page_writeback)
+	 *
+	 * This causes buffers to be discarded when the page dirty bit is set.
+	 */
+	spin_unlock_block_irq(fsb);
 }
 
 STATIC void
@@ -458,11 +484,31 @@ xfs_start_page_writeback(
 	/* If no buffers on the page are to be written, finish it here */
 	if (!buffers)
 		end_page_writeback(page);
+	else
+		page_cache_get(page);
 }
 
-static inline int bio_add_buffer(struct bio *bio, struct buffer_head *bh)
+static inline int bio_add_buffer(struct bio *bio, struct fsblock *fsb)
 {
-	return bio_add_page(bio, bh->b_page, bh->b_size, bh_offset(bh));
+	unsigned int size = fsblock_size(fsb);
+	unsigned int offset = block_page_offset(fsb, size);
+	return bio_add_page(bio, fsb->page, size, offset);
+}
+
+STATIC void
+xfs_start_ioend(
+	xfs_ioend_t		*ioend)
+{
+	xfs_ioend_t		*head = ioend;
+	xfs_ioend_t		*next;
+	struct fsblock		*fsb;
+
+	do {
+		next = ioend->io_list;
+		for (fsb = ioend->io_fsb_head; fsb; fsb = fsb->private) {
+			xfs_start_buffer_writeback(fsb);
+		}
+	} while ((ioend = next) != NULL);
 }
 
 /*
@@ -471,16 +517,16 @@ static inline int bio_add_buffer(struct
  *
  * Because we may have multiple ioends spanning a page, we need to start
  * writeback on all the buffers before we submit them for I/O. If we mark the
- * buffers as we got, then we can end up with a page that only has buffers
+ * buffers as we got, then we can end up with a page that only has fsblocks
  * marked async write and I/O complete on can occur before we mark the other
- * buffers async write.
+ * fsblocks async write.
  *
  * The end result of this is that we trip a bug in end_page_writeback() because
- * we call it twice for the one page as the code in end_buffer_async_write()
- * assumes that all buffers on the page are started at the same time.
+ * we call it twice for the one page as the code in fsblock_end_io()
+ * assumes that all fsblocks on the page are started at the same time.
  *
  * The fix is two passes across the ioend list - one to start writeback on the
- * buffer_heads, and then submit them for I/O on the second pass.
+ * fsblocks, and then submit them for I/O on the second pass.
  */
 STATIC void
 xfs_submit_ioend(
@@ -488,40 +534,30 @@ xfs_submit_ioend(
 {
 	xfs_ioend_t		*head = ioend;
 	xfs_ioend_t		*next;
-	struct buffer_head	*bh;
+	struct fsblock		*fsb;
 	struct bio		*bio;
 	sector_t		lastblock = 0;
 
-	/* Pass 1 - start writeback */
-	do {
-		next = ioend->io_list;
-		for (bh = ioend->io_buffer_head; bh; bh = bh->b_private) {
-			xfs_start_buffer_writeback(bh);
-		}
-	} while ((ioend = next) != NULL);
-
-	/* Pass 2 - submit I/O */
-	ioend = head;
 	do {
 		next = ioend->io_list;
 		bio = NULL;
 
-		for (bh = ioend->io_buffer_head; bh; bh = bh->b_private) {
+		for (fsb = ioend->io_fsb_head; fsb; fsb = fsb->private) {
 
 			if (!bio) {
  retry:
-				bio = xfs_alloc_ioend_bio(bh);
-			} else if (bh->b_blocknr != lastblock + 1) {
+				bio = xfs_alloc_ioend_bio(fsb);
+			} else if (fsb->block_nr != lastblock + 1) {
 				xfs_submit_ioend_bio(ioend, bio);
 				goto retry;
 			}
 
-			if (bio_add_buffer(bio, bh) != bh->b_size) {
+			if (bio_add_buffer(bio, fsb) != fsblock_size(fsb)) {
 				xfs_submit_ioend_bio(ioend, bio);
 				goto retry;
 			}
 
-			lastblock = bh->b_blocknr;
+			lastblock = fsb->block_nr;
 		}
 		if (bio)
 			xfs_submit_ioend_bio(ioend, bio);
@@ -530,7 +566,7 @@ xfs_submit_ioend(
 }
 
 /*
- * Cancel submission of all buffer_heads so far in this endio.
+ * Cancel submission of all fsblocks so far in this endio.
  * Toss the endio too.  Only ever called for the initial page
  * in a writepage request, so only ever one page.
  */
@@ -539,16 +575,19 @@ xfs_cancel_ioend(
 	xfs_ioend_t		*ioend)
 {
 	xfs_ioend_t		*next;
-	struct buffer_head	*bh, *next_bh;
+	struct fsblock		*fsb, *next_fsb;
 
 	do {
 		next = ioend->io_list;
-		bh = ioend->io_buffer_head;
+		fsb = ioend->io_fsb_head;
 		do {
-			next_bh = bh->b_private;
-			clear_buffer_async_write(bh);
-			unlock_buffer(bh);
-		} while ((bh = next_bh) != NULL);
+			next_fsb = fsb->private;
+			spin_lock_block_irq(fsb);
+			fsb->flags &= ~BL_writeback;
+			fsb->count--;
+			spin_unlock_block_irq(fsb);
+			unlock_block(fsb);
+		} while ((fsb = next_fsb) != NULL);
 
 		xfs_ioend_wake(XFS_I(ioend->io_inode));
 		mempool_free(ioend, xfs_ioend_pool);
@@ -557,14 +596,14 @@ xfs_cancel_ioend(
 
 /*
  * Test to see if we've been building up a completion structure for
- * earlier buffers -- if so, we try to append to this ioend if we
+ * earlier fsblocks -- if so, we try to append to this ioend if we
  * can, otherwise we finish off any current ioend and start another.
  * Return true if we've finished the given ioend.
  */
 STATIC void
 xfs_add_to_ioend(
 	struct inode		*inode,
-	struct buffer_head	*bh,
+	struct fsblock		*fsb,
 	xfs_off_t		offset,
 	unsigned int		type,
 	xfs_ioend_t		**result,
@@ -577,23 +616,23 @@ xfs_add_to_ioend(
 
 		ioend = xfs_alloc_ioend(inode, type);
 		ioend->io_offset = offset;
-		ioend->io_buffer_head = bh;
-		ioend->io_buffer_tail = bh;
+		ioend->io_fsb_head = fsb;
+		ioend->io_fsb_tail = fsb;
 		if (previous)
 			previous->io_list = ioend;
 		*result = ioend;
 	} else {
-		ioend->io_buffer_tail->b_private = bh;
-		ioend->io_buffer_tail = bh;
+		ioend->io_fsb_tail->private = fsb;
+		ioend->io_fsb_tail = fsb;
 	}
 
-	bh->b_private = NULL;
-	ioend->io_size += bh->b_size;
+	fsb->private = NULL;
+	ioend->io_size += fsblock_size(fsb);
 }
 
 STATIC void
 xfs_map_buffer(
-	struct buffer_head	*bh,
+	struct fsblock		*fsb,
 	xfs_iomap_t		*mp,
 	xfs_off_t		offset,
 	uint			block_bits)
@@ -607,13 +646,12 @@ xfs_map_buffer(
 
 	ASSERT(bn || (mp->iomap_flags & IOMAP_REALTIME));
 
-	bh->b_blocknr = bn;
-	set_buffer_mapped(bh);
+	map_fsblock(fsb, bn);
 }
 
 STATIC void
 xfs_map_at_offset(
-	struct buffer_head	*bh,
+	struct fsblock		*fsb,
 	loff_t			offset,
 	int			block_bits,
 	xfs_iomap_t		*iomapp)
@@ -621,12 +659,16 @@ xfs_map_at_offset(
 	ASSERT(!(iomapp->iomap_flags & IOMAP_HOLE));
 	ASSERT(!(iomapp->iomap_flags & IOMAP_DELAY));
 
-	lock_buffer(bh);
-	xfs_map_buffer(bh, iomapp, offset, block_bits);
-	bh->b_bdev = iomapp->iomap_target->bt_bdev;
-	set_buffer_mapped(bh);
-	clear_buffer_delay(bh);
-	clear_buffer_unwritten(bh);
+	spin_lock_block_irq(fsb);
+	fsb->count++; // XXX: hack
+	spin_unlock_block_irq(fsb);
+
+	lock_block(fsb);
+	spin_lock_block_irq(fsb);
+	xfs_map_buffer(fsb, iomapp, offset, block_bits);
+	fsb->count--;
+	spin_unlock_block_irq(fsb);
+//XXX?	bh->b_bdev = iomapp->iomap_target->bt_bdev;
 }
 
 /*
@@ -644,19 +686,28 @@ xfs_probe_page(
 		return 0;
 
 	if (page->mapping && PageDirty(page)) {
-		if (page_has_buffers(page)) {
-			struct buffer_head	*bh, *head;
+		if (PageBlocks(page)) {
+			struct fsblock	*fsb;
 
-			bh = head = page_buffers(page);
-			do {
-				if (!buffer_uptodate(bh))
-					break;
-				if (mapped != buffer_mapped(bh))
-					break;
-				ret += bh->b_size;
-				if (ret >= pg_offset)
-					break;
-			} while ((bh = bh->b_this_page) != head);
+			fsb = page_blocks(page);
+			if (fsblock_midpage(fsb)) {
+				if (!(fsb->flags & BL_uptodate))
+					return 0;
+				if (mapped != (fsb->flags & BL_mapped))
+					return 0;
+				return PAGE_CACHE_SIZE;
+			} else {
+				struct fsblock *b;
+				for_each_block(fsb, b) {
+					if (!(b->flags & BL_uptodate))
+						break;
+					if (mapped != (b->flags & BL_mapped))
+						break;
+					ret += fsblock_size(fsb);
+					if (ret >= pg_offset)
+						break;
+				}
+			}
 		} else
 			ret = mapped ? 0 : PAGE_CACHE_SIZE;
 	}
@@ -668,8 +719,8 @@ STATIC size_t
 xfs_probe_cluster(
 	struct inode		*inode,
 	struct page		*startpage,
-	struct buffer_head	*bh,
-	struct buffer_head	*head,
+	struct fsblock		*fsb,
+	struct fsblock		*head,
 	int			mapped)
 {
 	struct pagevec		pvec;
@@ -678,11 +729,12 @@ xfs_probe_cluster(
 	int			done = 0, i;
 
 	/* First sum forwards in this page */
-	do {
-		if (!buffer_uptodate(bh) || (mapped != buffer_mapped(bh)))
+	if (fsblock_midpage(fsb)) {
+		if (!(fsb->flags & BL_uptodate) ||
+				mapped != (fsb->flags & BL_mapped))
 			return total;
-		total += bh->b_size;
-	} while ((bh = bh->b_this_page) != head);
+		total += fsblock_size(fsb);
+	}
 
 	/* if we reached the end of the page, sum forwards in following pages */
 	tlast = i_size_read(inode) >> PAGE_CACHE_SHIFT;
@@ -745,21 +797,21 @@ xfs_is_delayed_page(
 	if (PageWriteback(page))
 		return 0;
 
-	if (page->mapping && page_has_buffers(page)) {
-		struct buffer_head	*bh, *head;
+	if (page->mapping && PageBlocks(page)) {
+		struct fsblock		*fsb;
 		int			acceptable = 0;
 
-		bh = head = page_buffers(page);
-		do {
-			if (buffer_unwritten(bh))
+		fsb = page_blocks(page);
+		if (fsblock_midpage(fsb)) { /* XXX: midpage! */
+			if (fsb->flags & BL_unwritten)
 				acceptable = (type == IOMAP_UNWRITTEN);
-			else if (buffer_delay(bh))
+			else if (fsb->flags & BL_delay)
 				acceptable = (type == IOMAP_DELAY);
-			else if (buffer_dirty(bh) && buffer_mapped(bh))
+			else if ((fsb->flags & (BL_dirty|BL_mapped)) == (BL_dirty|BL_mapped))
 				acceptable = (type == IOMAP_NEW);
 			else
-				break;
-		} while ((bh = bh->b_this_page) != head);
+				return 0;
+		}
 
 		if (acceptable)
 			return 1;
@@ -785,7 +837,7 @@ xfs_convert_page(
 	int			startio,
 	int			all_bh)
 {
-	struct buffer_head	*bh, *head;
+	struct fsblock		*fsb;
 	xfs_off_t		end_offset;
 	unsigned long		p_offset;
 	unsigned int		type;
@@ -805,6 +857,8 @@ xfs_convert_page(
 	if (!xfs_is_delayed_page(page, (*ioendp)->io_type))
 		goto fail_unlock_page;
 
+	clean_page_prepare(page);
+
 	/*
 	 * page_dirty is initially a count of buffers on the page before
 	 * EOF and is decremented as we move each into a cleanable state.
@@ -828,19 +882,20 @@ xfs_convert_page(
 	p_offset = p_offset ? roundup(p_offset, len) : PAGE_CACHE_SIZE;
 	page_dirty = p_offset / len;
 
-	bh = head = page_buffers(page);
+	/* XXX: midpage */
+	fsb = page_blocks(page);
 	do {
 		if (offset >= end_offset)
 			break;
-		if (!buffer_uptodate(bh))
+		if (!(fsb->flags & BL_uptodate))
 			uptodate = 0;
-		if (!(PageUptodate(page) || buffer_uptodate(bh))) {
+		if (!(PageUptodate(page) || (fsb->flags & BL_uptodate))) {
 			done = 1;
 			continue;
 		}
 
-		if (buffer_unwritten(bh) || buffer_delay(bh)) {
-			if (buffer_unwritten(bh))
+		if (fsb->flags & (BL_unwritten|BL_delay)) {
+			if (fsb->flags & BL_unwritten)
 				type = IOMAP_UNWRITTEN;
 			else
 				type = IOMAP_DELAY;
@@ -853,22 +908,21 @@ xfs_convert_page(
 			ASSERT(!(mp->iomap_flags & IOMAP_HOLE));
 			ASSERT(!(mp->iomap_flags & IOMAP_DELAY));
 
-			xfs_map_at_offset(bh, offset, bbits, mp);
+			xfs_map_at_offset(fsb, offset, bbits, mp);
 			if (startio) {
-				xfs_add_to_ioend(inode, bh, offset,
+				xfs_add_to_ioend(inode, fsb, offset,
 						type, ioendp, done);
 			} else {
-				set_buffer_dirty(bh);
-				unlock_buffer(bh);
-				mark_buffer_dirty(bh);
+				mark_mblock_dirty(fsb);
+				unlock_block(fsb);
 			}
 			page_dirty--;
 			count++;
 		} else {
 			type = IOMAP_NEW;
-			if (buffer_mapped(bh) && all_bh && startio) {
-				lock_buffer(bh);
-				xfs_add_to_ioend(inode, bh, offset,
+			if (fsb->flags & BL_mapped && all_bh && startio) {
+				lock_block(fsb);
+				xfs_add_to_ioend(inode, fsb, offset,
 						type, ioendp, done);
 				count++;
 				page_dirty--;
@@ -876,9 +930,9 @@ xfs_convert_page(
 				done = 1;
 			}
 		}
-	} while (offset += len, (bh = bh->b_this_page) != head);
+	} while (offset += len, 1);
 
-	if (uptodate && bh == head)
+	if (uptodate && 1) // fsb == head)
 		SetPageUptodate(page);
 
 	if (startio) {
@@ -968,7 +1022,7 @@ xfs_page_state_convert(
 	int		startio,
 	int		unmapped) /* also implies page uptodate */
 {
-	struct buffer_head	*bh, *head;
+	struct fsblock		*fsb;
 	xfs_iomap_t		iomap;
 	xfs_ioend_t		*ioend = NULL, *iohead = NULL;
 	loff_t			offset;
@@ -1000,6 +1054,8 @@ xfs_page_state_convert(
 		}
 	}
 
+	clean_page_prepare(page);
+
 	/*
 	 * page_dirty is initially a count of buffers on the page before
 	 * EOF and is decremented as we move each into a cleanable state.
@@ -1021,7 +1077,7 @@ xfs_page_state_convert(
 	p_offset = p_offset ? roundup(p_offset, len) : PAGE_CACHE_SIZE;
 	page_dirty = p_offset / len;
 
-	bh = head = page_buffers(page);
+	fsb = page_blocks(page);
 	offset = page_offset(page);
 	flags = BMAPI_READ;
 	type = IOMAP_NEW;
@@ -1031,9 +1087,9 @@ xfs_page_state_convert(
 	do {
 		if (offset >= end_offset)
 			break;
-		if (!buffer_uptodate(bh))
+		if (!(fsb->flags & BL_uptodate))
 			uptodate = 0;
-		if (!(PageUptodate(page) || buffer_uptodate(bh)) && !startio) {
+		if (!(PageUptodate(page) || fsb->flags & BL_uptodate) && !startio) {
 			/*
 			 * the iomap is actually still valid, but the ioend
 			 * isn't.  shouldn't happen too often.
@@ -1055,9 +1111,9 @@ xfs_page_state_convert(
 		 * Third case, an unmapped buffer was found, and we are
 		 * in a path where we need to write the whole page out.
 		 */
-		if (buffer_unwritten(bh) || buffer_delay(bh) ||
-		    ((buffer_uptodate(bh) || PageUptodate(page)) &&
-		     !buffer_mapped(bh) && (unmapped || startio))) {
+		if (fsb->flags & (BL_unwritten|BL_delay) ||
+		    ((fsb->flags & BL_uptodate || PageUptodate(page)) &&
+		     !(fsb->flags & BL_mapped) && (unmapped || startio))) {
 			int new_ioend = 0;
 
 			/*
@@ -1066,10 +1122,10 @@ xfs_page_state_convert(
 			if (flags == BMAPI_READ)
 				iomap_valid = 0;
 
-			if (buffer_unwritten(bh)) {
+			if (fsb->flags & BL_unwritten) {
 				type = IOMAP_UNWRITTEN;
 				flags = BMAPI_WRITE | BMAPI_IGNSTATE;
-			} else if (buffer_delay(bh)) {
+			} else if (fsb->flags & BL_delay) {
 				type = IOMAP_DELAY;
 				flags = BMAPI_ALLOCATE | trylock;
 			} else {
@@ -1089,7 +1145,7 @@ xfs_page_state_convert(
 				new_ioend = 1;
 				if (type == IOMAP_NEW) {
 					size = xfs_probe_cluster(inode,
-							page, bh, head, 0);
+							page, fsb, NULL, 0);
 				} else {
 					size = len;
 				}
@@ -1101,21 +1157,20 @@ xfs_page_state_convert(
 				iomap_valid = xfs_iomap_valid(&iomap, offset);
 			}
 			if (iomap_valid) {
-				xfs_map_at_offset(bh, offset,
+				xfs_map_at_offset(fsb, offset,
 						inode->i_blkbits, &iomap);
 				if (startio) {
-					xfs_add_to_ioend(inode, bh, offset,
+					xfs_add_to_ioend(inode, fsb, offset,
 							type, &ioend,
 							new_ioend);
 				} else {
-					set_buffer_dirty(bh);
-					unlock_buffer(bh);
-					mark_buffer_dirty(bh);
+					mark_mblock_dirty(fsb);
+					unlock_block(fsb);
 				}
 				page_dirty--;
 				count++;
 			}
-		} else if (buffer_uptodate(bh) && startio) {
+		} else if (fsb->flags & BL_uptodate && startio) {
 			/*
 			 * we got here because the buffer is already mapped.
 			 * That means it must already have extents allocated
@@ -1123,8 +1178,8 @@ xfs_page_state_convert(
 			 */
 			if (!iomap_valid || flags != BMAPI_READ) {
 				flags = BMAPI_READ;
-				size = xfs_probe_cluster(inode, page, bh,
-								head, 1);
+				size = xfs_probe_cluster(inode, page, fsb,
+								NULL, 1);
 				err = xfs_map_blocks(inode, offset, size,
 						&iomap, flags);
 				if (err)
@@ -1141,18 +1196,18 @@ xfs_page_state_convert(
 			 * that we are writing into for the first time.
 			 */
 			type = IOMAP_NEW;
-			if (trylock_buffer(bh)) {
-				ASSERT(buffer_mapped(bh));
+			if (trylock_block(fsb)) {
+				ASSERT(fsb->flags & BL_mapped);
 				if (iomap_valid)
 					all_bh = 1;
-				xfs_add_to_ioend(inode, bh, offset, type,
+				xfs_add_to_ioend(inode, fsb, offset, type,
 						&ioend, !iomap_valid);
 				page_dirty--;
 				count++;
 			} else {
 				iomap_valid = 0;
 			}
-		} else if ((buffer_uptodate(bh) || PageUptodate(page)) &&
+		} else if ((fsb->flags & BL_uptodate || PageUptodate(page)) &&
 			   (unmapped || startio)) {
 			iomap_valid = 0;
 		}
@@ -1160,14 +1215,11 @@ xfs_page_state_convert(
 		if (!iohead)
 			iohead = ioend;
 
-	} while (offset += len, ((bh = bh->b_this_page) != head));
+	} while (offset += len, 1);
 
-	if (uptodate && bh == head)
+	if (uptodate && 1) //bh == head)
 		SetPageUptodate(page);
 
-	if (startio)
-		xfs_start_page_writeback(page, 1, count);
-
 	if (ioend && iomap_valid) {
 		offset = (iomap.iomap_offset + iomap.iomap_bsize - 1) >>
 					PAGE_CACHE_SHIFT;
@@ -1177,6 +1229,12 @@ xfs_page_state_convert(
 	}
 
 	if (iohead)
+		xfs_start_ioend(iohead);
+
+	if (startio)
+		xfs_start_page_writeback(page, 1, count);
+
+	if (iohead)
 		xfs_submit_ioend(iohead);
 
 	return page_dirty;
@@ -1192,7 +1250,7 @@ error:
 	 */
 	if (err != -EAGAIN) {
 		if (!unmapped)
-			block_invalidatepage(page, 0);
+			fsblock_invalidate_page(page, 0);
 		ClearPageUptodate(page);
 	}
 	return err;
@@ -1239,7 +1297,7 @@ xfs_vm_writepage(
 	 *  4. There are unwritten buffers on the page
 	 */
 
-	if (!page_has_buffers(page)) {
+	if (!PageBlocks(page)) {
 		unmapped = 1;
 		need_trans = 1;
 	} else {
@@ -1249,6 +1307,7 @@ xfs_vm_writepage(
 		need_trans = delalloc + unmapped + unwritten;
 	}
 
+	clean_page_prepare(page);
 	/*
 	 * If we need a transaction and the process flags say
 	 * we are already in a transaction, or no IO is allowed
@@ -1262,8 +1321,8 @@ xfs_vm_writepage(
 	 * Delay hooking up buffer heads until we have
 	 * made our go/no-go decision.
 	 */
-	if (!page_has_buffers(page))
-		create_empty_buffers(page, 1 << inode->i_blkbits, 0);
+	if (!PageBlocks(page))
+		create_unmapped_blocks(page, GFP_NOIO, 1 << inode->i_blkbits, 0);
 
 	/*
 	 * Convert delayed allocate, unwritten or unmapped space
@@ -1326,12 +1385,12 @@ xfs_vm_releasepage(
 
 	xfs_page_trace(XFS_RELEASEPAGE_ENTER, inode, page, 0);
 
-	if (!page_has_buffers(page))
+	if (!PageBlocks(page))
 		return 0;
 
 	xfs_count_page_state(page, &delalloc, &unmapped, &unwritten);
 	if (!delalloc && !unwritten)
-		goto free_buffers;
+		goto free_blocks;
 
 	if (!(gfp_mask & __GFP_FS))
 		return 0;
@@ -1350,18 +1409,19 @@ xfs_vm_releasepage(
 	 */
 	dirty = xfs_page_state_convert(inode, page, &wbc, 0, 0);
 	if (dirty == 0 && !unwritten)
-		goto free_buffers;
+		goto free_blocks;
+
 	return 0;
 
-free_buffers:
-	return try_to_free_buffers(page);
+free_blocks:
+	return fsblock_releasepage(page, gfp_mask);
 }
 
 STATIC int
 __xfs_get_blocks(
 	struct inode		*inode,
 	sector_t		iblock,
-	struct buffer_head	*bh_result,
+	struct fsblock		*fsb_result,
 	int			create,
 	int			direct,
 	bmapi_flags_t		flags)
@@ -1373,40 +1433,42 @@ __xfs_get_blocks(
 	int			error;
 
 	offset = (xfs_off_t)iblock << inode->i_blkbits;
-	ASSERT(bh_result->b_size >= (1 << inode->i_blkbits));
-	size = bh_result->b_size;
+	ASSERT(fsblock_size(fsb_result) >= (1 << inode->i_blkbits));
+	size = fsblock_size(fsb_result);
 
 	if (!create && direct && offset >= i_size_read(inode))
-		return 0;
+		goto hole;
 
 	error = xfs_iomap(XFS_I(inode), offset, size,
 			     create ? flags : BMAPI_READ, &iomap, &niomap);
 	if (error)
 		return -error;
 	if (niomap == 0)
-		return 0;
+		goto hole;
 
+	spin_lock_block_irq(fsb_result);
 	if (iomap.iomap_bn != IOMAP_DADDR_NULL) {
 		/*
 		 * For unwritten extents do not report a disk address on
 		 * the read case (treat as if we're reading into a hole).
 		 */
 		if (create || !(iomap.iomap_flags & IOMAP_UNWRITTEN)) {
-			xfs_map_buffer(bh_result, &iomap, offset,
+			xfs_map_buffer(fsb_result, &iomap, offset,
 				       inode->i_blkbits);
 		}
 		if (create && (iomap.iomap_flags & IOMAP_UNWRITTEN)) {
 			if (direct)
-				bh_result->b_private = inode;
-			set_buffer_unwritten(bh_result);
+				fsb_result->private = inode;
+			fsb_result->flags |= BL_unwritten;
 		}
-	}
+	} else
+		fsb_result->flags |= BL_hole;
 
 	/*
 	 * If this is a realtime file, data may be on a different device.
 	 * to that pointed to from the buffer_head b_bdev currently.
 	 */
-	bh_result->b_bdev = iomap.iomap_target->bt_bdev;
+//XXX	bh_result->b_bdev = iomap.iomap_target->bt_bdev;
 
 	/*
 	 * If we previously allocated a block out beyond eof and we are now
@@ -1418,50 +1480,59 @@ __xfs_get_blocks(
 	 * correctly zeroed.
 	 */
 	if (create &&
-	    ((!buffer_mapped(bh_result) && !buffer_uptodate(bh_result)) ||
+	    ((!(fsb_result->flags & (BL_mapped|BL_uptodate))) ||
 	     (offset >= i_size_read(inode)) ||
 	     (iomap.iomap_flags & (IOMAP_NEW|IOMAP_UNWRITTEN))))
-		set_buffer_new(bh_result);
+		fsb_result->flags |= BL_new;
 
 	if (iomap.iomap_flags & IOMAP_DELAY) {
 		BUG_ON(direct);
-		if (create) {
-			set_buffer_uptodate(bh_result);
-			set_buffer_mapped(bh_result);
-			set_buffer_delay(bh_result);
-		}
+		if (create)
+			fsb_result->flags |= BL_uptodate|BL_delay; /* XXX: XFS wanted to put BL_mapped here... */
 	}
 
 	if (direct || size > (1 << inode->i_blkbits)) {
 		ASSERT(iomap.iomap_bsize - iomap.iomap_delta > 0);
 		offset = min_t(xfs_off_t,
 				iomap.iomap_bsize - iomap.iomap_delta, size);
-		bh_result->b_size = (ssize_t)min_t(xfs_off_t, LONG_MAX, offset);
+//XXX: could change fsb size bits		fsb_result->size = (ssize_t)min_t(xfs_off_t, LONG_MAX, offset);
 	}
 
+	if (create && fsb_result->flags & BL_hole)
+		fsb_result->flags &= ~BL_hole;
+
+	spin_unlock_block_irq(fsb_result);
+
+	return 0;
+hole:
+	spin_lock_block_irq(fsb_result);
+	fsb_result->flags |= BL_hole;
+	spin_unlock_block_irq(fsb_result);
 	return 0;
 }
 
 int
 xfs_get_blocks(
-	struct inode		*inode,
-	sector_t		iblock,
-	struct buffer_head	*bh_result,
-	int			create)
+	struct address_space	*mapping,
+	struct fsblock		*fsb_result,
+	loff_t			pos,
+	int			mode)
 {
-	return __xfs_get_blocks(inode, iblock,
-				bh_result, create, 0, BMAPI_WRITE);
+	sector_t iblock;
+	iblock = pos >> fsblock_bits(fsb_result);
+	return __xfs_get_blocks(mapping->host, iblock,
+				fsb_result, mode, 0, BMAPI_WRITE);
 }
 
 STATIC int
 xfs_get_blocks_direct(
 	struct inode		*inode,
 	sector_t		iblock,
-	struct buffer_head	*bh_result,
+	struct fsblock		*fsb_result,
 	int			create)
 {
 	return __xfs_get_blocks(inode, iblock,
-				bh_result, create, 1, BMAPI_WRITE|BMAPI_DIRECT);
+				fsb_result, create, 1, BMAPI_WRITE|BMAPI_DIRECT);
 }
 
 STATIC void
@@ -1562,7 +1633,7 @@ xfs_vm_write_begin(
 	void			**fsdata)
 {
 	*pagep = NULL;
-	return block_write_begin(file, mapping, pos, len, flags, pagep, fsdata,
+	return fsblock_write_begin(file, mapping, pos, len, flags, pagep, fsdata,
 								xfs_get_blocks);
 }
 
@@ -1578,7 +1649,7 @@ xfs_vm_bmap(
 	xfs_ilock(ip, XFS_IOLOCK_SHARED);
 	xfs_flush_pages(ip, (xfs_off_t)0, -1, 0, FI_REMAPF);
 	xfs_iunlock(ip, XFS_IOLOCK_SHARED);
-	return generic_block_bmap(mapping, block, xfs_get_blocks);
+	return fsblock_bmap(mapping, block, xfs_get_blocks);
 }
 
 STATIC int
@@ -1586,17 +1657,7 @@ xfs_vm_readpage(
 	struct file		*unused,
 	struct page		*page)
 {
-	return mpage_readpage(page, xfs_get_blocks);
-}
-
-STATIC int
-xfs_vm_readpages(
-	struct file		*unused,
-	struct address_space	*mapping,
-	struct list_head	*pages,
-	unsigned		nr_pages)
-{
-	return mpage_readpages(mapping, pages, nr_pages, xfs_get_blocks);
+	return fsblock_read_page(page, xfs_get_blocks);
 }
 
 STATIC void
@@ -1606,20 +1667,18 @@ xfs_vm_invalidatepage(
 {
 	xfs_page_trace(XFS_INVALIDPAGE_ENTER,
 			page->mapping->host, page, offset);
-	block_invalidatepage(page, offset);
+	fsblock_invalidate_page(page, offset);
 }
 
 const struct address_space_operations xfs_address_space_operations = {
 	.readpage		= xfs_vm_readpage,
-	.readpages		= xfs_vm_readpages,
 	.writepage		= xfs_vm_writepage,
 	.writepages		= xfs_vm_writepages,
-	.sync_page		= block_sync_page,
 	.releasepage		= xfs_vm_releasepage,
 	.invalidatepage		= xfs_vm_invalidatepage,
 	.write_begin		= xfs_vm_write_begin,
-	.write_end		= generic_write_end,
+	.write_end		= fsblock_write_end,
 	.bmap			= xfs_vm_bmap,
 	.direct_IO		= xfs_vm_direct_IO,
-	.migratepage		= buffer_migrate_page,
+	.set_page_dirty		= fsblock_set_page_dirty,
 };
Index: linux-2.6/fs/xfs/linux-2.6/xfs_buf.h
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/xfs_buf.h
+++ linux-2.6/fs/xfs/linux-2.6/xfs_buf.h
@@ -24,7 +24,7 @@
 #include <asm/system.h>
 #include <linux/mm.h>
 #include <linux/fs.h>
-#include <linux/buffer_head.h>
+#include <linux/fsblock.h>
 #include <linux/uio.h>
 
 /*
Index: linux-2.6/fs/xfs/linux-2.6/xfs_aops.h
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/xfs_aops.h
+++ linux-2.6/fs/xfs/linux-2.6/xfs_aops.h
@@ -31,15 +31,19 @@ typedef struct xfs_ioend {
 	int			io_error;	/* I/O error code */
 	atomic_t		io_remaining;	/* hold count */
 	struct inode		*io_inode;	/* file being written to */
-	struct buffer_head	*io_buffer_head;/* buffer linked list head */
-	struct buffer_head	*io_buffer_tail;/* buffer linked list tail */
+	struct fsblock		*io_fsb_head;	/* fsb linked list head */
+	struct fsblock		*io_fsb_tail;	/* fsb linked list tail */
 	size_t			io_size;	/* size of the extent */
 	xfs_off_t		io_offset;	/* offset in the file */
 	struct work_struct	io_work;	/* xfsdatad work queue */
 } xfs_ioend_t;
 
 extern const struct address_space_operations xfs_address_space_operations;
-extern int xfs_get_blocks(struct inode *, sector_t, struct buffer_head *, int);
+extern int xfs_get_blocks(
+	struct address_space	*mapping,
+	struct fsblock		*fsb_result,
+	loff_t			pos,
+	int			create);
 
 extern void xfs_ioend_init(void);
 extern void xfs_ioend_wait(struct xfs_inode *);
Index: linux-2.6/fs/xfs/linux-2.6/xfs_buf.c
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/xfs_buf.c
+++ linux-2.6/fs/xfs/linux-2.6/xfs_buf.c
@@ -1513,7 +1513,6 @@ xfs_mapping_buftarg(
 	struct inode		*inode;
 	struct address_space	*mapping;
 	static const struct address_space_operations mapping_aops = {
-		.sync_page = block_sync_page,
 		.migratepage = fail_migrate_page,
 	};
 
Index: linux-2.6/fs/xfs/linux-2.6/xfs_file.c
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/xfs_file.c
+++ linux-2.6/fs/xfs/linux-2.6/xfs_file.c
@@ -236,7 +236,7 @@ xfs_vm_page_mkwrite(
 	struct vm_area_struct	*vma,
 	struct page		*page)
 {
-	return block_page_mkwrite(vma, page, xfs_get_blocks);
+	return fsblock_page_mkwrite(vma, page, xfs_get_blocks);
 }
 
 const struct file_operations xfs_file_operations = {
Index: linux-2.6/fs/xfs/linux-2.6/xfs_iops.c
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/xfs_iops.c
+++ linux-2.6/fs/xfs/linux-2.6/xfs_iops.c
@@ -608,8 +608,7 @@ xfs_vn_truncate(
 	struct inode	*inode)
 {
 	int	error;
-	error = block_truncate_page(inode->i_mapping, inode->i_size,
-							xfs_get_blocks);
+	error = fsblock_truncate_page(inode->i_mapping, inode->i_size);
 	WARN_ON(error);
 }
 
Index: linux-2.6/fs/xfs/linux-2.6/xfs_super.c
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/xfs_super.c
+++ linux-2.6/fs/xfs/linux-2.6/xfs_super.c
@@ -1084,6 +1084,7 @@ xfs_fs_put_super(
 	xfs_dmops_put(mp);
 	xfs_free_fsname(mp);
 	kfree(mp);
+	fsblock_unregister_super_light(sb);
 }
 
 STATIC void
@@ -1488,6 +1489,10 @@ xfs_fs_fill_super(
 	sb->s_time_gran = 1;
 	set_posix_acl_flag(sb);
 
+	error = fsblock_register_super_light(sb);
+	if (error)
+		goto fail_unmount;
+
 	root = igrab(VFS_I(mp->m_rootip));
 	if (!root) {
 		error = ENOENT;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
