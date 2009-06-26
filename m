Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 45ACA6B0085
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 12:08:42 -0400 (EDT)
Date: Fri, 26 Jun 2009 18:08:51 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 02/11] vfs: Add better VFS support for page_mkwrite
	when blocksize < pagesize
Message-ID: <20090626160851.GA22335@duck.suse.cz>
References: <1245088797-29533-1-git-send-email-jack@suse.cz> <1245088797-29533-3-git-send-email-jack@suse.cz> <20090625161753.GB30755@wotan.suse.de> <20090626122141.GB32125@duck.suse.cz> <20090626125505.GD11450@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090626125505.GD11450@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri 26-06-09 14:55:05, Nick Piggin wrote:
> On Fri, Jun 26, 2009 at 02:21:41PM +0200, Jan Kara wrote:
> > > Now I may be speaking too soon. It might trun out that my fix is
> > > complex as well, but let me just give you an RFC and we can discuss.
> >   I've looked at your patch and it's definitely a worthwhile cleanup.
> > But it's not quite enough for what I need. I'll try to describe the issue
> > as I'm aware of it and possible solutions and maybe you'll have some idea
> > about a better solution.
> >   PROBLEM: We have a file 'f' of length OLD_ISIZE mmapped upto some offset
> > OFF (multiple of pagesize). The problem generally happens when OLD_ISIZE <
> > OFF and subsequent filesystem operation (it need not be just truncate() but
> > also a plain write() creating a hole - this is the main reason why the
> > patch is much more complicated than I'd like) increases file size to
> > NEW_ISIZE.
> >   The first decision: mmap() documentation says: "The effect of changing
> > the size of the underlying file of a mapping on the pages that correspond
> > to added or removed regions of the file is  unspecified." So according to
> > this it would be perfectly fine if we just discarded all the data beyond
> > OLD_ISIZE written via that particular mmap(). It would be even technically
> > doable - vma would store minimum i_size which was ever seen at page_mkwrite
> > time, page_mkwrite will allocate buffers only upto vma->i_size, we silently
> > discard all unmapped dirty buffers. But I also see two problems with this:
> >   1) So far we were much nicer to the user and when the file size has been
> > increased, user could happily write data via old mmap upto new file size.
> > I'd almost bet some people rely on this especially in the case
> > truncate-down, truncate-up, write via mmap.
> >   2) It's kind of fragile to discard dirty unmapped buffers without a
> > warning.
> > 
> >   So I took the decision that data written via mmap() should be stored
> > on disk properly if they were written inside i_size at the time the write
> > via mmap() happened. This decision basically dictates, that you have to do
> > some magic for the page containing OLD_ISIZE at the time file size is going
> > to be extended. All kinds of magic I could think of required taking
> > PageLock of the page containing OLD_ISIZE and that makes locking for the
> > write case interesting:
> >   1) write creating a hole has to update i_size inside PageLock for the
> > page it writes to (to avoid races with block_write_full_page()).
> >   2) we have to take PageLock for the page containing OLD_ISIZE sometime
> > before i_size gets updated to do our magic -> this has to happen in
> > write_begin().
> > 
> >   Now about the magic: There are two things I could imagine we do:
> > a) when the page containing OLD_ISIZE is dirty, try to allocate blocks
> > under it as needed for NEW_ISIZE - but the errors when this fails will
> > return to the process doing truncate / creating hole with write which is
> > kind of strange. Also we maybe allocate blocks unnecessarily because user
> > may never actually write to the page containing OLD_ISIZE again...
> > b) we writeout the page, writeprotect it and let page_mkwrite() do it's
> > work when it's called again. This is nice from the theoretical POV but
> > gets a bit messy - we have to make sure page_mkwrite() for that page
> > doesn't proceed until we update the i_size. Which is why I introduced that
> > inode bit-lock. We cannot use e.g. i_mutex for that because it ranks above
> > mmap_sem which is held when we enter page_mkwrite.
> > 
> >   So if you have any idea how to better solve this, you are welcome ;).
> 
> Ah thanks, the write(2) case I missed. That does get complex to
> do with the page lock.
> 
> I agree with the semantics you are aiming for, and I agree we should
> not try to allocate blocks when extending i_size.
> 
> We actually could update i_size after dropping the page lock in
> these paths. That would give a window where we can page_mkclean
> the old partial page before the i_size update.
  Yes, that would be fine and make things simpler...

> However this does actually require that we remove the partial-page
> zeroing that writepage does. I think it does it in order to attempt
> to write zeroes into the fs even if the app does mmaped writes
> past i_size... but it is pretty dumb anyway really because the
> behaviour is undefined anyway so there is no problem if weird
> stuff gets written there (it should be zeroed out when extending
> the file anyway), and also there is nothing to prevent races of
> subsequent mmapped writes before the DMA completes.
  We definitely don't zero out the last page when extending the file. But
if we do it, we should be fine as you write. I'll try to write a patch...
(I'm on vacation next week though so probably after that).

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
