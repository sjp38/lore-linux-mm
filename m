Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5EDB06B01BF
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 19:30:32 -0400 (EDT)
Date: Sat, 19 Jun 2010 09:29:39 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through
 waiting for flusher thread
Message-ID: <20100618232939.GG6590@dastard>
References: <1276797878-28893-1-git-send-email-jack@suse.cz>
 <20100618060901.GA6590@dastard>
 <1276852260.27822.1598.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1276852260.27822.1598.camel@twins>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hch@infradead.org, akpm@linux-foundation.org, wfg@mail.ustc.edu.cn
List-ID: <linux-mm.kvack.org>

On Fri, Jun 18, 2010 at 11:11:00AM +0200, Peter Zijlstra wrote:
> On Fri, 2010-06-18 at 16:09 +1000, Dave Chinner wrote:
> > > +             bdi->wb_written_head = bdi_stat(bdi, BDI_WRITTEN) + wc->written;
> > 
> > The resolution of the percpu counters is an issue here, I think.
> > percpu counters update in batches of 32 counts per CPU. wc->written
> > is going to have a value of roughly 8 or 32 depending on whether
> > bdi->dirty_exceeded is set or not. I note that you take this into
> > account when checking dirty threshold limits, but it doesn't appear
> > to be taken in to here. 
> 
> The BDI stuff uses a custom batch-size, see bdi_stat_error() and
> related. The total error is in the order of O(n log n) where n is the
> number of CPUs.

#define BDI_STAT_BATCH (8*(1+ilog2(nr_cpu_ids)))

A dual socket server I have here:

[    0.000000] NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:32 nr_node_ids:2

Which means that the bdi per-cpu counter batch size on it would be 48
and the inaccuracy would be even bigger than I described. ;)

> But yeah, the whole dirty_exceeded thing makes life more
> interesting.

I suspect the 8 vs 32 pages could go away without too much impact
with the Jan's mechanism...

Another thing to consider is the impact of mulipage writes on the
incoming value to balance_dirty_pages - if we get 1024 page writes
running, then that may impact on the way throttling behaves, too.

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
