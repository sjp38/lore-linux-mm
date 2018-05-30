Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 816266B027E
	for <linux-mm@kvack.org>; Wed, 30 May 2018 06:00:48 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id c6-v6so942830pll.4
        for <linux-mm@kvack.org>; Wed, 30 May 2018 03:00:48 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l13-v6si18576163pls.45.2018.05.30.03.00.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 03:00:46 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 06/18] xfs: make xfs_writepage_map extent map centric
Date: Wed, 30 May 2018 12:00:01 +0200
Message-Id: <20180530100013.31358-7-hch@lst.de>
In-Reply-To: <20180530100013.31358-1-hch@lst.de>
References: <20180530100013.31358-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>

From: Dave Chinner <dchinner@redhat.com>

xfs_writepage_map() iterates over the bufferheads on a page to decide
what sort of IO to do and what actions to take.  However, when it comes
to reflink and deciding when it needs to execute a COW operation, we no
longer look at the bufferhead state but instead we ignore than and look
up internal state held in teh COW fork extent list.

This means xfs_writepage_map() is somewhat confused. It does stuff, then
ignores it, then tries to handle the impedence mismatch by shovelling the
results inside the existing mapping code.  It works, but it's a bit of a
mess and it makes it hard to fix the cached map bug that the writepage
code currently has.

To unify the two different mechanisms, we first have to choose a direction.
That's already been set - we're de-emphasising bufferheads so they are no
longer a control structure as we need to do taht to allow for eventual
removal.  Hence we need to move away from looking at bufferhead state to
determine what operations we need to perform.

We can't completely get rid of bufferheads yet - they do contain some
state that is absolutely necessary, such as whether that part of the page
contains valid data or not (buffer_uptodate()).  Other state in the
bufferhead is redundant:

	BH_dirty - the page is dirty, so we can ignore this and just
		write it
	BH_delay - we have delalloc extent info in the DATA fork extent
		tree
	BH_unwritten - same as BH_delay
	BH_mapped - indicates we've already used it once for IO and it is
		mapped to a disk address. Needs to be ignored for COW
		blocks.

The BH_mapped flag is an interesting case - it's supposed to indicate that
it's already mapped to disk and so we can just use it "as is".  In theory,
we don't even have to do an extent lookup to find where to write it too,
but we have to do that anyway to determine we are actually writing over a
valid extent.  Hence it's not even serving the purpose of avoiding a an
extent lookup during writeback, and so we can pretty much ignore it.
Especially as we have to ignore it for COW operations...

Therefore, use the extent map as the source of information to tell us
what actions we need to take and what sort of IO we should perform.  The
first step is integration xfs_map_blocks() and xfs_map_cow() and have
xfs_map_blocks() set the io type according to what it looks up.  This
means it can easily handle both normal overwrite and COW cases.  The
only thing we also need to add is the ability to return hole mappings.

We need to return and cache hole mappings now for the case of multiple
blocks per page.  We no longer use the BH_mapped to indicate a block over
a hole, so we have to get that info from xfs_map_blocks().  We cache it so
that holes that span two pages don't need separate lookups.  This allows us
to avoid ever doing write IO over a hole, too.

Further, we need to drop the XFS_BMAPI_IGSTATE flag so that we don't
combine contiguous written and unwritten extents into a single map.  The
io type needs to match the extent type we are writing to so that we run the
correct IO completion routine for the IO. There is scope for optimisation
that would allow us to re-instate the XFS_BMAPI_IGSTATE flag, but this
requires tweaks to code outside the scope of this change.

Now that we have xfs_map_blocks() returning both a cached map and the type
of IO we need to perform, we can rewrite xfs_writepage_map() to drop all
the bufferhead control. It's also much simplified because it doesn't need
to explicitly handle COW operations.  Instead of iterating bufferheads, it
iterates blocks within the page and then looks up what per-block state is
required from the appropriate bufferhead.  It then validates the cached
map, and if it's not valid, we get a new map.  If we don't get a valid map
or it's over a hole, we skip the block.

At this point, we have to remap the bufferhead via xfs_map_at_offset().
As previously noted, we had to do this even if the buffer was already
mapped as the mapping would be stale for XFS_IO_DELALLOC, XFS_IO_UNWRITTEN
and XFS_IO_COW IO types.  With xfs_map_blocks() now controlling the type,
even XFS_IO_OVERWRITE types need remapping, as converted-but-not-yet-
written delalloc extents beyond EOF can be reported at XFS_IO_OVERWRITE.
Bufferheads that span such regions still need their BH_Delay flags cleared
and their block numbers calculated, so we now unconditionally map each
bufferhead before submission.

