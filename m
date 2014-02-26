Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 364B26B0062
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 20:57:53 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id y10so258874pdj.29
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 17:57:52 -0800 (PST)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:5])
        by mx.google.com with ESMTP id gk3si22337400pac.263.2014.02.25.17.57.51
        for <linux-mm@kvack.org>;
        Tue, 25 Feb 2014 17:57:52 -0800 (PST)
Date: Wed, 26 Feb 2014 12:57:47 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v5 1/10] fs: Add new flag(FALLOC_FL_COLLAPSE_RANGE) for
 fallocate
Message-ID: <20140226015747.GN13647@dastard>
References: <1392741464-20029-1-git-send-email-linkinjeon@gmail.com>
 <20140222140625.GD26637@thunk.org>
 <20140223213606.GE4317@dastard>
 <alpine.LSU.2.11.1402251525370.2380@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1402251525370.2380@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Namjae Jeon <linkinjeon@gmail.com>, viro@zeniv.linux.org.uk, bpm@sgi.com, adilger.kernel@dilger.ca, jack@suse.cz, mtk.manpages@gmail.com, lczerner@redhat.com, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Namjae Jeon <namjae.jeon@samsung.com>, Ashish Sangwan <a.sangwan@samsung.com>

On Tue, Feb 25, 2014 at 03:41:20PM -0800, Hugh Dickins wrote:
> On Mon, 24 Feb 2014, Dave Chinner wrote:
> > On Sat, Feb 22, 2014 at 09:06:25AM -0500, Theodore Ts'o wrote:
> > > On Wed, Feb 19, 2014 at 01:37:43AM +0900, Namjae Jeon wrote:
> > > > +	/*
> > > > +	 * There is no need to overlap collapse range with EOF, in which case
> > > > +	 * it is effectively a truncate operation
> > > > +	 */
> > > > +	if ((mode & FALLOC_FL_COLLAPSE_RANGE) &&
> > > > +	    (offset + len >= i_size_read(inode)))
> > > > +		return -EINVAL;
> > > > +
> > > 
> > > I wonder if we should just translate a collapse range that is
> > > equivalent to a truncate operation to, in fact, be a truncate
> > > operation?
> > 
> > Trying to collapse a range that extends beyond EOF, IMO, is likely
> > to only happen if the DVR/NLE application is buggy. Hence I think
> > that telling the application it is doing something that is likely to
> > be wrong is better than silently truncating the file....
> 
> I do agree with Ted on this point.  This is not an xfs ioctl added
> for one DVR/NLE application, it's a mode of a Linux system call.
> 
> We do not usually reject with an error when one system call happens
> to ask for something which can already be accomplished another way;
> nor nanny our callers.
> 
> It seems natural to me that COLLAPSE_RANGE should support beyond EOF;
> unless that adds significantly to implementation difficulties?

Yes, it does add to the implementation complexity significantly - it
adds data security issues that don't exist with the current API.

That is, Filesystems can have uninitialised blocks beyond EOF so
if we allow COLLAPSE_RANGE to shift them down within EOF, we now
have to ensure they are properly zeroed or marked as unwritten.

It also makes implementations more difficult. For example, XFS can
also have in-memory delayed allocation extents beyond EOF, and they
can't be brought into the range < EOF without either:

	a) inserting zeroed pages with appropriately set up
	and mapped bufferheads into the page cache for the range
	that sits within EOF; or
	b) truncating the delalloc extents beyond EOF before the
	move

So, really, the moment you go beyond EOF filesystems have to do
quite a bit more validation and IO in the context of the system
call. It no longer becomes a pure extent manipulation offload - it
becomes a data security problem.

And, indeed, the specification that we are working to is that the
applications that want to collapse the range of a file are using
this function instead of read/memcpy/write/truncate, which by
definition means they cannot shift ranges of the file beyond EOF
into the new file.

So IMO the API defines the functionality as required by the
applications that require it and *no more*. If you need some
different behaviour - we can add it via additional flags in future
when you have an application that requires it. 

> Actually, is it even correct to fail at EOF?  What if fallocation
> with FALLOC_FL_KEEP_SIZE was used earlier, to allocate beyond EOF:
> shouldn't it be possible to shift that allocation down, along with
> the EOF, rather than leave it behind as a stranded island?

It does get shifted down - it just remains beyond EOF, just like it
was before the operation. And that is part of the specification of
COLLAPSE_RANGE - it was done so that preallocation (physical or
speculative delayed allocation) beyond EOF to avoid fragmentation as
the DVR continues to write is not screwed up by chopping out earlier
parts of the file.

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
