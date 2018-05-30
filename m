Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 249EA6B0005
	for <linux-mm@kvack.org>; Wed, 30 May 2018 09:34:53 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id e95-v6so11910663otb.15
        for <linux-mm@kvack.org>; Wed, 30 May 2018 06:34:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o186-v6si11770762oib.183.2018.05.30.06.34.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 May 2018 06:34:51 -0700 (PDT)
Date: Wed, 30 May 2018 09:34:49 -0400
From: Brian Foster <bfoster@redhat.com>
Subject: Re: [PATCH 01/18] fs: factor out a __generic_write_end helper
Message-ID: <20180530133448.GA112411@bfoster.bfoster>
References: <20180530100013.31358-1-hch@lst.de>
 <20180530100013.31358-2-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530100013.31358-2-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 30, 2018 at 11:59:56AM +0200, Christoph Hellwig wrote:
> Bits of the buffer.c based write_end implementations that don't know
> about buffer_heads and can be reused by other implementations.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---

Reviewed-by: Brian Foster <bfoster@redhat.com>

>  fs/buffer.c   | 67 +++++++++++++++++++++++++++------------------------
>  fs/internal.h |  2 ++
>  2 files changed, 37 insertions(+), 32 deletions(-)
> 
> diff --git a/fs/buffer.c b/fs/buffer.c
> index 249b83fafe48..bd964b2ad99a 100644
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -2076,6 +2076,40 @@ int block_write_begin(struct address_space *mapping, loff_t pos, unsigned len,
>  }
>  EXPORT_SYMBOL(block_write_begin);
>  
> +int __generic_write_end(struct inode *inode, loff_t pos, unsigned copied,
> +		struct page *page)
> +{
> +	loff_t old_size = inode->i_size;
> +	bool i_size_changed = false;
> +
> +	/*
> +	 * No need to use i_size_read() here, the i_size cannot change under us
> +	 * because we hold i_rwsem.
> +	 *
> +	 * But it's important to update i_size while still holding page lock:
> +	 * page writeout could otherwise come in and zero beyond i_size.
> +	 */
> +	if (pos + copied > inode->i_size) {
> +		i_size_write(inode, pos + copied);
> +		i_size_changed = true;
> +	}
> +
> +	unlock_page(page);
> +	put_page(page);
> +
> +	if (old_size < pos)
> +		pagecache_isize_extended(inode, old_size, pos);
> +	/*
> +	 * Don't mark the inode dirty under page lock. First, it unnecessarily
> +	 * makes the holding time of page lock longer. Second, it forces lock
> +	 * ordering of page lock and transaction start for journaling
> +	 * filesystems.
> +	 */
> +	if (i_size_changed)
> +		mark_inode_dirty(inode);
> +	return copied;
> +}
> +
>  int block_write_end(struct file *file, struct address_space *mapping,
>  			loff_t pos, unsigned len, unsigned copied,
>  			struct page *page, void *fsdata)
> @@ -2116,39 +2150,8 @@ int generic_write_end(struct file *file, struct address_space *mapping,
>  			loff_t pos, unsigned len, unsigned copied,
>  			struct page *page, void *fsdata)
>  {
> -	struct inode *inode = mapping->host;
> -	loff_t old_size = inode->i_size;
> -	int i_size_changed = 0;
> -
>  	copied = block_write_end(file, mapping, pos, len, copied, page, fsdata);
> -
> -	/*
> -	 * No need to use i_size_read() here, the i_size
> -	 * cannot change under us because we hold i_mutex.
> -	 *
> -	 * But it's important to update i_size while still holding page lock:
> -	 * page writeout could otherwise come in and zero beyond i_size.
> -	 */
> -	if (pos+copied > inode->i_size) {
> -		i_size_write(inode, pos+copied);
> -		i_size_changed = 1;
> -	}
> -
> -	unlock_page(page);
> -	put_page(page);
> -
> -	if (old_size < pos)
> -		pagecache_isize_extended(inode, old_size, pos);
> -	/*
> -	 * Don't mark the inode dirty under page lock. First, it unnecessarily
> -	 * makes the holding time of page lock longer. Second, it forces lock
> -	 * ordering of page lock and transaction start for journaling
> -	 * filesystems.
> -	 */
> -	if (i_size_changed)
> -		mark_inode_dirty(inode);
> -
> -	return copied;
> +	return __generic_write_end(mapping->host, pos, copied, page);
>  }
>  EXPORT_SYMBOL(generic_write_end);
>  
> diff --git a/fs/internal.h b/fs/internal.h
> index e08972db0303..b955232d3d49 100644
> --- a/fs/internal.h
> +++ b/fs/internal.h
> @@ -43,6 +43,8 @@ static inline int __sync_blockdev(struct block_device *bdev, int wait)
>  extern void guard_bio_eod(int rw, struct bio *bio);
>  extern int __block_write_begin_int(struct page *page, loff_t pos, unsigned len,
>  		get_block_t *get_block, struct iomap *iomap);
> +int __generic_write_end(struct inode *inode, loff_t pos, unsigned copied,
> +		struct page *page);
>  
>  /*
>   * char_dev.c
> -- 
> 2.17.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
