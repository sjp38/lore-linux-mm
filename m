Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 26E6E6B0253
	for <linux-mm@kvack.org>; Sat, 23 Jan 2016 17:23:03 -0500 (EST)
Received: by mail-ig0-f169.google.com with SMTP id ik10so13129920igb.1
        for <linux-mm@kvack.org>; Sat, 23 Jan 2016 14:23:03 -0800 (PST)
Date: Sun, 24 Jan 2016 09:22:57 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 07/13] aio: enabled thread based async fsync
Message-ID: <20160123222257.GG6033@dastard>
References: <CA+55aFxCM-xWVR4jC=q2wSk+-WC1Xuf+nZLoud8JwKZopnR_dQ@mail.gmail.com>
 <20160115202131.GH6330@kvack.org>
 <CA+55aFzRo3yztEBBvJ4CMCvVHAo6qEDhTHTc_LGyqmxbcFyNYw@mail.gmail.com>
 <20160120195957.GV6033@dastard>
 <CA+55aFx4PzugV+wOKRqMEwo8XJ1QxP8r+s-mvn6H064FROnKdQ@mail.gmail.com>
 <20160120204449.GC12249@kvack.org>
 <20160120214546.GX6033@dastard>
 <20160120215630.GD12249@kvack.org>
 <20160123042449.GE6033@dastard>
 <20160123045024.GA32488@kvack.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160123045024.GA32488@kvack.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-aio@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jan 22, 2016 at 11:50:24PM -0500, Benjamin LaHaise wrote:
> On Sat, Jan 23, 2016 at 03:24:49PM +1100, Dave Chinner wrote:
> > On Wed, Jan 20, 2016 at 04:56:30PM -0500, Benjamin LaHaise wrote:
> > > On Thu, Jan 21, 2016 at 08:45:46AM +1100, Dave Chinner wrote:
> > > > Filesystems *must take locks* in the IO path. We have to serialise
> > > > against truncate and other operations at some point in the IO path
> > > > (e.g. block mapping vs concurrent allocation and/or removal), and
> > > > that can only be done sanely with sleeping locks.  There is no way
> > > > of knowing in advance if we are going to block, and so either we
> > > > always use threads for IO submission or we accept that occasionally
> > > > the AIO submission will block.
> > > 
> > > I never said we don't take locks.  Still, we can be more intelligent 
> > > about when and where we do so.  With the nonblocking pread() and pwrite() 
> > > changes being proposed elsewhere, we can do the part of the I/O that 
> > > doesn't block in the submitter, which is a huge win when possible.
> > > 
> > > As it stands today, *every* buffered write takes i_mutex immediately 
> > > on entering ->write().  That one issue alone accounts for a nearly 10x 
> > > performance difference between an O_SYNC write and an O_DIRECT write, 
> > 
> > Yes, that locking is for correct behaviour, not for performance
> > reasons.  The i_mutex is providing the required semantics for POSIX
> > write(2) functionality - writes must serialise against other reads
> > and writes so that they are completed atomically w.r.t. other IO.
> > i.e. writes to the same offset must not interleave, not should reads
> > be able to see partial data from a write in progress.
> 
> No, the locks are not *required* for POSIX semantics, they are a legacy
> of how Linux filesystem code has been implemented and how we ensure the
> necessary internal consistency needed inside our filesystems is
> provided.

That may be the case, but I really don't see how you can provide
such required functionality without some kind of exclusion barrier
in place. No matter how you implement that exclusion, it can be seen
effectively as a lock.

Even if the filesystem doesn't use the i_mutex for exclusion to the
page cache, it has to use some kind of lock as that IO still needs
to be serialised against any truncate, hole punch or other extent
manipulation that is currently in progress on the inode...

> There are other ways to achieve the required semantics that
> do not involve a single giant lock for the entire file/inode.

Most performant filesystems don't have a "single giant lock"
anymore. The problem is that the VFS expects the i_mutex to be held
for certain operations in the IO path and the VFS lock order
heirarchy makes it impossible to do anything but "get i_mutex
first".  That's the problem that needs to be solved - the VFS
enforces the "one giant lock" model, even when underlying
filesystems do not require it.

i.e. we could quite happily remove the i_mutex completely from the XFS
buffered IO path without breaking anything, but we can't because
that results in the VFS throwing warnings that we don't hold the
i_mutex (e.g like when removing the SUID bits on write). So there's
lots of VFS functionality that needs to be turned on it's head
before the i_mutex can be removed from the IO path.

> And no, I
> am not saying that doing this is simple or easy to do.

Sure. That's always been the problem. Even when a split IO/metadata
locking strategy like what XFS uses (and other modern filesystems
are moving to internally) is suggested as a model for solving
these problems, the usual response instant dismissal with
"no way, that's unworkable" and so nothing ever changes...

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
