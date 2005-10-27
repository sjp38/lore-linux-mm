Date: Thu, 27 Oct 2005 23:37:21 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Message-ID: <20051027213721.GX5091@opteron.random>
References: <1130366995.23729.38.camel@localhost.localdomain> <200510271038.52277.ak@suse.de> <20051027131725.GI5091@opteron.random> <1130425212.23729.55.camel@localhost.localdomain> <20051027151123.GO5091@opteron.random> <20051027112054.10e945ae.akpm@osdl.org> <20051027200434.GT5091@opteron.random> <20051027135058.2f72e706.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051027135058.2f72e706.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: pbadari@us.ibm.com, ak@suse.de, hugh@veritas.com, jdike@addtoit.com, dvhltc@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 27, 2005 at 01:50:58PM -0700, Andrew Morton wrote:
> This is what I'm asking about.  What's the requirement?  What's the
> application?  What's the workload?  What's the testcase?  All that old
> stuff.  This should have been the very, very first thing which Badari
> presented to us.

I mentioned the reason we need that feature at the end of the last email.

> If we do it this way then we should do it for other filesystems.  And then

Why do you think so? Even O_DIRECT and the acl were not supported by all
the fs immediately, what's wrong with that? This is normal procedure as
far as I can tell. If -ENOSYS is returned, it means the app should
fallback to some other way to do the truncate by hand (depending on the
app, bzero could work or some other app can be ok with doing nothing at
all if -ENOSYS is returned).

> we should do it for files which _aren't_ mmapped.  And then we should do it
> on a finer-than-PAGE_SIZE granularity.

I agree with this. I also suggested doing all of it, not just the mmap
interface. However the only thing they care about is the mmap interface,
and this is why this is coming first. Also note, my MADV_TRUNCATE is by
coincidence needed by IBM too, the testcase I was trying to improve was
not an IBM workload, I learnt about the IBM effort only a few days ago.
But others happen to need it for the very same reason (no, not Oracle,
but Oracle would benefit from it too of course).

> IOW: we're unlikely to implement MADV_TRUNCATE for anything other than
> tmpfs, in which case MADV_TRUNCATE will remain a tmpfs specific hack, no?

In 2.6 yes. But in the future it's an API we can extend to work on more
fs with well defined semantics.

What's the benefit in having MADV_DISCARD that works on tmpfs, and then
some day in the future to add a MADV_TRUNCATE that works on other fs too?

The retval of MADV_TRUNCATE will still be an error in both cases for
older kernels. So we may go for the more generic API in the first place
IMHO.

The less MADV_MESS there is the better and the more explicit the name is
the better too.

> Or to swap it out.

Ok, the whole point is to release the swap. This stuff is already in
completely swap for ages, nobody touched it for ages, but it's bad for
performance and for swap fragmentation if after a peak of load 16G
remains always in swap when infact the app could release all the
swap after the load went down (if only it could use MADV_TRUNCATE).
 
At some point during the lifetime of the appliaction thousand of clients
connects, each one allocats from tmpfs, then when the load goes down we
want to free the swap that contains no useful info anymore. Perhaps such
a peak load will never happen again in the lifetime of the application,
and we want to have swap available for other usages. munmap isn't
enough, that's tmpfs backed storage, only truncate can release the swap.

> I think we need to restart this discussion.  Can we please have a

Sure no problem.

> *detailed* description of the problem?

Hope the above clarifies some more bits.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
