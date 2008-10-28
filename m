Date: Tue, 28 Oct 2008 17:25:24 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: deadlock with latest xfs
Message-ID: <20081028062524.GQ4985@disturbed>
References: <4900412A.2050802@sgi.com> <20081026005351.GK18495@disturbed> <20081026025013.GL18495@disturbed> <200810281702.17135.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200810281702.17135.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Lachlan McIlroy <lachlan@sgi.com>, Christoph Hellwig <hch@infradead.org>, xfs-oss <xfs@oss.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 28, 2008 at 05:02:16PM +1100, Nick Piggin wrote:
> On Sunday 26 October 2008 13:50, Dave Chinner wrote:
> 
> > [1] I don't see how any of the XFS changes we made make this easier to hit.
> > What I suspect is a VM regression w.r.t. memory reclaim because this is
> > the second problem since 2.6.26 that appears to be a result of memory
> > allocation failures in places that we've never, ever seen failures before.
> >
> > The other new failure is this one:
> >
> > http://bugzilla.kernel.org/show_bug.cgi?id=11805
> >
> > which is an alloc_pages(GFP_KERNEL) failure....
> >
> > mm-folk - care to weight in?
> 
> order-0 alloc page GFP_KERNEL can fail sometimes. If it is called
> from reclaim or PF_MEMALLOC thread; if it is OOM-killed; fault
> injection.
> 
> This is even the case for __GFP_NOFAIL allocations (which basically
> are buggy anyway).
> 
> Not sure why it might have started happening, but I didn't see
> exactly which alloc_pages you are talking about? If it is via slab,
> then maybe some parameters have changed (eg. in SLUB) which is
> using higher order allocations.

In fs/xfs/linux-2.6/xfs_buf.c::xfs_buf_get_noaddr(). It's doing a
single page allocation at a time.

It may be that this failure is caused by an increase base memory
consumption of the kernel as this failure was reported in an lguest
and reproduced with a simple 'modprobe xfs ; mount /dev/xxx
/mnt/xfs' command. Maybe the lguest had very little memory available
to begin with and trying to allocate 2MB of pages for 8x256k log
buffers may have been too much for it...

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
