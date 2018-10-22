Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0E6B56B0006
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 13:56:58 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id j60-v6so48497595qtb.8
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 10:56:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o21sor22484584qve.43.2018.10.22.10.56.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Oct 2018 10:56:56 -0700 (PDT)
Date: Mon, 22 Oct 2018 13:56:54 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH 7/7] btrfs: drop mmap_sem in mkwrite for btrfs
Message-ID: <20181022175652.ase7u23uzizqtlao@destiny>
References: <20181018202318.9131-1-josef@toxicpanda.com>
 <20181018202318.9131-8-josef@toxicpanda.com>
 <20181019034847.GM18822@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181019034847.GM18822@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Josef Bacik <josef@toxicpanda.com>, kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org, riel@fb.com, linux-mm@kvack.org

On Fri, Oct 19, 2018 at 02:48:47PM +1100, Dave Chinner wrote:
> On Thu, Oct 18, 2018 at 04:23:18PM -0400, Josef Bacik wrote:
> > ->page_mkwrite is extremely expensive in btrfs.  We have to reserve
> > space, which can take 6 lifetimes, and we could possibly have to wait on
> > writeback on the page, another several lifetimes.  To avoid this simply
> > drop the mmap_sem if we didn't have the cached page and do all of our
> > work and return the appropriate retry error.  If we have the cached page
> > we know we did all the right things to set this page up and we can just
> > carry on.
> > 
> > Signed-off-by: Josef Bacik <josef@toxicpanda.com>
> > ---
> >  fs/btrfs/inode.c   | 41 +++++++++++++++++++++++++++++++++++++++--
> >  include/linux/mm.h | 14 ++++++++++++++
> >  mm/filemap.c       |  3 ++-
> >  3 files changed, 55 insertions(+), 3 deletions(-)
> > 
> > diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
> > index 3ea5339603cf..6b723d29bc0c 100644
> > --- a/fs/btrfs/inode.c
> > +++ b/fs/btrfs/inode.c
> > @@ -8809,7 +8809,9 @@ static void btrfs_invalidatepage(struct page *page, unsigned int offset,
> >  vm_fault_t btrfs_page_mkwrite(struct vm_fault *vmf)
> >  {
> >  	struct page *page = vmf->page;
> > -	struct inode *inode = file_inode(vmf->vma->vm_file);
> > +	struct file *file = vmf->vma->vm_file, *fpin;
> > +	struct mm_struct *mm = vmf->vma->vm_mm;
> > +	struct inode *inode = file_inode(file);
> >  	struct btrfs_fs_info *fs_info = btrfs_sb(inode->i_sb);
> >  	struct extent_io_tree *io_tree = &BTRFS_I(inode)->io_tree;
> >  	struct btrfs_ordered_extent *ordered;
> > @@ -8828,6 +8830,29 @@ vm_fault_t btrfs_page_mkwrite(struct vm_fault *vmf)
> >  
> >  	reserved_space = PAGE_SIZE;
> >  
> > +	/*
> > +	 * We have our cached page from a previous mkwrite, check it to make
> > +	 * sure it's still dirty and our file size matches when we ran mkwrite
> > +	 * the last time.  If everything is OK then return VM_FAULT_LOCKED,
> > +	 * otherwise do the mkwrite again.
> > +	 */
> > +	if (vmf->flags & FAULT_FLAG_USED_CACHED) {
> > +		lock_page(page);
> > +		if (vmf->cached_size == i_size_read(inode) &&
> > +		    PageDirty(page))
> > +			return VM_FAULT_LOCKED;
> > +		unlock_page(page);
> > +	}
> 
> What does the file size have to do with whether we can use the
> initialised page or not? The file can be extended by other
> data operations (like write()) while a page fault is in progress,
> so I'm not sure how or why this check makes any sense.
> 
> I also don't see anything btrfs specific here, so....
> 

First thanks for the review, I've gone through and addressed everything you
mentioned, however this one is subtle.

The problem is the vmf->vma->vm_file access.  Once we drop the mmap_sem we can
no longer safely go into vmf->vma, so I'd have to fix all the page_mkwrite()'s
to not touch vma, and add a vmf->fpin instead to mess with. Plus I didn't want
to miss some subtlety in other fs's page_mkwrite()'s and inavertedly break them.
If I break btrfs I can fix it, I'm not as good with xfs.

If you want this in the generic layer and not in the fs I can go back and add a
vmf->fpin and vmf->mm, and then fix up all the mkwrite()'s to use that instead
of vmf->vma.  I think that's the only things we care about so it wouldn't be
hard.  Does that sound reasonable to you?

Also the size thing was just a paranoid way to make sure everything had stayed
exactly the same, but you're right, I'll just keep it consistent with all of our
other "is this page ok" checks.  Thanks,

Josef
