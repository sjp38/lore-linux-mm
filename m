Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 06D136B0269
	for <linux-mm@kvack.org>; Thu, 31 May 2018 09:49:50 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id e95-v6so14112448otb.15
        for <linux-mm@kvack.org>; Thu, 31 May 2018 06:49:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k4-v6si14079572otf.18.2018.05.31.06.49.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 May 2018 06:49:48 -0700 (PDT)
Date: Thu, 31 May 2018 09:49:47 -0400
From: Brian Foster <bfoster@redhat.com>
Subject: Re: [PATCH 18/18] xfs: allow writeback on pages without buffer heads
Message-ID: <20180531134946.GL2997@bfoster.bfoster>
References: <20180530100013.31358-1-hch@lst.de>
 <20180530100013.31358-19-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530100013.31358-19-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 30, 2018 at 12:00:13PM +0200, Christoph Hellwig wrote:
> Disable the IOMAP_F_BUFFER_HEAD flag on file systems with a block size
> equal to the page size, and deal with pages without buffer heads in
> writeback.  Thanks to the previous refactoring this is basically trivial
> now.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---

Reviewed-by: Brian Foster <bfoster@redhat.com>

>  fs/xfs/xfs_aops.c  | 47 +++++++++++++++++++++++++++++++++-------------
>  fs/xfs/xfs_iomap.c |  3 ++-
>  2 files changed, 36 insertions(+), 14 deletions(-)
> 
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index 84f88cecd2f1..6640377b6eae 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -91,6 +91,19 @@ xfs_find_daxdev_for_inode(
>  		return mp->m_ddev_targp->bt_daxdev;
>  }
>  
> +static void
> +xfs_finish_page_writeback(
> +	struct inode		*inode,
> +	struct bio_vec		*bvec,
> +	int			error)
> +{
> +	if (error) {
> +		SetPageError(bvec->bv_page);
> +		mapping_set_error(inode->i_mapping, -EIO);
> +	}
> +	end_page_writeback(bvec->bv_page);
> +}
> +
>  /*
>   * We're now finished for good with this page.  Update the page state via the
>   * associated buffer_heads, paying attention to the start and end offsets that
> @@ -103,7 +116,7 @@ xfs_find_daxdev_for_inode(
>   * and buffers potentially freed after every call to end_buffer_async_write.
>   */
>  static void
> -xfs_finish_page_writeback(
> +xfs_finish_buffer_writeback(
>  	struct inode		*inode,
>  	struct bio_vec		*bvec,
>  	int			error)
> @@ -178,9 +191,12 @@ xfs_destroy_ioend(
>  			next = bio->bi_private;
>  
>  		/* walk each page on bio, ending page IO on them */
> -		bio_for_each_segment_all(bvec, bio, i)
> -			xfs_finish_page_writeback(inode, bvec, error);
> -
> +		bio_for_each_segment_all(bvec, bio, i) {
> +			if (page_has_buffers(bvec->bv_page))
> +				xfs_finish_buffer_writeback(inode, bvec, error);
> +			else
> +				xfs_finish_page_writeback(inode, bvec, error);
> +		}
>  		bio_put(bio);
>  	}
>  
> @@ -782,13 +798,16 @@ xfs_writepage_map(
>  {
>  	LIST_HEAD(submit_list);
>  	struct xfs_ioend	*ioend, *next;
> -	struct buffer_head	*bh;
> +	struct buffer_head	*bh = NULL;
>  	ssize_t			len = i_blocksize(inode);
>  	int			error = 0;
>  	int			count = 0;
>  	loff_t			file_offset;	/* file offset of page */
>  	unsigned		poffset;	/* offset into page */
>  
> +	if (page_has_buffers(page))
> +		bh = page_buffers(page);
> +
>  	/*
>  	 * Walk the blocks on the page, and we we run off then end of the
>  	 * current map or find the current map invalid, grab a new one.
> @@ -797,11 +816,9 @@ xfs_writepage_map(
>  	 * replace the bufferhead with some other state tracking mechanism in
>  	 * future.
>  	 */
> -	file_offset = page_offset(page);
> -	bh = page_buffers(page);
> -	for (poffset = 0;
> +	for (poffset = 0, file_offset = page_offset(page);
>  	     poffset < PAGE_SIZE;
> -	     poffset += len, file_offset += len, bh = bh->b_this_page) {
> +	     poffset += len, file_offset += len) {
>  		/* past the range we are writing, so nothing more to write. */
>  		if (file_offset >= end_offset)
>  			break;
> @@ -809,9 +826,10 @@ xfs_writepage_map(
>  		/*
>  		 * Block does not contain valid data, skip it.
>  		 */
> -		if (!buffer_uptodate(bh)) {
> +		if (bh && !buffer_uptodate(bh)) {
>  			if (PageUptodate(page))
>  				ASSERT(buffer_mapped(bh));
> +			bh = bh->b_this_page;
>  			continue;
>  		}
>  
> @@ -836,10 +854,15 @@ xfs_writepage_map(
>  			 * meaningless for holes (!mapped && uptodate), so check we did
>  			 * have a buffer covering a hole here and continue.
>  			 */
> +			if (bh)
> +				bh = bh->b_this_page;
>  			continue;
>  		}
>  
> -		xfs_map_at_offset(inode, bh, &wpc->imap, file_offset);
> +		if (bh) {
> +			xfs_map_at_offset(inode, bh, &wpc->imap, file_offset);
> +			bh = bh->b_this_page;
> +		}
>  		xfs_add_to_ioend(inode, file_offset, page, wpc, wbc,
>  				&submit_list);
>  		count++;
> @@ -939,8 +962,6 @@ xfs_do_writepage(
>  
>  	trace_xfs_writepage(inode, page, 0, 0);
>  
> -	ASSERT(page_has_buffers(page));
> -
>  	/*
>  	 * Refuse to write the page out if we are called from reclaim context.
>  	 *
> diff --git a/fs/xfs/xfs_iomap.c b/fs/xfs/xfs_iomap.c
> index f949f0dd7382..93c40da3378a 100644
> --- a/fs/xfs/xfs_iomap.c
> +++ b/fs/xfs/xfs_iomap.c
> @@ -1031,7 +1031,8 @@ xfs_file_iomap_begin(
>  	if (XFS_FORCED_SHUTDOWN(mp))
>  		return -EIO;
>  
> -	iomap->flags |= IOMAP_F_BUFFER_HEAD;
> +	if (i_blocksize(inode) < PAGE_SIZE)
> +		iomap->flags |= IOMAP_F_BUFFER_HEAD;
>  
>  	if (((flags & (IOMAP_WRITE | IOMAP_DIRECT)) == IOMAP_WRITE) &&
>  			!IS_DAX(inode) && !xfs_get_extsz_hint(ip)) {
> -- 
> 2.17.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
