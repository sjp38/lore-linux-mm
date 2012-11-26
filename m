Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 603446B0072
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 16:28:49 -0500 (EST)
Date: Tue, 27 Nov 2012 08:28:45 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [Bug 50981] generic_file_aio_read ?: No locking means DATA
 CORRUPTION read and write on same 4096 page  range
Message-ID: <20121126212845.GJ6434@dastard>
References: <bug-50981-5823@https.bugzilla.kernel.org/>
 <20121126163328.ACEB011FE9C@bugzilla.kernel.org>
 <20121126164555.GL31891@thunk.org>
 <alpine.LNX.2.00.1211261144190.1183@eggly.anvils>
 <20121126201308.GA21050@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121126201308.GA21050@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, bugzilla-daemon@bugzilla.kernel.org, meetmehiro@gmail.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon, Nov 26, 2012 at 03:13:08PM -0500, Christoph Hellwig wrote:
> On Mon, Nov 26, 2012 at 12:05:57PM -0800, Hugh Dickins wrote:
> > Gosh, that's a very sudden new consensus.  The consensus over the past
> > ten or twenty years has been that the Linux kernel enforce locking for
> > consistent atomic writes, but skip that overhead on reads - hasn't it?
> 
> I'm not sure there was much of a consensus ever.  We XFS people always
> ttried to push everyone down the strict rule, but there was enough
> pushback that it didn't actually happen.
> 
> > Thanks, that's helpful; but I think linux-mm people would want to defer
> > to linux-fsdevel maintainers on this: mm/filemap.c happens to be in mm/,
> > but a fundamental change to VFS locking philosophy is not mm's call.
> > 
> > I don't see that page locking would have anything to do with it: if we
> > are going to start guaranteeing reads atomic against concurrent writes,
> > then surely it's the size requested by the user to be guaranteed,
> > spanning however many pages and fs-blocks: i_mutex, or a more
> > efficiently crafted alternative.
> 
> What XFS does is simply replace (or rather augment currently) i_mutex
> with a rw_semaphore (i_iolock in XFS) which is used the following way:
> 
> exclusive:
>  - buffer writes
>  - pagecache flushing before direct I/O (then downgraded)
>  - appending direct I/O writes
>  - less than blocksize granularity direct I/O
   - splice write

Also, direct extent manipulations that are outside the IO path such
as:
   - truncate
   - preallocation
   - hole punching

use the XFS_IOLOCK_EXCL to provide exclusion against new IO starting
while such an operation is in progress.

> shared:
>  - everything else (buffered reads, "normal" direct I/O)
> 
> Doing this in the highest levels of the generic_file_ code would be
> trivial, and would allow us to get rid of a fair chunk of wrappers in
> XFS.

We still need the iolock deep in the guts of the filesystem, though.

I suspect that if we are going to change the VFS locking, then we
should seriously consider allowing the filesystem to provide it's
own locking implementation and the VFS just pass the type of lock
required. Otherwise we are still going to need all the locking
within the filesystem to serialise all the core pieces that the VFS
locking doesn't serialise (e.g. EOF truncation on close/evict,
extent swaps for online defrag, etc).

> Note that we've been thinking about replacing this lock with a range
> lock, but this will require more research.

I'd say we need a working implementation in a filesystem before even
considering a VFS implementation...

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
