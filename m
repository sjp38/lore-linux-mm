Date: Wed, 28 Jul 2004 18:40:40 -0500
From: Brent Casavant <bcasavan@sgi.com>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Subject: Re: Scaling problem with shmem_sb_info->stat_lock
In-Reply-To: <20040728160537.57c8c85b.akpm@osdl.org>
Message-ID: <Pine.SGI.4.58.0407281821040.33392@kzerza.americas.sgi.com>
References: <Pine.SGI.4.58.0407131449330.111843@kzerza.americas.sgi.com>
 <Pine.LNX.4.44.0407132113350.8577-100000@localhost.localdomain>
 <20040728022625.249c78da.akpm@osdl.org> <20040728095925.GQ2334@holomorphy.com>
 <Pine.SGI.4.58.0407281707370.33392@kzerza.americas.sgi.com>
 <20040728160537.57c8c85b.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 28 Jul 2004, Andrew Morton wrote:

> Brent Casavant <bcasavan@sgi.com> wrote:

> Normally a per-inode lock doesn't hurt too much because it's rare
> for lots of tasks to whack on the same inode at the same time.
>
> I guess with tmpfs-backed-shm, we have a rare workload.  How
> unpleasant.

Well, it's really not even a common workload for tmpfs-backed-shm, where
common means "non-HPC".  Where SGI ran into this problem is with MPI
startup.  Our workaround at this time is to replace one large /dev/zero
mapping shared amongst many forked processes (e.g. one process per CPU)
with a bunch of single-page mappings of the same total size.  This
apparently has the effect of breaking the mapping up into multiple inodes,
and reduces contention for any particular inode lock.

But that's an ugly hack, and we really want to get rid of it.  I may be
talking out my rear, but I suspect that this will cause issues elsewhere
(e.g. lots of tiny VM regions to track, which can be painful at
fork/exec/exit time [if my IRIX experience serves me well]).  I can look
into the specifics of the workaround and probably provide numbers if
anyone is really interested in such things at this point.

Brent

-- 
Brent Casavant             bcasavan@sgi.com        Forget bright-eyed and
Operating System Engineer  http://www.sgi.com/     bushy-tailed; I'm red-
Silicon Graphics, Inc.     44.8562N 93.1355W 860F  eyed and bushy-haired.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
