Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 49C8E6B000D
	for <linux-mm@kvack.org>; Thu, 24 May 2018 10:59:40 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id t1-v6so1088134oth.3
        for <linux-mm@kvack.org>; Thu, 24 May 2018 07:59:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 32-v6si8221808otf.290.2018.05.24.07.59.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 07:59:38 -0700 (PDT)
Date: Thu, 24 May 2018 10:59:36 -0400
From: Brian Foster <bfoster@redhat.com>
Subject: Re: [PATCH 22/34] xfs: make xfs_writepage_map extent map centric
Message-ID: <20180524145935.GA84959@bfoster.bfoster>
References: <20180523144357.18985-1-hch@lst.de>
 <20180523144357.18985-23-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523144357.18985-23-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>

On Wed, May 23, 2018 at 04:43:45PM +0200, Christoph Hellwig wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
...
> 
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index 5dd09e83c81c..a50f69c2c602 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
...
> @@ -845,85 +826,81 @@ xfs_writepage_map(
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

The comment above doesn't make much sense given that we don't check for
anything here and just continue the loop.

That aside, the concern I had with this patch when it was last posted is
that it indirectly dropped the error/consistency check between page
state and extent state provided by the XFS_BMAPI_DELALLOC flag. What was
historically an accounting/reservation issue was turned into something
like this by XFS_BMAPI_DELALLOC:

# xfs_io -c "pwrite 0 4k" -c fsync /mnt/file
wrote 4096/4096 bytes at offset 0
4 KiB, 1 ops; 0.0041 sec (974.184 KiB/sec and 243.5460 ops/sec)
fsync: Input/output error

As of this patch, that same error condition now behaves something like
this:

[root@localhost ~]# xfs_io -c "pwrite 0 4k" -c fsync /mnt/file
wrote 4096/4096 bytes at offset 0
4 KiB, 1 ops; 0.0029 sec (1.325 MiB/sec and 339.2130 ops/sec)
[root@localhost ~]# ls -al /mnt/file
-rw-r--r--. 1 root root 4096 May 24 08:27 /mnt/file
[root@localhost ~]# umount  /mnt ; mount /dev/test/scratch /mnt/
[root@localhost ~]# ls -al /mnt/file
-rw-r--r--. 1 root root 0 May 24 08:27 /mnt/file

So our behavior has changed from forced block allocation (violating
reservation) and writing the data, to instead return an error, and now
to silently skip the page. I suppose there are situations (i.e., races
with truncate) where a hole is valid and the correct behavior is to skip
the page, and this is admittedly an error condition that "should never
happen," but can we at least add an assert somewhere in this series that
ensures if uptodate data maps over a hole that the associated block
offset is beyond EOF (or something of that nature)?

Brian

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
