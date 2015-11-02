Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id F23906B0038
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 15:10:46 -0500 (EST)
Received: by pacfv9 with SMTP id fv9so164588764pac.3
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 12:10:46 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id yb1si37252874pab.179.2015.11.02.12.10.44
        for <linux-mm@kvack.org>;
        Mon, 02 Nov 2015 12:10:45 -0800 (PST)
Date: Tue, 3 Nov 2015 07:10:29 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC 00/11] DAX fsynx/msync support
Message-ID: <20151102201029.GI10656@dastard>
References: <1446149535-16200-1-git-send-email-ross.zwisler@linux.intel.com>
 <20151030035533.GU19199@dastard>
 <20151030183938.GC24643@linux.intel.com>
 <20151101232948.GF10656@dastard>
 <x49vb9kqy5k.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49vb9kqy5k.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>

On Mon, Nov 02, 2015 at 09:22:15AM -0500, Jeff Moyer wrote:
> Dave Chinner <david@fromorbit.com> writes:
> 
> > Further, REQ_FLUSH/REQ_FUA are more than just "put the data on stable
> > storage" commands. They are also IO barriers that affect scheduling
> > of IOs in progress and in the request queues.  A REQ_FLUSH/REQ_FUA
> > IO cannot be dispatched before all prior IO has been dispatched and
> > drained from the request queue, and IO submitted after a queued
> > REQ_FLUSH/REQ_FUA cannot be scheduled ahead of the queued
> > REQ_FLUSH/REQ_FUA operation.
> >
> > IOWs, REQ_FUA/REQ_FLUSH not only guarantee data is on stable
> > storage, they also guarantee the order of IO dispatch and
> > completion when concurrent IO is in progress.
> 
> This hasn't been the case for several years, now.  It used to work that
> way, and that was deemed a big performance problem.  Since file systems
> already issued and waited for all I/O before sending down a barrier, we
> decided to get rid of the I/O ordering pieces of barriers (and stop
> calling them barriers).
> 
> See commit 28e7d184521 (block: drop barrier ordering by queue draining).

Yes, I realise that, even if I wasn't very clear about how I wrote
it. ;)

Correct me if I'm wrong: AFAIA, dispatch ordering (i.e. the "IO
barrier") is still enforced by the scheduler via REQ_FUA|REQ_FLUSH
-> ELEVATOR_INSERT_FLUSH -> REQ_SOFTBARRIER and subsequent IO
scheduler calls to elv_dispatch_sort() that don't pass
REQ_SOFTBARRIER in the queue.

IOWs, if we queue a bunch of REQ_WRITE IOs followed by a
REQ_WRITE|REQ_FLUSH IO, all of the prior REQ_WRITE IOs will be
dispatched before the REQ_WRITE|REQ_FLUSH IO and hence be captured
by the cache flush.

Hence once the filesystem has waited on the REQ_WRITE|REQ_FLUSH IO
to complete, we know that all the earlier REQ_WRITE IOs are on
stable storage, too. Hence there's no need for the elevator to drain
the queue to guarantee completion ordering - the dispatch ordering
and flush/fua write semantics guarantee that when the flush/fua
completes, all the IOs dispatch prior to that flush/fua write are
also on stable storage...

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
