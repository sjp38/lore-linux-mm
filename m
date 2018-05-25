Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 793456B0006
	for <linux-mm@kvack.org>; Fri, 25 May 2018 13:17:20 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id w12-v6so2764295otg.2
        for <linux-mm@kvack.org>; Fri, 25 May 2018 10:17:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h125-v6si8405615oic.283.2018.05.25.10.17.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 May 2018 10:17:17 -0700 (PDT)
Date: Fri, 25 May 2018 13:17:15 -0400
From: Brian Foster <bfoster@redhat.com>
Subject: Re: [PATCH 2/2] xfs: add support for sub-pagesize writeback without
 buffer_heads
Message-ID: <20180525171714.GB92502@bfoster.bfoster>
References: <20180523144646.19159-1-hch@lst.de>
 <20180523144646.19159-3-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523144646.19159-3-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Wed, May 23, 2018 at 04:46:46PM +0200, Christoph Hellwig wrote:
> Switch to using the iomap_page structure for checking sub-page uptodate
> status and track sub-page I/O completion status, and remove large
> quantities of boilerplate code working around buffer heads.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/xfs/xfs_aops.c  | 536 +++++++--------------------------------------
>  fs/xfs/xfs_buf.h   |   1 -
>  fs/xfs/xfs_iomap.c |   3 -
>  fs/xfs/xfs_super.c |   2 +-
>  fs/xfs/xfs_trace.h |  18 +-
>  5 files changed, 79 insertions(+), 481 deletions(-)
> 
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index efa2cbb27d67..d279929e53fb 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
...
> @@ -768,7 +620,7 @@ xfs_aops_discard_page(
>  	int			error;
>  
>  	if (XFS_FORCED_SHUTDOWN(mp))
> -		goto out_invalidate;
> +		goto out;
>  
>  	xfs_alert(mp,
>  		"page discard on page "PTR_FMT", inode 0x%llx, offset %llu.",
> @@ -778,15 +630,15 @@ xfs_aops_discard_page(
>  			PAGE_SIZE / i_blocksize(inode));
>  	if (error && !XFS_FORCED_SHUTDOWN(mp))
>  		xfs_alert(mp, "page discard unable to remove delalloc mapping.");
> -out_invalidate:
> -	xfs_vm_invalidatepage(page, 0, PAGE_SIZE);
> +out:
> +	iomap_invalidatepage(page, 0, PAGE_SIZE);

All this does is lose the tracepoint. I don't think this call needs to
change. The rest looks Ok to me, but I still need to run some tests on
the whole thing.

Brian

>  }
>  
>  /*
>   * We implement an immediate ioend submission policy here to avoid needing to
>   * chain multiple ioends and hence nest mempool allocations which can violate
>   * forward progress guarantees we need to provide. The current ioend we are
> - * adding buffers to is cached on the writepage context, and if the new buffer
> + * adding blocks to is cached on the writepage context, and if the new block
>   * does not append to the cached ioend it will create a new ioend and cache that
>   * instead.
>   *
> @@ -807,41 +659,28 @@ xfs_writepage_map(
>  	uint64_t		end_offset)
>  {
>  	LIST_HEAD(submit_list);
> +	struct iomap_page	*iop = to_iomap_page(page);
> +	unsigned		len = i_blocksize(inode);
>  	struct xfs_ioend	*ioend, *next;
> -	struct buffer_head	*bh = NULL;
> -	ssize_t			len = i_blocksize(inode);
> -	int			error = 0;
> -	int			count = 0;
> -	loff_t			file_offset;	/* file offset of page */
> -	unsigned		poffset;	/* offset into page */
> +	int			error = 0, count = 0, i;
> +	u64			file_offset;	/* file offset of page */
>  
> -	if (page_has_buffers(page))
> -		bh = page_buffers(page);
> +	ASSERT(iop || i_blocksize(inode) == PAGE_SIZE);
> +	ASSERT(!iop || atomic_read(&iop->write_count) == 0);
>  
>  	/*
> -	 * Walk the blocks on the page, and we we run off then end of the
> -	 * current map or find the current map invalid, grab a new one.
> -	 * We only use bufferheads here to check per-block state - they no
> -	 * longer control the iteration through the page. This allows us to
> -	 * replace the bufferhead with some other state tracking mechanism in
> -	 * future.
> +	 * Walk through the page to find areas to write back. If we run off the
> +	 * end of the current map or find the current map invalid, grab a new
> +	 * one.
>  	 */
> -	for (poffset = 0, file_offset = page_offset(page);
> -	     poffset < PAGE_SIZE;
> -	     poffset += len, file_offset += len) {
> -		/* past the range we are writing, so nothing more to write. */
> -		if (file_offset >= end_offset)
> -			break;
> -
> +	for (i = 0, file_offset = page_offset(page);
> +	     i < (PAGE_SIZE >> inode->i_blkbits) && file_offset < end_offset;
> +	     i++, file_offset += len) {
>  		/*
>  		 * Block does not contain valid data, skip it.
>  		 */
> -		if (bh && !buffer_uptodate(bh)) {
> -			if (PageUptodate(page))
> -				ASSERT(buffer_mapped(bh));
> -			bh = bh->b_this_page;
> +		if (iop && !test_bit(i, iop->uptodate))
>  			continue;
> -		}
>  
>  		/*
>  		 * If we don't have a valid map, now it's time to get a new one
> @@ -854,52 +693,33 @@ xfs_writepage_map(
>  			error = xfs_map_blocks(inode, file_offset, &wpc->imap,
>  					     &wpc->io_type);
>  			if (error)
> -				goto out;
> +				break;
>  		}
>  
> -		if (wpc->io_type == XFS_IO_HOLE) {
> -			/*
> -			 * set_page_dirty dirties all buffers in a page, independent
> -			 * of their state.  The dirty state however is entirely
> -			 * meaningless for holes (!mapped && uptodate), so check we did
> -			 * have a buffer covering a hole here and continue.
> -			 */
> -			if (bh)
> -				bh = bh->b_this_page;
> -			continue;
> -		}
> -
> -		if (bh) {
> -			xfs_map_at_offset(inode, bh, &wpc->imap, file_offset);
> -			bh = bh->b_this_page;
> +		if (wpc->io_type != XFS_IO_HOLE) {
> +			xfs_add_to_ioend(inode, file_offset, page, iop, wpc,
> +				wbc, &submit_list);
> +			count++;
>  		}
> -		xfs_add_to_ioend(inode, file_offset, page, wpc, wbc,
> -				&submit_list);
> -		count++;
>  	}
>  
>  	ASSERT(wpc->ioend || list_empty(&submit_list));
> -
> -out:
>  	ASSERT(PageLocked(page));
>  	ASSERT(!PageWriteback(page));
>  
>  	/*
> -	 * On error, we have to fail the ioend here because we have locked
> -	 * buffers in the ioend. If we don't do this, we'll deadlock
> -	 * invalidating the page as that tries to lock the buffers on the page.
> -	 * Also, because we may have set pages under writeback, we have to make
> -	 * sure we run IO completion to mark the error state of the IO
> -	 * appropriately, so we can't cancel the ioend directly here. That means
> -	 * we have to mark this page as under writeback if we included any
> -	 * buffers from it in the ioend chain so that completion treats it
> -	 * correctly.
> +	 * On error, we have to fail the ioend here because we may have set
> +	 * pages under writeback, we have to make sure we run IO completion to
> +	 * mark the error state of the IO appropriately, so we can't cancel the
> +	 * ioend directly here.  That means we have to mark this page as under
> +	 * writeback if we included any blocks from it in the ioend chain so
> +	 * that completion treats it correctly.
>  	 *
>  	 * If we didn't include the page in the ioend, the on error we can
>  	 * simply discard and unlock it as there are no other users of the page
> -	 * or it's buffers right now. The caller will still need to trigger
> -	 * submission of outstanding ioends on the writepage context so they are
> -	 * treated correctly on error.
> +	 * now.  The caller will still need to trigger submission of outstanding
> +	 * ioends on the writepage context so they are treated correctly on
> +	 * error.
>  	 */
>  	if (unlikely(error)) {
>  		if (!count) {
> @@ -940,8 +760,8 @@ xfs_writepage_map(
>  	}
>  
>  	/*
> -	 * We can end up here with no error and nothing to write if we race with
> -	 * a partial page truncate on a sub-page block sized filesystem.
> +	 * We can end up here with no error and nothing to write only if we race
> +	 * with a partial page truncate on a sub-page block sized filesystem.
>  	 */
>  	if (!count)
>  		end_page_writeback(page);
> @@ -956,7 +776,6 @@ xfs_writepage_map(
>   * For delalloc space on the page we need to allocate space and flush it.
>   * For unwritten space on the page we need to start the conversion to
>   * regular allocated space.
> - * For any other dirty buffer heads on the page we should flush them.
>   */
>  STATIC int
>  xfs_do_writepage(
> @@ -1110,168 +929,6 @@ xfs_dax_writepages(
>  			xfs_find_bdev_for_inode(mapping->host), wbc);
>  }
>  
> -/*
> - * Called to move a page into cleanable state - and from there
> - * to be released. The page should already be clean. We always
> - * have buffer heads in this call.
> - *
> - * Returns 1 if the page is ok to release, 0 otherwise.
> - */
> -STATIC int
> -xfs_vm_releasepage(
> -	struct page		*page,
> -	gfp_t			gfp_mask)
> -{
> -	int			delalloc, unwritten;
> -
> -	trace_xfs_releasepage(page->mapping->host, page, 0, 0);
> -
> -	/*
> -	 * mm accommodates an old ext3 case where clean pages might not have had
> -	 * the dirty bit cleared. Thus, it can send actual dirty pages to
> -	 * ->releasepage() via shrink_active_list(). Conversely,
> -	 * block_invalidatepage() can send pages that are still marked dirty but
> -	 * otherwise have invalidated buffers.
> -	 *
> -	 * We want to release the latter to avoid unnecessary buildup of the
> -	 * LRU, so xfs_vm_invalidatepage() clears the page dirty flag on pages
> -	 * that are entirely invalidated and need to be released.  Hence the
> -	 * only time we should get dirty pages here is through
> -	 * shrink_active_list() and so we can simply skip those now.
> -	 *
> -	 * warn if we've left any lingering delalloc/unwritten buffers on clean
> -	 * or invalidated pages we are about to release.
> -	 */
> -	if (PageDirty(page))
> -		return 0;
> -
> -	xfs_count_page_state(page, &delalloc, &unwritten);
> -
> -	if (WARN_ON_ONCE(delalloc))
> -		return 0;
> -	if (WARN_ON_ONCE(unwritten))
> -		return 0;
> -
> -	return try_to_free_buffers(page);
> -}
> -
> -/*
> - * If this is O_DIRECT or the mpage code calling tell them how large the mapping
> - * is, so that we can avoid repeated get_blocks calls.
> - *
> - * If the mapping spans EOF, then we have to break the mapping up as the mapping
> - * for blocks beyond EOF must be marked new so that sub block regions can be
> - * correctly zeroed. We can't do this for mappings within EOF unless the mapping
> - * was just allocated or is unwritten, otherwise the callers would overwrite
> - * existing data with zeros. Hence we have to split the mapping into a range up
> - * to and including EOF, and a second mapping for beyond EOF.
> - */
> -static void
> -xfs_map_trim_size(
> -	struct inode		*inode,
> -	sector_t		iblock,
> -	struct buffer_head	*bh_result,
> -	struct xfs_bmbt_irec	*imap,
> -	xfs_off_t		offset,
> -	ssize_t			size)
> -{
> -	xfs_off_t		mapping_size;
> -
> -	mapping_size = imap->br_startoff + imap->br_blockcount - iblock;
> -	mapping_size <<= inode->i_blkbits;
> -
> -	ASSERT(mapping_size > 0);
> -	if (mapping_size > size)
> -		mapping_size = size;
> -	if (offset < i_size_read(inode) &&
> -	    (xfs_ufsize_t)offset + mapping_size >= i_size_read(inode)) {
> -		/* limit mapping to block that spans EOF */
> -		mapping_size = roundup_64(i_size_read(inode) - offset,
> -					  i_blocksize(inode));
> -	}
> -	if (mapping_size > LONG_MAX)
> -		mapping_size = LONG_MAX;
> -
> -	bh_result->b_size = mapping_size;
> -}
> -
> -static int
> -xfs_get_blocks(
> -	struct inode		*inode,
> -	sector_t		iblock,
> -	struct buffer_head	*bh_result,
> -	int			create)
> -{
> -	struct xfs_inode	*ip = XFS_I(inode);
> -	struct xfs_mount	*mp = ip->i_mount;
> -	xfs_fileoff_t		offset_fsb, end_fsb;
> -	int			error = 0;
> -	int			lockmode = 0;
> -	struct xfs_bmbt_irec	imap;
> -	int			nimaps = 1;
> -	xfs_off_t		offset;
> -	ssize_t			size;
> -
> -	BUG_ON(create);
> -
> -	if (XFS_FORCED_SHUTDOWN(mp))
> -		return -EIO;
> -
> -	offset = (xfs_off_t)iblock << inode->i_blkbits;
> -	ASSERT(bh_result->b_size >= i_blocksize(inode));
> -	size = bh_result->b_size;
> -
> -	if (offset >= i_size_read(inode))
> -		return 0;
> -
> -	/*
> -	 * Direct I/O is usually done on preallocated files, so try getting
> -	 * a block mapping without an exclusive lock first.
> -	 */
> -	lockmode = xfs_ilock_data_map_shared(ip);
> -
> -	ASSERT(offset <= mp->m_super->s_maxbytes);
> -	if (offset > mp->m_super->s_maxbytes - size)
> -		size = mp->m_super->s_maxbytes - offset;
> -	end_fsb = XFS_B_TO_FSB(mp, (xfs_ufsize_t)offset + size);
> -	offset_fsb = XFS_B_TO_FSBT(mp, offset);
> -
> -	error = xfs_bmapi_read(ip, offset_fsb, end_fsb - offset_fsb, &imap,
> -			&nimaps, 0);
> -	if (error)
> -		goto out_unlock;
> -	if (!nimaps) {
> -		trace_xfs_get_blocks_notfound(ip, offset, size);
> -		goto out_unlock;
> -	}
> -
> -	trace_xfs_get_blocks_found(ip, offset, size,
> -		imap.br_state == XFS_EXT_UNWRITTEN ?
> -			XFS_IO_UNWRITTEN : XFS_IO_OVERWRITE, &imap);
> -	xfs_iunlock(ip, lockmode);
> -
> -	/* trim mapping down to size requested */
> -	xfs_map_trim_size(inode, iblock, bh_result, &imap, offset, size);
> -
> -	/*
> -	 * For unwritten extents do not report a disk address in the buffered
> -	 * read case (treat as if we're reading into a hole).
> -	 */
> -	if (xfs_bmap_is_real_extent(&imap))
> -		xfs_map_buffer(inode, bh_result, &imap, offset);
> -
> -	/*
> -	 * If this is a realtime file, data may be on a different device.
> -	 * to that pointed to from the buffer_head b_bdev currently.
> -	 */
> -	bh_result->b_bdev = xfs_find_bdev_for_inode(inode);
> -	return 0;
> -
> -out_unlock:
> -	xfs_iunlock(ip, lockmode);
> -	return error;
> -}
> -
>  STATIC sector_t
>  xfs_vm_bmap(
>  	struct address_space	*mapping,
> @@ -1301,9 +958,7 @@ xfs_vm_readpage(
>  	struct page		*page)
>  {
>  	trace_xfs_vm_readpage(page->mapping->host, 1);
> -	if (i_blocksize(page->mapping->host) == PAGE_SIZE)
> -		return iomap_readpage(page, &xfs_iomap_ops);
> -	return mpage_readpage(page, xfs_get_blocks);
> +	return iomap_readpage(page, &xfs_iomap_ops);
>  }
>  
>  STATIC int
> @@ -1314,65 +969,26 @@ xfs_vm_readpages(
>  	unsigned		nr_pages)
>  {
>  	trace_xfs_vm_readpages(mapping->host, nr_pages);
> -	if (i_blocksize(mapping->host) == PAGE_SIZE)
> -		return iomap_readpages(mapping, pages, nr_pages, &xfs_iomap_ops);
> -	return mpage_readpages(mapping, pages, nr_pages, xfs_get_blocks);
> +	return iomap_readpages(mapping, pages, nr_pages, &xfs_iomap_ops);
>  }
>  
> -/*
> - * This is basically a copy of __set_page_dirty_buffers() with one
> - * small tweak: buffers beyond EOF do not get marked dirty. If we mark them
> - * dirty, we'll never be able to clean them because we don't write buffers
> - * beyond EOF, and that means we can't invalidate pages that span EOF
> - * that have been marked dirty. Further, the dirty state can leak into
> - * the file interior if the file is extended, resulting in all sorts of
> - * bad things happening as the state does not match the underlying data.
> - *
> - * XXX: this really indicates that bufferheads in XFS need to die. Warts like
> - * this only exist because of bufferheads and how the generic code manages them.
> - */
> -STATIC int
> -xfs_vm_set_page_dirty(
> -	struct page		*page)
> +static int
> +xfs_vm_releasepage(
> +	struct page		*page,
> +	gfp_t			gfp_mask)
>  {
> -	struct address_space	*mapping = page->mapping;
> -	struct inode		*inode = mapping->host;
> -	loff_t			end_offset;
> -	loff_t			offset;
> -	int			newly_dirty;
> -
> -	if (unlikely(!mapping))
> -		return !TestSetPageDirty(page);
> -
> -	end_offset = i_size_read(inode);
> -	offset = page_offset(page);
> -
> -	spin_lock(&mapping->private_lock);
> -	if (page_has_buffers(page)) {
> -		struct buffer_head *head = page_buffers(page);
> -		struct buffer_head *bh = head;
> +	trace_xfs_releasepage(page->mapping->host, page, 0, 0);
> +	return iomap_releasepage(page, gfp_mask);
> +}
>  
> -		do {
> -			if (offset < end_offset)
> -				set_buffer_dirty(bh);
> -			bh = bh->b_this_page;
> -			offset += i_blocksize(inode);
> -		} while (bh != head);
> -	}
> -	/*
> -	 * Lock out page->mem_cgroup migration to keep PageDirty
> -	 * synchronized with per-memcg dirty page counters.
> -	 */
> -	lock_page_memcg(page);
> -	newly_dirty = !TestSetPageDirty(page);
> -	spin_unlock(&mapping->private_lock);
> -
> -	if (newly_dirty)
> -		__set_page_dirty(page, mapping, 1);
> -	unlock_page_memcg(page);
> -	if (newly_dirty)
> -		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
> -	return newly_dirty;
> +static void
> +xfs_vm_invalidatepage(
> +	struct page		*page,
> +	unsigned int		offset,
> +	unsigned int		length)
> +{
> +	trace_xfs_invalidatepage(page->mapping->host, page, offset, length);
> +	iomap_invalidatepage(page, offset, length);
>  }
>  
>  static int
> @@ -1390,13 +1006,13 @@ const struct address_space_operations xfs_address_space_operations = {
>  	.readpages		= xfs_vm_readpages,
>  	.writepage		= xfs_vm_writepage,
>  	.writepages		= xfs_vm_writepages,
> -	.set_page_dirty		= xfs_vm_set_page_dirty,
> +	.set_page_dirty		= iomap_set_page_dirty,
>  	.releasepage		= xfs_vm_releasepage,
>  	.invalidatepage		= xfs_vm_invalidatepage,
>  	.bmap			= xfs_vm_bmap,
>  	.direct_IO		= noop_direct_IO,
> -	.migratepage		= buffer_migrate_page,
> -	.is_partially_uptodate  = block_is_partially_uptodate,
> +	.migratepage		= iomap_migrate_page,
> +	.is_partially_uptodate  = iomap_is_partially_uptodate,
>  	.error_remove_page	= generic_error_remove_page,
>  	.swap_activate		= xfs_iomap_swapfile_activate,
>  };
> diff --git a/fs/xfs/xfs_buf.h b/fs/xfs/xfs_buf.h
> index f5f2b71c2fde..f3fa197bd272 100644
> --- a/fs/xfs/xfs_buf.h
> +++ b/fs/xfs/xfs_buf.h
> @@ -24,7 +24,6 @@
>  #include <linux/mm.h>
>  #include <linux/fs.h>
>  #include <linux/dax.h>
> -#include <linux/buffer_head.h>
>  #include <linux/uio.h>
>  #include <linux/list_lru.h>
>  
> diff --git a/fs/xfs/xfs_iomap.c b/fs/xfs/xfs_iomap.c
> index 93c40da3378a..c646d84cd55e 100644
> --- a/fs/xfs/xfs_iomap.c
> +++ b/fs/xfs/xfs_iomap.c
> @@ -1031,9 +1031,6 @@ xfs_file_iomap_begin(
>  	if (XFS_FORCED_SHUTDOWN(mp))
>  		return -EIO;
>  
> -	if (i_blocksize(inode) < PAGE_SIZE)
> -		iomap->flags |= IOMAP_F_BUFFER_HEAD;
> -
>  	if (((flags & (IOMAP_WRITE | IOMAP_DIRECT)) == IOMAP_WRITE) &&
>  			!IS_DAX(inode) && !xfs_get_extsz_hint(ip)) {
>  		/* Reserve delalloc blocks for regular writeback. */
> diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
> index 39e5ec3d407f..a9f23ec95216 100644
> --- a/fs/xfs/xfs_super.c
> +++ b/fs/xfs/xfs_super.c
> @@ -1866,7 +1866,7 @@ MODULE_ALIAS_FS("xfs");
>  STATIC int __init
>  xfs_init_zones(void)
>  {
> -	xfs_ioend_bioset = bioset_create(4 * MAX_BUF_PER_PAGE,
> +	xfs_ioend_bioset = bioset_create(4 * (PAGE_SIZE / SECTOR_SIZE),
>  			offsetof(struct xfs_ioend, io_inline_bio),
>  			BIOSET_NEED_BVECS);
>  	if (!xfs_ioend_bioset)
> diff --git a/fs/xfs/xfs_trace.h b/fs/xfs/xfs_trace.h
> index ed8f774944ba..e4dc7c7f3da9 100644
> --- a/fs/xfs/xfs_trace.h
> +++ b/fs/xfs/xfs_trace.h
> @@ -1165,33 +1165,23 @@ DECLARE_EVENT_CLASS(xfs_page_class,
>  		__field(loff_t, size)
>  		__field(unsigned long, offset)
>  		__field(unsigned int, length)
> -		__field(int, delalloc)
> -		__field(int, unwritten)
>  	),
>  	TP_fast_assign(
> -		int delalloc = -1, unwritten = -1;
> -
> -		if (page_has_buffers(page))
> -			xfs_count_page_state(page, &delalloc, &unwritten);
>  		__entry->dev = inode->i_sb->s_dev;
>  		__entry->ino = XFS_I(inode)->i_ino;
>  		__entry->pgoff = page_offset(page);
>  		__entry->size = i_size_read(inode);
>  		__entry->offset = off;
>  		__entry->length = len;
> -		__entry->delalloc = delalloc;
> -		__entry->unwritten = unwritten;
>  	),
>  	TP_printk("dev %d:%d ino 0x%llx pgoff 0x%lx size 0x%llx offset %lx "
> -		  "length %x delalloc %d unwritten %d",
> +		  "length %x",
>  		  MAJOR(__entry->dev), MINOR(__entry->dev),
>  		  __entry->ino,
>  		  __entry->pgoff,
>  		  __entry->size,
>  		  __entry->offset,
> -		  __entry->length,
> -		  __entry->delalloc,
> -		  __entry->unwritten)
> +		  __entry->length)
>  )
>  
>  #define DEFINE_PAGE_EVENT(name)		\
> @@ -1275,9 +1265,6 @@ DEFINE_EVENT(xfs_imap_class, name,	\
>  	TP_ARGS(ip, offset, count, type, irec))
>  DEFINE_IOMAP_EVENT(xfs_map_blocks_found);
>  DEFINE_IOMAP_EVENT(xfs_map_blocks_alloc);
> -DEFINE_IOMAP_EVENT(xfs_get_blocks_found);
> -DEFINE_IOMAP_EVENT(xfs_get_blocks_alloc);
> -DEFINE_IOMAP_EVENT(xfs_get_blocks_map_direct);
>  DEFINE_IOMAP_EVENT(xfs_iomap_alloc);
>  DEFINE_IOMAP_EVENT(xfs_iomap_found);
>  
> @@ -1316,7 +1303,6 @@ DEFINE_EVENT(xfs_simple_io_class, name,	\
>  	TP_ARGS(ip, offset, count))
>  DEFINE_SIMPLE_IO_EVENT(xfs_delalloc_enospc);
>  DEFINE_SIMPLE_IO_EVENT(xfs_unwritten_convert);
> -DEFINE_SIMPLE_IO_EVENT(xfs_get_blocks_notfound);
>  DEFINE_SIMPLE_IO_EVENT(xfs_setfilesize);
>  DEFINE_SIMPLE_IO_EVENT(xfs_zero_eof);
>  DEFINE_SIMPLE_IO_EVENT(xfs_end_io_direct_write);
> -- 
> 2.17.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
