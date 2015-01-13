Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 521C16B0071
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 15:59:53 -0500 (EST)
Received: by mail-qg0-f49.google.com with SMTP id f51so4142602qge.8
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 12:59:53 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id q9si28365908qgq.83.2015.01.13.12.59.51
        for <linux-mm@kvack.org>;
        Tue, 13 Jan 2015 12:59:52 -0800 (PST)
Date: Tue, 13 Jan 2015 15:59:49 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v12 06/20] dax,ext2: Replace XIP read and write with DAX
 I/O
Message-ID: <20150113205949.GI5661@wil.cx>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
 <1414185652-28663-7-git-send-email-matthew.r.wilcox@intel.com>
 <20150112150941.ab63f50561322415cca7eca9@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150112150941.ab63f50561322415cca7eca9@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@linux.intel.com

On Mon, Jan 12, 2015 at 03:09:41PM -0800, Andrew Morton wrote:
> On Fri, 24 Oct 2014 17:20:38 -0400 Matthew Wilcox <matthew.r.wilcox@intel.com> wrote:
> > +/*
> > + * When ext4 encounters a hole, it returns without modifying the buffer_head
> > + * which means that we can't trust b_size.  To cope with this, we set b_state
> > + * to 0 before calling get_block and, if any bit is set, we know we can trust
> > + * b_size.  Unfortunate, really, since ext4 knows precisely how long a hole is
> > + * and would save us time calling get_block repeatedly.
> > + */
> > +static bool buffer_size_valid(struct buffer_head *bh)
> > +{
> > +	return bh->b_state != 0;
> > +}
> 
> Yitch.  Is there a cleaner way of doing this?

I'm hoping to fix ext* and then this problem can go away ...

> > +static ssize_t dax_io(int rw, struct inode *inode, struct iov_iter *iter,
> > +			loff_t start, loff_t end, get_block_t get_block,
> > +			struct buffer_head *bh)
> 
> hm, some documentation would be nice.  I expected "dax_io" to do IO,
> but this doesn't.  Is it well named?

It does do I/O!

> > +		if (rw == WRITE)
> > +			len = copy_from_iter(addr, max - pos, iter);
> > +		else if (!hole)
> > +			len = copy_to_iter(addr, max - pos, iter);
> > +		else
> > +			len = iov_iter_zero(max - pos, iter);

> > + * This function uses the same locking scheme as do_blockdev_direct_IO:
> > + * If @flags has DIO_LOCKING set, we assume that the i_mutex is held by the
> > + * caller for writes.  For reads, we take and release the i_mutex ourselves.
> > + * If DIO_LOCKING is not set, the filesystem takes care of its own locking.
> > + * As with do_blockdev_direct_IO(), we increment i_dio_count while the I/O
> > + * is in progress.
> 
> It would be helpful here to explain *why* this code uses i_dio_count:
> what is trying to protect (against)?

Rather than just referencing the documentation in fs/direct_io.c?  I
find it tends to get stale if we have documentation in multiple places.

> Oh, is that how it works ;)
> 
> Perhaps a few BUG_ON(!mutex_is_locked(&inode->i_mutex)) would clarfiy
> and prevent mistakes.

Perhaps ... although there aren't any in blockdev_direct_IO(), and all the
callers are of the form:

	if (IS_DAX)
		dax_do_io()
	else
		blockdev_direct_IO()

so they've already got their flags and locking sorted out.

> > + */
> > +ssize_t dax_do_io(int rw, struct kiocb *iocb, struct inode *inode,
> > +			struct iov_iter *iter, loff_t pos,
> > +			get_block_t get_block, dio_iodone_t end_io, int flags)
> >
> > ...
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
