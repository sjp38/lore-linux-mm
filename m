Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id EF2496B0069
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 02:06:48 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f188so152231711pgc.1
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 23:06:48 -0800 (PST)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id 37si14695537plq.20.2016.11.24.23.06.46
        for <linux-mm@kvack.org>;
        Thu, 24 Nov 2016 23:06:47 -0800 (PST)
Date: Fri, 25 Nov 2016 18:06:42 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/6] dax: add tracepoint infrastructure, PMD tracing
Message-ID: <20161125070642.GZ31101@dastard>
References: <1479926662-21718-1-git-send-email-ross.zwisler@linux.intel.com>
 <1479926662-21718-4-git-send-email-ross.zwisler@linux.intel.com>
 <20161124173220.GR1555@ZenIV.linux.org.uk>
 <20161125024918.GX31101@dastard>
 <20161125041419.GT1555@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161125041419.GT1555@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Linus Torvalds <torvalds@linux-foundation.org>

On Fri, Nov 25, 2016 at 04:14:19AM +0000, Al Viro wrote:
> [Linus Cc'd]
> 
> On Fri, Nov 25, 2016 at 01:49:18PM +1100, Dave Chinner wrote:
> > > they have become parts of stable userland ABI and are to be maintained
> > > indefinitely.  Don't expect "tracepoints are special case" to prevent that.
> > 
> > I call bullshit just like I always do when someone spouts this
> > "tracepoints are stable ABI" garbage.
> 
> > Quite frankly, anyone that wants to stop us from
> > adding/removing/changing tracepoints or the code that they are
> > reporting information about "because ABI" can go take a long walk
> > off a short cliff.  Diagnostic tracepoints are not part of the
> > stable ABI. End of story.
> 
> Tell that to Linus.  You had been in the room, IIRC, when that had been
> brought up this year in Santa Fe.

No, I wasn't at KS or plumbers, so this is all news to me. Beleive
me, if I was in the room when this discussion was in progress, you'd
remember it /very clearly/.

> "End of story" is not going to be
> yours (or mine, for that matter) to declare - Linus is the only one who
> can do that.  If he says "if userland code relies upon it, so that
> userland code needs to be fixed" - I'm very happy (and everyone involved
> can count upon quite a few free drinks from me at the next summit).  If
> it's "that userland code really shouldn't have relied upon it, and it's
> real unfortunate that it does, but we still get to keep it working" -
> too bad, "because ABI" is the reality and we will be the ones to take
> that long walk.

When the tracepoint infrastructure was added it was considered a
debugging tool and not stable - it was even exposed through
/sys/kernel/debug! We connected up the ~280 /debug/ tracepoints we
had in XFS at the time with the understanding it was a /diagnostic
tool/. We exposed all sorts of internal details we'd previously been
exposing with tracing through lcrash and kdb (and Irix before that)
so we could diagnose problems quickly on a running kernel.

The scope of tracepoints may have grown since then, but it does not
change the fact that many of the tracepoints that were added years
ago were done under the understanding that it was a mutable
interface and nobody could rely on any specific tracepoint detail
remaining unchanged.

We're still treating then as mutable diagnostic and debugging aids
across the kernel. In XFS, We've now got over *500* unique trace
events and *650* tracepoints; ignoring comments, *4%* of the entire
XFS kernel code base is tracing code.  We expose structure contents,
transaction states, locking algorithms, object life cycles, journal
operations, etc. All the new reverse mapping and shared data extent
code that has been merged in 4.8 and 4.9 has been extensively
exposed by tracepoints - these changes also modified a significant
number of existing tracepoints.

Put simply: every major and most minor pieces of functionality in
XFS are exposed via tracepoints.

Hence if the stable ABI tracepoint rules you've just described are
going to enforced, it will mean we will not be able to change
anything signficant in XFS because almost everything significant we
do involves changing tracepoints in some way. This leaves us with
three unacceptable choices:

	1. stop developing XFS so we can maintain the stable
	tracepoint ABI;

	2. ignore the ABI rules and hope that Linus keeps pulling
	code that obviously ignores the ABI rules; or

	3. screw over our upstream/vanilla kernel users by removing
	the tracepoints from Linus' tree and suck up the pain of
	maintaining an out of tree patch for XFS developers and
	distros so kernel tracepoint ABI rules can be ignored.

Nobody wins if these are the only choices we are being given.

I understand why there is a desire for stable tracepoints, and
that's why I suggested that there should be an in-kernel API to
declare stable tracepoints. That way we can have the best of both
worlds - tracepoints that applications need to be stable can be
declared, reviewed and explicitly marked as stable in full knowledge
of what that implies. The rest of the vast body of tracepoints can
be left as mutable with no stability or existence guarantees so that
developers can continue to treat them in a way that best suits
problem diagnosis without compromising the future development of the
code being traced. If userspace finds some of those tracepoints
useful, then they can be taken through the process of making them
into a maintainable stable form and being marked as such.

We already have distros mounting the tracing subsystem on
/sys/kernel/tracing. Expose all the stable tracepoints there, and
leave all the other tracepoints under /sys/kernel/debug/tracing.
Simple, clear separation between stable and mutable diagnostic
tracepoints for users, combined with a simple, clear in-kernel API
and process for making tracepoints stable....

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
