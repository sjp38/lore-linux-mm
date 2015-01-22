Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 0FE866B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 08:09:12 -0500 (EST)
Received: by mail-qc0-f181.google.com with SMTP id l6so1025167qcy.12
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 05:09:11 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 91si4502256qgo.15.2015.01.22.05.09.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jan 2015 05:09:10 -0800 (PST)
Date: Thu, 22 Jan 2015 08:09:06 -0500
From: Brian Foster <bfoster@redhat.com>
Subject: Re: [RFC PATCH 1/6] xfs: introduce mmap/truncate lock
Message-ID: <20150122130905.GA25345@bfoster.bfoster>
References: <1420669543-8093-1-git-send-email-david@fromorbit.com>
 <1420669543-8093-2-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1420669543-8093-2-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jan 08, 2015 at 09:25:38AM +1100, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Right now we cannot serialise mmap against truncate or hole punch
> sanely. ->page_mkwrite is not able to take locks that the read IO
> path normally takes (i.e. the inode iolock) because that could
> result in lock inversions (read - iolock - page fault - page_mkwrite
> - iolock) and so we cannot use an IO path lock to serialise page
> write faults against truncate operations.
> 
> Instead, introduce a new lock that is used *only* in the
> ->page_mkwrite path that is the equivalent of the iolock. The lock
> ordering in a page fault is i_mmaplock -> page lock -> i_ilock,
> and so in truncate we can i_iolock -> i_mmaplock and so lock out
> new write faults during the process of truncation.
> 
> Because i_mmap_lock is outside the page lock, we can hold it across
> all the same operations we hold the i_iolock for. The only
> difference is that we never hold the i_mmaplock in the normal IO
> path and so do not ever have the possibility that we can page fault
> inside it. Hence there are no recursion issues on the i_mmap_lock
> and so we can use it to serialise page fault IO against inode
> modification operations that affect the IO path.
> 
> This patch introduces the i_mmaplock infrastructure, lockdep
> annotations and initialisation/destruction code. Use of the new lock
> will be in subsequent patches.
> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  fs/xfs/xfs_inode.c | 86 ++++++++++++++++++++++++++++++++++++++++++++----------
>  fs/xfs/xfs_inode.h | 29 +++++++++++++-----
>  fs/xfs/xfs_super.c |  2 ++
>  3 files changed, 95 insertions(+), 22 deletions(-)
> 
> diff --git a/fs/xfs/xfs_inode.c b/fs/xfs/xfs_inode.c
> index 400791a..573b49c 100644
> --- a/fs/xfs/xfs_inode.c
> +++ b/fs/xfs/xfs_inode.c
> @@ -150,6 +150,8 @@ xfs_ilock(
>  	 */
>  	ASSERT((lock_flags & (XFS_IOLOCK_SHARED | XFS_IOLOCK_EXCL)) !=
>  	       (XFS_IOLOCK_SHARED | XFS_IOLOCK_EXCL));
> +	ASSERT((lock_flags & (XFS_MMAPLOCK_SHARED | XFS_MMAPLOCK_EXCL)) !=
> +	       (XFS_MMAPLOCK_SHARED | XFS_MMAPLOCK_EXCL));

The comment that precedes xfs_ilock() explains the locks that exist
within the inode, locking order, etc. We should probably update it to
explain how i_mmap_lock fits in as well (e.g., text from the commit log
description would suffice, imo).

>  	ASSERT((lock_flags & (XFS_ILOCK_SHARED | XFS_ILOCK_EXCL)) !=
>  	       (XFS_ILOCK_SHARED | XFS_ILOCK_EXCL));
>  	ASSERT((lock_flags & ~(XFS_LOCK_MASK | XFS_LOCK_DEP_MASK)) == 0);
> @@ -159,6 +161,11 @@ xfs_ilock(
>  	else if (lock_flags & XFS_IOLOCK_SHARED)
>  		mraccess_nested(&ip->i_iolock, XFS_IOLOCK_DEP(lock_flags));
>  
> +	if (lock_flags & XFS_MMAPLOCK_EXCL)
> +		mrupdate_nested(&ip->i_mmaplock, XFS_IOLOCK_DEP(lock_flags));
> +	else if (lock_flags & XFS_MMAPLOCK_SHARED)
> +		mraccess_nested(&ip->i_mmaplock, XFS_IOLOCK_DEP(lock_flags));
> +

XFS_MMAPLOCK_DEP()?

>  	if (lock_flags & XFS_ILOCK_EXCL)
>  		mrupdate_nested(&ip->i_lock, XFS_ILOCK_DEP(lock_flags));
>  	else if (lock_flags & XFS_ILOCK_SHARED)
> @@ -191,6 +198,8 @@ xfs_ilock_nowait(
>  	 */
>  	ASSERT((lock_flags & (XFS_IOLOCK_SHARED | XFS_IOLOCK_EXCL)) !=
>  	       (XFS_IOLOCK_SHARED | XFS_IOLOCK_EXCL));
> +	ASSERT((lock_flags & (XFS_MMAPLOCK_SHARED | XFS_MMAPLOCK_EXCL)) !=
> +	       (XFS_MMAPLOCK_SHARED | XFS_MMAPLOCK_EXCL));
>  	ASSERT((lock_flags & (XFS_ILOCK_SHARED | XFS_ILOCK_EXCL)) !=
>  	       (XFS_ILOCK_SHARED | XFS_ILOCK_EXCL));
>  	ASSERT((lock_flags & ~(XFS_LOCK_MASK | XFS_LOCK_DEP_MASK)) == 0);
> @@ -202,21 +211,35 @@ xfs_ilock_nowait(
>  		if (!mrtryaccess(&ip->i_iolock))
>  			goto out;
>  	}
> +
> +	if (lock_flags & XFS_MMAPLOCK_EXCL) {
> +		if (!mrtryupdate(&ip->i_mmaplock))
> +			goto out_undo_iolock;
> +	} else if (lock_flags & XFS_MMAPLOCK_SHARED) {
> +		if (!mrtryaccess(&ip->i_mmaplock))
> +			goto out_undo_iolock;
> +	}
> +
>  	if (lock_flags & XFS_ILOCK_EXCL) {
>  		if (!mrtryupdate(&ip->i_lock))
> -			goto out_undo_iolock;
> +			goto out_undo_mmaplock;
>  	} else if (lock_flags & XFS_ILOCK_SHARED) {
>  		if (!mrtryaccess(&ip->i_lock))
> -			goto out_undo_iolock;
> +			goto out_undo_mmaplock;
>  	}
>  	return 1;
>  
> - out_undo_iolock:
> +out_undo_mmaplock:
> +	if (lock_flags & XFS_MMAPLOCK_EXCL)
> +		mrunlock_excl(&ip->i_mmaplock);
> +	else if (lock_flags & XFS_MMAPLOCK_SHARED)
> +		mrunlock_shared(&ip->i_mmaplock);
> +out_undo_iolock:
>  	if (lock_flags & XFS_IOLOCK_EXCL)
>  		mrunlock_excl(&ip->i_iolock);
>  	else if (lock_flags & XFS_IOLOCK_SHARED)
>  		mrunlock_shared(&ip->i_iolock);
> - out:
> +out:
>  	return 0;
>  }
>  
> @@ -244,6 +267,8 @@ xfs_iunlock(
>  	 */
>  	ASSERT((lock_flags & (XFS_IOLOCK_SHARED | XFS_IOLOCK_EXCL)) !=
>  	       (XFS_IOLOCK_SHARED | XFS_IOLOCK_EXCL));
> +	ASSERT((lock_flags & (XFS_MMAPLOCK_SHARED | XFS_MMAPLOCK_EXCL)) !=
> +	       (XFS_MMAPLOCK_SHARED | XFS_MMAPLOCK_EXCL));
>  	ASSERT((lock_flags & (XFS_ILOCK_SHARED | XFS_ILOCK_EXCL)) !=
>  	       (XFS_ILOCK_SHARED | XFS_ILOCK_EXCL));
>  	ASSERT((lock_flags & ~(XFS_LOCK_MASK | XFS_LOCK_DEP_MASK)) == 0);
> @@ -254,6 +279,11 @@ xfs_iunlock(
>  	else if (lock_flags & XFS_IOLOCK_SHARED)
>  		mrunlock_shared(&ip->i_iolock);
>  
> +	if (lock_flags & XFS_MMAPLOCK_EXCL)
> +		mrunlock_excl(&ip->i_mmaplock);
> +	else if (lock_flags & XFS_MMAPLOCK_SHARED)
> +		mrunlock_shared(&ip->i_mmaplock);
> +
>  	if (lock_flags & XFS_ILOCK_EXCL)
>  		mrunlock_excl(&ip->i_lock);
>  	else if (lock_flags & XFS_ILOCK_SHARED)
> @@ -271,11 +301,14 @@ xfs_ilock_demote(
>  	xfs_inode_t		*ip,
>  	uint			lock_flags)
>  {
> -	ASSERT(lock_flags & (XFS_IOLOCK_EXCL|XFS_ILOCK_EXCL));
> -	ASSERT((lock_flags & ~(XFS_IOLOCK_EXCL|XFS_ILOCK_EXCL)) == 0);
> +	ASSERT(lock_flags & (XFS_IOLOCK_EXCL|XFS_MMAPLOCK_EXCL|XFS_ILOCK_EXCL));
> +	ASSERT((lock_flags &
> +		~(XFS_IOLOCK_EXCL|XFS_MMAPLOCK_EXCL|XFS_ILOCK_EXCL)) == 0);
>  
>  	if (lock_flags & XFS_ILOCK_EXCL)
>  		mrdemote(&ip->i_lock);
> +	if (lock_flags & XFS_MMAPLOCK_EXCL)
> +		mrdemote(&ip->i_mmaplock);
>  	if (lock_flags & XFS_IOLOCK_EXCL)
>  		mrdemote(&ip->i_iolock);
>  
> @@ -294,6 +327,12 @@ xfs_isilocked(
>  		return rwsem_is_locked(&ip->i_lock.mr_lock);
>  	}
>  
> +	if (lock_flags & (XFS_MMAPLOCK_EXCL|XFS_MMAPLOCK_SHARED)) {
> +		if (!(lock_flags & XFS_MMAPLOCK_SHARED))
> +			return !!ip->i_mmaplock.mr_writer;
> +		return rwsem_is_locked(&ip->i_mmaplock.mr_lock);
> +	}
> +
>  	if (lock_flags & (XFS_IOLOCK_EXCL|XFS_IOLOCK_SHARED)) {
>  		if (!(lock_flags & XFS_IOLOCK_SHARED))
>  			return !!ip->i_iolock.mr_writer;
> @@ -314,14 +353,27 @@ int xfs_lock_delays;
>  #endif
>  
>  /*
> - * Bump the subclass so xfs_lock_inodes() acquires each lock with
> - * a different value
> + * Bump the subclass so xfs_lock_inodes() acquires each lock with a different
> + * value. This shouldn't be called for page fault locking, but we also need to
> + * ensure we don't overrun the number of lockdep subclasses for the iolock or
> + * mmaplock as that is limited to 12 by the mmap lock lockdep annotations.
>   */
>  static inline int
>  xfs_lock_inumorder(int lock_mode, int subclass)
>  {
> -	if (lock_mode & (XFS_IOLOCK_SHARED|XFS_IOLOCK_EXCL))
> +	if (lock_mode & (XFS_IOLOCK_SHARED|XFS_IOLOCK_EXCL)) {
> +		ASSERT(subclass + XFS_LOCK_INUMORDER <
> +			(1 << (XFS_MMAPLOCK_SHIFT - XFS_IOLOCK_SHIFT)));
>  		lock_mode |= (subclass + XFS_LOCK_INUMORDER) << XFS_IOLOCK_SHIFT;
> +	}
> +
> +	if (lock_mode & (XFS_MMAPLOCK_SHARED|XFS_MMAPLOCK_EXCL)) {
> +		ASSERT(subclass + XFS_LOCK_INUMORDER <
> +			(1 << (XFS_ILOCK_SHIFT - XFS_MMAPLOCK_SHIFT)));
> +		lock_mode |= (subclass + XFS_LOCK_INUMORDER) <<
> +							XFS_MMAPLOCK_SHIFT;
> +	}
> +
>  	if (lock_mode & (XFS_ILOCK_SHARED|XFS_ILOCK_EXCL))
>  		lock_mode |= (subclass + XFS_LOCK_INUMORDER) << XFS_ILOCK_SHIFT;
>  
> @@ -440,10 +492,10 @@ again:
>  }
>  
>  /*
> - * xfs_lock_two_inodes() can only be used to lock one type of lock
> - * at a time - the iolock or the ilock, but not both at once. If
> - * we lock both at once, lockdep will report false positives saying
> - * we have violated locking orders.
> + * xfs_lock_two_inodes() can only be used to lock one type of lock at a time -
> + * the iolock, the mmaplock or the ilock, but not more than one at a time. If we
> + * lock more than one at a time, lockdep will report false positives saying we
> + * have violated locking orders.
>   */
>  void
>  xfs_lock_two_inodes(
> @@ -455,8 +507,12 @@ xfs_lock_two_inodes(
>  	int			attempts = 0;
>  	xfs_log_item_t		*lp;
>  
> -	if (lock_mode & (XFS_IOLOCK_SHARED|XFS_IOLOCK_EXCL))
> -		ASSERT((lock_mode & (XFS_ILOCK_SHARED|XFS_ILOCK_EXCL)) == 0);
> +	if (lock_mode & (XFS_IOLOCK_SHARED|XFS_IOLOCK_EXCL)) {
> +		ASSERT(!(lock_mode & (XFS_MMAPLOCK_SHARED|XFS_MMAPLOCK_EXCL)));
> +		ASSERT(!(lock_mode & (XFS_ILOCK_SHARED|XFS_ILOCK_EXCL)));
> +	} else if (lock_mode & (XFS_MMAPLOCK_SHARED|XFS_MMAPLOCK_EXCL))
> +		ASSERT(!(lock_mode & (XFS_ILOCK_SHARED|XFS_ILOCK_EXCL)));
> +

Should this last branch not also check for iolock flags? If not, how is
that consistent with the function comment above?

Brian

>  	ASSERT(ip0->i_ino != ip1->i_ino);
>  
>  	if (ip0->i_ino > ip1->i_ino) {
> diff --git a/fs/xfs/xfs_inode.h b/fs/xfs/xfs_inode.h
> index de97ccc..8e7a12a 100644
> --- a/fs/xfs/xfs_inode.h
> +++ b/fs/xfs/xfs_inode.h
> @@ -56,6 +56,7 @@ typedef struct xfs_inode {
>  	struct xfs_inode_log_item *i_itemp;	/* logging information */
>  	mrlock_t		i_lock;		/* inode lock */
>  	mrlock_t		i_iolock;	/* inode IO lock */
> +	mrlock_t		i_mmaplock;	/* inode mmap IO lock */
>  	atomic_t		i_pincount;	/* inode pin count */
>  	spinlock_t		i_flags_lock;	/* inode i_flags lock */
>  	/* Miscellaneous state. */
> @@ -263,15 +264,20 @@ static inline int xfs_isiflocked(struct xfs_inode *ip)
>  #define	XFS_IOLOCK_SHARED	(1<<1)
>  #define	XFS_ILOCK_EXCL		(1<<2)
>  #define	XFS_ILOCK_SHARED	(1<<3)
> +#define	XFS_MMAPLOCK_EXCL	(1<<4)
> +#define	XFS_MMAPLOCK_SHARED	(1<<5)
>  
>  #define XFS_LOCK_MASK		(XFS_IOLOCK_EXCL | XFS_IOLOCK_SHARED \
> -				| XFS_ILOCK_EXCL | XFS_ILOCK_SHARED)
> +				| XFS_ILOCK_EXCL | XFS_ILOCK_SHARED \
> +				| XFS_MMAPLOCK_EXCL | XFS_MMAPLOCK_SHARED)
>  
>  #define XFS_LOCK_FLAGS \
>  	{ XFS_IOLOCK_EXCL,	"IOLOCK_EXCL" }, \
>  	{ XFS_IOLOCK_SHARED,	"IOLOCK_SHARED" }, \
>  	{ XFS_ILOCK_EXCL,	"ILOCK_EXCL" }, \
> -	{ XFS_ILOCK_SHARED,	"ILOCK_SHARED" }
> +	{ XFS_ILOCK_SHARED,	"ILOCK_SHARED" }, \
> +	{ XFS_MMAPLOCK_EXCL,	"MMAPLOCK_EXCL" }, \
> +	{ XFS_MMAPLOCK_SHARED,	"MMAPLOCK_SHARED" }
>  
>  
>  /*
> @@ -302,17 +308,26 @@ static inline int xfs_isiflocked(struct xfs_inode *ip)
>  #define XFS_IOLOCK_SHIFT	16
>  #define	XFS_IOLOCK_PARENT	(XFS_LOCK_PARENT << XFS_IOLOCK_SHIFT)
>  
> +#define XFS_MMAPLOCK_SHIFT	20
> +
>  #define XFS_ILOCK_SHIFT		24
>  #define	XFS_ILOCK_PARENT	(XFS_LOCK_PARENT << XFS_ILOCK_SHIFT)
>  #define	XFS_ILOCK_RTBITMAP	(XFS_LOCK_RTBITMAP << XFS_ILOCK_SHIFT)
>  #define	XFS_ILOCK_RTSUM		(XFS_LOCK_RTSUM << XFS_ILOCK_SHIFT)
>  
> -#define XFS_IOLOCK_DEP_MASK	0x00ff0000
> +#define XFS_IOLOCK_DEP_MASK	0x000f0000
> +#define XFS_MMAPLOCK_DEP_MASK	0x00f00000
>  #define XFS_ILOCK_DEP_MASK	0xff000000
> -#define XFS_LOCK_DEP_MASK	(XFS_IOLOCK_DEP_MASK | XFS_ILOCK_DEP_MASK)
> -
> -#define XFS_IOLOCK_DEP(flags)	(((flags) & XFS_IOLOCK_DEP_MASK) >> XFS_IOLOCK_SHIFT)
> -#define XFS_ILOCK_DEP(flags)	(((flags) & XFS_ILOCK_DEP_MASK) >> XFS_ILOCK_SHIFT)
> +#define XFS_LOCK_DEP_MASK	(XFS_IOLOCK_DEP_MASK | \
> +				 XFS_MMAPLOCK_DEP_MASK | \
> +				 XFS_ILOCK_DEP_MASK)
> +
> +#define XFS_IOLOCK_DEP(flags)	(((flags) & XFS_IOLOCK_DEP_MASK) \
> +					>> XFS_IOLOCK_SHIFT)
> +#define XFS_MMAPLOCK_DEP(flags)	(((flags) & XFS_MMAPLOCK_DEP_MASK) \
> +					>> XFS_MMAPLOCK_SHIFT)
> +#define XFS_ILOCK_DEP(flags)	(((flags) & XFS_ILOCK_DEP_MASK) \
> +					>> XFS_ILOCK_SHIFT)
>  
>  /*
>   * For multiple groups support: if S_ISGID bit is set in the parent
> diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
> index afd6bae..40d2ac5 100644
> --- a/fs/xfs/xfs_super.c
> +++ b/fs/xfs/xfs_super.c
> @@ -986,6 +986,8 @@ xfs_fs_inode_init_once(
>  	atomic_set(&ip->i_pincount, 0);
>  	spin_lock_init(&ip->i_flags_lock);
>  
> +	mrlock_init(&ip->i_mmaplock, MRLOCK_ALLOW_EQUAL_PRI|MRLOCK_BARRIER,
> +		     "xfsino", ip->i_ino);
>  	mrlock_init(&ip->i_lock, MRLOCK_ALLOW_EQUAL_PRI|MRLOCK_BARRIER,
>  		     "xfsino", ip->i_ino);
>  }
> -- 
> 2.0.0
> 
> _______________________________________________
> xfs mailing list
> xfs@oss.sgi.com
> http://oss.sgi.com/mailman/listinfo/xfs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
