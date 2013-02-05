Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id D891F6B000A
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 18:25:16 -0500 (EST)
Date: Wed, 6 Feb 2013 10:25:12 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 0/6 RFC] Mapping range lock
Message-ID: <20130205232512.GR2667@dastard>
References: <1359668994-13433-1-git-send-email-jack@suse.cz>
 <20130131160757.06d7f1c2.akpm@linux-foundation.org>
 <20130204123831.GE7523@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130204123831.GE7523@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Mon, Feb 04, 2013 at 01:38:31PM +0100, Jan Kara wrote:
> On Thu 31-01-13 16:07:57, Andrew Morton wrote:
> > > c) i_mutex doesn't allow any paralellism of operations using it and some
> > >    filesystems workaround this for specific cases (e.g. DIO reads). Using
> > >    range locking allows for concurrent operations (e.g. writes, DIO) on
> > >    different parts of the file. Of course, range locking itself isn't
> > >    enough to make the parallelism possible. Filesystems still have to
> > >    somehow deal with the concurrency when manipulating inode allocation
> > >    data. But the range locking at least provides a common VFS mechanism for
> > >    serialization VFS itself needs and it's upto each filesystem to
> > >    serialize more if it needs to.
> > 
> > That would be useful to end-users, but I'm having trouble predicting
> > *how* useful.
>   As Zheng said, there are people interested in this for DIO. Currently
> filesystems each invent their own tweaks to avoid the serialization at
> least for the easiest cases.

The thing is, this won't replace the locking those filesystems use
to parallelise DIO - it just adds another layer of locking they'll
need to use. The locks filesystems like XFS use to serialise IO
against hole punch also serialise against many more internal
functions and so if these range locks don't have the same capability
we're going to have to retain those locks even after the range locks
are introduced. It basically means we're going to have two layers
of range locks - one for IO sanity and atomicity, and then this
layer just for hole punch vs mmap.

As i've said before, what we really need in XFS is IO range locks
because we need to be able to serialise operations against IO in
progress, not page cache operations in progress.  IOWs, locking at
the mapping tree level does not provide the right exclusion
semantics we need to get rid of the existing filesystem locking that
allows concurrent IO to be managed.  Hence the XFS IO path locking
suddenly because 4 locks deep:

	i_mutex
	  XFS_IOLOCK_{SHARED,EXCL}
	    mapping range lock
	      XFS_ILOCK_{SHARED,EXCL}

That's because the buffered IO path uses per-page lock ranges and to
provide atomicity of read vs write, read vs truncate, etc we still
need to use the XFS_IOLOCK_EXCL to provide this functionality.

Hence I really think we need to be driving this lock outwards to
where the i_mutex currently sits, turning it into an *IO range
lock*, and not an inner-level mapping range lock. i.e flattening the
locking to:

	io_range_lock(off, len)
	  fs internal inode metadata modification lock

Yes, I know this causes problems with mmap and locking orders, but
perhaps we should be trying to get that fixed first because it
simplifies the whole locking schema we need for filesystems to
behave sanely. i.e. shouldn't we be aiming to simplify things
as we rework locking rather than make the more complex?

IOWs, I think the "it's a mapping range lock" approach is not the
right level to be providing IO exclusion semantics. After all, it's
entire IO ranges that we need to provide -atomic- exclusion for...

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
