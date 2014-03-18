Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 206BB6B0118
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 14:44:32 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id rd3so7703324pab.25
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 11:44:31 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id zm8si13052531pac.358.2014.03.18.11.44.29
        for <linux-mm@kvack.org>;
        Tue, 18 Mar 2014 11:44:30 -0700 (PDT)
Date: Tue, 18 Mar 2014 12:45:29 -0600 (MDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v6 20/22] ext4: Add DAX functionality
In-Reply-To: <CF4DEE22.25C8F%matthew.r.wilcox@intel.com>
Message-ID: <alpine.OSX.2.00.1403181236280.8685@scrumpy>
References: <1393337918-28265-1-git-send-email-matthew.r.wilcox@intel.com> <CF4DEE22.25C8F%matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, willy@linux.intel.com, Ross Zwisler <ross.zwisler@linux.intel.com>

On Tue, 25 Feb 2014, Matthew Wilcox wrote:
> From: Ross Zwisler <ross.zwisler@linux.intel.com>
> 
> This is a port of the DAX functionality found in the current version of
> ext2.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
> [heavily tweaked]
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>

...

> diff --git a/fs/ext4/indirect.c b/fs/ext4/indirect.c
> index 594009f..dbdacef 100644
> --- a/fs/ext4/indirect.c
> +++ b/fs/ext4/indirect.c
> @@ -686,15 +686,22 @@ retry:
>  			inode_dio_done(inode);
>  			goto locked;
>  		}
> -		ret = __blockdev_direct_IO(rw, iocb, inode,
> -				 inode->i_sb->s_bdev, iov,
> -				 offset, nr_segs,
> -				 ext4_get_block, NULL, NULL, 0);
> +		if (IS_DAX(inode))
> +			ret = dax_do_io(rw, iocb, inode, iov, offset, nr_segs,
> +					ext4_get_block, NULL, 0);
> +		else
> +			ret = __blockdev_direct_IO(rw, iocb, inode,
> +					inode->i_sb->s_bdev, iov, offset,
> +					nr_segs, ext4_get_block, NULL, NULL, 0);
>  		inode_dio_done(inode);
>  	} else {
>  locked:
> -		ret = blockdev_direct_IO(rw, iocb, inode, iov,
> -				 offset, nr_segs, ext4_get_block);
> +		if (IS_DAX(inode))
> +			ret = dax_do_io(rw, iocb, inode, iov, offset, nr_segs,
> +					ext4_get_block, NULL, 0);

We need to pass in a DIO_LOCKING flag to this call to dax_do_io.  This flag is
provided correctly in ext2_direct_IO which is the only other place I found
where we have a call to dax_do_io as an alternative to blockdev_direct_IO.

The other calls to dax_do_io are alternatives to __blockdev_direct_IO, which
has an explicit flags parameter.  I believe all of these cases are being
handled correctly.

- Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
