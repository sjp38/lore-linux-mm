Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC9256B0003
	for <linux-mm@kvack.org>; Wed, 30 May 2018 13:55:37 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id s133-v6so9666022qke.21
        for <linux-mm@kvack.org>; Wed, 30 May 2018 10:55:37 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id i23-v6si10612149qkh.374.2018.05.30.10.55.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 May 2018 10:55:36 -0700 (PDT)
Date: Wed, 30 May 2018 10:55:29 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 13/18] xfs: don't look at buffer heads in xfs_add_to_ioend
Message-ID: <20180530175529.GQ837@magnolia>
References: <20180530100013.31358-1-hch@lst.de>
 <20180530100013.31358-14-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530100013.31358-14-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 30, 2018 at 12:00:08PM +0200, Christoph Hellwig wrote:
> Calculate all information for the bio based on the passed in information
> without requiring a buffer_head structure.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/xfs/xfs_aops.c | 68 ++++++++++++++++++++++-------------------------
>  1 file changed, 32 insertions(+), 36 deletions(-)
> 
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index 910b410e5a90..7d02d04d5a5b 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -44,7 +44,6 @@ struct xfs_writepage_ctx {
>  	struct xfs_bmbt_irec    imap;
>  	unsigned int		io_type;
>  	struct xfs_ioend	*ioend;
> -	sector_t		last_block;
>  };
>  
>  void
> @@ -535,11 +534,6 @@ xfs_start_page_writeback(
>  	unlock_page(page);
>  }
>  
> -static inline int xfs_bio_add_buffer(struct bio *bio, struct buffer_head *bh)
> -{
> -	return bio_add_page(bio, bh->b_page, bh->b_size, bh_offset(bh));
> -}
> -
>  /*
>   * Submit the bio for an ioend. We are passed an ioend with a bio attached to
>   * it, and we submit that bio. The ioend may be used for multiple bio
> @@ -594,27 +588,20 @@ xfs_submit_ioend(
>  	return 0;
>  }
>  
> -static void
> -xfs_init_bio_from_bh(
> -	struct bio		*bio,
> -	struct buffer_head	*bh)
> -{
> -	bio->bi_iter.bi_sector = bh->b_blocknr * (bh->b_size >> 9);
> -	bio_set_dev(bio, bh->b_bdev);
> -}
> -
>  static struct xfs_ioend *
>  xfs_alloc_ioend(
>  	struct inode		*inode,
>  	unsigned int		type,
>  	xfs_off_t		offset,
> -	struct buffer_head	*bh)
> +	struct block_device	*bdev,
> +	sector_t		sector)
>  {
>  	struct xfs_ioend	*ioend;
>  	struct bio		*bio;
>  
>  	bio = bio_alloc_bioset(GFP_NOFS, BIO_MAX_PAGES, xfs_ioend_bioset);
> -	xfs_init_bio_from_bh(bio, bh);
> +	bio_set_dev(bio, bdev);
> +	bio->bi_iter.bi_sector = sector;
>  
>  	ioend = container_of(bio, struct xfs_ioend, io_inline_bio);
>  	INIT_LIST_HEAD(&ioend->io_list);
> @@ -639,13 +626,14 @@ static void
>  xfs_chain_bio(
>  	struct xfs_ioend	*ioend,
>  	struct writeback_control *wbc,
> -	struct buffer_head	*bh)
> +	struct block_device	*bdev,
> +	sector_t		sector)
>  {
>  	struct bio *new;
>  
>  	new = bio_alloc(GFP_NOFS, BIO_MAX_PAGES);
> -	xfs_init_bio_from_bh(new, bh);
> -
> +	bio_set_dev(new, bdev);
> +	new->bi_iter.bi_sector = sector;
>  	bio_chain(ioend->io_bio, new);
>  	bio_get(ioend->io_bio);		/* for xfs_destroy_ioend */
>  	ioend->io_bio->bi_opf = REQ_OP_WRITE | wbc_to_write_flags(wbc);
> @@ -655,39 +643,45 @@ xfs_chain_bio(
>  }
>  
>  /*
> - * Test to see if we've been building up a completion structure for
> - * earlier buffers -- if so, we try to append to this ioend if we
> - * can, otherwise we finish off any current ioend and start another.
> - * Return the ioend we finished off so that the caller can submit it
> - * once it has finished processing the dirty page.
> + * Test to see if we have an existing ioend structure that we could append to
> + * first, otherwise finish off the current ioend and start another.
>   */
>  STATIC void
>  xfs_add_to_ioend(
>  	struct inode		*inode,
> -	struct buffer_head	*bh,
>  	xfs_off_t		offset,
> +	struct page		*page,
>  	struct xfs_writepage_ctx *wpc,
>  	struct writeback_control *wbc,
>  	struct list_head	*iolist)
>  {
> +	struct xfs_inode	*ip = XFS_I(inode);
> +	struct xfs_mount	*mp = ip->i_mount;
> +	struct block_device	*bdev = xfs_find_bdev_for_inode(inode);
> +	unsigned		len = i_blocksize(inode);
> +	unsigned		poff = offset & (PAGE_SIZE - 1);
> +	sector_t		sector;
> +
> +	sector = xfs_fsb_to_db(ip, wpc->imap.br_startblock) +
> +		((offset - XFS_FSB_TO_B(mp, wpc->imap.br_startoff)) >> 9);

" >> SECTOR_SHIFT" here?  If so, I can fix this on its way in.

Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> +
>  	if (!wpc->ioend || wpc->io_type != wpc->ioend->io_type ||
> -	    bh->b_blocknr != wpc->last_block + 1 ||
> +	    sector != bio_end_sector(wpc->ioend->io_bio) ||
>  	    offset != wpc->ioend->io_offset + wpc->ioend->io_size) {
>  		if (wpc->ioend)
>  			list_add(&wpc->ioend->io_list, iolist);
> -		wpc->ioend = xfs_alloc_ioend(inode, wpc->io_type, offset, bh);
> +		wpc->ioend = xfs_alloc_ioend(inode, wpc->io_type, offset,
> +				bdev, sector);
>  	}
>  
>  	/*
> -	 * If the buffer doesn't fit into the bio we need to allocate a new
> -	 * one.  This shouldn't happen more than once for a given buffer.
> +	 * If the block doesn't fit into the bio we need to allocate a new
> +	 * one.  This shouldn't happen more than once for a given block.
>  	 */
> -	while (xfs_bio_add_buffer(wpc->ioend->io_bio, bh) != bh->b_size)
> -		xfs_chain_bio(wpc->ioend, wbc, bh);
> +	while (bio_add_page(wpc->ioend->io_bio, page, len, poff) != len)
> +		xfs_chain_bio(wpc->ioend, wbc, bdev, sector);
>  
> -	wpc->ioend->io_size += bh->b_size;
> -	wpc->last_block = bh->b_blocknr;
> -	xfs_start_buffer_writeback(bh);
> +	wpc->ioend->io_size += len;
>  }
>  
>  STATIC void
> @@ -883,7 +877,9 @@ xfs_writepage_map(
>  
>  		lock_buffer(bh);
>  		xfs_map_at_offset(inode, bh, &wpc->imap, file_offset);
> -		xfs_add_to_ioend(inode, bh, file_offset, wpc, wbc, &submit_list);
> +		xfs_add_to_ioend(inode, file_offset, page, wpc, wbc,
> +				&submit_list);
> +		xfs_start_buffer_writeback(bh);
>  		count++;
>  	}
>  
> -- 
> 2.17.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
