Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7D4B56B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 10:56:09 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id zy2so297003682pac.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 07:56:09 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id tp1si1380957pac.137.2016.05.02.07.56.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 07:56:08 -0700 (PDT)
Date: Mon, 2 May 2016 07:56:06 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v4 5/7] fs: prioritize and separate direct_io from dax_io
Message-ID: <20160502145606.GD20589@infradead.org>
References: <1461878218-3844-1-git-send-email-vishal.l.verma@intel.com>
 <1461878218-3844-6-git-send-email-vishal.l.verma@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461878218-3844-6-git-send-email-vishal.l.verma@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vishal Verma <vishal.l.verma@intel.com>
Cc: linux-nvdimm@ml01.01.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <matthew@wil.cx>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@fb.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Jeff Moyer <jmoyer@redhat.com>

> index 79defba..97a1f5f 100644
> --- a/fs/block_dev.c
> +++ b/fs/block_dev.c
> @@ -167,12 +167,21 @@ blkdev_direct_IO(struct kiocb *iocb, struct iov_iter *iter, loff_t offset)
>  	struct file *file = iocb->ki_filp;
>  	struct inode *inode = bdev_file_inode(file);
>  
> -	if (IS_DAX(inode))
> +	if (iocb_is_direct(iocb))
> +		return __blockdev_direct_IO(iocb, inode, I_BDEV(inode), iter,
> +					    offset, blkdev_get_block, NULL,
> +					    NULL, DIO_SKIP_DIO_COUNT);
> +	else if (iocb_is_dax(iocb))
>  		return dax_do_io(iocb, inode, iter, offset, blkdev_get_block,
>  				NULL, DIO_SKIP_DIO_COUNT);
> -	return __blockdev_direct_IO(iocb, inode, I_BDEV(inode), iter, offset,
> -				    blkdev_get_block, NULL, NULL,
> -				    DIO_SKIP_DIO_COUNT);
> +	else {
> +		/*
> +		 * If we're in the direct_IO path, either the IOCB_DIRECT or
> +		 * IOCB_DAX flags must be set.
> +		 */
> +		WARN_ONCE(1, "Kernel Bug with iocb flags\n");
> +		return -ENXIO;
> +	}

DAX should not even end up in ->direct_IO.

> --- a/fs/xfs/xfs_file.c
> +++ b/fs/xfs/xfs_file.c
> @@ -300,7 +300,7 @@ xfs_file_read_iter(
>  
>  	XFS_STATS_INC(mp, xs_read_calls);
>  
> -	if (unlikely(iocb->ki_flags & IOCB_DIRECT))
> +	if (unlikely(iocb->ki_flags & (IOCB_DIRECT | IOCB_DAX)))
>  		ioflags |= XFS_IO_ISDIRECT;

please also add a XFS_IO_ISDAX flag to propagate the information
properly and allow tracing to display the actual I/O type.

> +static inline bool iocb_is_dax(struct kiocb *iocb)
>  {
> +	return IS_DAX(file_inode(iocb->ki_filp)) &&
> +		(iocb->ki_flags & IOCB_DAX);
> +}
> +
> +static inline bool iocb_is_direct(struct kiocb *iocb)
> +{
> +	return iocb->ki_flags & IOCB_DIRECT;
>  }

No need for these helpers - especially as IOCB_DAX should never be set
if IS_DAX is false.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
