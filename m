Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id EAE4B6B004D
	for <linux-mm@kvack.org>; Sun, 18 Dec 2011 21:06:47 -0500 (EST)
Date: Mon, 19 Dec 2011 02:06:37 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] mm: add missing mutex lock arround notify_change
Message-ID: <20111219020637.GA1653@ZenIV.linux.org.uk>
References: <20111216112534.GA13147@dztty>
 <20111216125556.db2bf308.akpm@linux-foundation.org>
 <20111217214137.GY2203@ZenIV.linux.org.uk>
 <20111219014343.GK23662@dastard>
 <20111219020340.GG2203@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111219020340.GG2203@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Djalal Harouni <tixxdz@opendz.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>, Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>, Christoph Hellwig <hch@infradead.org>

On Mon, Dec 19, 2011 at 02:03:40AM +0000, Al Viro wrote:

> OK, I'm definitely missing something.  The very first thing
> xfs_file_aio_write_checks() does is
>         xfs_rw_ilock(ip, XFS_ILOCK_EXCL);
> which really makes me wonder how the hell does that manage to avoid an
> instant deadlock in case of call via xfs_file_buffered_aio_write()
> where we have:
>         struct address_space    *mapping = file->f_mapping;
>         struct inode            *inode = mapping->host;
>         struct xfs_inode        *ip = XFS_I(inode);
>         *iolock = XFS_IOLOCK_EXCL;
>         xfs_rw_ilock(ip, *iolock);
>         ret = xfs_file_aio_write_checks(file, &pos, &count, new_size, iolock);
> which leads to
>         struct inode            *inode = file->f_mapping->host;
>         struct xfs_inode        *ip = XFS_I(inode);
> (IOW, inode and ip are the same as in the caller) followed by
>         xfs_rw_ilock(ip, XFS_ILOCK_EXCL);
> and with both xfs_rw_ilock() calls turning into
> 	mutex_lock(&VFS_I(ip)->i_mutex);
>         xfs_ilock(ip, XFS_ILOCK_EXCL);
> we ought to deadlock on that i_mutex.  What am I missing and how do we manage
> to survive that?

Arrrgh...  OK, I see...  What I missed is that XFS_IOLOCK_EXCL is not
XFS_ILOCK_EXCL.  Nice naming, that...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
