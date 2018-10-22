Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4719B6B0003
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 17:32:22 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e6-v6so30516968pge.5
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 14:32:22 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id bj8-v6si6644679plb.67.2018.10.22.14.32.19
        for <linux-mm@kvack.org>;
        Mon, 22 Oct 2018 14:32:20 -0700 (PDT)
Date: Tue, 23 Oct 2018 08:31:33 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 7/7] btrfs: drop mmap_sem in mkwrite for btrfs
Message-ID: <20181022213133.GB6311@dastard>
References: <20181018202318.9131-1-josef@toxicpanda.com>
 <20181018202318.9131-8-josef@toxicpanda.com>
 <20181019034847.GM18822@dastard>
 <20181022175652.ase7u23uzizqtlao@destiny>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181022175652.ase7u23uzizqtlao@destiny>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org, riel@fb.com, linux-mm@kvack.org

On Mon, Oct 22, 2018 at 01:56:54PM -0400, Josef Bacik wrote:
> On Fri, Oct 19, 2018 at 02:48:47PM +1100, Dave Chinner wrote:
> > On Thu, Oct 18, 2018 at 04:23:18PM -0400, Josef Bacik wrote:
> > > ->page_mkwrite is extremely expensive in btrfs.  We have to reserve
> > > space, which can take 6 lifetimes, and we could possibly have to wait on
> > > writeback on the page, another several lifetimes.  To avoid this simply
> > > drop the mmap_sem if we didn't have the cached page and do all of our
> > > work and return the appropriate retry error.  If we have the cached page
> > > we know we did all the right things to set this page up and we can just
> > > carry on.
> > > 
> > > Signed-off-by: Josef Bacik <josef@toxicpanda.com>
> > > ---
> > >  fs/btrfs/inode.c   | 41 +++++++++++++++++++++++++++++++++++++++--
> > >  include/linux/mm.h | 14 ++++++++++++++
> > >  mm/filemap.c       |  3 ++-
> > >  3 files changed, 55 insertions(+), 3 deletions(-)
> > > 
> > > diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
> > > index 3ea5339603cf..6b723d29bc0c 100644
> > > --- a/fs/btrfs/inode.c
> > > +++ b/fs/btrfs/inode.c
> > > @@ -8809,7 +8809,9 @@ static void btrfs_invalidatepage(struct page *page, unsigned int offset,
> > >  vm_fault_t btrfs_page_mkwrite(struct vm_fault *vmf)
> > >  {
> > >  	struct page *page = vmf->page;
> > > -	struct inode *inode = file_inode(vmf->vma->vm_file);
> > > +	struct file *file = vmf->vma->vm_file, *fpin;
> > > +	struct mm_struct *mm = vmf->vma->vm_mm;
> > > +	struct inode *inode = file_inode(file);
> > >  	struct btrfs_fs_info *fs_info = btrfs_sb(inode->i_sb);
> > >  	struct extent_io_tree *io_tree = &BTRFS_I(inode)->io_tree;
> > >  	struct btrfs_ordered_extent *ordered;
> > > @@ -8828,6 +8830,29 @@ vm_fault_t btrfs_page_mkwrite(struct vm_fault *vmf)
> > >  
> > >  	reserved_space = PAGE_SIZE;
> > >  
> > > +	/*
> > > +	 * We have our cached page from a previous mkwrite, check it to make
> > > +	 * sure it's still dirty and our file size matches when we ran mkwrite
> > > +	 * the last time.  If everything is OK then return VM_FAULT_LOCKED,
> > > +	 * otherwise do the mkwrite again.
> > > +	 */
> > > +	if (vmf->flags & FAULT_FLAG_USED_CACHED) {
> > > +		lock_page(page);
> > > +		if (vmf->cached_size == i_size_read(inode) &&
> > > +		    PageDirty(page))
> > > +			return VM_FAULT_LOCKED;
> > > +		unlock_page(page);
> > > +	}
> > 
> > What does the file size have to do with whether we can use the
> > initialised page or not? The file can be extended by other
> > data operations (like write()) while a page fault is in progress,
> > so I'm not sure how or why this check makes any sense.
> > 
> > I also don't see anything btrfs specific here, so....
> > 
> 
> First thanks for the review, I've gone through and addressed everything you
> mentioned, however this one is subtle.
> 
> The problem is the vmf->vma->vm_file access.  Once we drop the mmap_sem we can
> no longer safely go into vmf->vma, so I'd have to fix all the page_mkwrite()'s
> to not touch vma, and add a vmf->fpin instead to mess with.

Adding a vmf->file pointer seems pretty easy - making /everything/
use it instead of just special casing page_mkwrite also seems like
it would be a good idea - set it up in your new init function and
it's done. Pinning and unpinning could be done unconditionally, too
- that doesn't look expensive - and it would pull a lot of the
complexity out of the patchset for the cases where unlocking the
mmap_sem is done....

> Plus I didn't want
> to miss some subtlety in other fs's page_mkwrite()'s and inavertedly break them.
> If I break btrfs I can fix it, I'm not as good with xfs.

Sure, but if you make it a generic helper then you don't have to
worry about that. i.e.

generic_page_mkwrite_nommapsem(vmf, page_mkwrite_cb)
{
	/* use cached page if valid */

	/* unlock mmap_sem */

	/* do filesystem page_mkwrite callback */
	ret = page_mkwrite_cb(vmf);

	/* handle page caching */

	/* return retry fault indicator */
}

and that allows all filesystems to easily opt in to dropping the
mmap_sem and you don't have to worry about it too much. It means
filesystems with dax fault paths (like XFS) can convert the non-dax
paths that call immediately, and worry about the more tricky stuff
later...

> vmf->fpin and vmf->mm, and then fix up all the mkwrite()'s to use that instead

Ignoring DAX (because I haven't checked), what filesystem
page_mkwrite implementation requires access to the mm_struct? They
should all just be doing file operations on a page, not anything to
do with the way the page is mapped into the task memory....

> of vmf->vma.  I think that's the only things we care about so it wouldn't be
> hard.  Does that sound reasonable to you?

I think a little bit of tweaking, and it will be easy to for
everyone to opt in to this behaviour....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
