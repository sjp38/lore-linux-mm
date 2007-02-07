Date: Thu, 8 Feb 2007 09:50:13 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [PATCH 1 of 2] Implement generic block_page_mkwrite() functionality
Message-ID: <20070207225013.GQ44411608@melbourne.sgi.com>
References: <20070207124922.GK44411608@melbourne.sgi.com> <Pine.LNX.4.64.0702071256530.25060@blonde.wat.veritas.com> <20070207144415.GN44411608@melbourne.sgi.com> <Pine.LNX.4.64.0702071454250.32223@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0702071454250.32223@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 07, 2007 at 03:56:15PM +0000, Hugh Dickins wrote:
> On Thu, 8 Feb 2007, David Chinner wrote:
> > On Wed, Feb 07, 2007 at 01:00:28PM +0000, Hugh Dickins wrote:
> > > 
> > > I'm worried about concurrent truncation.  Isn't it the case that
> > > i_mutex is held when prepare_write and commit_write are normally
> > > called?  But not here when page_mkwrite is called.
> > 
> > I'm not holding i_mutex. I assumed that it was probably safe to do
> > because we are likely to be reading the page off disk just before we
> > call mkwrite and that has to be synchronised with truncate in some
> > manner....
> 
> "assumed"..."probably"..."likely"..."just before"..."in some manner"
> doesn't sound very safe, does it :-?

You're right, it doesn't sound safe, does it? Why do you think I
posted the patches for comment?

> But page_mkwrite is something new: so far, it's up to the implementor
> (the filesystem) to work out how to guard against truncation.

Ok. I can do that now I know I have to.

> > So, do I need to grab the i_mutex here? Is that safe to do that in
> > the middle of a page fault?
> 
> It's certainly easier to think about if you don't grab i_mutex there:
> sys_msync used to take i_mutex within down_read of mmap_sem, but we
> were quite happy to get rid of that, because usually it's down_read
> of mmap_sem within i_mutex (page fault when writing from userspace
> to file).  I can't at this moment put my finger on an actual deadlock
> if you take i_mutex in page_mkwrite, but it feels wrong: hmm, if you
> add another thread waiting to down_write the mmap_sem, I think you
> would be able to deadlock.

Right, so i_mutex is out. That needs to be commented in big flashing
neon lights somewhere in the code.

> You don't need to lock out all truncation, but you do need to lock
> out truncation of the page in question.  Instead of your i_size
> checks, check page->mapping isn't NULL after the lock_page?

Yes, that can be done, but we still need to know if part of
the page is beyond EOF for when we call block_commit_write()
and mark buffers dirty. Hence we need to check the inode size.

I guess if we block the truncate with the page lock, then the
inode size is not going to change until we unlock the page.
If the inode size has already been changed but the page not yet
removed from the mapping we'll be beyond EOF.

So it seems to me that we can get away with not using the i_mutex
in the generic code here.

> But aside from the truncation issue, if prepare_write and commit_write
> are always called with i_mutex held at present, I'm doubtful whether
> you can provide a generic default page_mkwrite which calls them without.
> Which would take us back to grabbing i_mutex within page_mkwrite.  Ugh.

The only thing that is asserted as a requirement for
block_prepare_write is that the page is locked. Apart fromteh page
truncation issue, it is safe to do this at least on XFS because it
has internal locks that ensure sanity even when the i_mutex is not
held.  If a particular filesystem has different locking
requirements, they can be met in the filesystem wrapper function
(e.g.  xfs_vm_page_mkwrite()) which calls block_page_mkwrite().

> > If we do race with a truncate and the
> > page is now beyond EOF, what am I supposed to return?
> 
> Something negative.  Nothing presently reports the error code in
> question, it just does SIGBUS; but it would be better for the
> truncation case to avoid -ENOMEM and -ENOSPC, which could easily
> have meanings here.  I don't see a good choice, so maybe -EINVAL.

Ok.

> > I'm fishing for what I'm supposed to be doing here because there's
> > zero implementations of this callout in the kernel and the comments
> > in the code explaining the interface constraints are
> > non-existant....
> 
> Well, you seem to be the first to implement it.  Hmm, that's not true,
> David was: what magic saved him from addressing the truncation issue?

No idea. His code is not in mainline....

> Don't be surprised if it turns out page_mkwrite needs more thought.

I'll add a patch to the series adding some comments on the restrictions
placed on implementers of this function.

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
