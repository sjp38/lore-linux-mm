Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id F08A56B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 18:31:47 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id kq14so6554004pab.31
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 15:31:47 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id wm3si13131149pab.49.2014.01.27.15.31.45
        for <linux-mm@kvack.org>;
        Mon, 27 Jan 2014 15:31:46 -0800 (PST)
Date: Mon, 27 Jan 2014 16:32:07 -0700 (MST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v5 22/22] XIP: Add support for unwritten extents
In-Reply-To: <CF0C370C.235F1%willy@linux.intel.com>
Message-ID: <alpine.OSX.2.00.1401271617570.9254@scrumpy>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com> <CEFD7DAD.22F65%matthew.r.wilcox@intel.com> <alpine.OSX.2.00.1401221546240.70541@scrumpy> <CF0C370C.235F1%willy@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org

On Thu, 23 Jan 2014, Matthew Wilcox wrote:
> On Wed, Jan 22, 2014 at 03:51:56PM -0700, Ross Zwisler wrote:
> > > +			if (hole) {
> > >  				addr = NULL;
> > > -				hole = true;
> > >  				size = bh->b_size;
> > > +			} else {
> > > +				unsigned first;
> > > +				retval = xip_get_addr(inode, bh, &addr);
> > > +				if (retval < 0)
> > > +					break;
> > > +				size = retval;
> > > +				first = offset - (block << inode->i_blkbits);
> > > +				if (buffer_unwritten(bh))
> > > +					memset(addr, 0, first);
> > > +				addr += first;
> > 
> > +                               size -= first;
> > 
> > This is needed so that we don't overrun the XIP buffer we are given in the
> > event that our user buffer >= our XIP buffer and the start of our I/O isn't
> > block aligned.
> 
> You're right!  Thank you!  However, we also need it for the hole ==
> true case, don't we?  So maybe something like this, incrementally on top of
> patch 22/22:
> 
> P.S. Can someone come up with a better name for this variable than 'first'?
> I'd usually use 'offset', but that's already taken.  'annoying_bit' seems a
> bit judgemental.  'misaligned', maybe?  'skip' or 'seek' like dd uses?
> 
> diff --git a/fs/xip.c b/fs/xip.c
> index 92157ff..1ae00db 100644
> --- a/fs/xip.c
> +++ b/fs/xip.c
> @@ -103,6 +103,7 @@ static ssize_t xip_io(int rw, struct inode *inode, const
> struct iovec *iov,
>  
>  		if (max == offset) {
>  			sector_t block = offset >> inode->i_blkbits;
> +			unsigned first = offset - (block << inode->i_blkbits);
>  			long size;
>  			memset(bh, 0, sizeof(*bh));
>  			bh->b_size = ALIGN(end - offset, PAGE_SIZE);
> @@ -121,14 +122,12 @@ static ssize_t xip_io(int rw, struct inode *inode,
> const struct iovec *iov,
>  
>  			if (hole) {
>  				addr = NULL;
> -				size = bh->b_size;
> +				size = bh->b_size - first;

It looks like we have an additional bit of complexity with the hole case.  The
issue is that for holes, bh->b_size is just the full size of the write as set
earlier in the function:

                        bh->b_size = ALIGN(end - offset, PAGE_SIZE);

>From this code it seems like you hoped the call into get_block() would adjust
bh->b_size to the size of the hole, allowing you to zero just the hole space
in the user buffer.  It doesn't look like it does, though, at least for ext4.
In looking at the direct I/O case (do_direct_IO()), they deal with holes on a
per FS block basis, and don't ever look at bh->b_size once they've figured out
the buffer is unmapped.

The result of this is that when you get a read that starts at a hole but moves
into real data, the read will just see a hole and return data of all zeros.

To just assume the current FS block is a hole, we can do something like this:

diff --git a/fs/xip.c b/fs/xip.c
index 35e401e..e902593 100644
--- a/fs/xip.c
+++ b/fs/xip.c
@@ -122,7 +122,7 @@ static ssize_t xip_io(int rw, struct inode *inode, const struct
 
                        if (hole) {
                                addr = NULL;
-                               size = bh->b_size - first;
+                               size = (1 << inode->i_blkbits) - first;
                        } else {
                                retval = xip_get_addr(inode, bh, &addr);
                                if (retval < 0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
