Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id EBF886B0003
	for <linux-mm@kvack.org>; Wed, 30 May 2018 13:39:59 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id 106-v6so12097422otg.22
        for <linux-mm@kvack.org>; Wed, 30 May 2018 10:39:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s133-v6si12066803oig.20.2018.05.30.10.39.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 May 2018 10:39:58 -0700 (PDT)
Date: Wed, 30 May 2018 13:39:56 -0400
From: Brian Foster <bfoster@redhat.com>
Subject: Re: [PATCH 06/18] xfs: make xfs_writepage_map extent map centric
Message-ID: <20180530173955.GF112411@bfoster.bfoster>
References: <20180530100013.31358-1-hch@lst.de>
 <20180530100013.31358-7-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530100013.31358-7-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>

On Wed, May 30, 2018 at 12:00:01PM +0200, Christoph Hellwig wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> xfs_writepage_map() iterates over the bufferheads on a page to decide
> what sort of IO to do and what actions to take.  However, when it comes
> to reflink and deciding when it needs to execute a COW operation, we no
> longer look at the bufferhead state but instead we ignore than and look
> up internal state held in teh COW fork extent list.
> 
...
> 
> Signed-Off-By: Dave Chinner <dchinner@redhat.com>
> [hch: forward port + slight refactoring]
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---

I believe Dave originally intended to split this up into multiple
patches. Dave, did you happen to get anywhere with that before Christoph
pulled this in?

If not, could we at least split off some of the behavior changes into
separate patches? For example, dropping the !mapped && uptodate check
that causes us to writeback zeroed blocks over unwritten extents is a
behavior change that warrants a separate patch. I also think the
associated text above doesn't quite describe the details of the behavior
change. Writeback only converts those extents if they've been previously
read somehow or another, otherwise those blocks are still skipped.

So for example, (on a bsize=1k fs) this:

	xfs_io -fc "falloc 0 4k" -c "pread 3k 1k" -c "pwrite 3k 1k" \
		-c fsync -c "fiemap -v" /mnt/file

... now results in different writeback behavior from this:

	xfs_io -fc "falloc 0 4k" -c "pwrite 3k 1k" \
		-c fsync -c "fiemap -v" /mnt/file

That may be fine, but it does leave me thinking whether we should
consider ways to provide more consistent behavior here (such as zeroing
blocks at writeback time, for example).

