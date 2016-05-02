Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2C27E6B0253
	for <linux-mm@kvack.org>; Mon,  2 May 2016 11:45:40 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e190so412791086pfe.3
        for <linux-mm@kvack.org>; Mon, 02 May 2016 08:45:40 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id fk7si23054559pab.97.2016.05.02.08.45.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 08:45:39 -0700 (PDT)
Message-ID: <1462203935.11211.15.camel@kernel.org>
Subject: Re: [PATCH v4 5/7] fs: prioritize and separate direct_io from dax_io
From: Vishal Verma <vishal@kernel.org>
Date: Mon, 02 May 2016 09:45:35 -0600
In-Reply-To: <20160502145606.GD20589@infradead.org>
References: <1461878218-3844-1-git-send-email-vishal.l.verma@intel.com>
	 <1461878218-3844-6-git-send-email-vishal.l.verma@intel.com>
	 <20160502145606.GD20589@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Vishal Verma <vishal.l.verma@intel.com>
Cc: linux-nvdimm@ml01.01.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <matthew@wil.cx>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@fb.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jeff Moyer <jmoyer@redhat.com>

On Mon, 2016-05-02 at 07:56 -0700, Christoph Hellwig wrote:
> > 
> > index 79defba..97a1f5f 100644
> > --- a/fs/block_dev.c
> > +++ b/fs/block_dev.c
> > @@ -167,12 +167,21 @@ blkdev_direct_IO(struct kiocb *iocb, struct
> > iov_iter *iter, loff_t offset)
> > A 	struct file *file = iocb->ki_filp;
> > A 	struct inode *inode = bdev_file_inode(file);
> > A 
> > -	if (IS_DAX(inode))
> > +	if (iocb_is_direct(iocb))
> > +		return __blockdev_direct_IO(iocb, inode,
> > I_BDEV(inode), iter,
> > +					A A A A offset,
> > blkdev_get_block, NULL,
> > +					A A A A NULL,
> > DIO_SKIP_DIO_COUNT);
> > +	else if (iocb_is_dax(iocb))
> > A 		return dax_do_io(iocb, inode, iter, offset,
> > blkdev_get_block,
> > A 				NULL, DIO_SKIP_DIO_COUNT);
> > -	return __blockdev_direct_IO(iocb, inode, I_BDEV(inode),
> > iter, offset,
> > -				A A A A blkdev_get_block, NULL, NULL,
> > -				A A A A DIO_SKIP_DIO_COUNT);
> > +	else {
> > +		/*
> > +		A * If we're in the direct_IO path, either the
> > IOCB_DIRECT or
> > +		A * IOCB_DAX flags must be set.
> > +		A */
> > +		WARN_ONCE(1, "Kernel Bug with iocb flags\n");
> > +		return -ENXIO;
> > +	}
> DAX should not even end up in ->direct_IO.

Do you mean to say remove the last 'else' clause entirely?
I agree that it should never be hit, which is why it is a WARN..
But I'm happy to remove it.

> 
> > 
> > --- a/fs/xfs/xfs_file.c
> > +++ b/fs/xfs/xfs_file.c
> > @@ -300,7 +300,7 @@ xfs_file_read_iter(
> > A 
> > A 	XFS_STATS_INC(mp, xs_read_calls);
> > A 
> > -	if (unlikely(iocb->ki_flags & IOCB_DIRECT))
> > +	if (unlikely(iocb->ki_flags & (IOCB_DIRECT | IOCB_DAX)))
> > A 		ioflags |= XFS_IO_ISDIRECT;
> please also add a XFS_IO_ISDAX flag to propagate the information
> properly and allow tracing to display the actual I/O type.

Will do.

> 
> > 
> > +static inline bool iocb_is_dax(struct kiocb *iocb)
> > A {
> > +	return IS_DAX(file_inode(iocb->ki_filp)) &&
> > +		(iocb->ki_flags & IOCB_DAX);
> > +}
> > +
> > +static inline bool iocb_is_direct(struct kiocb *iocb)
> > +{
> > +	return iocb->ki_flags & IOCB_DIRECT;
> > A }
> No need for these helpers - especially as IOCB_DAX should never be
> set
> if IS_DAX is false.

Ok. So check the flags directly where needed?

> --
> To unsubscribe from this list: send the line "unsubscribe linux-
> block" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info atA A http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
