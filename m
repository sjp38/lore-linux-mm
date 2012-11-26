Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id B4F1E6B0044
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 17:17:14 -0500 (EST)
Date: Tue, 27 Nov 2012 09:17:10 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [Bug 50981] generic_file_aio_read ?: No locking means DATA
 CORRUPTION read and write on same 4096 page  range
Message-ID: <20121126221710.GR32450@dastard>
References: <bug-50981-5823@https.bugzilla.kernel.org/>
 <20121126163328.ACEB011FE9C@bugzilla.kernel.org>
 <20121126164555.GL31891@thunk.org>
 <alpine.LNX.2.00.1211261144190.1183@eggly.anvils>
 <20121126201308.GA21050@infradead.org>
 <20121126214937.GA21590@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121126214937.GA21590@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, bugzilla-daemon@bugzilla.kernel.org, meetmehiro@gmail.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon, Nov 26, 2012 at 04:49:37PM -0500, Theodore Ts'o wrote:
> On Mon, Nov 26, 2012 at 03:13:08PM -0500, Christoph Hellwig wrote:
> > On Mon, Nov 26, 2012 at 12:05:57PM -0800, Hugh Dickins wrote:
> > > Gosh, that's a very sudden new consensus.  The consensus over the past
> > > ten or twenty years has been that the Linux kernel enforce locking for
> > > consistent atomic writes, but skip that overhead on reads - hasn't it?
> > 
> > I'm not sure there was much of a consensus ever.  We XFS people always
> > ttried to push everyone down the strict rule, but there was enough
> > pushback that it didn't actually happen.
> 
> Christoph, can you give some kind of estimate for the overhead that
> adding this locking in XFS actually costs in practice?

It doesn't show up any significant numbers in profiles, if that is
what you are asking.

I've tested over random 4k reads and writes at over 2 million IOPS
to a single file using concurrent direct IO, so the non-exclusive
locking overhead is pretty minimal. If the workload is modified
slightly to used buffered writes instead of direct IO writes and so
triggering shared/exclusive lock contention, then the same workload
tends to get limited at around 250,000 IOPS per file. That's a
direct result of the exclusive locking limiting the workload to what
a single CPU can sustain (i.e difference between 8p @ 250-300k iops
vs 1p @ 250k iops on the exclusive locking workload).

> And does XFS
> provide any kind of consistency guarantees if the reads/write overlap
> spans multiple pages?  I assume the answer to that is no, correct?

A buffered write is locked exclusive for the entire of the write.
That includes multiple page writes as the locking is outside of
the begin_write/end_write per-page iteration. Hence the atomicity of
the entire buffered write against both buffered read and direct IO
is guaranteed.

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
