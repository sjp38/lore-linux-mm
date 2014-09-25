Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 773716B0036
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 05:34:16 -0400 (EDT)
Received: by mail-la0-f44.google.com with SMTP id gi9so1960099lab.3
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 02:34:15 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id oc4si2279189lbb.11.2014.09.25.02.34.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Sep 2014 02:34:14 -0700 (PDT)
Date: Thu, 25 Sep 2014 11:34:10 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/2] vfs: Fix data corruption when blocksize < pagesize
 for mmaped data
Message-ID: <20140925093410.GC3096@quack.suse.cz>
References: <1411484603-17756-1-git-send-email-jack@suse.cz>
 <1411484603-17756-2-git-send-email-jack@suse.cz>
 <20140925013216.GD4945@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140925013216.GD4945@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, Ted Tso <tytso@mit.edu>

On Thu 25-09-14 11:32:16, Dave Chinner wrote:
> On Tue, Sep 23, 2014 at 05:03:22PM +0200, Jan Kara wrote:
> > ->page_mkwrite() is used by filesystems to allocate blocks under a page
> > which is becoming writeably mmapped in some process' address space. This
> > allows a filesystem to return a page fault if there is not enough space
> > available, user exceeds quota or similar problem happens, rather than
> > silently discarding data later when writepage is called.
> > 
> > However VFS fails to call ->page_mkwrite() in all the cases where
> > filesystems need it when blocksize < pagesize. For example when
> > blocksize = 1024, pagesize = 4096 the following is problematic:
> >   ftruncate(fd, 0);
> >   pwrite(fd, buf, 1024, 0);
> >   map = mmap(NULL, 1024, PROT_WRITE, MAP_SHARED, fd, 0);
> >   map[0] = 'a';       ----> page_mkwrite() for index 0 is called
> >   ftruncate(fd, 10000); /* or even pwrite(fd, buf, 1, 10000) */
> >   mremap(map, 1024, 10000, 0);
> >   map[4095] = 'a';    ----> no page_mkwrite() called
> > 
> > At the moment ->page_mkwrite() is called, filesystem can allocate only
> > one block for the page because i_size == 1024. Otherwise it would create
> > blocks beyond i_size which is generally undesirable. But later at
> > ->writepage() time, we also need to store data at offset 4095 but we
> > don't have block allocated for it.
> ...
> >  
> > +#ifdef CONFIG_MMU
> > +/**
> > + * block_create_hole - handle creation of a hole in a file
> > + * @inode:	inode where the hole is created
> > + * @from:	offset in bytes where the hole starts
> > + * @to:		offset in bytes where the hole ends.
> 
> This function doesn't create holes.  It also manipulates page state,
> not block state.  Probably could do with a better name, but I'm not
> sure what a better name is - something like
> pagecache_extend_isize(old_eof, new_eof)?
  Yeah, you are right. I should be actually better off moving that function
to mm/truncate.c. Regarding the name I agree block_create_hole() isn't
very accurate but I don't like pagecache_extend_isize() too much either -
see below for reason.

> > +void block_create_hole(struct inode *inode, loff_t from, loff_t to)
> > +{
> > +	int bsize = 1 << inode->i_blkbits;
> > +	loff_t rounded_from;
> > +	struct page *page;
> > +	pgoff_t index;
> > +
> > +	WARN_ON(!mutex_is_locked(&inode->i_mutex));
> > +	WARN_ON(to > inode->i_size);
> 
> We've already changed i_size, so shouldn't that be:
  Not quite. When you have 1k blocksize, filesize == 512 and you do
pwrite(file, buf, 1024, 8192);
  Then you want the function to be called for range 512 - 8192, however
i_size is already 9216. So the assertion is correct as is. This is also
the reason why I don't like pagecache_extend_isize() because it suggests
'to' is the final i_size but it's not.

Maybe the most simple interface would be to really call the function
pagecache_extend_isize(), let it take just 'to' and it will write the new
i_size and handle pagecache tricks. The extending writes will then be
handled by first calling pagecache_extend_isize() to extend to 'pos' and
then just i_size_write() the final size...

								Honza
> 	WARN_ON(to != inode->i_size);
> 
> > +
> > +	if (from >= to || bsize == PAGE_CACHE_SIZE)
> > +		return;
> > +	/* Currently last page will not have any hole block created? */
> > +	rounded_from = ALIGN(from, bsize);
> 
> That rounds down? or up? round_down/round_up are much better than
> ALIGN() because they tell you exactly what rounding was intended...
  Good point. I'll use round_up().

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
