Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id m5BF9JGE023054
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 20:39:19 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5BF92ba1056782
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 20:39:02 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m5BF9IW2014335
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 20:39:18 +0530
Date: Wed, 11 Jun 2008 20:38:45 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] ext2: Use page_mkwrite vma_operations to get mmap
	write notification.
Message-ID: <20080611150845.GA21910@skywalker>
References: <1212685513-32237-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20080605123045.445e380a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080605123045.445e380a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: cmm@us.ibm.com, jack@suse.cz, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 05, 2008 at 12:30:45PM -0700, Andrew Morton wrote:
> On Thu,  5 Jun 2008 22:35:12 +0530
> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> 
> > We would like to get notified when we are doing a write on mmap
> > section.  The changes are needed to handle ENOSPC when writing to an
> > mmap section of files with holes.
> > 
> 
> Whoa.  You didn't copy anything like enough mailing lists for a change
> of this magnitude.  I added some.
> 
> This is a large change in behaviour!
> 
> a) applications will now get a synchronous SIGBUS when modifying a
>    page over an ENOSPC filesystem.  Whereas previously they could have
>    proceeded to completion and then detected the error via an fsync().

Or not detect the error at all if we don't call fsync() right ? Isn't a
synchronous SIGBUS the right behaviour ?


> 
>    It's going to take more than one skimpy little paragraph to
>    justify this, and to demonstrate that it is preferable, and to
>    convince us that nothing will break from this user-visible behaviour
>    change.
> 
> b) we're now doing fs operations (and some I/O) in the pagefault
>    code.  This has several implications:
> 
>    - performance changes
> 
>    - potential for deadlocks when a process takes the fault from
>      within a copy_to_user() in, say, mm/filemap.c
> 
>    - performing additional memory allocations within that
>      copy_to_user().  Possibility that these will reenter the
>      filesystem.
> 
> And that's just ext2.
> 
> For ext3 things are even more complex, because we have the
> journal_start/journal_end pair which is effectively another "lock" for
> ranking/deadlock purposes.  And now we're taking i_alloc_sem and
> lock_page and we're doing ->writepage() and its potential
> journal_start(), all potentially within the context of a
> copy_to_user().

One of the reason why we would need this in ext3/ext4 is that we cannot
do block allocation in the writepage with the recent locking changes.
The locking changes involve changing the locking order of journal_start
and page_lock. With writepage we are already called with page_lock and
we can't start new transaction needed for block allocation.

But if we agree that we should not do block allocation in page_mkwrite
we need to add writepages and allocate blocks in writepages.

> 
> Now, things become easier because copy_to_user() only happens on the
> read() side of things, where we don't hold lock_page() and things are
> generally simpler.
> 
> But still, this is a high-risk change.  I think we should require a lot
> of convincing that issues such as the above have been suitably
> considered and addressed, and that the change has had *intense*
> testing.
> 
> > index 47d88da..cc2e106 100644
> > --- a/fs/ext2/ext2.h
> > +++ b/fs/ext2/ext2.h
> > @@ -136,6 +136,7 @@ extern void ext2_get_inode_flags(struct ext2_inode_info *);
> >  int __ext2_write_begin(struct file *file, struct address_space *mapping,
> >  		loff_t pos, unsigned len, unsigned flags,
> >  		struct page **pagep, void **fsdata);
> > +extern int ext2_page_mkwrite(struct vm_area_struct *vma, struct page *page);
> >  
> >  /* ioctl.c */
> >  extern long ext2_ioctl(struct file *, unsigned int, unsigned long);
> > diff --git a/fs/ext2/file.c b/fs/ext2/file.c
> > index 5f2fa9c..d539dcf 100644
> > --- a/fs/ext2/file.c
> > +++ b/fs/ext2/file.c
> > @@ -18,6 +18,7 @@
> >   * 	(jj@sunsite.ms.mff.cuni.cz)
> >   */
> >  
> > +#include <linux/mm.h>
> >  #include <linux/time.h>
> >  #include "ext2.h"
> >  #include "xattr.h"
> > @@ -38,6 +39,24 @@ static int ext2_release_file (struct inode * inode, struct file * filp)
> >  	return 0;
> >  }
> >  
> > +static struct vm_operations_struct ext2_file_vm_ops = {
> > +	.fault		= filemap_fault,
> > +	.page_mkwrite   = ext2_page_mkwrite,
> > +};
> > +
> > +static int ext2_file_mmap(struct file *file, struct vm_area_struct *vma)
> > +{
> > +	struct address_space *mapping = file->f_mapping;
> > +
> > +	if (!mapping->a_ops->readpage)
> > +		return -ENOEXEC;
> 
> this copied-and-pasted test can now be removed.
> 
> > +	file_accessed(file);
> > +	vma->vm_ops = &ext2_file_vm_ops;
> > +	vma->vm_flags |= VM_CAN_NONLINEAR;
> > +	return 0;
> > +}
> > +
> > +
> >  /*
> >   * We have mostly NULL's here: the current defaults are ok for
> >   * the ext2 filesystem.
> > @@ -52,7 +71,7 @@ static int ext2_release_file (struct inode * inode, struct file * filp)
> >  #ifdef CONFIG_COMPAT
> >  	.compat_ioctl	= ext2_compat_ioctl,
> >  #endif
> > -	.mmap		= generic_file_mmap,
> > +	.mmap		= ext2_file_mmap,
> >  	.open		= generic_file_open,
> >  	.release	= ext2_release_file,
> >  	.fsync		= ext2_sync_file,
> > diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
> > index 384fc0d..d4c5c23 100644
> > --- a/fs/ext2/inode.c
> > +++ b/fs/ext2/inode.c
> > @@ -1443,3 +1443,8 @@ int ext2_setattr(struct dentry *dentry, struct iattr *iattr)
> >  		error = ext2_acl_chmod(inode);
> >  	return error;
> >  }
> > +
> > +int ext2_page_mkwrite(struct vm_area_struct *vma, struct page *page)
> > +{
> > +	return block_page_mkwrite(vma, page, ext2_get_block);
> > +}
> > -- 

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
