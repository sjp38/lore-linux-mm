Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2ADA86B0071
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 18:09:44 -0500 (EST)
Received: by mail-yh0-f42.google.com with SMTP id v1so11036760yhn.1
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 15:09:43 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r83si9869317ykc.117.2015.01.12.15.09.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jan 2015 15:09:43 -0800 (PST)
Date: Mon, 12 Jan 2015 15:09:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v12 06/20] dax,ext2: Replace XIP read and write with DAX
 I/O
Message-Id: <20150112150941.ab63f50561322415cca7eca9@linux-foundation.org>
In-Reply-To: <1414185652-28663-7-git-send-email-matthew.r.wilcox@intel.com>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
	<1414185652-28663-7-git-send-email-matthew.r.wilcox@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@linux.intel.com

On Fri, 24 Oct 2014 17:20:38 -0400 Matthew Wilcox <matthew.r.wilcox@intel.com> wrote:

> Use the generic AIO infrastructure instead of custom read and write
> methods.  In addition to giving us support for AIO, this adds the missing
> locking between read() and truncate().
> 
> ...
>
> +/*
> + * When ext4 encounters a hole, it returns without modifying the buffer_head
> + * which means that we can't trust b_size.  To cope with this, we set b_state
> + * to 0 before calling get_block and, if any bit is set, we know we can trust
> + * b_size.  Unfortunate, really, since ext4 knows precisely how long a hole is
> + * and would save us time calling get_block repeatedly.
> + */
> +static bool buffer_size_valid(struct buffer_head *bh)
> +{
> +	return bh->b_state != 0;
> +}

Yitch.  Is there a cleaner way of doing this?

> +static ssize_t dax_io(int rw, struct inode *inode, struct iov_iter *iter,
> +			loff_t start, loff_t end, get_block_t get_block,
> +			struct buffer_head *bh)

hm, some documentation would be nice.  I expected "dax_io" to do IO,
but this doesn't.  Is it well named?

> +{
> +	ssize_t retval = 0;
> +	loff_t pos = start;
> +	loff_t max = start;
> +	loff_t bh_max = start;
> +	void *addr;
> +	bool hole = false;
> +
> +	if (rw != WRITE)
> +		end = min(end, i_size_read(inode));
> +
> +	while (pos < end) {
> +		unsigned len;
> +		if (pos == max) {
> +			unsigned blkbits = inode->i_blkbits;
> +			sector_t block = pos >> blkbits;
> +			unsigned first = pos - (block << blkbits);
> +			long size;
> +
> +			if (pos == bh_max) {
> +				bh->b_size = PAGE_ALIGN(end - pos);
> +				bh->b_state = 0;
> +				retval = get_block(inode, block, bh,
> +								rw == WRITE);
> +				if (retval)
> +					break;
> +				if (!buffer_size_valid(bh))
> +					bh->b_size = 1 << blkbits;
> +				bh_max = pos - first + bh->b_size;
> +			} else {
> +				unsigned done = bh->b_size -
> +						(bh_max - (pos - first));
> +				bh->b_blocknr += done >> blkbits;
> +				bh->b_size -= done;
> +			}
> +
> +			hole = (rw != WRITE) && !buffer_written(bh);
> +			if (hole) {
> +				addr = NULL;
> +				size = bh->b_size - first;
> +			} else {
> +				retval = dax_get_addr(bh, &addr, blkbits);
> +				if (retval < 0)
> +					break;
> +				if (buffer_unwritten(bh) || buffer_new(bh))
> +					dax_new_buf(addr, retval, first, pos,
> +									end);
> +				addr += first;
> +				size = retval - first;
> +			}
> +			max = min(pos + size, end);
> +		}
> +
> +		if (rw == WRITE)
> +			len = copy_from_iter(addr, max - pos, iter);
> +		else if (!hole)
> +			len = copy_to_iter(addr, max - pos, iter);
> +		else
> +			len = iov_iter_zero(max - pos, iter);
> +
> +		if (!len)
> +			break;
> +
> +		pos += len;
> +		addr += len;
> +	}
> +
> +	return (pos == start) ? retval : pos - start;
> +}
> +
> +/**
> + * dax_do_io - Perform I/O to a DAX file
> + * @rw: READ to read or WRITE to write
> + * @iocb: The control block for this I/O
> + * @inode: The file which the I/O is directed at
> + * @iter: The addresses to do I/O from or to
> + * @pos: The file offset where the I/O starts
> + * @get_block: The filesystem method used to translate file offsets to blocks
> + * @end_io: A filesystem callback for I/O completion
> + * @flags: See below
> + *
> + * This function uses the same locking scheme as do_blockdev_direct_IO:
> + * If @flags has DIO_LOCKING set, we assume that the i_mutex is held by the
> + * caller for writes.  For reads, we take and release the i_mutex ourselves.
> + * If DIO_LOCKING is not set, the filesystem takes care of its own locking.
> + * As with do_blockdev_direct_IO(), we increment i_dio_count while the I/O
> + * is in progress.

It would be helpful here to explain *why* this code uses i_dio_count:
what is trying to protect (against)?

Oh, is that how it works ;)

Perhaps a few BUG_ON(!mutex_is_locked(&inode->i_mutex)) would clarfiy
and prevent mistakes.

> + */
> +ssize_t dax_do_io(int rw, struct kiocb *iocb, struct inode *inode,
> +			struct iov_iter *iter, loff_t pos,
> +			get_block_t get_block, dio_iodone_t end_io, int flags)
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