But wait! There's more - remember the old "treat unwritten extents as
holes on read" hack?  Yeah, that means we can have a dirty page with
unmapped, unwritten bufferheads that contain data!  What makes these so
special is that the unwritten "hole" bufferheads do not have a valid block
device pointer, so if we attempt to write them xfs_add_to_ioend() blows
up. So we make xfs_map_at_offset() do the "realtime or data device"
lookup from the inode and ignore what was or wasn't put into the
bufferhead when the buffer was instantiated.

The astute reader will have realised by now that this code treats
unwritten extents in multiple-blocks-per-page situations differently.
If we get any combination of unwritten blocks on a dirty page that contain
valid data in the page, we're going to convert them to real extents.  This
can actually be a win, because it means that pages with interleaving
unwritten and written blocks will get converted to a single written extent
with zeros replacing the interspersed unwritten blocks.  This is actually
good for reducing extent list and conversion overhead, and it means we
issue a contiguous IO instead of lots of little ones.  The downside is
that we use up a little extra IO bandwidth.  Neither of these seem like a
bad thing given that spinning disks are seek sensitive, and SSDs/pmem have
bandwidth to burn and the lower Io latency/CPU overhead of fewer, larger
IOs will result in better performance on them...

As a result of all this, the only state we actually care about from the
bufferhead is a single flag - BH_Uptodate. We still use the bufferhead to
pass some information to the bio via xfs_add_to_ioend(), but that is
trivial to separate and pass explicitly.  This means we really only need
1 bit of state per block per page from the buffered write path in the
writeback path.  Everything else we do with the bufferhead is purely to
make the buffered IO front end continue to work correctly. i.e we've
pretty much marginalised bufferheads in the writeback path completely.

Signed-Off-By: Dave Chinner <dchinner@redhat.com>
[hch: forward port + slight refactoring]
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/xfs/xfs_aops.c | 273 ++++++++++++++++++++--------------------------
 fs/xfs/xfs_aops.h |   4 +-
 2 files changed, 124 insertions(+), 153 deletions(-)

diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 5dd09e83c81c..8cc41a786b5e 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -378,78 +378,93 @@ xfs_map_blocks(
 	struct inode		*inode,
 	loff_t			offset,
 	struct xfs_bmbt_irec	*imap,
-	int			type)
+	int			*type)
 {
 	struct xfs_inode	*ip = XFS_I(inode);
 	struct xfs_mount	*mp = ip->i_mount;
 	ssize_t			count = i_blocksize(inode);
 	xfs_fileoff_t		offset_fsb, end_fsb;
+	int			whichfork = XFS_DATA_FORK;
 	int			error = 0;
-	int			bmapi_flags = XFS_BMAPI_ENTIRE;
 	int			nimaps = 1;
 
 	if (XFS_FORCED_SHUTDOWN(mp))
 		return -EIO;
 
-	/*
-	 * Truncate can race with writeback since writeback doesn't take the
-	 * iolock and truncate decreases the file size before it starts
-	 * truncating the pages between new_size and old_size.  Therefore, we
-	 * can end up in the situation where writeback gets a CoW fork mapping
-	 * but the truncate makes the mapping invalid and we end up in here
-	 * trying to get a new mapping.  Bail out here so that we simply never
-	 * get a valid mapping and so we drop the write altogether.  The page
-	 * truncation will kill the contents anyway.
-	 */
-	if (type == XFS_IO_COW && offset > i_size_read(inode))
-		return 0;
-
-	ASSERT(type != XFS_IO_COW);
-	if (type == XFS_IO_UNWRITTEN)
-		bmapi_flags |= XFS_BMAPI_IGSTATE;
-
 	xfs_ilock(ip, XFS_ILOCK_SHARED);
 	ASSERT(ip->i_d.di_format != XFS_DINODE_FMT_BTREE ||
 	       (ip->i_df.if_flags & XFS_IFEXTENTS));
 	ASSERT(offset <= mp->m_super->s_maxbytes);
 
+	if (xfs_is_reflink_inode(ip) &&
+	    xfs_reflink_find_cow_mapping(ip, offset, imap)) {
+		xfs_iunlock(ip, XFS_ILOCK_SHARED);
+		/*
+		 * Truncate can race with writeback since writeback doesn't
+		 * take the iolock and truncate decreases the file size before
+		 * it starts truncating the pages between new_size and old_size.
+		 * Therefore, we can end up in the situation where writeback
+		 * gets a CoW fork mapping but the truncate makes the mapping
+		 * invalid and we end up in here trying to get a new mapping.
+		 * bail out here so that we simply never get a valid mapping
+		 * and so we drop the write altogether.  The page truncation
+		 * will kill the contents anyway.
+		 */
+		if (offset > i_size_read(inode))
+			return 0;
+		whichfork = XFS_COW_FORK;
+		*type = XFS_IO_COW;
+		goto allocate_blocks;
+	}
+
 	if (offset > mp->m_super->s_maxbytes - count)
 		count = mp->m_super->s_maxbytes - offset;
 	end_fsb = XFS_B_TO_FSB(mp, (xfs_ufsize_t)offset + count);
 	offset_fsb = XFS_B_TO_FSBT(mp, offset);
 	error = xfs_bmapi_read(ip, offset_fsb, end_fsb - offset_fsb,
-				imap, &nimaps, bmapi_flags);
-	/*
-	 * Truncate an overwrite extent if there's a pending CoW
-	 * reservation before the end of this extent.  This forces us
-	 * to come back to writepage to take care of the CoW.
-	 */
-	if (nimaps && type == XFS_IO_OVERWRITE)
+				imap, &nimaps, XFS_BMAPI_ENTIRE);
+	if (!nimaps) {
+		/*
+		 * Lookup returns no match? Beyond eof? regardless,
+		 * return it as a hole so we don't write it
+		 */
+		imap->br_startoff = offset_fsb;
+		imap->br_blockcount = end_fsb - offset_fsb;
+		imap->br_startblock = HOLESTARTBLOCK;
+		*type = XFS_IO_HOLE;
+	} else if (imap->br_startblock == HOLESTARTBLOCK) {
+		/* landed in a hole */
+		*type = XFS_IO_HOLE;
+	} else {
+		if (isnullstartblock(imap->br_startblock)) {
+			/* got a delalloc extent */
+			*type = XFS_IO_DELALLOC;
+			goto allocate_blocks;
+		}
+
+		/*
+		 * Got an existing extent for overwrite.  Truncate it if there
+		 * is a pending CoW reservation before the end of this extent,
+		 * so that we pick up the COW extents in the next iteration.
+		 */
 		xfs_reflink_trim_irec_to_next_cow(ip, offset_fsb, imap);
+		if (imap->br_state == XFS_EXT_UNWRITTEN)
+			*type = XFS_IO_UNWRITTEN;
+		else
+			*type = XFS_IO_OVERWRITE;
+	}
 	xfs_iunlock(ip, XFS_ILOCK_SHARED);
 
-	if (error)
-		return error;
-
-	if (type == XFS_IO_DELALLOC &&
-	    (!nimaps || isnullstartblock(imap->br_startblock))) {
-		error = xfs_iomap_write_allocate(ip, XFS_DATA_FORK, offset,
-				imap);
-		if (!error)
-			trace_xfs_map_blocks_alloc(ip, offset, count, type, imap);
-		return error;
-	}
+	trace_xfs_map_blocks_found(ip, offset, count, *type, imap);
+	return error;
 
-#ifdef DEBUG
-	if (type == XFS_IO_UNWRITTEN) {
-		ASSERT(nimaps);
-		ASSERT(imap->br_startblock != HOLESTARTBLOCK);
-		ASSERT(imap->br_startblock != DELAYSTARTBLOCK);
-	}
-#endif
-	if (nimaps)
-		trace_xfs_map_blocks_found(ip, offset, count, type, imap);
-	return 0;
+allocate_blocks:
+	xfs_iunlock(ip, XFS_ILOCK_SHARED);
+	if (!error)
+		error = xfs_iomap_write_allocate(ip, whichfork, offset, imap);
+	if (!error)
+		trace_xfs_map_blocks_alloc(ip, offset, count, *type, imap);
+	return error;
 }
 
 STATIC bool
