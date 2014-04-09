Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id E33D66B0035
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 11:24:33 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id uo5so2669451pbc.10
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 08:24:32 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id iw3si625986pac.342.2014.04.09.08.24.31
        for <linux-mm@kvack.org>;
        Wed, 09 Apr 2014 08:24:31 -0700 (PDT)
Date: Wed, 9 Apr 2014 11:19:08 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v7 06/22] Replace XIP read and write with DAX I/O
Message-ID: <20140409151908.GD5727@linux.intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <3ebe329d8713f7db4c105021a845316a47a29797.1395591795.git.matthew.r.wilcox@intel.com>
 <20140408175600.GE2713@quack.suse.cz>
 <20140408202102.GB5727@linux.intel.com>
 <20140409091450.GA32103@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140409091450.GA32103@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 09, 2014 at 11:14:50AM +0200, Jan Kara wrote:
> On Tue 08-04-14 16:21:02, Matthew Wilcox wrote:
> > On Tue, Apr 08, 2014 at 07:56:00PM +0200, Jan Kara wrote:
> > > > +static void dax_new_buf(void *addr, unsigned size, unsigned first,
> > > > +					loff_t offset, loff_t end, int rw)
> > > > +{
> > > > +	loff_t final = end - offset + first; /* The final byte of the buffer */
> > > > +	if (rw != WRITE) {
> > > > +		memset(addr, 0, size);
> > > > +		return;
> > > > +	}
> > >   It seems counterintuitive to zero out "on-disk" blocks (it seems you'd do
> > > this for unwritten blocks) when reading from them. Presumably it could also
> > > have undesired effects on endurance of persistent memory. Instead I'd expect
> > > that you simply zero out user provided buffer the same way as you do it for
> > > holes.
> > 
> > I think we have to zero it here, because the second time we call
> > get_block() for a given block, it won't be BH_New any more, so we won't
> > know that it's supposed to be zeroed.
>   But how can you have BH_New buffer when you didn't ask get_blocks() to
> create any block? That would be a bug in the get_blocks() implementation...
> Or am I missing something?

Oh ... right.  So just to be clear, we're looking at the case where
we're doing a read of a filesystem block which is BH_Unwritten, but
isn't a hole ... so it's been allocated on storage and not yet written.
That's already treated as a hole:

                        if (rw == WRITE) {
...
                        } else {
                                hole = !buffer_written(bh);
                        }

and dax_new_buf is only called in the !hole case.

>   OK, but there are filesystems which do the same thing as ext4 (e.g.
> btrfs) and historically noone really cared. E.g. direct IO code advances
> only by a single block regardless of what filesystem returns when the
> buffer is unmapped. As you correctly mention, get_blocks() API isn't really
> documented so noone has really defined what should happen when you ask
> filesystem to map some blocks and there's a hole. I agree what XFS does
> looks sensible and ext4 can do the same. Hopefully this gets cleaned up
> when Dave finishes his new block mapping interface.

I hope so too!  The get_block() API has been the bane of my existance
since Christmas :-)

>   This wouldn't quite work because even ext4_map_blocks() doesn't bother to
> fill in 'map' when it finds a hole. But it won't be complicated to
> propagate the information.

Good point.

> > It'll be kind of tricky to move it because 'len' is not necessarily
> > a multiple of i_blkbits, so we can't necessarily maintain b_blocknr
> > accurately.
>   Yeah, after I understood the code I also understood why you do it the way
> you did. But we could do something like:
> ...
> +               if (!len)
> +                       break;
> + 
> 		blocks = ((offset + len) >> inode->i_blkbits) - 
> 				(offset >> inode->i_blkbits);
> 		bh->b_blocknr += blocks;
> 		bh->b_size -= blocks << inode->i_blkbits;
> +               offset += len;
> +               copied += len;
> +               addr += len;
> ...

We could ... I'm not sure it's simpler though.

> BTW: it might be good to store inode->i_blkbits in a local variable. It
> makes some expressions shorter.

Yes, good idea.  Done.

> BTW2: although direct IO uses 'offset' for position in file, the rest of
> VFS uses 'pos' for that and that seems to be less overloaded term so for me
> it would be easier if you used 'pos' instead of 'offset'. Just a
> suggestion.

Sure.  Done.

> > > > +			if (rw == WRITE) {
> > > > +				if (!buffer_mapped(bh)) {
> > > > +					retval = -EIO;
> > > > +					break;
> > >   -EIO looks like a wrong error here. Or maybe it is the right one and it
> > > only needs some explanation? The thing is that for direct IO some
> > > filesystems choose not to fill holes for direct IO and fall back to
> > > buffered IO instead (to avoid exposure of uninitialized blocks if the
> > > system crashes after blocks have been added to a file but before they were
> > > written out). For DAX you are pretty much free to define what you ask from
> > > the get_blocks() (and this fallback behavior is somewhat disputed behavior
> > > in direct IO case so you might want to differ here) but you should document
> > > it somewhere.
> > 
> > Hmm ... I thought that calling get_block() with the create argument would
> > force the return of a bh with the Mapped bit set.  Did I misunderstand that
> > aspect of the undocumented get_block() API too?
>   As you mention the API is undocumented and not really designed. So
> filesystems do whatever causes the generic code to do what they want (it's
> a mess I know). In this case, I'm warning you there are filesystems which
> refuse to fill in holes from the get_blocks() function passed to
> blockdev_direct_IO() (even ext4 does this for inodes with old
> indirect-block based on disk format). You can just define DAX fails
> horribly in these case and I'm fine with that at least in this stage. If
> someone bothers later, fallback to buffered IO can be implemented. But we
> should document this somewhere. 

Urgh.  Yeah, we should probably fall back to buffered I/O for that case.
I'll stick a comment in dax.c for now, and we can fix it later.

> > > > +	if ((flags & DIO_LOCKING) && (rw == READ)) {
> > > > +		struct address_space *mapping = inode->i_mapping;
> > > > +		mutex_lock(&inode->i_mutex);
> > > > +		retval = filemap_write_and_wait_range(mapping, offset, end - 1);
> > > > +		if (retval) {
> > > > +			mutex_unlock(&inode->i_mutex);
> > > > +			goto out;
> > > > +		}
> > >   Is there a reason for this? I'd assume DAX has no pages in pagecache...
> > 
> > There will be pages in the page cache for holes that we page faulted on.
> > They must go!  :-)
>   Well, but this will only writeback dirty pages and if I read the code
> correctly those pages will never be dirty since dax_mkwrite() will replace
> them. Or am I missing something?

In addition to writing back dirty pages, filemap_write_and_wait_range()
will evict clean pages.  Unintuitive, I know, but it matches what the
direct I/O path does.  Plus, if we fall back to buffered I/O for holes
(see above), then this will do the right thing at that time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
