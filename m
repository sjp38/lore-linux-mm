Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 90A3A6B003D
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 11:35:39 -0400 (EDT)
Date: Tue, 24 Mar 2009 16:48:14 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: ftruncate-mmap: pages are lost after writing to mmaped file.
Message-ID: <20090324154813.GH23439@duck.suse.cz>
References: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com> <200903250130.02485.nickpiggin@yahoo.com.au> <20090324144709.GF23439@duck.suse.cz> <200903250203.55520.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200903250203.55520.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Jan Kara <jack@suse.cz>, "Martin J. Bligh" <mbligh@mbligh.org>, linux-ext4@vger.kernel.org, Ying Han <yinghan@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, guichaz@gmail.com, Alex Khesin <alexk@google.com>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Wed 25-03-09 02:03:54, Nick Piggin wrote:
> On Wednesday 25 March 2009 01:47:09 Jan Kara wrote:
> > On Wed 25-03-09 01:30:00, Nick Piggin wrote:
> 
> > > I don't think it is a very good idea for block_write_full_page recovery
> > > to do clear_buffer_dirty for !mapped buffers. I think that should rather
> > > be a redirty_page_for_writepage in the case that the buffer is dirty.
> > >
> > > Perhaps not the cleanest way to solve the problem if it is just due to
> > > transient shortage of space in ext3, but generic code shouldn't be
> > > allowed to throw away dirty data even if it can't be written back due
> > > to some software or hardware error.
> >
> >   Well, that would be one possibility. But then we'd be left with dirty
> > pages we cannot ever release since they are constantly dirty (when the
> > filesystem really becomes out of space). So what I
> 
> If the filesystem becomes out of space and we have over-committed these
> dirty mmapped blocks, then we most definitely want to keep them around.
> An error of the system losing a few pages (or if it happens an insanely
> large number of times, then slowly dying due to memory leak) is better
> than an app suddenly seeing the contents of the page change to nulls
> under it when the kernel decides to do some page reclaim.
  Hmm, probably you're right. Definitely it would be much easier to track
the problem down than it is now... Thinking a bit more... But couldn't a
malicious user bring the machine easily to OOM this way? That would be
unfortunate.

> > rather want to do is something like below:
> >
> > diff --git a/fs/ext3/inode.c b/fs/ext3/inode.c
> > index d351eab..77c526f 100644
> > --- a/fs/ext3/inode.c
> > +++ b/fs/ext3/inode.c
> > @@ -1440,6 +1440,40 @@ static int journal_dirty_data_fn(handle_t *handle,
> > struct buffer_head *bh) }
> >
> >  /*
> > + * Decides whether it's worthwhile to wait for transaction commit and
> > + * retry allocation. If it is, function waits 1 is returns, otherwise
> > + * 0 is returned. In both cases we redirty page and it's buffers so that
> > + * data is not lost. In case we've retried too many times, we also return
> > + * 0 and don't redirty the page. Data gets discarded but we cannot hang
> > + * writepage forever...
> > + */
> > +static int ext3_writepage_retry_alloc(struct page *page, int *retries,
> > +				      struct writeback_control *wbc)
> > +{
> > +	struct super_block *sb = ((struct inode *)page->mapping->host)->i_sb;
> > +	int ret = 0;
> > +
> > +	/*
> > +	 * We don't want to slow down background writeback too much. On the
> > +	 * other hand if most of the dirty data needs allocation, we better
> > +	 * wait to make some progress
> > +	 */
> > +	if (wbc->sync_mode == WB_SYNC_NONE && !wbc->for_reclaim &&
> > +	    wbc->pages_skipped < wbc->nr_to_write / 2)
> > +		goto redirty;
> > +	/*
> > +	 * Now wait if commit can free some space and we haven't retried
> > +	 * too much
> > +	 */
> > +	if (!ext3_should_retry_alloc(sb, retries))
> > +		return 0;
> > +	ret = 1;
> > +redirty:
> > +	set_page_dirty(page);
> > +	return ret;
> > +}
> > +
> > +/*
> >   * Note that we always start a transaction even if we're not journalling
> >   * data.  This is to preserve ordering: any hole instantiation within
> >   * __block_write_full_page -> ext3_get_block() should be journalled
> > @@ -1564,10 +1598,12 @@ static int ext3_writeback_writepage(struct page
> > *page, handle_t *handle = NULL;
> >  	int ret = 0;
> >  	int err;
> > +	int retries;
> >
> >  	if (ext3_journal_current_handle())
> >  		goto out_fail;
> >
> > +restart:
> >  	handle = ext3_journal_start(inode, ext3_writepage_trans_blocks(inode));
> >  	if (IS_ERR(handle)) {
> >  		ret = PTR_ERR(handle);
> > @@ -1580,8 +1616,13 @@ static int ext3_writeback_writepage(struct page
> > *page, ret = block_write_full_page(page, ext3_get_block, wbc);
> >
> >  	err = ext3_journal_stop(handle);
> > -	if (!ret)
> > +	if (!ret) {
> >  		ret = err;
> > +	} else {
> > +		if (ret == -ENOSPC &&
> > +		    ext3_writepage_retry_alloc(page, &retries, wbc))
> > +			goto restart;
> > +	}
> >  	return ret;
> >
> >  out_fail:
> >
> >   And similarly for the other two writepage implementations in ext3...
> > But it currently gives me:
> > WARNING: at fs/buffer.c:781 __set_page_dirty+0x8d/0x145()
> > probably because of that set_page_dirty() in ext3_writepage_retry_alloc().
> 
> And this is a valid warning because we don't know that all buffers are
> uptodate or which ones to set as dirty, I think. Unless it is impossible
> to have dirty && !uptodate pages come thought this path.
  Ah, OK, thanks for explanation.

> But you shouldn't need to redirty the page at all if we change
> block_write_full_page in the way I suggested. Because then it won't
> have cleaned the buffer, and it will have done redirty_page_for_writepage.
>
> > Or we could implement ext3_mkwrite() to allocate buffers already when we
> > make page writeable. But it costs some performace (we have to write page
> > full of zeros when allocating those buffers, where previously we didn't
> > have to do anything) and it's not trivial to make it work if pagesize >
> > blocksize (we should not allocate buffers outside of i_size so if i_size
> > = 1024, we create just one block in ext3_mkwrite() but then we need to
> > allocate more when we extend the file).
> 
> Well the core page_mkwrite function doesn't care about that case
> properly either (it just doesn't allocate buffers on extend). I agree it
> should be fixed, but it is a little hard (I need to fix it in fsblock
> and I think what is required is a setattr helper for that).
  Won't it be enough, if extending truncate called page_mkwrite() on the
page which used to be the last one in the file? That would be enough for
my use although it seems a bit hacky I agree...
  

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