@@ -709,6 +724,14 @@ xfs_map_at_offset(
 	set_buffer_mapped(bh);
 	clear_buffer_delay(bh);
 	clear_buffer_unwritten(bh);
+
+	/*
+	 * If this is a realtime file, data may be on a different device.
+	 * to that pointed to from the buffer_head b_bdev currently. We can't
+	 * trust that the bufferhead has a already been mapped correctly, so
+	 * set the bdev now.
+	 */
+	bh->b_bdev = xfs_find_bdev_for_inode(inode);
 }
 
 STATIC void
@@ -769,56 +792,6 @@ xfs_aops_discard_page(
 	xfs_vm_invalidatepage(page, 0, PAGE_SIZE);
 }
 
-static int
-xfs_map_cow(
-	struct xfs_writepage_ctx *wpc,
-	struct inode		*inode,
-	loff_t			offset,
-	unsigned int		*new_type)
-{
-	struct xfs_inode	*ip = XFS_I(inode);
-	struct xfs_bmbt_irec	imap;
-	bool			is_cow = false;
-	int			error;
-
-	/*
-	 * If we already have a valid COW mapping keep using it.
-	 */
-	if (wpc->io_type == XFS_IO_COW) {
-		wpc->imap_valid = xfs_imap_valid(inode, &wpc->imap, offset);
-		if (wpc->imap_valid) {
-			*new_type = XFS_IO_COW;
-			return 0;
-		}
-	}
-
-	/*
-	 * Else we need to check if there is a COW mapping at this offset.
-	 */
-	xfs_ilock(ip, XFS_ILOCK_SHARED);
-	is_cow = xfs_reflink_find_cow_mapping(ip, offset, &imap);
-	xfs_iunlock(ip, XFS_ILOCK_SHARED);
-
-	if (!is_cow)
-		return 0;
-
-	/*
-	 * And if the COW mapping has a delayed extent here we need to
-	 * allocate real space for it now.
-	 */
-	if (isnullstartblock(imap.br_startblock)) {
-		error = xfs_iomap_write_allocate(ip, XFS_COW_FORK, offset,
-				&imap);
-		if (error)
-			return error;
-	}
-
-	wpc->io_type = *new_type = XFS_IO_COW;
-	wpc->imap_valid = true;
-	wpc->imap = imap;
-	return 0;
-}
-
 /*
  * We implement an immediate ioend submission policy here to avoid needing to
  * chain multiple ioends and hence nest mempool allocations which can violate
@@ -845,85 +818,81 @@ xfs_writepage_map(
 {
 	LIST_HEAD(submit_list);
 	struct xfs_ioend	*ioend, *next;
-	struct buffer_head	*bh, *head;
+	struct buffer_head	*bh;
 	ssize_t			len = i_blocksize(inode);
-	uint64_t		offset;
 	int			error = 0;
 	int			count = 0;
-	int			uptodate = 1;
-	unsigned int		new_type;
+	bool			uptodate = true;
+	loff_t			file_offset;	/* file offset of page */
+	unsigned		poffset;	/* offset into page */
 
