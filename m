Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 545886B0006
	for <linux-mm@kvack.org>; Mon, 21 May 2018 15:53:11 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id 76-v6so12865012ioh.6
        for <linux-mm@kvack.org>; Mon, 21 May 2018 12:53:11 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id u62-v6si12694624itf.98.2018.05.21.12.53.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 12:53:10 -0700 (PDT)
Date: Mon, 21 May 2018 12:53:04 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 05/34] fs: use ->is_partially_uptodate in
 page_cache_seek_hole_data
Message-ID: <20180521195304.GA14384@magnolia>
References: <20180518164830.1552-1-hch@lst.de>
 <20180518164830.1552-6-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180518164830.1552-6-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Fri, May 18, 2018 at 06:48:01PM +0200, Christoph Hellwig wrote:
> This way the implementation doesn't depend on buffer_head internals.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/iomap.c | 83 +++++++++++++++++++++++++++---------------------------
>  1 file changed, 42 insertions(+), 41 deletions(-)
> 
> diff --git a/fs/iomap.c b/fs/iomap.c
> index bef5e91d40bf..0fecd5789d7b 100644
> --- a/fs/iomap.c
> +++ b/fs/iomap.c
> @@ -594,31 +594,54 @@ EXPORT_SYMBOL_GPL(iomap_fiemap);
>   *
>   * Returns the offset within the file on success, and -ENOENT otherwise.

This comment is now wrong, since we return the offset via *lastoff and I
think the return value is whether or not we found what we were looking
for...?

>   */
> -static loff_t
> -page_seek_hole_data(struct page *page, loff_t lastoff, int whence)
> +static bool
> +page_seek_hole_data(struct inode *inode, struct page *page, loff_t *lastoff,
> +		int whence)
>  {
> -	loff_t offset = page_offset(page);
> -	struct buffer_head *bh, *head;
> +	const struct address_space_operations *ops = inode->i_mapping->a_ops;
> +	unsigned int bsize = i_blocksize(inode), off;
>  	bool seek_data = whence == SEEK_DATA;
> +	loff_t poff = page_offset(page);
>  
> -	if (lastoff < offset)
> -		lastoff = offset;
> -
> -	bh = head = page_buffers(page);
> -	do {
> -		offset += bh->b_size;
> -		if (lastoff >= offset)
> -			continue;
> +	if (WARN_ON_ONCE(*lastoff >= poff + PAGE_SIZE))
> +		return false;
>  
> +	if (*lastoff < poff) {
>  		/*
> -		 * Any buffer with valid data in it should have BH_Uptodate set.
> +		 * Last offset smaller than the start of the page means we found
> +		 * a hole:
>  		 */
> -		if (buffer_uptodate(bh) == seek_data)
> -			return lastoff;
> +		if (whence == SEEK_HOLE)
> +			return true;
> +		*lastoff = poff;
> +	}
>  
> -		lastoff = offset;
> -	} while ((bh = bh->b_this_page) != head);
> -	return -ENOENT;
> +	/*
> +	 * Just check the page unless we can and should check block ranges:
> +	 */
> +	if (bsize == PAGE_SIZE || !ops->is_partially_uptodate) {
> +		if (PageUptodate(page) == seek_data)
> +			return true;
> +		return false;

return PageUptodate(page) == seek_data; ?

--D

> +	}
> +
> +	lock_page(page);
> +	if (unlikely(page->mapping != inode->i_mapping))
> +		goto out_unlock_not_found;
> +
> +	for (off = 0; off < PAGE_SIZE; off += bsize) {
> +		if ((*lastoff & ~PAGE_MASK) >= off + bsize)
> +			continue;
> +		if (ops->is_partially_uptodate(page, off, bsize) == seek_data) {
> +			unlock_page(page);
> +			return true;
> +		}
> +		*lastoff = poff + off + bsize;
> +	}
> +
> +out_unlock_not_found:
> +	unlock_page(page);
> +	return false;
>  }
>  
>  /*
> @@ -655,30 +678,8 @@ page_cache_seek_hole_data(struct inode *inode, loff_t offset, loff_t length,
>  		for (i = 0; i < nr_pages; i++) {
>  			struct page *page = pvec.pages[i];
>  
> -			/*
> -			 * At this point, the page may be truncated or
> -			 * invalidated (changing page->mapping to NULL), or
> -			 * even swizzled back from swapper_space to tmpfs file
> -			 * mapping.  However, page->index will not change
> -			 * because we have a reference on the page.
> -                         *
> -			 * If current page offset is beyond where we've ended,
> -			 * we've found a hole.
> -                         */
> -			if (whence == SEEK_HOLE &&
> -			    lastoff < page_offset(page))
> +			if (page_seek_hole_data(inode, page, &lastoff, whence))
>  				goto check_range;
> -
> -			lock_page(page);
> -			if (likely(page->mapping == inode->i_mapping) &&
> -			    page_has_buffers(page)) {
> -				lastoff = page_seek_hole_data(page, lastoff, whence);
> -				if (lastoff >= 0) {
> -					unlock_page(page);
> -					goto check_range;
> -				}
> -			}
> -			unlock_page(page);
>  			lastoff = page_offset(page) + PAGE_SIZE;
>  		}
>  		pagevec_release(&pvec);
> -- 
> 2.17.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