>  fs/xfs/xfs_aops.c | 273 ++++++++++++++++++++--------------------------
>  fs/xfs/xfs_aops.h |   4 +-
>  2 files changed, 124 insertions(+), 153 deletions(-)
> 
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index 5dd09e83c81c..8cc41a786b5e 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
...
> @@ -845,85 +818,81 @@ xfs_writepage_map(
>  {
>  	LIST_HEAD(submit_list);
>  	struct xfs_ioend	*ioend, *next;
> -	struct buffer_head	*bh, *head;
> +	struct buffer_head	*bh;
>  	ssize_t			len = i_blocksize(inode);
> -	uint64_t		offset;
>  	int			error = 0;
>  	int			count = 0;
> -	int			uptodate = 1;
> -	unsigned int		new_type;
> +	bool			uptodate = true;
> +	loff_t			file_offset;	/* file offset of page */
> +	unsigned		poffset;	/* offset into page */
>  
> -	bh = head = page_buffers(page);
> -	offset = page_offset(page);
> -	do {
> -		if (offset >= end_offset)
> +	/*
> +	 * Walk the blocks on the page, and we we run off then end of the
> +	 * current map or find the current map invalid, grab a new one.
> +	 * We only use bufferheads here to check per-block state - they no
> +	 * longer control the iteration through the page. This allows us to
> +	 * replace the bufferhead with some other state tracking mechanism in
> +	 * future.
> +	 */
> +	file_offset = page_offset(page);
> +	bh = page_buffers(page);
> +	for (poffset = 0;
> +	     poffset < PAGE_SIZE;
> +	     poffset += len, file_offset += len, bh = bh->b_this_page) {
> +		/* past the range we are writing, so nothing more to write. */
> +		if (file_offset >= end_offset)
>  			break;
> -		if (!buffer_uptodate(bh))
> -			uptodate = 0;
>  
>  		/*
> -		 * set_page_dirty dirties all buffers in a page, independent
> -		 * of their state.  The dirty state however is entirely
> -		 * meaningless for holes (!mapped && uptodate), so skip
> -		 * buffers covering holes here.
> +		 * Block does not contain valid data, skip it, mark the current
> +		 * map as invalid because we have a discontiguity. This ensures
> +		 * we put subsequent writeable buffers into a new ioend.
>  		 */
> -		if (!buffer_mapped(bh) && buffer_uptodate(bh)) {
> -			wpc->imap_valid = false;
> -			continue;
> -		}
> -
> -		if (buffer_unwritten(bh))
> -			new_type = XFS_IO_UNWRITTEN;
> -		else if (buffer_delay(bh))
> -			new_type = XFS_IO_DELALLOC;
> -		else if (buffer_uptodate(bh))
> -			new_type = XFS_IO_OVERWRITE;
> -		else {
> +		if (!buffer_uptodate(bh)) {
>  			if (PageUptodate(page))
>  				ASSERT(buffer_mapped(bh));
> -			/*
> -			 * This buffer is not uptodate and will not be
> -			 * written to disk.  Ensure that we will put any
> -			 * subsequent writeable buffers into a new
> -			 * ioend.
> -			 */
> +			uptodate = false;
>  			wpc->imap_valid = false;
>  			continue;
>  		}
>  
> -		if (xfs_is_reflink_inode(XFS_I(inode))) {
> -			error = xfs_map_cow(wpc, inode, offset, &new_type);
> -			if (error)
> -				goto out;
> -		}
> -
> -		if (wpc->io_type != new_type) {
> -			wpc->io_type = new_type;
> -			wpc->imap_valid = false;
> -		}
> -
> +		/* Check to see if current map spans this file offset */
>  		if (wpc->imap_valid)
>  			wpc->imap_valid = xfs_imap_valid(inode, &wpc->imap,
> -							 offset);
> +							 file_offset);

What if the file is reflinked and the current page covers a non-shared
block but has an overlapping cow mapping due to cowextsize? The current
logic unconditionally uses the COW mapping for writeback. The updated
logic doesn't appear to do that in all cases. Consider if the current
imap was delalloc (and so not trimmed) or the cow mapping was introduced
after the current imap was mapped. This logic appears to prioritize the
current mapping so long as it is valid. Doesn't that break the
cowextsize hint?

Brian

> +		/*
> +		 * If we don't have a valid map, now it's time to get a new one
> +		 * for this offset.  This will convert delayed allocations
> +		 * (including COW ones) into real extents.  If we return without
> +		 * a valid map, it means we landed in a hole and we skip the
> +		 * block.
> +		 */
>  		if (!wpc->imap_valid) {
> -			error = xfs_map_blocks(inode, offset, &wpc->imap,
> -					     wpc->io_type);
> +			error = xfs_map_blocks(inode, file_offset, &wpc->imap,
> +					     &wpc->io_type);
>  			if (error)
>  				goto out;
>  			wpc->imap_valid = xfs_imap_valid(inode, &wpc->imap,
> -							 offset);
> +							 file_offset);
>  		}
> -		if (wpc->imap_valid) {
> -			lock_buffer(bh);
> -			if (wpc->io_type != XFS_IO_OVERWRITE)
> -				xfs_map_at_offset(inode, bh, &wpc->imap, offset);
> -			xfs_add_to_ioend(inode, bh, offset, wpc, wbc, &submit_list);
> -			count++;
> +
> +		if (!wpc->imap_valid || wpc->io_type == XFS_IO_HOLE) {
> +			/*
> +			 * set_page_dirty dirties all buffers in a page, independent
> +			 * of their state.  The dirty state however is entirely
> +			 * meaningless for holes (!mapped && uptodate), so check we did
> +			 * have a buffer covering a hole here and continue.
> +			 */
> +			continue;
>  		}
>  
> -	} while (offset += len, ((bh = bh->b_this_page) != head));
> +		lock_buffer(bh);
> +		xfs_map_at_offset(inode, bh, &wpc->imap, file_offset);
> +		xfs_add_to_ioend(inode, bh, file_offset, wpc, wbc, &submit_list);
> +		count++;
> +	}
>  
> -	if (uptodate && bh == head)
> +	if (uptodate && poffset == PAGE_SIZE)
>  		SetPageUptodate(page);
>  
>  	ASSERT(wpc->ioend || list_empty(&submit_list));
> diff --git a/fs/xfs/xfs_aops.h b/fs/xfs/xfs_aops.h
> index 69346d460dfa..b2ef5b661761 100644
> --- a/fs/xfs/xfs_aops.h
> +++ b/fs/xfs/xfs_aops.h
> @@ -29,6 +29,7 @@ enum {
>  	XFS_IO_UNWRITTEN,	/* covers allocated but uninitialized data */
>  	XFS_IO_OVERWRITE,	/* covers already allocated extent */
>  	XFS_IO_COW,		/* covers copy-on-write extent */
> +	XFS_IO_HOLE,		/* covers region without any block allocation */
>  };
>  
>  #define XFS_IO_TYPES \
> @@ -36,7 +37,8 @@ enum {
>  	{ XFS_IO_DELALLOC,		"delalloc" }, \
>  	{ XFS_IO_UNWRITTEN,		"unwritten" }, \
>  	{ XFS_IO_OVERWRITE,		"overwrite" }, \
> -	{ XFS_IO_COW,			"CoW" }
> +	{ XFS_IO_COW,			"CoW" }, \
> +	{ XFS_IO_HOLE,			"hole" }
>  
>  /*
>   * Structure for buffered I/O completions.
> -- 
> 2.17.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