-	bh = head = page_buffers(page);
-	offset = page_offset(page);
-	do {
-		if (offset >= end_offset)
+	/*
+	 * Walk the blocks on the page, and we we run off then end of the
+	 * current map or find the current map invalid, grab a new one.
+	 * We only use bufferheads here to check per-block state - they no
+	 * longer control the iteration through the page. This allows us to
+	 * replace the bufferhead with some other state tracking mechanism in
+	 * future.
+	 */
+	file_offset = page_offset(page);
+	bh = page_buffers(page);
+	for (poffset = 0;
+	     poffset < PAGE_SIZE;
+	     poffset += len, file_offset += len, bh = bh->b_this_page) {
+		/* past the range we are writing, so nothing more to write. */
+		if (file_offset >= end_offset)
 			break;
-		if (!buffer_uptodate(bh))
-			uptodate = 0;
 
 		/*
-		 * set_page_dirty dirties all buffers in a page, independent
-		 * of their state.  The dirty state however is entirely
-		 * meaningless for holes (!mapped && uptodate), so skip
-		 * buffers covering holes here.
+		 * Block does not contain valid data, skip it, mark the current
+		 * map as invalid because we have a discontiguity. This ensures
+		 * we put subsequent writeable buffers into a new ioend.
 		 */
-		if (!buffer_mapped(bh) && buffer_uptodate(bh)) {
-			wpc->imap_valid = false;
-			continue;
-		}
-
-		if (buffer_unwritten(bh))
-			new_type = XFS_IO_UNWRITTEN;
-		else if (buffer_delay(bh))
-			new_type = XFS_IO_DELALLOC;
-		else if (buffer_uptodate(bh))
-			new_type = XFS_IO_OVERWRITE;
-		else {
+		if (!buffer_uptodate(bh)) {
 			if (PageUptodate(page))
 				ASSERT(buffer_mapped(bh));
-			/*
-			 * This buffer is not uptodate and will not be
-			 * written to disk.  Ensure that we will put any
-			 * subsequent writeable buffers into a new
-			 * ioend.
-			 */
+			uptodate = false;
 			wpc->imap_valid = false;
 			continue;
 		}
 
-		if (xfs_is_reflink_inode(XFS_I(inode))) {
-			error = xfs_map_cow(wpc, inode, offset, &new_type);
-			if (error)
-				goto out;
-		}
-
-		if (wpc->io_type != new_type) {
-			wpc->io_type = new_type;
-			wpc->imap_valid = false;
-		}
-
+		/* Check to see if current map spans this file offset */
 		if (wpc->imap_valid)
 			wpc->imap_valid = xfs_imap_valid(inode, &wpc->imap,
-							 offset);
+							 file_offset);
+		/*
+		 * If we don't have a valid map, now it's time to get a new one
+		 * for this offset.  This will convert delayed allocations
+		 * (including COW ones) into real extents.  If we return without
+		 * a valid map, it means we landed in a hole and we skip the
+		 * block.
+		 */
 		if (!wpc->imap_valid) {
-			error = xfs_map_blocks(inode, offset, &wpc->imap,
-					     wpc->io_type);
+			error = xfs_map_blocks(inode, file_offset, &wpc->imap,
+					     &wpc->io_type);
 			if (error)
 				goto out;
 			wpc->imap_valid = xfs_imap_valid(inode, &wpc->imap,
-							 offset);
+							 file_offset);
 		}
-		if (wpc->imap_valid) {
-			lock_buffer(bh);
-			if (wpc->io_type != XFS_IO_OVERWRITE)
-				xfs_map_at_offset(inode, bh, &wpc->imap, offset);
-			xfs_add_to_ioend(inode, bh, offset, wpc, wbc, &submit_list);
-			count++;
+
+		if (!wpc->imap_valid || wpc->io_type == XFS_IO_HOLE) {
+			/*
+			 * set_page_dirty dirties all buffers in a page, independent
+			 * of their state.  The dirty state however is entirely
+			 * meaningless for holes (!mapped && uptodate), so check we did
+			 * have a buffer covering a hole here and continue.
+			 */
+			continue;
 		}
 
-	} while (offset += len, ((bh = bh->b_this_page) != head));
+		lock_buffer(bh);
+		xfs_map_at_offset(inode, bh, &wpc->imap, file_offset);
+		xfs_add_to_ioend(inode, bh, file_offset, wpc, wbc, &submit_list);
+		count++;
+	}
 
-	if (uptodate && bh == head)
+	if (uptodate && poffset == PAGE_SIZE)
 		SetPageUptodate(page);
 
 	ASSERT(wpc->ioend || list_empty(&submit_list));
diff --git a/fs/xfs/xfs_aops.h b/fs/xfs/xfs_aops.h
index 69346d460dfa..b2ef5b661761 100644
--- a/fs/xfs/xfs_aops.h
+++ b/fs/xfs/xfs_aops.h
@@ -29,6 +29,7 @@ enum {
 	XFS_IO_UNWRITTEN,	/* covers allocated but uninitialized data */
 	XFS_IO_OVERWRITE,	/* covers already allocated extent */
 	XFS_IO_COW,		/* covers copy-on-write extent */
+	XFS_IO_HOLE,		/* covers region without any block allocation */
 };
 
 #define XFS_IO_TYPES \
@@ -36,7 +37,8 @@ enum {
 	{ XFS_IO_DELALLOC,		"delalloc" }, \
 	{ XFS_IO_UNWRITTEN,		"unwritten" }, \
 	{ XFS_IO_OVERWRITE,		"overwrite" }, \
-	{ XFS_IO_COW,			"CoW" }
+	{ XFS_IO_COW,			"CoW" }, \
+	{ XFS_IO_HOLE,			"hole" }
 
 /*
  * Structure for buffered I/O completions.
-- 
2.17.0
