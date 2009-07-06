Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0BC966B005C
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 12:50:38 -0400 (EDT)
Date: Mon, 6 Jul 2009 13:28:38 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [rfc][patch 3/3] fs: convert ext2,tmpfs to new truncate
Message-ID: <20090706172838.GC26042@infradead.org>
References: <20090706165438.GQ2714@wotan.suse.de> <20090706165629.GS2714@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090706165629.GS2714@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 06, 2009 at 06:56:29PM +0200, Nick Piggin wrote:
> 
> Convert filemap_xip.c, buffer.c, and some filesystems to the new truncate
> convention. Converting generic helpers is using some ugly code (testing
> for i_op->ftruncate) to distinguish new and old callers... better
> alternative might be just define a new function for these guys.

Splitting generic preparations, ext2 and shmem into separate patch would
be a tad cleaner I think.

The testing for the new op is pretty ugly, but this should be just a
transition help, so it's fine to me.

>  		struct page **pagep, void **fsdata)
>  {
> +	int ret;
> +
>  	*pagep = NULL;
> -	return __ext2_write_begin(file, mapping, pos, len, flags, pagep,fsdata);
> +	ret = __ext2_write_begin(file, mapping, pos, len, flags, pagep,fsdata);
> +	if (ret < 0) {
> +		loff_t isize = inode->i_size;
> +		if (pos + len > isize)
> +			ext2_ftruncate(NULL, 0, inode, isize);
> +	}
> +	return ret;
> +}
> +
> +static int ext2_write_end(struct file *file, struct address_space *mapping,
> +			loff_t pos, unsigned len, unsigned copied,
> +			struct page *page, void *fsdata)
> +{
> +	int ret;
> +
> +	ret = generic_write_end(file, mapping, pos, len, copied, page, fsdata);
> +	if (ret < len) {
> +		loff_t isize = inode->i_size;
> +		if (pos + len > isize)
> +			ext2_ftruncate(NULL, 0, inode, isize);
> +	}
> +	return ret;
>  }
>  
>  static int
> @@ -770,13 +793,22 @@ ext2_nobh_write_begin(struct file *file,
>  		loff_t pos, unsigned len, unsigned flags,
>  		struct page **pagep, void **fsdata)
>  {
> +	int ret;
> +
>  	/*
>  	 * Dir-in-pagecache still uses ext2_write_begin. Would have to rework
>  	 * directory handling code to pass around offsets rather than struct
>  	 * pages in order to make this work easily.
>  	 */
> -	return nobh_write_begin(file, mapping, pos, len, flags, pagep, fsdata,
> +	ret = nobh_write_begin(file, mapping, pos, len, flags, pagep, fsdata,
>  							ext2_get_block);
> +	if (ret < 0) {
> +		loff_t isize;
> +		isize = i_size_read(inode);
> +		if (pos + len > isize)
> +			ext2_ftruncate(NULL, 0, inode, isize);
> +	}
> +	return ret;
>  }
>  
>  static int ext2_nobh_writepage(struct page *page,
> @@ -796,9 +828,15 @@ ext2_direct_IO(int rw, struct kiocb *ioc
>  {
>  	struct file *file = iocb->ki_filp;
>  	struct inode *inode = file->f_mapping->host;
> +	ssize_t ret;
>  
> -	return blockdev_direct_IO(rw, iocb, inode, inode->i_sb->s_bdev, iov,
> +	ret = blockdev_direct_IO(rw, iocb, inode, inode->i_sb->s_bdev, iov,
>  				offset, nr_segs, ext2_get_block, NULL);
> +	if (ret < 0 && (rw & WRITE)) {
> +		loff_t isize = i_size_read(inode);
> +		ext2_ftruncate(NULL, 0, inode, isize);

These calls don't actually have i_alloc_mutex anymore, do they?

>  {
> -	shmem_truncate_range(inode, inode->i_size, (loff_t)-1);
> +	loff_t oldsize;
> +	int error;
> +
> +	error = inode_truncate_ok(inode, offset);
> +	if (error)
> +		return error;
> +	oldsize = inode->i_size;
> +	i_size_write(inode, offset);
> +	truncate_pagecache(inode, oldsize, offset);
> +	shmem_truncate_range(inode, offset, (loff_t)-1);
> +
> +	return error;
>  }

Just make this

	error = simple_ftruncate(...);
	if (!error)
		shmem_truncate_range(inode, offset, -1);
	return error;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
