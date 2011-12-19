Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 3296A6B004D
	for <linux-mm@kvack.org>; Sun, 18 Dec 2011 21:04:00 -0500 (EST)
Date: Mon, 19 Dec 2011 02:03:40 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] mm: add missing mutex lock arround notify_change
Message-ID: <20111219020340.GG2203@ZenIV.linux.org.uk>
References: <20111216112534.GA13147@dztty>
 <20111216125556.db2bf308.akpm@linux-foundation.org>
 <20111217214137.GY2203@ZenIV.linux.org.uk>
 <20111219014343.GK23662@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111219014343.GK23662@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Djalal Harouni <tixxdz@opendz.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>, Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>, Christoph Hellwig <hch@infradead.org>

On Mon, Dec 19, 2011 at 12:43:43PM +1100, Dave Chinner wrote:
> > We have a shitload of deadlocks on very common paths with that patch.  What
> > of the paths that do lead to file_remove_suid() without i_mutex?
> > *	xfs_file_aio_write_checks(): we drop i_mutex (via xfs_rw_iunlock())
> > just before calling file_remove_suid().  Racy, the fix is obvious - move
> > file_remove_suid() call before unlocking.
> 
> Not exactly. xfs_rw_iunlock() is not doing what you think it's doing
> there.....

Huh?  It is called as 

> > -	xfs_rw_iunlock(ip, XFS_ILOCK_EXCL);

and thus in
static inline void
xfs_rw_iunlock(
        struct xfs_inode        *ip,
        int                     type)
{
        xfs_iunlock(ip, type);
        if (type & XFS_IOLOCK_EXCL)
                mutex_unlock(&VFS_I(ip)->i_mutex);
}
we are guaranteed to hit i_mutex.  

> Wrong lock.  That's dropping the internal XFS inode metadata lock,
> but the VFS i_mutex is associated with the internal XFS inode IO
> lock, which is accessed via XFS_IOLOCK_*. Only if we take the iolock
> via XFS_IOLOCK_EXCL do we actually take the i_mutex.

> Now it gets complex. For buffered IO, we are guaranteed to already
> be holding the i_mutex because we do:
> 
>         *iolock = XFS_IOLOCK_EXCL;
>         xfs_rw_ilock(ip, *iolock);
> 
>         ret = xfs_file_aio_write_checks(file, &pos, &count, new_size, iolock);
> 
> So that is safe and non-racy right now.

No, it is not - we *drop* it before calling file_remove_suid().  Explicitly.
Again, look at that xfs_rw_iunlock() call there - it does drop i_mutex
(which is to say, you'd better have taken it prior to that, or you have
far worse problems).

> For direct IO, however, we don't always take the IOLOCK exclusively.
> Indeed, we try really, really hard not to do this so we can do
> concurrent reads and writes to the inode, and that results
> in a bunch of lock juggling when we actually need the IOLOCK
> exclusive (like in xfs_file_aio_write_checks()). It sounds like we
> need to know if we are going to have to remove the SUID bit ahead of
> time so that we can  take the correct lock up front. I haven't
> looked at what is needed to do that yet.

OK, I'm definitely missing something.  The very first thing
xfs_file_aio_write_checks() does is
        xfs_rw_ilock(ip, XFS_ILOCK_EXCL);
which really makes me wonder how the hell does that manage to avoid an
instant deadlock in case of call via xfs_file_buffered_aio_write()
where we have:
        struct address_space    *mapping = file->f_mapping;
        struct inode            *inode = mapping->host;
        struct xfs_inode        *ip = XFS_I(inode);
        *iolock = XFS_IOLOCK_EXCL;
        xfs_rw_ilock(ip, *iolock);
        ret = xfs_file_aio_write_checks(file, &pos, &count, new_size, iolock);
which leads to
        struct inode            *inode = file->f_mapping->host;
        struct xfs_inode        *ip = XFS_I(inode);
(IOW, inode and ip are the same as in the caller) followed by
        xfs_rw_ilock(ip, XFS_ILOCK_EXCL);
and with both xfs_rw_ilock() calls turning into
	mutex_lock(&VFS_I(ip)->i_mutex);
        xfs_ilock(ip, XFS_ILOCK_EXCL);
we ought to deadlock on that i_mutex.  What am I missing and how do we manage
to survive that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
