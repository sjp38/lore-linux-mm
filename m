Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7208E6B0071
	for <linux-mm@kvack.org>; Wed, 23 Jun 2010 19:42:54 -0400 (EDT)
Date: Thu, 24 Jun 2010 09:42:37 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through
 waiting for flusher thread
Message-ID: <20100623234237.GA23223@dastard>
References: <20100622131745.GB3338@quack.suse.cz>
 <20100622135234.GA11561@localhost>
 <20100622143124.GA15235@infradead.org>
 <20100622143856.GG3338@quack.suse.cz>
 <20100622224551.GS7869@dastard>
 <20100623013426.GA6706@localhost>
 <20100623030604.GM6590@dastard>
 <20100623032213.GA13068@localhost>
 <20100623060319.GN6590@dastard>
 <20100623062540.GA25103@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100623062540.GA25103@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "peterz@infradead.org" <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 23, 2010 at 02:25:40PM +0800, Wu Fengguang wrote:
> On Wed, Jun 23, 2010 at 02:03:19PM +0800, Dave Chinner wrote:
> > On Wed, Jun 23, 2010 at 11:22:13AM +0800, Wu Fengguang wrote:
> > > On Wed, Jun 23, 2010 at 11:06:04AM +0800, Dave Chinner wrote:
> > > > On Wed, Jun 23, 2010 at 09:34:26AM +0800, Wu Fengguang wrote:
> > > > > On Wed, Jun 23, 2010 at 06:45:51AM +0800, Dave Chinner wrote:
> > > > > > By default we set QUEUE_FLAG_SAME_COMP, which means we hand
> > > > > > completions back to the submitter CPU during blk_complete_request().
> > > > > > Completion processing is then handled by a softirq on the CPU
> > > > > > selected for completion processing.
> > > > > 
> > > > > Good to know about that, thanks!
> > > > > 
> > > > > > This was done, IIRC, because it provided some OLTP benchmark 1-2%
> > > > > > better results. It can, however, be turned off via
> > > > > > /sys/block/<foo>/queue/rq_affinity, and there's no guarantee that
> > > > > > the completion processing doesn't get handled off to some other CPU
> > > > > > (e.g. via a workqueue) so we cannot rely on this completion
> > > > > > behaviour to avoid cacheline bouncing.
> > > > > 
> > > > > If rq_affinity does not work reliably somewhere in the IO completion
> > > > > path, why not trying to fix it?
> > > > 
> > > > Because completion on the submitter CPU is not ideal for high
> > > > bandwidth buffered IO.
> > > 
> > > Yes there may be heavy post-processing for read data, however for writes
> > > it is mainly the pre-processing that costs CPU?
> > 
> > Could be either - delayed allocation requires significant pre-processing
> > for allocation. Avoiding this by using preallocation just
> > moves the processing load to IO completion which needs to issue
> > transactions to mark the region written.
> 
> Good point, thanks.
> 
> > > So perfect rq_affinity
> > > should always benefit write IO?
> > 
> > No, because the flusher thread gets to be CPU bound just writing
> > pages, allocating blocks and submitting IO. It might take 5-10GB/s
> > to get there (say a million dirty pages a second being processed by
> > a single CPU), but that's the sort of storage subsystem XFS is
> > capable of driving. IO completion time for such a workload is
> > significant, too, so putting that on the same CPU as the flusher
> > thread will slow things down by far more than gain from avoiding
> > cacheline bouncing.
> 
> So super fast storage is going to demand multiple flushers per bdi.
> And once we run multiple flushers for one bdi, it will again be
> beneficial to schedule IO completion to the flusher CPU :)

Yes - that is where we want to get to with XFS. But we don't have
multiple bdi-flusher thread support yet for any filesystem, so
I think it will be a while before the we can ignore this issue...

Cheers,

Dave.> 

-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
