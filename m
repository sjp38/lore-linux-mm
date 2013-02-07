Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id ABFAF6B0005
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 21:43:47 -0500 (EST)
Date: Thu, 7 Feb 2013 13:43:42 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 0/6 RFC] Mapping range lock
Message-ID: <20130207024342.GX2667@dastard>
References: <1359668994-13433-1-git-send-email-jack@suse.cz>
 <20130131160757.06d7f1c2.akpm@linux-foundation.org>
 <20130204123831.GE7523@quack.suse.cz>
 <20130205232512.GR2667@dastard>
 <20130206192534.GB11254@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130206192534.GB11254@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, Feb 06, 2013 at 08:25:34PM +0100, Jan Kara wrote:
> On Wed 06-02-13 10:25:12, Dave Chinner wrote:
> > On Mon, Feb 04, 2013 at 01:38:31PM +0100, Jan Kara wrote:
> > > On Thu 31-01-13 16:07:57, Andrew Morton wrote:
> > > > > c) i_mutex doesn't allow any paralellism of operations using it and some
> > > > >    filesystems workaround this for specific cases (e.g. DIO reads). Using
> > > > >    range locking allows for concurrent operations (e.g. writes, DIO) on
> > > > >    different parts of the file. Of course, range locking itself isn't
> > > > >    enough to make the parallelism possible. Filesystems still have to
> > > > >    somehow deal with the concurrency when manipulating inode allocation
> > > > >    data. But the range locking at least provides a common VFS mechanism for
> > > > >    serialization VFS itself needs and it's upto each filesystem to
> > > > >    serialize more if it needs to.
> > > > 
> > > > That would be useful to end-users, but I'm having trouble predicting
> > > > *how* useful.
> > >   As Zheng said, there are people interested in this for DIO. Currently
> > > filesystems each invent their own tweaks to avoid the serialization at
> > > least for the easiest cases.
> > 
> > The thing is, this won't replace the locking those filesystems use
> > to parallelise DIO - it just adds another layer of locking they'll
> > need to use. The locks filesystems like XFS use to serialise IO
> > against hole punch also serialise against many more internal
> > functions and so if these range locks don't have the same capability
> > we're going to have to retain those locks even after the range locks
> > are introduced. It basically means we're going to have two layers
> > of range locks - one for IO sanity and atomicity, and then this
> > layer just for hole punch vs mmap.
> > 
> > As i've said before, what we really need in XFS is IO range locks
> > because we need to be able to serialise operations against IO in
> > progress, not page cache operations in progress.
>   Hum, I'm not sure I follow you here. So mapping tree lock + PageLocked +
> PageWriteback serialize all IO for part of the file underlying the page.
> I.e. at most one of truncate (punch hole), DIO, writeback, buffered write,
> buffered read, page fault can run on that part of file.

Right, it serialises page cache operations sufficient to avoid
page cache coherence problems, but it does not serialise operations
sufficiently to provide atomicity between operations that should be
atomic w.r.t. each other.

> So how come it
> doesn't provide enough serialization for XFS?
> 
> Ah, is it the problem that if two threads do overlapping buffered writes
> to a file then we can end up with data mixed from the two writes (if we
> didn't have something like i_mutex)?

That's one case of specific concern - the POSIX write() atomicity
guarantee - but it indicates the cause of many of my other concerns,
too. e.g. write vs prealloc, write vs punch, read vs truncate, write
vs truncate, buffered vs direct write, etc.

Basically, page-cache granularity locking for buffered IO means that
it cannot be wholly serialised against any other operation in
progress. That means we can't use the range lock to provide a
barrier to guarantee that no IO is currently in progress at all, and
hence it doesn't provide the IO barrier semantics we need for
various operations within XFS.

An example of this is that the online defrag ioctl requires copyin +
mtime updates in the write path are atomic w.r.t the swap extents
ioctl so that it can detect concurrent modification of the file being
defragged and abort. The page cache based range locks simply don't
provide this coverage, and so we'd need to maintain the IO operation
locking we currently have to provide this exclusion..

Truncate is something I also see as particularly troublesome,
because the i_mutex current provides mutual exclusion against the
operational range of a buffered write (i.e. at the .aio_write level)
and not page granularity like this patch set would result in. Hence
the behaviour of write vs truncate races could change quite
significantly. e.g.  instead of "write completes then truncate" or
"truncate completes then write", we could have "partial write,
truncate, write continues and completes" resulting in a bunch of
zeros inside the range the write call wrote to. The application
won't even realise that the data it wrote was corrupted by the
racing truncate.....

IOWs, I think that the fundamental unit of atomicity we need here is
the operational range of the syscall i.e. that each of the protected
operations needs to execute atomically as a whole with respect to
each other, not in a piecemeal fashion where some use whole range
locking and others use fine-grained page-range locking...

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
