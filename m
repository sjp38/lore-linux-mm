Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 50CB96B0071
	for <linux-mm@kvack.org>; Wed, 23 Jun 2010 19:06:38 -0400 (EDT)
Date: Thu, 24 Jun 2010 09:06:17 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through
 waiting for flusher thread
Message-ID: <20100623230617.GO6590@dastard>
References: <20100618060901.GA6590@dastard>
 <20100621233628.GL3828@quack.suse.cz>
 <20100622054409.GP7869@dastard>
 <20100621231416.904c50c7.akpm@linux-foundation.org>
 <20100622100924.GQ7869@dastard>
 <20100622131745.GB3338@quack.suse.cz>
 <20100622135234.GA11561@localhost>
 <20100622140258.GE3338@quack.suse.cz>
 <20100622222932.GR7869@dastard>
 <20100623131557.GB13649@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100623131557.GB13649@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hch@infradead.org, peterz@infradead.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 23, 2010 at 03:15:57PM +0200, Jan Kara wrote:
> On Wed 23-06-10 08:29:32, Dave Chinner wrote:
> > On Tue, Jun 22, 2010 at 04:02:59PM +0200, Jan Kara wrote:
> > > > 2) most writeback will be submitted by one per-bdi-flusher, so no worry
> > > >    of cache bouncing (this also means the per CPU counter error is
> > > >    normally bounded by the batch size)
> > >   Yes, writeback will be submitted by one flusher thread but the question
> > > is rather where the writeback will be completed. And that depends on which
> > > CPU that particular irq is handled. As far as my weak knowledge of HW goes,
> > > this very much depends on the system configuration (i.e., irq affinity and
> > > other things).
> > 
> > And how many paths to the storage you are using, how threaded the
> > underlying driver is, whether it is using MSI to direct interrupts to
> > multiple CPUs instead of just one, etc.
> > 
> > As we scale up we're more likely to see multiple CPUs doing IO
> > completion for the same BDI because the storage configs are more
> > complex in high end machines. Hence IMO preventing cacheline
> > bouncing between submission and completion is a significant
> > scalability concern.
>   Thanks for details. I'm wondering whether we could assume that although
> IO completion can run on several CPUs, it will be still a fairly limited
> number of CPUs.

I don't think we can. For example, the 10GB/s test bed I used in
2006 had 32 dual port FC HBAs in it and only 24 CPUs. The result was
that every single CPU was taking HBA interrupts and hence doing IO
completion processing.

> If this is the case, we could then implement a per-cpu counter
> that would additionally track number of CPUs modifying the counter
> (the number of CPUs would get zeroed in ???_counter_sum). This way
> the number of atomic operations won't be much higher (only one
> atomic inc when a CPU updates the counter for the first time) and
> if only several CPUs modify the counter, we would be able to bound
> the error much better.

Effectively track the number of changed counters? That might work on
several levels.  Firstly, the number of changed counters could be a
trigger for accurate summing during counter reads, and secondly it
could be used to optimise the summing only to lock and sum changed
CPUs, which should also speed that operation up...

I also had a thought for removing the error completely from the
default complete-on-submitter-cpu behaviour - all the percpu
accounting in that case is likely to be on the local counter, so the
counter read could return (fbc->count + local cpu count) rather than
just fbc->count. This gives us finer-grained visibility of local
completions at no extra cost.

This only falls down when completions are on another CPU, but if we
can track the maximum counter error bounds across those other CPUs
like you've suggest then we should be able to make this work...

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
