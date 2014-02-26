Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4CE8F6B003A
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 05:04:57 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id md12so785835pbc.7
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 02:04:56 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [2001:44b8:8060:ff02:300:1:2:7])
        by mx.google.com with ESMTP id bl2si522723pbb.132.2014.02.26.02.04.55
        for <linux-mm@kvack.org>;
        Wed, 26 Feb 2014 02:04:56 -0800 (PST)
Date: Wed, 26 Feb 2014 21:04:39 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v5 1/10] fs: Add new flag(FALLOC_FL_COLLAPSE_RANGE) for
 fallocate
Message-ID: <20140226100439.GV13647@dastard>
References: <1392741464-20029-1-git-send-email-linkinjeon@gmail.com>
 <20140222140625.GD26637@thunk.org>
 <20140223213606.GE4317@dastard>
 <alpine.LSU.2.11.1402251525370.2380@eggly.anvils>
 <20140226015747.GN13647@dastard>
 <alpine.LSU.2.11.1402252049250.1586@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1402252049250.1586@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Namjae Jeon <linkinjeon@gmail.com>, viro@zeniv.linux.org.uk, bpm@sgi.com, adilger.kernel@dilger.ca, jack@suse.cz, mtk.manpages@gmail.com, lczerner@redhat.com, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Namjae Jeon <namjae.jeon@samsung.com>, Ashish Sangwan <a.sangwan@samsung.com>

On Tue, Feb 25, 2014 at 09:25:40PM -0800, Hugh Dickins wrote:
> On Wed, 26 Feb 2014, Dave Chinner wrote:
> > On Tue, Feb 25, 2014 at 03:41:20PM -0800, Hugh Dickins wrote:
> > > On Mon, 24 Feb 2014, Dave Chinner wrote:
> > > > On Sat, Feb 22, 2014 at 09:06:25AM -0500, Theodore Ts'o wrote:
> > > > > On Wed, Feb 19, 2014 at 01:37:43AM +0900, Namjae Jeon wrote:
> > > > > > +	/*
> > > > > > +	 * There is no need to overlap collapse range with EOF, in which case
> > > > > > +	 * it is effectively a truncate operation
> > > > > > +	 */
> > > > > > +	if ((mode & FALLOC_FL_COLLAPSE_RANGE) &&
> > > > > > +	    (offset + len >= i_size_read(inode)))
> > > > > > +		return -EINVAL;
> > > > > > +
> > > > > 
> > > > > I wonder if we should just translate a collapse range that is
> > > > > equivalent to a truncate operation to, in fact, be a truncate
> > > > > operation?
> > > > 
> > > > Trying to collapse a range that extends beyond EOF, IMO, is likely
> > > > to only happen if the DVR/NLE application is buggy. Hence I think
> > > > that telling the application it is doing something that is likely to
> > > > be wrong is better than silently truncating the file....
> > > 
> > > I do agree with Ted on this point.  This is not an xfs ioctl added
> > > for one DVR/NLE application, it's a mode of a Linux system call.
> > > 
> > > We do not usually reject with an error when one system call happens
> > > to ask for something which can already be accomplished another way;
> > > nor nanny our callers.
> > > 
> > > It seems natural to me that COLLAPSE_RANGE should support beyond EOF;
> > > unless that adds significantly to implementation difficulties?
> > 
> > Yes, it does add to the implementation complexity significantly - it
> > adds data security issues that don't exist with the current API.
> > 
> > That is, Filesystems can have uninitialised blocks beyond EOF so
> > if we allow COLLAPSE_RANGE to shift them down within EOF, we now
> > have to ensure they are properly zeroed or marked as unwritten.
> > 
> > It also makes implementations more difficult. For example, XFS can
> > also have in-memory delayed allocation extents beyond EOF, and they
> > can't be brought into the range < EOF without either:
> > 
> > 	a) inserting zeroed pages with appropriately set up
> > 	and mapped bufferheads into the page cache for the range
> > 	that sits within EOF; or
> > 	b) truncating the delalloc extents beyond EOF before the
> > 	move
> > 
> > So, really, the moment you go beyond EOF filesystems have to do
> > quite a bit more validation and IO in the context of the system
> > call. It no longer becomes a pure extent manipulation offload - it
> > becomes a data security problem.
> 
> Those sound like problems you would already have solved for a
> simple extending truncate.

