Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 966A46B0031
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 05:14:57 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id hi2so8491086wib.11
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 02:14:55 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t1si163551wjt.90.2014.04.09.02.14.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Apr 2014 02:14:54 -0700 (PDT)
Date: Wed, 9 Apr 2014 11:14:50 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v7 06/22] Replace XIP read and write with DAX I/O
Message-ID: <20140409091450.GA32103@quack.suse.cz>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <3ebe329d8713f7db4c105021a845316a47a29797.1395591795.git.matthew.r.wilcox@intel.com>
 <20140408175600.GE2713@quack.suse.cz>
 <20140408202102.GB5727@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140408202102.GB5727@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 08-04-14 16:21:02, Matthew Wilcox wrote:
> On Tue, Apr 08, 2014 at 07:56:00PM +0200, Jan Kara wrote:
> > > +static void dax_new_buf(void *addr, unsigned size, unsigned first,
> > > +					loff_t offset, loff_t end, int rw)
> > > +{
> > > +	loff_t final = end - offset + first; /* The final byte of the buffer */
> > > +	if (rw != WRITE) {
> > > +		memset(addr, 0, size);
> > > +		return;
> > > +	}
> >   It seems counterintuitive to zero out "on-disk" blocks (it seems you'd do
> > this for unwritten blocks) when reading from them. Presumably it could also
> > have undesired effects on endurance of persistent memory. Instead I'd expect
> > that you simply zero out user provided buffer the same way as you do it for
> > holes.
> 
> I think we have to zero it here, because the second time we call
> get_block() for a given block, it won't be BH_New any more, so we won't
> know that it's supposed to be zeroed.
  But how can you have BH_New buffer when you didn't ask get_blocks() to
create any block? That would be a bug in the get_blocks() implementation...
Or am I missing something?

> > > +/*
> > > + * When ext4 encounters a hole, it likes to return without modifying the
> > > + * buffer_head which means that we can't trust b_size.  To cope with this,
> > > + * we set b_state to 0 before calling get_block and, if any bit is set, we
> > > + * know we can trust b_size.  Unfortunate, really, since ext4 does know
> > > + * precisely how long a hole is and would save us time calling get_block
> > > + * repeatedly.
> >   Well, this is really a problem of get_blocks() returning the result in
> > struct buffer_head which is used for input as well. I don't think it is
> > actually ext4 specific.
> 
> Of course it's ext4 specific!  It's the ext4_get_block() implementation
> which is choosing not to return the length of the hole.  XFS does return
> the length of the hole.  I think something like this would fix it:
  OK, but there are filesystems which do the same thing as ext4 (e.g.
btrfs) and historically noone really cared. E.g. direct IO code advances
only by a single block regardless of what filesystem returns when the
buffer is unmapped. As you correctly mention, get_blocks() API isn't really
documented so noone has really defined what should happen when you ask
filesystem to map some blocks and there's a hole. I agree what XFS does
looks sensible and ext4 can do the same. Hopefully this gets cleaned up
when Dave finishes his new block mapping interface.

> +++ b/fs/ext4/inode.c
> @@ -727,14 +727,14 @@ static int _ext4_get_block(struct inode *inode, sector_t i
>         }
>  
>         ret = ext4_map_blocks(handle, inode, &map, flags);
> +       map_bh(bh, inode->i_sb, map.m_pblk);
> +       bh->b_state = (bh->b_state & ~EXT4_MAP_FLAGS) | map.m_flags;
> +       bh->b_size = inode->i_sb->s_blocksize * map.m_len;
>         if (ret > 0) {
>                 ext4_io_end_t *io_end = ext4_inode_aio(inode);
>  
> -               map_bh(bh, inode->i_sb, map.m_pblk);
> -               bh->b_state = (bh->b_state & ~EXT4_MAP_FLAGS) | map.m_flags;
>                 if (io_end && io_end->flag & EXT4_IO_END_UNWRITTEN)
>                         set_buffer_defer_completion(bh);
> -               bh->b_size = inode->i_sb->s_blocksize * map.m_len;
>                 ret = 0;
>         }
>         if (started)
  This wouldn't quite work because even ext4_map_blocks() doesn't bother to
fill in 'map' when it finds a hole. But it won't be complicated to
propagate the information.

> > > +	while (offset < end) {
> > > +		void __user *buf = iov[seg].iov_base + copied;
> > > +
> > > +		if (offset == max) {
> > > +			sector_t block = offset >> inode->i_blkbits;
> > > +			unsigned first = offset - (block << inode->i_blkbits);
> > > +			long size;
> > > +
> > > +			if (offset == bh_max) {
> > > +				bh->b_size = PAGE_ALIGN(end - offset);
> > > +				bh->b_state = 0;
> > > +				retval = get_block(inode, block, bh,
> > > +								rw == WRITE);
> > > +				if (retval)
> > > +					break;
> > > +				if (!buffer_size_valid(bh))
> > > +					bh->b_size = 1 << inode->i_blkbits;
> > > +				bh_max = offset - first + bh->b_size;
> > > +			} else {
> > > +				unsigned done = bh->b_size - (bh_max -
> > > +							(offset - first));
> > > +				bh->b_blocknr += done >> inode->i_blkbits;
> > > +				bh->b_size -= done;
> >   It took me quite some time to figure out what this does and whether it is
> > correct :). Why isn't this at the place where we advance all other
> > iterators like offset, addr, etc.?
> 
> It'll be kind of tricky to move it because 'len' is not necessarily
> a multiple of i_blkbits, so we can't necessarily maintain b_blocknr
> accurately.
  Yeah, after I understood the code I also understood why you do it the way
you did. But we could do something like:
...
+               if (!len)
+                       break;
+ 
		blocks = ((offset + len) >> inode->i_blkbits) - 
				(offset >> inode->i_blkbits);
		bh->b_blocknr += blocks;
		bh->b_size -= blocks << inode->i_blkbits;
+               offset += len;
+               copied += len;
+               addr += len;
...

BTW: it might be good to store inode->i_blkbits in a local variable. It
makes some expressions shorter.

BTW2: although direct IO uses 'offset' for position in file, the rest of
VFS uses 'pos' for that and that seems to be less overloaded term so for me
it would be easier if you used 'pos' instead of 'offset'. Just a
suggestion.

> > > +			if (rw == WRITE) {
> > > +				if (!buffer_mapped(bh)) {
> > > +					retval = -EIO;
> > > +					break;
> >   -EIO looks like a wrong error here. Or maybe it is the right one and it
> > only needs some explanation? The thing is that for direct IO some
> > filesystems choose not to fill holes for direct IO and fall back to
> > buffered IO instead (to avoid exposure of uninitialized blocks if the
> > system crashes after blocks have been added to a file but before they were
> > written out). For DAX you are pretty much free to define what you ask from
> > the get_blocks() (and this fallback behavior is somewhat disputed behavior
> > in direct IO case so you might want to differ here) but you should document
> > it somewhere.
> 
> Hmm ... I thought that calling get_block() with the create argument would
> force the return of a bh with the Mapped bit set.  Did I misunderstand that
> aspect of the undocumented get_block() API too?
  As you mention the API is undocumented and not really designed. So
filesystems do whatever causes the generic code to do what they want (it's
a mess I know). In this case, I'm warning you there are filesystems which
refuse to fill in holes from the get_blocks() function passed to
blockdev_direct_IO() (even ext4 does this for inodes with old
indirect-block based on disk format). You can just define DAX fails
horribly in these case and I'm fine with that at least in this stage. If
someone bothers later, fallback to buffered IO can be implemented. But we
should document this somewhere. 

> > > +	if ((flags & DIO_LOCKING) && (rw == READ)) {
> > > +		struct address_space *mapping = inode->i_mapping;
> > > +		mutex_lock(&inode->i_mutex);
> > > +		retval = filemap_write_and_wait_range(mapping, offset, end - 1);
> > > +		if (retval) {
> > > +			mutex_unlock(&inode->i_mutex);
> > > +			goto out;
> > > +		}
> >   Is there a reason for this? I'd assume DAX has no pages in pagecache...
> 
> There will be pages in the page cache for holes that we page faulted on.
> They must go!  :-)
  Well, but this will only writeback dirty pages and if I read the code
correctly those pages will never be dirty since dax_mkwrite() will replace
them. Or am I missing something?
 
> > > @@ -858,7 +858,11 @@ ext2_direct_IO(int rw, struct kiocb *iocb, const struct iovec *iov,
> > >  	struct inode *inode = mapping->host;
> > >  	ssize_t ret;
> > >  
> > > -	ret = blockdev_direct_IO(rw, iocb, inode, iov, offset, nr_segs,
> > > +	if (IS_DAX(inode))
> > > +		ret = dax_do_io(rw, iocb, inode, iov, offset, nr_segs,
> > > +				ext2_get_block, NULL, DIO_LOCKING);
> > > +	else
> > > +		ret = blockdev_direct_IO(rw, iocb, inode, iov, offset, nr_segs,
> > >  				 ext2_get_block);
> >   I'd somewhat prefer to have a ext2_direct_IO() as is and have
> > ext2_dax_IO() call only dax_do_io() (and use that as .direct_io in
> > ext2_aops_xip). Then there's no need to check IS_DAX() and the code would
> > look more obvious to me. But I don't feel strongly about it.
> 
> I can look at that ... but I was hoping to not have separate aops for
> XIP and non-XIP files.
  OK, if you can do that, then I'm fine with the code as is.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
