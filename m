Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4742B6B0031
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 19:17:22 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so1634766pdi.16
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 16:17:21 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id xt7si1739203pab.471.2014.04.08.16.17.20
        for <linux-mm@kvack.org>;
        Tue, 08 Apr 2014 16:17:21 -0700 (PDT)
Date: Tue, 8 Apr 2014 16:21:02 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v7 06/22] Replace XIP read and write with DAX I/O
Message-ID: <20140408202102.GB5727@linux.intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <3ebe329d8713f7db4c105021a845316a47a29797.1395591795.git.matthew.r.wilcox@intel.com>
 <20140408175600.GE2713@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140408175600.GE2713@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Apr 08, 2014 at 07:56:00PM +0200, Jan Kara wrote:
> > +static void dax_new_buf(void *addr, unsigned size, unsigned first,
> > +					loff_t offset, loff_t end, int rw)
> > +{
> > +	loff_t final = end - offset + first; /* The final byte of the buffer */
> > +	if (rw != WRITE) {
> > +		memset(addr, 0, size);
> > +		return;
> > +	}
>   It seems counterintuitive to zero out "on-disk" blocks (it seems you'd do
> this for unwritten blocks) when reading from them. Presumably it could also
> have undesired effects on endurance of persistent memory. Instead I'd expect
> that you simply zero out user provided buffer the same way as you do it for
> holes.

I think we have to zero it here, because the second time we call
get_block() for a given block, it won't be BH_New any more, so we won't
know that it's supposed to be zeroed.

> > +/*
> > + * When ext4 encounters a hole, it likes to return without modifying the
> > + * buffer_head which means that we can't trust b_size.  To cope with this,
> > + * we set b_state to 0 before calling get_block and, if any bit is set, we
> > + * know we can trust b_size.  Unfortunate, really, since ext4 does know
> > + * precisely how long a hole is and would save us time calling get_block
> > + * repeatedly.
>   Well, this is really a problem of get_blocks() returning the result in
> struct buffer_head which is used for input as well. I don't think it is
> actually ext4 specific.

Of course it's ext4 specific!  It's the ext4_get_block() implementation
which is choosing not to return the length of the hole.  XFS does return
the length of the hole.  I think something like this would fix it:

+++ b/fs/ext4/inode.c
@@ -727,14 +727,14 @@ static int _ext4_get_block(struct inode *inode, sector_t i
        }
 
        ret = ext4_map_blocks(handle, inode, &map, flags);
+       map_bh(bh, inode->i_sb, map.m_pblk);
+       bh->b_state = (bh->b_state & ~EXT4_MAP_FLAGS) | map.m_flags;
+       bh->b_size = inode->i_sb->s_blocksize * map.m_len;
        if (ret > 0) {
                ext4_io_end_t *io_end = ext4_inode_aio(inode);
 
-               map_bh(bh, inode->i_sb, map.m_pblk);
-               bh->b_state = (bh->b_state & ~EXT4_MAP_FLAGS) | map.m_flags;
                if (io_end && io_end->flag & EXT4_IO_END_UNWRITTEN)
                        set_buffer_defer_completion(bh);
-               bh->b_size = inode->i_sb->s_blocksize * map.m_len;
                ret = 0;
        }
        if (started)

(completely untested).

> > +	while (offset < end) {
> > +		void __user *buf = iov[seg].iov_base + copied;
> > +
> > +		if (offset == max) {
> > +			sector_t block = offset >> inode->i_blkbits;
> > +			unsigned first = offset - (block << inode->i_blkbits);
> > +			long size;
> > +
> > +			if (offset == bh_max) {
> > +				bh->b_size = PAGE_ALIGN(end - offset);
> > +				bh->b_state = 0;
> > +				retval = get_block(inode, block, bh,
> > +								rw == WRITE);
> > +				if (retval)
> > +					break;
> > +				if (!buffer_size_valid(bh))
> > +					bh->b_size = 1 << inode->i_blkbits;
> > +				bh_max = offset - first + bh->b_size;
> > +			} else {
> > +				unsigned done = bh->b_size - (bh_max -
> > +							(offset - first));
> > +				bh->b_blocknr += done >> inode->i_blkbits;
> > +				bh->b_size -= done;
>   It took me quite some time to figure out what this does and whether it is
> correct :). Why isn't this at the place where we advance all other
> iterators like offset, addr, etc.?

It'll be kind of tricky to move it because 'len' is not necessarily
a multiple of i_blkbits, so we can't necessarily maintain b_blocknr
accurately.

> > +			if (rw == WRITE) {
> > +				if (!buffer_mapped(bh)) {
> > +					retval = -EIO;
> > +					break;
>   -EIO looks like a wrong error here. Or maybe it is the right one and it
> only needs some explanation? The thing is that for direct IO some
> filesystems choose not to fill holes for direct IO and fall back to
> buffered IO instead (to avoid exposure of uninitialized blocks if the
> system crashes after blocks have been added to a file but before they were
> written out). For DAX you are pretty much free to define what you ask from
> the get_blocks() (and this fallback behavior is somewhat disputed behavior
> in direct IO case so you might want to differ here) but you should document
> it somewhere.

Hmm ... I thought that calling get_block() with the create argument would
force the return of a bh with the Mapped bit set.  Did I misunderstand that
aspect of the undocumented get_block() API too?

> > +	if ((flags & DIO_LOCKING) && (rw == READ)) {
> > +		struct address_space *mapping = inode->i_mapping;
> > +		mutex_lock(&inode->i_mutex);
> > +		retval = filemap_write_and_wait_range(mapping, offset, end - 1);
> > +		if (retval) {
> > +			mutex_unlock(&inode->i_mutex);
> > +			goto out;
> > +		}
>   Is there a reason for this? I'd assume DAX has no pages in pagecache...

There will be pages in the page cache for holes that we page faulted on.
They must go!  :-)

> > @@ -858,7 +858,11 @@ ext2_direct_IO(int rw, struct kiocb *iocb, const struct iovec *iov,
> >  	struct inode *inode = mapping->host;
> >  	ssize_t ret;
> >  
> > -	ret = blockdev_direct_IO(rw, iocb, inode, iov, offset, nr_segs,
> > +	if (IS_DAX(inode))
> > +		ret = dax_do_io(rw, iocb, inode, iov, offset, nr_segs,
> > +				ext2_get_block, NULL, DIO_LOCKING);
> > +	else
> > +		ret = blockdev_direct_IO(rw, iocb, inode, iov, offset, nr_segs,
> >  				 ext2_get_block);
>   I'd somewhat prefer to have a ext2_direct_IO() as is and have
> ext2_dax_IO() call only dax_do_io() (and use that as .direct_io in
> ext2_aops_xip). Then there's no need to check IS_DAX() and the code would
> look more obvious to me. But I don't feel strongly about it.

I can look at that ... but I was hoping to not have separate aops for
XIP and non-XIP files.

> > @@ -2681,6 +2686,11 @@ extern int generic_show_options(struct seq_file *m, struct dentry *root);
> >  extern void save_mount_options(struct super_block *sb, char *options);
> >  extern void replace_mount_options(struct super_block *sb, char *options);
> >  
> > +static inline bool io_is_direct(struct file *filp)
> > +{
> > +	return (filp->f_flags & O_DIRECT) || IS_DAX(file_inode(filp));
> > +}
> > +
>   BTW: It seems fs/open.c: open_check_o_direct() can be simplified to not
> check for get_xip_mem(), cannot it?

That's in a later patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