Yes, they have because of what truncate defines - that the region
between the old EOF and the new EOF must contain zeroes. truncate
does not move blocks around, it merely changes the EOF, and so the
solution is simple.


> But I wasn't really thinking of the offset > i_size case, just the
> offset + len >= i_size case: which would end with i_size at offset,
> and the areas you're worried about still beyond EOF - or am I confused?

Right, offset beyond EOF is just plain daft. But you're not thinking
of the entire picture. What happens when a system crashes half way
through a collapse operation? On tmpfs you don't care - everything
is lost, but on real filesystems we have to care about. 

offset + len beyond EOF is just truncate(offset).

>From the point of view of an application offloading a data movement
operation via collapse range, any range that overlaps EOF is wrong -
data beyond EOF is not accessible and is not available for the
application to move. Hence EINVAL - it's an invalid set of
parameters.

If we do allow it and implement it by block shifting (which,
technically, is the correct interpretation of the collapse range
behaviour because it preserves preallocation beyond
the collapsed region beyond EOF), then we have
thr problem of moving data blocks below EOF by extent shifting
before we change the EOF. That exposes blocks of undefined content
to the user if we crash and recover up to that point of the
operation. It's just plain dangerous, and if we allow this
possibility via the API, someone is going to make that mistake in a
filesystem because it's difficult to test and hard to get right.

> > And, indeed, the specification that we are working to is that the
> > applications that want to collapse the range of a file are using
> > this function instead of read/memcpy/write/truncate, which by
> > definition means they cannot shift ranges of the file beyond EOF
> > into the new file.
> > 
> > So IMO the API defines the functionality as required by the
> > applications that require it and *no more*. If you need some
> > different behaviour - we can add it via additional flags in future
> > when you have an application that requires it. 
> 
> You still seem to be thinking in terms of xfs ioctl hacks,
> rather than fully scoped Linux system calls.

Low blow, referee! :/

To set the record straight, this fallocate interface was originally
scoped and implemented for ext4, then extended to XFS by request.
it's never been near an XFS ioctl interface in it's life.

Besides, you're completely off the ball here. This isn't a fully
scoped Linux system call - that's what fallocate() is. fallocate()
is designed to be as extensible as possible within the constraints
of it's three control parameters (flags, offset, length).  This was
done so we could add new allocation primitives for filesystem
offloads in the future. That's *exactly* what collapse range is -
it is using fallocate in the way it was intended to be used.

FWIW, consider the the "can't change EOF with the hole punch
primitive" rule we defined.  We did that because hole punch needs to
work beyond EOF without changing EOF because having a hole punch
that removes preallocation beyond EOF extend the file is just plain
daft.

Hence if you want to punch a hole that crosses EOF and set EOF to
the start of the hole a the same time *you have to use truncate*.
Because, by definition, that's a *truncate operation*, not a *hole
punch operation*.

Now, consider the collapse range primitive and apply the same logic:

Applications cannot access data beyond EOF. Allowing them to
collapse a range past EOF is effectively saying "bring data
beyond EOF down into the file, then set EOF so you can't
access the data that was beyond the old EOF. It has potential for
stale data exposure, especially if the operation is fatally
interrupted (e.g. by a system crash or filesystem shutdown).

Hence if you want to collapse a range that crosses EOF and set EOF
to the start of the range a the same time *you have to use
truncate*.  Because, by definition, that's a *truncate operation*,
not a *collapse range operation*.

> But it probably doesn't matter too much, if we start with an error,
> and later correct that to a full implementation - an xfstest or LTP
> test which expected failure will fail once it sees success, but no
> users harmed in the making of this change.

If we want different behaviour in future, then we define a new
control flag to indicate that we want the different behaviour.  Yet
another reason we designed the fallocate syscall to be
extensible....

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
