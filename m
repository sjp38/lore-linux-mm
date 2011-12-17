Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 42F3A6B004F
	for <linux-mm@kvack.org>; Sat, 17 Dec 2011 16:41:52 -0500 (EST)
Date: Sat, 17 Dec 2011 21:41:37 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] mm: add missing mutex lock arround notify_change
Message-ID: <20111217214137.GY2203@ZenIV.linux.org.uk>
References: <20111216112534.GA13147@dztty>
 <20111216125556.db2bf308.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111216125556.db2bf308.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Djalal Harouni <tixxdz@opendz.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>, Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>, Christoph Hellwig <hch@infradead.org>

On Fri, Dec 16, 2011 at 12:55:56PM -0800, Andrew Morton wrote:

> >  static int __remove_suid(struct dentry *dentry, int kill)
> >  {
> > +	int ret;
> >  	struct iattr newattrs;
> >  
> >  	newattrs.ia_valid = ATTR_FORCE | kill;
> > -	return notify_change(dentry, &newattrs);
> > +
> > +	mutex_lock(&dentry->d_inode->i_mutex);
> > +	ret = notify_change(dentry, &newattrs);
> > +	mutex_unlock(&dentry->d_inode->i_mutex);
> > +
> > +	return ret;
> >  }

Consider this:
generic_file_aio_write():
        mutex_lock(&inode->i_mutex);
...
        ret = __generic_file_aio_write(iocb, iov, nr_segs, &iocb->ki_pos);

and from there we have
        err = file_remove_suid(file);
which calls __remove_suid()

Deadlock.  OK, let's look at the callers:

__remove_suid() <- file_remove_suid()

file_remove_suid() <-
	xip_file_write()			! we grab i_mutex there
	__generic_file_aio_write() <-
		generic_file_aio_write()	! we grab i_mutex there
		pohmelfs_write()		! we grab i_mutex there
		blkdev_aio_write()
	generic_file_splice_write()		! we grab i_mutex there
	xfs_file_aio_write_checks()
	ntfs_file_aio_write_nolock() <-
		ntfs_file_aio_write()		! we grab i_mutex there
	fuse_file_aio_write()			! we grab i_mutex there
	btrfs_file_aio_write()			! we grab i_mutex there
	ext4_ioctl(), EXT4_IOC_MOVE_EXT case

We have a shitload of deadlocks on very common paths with that patch.  What
of the paths that do lead to file_remove_suid() without i_mutex?
*	xfs_file_aio_write_checks(): we drop i_mutex (via xfs_rw_iunlock())
just before calling file_remove_suid().  Racy, the fix is obvious - move
file_remove_suid() call before unlocking.
*	ext4_ioctl(): doesn't bother with i_mutex at all, very likely to be
racy.  BTW, that file_remove_suid() belongs *before* mnt_drop_write(), for
obvious reasons.
*	blkdev_aio_write(): file_remove_suid() will be called, but it won't
reach __remove_suid() - should_remove_suid() returns 0 unless we are dealing
with regular file.  And for blkdev_aio_write() that file will be a block
device.

IOW, this patch is bogus and would have deadlocked the box as soon as one
would try to do write(2) on suid file.  Testing Is A Good Thing(tm).

xfs and ext4_ioctl() need to be fixed; XFS fix follows, ext4 I'd rather left
to ext4 folks - I don't know how wide an area needs i_mutex there

xfs: call file_remove_suid() before dropping i_mutex

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 753ed9b..33705b1 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -750,17 +750,16 @@ restart:
 		*new_sizep = new_size;
 	}
 
-	xfs_rw_iunlock(ip, XFS_ILOCK_EXCL);
-	if (error)
-		return error;
-
 	/*
 	 * If we're writing the file then make sure to clear the setuid and
 	 * setgid bits if the process is not being run by root.  This keeps
 	 * people from modifying setuid and setgid binaries.
 	 */
-	return file_remove_suid(file);
+	if (!error)
+		error = file_remove_suid(file);
 
+	xfs_rw_iunlock(ip, XFS_ILOCK_EXCL);
+	return error;
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
