Received: from ip02.eastlink.ca ([24.222.39.20])
 by mta01.eastlink.ca (Sun Java System Messaging Server 6.2-4.03 (built Sep 22
 2005)) with ESMTP id <0KAB00IKQ25SDMI0@mta01.eastlink.ca> for
 linux-mm@kvack.org; Fri, 14 Nov 2008 00:08:16 -0400 (AST)
Date: Fri, 14 Nov 2008 00:08:16 -0400
From: Peter Cordes <peter@cordes.ca>
Subject: Re: [PATCH 2.6.28?] don't unlink an active swapfile
In-reply-to: <Pine.LNX.4.64.0811140234300.5027@blonde.site>
Message-id: <20081114040816.GS31127@cordes.ca>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7BIT
Content-disposition: inline
References: <bnJFK-3bu-7@gated-at.bofh.it> <bnR0A-4kq-1@gated-at.bofh.it>
 <E1KqkZK-0001HO-WF@be1.7eggert.dyndns.org>
 <Pine.LNX.4.64.0810171250410.22374@blonde.site>
 <20081018003117.GC26067@cordes.ca> <20081018051800.GO24654@1wt.eu>
 <Pine.LNX.4.64.0810182058120.7154@blonde.site>
 <20081018204948.GA22140@infradead.org> <20081018205647.GA29946@1wt.eu>
 <Pine.LNX.4.64.0811140234300.5027@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Willy Tarreau <w@1wt.eu>, Christoph Hellwig <hch@infradead.org>, Bodo Eggert <7eggert@gmx.de>, David Newall <davidn@davidnewall.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 14, 2008 at 02:37:22AM +0000, Hugh Dickins wrote:
> Peter Cordes is sorry that he rm'ed his swapfiles while they were in use,
> he then had no pathname to swapoff.  It's a curious little oversight, but
> not one worth a lot of hackery.

 Yeah, not a lot, but I'd say it's worth some.  On the system where I
'rm -rf'ed part of a filesystem before cp -a, mkfs, cp -a, I was left
unable to umount.  Plus, when I rebooted, Ubuntu's init scripts failed
to even sync the disks during shutdown.  A recently-written file on
the same XFS filesystem as the swap file ended up empty because of the
unclean shutdown. :(  I don't know if remount ro would have been
possible on a FS with an active swap file, but Ubuntu should have at
least tried to sync when umount failed.


>  Kudos to Willy Tarreau for turning this
> around from a discussion of synthetic pathnames to how to prevent unlink.

 Yeah, this is great; as a sysadmin, this produces exactly the right
behaviour, IMHO.  It doesn't have any chance of leaving files marked
immutable on disk after an unclean reboot, which was a fatal flaw in
the idea of setting the i bit on swap files, either in swapon(8) or in
the kernel.  That would introduce complexity for admins who would
otherwise never have to think about this.  The new behaviour this adds
should make sense to most admins;  They'll see
rm: swapfile: permission denied
or something, and should quickly realize that there must be something
special about active swap files.  So it's discoverable (i.e.
non-mysterious) behaviour.

 This prevents running with a deleted swapfile, but I can't think of a
case when that's useful, let alone worth the trouble of writing a new one every
reboot.  (e.g. xfs's resvsp ioctl creates extents flagged as unwritten
which can't be swapped on, so a swapfile would have to be actually
written on most filesystems.)

 And it doesn't add any size to the kernel binary, unlike my idea of
having a /proc/something/fd link that one could swapoff, having
sys_swapoff() fall back to parsing its argument as an integer index
into a list of swap areas, or other ugly ideas...  :P

 Thanks everyone for coming up with such a clever solution to the
pitfall I found.

> Mimic immutable: prohibit unlinking an active swapfile in may_delete()
> (and don't worry my little head over the tiny race window).
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
> ---
> Perhaps this is too late for 2.6.28: your decision.
> 
>  fs/namei.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- 2.6.28-rc4/fs/namei.c	2008-10-24 09:28:19.000000000 +0100
> +++ linux/fs/namei.c	2008-11-12 11:52:44.000000000 +0000
> @@ -1378,7 +1378,7 @@ static int may_delete(struct inode *dir,
>  	if (IS_APPEND(dir))
>  		return -EPERM;
>  	if (check_sticky(dir, victim->d_inode)||IS_APPEND(victim->d_inode)||
> -	    IS_IMMUTABLE(victim->d_inode))
> +	    IS_IMMUTABLE(victim->d_inode) || IS_SWAPFILE(victim->d_inode))
>  		return -EPERM;
>  	if (isdir) {
>  		if (!S_ISDIR(victim->d_inode->i_mode))

-- 
#define X(x,y) x##y
Peter Cordes ;  e-mail: X(peter@cor , des.ca)

"The gods confound the man who first found out how to distinguish the hours!
 Confound him, too, who in this place set up a sundial, to cut and hack
 my day so wretchedly into small pieces!" -- Plautus, 200 BC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
