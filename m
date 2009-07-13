Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 465DD6B004F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 02:33:28 -0400 (EDT)
Date: Mon, 13 Jul 2009 08:54:32 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/3] fs: buffer_head writepage no zero
Message-ID: <20090713065432.GM14666@wotan.suse.de>
References: <20090710073028.782561541@suse.de> <20090710093325.GG14666@wotan.suse.de> <20090710093403.GH14666@wotan.suse.de> <20090710114651.GJ17524@duck.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090710114651.GJ17524@duck.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, hch@infradead.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 10, 2009 at 01:46:51PM +0200, Jan Kara wrote:
> On Fri 10-07-09 11:34:03, Nick Piggin wrote:
> > 
> > When writing a page to filesystem, buffer.c zeroes out parts of the page past
> > i_size in an attempt to get zeroes into those blocks on disk, so as to honour
> > the requirement that an expanding truncate should zero-fill the file.
> > 
> > Unfortunately, this is racy. The reason we can get something other than
> > zeroes here is via an mmaped write to the block beyond i_size. Zeroing it
> > out before writepage narrows the window, but it is still possible to store
> > junk beyond i_size on disk, by storing into the page after writepage zeroes,
> > but before DMA (or copy) completes. This allows process A to break posix
> > semantics for process B (or even inadvertently for itsef).
> > 
> > It could also be possible that the filesystem has written data into the
> > block but not yet expanded the inode size when the system crashes for
> > some reason. Unless its journal reply / fsck process etc checks for this
> > condition, it could also cause subsequent breakage in semantics.
>   Actually, it should be possible to fix the posix semantics by zeroing out
> the page when i_size is going to be extended - hmm, I see you're trying to
> do something like that in ext2 code. Ugh. Since we have to lock the

Yeah, it could probably do it in write_begin in generic code, that
part was a bit ugly.

> old last page to make mkwrite work anyway, I think we should do it in a
> generic code (probably in a separate patch and just note it here...).
>   I can include it in my mkwrite fixes when I port them on top of your
> patches.
> 
> > @@ -2752,7 +2741,6 @@ has_buffers:
> >  	}
> >  	zero_user(page, offset, length);
> >  	set_page_dirty(page);
> > -	err = 0;
> >  
> >  unlock:
> >  	unlock_page(page);
>   Above two chunks are just style cleanup, aren't they? Could you maybe separate
> it from the logical changes?

Yes I think so. They devolved from something that was actually useful,
and I should remove them.

 
> > @@ -2802,15 +2790,20 @@ int block_truncate_page(struct address_s
> >  		pos += blocksize;
> >  	}
> >  
> > -	err = 0;
> >  	if (!buffer_mapped(bh)) {
> >  		WARN_ON(bh->b_size != blocksize);
> >  		err = get_block(inode, iblock, bh, 0);
> >  		if (err)
> >  			goto unlock;
> > -		/* unmapped? It's a hole - nothing to do */
> > -		if (!buffer_mapped(bh))
> > +		/*
> > +		 * unmapped? It's a hole - must zero out partial
> > +		 * in the case of an extending truncate where mmap has
> > +		 * previously written past i_size of the page
> > +		 */
> > +		if (!buffer_mapped(bh)) {
> > +			zero_user(page, offset, length);
> >  			goto unlock;
>   Hmm, but who was zeroing out the page previously? Because the end of the
> page gets zeroed already now...

Yes it does aready get zeroed, however I think ftruncate semantics
say that expanding ftruncate shoud leave the new area with zero
filled. A partial-mmap on the last page could have dirtied these
parts of the page and so break the guarantee.

I guess it could be ignored because such partial mmap writes are
supposed to result in undefined behaviour, however I think it is
a bit wrong (also the result could change based on memory pressure
even when another program opens the file, so I think zeroing here
is best).
 

> > -	/*
> > -	 * The page straddles i_size.  It must be zeroed out on each and every
> > -	 * writepage invokation because it may be mmapped.  "A file is mapped
> > -	 * in multiples of the page size.  For a file that is not a multiple of
> > -	 * the  page size, the remaining memory is zeroed when mapped, and
> > -	 * writes to that region are not written out to the file."
> > -	 */
> > -	zero_user_segment(page, offset, PAGE_CACHE_SIZE);
> >  	return __block_write_full_page(inode, page, get_block, wbc, handler);
> >  }
>   I suppose you should also update __block_write_full_page() - there's
> comment about zeroing. Also I'm not sure that marking buffer as uptodate
> there is a good idea when the buffer isn't zeroed.

Thanks I'll check it out.


> >  EXPORT_SYMBOL_GPL(xip_truncate_page);
>   Again, only a style change, right?

Yes.

> > Index: linux-2.6/fs/ext2/inode.c
> > ===================================================================
> > --- linux-2.6.orig/fs/ext2/inode.c
> > +++ linux-2.6/fs/ext2/inode.c
> > @@ -777,14 +777,40 @@ ext2_write_begin(struct file *file, stru
> >  	return ret;
> >  }
> >  
> > +int __block_truncate_page(struct address_space *mapping,
> > +			loff_t from, loff_t to, get_block_t *get_block);
>   Uf, that's ugly... Shouldn't it be in some header?
> 
> >  static int ext2_write_end(struct file *file, struct address_space *mapping,
> >  			loff_t pos, unsigned len, unsigned copied,
> >  			struct page *page, void *fsdata)
> >  {
> > +	struct inode *inode = mapping->host;
> >  	int ret;
> >  
> > -	ret = generic_write_end(file, mapping, pos, len, copied, page, fsdata);
> > -	if (ret < len) {
> > +	ret = block_write_end(file, mapping, pos, len, copied, page, fsdata);
> > +	unlock_page(page);
> > +	page_cache_release(page);
> > +        if (pos+copied > inode->i_size) {
> > +		int err;
> > +                if (pos > inode->i_size) {
> > +                        /* expanding a hole */
> > +			err = __block_truncate_page(mapping, inode->i_size,
> > +						pos, ext2_get_block);
> > +			if (err) {
> > +				ret = err;
> > +				goto out;
> > +			}
> > +			err = __block_truncate_page(mapping, pos+copied,
> > +						LLONG_MAX, ext2_get_block);
> > +			if (err) {
> > +				ret = err;
> > +				goto out;
> > +			}
> > +                }
> > +                i_size_write(inode, pos+copied);
> > +                mark_inode_dirty(inode);
> > +        }
> > +out:
> > +	if (ret < 0 || ret < len) {
> >  		struct inode *inode = mapping->host;
> >  		loff_t isize = inode->i_size;
> >  		if (pos + len > isize)
>   There are whitespace problems above... Also calling __block_truncate_page()
> on old i_size looks strange - we just want to zero-out the page if it
> exists (this way we'd unnecessarily read it from disk). Also I think
> block_write_end() should do this.
>   Finally, zeroing after pos+copied does not make sence to be conditioned
> by pos > inode->i_size and again I don't think it's needed...

Yeah this part was ugly because it was just a result of working
through bugs and I didn't really try to make it nice. I agree if
we can move as much as possible to generic code it woud be
best.

Thanks for review. I'll try to post another version soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
