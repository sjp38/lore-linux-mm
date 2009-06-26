Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A42A46B005A
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 08:21:06 -0400 (EDT)
Date: Fri, 26 Jun 2009 14:21:41 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 02/11] vfs: Add better VFS support for page_mkwrite
	when blocksize < pagesize
Message-ID: <20090626122141.GB32125@duck.suse.cz>
References: <1245088797-29533-1-git-send-email-jack@suse.cz> <1245088797-29533-3-git-send-email-jack@suse.cz> <20090625161753.GB30755@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090625161753.GB30755@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

  Hi Nick,

On Thu 25-06-09 18:17:53, Nick Piggin wrote:
> On Mon, Jun 15, 2009 at 07:59:49PM +0200, Jan Kara wrote:
> > page_mkwrite() is meant to be used by filesystems to allocate blocks under a
> > page which is becoming writeably mmapped in some process address space. This
> > allows a filesystem to return a page fault if there is not enough space
> > available, user exceeds quota or similar problem happens, rather than silently
> > discarding data later when writepage is called.
> > 
> > On filesystems where blocksize < pagesize the situation is more complicated.
> > Think for example that blocksize = 1024, pagesize = 4096 and a process does:
> >   ftruncate(fd, 0);
> >   pwrite(fd, buf, 1024, 0);
> >   map = mmap(NULL, 4096, PROT_WRITE, MAP_SHARED, fd, 0);
> >   map[0] = 'a';  ----> page_mkwrite() for index 0 is called
> >   ftruncate(fd, 10000); /* or even pwrite(fd, buf, 1, 10000) */
> >   fsync(fd); ----> writepage() for index 0 is called
> > 
> > At the moment page_mkwrite() is called, filesystem can allocate only one block
> > for the page because i_size == 1024. Otherwise it would create blocks beyond
> > i_size which is generally undesirable. But later at writepage() time, we would
> > like to have blocks allocated for the whole page (and in principle we have to
> > allocate them because user could have filled the page with data after the
> > second ftruncate()). This patch introduces a framework which allows filesystems
> > to handle this with a reasonable effort.
> > 
> > The idea is following: Before we extend i_size, we obtain a special lock blocking
> > page_mkwrite() on the page straddling i_size. Then we writeprotect the page,
> > change i_size and unlock the special lock. This way, page_mkwrite() is called for
> > a page each time a number of blocks needed to be allocated for a page increases.
> 
> 
> Sorry for late reply here, I'm not sure if the ptach was ready for this
> merge window anyway if it has not been in Andrew or Al's trees.
> 
> Well... I can't really find any hole in your code, but I'm not completely
> sure I like the design. I have done some thinking about the problem
> when working on fsblock.
> 
> This is adding a whole new layer of synchronisation, which isn't exactly
> trivial. What I had been thinking about is doing just page based
> synchronisation. Now that page_mkwrite has been changed to allow page
> lock held, I think it can work cleanly from the vm/pagecache perspective.
  Yes, I agree the solution isn't elegant. But I couldn't come up with
anything better ;).

> The biggest problem I ran into is the awful structuring of truncate from
> below the vfs (so I gave up then).
> 
> I have been working to clean up and complete (at least to an RFC stage)
> patches to improve this, at which point, doing the page_mkclean thing
> on the last partial page should be quite trivial I think.
> 
> Basically the problems is that i_op->truncate a) cannot return an error
> (which is causing problems missing -EIO today anyway), and b) is called
> after i_size update which makes it not possible to error-out without
> races anyway, and c) does not get the old i_size so you can't unmap the
> last partial page with it.
> 
> My patch is basically moving ->truncate call into setattr, and have
> the filesystem call vmtruncate. I've jt to clean up loose ends.
> 
> Now I may be speaking too soon. It might trun out that my fix is
> complex as well, but let me just give you an RFC and we can discuss.
  I've looked at your patch and it's definitely a worthwhile cleanup.
But it's not quite enough for what I need. I'll try to describe the issue
as I'm aware of it and possible solutions and maybe you'll have some idea
about a better solution.
  PROBLEM: We have a file 'f' of length OLD_ISIZE mmapped upto some offset
OFF (multiple of pagesize). The problem generally happens when OLD_ISIZE <
OFF and subsequent filesystem operation (it need not be just truncate() but
also a plain write() creating a hole - this is the main reason why the
patch is much more complicated than I'd like) increases file size to
NEW_ISIZE.
  The first decision: mmap() documentation says: "The effect of changing
the size of the underlying file of a mapping on the pages that correspond
to added or removed regions of the file is  unspecified." So according to
this it would be perfectly fine if we just discarded all the data beyond
OLD_ISIZE written via that particular mmap(). It would be even technically
doable - vma would store minimum i_size which was ever seen at page_mkwrite
time, page_mkwrite will allocate buffers only upto vma->i_size, we silently
discard all unmapped dirty buffers. But I also see two problems with this:
  1) So far we were much nicer to the user and when the file size has been
increased, user could happily write data via old mmap upto new file size.
I'd almost bet some people rely on this especially in the case
truncate-down, truncate-up, write via mmap.
  2) It's kind of fragile to discard dirty unmapped buffers without a
warning.

  So I took the decision that data written via mmap() should be stored
on disk properly if they were written inside i_size at the time the write
via mmap() happened. This decision basically dictates, that you have to do
some magic for the page containing OLD_ISIZE at the time file size is going
to be extended. All kinds of magic I could think of required taking
PageLock of the page containing OLD_ISIZE and that makes locking for the
write case interesting:
  1) write creating a hole has to update i_size inside PageLock for the
page it writes to (to avoid races with block_write_full_page()).
  2) we have to take PageLock for the page containing OLD_ISIZE sometime
before i_size gets updated to do our magic -> this has to happen in
write_begin().

  Now about the magic: There are two things I could imagine we do:
a) when the page containing OLD_ISIZE is dirty, try to allocate blocks
under it as needed for NEW_ISIZE - but the errors when this fails will
return to the process doing truncate / creating hole with write which is
kind of strange. Also we maybe allocate blocks unnecessarily because user
may never actually write to the page containing OLD_ISIZE again...
b) we writeout the page, writeprotect it and let page_mkwrite() do it's
work when it's called again. This is nice from the theoretical POV but
gets a bit messy - we have to make sure page_mkwrite() for that page
doesn't proceed until we update the i_size. Which is why I introduced that
inode bit-lock. We cannot use e.g. i_mutex for that because it ranks above
mmap_sem which is held when we enter page_mkwrite.

  So if you have any idea how to better solve this, you are welcome ;).

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
