Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 165DF6B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 16:30:20 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so4339709pad.7
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 13:30:19 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id gn10si13554460pbc.136.2015.01.22.13.30.17
        for <linux-mm@kvack.org>;
        Thu, 22 Jan 2015 13:30:18 -0800 (PST)
Date: Fri, 23 Jan 2015 08:30:14 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC PATCH 1/6] xfs: introduce mmap/truncate lock
Message-ID: <20150122213014.GA24722@dastard>
References: <1420669543-8093-1-git-send-email-david@fromorbit.com>
 <1420669543-8093-2-git-send-email-david@fromorbit.com>
 <20150122130905.GA25345@bfoster.bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150122130905.GA25345@bfoster.bfoster>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Foster <bfoster@redhat.com>
Cc: xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jan 22, 2015 at 08:09:06AM -0500, Brian Foster wrote:
> On Thu, Jan 08, 2015 at 09:25:38AM +1100, Dave Chinner wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > Right now we cannot serialise mmap against truncate or hole punch
> > sanely. ->page_mkwrite is not able to take locks that the read IO
> > path normally takes (i.e. the inode iolock) because that could
> > result in lock inversions (read - iolock - page fault - page_mkwrite
> > - iolock) and so we cannot use an IO path lock to serialise page
> > write faults against truncate operations.
.....
> > --- a/fs/xfs/xfs_inode.c
> > +++ b/fs/xfs/xfs_inode.c
> > @@ -150,6 +150,8 @@ xfs_ilock(
> >  	 */
> >  	ASSERT((lock_flags & (XFS_IOLOCK_SHARED | XFS_IOLOCK_EXCL)) !=
> >  	       (XFS_IOLOCK_SHARED | XFS_IOLOCK_EXCL));
> > +	ASSERT((lock_flags & (XFS_MMAPLOCK_SHARED | XFS_MMAPLOCK_EXCL)) !=
> > +	       (XFS_MMAPLOCK_SHARED | XFS_MMAPLOCK_EXCL));
> 
> The comment that precedes xfs_ilock() explains the locks that exist
> within the inode, locking order, etc. We should probably update it to
> explain how i_mmap_lock fits in as well (e.g., text from the commit log
> description would suffice, imo).

*nod*. Will fix.

> >  	ASSERT((lock_flags & (XFS_ILOCK_SHARED | XFS_ILOCK_EXCL)) !=
> >  	       (XFS_ILOCK_SHARED | XFS_ILOCK_EXCL));
> >  	ASSERT((lock_flags & ~(XFS_LOCK_MASK | XFS_LOCK_DEP_MASK)) == 0);
> > @@ -159,6 +161,11 @@ xfs_ilock(
> >  	else if (lock_flags & XFS_IOLOCK_SHARED)
> >  		mraccess_nested(&ip->i_iolock, XFS_IOLOCK_DEP(lock_flags));
> >  
> > +	if (lock_flags & XFS_MMAPLOCK_EXCL)
> > +		mrupdate_nested(&ip->i_mmaplock, XFS_IOLOCK_DEP(lock_flags));
> > +	else if (lock_flags & XFS_MMAPLOCK_SHARED)
> > +		mraccess_nested(&ip->i_mmaplock, XFS_IOLOCK_DEP(lock_flags));
> > +
> 
> XFS_MMAPLOCK_DEP()?

Good catch.

> > @@ -455,8 +507,12 @@ xfs_lock_two_inodes(
> >  	int			attempts = 0;
> >  	xfs_log_item_t		*lp;
> >  
> > -	if (lock_mode & (XFS_IOLOCK_SHARED|XFS_IOLOCK_EXCL))
> > -		ASSERT((lock_mode & (XFS_ILOCK_SHARED|XFS_ILOCK_EXCL)) == 0);
> > +	if (lock_mode & (XFS_IOLOCK_SHARED|XFS_IOLOCK_EXCL)) {
> > +		ASSERT(!(lock_mode & (XFS_MMAPLOCK_SHARED|XFS_MMAPLOCK_EXCL)));
> > +		ASSERT(!(lock_mode & (XFS_ILOCK_SHARED|XFS_ILOCK_EXCL)));
> > +	} else if (lock_mode & (XFS_MMAPLOCK_SHARED|XFS_MMAPLOCK_EXCL))
> > +		ASSERT(!(lock_mode & (XFS_ILOCK_SHARED|XFS_ILOCK_EXCL)));
> > +
> 
> Should this last branch not also check for iolock flags? If not, how is
> that consistent with the function comment above?

If we hit that else branch, we already know that the lock mode
does not contain IOLOCK flags. :)

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
