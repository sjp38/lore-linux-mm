Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 35E2A6B004D
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 00:07:18 -0500 (EST)
Date: Mon, 19 Dec 2011 16:07:10 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: add missing mutex lock arround notify_change
Message-ID: <20111219050710.GQ23662@dastard>
References: <20111216112534.GA13147@dztty>
 <20111216125556.db2bf308.akpm@linux-foundation.org>
 <20111217214137.GY2203@ZenIV.linux.org.uk>
 <20111219014343.GK23662@dastard>
 <20111219020340.GG2203@ZenIV.linux.org.uk>
 <20111219020637.GA1653@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111219020637.GA1653@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Djalal Harouni <tixxdz@opendz.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>, Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>, Christoph Hellwig <hch@infradead.org>

On Mon, Dec 19, 2011 at 02:06:37AM +0000, Al Viro wrote:
> On Mon, Dec 19, 2011 at 02:03:40AM +0000, Al Viro wrote:
> 
> > OK, I'm definitely missing something.  The very first thing
> > xfs_file_aio_write_checks() does is
> >         xfs_rw_ilock(ip, XFS_ILOCK_EXCL);
> > which really makes me wonder how the hell does that manage to avoid an
> > instant deadlock in case of call via xfs_file_buffered_aio_write()
> > where we have:
> >         struct address_space    *mapping = file->f_mapping;
> >         struct inode            *inode = mapping->host;
> >         struct xfs_inode        *ip = XFS_I(inode);
> >         *iolock = XFS_IOLOCK_EXCL;
> >         xfs_rw_ilock(ip, *iolock);
> >         ret = xfs_file_aio_write_checks(file, &pos, &count, new_size, iolock);
> > which leads to
> >         struct inode            *inode = file->f_mapping->host;
> >         struct xfs_inode        *ip = XFS_I(inode);
> > (IOW, inode and ip are the same as in the caller) followed by
> >         xfs_rw_ilock(ip, XFS_ILOCK_EXCL);
> > and with both xfs_rw_ilock() calls turning into
> > 	mutex_lock(&VFS_I(ip)->i_mutex);
> >         xfs_ilock(ip, XFS_ILOCK_EXCL);
> > we ought to deadlock on that i_mutex.  What am I missing and how do we manage
> > to survive that?
> 
> Arrrgh...  OK, I see...  What I missed is that XFS_IOLOCK_EXCL is not
> XFS_ILOCK_EXCL.  Nice naming, that...

Been that way for 15 years. :/

However, the naming makes sense to me - the IO lock is for
serialising IO operations on the inode, while the I lock is for
serialising metadata operations on the inode. I guess I'm used to
it, though, so I'll conceed that it might look strange/confusing to
someone who only occassionally looks at the internal XFS locking
code....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
