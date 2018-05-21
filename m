Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 907406B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 19:27:07 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id u137-v6so17839900itc.4
        for <linux-mm@kvack.org>; Mon, 21 May 2018 16:27:07 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id f65-v6si13531736ith.31.2018.05.21.16.27.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 16:27:06 -0700 (PDT)
Date: Mon, 21 May 2018 16:27:00 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 16/34] iomap: add initial support for writes without
 buffer heads
Message-ID: <20180521232700.GB14384@magnolia>
References: <20180518164830.1552-1-hch@lst.de>
 <20180518164830.1552-17-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180518164830.1552-17-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Fri, May 18, 2018 at 06:48:12PM +0200, Christoph Hellwig wrote:
> For now just limited to blocksize == PAGE_SIZE, where we can simply read
> in the full page in write begin, and just set the whole page dirty after
> copying data into it.  This code is enabled by default and XFS will now
> be feed pages without buffer heads in ->writepage and ->writepages.
> 
> If a file system sets the IOMAP_F_BUFFER_HEAD flag on the iomap the old
> path will still be used, this both helps the transition in XFS and
> prepares for the gfs2 migration to the iomap infrastructure.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/iomap.c            | 132 ++++++++++++++++++++++++++++++++++++++----
>  fs/xfs/xfs_iomap.c    |   6 +-
>  include/linux/iomap.h |   2 +
>  3 files changed, 127 insertions(+), 13 deletions(-)
> 
> diff --git a/fs/iomap.c b/fs/iomap.c
> index 821671af2618..cd4c563db80a 100644
> --- a/fs/iomap.c
> +++ b/fs/iomap.c
> @@ -314,6 +314,58 @@ iomap_write_failed(struct inode *inode, loff_t pos, unsigned len)
>  		truncate_pagecache_range(inode, max(pos, i_size), pos + len);
>  }
>  
> +static int
> +iomap_read_page_sync(struct inode *inode, loff_t block_start, struct page *page,
> +		unsigned poff, unsigned plen, struct iomap *iomap)
> +{
> +	struct bio_vec bvec;
> +	struct bio bio;
> +	int ret;
> +
> +	bio_init(&bio, &bvec, 1);
> +	bio.bi_opf = REQ_OP_READ;
> +	bio.bi_iter.bi_sector = iomap_sector(iomap, block_start);
> +	bio_set_dev(&bio, iomap->bdev);
> +	__bio_add_page(&bio, page, plen, poff);
> +	ret = submit_bio_wait(&bio);
> +	if (ret < 0 && iomap_block_needs_zeroing(inode, block_start, iomap))
> +		zero_user(page, poff, plen);
> +	return ret;
> +}
> +
> +static int
> +__iomap_write_begin(struct inode *inode, loff_t pos, unsigned len,
> +		struct page *page, struct iomap *iomap)
> +{
> +	loff_t block_size = i_blocksize(inode);
> +	loff_t block_start = pos & ~(block_size - 1);
> +	loff_t block_end = (pos + len + block_size - 1) & ~(block_size - 1);
> +	unsigned poff = block_start & (PAGE_SIZE - 1);
> +	unsigned plen = min_t(loff_t, PAGE_SIZE - poff, block_end - block_start);
> +	int status;
> +
> +	WARN_ON_ONCE(i_blocksize(inode) < PAGE_SIZE);
> +
> +	if (PageUptodate(page))
> +		return 0;
> +
> +	if (iomap_block_needs_zeroing(inode, block_start, iomap)) {
> +		unsigned from = pos & (PAGE_SIZE - 1), to = from + len;
> +		unsigned pend = poff + plen;
> +
> +		if (poff < from || pend > to)
> +			zero_user_segments(page, poff, from, to, pend);
> +	} else {
> +		status = iomap_read_page_sync(inode, block_start, page,
> +				poff, plen, iomap);

Something doesn't smell right here.  The only pages we need to read in
are the first and last pages in the write_begin range, and only if they
aren't page aligned and the underlying extent is IOMAP_MAPPED, right?

I also noticed that speculative preallocation kicks in by the second 80M
write() call and writeback for the second call can successfully allocate
the entire preallocation, which means that the third (or nth) write call
can have a real extent already mapped in, and then we end up reading it.

--D

> +		if (status < 0)
> +			return status;
> +		SetPageUptodate(page);
> +	}
> +
> +	return 0;
> +}
> +
>  static int
>  iomap_write_begin(struct inode *inode, loff_t pos, unsigned len, unsigned flags,
>  		struct page **pagep, struct iomap *iomap)
> @@ -331,7 +383,10 @@ iomap_write_begin(struct inode *inode, loff_t pos, unsigned len, unsigned flags,
>  	if (!page)
>  		return -ENOMEM;
>  
> -	status = __block_write_begin_int(page, pos, len, NULL, iomap);
> +	if (iomap->flags & IOMAP_F_BUFFER_HEAD)
> +		status = __block_write_begin_int(page, pos, len, NULL, iomap);
> +	else
> +		status = __iomap_write_begin(inode, pos, len, page, iomap);
>  	if (unlikely(status)) {
>  		unlock_page(page);
>  		put_page(page);
> @@ -344,14 +399,63 @@ iomap_write_begin(struct inode *inode, loff_t pos, unsigned len, unsigned flags,
>  	return status;
>  }
>  
> +int
> +iomap_set_page_dirty(struct page *page)
> +{
> +	struct address_space *mapping = page_mapping(page);
> +	int newly_dirty;
> +
> +	if (unlikely(!mapping))
> +		return !TestSetPageDirty(page);
> +
> +	/*
> +	 * Lock out page->mem_cgroup migration to keep PageDirty
> +	 * synchronized with per-memcg dirty page counters.
> +	 */
> +	lock_page_memcg(page);
> +	newly_dirty = !TestSetPageDirty(page);
> +	if (newly_dirty)
> +		__set_page_dirty(page, mapping, 0);
> +	unlock_page_memcg(page);
> +
> +	if (newly_dirty)
> +		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
> +	return newly_dirty;
> +}
> +EXPORT_SYMBOL_GPL(iomap_set_page_dirty);
> +
> +static int
> +__iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
> +		unsigned copied, struct page *page, struct iomap *iomap)
> +{
> +	unsigned start = pos & (PAGE_SIZE - 1);
> +
> +	if (unlikely(copied < len)) {
> +		/* see block_write_end() for an explanation */
> +		if (!PageUptodate(page))
> +			copied = 0;
> +		if (iomap_block_needs_zeroing(inode, pos, iomap))
> +			zero_user(page, start + copied, len - copied);
> +	}
> +
> +	flush_dcache_page(page);
> +	SetPageUptodate(page);
> +	iomap_set_page_dirty(page);
> +	return __generic_write_end(inode, pos, copied, page);
> +}
> +
>  static int
>  iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
> -		unsigned copied, struct page *page)
> +		unsigned copied, struct page *page, struct iomap *iomap)
>  {
>  	int ret;
>  
> -	ret = generic_write_end(NULL, inode->i_mapping, pos, len,
> -			copied, page, NULL);
> +	if (iomap->flags & IOMAP_F_BUFFER_HEAD)
> +		ret = generic_write_end(NULL, inode->i_mapping, pos, len,
> +				copied, page, NULL);
> +	else
> +		ret = __iomap_write_end(inode, pos, len, copied, page, iomap);
> +
>  	if (ret < len)
>  		iomap_write_failed(inode, pos, len);
>  	return ret;
> @@ -406,7 +510,8 @@ iomap_write_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
>  
>  		flush_dcache_page(page);
>  
> -		status = iomap_write_end(inode, pos, bytes, copied, page);
> +		status = iomap_write_end(inode, pos, bytes, copied, page,
> +				iomap);
>  		if (unlikely(status < 0))
>  			break;
>  		copied = status;
> @@ -500,7 +605,7 @@ iomap_dirty_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
>  
>  		WARN_ON_ONCE(!PageUptodate(page));
>  
> -		status = iomap_write_end(inode, pos, bytes, bytes, page);
> +		status = iomap_write_end(inode, pos, bytes, bytes, page, iomap);
>  		if (unlikely(status <= 0)) {
>  			if (WARN_ON_ONCE(status == 0))
>  				return -EIO;
> @@ -552,7 +657,7 @@ static int iomap_zero(struct inode *inode, loff_t pos, unsigned offset,
>  	zero_user(page, offset, bytes);
>  	mark_page_accessed(page);
>  
> -	return iomap_write_end(inode, pos, bytes, bytes, page);
> +	return iomap_write_end(inode, pos, bytes, bytes, page, iomap);
>  }
>  
>  static int iomap_dax_zero(loff_t pos, unsigned offset, unsigned bytes,
> @@ -638,11 +743,16 @@ iomap_page_mkwrite_actor(struct inode *inode, loff_t pos, loff_t length,
>  	struct page *page = data;
>  	int ret;
>  
> -	ret = __block_write_begin_int(page, pos, length, NULL, iomap);
> -	if (ret)
> -		return ret;
> +	if (iomap->flags & IOMAP_F_BUFFER_HEAD) {
> +		ret = __block_write_begin_int(page, pos, length, NULL, iomap);
> +		if (ret)
> +			return ret;
> +		block_commit_write(page, 0, length);
> +	} else {
> +		WARN_ON_ONCE(!PageUptodate(page));
> +		WARN_ON_ONCE(i_blocksize(inode) < PAGE_SIZE);
> +	}
>  
> -	block_commit_write(page, 0, length);
>  	return length;
>  }
>  
> diff --git a/fs/xfs/xfs_iomap.c b/fs/xfs/xfs_iomap.c
> index c6ce6f9335b6..da6d1995e460 100644
> --- a/fs/xfs/xfs_iomap.c
> +++ b/fs/xfs/xfs_iomap.c
> @@ -638,7 +638,7 @@ xfs_file_iomap_begin_delay(
>  	 * Flag newly allocated delalloc blocks with IOMAP_F_NEW so we punch
>  	 * them out if the write happens to fail.
>  	 */
> -	iomap->flags = IOMAP_F_NEW;
> +	iomap->flags |= IOMAP_F_NEW;
>  	trace_xfs_iomap_alloc(ip, offset, count, 0, &got);
>  done:
>  	if (isnullstartblock(got.br_startblock))
> @@ -1031,6 +1031,8 @@ xfs_file_iomap_begin(
>  	if (XFS_FORCED_SHUTDOWN(mp))
>  		return -EIO;
>  
> +	iomap->flags |= IOMAP_F_BUFFER_HEAD;
> +
>  	if (((flags & (IOMAP_WRITE | IOMAP_DIRECT)) == IOMAP_WRITE) &&
>  			!IS_DAX(inode) && !xfs_get_extsz_hint(ip)) {
>  		/* Reserve delalloc blocks for regular writeback. */
> @@ -1131,7 +1133,7 @@ xfs_file_iomap_begin(
>  	if (error)
>  		return error;
>  
> -	iomap->flags = IOMAP_F_NEW;
> +	iomap->flags |= IOMAP_F_NEW;
>  	trace_xfs_iomap_alloc(ip, offset, length, 0, &imap);
>  
>  out_finish:
> diff --git a/include/linux/iomap.h b/include/linux/iomap.h
> index 7300d30ca495..4d3d9d0cd69f 100644
> --- a/include/linux/iomap.h
> +++ b/include/linux/iomap.h
> @@ -30,6 +30,7 @@ struct vm_fault;
>   */
>  #define IOMAP_F_NEW		0x01	/* blocks have been newly allocated */
>  #define IOMAP_F_DIRTY		0x02	/* uncommitted metadata */
> +#define IOMAP_F_BUFFER_HEAD	0x04	/* file system requires buffer heads */
>  
>  /*
>   * Flags that only need to be reported for IOMAP_REPORT requests:
> @@ -92,6 +93,7 @@ ssize_t iomap_file_buffered_write(struct kiocb *iocb, struct iov_iter *from,
>  int iomap_readpage(struct page *page, const struct iomap_ops *ops);
>  int iomap_readpages(struct address_space *mapping, struct list_head *pages,
>  		unsigned nr_pages, const struct iomap_ops *ops);
> +int iomap_set_page_dirty(struct page *page);
>  int iomap_file_dirty(struct inode *inode, loff_t pos, loff_t len,
>  		const struct iomap_ops *ops);
>  int iomap_zero_range(struct inode *inode, loff_t pos, loff_t len,
> -- 
> 2.17.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
