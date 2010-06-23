Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A53776B0071
	for <linux-mm@kvack.org>; Wed, 23 Jun 2010 02:03:38 -0400 (EDT)
Date: Wed, 23 Jun 2010 16:03:19 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through
 waiting for flusher thread
Message-ID: <20100623060319.GN6590@dastard>
References: <20100621231416.904c50c7.akpm@linux-foundation.org>
 <20100622100924.GQ7869@dastard>
 <20100622131745.GB3338@quack.suse.cz>
 <20100622135234.GA11561@localhost>
 <20100622143124.GA15235@infradead.org>
 <20100622143856.GG3338@quack.suse.cz>
 <20100622224551.GS7869@dastard>
 <20100623013426.GA6706@localhost>
 <20100623030604.GM6590@dastard>
 <20100623032213.GA13068@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100623032213.GA13068@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "peterz@infradead.org" <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 23, 2010 at 11:22:13AM +0800, Wu Fengguang wrote:
> On Wed, Jun 23, 2010 at 11:06:04AM +0800, Dave Chinner wrote:
> > On Wed, Jun 23, 2010 at 09:34:26AM +0800, Wu Fengguang wrote:
> > > On Wed, Jun 23, 2010 at 06:45:51AM +0800, Dave Chinner wrote:
> > > > On Tue, Jun 22, 2010 at 04:38:56PM +0200, Jan Kara wrote:
> > > > > On Tue 22-06-10 10:31:24, Christoph Hellwig wrote:
> > > > > > On Tue, Jun 22, 2010 at 09:52:34PM +0800, Wu Fengguang wrote:
> > > > > > > 2) most writeback will be submitted by one per-bdi-flusher, so no worry
> > > > > > >    of cache bouncing (this also means the per CPU counter error is
> > > > > > >    normally bounded by the batch size)
> > > > > > 
> > > > > > What counter are we talking about exactly?  Once balanance_dirty_pages
> > > > >   The new per-bdi counter I'd like to introduce.
> > > > > 
> > > > > > stops submitting I/O the per-bdi flusher thread will in fact be
> > > > > > the only thing submitting writeback, unless you count direct invocations
> > > > > > of writeback_single_inode.
> > > > >   Yes, I agree that the per-bdi flusher thread should be the only thread
> > > > > submitting lots of IO (there is direct reclaim or kswapd if we change
> > > > > direct reclaim but those should be negligible). So does this mean that
> > > > > also I/O completions will be local to the CPU running per-bdi flusher
> > > > > thread? Because the counter is incremented from the I/O completion
> > > > > callback.
> > > > 
> > > > By default we set QUEUE_FLAG_SAME_COMP, which means we hand
> > > > completions back to the submitter CPU during blk_complete_request().
> > > > Completion processing is then handled by a softirq on the CPU
> > > > selected for completion processing.
> > > 
> > > Good to know about that, thanks!
> > > 
> > > > This was done, IIRC, because it provided some OLTP benchmark 1-2%
> > > > better results. It can, however, be turned off via
> > > > /sys/block/<foo>/queue/rq_affinity, and there's no guarantee that
> > > > the completion processing doesn't get handled off to some other CPU
> > > > (e.g. via a workqueue) so we cannot rely on this completion
> > > > behaviour to avoid cacheline bouncing.
> > > 
> > > If rq_affinity does not work reliably somewhere in the IO completion
> > > path, why not trying to fix it?
> > 
> > Because completion on the submitter CPU is not ideal for high
> > bandwidth buffered IO.
> 
> Yes there may be heavy post-processing for read data, however for writes
> it is mainly the pre-processing that costs CPU?

Could be either - delayed allocation requires significant pre-processing
for allocation. Avoiding this by using preallocation just
moves the processing load to IO completion which needs to issue
transactions to mark the region written.

> So perfect rq_affinity
> should always benefit write IO?

No, because the flusher thread gets to be CPU bound just writing
pages, allocating blocks and submitting IO. It might take 5-10GB/s
to get there (say a million dirty pages a second being processed by
a single CPU), but that's the sort of storage subsystem XFS is
capable of driving. IO completion time for such a workload is
significant, too, so putting that on the same CPU as the flusher
thread will slow things down by far more than gain from avoiding
cacheline bouncing.

> > > Otherwise all the page/mapping/zone
> > > cachelines covered by test_set_page_writeback()/test_clear_page_writeback()
> > > (and more other functions) will also be bounced.
> > 
> > Yes, but when the flusher thread is approaching being CPU bound for
> > high throughput IO, bouncing cachelines to another CPU during
> > completion costs far less in terms of throughput compared to
> > reducing the amount of time available to issue IO on that CPU.
> 
> Yes, reasonable for reads.

I was taking about writes - the flusher threads don't do any reading ;)

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
