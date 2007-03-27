In-reply-to: <20070326232214.ee92d8c4.akpm@linux-foundation.org> (message from
	Andrew Morton on Mon, 26 Mar 2007 23:22:14 -0800)
Subject: Re: [patch resend v4] update ctime and mtime for mmaped write
References: <E1HVZyn-0008T8-00@dorka.pomaz.szeredi.hu>
	<20070326140036.f3352f81.akpm@linux-foundation.org>
	<E1HVwy4-0002UD-00@dorka.pomaz.szeredi.hu>
	<20070326153153.817b6a82.akpm@linux-foundation.org>
	<E1HW5am-0003Mc-00@dorka.pomaz.szeredi.hu> <20070326232214.ee92d8c4.akpm@linux-foundation.org>
Message-Id: <E1HW6Ec-0003Tv-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 27 Mar 2007 09:36:50 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > > clear_page_dirty_for_io() already does that.
> > > 
> > > So we should be able to test PageDirtiedByWrite() after running
> > > clear_page_dirty_for_io() to discover whether this page was dirtied via
> > > MAP_SHARED, and then update the inode times if so.
> > 
> > What do you need the page flag for?
> 
> To work out whether the page was dirtied via write (in which case the
> timestamps were updated) or via mmap (in which case they were not).
> 
> >  The "modified through mmap" info
> > is there in the ptes.
> 
> It might not be there any more - the ptes could have got taken down by, for
> example, reclaim.

Yes, but then the "modified through mmap" is transferred to the
per-address_space flag.  All this is already done by this patch.

> I dunno - I'm not trying very hard.  I'm trying to encourage you to come up
> with something less costly and less complex than this thing, but you appear
> to be resisting.

No, I'm just arguing that your suggestion is actually a complication,
not a simplification ;)

> >  And from the ptes it can be transfered to a
> > per-address_space flag.  Nobody is interested through which page was
> > the file modified.
> > 
> > Anyway, that's just MS_SYNC.  MS_ASYNC doesn't walk the pages, yet it
> > should update the timestamp.  That's the difficult one.
> > 
> 
> We can treat MS_ASYNC as we treat MS_SYNC.  Then, MS_ASYNC *does* walk the
> pages.  Is does it in generic_writepages().  It also even walks the ptes
> for you, in clear_page_dirty_for_io().

Yes.  But that's not very useful semantic for MS_ASYNC vs. file time
update.

It would basically say:

  "if you cann MS_ASYNC, and the file was modified then sometime in
  the future you will get an updated c/mtime".

But this is not what POSIX says, and it's not what applications want.

For example "make" would want to know if a file was modified or not,
and with your suggestion only msync(MS_SYNC) would reliably provide
that info.  But msync(MS_SYNC) is unnecessary in many cases.

> There is surely no need to duplicate all that.

Yeah, we could teach generic_writepages() to conditionally not submit
for io just test/clear pte dirtyness.

Maybe that would be somewhat cleaner, dunno.

Then there are the ram backed filesystems, which don't have dirty
accounting and radix trees, and for which this pte walking is still
needed to provide semantics consistent with normal filesystems.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
