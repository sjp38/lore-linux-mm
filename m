Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id E64C06B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 17:51:50 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id g10so975629pdj.30
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 14:51:50 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id qx4si11491915pbc.225.2014.01.22.14.51.48
        for <linux-mm@kvack.org>;
        Wed, 22 Jan 2014 14:51:49 -0800 (PST)
Date: Wed, 22 Jan 2014 15:51:56 -0700 (MST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v5 22/22] XIP: Add support for unwritten extents
In-Reply-To: <CEFD7DAD.22F65%matthew.r.wilcox@intel.com>
Message-ID: <alpine.OSX.2.00.1401221546240.70541@scrumpy>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com> <CEFD7DAD.22F65%matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org

On Wed, 15 Jan 2014, Matthew Wilcox wrote:

>  static ssize_t xip_io(int rw, struct inode *inode, const struct iovec
> *iov,
>  			loff_t start, loff_t end, unsigned nr_segs,
>  			get_block_t get_block, struct buffer_head *bh)
> @@ -103,21 +109,29 @@ static ssize_t xip_io(int rw, struct inode *inode,
> const struct iovec *iov,
>  			retval = get_block(inode, block, bh, rw == WRITE);
>  			if (retval)
>  				break;
> -			if (buffer_mapped(bh)) {
> -				retval = xip_get_addr(inode, bh, &addr);
> -				if (retval < 0)
> -					break;
> -				addr += offset - (block << inode->i_blkbits);
> -				hole = false;
> -				size = retval;
> -			} else {
> -				if (rw == WRITE) {
> +			if (rw == WRITE) {
> +				if (!buffer_mapped(bh)) {
>  					retval = -EIO;
>  					break;
>  				}
> +				hole = false;
> +			} else {
> +				hole = !buffer_written(bh);
> +			}
> +
> +			if (hole) {
>  				addr = NULL;
> -				hole = true;
>  				size = bh->b_size;
> +			} else {
> +				unsigned first;
> +				retval = xip_get_addr(inode, bh, &addr);
> +				if (retval < 0)
> +					break;
> +				size = retval;
> +				first = offset - (block << inode->i_blkbits);
> +				if (buffer_unwritten(bh))
> +					memset(addr, 0, first);
> +				addr += first;

+                               size -= first;

This is needed so that we don't overrun the XIP buffer we are given in the
event that our user buffer >= our XIP buffer and the start of our I/O isn't
block aligned.

You can add my 
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com> 

Thanks,
- Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
