Return-Path: <owner-linux-mm@kvack.org>
Date: Fri, 22 Jan 2016 23:50:24 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH 07/13] aio: enabled thread based async fsync
Message-ID: <20160123045024.GA32488@kvack.org>
References: <CA+55aFyLb8scNSYb19rK4iT_Vx5=hKxqPwRHVnETzAhEev0aHw@mail.gmail.com> <CA+55aFxCM-xWVR4jC=q2wSk+-WC1Xuf+nZLoud8JwKZopnR_dQ@mail.gmail.com> <20160115202131.GH6330@kvack.org> <CA+55aFzRo3yztEBBvJ4CMCvVHAo6qEDhTHTc_LGyqmxbcFyNYw@mail.gmail.com> <20160120195957.GV6033@dastard> <CA+55aFx4PzugV+wOKRqMEwo8XJ1QxP8r+s-mvn6H064FROnKdQ@mail.gmail.com> <20160120204449.GC12249@kvack.org> <20160120214546.GX6033@dastard> <20160120215630.GD12249@kvack.org> <20160123042449.GE6033@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160123042449.GE6033@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-aio@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

On Sat, Jan 23, 2016 at 03:24:49PM +1100, Dave Chinner wrote:
> On Wed, Jan 20, 2016 at 04:56:30PM -0500, Benjamin LaHaise wrote:
> > On Thu, Jan 21, 2016 at 08:45:46AM +1100, Dave Chinner wrote:
> > > Filesystems *must take locks* in the IO path. We have to serialise
> > > against truncate and other operations at some point in the IO path
> > > (e.g. block mapping vs concurrent allocation and/or removal), and
> > > that can only be done sanely with sleeping locks.  There is no way
> > > of knowing in advance if we are going to block, and so either we
> > > always use threads for IO submission or we accept that occasionally
> > > the AIO submission will block.
> > 
> > I never said we don't take locks.  Still, we can be more intelligent 
> > about when and where we do so.  With the nonblocking pread() and pwrite() 
> > changes being proposed elsewhere, we can do the part of the I/O that 
> > doesn't block in the submitter, which is a huge win when possible.
> > 
> > As it stands today, *every* buffered write takes i_mutex immediately 
> > on entering ->write().  That one issue alone accounts for a nearly 10x 
> > performance difference between an O_SYNC write and an O_DIRECT write, 
> 
> Yes, that locking is for correct behaviour, not for performance
> reasons.  The i_mutex is providing the required semantics for POSIX
> write(2) functionality - writes must serialise against other reads
> and writes so that they are completed atomically w.r.t. other IO.
> i.e. writes to the same offset must not interleave, not should reads
> be able to see partial data from a write in progress.

No, the locks are not *required* for POSIX semantics, they are a legacy
of how Linux filesystem code has been implemented and how we ensure the
necessary internal consistency needed inside our filesystems is
provided.  There are other ways to achieve the required semantics that
do not involve a single giant lock for the entire file/inode.  And no, I
am not saying that doing this is simple or easy to do.

		-ben

> Direct IO does not conform to POSIX concurrency standards, so we
> don't have to serialise concurrent IO against each other.
> 
> > and using O_SYNC writes is a legitimate use-case for users who want 
> > caching of data by the kernel (duplicating that functionality is a huge 
> > amount of work for an application, plus if you want the cache to be 
> > persistent between runs of an app, you have to get the kernel to do it).
> 
> Yes, but you take what you get given. Buffered IO sucks in many ways;
> this is just one of them.
> 
> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com

-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
